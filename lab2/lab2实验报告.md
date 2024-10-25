# lab2实验报告

## 练习1：理解first-fit 连续物理内存分配算法

first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合`kern/mm/default_pmm.c`中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。 请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 你的first fit算法是否有进一步的改进空间？

### 一、总体概述

First-Fit 算法的核心思想是在空闲内存块列表中，从头开始查找，找到第一个足够大的空闲块来满足内存分配请求。如果找到的空闲块比请求的大小大，则需要将其拆分，分配所需的部分，剩余部分继续作为空闲块。

### 二、相关函数

#### 1. `default_init()`

- 初始化空闲链表 `free_list`，确保系统开始时没有空闲块记录。
- 将空闲页总数 `nr_free` 设为 0，表示当前没有任何空闲页。

------

#### 2. `default_init_memmap(struct Page *base, size_t n)`

- 对从 `base` 开始的 `n` 个连续页进行初始化，清除 `flags` 和 `property`。
- 设置第一个页的 `property`，表示该页块的大小为 `n`，并设置该页的 `PageProperty` 标志，表示这是一个空闲块的起始页。
- 将该空闲块插入到空闲链表 `free_list` 中，按地址顺序排列，以便后续合并空闲块。
- 更新空闲页总数 `nr_free`。

------

#### 3. `default_alloc_pages(size_t n)`

- 从空闲链表的头部开始遍历，查找第一个大小大于等于 `n` 的空闲块。
- 若找到合适的空闲块：
  - 如果块的大小刚好等于 `n`，则分配整个块。
  - 如果块的大小大于 `n`，则分配前 `n` 页，剩余部分重新插入空闲链表。
- 更新空闲页数 `nr_free`。
- 返回分配的页的起始地址；若未找到合适的空闲块，返回 `NULL`。

------

#### 4. `default_free_pages(struct Page *base, size_t n)`

- 将从 `base` 开始的 `n` 个页标记为空闲，清除 `flags` 并设置 `property`。
- 按地址顺序将释放的页块插入空闲链表。
- 尝试与前后相邻的空闲块合并，减少内存碎片。
- 更新空闲页数 `nr_free`。

------

#### 5. `default_nr_free_pages()`

- 直接返回当前记录的空闲页总数 `nr_free`，用于检查剩余的内存空间。

------

#### 6. `basic_check()` 和 `default_check()`

- `basic_check()` 会执行简单的分配、释放和引用计数检查。
- `default_check()` 执行更复杂的检查，验证分配、释放、合并等功能是否正确工作。

### 三、实现过程

#### 1. 初始化（`default_init` 和 `default_init_memmap`）

- **目的**：初始化内存管理器，建立空闲页链表。
- **步骤**：
  1. 调用 `default_init` 函数，初始化空闲链表 `free_list`，并将空闲页计数 `nr_free` 设为 0。
  2. 使用 `default_init_memmap` 将指定的页块标记为空闲，并按地址顺序插入到空闲链表中。每个空闲块的起始页设置 `property`，记录块大小，并标记 `PageProperty`。

------

#### 2. 分配内存（`default_alloc_pages`）

- **目的**：分配指定数量的连续页块。
- **步骤**：
  1. 从空闲链表的头部开始，遍历每个空闲块，找到第一个大小不小于请求页数 `n` 的空闲块。
  2. 如果找到合适的空闲块：
     - 若块大小等于请求大小，则将整个块分配出去，并从空闲链表中删除。
     - 若块大小大于请求大小，将该块拆分：
       - 将前 `n` 页分配出去。
       - 更新剩余空闲块的大小和起始位置，将其重新插入空闲链表。
  3. 更新空闲页数 `nr_free` 并返回分配的页块地址。
  4. 如果没有找到合适的块，返回 `NULL` 表示分配失败。

------

#### 3. 释放内存（`default_free_pages`）

- **目的**：释放指定的连续页块，并将其归还到空闲链表中，尝试合并相邻的空闲块。
- **步骤**：
  1. 将释放的页块标记为空闲，清除相关标志。
  2. 按照地址顺序将该空闲块插入空闲链表，便于后续的合并操作。
  3. 尝试与前后相邻的空闲块合并：
     - 若前一个空闲块与当前块相邻，则合并两个块并更新属性。
     - 若后一个空闲块与当前块相邻，也进行合并。
  4. 更新空闲页总数 `nr_free`。

### 四、改进空间

#### 1. 减少遍历次数（提高查找效率）

**问题**：First-Fit 算法每次分配内存时，都从链表的头部开始遍历空闲块，直到找到一个合适的块。这会导致在大量空闲块的情况下，分配操作的效率下降，尤其是空闲块数量多时。

**改进**：

- **Next-Fit 算法**：记住上次查找成功的位置，下次分配时从该位置继续查找，而不是每次都从头开始。这可以减少遍历的次数，特别是在内存碎片较多的情况下。
- **哈希表结合链表**：通过哈希表快速定位特定大小范围的块，减少线性遍历的开销。

#### 2. 减少外部碎片

**问题**：First-Fit 容易产生外部碎片（即大量的小块空闲内存分散在整个内存空间中），当碎片足够小且分散时，可能无法满足大块内存的分配需求。

**改进**：

- **Best-Fit 算法**：在分配时选择最接近请求大小的空闲块，减少剩余小块的产生，从而减少碎片。
- **Buddy System**：通过将内存划分为 2 的幂次大小分块，分配时分裂大块，释放时合并相邻块，能够有效减少碎片，并且提高合并效率。

#### 3. 优化空闲块的合并策略

**问题**：当前的实现会在释放内存时尝试合并相邻的空闲块，但在一些情况下可能会遗漏合并，或过于频繁地执行合并操作，导致性能下降。

**改进**：

- **延迟合并策略**：可以设置一个阈值，在空闲块碎片数量或总碎片大小达到一定程度时，进行全局的合并操作，而不是每次释放内存都进行合并。这可以减少频繁的合并操作。
- **使用双链表优化合并**：双向链表允许在释放内存时，快速找到前后相邻的空闲块，从而更高效地进行合并。

## 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）

在完成练习一后，参考kern/mm/default_pmm.c对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。 请在实验报告中简要说明你的设计实现过程，阐述代码是如何对物理内存进行分配和释放，并回答如下问题：

- 你的 Best-Fit 算法是否有进一步的改进空间？

​	运行结果：

```
>>>>>>>>>> here_make>>>>>>>>>>>
gmake[1]: Entering directory '/home/thealuka/OS/NKUOS/lab2' + cc kern/init/entry.S + cc kern/init/init.c + cc kern/libs/stdio.c + cc kern/debug/kdebug.c + cc kern/debug/kmonitor.c + cc kern/debug/panic.c + cc kern/driver/clock.c + cc kern/driver/console.c + cc kern/driver/intr.c + cc kern/trap/trap.c + cc kern/trap/trapentry.S + cc kern/mm/best_fit_pmm.c + cc kern/mm/default_pmm.c + cc kern/mm/pmm.c + cc libs/printfmt.c + cc libs/readline.c + cc libs/sbi.c + cc libs/string.c + ld bin/kernel riscv64-unknown-elf-objcopy bin/kernel --strip-all -O binary bin/ucore.img gmake[1]: Leaving directory '/home/thealuka/OS/NKUOS/lab2'
>>>>>>>>>> here_make>>>>>>>>>>>
<<<<<<<<<<<<<<< here_run_qemu <<<<<<<<<<<<<<<<<<
try to run qemu
qemu pid=12573
<<<<<<<<<<<<<<< here_run_check <<<<<<<<<<<<<<<<<<
  -check physical_memory_map_information:    OK
  -check_best_fit:                           OK
  -check ticks:                              OK
Total Score: 30/30
```

## 扩展练习Challenge：硬件的可用物理内存范围的获取方法

- 如果 OS 无法提前知道当前硬件的可用物理内存范围，请问你有何办法让 OS 获取可用物理内存范围？

### 1. BIOS 或 UEFI 调用

BIOS（Basic Input/Output System）和 UEFI（Unified Extensible Firmware Interface）是硬件和操作系统之间的接口，负责在操作系统启动前提供硬件信息。BIOS和UEFI通常提供内存布局信息，以帮助操作系统识别物理内存的可用范围。

- **BIOS内存映射接口**： 在传统的BIOS系统中，内存映射信息可以通过调用BIOS中断 `INT 15h` 获取（此方法多用于16位模式）。使用`INT 15h, AX=E820h` 中断，BIOS会返回一系列结构体，每个结构体描述一个内存块的地址范围和类型。常见的内存类型包括：

  - 可用内存
  - 保留内存（如BIOS和内核数据）
  - ACPI数据
  - 保留的设备内存（例如显卡内存）

  操作系统通过解析这些结构体，能够识别哪些内存块可用于分配，哪些则不可用。

- **UEFI内存映射**： 在现代系统中，BIOS逐渐被UEFI取代。UEFI提供了`GetMemoryMap()` 函数，直接返回内存映射的结构体。此结构体提供了详细的内存区域信息，包括内存地址、长度、内存类型和属性。UEFI内存类型定义比BIOS更丰富，支持标识各种设备区域和ACPI表等。

  操作系统在启动时可以调用`GetMemoryMap()` 来查询系统的内存布局，将返回的内存结构体存储到内核的数据结构中，以用于后续的内存管理。

### 2. 引导加载程序（Bootloader）传递内存信息

引导加载程序（如GRUB或LILO）负责加载和启动操作系统内核。许多引导加载程序支持在引导过程中检测和传递内存布局信息，以帮助操作系统快速了解物理内存的可用范围。

- **引导加载程序的内存检测**： 引导加载程序在系统启动时，会调用BIOS/UEFI接口或利用其他硬件接口来检测物理内存布局。GRUB等现代引导加载程序通常会使用UEFI的`GetMemoryMap()`或BIOS的`INT 15h, AX=E820h`获取内存映射。
- **向操作系统传递内存布局**： 检测完成后，引导加载程序会将内存信息传递给操作系统内核。通常采用的方式是将内存信息存储在指定的内存位置，或者通过传递内核命令行参数的形式传入。操作系统内核在初始化阶段会读取这些信息并解析，以便准确管理内存。
- **GRUB示例**： 对于GRUB引导的系统，GRUB会自动获取内存布局，并通过 `Multiboot` 协议将内存信息传递给内核。内核可以在启动时读取 `Multiboot` 信息结构体中的 `mmap` 字段，从中解析出每个内存块的地址、大小和类型。

### 3. ACPI（高级配置与电源接口）

ACPI（Advanced Configuration and Power Interface）是一个开放标准接口，允许操作系统和硬件之间进行高级电源管理和配置。ACPI规范中包含的表格信息可以帮助操作系统获取当前硬件的内存布局和可用范围。

- **ACPI表格的类型**： ACPI提供了许多表格，每个表格都包含不同类型的硬件信息。内存布局信息通常包含在SRAT（System Resource Affinity Table）和SLIT（System Locality Information Table）等表格中。此外，ACPI的MADT（Multiple APIC Description Table）表格包含中断控制器信息。
- **解析ACPI表格**： 操作系统在启动时可以读取ACPI根表（RSDP - Root System Description Pointer）来定位其他ACPI表格。这些表格通常通过物理地址或虚拟地址映射存放在低地址空间。操作系统解析这些表格后，可以识别系统中哪些内存块可用，哪些内存块保留给硬件或设备使用。
- **ACPI内存布局的优势**： 使用ACPI获取内存信息的好处在于其标准化。无论硬件类型或厂商如何，ACPI都提供了统一的接口，使操作系统能够在各种硬件配置上可靠地检测内存布局。ACPI的设计使其能够支持热插拔设备、NUMA等复杂系统架构，使其更适用于现代系统。