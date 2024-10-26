
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02042b7          	lui	t0,0xc0204
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
ffffffffc0200024:	c0204137          	lui	sp,0xc0204

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
ffffffffc0200032:	00005517          	auipc	a0,0x5
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0205010 <free_area>
ffffffffc020003a:	00005617          	auipc	a2,0x5
ffffffffc020003e:	44e60613          	addi	a2,a2,1102 # ffffffffc0205488 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	2fc010ef          	jal	ra,ffffffffc0201346 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3e4000ef          	jal	ra,ffffffffc0200432 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	30650513          	addi	a0,a0,774 # ffffffffc0201358 <etext>
ffffffffc020005a:	088000ef          	jal	ra,ffffffffc02000e2 <cputs>

    print_kerninfo();
ffffffffc020005e:	0d4000ef          	jal	ra,ffffffffc0200132 <print_kerninfo>

    // grade_backtrace();
    // idt_init();  // init interrupt descriptor table

    pmm_init();  // init physical memory management
ffffffffc0200062:	40f000ef          	jal	ra,ffffffffc0200c70 <pmm_init>

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
ffffffffc020009e:	5d3000ef          	jal	ra,ffffffffc0200e70 <vprintfmt>
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
ffffffffc02000ac:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
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
ffffffffc02000d4:	59d000ef          	jal	ra,ffffffffc0200e70 <vprintfmt>
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
ffffffffc0200134:	00001517          	auipc	a0,0x1
ffffffffc0200138:	24450513          	addi	a0,a0,580 # ffffffffc0201378 <etext+0x20>
void print_kerninfo(void) {
ffffffffc020013c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020013e:	f6dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200142:	00000597          	auipc	a1,0x0
ffffffffc0200146:	ef058593          	addi	a1,a1,-272 # ffffffffc0200032 <kern_init>
ffffffffc020014a:	00001517          	auipc	a0,0x1
ffffffffc020014e:	24e50513          	addi	a0,a0,590 # ffffffffc0201398 <etext+0x40>
ffffffffc0200152:	f59ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200156:	00001597          	auipc	a1,0x1
ffffffffc020015a:	20258593          	addi	a1,a1,514 # ffffffffc0201358 <etext>
ffffffffc020015e:	00001517          	auipc	a0,0x1
ffffffffc0200162:	25a50513          	addi	a0,a0,602 # ffffffffc02013b8 <etext+0x60>
ffffffffc0200166:	f45ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020016a:	00005597          	auipc	a1,0x5
ffffffffc020016e:	ea658593          	addi	a1,a1,-346 # ffffffffc0205010 <free_area>
ffffffffc0200172:	00001517          	auipc	a0,0x1
ffffffffc0200176:	26650513          	addi	a0,a0,614 # ffffffffc02013d8 <etext+0x80>
ffffffffc020017a:	f31ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020017e:	00005597          	auipc	a1,0x5
ffffffffc0200182:	30a58593          	addi	a1,a1,778 # ffffffffc0205488 <end>
ffffffffc0200186:	00001517          	auipc	a0,0x1
ffffffffc020018a:	27250513          	addi	a0,a0,626 # ffffffffc02013f8 <etext+0xa0>
ffffffffc020018e:	f1dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200192:	00005597          	auipc	a1,0x5
ffffffffc0200196:	6f558593          	addi	a1,a1,1781 # ffffffffc0205887 <end+0x3ff>
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
ffffffffc02001b4:	00001517          	auipc	a0,0x1
ffffffffc02001b8:	26450513          	addi	a0,a0,612 # ffffffffc0201418 <etext+0xc0>
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
ffffffffc02001c2:	00001617          	auipc	a2,0x1
ffffffffc02001c6:	28660613          	addi	a2,a2,646 # ffffffffc0201448 <etext+0xf0>
ffffffffc02001ca:	04e00593          	li	a1,78
ffffffffc02001ce:	00001517          	auipc	a0,0x1
ffffffffc02001d2:	29250513          	addi	a0,a0,658 # ffffffffc0201460 <etext+0x108>
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
ffffffffc02001de:	00001617          	auipc	a2,0x1
ffffffffc02001e2:	29a60613          	addi	a2,a2,666 # ffffffffc0201478 <etext+0x120>
ffffffffc02001e6:	00001597          	auipc	a1,0x1
ffffffffc02001ea:	2b258593          	addi	a1,a1,690 # ffffffffc0201498 <etext+0x140>
ffffffffc02001ee:	00001517          	auipc	a0,0x1
ffffffffc02001f2:	2b250513          	addi	a0,a0,690 # ffffffffc02014a0 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001f6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f8:	eb3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc02001fc:	00001617          	auipc	a2,0x1
ffffffffc0200200:	2b460613          	addi	a2,a2,692 # ffffffffc02014b0 <etext+0x158>
ffffffffc0200204:	00001597          	auipc	a1,0x1
ffffffffc0200208:	2d458593          	addi	a1,a1,724 # ffffffffc02014d8 <etext+0x180>
ffffffffc020020c:	00001517          	auipc	a0,0x1
ffffffffc0200210:	29450513          	addi	a0,a0,660 # ffffffffc02014a0 <etext+0x148>
ffffffffc0200214:	e97ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc0200218:	00001617          	auipc	a2,0x1
ffffffffc020021c:	2d060613          	addi	a2,a2,720 # ffffffffc02014e8 <etext+0x190>
ffffffffc0200220:	00001597          	auipc	a1,0x1
ffffffffc0200224:	2e858593          	addi	a1,a1,744 # ffffffffc0201508 <etext+0x1b0>
ffffffffc0200228:	00001517          	auipc	a0,0x1
ffffffffc020022c:	27850513          	addi	a0,a0,632 # ffffffffc02014a0 <etext+0x148>
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
ffffffffc0200262:	00001517          	auipc	a0,0x1
ffffffffc0200266:	2b650513          	addi	a0,a0,694 # ffffffffc0201518 <etext+0x1c0>
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
ffffffffc0200284:	00001517          	auipc	a0,0x1
ffffffffc0200288:	2bc50513          	addi	a0,a0,700 # ffffffffc0201540 <etext+0x1e8>
ffffffffc020028c:	e1fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    if (tf != NULL) {
ffffffffc0200290:	000b8563          	beqz	s7,ffffffffc020029a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200294:	855e                	mv	a0,s7
ffffffffc0200296:	382000ef          	jal	ra,ffffffffc0200618 <print_trapframe>
ffffffffc020029a:	00001c17          	auipc	s8,0x1
ffffffffc020029e:	316c0c13          	addi	s8,s8,790 # ffffffffc02015b0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002a2:	00001917          	auipc	s2,0x1
ffffffffc02002a6:	2c690913          	addi	s2,s2,710 # ffffffffc0201568 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002aa:	00001497          	auipc	s1,0x1
ffffffffc02002ae:	2c648493          	addi	s1,s1,710 # ffffffffc0201570 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002b2:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002b4:	00001b17          	auipc	s6,0x1
ffffffffc02002b8:	2c4b0b13          	addi	s6,s6,708 # ffffffffc0201578 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002bc:	00001a17          	auipc	s4,0x1
ffffffffc02002c0:	1dca0a13          	addi	s4,s4,476 # ffffffffc0201498 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c4:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002c6:	854a                	mv	a0,s2
ffffffffc02002c8:	72b000ef          	jal	ra,ffffffffc02011f2 <readline>
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
ffffffffc02002de:	00001d17          	auipc	s10,0x1
ffffffffc02002e2:	2d2d0d13          	addi	s10,s10,722 # ffffffffc02015b0 <commands>
        argv[argc ++] = buf;
ffffffffc02002e6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002e8:	4401                	li	s0,0
ffffffffc02002ea:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ec:	026010ef          	jal	ra,ffffffffc0201312 <strcmp>
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
ffffffffc0200300:	012010ef          	jal	ra,ffffffffc0201312 <strcmp>
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
ffffffffc020033e:	7f3000ef          	jal	ra,ffffffffc0201330 <strchr>
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
ffffffffc020037c:	7b5000ef          	jal	ra,ffffffffc0201330 <strchr>
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
ffffffffc0200396:	00001517          	auipc	a0,0x1
ffffffffc020039a:	20250513          	addi	a0,a0,514 # ffffffffc0201598 <etext+0x240>
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
ffffffffc02003a4:	00005317          	auipc	t1,0x5
ffffffffc02003a8:	08430313          	addi	t1,t1,132 # ffffffffc0205428 <is_panic>
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
ffffffffc02003d2:	00001517          	auipc	a0,0x1
ffffffffc02003d6:	22650513          	addi	a0,a0,550 # ffffffffc02015f8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003da:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	ccfff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e0:	65a2                	ld	a1,8(sp)
ffffffffc02003e2:	8522                	mv	a0,s0
ffffffffc02003e4:	ca7ff0ef          	jal	ra,ffffffffc020008a <vcprintf>
    cprintf("\n");
ffffffffc02003e8:	00001517          	auipc	a0,0x1
ffffffffc02003ec:	5e050513          	addi	a0,a0,1504 # ffffffffc02019c8 <commands+0x418>
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
ffffffffc0200418:	6a9000ef          	jal	ra,ffffffffc02012c0 <sbi_set_timer>
}
ffffffffc020041c:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020041e:	00005797          	auipc	a5,0x5
ffffffffc0200422:	0007b923          	sd	zero,18(a5) # ffffffffc0205430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200426:	00001517          	auipc	a0,0x1
ffffffffc020042a:	1f250513          	addi	a0,a0,498 # ffffffffc0201618 <commands+0x68>
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
ffffffffc0200438:	66f0006f          	j	ffffffffc02012a6 <sbi_console_putchar>

ffffffffc020043c <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020043c:	69f0006f          	j	ffffffffc02012da <sbi_console_getchar>

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
ffffffffc0200454:	00001517          	auipc	a0,0x1
ffffffffc0200458:	1e450513          	addi	a0,a0,484 # ffffffffc0201638 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc020045c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020045e:	c4dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200462:	640c                	ld	a1,8(s0)
ffffffffc0200464:	00001517          	auipc	a0,0x1
ffffffffc0200468:	1ec50513          	addi	a0,a0,492 # ffffffffc0201650 <commands+0xa0>
ffffffffc020046c:	c3fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200470:	680c                	ld	a1,16(s0)
ffffffffc0200472:	00001517          	auipc	a0,0x1
ffffffffc0200476:	1f650513          	addi	a0,a0,502 # ffffffffc0201668 <commands+0xb8>
ffffffffc020047a:	c31ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020047e:	6c0c                	ld	a1,24(s0)
ffffffffc0200480:	00001517          	auipc	a0,0x1
ffffffffc0200484:	20050513          	addi	a0,a0,512 # ffffffffc0201680 <commands+0xd0>
ffffffffc0200488:	c23ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020048c:	700c                	ld	a1,32(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	20a50513          	addi	a0,a0,522 # ffffffffc0201698 <commands+0xe8>
ffffffffc0200496:	c15ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020049a:	740c                	ld	a1,40(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	21450513          	addi	a0,a0,532 # ffffffffc02016b0 <commands+0x100>
ffffffffc02004a4:	c07ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004a8:	780c                	ld	a1,48(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	21e50513          	addi	a0,a0,542 # ffffffffc02016c8 <commands+0x118>
ffffffffc02004b2:	bf9ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004b6:	7c0c                	ld	a1,56(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	22850513          	addi	a0,a0,552 # ffffffffc02016e0 <commands+0x130>
ffffffffc02004c0:	bebff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004c4:	602c                	ld	a1,64(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	23250513          	addi	a0,a0,562 # ffffffffc02016f8 <commands+0x148>
ffffffffc02004ce:	bddff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004d2:	642c                	ld	a1,72(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	23c50513          	addi	a0,a0,572 # ffffffffc0201710 <commands+0x160>
ffffffffc02004dc:	bcfff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02004e0:	682c                	ld	a1,80(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	24650513          	addi	a0,a0,582 # ffffffffc0201728 <commands+0x178>
ffffffffc02004ea:	bc1ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02004ee:	6c2c                	ld	a1,88(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	25050513          	addi	a0,a0,592 # ffffffffc0201740 <commands+0x190>
ffffffffc02004f8:	bb3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02004fc:	702c                	ld	a1,96(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	25a50513          	addi	a0,a0,602 # ffffffffc0201758 <commands+0x1a8>
ffffffffc0200506:	ba5ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020050a:	742c                	ld	a1,104(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	26450513          	addi	a0,a0,612 # ffffffffc0201770 <commands+0x1c0>
ffffffffc0200514:	b97ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200518:	782c                	ld	a1,112(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	26e50513          	addi	a0,a0,622 # ffffffffc0201788 <commands+0x1d8>
ffffffffc0200522:	b89ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200526:	7c2c                	ld	a1,120(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	27850513          	addi	a0,a0,632 # ffffffffc02017a0 <commands+0x1f0>
ffffffffc0200530:	b7bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200534:	604c                	ld	a1,128(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	28250513          	addi	a0,a0,642 # ffffffffc02017b8 <commands+0x208>
ffffffffc020053e:	b6dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200542:	644c                	ld	a1,136(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	28c50513          	addi	a0,a0,652 # ffffffffc02017d0 <commands+0x220>
ffffffffc020054c:	b5fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200550:	684c                	ld	a1,144(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	29650513          	addi	a0,a0,662 # ffffffffc02017e8 <commands+0x238>
ffffffffc020055a:	b51ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020055e:	6c4c                	ld	a1,152(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	2a050513          	addi	a0,a0,672 # ffffffffc0201800 <commands+0x250>
ffffffffc0200568:	b43ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020056c:	704c                	ld	a1,160(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	2aa50513          	addi	a0,a0,682 # ffffffffc0201818 <commands+0x268>
ffffffffc0200576:	b35ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020057a:	744c                	ld	a1,168(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	2b450513          	addi	a0,a0,692 # ffffffffc0201830 <commands+0x280>
ffffffffc0200584:	b27ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200588:	784c                	ld	a1,176(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	2be50513          	addi	a0,a0,702 # ffffffffc0201848 <commands+0x298>
ffffffffc0200592:	b19ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200596:	7c4c                	ld	a1,184(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	2c850513          	addi	a0,a0,712 # ffffffffc0201860 <commands+0x2b0>
ffffffffc02005a0:	b0bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005a4:	606c                	ld	a1,192(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	2d250513          	addi	a0,a0,722 # ffffffffc0201878 <commands+0x2c8>
ffffffffc02005ae:	afdff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005b2:	646c                	ld	a1,200(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	2dc50513          	addi	a0,a0,732 # ffffffffc0201890 <commands+0x2e0>
ffffffffc02005bc:	aefff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005c0:	686c                	ld	a1,208(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	2e650513          	addi	a0,a0,742 # ffffffffc02018a8 <commands+0x2f8>
ffffffffc02005ca:	ae1ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005ce:	6c6c                	ld	a1,216(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	2f050513          	addi	a0,a0,752 # ffffffffc02018c0 <commands+0x310>
ffffffffc02005d8:	ad3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02005dc:	706c                	ld	a1,224(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	2fa50513          	addi	a0,a0,762 # ffffffffc02018d8 <commands+0x328>
ffffffffc02005e6:	ac5ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02005ea:	746c                	ld	a1,232(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	30450513          	addi	a0,a0,772 # ffffffffc02018f0 <commands+0x340>
ffffffffc02005f4:	ab7ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02005f8:	786c                	ld	a1,240(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	30e50513          	addi	a0,a0,782 # ffffffffc0201908 <commands+0x358>
ffffffffc0200602:	aa9ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200606:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200608:	6402                	ld	s0,0(sp)
ffffffffc020060a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020060c:	00001517          	auipc	a0,0x1
ffffffffc0200610:	31450513          	addi	a0,a0,788 # ffffffffc0201920 <commands+0x370>
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
ffffffffc0200620:	00001517          	auipc	a0,0x1
ffffffffc0200624:	31850513          	addi	a0,a0,792 # ffffffffc0201938 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200628:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020062a:	a81ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    print_regs(&tf->gpr);
ffffffffc020062e:	8522                	mv	a0,s0
ffffffffc0200630:	e1dff0ef          	jal	ra,ffffffffc020044c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200634:	10043583          	ld	a1,256(s0)
ffffffffc0200638:	00001517          	auipc	a0,0x1
ffffffffc020063c:	31850513          	addi	a0,a0,792 # ffffffffc0201950 <commands+0x3a0>
ffffffffc0200640:	a6bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200644:	10843583          	ld	a1,264(s0)
ffffffffc0200648:	00001517          	auipc	a0,0x1
ffffffffc020064c:	32050513          	addi	a0,a0,800 # ffffffffc0201968 <commands+0x3b8>
ffffffffc0200650:	a5bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200654:	11043583          	ld	a1,272(s0)
ffffffffc0200658:	00001517          	auipc	a0,0x1
ffffffffc020065c:	32850513          	addi	a0,a0,808 # ffffffffc0201980 <commands+0x3d0>
ffffffffc0200660:	a4bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200664:	11843583          	ld	a1,280(s0)
}
ffffffffc0200668:	6402                	ld	s0,0(sp)
ffffffffc020066a:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020066c:	00001517          	auipc	a0,0x1
ffffffffc0200670:	32c50513          	addi	a0,a0,812 # ffffffffc0201998 <commands+0x3e8>
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
ffffffffc0200678:	00005797          	auipc	a5,0x5
ffffffffc020067c:	99878793          	addi	a5,a5,-1640 # ffffffffc0205010 <free_area>
ffffffffc0200680:	e79c                	sd	a5,8(a5)
ffffffffc0200682:	e39c                	sd	a5,0(a5)

// 初始化伙伴系统内存管理
static void buddy_init(void) {
    // 初始化空闲链表和空闲页面数
    list_init(&(free_list));
    nr_free = 0;
ffffffffc0200684:	0007a823          	sw	zero,16(a5)

}
ffffffffc0200688:	8082                	ret

ffffffffc020068a <buddy_nr_free_pages>:

    
}
static size_t buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	99656503          	lwu	a0,-1642(a0) # ffffffffc0205020 <free_area+0x10>
ffffffffc0200692:	8082                	ret

ffffffffc0200694 <build_buddy_tree.isra.0>:
    if (stop_build) {
ffffffffc0200694:	00005797          	auipc	a5,0x5
ffffffffc0200698:	db478793          	addi	a5,a5,-588 # ffffffffc0205448 <stop_build>
ffffffffc020069c:	4398                	lw	a4,0(a5)
ffffffffc020069e:	e725                	bnez	a4,ffffffffc0200706 <build_buddy_tree.isra.0+0x72>
static void build_buddy_tree(size_t root, size_t full_tree_size, size_t real_tree_size,
ffffffffc02006a0:	7139                	addi	sp,sp,-64
ffffffffc02006a2:	f426                	sd	s1,40(sp)
ffffffffc02006a4:	fc06                	sd	ra,56(sp)
ffffffffc02006a6:	f822                	sd	s0,48(sp)
ffffffffc02006a8:	f04a                	sd	s2,32(sp)
ffffffffc02006aa:	ec4e                	sd	s3,24(sp)
ffffffffc02006ac:	e852                	sd	s4,16(sp)
ffffffffc02006ae:	84ae                	mv	s1,a1
    if (full_tree_size == 0 || real_tree_size == 0) {
ffffffffc02006b0:	c1a9                	beqz	a1,ffffffffc02006f2 <build_buddy_tree.isra.0+0x5e>
ffffffffc02006b2:	8932                	mv	s2,a2
ffffffffc02006b4:	ce1d                	beqz	a2,ffffffffc02006f2 <build_buddy_tree.isra.0+0x5e>
        build_buddy_tree(root * 2 + 1, left_size, real_tree_size, allocate_area, record_area);
ffffffffc02006b6:	00151a13          	slli	s4,a0,0x1
    size_t left_size = full_tree_size / 2;
ffffffffc02006ba:	8185                	srli	a1,a1,0x1
ffffffffc02006bc:	89aa                	mv	s3,a0
ffffffffc02006be:	8436                	mv	s0,a3
        build_buddy_tree(root * 2 + 1, left_size, real_tree_size, allocate_area, record_area);
ffffffffc02006c0:	001a0513          	addi	a0,s4,1
    if (real_tree_size <= left_size) {
ffffffffc02006c4:	04c5e263          	bltu	a1,a2,ffffffffc0200708 <build_buddy_tree.isra.0+0x74>
        build_buddy_tree(root * 2 + 2, right_size, real_tree_size - left_size,
ffffffffc02006c8:	fcdff0ef          	jal	ra,ffffffffc0200694 <build_buddy_tree.isra.0>
    record_area[root].property = full_tree_size;
ffffffffc02006cc:	00299693          	slli	a3,s3,0x2
ffffffffc02006d0:	96ce                	add	a3,a3,s3
ffffffffc02006d2:	068e                	slli	a3,a3,0x3
ffffffffc02006d4:	96a2                	add	a3,a3,s0
ffffffffc02006d6:	ca84                	sw	s1,16(a3)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02006d8:	4789                	li	a5,2
ffffffffc02006da:	00868713          	addi	a4,a3,8
ffffffffc02006de:	40f7302f          	amoor.d	zero,a5,(a4)
}
ffffffffc02006e2:	70e2                	ld	ra,56(sp)
ffffffffc02006e4:	7442                	ld	s0,48(sp)
ffffffffc02006e6:	74a2                	ld	s1,40(sp)
ffffffffc02006e8:	7902                	ld	s2,32(sp)
ffffffffc02006ea:	69e2                	ld	s3,24(sp)
ffffffffc02006ec:	6a42                	ld	s4,16(sp)
ffffffffc02006ee:	6121                	addi	sp,sp,64
ffffffffc02006f0:	8082                	ret
ffffffffc02006f2:	70e2                	ld	ra,56(sp)
ffffffffc02006f4:	7442                	ld	s0,48(sp)
        stop_build = 1;
ffffffffc02006f6:	4705                	li	a4,1
ffffffffc02006f8:	c398                	sw	a4,0(a5)
}
ffffffffc02006fa:	74a2                	ld	s1,40(sp)
ffffffffc02006fc:	7902                	ld	s2,32(sp)
ffffffffc02006fe:	69e2                	ld	s3,24(sp)
ffffffffc0200700:	6a42                	ld	s4,16(sp)
ffffffffc0200702:	6121                	addi	sp,sp,64
ffffffffc0200704:	8082                	ret
ffffffffc0200706:	8082                	ret
        build_buddy_tree(root * 2 + 1, left_size, left_size, allocate_area, record_area);
ffffffffc0200708:	862e                	mv	a2,a1
ffffffffc020070a:	e42e                	sd	a1,8(sp)
ffffffffc020070c:	f89ff0ef          	jal	ra,ffffffffc0200694 <build_buddy_tree.isra.0>
                         allocate_area + left_size, record_area + left_size);
ffffffffc0200710:	65a2                	ld	a1,8(sp)
        build_buddy_tree(root * 2 + 2, right_size, real_tree_size - left_size,
ffffffffc0200712:	002a0513          	addi	a0,s4,2
                         allocate_area + left_size, record_area + left_size);
ffffffffc0200716:	00259693          	slli	a3,a1,0x2
ffffffffc020071a:	96ae                	add	a3,a3,a1
ffffffffc020071c:	068e                	slli	a3,a3,0x3
        build_buddy_tree(root * 2 + 2, right_size, real_tree_size - left_size,
ffffffffc020071e:	96a2                	add	a3,a3,s0
ffffffffc0200720:	40b90633          	sub	a2,s2,a1
ffffffffc0200724:	b755                	j	ffffffffc02006c8 <build_buddy_tree.isra.0+0x34>

ffffffffc0200726 <buddy_check>:


// 伙伴系统的检查函数
static void buddy_check(void) {
ffffffffc0200726:	1141                	addi	sp,sp,-16
    size_t calculated_free_pages = 0;

    cprintf("Checking buddy system...\n");
ffffffffc0200728:	00001517          	auipc	a0,0x1
ffffffffc020072c:	28850513          	addi	a0,a0,648 # ffffffffc02019b0 <commands+0x400>
static void buddy_check(void) {
ffffffffc0200730:	e406                	sd	ra,8(sp)
    cprintf("Checking buddy system...\n");
ffffffffc0200732:	979ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200736:	00005597          	auipc	a1,0x5
ffffffffc020073a:	8da58593          	addi	a1,a1,-1830 # ffffffffc0205010 <free_area>
ffffffffc020073e:	659c                	ld	a5,8(a1)
    size_t calculated_free_pages = 0;
ffffffffc0200740:	4681                	li	a3,0

    // 1. 检查空闲列表中的块状态
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
ffffffffc0200742:	00b78c63          	beq	a5,a1,ffffffffc020075a <buddy_check+0x34>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200746:	ff07b703          	ld	a4,-16(a5)
        struct Page *page = le2page(le, page_link);
        size_t order = page->property;
ffffffffc020074a:	ff87e603          	lwu	a2,-8(a5)

        // 检查空闲块的大小是否为 2 的幂次
        // assert(order > 0 && (order & (order - 1)) == 0);

        // 检查页面是否在空闲列表中
        assert(PageProperty(page));
ffffffffc020074e:	8b09                	andi	a4,a4,2
ffffffffc0200750:	c31d                	beqz	a4,ffffffffc0200776 <buddy_check+0x50>
ffffffffc0200752:	679c                	ld	a5,8(a5)

        // 更新计算的空闲页数
        calculated_free_pages += order;
ffffffffc0200754:	96b2                	add	a3,a3,a2
    while (le != &free_list) {
ffffffffc0200756:	feb798e3          	bne	a5,a1,ffffffffc0200746 <buddy_check+0x20>
            assert(record_area[i].property <= NODE_LENGTH(i));
        }
    }

    // 3. 验证 nr_free 的正确性
    if (calculated_free_pages != nr_free) {
ffffffffc020075a:	498c                	lw	a1,16(a1)
ffffffffc020075c:	02059793          	slli	a5,a1,0x20
ffffffffc0200760:	9381                	srli	a5,a5,0x20
ffffffffc0200762:	02d79a63          	bne	a5,a3,ffffffffc0200796 <buddy_check+0x70>
               calculated_free_pages, nr_free);
        assert(0);
    }

    cprintf("Buddy system check passed. Total free pages: %lu.\n", nr_free);
}
ffffffffc0200766:	60a2                	ld	ra,8(sp)
    cprintf("Buddy system check passed. Total free pages: %lu.\n", nr_free);
ffffffffc0200768:	00001517          	auipc	a0,0x1
ffffffffc020076c:	2f050513          	addi	a0,a0,752 # ffffffffc0201a58 <commands+0x4a8>
}
ffffffffc0200770:	0141                	addi	sp,sp,16
    cprintf("Buddy system check passed. Total free pages: %lu.\n", nr_free);
ffffffffc0200772:	939ff06f          	j	ffffffffc02000aa <cprintf>
        assert(PageProperty(page));
ffffffffc0200776:	00001697          	auipc	a3,0x1
ffffffffc020077a:	25a68693          	addi	a3,a3,602 # ffffffffc02019d0 <commands+0x420>
ffffffffc020077e:	00001617          	auipc	a2,0x1
ffffffffc0200782:	26a60613          	addi	a2,a2,618 # ffffffffc02019e8 <commands+0x438>
ffffffffc0200786:	11e00593          	li	a1,286
ffffffffc020078a:	00001517          	auipc	a0,0x1
ffffffffc020078e:	27650513          	addi	a0,a0,630 # ffffffffc0201a00 <commands+0x450>
ffffffffc0200792:	c13ff0ef          	jal	ra,ffffffffc02003a4 <__panic>
        cprintf("Error: Calculated free pages %lu does not match nr_free %lu.\n",
ffffffffc0200796:	862e                	mv	a2,a1
ffffffffc0200798:	00001517          	auipc	a0,0x1
ffffffffc020079c:	27850513          	addi	a0,a0,632 # ffffffffc0201a10 <commands+0x460>
ffffffffc02007a0:	85b6                	mv	a1,a3
ffffffffc02007a2:	909ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
        assert(0);
ffffffffc02007a6:	00001697          	auipc	a3,0x1
ffffffffc02007aa:	2aa68693          	addi	a3,a3,682 # ffffffffc0201a50 <commands+0x4a0>
ffffffffc02007ae:	00001617          	auipc	a2,0x1
ffffffffc02007b2:	23a60613          	addi	a2,a2,570 # ffffffffc02019e8 <commands+0x438>
ffffffffc02007b6:	14300593          	li	a1,323
ffffffffc02007ba:	00001517          	auipc	a0,0x1
ffffffffc02007be:	24650513          	addi	a0,a0,582 # ffffffffc0201a00 <commands+0x450>
ffffffffc02007c2:	be3ff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc02007c6 <buddy_allocate_pages>:
    assert(n > 0);
ffffffffc02007c6:	16050063          	beqz	a0,ffffffffc0200926 <buddy_allocate_pages+0x160>
    return 1 << (32 - clz(n - 1));
ffffffffc02007ca:	fff50693          	addi	a3,a0,-1

extern const struct pmm_manager buddy_pmm_manager;

static size_t clz(size_t x) {
    size_t count = 0;
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc02007ce:	14068463          	beqz	a3,ffffffffc0200916 <buddy_allocate_pages+0x150>
    for (size_t i = sizeof(x) * 8 - 1; i >= 0; --i) {
        if (x & ((size_t)1 << i)) break;
ffffffffc02007d2:	03f6d713          	srli	a4,a3,0x3f
ffffffffc02007d6:	1406c063          	bltz	a3,ffffffffc0200916 <buddy_allocate_pages+0x150>
ffffffffc02007da:	03f00593          	li	a1,63
        count++;
ffffffffc02007de:	0705                	addi	a4,a4,1
        if (x & ((size_t)1 << i)) break;
ffffffffc02007e0:	40e587bb          	subw	a5,a1,a4
ffffffffc02007e4:	00f6d7b3          	srl	a5,a3,a5
ffffffffc02007e8:	8b85                	andi	a5,a5,1
ffffffffc02007ea:	0007061b          	sext.w	a2,a4
ffffffffc02007ee:	dbe5                	beqz	a5,ffffffffc02007de <buddy_allocate_pages+0x18>
    while (length <= record_area[block].property) {
ffffffffc02007f0:	00005817          	auipc	a6,0x5
ffffffffc02007f4:	c5083803          	ld	a6,-944(a6) # ffffffffc0205440 <record_area>
    return 1 << (32 - clz(n - 1));
ffffffffc02007f8:	02000313          	li	t1,32
    while (length <= record_area[block].property) {
ffffffffc02007fc:	01086583          	lwu	a1,16(a6)
    return 1 << (32 - clz(n - 1));
ffffffffc0200800:	40c3063b          	subw	a2,t1,a2
ffffffffc0200804:	4305                	li	t1,1
ffffffffc0200806:	00c3133b          	sllw	t1,t1,a2
    while (length <= record_area[block].property) {
ffffffffc020080a:	0a65e163          	bltu	a1,t1,ffffffffc02008ac <buddy_allocate_pages+0xe6>
ffffffffc020080e:	00005297          	auipc	t0,0x5
ffffffffc0200812:	80228293          	addi	t0,t0,-2046 # ffffffffc0205010 <free_area>
ffffffffc0200816:	0082be83          	ld	t4,8(t0)
    return 1 << (32 - clz(n - 1));
ffffffffc020081a:	8e42                	mv	t3,a6
ffffffffc020081c:	4f81                	li	t6,0
ffffffffc020081e:	4681                	li	a3,0
ffffffffc0200820:	4f01                	li	t5,0
        size_t left = block * 2 + 1;   // 左子节点
ffffffffc0200822:	00169893          	slli	a7,a3,0x1
ffffffffc0200826:	00188613          	addi	a2,a7,1
        size_t right = block * 2 + 2;  // 右子节点
ffffffffc020082a:	00168513          	addi	a0,a3,1
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc020082e:	ca91                	beqz	a3,ffffffffc0200842 <buddy_allocate_pages+0x7c>
        if (x & ((size_t)1 << i)) break;
ffffffffc0200830:	0006c963          	bltz	a3,ffffffffc0200842 <buddy_allocate_pages+0x7c>
    for (size_t i = sizeof(x) * 8 - 1; i >= 0; --i) {
ffffffffc0200834:	03f00713          	li	a4,63
ffffffffc0200838:	177d                	addi	a4,a4,-1
        if (x & ((size_t)1 << i)) break;
ffffffffc020083a:	00e6d7b3          	srl	a5,a3,a4
ffffffffc020083e:	8b85                	andi	a5,a5,1
ffffffffc0200840:	dfe5                	beqz	a5,ffffffffc0200838 <buddy_allocate_pages+0x72>
            record_area[left].property = half_size;
ffffffffc0200842:	00261793          	slli	a5,a2,0x2
ffffffffc0200846:	97b2                	add	a5,a5,a2
ffffffffc0200848:	078e                	slli	a5,a5,0x3
ffffffffc020084a:	00f80733          	add	a4,a6,a5
        if (BUDDY_EMPTY(block)) {
ffffffffc020084e:	e99d                	bnez	a1,ffffffffc0200884 <buddy_allocate_pages+0xbe>
            record_area[right].property = half_size;
ffffffffc0200850:	00251593          	slli	a1,a0,0x2
ffffffffc0200854:	95aa                	add	a1,a1,a0
ffffffffc0200856:	0592                	slli	a1,a1,0x4
            record_area[left].property = half_size;
ffffffffc0200858:	00072823          	sw	zero,16(a4)
            record_area[right].property = half_size;
ffffffffc020085c:	95c2                	add	a1,a1,a6
ffffffffc020085e:	0005a823          	sw	zero,16(a1)
            list_add(&free_list, &record_area[left].page_link);
ffffffffc0200862:	01870f93          	addi	t6,a4,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200866:	01feb023          	sd	t6,0(t4)
    elm->next = next;
ffffffffc020086a:	03d73023          	sd	t4,32(a4)
            list_add(&free_list, &record_area[right].page_link);
ffffffffc020086e:	01858e93          	addi	t4,a1,24
    prev->next = next->prev = elm;
ffffffffc0200872:	01d73c23          	sd	t4,24(a4)
    elm->next = next;
ffffffffc0200876:	03f5b023          	sd	t6,32(a1)
    elm->prev = prev;
ffffffffc020087a:	0055bc23          	sd	t0,24(a1)
            record_area[block].property = 0; // 原块被分裂后不再空闲
ffffffffc020087e:	000e2823          	sw	zero,16(t3)
ffffffffc0200882:	4f85                	li	t6,1
        if (length <= record_area[left].property) {
ffffffffc0200884:	01076583          	lwu	a1,16(a4)
ffffffffc0200888:	0065fe63          	bgeu	a1,t1,ffffffffc02008a4 <buddy_allocate_pages+0xde>
        } else if (length <= record_area[right].property) {
ffffffffc020088c:	00251793          	slli	a5,a0,0x2
ffffffffc0200890:	97aa                	add	a5,a5,a0
ffffffffc0200892:	0792                	slli	a5,a5,0x4
ffffffffc0200894:	00f80733          	add	a4,a6,a5
ffffffffc0200898:	01076583          	lwu	a1,16(a4)
ffffffffc020089c:	0065ea63          	bltu	a1,t1,ffffffffc02008b0 <buddy_allocate_pages+0xea>
        size_t right = block * 2 + 2;  // 右子节点
ffffffffc02008a0:	00288613          	addi	a2,a7,2
    return 1 << (32 - clz(n - 1));
ffffffffc02008a4:	86b2                	mv	a3,a2
ffffffffc02008a6:	8e3a                	mv	t3,a4
ffffffffc02008a8:	8f3e                	mv	t5,a5
ffffffffc02008aa:	bfa5                	j	ffffffffc0200822 <buddy_allocate_pages+0x5c>
        return NULL;
ffffffffc02008ac:	4501                	li	a0,0
ffffffffc02008ae:	8082                	ret
ffffffffc02008b0:	000f8463          	beqz	t6,ffffffffc02008b8 <buddy_allocate_pages+0xf2>
ffffffffc02008b4:	01d2b423          	sd	t4,8(t0)
    if (record_area[block].property < length) {
ffffffffc02008b8:	010e6783          	lwu	a5,16(t3)
ffffffffc02008bc:	fe67e8e3          	bltu	a5,t1,ffffffffc02008ac <buddy_allocate_pages+0xe6>
    __list_del(listelm->prev, listelm->next);
ffffffffc02008c0:	020e3703          	ld	a4,32(t3)
ffffffffc02008c4:	018e3603          	ld	a2,24(t3)
    nr_free -= length;                         // 更新全局空闲页数
ffffffffc02008c8:	0102a783          	lw	a5,16(t0)
    struct Page *page = allocate_area + block; // 根据块索引计算页面起始地址
ffffffffc02008cc:	00005517          	auipc	a0,0x5
ffffffffc02008d0:	b6c53503          	ld	a0,-1172(a0) # ffffffffc0205438 <allocate_area>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02008d4:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02008d6:	e310                	sd	a2,0(a4)
    record_area[block].property = 0;           // 标记该块为已使用
ffffffffc02008d8:	000e2823          	sw	zero,16(t3)
    nr_free -= length;                         // 更新全局空闲页数
ffffffffc02008dc:	4067833b          	subw	t1,a5,t1
    size_t parent_block = (block - 1) / 2;
ffffffffc02008e0:	fff68713          	addi	a4,a3,-1
    nr_free -= length;                         // 更新全局空闲页数
ffffffffc02008e4:	0062a823          	sw	t1,16(t0)
    struct Page *page = allocate_area + block; // 根据块索引计算页面起始地址
ffffffffc02008e8:	957a                	add	a0,a0,t5
    size_t parent_block = (block - 1) / 2;
ffffffffc02008ea:	8305                	srli	a4,a4,0x1
    while (block != TREE_ROOT) {
ffffffffc02008ec:	c685                	beqz	a3,ffffffffc0200914 <buddy_allocate_pages+0x14e>
            record_area[parent_block * 2 + 1].property |
ffffffffc02008ee:	00271793          	slli	a5,a4,0x2
ffffffffc02008f2:	97ba                	add	a5,a5,a4
ffffffffc02008f4:	00479693          	slli	a3,a5,0x4
ffffffffc02008f8:	96c2                	add	a3,a3,a6
ffffffffc02008fa:	5e90                	lw	a2,56(a3)
ffffffffc02008fc:	52b4                	lw	a3,96(a3)
        record_area[parent_block].property = 
ffffffffc02008fe:	078e                	slli	a5,a5,0x3
ffffffffc0200900:	97c2                	add	a5,a5,a6
            record_area[parent_block * 2 + 1].property |
ffffffffc0200902:	8ed1                	or	a3,a3,a2
        parent_block = (block - 1) / 2;
ffffffffc0200904:	fff70593          	addi	a1,a4,-1
ffffffffc0200908:	863a                	mv	a2,a4
        record_area[parent_block].property = 
ffffffffc020090a:	cb94                	sw	a3,16(a5)
        parent_block = (block - 1) / 2;
ffffffffc020090c:	0015d713          	srli	a4,a1,0x1
    while (block != TREE_ROOT) {
ffffffffc0200910:	fe79                	bnez	a2,ffffffffc02008ee <buddy_allocate_pages+0x128>
ffffffffc0200912:	8082                	ret
}
ffffffffc0200914:	8082                	ret
    while (length <= record_area[block].property) {
ffffffffc0200916:	00005817          	auipc	a6,0x5
ffffffffc020091a:	b2a83803          	ld	a6,-1238(a6) # ffffffffc0205440 <record_area>
ffffffffc020091e:	01086583          	lwu	a1,16(a6)
    return 1 << (32 - clz(n - 1));
ffffffffc0200922:	4305                	li	t1,1
ffffffffc0200924:	b5ed                	j	ffffffffc020080e <buddy_allocate_pages+0x48>
static struct Page *buddy_allocate_pages(size_t n) {
ffffffffc0200926:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200928:	00001697          	auipc	a3,0x1
ffffffffc020092c:	16868693          	addi	a3,a3,360 # ffffffffc0201a90 <commands+0x4e0>
ffffffffc0200930:	00001617          	auipc	a2,0x1
ffffffffc0200934:	0b860613          	addi	a2,a2,184 # ffffffffc02019e8 <commands+0x438>
ffffffffc0200938:	09700593          	li	a1,151
ffffffffc020093c:	00001517          	auipc	a0,0x1
ffffffffc0200940:	0c450513          	addi	a0,a0,196 # ffffffffc0201a00 <commands+0x450>
static struct Page *buddy_allocate_pages(size_t n) {
ffffffffc0200944:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200946:	a5fff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc020094a <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc020094a:	1141                	addi	sp,sp,-16
ffffffffc020094c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020094e:	1a058063          	beqz	a1,ffffffffc0200aee <buddy_free_pages+0x1a4>
    size_t index = (base - allocate_area); // 根据 base 地址计算伙伴树中的索引
ffffffffc0200952:	00005697          	auipc	a3,0x5
ffffffffc0200956:	ae66b683          	ld	a3,-1306(a3) # ffffffffc0205438 <allocate_area>
ffffffffc020095a:	40d506b3          	sub	a3,a0,a3
ffffffffc020095e:	868d                	srai	a3,a3,0x3
ffffffffc0200960:	00001797          	auipc	a5,0x1
ffffffffc0200964:	5387b783          	ld	a5,1336(a5) # ffffffffc0201e98 <error_string+0x38>
    return 1 << (32 - clz(n - 1));
ffffffffc0200968:	fff58613          	addi	a2,a1,-1
    size_t index = (base - allocate_area); // 根据 base 地址计算伙伴树中的索引
ffffffffc020096c:	02f686b3          	mul	a3,a3,a5
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc0200970:	c61d                	beqz	a2,ffffffffc020099e <buddy_free_pages+0x54>
        if (x & ((size_t)1 << i)) break;
ffffffffc0200972:	03f65713          	srli	a4,a2,0x3f
ffffffffc0200976:	14064363          	bltz	a2,ffffffffc0200abc <buddy_free_pages+0x172>
ffffffffc020097a:	03f00893          	li	a7,63
        count++;
ffffffffc020097e:	0705                	addi	a4,a4,1
        if (x & ((size_t)1 << i)) break;
ffffffffc0200980:	40e887bb          	subw	a5,a7,a4
ffffffffc0200984:	00f657b3          	srl	a5,a2,a5
ffffffffc0200988:	8b85                	andi	a5,a5,1
ffffffffc020098a:	0007081b          	sext.w	a6,a4
ffffffffc020098e:	dbe5                	beqz	a5,ffffffffc020097e <buddy_free_pages+0x34>
    return 1 << (32 - clz(n - 1));
ffffffffc0200990:	02000613          	li	a2,32
ffffffffc0200994:	4106083b          	subw	a6,a2,a6
ffffffffc0200998:	4605                	li	a2,1
ffffffffc020099a:	0106163b          	sllw	a2,a2,a6
    size_t block = index + size - 1;       // 找到对应的叶子节点位置
ffffffffc020099e:	16fd                	addi	a3,a3,-1
ffffffffc02009a0:	96b2                	add	a3,a3,a2
    while (block > 0 && !BUDDY_EMPTY(block)) {
ffffffffc02009a2:	ca9d                	beqz	a3,ffffffffc02009d8 <buddy_free_pages+0x8e>
ffffffffc02009a4:	00005897          	auipc	a7,0x5
ffffffffc02009a8:	a9c8b883          	ld	a7,-1380(a7) # ffffffffc0205440 <record_area>
ffffffffc02009ac:	00269813          	slli	a6,a3,0x2
ffffffffc02009b0:	9836                	add	a6,a6,a3
ffffffffc02009b2:	080e                	slli	a6,a6,0x3
ffffffffc02009b4:	9846                	add	a6,a6,a7
ffffffffc02009b6:	01082303          	lw	t1,16(a6)
ffffffffc02009ba:	0006c963          	bltz	a3,ffffffffc02009cc <buddy_free_pages+0x82>
    for (size_t i = sizeof(x) * 8 - 1; i >= 0; --i) {
ffffffffc02009be:	03f00713          	li	a4,63
ffffffffc02009c2:	177d                	addi	a4,a4,-1
        if (x & ((size_t)1 << i)) break;
ffffffffc02009c4:	00e6d7b3          	srl	a5,a3,a4
ffffffffc02009c8:	8b85                	andi	a5,a5,1
ffffffffc02009ca:	dfe5                	beqz	a5,ffffffffc02009c2 <buddy_free_pages+0x78>
ffffffffc02009cc:	0c030e63          	beqz	t1,ffffffffc0200aa8 <buddy_free_pages+0x15e>
        block = (block - 1) / 2;  // 计算父节点索引
ffffffffc02009d0:	16fd                	addi	a3,a3,-1
ffffffffc02009d2:	8285                	srli	a3,a3,0x1
        size <<= 1;               // 每次上移，块的大小加倍
ffffffffc02009d4:	0606                	slli	a2,a2,0x1
    while (block > 0 && !BUDDY_EMPTY(block)) {
ffffffffc02009d6:	faf9                	bnez	a3,ffffffffc02009ac <buddy_free_pages+0x62>
    for (p = base; p != base + n; ++p) {
ffffffffc02009d8:	00259713          	slli	a4,a1,0x2
ffffffffc02009dc:	972e                	add	a4,a4,a1
ffffffffc02009de:	070e                	slli	a4,a4,0x3
ffffffffc02009e0:	972a                	add	a4,a4,a0
ffffffffc02009e2:	4681                	li	a3,0
ffffffffc02009e4:	0ce50e63          	beq	a0,a4,ffffffffc0200ac0 <buddy_free_pages+0x176>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009e8:	4809                	li	a6,2
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009ea:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02009ec:	8b85                	andi	a5,a5,1
ffffffffc02009ee:	e3e5                	bnez	a5,ffffffffc0200ace <buddy_free_pages+0x184>
ffffffffc02009f0:	651c                	ld	a5,8(a0)
ffffffffc02009f2:	8b89                	andi	a5,a5,2
ffffffffc02009f4:	efe9                	bnez	a5,ffffffffc0200ace <buddy_free_pages+0x184>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009f6:	00850793          	addi	a5,a0,8
ffffffffc02009fa:	4107b02f          	amoor.d	zero,a6,(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02009fe:	00052023          	sw	zero,0(a0)
    for (p = base; p != base + n; ++p) {
ffffffffc0200a02:	02850513          	addi	a0,a0,40
ffffffffc0200a06:	fea712e3          	bne	a4,a0,ffffffffc02009ea <buddy_free_pages+0xa0>
    record_area[block].property = size;    // 标记当前节点为可用的块大小
ffffffffc0200a0a:	00269793          	slli	a5,a3,0x2
ffffffffc0200a0e:	97b6                	add	a5,a5,a3
ffffffffc0200a10:	00005897          	auipc	a7,0x5
ffffffffc0200a14:	a308b883          	ld	a7,-1488(a7) # ffffffffc0205440 <record_area>
ffffffffc0200a18:	078e                	slli	a5,a5,0x3
ffffffffc0200a1a:	97c6                	add	a5,a5,a7
ffffffffc0200a1c:	cb90                	sw	a2,16(a5)
    while (block > 0) {
ffffffffc0200a1e:	ee81                	bnez	a3,ffffffffc0200a36 <buddy_free_pages+0xec>
ffffffffc0200a20:	a8b9                	j	ffffffffc0200a7e <buddy_free_pages+0x134>
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200a22:	02081713          	slli	a4,a6,0x20
ffffffffc0200a26:	9301                	srli	a4,a4,0x20
ffffffffc0200a28:	04c71263          	bne	a4,a2,ffffffffc0200a6c <buddy_free_pages+0x122>
            record_area[parent].property = size * 2;
ffffffffc0200a2c:	0016171b          	slliw	a4,a2,0x1
ffffffffc0200a30:	cb98                	sw	a4,16(a5)
            size <<= 1;
ffffffffc0200a32:	0606                	slli	a2,a2,0x1
    while (block > 0) {
ffffffffc0200a34:	c6a9                	beqz	a3,ffffffffc0200a7e <buddy_free_pages+0x134>
        size_t parent = (block - 1) / 2;
ffffffffc0200a36:	fff68713          	addi	a4,a3,-1
        size_t left = parent * 2 + 1;
ffffffffc0200a3a:	00176513          	ori	a0,a4,1
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200a3e:	00251793          	slli	a5,a0,0x2
ffffffffc0200a42:	97aa                	add	a5,a5,a0
ffffffffc0200a44:	078e                	slli	a5,a5,0x3
ffffffffc0200a46:	97c6                	add	a5,a5,a7
ffffffffc0200a48:	4b88                	lw	a0,16(a5)
ffffffffc0200a4a:	8e36                	mv	t3,a3
        size_t parent = (block - 1) / 2;
ffffffffc0200a4c:	00175693          	srli	a3,a4,0x1
            record_area[parent].property = size * 2;
ffffffffc0200a50:	00269713          	slli	a4,a3,0x2
ffffffffc0200a54:	9736                	add	a4,a4,a3
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200a56:	02051313          	slli	t1,a0,0x20
            record_area[parent].property = size * 2;
ffffffffc0200a5a:	070e                	slli	a4,a4,0x3
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200a5c:	02035313          	srli	t1,t1,0x20
ffffffffc0200a60:	0387a803          	lw	a6,56(a5)
            record_area[parent].property = size * 2;
ffffffffc0200a64:	00e887b3          	add	a5,a7,a4
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200a68:	fac30de3          	beq	t1,a2,ffffffffc0200a22 <buddy_free_pages+0xd8>
            record_area[parent].property = max(record_area[left].property, record_area[right].property);
ffffffffc0200a6c:	86aa                	mv	a3,a0
ffffffffc0200a6e:	03056b63          	bltu	a0,a6,ffffffffc0200aa4 <buddy_free_pages+0x15a>
    list_add(&free_list, &record_area[block].page_link);
ffffffffc0200a72:	002e1713          	slli	a4,t3,0x2
ffffffffc0200a76:	9772                	add	a4,a4,t3
ffffffffc0200a78:	070e                	slli	a4,a4,0x3
            record_area[parent].property = max(record_area[left].property, record_area[right].property);
ffffffffc0200a7a:	cb94                	sw	a3,16(a5)
    list_add(&free_list, &record_area[block].page_link);
ffffffffc0200a7c:	98ba                	add	a7,a7,a4
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a7e:	00004797          	auipc	a5,0x4
ffffffffc0200a82:	59278793          	addi	a5,a5,1426 # ffffffffc0205010 <free_area>
ffffffffc0200a86:	6794                	ld	a3,8(a5)
    nr_free += n;
ffffffffc0200a88:	4b98                	lw	a4,16(a5)
}
ffffffffc0200a8a:	60a2                	ld	ra,8(sp)
    list_add(&free_list, &record_area[block].page_link);
ffffffffc0200a8c:	01888613          	addi	a2,a7,24
    prev->next = next->prev = elm;
ffffffffc0200a90:	e290                	sd	a2,0(a3)
    nr_free += n;
ffffffffc0200a92:	9db9                	addw	a1,a1,a4
ffffffffc0200a94:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200a96:	02d8b023          	sd	a3,32(a7)
    elm->prev = prev;
ffffffffc0200a9a:	00f8bc23          	sd	a5,24(a7)
ffffffffc0200a9e:	cb8c                	sw	a1,16(a5)
}
ffffffffc0200aa0:	0141                	addi	sp,sp,16
ffffffffc0200aa2:	8082                	ret
            record_area[parent].property = max(record_area[left].property, record_area[right].property);
ffffffffc0200aa4:	86c2                	mv	a3,a6
ffffffffc0200aa6:	b7f1                	j	ffffffffc0200a72 <buddy_free_pages+0x128>
    for (p = base; p != base + n; ++p) {
ffffffffc0200aa8:	00259713          	slli	a4,a1,0x2
ffffffffc0200aac:	972e                	add	a4,a4,a1
ffffffffc0200aae:	070e                	slli	a4,a4,0x3
ffffffffc0200ab0:	972a                	add	a4,a4,a0
ffffffffc0200ab2:	f2a71be3          	bne	a4,a0,ffffffffc02009e8 <buddy_free_pages+0x9e>
    record_area[block].property = size;    // 标记当前节点为可用的块大小
ffffffffc0200ab6:	00c82823          	sw	a2,16(a6)
    while (block > 0) {
ffffffffc0200aba:	bfb5                	j	ffffffffc0200a36 <buddy_free_pages+0xec>
ffffffffc0200abc:	4601                	li	a2,0
ffffffffc0200abe:	b5c5                	j	ffffffffc020099e <buddy_free_pages+0x54>
    record_area[block].property = size;    // 标记当前节点为可用的块大小
ffffffffc0200ac0:	00005897          	auipc	a7,0x5
ffffffffc0200ac4:	9808b883          	ld	a7,-1664(a7) # ffffffffc0205440 <record_area>
ffffffffc0200ac8:	00c8a823          	sw	a2,16(a7)
    while (block > 0) {
ffffffffc0200acc:	bf4d                	j	ffffffffc0200a7e <buddy_free_pages+0x134>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ace:	00001697          	auipc	a3,0x1
ffffffffc0200ad2:	fca68693          	addi	a3,a3,-54 # ffffffffc0201a98 <commands+0x4e8>
ffffffffc0200ad6:	00001617          	auipc	a2,0x1
ffffffffc0200ada:	f1260613          	addi	a2,a2,-238 # ffffffffc02019e8 <commands+0x438>
ffffffffc0200ade:	0eb00593          	li	a1,235
ffffffffc0200ae2:	00001517          	auipc	a0,0x1
ffffffffc0200ae6:	f1e50513          	addi	a0,a0,-226 # ffffffffc0201a00 <commands+0x450>
ffffffffc0200aea:	8bbff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(n > 0);
ffffffffc0200aee:	00001697          	auipc	a3,0x1
ffffffffc0200af2:	fa268693          	addi	a3,a3,-94 # ffffffffc0201a90 <commands+0x4e0>
ffffffffc0200af6:	00001617          	auipc	a2,0x1
ffffffffc0200afa:	ef260613          	addi	a2,a2,-270 # ffffffffc02019e8 <commands+0x438>
ffffffffc0200afe:	0da00593          	li	a1,218
ffffffffc0200b02:	00001517          	auipc	a0,0x1
ffffffffc0200b06:	efe50513          	addi	a0,a0,-258 # ffffffffc0201a00 <commands+0x450>
ffffffffc0200b0a:	89bff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc0200b0e <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200b0e:	1101                	addi	sp,sp,-32
ffffffffc0200b10:	ec06                	sd	ra,24(sp)
ffffffffc0200b12:	e822                	sd	s0,16(sp)
ffffffffc0200b14:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200b16:	12058b63          	beqz	a1,ffffffffc0200c4c <buddy_init_memmap+0x13e>
ffffffffc0200b1a:	84aa                	mv	s1,a0
ffffffffc0200b1c:	86aa                	mv	a3,a0
ffffffffc0200b1e:	4401                	li	s0,0
ffffffffc0200b20:	a011                	j	ffffffffc0200b24 <buddy_init_memmap+0x16>
ffffffffc0200b22:	843a                	mv	s0,a4
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b24:	669c                	ld	a5,8(a3)
        assert(PageReserved(page));
ffffffffc0200b26:	8b85                	andi	a5,a5,1
ffffffffc0200b28:	10078263          	beqz	a5,ffffffffc0200c2c <buddy_init_memmap+0x11e>
    for (size_t i = 0; i < n; i++) {
ffffffffc0200b2c:	00140713          	addi	a4,s0,1
ffffffffc0200b30:	02868693          	addi	a3,a3,40
ffffffffc0200b34:	fee597e3          	bne	a1,a4,ffffffffc0200b22 <buddy_init_memmap+0x14>
ffffffffc0200b38:	00271693          	slli	a3,a4,0x2
ffffffffc0200b3c:	96ba                	add	a3,a3,a4
ffffffffc0200b3e:	00848793          	addi	a5,s1,8
ffffffffc0200b42:	068e                	slli	a3,a3,0x3
ffffffffc0200b44:	96be                	add	a3,a3,a5
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200b46:	4609                	li	a2,2
        page->flags = 0;
ffffffffc0200b48:	0007b023          	sd	zero,0(a5)
        page->property = 0;
ffffffffc0200b4c:	0007a423          	sw	zero,8(a5)
        page->ref = 0;
ffffffffc0200b50:	fe07ac23          	sw	zero,-8(a5)
ffffffffc0200b54:	40c7b02f          	amoor.d	zero,a2,(a5)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200b58:	02878793          	addi	a5,a5,40
ffffffffc0200b5c:	fef696e3          	bne	a3,a5,ffffffffc0200b48 <buddy_init_memmap+0x3a>
    if (n < 512) {
ffffffffc0200b60:	1ff00793          	li	a5,511
ffffffffc0200b64:	0ae7e763          	bltu	a5,a4,ffffffffc0200c12 <buddy_init_memmap+0x104>
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc0200b68:	4581                	li	a1,0
ffffffffc0200b6a:	cc31                	beqz	s0,ffffffffc0200bc6 <buddy_init_memmap+0xb8>
    size_t count = 0;
ffffffffc0200b6c:	4681                	li	a3,0
        if (x & ((size_t)1 << i)) break;
ffffffffc0200b6e:	03f00593          	li	a1,63
        count++;
ffffffffc0200b72:	0685                	addi	a3,a3,1
        if (x & ((size_t)1 << i)) break;
ffffffffc0200b74:	40d587bb          	subw	a5,a1,a3
ffffffffc0200b78:	00f457b3          	srl	a5,s0,a5
ffffffffc0200b7c:	8b85                	andi	a5,a5,1
ffffffffc0200b7e:	0006861b          	sext.w	a2,a3
ffffffffc0200b82:	dbe5                	beqz	a5,ffffffffc0200b72 <buddy_init_memmap+0x64>
        full_tree_size = 1 << (32 - clz(n));
ffffffffc0200b84:	02000593          	li	a1,32
ffffffffc0200b88:	40c5863b          	subw	a2,a1,a2
ffffffffc0200b8c:	4585                	li	a1,1
ffffffffc0200b8e:	00c595bb          	sllw	a1,a1,a2
    size_t record_area_size = (full_tree_size * sizeof(struct Page)) / PGSIZE + 1;
ffffffffc0200b92:	00259793          	slli	a5,a1,0x2
ffffffffc0200b96:	97ae                	add	a5,a5,a1
ffffffffc0200b98:	078e                	slli	a5,a5,0x3
ffffffffc0200b9a:	83b1                	srli	a5,a5,0xc
ffffffffc0200b9c:	00178693          	addi	a3,a5,1
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200ba0:	0686                	slli	a3,a3,0x1
ffffffffc0200ba2:	96ae                	add	a3,a3,a1
    size_t real_tree_size = n - record_area_size;
ffffffffc0200ba4:	40f407b3          	sub	a5,s0,a5
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200ba8:	0ce6f263          	bgeu	a3,a4,ffffffffc0200c6c <buddy_init_memmap+0x15e>
        full_tree_size <<= 1; // 扩展树的大小，向上翻倍
ffffffffc0200bac:	0586                	slli	a1,a1,0x1
        record_area_size = (full_tree_size * sizeof(struct Page)) / PGSIZE + 1;
ffffffffc0200bae:	00259793          	slli	a5,a1,0x2
ffffffffc0200bb2:	97ae                	add	a5,a5,a1
ffffffffc0200bb4:	078e                	slli	a5,a5,0x3
ffffffffc0200bb6:	83b1                	srli	a5,a5,0xc
ffffffffc0200bb8:	00178693          	addi	a3,a5,1
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200bbc:	0686                	slli	a3,a3,0x1
ffffffffc0200bbe:	96ae                	add	a3,a3,a1
ffffffffc0200bc0:	fee6e6e3          	bltu	a3,a4,ffffffffc0200bac <buddy_init_memmap+0x9e>
        real_tree_size = n - record_area_size;
ffffffffc0200bc4:	8c1d                	sub	s0,s0,a5
    record_area = base + real_tree_size;
ffffffffc0200bc6:	00241693          	slli	a3,s0,0x2
ffffffffc0200bca:	96a2                	add	a3,a3,s0
ffffffffc0200bcc:	068e                	slli	a3,a3,0x3
ffffffffc0200bce:	96a6                	add	a3,a3,s1
    build_buddy_tree(TREE_ROOT, full_tree_size, real_tree_size, allocate_area, record_area);
ffffffffc0200bd0:	8622                	mv	a2,s0
ffffffffc0200bd2:	4501                	li	a0,0
    record_area = base + real_tree_size;
ffffffffc0200bd4:	00005797          	auipc	a5,0x5
ffffffffc0200bd8:	86d7b623          	sd	a3,-1940(a5) # ffffffffc0205440 <record_area>
    allocate_area = physical_area;
ffffffffc0200bdc:	00005797          	auipc	a5,0x5
ffffffffc0200be0:	8497be23          	sd	s1,-1956(a5) # ffffffffc0205438 <allocate_area>
    build_buddy_tree(TREE_ROOT, full_tree_size, real_tree_size, allocate_area, record_area);
ffffffffc0200be4:	ab1ff0ef          	jal	ra,ffffffffc0200694 <build_buddy_tree.isra.0>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200be8:	00004797          	auipc	a5,0x4
ffffffffc0200bec:	42878793          	addi	a5,a5,1064 # ffffffffc0205010 <free_area>
    nr_free += real_tree_size;
ffffffffc0200bf0:	4b98                	lw	a4,16(a5)
ffffffffc0200bf2:	6794                	ld	a3,8(a5)
    base->property = real_tree_size;
ffffffffc0200bf4:	2401                	sext.w	s0,s0
ffffffffc0200bf6:	c880                	sw	s0,16(s1)
    list_add(&free_list, &(base->page_link));
ffffffffc0200bf8:	01848613          	addi	a2,s1,24
    prev->next = next->prev = elm;
ffffffffc0200bfc:	e290                	sd	a2,0(a3)
    nr_free += real_tree_size;
ffffffffc0200bfe:	9c39                	addw	s0,s0,a4
}
ffffffffc0200c00:	60e2                	ld	ra,24(sp)
    nr_free += real_tree_size;
ffffffffc0200c02:	cb80                	sw	s0,16(a5)
}
ffffffffc0200c04:	6442                	ld	s0,16(sp)
    elm->next = next;
ffffffffc0200c06:	f094                	sd	a3,32(s1)
    elm->prev = prev;
ffffffffc0200c08:	ec9c                	sd	a5,24(s1)
    prev->next = next->prev = elm;
ffffffffc0200c0a:	e790                	sd	a2,8(a5)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
ffffffffc0200c10:	8082                	ret
    size_t count = 0;
ffffffffc0200c12:	4681                	li	a3,0
        if (x & ((size_t)1 << i)) break;
ffffffffc0200c14:	03f00593          	li	a1,63
        count++;
ffffffffc0200c18:	0685                	addi	a3,a3,1
        if (x & ((size_t)1 << i)) break;
ffffffffc0200c1a:	40d587bb          	subw	a5,a1,a3
ffffffffc0200c1e:	00f757b3          	srl	a5,a4,a5
ffffffffc0200c22:	8b85                	andi	a5,a5,1
ffffffffc0200c24:	0006861b          	sext.w	a2,a3
ffffffffc0200c28:	dbe5                	beqz	a5,ffffffffc0200c18 <buddy_init_memmap+0x10a>
ffffffffc0200c2a:	bfa9                	j	ffffffffc0200b84 <buddy_init_memmap+0x76>
        assert(PageReserved(page));
ffffffffc0200c2c:	00001697          	auipc	a3,0x1
ffffffffc0200c30:	e9468693          	addi	a3,a3,-364 # ffffffffc0201ac0 <commands+0x510>
ffffffffc0200c34:	00001617          	auipc	a2,0x1
ffffffffc0200c38:	db460613          	addi	a2,a2,-588 # ffffffffc02019e8 <commands+0x438>
ffffffffc0200c3c:	06100593          	li	a1,97
ffffffffc0200c40:	00001517          	auipc	a0,0x1
ffffffffc0200c44:	dc050513          	addi	a0,a0,-576 # ffffffffc0201a00 <commands+0x450>
ffffffffc0200c48:	f5cff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(n > 0);
ffffffffc0200c4c:	00001697          	auipc	a3,0x1
ffffffffc0200c50:	e4468693          	addi	a3,a3,-444 # ffffffffc0201a90 <commands+0x4e0>
ffffffffc0200c54:	00001617          	auipc	a2,0x1
ffffffffc0200c58:	d9460613          	addi	a2,a2,-620 # ffffffffc02019e8 <commands+0x438>
ffffffffc0200c5c:	05c00593          	li	a1,92
ffffffffc0200c60:	00001517          	auipc	a0,0x1
ffffffffc0200c64:	da050513          	addi	a0,a0,-608 # ffffffffc0201a00 <commands+0x450>
ffffffffc0200c68:	f3cff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200c6c:	843e                	mv	s0,a5
ffffffffc0200c6e:	bfa1                	j	ffffffffc0200bc6 <buddy_init_memmap+0xb8>

ffffffffc0200c70 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200c70:	00001797          	auipc	a5,0x1
ffffffffc0200c74:	e8078793          	addi	a5,a5,-384 # ffffffffc0201af0 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200c78:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200c7a:	1101                	addi	sp,sp,-32
ffffffffc0200c7c:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200c7e:	00001517          	auipc	a0,0x1
ffffffffc0200c82:	eaa50513          	addi	a0,a0,-342 # ffffffffc0201b28 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200c86:	00004497          	auipc	s1,0x4
ffffffffc0200c8a:	7da48493          	addi	s1,s1,2010 # ffffffffc0205460 <pmm_manager>
void pmm_init(void) {
ffffffffc0200c8e:	ec06                	sd	ra,24(sp)
ffffffffc0200c90:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200c92:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200c94:	c16ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    pmm_manager->init();
ffffffffc0200c98:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c9a:	00004417          	auipc	s0,0x4
ffffffffc0200c9e:	7de40413          	addi	s0,s0,2014 # ffffffffc0205478 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200ca2:	679c                	ld	a5,8(a5)
ffffffffc0200ca4:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200ca6:	57f5                	li	a5,-3
ffffffffc0200ca8:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200caa:	00001517          	auipc	a0,0x1
ffffffffc0200cae:	e9650513          	addi	a0,a0,-362 # ffffffffc0201b40 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200cb2:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200cb4:	bf6ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200cb8:	46c5                	li	a3,17
ffffffffc0200cba:	06ee                	slli	a3,a3,0x1b
ffffffffc0200cbc:	40100613          	li	a2,1025
ffffffffc0200cc0:	16fd                	addi	a3,a3,-1
ffffffffc0200cc2:	07e005b7          	lui	a1,0x7e00
ffffffffc0200cc6:	0656                	slli	a2,a2,0x15
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	e9050513          	addi	a0,a0,-368 # ffffffffc0201b58 <buddy_pmm_manager+0x68>
ffffffffc0200cd0:	bdaff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200cd4:	777d                	lui	a4,0xfffff
ffffffffc0200cd6:	00005797          	auipc	a5,0x5
ffffffffc0200cda:	7b178793          	addi	a5,a5,1969 # ffffffffc0206487 <end+0xfff>
ffffffffc0200cde:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ce0:	00004517          	auipc	a0,0x4
ffffffffc0200ce4:	77050513          	addi	a0,a0,1904 # ffffffffc0205450 <npage>
ffffffffc0200ce8:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200cec:	00004597          	auipc	a1,0x4
ffffffffc0200cf0:	76c58593          	addi	a1,a1,1900 # ffffffffc0205458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200cf4:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200cf6:	e19c                	sd	a5,0(a1)
ffffffffc0200cf8:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200cfa:	4701                	li	a4,0
ffffffffc0200cfc:	4885                	li	a7,1
ffffffffc0200cfe:	fff80837          	lui	a6,0xfff80
ffffffffc0200d02:	a011                	j	ffffffffc0200d06 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200d04:	619c                	ld	a5,0(a1)
ffffffffc0200d06:	97b6                	add	a5,a5,a3
ffffffffc0200d08:	07a1                	addi	a5,a5,8
ffffffffc0200d0a:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200d0e:	611c                	ld	a5,0(a0)
ffffffffc0200d10:	0705                	addi	a4,a4,1
ffffffffc0200d12:	02868693          	addi	a3,a3,40
ffffffffc0200d16:	01078633          	add	a2,a5,a6
ffffffffc0200d1a:	fec765e3          	bltu	a4,a2,ffffffffc0200d04 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200d1e:	6190                	ld	a2,0(a1)
ffffffffc0200d20:	00279713          	slli	a4,a5,0x2
ffffffffc0200d24:	973e                	add	a4,a4,a5
ffffffffc0200d26:	fec006b7          	lui	a3,0xfec00
ffffffffc0200d2a:	070e                	slli	a4,a4,0x3
ffffffffc0200d2c:	96b2                	add	a3,a3,a2
ffffffffc0200d2e:	96ba                	add	a3,a3,a4
ffffffffc0200d30:	c0200737          	lui	a4,0xc0200
ffffffffc0200d34:	08e6ef63          	bltu	a3,a4,ffffffffc0200dd2 <pmm_init+0x162>
ffffffffc0200d38:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200d3a:	45c5                	li	a1,17
ffffffffc0200d3c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200d3e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200d40:	04b6e863          	bltu	a3,a1,ffffffffc0200d90 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200d44:	609c                	ld	a5,0(s1)
ffffffffc0200d46:	7b9c                	ld	a5,48(a5)
ffffffffc0200d48:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200d4a:	00001517          	auipc	a0,0x1
ffffffffc0200d4e:	ea650513          	addi	a0,a0,-346 # ffffffffc0201bf0 <buddy_pmm_manager+0x100>
ffffffffc0200d52:	b58ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200d56:	00003597          	auipc	a1,0x3
ffffffffc0200d5a:	2aa58593          	addi	a1,a1,682 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc0200d5e:	00004797          	auipc	a5,0x4
ffffffffc0200d62:	70b7b923          	sd	a1,1810(a5) # ffffffffc0205470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d66:	c02007b7          	lui	a5,0xc0200
ffffffffc0200d6a:	08f5e063          	bltu	a1,a5,ffffffffc0200dea <pmm_init+0x17a>
ffffffffc0200d6e:	6010                	ld	a2,0(s0)
}
ffffffffc0200d70:	6442                	ld	s0,16(sp)
ffffffffc0200d72:	60e2                	ld	ra,24(sp)
ffffffffc0200d74:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d76:	40c58633          	sub	a2,a1,a2
ffffffffc0200d7a:	00004797          	auipc	a5,0x4
ffffffffc0200d7e:	6ec7b723          	sd	a2,1774(a5) # ffffffffc0205468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200d82:	00001517          	auipc	a0,0x1
ffffffffc0200d86:	e8e50513          	addi	a0,a0,-370 # ffffffffc0201c10 <buddy_pmm_manager+0x120>
}
ffffffffc0200d8a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200d8c:	b1eff06f          	j	ffffffffc02000aa <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200d90:	6705                	lui	a4,0x1
ffffffffc0200d92:	177d                	addi	a4,a4,-1
ffffffffc0200d94:	96ba                	add	a3,a3,a4
ffffffffc0200d96:	777d                	lui	a4,0xfffff
ffffffffc0200d98:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200d9a:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200d9e:	00f57e63          	bgeu	a0,a5,ffffffffc0200dba <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200da2:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200da4:	982a                	add	a6,a6,a0
ffffffffc0200da6:	00281513          	slli	a0,a6,0x2
ffffffffc0200daa:	9542                	add	a0,a0,a6
ffffffffc0200dac:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200dae:	8d95                	sub	a1,a1,a3
ffffffffc0200db0:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200db2:	81b1                	srli	a1,a1,0xc
ffffffffc0200db4:	9532                	add	a0,a0,a2
ffffffffc0200db6:	9782                	jalr	a5
}
ffffffffc0200db8:	b771                	j	ffffffffc0200d44 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200dba:	00001617          	auipc	a2,0x1
ffffffffc0200dbe:	e0660613          	addi	a2,a2,-506 # ffffffffc0201bc0 <buddy_pmm_manager+0xd0>
ffffffffc0200dc2:	06b00593          	li	a1,107
ffffffffc0200dc6:	00001517          	auipc	a0,0x1
ffffffffc0200dca:	e1a50513          	addi	a0,a0,-486 # ffffffffc0201be0 <buddy_pmm_manager+0xf0>
ffffffffc0200dce:	dd6ff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200dd2:	00001617          	auipc	a2,0x1
ffffffffc0200dd6:	db660613          	addi	a2,a2,-586 # ffffffffc0201b88 <buddy_pmm_manager+0x98>
ffffffffc0200dda:	06f00593          	li	a1,111
ffffffffc0200dde:	00001517          	auipc	a0,0x1
ffffffffc0200de2:	dd250513          	addi	a0,a0,-558 # ffffffffc0201bb0 <buddy_pmm_manager+0xc0>
ffffffffc0200de6:	dbeff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200dea:	86ae                	mv	a3,a1
ffffffffc0200dec:	00001617          	auipc	a2,0x1
ffffffffc0200df0:	d9c60613          	addi	a2,a2,-612 # ffffffffc0201b88 <buddy_pmm_manager+0x98>
ffffffffc0200df4:	08a00593          	li	a1,138
ffffffffc0200df8:	00001517          	auipc	a0,0x1
ffffffffc0200dfc:	db850513          	addi	a0,a0,-584 # ffffffffc0201bb0 <buddy_pmm_manager+0xc0>
ffffffffc0200e00:	da4ff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc0200e04 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200e04:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200e08:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200e0a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200e0e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200e10:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200e14:	f022                	sd	s0,32(sp)
ffffffffc0200e16:	ec26                	sd	s1,24(sp)
ffffffffc0200e18:	e84a                	sd	s2,16(sp)
ffffffffc0200e1a:	f406                	sd	ra,40(sp)
ffffffffc0200e1c:	e44e                	sd	s3,8(sp)
ffffffffc0200e1e:	84aa                	mv	s1,a0
ffffffffc0200e20:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200e22:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200e26:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200e28:	03067e63          	bgeu	a2,a6,ffffffffc0200e64 <printnum+0x60>
ffffffffc0200e2c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200e2e:	00805763          	blez	s0,ffffffffc0200e3c <printnum+0x38>
ffffffffc0200e32:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200e34:	85ca                	mv	a1,s2
ffffffffc0200e36:	854e                	mv	a0,s3
ffffffffc0200e38:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200e3a:	fc65                	bnez	s0,ffffffffc0200e32 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200e3c:	1a02                	slli	s4,s4,0x20
ffffffffc0200e3e:	00001797          	auipc	a5,0x1
ffffffffc0200e42:	e1278793          	addi	a5,a5,-494 # ffffffffc0201c50 <buddy_pmm_manager+0x160>
ffffffffc0200e46:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200e4a:	9a3e                	add	s4,s4,a5
}
ffffffffc0200e4c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200e4e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200e52:	70a2                	ld	ra,40(sp)
ffffffffc0200e54:	69a2                	ld	s3,8(sp)
ffffffffc0200e56:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200e58:	85ca                	mv	a1,s2
ffffffffc0200e5a:	87a6                	mv	a5,s1
}
ffffffffc0200e5c:	6942                	ld	s2,16(sp)
ffffffffc0200e5e:	64e2                	ld	s1,24(sp)
ffffffffc0200e60:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200e62:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200e64:	03065633          	divu	a2,a2,a6
ffffffffc0200e68:	8722                	mv	a4,s0
ffffffffc0200e6a:	f9bff0ef          	jal	ra,ffffffffc0200e04 <printnum>
ffffffffc0200e6e:	b7f9                	j	ffffffffc0200e3c <printnum+0x38>

ffffffffc0200e70 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200e70:	7119                	addi	sp,sp,-128
ffffffffc0200e72:	f4a6                	sd	s1,104(sp)
ffffffffc0200e74:	f0ca                	sd	s2,96(sp)
ffffffffc0200e76:	ecce                	sd	s3,88(sp)
ffffffffc0200e78:	e8d2                	sd	s4,80(sp)
ffffffffc0200e7a:	e4d6                	sd	s5,72(sp)
ffffffffc0200e7c:	e0da                	sd	s6,64(sp)
ffffffffc0200e7e:	fc5e                	sd	s7,56(sp)
ffffffffc0200e80:	f06a                	sd	s10,32(sp)
ffffffffc0200e82:	fc86                	sd	ra,120(sp)
ffffffffc0200e84:	f8a2                	sd	s0,112(sp)
ffffffffc0200e86:	f862                	sd	s8,48(sp)
ffffffffc0200e88:	f466                	sd	s9,40(sp)
ffffffffc0200e8a:	ec6e                	sd	s11,24(sp)
ffffffffc0200e8c:	892a                	mv	s2,a0
ffffffffc0200e8e:	84ae                	mv	s1,a1
ffffffffc0200e90:	8d32                	mv	s10,a2
ffffffffc0200e92:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e94:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200e98:	5b7d                	li	s6,-1
ffffffffc0200e9a:	00001a97          	auipc	s5,0x1
ffffffffc0200e9e:	deaa8a93          	addi	s5,s5,-534 # ffffffffc0201c84 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200ea2:	00001b97          	auipc	s7,0x1
ffffffffc0200ea6:	fbeb8b93          	addi	s7,s7,-66 # ffffffffc0201e60 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200eaa:	000d4503          	lbu	a0,0(s10)
ffffffffc0200eae:	001d0413          	addi	s0,s10,1
ffffffffc0200eb2:	01350a63          	beq	a0,s3,ffffffffc0200ec6 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0200eb6:	c121                	beqz	a0,ffffffffc0200ef6 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0200eb8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200eba:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200ebc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200ebe:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200ec2:	ff351ae3          	bne	a0,s3,ffffffffc0200eb6 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200ec6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200eca:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200ece:	4c81                	li	s9,0
ffffffffc0200ed0:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0200ed2:	5c7d                	li	s8,-1
ffffffffc0200ed4:	5dfd                	li	s11,-1
ffffffffc0200ed6:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0200eda:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200edc:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200ee0:	0ff5f593          	zext.b	a1,a1
ffffffffc0200ee4:	00140d13          	addi	s10,s0,1
ffffffffc0200ee8:	04b56263          	bltu	a0,a1,ffffffffc0200f2c <vprintfmt+0xbc>
ffffffffc0200eec:	058a                	slli	a1,a1,0x2
ffffffffc0200eee:	95d6                	add	a1,a1,s5
ffffffffc0200ef0:	4194                	lw	a3,0(a1)
ffffffffc0200ef2:	96d6                	add	a3,a3,s5
ffffffffc0200ef4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200ef6:	70e6                	ld	ra,120(sp)
ffffffffc0200ef8:	7446                	ld	s0,112(sp)
ffffffffc0200efa:	74a6                	ld	s1,104(sp)
ffffffffc0200efc:	7906                	ld	s2,96(sp)
ffffffffc0200efe:	69e6                	ld	s3,88(sp)
ffffffffc0200f00:	6a46                	ld	s4,80(sp)
ffffffffc0200f02:	6aa6                	ld	s5,72(sp)
ffffffffc0200f04:	6b06                	ld	s6,64(sp)
ffffffffc0200f06:	7be2                	ld	s7,56(sp)
ffffffffc0200f08:	7c42                	ld	s8,48(sp)
ffffffffc0200f0a:	7ca2                	ld	s9,40(sp)
ffffffffc0200f0c:	7d02                	ld	s10,32(sp)
ffffffffc0200f0e:	6de2                	ld	s11,24(sp)
ffffffffc0200f10:	6109                	addi	sp,sp,128
ffffffffc0200f12:	8082                	ret
            padc = '0';
ffffffffc0200f14:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0200f16:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f1a:	846a                	mv	s0,s10
ffffffffc0200f1c:	00140d13          	addi	s10,s0,1
ffffffffc0200f20:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200f24:	0ff5f593          	zext.b	a1,a1
ffffffffc0200f28:	fcb572e3          	bgeu	a0,a1,ffffffffc0200eec <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0200f2c:	85a6                	mv	a1,s1
ffffffffc0200f2e:	02500513          	li	a0,37
ffffffffc0200f32:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0200f34:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200f38:	8d22                	mv	s10,s0
ffffffffc0200f3a:	f73788e3          	beq	a5,s3,ffffffffc0200eaa <vprintfmt+0x3a>
ffffffffc0200f3e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200f42:	1d7d                	addi	s10,s10,-1
ffffffffc0200f44:	ff379de3          	bne	a5,s3,ffffffffc0200f3e <vprintfmt+0xce>
ffffffffc0200f48:	b78d                	j	ffffffffc0200eaa <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0200f4a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0200f4e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f52:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0200f54:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0200f58:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200f5c:	02d86463          	bltu	a6,a3,ffffffffc0200f84 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0200f60:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0200f64:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200f68:	0186873b          	addw	a4,a3,s8
ffffffffc0200f6c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200f70:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0200f72:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0200f76:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0200f78:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0200f7c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200f80:	fed870e3          	bgeu	a6,a3,ffffffffc0200f60 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0200f84:	f40ddce3          	bgez	s11,ffffffffc0200edc <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0200f88:	8de2                	mv	s11,s8
ffffffffc0200f8a:	5c7d                	li	s8,-1
ffffffffc0200f8c:	bf81                	j	ffffffffc0200edc <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0200f8e:	fffdc693          	not	a3,s11
ffffffffc0200f92:	96fd                	srai	a3,a3,0x3f
ffffffffc0200f94:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f98:	00144603          	lbu	a2,1(s0)
ffffffffc0200f9c:	2d81                	sext.w	s11,s11
ffffffffc0200f9e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200fa0:	bf35                	j	ffffffffc0200edc <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0200fa2:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200fa6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0200faa:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200fac:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0200fae:	bfd9                	j	ffffffffc0200f84 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0200fb0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200fb2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200fb6:	01174463          	blt	a4,a7,ffffffffc0200fbe <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0200fba:	1a088e63          	beqz	a7,ffffffffc0201176 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0200fbe:	000a3603          	ld	a2,0(s4)
ffffffffc0200fc2:	46c1                	li	a3,16
ffffffffc0200fc4:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0200fc6:	2781                	sext.w	a5,a5
ffffffffc0200fc8:	876e                	mv	a4,s11
ffffffffc0200fca:	85a6                	mv	a1,s1
ffffffffc0200fcc:	854a                	mv	a0,s2
ffffffffc0200fce:	e37ff0ef          	jal	ra,ffffffffc0200e04 <printnum>
            break;
ffffffffc0200fd2:	bde1                	j	ffffffffc0200eaa <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0200fd4:	000a2503          	lw	a0,0(s4)
ffffffffc0200fd8:	85a6                	mv	a1,s1
ffffffffc0200fda:	0a21                	addi	s4,s4,8
ffffffffc0200fdc:	9902                	jalr	s2
            break;
ffffffffc0200fde:	b5f1                	j	ffffffffc0200eaa <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200fe0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200fe2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200fe6:	01174463          	blt	a4,a7,ffffffffc0200fee <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0200fea:	18088163          	beqz	a7,ffffffffc020116c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0200fee:	000a3603          	ld	a2,0(s4)
ffffffffc0200ff2:	46a9                	li	a3,10
ffffffffc0200ff4:	8a2e                	mv	s4,a1
ffffffffc0200ff6:	bfc1                	j	ffffffffc0200fc6 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200ff8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0200ffc:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200ffe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201000:	bdf1                	j	ffffffffc0200edc <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201002:	85a6                	mv	a1,s1
ffffffffc0201004:	02500513          	li	a0,37
ffffffffc0201008:	9902                	jalr	s2
            break;
ffffffffc020100a:	b545                	j	ffffffffc0200eaa <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020100c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201010:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201012:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201014:	b5e1                	j	ffffffffc0200edc <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201016:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201018:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020101c:	01174463          	blt	a4,a7,ffffffffc0201024 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201020:	14088163          	beqz	a7,ffffffffc0201162 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201024:	000a3603          	ld	a2,0(s4)
ffffffffc0201028:	46a1                	li	a3,8
ffffffffc020102a:	8a2e                	mv	s4,a1
ffffffffc020102c:	bf69                	j	ffffffffc0200fc6 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020102e:	03000513          	li	a0,48
ffffffffc0201032:	85a6                	mv	a1,s1
ffffffffc0201034:	e03e                	sd	a5,0(sp)
ffffffffc0201036:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201038:	85a6                	mv	a1,s1
ffffffffc020103a:	07800513          	li	a0,120
ffffffffc020103e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201040:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201042:	6782                	ld	a5,0(sp)
ffffffffc0201044:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201046:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020104a:	bfb5                	j	ffffffffc0200fc6 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020104c:	000a3403          	ld	s0,0(s4)
ffffffffc0201050:	008a0713          	addi	a4,s4,8
ffffffffc0201054:	e03a                	sd	a4,0(sp)
ffffffffc0201056:	14040263          	beqz	s0,ffffffffc020119a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020105a:	0fb05763          	blez	s11,ffffffffc0201148 <vprintfmt+0x2d8>
ffffffffc020105e:	02d00693          	li	a3,45
ffffffffc0201062:	0cd79163          	bne	a5,a3,ffffffffc0201124 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201066:	00044783          	lbu	a5,0(s0)
ffffffffc020106a:	0007851b          	sext.w	a0,a5
ffffffffc020106e:	cf85                	beqz	a5,ffffffffc02010a6 <vprintfmt+0x236>
ffffffffc0201070:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201074:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201078:	000c4563          	bltz	s8,ffffffffc0201082 <vprintfmt+0x212>
ffffffffc020107c:	3c7d                	addiw	s8,s8,-1
ffffffffc020107e:	036c0263          	beq	s8,s6,ffffffffc02010a2 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201082:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201084:	0e0c8e63          	beqz	s9,ffffffffc0201180 <vprintfmt+0x310>
ffffffffc0201088:	3781                	addiw	a5,a5,-32
ffffffffc020108a:	0ef47b63          	bgeu	s0,a5,ffffffffc0201180 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020108e:	03f00513          	li	a0,63
ffffffffc0201092:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201094:	000a4783          	lbu	a5,0(s4)
ffffffffc0201098:	3dfd                	addiw	s11,s11,-1
ffffffffc020109a:	0a05                	addi	s4,s4,1
ffffffffc020109c:	0007851b          	sext.w	a0,a5
ffffffffc02010a0:	ffe1                	bnez	a5,ffffffffc0201078 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02010a2:	01b05963          	blez	s11,ffffffffc02010b4 <vprintfmt+0x244>
ffffffffc02010a6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02010a8:	85a6                	mv	a1,s1
ffffffffc02010aa:	02000513          	li	a0,32
ffffffffc02010ae:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02010b0:	fe0d9be3          	bnez	s11,ffffffffc02010a6 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02010b4:	6a02                	ld	s4,0(sp)
ffffffffc02010b6:	bbd5                	j	ffffffffc0200eaa <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02010b8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02010ba:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02010be:	01174463          	blt	a4,a7,ffffffffc02010c6 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02010c2:	08088d63          	beqz	a7,ffffffffc020115c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02010c6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02010ca:	0a044d63          	bltz	s0,ffffffffc0201184 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02010ce:	8622                	mv	a2,s0
ffffffffc02010d0:	8a66                	mv	s4,s9
ffffffffc02010d2:	46a9                	li	a3,10
ffffffffc02010d4:	bdcd                	j	ffffffffc0200fc6 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02010d6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010da:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02010dc:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02010de:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02010e2:	8fb5                	xor	a5,a5,a3
ffffffffc02010e4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010e8:	02d74163          	blt	a4,a3,ffffffffc020110a <vprintfmt+0x29a>
ffffffffc02010ec:	00369793          	slli	a5,a3,0x3
ffffffffc02010f0:	97de                	add	a5,a5,s7
ffffffffc02010f2:	639c                	ld	a5,0(a5)
ffffffffc02010f4:	cb99                	beqz	a5,ffffffffc020110a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02010f6:	86be                	mv	a3,a5
ffffffffc02010f8:	00001617          	auipc	a2,0x1
ffffffffc02010fc:	b8860613          	addi	a2,a2,-1144 # ffffffffc0201c80 <buddy_pmm_manager+0x190>
ffffffffc0201100:	85a6                	mv	a1,s1
ffffffffc0201102:	854a                	mv	a0,s2
ffffffffc0201104:	0ce000ef          	jal	ra,ffffffffc02011d2 <printfmt>
ffffffffc0201108:	b34d                	j	ffffffffc0200eaa <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020110a:	00001617          	auipc	a2,0x1
ffffffffc020110e:	b6660613          	addi	a2,a2,-1178 # ffffffffc0201c70 <buddy_pmm_manager+0x180>
ffffffffc0201112:	85a6                	mv	a1,s1
ffffffffc0201114:	854a                	mv	a0,s2
ffffffffc0201116:	0bc000ef          	jal	ra,ffffffffc02011d2 <printfmt>
ffffffffc020111a:	bb41                	j	ffffffffc0200eaa <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020111c:	00001417          	auipc	s0,0x1
ffffffffc0201120:	b4c40413          	addi	s0,s0,-1204 # ffffffffc0201c68 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201124:	85e2                	mv	a1,s8
ffffffffc0201126:	8522                	mv	a0,s0
ffffffffc0201128:	e43e                	sd	a5,8(sp)
ffffffffc020112a:	1cc000ef          	jal	ra,ffffffffc02012f6 <strnlen>
ffffffffc020112e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201132:	01b05b63          	blez	s11,ffffffffc0201148 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201136:	67a2                	ld	a5,8(sp)
ffffffffc0201138:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020113c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020113e:	85a6                	mv	a1,s1
ffffffffc0201140:	8552                	mv	a0,s4
ffffffffc0201142:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201144:	fe0d9ce3          	bnez	s11,ffffffffc020113c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201148:	00044783          	lbu	a5,0(s0)
ffffffffc020114c:	00140a13          	addi	s4,s0,1
ffffffffc0201150:	0007851b          	sext.w	a0,a5
ffffffffc0201154:	d3a5                	beqz	a5,ffffffffc02010b4 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201156:	05e00413          	li	s0,94
ffffffffc020115a:	bf39                	j	ffffffffc0201078 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020115c:	000a2403          	lw	s0,0(s4)
ffffffffc0201160:	b7ad                	j	ffffffffc02010ca <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201162:	000a6603          	lwu	a2,0(s4)
ffffffffc0201166:	46a1                	li	a3,8
ffffffffc0201168:	8a2e                	mv	s4,a1
ffffffffc020116a:	bdb1                	j	ffffffffc0200fc6 <vprintfmt+0x156>
ffffffffc020116c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201170:	46a9                	li	a3,10
ffffffffc0201172:	8a2e                	mv	s4,a1
ffffffffc0201174:	bd89                	j	ffffffffc0200fc6 <vprintfmt+0x156>
ffffffffc0201176:	000a6603          	lwu	a2,0(s4)
ffffffffc020117a:	46c1                	li	a3,16
ffffffffc020117c:	8a2e                	mv	s4,a1
ffffffffc020117e:	b5a1                	j	ffffffffc0200fc6 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201180:	9902                	jalr	s2
ffffffffc0201182:	bf09                	j	ffffffffc0201094 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201184:	85a6                	mv	a1,s1
ffffffffc0201186:	02d00513          	li	a0,45
ffffffffc020118a:	e03e                	sd	a5,0(sp)
ffffffffc020118c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020118e:	6782                	ld	a5,0(sp)
ffffffffc0201190:	8a66                	mv	s4,s9
ffffffffc0201192:	40800633          	neg	a2,s0
ffffffffc0201196:	46a9                	li	a3,10
ffffffffc0201198:	b53d                	j	ffffffffc0200fc6 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020119a:	03b05163          	blez	s11,ffffffffc02011bc <vprintfmt+0x34c>
ffffffffc020119e:	02d00693          	li	a3,45
ffffffffc02011a2:	f6d79de3          	bne	a5,a3,ffffffffc020111c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02011a6:	00001417          	auipc	s0,0x1
ffffffffc02011aa:	ac240413          	addi	s0,s0,-1342 # ffffffffc0201c68 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011ae:	02800793          	li	a5,40
ffffffffc02011b2:	02800513          	li	a0,40
ffffffffc02011b6:	00140a13          	addi	s4,s0,1
ffffffffc02011ba:	bd6d                	j	ffffffffc0201074 <vprintfmt+0x204>
ffffffffc02011bc:	00001a17          	auipc	s4,0x1
ffffffffc02011c0:	aada0a13          	addi	s4,s4,-1363 # ffffffffc0201c69 <buddy_pmm_manager+0x179>
ffffffffc02011c4:	02800513          	li	a0,40
ffffffffc02011c8:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011cc:	05e00413          	li	s0,94
ffffffffc02011d0:	b565                	j	ffffffffc0201078 <vprintfmt+0x208>

ffffffffc02011d2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02011d2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02011d4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02011d8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02011da:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02011dc:	ec06                	sd	ra,24(sp)
ffffffffc02011de:	f83a                	sd	a4,48(sp)
ffffffffc02011e0:	fc3e                	sd	a5,56(sp)
ffffffffc02011e2:	e0c2                	sd	a6,64(sp)
ffffffffc02011e4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02011e6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02011e8:	c89ff0ef          	jal	ra,ffffffffc0200e70 <vprintfmt>
}
ffffffffc02011ec:	60e2                	ld	ra,24(sp)
ffffffffc02011ee:	6161                	addi	sp,sp,80
ffffffffc02011f0:	8082                	ret

ffffffffc02011f2 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02011f2:	715d                	addi	sp,sp,-80
ffffffffc02011f4:	e486                	sd	ra,72(sp)
ffffffffc02011f6:	e0a6                	sd	s1,64(sp)
ffffffffc02011f8:	fc4a                	sd	s2,56(sp)
ffffffffc02011fa:	f84e                	sd	s3,48(sp)
ffffffffc02011fc:	f452                	sd	s4,40(sp)
ffffffffc02011fe:	f056                	sd	s5,32(sp)
ffffffffc0201200:	ec5a                	sd	s6,24(sp)
ffffffffc0201202:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201204:	c901                	beqz	a0,ffffffffc0201214 <readline+0x22>
ffffffffc0201206:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201208:	00001517          	auipc	a0,0x1
ffffffffc020120c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201c80 <buddy_pmm_manager+0x190>
ffffffffc0201210:	e9bfe0ef          	jal	ra,ffffffffc02000aa <cprintf>
readline(const char *prompt) {
ffffffffc0201214:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201216:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201218:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020121a:	4aa9                	li	s5,10
ffffffffc020121c:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020121e:	00004b97          	auipc	s7,0x4
ffffffffc0201222:	e0ab8b93          	addi	s7,s7,-502 # ffffffffc0205028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201226:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020122a:	ef9fe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc020122e:	00054a63          	bltz	a0,ffffffffc0201242 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201232:	00a95a63          	bge	s2,a0,ffffffffc0201246 <readline+0x54>
ffffffffc0201236:	029a5263          	bge	s4,s1,ffffffffc020125a <readline+0x68>
        c = getchar();
ffffffffc020123a:	ee9fe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc020123e:	fe055ae3          	bgez	a0,ffffffffc0201232 <readline+0x40>
            return NULL;
ffffffffc0201242:	4501                	li	a0,0
ffffffffc0201244:	a091                	j	ffffffffc0201288 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201246:	03351463          	bne	a0,s3,ffffffffc020126e <readline+0x7c>
ffffffffc020124a:	e8a9                	bnez	s1,ffffffffc020129c <readline+0xaa>
        c = getchar();
ffffffffc020124c:	ed7fe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc0201250:	fe0549e3          	bltz	a0,ffffffffc0201242 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201254:	fea959e3          	bge	s2,a0,ffffffffc0201246 <readline+0x54>
ffffffffc0201258:	4481                	li	s1,0
            cputchar(c);
ffffffffc020125a:	e42a                	sd	a0,8(sp)
ffffffffc020125c:	e85fe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            buf[i ++] = c;
ffffffffc0201260:	6522                	ld	a0,8(sp)
ffffffffc0201262:	009b87b3          	add	a5,s7,s1
ffffffffc0201266:	2485                	addiw	s1,s1,1
ffffffffc0201268:	00a78023          	sb	a0,0(a5)
ffffffffc020126c:	bf7d                	j	ffffffffc020122a <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020126e:	01550463          	beq	a0,s5,ffffffffc0201276 <readline+0x84>
ffffffffc0201272:	fb651ce3          	bne	a0,s6,ffffffffc020122a <readline+0x38>
            cputchar(c);
ffffffffc0201276:	e6bfe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            buf[i] = '\0';
ffffffffc020127a:	00004517          	auipc	a0,0x4
ffffffffc020127e:	dae50513          	addi	a0,a0,-594 # ffffffffc0205028 <buf>
ffffffffc0201282:	94aa                	add	s1,s1,a0
ffffffffc0201284:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201288:	60a6                	ld	ra,72(sp)
ffffffffc020128a:	6486                	ld	s1,64(sp)
ffffffffc020128c:	7962                	ld	s2,56(sp)
ffffffffc020128e:	79c2                	ld	s3,48(sp)
ffffffffc0201290:	7a22                	ld	s4,40(sp)
ffffffffc0201292:	7a82                	ld	s5,32(sp)
ffffffffc0201294:	6b62                	ld	s6,24(sp)
ffffffffc0201296:	6bc2                	ld	s7,16(sp)
ffffffffc0201298:	6161                	addi	sp,sp,80
ffffffffc020129a:	8082                	ret
            cputchar(c);
ffffffffc020129c:	4521                	li	a0,8
ffffffffc020129e:	e43fe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            i --;
ffffffffc02012a2:	34fd                	addiw	s1,s1,-1
ffffffffc02012a4:	b759                	j	ffffffffc020122a <readline+0x38>

ffffffffc02012a6 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02012a6:	4781                	li	a5,0
ffffffffc02012a8:	00004717          	auipc	a4,0x4
ffffffffc02012ac:	d6073703          	ld	a4,-672(a4) # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02012b0:	88ba                	mv	a7,a4
ffffffffc02012b2:	852a                	mv	a0,a0
ffffffffc02012b4:	85be                	mv	a1,a5
ffffffffc02012b6:	863e                	mv	a2,a5
ffffffffc02012b8:	00000073          	ecall
ffffffffc02012bc:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02012be:	8082                	ret

ffffffffc02012c0 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02012c0:	4781                	li	a5,0
ffffffffc02012c2:	00004717          	auipc	a4,0x4
ffffffffc02012c6:	1be73703          	ld	a4,446(a4) # ffffffffc0205480 <SBI_SET_TIMER>
ffffffffc02012ca:	88ba                	mv	a7,a4
ffffffffc02012cc:	852a                	mv	a0,a0
ffffffffc02012ce:	85be                	mv	a1,a5
ffffffffc02012d0:	863e                	mv	a2,a5
ffffffffc02012d2:	00000073          	ecall
ffffffffc02012d6:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02012d8:	8082                	ret

ffffffffc02012da <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02012da:	4501                	li	a0,0
ffffffffc02012dc:	00004797          	auipc	a5,0x4
ffffffffc02012e0:	d247b783          	ld	a5,-732(a5) # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
ffffffffc02012e4:	88be                	mv	a7,a5
ffffffffc02012e6:	852a                	mv	a0,a0
ffffffffc02012e8:	85aa                	mv	a1,a0
ffffffffc02012ea:	862a                	mv	a2,a0
ffffffffc02012ec:	00000073          	ecall
ffffffffc02012f0:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02012f2:	2501                	sext.w	a0,a0
ffffffffc02012f4:	8082                	ret

ffffffffc02012f6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02012f6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012f8:	e589                	bnez	a1,ffffffffc0201302 <strnlen+0xc>
ffffffffc02012fa:	a811                	j	ffffffffc020130e <strnlen+0x18>
        cnt ++;
ffffffffc02012fc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02012fe:	00f58863          	beq	a1,a5,ffffffffc020130e <strnlen+0x18>
ffffffffc0201302:	00f50733          	add	a4,a0,a5
ffffffffc0201306:	00074703          	lbu	a4,0(a4)
ffffffffc020130a:	fb6d                	bnez	a4,ffffffffc02012fc <strnlen+0x6>
ffffffffc020130c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020130e:	852e                	mv	a0,a1
ffffffffc0201310:	8082                	ret

ffffffffc0201312 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201312:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201316:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020131a:	cb89                	beqz	a5,ffffffffc020132c <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020131c:	0505                	addi	a0,a0,1
ffffffffc020131e:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201320:	fee789e3          	beq	a5,a4,ffffffffc0201312 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201324:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201328:	9d19                	subw	a0,a0,a4
ffffffffc020132a:	8082                	ret
ffffffffc020132c:	4501                	li	a0,0
ffffffffc020132e:	bfed                	j	ffffffffc0201328 <strcmp+0x16>

ffffffffc0201330 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201330:	00054783          	lbu	a5,0(a0)
ffffffffc0201334:	c799                	beqz	a5,ffffffffc0201342 <strchr+0x12>
        if (*s == c) {
ffffffffc0201336:	00f58763          	beq	a1,a5,ffffffffc0201344 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020133a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020133e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201340:	fbfd                	bnez	a5,ffffffffc0201336 <strchr+0x6>
    }
    return NULL;
ffffffffc0201342:	4501                	li	a0,0
}
ffffffffc0201344:	8082                	ret

ffffffffc0201346 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201346:	ca01                	beqz	a2,ffffffffc0201356 <memset+0x10>
ffffffffc0201348:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020134a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020134c:	0785                	addi	a5,a5,1
ffffffffc020134e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201352:	fec79de3          	bne	a5,a2,ffffffffc020134c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201356:	8082                	ret
