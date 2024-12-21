#include <slab.h>
#include<pmm.h>
#include <memlayout.h>
#include <stdio.h>

//#define DEBUG
slab_cache_t kmallo_cache_8;
slab_cache_t kmallo_cache_16;
slab_cache_t kmallo_cache_32;
slab_cache_t kmallo_cache_64;
slab_cache_t kmallo_cache_128;
slab_cache_t kmallo_cache_256;
slab_cache_t kmallo_cache_512;
slab_cache_t kmallo_cache_1024;
#define NUM_SLAB_CACHES (sizeof(slab_caches) / sizeof(slab_caches[0]))
slab_cache_t* slab_caches[] = {
    &kmallo_cache_8,
    &kmallo_cache_16,
    &kmallo_cache_32,
    &kmallo_cache_64,
    &kmallo_cache_128,
    &kmallo_cache_256,
    &kmallo_cache_512,
    &kmallo_cache_1024
};
inline int standardsize(int size){
    size = size>>1 | size;
    size = size >> 2 | size;
    size = size >> 4 | size;
    size = size >> 8 | size;
    size = size >> 16 | size;
    size = (size + 1)>>1;
    if(size <= 8){
        return 8;
    }
    return size;
}



void init_cache(){
    int size = 8;
    int order = 1;
    slab_cache_t  * ptr2cache = NULL;
    //用于存储slab
    struct Page *page = (struct Page *)KADDR(page2pa(alloc_pages(1)));
    assert(8*sizeof(struct Page) < 4096);
    assert(page !=NULL);
    while(size <= 1024){
            switch (size) {
    case 8:
        ptr2cache = &kmallo_cache_8;
        break;
    case 16:
        ptr2cache = &kmallo_cache_16;
        break;
    case 32:
        ptr2cache = &kmallo_cache_32;
        break;
    case 64:
        ptr2cache = &kmallo_cache_64;
        break;
    case 128:   
        ptr2cache = &kmallo_cache_128;
        break;
    case 256:  
        ptr2cache = &kmallo_cache_256;
        break;
    case 512:  
        ptr2cache = &kmallo_cache_512;
        break;
    case 1024:  
        ptr2cache = &kmallo_cache_1024;
        break;
}

    ptr2cache -> page = page;
    page = page+1;
    ptr2cache -> order = order;
    struct Page *objspace = alloc_pages(order);
    assert(objspace !=NULL);
    char * color = (char *)KADDR(page2pa(objspace));
    int perpagespace = (4096 - 0x10)/size;
    #ifdef DEBUG
    cprintf("size = %d , perpagespace = %d,order = %d\n",size,perpagespace,order);
    #endif
    for(int i = 0; i < 4096*order; i+=4096){
        //着色0x10字节
        *((unsigned long *)(color + i)) = size;
        *((unsigned long *)(color + i+8)) = 0;//保留可以留在以后
        #ifdef DEBUG
        cprintf("i = %d,color = %d , aline = %d\n",\
        i/4096,*(unsigned long *)(color + i),*(unsigned long *)(color + i+8));
        #endif
    }





    ptr2cache ->page->freelist =(struct obj_list_entry *)KADDR(page2pa(\
        alloc_pages(((perpagespace*order*sizeof(struct obj_list_entry)+4095)&(~4095))/4096)));
    
    
    
    #ifdef DEBUG
     cprintf("freelist = %p,",ptr2cache ->page->freelist);
    cprintf("freelist space = %d,",perpagespace*order*sizeof(struct obj_list_entry));
    cprintf("freelist count = %d,",perpagespace*order);
    cprintf("freelist page order = %d\n",((perpagespace*order*sizeof(struct obj_list_entry)+4095)&(~4095))/4096);
    #endif
    
    //obj数量
    ptr2cache->objnum = perpagespace*order;
    //obj大小
    ptr2cache->sizeofobj = size;
    //初始化freelist
    struct obj_list_entry * setup =  ptr2cache ->page->freelist;
    for(int i = 0; i!= perpagespace*order;i++){
        setup->next = (struct obj_list_entry *)setup + 1;
        setup->next->prev = setup;
        
        #ifdef DEBUG
        cprintf("%p,%p,%p\n",setup,setup->next,setup->next->prev);
        #endif
        setup = setup + 1;
        if(i == perpagespace*order -1){
            setup->prev->next = NULL;
        }
    }    
    #ifdef DEBUG
    struct obj_list_entry *entry = ptr2cache ->page->freelist;
    while (entry) {
        cprintf("list number %p: %p\n", entry, entry->obj);
        entry = entry->next;
        }
    
    #endif


    //给freelist赋值
    struct obj_list_entry * temp = (struct obj_list_entry*)ptr2cache ->page->freelist;
    char * position = (char *)KADDR(page2pa(objspace));
    for(int i = 0; i < 4096*order; i+=4096){
        for(int j = 0;j<perpagespace;j++){
                temp->obj = (char*)(position+i+0x10)+j*size;
                temp = temp->next;
            }
    }
    ptr2cache->page->active = 0;
    order *= 2;
    size *= 2;
    }
}
void *kmalloc(int size){
    slab_cache_t* malloc_cache = NULL;
    if(size == 0){
        return NULL;
    }
    size = standardsize(size);
    int index = 0;
    while(size){
        size = size >> 1;
        index++;
    }
    malloc_cache = slab_caches[index-4];
    assert(malloc_cache != NULL);
    if(malloc_cache->objnum == malloc_cache->page->active){
        return NULL;
    }
    struct obj_list_entry * temp = malloc_cache->page->freelist;
    void * victim = temp->obj;
    temp -> obj =NULL;
    malloc_cache->page->freelist = temp->next;
    malloc_cache->page->active++;
    return victim;
}
void kfree(void *obj){
    unsigned long head = (unsigned long)obj & 0xFFFFFFFFFFFFF000;
    int size =*(unsigned long*)head;
    int index = 0;
    while(size){
        size = size >> 1;
        index++;
    }
    slab_cache_t* free_cache = slab_caches[index-4];
    assert(free_cache != NULL);
    free_cache->page->freelist->prev->obj == obj ;
    free_cache->page->freelist = free_cache->page->freelist->prev;
    free_cache->page ->active--;
}



void print_slab_cache_status(int size);
void check(){
    // 测试 size = 8
    void *obj = kmalloc(8);
    print_slab_cache_status(8);
    kfree(obj);
    print_slab_cache_status(8);
    //测试 size = 16
}
inline  void print_slab_cache_status(int size) {
    size = standardsize(size);
    int index = 0;
    while(size){
        size = size >> 1;
        index++;
    }
    slab_cache_t* cache = slab_caches[index-4];
    if (cache == NULL) {
        cprintf("Slab cache %d is NULL.\n", index-4);
        return;
    }

    cprintf("Slab cache %d status:\n", index-4);
    cprintf("  Total objects: %d\n", cache->objnum);
    cprintf("  Active objects: %d\n", cache->page->active);

    struct obj_list_entry* temp = cache->page->freelist;
    int free_count = 0;
    while (temp != NULL) {
        free_count++;
        temp = temp->next;
    }
    cprintf("  Free objects in freelist: %d\n", free_count);
}









void debug_print_slab_caches() {
    cprintf("===== Slab Cache Layout =====\n");

    for (int i = 0; i < NUM_SLAB_CACHES; i++) {
        slab_cache_t *cache = slab_caches[i];
        cprintf("Slab Cache %d:\n", i + 1);
        cprintf("  Order: %d\n", cache->order);
        cprintf("  Object Number: %d\n", cache->objnum);
        cprintf("  Size of Object: %d bytes\n", cache->sizeofobj);

        struct Page *page = cache->page;
        if (page) {
            cprintf("  Page Details:\n");
            cprintf("    Reference Count: %d\n", page->ref);
            cprintf("    Flags: 0x%lx\n", page->flags);
            cprintf("    Property: %u\n", page->property);
            cprintf("    Active Objects: %d\n", page->active);

            struct obj_list_entry *entry = page->freelist;
            int count = 0;
            cprintf("    Free Objects in Slab:\n");
            while (entry) {
                cprintf("      Free Object %d: %p\n", count, entry->obj);
                entry = entry->next;
                count++;
            }
            if (count == 0) {
                cprintf("      No free objects in this slab.\n");
            }
        } else {
            cprintf("  No associated Page.\n");
        }

        cprintf("\n");
    }

    cprintf("===== End of Slab Cache Layout =====\n");
}