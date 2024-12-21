
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#define PAGE_SIZE 4096
#define TEST_SIZE (4 * PAGE_SIZE)  // 测试4个页面

int
main(void) {
    // 1. 分配并初始化测试内存
    char buffer[TEST_SIZE];
    memset(buffer, 'A', TEST_SIZE);
    printf("Parent %04x: Initialize buffer with 'A'\n", getpid());
    
    // 2. 创建子进程
    int pid = fork();
    if (pid == 0) {
        // 子进程
        printf("Child  %04x: Original first byte: %c\n", getpid(), buffer[0]);
        
        // 修改第一个页面
        buffer[0] = 'B';
        printf("Child  %04x: Modified first byte to: %c\n", getpid(), buffer[0]);
        
        // 修改第二个页面
        buffer[PAGE_SIZE] = 'C';
        printf("Child  %04x: Modified page 2 first byte to: %c\n", 
                getpid(), buffer[PAGE_SIZE]);
        
        // 检查其他页面是否保持不变
        printf("Child  %04x: Page 3 first byte remains: %c\n",
                getpid(), buffer[PAGE_SIZE * 2]);
    }
    else {
        
        
        // 检查原始内存内容
        printf("Parent %04x: My first byte is still: %c\n", 
                getpid(), buffer[0]);
        printf("Parent %04x: Page 2 first byte is still: %c\n", 
                getpid(), buffer[PAGE_SIZE]);
        
        // 修改第三个页面
        buffer[PAGE_SIZE * 2] = 'D';
        printf("Parent %04x: Modified page 3 first byte to: %c\n",
                getpid(), buffer[PAGE_SIZE * 2]);
        
    }
    return 0;
}