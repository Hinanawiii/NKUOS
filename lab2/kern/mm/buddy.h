#ifndef __BUDDY_H__
#define __BUDDY_H__

#include <assert.h>
#include "pmm.h"
#include <list.h>

// 宏定义，用于操作伙伴系统树
#define TREE_ROOT (1)
#define LEFT_CHILD(idx) ((idx) << 1)
#define RIGHT_CHILD(idx) (((idx) << 1) + 1)
#define PARENT(idx) ((idx) >> 1)
#define IS_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
#define NEXT_POWER_OF_2(x) (IS_POWER_OF_2(x) ? (x) : (1 << (32 - clz(x))))

// 伙伴系统内存管理器结构体
extern const struct pmm_manager buddy_pmm_manager;

// 函数声明，用于伙伴系统内存管理
void buddy_init(void);
void buddy_init_memmap(struct Page *base, size_t n);
size_t buddy_nr_free_pages(void);
struct Page *buddy_allocate_pages(size_t n);
void buddy_free_pages(struct Page *base, size_t n);


static inline int clz(size_t x) {
    int count = 0;
    while (x != 0) {
        x >>= 1;
        count++;
    }
    return (sizeof(size_t) * 8) - count;
}

#endif /* __BUDDY_H__ */
