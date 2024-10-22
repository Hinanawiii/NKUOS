#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy.h>
#include <memlayout.h>

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static size_t total_size;           // 总物理内存大小
static size_t tree_size;            // 伙伴系统树的大小
static size_t *tree_nodes;          // 用于记录节点信息的数组
static struct Page *memory_area;    // 内存的起始地址

#define TREE_ROOT (1)
#define LEFT_CHILD(idx) ((idx) << 1)
#define RIGHT_CHILD(idx) (((idx) << 1) + 1)
#define PARENT(idx) ((idx) >> 1)
#define IS_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
#define NEXT_POWER_OF_2(x) (IS_POWER_OF_2(x) ? (x) : (1 << (32 - __builtin_clz(x))))

static void buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p;
    for (p = base; p < base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
    }
    total_size = n;
    tree_size = NEXT_POWER_OF_2(n);  // 计算出最近的 2 的幂次大小
    memory_area = base;
    tree_nodes = (size_t *)KADDR(page2pa(base));
    memset(tree_nodes, 0, tree_size * sizeof(size_t));

    nr_free = n;
    tree_nodes[TREE_ROOT] = n;
    list_add(&free_list, &base->page_link);
    base->property = n;
    set_page_ref(base, 0);
    SetPageProperty(base);
}

static struct Page *buddy_allocate_pages(size_t n) {
    assert(n > 0);
    n = NEXT_POWER_OF_2(n);  // 将请求的页面数量调整为 2 的幂次

    size_t idx = TREE_ROOT;
    while (idx < tree_size) {
        if (tree_nodes[idx] >= n) {
            if (tree_nodes[idx] == n) {
                // 找到刚好合适的块
                tree_nodes[idx] = 0;
                struct Page *page = &memory_area[(idx - TREE_ROOT) * (total_size / tree_size)];
                list_del(&page->page_link);
                nr_free -= n;
                return page;
            } else {
                // 继续向下查找
                size_t left = LEFT_CHILD(idx);
                size_t right = RIGHT_CHILD(idx);
                if (tree_nodes[left] >= n) {
                    idx = left;
                } else {
                    idx = right;
                }
            }
        } else {
            break;
        }
    }
    return NULL;  // 没有足够大的块可供分配
}

static void buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    n = NEXT_POWER_OF_2(n);  // 将释放的页面数量调整为 2 的幂次

    size_t idx = (base - memory_area) / (total_size / tree_size) + TREE_ROOT;
    tree_nodes[idx] = n;
    nr_free += n;

    // 尝试合并伙伴块
    while (idx != TREE_ROOT) {
        size_t parent = PARENT(idx);
        size_t sibling = (idx == LEFT_CHILD(parent)) ? RIGHT_CHILD(parent) : LEFT_CHILD(parent);
        if (tree_nodes[sibling] == tree_nodes[idx]) {
            // 伙伴块大小相同，进行合并
            tree_nodes[parent] = tree_nodes[idx] << 1;
            tree_nodes[sibling] = 0;
            tree_nodes[idx] = 0;
            idx = parent;
        } else {
            break;
        }
    }
    list_add(&free_list, &base->page_link);
}

static size_t buddy_nr_free_pages(void) {
    return nr_free;
}

static void buddy_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = buddy_allocate_pages(1)) != NULL);
    assert((p1 = buddy_allocate_pages(1)) != NULL);
    assert((p2 = buddy_allocate_pages(1)) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    buddy_free_pages(p0, 1);
    buddy_free_pages(p1, 1);
    buddy_free_pages(p2, 1);
    assert(buddy_nr_free_pages() == 3);

    assert((p0 = buddy_allocate_pages(2)) != NULL);
    assert((p1 = buddy_allocate_pages(1)) != NULL);
    assert(buddy_nr_free_pages() == 0);

    buddy_free_pages(p0, 2);
    buddy_free_pages(p1, 1);
    assert(buddy_nr_free_pages() == 3);
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_allocate_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
