
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02062b7          	lui	t0,0xc0206
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop

    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00007517          	auipc	a0,0x7
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0207010 <free_area>
ffffffffc020003a:	00007617          	auipc	a2,0x7
ffffffffc020003e:	46660613          	addi	a2,a2,1126 # ffffffffc02074a0 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	1e9010ef          	jal	ra,ffffffffc0201a32 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3e4000ef          	jal	ra,ffffffffc0200432 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	9f650513          	addi	a0,a0,-1546 # ffffffffc0201a48 <etext+0x4>
ffffffffc020005a:	088000ef          	jal	ra,ffffffffc02000e2 <cputs>

    print_kerninfo();
ffffffffc020005e:	0d4000ef          	jal	ra,ffffffffc0200132 <print_kerninfo>

    // grade_backtrace();
    // idt_init();  // init interrupt descriptor table

    pmm_init();  // init physical memory management
ffffffffc0200062:	2fa010ef          	jal	ra,ffffffffc020135c <pmm_init>

    // idt_init();  // init interrupt descriptor table

    clock_init();   // init clock interrupt
ffffffffc0200066:	39a000ef          	jal	ra,ffffffffc0200400 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc020006a:	3d6000ef          	jal	ra,ffffffffc0200440 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc020006e:	a001                	j	ffffffffc020006e <kern_init+0x3c>

ffffffffc0200070 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200070:	1141                	addi	sp,sp,-16
ffffffffc0200072:	e022                	sd	s0,0(sp)
ffffffffc0200074:	e406                	sd	ra,8(sp)
ffffffffc0200076:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200078:	3bc000ef          	jal	ra,ffffffffc0200434 <cons_putc>
    (*cnt) ++;
ffffffffc020007c:	401c                	lw	a5,0(s0)
}
ffffffffc020007e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200080:	2785                	addiw	a5,a5,1
ffffffffc0200082:	c01c                	sw	a5,0(s0)
}
ffffffffc0200084:	6402                	ld	s0,0(sp)
ffffffffc0200086:	0141                	addi	sp,sp,16
ffffffffc0200088:	8082                	ret

ffffffffc020008a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020008a:	1101                	addi	sp,sp,-32
ffffffffc020008c:	862a                	mv	a2,a0
ffffffffc020008e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200090:	00000517          	auipc	a0,0x0
ffffffffc0200094:	fe050513          	addi	a0,a0,-32 # ffffffffc0200070 <cputch>
ffffffffc0200098:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020009c:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020009e:	4be010ef          	jal	ra,ffffffffc020155c <vprintfmt>
    return cnt;
}
ffffffffc02000a2:	60e2                	ld	ra,24(sp)
ffffffffc02000a4:	4532                	lw	a0,12(sp)
ffffffffc02000a6:	6105                	addi	sp,sp,32
ffffffffc02000a8:	8082                	ret

ffffffffc02000aa <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000aa:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ac:	02810313          	addi	t1,sp,40 # ffffffffc0206028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b0:	8e2a                	mv	t3,a0
ffffffffc02000b2:	f42e                	sd	a1,40(sp)
ffffffffc02000b4:	f832                	sd	a2,48(sp)
ffffffffc02000b6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b8:	00000517          	auipc	a0,0x0
ffffffffc02000bc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200070 <cputch>
ffffffffc02000c0:	004c                	addi	a1,sp,4
ffffffffc02000c2:	869a                	mv	a3,t1
ffffffffc02000c4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000c6:	ec06                	sd	ra,24(sp)
ffffffffc02000c8:	e0ba                	sd	a4,64(sp)
ffffffffc02000ca:	e4be                	sd	a5,72(sp)
ffffffffc02000cc:	e8c2                	sd	a6,80(sp)
ffffffffc02000ce:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000d2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000d4:	488010ef          	jal	ra,ffffffffc020155c <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000d8:	60e2                	ld	ra,24(sp)
ffffffffc02000da:	4512                	lw	a0,4(sp)
ffffffffc02000dc:	6125                	addi	sp,sp,96
ffffffffc02000de:	8082                	ret

ffffffffc02000e0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e0:	ae91                	j	ffffffffc0200434 <cons_putc>

ffffffffc02000e2 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000e2:	1101                	addi	sp,sp,-32
ffffffffc02000e4:	e822                	sd	s0,16(sp)
ffffffffc02000e6:	ec06                	sd	ra,24(sp)
ffffffffc02000e8:	e426                	sd	s1,8(sp)
ffffffffc02000ea:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000ec:	00054503          	lbu	a0,0(a0)
ffffffffc02000f0:	c51d                	beqz	a0,ffffffffc020011e <cputs+0x3c>
ffffffffc02000f2:	0405                	addi	s0,s0,1
ffffffffc02000f4:	4485                	li	s1,1
ffffffffc02000f6:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02000f8:	33c000ef          	jal	ra,ffffffffc0200434 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02000fc:	00044503          	lbu	a0,0(s0)
ffffffffc0200100:	008487bb          	addw	a5,s1,s0
ffffffffc0200104:	0405                	addi	s0,s0,1
ffffffffc0200106:	f96d                	bnez	a0,ffffffffc02000f8 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200108:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020010c:	4529                	li	a0,10
ffffffffc020010e:	326000ef          	jal	ra,ffffffffc0200434 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200112:	60e2                	ld	ra,24(sp)
ffffffffc0200114:	8522                	mv	a0,s0
ffffffffc0200116:	6442                	ld	s0,16(sp)
ffffffffc0200118:	64a2                	ld	s1,8(sp)
ffffffffc020011a:	6105                	addi	sp,sp,32
ffffffffc020011c:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020011e:	4405                	li	s0,1
ffffffffc0200120:	b7f5                	j	ffffffffc020010c <cputs+0x2a>

ffffffffc0200122 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200122:	1141                	addi	sp,sp,-16
ffffffffc0200124:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200126:	316000ef          	jal	ra,ffffffffc020043c <cons_getc>
ffffffffc020012a:	dd75                	beqz	a0,ffffffffc0200126 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020012c:	60a2                	ld	ra,8(sp)
ffffffffc020012e:	0141                	addi	sp,sp,16
ffffffffc0200130:	8082                	ret

ffffffffc0200132 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200132:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200134:	00002517          	auipc	a0,0x2
ffffffffc0200138:	93450513          	addi	a0,a0,-1740 # ffffffffc0201a68 <etext+0x24>
void print_kerninfo(void) {
ffffffffc020013c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020013e:	f6dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200142:	00000597          	auipc	a1,0x0
ffffffffc0200146:	ef058593          	addi	a1,a1,-272 # ffffffffc0200032 <kern_init>
ffffffffc020014a:	00002517          	auipc	a0,0x2
ffffffffc020014e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201a88 <etext+0x44>
ffffffffc0200152:	f59ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200156:	00002597          	auipc	a1,0x2
ffffffffc020015a:	8ee58593          	addi	a1,a1,-1810 # ffffffffc0201a44 <etext>
ffffffffc020015e:	00002517          	auipc	a0,0x2
ffffffffc0200162:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201aa8 <etext+0x64>
ffffffffc0200166:	f45ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020016a:	00007597          	auipc	a1,0x7
ffffffffc020016e:	ea658593          	addi	a1,a1,-346 # ffffffffc0207010 <free_area>
ffffffffc0200172:	00002517          	auipc	a0,0x2
ffffffffc0200176:	95650513          	addi	a0,a0,-1706 # ffffffffc0201ac8 <etext+0x84>
ffffffffc020017a:	f31ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020017e:	00007597          	auipc	a1,0x7
ffffffffc0200182:	32258593          	addi	a1,a1,802 # ffffffffc02074a0 <end>
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	96250513          	addi	a0,a0,-1694 # ffffffffc0201ae8 <etext+0xa4>
ffffffffc020018e:	f1dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200192:	00007597          	auipc	a1,0x7
ffffffffc0200196:	70d58593          	addi	a1,a1,1805 # ffffffffc020789f <end+0x3ff>
ffffffffc020019a:	00000797          	auipc	a5,0x0
ffffffffc020019e:	e9878793          	addi	a5,a5,-360 # ffffffffc0200032 <kern_init>
ffffffffc02001a2:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001a6:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001aa:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ac:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b0:	95be                	add	a1,a1,a5
ffffffffc02001b2:	85a9                	srai	a1,a1,0xa
ffffffffc02001b4:	00002517          	auipc	a0,0x2
ffffffffc02001b8:	95450513          	addi	a0,a0,-1708 # ffffffffc0201b08 <etext+0xc4>
}
ffffffffc02001bc:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001be:	b5f5                	j	ffffffffc02000aa <cprintf>

ffffffffc02001c0 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c0:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001c2:	00002617          	auipc	a2,0x2
ffffffffc02001c6:	97660613          	addi	a2,a2,-1674 # ffffffffc0201b38 <etext+0xf4>
ffffffffc02001ca:	04e00593          	li	a1,78
ffffffffc02001ce:	00002517          	auipc	a0,0x2
ffffffffc02001d2:	98250513          	addi	a0,a0,-1662 # ffffffffc0201b50 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001d6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001d8:	1cc000ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc02001dc <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001dc:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001de:	00002617          	auipc	a2,0x2
ffffffffc02001e2:	98a60613          	addi	a2,a2,-1654 # ffffffffc0201b68 <etext+0x124>
ffffffffc02001e6:	00002597          	auipc	a1,0x2
ffffffffc02001ea:	9a258593          	addi	a1,a1,-1630 # ffffffffc0201b88 <etext+0x144>
ffffffffc02001ee:	00002517          	auipc	a0,0x2
ffffffffc02001f2:	9a250513          	addi	a0,a0,-1630 # ffffffffc0201b90 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001f6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f8:	eb3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc02001fc:	00002617          	auipc	a2,0x2
ffffffffc0200200:	9a460613          	addi	a2,a2,-1628 # ffffffffc0201ba0 <etext+0x15c>
ffffffffc0200204:	00002597          	auipc	a1,0x2
ffffffffc0200208:	9c458593          	addi	a1,a1,-1596 # ffffffffc0201bc8 <etext+0x184>
ffffffffc020020c:	00002517          	auipc	a0,0x2
ffffffffc0200210:	98450513          	addi	a0,a0,-1660 # ffffffffc0201b90 <etext+0x14c>
ffffffffc0200214:	e97ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc0200218:	00002617          	auipc	a2,0x2
ffffffffc020021c:	9c060613          	addi	a2,a2,-1600 # ffffffffc0201bd8 <etext+0x194>
ffffffffc0200220:	00002597          	auipc	a1,0x2
ffffffffc0200224:	9d858593          	addi	a1,a1,-1576 # ffffffffc0201bf8 <etext+0x1b4>
ffffffffc0200228:	00002517          	auipc	a0,0x2
ffffffffc020022c:	96850513          	addi	a0,a0,-1688 # ffffffffc0201b90 <etext+0x14c>
ffffffffc0200230:	e7bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    }
    return 0;
}
ffffffffc0200234:	60a2                	ld	ra,8(sp)
ffffffffc0200236:	4501                	li	a0,0
ffffffffc0200238:	0141                	addi	sp,sp,16
ffffffffc020023a:	8082                	ret

ffffffffc020023c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020023c:	1141                	addi	sp,sp,-16
ffffffffc020023e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200240:	ef3ff0ef          	jal	ra,ffffffffc0200132 <print_kerninfo>
    return 0;
}
ffffffffc0200244:	60a2                	ld	ra,8(sp)
ffffffffc0200246:	4501                	li	a0,0
ffffffffc0200248:	0141                	addi	sp,sp,16
ffffffffc020024a:	8082                	ret

ffffffffc020024c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024c:	1141                	addi	sp,sp,-16
ffffffffc020024e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200250:	f71ff0ef          	jal	ra,ffffffffc02001c0 <print_stackframe>
    return 0;
}
ffffffffc0200254:	60a2                	ld	ra,8(sp)
ffffffffc0200256:	4501                	li	a0,0
ffffffffc0200258:	0141                	addi	sp,sp,16
ffffffffc020025a:	8082                	ret

ffffffffc020025c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020025c:	7115                	addi	sp,sp,-224
ffffffffc020025e:	ed5e                	sd	s7,152(sp)
ffffffffc0200260:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200262:	00002517          	auipc	a0,0x2
ffffffffc0200266:	9a650513          	addi	a0,a0,-1626 # ffffffffc0201c08 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	ed86                	sd	ra,216(sp)
ffffffffc020026c:	e9a2                	sd	s0,208(sp)
ffffffffc020026e:	e5a6                	sd	s1,200(sp)
ffffffffc0200270:	e1ca                	sd	s2,192(sp)
ffffffffc0200272:	fd4e                	sd	s3,184(sp)
ffffffffc0200274:	f952                	sd	s4,176(sp)
ffffffffc0200276:	f556                	sd	s5,168(sp)
ffffffffc0200278:	f15a                	sd	s6,160(sp)
ffffffffc020027a:	e962                	sd	s8,144(sp)
ffffffffc020027c:	e566                	sd	s9,136(sp)
ffffffffc020027e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200280:	e2bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200284:	00002517          	auipc	a0,0x2
ffffffffc0200288:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0201c30 <etext+0x1ec>
ffffffffc020028c:	e1fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    if (tf != NULL) {
ffffffffc0200290:	000b8563          	beqz	s7,ffffffffc020029a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200294:	855e                	mv	a0,s7
ffffffffc0200296:	382000ef          	jal	ra,ffffffffc0200618 <print_trapframe>
ffffffffc020029a:	00002c17          	auipc	s8,0x2
ffffffffc020029e:	a06c0c13          	addi	s8,s8,-1530 # ffffffffc0201ca0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002a2:	00002917          	auipc	s2,0x2
ffffffffc02002a6:	9b690913          	addi	s2,s2,-1610 # ffffffffc0201c58 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002aa:	00002497          	auipc	s1,0x2
ffffffffc02002ae:	9b648493          	addi	s1,s1,-1610 # ffffffffc0201c60 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002b2:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002b4:	00002b17          	auipc	s6,0x2
ffffffffc02002b8:	9b4b0b13          	addi	s6,s6,-1612 # ffffffffc0201c68 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002bc:	00002a17          	auipc	s4,0x2
ffffffffc02002c0:	8cca0a13          	addi	s4,s4,-1844 # ffffffffc0201b88 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c4:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002c6:	854a                	mv	a0,s2
ffffffffc02002c8:	616010ef          	jal	ra,ffffffffc02018de <readline>
ffffffffc02002cc:	842a                	mv	s0,a0
ffffffffc02002ce:	dd65                	beqz	a0,ffffffffc02002c6 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002d4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	e1bd                	bnez	a1,ffffffffc020033c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002d8:	fe0c87e3          	beqz	s9,ffffffffc02002c6 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002dc:	6582                	ld	a1,0(sp)
ffffffffc02002de:	00002d17          	auipc	s10,0x2
ffffffffc02002e2:	9c2d0d13          	addi	s10,s10,-1598 # ffffffffc0201ca0 <commands>
        argv[argc ++] = buf;
ffffffffc02002e6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002e8:	4401                	li	s0,0
ffffffffc02002ea:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ec:	712010ef          	jal	ra,ffffffffc02019fe <strcmp>
ffffffffc02002f0:	c919                	beqz	a0,ffffffffc0200306 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f2:	2405                	addiw	s0,s0,1
ffffffffc02002f4:	0b540063          	beq	s0,s5,ffffffffc0200394 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f8:	000d3503          	ld	a0,0(s10)
ffffffffc02002fc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fe:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	6fe010ef          	jal	ra,ffffffffc02019fe <strcmp>
ffffffffc0200304:	f57d                	bnez	a0,ffffffffc02002f2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200306:	00141793          	slli	a5,s0,0x1
ffffffffc020030a:	97a2                	add	a5,a5,s0
ffffffffc020030c:	078e                	slli	a5,a5,0x3
ffffffffc020030e:	97e2                	add	a5,a5,s8
ffffffffc0200310:	6b9c                	ld	a5,16(a5)
ffffffffc0200312:	865e                	mv	a2,s7
ffffffffc0200314:	002c                	addi	a1,sp,8
ffffffffc0200316:	fffc851b          	addiw	a0,s9,-1
ffffffffc020031a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020031c:	fa0555e3          	bgez	a0,ffffffffc02002c6 <kmonitor+0x6a>
}
ffffffffc0200320:	60ee                	ld	ra,216(sp)
ffffffffc0200322:	644e                	ld	s0,208(sp)
ffffffffc0200324:	64ae                	ld	s1,200(sp)
ffffffffc0200326:	690e                	ld	s2,192(sp)
ffffffffc0200328:	79ea                	ld	s3,184(sp)
ffffffffc020032a:	7a4a                	ld	s4,176(sp)
ffffffffc020032c:	7aaa                	ld	s5,168(sp)
ffffffffc020032e:	7b0a                	ld	s6,160(sp)
ffffffffc0200330:	6bea                	ld	s7,152(sp)
ffffffffc0200332:	6c4a                	ld	s8,144(sp)
ffffffffc0200334:	6caa                	ld	s9,136(sp)
ffffffffc0200336:	6d0a                	ld	s10,128(sp)
ffffffffc0200338:	612d                	addi	sp,sp,224
ffffffffc020033a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033c:	8526                	mv	a0,s1
ffffffffc020033e:	6de010ef          	jal	ra,ffffffffc0201a1c <strchr>
ffffffffc0200342:	c901                	beqz	a0,ffffffffc0200352 <kmonitor+0xf6>
ffffffffc0200344:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200348:	00040023          	sb	zero,0(s0)
ffffffffc020034c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034e:	d5c9                	beqz	a1,ffffffffc02002d8 <kmonitor+0x7c>
ffffffffc0200350:	b7f5                	j	ffffffffc020033c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200352:	00044783          	lbu	a5,0(s0)
ffffffffc0200356:	d3c9                	beqz	a5,ffffffffc02002d8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200358:	033c8963          	beq	s9,s3,ffffffffc020038a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020035c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200360:	0118                	addi	a4,sp,128
ffffffffc0200362:	97ba                	add	a5,a5,a4
ffffffffc0200364:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200368:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020036c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020036e:	e591                	bnez	a1,ffffffffc020037a <kmonitor+0x11e>
ffffffffc0200370:	b7b5                	j	ffffffffc02002dc <kmonitor+0x80>
ffffffffc0200372:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200376:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	d1a5                	beqz	a1,ffffffffc02002d8 <kmonitor+0x7c>
ffffffffc020037a:	8526                	mv	a0,s1
ffffffffc020037c:	6a0010ef          	jal	ra,ffffffffc0201a1c <strchr>
ffffffffc0200380:	d96d                	beqz	a0,ffffffffc0200372 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200382:	00044583          	lbu	a1,0(s0)
ffffffffc0200386:	d9a9                	beqz	a1,ffffffffc02002d8 <kmonitor+0x7c>
ffffffffc0200388:	bf55                	j	ffffffffc020033c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	45c1                	li	a1,16
ffffffffc020038c:	855a                	mv	a0,s6
ffffffffc020038e:	d1dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc0200392:	b7e9                	j	ffffffffc020035c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200394:	6582                	ld	a1,0(sp)
ffffffffc0200396:	00002517          	auipc	a0,0x2
ffffffffc020039a:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201c88 <etext+0x244>
ffffffffc020039e:	d0dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    return 0;
ffffffffc02003a2:	b715                	j	ffffffffc02002c6 <kmonitor+0x6a>

ffffffffc02003a4 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003a4:	00007317          	auipc	t1,0x7
ffffffffc02003a8:	08430313          	addi	t1,t1,132 # ffffffffc0207428 <is_panic>
ffffffffc02003ac:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b0:	715d                	addi	sp,sp,-80
ffffffffc02003b2:	ec06                	sd	ra,24(sp)
ffffffffc02003b4:	e822                	sd	s0,16(sp)
ffffffffc02003b6:	f436                	sd	a3,40(sp)
ffffffffc02003b8:	f83a                	sd	a4,48(sp)
ffffffffc02003ba:	fc3e                	sd	a5,56(sp)
ffffffffc02003bc:	e0c2                	sd	a6,64(sp)
ffffffffc02003be:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c0:	020e1a63          	bnez	t3,ffffffffc02003f4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003c4:	4785                	li	a5,1
ffffffffc02003c6:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003ca:	8432                	mv	s0,a2
ffffffffc02003cc:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ce:	862e                	mv	a2,a1
ffffffffc02003d0:	85aa                	mv	a1,a0
ffffffffc02003d2:	00002517          	auipc	a0,0x2
ffffffffc02003d6:	91650513          	addi	a0,a0,-1770 # ffffffffc0201ce8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003da:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	ccfff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e0:	65a2                	ld	a1,8(sp)
ffffffffc02003e2:	8522                	mv	a0,s0
ffffffffc02003e4:	ca7ff0ef          	jal	ra,ffffffffc020008a <vcprintf>
    cprintf("\n");
ffffffffc02003e8:	00003517          	auipc	a0,0x3
ffffffffc02003ec:	88850513          	addi	a0,a0,-1912 # ffffffffc0202c70 <commands+0xfd0>
ffffffffc02003f0:	cbbff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003f4:	052000ef          	jal	ra,ffffffffc0200446 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003f8:	4501                	li	a0,0
ffffffffc02003fa:	e63ff0ef          	jal	ra,ffffffffc020025c <kmonitor>
    while (1) {
ffffffffc02003fe:	bfed                	j	ffffffffc02003f8 <__panic+0x54>

ffffffffc0200400 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200400:	1141                	addi	sp,sp,-16
ffffffffc0200402:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200404:	02000793          	li	a5,32
ffffffffc0200408:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200410:	67e1                	lui	a5,0x18
ffffffffc0200412:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200416:	953e                	add	a0,a0,a5
ffffffffc0200418:	594010ef          	jal	ra,ffffffffc02019ac <sbi_set_timer>
}
ffffffffc020041c:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020041e:	00007797          	auipc	a5,0x7
ffffffffc0200422:	0007b923          	sd	zero,18(a5) # ffffffffc0207430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200426:	00002517          	auipc	a0,0x2
ffffffffc020042a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201d08 <commands+0x68>
}
ffffffffc020042e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200430:	b9ad                	j	ffffffffc02000aa <cprintf>

ffffffffc0200432 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200432:	8082                	ret

ffffffffc0200434 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200434:	0ff57513          	zext.b	a0,a0
ffffffffc0200438:	55a0106f          	j	ffffffffc0201992 <sbi_console_putchar>

ffffffffc020043c <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020043c:	58a0106f          	j	ffffffffc02019c6 <sbi_console_getchar>

ffffffffc0200440 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200440:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200444:	8082                	ret

ffffffffc0200446 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200446:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020044a:	8082                	ret

ffffffffc020044c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020044c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020044e:	1141                	addi	sp,sp,-16
ffffffffc0200450:	e022                	sd	s0,0(sp)
ffffffffc0200452:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200454:	00002517          	auipc	a0,0x2
ffffffffc0200458:	8d450513          	addi	a0,a0,-1836 # ffffffffc0201d28 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc020045c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020045e:	c4dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200462:	640c                	ld	a1,8(s0)
ffffffffc0200464:	00002517          	auipc	a0,0x2
ffffffffc0200468:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0201d40 <commands+0xa0>
ffffffffc020046c:	c3fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200470:	680c                	ld	a1,16(s0)
ffffffffc0200472:	00002517          	auipc	a0,0x2
ffffffffc0200476:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201d58 <commands+0xb8>
ffffffffc020047a:	c31ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020047e:	6c0c                	ld	a1,24(s0)
ffffffffc0200480:	00002517          	auipc	a0,0x2
ffffffffc0200484:	8f050513          	addi	a0,a0,-1808 # ffffffffc0201d70 <commands+0xd0>
ffffffffc0200488:	c23ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020048c:	700c                	ld	a1,32(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0201d88 <commands+0xe8>
ffffffffc0200496:	c15ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020049a:	740c                	ld	a1,40(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	90450513          	addi	a0,a0,-1788 # ffffffffc0201da0 <commands+0x100>
ffffffffc02004a4:	c07ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004a8:	780c                	ld	a1,48(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	90e50513          	addi	a0,a0,-1778 # ffffffffc0201db8 <commands+0x118>
ffffffffc02004b2:	bf9ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004b6:	7c0c                	ld	a1,56(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	91850513          	addi	a0,a0,-1768 # ffffffffc0201dd0 <commands+0x130>
ffffffffc02004c0:	bebff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004c4:	602c                	ld	a1,64(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	92250513          	addi	a0,a0,-1758 # ffffffffc0201de8 <commands+0x148>
ffffffffc02004ce:	bddff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004d2:	642c                	ld	a1,72(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	92c50513          	addi	a0,a0,-1748 # ffffffffc0201e00 <commands+0x160>
ffffffffc02004dc:	bcfff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02004e0:	682c                	ld	a1,80(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	93650513          	addi	a0,a0,-1738 # ffffffffc0201e18 <commands+0x178>
ffffffffc02004ea:	bc1ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02004ee:	6c2c                	ld	a1,88(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	94050513          	addi	a0,a0,-1728 # ffffffffc0201e30 <commands+0x190>
ffffffffc02004f8:	bb3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02004fc:	702c                	ld	a1,96(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201e48 <commands+0x1a8>
ffffffffc0200506:	ba5ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020050a:	742c                	ld	a1,104(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	95450513          	addi	a0,a0,-1708 # ffffffffc0201e60 <commands+0x1c0>
ffffffffc0200514:	b97ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200518:	782c                	ld	a1,112(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201e78 <commands+0x1d8>
ffffffffc0200522:	b89ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200526:	7c2c                	ld	a1,120(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	96850513          	addi	a0,a0,-1688 # ffffffffc0201e90 <commands+0x1f0>
ffffffffc0200530:	b7bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200534:	604c                	ld	a1,128(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	97250513          	addi	a0,a0,-1678 # ffffffffc0201ea8 <commands+0x208>
ffffffffc020053e:	b6dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200542:	644c                	ld	a1,136(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	97c50513          	addi	a0,a0,-1668 # ffffffffc0201ec0 <commands+0x220>
ffffffffc020054c:	b5fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200550:	684c                	ld	a1,144(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	98650513          	addi	a0,a0,-1658 # ffffffffc0201ed8 <commands+0x238>
ffffffffc020055a:	b51ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020055e:	6c4c                	ld	a1,152(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	99050513          	addi	a0,a0,-1648 # ffffffffc0201ef0 <commands+0x250>
ffffffffc0200568:	b43ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020056c:	704c                	ld	a1,160(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201f08 <commands+0x268>
ffffffffc0200576:	b35ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020057a:	744c                	ld	a1,168(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201f20 <commands+0x280>
ffffffffc0200584:	b27ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200588:	784c                	ld	a1,176(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0201f38 <commands+0x298>
ffffffffc0200592:	b19ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200596:	7c4c                	ld	a1,184(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0201f50 <commands+0x2b0>
ffffffffc02005a0:	b0bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005a4:	606c                	ld	a1,192(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201f68 <commands+0x2c8>
ffffffffc02005ae:	afdff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005b2:	646c                	ld	a1,200(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0201f80 <commands+0x2e0>
ffffffffc02005bc:	aefff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005c0:	686c                	ld	a1,208(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201f98 <commands+0x2f8>
ffffffffc02005ca:	ae1ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005ce:	6c6c                	ld	a1,216(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	9e050513          	addi	a0,a0,-1568 # ffffffffc0201fb0 <commands+0x310>
ffffffffc02005d8:	ad3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02005dc:	706c                	ld	a1,224(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0201fc8 <commands+0x328>
ffffffffc02005e6:	ac5ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02005ea:	746c                	ld	a1,232(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	9f450513          	addi	a0,a0,-1548 # ffffffffc0201fe0 <commands+0x340>
ffffffffc02005f4:	ab7ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02005f8:	786c                	ld	a1,240(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0201ff8 <commands+0x358>
ffffffffc0200602:	aa9ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200606:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200608:	6402                	ld	s0,0(sp)
ffffffffc020060a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020060c:	00002517          	auipc	a0,0x2
ffffffffc0200610:	a0450513          	addi	a0,a0,-1532 # ffffffffc0202010 <commands+0x370>
}
ffffffffc0200614:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200616:	bc51                	j	ffffffffc02000aa <cprintf>

ffffffffc0200618 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200618:	1141                	addi	sp,sp,-16
ffffffffc020061a:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020061c:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020061e:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200620:	00002517          	auipc	a0,0x2
ffffffffc0200624:	a0850513          	addi	a0,a0,-1528 # ffffffffc0202028 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200628:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020062a:	a81ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    print_regs(&tf->gpr);
ffffffffc020062e:	8522                	mv	a0,s0
ffffffffc0200630:	e1dff0ef          	jal	ra,ffffffffc020044c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200634:	10043583          	ld	a1,256(s0)
ffffffffc0200638:	00002517          	auipc	a0,0x2
ffffffffc020063c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0202040 <commands+0x3a0>
ffffffffc0200640:	a6bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200644:	10843583          	ld	a1,264(s0)
ffffffffc0200648:	00002517          	auipc	a0,0x2
ffffffffc020064c:	a1050513          	addi	a0,a0,-1520 # ffffffffc0202058 <commands+0x3b8>
ffffffffc0200650:	a5bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200654:	11043583          	ld	a1,272(s0)
ffffffffc0200658:	00002517          	auipc	a0,0x2
ffffffffc020065c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0202070 <commands+0x3d0>
ffffffffc0200660:	a4bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200664:	11843583          	ld	a1,280(s0)
}
ffffffffc0200668:	6402                	ld	s0,0(sp)
ffffffffc020066a:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020066c:	00002517          	auipc	a0,0x2
ffffffffc0200670:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0202088 <commands+0x3e8>
}
ffffffffc0200674:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200676:	bc15                	j	ffffffffc02000aa <cprintf>

ffffffffc0200678 <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200678:	00007797          	auipc	a5,0x7
ffffffffc020067c:	99878793          	addi	a5,a5,-1640 # ffffffffc0207010 <free_area>

// 初始化伙伴系统内存管理
void buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
    cprintf("[DEBUG] Initialized buddy system.\n");
ffffffffc0200680:	00002517          	auipc	a0,0x2
ffffffffc0200684:	a2050513          	addi	a0,a0,-1504 # ffffffffc02020a0 <commands+0x400>
ffffffffc0200688:	e79c                	sd	a5,8(a5)
ffffffffc020068a:	e39c                	sd	a5,0(a5)
    nr_free = 0;
ffffffffc020068c:	0007a823          	sw	zero,16(a5)
    cprintf("[DEBUG] Initialized buddy system.\n");
ffffffffc0200690:	bc29                	j	ffffffffc02000aa <cprintf>

ffffffffc0200692 <buddy_nr_free_pages>:
    cprintf("[DEBUG] buddy_check: Completed buddy allocator check.\n");
}


// 返回空闲页面的数量
size_t buddy_nr_free_pages(void) {
ffffffffc0200692:	1141                	addi	sp,sp,-16
ffffffffc0200694:	e022                	sd	s0,0(sp)
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc0200696:	00007417          	auipc	s0,0x7
ffffffffc020069a:	97a40413          	addi	s0,s0,-1670 # ffffffffc0207010 <free_area>
ffffffffc020069e:	480c                	lw	a1,16(s0)
ffffffffc02006a0:	00002517          	auipc	a0,0x2
ffffffffc02006a4:	a2850513          	addi	a0,a0,-1496 # ffffffffc02020c8 <commands+0x428>
size_t buddy_nr_free_pages(void) {
ffffffffc02006a8:	e406                	sd	ra,8(sp)
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc02006aa:	a01ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    return nr_free;
}
ffffffffc02006ae:	01046503          	lwu	a0,16(s0)
ffffffffc02006b2:	60a2                	ld	ra,8(sp)
ffffffffc02006b4:	6402                	ld	s0,0(sp)
ffffffffc02006b6:	0141                	addi	sp,sp,16
ffffffffc02006b8:	8082                	ret

ffffffffc02006ba <buddy_allocate_pages>:
struct Page *buddy_allocate_pages(size_t n) {
ffffffffc02006ba:	1141                	addi	sp,sp,-16
ffffffffc02006bc:	e406                	sd	ra,8(sp)
ffffffffc02006be:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc02006c0:	20050c63          	beqz	a0,ffffffffc02008d8 <buddy_allocate_pages+0x21e>
    size_t length = POWER_ROUND_UP(n);
ffffffffc02006c4:	00155793          	srli	a5,a0,0x1
ffffffffc02006c8:	8fc9                	or	a5,a5,a0
ffffffffc02006ca:	0027d713          	srli	a4,a5,0x2
ffffffffc02006ce:	8fd9                	or	a5,a5,a4
ffffffffc02006d0:	0047d713          	srli	a4,a5,0x4
ffffffffc02006d4:	8f5d                	or	a4,a4,a5
ffffffffc02006d6:	00875793          	srli	a5,a4,0x8
ffffffffc02006da:	8f5d                	or	a4,a4,a5
ffffffffc02006dc:	01075793          	srli	a5,a4,0x10
ffffffffc02006e0:	8fd9                	or	a5,a5,a4
ffffffffc02006e2:	8385                	srli	a5,a5,0x1
ffffffffc02006e4:	00a7f733          	and	a4,a5,a0
ffffffffc02006e8:	85aa                	mv	a1,a0
ffffffffc02006ea:	8eaa                	mv	t4,a0
ffffffffc02006ec:	1c071363          	bnez	a4,ffffffffc02008b2 <buddy_allocate_pages+0x1f8>
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc02006f0:	00007317          	auipc	t1,0x7
ffffffffc02006f4:	d6033303          	ld	t1,-672(t1) # ffffffffc0207450 <record_area>
ffffffffc02006f8:	00833703          	ld	a4,8(t1)
ffffffffc02006fc:	00830293          	addi	t0,t1,8
ffffffffc0200700:	19d76763          	bltu	a4,t4,ffffffffc020088e <buddy_allocate_pages+0x1d4>
ffffffffc0200704:	00007f17          	auipc	t5,0x7
ffffffffc0200708:	d3cf3f03          	ld	t5,-708(t5) # ffffffffc0207440 <full_tree_size>
    size_t block = TREE_ROOT;
ffffffffc020070c:	4805                	li	a6,1
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc020070e:	030f5833          	divu	a6,t5,a6
            list_del(&allocate_area[begin].page_link);
ffffffffc0200712:	00007517          	auipc	a0,0x7
ffffffffc0200716:	d2653503          	ld	a0,-730(a0) # ffffffffc0207438 <allocate_area>
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc020071a:	4881                	li	a7,0
ffffffffc020071c:	4601                	li	a2,0
    size_t block = TREE_ROOT;
ffffffffc020071e:	4785                	li	a5,1
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200720:	00007f97          	auipc	t6,0x7
ffffffffc0200724:	8f0f8f93          	addi	t6,t6,-1808 # ffffffffc0207010 <free_area>
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc0200728:	090ef063          	bgeu	t4,a6,ffffffffc02007a8 <buddy_allocate_pages+0xee>
        size_t left = LEFT_CHILD(block);
ffffffffc020072c:	00179693          	slli	a3,a5,0x1
            record_area[left] = record_area[block] >> 1;
ffffffffc0200730:	00479613          	slli	a2,a5,0x4
        size_t right = RIGHT_CHILD(block);
ffffffffc0200734:	00168393          	addi	t2,a3,1
            record_area[left] = record_area[block] >> 1;
ffffffffc0200738:	00c30e33          	add	t3,t1,a2
        if (BUDDY_EMPTY(block)) {
ffffffffc020073c:	0ce80d63          	beq	a6,a4,ffffffffc0200816 <buddy_allocate_pages+0x15c>
        } else if (length & record_area[left]) {
ffffffffc0200740:	000e3703          	ld	a4,0(t3)
ffffffffc0200744:	01d77833          	and	a6,a4,t4
ffffffffc0200748:	14081163          	bnez	a6,ffffffffc020088a <buddy_allocate_pages+0x1d0>
        } else if (length & record_area[right]) {
ffffffffc020074c:	0621                	addi	a2,a2,8
ffffffffc020074e:	961a                	add	a2,a2,t1
ffffffffc0200750:	00063803          	ld	a6,0(a2)
ffffffffc0200754:	01d878b3          	and	a7,a6,t4
ffffffffc0200758:	14089763          	bnez	a7,ffffffffc02008a6 <buddy_allocate_pages+0x1ec>
        } else if (length <= record_area[left]) {
ffffffffc020075c:	01d77763          	bgeu	a4,t4,ffffffffc020076a <buddy_allocate_pages+0xb0>
        } else if (length <= record_area[right]) {
ffffffffc0200760:	17d86363          	bltu	a6,t4,ffffffffc02008c6 <buddy_allocate_pages+0x20c>
ffffffffc0200764:	8742                	mv	a4,a6
ffffffffc0200766:	8e32                	mv	t3,a2
            block = right;
ffffffffc0200768:	869e                	mv	a3,t2
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc020076a:	0016d613          	srli	a2,a3,0x1
ffffffffc020076e:	8e55                	or	a2,a2,a3
ffffffffc0200770:	00265793          	srli	a5,a2,0x2
ffffffffc0200774:	8e5d                	or	a2,a2,a5
ffffffffc0200776:	00465793          	srli	a5,a2,0x4
ffffffffc020077a:	8fd1                	or	a5,a5,a2
ffffffffc020077c:	0087d613          	srli	a2,a5,0x8
ffffffffc0200780:	8fd1                	or	a5,a5,a2
ffffffffc0200782:	0107d613          	srli	a2,a5,0x10
ffffffffc0200786:	8e5d                	or	a2,a2,a5
ffffffffc0200788:	8205                	srli	a2,a2,0x1
ffffffffc020078a:	00d678b3          	and	a7,a2,a3
ffffffffc020078e:	8836                	mv	a6,a3
ffffffffc0200790:	00088663          	beqz	a7,ffffffffc020079c <buddy_allocate_pages+0xe2>
ffffffffc0200794:	fff64813          	not	a6,a2
ffffffffc0200798:	00d87833          	and	a6,a6,a3
ffffffffc020079c:	030f5833          	divu	a6,t5,a6
ffffffffc02007a0:	82f2                	mv	t0,t3
ffffffffc02007a2:	87b6                	mv	a5,a3
ffffffffc02007a4:	f90ee4e3          	bltu	t4,a6,ffffffffc020072c <buddy_allocate_pages+0x72>
    page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc02007a8:	10089b63          	bnez	a7,ffffffffc02008be <buddy_allocate_pages+0x204>
ffffffffc02007ac:	863e                	mv	a2,a5
ffffffffc02007ae:	02cf5633          	divu	a2,t5,a2
    nr_free -= length;
ffffffffc02007b2:	00007697          	auipc	a3,0x7
ffffffffc02007b6:	85e68693          	addi	a3,a3,-1954 # ffffffffc0207010 <free_area>
ffffffffc02007ba:	4a98                	lw	a4,16(a3)
    while (block != TREE_ROOT) {
ffffffffc02007bc:	4e05                	li	t3,1
ffffffffc02007be:	4805                	li	a6,1
    nr_free -= length;
ffffffffc02007c0:	41d70ebb          	subw	t4,a4,t4
    page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc02007c4:	03160733          	mul	a4,a2,a7
ffffffffc02007c8:	00271413          	slli	s0,a4,0x2
ffffffffc02007cc:	943a                	add	s0,s0,a4
ffffffffc02007ce:	040e                	slli	s0,s0,0x3
ffffffffc02007d0:	942a                	add	s0,s0,a0
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
ffffffffc02007d2:	6c10                	ld	a2,24(s0)
ffffffffc02007d4:	7018                	ld	a4,32(s0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02007d6:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02007d8:	e310                	sd	a2,0(a4)
    record_area[block] = 0;
ffffffffc02007da:	0002b023          	sd	zero,0(t0)
    nr_free -= length;
ffffffffc02007de:	01d6a823          	sw	t4,16(a3)
    while (block != TREE_ROOT) {
ffffffffc02007e2:	01c78f63          	beq	a5,t3,ffffffffc0200800 <buddy_allocate_pages+0x146>
        block = PARENT(block);
ffffffffc02007e6:	8385                	srli	a5,a5,0x1
        record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
ffffffffc02007e8:	00479713          	slli	a4,a5,0x4
ffffffffc02007ec:	971a                	add	a4,a4,t1
ffffffffc02007ee:	6310                	ld	a2,0(a4)
ffffffffc02007f0:	6714                	ld	a3,8(a4)
ffffffffc02007f2:	00379713          	slli	a4,a5,0x3
ffffffffc02007f6:	971a                	add	a4,a4,t1
ffffffffc02007f8:	8ed1                	or	a3,a3,a2
ffffffffc02007fa:	e314                	sd	a3,0(a4)
    while (block != TREE_ROOT) {
ffffffffc02007fc:	ff0795e3          	bne	a5,a6,ffffffffc02007e6 <buddy_allocate_pages+0x12c>
    cprintf("[DEBUG] Allocated %lu pages.\n", n);
ffffffffc0200800:	00002517          	auipc	a0,0x2
ffffffffc0200804:	92050513          	addi	a0,a0,-1760 # ffffffffc0202120 <commands+0x480>
ffffffffc0200808:	8a3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
}
ffffffffc020080c:	60a2                	ld	ra,8(sp)
ffffffffc020080e:	8522                	mv	a0,s0
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	0141                	addi	sp,sp,16
ffffffffc0200814:	8082                	ret
            size_t begin = NODE_BEGINNING(block);
ffffffffc0200816:	031708b3          	mul	a7,a4,a7
            record_area[left] = record_area[block] >> 1;
ffffffffc020081a:	00175413          	srli	s0,a4,0x1
            list_del(&allocate_area[begin].page_link);
ffffffffc020081e:	00289793          	slli	a5,a7,0x2
ffffffffc0200822:	97c6                	add	a5,a5,a7
ffffffffc0200824:	078e                	slli	a5,a5,0x3
ffffffffc0200826:	97aa                	add	a5,a5,a0
            size_t end = NODE_ENDING(block);
ffffffffc0200828:	9746                	add	a4,a4,a7
    __list_del(listelm->prev, listelm->next);
ffffffffc020082a:	0207b803          	ld	a6,32(a5)
ffffffffc020082e:	0187b383          	ld	t2,24(a5)
            size_t mid = (begin + end) >> 1;
ffffffffc0200832:	98ba                	add	a7,a7,a4
ffffffffc0200834:	0018d893          	srli	a7,a7,0x1
            allocate_area[begin].property >>= 1;
ffffffffc0200838:	4b98                	lw	a4,16(a5)
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc020083a:	00289613          	slli	a2,a7,0x2
    prev->next = next;
ffffffffc020083e:	0103b423          	sd	a6,8(t2)
ffffffffc0200842:	9646                	add	a2,a2,a7
    next->prev = prev;
ffffffffc0200844:	00783023          	sd	t2,0(a6)
            allocate_area[begin].property >>= 1;
ffffffffc0200848:	0017571b          	srliw	a4,a4,0x1
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc020084c:	060e                	slli	a2,a2,0x3
            allocate_area[begin].property >>= 1;
ffffffffc020084e:	cb98                	sw	a4,16(a5)
            allocate_area[mid].property = allocate_area[begin].property;
ffffffffc0200850:	962a                	add	a2,a2,a0
ffffffffc0200852:	ca18                	sw	a4,16(a2)
            record_area[left] = record_area[block] >> 1;
ffffffffc0200854:	008e3023          	sd	s0,0(t3)
            record_area[right] = record_area[block] >> 1;
ffffffffc0200858:	0002b703          	ld	a4,0(t0)
    __list_add(elm, listelm, listelm->next);
ffffffffc020085c:	008fb283          	ld	t0,8(t6)
            list_add(&free_list, &allocate_area[begin].page_link);
ffffffffc0200860:	01878813          	addi	a6,a5,24
            record_area[right] = record_area[block] >> 1;
ffffffffc0200864:	8305                	srli	a4,a4,0x1
ffffffffc0200866:	00ee3423          	sd	a4,8(t3)
    prev->next = next->prev = elm;
ffffffffc020086a:	0102b023          	sd	a6,0(t0)
            list_add(&free_list, &allocate_area[mid].page_link);
ffffffffc020086e:	01860893          	addi	a7,a2,24
    elm->next = next;
ffffffffc0200872:	0257b023          	sd	t0,32(a5)
    prev->next = next->prev = elm;
ffffffffc0200876:	0117bc23          	sd	a7,24(a5)
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc020087a:	000e3703          	ld	a4,0(t3)
ffffffffc020087e:	011fb423          	sd	a7,8(t6)
    elm->next = next;
ffffffffc0200882:	03063023          	sd	a6,32(a2)
    elm->prev = prev;
ffffffffc0200886:	01f63c23          	sd	t6,24(a2)
ffffffffc020088a:	efd770e3          	bgeu	a4,t4,ffffffffc020076a <buddy_allocate_pages+0xb0>
        cprintf("[DEBUG] Allocation failed. Requested: %lu\n", n);
ffffffffc020088e:	00002517          	auipc	a0,0x2
ffffffffc0200892:	8b250513          	addi	a0,a0,-1870 # ffffffffc0202140 <commands+0x4a0>
ffffffffc0200896:	815ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
        return NULL;
ffffffffc020089a:	4401                	li	s0,0
}
ffffffffc020089c:	60a2                	ld	ra,8(sp)
ffffffffc020089e:	8522                	mv	a0,s0
ffffffffc02008a0:	6402                	ld	s0,0(sp)
ffffffffc02008a2:	0141                	addi	sp,sp,16
ffffffffc02008a4:	8082                	ret
ffffffffc02008a6:	8742                	mv	a4,a6
ffffffffc02008a8:	8e32                	mv	t3,a2
            block = right;
ffffffffc02008aa:	869e                	mv	a3,t2
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc02008ac:	ebd77fe3          	bgeu	a4,t4,ffffffffc020076a <buddy_allocate_pages+0xb0>
ffffffffc02008b0:	bff9                	j	ffffffffc020088e <buddy_allocate_pages+0x1d4>
    size_t length = POWER_ROUND_UP(n);
ffffffffc02008b2:	fff7ce93          	not	t4,a5
ffffffffc02008b6:	00aefeb3          	and	t4,t4,a0
ffffffffc02008ba:	0e86                	slli	t4,t4,0x1
ffffffffc02008bc:	bd15                	j	ffffffffc02006f0 <buddy_allocate_pages+0x36>
    page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc02008be:	fff64613          	not	a2,a2
ffffffffc02008c2:	8e7d                	and	a2,a2,a5
ffffffffc02008c4:	b5ed                	j	ffffffffc02007ae <buddy_allocate_pages+0xf4>
    while (length <= record_area[block] && length < NODE_LENGTH(block)) {
ffffffffc02008c6:	00379e13          	slli	t3,a5,0x3
ffffffffc02008ca:	9e1a                	add	t3,t3,t1
ffffffffc02008cc:	000e3703          	ld	a4,0(t3)
ffffffffc02008d0:	86be                	mv	a3,a5
ffffffffc02008d2:	e9d77ce3          	bgeu	a4,t4,ffffffffc020076a <buddy_allocate_pages+0xb0>
ffffffffc02008d6:	bf65                	j	ffffffffc020088e <buddy_allocate_pages+0x1d4>
    assert(n > 0);
ffffffffc02008d8:	00002697          	auipc	a3,0x2
ffffffffc02008dc:	81868693          	addi	a3,a3,-2024 # ffffffffc02020f0 <commands+0x450>
ffffffffc02008e0:	00002617          	auipc	a2,0x2
ffffffffc02008e4:	81860613          	addi	a2,a2,-2024 # ffffffffc02020f8 <commands+0x458>
ffffffffc02008e8:	08a00593          	li	a1,138
ffffffffc02008ec:	00002517          	auipc	a0,0x2
ffffffffc02008f0:	82450513          	addi	a0,a0,-2012 # ffffffffc0202110 <commands+0x470>
ffffffffc02008f4:	ab1ff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc02008f8 <buddy_free_pages>:
void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc02008f8:	1101                	addi	sp,sp,-32
ffffffffc02008fa:	ec06                	sd	ra,24(sp)
ffffffffc02008fc:	e822                	sd	s0,16(sp)
ffffffffc02008fe:	e426                	sd	s1,8(sp)
ffffffffc0200900:	e04a                	sd	s2,0(sp)
    assert(n > 0);
ffffffffc0200902:	22058863          	beqz	a1,ffffffffc0200b32 <buddy_free_pages+0x23a>
    size_t length = POWER_ROUND_UP(n);
ffffffffc0200906:	0015d793          	srli	a5,a1,0x1
ffffffffc020090a:	8fcd                	or	a5,a5,a1
ffffffffc020090c:	0027d713          	srli	a4,a5,0x2
ffffffffc0200910:	8fd9                	or	a5,a5,a4
ffffffffc0200912:	0047d713          	srli	a4,a5,0x4
ffffffffc0200916:	8f5d                	or	a4,a4,a5
ffffffffc0200918:	00875793          	srli	a5,a4,0x8
ffffffffc020091c:	8f5d                	or	a4,a4,a5
ffffffffc020091e:	01075793          	srli	a5,a4,0x10
ffffffffc0200922:	8fd9                	or	a5,a5,a4
ffffffffc0200924:	8385                	srli	a5,a5,0x1
ffffffffc0200926:	00b7f733          	and	a4,a5,a1
ffffffffc020092a:	862a                	mv	a2,a0
ffffffffc020092c:	8e2e                	mv	t3,a1
ffffffffc020092e:	1c071c63          	bnez	a4,ffffffffc0200b06 <buddy_free_pages+0x20e>
    size_t begin = (base - allocate_area);
ffffffffc0200932:	00007517          	auipc	a0,0x7
ffffffffc0200936:	b0653503          	ld	a0,-1274(a0) # ffffffffc0207438 <allocate_area>
ffffffffc020093a:	40a60733          	sub	a4,a2,a0
ffffffffc020093e:	00002697          	auipc	a3,0x2
ffffffffc0200942:	7ca6b683          	ld	a3,1994(a3) # ffffffffc0203108 <error_string+0x38>
ffffffffc0200946:	870d                	srai	a4,a4,0x3
ffffffffc0200948:	02d70733          	mul	a4,a4,a3
    for (; p != base + n; p++) {
ffffffffc020094c:	00259813          	slli	a6,a1,0x2
ffffffffc0200950:	982e                	add	a6,a6,a1
    size_t block = (begin ^ (end - 1)) & (full_tree_size - 1); // 修复 BUDDY_BLOCK 的定义
ffffffffc0200952:	00007897          	auipc	a7,0x7
ffffffffc0200956:	aee8b883          	ld	a7,-1298(a7) # ffffffffc0207440 <full_tree_size>
    for (; p != base + n; p++) {
ffffffffc020095a:	080e                	slli	a6,a6,0x3
    size_t block = (begin ^ (end - 1)) & (full_tree_size - 1); // 修复 BUDDY_BLOCK 的定义
ffffffffc020095c:	fff88313          	addi	t1,a7,-1
    for (; p != base + n; p++) {
ffffffffc0200960:	9832                	add	a6,a6,a2
ffffffffc0200962:	87b2                	mv	a5,a2
    size_t block = (begin ^ (end - 1)) & (full_tree_size - 1); // 修复 BUDDY_BLOCK 的定义
ffffffffc0200964:	fff70693          	addi	a3,a4,-1
ffffffffc0200968:	96f2                	add	a3,a3,t3
ffffffffc020096a:	8f35                	xor	a4,a4,a3
ffffffffc020096c:	006776b3          	and	a3,a4,t1
    for (; p != base + n; p++) {
ffffffffc0200970:	01060e63          	beq	a2,a6,ffffffffc020098c <buddy_free_pages+0x94>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200974:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p));
ffffffffc0200976:	8b05                	andi	a4,a4,1
ffffffffc0200978:	18071d63          	bnez	a4,ffffffffc0200b12 <buddy_free_pages+0x21a>
        p->flags = 0;
ffffffffc020097c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200980:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc0200984:	02878793          	addi	a5,a5,40
ffffffffc0200988:	ff0796e3          	bne	a5,a6,ffffffffc0200974 <buddy_free_pages+0x7c>
    __list_add(elm, listelm, listelm->next);
ffffffffc020098c:	00006e97          	auipc	t4,0x6
ffffffffc0200990:	684e8e93          	addi	t4,t4,1668 # ffffffffc0207010 <free_area>
    nr_free += length;
ffffffffc0200994:	010ea783          	lw	a5,16(t4)
ffffffffc0200998:	008eb803          	ld	a6,8(t4)
    base->property = length;
ffffffffc020099c:	000e071b          	sext.w	a4,t3
ffffffffc02009a0:	ca18                	sw	a4,16(a2)
    list_add(&free_list, &base->page_link);
ffffffffc02009a2:	01860f13          	addi	t5,a2,24
    prev->next = next->prev = elm;
ffffffffc02009a6:	01e83023          	sd	t5,0(a6)
    nr_free += length;
ffffffffc02009aa:	9fb9                	addw	a5,a5,a4
    record_area[block] = length;
ffffffffc02009ac:	00007317          	auipc	t1,0x7
ffffffffc02009b0:	aa433303          	ld	t1,-1372(t1) # ffffffffc0207450 <record_area>
ffffffffc02009b4:	00369713          	slli	a4,a3,0x3
    nr_free += length;
ffffffffc02009b8:	00fea823          	sw	a5,16(t4)
ffffffffc02009bc:	01eeb423          	sd	t5,8(t4)
    elm->next = next;
ffffffffc02009c0:	03063023          	sd	a6,32(a2)
    elm->prev = prev;
ffffffffc02009c4:	01d63c23          	sd	t4,24(a2)
    record_area[block] = length;
ffffffffc02009c8:	971a                	add	a4,a4,t1
ffffffffc02009ca:	01c73023          	sd	t3,0(a4)
    while (block != TREE_ROOT) {
ffffffffc02009ce:	4785                	li	a5,1
ffffffffc02009d0:	4e05                	li	t3,1
ffffffffc02009d2:	06f68a63          	beq	a3,a5,ffffffffc0200a46 <buddy_free_pages+0x14e>
        size_t left = LEFT_CHILD(block);
ffffffffc02009d6:	ffe6f793          	andi	a5,a3,-2
        block = PARENT(block);
ffffffffc02009da:	8285                	srli	a3,a3,0x1
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc02009dc:	00f6e733          	or	a4,a3,a5
ffffffffc02009e0:	00275813          	srli	a6,a4,0x2
ffffffffc02009e4:	00e86733          	or	a4,a6,a4
ffffffffc02009e8:	00475813          	srli	a6,a4,0x4
ffffffffc02009ec:	00e86833          	or	a6,a6,a4
ffffffffc02009f0:	00885713          	srli	a4,a6,0x8
ffffffffc02009f4:	01076833          	or	a6,a4,a6
ffffffffc02009f8:	01085713          	srli	a4,a6,0x10
ffffffffc02009fc:	01076733          	or	a4,a4,a6
ffffffffc0200a00:	00379f13          	slli	t5,a5,0x3
ffffffffc0200a04:	8305                	srli	a4,a4,0x1
ffffffffc0200a06:	9f1a                	add	t5,t5,t1
ffffffffc0200a08:	00f772b3          	and	t0,a4,a5
ffffffffc0200a0c:	000f3403          	ld	s0,0(t5)
        size_t left = LEFT_CHILD(block);
ffffffffc0200a10:	883e                	mv	a6,a5
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200a12:	00028663          	beqz	t0,ffffffffc0200a1e <buddy_free_pages+0x126>
ffffffffc0200a16:	fff74713          	not	a4,a4
ffffffffc0200a1a:	00f77833          	and	a6,a4,a5
ffffffffc0200a1e:	0308d733          	divu	a4,a7,a6
            record_area[block] = record_area[left] << 1;
ffffffffc0200a22:	00369813          	slli	a6,a3,0x3
ffffffffc0200a26:	01030fb3          	add	t6,t1,a6
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200a2a:	02e40963          	beq	s0,a4,ffffffffc0200a5c <buddy_free_pages+0x164>
            record_area[block] = record_area[LEFT_CHILD(block)] | record_area[RIGHT_CHILD(block)];
ffffffffc0200a2e:	00469793          	slli	a5,a3,0x4
ffffffffc0200a32:	979a                	add	a5,a5,t1
ffffffffc0200a34:	987e                	add	a6,a6,t6
ffffffffc0200a36:	679c                	ld	a5,8(a5)
ffffffffc0200a38:	00083703          	ld	a4,0(a6)
ffffffffc0200a3c:	8fd9                	or	a5,a5,a4
ffffffffc0200a3e:	00ffb023          	sd	a5,0(t6)
    while (block != TREE_ROOT) {
ffffffffc0200a42:	f9c69ae3          	bne	a3,t3,ffffffffc02009d6 <buddy_free_pages+0xde>
}
ffffffffc0200a46:	6442                	ld	s0,16(sp)
ffffffffc0200a48:	60e2                	ld	ra,24(sp)
ffffffffc0200a4a:	64a2                	ld	s1,8(sp)
ffffffffc0200a4c:	6902                	ld	s2,0(sp)
    cprintf("[DEBUG] Freed %lu pages starting at address %p\n", n, base);
ffffffffc0200a4e:	00001517          	auipc	a0,0x1
ffffffffc0200a52:	73a50513          	addi	a0,a0,1850 # ffffffffc0202188 <commands+0x4e8>
}
ffffffffc0200a56:	6105                	addi	sp,sp,32
    cprintf("[DEBUG] Freed %lu pages starting at address %p\n", n, base);
ffffffffc0200a58:	e52ff06f          	j	ffffffffc02000aa <cprintf>
        size_t right = RIGHT_CHILD(block);
ffffffffc0200a5c:	00178393          	addi	t2,a5,1
        if (BUDDY_EMPTY(left) && BUDDY_EMPTY(right)) {
ffffffffc0200a60:	8385                	srli	a5,a5,0x1
ffffffffc0200a62:	0077e7b3          	or	a5,a5,t2
ffffffffc0200a66:	0027d493          	srli	s1,a5,0x2
ffffffffc0200a6a:	8fc5                	or	a5,a5,s1
ffffffffc0200a6c:	0047d493          	srli	s1,a5,0x4
ffffffffc0200a70:	8cdd                	or	s1,s1,a5
ffffffffc0200a72:	0084d793          	srli	a5,s1,0x8
ffffffffc0200a76:	8cdd                	or	s1,s1,a5
ffffffffc0200a78:	0104d793          	srli	a5,s1,0x10
ffffffffc0200a7c:	8fc5                	or	a5,a5,s1
ffffffffc0200a7e:	8385                	srli	a5,a5,0x1
ffffffffc0200a80:	0077f4b3          	and	s1,a5,t2
ffffffffc0200a84:	008f3903          	ld	s2,8(t5)
ffffffffc0200a88:	c489                	beqz	s1,ffffffffc0200a92 <buddy_free_pages+0x19a>
ffffffffc0200a8a:	fff7c793          	not	a5,a5
ffffffffc0200a8e:	00f3f3b3          	and	t2,t2,a5
ffffffffc0200a92:	0278d3b3          	divu	t2,a7,t2
ffffffffc0200a96:	f8791ce3          	bne	s2,t2,ffffffffc0200a2e <buddy_free_pages+0x136>
            list_del(&allocate_area[lbegin].page_link);
ffffffffc0200a9a:	02e28733          	mul	a4,t0,a4
            record_area[block] = record_area[left] << 1;
ffffffffc0200a9e:	0406                	slli	s0,s0,0x1
            list_del(&allocate_area[rbegin].page_link);
ffffffffc0200aa0:	032484b3          	mul	s1,s1,s2
            list_del(&allocate_area[lbegin].page_link);
ffffffffc0200aa4:	00271793          	slli	a5,a4,0x2
ffffffffc0200aa8:	973e                	add	a4,a4,a5
ffffffffc0200aaa:	00371793          	slli	a5,a4,0x3
ffffffffc0200aae:	97aa                	add	a5,a5,a0
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ab0:	0207b803          	ld	a6,32(a5)
ffffffffc0200ab4:	0187b383          	ld	t2,24(a5)
            list_add(&free_list, &allocate_area[lbegin].page_link);
ffffffffc0200ab8:	01878293          	addi	t0,a5,24
    prev->next = next;
ffffffffc0200abc:	0103b423          	sd	a6,8(t2)
            list_del(&allocate_area[rbegin].page_link);
ffffffffc0200ac0:	00249713          	slli	a4,s1,0x2
ffffffffc0200ac4:	94ba                	add	s1,s1,a4
ffffffffc0200ac6:	00349713          	slli	a4,s1,0x3
    next->prev = prev;
ffffffffc0200aca:	00783023          	sd	t2,0(a6)
ffffffffc0200ace:	972a                	add	a4,a4,a0
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ad0:	01873803          	ld	a6,24(a4)
ffffffffc0200ad4:	7318                	ld	a4,32(a4)
    prev->next = next;
ffffffffc0200ad6:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0200ada:	01073023          	sd	a6,0(a4)
            record_area[block] = record_area[left] << 1;
ffffffffc0200ade:	008fb023          	sd	s0,0(t6)
            allocate_area[lbegin].property = record_area[left] << 1;
ffffffffc0200ae2:	000f3703          	ld	a4,0(t5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ae6:	008eb803          	ld	a6,8(t4)
ffffffffc0200aea:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200aee:	cb98                	sw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200af0:	00583023          	sd	t0,0(a6)
ffffffffc0200af4:	005eb423          	sd	t0,8(t4)
    elm->next = next;
ffffffffc0200af8:	0307b023          	sd	a6,32(a5)
    elm->prev = prev;
ffffffffc0200afc:	01d7bc23          	sd	t4,24(a5)
    while (block != TREE_ROOT) {
ffffffffc0200b00:	edc69be3          	bne	a3,t3,ffffffffc02009d6 <buddy_free_pages+0xde>
ffffffffc0200b04:	b789                	j	ffffffffc0200a46 <buddy_free_pages+0x14e>
    size_t length = POWER_ROUND_UP(n);
ffffffffc0200b06:	fff7c793          	not	a5,a5
ffffffffc0200b0a:	8fed                	and	a5,a5,a1
ffffffffc0200b0c:	00179e13          	slli	t3,a5,0x1
ffffffffc0200b10:	b50d                	j	ffffffffc0200932 <buddy_free_pages+0x3a>
        assert(!PageReserved(p));
ffffffffc0200b12:	00001697          	auipc	a3,0x1
ffffffffc0200b16:	65e68693          	addi	a3,a3,1630 # ffffffffc0202170 <commands+0x4d0>
ffffffffc0200b1a:	00001617          	auipc	a2,0x1
ffffffffc0200b1e:	5de60613          	addi	a2,a2,1502 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200b22:	0c200593          	li	a1,194
ffffffffc0200b26:	00001517          	auipc	a0,0x1
ffffffffc0200b2a:	5ea50513          	addi	a0,a0,1514 # ffffffffc0202110 <commands+0x470>
ffffffffc0200b2e:	877ff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(n > 0);
ffffffffc0200b32:	00001697          	auipc	a3,0x1
ffffffffc0200b36:	5be68693          	addi	a3,a3,1470 # ffffffffc02020f0 <commands+0x450>
ffffffffc0200b3a:	00001617          	auipc	a2,0x1
ffffffffc0200b3e:	5be60613          	addi	a2,a2,1470 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200b42:	0ba00593          	li	a1,186
ffffffffc0200b46:	00001517          	auipc	a0,0x1
ffffffffc0200b4a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0202110 <commands+0x470>
ffffffffc0200b4e:	857ff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc0200b52 <buddy_check>:
void buddy_check(void) {
ffffffffc0200b52:	1101                	addi	sp,sp,-32
    cprintf("[DEBUG] buddy_check: Starting buddy allocator check.\n");
ffffffffc0200b54:	00001517          	auipc	a0,0x1
ffffffffc0200b58:	66450513          	addi	a0,a0,1636 # ffffffffc02021b8 <commands+0x518>
void buddy_check(void) {
ffffffffc0200b5c:	ec06                	sd	ra,24(sp)
ffffffffc0200b5e:	e822                	sd	s0,16(sp)
ffffffffc0200b60:	e426                	sd	s1,8(sp)
ffffffffc0200b62:	e04a                	sd	s2,0(sp)
    cprintf("[DEBUG] buddy_check: Starting buddy allocator check.\n");
ffffffffc0200b64:	d46ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert((p0 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200b68:	4505                	li	a0,1
ffffffffc0200b6a:	b51ff0ef          	jal	ra,ffffffffc02006ba <buddy_allocate_pages>
ffffffffc0200b6e:	2a050863          	beqz	a0,ffffffffc0200e1e <buddy_check+0x2cc>
    cprintf("[DEBUG] buddy_check: Allocated p0 at address %p.\n", p0);
ffffffffc0200b72:	85aa                	mv	a1,a0
ffffffffc0200b74:	842a                	mv	s0,a0
ffffffffc0200b76:	00001517          	auipc	a0,0x1
ffffffffc0200b7a:	6a250513          	addi	a0,a0,1698 # ffffffffc0202218 <commands+0x578>
ffffffffc0200b7e:	d2cff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert((p1 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200b82:	4505                	li	a0,1
ffffffffc0200b84:	b37ff0ef          	jal	ra,ffffffffc02006ba <buddy_allocate_pages>
ffffffffc0200b88:	84aa                	mv	s1,a0
ffffffffc0200b8a:	26050a63          	beqz	a0,ffffffffc0200dfe <buddy_check+0x2ac>
    cprintf("[DEBUG] buddy_check: Allocated p1 at address %p.\n", p1);
ffffffffc0200b8e:	85aa                	mv	a1,a0
ffffffffc0200b90:	00001517          	auipc	a0,0x1
ffffffffc0200b94:	6e850513          	addi	a0,a0,1768 # ffffffffc0202278 <commands+0x5d8>
ffffffffc0200b98:	d12ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert((p2 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200b9c:	4505                	li	a0,1
ffffffffc0200b9e:	b1dff0ef          	jal	ra,ffffffffc02006ba <buddy_allocate_pages>
ffffffffc0200ba2:	892a                	mv	s2,a0
ffffffffc0200ba4:	22050d63          	beqz	a0,ffffffffc0200dde <buddy_check+0x28c>
    cprintf("[DEBUG] buddy_check: Allocated p2 at address %p.\n", p2);
ffffffffc0200ba8:	85aa                	mv	a1,a0
ffffffffc0200baa:	00001517          	auipc	a0,0x1
ffffffffc0200bae:	72e50513          	addi	a0,a0,1838 # ffffffffc02022d8 <commands+0x638>
ffffffffc0200bb2:	cf8ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bb6:	18940463          	beq	s0,s1,ffffffffc0200d3e <buddy_check+0x1ec>
ffffffffc0200bba:	19240263          	beq	s0,s2,ffffffffc0200d3e <buddy_check+0x1ec>
ffffffffc0200bbe:	19248063          	beq	s1,s2,ffffffffc0200d3e <buddy_check+0x1ec>
    cprintf("[DEBUG] buddy_check: p0, p1, p2 are distinct pages.\n");
ffffffffc0200bc2:	00001517          	auipc	a0,0x1
ffffffffc0200bc6:	77650513          	addi	a0,a0,1910 # ffffffffc0202338 <commands+0x698>
ffffffffc0200bca:	ce0ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bce:	401c                	lw	a5,0(s0)
ffffffffc0200bd0:	18079763          	bnez	a5,ffffffffc0200d5e <buddy_check+0x20c>
ffffffffc0200bd4:	409c                	lw	a5,0(s1)
ffffffffc0200bd6:	18079463          	bnez	a5,ffffffffc0200d5e <buddy_check+0x20c>
ffffffffc0200bda:	00092783          	lw	a5,0(s2)
ffffffffc0200bde:	18079063          	bnez	a5,ffffffffc0200d5e <buddy_check+0x20c>
    cprintf("[DEBUG] buddy_check: Reference counts of p0, p1, p2 are all zero.\n");
ffffffffc0200be2:	00001517          	auipc	a0,0x1
ffffffffc0200be6:	7ce50513          	addi	a0,a0,1998 # ffffffffc02023b0 <commands+0x710>
ffffffffc0200bea:	cc0ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    buddy_free_pages(p0, 1);
ffffffffc0200bee:	4585                	li	a1,1
ffffffffc0200bf0:	8522                	mv	a0,s0
ffffffffc0200bf2:	d07ff0ef          	jal	ra,ffffffffc02008f8 <buddy_free_pages>
    cprintf("[DEBUG] buddy_check: Freed p0.\n");
ffffffffc0200bf6:	00002517          	auipc	a0,0x2
ffffffffc0200bfa:	80250513          	addi	a0,a0,-2046 # ffffffffc02023f8 <commands+0x758>
ffffffffc0200bfe:	cacff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    buddy_free_pages(p1, 1);
ffffffffc0200c02:	4585                	li	a1,1
ffffffffc0200c04:	8526                	mv	a0,s1
ffffffffc0200c06:	cf3ff0ef          	jal	ra,ffffffffc02008f8 <buddy_free_pages>
    cprintf("[DEBUG] buddy_check: Freed p1.\n");
ffffffffc0200c0a:	00002517          	auipc	a0,0x2
ffffffffc0200c0e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0202418 <commands+0x778>
ffffffffc0200c12:	c98ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    buddy_free_pages(p2, 1);
ffffffffc0200c16:	4585                	li	a1,1
ffffffffc0200c18:	854a                	mv	a0,s2
ffffffffc0200c1a:	cdfff0ef          	jal	ra,ffffffffc02008f8 <buddy_free_pages>
    cprintf("[DEBUG] buddy_check: Freed p2.\n");
ffffffffc0200c1e:	00002517          	auipc	a0,0x2
ffffffffc0200c22:	81a50513          	addi	a0,a0,-2022 # ffffffffc0202438 <commands+0x798>
ffffffffc0200c26:	c84ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc0200c2a:	00006417          	auipc	s0,0x6
ffffffffc0200c2e:	3e640413          	addi	s0,s0,998 # ffffffffc0207010 <free_area>
ffffffffc0200c32:	480c                	lw	a1,16(s0)
ffffffffc0200c34:	00001517          	auipc	a0,0x1
ffffffffc0200c38:	49450513          	addi	a0,a0,1172 # ffffffffc02020c8 <commands+0x428>
ffffffffc0200c3c:	c6eff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert(buddy_nr_free_pages() == 3);
ffffffffc0200c40:	4818                	lw	a4,16(s0)
ffffffffc0200c42:	478d                	li	a5,3
ffffffffc0200c44:	20f71d63          	bne	a4,a5,ffffffffc0200e5e <buddy_check+0x30c>
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc0200c48:	458d                	li	a1,3
ffffffffc0200c4a:	00001517          	auipc	a0,0x1
ffffffffc0200c4e:	47e50513          	addi	a0,a0,1150 # ffffffffc02020c8 <commands+0x428>
ffffffffc0200c52:	c58ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] buddy_check: Number of free pages after freeing p0, p1, p2 is %lu.\n", (unsigned long)buddy_nr_free_pages());
ffffffffc0200c56:	01046583          	lwu	a1,16(s0)
ffffffffc0200c5a:	00002517          	auipc	a0,0x2
ffffffffc0200c5e:	81e50513          	addi	a0,a0,-2018 # ffffffffc0202478 <commands+0x7d8>
ffffffffc0200c62:	c48ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert((p0 = buddy_allocate_pages(2)) != NULL);
ffffffffc0200c66:	4509                	li	a0,2
ffffffffc0200c68:	a53ff0ef          	jal	ra,ffffffffc02006ba <buddy_allocate_pages>
ffffffffc0200c6c:	84aa                	mv	s1,a0
ffffffffc0200c6e:	10050863          	beqz	a0,ffffffffc0200d7e <buddy_check+0x22c>
    cprintf("[DEBUG] buddy_check: Allocated 2 pages for p0 at address %p.\n", p0);
ffffffffc0200c72:	85aa                	mv	a1,a0
ffffffffc0200c74:	00002517          	auipc	a0,0x2
ffffffffc0200c78:	87c50513          	addi	a0,a0,-1924 # ffffffffc02024f0 <commands+0x850>
ffffffffc0200c7c:	c2eff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert((p1 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200c80:	4505                	li	a0,1
ffffffffc0200c82:	a39ff0ef          	jal	ra,ffffffffc02006ba <buddy_allocate_pages>
ffffffffc0200c86:	892a                	mv	s2,a0
ffffffffc0200c88:	12050b63          	beqz	a0,ffffffffc0200dbe <buddy_check+0x26c>
    cprintf("[DEBUG] buddy_check: Allocated 1 page for p1 at address %p.\n", p1);
ffffffffc0200c8c:	85aa                	mv	a1,a0
ffffffffc0200c8e:	00002517          	auipc	a0,0x2
ffffffffc0200c92:	8a250513          	addi	a0,a0,-1886 # ffffffffc0202530 <commands+0x890>
ffffffffc0200c96:	c14ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc0200c9a:	480c                	lw	a1,16(s0)
ffffffffc0200c9c:	00001517          	auipc	a0,0x1
ffffffffc0200ca0:	42c50513          	addi	a0,a0,1068 # ffffffffc02020c8 <commands+0x428>
ffffffffc0200ca4:	c06ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert(buddy_nr_free_pages() == 0);
ffffffffc0200ca8:	481c                	lw	a5,16(s0)
ffffffffc0200caa:	0e079a63          	bnez	a5,ffffffffc0200d9e <buddy_check+0x24c>
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc0200cae:	4581                	li	a1,0
ffffffffc0200cb0:	00001517          	auipc	a0,0x1
ffffffffc0200cb4:	41850513          	addi	a0,a0,1048 # ffffffffc02020c8 <commands+0x428>
ffffffffc0200cb8:	bf2ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] buddy_check: Number of free pages after allocating p0 and p1 is %lu.\n", (unsigned long)buddy_nr_free_pages());
ffffffffc0200cbc:	01046583          	lwu	a1,16(s0)
ffffffffc0200cc0:	00002517          	auipc	a0,0x2
ffffffffc0200cc4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0202590 <commands+0x8f0>
ffffffffc0200cc8:	be2ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    buddy_free_pages(p0, 2);
ffffffffc0200ccc:	4589                	li	a1,2
ffffffffc0200cce:	8526                	mv	a0,s1
ffffffffc0200cd0:	c29ff0ef          	jal	ra,ffffffffc02008f8 <buddy_free_pages>
    cprintf("[DEBUG] buddy_check: Freed 2 pages for p0.\n");
ffffffffc0200cd4:	00002517          	auipc	a0,0x2
ffffffffc0200cd8:	90c50513          	addi	a0,a0,-1780 # ffffffffc02025e0 <commands+0x940>
ffffffffc0200cdc:	bceff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    buddy_free_pages(p1, 1);
ffffffffc0200ce0:	4585                	li	a1,1
ffffffffc0200ce2:	854a                	mv	a0,s2
ffffffffc0200ce4:	c15ff0ef          	jal	ra,ffffffffc02008f8 <buddy_free_pages>
    cprintf("[DEBUG] buddy_check: Freed 1 page for p1.\n");
ffffffffc0200ce8:	00002517          	auipc	a0,0x2
ffffffffc0200cec:	92850513          	addi	a0,a0,-1752 # ffffffffc0202610 <commands+0x970>
ffffffffc0200cf0:	bbaff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc0200cf4:	480c                	lw	a1,16(s0)
ffffffffc0200cf6:	00001517          	auipc	a0,0x1
ffffffffc0200cfa:	3d250513          	addi	a0,a0,978 # ffffffffc02020c8 <commands+0x428>
ffffffffc0200cfe:	bacff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    assert(buddy_nr_free_pages() == 3);
ffffffffc0200d02:	4818                	lw	a4,16(s0)
ffffffffc0200d04:	478d                	li	a5,3
ffffffffc0200d06:	12f71c63          	bne	a4,a5,ffffffffc0200e3e <buddy_check+0x2ec>
    cprintf("[DEBUG] Number of free pages: %lu\n", nr_free);
ffffffffc0200d0a:	458d                	li	a1,3
ffffffffc0200d0c:	00001517          	auipc	a0,0x1
ffffffffc0200d10:	3bc50513          	addi	a0,a0,956 # ffffffffc02020c8 <commands+0x428>
ffffffffc0200d14:	b96ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] buddy_check: Number of free pages after freeing p0 and p1 is %lu.\n", (unsigned long)buddy_nr_free_pages());
ffffffffc0200d18:	01046583          	lwu	a1,16(s0)
ffffffffc0200d1c:	00002517          	auipc	a0,0x2
ffffffffc0200d20:	92450513          	addi	a0,a0,-1756 # ffffffffc0202640 <commands+0x9a0>
ffffffffc0200d24:	b86ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
}
ffffffffc0200d28:	6442                	ld	s0,16(sp)
ffffffffc0200d2a:	60e2                	ld	ra,24(sp)
ffffffffc0200d2c:	64a2                	ld	s1,8(sp)
ffffffffc0200d2e:	6902                	ld	s2,0(sp)
    cprintf("[DEBUG] buddy_check: Completed buddy allocator check.\n");
ffffffffc0200d30:	00002517          	auipc	a0,0x2
ffffffffc0200d34:	96050513          	addi	a0,a0,-1696 # ffffffffc0202690 <commands+0x9f0>
}
ffffffffc0200d38:	6105                	addi	sp,sp,32
    cprintf("[DEBUG] buddy_check: Completed buddy allocator check.\n");
ffffffffc0200d3a:	b70ff06f          	j	ffffffffc02000aa <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d3e:	00001697          	auipc	a3,0x1
ffffffffc0200d42:	5d268693          	addi	a3,a3,1490 # ffffffffc0202310 <commands+0x670>
ffffffffc0200d46:	00001617          	auipc	a2,0x1
ffffffffc0200d4a:	3b260613          	addi	a2,a2,946 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200d4e:	0ed00593          	li	a1,237
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	3be50513          	addi	a0,a0,958 # ffffffffc0202110 <commands+0x470>
ffffffffc0200d5a:	e4aff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d5e:	00001697          	auipc	a3,0x1
ffffffffc0200d62:	61268693          	addi	a3,a3,1554 # ffffffffc0202370 <commands+0x6d0>
ffffffffc0200d66:	00001617          	auipc	a2,0x1
ffffffffc0200d6a:	39260613          	addi	a2,a2,914 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200d6e:	0f100593          	li	a1,241
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	39e50513          	addi	a0,a0,926 # ffffffffc0202110 <commands+0x470>
ffffffffc0200d7a:	e2aff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert((p0 = buddy_allocate_pages(2)) != NULL);
ffffffffc0200d7e:	00001697          	auipc	a3,0x1
ffffffffc0200d82:	74a68693          	addi	a3,a3,1866 # ffffffffc02024c8 <commands+0x828>
ffffffffc0200d86:	00001617          	auipc	a2,0x1
ffffffffc0200d8a:	37260613          	addi	a2,a2,882 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200d8e:	10100593          	li	a1,257
ffffffffc0200d92:	00001517          	auipc	a0,0x1
ffffffffc0200d96:	37e50513          	addi	a0,a0,894 # ffffffffc0202110 <commands+0x470>
ffffffffc0200d9a:	e0aff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(buddy_nr_free_pages() == 0);
ffffffffc0200d9e:	00001697          	auipc	a3,0x1
ffffffffc0200da2:	7d268693          	addi	a3,a3,2002 # ffffffffc0202570 <commands+0x8d0>
ffffffffc0200da6:	00001617          	auipc	a2,0x1
ffffffffc0200daa:	35260613          	addi	a2,a2,850 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200dae:	10700593          	li	a1,263
ffffffffc0200db2:	00001517          	auipc	a0,0x1
ffffffffc0200db6:	35e50513          	addi	a0,a0,862 # ffffffffc0202110 <commands+0x470>
ffffffffc0200dba:	deaff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert((p1 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200dbe:	00001697          	auipc	a3,0x1
ffffffffc0200dc2:	49268693          	addi	a3,a3,1170 # ffffffffc0202250 <commands+0x5b0>
ffffffffc0200dc6:	00001617          	auipc	a2,0x1
ffffffffc0200dca:	33260613          	addi	a2,a2,818 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200dce:	10300593          	li	a1,259
ffffffffc0200dd2:	00001517          	auipc	a0,0x1
ffffffffc0200dd6:	33e50513          	addi	a0,a0,830 # ffffffffc0202110 <commands+0x470>
ffffffffc0200dda:	dcaff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert((p2 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200dde:	00001697          	auipc	a3,0x1
ffffffffc0200de2:	4d268693          	addi	a3,a3,1234 # ffffffffc02022b0 <commands+0x610>
ffffffffc0200de6:	00001617          	auipc	a2,0x1
ffffffffc0200dea:	31260613          	addi	a2,a2,786 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200dee:	0e900593          	li	a1,233
ffffffffc0200df2:	00001517          	auipc	a0,0x1
ffffffffc0200df6:	31e50513          	addi	a0,a0,798 # ffffffffc0202110 <commands+0x470>
ffffffffc0200dfa:	daaff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert((p1 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200dfe:	00001697          	auipc	a3,0x1
ffffffffc0200e02:	45268693          	addi	a3,a3,1106 # ffffffffc0202250 <commands+0x5b0>
ffffffffc0200e06:	00001617          	auipc	a2,0x1
ffffffffc0200e0a:	2f260613          	addi	a2,a2,754 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200e0e:	0e700593          	li	a1,231
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	2fe50513          	addi	a0,a0,766 # ffffffffc0202110 <commands+0x470>
ffffffffc0200e1a:	d8aff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert((p0 = buddy_allocate_pages(1)) != NULL);
ffffffffc0200e1e:	00001697          	auipc	a3,0x1
ffffffffc0200e22:	3d268693          	addi	a3,a3,978 # ffffffffc02021f0 <commands+0x550>
ffffffffc0200e26:	00001617          	auipc	a2,0x1
ffffffffc0200e2a:	2d260613          	addi	a2,a2,722 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200e2e:	0e500593          	li	a1,229
ffffffffc0200e32:	00001517          	auipc	a0,0x1
ffffffffc0200e36:	2de50513          	addi	a0,a0,734 # ffffffffc0202110 <commands+0x470>
ffffffffc0200e3a:	d6aff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(buddy_nr_free_pages() == 3);
ffffffffc0200e3e:	00001697          	auipc	a3,0x1
ffffffffc0200e42:	61a68693          	addi	a3,a3,1562 # ffffffffc0202458 <commands+0x7b8>
ffffffffc0200e46:	00001617          	auipc	a2,0x1
ffffffffc0200e4a:	2b260613          	addi	a2,a2,690 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200e4e:	11100593          	li	a1,273
ffffffffc0200e52:	00001517          	auipc	a0,0x1
ffffffffc0200e56:	2be50513          	addi	a0,a0,702 # ffffffffc0202110 <commands+0x470>
ffffffffc0200e5a:	d4aff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(buddy_nr_free_pages() == 3);
ffffffffc0200e5e:	00001697          	auipc	a3,0x1
ffffffffc0200e62:	5fa68693          	addi	a3,a3,1530 # ffffffffc0202458 <commands+0x7b8>
ffffffffc0200e66:	00001617          	auipc	a2,0x1
ffffffffc0200e6a:	29260613          	addi	a2,a2,658 # ffffffffc02020f8 <commands+0x458>
ffffffffc0200e6e:	0fd00593          	li	a1,253
ffffffffc0200e72:	00001517          	auipc	a0,0x1
ffffffffc0200e76:	29e50513          	addi	a0,a0,670 # ffffffffc0202110 <commands+0x470>
ffffffffc0200e7a:	d2aff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc0200e7e <buddy_init_memmap>:
void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200e7e:	7159                	addi	sp,sp,-112
ffffffffc0200e80:	f486                	sd	ra,104(sp)
ffffffffc0200e82:	f0a2                	sd	s0,96(sp)
ffffffffc0200e84:	eca6                	sd	s1,88(sp)
ffffffffc0200e86:	e8ca                	sd	s2,80(sp)
ffffffffc0200e88:	e4ce                	sd	s3,72(sp)
ffffffffc0200e8a:	e0d2                	sd	s4,64(sp)
ffffffffc0200e8c:	fc56                	sd	s5,56(sp)
ffffffffc0200e8e:	f85a                	sd	s6,48(sp)
ffffffffc0200e90:	f45e                	sd	s7,40(sp)
ffffffffc0200e92:	f062                	sd	s8,32(sp)
ffffffffc0200e94:	ec66                	sd	s9,24(sp)
ffffffffc0200e96:	e86a                	sd	s10,16(sp)
ffffffffc0200e98:	e46e                	sd	s11,8(sp)
    assert(n > 0);
ffffffffc0200e9a:	48058563          	beqz	a1,ffffffffc0201324 <buddy_init_memmap+0x4a6>
ffffffffc0200e9e:	842e                	mv	s0,a1
ffffffffc0200ea0:	84aa                	mv	s1,a0
    cprintf("[DEBUG] buddy_init_memmap: Start initialization. Base address: %p, Number of pages: %lu\n", base, (unsigned long)n);
ffffffffc0200ea2:	862e                	mv	a2,a1
ffffffffc0200ea4:	85aa                	mv	a1,a0
ffffffffc0200ea6:	00002517          	auipc	a0,0x2
ffffffffc0200eaa:	82250513          	addi	a0,a0,-2014 # ffffffffc02026c8 <commands+0xa28>
ffffffffc0200eae:	9fcff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    for (p = base; p < base + n; p++) {
ffffffffc0200eb2:	00241693          	slli	a3,s0,0x2
ffffffffc0200eb6:	96a2                	add	a3,a3,s0
ffffffffc0200eb8:	068e                	slli	a3,a3,0x3
ffffffffc0200eba:	96a6                	add	a3,a3,s1
ffffffffc0200ebc:	87a6                	mv	a5,s1
ffffffffc0200ebe:	00d4fe63          	bgeu	s1,a3,ffffffffc0200eda <buddy_init_memmap+0x5c>
ffffffffc0200ec2:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200ec4:	8b05                	andi	a4,a4,1
ffffffffc0200ec6:	42070f63          	beqz	a4,ffffffffc0201304 <buddy_init_memmap+0x486>
        p->flags = p->property = 0;
ffffffffc0200eca:	0007a823          	sw	zero,16(a5)
ffffffffc0200ece:	0007b423          	sd	zero,8(a5)
    for (p = base; p < base + n; p++) {
ffffffffc0200ed2:	02878793          	addi	a5,a5,40
ffffffffc0200ed6:	fed7e6e3          	bltu	a5,a3,ffffffffc0200ec2 <buddy_init_memmap+0x44>
    cprintf("[DEBUG] buddy_init_memmap: Cleared page flags and properties for all pages.\n");
ffffffffc0200eda:	00002517          	auipc	a0,0x2
ffffffffc0200ede:	84e50513          	addi	a0,a0,-1970 # ffffffffc0202728 <commands+0xa88>
ffffffffc0200ee2:	9c8ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    total_size = n;
ffffffffc0200ee6:	00006797          	auipc	a5,0x6
ffffffffc0200eea:	57a78793          	addi	a5,a5,1402 # ffffffffc0207460 <total_size>
    cprintf("[DEBUG] buddy_init_memmap: Set total_size to %lu.\n", (unsigned long)total_size);
ffffffffc0200eee:	85a2                	mv	a1,s0
ffffffffc0200ef0:	00002517          	auipc	a0,0x2
ffffffffc0200ef4:	88850513          	addi	a0,a0,-1912 # ffffffffc0202778 <commands+0xad8>
    total_size = n;
ffffffffc0200ef8:	e380                	sd	s0,0(a5)
    cprintf("[DEBUG] buddy_init_memmap: Set total_size to %lu.\n", (unsigned long)total_size);
ffffffffc0200efa:	9b0ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    if (n < 512) {
ffffffffc0200efe:	1ff00793          	li	a5,511
ffffffffc0200f02:	3487f363          	bgeu	a5,s0,ffffffffc0201248 <buddy_init_memmap+0x3ca>
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200f06:	00145793          	srli	a5,s0,0x1
ffffffffc0200f0a:	8fc1                	or	a5,a5,s0
ffffffffc0200f0c:	0027d713          	srli	a4,a5,0x2
ffffffffc0200f10:	8fd9                	or	a5,a5,a4
ffffffffc0200f12:	0047d713          	srli	a4,a5,0x4
ffffffffc0200f16:	8f5d                	or	a4,a4,a5
ffffffffc0200f18:	00875793          	srli	a5,a4,0x8
ffffffffc0200f1c:	8f5d                	or	a4,a4,a5
ffffffffc0200f1e:	01075793          	srli	a5,a4,0x10
ffffffffc0200f22:	8fd9                	or	a5,a5,a4
ffffffffc0200f24:	8385                	srli	a5,a5,0x1
ffffffffc0200f26:	00f47733          	and	a4,s0,a5
ffffffffc0200f2a:	85a2                	mv	a1,s0
ffffffffc0200f2c:	c709                	beqz	a4,ffffffffc0200f36 <buddy_init_memmap+0xb8>
ffffffffc0200f2e:	fff7c793          	not	a5,a5
ffffffffc0200f32:	0087f5b3          	and	a1,a5,s0
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200f36:	00459613          	slli	a2,a1,0x4
ffffffffc0200f3a:	8231                	srli	a2,a2,0xc
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200f3c:	00006a17          	auipc	s4,0x6
ffffffffc0200f40:	504a0a13          	addi	s4,s4,1284 # ffffffffc0207440 <full_tree_size>
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200f44:	00006b17          	auipc	s6,0x6
ffffffffc0200f48:	514b0b13          	addi	s6,s6,1300 # ffffffffc0207458 <record_area_size>
        cprintf("[DEBUG] buddy_init_memmap: n >= 512, initial full_tree_size set to %lu, initial record_area_size set to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
ffffffffc0200f4c:	00002517          	auipc	a0,0x2
ffffffffc0200f50:	8d450513          	addi	a0,a0,-1836 # ffffffffc0202820 <commands+0xb80>
        record_area_size = full_tree_size * sizeof(size_t) * 2 / PGSIZE;
ffffffffc0200f54:	00cb3023          	sd	a2,0(s6)
        full_tree_size = POWER_ROUND_DOWN(n);
ffffffffc0200f58:	00ba3023          	sd	a1,0(s4)
        cprintf("[DEBUG] buddy_init_memmap: n >= 512, initial full_tree_size set to %lu, initial record_area_size set to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
ffffffffc0200f5c:	94eff0ef          	jal	ra,ffffffffc02000aa <cprintf>
        if (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200f60:	000b3703          	ld	a4,0(s6)
ffffffffc0200f64:	000a3783          	ld	a5,0(s4)
ffffffffc0200f68:	00171613          	slli	a2,a4,0x1
ffffffffc0200f6c:	00f606b3          	add	a3,a2,a5
ffffffffc0200f70:	3686e363          	bltu	a3,s0,ffffffffc02012d6 <buddy_init_memmap+0x458>
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200f74:	00006697          	auipc	a3,0x6
ffffffffc0200f78:	4ec68693          	addi	a3,a3,1260 # ffffffffc0207460 <total_size>
ffffffffc0200f7c:	628c                	ld	a1,0(a3)
ffffffffc0200f7e:	8d99                	sub	a1,a1,a4
ffffffffc0200f80:	00b7f363          	bgeu	a5,a1,ffffffffc0200f86 <buddy_init_memmap+0x108>
ffffffffc0200f84:	85be                	mv	a1,a5
ffffffffc0200f86:	00006797          	auipc	a5,0x6
ffffffffc0200f8a:	4c278793          	addi	a5,a5,1218 # ffffffffc0207448 <real_tree_size>
    cprintf("[DEBUG] buddy_init_memmap: Set real_tree_size to %lu.\n", (unsigned long)real_tree_size);
ffffffffc0200f8e:	00002517          	auipc	a0,0x2
ffffffffc0200f92:	96250513          	addi	a0,a0,-1694 # ffffffffc02028f0 <commands+0xc50>
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc0200f96:	e38c                	sd	a1,0(a5)
    cprintf("[DEBUG] buddy_init_memmap: Set real_tree_size to %lu.\n", (unsigned long)real_tree_size);
ffffffffc0200f98:	912ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200f9c:	00006697          	auipc	a3,0x6
ffffffffc0200fa0:	4d46b683          	ld	a3,1236(a3) # ffffffffc0207470 <pages>
ffffffffc0200fa4:	40d486b3          	sub	a3,s1,a3
ffffffffc0200fa8:	00002797          	auipc	a5,0x2
ffffffffc0200fac:	1607b783          	ld	a5,352(a5) # ffffffffc0203108 <error_string+0x38>
ffffffffc0200fb0:	868d                	srai	a3,a3,0x3
ffffffffc0200fb2:	02f686b3          	mul	a3,a3,a5
ffffffffc0200fb6:	00002617          	auipc	a2,0x2
ffffffffc0200fba:	15a63603          	ld	a2,346(a2) # ffffffffc0203110 <nbase>
    record_area = KADDR(page2pa(base));
ffffffffc0200fbe:	00006717          	auipc	a4,0x6
ffffffffc0200fc2:	4aa73703          	ld	a4,1194(a4) # ffffffffc0207468 <npage>
ffffffffc0200fc6:	96b2                	add	a3,a3,a2
ffffffffc0200fc8:	00c69793          	slli	a5,a3,0xc
ffffffffc0200fcc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fce:	06b2                	slli	a3,a3,0xc
ffffffffc0200fd0:	36e7fa63          	bgeu	a5,a4,ffffffffc0201344 <buddy_init_memmap+0x4c6>
    allocate_area = base + record_area_size;
ffffffffc0200fd4:	000b3783          	ld	a5,0(s6)
    record_area = KADDR(page2pa(base));
ffffffffc0200fd8:	00006617          	auipc	a2,0x6
ffffffffc0200fdc:	4b863603          	ld	a2,1208(a2) # ffffffffc0207490 <va_pa_offset>
ffffffffc0200fe0:	9636                	add	a2,a2,a3
    allocate_area = base + record_area_size;
ffffffffc0200fe2:	00279693          	slli	a3,a5,0x2
ffffffffc0200fe6:	96be                	add	a3,a3,a5
ffffffffc0200fe8:	068e                	slli	a3,a3,0x3
ffffffffc0200fea:	00006797          	auipc	a5,0x6
ffffffffc0200fee:	44e78793          	addi	a5,a5,1102 # ffffffffc0207438 <allocate_area>
    record_area = KADDR(page2pa(base));
ffffffffc0200ff2:	00006997          	auipc	s3,0x6
ffffffffc0200ff6:	45e98993          	addi	s3,s3,1118 # ffffffffc0207450 <record_area>
    allocate_area = base + record_area_size;
ffffffffc0200ffa:	96a6                	add	a3,a3,s1
    cprintf("[DEBUG] buddy_init_memmap: Set physical_area to %p, record_area to %p, allocate_area to %p.\n", physical_area, record_area, allocate_area);
ffffffffc0200ffc:	85a6                	mv	a1,s1
ffffffffc0200ffe:	00002517          	auipc	a0,0x2
ffffffffc0201002:	95250513          	addi	a0,a0,-1710 # ffffffffc0202950 <commands+0xcb0>
    allocate_area = base + record_area_size;
ffffffffc0201006:	e394                	sd	a3,0(a5)
    record_area = KADDR(page2pa(base));
ffffffffc0201008:	00c9b023          	sd	a2,0(s3)
    cprintf("[DEBUG] buddy_init_memmap: Set physical_area to %p, record_area to %p, allocate_area to %p.\n", physical_area, record_area, allocate_area);
ffffffffc020100c:	89eff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] About to clear record_area. record_area address: %p, record_area_size: %lu, size to clear: %lu bytes.\n", record_area, (unsigned long)record_area_size, (unsigned long)(record_area_size * PGSIZE));
ffffffffc0201010:	000b3603          	ld	a2,0(s6)
ffffffffc0201014:	0009b583          	ld	a1,0(s3)
ffffffffc0201018:	00002517          	auipc	a0,0x2
ffffffffc020101c:	99850513          	addi	a0,a0,-1640 # ffffffffc02029b0 <commands+0xd10>
ffffffffc0201020:	00c61693          	slli	a3,a2,0xc
ffffffffc0201024:	886ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    memset(record_area, 0, record_area_size * PGSIZE);
ffffffffc0201028:	000b3603          	ld	a2,0(s6)
ffffffffc020102c:	0009b503          	ld	a0,0(s3)
ffffffffc0201030:	4581                	li	a1,0
ffffffffc0201032:	0632                	slli	a2,a2,0xc
ffffffffc0201034:	1ff000ef          	jal	ra,ffffffffc0201a32 <memset>
    cprintf("[DEBUG] buddy_init_memmap: Cleared record_area with size %lu pages.\n", (unsigned long)record_area_size);
ffffffffc0201038:	000b3583          	ld	a1,0(s6)
ffffffffc020103c:	00002517          	auipc	a0,0x2
ffffffffc0201040:	9e450513          	addi	a0,a0,-1564 # ffffffffc0202a20 <commands+0xd80>
    nr_free += real_tree_size;
ffffffffc0201044:	00006917          	auipc	s2,0x6
ffffffffc0201048:	fcc90913          	addi	s2,s2,-52 # ffffffffc0207010 <free_area>
    cprintf("[DEBUG] buddy_init_memmap: Cleared record_area with size %lu pages.\n", (unsigned long)record_area_size);
ffffffffc020104c:	85eff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    nr_free += real_tree_size;
ffffffffc0201050:	00006417          	auipc	s0,0x6
ffffffffc0201054:	3f840413          	addi	s0,s0,1016 # ffffffffc0207448 <real_tree_size>
ffffffffc0201058:	01092783          	lw	a5,16(s2)
ffffffffc020105c:	6018                	ld	a4,0(s0)
    cprintf("[DEBUG] buddy_init_memmap: Updated nr_free to %lu.\n", (unsigned long)nr_free);
ffffffffc020105e:	00002517          	auipc	a0,0x2
ffffffffc0201062:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0202a68 <commands+0xdc8>
    nr_free += real_tree_size;
ffffffffc0201066:	9fb9                	addw	a5,a5,a4
    cprintf("[DEBUG] buddy_init_memmap: Updated nr_free to %lu.\n", (unsigned long)nr_free);
ffffffffc0201068:	02079593          	slli	a1,a5,0x20
ffffffffc020106c:	9181                	srli	a1,a1,0x20
    nr_free += real_tree_size;
ffffffffc020106e:	00f92823          	sw	a5,16(s2)
    cprintf("[DEBUG] buddy_init_memmap: Updated nr_free to %lu.\n", (unsigned long)nr_free);
ffffffffc0201072:	838ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    record_area[block] = real_subtree_size;
ffffffffc0201076:	0009b783          	ld	a5,0(s3)
    size_t real_subtree_size = real_tree_size;
ffffffffc020107a:	00043d83          	ld	s11,0(s0)
    cprintf("[DEBUG] buddy_init_memmap: Initialized record_area at root block %lu with size %lu.\n", (unsigned long)block, (unsigned long)real_subtree_size);
ffffffffc020107e:	4585                	li	a1,1
ffffffffc0201080:	00002517          	auipc	a0,0x2
ffffffffc0201084:	a2050513          	addi	a0,a0,-1504 # ffffffffc0202aa0 <commands+0xe00>
ffffffffc0201088:	866e                	mv	a2,s11
    record_area[block] = real_subtree_size;
ffffffffc020108a:	01b7b423          	sd	s11,8(a5)
    size_t full_subtree_size = full_tree_size;
ffffffffc020108e:	000a3b83          	ld	s7,0(s4)
    cprintf("[DEBUG] buddy_init_memmap: Initialized record_area at root block %lu with size %lu.\n", (unsigned long)block, (unsigned long)real_subtree_size);
ffffffffc0201092:	818ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size) {
ffffffffc0201096:	160d8763          	beqz	s11,ffffffffc0201204 <buddy_init_memmap+0x386>
ffffffffc020109a:	257dff63          	bgeu	s11,s7,ffffffffc02012f8 <buddy_init_memmap+0x47a>
    size_t block = TREE_ROOT;
ffffffffc020109e:	4d05                	li	s10,1
        cprintf("[DEBUG] buddy_init_memmap: Reduced full_subtree_size to %lu.\n", (unsigned long)full_subtree_size);
ffffffffc02010a0:	00002a97          	auipc	s5,0x2
ffffffffc02010a4:	a58a8a93          	addi	s5,s5,-1448 # ffffffffc0202af8 <commands+0xe58>
        full_subtree_size >>= 1;
ffffffffc02010a8:	001bdb93          	srli	s7,s7,0x1
        cprintf("[DEBUG] buddy_init_memmap: Reduced full_subtree_size to %lu.\n", (unsigned long)full_subtree_size);
ffffffffc02010ac:	85de                	mv	a1,s7
ffffffffc02010ae:	8556                	mv	a0,s5
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc02010b0:	004d1413          	slli	s0,s10,0x4
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size %lu.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)full_subtree_size, (unsigned long)RIGHT_CHILD(block), (unsigned long)real_subtree_size);
ffffffffc02010b4:	001d1493          	slli	s1,s10,0x1
        cprintf("[DEBUG] buddy_init_memmap: Reduced full_subtree_size to %lu.\n", (unsigned long)full_subtree_size);
ffffffffc02010b8:	ff3fe0ef          	jal	ra,ffffffffc02000aa <cprintf>
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
ffffffffc02010bc:	00840c13          	addi	s8,s0,8
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size %lu.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)full_subtree_size, (unsigned long)RIGHT_CHILD(block), (unsigned long)real_subtree_size);
ffffffffc02010c0:	00148c93          	addi	s9,s1,1
        if (real_subtree_size > full_subtree_size) {
ffffffffc02010c4:	1fbbf263          	bgeu	s7,s11,ffffffffc02012a8 <buddy_init_memmap+0x42a>
            struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc02010c8:	001d5513          	srli	a0,s10,0x1
ffffffffc02010cc:	01a56533          	or	a0,a0,s10
ffffffffc02010d0:	00255593          	srli	a1,a0,0x2
ffffffffc02010d4:	8d4d                	or	a0,a0,a1
ffffffffc02010d6:	00455593          	srli	a1,a0,0x4
ffffffffc02010da:	8dc9                	or	a1,a1,a0
ffffffffc02010dc:	0085d513          	srli	a0,a1,0x8
ffffffffc02010e0:	8dc9                	or	a1,a1,a0
ffffffffc02010e2:	0105d513          	srli	a0,a1,0x10
ffffffffc02010e6:	8d4d                	or	a0,a0,a1
ffffffffc02010e8:	8105                	srli	a0,a0,0x1
ffffffffc02010ea:	00006797          	auipc	a5,0x6
ffffffffc02010ee:	34e78793          	addi	a5,a5,846 # ffffffffc0207438 <allocate_area>
ffffffffc02010f2:	01a57333          	and	t1,a0,s10
ffffffffc02010f6:	638c                	ld	a1,0(a5)
ffffffffc02010f8:	000a3883          	ld	a7,0(s4)
ffffffffc02010fc:	00030663          	beqz	t1,ffffffffc0201108 <buddy_init_memmap+0x28a>
ffffffffc0201100:	fff54513          	not	a0,a0
ffffffffc0201104:	00ad7d33          	and	s10,s10,a0
ffffffffc0201108:	03a8d633          	divu	a2,a7,s10
    __list_add(elm, listelm, listelm->next);
ffffffffc020110c:	00893883          	ld	a7,8(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201110:	4709                	li	a4,2
ffffffffc0201112:	02660633          	mul	a2,a2,t1
ffffffffc0201116:	00261513          	slli	a0,a2,0x2
ffffffffc020111a:	962a                	add	a2,a2,a0
ffffffffc020111c:	060e                	slli	a2,a2,0x3
ffffffffc020111e:	95b2                	add	a1,a1,a2
            list_add(&free_list, &page->page_link);
ffffffffc0201120:	01858613          	addi	a2,a1,24
            page->property = full_subtree_size;
ffffffffc0201124:	0175a823          	sw	s7,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201128:	00c8b023          	sd	a2,0(a7)
ffffffffc020112c:	00c93423          	sd	a2,8(s2)
    elm->next = next;
ffffffffc0201130:	0315b023          	sd	a7,32(a1)
    elm->prev = prev;
ffffffffc0201134:	0125bc23          	sd	s2,24(a1)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201138:	0005a023          	sw	zero,0(a1)
ffffffffc020113c:	00858793          	addi	a5,a1,8
ffffffffc0201140:	40e7b02f          	amoor.d	zero,a4,(a5)
            cprintf("[DEBUG] buddy_init_memmap: Added page at %p with size %lu to free_list.\n", page, (unsigned long)full_subtree_size);
ffffffffc0201144:	00002517          	auipc	a0,0x2
ffffffffc0201148:	9f450513          	addi	a0,a0,-1548 # ffffffffc0202b38 <commands+0xe98>
ffffffffc020114c:	865e                	mv	a2,s7
ffffffffc020114e:	f5dfe0ef          	jal	ra,ffffffffc02000aa <cprintf>
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc0201152:	0009b603          	ld	a2,0(s3)
            real_subtree_size -= full_subtree_size;
ffffffffc0201156:	417d8db3          	sub	s11,s11,s7
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size %lu.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)full_subtree_size, (unsigned long)RIGHT_CHILD(block), (unsigned long)real_subtree_size);
ffffffffc020115a:	876e                	mv	a4,s11
            record_area[LEFT_CHILD(block)] = full_subtree_size;
ffffffffc020115c:	9432                	add	s0,s0,a2
ffffffffc020115e:	01743023          	sd	s7,0(s0)
            record_area[RIGHT_CHILD(block)] = real_subtree_size;
ffffffffc0201162:	9662                	add	a2,a2,s8
ffffffffc0201164:	01b63023          	sd	s11,0(a2)
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size %lu.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)full_subtree_size, (unsigned long)RIGHT_CHILD(block), (unsigned long)real_subtree_size);
ffffffffc0201168:	86e6                	mv	a3,s9
ffffffffc020116a:	865e                	mv	a2,s7
ffffffffc020116c:	85a6                	mv	a1,s1
ffffffffc020116e:	00002517          	auipc	a0,0x2
ffffffffc0201172:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0202b88 <commands+0xee8>
ffffffffc0201176:	f35fe0ef          	jal	ra,ffffffffc02000aa <cprintf>
            block = RIGHT_CHILD(block);
ffffffffc020117a:	8d66                	mv	s10,s9
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size) {
ffffffffc020117c:	f37de6e3          	bltu	s11,s7,ffffffffc02010a8 <buddy_init_memmap+0x22a>
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc0201180:	001d5793          	srli	a5,s10,0x1
ffffffffc0201184:	01a7e7b3          	or	a5,a5,s10
ffffffffc0201188:	0027d693          	srli	a3,a5,0x2
ffffffffc020118c:	8fd5                	or	a5,a5,a3
ffffffffc020118e:	0047d693          	srli	a3,a5,0x4
ffffffffc0201192:	8edd                	or	a3,a3,a5
ffffffffc0201194:	0086d793          	srli	a5,a3,0x8
ffffffffc0201198:	8edd                	or	a3,a3,a5
ffffffffc020119a:	0106d793          	srli	a5,a3,0x10
ffffffffc020119e:	8fd5                	or	a5,a5,a3
ffffffffc02011a0:	8385                	srli	a5,a5,0x1
ffffffffc02011a2:	00006717          	auipc	a4,0x6
ffffffffc02011a6:	29670713          	addi	a4,a4,662 # ffffffffc0207438 <allocate_area>
ffffffffc02011aa:	01a7f533          	and	a0,a5,s10
ffffffffc02011ae:	630c                	ld	a1,0(a4)
ffffffffc02011b0:	000a3683          	ld	a3,0(s4)
ffffffffc02011b4:	cd11                	beqz	a0,ffffffffc02011d0 <buddy_init_memmap+0x352>
ffffffffc02011b6:	fff7c793          	not	a5,a5
ffffffffc02011ba:	01a7f633          	and	a2,a5,s10
ffffffffc02011be:	02c6d633          	divu	a2,a3,a2
ffffffffc02011c2:	02a607b3          	mul	a5,a2,a0
ffffffffc02011c6:	00279693          	slli	a3,a5,0x2
ffffffffc02011ca:	97b6                	add	a5,a5,a3
ffffffffc02011cc:	078e                	slli	a5,a5,0x3
ffffffffc02011ce:	95be                	add	a1,a1,a5
        page->property = real_subtree_size;
ffffffffc02011d0:	01b5a823          	sw	s11,16(a1)
ffffffffc02011d4:	0005a023          	sw	zero,0(a1)
ffffffffc02011d8:	4789                	li	a5,2
ffffffffc02011da:	00858713          	addi	a4,a1,8
ffffffffc02011de:	40f7302f          	amoor.d	zero,a5,(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc02011e2:	00893683          	ld	a3,8(s2)
        list_add(&free_list, &page->page_link);
ffffffffc02011e6:	01858793          	addi	a5,a1,24
        cprintf("[DEBUG] buddy_init_memmap: Added remaining page at %p with size %lu to free_list.\n", page, (unsigned long)real_subtree_size);
ffffffffc02011ea:	866e                	mv	a2,s11
    prev->next = next->prev = elm;
ffffffffc02011ec:	e29c                	sd	a5,0(a3)
    elm->next = next;
ffffffffc02011ee:	f194                	sd	a3,32(a1)
    elm->prev = prev;
ffffffffc02011f0:	0125bc23          	sd	s2,24(a1)
ffffffffc02011f4:	00002517          	auipc	a0,0x2
ffffffffc02011f8:	a8450513          	addi	a0,a0,-1404 # ffffffffc0202c78 <commands+0xfd8>
    prev->next = next->prev = elm;
ffffffffc02011fc:	00f93423          	sd	a5,8(s2)
ffffffffc0201200:	eabfe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("[DEBUG] Initialized memory map. Total size: %lu, Full tree size: %lu, Record area size: %lu, Real tree size: %lu\n", (unsigned long)total_size, (unsigned long)full_tree_size, (unsigned long)record_area_size, (unsigned long)real_tree_size);
ffffffffc0201204:	00006797          	auipc	a5,0x6
ffffffffc0201208:	24478793          	addi	a5,a5,580 # ffffffffc0207448 <real_tree_size>
ffffffffc020120c:	6398                	ld	a4,0(a5)
}
ffffffffc020120e:	7406                	ld	s0,96(sp)
    cprintf("[DEBUG] Initialized memory map. Total size: %lu, Full tree size: %lu, Record area size: %lu, Real tree size: %lu\n", (unsigned long)total_size, (unsigned long)full_tree_size, (unsigned long)record_area_size, (unsigned long)real_tree_size);
ffffffffc0201210:	00006797          	auipc	a5,0x6
ffffffffc0201214:	25078793          	addi	a5,a5,592 # ffffffffc0207460 <total_size>
ffffffffc0201218:	000b3683          	ld	a3,0(s6)
ffffffffc020121c:	000a3603          	ld	a2,0(s4)
}
ffffffffc0201220:	70a6                	ld	ra,104(sp)
ffffffffc0201222:	64e6                	ld	s1,88(sp)
ffffffffc0201224:	6946                	ld	s2,80(sp)
ffffffffc0201226:	69a6                	ld	s3,72(sp)
ffffffffc0201228:	6a06                	ld	s4,64(sp)
ffffffffc020122a:	7ae2                	ld	s5,56(sp)
ffffffffc020122c:	7b42                	ld	s6,48(sp)
ffffffffc020122e:	7ba2                	ld	s7,40(sp)
ffffffffc0201230:	7c02                	ld	s8,32(sp)
ffffffffc0201232:	6ce2                	ld	s9,24(sp)
ffffffffc0201234:	6d42                	ld	s10,16(sp)
ffffffffc0201236:	6da2                	ld	s11,8(sp)
    cprintf("[DEBUG] Initialized memory map. Total size: %lu, Full tree size: %lu, Record area size: %lu, Real tree size: %lu\n", (unsigned long)total_size, (unsigned long)full_tree_size, (unsigned long)record_area_size, (unsigned long)real_tree_size);
ffffffffc0201238:	638c                	ld	a1,0(a5)
ffffffffc020123a:	00002517          	auipc	a0,0x2
ffffffffc020123e:	a9650513          	addi	a0,a0,-1386 # ffffffffc0202cd0 <commands+0x1030>
}
ffffffffc0201242:	6165                	addi	sp,sp,112
    cprintf("[DEBUG] Initialized memory map. Total size: %lu, Full tree size: %lu, Record area size: %lu, Real tree size: %lu\n", (unsigned long)total_size, (unsigned long)full_tree_size, (unsigned long)record_area_size, (unsigned long)real_tree_size);
ffffffffc0201244:	e67fe06f          	j	ffffffffc02000aa <cprintf>
        full_tree_size = POWER_ROUND_UP(n - 1);
ffffffffc0201248:	fff40593          	addi	a1,s0,-1
ffffffffc020124c:	0015d713          	srli	a4,a1,0x1
ffffffffc0201250:	00b767b3          	or	a5,a4,a1
ffffffffc0201254:	0027d713          	srli	a4,a5,0x2
ffffffffc0201258:	8f5d                	or	a4,a4,a5
ffffffffc020125a:	00475793          	srli	a5,a4,0x4
ffffffffc020125e:	8f5d                	or	a4,a4,a5
ffffffffc0201260:	00875793          	srli	a5,a4,0x8
ffffffffc0201264:	8fd9                	or	a5,a5,a4
ffffffffc0201266:	8385                	srli	a5,a5,0x1
ffffffffc0201268:	00f5f733          	and	a4,a1,a5
ffffffffc020126c:	c709                	beqz	a4,ffffffffc0201276 <buddy_init_memmap+0x3f8>
ffffffffc020126e:	fff7c793          	not	a5,a5
ffffffffc0201272:	8dfd                	and	a1,a1,a5
ffffffffc0201274:	0586                	slli	a1,a1,0x1
        record_area_size = 1;
ffffffffc0201276:	4785                	li	a5,1
        full_tree_size = POWER_ROUND_UP(n - 1);
ffffffffc0201278:	00006a17          	auipc	s4,0x6
ffffffffc020127c:	1c8a0a13          	addi	s4,s4,456 # ffffffffc0207440 <full_tree_size>
        record_area_size = 1;
ffffffffc0201280:	00006b17          	auipc	s6,0x6
ffffffffc0201284:	1d8b0b13          	addi	s6,s6,472 # ffffffffc0207458 <record_area_size>
        cprintf("[DEBUG] buddy_init_memmap: n < 512, full_tree_size set to %lu, record_area_size set to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
ffffffffc0201288:	4605                	li	a2,1
ffffffffc020128a:	00001517          	auipc	a0,0x1
ffffffffc020128e:	53650513          	addi	a0,a0,1334 # ffffffffc02027c0 <commands+0xb20>
        record_area_size = 1;
ffffffffc0201292:	00fb3023          	sd	a5,0(s6)
        full_tree_size = POWER_ROUND_UP(n - 1);
ffffffffc0201296:	00ba3023          	sd	a1,0(s4)
        cprintf("[DEBUG] buddy_init_memmap: n < 512, full_tree_size set to %lu, record_area_size set to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
ffffffffc020129a:	e11fe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc020129e:	000b3703          	ld	a4,0(s6)
ffffffffc02012a2:	000a3783          	ld	a5,0(s4)
ffffffffc02012a6:	b1f9                	j	ffffffffc0200f74 <buddy_init_memmap+0xf6>
            record_area[LEFT_CHILD(block)] = real_subtree_size;
ffffffffc02012a8:	0009b583          	ld	a1,0(s3)
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size 0.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)real_subtree_size, (unsigned long)RIGHT_CHILD(block));
ffffffffc02012ac:	86e6                	mv	a3,s9
ffffffffc02012ae:	866e                	mv	a2,s11
            record_area[LEFT_CHILD(block)] = real_subtree_size;
ffffffffc02012b0:	942e                	add	s0,s0,a1
ffffffffc02012b2:	01b43023          	sd	s11,0(s0)
            record_area[RIGHT_CHILD(block)] = 0;
ffffffffc02012b6:	95e2                	add	a1,a1,s8
ffffffffc02012b8:	0005b023          	sd	zero,0(a1)
            cprintf("[DEBUG] buddy_init_memmap: Updated record_area for left child %lu with size %lu and right child %lu with size 0.\n", (unsigned long)LEFT_CHILD(block), (unsigned long)real_subtree_size, (unsigned long)RIGHT_CHILD(block));
ffffffffc02012bc:	00002517          	auipc	a0,0x2
ffffffffc02012c0:	94450513          	addi	a0,a0,-1724 # ffffffffc0202c00 <commands+0xf60>
ffffffffc02012c4:	85a6                	mv	a1,s1
ffffffffc02012c6:	de5fe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size) {
ffffffffc02012ca:	f20d8de3          	beqz	s11,ffffffffc0201204 <buddy_init_memmap+0x386>
            block = LEFT_CHILD(block);
ffffffffc02012ce:	8d26                	mv	s10,s1
    while (real_subtree_size > 0 && real_subtree_size < full_subtree_size) {
ffffffffc02012d0:	dd7dece3          	bltu	s11,s7,ffffffffc02010a8 <buddy_init_memmap+0x22a>
ffffffffc02012d4:	b575                	j	ffffffffc0201180 <buddy_init_memmap+0x302>
            full_tree_size <<= 1;
ffffffffc02012d6:	00179593          	slli	a1,a5,0x1
            cprintf("[DEBUG] buddy_init_memmap: Expanded full_tree_size to %lu, expanded record_area_size to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
ffffffffc02012da:	00001517          	auipc	a0,0x1
ffffffffc02012de:	5b650513          	addi	a0,a0,1462 # ffffffffc0202890 <commands+0xbf0>
            full_tree_size <<= 1;
ffffffffc02012e2:	00ba3023          	sd	a1,0(s4)
            record_area_size <<= 1;
ffffffffc02012e6:	00cb3023          	sd	a2,0(s6)
            cprintf("[DEBUG] buddy_init_memmap: Expanded full_tree_size to %lu, expanded record_area_size to %lu.\n", (unsigned long)full_tree_size, (unsigned long)record_area_size);
ffffffffc02012ea:	dc1fe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    real_tree_size = (full_tree_size < total_size - record_area_size) ? full_tree_size : total_size - record_area_size;
ffffffffc02012ee:	000b3703          	ld	a4,0(s6)
ffffffffc02012f2:	000a3783          	ld	a5,0(s4)
ffffffffc02012f6:	b9bd                	j	ffffffffc0200f74 <buddy_init_memmap+0xf6>
        struct Page *page = &allocate_area[NODE_BEGINNING(block)];
ffffffffc02012f8:	00006797          	auipc	a5,0x6
ffffffffc02012fc:	14078793          	addi	a5,a5,320 # ffffffffc0207438 <allocate_area>
ffffffffc0201300:	638c                	ld	a1,0(a5)
ffffffffc0201302:	b5f9                	j	ffffffffc02011d0 <buddy_init_memmap+0x352>
        assert(PageReserved(p));
ffffffffc0201304:	00001697          	auipc	a3,0x1
ffffffffc0201308:	4ac68693          	addi	a3,a3,1196 # ffffffffc02027b0 <commands+0xb10>
ffffffffc020130c:	00001617          	auipc	a2,0x1
ffffffffc0201310:	dec60613          	addi	a2,a2,-532 # ffffffffc02020f8 <commands+0x458>
ffffffffc0201314:	03400593          	li	a1,52
ffffffffc0201318:	00001517          	auipc	a0,0x1
ffffffffc020131c:	df850513          	addi	a0,a0,-520 # ffffffffc0202110 <commands+0x470>
ffffffffc0201320:	884ff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(n > 0);
ffffffffc0201324:	00001697          	auipc	a3,0x1
ffffffffc0201328:	dcc68693          	addi	a3,a3,-564 # ffffffffc02020f0 <commands+0x450>
ffffffffc020132c:	00001617          	auipc	a2,0x1
ffffffffc0201330:	dcc60613          	addi	a2,a2,-564 # ffffffffc02020f8 <commands+0x458>
ffffffffc0201334:	02f00593          	li	a1,47
ffffffffc0201338:	00001517          	auipc	a0,0x1
ffffffffc020133c:	dd850513          	addi	a0,a0,-552 # ffffffffc0202110 <commands+0x470>
ffffffffc0201340:	864ff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    record_area = KADDR(page2pa(base));
ffffffffc0201344:	00001617          	auipc	a2,0x1
ffffffffc0201348:	5e460613          	addi	a2,a2,1508 # ffffffffc0202928 <commands+0xc88>
ffffffffc020134c:	04f00593          	li	a1,79
ffffffffc0201350:	00001517          	auipc	a0,0x1
ffffffffc0201354:	dc050513          	addi	a0,a0,-576 # ffffffffc0202110 <commands+0x470>
ffffffffc0201358:	84cff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc020135c <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &buddy_pmm_manager;
ffffffffc020135c:	00002797          	auipc	a5,0x2
ffffffffc0201360:	a0478793          	addi	a5,a5,-1532 # ffffffffc0202d60 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201364:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201366:	1101                	addi	sp,sp,-32
ffffffffc0201368:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020136a:	00002517          	auipc	a0,0x2
ffffffffc020136e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc0202d98 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201372:	00006497          	auipc	s1,0x6
ffffffffc0201376:	10648493          	addi	s1,s1,262 # ffffffffc0207478 <pmm_manager>
void pmm_init(void) {
ffffffffc020137a:	ec06                	sd	ra,24(sp)
ffffffffc020137c:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020137e:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201380:	d2bfe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    pmm_manager->init();
ffffffffc0201384:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201386:	00006417          	auipc	s0,0x6
ffffffffc020138a:	10a40413          	addi	s0,s0,266 # ffffffffc0207490 <va_pa_offset>
    pmm_manager->init();
ffffffffc020138e:	679c                	ld	a5,8(a5)
ffffffffc0201390:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201392:	57f5                	li	a5,-3
ffffffffc0201394:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201396:	00002517          	auipc	a0,0x2
ffffffffc020139a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0202db0 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020139e:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02013a0:	d0bfe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013a4:	46c5                	li	a3,17
ffffffffc02013a6:	06ee                	slli	a3,a3,0x1b
ffffffffc02013a8:	40100613          	li	a2,1025
ffffffffc02013ac:	16fd                	addi	a3,a3,-1
ffffffffc02013ae:	07e005b7          	lui	a1,0x7e00
ffffffffc02013b2:	0656                	slli	a2,a2,0x15
ffffffffc02013b4:	00002517          	auipc	a0,0x2
ffffffffc02013b8:	a1450513          	addi	a0,a0,-1516 # ffffffffc0202dc8 <buddy_pmm_manager+0x68>
ffffffffc02013bc:	ceffe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013c0:	777d                	lui	a4,0xfffff
ffffffffc02013c2:	00007797          	auipc	a5,0x7
ffffffffc02013c6:	0dd78793          	addi	a5,a5,221 # ffffffffc020849f <end+0xfff>
ffffffffc02013ca:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02013cc:	00006517          	auipc	a0,0x6
ffffffffc02013d0:	09c50513          	addi	a0,a0,156 # ffffffffc0207468 <npage>
ffffffffc02013d4:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013d8:	00006597          	auipc	a1,0x6
ffffffffc02013dc:	09858593          	addi	a1,a1,152 # ffffffffc0207470 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02013e0:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013e2:	e19c                	sd	a5,0(a1)
ffffffffc02013e4:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013e6:	4701                	li	a4,0
ffffffffc02013e8:	4885                	li	a7,1
ffffffffc02013ea:	fff80837          	lui	a6,0xfff80
ffffffffc02013ee:	a011                	j	ffffffffc02013f2 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02013f0:	619c                	ld	a5,0(a1)
ffffffffc02013f2:	97b6                	add	a5,a5,a3
ffffffffc02013f4:	07a1                	addi	a5,a5,8
ffffffffc02013f6:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013fa:	611c                	ld	a5,0(a0)
ffffffffc02013fc:	0705                	addi	a4,a4,1
ffffffffc02013fe:	02868693          	addi	a3,a3,40
ffffffffc0201402:	01078633          	add	a2,a5,a6
ffffffffc0201406:	fec765e3          	bltu	a4,a2,ffffffffc02013f0 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020140a:	6190                	ld	a2,0(a1)
ffffffffc020140c:	00279713          	slli	a4,a5,0x2
ffffffffc0201410:	973e                	add	a4,a4,a5
ffffffffc0201412:	fec006b7          	lui	a3,0xfec00
ffffffffc0201416:	070e                	slli	a4,a4,0x3
ffffffffc0201418:	96b2                	add	a3,a3,a2
ffffffffc020141a:	96ba                	add	a3,a3,a4
ffffffffc020141c:	c0200737          	lui	a4,0xc0200
ffffffffc0201420:	08e6ef63          	bltu	a3,a4,ffffffffc02014be <pmm_init+0x162>
ffffffffc0201424:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201426:	45c5                	li	a1,17
ffffffffc0201428:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020142a:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020142c:	04b6e863          	bltu	a3,a1,ffffffffc020147c <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201430:	609c                	ld	a5,0(s1)
ffffffffc0201432:	7b9c                	ld	a5,48(a5)
ffffffffc0201434:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201436:	00002517          	auipc	a0,0x2
ffffffffc020143a:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0202e60 <buddy_pmm_manager+0x100>
ffffffffc020143e:	c6dfe0ef          	jal	ra,ffffffffc02000aa <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201442:	00005597          	auipc	a1,0x5
ffffffffc0201446:	bbe58593          	addi	a1,a1,-1090 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc020144a:	00006797          	auipc	a5,0x6
ffffffffc020144e:	02b7bf23          	sd	a1,62(a5) # ffffffffc0207488 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201452:	c02007b7          	lui	a5,0xc0200
ffffffffc0201456:	08f5e063          	bltu	a1,a5,ffffffffc02014d6 <pmm_init+0x17a>
ffffffffc020145a:	6010                	ld	a2,0(s0)
}
ffffffffc020145c:	6442                	ld	s0,16(sp)
ffffffffc020145e:	60e2                	ld	ra,24(sp)
ffffffffc0201460:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201462:	40c58633          	sub	a2,a1,a2
ffffffffc0201466:	00006797          	auipc	a5,0x6
ffffffffc020146a:	00c7bd23          	sd	a2,26(a5) # ffffffffc0207480 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020146e:	00002517          	auipc	a0,0x2
ffffffffc0201472:	a1250513          	addi	a0,a0,-1518 # ffffffffc0202e80 <buddy_pmm_manager+0x120>
}
ffffffffc0201476:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201478:	c33fe06f          	j	ffffffffc02000aa <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020147c:	6705                	lui	a4,0x1
ffffffffc020147e:	177d                	addi	a4,a4,-1
ffffffffc0201480:	96ba                	add	a3,a3,a4
ffffffffc0201482:	777d                	lui	a4,0xfffff
ffffffffc0201484:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201486:	00c6d513          	srli	a0,a3,0xc
ffffffffc020148a:	00f57e63          	bgeu	a0,a5,ffffffffc02014a6 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc020148e:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201490:	982a                	add	a6,a6,a0
ffffffffc0201492:	00281513          	slli	a0,a6,0x2
ffffffffc0201496:	9542                	add	a0,a0,a6
ffffffffc0201498:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020149a:	8d95                	sub	a1,a1,a3
ffffffffc020149c:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020149e:	81b1                	srli	a1,a1,0xc
ffffffffc02014a0:	9532                	add	a0,a0,a2
ffffffffc02014a2:	9782                	jalr	a5
}
ffffffffc02014a4:	b771                	j	ffffffffc0201430 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02014a6:	00002617          	auipc	a2,0x2
ffffffffc02014aa:	98a60613          	addi	a2,a2,-1654 # ffffffffc0202e30 <buddy_pmm_manager+0xd0>
ffffffffc02014ae:	06b00593          	li	a1,107
ffffffffc02014b2:	00002517          	auipc	a0,0x2
ffffffffc02014b6:	99e50513          	addi	a0,a0,-1634 # ffffffffc0202e50 <buddy_pmm_manager+0xf0>
ffffffffc02014ba:	eebfe0ef          	jal	ra,ffffffffc02003a4 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014be:	00002617          	auipc	a2,0x2
ffffffffc02014c2:	93a60613          	addi	a2,a2,-1734 # ffffffffc0202df8 <buddy_pmm_manager+0x98>
ffffffffc02014c6:	06f00593          	li	a1,111
ffffffffc02014ca:	00002517          	auipc	a0,0x2
ffffffffc02014ce:	95650513          	addi	a0,a0,-1706 # ffffffffc0202e20 <buddy_pmm_manager+0xc0>
ffffffffc02014d2:	ed3fe0ef          	jal	ra,ffffffffc02003a4 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014d6:	86ae                	mv	a3,a1
ffffffffc02014d8:	00002617          	auipc	a2,0x2
ffffffffc02014dc:	92060613          	addi	a2,a2,-1760 # ffffffffc0202df8 <buddy_pmm_manager+0x98>
ffffffffc02014e0:	08a00593          	li	a1,138
ffffffffc02014e4:	00002517          	auipc	a0,0x2
ffffffffc02014e8:	93c50513          	addi	a0,a0,-1732 # ffffffffc0202e20 <buddy_pmm_manager+0xc0>
ffffffffc02014ec:	eb9fe0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc02014f0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02014f0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014f4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02014f6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014fa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02014fc:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201500:	f022                	sd	s0,32(sp)
ffffffffc0201502:	ec26                	sd	s1,24(sp)
ffffffffc0201504:	e84a                	sd	s2,16(sp)
ffffffffc0201506:	f406                	sd	ra,40(sp)
ffffffffc0201508:	e44e                	sd	s3,8(sp)
ffffffffc020150a:	84aa                	mv	s1,a0
ffffffffc020150c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020150e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201512:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201514:	03067e63          	bgeu	a2,a6,ffffffffc0201550 <printnum+0x60>
ffffffffc0201518:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020151a:	00805763          	blez	s0,ffffffffc0201528 <printnum+0x38>
ffffffffc020151e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201520:	85ca                	mv	a1,s2
ffffffffc0201522:	854e                	mv	a0,s3
ffffffffc0201524:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201526:	fc65                	bnez	s0,ffffffffc020151e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201528:	1a02                	slli	s4,s4,0x20
ffffffffc020152a:	00002797          	auipc	a5,0x2
ffffffffc020152e:	99678793          	addi	a5,a5,-1642 # ffffffffc0202ec0 <buddy_pmm_manager+0x160>
ffffffffc0201532:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201536:	9a3e                	add	s4,s4,a5
}
ffffffffc0201538:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020153a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020153e:	70a2                	ld	ra,40(sp)
ffffffffc0201540:	69a2                	ld	s3,8(sp)
ffffffffc0201542:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201544:	85ca                	mv	a1,s2
ffffffffc0201546:	87a6                	mv	a5,s1
}
ffffffffc0201548:	6942                	ld	s2,16(sp)
ffffffffc020154a:	64e2                	ld	s1,24(sp)
ffffffffc020154c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020154e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201550:	03065633          	divu	a2,a2,a6
ffffffffc0201554:	8722                	mv	a4,s0
ffffffffc0201556:	f9bff0ef          	jal	ra,ffffffffc02014f0 <printnum>
ffffffffc020155a:	b7f9                	j	ffffffffc0201528 <printnum+0x38>

ffffffffc020155c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020155c:	7119                	addi	sp,sp,-128
ffffffffc020155e:	f4a6                	sd	s1,104(sp)
ffffffffc0201560:	f0ca                	sd	s2,96(sp)
ffffffffc0201562:	ecce                	sd	s3,88(sp)
ffffffffc0201564:	e8d2                	sd	s4,80(sp)
ffffffffc0201566:	e4d6                	sd	s5,72(sp)
ffffffffc0201568:	e0da                	sd	s6,64(sp)
ffffffffc020156a:	fc5e                	sd	s7,56(sp)
ffffffffc020156c:	f06a                	sd	s10,32(sp)
ffffffffc020156e:	fc86                	sd	ra,120(sp)
ffffffffc0201570:	f8a2                	sd	s0,112(sp)
ffffffffc0201572:	f862                	sd	s8,48(sp)
ffffffffc0201574:	f466                	sd	s9,40(sp)
ffffffffc0201576:	ec6e                	sd	s11,24(sp)
ffffffffc0201578:	892a                	mv	s2,a0
ffffffffc020157a:	84ae                	mv	s1,a1
ffffffffc020157c:	8d32                	mv	s10,a2
ffffffffc020157e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201580:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201584:	5b7d                	li	s6,-1
ffffffffc0201586:	00002a97          	auipc	s5,0x2
ffffffffc020158a:	96ea8a93          	addi	s5,s5,-1682 # ffffffffc0202ef4 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020158e:	00002b97          	auipc	s7,0x2
ffffffffc0201592:	b42b8b93          	addi	s7,s7,-1214 # ffffffffc02030d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201596:	000d4503          	lbu	a0,0(s10)
ffffffffc020159a:	001d0413          	addi	s0,s10,1
ffffffffc020159e:	01350a63          	beq	a0,s3,ffffffffc02015b2 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02015a2:	c121                	beqz	a0,ffffffffc02015e2 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02015a4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015a6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02015a8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015aa:	fff44503          	lbu	a0,-1(s0)
ffffffffc02015ae:	ff351ae3          	bne	a0,s3,ffffffffc02015a2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02015b6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02015ba:	4c81                	li	s9,0
ffffffffc02015bc:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02015be:	5c7d                	li	s8,-1
ffffffffc02015c0:	5dfd                	li	s11,-1
ffffffffc02015c2:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02015c6:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015c8:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015cc:	0ff5f593          	zext.b	a1,a1
ffffffffc02015d0:	00140d13          	addi	s10,s0,1
ffffffffc02015d4:	04b56263          	bltu	a0,a1,ffffffffc0201618 <vprintfmt+0xbc>
ffffffffc02015d8:	058a                	slli	a1,a1,0x2
ffffffffc02015da:	95d6                	add	a1,a1,s5
ffffffffc02015dc:	4194                	lw	a3,0(a1)
ffffffffc02015de:	96d6                	add	a3,a3,s5
ffffffffc02015e0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02015e2:	70e6                	ld	ra,120(sp)
ffffffffc02015e4:	7446                	ld	s0,112(sp)
ffffffffc02015e6:	74a6                	ld	s1,104(sp)
ffffffffc02015e8:	7906                	ld	s2,96(sp)
ffffffffc02015ea:	69e6                	ld	s3,88(sp)
ffffffffc02015ec:	6a46                	ld	s4,80(sp)
ffffffffc02015ee:	6aa6                	ld	s5,72(sp)
ffffffffc02015f0:	6b06                	ld	s6,64(sp)
ffffffffc02015f2:	7be2                	ld	s7,56(sp)
ffffffffc02015f4:	7c42                	ld	s8,48(sp)
ffffffffc02015f6:	7ca2                	ld	s9,40(sp)
ffffffffc02015f8:	7d02                	ld	s10,32(sp)
ffffffffc02015fa:	6de2                	ld	s11,24(sp)
ffffffffc02015fc:	6109                	addi	sp,sp,128
ffffffffc02015fe:	8082                	ret
            padc = '0';
ffffffffc0201600:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201602:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201606:	846a                	mv	s0,s10
ffffffffc0201608:	00140d13          	addi	s10,s0,1
ffffffffc020160c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201610:	0ff5f593          	zext.b	a1,a1
ffffffffc0201614:	fcb572e3          	bgeu	a0,a1,ffffffffc02015d8 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201618:	85a6                	mv	a1,s1
ffffffffc020161a:	02500513          	li	a0,37
ffffffffc020161e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201620:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201624:	8d22                	mv	s10,s0
ffffffffc0201626:	f73788e3          	beq	a5,s3,ffffffffc0201596 <vprintfmt+0x3a>
ffffffffc020162a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020162e:	1d7d                	addi	s10,s10,-1
ffffffffc0201630:	ff379de3          	bne	a5,s3,ffffffffc020162a <vprintfmt+0xce>
ffffffffc0201634:	b78d                	j	ffffffffc0201596 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201636:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020163a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020163e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201640:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201644:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201648:	02d86463          	bltu	a6,a3,ffffffffc0201670 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020164c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201650:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201654:	0186873b          	addw	a4,a3,s8
ffffffffc0201658:	0017171b          	slliw	a4,a4,0x1
ffffffffc020165c:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc020165e:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201662:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201664:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0201668:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020166c:	fed870e3          	bgeu	a6,a3,ffffffffc020164c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201670:	f40ddce3          	bgez	s11,ffffffffc02015c8 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201674:	8de2                	mv	s11,s8
ffffffffc0201676:	5c7d                	li	s8,-1
ffffffffc0201678:	bf81                	j	ffffffffc02015c8 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020167a:	fffdc693          	not	a3,s11
ffffffffc020167e:	96fd                	srai	a3,a3,0x3f
ffffffffc0201680:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201684:	00144603          	lbu	a2,1(s0)
ffffffffc0201688:	2d81                	sext.w	s11,s11
ffffffffc020168a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020168c:	bf35                	j	ffffffffc02015c8 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc020168e:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201692:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201696:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201698:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020169a:	bfd9                	j	ffffffffc0201670 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc020169c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020169e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016a2:	01174463          	blt	a4,a7,ffffffffc02016aa <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02016a6:	1a088e63          	beqz	a7,ffffffffc0201862 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02016aa:	000a3603          	ld	a2,0(s4)
ffffffffc02016ae:	46c1                	li	a3,16
ffffffffc02016b0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02016b2:	2781                	sext.w	a5,a5
ffffffffc02016b4:	876e                	mv	a4,s11
ffffffffc02016b6:	85a6                	mv	a1,s1
ffffffffc02016b8:	854a                	mv	a0,s2
ffffffffc02016ba:	e37ff0ef          	jal	ra,ffffffffc02014f0 <printnum>
            break;
ffffffffc02016be:	bde1                	j	ffffffffc0201596 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02016c0:	000a2503          	lw	a0,0(s4)
ffffffffc02016c4:	85a6                	mv	a1,s1
ffffffffc02016c6:	0a21                	addi	s4,s4,8
ffffffffc02016c8:	9902                	jalr	s2
            break;
ffffffffc02016ca:	b5f1                	j	ffffffffc0201596 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016cc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016ce:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016d2:	01174463          	blt	a4,a7,ffffffffc02016da <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02016d6:	18088163          	beqz	a7,ffffffffc0201858 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02016da:	000a3603          	ld	a2,0(s4)
ffffffffc02016de:	46a9                	li	a3,10
ffffffffc02016e0:	8a2e                	mv	s4,a1
ffffffffc02016e2:	bfc1                	j	ffffffffc02016b2 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016e4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02016e8:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ea:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016ec:	bdf1                	j	ffffffffc02015c8 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02016ee:	85a6                	mv	a1,s1
ffffffffc02016f0:	02500513          	li	a0,37
ffffffffc02016f4:	9902                	jalr	s2
            break;
ffffffffc02016f6:	b545                	j	ffffffffc0201596 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02016fc:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016fe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201700:	b5e1                	j	ffffffffc02015c8 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201702:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201704:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201708:	01174463          	blt	a4,a7,ffffffffc0201710 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020170c:	14088163          	beqz	a7,ffffffffc020184e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201710:	000a3603          	ld	a2,0(s4)
ffffffffc0201714:	46a1                	li	a3,8
ffffffffc0201716:	8a2e                	mv	s4,a1
ffffffffc0201718:	bf69                	j	ffffffffc02016b2 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020171a:	03000513          	li	a0,48
ffffffffc020171e:	85a6                	mv	a1,s1
ffffffffc0201720:	e03e                	sd	a5,0(sp)
ffffffffc0201722:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201724:	85a6                	mv	a1,s1
ffffffffc0201726:	07800513          	li	a0,120
ffffffffc020172a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020172c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020172e:	6782                	ld	a5,0(sp)
ffffffffc0201730:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201732:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201736:	bfb5                	j	ffffffffc02016b2 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201738:	000a3403          	ld	s0,0(s4)
ffffffffc020173c:	008a0713          	addi	a4,s4,8
ffffffffc0201740:	e03a                	sd	a4,0(sp)
ffffffffc0201742:	14040263          	beqz	s0,ffffffffc0201886 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201746:	0fb05763          	blez	s11,ffffffffc0201834 <vprintfmt+0x2d8>
ffffffffc020174a:	02d00693          	li	a3,45
ffffffffc020174e:	0cd79163          	bne	a5,a3,ffffffffc0201810 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201752:	00044783          	lbu	a5,0(s0)
ffffffffc0201756:	0007851b          	sext.w	a0,a5
ffffffffc020175a:	cf85                	beqz	a5,ffffffffc0201792 <vprintfmt+0x236>
ffffffffc020175c:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201760:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201764:	000c4563          	bltz	s8,ffffffffc020176e <vprintfmt+0x212>
ffffffffc0201768:	3c7d                	addiw	s8,s8,-1
ffffffffc020176a:	036c0263          	beq	s8,s6,ffffffffc020178e <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc020176e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201770:	0e0c8e63          	beqz	s9,ffffffffc020186c <vprintfmt+0x310>
ffffffffc0201774:	3781                	addiw	a5,a5,-32
ffffffffc0201776:	0ef47b63          	bgeu	s0,a5,ffffffffc020186c <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020177a:	03f00513          	li	a0,63
ffffffffc020177e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201780:	000a4783          	lbu	a5,0(s4)
ffffffffc0201784:	3dfd                	addiw	s11,s11,-1
ffffffffc0201786:	0a05                	addi	s4,s4,1
ffffffffc0201788:	0007851b          	sext.w	a0,a5
ffffffffc020178c:	ffe1                	bnez	a5,ffffffffc0201764 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020178e:	01b05963          	blez	s11,ffffffffc02017a0 <vprintfmt+0x244>
ffffffffc0201792:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201794:	85a6                	mv	a1,s1
ffffffffc0201796:	02000513          	li	a0,32
ffffffffc020179a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020179c:	fe0d9be3          	bnez	s11,ffffffffc0201792 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02017a0:	6a02                	ld	s4,0(sp)
ffffffffc02017a2:	bbd5                	j	ffffffffc0201596 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02017a6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02017aa:	01174463          	blt	a4,a7,ffffffffc02017b2 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02017ae:	08088d63          	beqz	a7,ffffffffc0201848 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02017b2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02017b6:	0a044d63          	bltz	s0,ffffffffc0201870 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02017ba:	8622                	mv	a2,s0
ffffffffc02017bc:	8a66                	mv	s4,s9
ffffffffc02017be:	46a9                	li	a3,10
ffffffffc02017c0:	bdcd                	j	ffffffffc02016b2 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02017c2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017c6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02017c8:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02017ca:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02017ce:	8fb5                	xor	a5,a5,a3
ffffffffc02017d0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02017d4:	02d74163          	blt	a4,a3,ffffffffc02017f6 <vprintfmt+0x29a>
ffffffffc02017d8:	00369793          	slli	a5,a3,0x3
ffffffffc02017dc:	97de                	add	a5,a5,s7
ffffffffc02017de:	639c                	ld	a5,0(a5)
ffffffffc02017e0:	cb99                	beqz	a5,ffffffffc02017f6 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017e2:	86be                	mv	a3,a5
ffffffffc02017e4:	00001617          	auipc	a2,0x1
ffffffffc02017e8:	70c60613          	addi	a2,a2,1804 # ffffffffc0202ef0 <buddy_pmm_manager+0x190>
ffffffffc02017ec:	85a6                	mv	a1,s1
ffffffffc02017ee:	854a                	mv	a0,s2
ffffffffc02017f0:	0ce000ef          	jal	ra,ffffffffc02018be <printfmt>
ffffffffc02017f4:	b34d                	j	ffffffffc0201596 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02017f6:	00001617          	auipc	a2,0x1
ffffffffc02017fa:	6ea60613          	addi	a2,a2,1770 # ffffffffc0202ee0 <buddy_pmm_manager+0x180>
ffffffffc02017fe:	85a6                	mv	a1,s1
ffffffffc0201800:	854a                	mv	a0,s2
ffffffffc0201802:	0bc000ef          	jal	ra,ffffffffc02018be <printfmt>
ffffffffc0201806:	bb41                	j	ffffffffc0201596 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201808:	00001417          	auipc	s0,0x1
ffffffffc020180c:	6d040413          	addi	s0,s0,1744 # ffffffffc0202ed8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201810:	85e2                	mv	a1,s8
ffffffffc0201812:	8522                	mv	a0,s0
ffffffffc0201814:	e43e                	sd	a5,8(sp)
ffffffffc0201816:	1cc000ef          	jal	ra,ffffffffc02019e2 <strnlen>
ffffffffc020181a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020181e:	01b05b63          	blez	s11,ffffffffc0201834 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201822:	67a2                	ld	a5,8(sp)
ffffffffc0201824:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201828:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020182a:	85a6                	mv	a1,s1
ffffffffc020182c:	8552                	mv	a0,s4
ffffffffc020182e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201830:	fe0d9ce3          	bnez	s11,ffffffffc0201828 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201834:	00044783          	lbu	a5,0(s0)
ffffffffc0201838:	00140a13          	addi	s4,s0,1
ffffffffc020183c:	0007851b          	sext.w	a0,a5
ffffffffc0201840:	d3a5                	beqz	a5,ffffffffc02017a0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201842:	05e00413          	li	s0,94
ffffffffc0201846:	bf39                	j	ffffffffc0201764 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201848:	000a2403          	lw	s0,0(s4)
ffffffffc020184c:	b7ad                	j	ffffffffc02017b6 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020184e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201852:	46a1                	li	a3,8
ffffffffc0201854:	8a2e                	mv	s4,a1
ffffffffc0201856:	bdb1                	j	ffffffffc02016b2 <vprintfmt+0x156>
ffffffffc0201858:	000a6603          	lwu	a2,0(s4)
ffffffffc020185c:	46a9                	li	a3,10
ffffffffc020185e:	8a2e                	mv	s4,a1
ffffffffc0201860:	bd89                	j	ffffffffc02016b2 <vprintfmt+0x156>
ffffffffc0201862:	000a6603          	lwu	a2,0(s4)
ffffffffc0201866:	46c1                	li	a3,16
ffffffffc0201868:	8a2e                	mv	s4,a1
ffffffffc020186a:	b5a1                	j	ffffffffc02016b2 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc020186c:	9902                	jalr	s2
ffffffffc020186e:	bf09                	j	ffffffffc0201780 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201870:	85a6                	mv	a1,s1
ffffffffc0201872:	02d00513          	li	a0,45
ffffffffc0201876:	e03e                	sd	a5,0(sp)
ffffffffc0201878:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020187a:	6782                	ld	a5,0(sp)
ffffffffc020187c:	8a66                	mv	s4,s9
ffffffffc020187e:	40800633          	neg	a2,s0
ffffffffc0201882:	46a9                	li	a3,10
ffffffffc0201884:	b53d                	j	ffffffffc02016b2 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201886:	03b05163          	blez	s11,ffffffffc02018a8 <vprintfmt+0x34c>
ffffffffc020188a:	02d00693          	li	a3,45
ffffffffc020188e:	f6d79de3          	bne	a5,a3,ffffffffc0201808 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201892:	00001417          	auipc	s0,0x1
ffffffffc0201896:	64640413          	addi	s0,s0,1606 # ffffffffc0202ed8 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020189a:	02800793          	li	a5,40
ffffffffc020189e:	02800513          	li	a0,40
ffffffffc02018a2:	00140a13          	addi	s4,s0,1
ffffffffc02018a6:	bd6d                	j	ffffffffc0201760 <vprintfmt+0x204>
ffffffffc02018a8:	00001a17          	auipc	s4,0x1
ffffffffc02018ac:	631a0a13          	addi	s4,s4,1585 # ffffffffc0202ed9 <buddy_pmm_manager+0x179>
ffffffffc02018b0:	02800513          	li	a0,40
ffffffffc02018b4:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02018b8:	05e00413          	li	s0,94
ffffffffc02018bc:	b565                	j	ffffffffc0201764 <vprintfmt+0x208>

ffffffffc02018be <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018be:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02018c0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018c4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018c6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018c8:	ec06                	sd	ra,24(sp)
ffffffffc02018ca:	f83a                	sd	a4,48(sp)
ffffffffc02018cc:	fc3e                	sd	a5,56(sp)
ffffffffc02018ce:	e0c2                	sd	a6,64(sp)
ffffffffc02018d0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02018d2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018d4:	c89ff0ef          	jal	ra,ffffffffc020155c <vprintfmt>
}
ffffffffc02018d8:	60e2                	ld	ra,24(sp)
ffffffffc02018da:	6161                	addi	sp,sp,80
ffffffffc02018dc:	8082                	ret

ffffffffc02018de <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02018de:	715d                	addi	sp,sp,-80
ffffffffc02018e0:	e486                	sd	ra,72(sp)
ffffffffc02018e2:	e0a6                	sd	s1,64(sp)
ffffffffc02018e4:	fc4a                	sd	s2,56(sp)
ffffffffc02018e6:	f84e                	sd	s3,48(sp)
ffffffffc02018e8:	f452                	sd	s4,40(sp)
ffffffffc02018ea:	f056                	sd	s5,32(sp)
ffffffffc02018ec:	ec5a                	sd	s6,24(sp)
ffffffffc02018ee:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02018f0:	c901                	beqz	a0,ffffffffc0201900 <readline+0x22>
ffffffffc02018f2:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02018f4:	00001517          	auipc	a0,0x1
ffffffffc02018f8:	5fc50513          	addi	a0,a0,1532 # ffffffffc0202ef0 <buddy_pmm_manager+0x190>
ffffffffc02018fc:	faefe0ef          	jal	ra,ffffffffc02000aa <cprintf>
readline(const char *prompt) {
ffffffffc0201900:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201902:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201904:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201906:	4aa9                	li	s5,10
ffffffffc0201908:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020190a:	00005b97          	auipc	s7,0x5
ffffffffc020190e:	71eb8b93          	addi	s7,s7,1822 # ffffffffc0207028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201912:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201916:	80dfe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc020191a:	00054a63          	bltz	a0,ffffffffc020192e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020191e:	00a95a63          	bge	s2,a0,ffffffffc0201932 <readline+0x54>
ffffffffc0201922:	029a5263          	bge	s4,s1,ffffffffc0201946 <readline+0x68>
        c = getchar();
ffffffffc0201926:	ffcfe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc020192a:	fe055ae3          	bgez	a0,ffffffffc020191e <readline+0x40>
            return NULL;
ffffffffc020192e:	4501                	li	a0,0
ffffffffc0201930:	a091                	j	ffffffffc0201974 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201932:	03351463          	bne	a0,s3,ffffffffc020195a <readline+0x7c>
ffffffffc0201936:	e8a9                	bnez	s1,ffffffffc0201988 <readline+0xaa>
        c = getchar();
ffffffffc0201938:	feafe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc020193c:	fe0549e3          	bltz	a0,ffffffffc020192e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201940:	fea959e3          	bge	s2,a0,ffffffffc0201932 <readline+0x54>
ffffffffc0201944:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201946:	e42a                	sd	a0,8(sp)
ffffffffc0201948:	f98fe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            buf[i ++] = c;
ffffffffc020194c:	6522                	ld	a0,8(sp)
ffffffffc020194e:	009b87b3          	add	a5,s7,s1
ffffffffc0201952:	2485                	addiw	s1,s1,1
ffffffffc0201954:	00a78023          	sb	a0,0(a5)
ffffffffc0201958:	bf7d                	j	ffffffffc0201916 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020195a:	01550463          	beq	a0,s5,ffffffffc0201962 <readline+0x84>
ffffffffc020195e:	fb651ce3          	bne	a0,s6,ffffffffc0201916 <readline+0x38>
            cputchar(c);
ffffffffc0201962:	f7efe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            buf[i] = '\0';
ffffffffc0201966:	00005517          	auipc	a0,0x5
ffffffffc020196a:	6c250513          	addi	a0,a0,1730 # ffffffffc0207028 <buf>
ffffffffc020196e:	94aa                	add	s1,s1,a0
ffffffffc0201970:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201974:	60a6                	ld	ra,72(sp)
ffffffffc0201976:	6486                	ld	s1,64(sp)
ffffffffc0201978:	7962                	ld	s2,56(sp)
ffffffffc020197a:	79c2                	ld	s3,48(sp)
ffffffffc020197c:	7a22                	ld	s4,40(sp)
ffffffffc020197e:	7a82                	ld	s5,32(sp)
ffffffffc0201980:	6b62                	ld	s6,24(sp)
ffffffffc0201982:	6bc2                	ld	s7,16(sp)
ffffffffc0201984:	6161                	addi	sp,sp,80
ffffffffc0201986:	8082                	ret
            cputchar(c);
ffffffffc0201988:	4521                	li	a0,8
ffffffffc020198a:	f56fe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            i --;
ffffffffc020198e:	34fd                	addiw	s1,s1,-1
ffffffffc0201990:	b759                	j	ffffffffc0201916 <readline+0x38>

ffffffffc0201992 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201992:	4781                	li	a5,0
ffffffffc0201994:	00005717          	auipc	a4,0x5
ffffffffc0201998:	67473703          	ld	a4,1652(a4) # ffffffffc0207008 <SBI_CONSOLE_PUTCHAR>
ffffffffc020199c:	88ba                	mv	a7,a4
ffffffffc020199e:	852a                	mv	a0,a0
ffffffffc02019a0:	85be                	mv	a1,a5
ffffffffc02019a2:	863e                	mv	a2,a5
ffffffffc02019a4:	00000073          	ecall
ffffffffc02019a8:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02019aa:	8082                	ret

ffffffffc02019ac <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02019ac:	4781                	li	a5,0
ffffffffc02019ae:	00006717          	auipc	a4,0x6
ffffffffc02019b2:	aea73703          	ld	a4,-1302(a4) # ffffffffc0207498 <SBI_SET_TIMER>
ffffffffc02019b6:	88ba                	mv	a7,a4
ffffffffc02019b8:	852a                	mv	a0,a0
ffffffffc02019ba:	85be                	mv	a1,a5
ffffffffc02019bc:	863e                	mv	a2,a5
ffffffffc02019be:	00000073          	ecall
ffffffffc02019c2:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02019c4:	8082                	ret

ffffffffc02019c6 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02019c6:	4501                	li	a0,0
ffffffffc02019c8:	00005797          	auipc	a5,0x5
ffffffffc02019cc:	6387b783          	ld	a5,1592(a5) # ffffffffc0207000 <SBI_CONSOLE_GETCHAR>
ffffffffc02019d0:	88be                	mv	a7,a5
ffffffffc02019d2:	852a                	mv	a0,a0
ffffffffc02019d4:	85aa                	mv	a1,a0
ffffffffc02019d6:	862a                	mv	a2,a0
ffffffffc02019d8:	00000073          	ecall
ffffffffc02019dc:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02019de:	2501                	sext.w	a0,a0
ffffffffc02019e0:	8082                	ret

ffffffffc02019e2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02019e2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02019e4:	e589                	bnez	a1,ffffffffc02019ee <strnlen+0xc>
ffffffffc02019e6:	a811                	j	ffffffffc02019fa <strnlen+0x18>
        cnt ++;
ffffffffc02019e8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02019ea:	00f58863          	beq	a1,a5,ffffffffc02019fa <strnlen+0x18>
ffffffffc02019ee:	00f50733          	add	a4,a0,a5
ffffffffc02019f2:	00074703          	lbu	a4,0(a4)
ffffffffc02019f6:	fb6d                	bnez	a4,ffffffffc02019e8 <strnlen+0x6>
ffffffffc02019f8:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02019fa:	852e                	mv	a0,a1
ffffffffc02019fc:	8082                	ret

ffffffffc02019fe <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019fe:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a02:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a06:	cb89                	beqz	a5,ffffffffc0201a18 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201a08:	0505                	addi	a0,a0,1
ffffffffc0201a0a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a0c:	fee789e3          	beq	a5,a4,ffffffffc02019fe <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a10:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a14:	9d19                	subw	a0,a0,a4
ffffffffc0201a16:	8082                	ret
ffffffffc0201a18:	4501                	li	a0,0
ffffffffc0201a1a:	bfed                	j	ffffffffc0201a14 <strcmp+0x16>

ffffffffc0201a1c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a1c:	00054783          	lbu	a5,0(a0)
ffffffffc0201a20:	c799                	beqz	a5,ffffffffc0201a2e <strchr+0x12>
        if (*s == c) {
ffffffffc0201a22:	00f58763          	beq	a1,a5,ffffffffc0201a30 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201a26:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201a2a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201a2c:	fbfd                	bnez	a5,ffffffffc0201a22 <strchr+0x6>
    }
    return NULL;
ffffffffc0201a2e:	4501                	li	a0,0
}
ffffffffc0201a30:	8082                	ret

ffffffffc0201a32 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a32:	ca01                	beqz	a2,ffffffffc0201a42 <memset+0x10>
ffffffffc0201a34:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a36:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a38:	0785                	addi	a5,a5,1
ffffffffc0201a3a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201a3e:	fec79de3          	bne	a5,a2,ffffffffc0201a38 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201a42:	8082                	ret
