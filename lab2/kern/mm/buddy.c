#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy.h>
#include <memlayout.h>
#include <stdio.h>

// 伙伴系统内存管理的空闲区域
static free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static size_t total_size;           // 总物理内存大小
static size_t full_tree_size;       // 内存管理的完整二叉树大小
static size_t record_area_size;     // 记录节点信息的区域大小
static size_t real_tree_size;       // 实际可分配内存区域的大小
static size_t *record_area;         // 记录区域节点的指针
static struct Page *physical_area;  // 物理内存的起始地址
static struct Page *allocate_area;  // 可分配区域的起始地址

// 处理伙伴树操作的实用常量
#define TREE_ROOT (1)
#define LEFT_CHILD(idx) ((idx) << 1)
#define RIGHT_CHILD(idx) (((idx) << 1) + 1)
#define PARENT(idx) ((idx) >> 1)
#define NODE_LENGTH(idx) (full_tree_size / POWER_ROUND_DOWN(idx))
#define NODE_BEGINNING(idx) (POWER_REMAINDER(idx) * NODE_LENGTH(idx))
#define NODE_ENDING(idx) ((POWER_REMAINDER(idx) + 1) * NODE_LENGTH(idx))
#define BUDDY_EMPTY(idx) (record_area[(idx)] == NODE_LENGTH(idx))

#define OR_SHIFT_RIGHT(a, n) ((a) | ((a) >> (n)))
#define ALL_BIT_TO_ONE(a) (OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(OR_SHIFT_RIGHT(a, 1), 2), 4), 8), 16))
#define POWER_REMAINDER(a) ((a) & (ALL_BIT_TO_ONE(a) >> 1))
#define POWER_ROUND_UP(a) (POWER_REMAINDER(a) ? (((a)-POWER_REMAINDER(a)) << 1) : (a))
#define POWER_ROUND_DOWN(a) (POWER_REMAINDER(a) ? ((a)-POWER_REMAINDER(a)) : (a))

// 初始化伙伴系统内存管理
void buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
    cprintf("[DEBUG] Initialized buddy system.\n");
}

// 初始化伙伴系统的内存映射
void buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    cprintf("[DEBUG] buddy_init_memmap: Start initialization. Base address: %p, Number of pages: %lu\n", base, (unsigned long)n);
    
    struct Page *p;
    for (p = base; p < base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
    }
    cprintf("[DEBUG] buddy_init_memmap: Cleared page flags and properties for all pages.\n");

    total_size = n;
    cprintf("[DEBUG] buddy_init_memmap: Set total_size to %lu.\n", (unsigned long)total_size);

    if (n < 512) {
        full_tree_size = POWER_ROUND_UP(n - 1);
        record_area_size = 1;
        cprintf("[DEBUG] buddy_init_memmap: n < 512, full_tree_size set to %lu, record_area_size set to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
    } else {
        full_tree_size = POWER_ROUND_DOWN(n);
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
        cprintf("[DEBUG] buddy_init_memmap: n >= 512, initial full_tree_size set to %lu, initial record_area_size set to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
        if (n > full_tree_size + (record_area_size << 1)) {
            full_tree_size <<= 1;
            record_area_size <<= 1;
            cprintf("[DEBUG] buddy_init_memmap: Expanded full_tree_size to %lu, expanded record_area_size to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
        }
    }

    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
    cprintf("[DEBUG] buddy_init_memmap: Set real_tree_size to %lu.\n", (unsigned long)real_tree_size);

    physical_area = base;
    record_area = KADDR(page2pa(base));
    allocate_area = base + record_area_size;
    cprintf("[DEBUG] buddy_init_memmap: Set physical_area to %p, record_area to %p, allocate_area to %p.\n", physical_area, record_area, allocate_area);

    cprintf("[DEBUG] About to clear record_area. record_area address: %p, record_area_size: %lu, size to clear: %lu bytes.\n", record_area, (unsigned long)record_area_size, (unsigned long)(record_area_size * PGSIZE));
    memset(record_area, 0, record_area_size * PGSIZE);
    cprintf("[DEBUG] buddy_init_memmap: Cleared record_area with size %lu pages.\n", (unsigned long)record_area_size);

    nr_free += real_tree_size;
    cprintf("[DEBUG] buddy_init_memmap: Updated nr_free to %lu.\n", (unsigned long)nr_free);

    size_t block = TREE_ROOT;
    size_t real_subtree_size = real_tree_size;
    size_t full_subtree_size = full_tree_size;

    record_area[block] = real_subtree_size;
    cprintf("[DEBUG] buddy_init_memmap: Initialized record_area at root block %lu with size %lu.\n", (unsigned long)block, (unsigned long)real_subtree_size);

    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size) {
        full_subtree_size >>= 1;
        cprintf("[DEBUG] buddy_init_memmap: Reduced full_subtree_size to %lu.\n", (unsigned long)full_subtree_size);
        if (real_subtree_size > full_subtree_size) {
            struct Page *page = &allocate_area[NODE_BEGINNING(block)];
            page->property = full_subtree_size;
            list_add(&free_list, &page->page_link);
            set_page_ref(page, 0);
            SetPageProperty(page);
            cprintf("[DEBUG] buddy_init_memmap: Added page at %p with size %lu to free_list.\n", page, (unsigned long)full_subtree_size);

            record_area[LEFT_CHILD(block)] = full_subtree_size;
            real_subtree_size -= full_subtree_size;
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size %lu.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)full_subtree_size, (unsigned long)RIGHT_CHILD(block), (unsigned long)real_subtree_size);

            block = RIGHT_CHILD(block);
        } else {
            record_area[LEFT_CHILD(block)] = real_subtree_size;
            record_area[RIGHT_CHILD(block)] = 0;
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size 0.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)real_subtree_size, (unsigned long)RIGHT_CHILD(block));

            block = LEFT_CHILD(block);
        }
    }

    if (real_subtree_size > 0) {
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
        page->property = real_subtree_size;
        set_page_ref(page, 0);
        SetPageProperty(page);
        list_add(&free_list, &page->page_link);
        cprintf("[DEBUG] buddy_init_memmap: Added remaining page at %p with size %lu to free_list.\n", page, (unsigned long)real_subtree_size);
    }

    cprintf("[DEBUG] Initialized memory map. Total size: %lu, Full tree size: %lu, Record area size: %lu, Real tree size: %lu\n", (unsigned long)total_size, (unsigned long)full_tree_size, (unsigned long)record_area_size, (unsigned long)real_tree_size);
}


// 使用伙伴系统分配页面
struct Page *buddy_allocate_pages(size_t n) {
    assert(n > 0);
    struct Page *page;
    size_t block = TREE_ROOT;
    size_t length = POWER_ROUND_UP(n);

    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
        size_t left = LEFT_CHILD(block);
        size_t right = RIGHT_CHILD(block);
        if (BUDDY_EMPTY(block)) {
            size_t begin = NODE_BEGINNING(block);
            size_t end = NODE_ENDING(block);
            size_t mid = (begin + end) >> 1;
            list_del(&allocate_area[begin].page_link);
            allocate_area[begin].property >>= 1;
            allocate_area[mid].property = allocate_area[begin].property;
            record_area[left] = record_area[block] >> 1;
            record_area[right] = record_area[block] >> 1;
            list_add(&free_list, &allocate_area[begin].page_link);
            list_add(&free_list, &allocate_area[mid].page_link);
            block = left;
        } else if (length & record_area[left]) {
            block = left;
        } else if (length & record_area[right]) {
            block = right;
        } else if (length <= record_area[left]) {
            block = left;
        } else if (length <= record_area[right]) {
            block = right;
        }
    }
    if (length > record_area[block]) {
        cprintf("[DEBUG] Allocation failed. Requested: %lu\n", n);
        return NULL;
    }
    page = &allocate_area[NODE_BEGINNING(block)];
    list_del(&page->page_link);
    record_area[block] = 0;
    nr_free -= length;
    while (block != TREE_ROOT) {
        block = PARENT(block);
        record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
    }
    cprintf("[DEBUG] Allocated %lu pages.\n", n);
    return page;
}

// 使用伙伴系统释放页面
void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    size_t length = POWER_ROUND_UP(n);
    size_t begin = (base - allocate_area);
    size_t end = begin + length;
    size_t block = (begin ^ (end - 1)) & (full_tree_size - 1); // 修复 BUDDY_BLOCK 的定义

    for (; p != base + n; p++) {
        assert(!PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = length;
    list_add(&free_list, &base->page_link);
    nr_free += length;
    record_area[block] = length;

    while (block != TREE_ROOT) {
        block = PARENT(block);
        size_t left = LEFT_CHILD(block);
        size_t right = RIGHT_CHILD(block);
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
            size_t lbegin = NODE_BEGINNING(left);
            size_t rbegin = NODE_BEGINNING(right);
            list_del(&allocate_area[lbegin].page_link);
            list_del(&allocate_area[rbegin].page_link);
            record_area[block] = record_area[left] << 1;
            allocate_area[lbegin].property = record_area[left] << 1;
            list_add(&free_list, &allocate_area[lbegin].page_link);
        } else {
            record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
        }
    }
    cprintf("[DEBUG] Freed %lu pages starting at address %p\n", n, base);
}

void buddy_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    cprintf("[DEBUG] buddy_check: Starting buddy allocator check.\n");

    // 分配三个页面，确保它们被成功分配
    assert((p0 = buddy_allocate_pages(1)) != NULL);
    cprintf("[DEBUG] buddy_check: Allocated p0 at address %p.\n", p0);
    assert((p1 = buddy_allocate_pages(1)) != NULL);
    cprintf("[DEBUG] buddy_check: Allocated p1 at address %p.\n", p1);
    assert((p2 = buddy_allocate_pages(1)) != NULL);
    cprintf("[DEBUG] buddy_check: Allocated p2 at address %p.\n", p2);

    // 确保分配的页面不同
    assert(p0 != p1 && p0 != p2 && p1 != p2);
    cprintf("[DEBUG] buddy_check: p0, p1, p2 are distinct pages.\n");

    // 确保每个页面的引用计数为0
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
    cprintf("[DEBUG] buddy_check: Reference counts of p0, p1, p2 are all zero.\n");

    // 释放这三个页面
    buddy_free_pages(p0, 1);
    cprintf("[DEBUG] buddy_check: Freed p0.\n");
    buddy_free_pages(p1, 1);
    cprintf("[DEBUG] buddy_check: Freed p1.\n");
    buddy_free_pages(p2, 1);
    cprintf("[DEBUG] buddy_check: Freed p2.\n");

    // 确保释放后空闲页数为3
    assert(buddy_nr_free_pages() == 3);
    cprintf("[DEBUG] buddy_check: Number of free pages after freeing p0, p1, p2 is %lu.\n", (unsigned long)buddy_nr_free_pages());

    // 分配2页和1页，确保正确分配
    assert((p0 = buddy_allocate_pages(2)) != NULL);
    cprintf("[DEBUG] buddy_check: Allocated 2 pages for p0 at address %p.\n", p0);
    assert((p1 = buddy_allocate_pages(1)) != NULL);
    cprintf("[DEBUG] buddy_check: Allocated 1 page for p1 at address %p.\n", p1);

    // 确保现在没有空闲页
    assert(buddy_nr_free_pages() == 0);
    cprintf("[DEBUG] buddy_check: Number of free pages after allocating p0 and p1 is %lu.\n", (unsigned long)buddy_nr_free_pages());

    // 释放之前分配的页面
    buddy_free_pages(p0, 2);
    cprintf("[DEBUG] buddy_check: Freed 2 pages for p0.\n");
    buddy_free_pages(p1, 1);
    cprintf("[DEBUG] buddy_check: Freed 1 page for p1.\n");

    // 确保所有页都已释放
    assert(buddy_nr_free_pages() == 3);
    cprintf("[DEBUG] buddy_check: Number of free pages after freeing p0 and p1 is %lu.\n", (unsigned long)buddy_nr_free_pages());

    cprintf("[DEBUG] buddy_check: Completed buddy allocator check.\n");
}


// 返回空闲页面的数量
size_t buddy_nr_free_pages(void) {
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
    return nr_free;
}

// 伙伴内存管理器的结构体
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_allocate_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};