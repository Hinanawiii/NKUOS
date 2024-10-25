#include <stdio.h>
#include <assert.h>
#include "buddy.h"

#define PAGE_COUNT 1024

// 使用 extern 以引用全局的 pages 变量
extern struct Page *pages;

// 初始化所有页为保留页
void init_reserved_pages() {
    for (int i = 0; i < PAGE_COUNT; i++) {
        SetPageReserved(&pages[i]);
    }
}

// 测试伙伴系统分配器的分配与释放功能
void test_buddy_allocator() {
    cprintf("Initializing buddy allocator...\n");
    buddy_init();
    buddy_init_memmap(pages, PAGE_COUNT);

    cprintf("Initial free pages: %zu\n", buddy_nr_free_pages());
    if (!(buddy_nr_free_pages() == PAGE_COUNT)) {
        cprintf("Assertion failed: %s, at %s:%d\n", "buddy_nr_free_pages() == PAGE_COUNT", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }

    // 分配 10 页
    struct Page *alloc1 = buddy_allocate_pages(10);
    if (!(alloc1 != NULL)) {
        cprintf("Assertion failed: %s, at %s:%d\n", "alloc1 != NULL", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }
    cprintf("Allocated 10 pages. Free pages: %zu\n", buddy_nr_free_pages());
    if (!(buddy_nr_free_pages() == (PAGE_COUNT - 10))) {
        cprintf("Assertion failed: %s, at %s:%d\n", "buddy_nr_free_pages() == (PAGE_COUNT - 10)", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }

    // 分配 20 页
    struct Page *alloc2 = buddy_allocate_pages(20);
    if (!(alloc2 != NULL)) {
        cprintf("Assertion failed: %s, at %s:%d\n", "alloc2 != NULL", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }
    cprintf("Allocated 20 pages. Free pages: %zu\n", buddy_nr_free_pages());
    if (!(buddy_nr_free_pages() == (PAGE_COUNT - 30))) {
        cprintf("Assertion failed: %s, at %s:%d\n", "buddy_nr_free_pages() == (PAGE_COUNT - 30)", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }

    // 释放之前分配的 10 页
    buddy_free_pages(alloc1, 10);
    cprintf("Freed 10 pages. Free pages: %zu\n", buddy_nr_free_pages());
    if (!(buddy_nr_free_pages() == (PAGE_COUNT - 20))) {
        cprintf("Assertion failed: %s, at %s:%d\n", "buddy_nr_free_pages() == (PAGE_COUNT - 20)", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }

    // 分配 5 页
    struct Page *alloc3 = buddy_allocate_pages(5);
    if (!(alloc3 != NULL)) {
        cprintf("Assertion failed: %s, at %s:%d\n", "alloc3 != NULL", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }
    cprintf("Allocated 5 pages. Free pages: %zu\n", buddy_nr_free_pages());
    if (!(buddy_nr_free_pages() == (PAGE_COUNT - 25))) {
        cprintf("Assertion failed: %s, at %s:%d\n", "buddy_nr_free_pages() == (PAGE_COUNT - 25)", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }

    // 释放之前分配的 20 页
    buddy_free_pages(alloc2, 20);
    cprintf("Freed 20 pages. Free pages: %zu\n", buddy_nr_free_pages());
    if (!(buddy_nr_free_pages() == (PAGE_COUNT - 5))) {
        cprintf("Assertion failed: %s, at %s:%d\n", "buddy_nr_free_pages() == (PAGE_COUNT - 5)", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }

    // 释放之前分配的 5 页
    buddy_free_pages(alloc3, 5);
    cprintf("Freed 5 pages. Free pages: %zu\n", buddy_nr_free_pages());
    if (!(buddy_nr_free_pages() == PAGE_COUNT)) {
        cprintf("Assertion failed: %s, at %s:%d\n", "buddy_nr_free_pages() == PAGE_COUNT", __FILE__, __LINE__);
        while (1);  // Hang the system to indicate a critical failure
    }

    cprintf("All tests passed successfully.\n");
}

int main() {
    init_reserved_pages();
    test_buddy_allocator();
    return 0;
}
