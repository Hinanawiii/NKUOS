# Lab 5实验报告

#### **练习0：填写已有实验**

> 本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

#### **练习1: 加载应用程序并执行（需要编码）**

> **do_execv**函数调用`load_icode`（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充`load_icode`的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好`proc_struct`结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。
>
> 请在实验报告中简要说明你的设计实现过程。
>
> - 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

```C
/* LAB5: 2211459 EXERCISE1 YOUR CODE
* should set tf->gpr.sp, tf->epc, tf->status
* NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
*          tf->gpr.sp should be user stack top (the value of sp)
*          tf->epc should be entry point of user program (the value of sepc)
*          tf->status should be appropriate for user program (the value of sstatus)
*          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
*/
tf->gpr.sp = USTACKTOP;                                          // 设置f->gpr.sp为用户栈的顶部地址
tf->epc = elf->e_entry;                                          // 设置tf->epc为用户程序的入口地址
tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE); // 根据需要设置 tf->status 的值，清除 SSTATUS_SPP 和 SSTATUS_SPIE 位
```

#### 设计实现过程

在实现`load_icode`函数的第6步时，主要任务是为用户态进程建立相应的用户内存空间，并正确初始化`trapframe`结构，以确保进程能够从设定的起始执行地址开始执行。具体实现步骤如下：

1. **设置用户栈指针 (`sp`)**：
   - 将`trapframe`中的通用寄存器`sp`设置为用户栈的顶部地址`USTACKTOP`。这确保了用户态进程在执行时拥有正确的栈空间。
2. **设置程序入口地址 (`epc`)**：
   - 将`trapframe`中的`epc`寄存器设置为ELF头中的入口地址`elf->e_entry`。这保证了进程在调度到CPU执行时，从正确的入口点开始执行用户程序。
3. **设置状态寄存器 (`status`)**：
   - 从当前的status寄存器中读取值，并清除SSTATUS_SPP和SSTATUS_SPIE位。具体来说：
     - **`SSTATUS_SPP`**：设置为0，表示陷入内核态的上一次模式是用户态。
     - **`SSTATUS_SPIE`**：设置为1，使得陷入中断后能够恢复到中断前的状态。

**用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过**：

1. **内核初始化和空闲线程创建**：

   - `proc_init` 函数初始化了第一个内核线程 `idle`。
   - `kernel_thread` 创建了 `init` 内核线程。

2. **调度器的启动**：

   - `cpu_idle` 持续检查 `need_resched` 标志位。
   - 当需要调度时，调用 `schedule` 函数。
   - `schedule` 找到优先级最高的进程后，通过 `proc_run` 切换到新进程。

3. **切换到新进程**：

   - 在 `proc_run` 中，通过 `switch_to` 和加载 `cr3` 的方式切换到新进程。
   - 随后，返回到 `kernel_thread_entry`，执行指定的函数。

4. **进入 `init_main` 函数**：

   - 在 `init_main` 中，通过 `kernel_thread` 创建用户态主程序 `user_main`。
   - `user_main` 是一个占位符程序，会被 `KERNEL_EXECVE` 宏调用进行替换。

5. **加载用户态程序**：

   - `KERNEL_EXECVE` 最终调用 `kernel_execve`，内联汇编中设置 `a7` 寄存器值为 `10`，触发 `syscall` 系统调用。

   - 进入系统调用后，do_execve

      被调用：

     - 加载用户程序的二进制内容（通过 `load_icode`）。
     - 设置用户态进程的上下文（`trapframe`）。
     - 设置返回时的用户程序入口地址（`SPPC` 指向用户程序的入口点）。

6. **用户态进程的状态初始化**：

   - 进程状态被设置为 `sleeping`，等待状态为 `WT_CHILD`。
   - 调用 `schedule` 后，该进程切换到 `RUNNING` 状态。

7. **执行用户程序**：

   - `kernel_execve_ret` 设置返回地址。
   - 切换到用户态，并从 `initcode.s` 中的第一条指令开始执行。
   - 用户态程序的第一条指令由 `initcode.s` 设置，通常是进入主程序逻辑。

8. **主程序进入运行**：

   - 用户态程序的主逻辑开始运行。
   - 通过 `exit` 或 `fork` 等系统调用进行后续操作。

#### **练习2: 父进程复制自己的内存空间给子进程（需要编码）**

> 创建子进程的函数`do_fork`在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过`copy_range`函数（位于kern/mm/pmm.c中）实现的，请补充`copy_range`的实现，确保能够正确执行。
>
> 请在实验报告中简要说明你的设计实现过程。
>
> - 如何设计实现`Copy on Write`机制？给出概要设计，鼓励给出详细设计。
>
> > Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

```C
void *kva_src = page2kva(page);
void *kva_dst = page2kva(npage);
memcpy(kva_dst, kva_src, PGSIZE);
ret = page_insert(to, npage, start, perm);
assert(ret == 0);
```

如何设计实现`Copy on Write`机制？

见Challenge1设计文档

#### **练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现，以及系统调用的实现（不需要编码）**

#### 1. `fork/exec/wait/exit` 的执行流程分析**

##### **fork**

- 用户态操作:
  - 用户态调用 `fork()` 函数，通过系统调用封装后进入内核态。
- 内核态操作:
  - 触发 `sys_fork` 系统调用。
  - 内核通过 `do_fork` 分配新的进程控制块 (`proc_struct`)。
  - 调用 `alloc_proc` 为子进程分配内存，初始化 PCB。
  - 设置子进程的寄存器上下文 (`setup_kstack`)。
  - 使用 `copy_mm` 复制父进程的内存映射关系。
  - 调用 `copy_thread` 设置子进程的上下文。
  - 将子进程加入 `proc_list` 和 `hash_list`，并将状态设置为 `RUNNABLE`。
  - 返回子进程的 `PID` 给父进程。
- 返回用户态:
  - 父进程和子进程分别收到 `fork` 的返回值，父进程收到子进程的 `PID`，子进程收到返回值为 0。

------

##### **exec**

- 用户态操作:
  - 用户态调用 `exec()` 函数，通过封装后进入内核态。
- 内核态操作:
  - 触发 `sys_exec` 系统调用。
  - 在 `do_execve` 中，首先检查用户提供的程序是否合法。
  - 如果当前进程占用了内存，释放其页表和其他资源。
  - 调用 `load_icode` 将新程序的二进制文件加载到内存中。
  - 初始化 `trapframe`，设置新程序的入口地址和执行上下文。
  - 更新进程名称。
- 返回用户态:
  - `exec` 不返回到旧的用户态，而是直接进入新程序的入口地址开始执行。

------

##### **wait**

- 用户态操作:
  - 用户态调用 `wait()` 函数，通过封装后进入内核态。
- 内核态操作:
  - 触发 `sys_wait` 系统调用。
  - 在 `do_wait` 中，检查是否有子进程处于 `EXITED` 状态。
  - 如果没有，设置父进程状态为 `SLEEPING`，进入调度器等待。
  - 如果子进程退出，处理子进程的退出状态并释放资源。
  - 返回退出的子进程信息。
- 返回用户态:
  - 父进程从 `wait` 函数返回，收到子进程的退出信息。

------

##### **exit**

- 用户态操作:
  - 用户态调用 `exit()` 函数，通过封装后进入内核态。
- 内核态操作:
  - 触发 `sys_exit` 系统调用。
  - 在 do_exit 中，检查进程的资源并释放：
    - 释放内存管理资源。
    - 修改进程状态为 `EXITED`。
    - 如果父进程等待子进程，则唤醒父进程。
    - 如果没有父进程，将子进程交给 `init` 进程。
  - 将进程状态设为 `ZOMBIE`。
- 返回用户态:
  - 当前进程退出，不会返回用户态。

------

#### **2. 用户态与内核态交错执行分析**

- 用户态程序通过系统调用接口进入内核态，完成核心操作。
- 系统调用完成后，内核通过返回值或直接切换上下文将结果传递给用户态。
- 每个系统调用对应一个中断，内核通过中断号区分具体操作。
- 在内核态执行过程中，调度器可能切换其他进程的执行。

------

#### **3. 内核态执行结果返回给用户态的机制**

- **通过返回值**: 系统调用的返回值会通过寄存器或用户栈传递给用户态。
- **状态切换**: 像 `exec` 直接切换到新用户程序入口，不再返回旧用户态。

------

#### **4. 用户态进程的执行状态生命周期图**

以下是生命周期图，描述进程的状态及状态之间的转换：

```
+------------+      fork()     +-------------+     exit()     +-------------+
|  NEW       |  ------------> |  RUNNABLE   |  ----------->  |   ZOMBIE    |
+------------+                 +-------------+                 +-------------+
                                    ^  ^                             |
                                    |  |                             |
               sleep()/wait()/yield |  | schedule()                  |
                                    v  v                             |
                              +-------------+                        |
                              |  RUNNING    |------------------------+
                              +-------------+   exec()
```

#### **扩展练习 Challenge**

1. 实现 Copy on Write （COW）机制

   给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。

   这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。

   由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。

   这是一个big challenge.

​	首先，在 `vmm.c` 中设置共享标志，将 `dup_mmap` 中的 `share` 变量的值改为 1，启用共享：

```C
int dup_mmap(struct mm_struct *to, struct mm_struct *from) {
	bool share = 1;
}
```

​	然后，映射共享页面：在 `pmm.c` 中为 `copy_range` 添加了对共享的处理。如果 `share` 为 1，则子进程的页面会映射到父进程的页面，且在页表中将共享页面的权限设置为只读（清除 `PTE_W` 标志）。这样确保两个进程共享同一个页面的内容，但如果其中任意一个进程尝试写入该页面时，会触发写保护异常（COW 机制）。共享页面的引用计数会被正确管理，保证页面的内存资源不会被提前回收。

```C
int copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end,
               bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do {
        // call get_pte to find process A's pte according to the addr start
        pte_t *ptep = get_pte(from, start, 0), *nptep;
        if (ptep == NULL) {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
            continue;
        }
        // call get_pte to find process B's pte according to the addr start. If
        // pte is NULL, just alloc a PT
        if (*ptep & PTE_V) {
            if ((nptep = get_pte(to, start, 1)) == NULL) {
                return -E_NO_MEM;
            }
            uint32_t perm = (*ptep & PTE_USER);
            // get page from ptep
            struct Page *page = pte2page(*ptep);
            // alloc a page for process B
            struct Page *npage = alloc_page();
            assert(page != NULL);
            assert(npage != NULL);
            int ret = 0;
            if(share){
                //cprintf("ref::%d\n",page->ref);
                //page_ref_inc(page);
                 //cprintf("ref::%d\n",page->ref);
                //*ptep = pte_create(page2ppn(page), (~PTE_W) & perm);
                page_insert(from, page, start, perm & (~PTE_W));
                ret = page_insert(to, page, start, perm & (~PTE_W));
                //*nptep = *ptep;
            }else{
                uintptr_t src_kvaddr = (uintptr_t)page2kva(page);
                uintptr_t dst_kvaddr = (uintptr_t)page2kva(npage);
                memcpy((void *)dst_kvaddr, (void *)src_kvaddr, PGSIZE);
                ret = page_insert(to, npage, start, perm);
                assert(ret == 0);
            }
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}
```

​	最后，修改时拷贝，当程序尝试修改只读的内存页面时，会触发 Page Fault 中断，此时错误代码中 P=1 表示页面存在，W/R=1 表示因写入只读页面引发的错误。因此，当错误代码的最低两位均为 1 时，表明进程试图修改共享的页面。此时，内核需要执行写时复制（COW）操作：为当前进程分配一个新的页面，将原页面的内容复制到新页面，然后更新页表映射关系以指向新页面，最终允许当前进程继续写入。

```C
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
       
       if (*ptep & PTE_V) {
            
            assert((*ptep & PTE_W) == 0);//不可写引起的缺页
            struct Page *page = pa2page(PTE_ADDR(*ptep));  // 获取物理页
            //cprintf("start cow,page ref :%d\n",page->ref);
            // 2. 检查引用计数，判断是否需要复制
            if (page_ref(page) > 1) {
                //cprintf("REF > 1\n");
                perm = *ptep & 0xff; //获得权限
                // struct Page *new_page = alloc_page();  // 分配新物理页
                struct Page* new_page = pgdir_alloc_page(mm->pgdir, addr, perm|PTE_W);
                if (new_page == NULL) {
                    cprintf("cow alloc page failed\n");
                    goto failed;
                }
                // 3. 复制内存内容
                void *kva_src = page2kva(page);
                void *kva_dst = page2kva(new_page); 
                memcpy(kva_dst, kva_src, PGSIZE);
                // 4. 减少原页面引用计数
                page_ref_dec(page);
                return 0;
            }
            // 如果引用计数为1，直接修改权限
            else {
                *ptep |= PTE_W | PTE_R;
                return 0;
            }
        }
```

2. 测试样例

   > 写了一个测试样例可以观察出cow的逻辑的正确性，子进程用来修改页表，父进程用来观察页表，这样可以看出cow是否能正常工作。使用 yield();可以让子进程先运行

   ```c
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
   ```

   > 可以观察到逻辑的正确性

   ![image-20241221125910845](./lab5实验报告.assets/image-20241221125910845.png)

3. 说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？ 

### **用户程序何时被预先加载到内存中**

在本次实验中，用户程序在编译时被链接到内核中，并定义好了程序的起始位置和大小。在执行过程中，通过 `user_main()` 函数调用 `KERNEL_EXECVE` 宏，而 `KERNEL_EXECVE` 最终调用 `kernel_execve()` 函数，在 `kernel_execve()` 函数中调用 `load_icode()` 将用户程序的整段文件直接加载到内存中。这样，用户程序会在 `exec` 系统调用执行时被预先加载到内存中。

------

### **与常用操作系统的加载区别**

在常用的操作系统中，用户程序通常是存储在外部存储设备上的独立文件。当需要执行某个程序时，操作系统会从磁盘等存储介质中按需动态地加载程序到内存中。

相比之下，uCore 中的用户程序加载方式更加简单，用户程序在内核编译时就被链接进去，并在 `exec` 调用时一次性被加载到内存。这种加载方式避免了复杂的文件系统和动态加载机制的实现。

------

### **原因**

uCore 采用这种加载方式的原因是：

1. **教学和简化设计**：uCore 的目标是帮助学生理解操作系统的基本原理，简化实现复杂性，因此直接将用户程序编译到内核中，避免引入文件系统和硬件存储管理等额外模块。
2. **避免硬件依赖**：由于没有实现完整的硬盘管理和文件系统，直接将程序编译到内核中可以有效降低实现成本，同时保证系统运行的可控性。
3. **适应实验环境**：这种设计更符合教学实验的需求，让学生专注于学习内核和进程管理的基本概念。