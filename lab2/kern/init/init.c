#include <clock.h>
#include <console.h>
#include <defs.h>
#include <intr.h>
#include <kdebug.h>
#include <kmonitor.h>
#include <pmm.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <sbi.h>
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
inline void sbi_shutdown(void)
{
	({ register uintptr_t a0 asm ("a0") = (uintptr_t)(0); register uintptr_t a1 asm ("a1") = (uintptr_t)(0); register uintptr_t a2 asm ("a2") = (uintptr_t)(0); register uintptr_t a7 asm ("a7") = (uintptr_t)(8); asm volatile ("ecall" : "+r" (a0) : "r" (a1), "r" (a2), "r" (a7) : "memory"); a0; });
}

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    cons_init();  // init the console
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);

    print_kerninfo();

    // grade_backtrace();
    //idt_init();  // init interrupt descriptor table
    
    pmm_init();  // init physical memory management
    
    //idt_init();  // init interrupt descriptor table

    clock_init();   // init clock interrupt
    //intr_enable();  // enable irq interrupt

    
    
    /* do nothing */
    while (1)
        sbi_shutdown();;
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    mon_backtrace(0, NULL, NULL);
}

void __attribute__((noinline)) grade_backtrace1(int arg0, int arg1) {
    grade_backtrace2(arg0, (uintptr_t)&arg0, arg1, (uintptr_t)&arg1);
}

void __attribute__((noinline)) grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

void grade_backtrace(void) { grade_backtrace0(0, (uintptr_t)kern_init, 0xffff0000); }

static void lab1_print_cur_status(void) {
    static int round = 0;
    round++;
}

