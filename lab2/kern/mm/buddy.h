#ifndef __BUDDY_H__
#define __BUDDY_H__

#include <assert.h>
#include "pmm.h"
#include <list.h>

extern const struct pmm_manager buddy_pmm_manager;

static size_t clz(size_t x) {
    size_t count = 0;
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
    for (size_t i = sizeof(x) * 8 - 1; i >= 0; --i) {
        if (x & ((size_t)1 << i)) break;
        count++;
    }
    return count;
}


#endif /* __BUDDY_H__ */
