#ifndef __BUDDY_H__
#define __BUDDY_H__

#include <stddef.h>
#include <assert.h>
#include <pmm.h>
#include <list.h>

// 宏定义，用于操作伙伴系统树
#define TREE_ROOT (1)
#define LEFT_CHILD(idx) ((idx) << 1)
#define RIGHT_CHILD(idx) (((idx) << 1) + 1)
#define PARENT(idx) ((idx) >> 1)
#define IS_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
#define NEXT_POWER_OF_2(x) (IS_POWER_OF_2(x) ? (x) : (1 << (32 - __builtin_clz(x))))

// 伙伴系统内存管理器结构体
extern const struct pmm_manager buddy_pmm_manager;

// 初始化伙伴系统
void buddy_init(void);

// 初始化伙伴系统的内存映射
void buddy_init_memmap(struct Page *base, size_t n);

// 分配指定数量的页面
struct Page *buddy_allocate_pages(size_t n);

// 释放指定的页面
void buddy_free_pages(struct Page *base, size_t n);

// 获取当前空闲页面的数量
size_t buddy_nr_free_pages(void);

// 检查伙伴系统内存分配器的正确性
void buddy_check(void);

#endif /* __BUDDY_H__ */