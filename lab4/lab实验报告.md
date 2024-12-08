# lab4 实验报告

#### **练习1：分配并初始化一个进程控制块（需要编码）**

alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

```c
// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 2211459 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;
        proc->pid = -1;
        proc->cr3 = boot_cr3;
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
        proc->tf = NULL;
        proc->flags = 0;
        memset(proc->name, 0, PROC_NAME_LEN + 1);

    }
    return proc;
}
```

* **请说明proc_struct中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）**

在`proc_struct`结构体中，`struct context context`和`struct trapframe *tf`是两个关键成员变量，它们在进程管理和上下文切换中起着至关重要的作用。以下是它们的详细含义及在本实验中的具体作用：

### 1. `struct context context`

**结构**

```c
struct context {
    uintptr_t ra;
    uintptr_t sp;
    uintptr_t s0;
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};
```

#### **含义**

`struct context`通常用于保存和恢复进程的CPU寄存器状态，以便在不同进程之间进行上下文切换。具体来说，这个结构体包含了在上下文切换过程中需要保存的所有CPU寄存器，如通用寄存器、程序计数器（PC）、堆栈指针（SP）等。

#### **在本实验中的作用**

在本实验中，`context`成员用于实现内核态下的进程上下文切换。当操作系统调度器决定切换当前运行的进程时，`switch_to`函数会被调用，传入当前进程的`context`和下一个要运行的进程的`context`。具体流程如下：

1. **保存当前进程的上下文**：`switch_to`函数会将当前进程的CPU寄存器状态保存到其`context`结构体中。
2. **恢复下一个进程的上下文**：随后，`switch_to`函数会从下一个进程的`context`结构体中恢复CPU寄存器状态，使得下一个进程能够从它上次停止的地方继续执行。

这确保了每个进程在被切换出去时能够正确保存其执行状态，并在被切换回来时能够无缝继续执行。

### 2. `struct trapframe *tf`

**结构**

```c
struct trapframe {
    struct pushregs gpr;
    uintptr_t status;
    uintptr_t epc;
    uintptr_t badvaddr;
    uintptr_t cause;
};
```

#### **含义**

`struct trapframe`用于保存进程在发生陷入（trap，例如系统调用、异常或中断）时的CPU状态。它包含了进程在陷入点的寄存器状态、程序计数器、堆栈指针等信息，以便在陷入处理完成后能够正确恢复进程的执行。

#### **在本实验中的作用**

在本实验中，`tf`成员主要用于处理进程的陷入和系统调用。具体作用包括：

1. **保存陷入时的状态**：当进程执行到系统调用或发生中断时，当前的CPU状态（如寄存器值）会被保存到`trapframe`中。这确保了在陷入处理完成后，进程能够从正确的位置继续执行。
2. **进程复制与切换**：在`do_fork`函数中，`copy_thread`会复制父进程的`trapframe`到子进程的`tf`成员。这使得子进程在被调度运行时，能够正确地从`forkret`函数开始执行，模拟出一个新的独立进程。
3. **陷入返回**：在`forkret`函数中，通过调用`forkrets(current->tf)`，系统能够使用保存的`trapframe`信息恢复进程的执行状态，确保新创建的进程能够正确返回到用户态或继续执行其内核代码。

### **总结**

- **`struct context context`**：主要用于内核态下的进程上下文切换，保存和恢复进程的CPU寄存器状态，确保不同进程之间能够无缝切换。
- **`struct trapframe \*tf`**：用于保存陷入时的CPU状态，支持系统调用和异常处理，确保进程在陷入处理完成后能够正确恢复执行。

#### **练习2：为新创建的内核线程分配资源（需要编码）**

创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用**do_fork**函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们**实际需要"fork"的东西就是stack和trapframe**。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：

- 调用alloc_proc，首先获得一块用户信息块。
- 为进程分配一个内核栈。
- 复制原进程的内存管理信息到新进程（但内核线程不必做此事）
- 复制原进程上下文到新进程
- 将新进程添加到进程列表
- 唤醒新进程
- 返回新进程号

```c
/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4: 2211459 EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;
    }
    proc->parent = current;  // 子进程的父进程是当前进程
    if (setup_kstack(proc) == -E_NO_MEM) { 
        goto bad_fork_cleanup_proc;
    }
    if (copy_mm(clone_flags, proc) != 0) {  
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc, stack, tf);  
    bool interrupt_flag; 
    local_intr_save(interrupt_flag);  
    {  
        proc->pid = get_pid();  // 获取当前pid
        hash_proc(proc);
        list_add(&proc_list, &proc->list_link); 
        nr_process++;  // 更新进程数
    }
    local_intr_restore(interrupt_flag);  // 恢复之前的中断状态；
    wakeup_proc(proc);
    ret = proc->pid;
    

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

* **请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。**

get_pid函数：

```cpp
// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

在uCore操作系统中，**每个新`fork`出的线程都会被分配一个唯一的进程标识符（PID）**。这一机制的实现依赖于`get_pid`函数的设计和`do_fork`函数的调用逻辑。以下是详细的分析和理由：

### 1. `get_pid` 函数的作用

`get_pid`函数的主要职责是为新创建的进程（包括线程）分配一个唯一的PID。其核心逻辑如下：

- **PID分配策略**：
  - **循环递增**：函数通过递增`last_pid`来寻找下一个可用的PID。当`last_pid`达到`MAX_PID`时，重置为1，形成循环。
  - **冲突检测**：在分配过程中，`get_pid`会遍历当前所有进程（包括线程）的PID，确保新分配的PID未被占用。如果发现冲突，则继续递增`last_pid`，直到找到一个未被使用的PID。
  - **优化查找**：通过维护`next_safe`，函数尝试跳过已经被使用的PID范围，优化PID分配的效率。
- **唯一性保障**：
  - **静态断言**：`static_assert(MAX_PID > MAX_PROCESS);`确保PID的最大值大于系统允许的最大进程数，避免PID耗尽的情况。
  - **全局进程列表遍历**：通过遍历`proc_list`，`get_pid`确保每个分配的PID在全局范围内是唯一的。

### 2. `do_fork` 函数中的PID分配

在`do_fork`函数中，PID的分配流程如下：

1. **调用`alloc_proc`**：为新进程分配并初始化一个`proc_struct`结构体。
2. **设置内核栈和内存管理**：为新进程设置内核栈，并根据`clone_flags`决定是共享内存（创建线程）还是复制内存（创建独立进程）。
3. **调用`copy_thread`**：复制父进程的陷阱帧（trapframe），为新进程设置执行环境。
4. **分配PID**：通过`get_pid`函数为新进程分配一个唯一的PID。
5. **将新进程加入全局进程列表**：包括哈希表和`proc_list`，确保新PID在系统范围内的唯一性。
6. **设置新进程为可运行状态**：通过`wakeup_proc`使新进程进入可运行状态，等待调度器调度执行。

### 3. 线程与进程的PID分配

在uCore中，**线程被视为特殊的进程**，它们共享相同的内存空间但拥有独立的执行上下文。因此，**每个线程都会通过`do_fork`流程被分配一个独立的PID**。具体分析如下：

- **PID的唯一性**：由于`get_pid`函数在分配PID时会遍历所有进程（包括线程），确保每个PID在全局范围内唯一。因此，即使是创建多个线程，每个线程也会获得一个唯一的PID。
- **进程与线程的关系**：在`do_fork`中，无论是创建独立进程还是线程，都会调用`get_pid`进行PID分配。这意味着每个线程作为一个独立的`proc_struct`实例，也会拥有自己的PID。

### 4. 实验代码中的验证

在提供的代码中，`proc_init`函数初始化了`idleproc`和`initproc`，并为它们分配了不同的PID（0和1）。随后，通过`kernel_thread`创建新的线程，这些线程会调用`do_fork`，从而通过`get_pid`获取唯一的PID。这确保了系统中的每个进程和线程都有一个唯一的标识符。

### 5. 总结

- **唯一PID分配**：`get_pid`函数通过遍历全局进程列表，确保为每个新创建的进程或线程分配一个唯一的PID。
- **线程的PID**：在uCore中，线程作为特殊的进程，也会被分配独立的PID，确保与其他线程和进程的PID不冲突。
- **系统限制**：通过`static_assert(MAX_PID > MAX_PROCESS);`，系统确保PID的空间足够大，以避免PID耗尽导致的分配失败。

因此，**uCore确实为每个新`fork`的线程分配了一个唯一的PID**，这一机制通过`get_pid`函数和`do_fork`函数的协同工作得以实现，确保了系统中所有进程和线程的PID唯一性。

#### **练习3：编写proc_run 函数（需要编码）**

proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：

- 检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
- 禁用中断。你可以使用`/kern/sync/sync.h`中定义好的宏`local_intr_save(x)`和`local_intr_restore(x)`来实现关、开中断。
- 切换当前进程为要运行的进程。
- 切换页表，以便使用新进程的地址空间。`/libs/riscv.h`中提供了`lcr3(unsigned int cr3)`函数，可实现修改CR3寄存器值的功能。
- 实现上下文切换。`/kern/process`中已经预先编写好了`switch.S`，其中定义了`switch_to()`函数。可实现两个进程的context切换。
- 允许中断。

```c
// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4: 2211459 EXERCISE3 YOUR CODE
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
        bool flag = 0;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(flag); {
            current = proc;
            lcr3(next->cr3);
            switch_to(&(prev->context), &(next->context));
        }
        local_intr_restore(flag);
    }
}
```

* **在本实验的执行过程中，创建且运行了几个内核线程？**

在本实验的执行过程中，**创建且运行了两个内核线程**。具体分析如下：

### 1. 创建的内核线程

#### **1.1 `idleproc`（空闲进程）**

- **创建过程**：
  - 在`proc_init`函数中，首先调用`alloc_proc`分配并初始化一个`proc_struct`结构体，赋值给`idleproc`。
  - 设置`idleproc`的PID为`0`，状态为`PROC_RUNNABLE`，并分配其内核栈地址`bootstack`。
  - 使用`set_proc_name(idleproc, "idle")`将其命名为“idle”。
  - 将`idleproc`设置为当前进程`current`。
- **运行机制**：
  - `idleproc`执行`cpu_idle`函数，该函数包含一个无限循环，不断检查自身是否需要调度（`current->need_resched`），并在需要时调用调度器`schedule`。
  - 作为系统的空闲进程，`idleproc`在没有其他可运行进程时占用CPU资源，确保系统不会进入空转状态。

#### **1.2 `initproc`（初始化进程）**

- **创建过程**：
  - 在`proc_init`函数中，通过调用`kernel_thread(init_main, "Hello world!!", 0)`创建一个新的内核线程，该线程的入口函数为`init_main`。
  - `do_fork`函数负责分配一个新的`proc_struct`，设置其内核栈，复制父进程的内存管理结构（在本实验中`copy_mm`函数未实际实现），并分配一个唯一的PID（通常为`1`）。
  - 将新创建的进程添加到全局进程列表中，并调用`wakeup_proc(proc)`将其状态设置为`PROC_RUNNABLE`，使其能够被调度执行。
  - 使用`find_proc(pid)`找到新进程并赋值给`initproc`，并通过`set_proc_name(initproc, "init")`将其命名为“init”。
- **运行机制**：
  - `initproc`执行`init_main`函数，该函数主要用于初始化用户空间的主线程。在本实验中，`init_main`函数会打印相关信息并返回`0`，随后进程状态会被设置为`PROC_ZOMBIE`，等待被回收。

### 2. 运行的内核线程

在上述创建的两个内核线程中：

1. **`idleproc`**：
   - **作用**：作为系统的空闲进程，`idleproc`在系统没有其他可运行进程时占用CPU，确保系统处于活跃状态。
   - **执行函数**：`cpu_idle`，包含一个无限循环，等待调度。
2. **`initproc`**：
   - **作用**：作为系统的初始化进程，`initproc`负责启动用户空间的第一个用户进程。在本实验中，`init_main`函数的主要任务是打印初始化信息。
   - **执行函数**：`init_main`，打印信息并返回。

#### **扩展练习 Challenge：**

* **说明语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`是如何实现开关中断的？**

在操作系统内核开发中，**中断管理**是确保系统稳定性和一致性的关键机制。语句 `local_intr_save(intr_flag); ... local_intr_restore(intr_flag);` 在本实验中用于实现**临界区**的保护，确保在执行关键操作时不会被中断打断，从而避免数据竞争和状态不一致的问题。以下是对这两个宏的详细说明及其如何实现中断的开启与关闭：

### 1. **`local_intr_save(intr_flag)` 的作用**

#### **含义**

- **保存当前中断状态**：`local_intr_save` 宏的主要功能是**保存当前的中断使能状态**（即中断是否被启用），并**关闭本地CPU的中断**。这样可以确保在临界区内的操作不会被中断打断，从而避免潜在的竞态条件。

#### **实现机制**

- **读取当前中断状态**：通常，通过读取处理器的状态寄存器（如x86架构中的EFLAGS寄存器）来确定当前中断是否被启用。例如，在x86中，可以读取IF（中断标志位）来判断中断状态。
- **保存状态到变量**：将读取到的中断状态保存到传入的变量 `intr_flag` 中，以便稍后能够恢复到之前的状态。
- **关闭中断**：通过修改处理器的状态寄存器，**禁用中断**，确保后续的关键操作不会被中断打断。

### 2. **`local_intr_restore(intr_flag)` 的作用**

#### **含义**

- **恢复中断状态**：`local_intr_restore` 宏的功能是**根据保存的中断状态**，**恢复中断**的启用或禁用。这确保了在临界区操作完成后，系统的中断状态能够回到之前的状态，维持系统的正常运行。

#### **实现机制**

- **检查保存的状态**：根据之前保存的 `intr_flag` 的值，判断中断在进入临界区之前是处于启用还是禁用状态。
- **恢复中断**：如果 `intr_flag` 表示中断之前是启用的，则重新启用中断；否则，保持中断禁用状态。