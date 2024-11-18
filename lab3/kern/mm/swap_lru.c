#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

int count = 0;

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */

extern list_entry_t pra_list_head;
/*
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_lru_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL);
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_add_before(head, entry);
    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
void print_sm_priv_layout(struct mm_struct *mm);
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     cprintf("lru_swap_out_victim start\n");
     count++;
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
    
     assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    
    if(head==list_next(head)){
        cprintf("no page to swap out\n");
        return 0;
    }
    //更新访问位,并找到访问次数最少的页面
    size_t min = le2page(list_next(head), pra_page_link)->visited;
    list_entry_t *victim = list_next(head);
    for(list_entry_t *entry = list_next(head); entry != head; entry = list_next(entry)) {
        struct Page* currentpage = le2page(entry, pra_page_link);
        pte_t * currentpte = get_has_pte(mm->pgdir, currentpage->pra_vaddr);
        if(((*currentpte)&PTE_A) != 0) {
            pte_t newpte = *currentpte & ~PTE_A;
            *currentpte = newpte;
            currentpage->visited++;
        }
        size_t min = currentpage->visited;
        if(min>currentpage->visited){
            min = currentpage->visited;
            victim = entry;
        }
    }
    //删除victim
    list_del(victim);
    *ptr_page = le2page(victim, pra_page_link);
    cprintf("lru_swap_out_victim vaddr %x",(**ptr_page).pra_vaddr);
    return 0;

}
// 辅助函数：打印 sm_priv 中页面的布局
void print_sm_priv_layout(struct mm_struct *mm) {
    list_entry_t *head = (list_entry_t *) mm->sm_priv;
    assert(head != NULL);

    // 如果队列为空
    if (head == list_next(head)) {
        cprintf("No pages in FIFO list.\n");
        return;
    }

    list_entry_t *entry;
    struct Page *page;
    int i = 0;  // 计数器
    for (entry = list_next(head); entry != head; entry = list_next(entry)) {
        i++;
        cprintf("Page %d: ", i);
        page = le2page(entry, pra_page_link);
        // 打印页面的虚拟地址和访问次数
        cprintf("Page at vaddr: %p, visited: %d\n", page->pra_vaddr, page->visited);
    }
}
extern struct mm_struct *check_mm_struct;
static int
_lru_check_swap(void) {
#ifdef ucore_test
    int score = 0, totalscore = 5;
    cprintf("%d\n", &score);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    *(unsigned char *)0x2000 = 0x0b;
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    assert(pgfault_num==4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
#else 
    //已被初始化为 1 2 3 4
    /**(unsigned char *)0x3000 = 0x0c;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x1000 = 0x0a;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x4000 = 0x0d;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x2000 = 0x0b;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x5000 = 0x0e; //换页，换出1，其余visit+1
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x2000 = 0x0b;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x2000 = 0x0a;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x2000 = 0x0b;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x3000 = 0x0c;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x4000 = 0x0d;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x5000 = 0x0e;
    print_sm_priv_layout(check_mm_struct);
    *(unsigned char *)0x1000 = 0x0a; //换页，换出2，其余visit+1
    print_sm_priv_layout(check_mm_struct);*/
// 模拟页面访问，最大缓存 4 个页面，页面被频繁访问和替换 
// 页面 1 和 2 被频繁访问，页面 3 和 4 偶尔访问
*(unsigned char *)0x1000 = 0x01;  // 访问页面 1
*(unsigned char *)0x2000 = 0x02;  // 访问页面 2
*(unsigned char *)0x3000 = 0x03;  // 访问页面 3
*(unsigned char *)0x4000 = 0x04;  // 访问页面 4

// 页面 1 和 2 被频繁访问
*(unsigned char *)0x1000 = 0x01;  // 页面 1 继续访问
*(unsigned char *)0x2000 = 0x02;  // 页面 2 继续访问
*(unsigned char *)0x1000 = 0x01;  // 页面 1 继续访问

// 页面 5 访问，换出页面 3（最少访问）
*(unsigned char *)0x5000 = 0x05;  // 页面 5 访问
*(unsigned char *)0x2000 = 0x02;  // 页面 2 继续访问

// 页面 3 重新访问，换入页面 3
*(unsigned char *)0x3000 = 0x03;  // 页面 3 重新访问

*(unsigned char *)0x2000 = 0x02;  // 页面 2 继续访问

// 页面 7 访问，换出页面 1（最少访问）
*(unsigned char *)0x1000 = 0x01;  // 页面 1 重新访问，换入页面 1

// 页面 8 访问，换出页面 5（最少访问）
*(unsigned char *)0x2000 = 0x02;  // 页面 2 继续访问

// 页面 9 访问，换出页面 3（最少访问）
*(unsigned char *)0x3000 = 0x03;  // 页面 3 继续访问


// 页面 2 和 3 被频繁访问
*(unsigned char *)0x2000 = 0x02;  // 页面 2 继续访问
*(unsigned char *)0x3000 = 0x03;  // 页面 3 继续访问
*(unsigned char *)0x2000 = 0x02;  // 页面 2 继续访问




    cprintf("countttttttttttttttttttttttt = %d\n",count);
#endif
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};
