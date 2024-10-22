#ifndef __BUDDY_H__
#define __BUDDY_H__

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

#endif /* __BUDDY_H__ */