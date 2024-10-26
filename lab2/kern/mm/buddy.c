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

static struct Page *record_area;    // 记录区域节点的指针
static struct Page *physical_area;  // 物理内存的起始地址
static struct Page *allocate_area;  // 可分配区域的起始地址

// 处理伙伴树操作的实用常量
// 伙伴树节点的起始索引，假设从0开始
#define TREE_ROOT 0
#define BUDDY_EMPTY(idx) (record_area[(idx)].property == NODE_LENGTH(idx))
#define NODE_LENGTH(idx) (full_tree_size / POWER_ROUND_DOWN(idx))
#define POWER_ROUND_DOWN(idx) (1 << (31 - clz(idx)))
#define max(a, b) ((a) > (b) ? (a) : (b))


static size_t power_round_up(size_t n) {
    return 1 << (32 - clz(n - 1));
}

// 初始化伙伴系统内存管理
static void buddy_init(void) {
    // 初始化空闲链表和空闲页面数
    list_init(&(free_list));
    nr_free = 0;

}

static bool stop_build = 0;

// 建立伙伴树的辅助函数（递归）
static void build_buddy_tree(size_t root, size_t full_tree_size, size_t real_tree_size,
                             struct Page *allocate_area, struct Page *record_area) {
    // 如果标志已设置，立即返回
    if (stop_build) {
        return;
    }

;

    // 增加终止条件：full_tree_size 或 real_tree_size 为 0 时返回
    if (full_tree_size == 0 || real_tree_size == 0) {
        stop_build = 1;

        return;
    }

    size_t left_size = full_tree_size / 2;
    size_t right_size = full_tree_size / 2;

    // 检查是否需要继续递归构建
    if (real_tree_size <= left_size) {
        build_buddy_tree(root * 2 + 1, left_size, real_tree_size, allocate_area, record_area);
    } else {
        build_buddy_tree(root * 2 + 1, left_size, left_size, allocate_area, record_area);
        build_buddy_tree(root * 2 + 2, right_size, real_tree_size - left_size,
                         allocate_area + left_size, record_area + left_size);
    }

    // 设置当前节点的属性
    record_area[root].property = full_tree_size;
    SetPageProperty(&record_area[root]);


    // 假设在某个条件下我们需要停止整个构建过程，比如错误检测到
    if (full_tree_size == 0 || real_tree_size == 0) {
        stop_build = 1;

    }
}



// 初始化内存映射，设置 n 个页面为可用状态
static void buddy_init_memmap(struct Page *base, size_t n) {
    // 1. 校验输入参数
    assert(n > 0);

    // 检查所有页面是否处于保留状态
    for (size_t i = 0; i < n; i++) {
        struct Page *page = base + i;
        assert(PageReserved(page));
    }

    // 2. 初始化每个页面的属性
    for (size_t i = 0; i < n; i++) {
        struct Page *page = base + i;
        page->flags = 0;
        page->property = 0;
        page->ref = 0;
        SetPageProperty(page);
    }

    // 3. 计算全局参数
    size_t full_tree_size;
    if (n < 512) {
        full_tree_size = 1 << (32 - clz(n - 1));
    } else {
        full_tree_size = 1 << (32 - clz(n));
    }

    size_t record_area_size = (full_tree_size * sizeof(struct Page)) / PGSIZE + 1;
    size_t real_tree_size = n - record_area_size;


    // 4. 检查是否需要调整树的大小
    while (n > full_tree_size + (record_area_size << 1)) {
        full_tree_size <<= 1; // 扩展树的大小，向上翻倍
        record_area_size = (full_tree_size * sizeof(struct Page)) / PGSIZE + 1;
        real_tree_size = n - record_area_size;

    }

    // 5. 初始化伙伴系统的区域
    physical_area = base;
    record_area = base + real_tree_size;
    allocate_area = physical_area;


    // 6. 建立初始的伙伴树
    build_buddy_tree(TREE_ROOT, full_tree_size, real_tree_size, allocate_area, record_area);


    // 7. 将初始块加入到空闲列表中
    base->property = real_tree_size;
    list_add(&free_list, &(base->page_link));
    nr_free += real_tree_size;


}



// 分配 n 页内存
static struct Page *buddy_allocate_pages(size_t n) {
    assert(n > 0);

    // 1. 参数检查与初始设置
    size_t length = power_round_up(n); // 请求的页数向上取整为 2 的幂次
    size_t block = TREE_ROOT;

    // 2. 遍历伙伴树查找合适的内存块
    while (length <= record_area[block].property) {
        size_t left = block * 2 + 1;   // 左子节点
        size_t right = block * 2 + 2;  // 右子节点
        size_t begin = block;          // 当前块的起始地址
        size_t end = begin + length;   // 当前块的结束地址

        if (BUDDY_EMPTY(block)) {
            // 如果当前节点为空，则进行分裂
            size_t full_subtree_size = record_area[block].property;
            size_t half_size = full_subtree_size / 2;

            // 分裂为左右子块
            record_area[left].property = half_size;
            record_area[right].property = half_size;
            list_add(&free_list, &record_area[left].page_link);
            list_add(&free_list, &record_area[right].page_link);
            
            // 更新当前节点为空闲列表状态
            record_area[block].property = 0; // 原块被分裂后不再空闲
        }

        // 判断进入左子节点或右子节点
        if (length <= record_area[left].property) {
            block = left;  // 进入左子节点
        } else if (length <= record_area[right].property) {
            block = right; // 进入右子节点
        } else {
            break; // 无法找到更小的块
        }
    }

    // 3. 检查是否找到合适的内存块
    if (record_area[block].property < length) {
        // 如果没有找到合适的块，返回 NULL
        return NULL;
    }

    // 4. 更新伙伴树和空闲链表
    struct Page *page = allocate_area + block; // 根据块索引计算页面起始地址
    list_del(&record_area[block].page_link);   // 从空闲列表中移除
    record_area[block].property = 0;           // 标记该块为已使用
    nr_free -= length;                         // 更新全局空闲页数

    // 5. 更新伙伴树的状态
    size_t parent_block = (block - 1) / 2;
    while (block != TREE_ROOT) {
        // 按位或更新父节点的状态，反映子节点的状态
        record_area[parent_block].property = 
            record_area[parent_block * 2 + 1].property |
            record_area[parent_block * 2 + 2].property;

        block = parent_block;
        parent_block = (block - 1) / 2;
    }

    // 6. 返回分配的页面指针
    return page;
}

static void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);

    // 1. 计算初始的 index 和 size
    size_t index = (base - allocate_area); // 根据 base 地址计算伙伴树中的索引
    size_t size = power_round_up(n);       // 向上取整到 2 的幂次
    size_t block = index + size - 1;       // 找到对应的叶子节点位置

    // 2. 找到第一个可以合并的伙伴节点
    while (block > 0 && !BUDDY_EMPTY(block)) {
        // 如果当前块不为空，向上移动以找到可以合并的位置
        block = (block - 1) / 2;  // 计算父节点索引
        size <<= 1;               // 每次上移，块的大小加倍
    }

    // 3. 释放指定的页面块
    struct Page *p;
    for (p = base; p != base + n; ++p) {
        assert(!PageReserved(p) && !PageProperty(p));
        SetPageProperty(p);        // 标记页面为可分配状态
        set_page_ref(p, 0);        // 重置引用计数
    }

    // 4. 更新伙伴树并合并节点
    record_area[block].property = size;    // 标记当前节点为可用的块大小
    while (block > 0) {
        size_t parent = (block - 1) / 2;
        size_t left = parent * 2 + 1;
        size_t right = left + 1;

        // 如果左右子节点可以合并，则更新父节点的状态
        if (record_area[left].property == size && record_area[right].property == size) {
            record_area[parent].property = size * 2;
            block = parent;       // 继续向上合并
            size <<= 1;
        } else {
            // 如果不能合并，则选择较大的子节点的值
            record_area[parent].property = max(record_area[left].property, record_area[right].property);
            break;
        }
    }

    // 5. 将释放的块重新加入空闲链表
    list_add(&free_list, &record_area[block].page_link);
    nr_free += n;

    
}
static size_t buddy_nr_free_pages(void) {
    return nr_free;
}


// 伙伴系统的检查函数
static void buddy_check(void) {
    size_t calculated_free_pages = 0;

    cprintf("Checking buddy system...\n");

    // 1. 检查空闲列表中的块状态
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
        struct Page *page = le2page(le, page_link);
        size_t order = page->property;

        // 检查空闲块的大小是否为 2 的幂次
        // assert(order > 0 && (order & (order - 1)) == 0);

        // 检查页面是否在空闲列表中
        assert(PageProperty(page));

        // 更新计算的空闲页数
        calculated_free_pages += order;

        le = list_next(le);
    }

    // 2. 检查伙伴树的状态
    for (size_t i = 0; i < full_tree_size; i++) {
        size_t left = i * 2 + 1;
        size_t right = i * 2 + 2;
        size_t parent = (i - 1) / 2;

        // 检查父节点的状态是否正确反映子节点的状态
        if (left < full_tree_size && right < full_tree_size) {
            size_t expected_property = 
                record_area[left].property + record_area[right].property;
            if (record_area[parent].property != expected_property) {
                cprintf("Error: Parent node %lu has property %lu, expected %lu.\n",
                       parent, record_area[parent].property, expected_property);
                assert(0);
            }
        }

        // 检查节点是否符合伙伴系统的空闲状态
        if (BUDDY_EMPTY(i)) {
            assert(record_area[i].property == NODE_LENGTH(i));
        } else {
            assert(record_area[i].property <= NODE_LENGTH(i));
        }
    }

    // 3. 验证 nr_free 的正确性
    if (calculated_free_pages != nr_free) {
        cprintf("Error: Calculated free pages %lu does not match nr_free %lu.\n",
               calculated_free_pages, nr_free);
        assert(0);
    }

    cprintf("Buddy system check passed. Total free pages: %lu.\n", nr_free);
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