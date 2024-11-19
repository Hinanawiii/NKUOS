### **1. 概述**

LRU（Least Recently Used）是一种经典的页面置换算法，其核心思想是优先替换最近最少使用的页面。这种算法假设最近访问过的页面在未来仍可能被访问，而长期未访问的页面更适合被替换。本次设计通过链表记录页面的访问顺序，并结合访问位（PTE_A）实现对页面访问频率的追踪，以模拟 LRU 算法。

------

### **2. 设计思路**

1. **目标**：
   - 选择最近最少使用的页面作为替换目标。
   - 在内存不足时，将访问最少的页面换出到磁盘。
2. **关键机制**：
   - 通过链表维护页面的管理顺序。
   - 使用访问位和访问次数结合，实现对页面访问频率的记录。
3. **工作流程**：
   - **页面插入**：每次将新页面插入到链表的头部。
   - **页面访问**：更新访问位，记录页面的使用次数。
   - **页面替换**：遍历链表，找到访问次数最少的页面进行替换。

------

### **3. 核心数据结构**

1. **链表**：
   - 记录所有可换出的页面，链表头部为最近访问的页面。
   - 每个页面通过 `pra_page_link` 连接，便于高效管理页面顺序。
2. **访问位（PTE_A）**：
   - 页表项中访问位标志页面是否被访问过。
   - 页面被访问时，硬件会设置 PTE_A。
3. **页面访问统计**：
   - 页面结构中新增 `visited` 字段，记录页面被访问的次数。
   - 用于页面替换时的比较。

------

### **4. 算法实现**

#### **4.1 初始化**

- 函数: _lru_init_mm

  - 功能：

    - 初始化页面链表 `pra_list_head`，用于管理所有可替换的页面。
    - 将链表头指针存储到 `mm->sm_priv` 中，便于后续操作。

  - 伪代码：

    ```
    static int _lru_init_mm(struct mm_struct *mm) {
        list_init(&pra_list_head);  // 初始化链表
        mm->sm_priv = &pra_list_head;  // 保存链表头指针
        return 0;
    }
    ```

------

#### **4.2 页面插入**

- 函数: _lru_map_swappable

  - 功能：

    - 当一个页面被标记为可换出时，将页面插入链表头部，表示它是最近被访问的页面。
    - 确保链表按照页面的访问顺序维护。

  - 伪代码：

    ```
    static int _lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
        list_entry_t *entry = &(page->pra_page_link);  // 获取页面链表节点
        assert(entry != NULL);
        list_entry_t *head = (list_entry_t *)mm->sm_priv;
        list_add_before(head, entry);  // 插入到链表头部
        return 0;
    }
    ```

------

#### **4.3 页面替换**

- 函数: _lru_swap_out_victim

  - 功能：

    - 遍历链表，选择最近最少使用的页面作为替换目标。
    - 更新每个页面的访问位 `PTE_A` 和 `visited` 值。
    - 将访问次数最少的页面从链表中移除。

  - 伪代码：

    ```
    static int _lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {
        list_entry_t *head = (list_entry_t *)mm->sm_priv;
        assert(head != NULL);
    
        if (head == list_next(head)) {
            cprintf("No pages to swap out.\n");
            return 0;  // 链表为空，无页面可替换
        }
    
        list_entry_t *victim = NULL;
        size_t min_visited = SIZE_MAX;  // 初始最小访问次数为最大值
        for (list_entry_t *entry = list_next(head); entry != head; entry = list_next(entry)) {
            struct Page *page = le2page(entry, pra_page_link);
            pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
            assert(ptep != NULL);
    
            if ((*ptep & PTE_A) != 0) {
                *ptep &= ~PTE_A;  // 清除访问位
                page->visited++;  // 增加访问次数
            }
    
            if (page->visited < min_visited) {
                min_visited = page->visited;  // 更新最小访问次数
                victim = entry;  // 记录最少访问页面
            }
        }
    
        assert(victim != NULL);  // 确保找到可替换页面
        list_del(victim);  // 从链表中移除
        *ptr_page = le2page(victim, pra_page_link);  // 返回被替换的页面
        return 0;
    }
    ```

------

#### **4.4 辅助调试**

- 函数: print_sm_priv_layout

  - 功能：

    - 打印当前链表中所有页面的布局，包括页面的虚拟地址和访问次数。
    - 用于调试和验证页面替换逻辑。

  - 伪代码：

    ```
    void print_sm_priv_layout(struct mm_struct *mm) {
        list_entry_t *head = (list_entry_t *)mm->sm_priv;
        if (head == list_next(head)) {
            cprintf("No pages in LRU list.\n");
            return;  // 链表为空
        }
    
        int index = 0;
        for (list_entry_t *entry = list_next(head); entry != head; entry = list_next(entry)) {
            index++;
            struct Page *page = le2page(entry, pra_page_link);
            cprintf("Page %d: vaddr = %p, visited = %d\n", index, page->pra_vaddr, page->visited);
        }
    }
    ```

------

#### **4.5 测试逻辑**

- 函数: _lru_check_swap
  - 功能：
    - 模拟页面访问与替换，验证 LRU 算法的正确性。
    - 检查页面替换是否按照最近最少使用的策略执行。
  - 测试逻辑：
    1. 初始化 4 个页面。
    2. 模拟页面 1 和 2 频繁访问，页面 3 和 4 偶尔访问。
    3. 访问新页面，验证最少使用的页面（页面 3 或 4）被替换。

------

### **5. 总结**

1. **优点**：
   - 精确选择最近最少使用的页面，降低页面缺失率。
   - 通过链表管理页面，逻辑清晰、易于扩展。
2. **缺点**：
   - 需要维护链表和访问统计，增加了一定的内存和计算开销。
   - 遍历链表选择替换页面，效率较低。
3. **适用场景**：
   - 适合需要精确管理内存访问频率的场景，如数据库和科学计算。
   - 不适合对实时性要求较高的场景。