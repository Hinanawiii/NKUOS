#include <ulib.h>
#include <stdio.h>
#include <string.h>

#define PAGE_SIZE 4096
#define TEST_SIZE (4 * PAGE_SIZE)  // 测试4个页面
char buffer[TEST_SIZE]={'A','A'};

//子进程修改，父进程查看
int
main(void) {
    // 1. 分配并初始化测试内存
    memset(buffer, 'A', TEST_SIZE);
    cprintf("Parent %04x: Initialize buffer with 'A'\n", getpid());
    
    // 2. 创建子进程
    int pid = fork();
    if (pid == 0) {
        // 子进程
        cprintf("Child  %04x: Original first byte: %c\n", getpid(), buffer[0]);
        
        // 修改第一个页面
        buffer[0] = 'B';
        cprintf("Child  %04x: Modified first byte to: %c\n", getpid(), buffer[0]);
        
        // 修改第二个页面
        buffer[PAGE_SIZE] = 'C';
        cprintf("Child  %04x: Modified page 2 first byte to: %c\n", 
                getpid(), buffer[PAGE_SIZE]);
        
        exit(0);
    }
    else {
        // 父进程
        yield();  // 让子进程先运行
        
        // 检查原始内存内容
        cprintf("Parent %04x: My first byte is still: %c\n", 
                getpid(), buffer[0]);
        cprintf("Parent %04x: Page 2 first byte is still: %c\n", 
                getpid(), buffer[PAGE_SIZE]);
        
        wait();
    }
    return 0;
}