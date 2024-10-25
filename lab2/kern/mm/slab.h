#ifndef __SLAB_H__
#define __SLAB_H__

#include <memlayout.h>
#define KMALLOC_CACHE(i) kmalloc_cache_##i
struct slab_cache{
    struct  Page *page; //指向slab结构体
    int order; //slab的阶数
    int objnum;
    int sizeofobj;
};

struct obj_list_entry {
    struct obj_list_entry *prev, *next;
    void * obj;
};


typedef struct slab_cache slab_cache_t;
extern slab_cache_t* slab_caches[];
extern slab_cache_t kmallo_cache_8;
extern slab_cache_t kmallo_cache_16;
extern slab_cache_t kmallo_cache_32;
extern slab_cache_t kmallo_cache_64;
extern slab_cache_t kmallo_cache_128;
extern slab_cache_t kmallo_cache_256;
extern slab_cache_t kmallo_cache_512;
extern slab_cache_t kmallo_cache_1024;
void * kmalloc();
void kfree();
void init_cache();
void debug_print_slab_caches();
void check();
#endif /* !_SLAB_H__ */