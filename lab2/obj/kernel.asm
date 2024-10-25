
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
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
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

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
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	44e60613          	addi	a2,a2,1102 # ffffffffc0206488 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	420010ef          	jal	ra,ffffffffc020146a <memset>
    cons_init();  // init the console
ffffffffc020004e:	3e4000ef          	jal	ra,ffffffffc0200432 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	42e50513          	addi	a0,a0,1070 # ffffffffc0201480 <etext+0x4>
ffffffffc020005a:	088000ef          	jal	ra,ffffffffc02000e2 <cputs>

    print_kerninfo();
ffffffffc020005e:	0d4000ef          	jal	ra,ffffffffc0200132 <print_kerninfo>

    // grade_backtrace();
    // idt_init();  // init interrupt descriptor table

    pmm_init();  // init physical memory management
ffffffffc0200062:	533000ef          	jal	ra,ffffffffc0200d94 <pmm_init>

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
ffffffffc020009e:	6f7000ef          	jal	ra,ffffffffc0200f94 <vprintfmt>
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
ffffffffc02000ac:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
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
ffffffffc02000d4:	6c1000ef          	jal	ra,ffffffffc0200f94 <vprintfmt>
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
ffffffffc0200138:	36c50513          	addi	a0,a0,876 # ffffffffc02014a0 <etext+0x24>
void print_kerninfo(void) {
ffffffffc020013c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020013e:	f6dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200142:	00000597          	auipc	a1,0x0
ffffffffc0200146:	ef058593          	addi	a1,a1,-272 # ffffffffc0200032 <kern_init>
ffffffffc020014a:	00001517          	auipc	a0,0x1
ffffffffc020014e:	37650513          	addi	a0,a0,886 # ffffffffc02014c0 <etext+0x44>
ffffffffc0200152:	f59ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200156:	00001597          	auipc	a1,0x1
ffffffffc020015a:	32658593          	addi	a1,a1,806 # ffffffffc020147c <etext>
ffffffffc020015e:	00001517          	auipc	a0,0x1
ffffffffc0200162:	38250513          	addi	a0,a0,898 # ffffffffc02014e0 <etext+0x64>
ffffffffc0200166:	f45ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020016a:	00006597          	auipc	a1,0x6
ffffffffc020016e:	ea658593          	addi	a1,a1,-346 # ffffffffc0206010 <free_area>
ffffffffc0200172:	00001517          	auipc	a0,0x1
ffffffffc0200176:	38e50513          	addi	a0,a0,910 # ffffffffc0201500 <etext+0x84>
ffffffffc020017a:	f31ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020017e:	00006597          	auipc	a1,0x6
ffffffffc0200182:	30a58593          	addi	a1,a1,778 # ffffffffc0206488 <end>
ffffffffc0200186:	00001517          	auipc	a0,0x1
ffffffffc020018a:	39a50513          	addi	a0,a0,922 # ffffffffc0201520 <etext+0xa4>
ffffffffc020018e:	f1dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200192:	00006597          	auipc	a1,0x6
ffffffffc0200196:	6f558593          	addi	a1,a1,1781 # ffffffffc0206887 <end+0x3ff>
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
ffffffffc02001b8:	38c50513          	addi	a0,a0,908 # ffffffffc0201540 <etext+0xc4>
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
ffffffffc02001c6:	3ae60613          	addi	a2,a2,942 # ffffffffc0201570 <etext+0xf4>
ffffffffc02001ca:	04e00593          	li	a1,78
ffffffffc02001ce:	00001517          	auipc	a0,0x1
ffffffffc02001d2:	3ba50513          	addi	a0,a0,954 # ffffffffc0201588 <etext+0x10c>
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
ffffffffc02001e2:	3c260613          	addi	a2,a2,962 # ffffffffc02015a0 <etext+0x124>
ffffffffc02001e6:	00001597          	auipc	a1,0x1
ffffffffc02001ea:	3da58593          	addi	a1,a1,986 # ffffffffc02015c0 <etext+0x144>
ffffffffc02001ee:	00001517          	auipc	a0,0x1
ffffffffc02001f2:	3da50513          	addi	a0,a0,986 # ffffffffc02015c8 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001f6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f8:	eb3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc02001fc:	00001617          	auipc	a2,0x1
ffffffffc0200200:	3dc60613          	addi	a2,a2,988 # ffffffffc02015d8 <etext+0x15c>
ffffffffc0200204:	00001597          	auipc	a1,0x1
ffffffffc0200208:	3fc58593          	addi	a1,a1,1020 # ffffffffc0201600 <etext+0x184>
ffffffffc020020c:	00001517          	auipc	a0,0x1
ffffffffc0200210:	3bc50513          	addi	a0,a0,956 # ffffffffc02015c8 <etext+0x14c>
ffffffffc0200214:	e97ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc0200218:	00001617          	auipc	a2,0x1
ffffffffc020021c:	3f860613          	addi	a2,a2,1016 # ffffffffc0201610 <etext+0x194>
ffffffffc0200220:	00001597          	auipc	a1,0x1
ffffffffc0200224:	41058593          	addi	a1,a1,1040 # ffffffffc0201630 <etext+0x1b4>
ffffffffc0200228:	00001517          	auipc	a0,0x1
ffffffffc020022c:	3a050513          	addi	a0,a0,928 # ffffffffc02015c8 <etext+0x14c>
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
ffffffffc0200266:	3de50513          	addi	a0,a0,990 # ffffffffc0201640 <etext+0x1c4>
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
ffffffffc0200288:	3e450513          	addi	a0,a0,996 # ffffffffc0201668 <etext+0x1ec>
ffffffffc020028c:	e1fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    if (tf != NULL) {
ffffffffc0200290:	000b8563          	beqz	s7,ffffffffc020029a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200294:	855e                	mv	a0,s7
ffffffffc0200296:	382000ef          	jal	ra,ffffffffc0200618 <print_trapframe>
ffffffffc020029a:	00001c17          	auipc	s8,0x1
ffffffffc020029e:	43ec0c13          	addi	s8,s8,1086 # ffffffffc02016d8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002a2:	00001917          	auipc	s2,0x1
ffffffffc02002a6:	3ee90913          	addi	s2,s2,1006 # ffffffffc0201690 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002aa:	00001497          	auipc	s1,0x1
ffffffffc02002ae:	3ee48493          	addi	s1,s1,1006 # ffffffffc0201698 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002b2:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002b4:	00001b17          	auipc	s6,0x1
ffffffffc02002b8:	3ecb0b13          	addi	s6,s6,1004 # ffffffffc02016a0 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002bc:	00001a17          	auipc	s4,0x1
ffffffffc02002c0:	304a0a13          	addi	s4,s4,772 # ffffffffc02015c0 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c4:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002c6:	854a                	mv	a0,s2
ffffffffc02002c8:	04e010ef          	jal	ra,ffffffffc0201316 <readline>
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
ffffffffc02002e2:	3fad0d13          	addi	s10,s10,1018 # ffffffffc02016d8 <commands>
        argv[argc ++] = buf;
ffffffffc02002e6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002e8:	4401                	li	s0,0
ffffffffc02002ea:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ec:	14a010ef          	jal	ra,ffffffffc0201436 <strcmp>
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
ffffffffc0200300:	136010ef          	jal	ra,ffffffffc0201436 <strcmp>
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
ffffffffc020033e:	116010ef          	jal	ra,ffffffffc0201454 <strchr>
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
ffffffffc020037c:	0d8010ef          	jal	ra,ffffffffc0201454 <strchr>
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
ffffffffc020039a:	32a50513          	addi	a0,a0,810 # ffffffffc02016c0 <etext+0x244>
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
ffffffffc02003a4:	00006317          	auipc	t1,0x6
ffffffffc02003a8:	08430313          	addi	t1,t1,132 # ffffffffc0206428 <is_panic>
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
ffffffffc02003d6:	34e50513          	addi	a0,a0,846 # ffffffffc0201720 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003da:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	ccfff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e0:	65a2                	ld	a1,8(sp)
ffffffffc02003e2:	8522                	mv	a0,s0
ffffffffc02003e4:	ca7ff0ef          	jal	ra,ffffffffc020008a <vcprintf>
    cprintf("\n");
ffffffffc02003e8:	00002517          	auipc	a0,0x2
ffffffffc02003ec:	82050513          	addi	a0,a0,-2016 # ffffffffc0201c08 <commands+0x530>
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
ffffffffc0200418:	7cd000ef          	jal	ra,ffffffffc02013e4 <sbi_set_timer>
}
ffffffffc020041c:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020041e:	00006797          	auipc	a5,0x6
ffffffffc0200422:	0007b923          	sd	zero,18(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200426:	00001517          	auipc	a0,0x1
ffffffffc020042a:	31a50513          	addi	a0,a0,794 # ffffffffc0201740 <commands+0x68>
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
ffffffffc0200438:	7930006f          	j	ffffffffc02013ca <sbi_console_putchar>

ffffffffc020043c <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020043c:	7c30006f          	j	ffffffffc02013fe <sbi_console_getchar>

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
ffffffffc0200458:	30c50513          	addi	a0,a0,780 # ffffffffc0201760 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc020045c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020045e:	c4dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200462:	640c                	ld	a1,8(s0)
ffffffffc0200464:	00001517          	auipc	a0,0x1
ffffffffc0200468:	31450513          	addi	a0,a0,788 # ffffffffc0201778 <commands+0xa0>
ffffffffc020046c:	c3fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200470:	680c                	ld	a1,16(s0)
ffffffffc0200472:	00001517          	auipc	a0,0x1
ffffffffc0200476:	31e50513          	addi	a0,a0,798 # ffffffffc0201790 <commands+0xb8>
ffffffffc020047a:	c31ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020047e:	6c0c                	ld	a1,24(s0)
ffffffffc0200480:	00001517          	auipc	a0,0x1
ffffffffc0200484:	32850513          	addi	a0,a0,808 # ffffffffc02017a8 <commands+0xd0>
ffffffffc0200488:	c23ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020048c:	700c                	ld	a1,32(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	33250513          	addi	a0,a0,818 # ffffffffc02017c0 <commands+0xe8>
ffffffffc0200496:	c15ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020049a:	740c                	ld	a1,40(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	33c50513          	addi	a0,a0,828 # ffffffffc02017d8 <commands+0x100>
ffffffffc02004a4:	c07ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004a8:	780c                	ld	a1,48(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	34650513          	addi	a0,a0,838 # ffffffffc02017f0 <commands+0x118>
ffffffffc02004b2:	bf9ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004b6:	7c0c                	ld	a1,56(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	35050513          	addi	a0,a0,848 # ffffffffc0201808 <commands+0x130>
ffffffffc02004c0:	bebff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004c4:	602c                	ld	a1,64(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	35a50513          	addi	a0,a0,858 # ffffffffc0201820 <commands+0x148>
ffffffffc02004ce:	bddff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004d2:	642c                	ld	a1,72(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	36450513          	addi	a0,a0,868 # ffffffffc0201838 <commands+0x160>
ffffffffc02004dc:	bcfff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02004e0:	682c                	ld	a1,80(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	36e50513          	addi	a0,a0,878 # ffffffffc0201850 <commands+0x178>
ffffffffc02004ea:	bc1ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02004ee:	6c2c                	ld	a1,88(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	37850513          	addi	a0,a0,888 # ffffffffc0201868 <commands+0x190>
ffffffffc02004f8:	bb3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02004fc:	702c                	ld	a1,96(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	38250513          	addi	a0,a0,898 # ffffffffc0201880 <commands+0x1a8>
ffffffffc0200506:	ba5ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020050a:	742c                	ld	a1,104(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	38c50513          	addi	a0,a0,908 # ffffffffc0201898 <commands+0x1c0>
ffffffffc0200514:	b97ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200518:	782c                	ld	a1,112(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	39650513          	addi	a0,a0,918 # ffffffffc02018b0 <commands+0x1d8>
ffffffffc0200522:	b89ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200526:	7c2c                	ld	a1,120(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	3a050513          	addi	a0,a0,928 # ffffffffc02018c8 <commands+0x1f0>
ffffffffc0200530:	b7bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200534:	604c                	ld	a1,128(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	3aa50513          	addi	a0,a0,938 # ffffffffc02018e0 <commands+0x208>
ffffffffc020053e:	b6dff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200542:	644c                	ld	a1,136(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	3b450513          	addi	a0,a0,948 # ffffffffc02018f8 <commands+0x220>
ffffffffc020054c:	b5fff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200550:	684c                	ld	a1,144(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	3be50513          	addi	a0,a0,958 # ffffffffc0201910 <commands+0x238>
ffffffffc020055a:	b51ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020055e:	6c4c                	ld	a1,152(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	3c850513          	addi	a0,a0,968 # ffffffffc0201928 <commands+0x250>
ffffffffc0200568:	b43ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020056c:	704c                	ld	a1,160(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	3d250513          	addi	a0,a0,978 # ffffffffc0201940 <commands+0x268>
ffffffffc0200576:	b35ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020057a:	744c                	ld	a1,168(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	3dc50513          	addi	a0,a0,988 # ffffffffc0201958 <commands+0x280>
ffffffffc0200584:	b27ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200588:	784c                	ld	a1,176(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	3e650513          	addi	a0,a0,998 # ffffffffc0201970 <commands+0x298>
ffffffffc0200592:	b19ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200596:	7c4c                	ld	a1,184(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	3f050513          	addi	a0,a0,1008 # ffffffffc0201988 <commands+0x2b0>
ffffffffc02005a0:	b0bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005a4:	606c                	ld	a1,192(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	3fa50513          	addi	a0,a0,1018 # ffffffffc02019a0 <commands+0x2c8>
ffffffffc02005ae:	afdff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005b2:	646c                	ld	a1,200(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	40450513          	addi	a0,a0,1028 # ffffffffc02019b8 <commands+0x2e0>
ffffffffc02005bc:	aefff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005c0:	686c                	ld	a1,208(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	40e50513          	addi	a0,a0,1038 # ffffffffc02019d0 <commands+0x2f8>
ffffffffc02005ca:	ae1ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005ce:	6c6c                	ld	a1,216(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	41850513          	addi	a0,a0,1048 # ffffffffc02019e8 <commands+0x310>
ffffffffc02005d8:	ad3ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02005dc:	706c                	ld	a1,224(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	42250513          	addi	a0,a0,1058 # ffffffffc0201a00 <commands+0x328>
ffffffffc02005e6:	ac5ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02005ea:	746c                	ld	a1,232(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	42c50513          	addi	a0,a0,1068 # ffffffffc0201a18 <commands+0x340>
ffffffffc02005f4:	ab7ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02005f8:	786c                	ld	a1,240(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	43650513          	addi	a0,a0,1078 # ffffffffc0201a30 <commands+0x358>
ffffffffc0200602:	aa9ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200606:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200608:	6402                	ld	s0,0(sp)
ffffffffc020060a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020060c:	00001517          	auipc	a0,0x1
ffffffffc0200610:	43c50513          	addi	a0,a0,1084 # ffffffffc0201a48 <commands+0x370>
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
ffffffffc0200624:	44050513          	addi	a0,a0,1088 # ffffffffc0201a60 <commands+0x388>
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
ffffffffc020063c:	44050513          	addi	a0,a0,1088 # ffffffffc0201a78 <commands+0x3a0>
ffffffffc0200640:	a6bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200644:	10843583          	ld	a1,264(s0)
ffffffffc0200648:	00001517          	auipc	a0,0x1
ffffffffc020064c:	44850513          	addi	a0,a0,1096 # ffffffffc0201a90 <commands+0x3b8>
ffffffffc0200650:	a5bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200654:	11043583          	ld	a1,272(s0)
ffffffffc0200658:	00001517          	auipc	a0,0x1
ffffffffc020065c:	45050513          	addi	a0,a0,1104 # ffffffffc0201aa8 <commands+0x3d0>
ffffffffc0200660:	a4bff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200664:	11843583          	ld	a1,280(s0)
}
ffffffffc0200668:	6402                	ld	s0,0(sp)
ffffffffc020066a:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020066c:	00001517          	auipc	a0,0x1
ffffffffc0200670:	45450513          	addi	a0,a0,1108 # ffffffffc0201ac0 <commands+0x3e8>
}
ffffffffc0200674:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200676:	bc15                	j	ffffffffc02000aa <cprintf>

ffffffffc0200678 <buddy_nr_free_pages>:

    cprintf("Freed %lu pages at index %lu with size %lu.\n", n, index, size);
}
static size_t buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200678:	00006517          	auipc	a0,0x6
ffffffffc020067c:	9a856503          	lwu	a0,-1624(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc0200680:	8082                	ret

ffffffffc0200682 <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200682:	00006797          	auipc	a5,0x6
ffffffffc0200686:	98e78793          	addi	a5,a5,-1650 # ffffffffc0206010 <free_area>
    cprintf("Buddy system initialized.\n");
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	44e50513          	addi	a0,a0,1102 # ffffffffc0201ad8 <commands+0x400>
ffffffffc0200692:	e79c                	sd	a5,8(a5)
ffffffffc0200694:	e39c                	sd	a5,0(a5)
    nr_free = 0;
ffffffffc0200696:	0007a823          	sw	zero,16(a5)
    cprintf("Buddy system initialized.\n");
ffffffffc020069a:	bc01                	j	ffffffffc02000aa <cprintf>

ffffffffc020069c <build_buddy_tree.isra.0>:
static void build_buddy_tree(size_t root, size_t full_tree_size, size_t real_tree_size,
ffffffffc020069c:	7139                	addi	sp,sp,-64
ffffffffc020069e:	e852                	sd	s4,16(sp)
    if (stop_build) {
ffffffffc02006a0:	00006a17          	auipc	s4,0x6
ffffffffc02006a4:	da8a0a13          	addi	s4,s4,-600 # ffffffffc0206448 <stop_build>
ffffffffc02006a8:	000a2783          	lw	a5,0(s4)
static void build_buddy_tree(size_t root, size_t full_tree_size, size_t real_tree_size,
ffffffffc02006ac:	fc06                	sd	ra,56(sp)
ffffffffc02006ae:	f822                	sd	s0,48(sp)
ffffffffc02006b0:	f426                	sd	s1,40(sp)
ffffffffc02006b2:	f04a                	sd	s2,32(sp)
ffffffffc02006b4:	ec4e                	sd	s3,24(sp)
    if (stop_build) {
ffffffffc02006b6:	cb89                	beqz	a5,ffffffffc02006c8 <build_buddy_tree.isra.0+0x2c>
}
ffffffffc02006b8:	70e2                	ld	ra,56(sp)
ffffffffc02006ba:	7442                	ld	s0,48(sp)
ffffffffc02006bc:	74a2                	ld	s1,40(sp)
ffffffffc02006be:	7902                	ld	s2,32(sp)
ffffffffc02006c0:	69e2                	ld	s3,24(sp)
ffffffffc02006c2:	6a42                	ld	s4,16(sp)
ffffffffc02006c4:	6121                	addi	sp,sp,64
ffffffffc02006c6:	8082                	ret
ffffffffc02006c8:	842e                	mv	s0,a1
ffffffffc02006ca:	89aa                	mv	s3,a0
ffffffffc02006cc:	8932                	mv	s2,a2
ffffffffc02006ce:	84b6                	mv	s1,a3
    cprintf("[DEBUG] Building buddy tree: root = %lu, full_tree_size = %lu, real_tree_size = %lu\n",
ffffffffc02006d0:	86b2                	mv	a3,a2
ffffffffc02006d2:	862e                	mv	a2,a1
ffffffffc02006d4:	85aa                	mv	a1,a0
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	42250513          	addi	a0,a0,1058 # ffffffffc0201af8 <commands+0x420>
ffffffffc02006de:	9cdff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    if (full_tree_size == 0 || real_tree_size == 0) {
ffffffffc02006e2:	cc31                	beqz	s0,ffffffffc020073e <build_buddy_tree.isra.0+0xa2>
ffffffffc02006e4:	04090d63          	beqz	s2,ffffffffc020073e <build_buddy_tree.isra.0+0xa2>
        build_buddy_tree(root * 2 + 1, left_size, real_tree_size, allocate_area, record_area);
ffffffffc02006e8:	00199a13          	slli	s4,s3,0x1
    size_t left_size = full_tree_size / 2;
ffffffffc02006ec:	00145593          	srli	a1,s0,0x1
        build_buddy_tree(root * 2 + 1, left_size, real_tree_size, allocate_area, record_area);
ffffffffc02006f0:	001a0513          	addi	a0,s4,1
ffffffffc02006f4:	86a6                	mv	a3,s1
    if (real_tree_size <= left_size) {
ffffffffc02006f6:	0725f663          	bgeu	a1,s2,ffffffffc0200762 <build_buddy_tree.isra.0+0xc6>
        build_buddy_tree(root * 2 + 1, left_size, left_size, allocate_area, record_area);
ffffffffc02006fa:	862e                	mv	a2,a1
ffffffffc02006fc:	e42e                	sd	a1,8(sp)
ffffffffc02006fe:	f9fff0ef          	jal	ra,ffffffffc020069c <build_buddy_tree.isra.0>
                         allocate_area + left_size, record_area + left_size);
ffffffffc0200702:	65a2                	ld	a1,8(sp)
        build_buddy_tree(root * 2 + 2, right_size, real_tree_size - left_size,
ffffffffc0200704:	002a0513          	addi	a0,s4,2
                         allocate_area + left_size, record_area + left_size);
ffffffffc0200708:	00259693          	slli	a3,a1,0x2
ffffffffc020070c:	96ae                	add	a3,a3,a1
ffffffffc020070e:	068e                	slli	a3,a3,0x3
        build_buddy_tree(root * 2 + 2, right_size, real_tree_size - left_size,
ffffffffc0200710:	96a6                	add	a3,a3,s1
ffffffffc0200712:	40b90633          	sub	a2,s2,a1
ffffffffc0200716:	f87ff0ef          	jal	ra,ffffffffc020069c <build_buddy_tree.isra.0>
    record_area[root].property = full_tree_size;
ffffffffc020071a:	00299693          	slli	a3,s3,0x2
ffffffffc020071e:	96ce                	add	a3,a3,s3
ffffffffc0200720:	068e                	slli	a3,a3,0x3
ffffffffc0200722:	96a6                	add	a3,a3,s1
ffffffffc0200724:	ca80                	sw	s0,16(a3)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200726:	4789                	li	a5,2
ffffffffc0200728:	00868713          	addi	a4,a3,8
ffffffffc020072c:	40f7302f          	amoor.d	zero,a5,(a4)
    cprintf("[DEBUG] Set property for root %lu, full_tree_size = %lu\n",
ffffffffc0200730:	00001517          	auipc	a0,0x1
ffffffffc0200734:	48050513          	addi	a0,a0,1152 # ffffffffc0201bb0 <commands+0x4d8>
ffffffffc0200738:	8622                	mv	a2,s0
ffffffffc020073a:	85ce                	mv	a1,s3
ffffffffc020073c:	a811                	j	ffffffffc0200750 <build_buddy_tree.isra.0+0xb4>
        stop_build = 1;
ffffffffc020073e:	4785                	li	a5,1
        cprintf("[DEBUG] Reached a leaf node with full_tree_size = %lu, real_tree_size = %lu, returning.\n",
ffffffffc0200740:	864a                	mv	a2,s2
ffffffffc0200742:	85a2                	mv	a1,s0
ffffffffc0200744:	00001517          	auipc	a0,0x1
ffffffffc0200748:	40c50513          	addi	a0,a0,1036 # ffffffffc0201b50 <commands+0x478>
        stop_build = 1;
ffffffffc020074c:	00fa2023          	sw	a5,0(s4)
}
ffffffffc0200750:	7442                	ld	s0,48(sp)
ffffffffc0200752:	70e2                	ld	ra,56(sp)
ffffffffc0200754:	74a2                	ld	s1,40(sp)
ffffffffc0200756:	7902                	ld	s2,32(sp)
ffffffffc0200758:	69e2                	ld	s3,24(sp)
ffffffffc020075a:	6a42                	ld	s4,16(sp)
ffffffffc020075c:	6121                	addi	sp,sp,64
    cprintf("[DEBUG] Set property for root %lu, full_tree_size = %lu\n",
ffffffffc020075e:	94dff06f          	j	ffffffffc02000aa <cprintf>
        build_buddy_tree(root * 2 + 1, left_size, real_tree_size, allocate_area, record_area);
ffffffffc0200762:	864a                	mv	a2,s2
ffffffffc0200764:	f39ff0ef          	jal	ra,ffffffffc020069c <build_buddy_tree.isra.0>
ffffffffc0200768:	bf4d                	j	ffffffffc020071a <build_buddy_tree.isra.0+0x7e>

ffffffffc020076a <buddy_check>:


// 伙伴系统的检查函数
static void buddy_check(void) {
ffffffffc020076a:	1141                	addi	sp,sp,-16
    size_t calculated_free_pages = 0;

    cprintf("Checking buddy system...\n");
ffffffffc020076c:	00001517          	auipc	a0,0x1
ffffffffc0200770:	48450513          	addi	a0,a0,1156 # ffffffffc0201bf0 <commands+0x518>
static void buddy_check(void) {
ffffffffc0200774:	e406                	sd	ra,8(sp)
    cprintf("Checking buddy system...\n");
ffffffffc0200776:	935ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020077a:	00006597          	auipc	a1,0x6
ffffffffc020077e:	89658593          	addi	a1,a1,-1898 # ffffffffc0206010 <free_area>
ffffffffc0200782:	659c                	ld	a5,8(a1)
    size_t calculated_free_pages = 0;
ffffffffc0200784:	4681                	li	a3,0

    // 1. 检查空闲列表中的块状态
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
ffffffffc0200786:	00b78c63          	beq	a5,a1,ffffffffc020079e <buddy_check+0x34>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020078a:	ff07b703          	ld	a4,-16(a5)
        struct Page *page = le2page(le, page_link);
        size_t order = page->property;
ffffffffc020078e:	ff87e603          	lwu	a2,-8(a5)

        // 检查空闲块的大小是否为 2 的幂次
        // assert(order > 0 && (order & (order - 1)) == 0);

        // 检查页面是否在空闲列表中
        assert(PageProperty(page));
ffffffffc0200792:	8b09                	andi	a4,a4,2
ffffffffc0200794:	c31d                	beqz	a4,ffffffffc02007ba <buddy_check+0x50>
ffffffffc0200796:	679c                	ld	a5,8(a5)

        // 更新计算的空闲页数
        calculated_free_pages += order;
ffffffffc0200798:	96b2                	add	a3,a3,a2
    while (le != &free_list) {
ffffffffc020079a:	feb798e3          	bne	a5,a1,ffffffffc020078a <buddy_check+0x20>
            assert(record_area[i].property <= NODE_LENGTH(i));
        }
    }

    // 3. 验证 nr_free 的正确性
    if (calculated_free_pages != nr_free) {
ffffffffc020079e:	498c                	lw	a1,16(a1)
ffffffffc02007a0:	02059793          	slli	a5,a1,0x20
ffffffffc02007a4:	9381                	srli	a5,a5,0x20
ffffffffc02007a6:	02d79a63          	bne	a5,a3,ffffffffc02007da <buddy_check+0x70>
               calculated_free_pages, nr_free);
        assert(0);
    }

    cprintf("Buddy system check passed. Total free pages: %lu.\n", nr_free);
}
ffffffffc02007aa:	60a2                	ld	ra,8(sp)
    cprintf("Buddy system check passed. Total free pages: %lu.\n", nr_free);
ffffffffc02007ac:	00001517          	auipc	a0,0x1
ffffffffc02007b0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0201c98 <commands+0x5c0>
}
ffffffffc02007b4:	0141                	addi	sp,sp,16
    cprintf("Buddy system check passed. Total free pages: %lu.\n", nr_free);
ffffffffc02007b6:	8f5ff06f          	j	ffffffffc02000aa <cprintf>
        assert(PageProperty(page));
ffffffffc02007ba:	00001697          	auipc	a3,0x1
ffffffffc02007be:	45668693          	addi	a3,a3,1110 # ffffffffc0201c10 <commands+0x538>
ffffffffc02007c2:	00001617          	auipc	a2,0x1
ffffffffc02007c6:	46660613          	addi	a2,a2,1126 # ffffffffc0201c28 <commands+0x550>
ffffffffc02007ca:	12900593          	li	a1,297
ffffffffc02007ce:	00001517          	auipc	a0,0x1
ffffffffc02007d2:	47250513          	addi	a0,a0,1138 # ffffffffc0201c40 <commands+0x568>
ffffffffc02007d6:	bcfff0ef          	jal	ra,ffffffffc02003a4 <__panic>
        cprintf("Error: Calculated free pages %lu does not match nr_free %lu.\n",
ffffffffc02007da:	862e                	mv	a2,a1
ffffffffc02007dc:	00001517          	auipc	a0,0x1
ffffffffc02007e0:	47450513          	addi	a0,a0,1140 # ffffffffc0201c50 <commands+0x578>
ffffffffc02007e4:	85b6                	mv	a1,a3
ffffffffc02007e6:	8c5ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
        assert(0);
ffffffffc02007ea:	00001697          	auipc	a3,0x1
ffffffffc02007ee:	4a668693          	addi	a3,a3,1190 # ffffffffc0201c90 <commands+0x5b8>
ffffffffc02007f2:	00001617          	auipc	a2,0x1
ffffffffc02007f6:	43660613          	addi	a2,a2,1078 # ffffffffc0201c28 <commands+0x550>
ffffffffc02007fa:	14e00593          	li	a1,334
ffffffffc02007fe:	00001517          	auipc	a0,0x1
ffffffffc0200802:	44250513          	addi	a0,a0,1090 # ffffffffc0201c40 <commands+0x568>
ffffffffc0200806:	b9fff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc020080a <buddy_allocate_pages>:
    assert(n > 0);
ffffffffc020080a:	16050063          	beqz	a0,ffffffffc020096a <buddy_allocate_pages+0x160>
    return 1 << (32 - clz(n - 1));
ffffffffc020080e:	fff50693          	addi	a3,a0,-1

extern const struct pmm_manager buddy_pmm_manager;

static size_t clz(size_t x) {
    size_t count = 0;
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc0200812:	14068463          	beqz	a3,ffffffffc020095a <buddy_allocate_pages+0x150>
    for (size_t i = sizeof(x) * 8 - 1; i >= 0; --i) {
        if (x & ((size_t)1 << i)) break;
ffffffffc0200816:	03f6d713          	srli	a4,a3,0x3f
ffffffffc020081a:	1406c063          	bltz	a3,ffffffffc020095a <buddy_allocate_pages+0x150>
ffffffffc020081e:	03f00593          	li	a1,63
        count++;
ffffffffc0200822:	0705                	addi	a4,a4,1
        if (x & ((size_t)1 << i)) break;
ffffffffc0200824:	40e587bb          	subw	a5,a1,a4
ffffffffc0200828:	00f6d7b3          	srl	a5,a3,a5
ffffffffc020082c:	8b85                	andi	a5,a5,1
ffffffffc020082e:	0007061b          	sext.w	a2,a4
ffffffffc0200832:	dbe5                	beqz	a5,ffffffffc0200822 <buddy_allocate_pages+0x18>
    while (length <= record_area[block].property) {
ffffffffc0200834:	00006817          	auipc	a6,0x6
ffffffffc0200838:	c0c83803          	ld	a6,-1012(a6) # ffffffffc0206440 <record_area>
    return 1 << (32 - clz(n - 1));
ffffffffc020083c:	02000313          	li	t1,32
    while (length <= record_area[block].property) {
ffffffffc0200840:	01086583          	lwu	a1,16(a6)
    return 1 << (32 - clz(n - 1));
ffffffffc0200844:	40c3063b          	subw	a2,t1,a2
ffffffffc0200848:	4305                	li	t1,1
ffffffffc020084a:	00c3133b          	sllw	t1,t1,a2
    while (length <= record_area[block].property) {
ffffffffc020084e:	0a65e163          	bltu	a1,t1,ffffffffc02008f0 <buddy_allocate_pages+0xe6>
ffffffffc0200852:	00005297          	auipc	t0,0x5
ffffffffc0200856:	7be28293          	addi	t0,t0,1982 # ffffffffc0206010 <free_area>
ffffffffc020085a:	0082be83          	ld	t4,8(t0)
    return 1 << (32 - clz(n - 1));
ffffffffc020085e:	8e42                	mv	t3,a6
ffffffffc0200860:	4f81                	li	t6,0
ffffffffc0200862:	4681                	li	a3,0
ffffffffc0200864:	4f01                	li	t5,0
        size_t left = block * 2 + 1;   // 左子节点
ffffffffc0200866:	00169893          	slli	a7,a3,0x1
ffffffffc020086a:	00188613          	addi	a2,a7,1
        size_t right = block * 2 + 2;  // 右子节点
ffffffffc020086e:	00168513          	addi	a0,a3,1
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc0200872:	ca91                	beqz	a3,ffffffffc0200886 <buddy_allocate_pages+0x7c>
        if (x & ((size_t)1 << i)) break;
ffffffffc0200874:	0006c963          	bltz	a3,ffffffffc0200886 <buddy_allocate_pages+0x7c>
    for (size_t i = sizeof(x) * 8 - 1; i >= 0; --i) {
ffffffffc0200878:	03f00713          	li	a4,63
ffffffffc020087c:	177d                	addi	a4,a4,-1
        if (x & ((size_t)1 << i)) break;
ffffffffc020087e:	00e6d7b3          	srl	a5,a3,a4
ffffffffc0200882:	8b85                	andi	a5,a5,1
ffffffffc0200884:	dfe5                	beqz	a5,ffffffffc020087c <buddy_allocate_pages+0x72>
            record_area[left].property = half_size;
ffffffffc0200886:	00261793          	slli	a5,a2,0x2
ffffffffc020088a:	97b2                	add	a5,a5,a2
ffffffffc020088c:	078e                	slli	a5,a5,0x3
ffffffffc020088e:	00f80733          	add	a4,a6,a5
        if (BUDDY_EMPTY(block)) {
ffffffffc0200892:	e99d                	bnez	a1,ffffffffc02008c8 <buddy_allocate_pages+0xbe>
            record_area[right].property = half_size;
ffffffffc0200894:	00251593          	slli	a1,a0,0x2
ffffffffc0200898:	95aa                	add	a1,a1,a0
ffffffffc020089a:	0592                	slli	a1,a1,0x4
            record_area[left].property = half_size;
ffffffffc020089c:	00072823          	sw	zero,16(a4)
            record_area[right].property = half_size;
ffffffffc02008a0:	95c2                	add	a1,a1,a6
ffffffffc02008a2:	0005a823          	sw	zero,16(a1)
            list_add(&free_list, &record_area[left].page_link);
ffffffffc02008a6:	01870f93          	addi	t6,a4,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02008aa:	01feb023          	sd	t6,0(t4)
    elm->next = next;
ffffffffc02008ae:	03d73023          	sd	t4,32(a4)
            list_add(&free_list, &record_area[right].page_link);
ffffffffc02008b2:	01858e93          	addi	t4,a1,24
    prev->next = next->prev = elm;
ffffffffc02008b6:	01d73c23          	sd	t4,24(a4)
    elm->next = next;
ffffffffc02008ba:	03f5b023          	sd	t6,32(a1)
    elm->prev = prev;
ffffffffc02008be:	0055bc23          	sd	t0,24(a1)
            record_area[block].property = 0; // 原块被分裂后不再空闲
ffffffffc02008c2:	000e2823          	sw	zero,16(t3)
ffffffffc02008c6:	4f85                	li	t6,1
        if (length <= record_area[left].property) {
ffffffffc02008c8:	01076583          	lwu	a1,16(a4)
ffffffffc02008cc:	0065fe63          	bgeu	a1,t1,ffffffffc02008e8 <buddy_allocate_pages+0xde>
        } else if (length <= record_area[right].property) {
ffffffffc02008d0:	00251793          	slli	a5,a0,0x2
ffffffffc02008d4:	97aa                	add	a5,a5,a0
ffffffffc02008d6:	0792                	slli	a5,a5,0x4
ffffffffc02008d8:	00f80733          	add	a4,a6,a5
ffffffffc02008dc:	01076583          	lwu	a1,16(a4)
ffffffffc02008e0:	0065ea63          	bltu	a1,t1,ffffffffc02008f4 <buddy_allocate_pages+0xea>
        size_t right = block * 2 + 2;  // 右子节点
ffffffffc02008e4:	00288613          	addi	a2,a7,2
    return 1 << (32 - clz(n - 1));
ffffffffc02008e8:	86b2                	mv	a3,a2
ffffffffc02008ea:	8e3a                	mv	t3,a4
ffffffffc02008ec:	8f3e                	mv	t5,a5
ffffffffc02008ee:	bfa5                	j	ffffffffc0200866 <buddy_allocate_pages+0x5c>
        return NULL;
ffffffffc02008f0:	4501                	li	a0,0
ffffffffc02008f2:	8082                	ret
ffffffffc02008f4:	000f8463          	beqz	t6,ffffffffc02008fc <buddy_allocate_pages+0xf2>
ffffffffc02008f8:	01d2b423          	sd	t4,8(t0)
    if (record_area[block].property < length) {
ffffffffc02008fc:	010e6783          	lwu	a5,16(t3)
ffffffffc0200900:	fe67e8e3          	bltu	a5,t1,ffffffffc02008f0 <buddy_allocate_pages+0xe6>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200904:	020e3703          	ld	a4,32(t3)
ffffffffc0200908:	018e3603          	ld	a2,24(t3)
    nr_free -= length;                         // 更新全局空闲页数
ffffffffc020090c:	0102a783          	lw	a5,16(t0)
    struct Page *page = allocate_area + block; // 根据块索引计算页面起始地址
ffffffffc0200910:	00006517          	auipc	a0,0x6
ffffffffc0200914:	b2853503          	ld	a0,-1240(a0) # ffffffffc0206438 <allocate_area>
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200918:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020091a:	e310                	sd	a2,0(a4)
    record_area[block].property = 0;           // 标记该块为已使用
ffffffffc020091c:	000e2823          	sw	zero,16(t3)
    nr_free -= length;                         // 更新全局空闲页数
ffffffffc0200920:	4067833b          	subw	t1,a5,t1
    size_t parent_block = (block - 1) / 2;
ffffffffc0200924:	fff68713          	addi	a4,a3,-1
    nr_free -= length;                         // 更新全局空闲页数
ffffffffc0200928:	0062a823          	sw	t1,16(t0)
    struct Page *page = allocate_area + block; // 根据块索引计算页面起始地址
ffffffffc020092c:	957a                	add	a0,a0,t5
    size_t parent_block = (block - 1) / 2;
ffffffffc020092e:	8305                	srli	a4,a4,0x1
    while (block != TREE_ROOT) {
ffffffffc0200930:	c685                	beqz	a3,ffffffffc0200958 <buddy_allocate_pages+0x14e>
            record_area[parent_block * 2 + 1].property |
ffffffffc0200932:	00271793          	slli	a5,a4,0x2
ffffffffc0200936:	97ba                	add	a5,a5,a4
ffffffffc0200938:	00479693          	slli	a3,a5,0x4
ffffffffc020093c:	96c2                	add	a3,a3,a6
ffffffffc020093e:	5e90                	lw	a2,56(a3)
ffffffffc0200940:	52b4                	lw	a3,96(a3)
        record_area[parent_block].property = 
ffffffffc0200942:	078e                	slli	a5,a5,0x3
ffffffffc0200944:	97c2                	add	a5,a5,a6
            record_area[parent_block * 2 + 1].property |
ffffffffc0200946:	8ed1                	or	a3,a3,a2
        parent_block = (block - 1) / 2;
ffffffffc0200948:	fff70593          	addi	a1,a4,-1
ffffffffc020094c:	863a                	mv	a2,a4
        record_area[parent_block].property = 
ffffffffc020094e:	cb94                	sw	a3,16(a5)
        parent_block = (block - 1) / 2;
ffffffffc0200950:	0015d713          	srli	a4,a1,0x1
    while (block != TREE_ROOT) {
ffffffffc0200954:	fe79                	bnez	a2,ffffffffc0200932 <buddy_allocate_pages+0x128>
ffffffffc0200956:	8082                	ret
}
ffffffffc0200958:	8082                	ret
    while (length <= record_area[block].property) {
ffffffffc020095a:	00006817          	auipc	a6,0x6
ffffffffc020095e:	ae683803          	ld	a6,-1306(a6) # ffffffffc0206440 <record_area>
ffffffffc0200962:	01086583          	lwu	a1,16(a6)
    return 1 << (32 - clz(n - 1));
ffffffffc0200966:	4305                	li	t1,1
ffffffffc0200968:	b5ed                	j	ffffffffc0200852 <buddy_allocate_pages+0x48>
static struct Page *buddy_allocate_pages(size_t n) {
ffffffffc020096a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020096c:	00001697          	auipc	a3,0x1
ffffffffc0200970:	36468693          	addi	a3,a3,868 # ffffffffc0201cd0 <commands+0x5f8>
ffffffffc0200974:	00001617          	auipc	a2,0x1
ffffffffc0200978:	2b460613          	addi	a2,a2,692 # ffffffffc0201c28 <commands+0x550>
ffffffffc020097c:	0a200593          	li	a1,162
ffffffffc0200980:	00001517          	auipc	a0,0x1
ffffffffc0200984:	2c050513          	addi	a0,a0,704 # ffffffffc0201c40 <commands+0x568>
static struct Page *buddy_allocate_pages(size_t n) {
ffffffffc0200988:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020098a:	a1bff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc020098e <buddy_free_pages>:
static void buddy_free_pages(struct Page *base, size_t n) {
ffffffffc020098e:	1141                	addi	sp,sp,-16
ffffffffc0200990:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200992:	1a058e63          	beqz	a1,ffffffffc0200b4e <buddy_free_pages+0x1c0>
    size_t index = (base - allocate_area); // 根据 base 地址计算伙伴树中的索引
ffffffffc0200996:	00006617          	auipc	a2,0x6
ffffffffc020099a:	aa263603          	ld	a2,-1374(a2) # ffffffffc0206438 <allocate_area>
ffffffffc020099e:	40c50633          	sub	a2,a0,a2
ffffffffc02009a2:	860d                	srai	a2,a2,0x3
ffffffffc02009a4:	00002797          	auipc	a5,0x2
ffffffffc02009a8:	a047b783          	ld	a5,-1532(a5) # ffffffffc02023a8 <error_string+0x38>
    return 1 << (32 - clz(n - 1));
ffffffffc02009ac:	fff58693          	addi	a3,a1,-1
    size_t index = (base - allocate_area); // 根据 base 地址计算伙伴树中的索引
ffffffffc02009b0:	02f60633          	mul	a2,a2,a5
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc02009b4:	c69d                	beqz	a3,ffffffffc02009e2 <buddy_free_pages+0x54>
        if (x & ((size_t)1 << i)) break;
ffffffffc02009b6:	03f6d713          	srli	a4,a3,0x3f
ffffffffc02009ba:	1606c163          	bltz	a3,ffffffffc0200b1c <buddy_free_pages+0x18e>
ffffffffc02009be:	03f00893          	li	a7,63
        count++;
ffffffffc02009c2:	0705                	addi	a4,a4,1
        if (x & ((size_t)1 << i)) break;
ffffffffc02009c4:	40e887bb          	subw	a5,a7,a4
ffffffffc02009c8:	00f6d7b3          	srl	a5,a3,a5
ffffffffc02009cc:	8b85                	andi	a5,a5,1
ffffffffc02009ce:	0007081b          	sext.w	a6,a4
ffffffffc02009d2:	dbe5                	beqz	a5,ffffffffc02009c2 <buddy_free_pages+0x34>
    return 1 << (32 - clz(n - 1));
ffffffffc02009d4:	02000693          	li	a3,32
ffffffffc02009d8:	4106883b          	subw	a6,a3,a6
ffffffffc02009dc:	4685                	li	a3,1
ffffffffc02009de:	010696bb          	sllw	a3,a3,a6
    size_t block = index + size - 1;       // 找到对应的叶子节点位置
ffffffffc02009e2:	fff60813          	addi	a6,a2,-1
ffffffffc02009e6:	9836                	add	a6,a6,a3
    while (block > 0 && !BUDDY_EMPTY(block)) {
ffffffffc02009e8:	02080e63          	beqz	a6,ffffffffc0200a24 <buddy_free_pages+0x96>
ffffffffc02009ec:	00006317          	auipc	t1,0x6
ffffffffc02009f0:	a5433303          	ld	t1,-1452(t1) # ffffffffc0206440 <record_area>
ffffffffc02009f4:	00281893          	slli	a7,a6,0x2
ffffffffc02009f8:	98c2                	add	a7,a7,a6
ffffffffc02009fa:	088e                	slli	a7,a7,0x3
ffffffffc02009fc:	989a                	add	a7,a7,t1
ffffffffc02009fe:	0108ae03          	lw	t3,16(a7)
ffffffffc0200a02:	00084963          	bltz	a6,ffffffffc0200a14 <buddy_free_pages+0x86>
    for (size_t i = sizeof(x) * 8 - 1; i >= 0; --i) {
ffffffffc0200a06:	03f00713          	li	a4,63
ffffffffc0200a0a:	177d                	addi	a4,a4,-1
        if (x & ((size_t)1 << i)) break;
ffffffffc0200a0c:	00e857b3          	srl	a5,a6,a4
ffffffffc0200a10:	8b85                	andi	a5,a5,1
ffffffffc0200a12:	dfe5                	beqz	a5,ffffffffc0200a0a <buddy_free_pages+0x7c>
ffffffffc0200a14:	0e0e0a63          	beqz	t3,ffffffffc0200b08 <buddy_free_pages+0x17a>
        block = (block - 1) / 2;  // 计算父节点索引
ffffffffc0200a18:	187d                	addi	a6,a6,-1
ffffffffc0200a1a:	00185813          	srli	a6,a6,0x1
        size <<= 1;               // 每次上移，块的大小加倍
ffffffffc0200a1e:	0686                	slli	a3,a3,0x1
    while (block > 0 && !BUDDY_EMPTY(block)) {
ffffffffc0200a20:	fc081ae3          	bnez	a6,ffffffffc02009f4 <buddy_free_pages+0x66>
    for (p = base; p != base + n; ++p) {
ffffffffc0200a24:	00259713          	slli	a4,a1,0x2
ffffffffc0200a28:	972e                	add	a4,a4,a1
ffffffffc0200a2a:	070e                	slli	a4,a4,0x3
ffffffffc0200a2c:	972a                	add	a4,a4,a0
ffffffffc0200a2e:	4801                	li	a6,0
ffffffffc0200a30:	0ee50863          	beq	a0,a4,ffffffffc0200b20 <buddy_free_pages+0x192>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a34:	4889                	li	a7,2
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a36:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200a38:	8b85                	andi	a5,a5,1
ffffffffc0200a3a:	ebf5                	bnez	a5,ffffffffc0200b2e <buddy_free_pages+0x1a0>
ffffffffc0200a3c:	651c                	ld	a5,8(a0)
ffffffffc0200a3e:	8b89                	andi	a5,a5,2
ffffffffc0200a40:	e7fd                	bnez	a5,ffffffffc0200b2e <buddy_free_pages+0x1a0>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a42:	00850793          	addi	a5,a0,8
ffffffffc0200a46:	4117b02f          	amoor.d	zero,a7,(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a4a:	00052023          	sw	zero,0(a0)
    for (p = base; p != base + n; ++p) {
ffffffffc0200a4e:	02850513          	addi	a0,a0,40
ffffffffc0200a52:	fea712e3          	bne	a4,a0,ffffffffc0200a36 <buddy_free_pages+0xa8>
    record_area[block].property = size;    // 标记当前节点为可用的块大小
ffffffffc0200a56:	00281793          	slli	a5,a6,0x2
ffffffffc0200a5a:	97c2                	add	a5,a5,a6
ffffffffc0200a5c:	00006317          	auipc	t1,0x6
ffffffffc0200a60:	9e433303          	ld	t1,-1564(t1) # ffffffffc0206440 <record_area>
ffffffffc0200a64:	078e                	slli	a5,a5,0x3
ffffffffc0200a66:	979a                	add	a5,a5,t1
ffffffffc0200a68:	cb94                	sw	a3,16(a5)
    while (block > 0) {
ffffffffc0200a6a:	00081e63          	bnez	a6,ffffffffc0200a86 <buddy_free_pages+0xf8>
ffffffffc0200a6e:	a08d                	j	ffffffffc0200ad0 <buddy_free_pages+0x142>
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200a70:	02089713          	slli	a4,a7,0x20
ffffffffc0200a74:	9301                	srli	a4,a4,0x20
ffffffffc0200a76:	04d71363          	bne	a4,a3,ffffffffc0200abc <buddy_free_pages+0x12e>
            record_area[parent].property = size * 2;
ffffffffc0200a7a:	0016971b          	slliw	a4,a3,0x1
ffffffffc0200a7e:	cb98                	sw	a4,16(a5)
            size <<= 1;
ffffffffc0200a80:	0686                	slli	a3,a3,0x1
    while (block > 0) {
ffffffffc0200a82:	04080763          	beqz	a6,ffffffffc0200ad0 <buddy_free_pages+0x142>
        size_t parent = (block - 1) / 2;
ffffffffc0200a86:	fff80713          	addi	a4,a6,-1
        size_t left = parent * 2 + 1;
ffffffffc0200a8a:	00176513          	ori	a0,a4,1
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200a8e:	00251793          	slli	a5,a0,0x2
ffffffffc0200a92:	97aa                	add	a5,a5,a0
ffffffffc0200a94:	078e                	slli	a5,a5,0x3
ffffffffc0200a96:	979a                	add	a5,a5,t1
ffffffffc0200a98:	4b88                	lw	a0,16(a5)
ffffffffc0200a9a:	8ec2                	mv	t4,a6
        size_t parent = (block - 1) / 2;
ffffffffc0200a9c:	00175813          	srli	a6,a4,0x1
            record_area[parent].property = size * 2;
ffffffffc0200aa0:	00281713          	slli	a4,a6,0x2
ffffffffc0200aa4:	9742                	add	a4,a4,a6
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200aa6:	02051e13          	slli	t3,a0,0x20
            record_area[parent].property = size * 2;
ffffffffc0200aaa:	070e                	slli	a4,a4,0x3
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200aac:	020e5e13          	srli	t3,t3,0x20
ffffffffc0200ab0:	0387a883          	lw	a7,56(a5)
            record_area[parent].property = size * 2;
ffffffffc0200ab4:	00e307b3          	add	a5,t1,a4
        if (record_area[left].property == size && record_area[right].property == size) {
ffffffffc0200ab8:	fade0ce3          	beq	t3,a3,ffffffffc0200a70 <buddy_free_pages+0xe2>
            record_area[parent].property = max(record_area[left].property, record_area[right].property);
ffffffffc0200abc:	882a                	mv	a6,a0
ffffffffc0200abe:	05156363          	bltu	a0,a7,ffffffffc0200b04 <buddy_free_pages+0x176>
    list_add(&free_list, &record_area[block].page_link);
ffffffffc0200ac2:	002e9713          	slli	a4,t4,0x2
ffffffffc0200ac6:	9776                	add	a4,a4,t4
ffffffffc0200ac8:	070e                	slli	a4,a4,0x3
            record_area[parent].property = max(record_area[left].property, record_area[right].property);
ffffffffc0200aca:	0107a823          	sw	a6,16(a5)
    list_add(&free_list, &record_area[block].page_link);
ffffffffc0200ace:	933a                	add	t1,t1,a4
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ad0:	00005797          	auipc	a5,0x5
ffffffffc0200ad4:	54078793          	addi	a5,a5,1344 # ffffffffc0206010 <free_area>
ffffffffc0200ad8:	6788                	ld	a0,8(a5)
    nr_free += n;
ffffffffc0200ada:	4b98                	lw	a4,16(a5)
    list_add(&free_list, &record_area[block].page_link);
ffffffffc0200adc:	01830813          	addi	a6,t1,24
    prev->next = next->prev = elm;
ffffffffc0200ae0:	01053023          	sd	a6,0(a0)
}
ffffffffc0200ae4:	60a2                	ld	ra,8(sp)
    nr_free += n;
ffffffffc0200ae6:	9f2d                	addw	a4,a4,a1
    elm->next = next;
ffffffffc0200ae8:	02a33023          	sd	a0,32(t1)
    elm->prev = prev;
ffffffffc0200aec:	00f33c23          	sd	a5,24(t1)
    prev->next = next->prev = elm;
ffffffffc0200af0:	0107b423          	sd	a6,8(a5)
ffffffffc0200af4:	cb98                	sw	a4,16(a5)
    cprintf("Freed %lu pages at index %lu with size %lu.\n", n, index, size);
ffffffffc0200af6:	00001517          	auipc	a0,0x1
ffffffffc0200afa:	20a50513          	addi	a0,a0,522 # ffffffffc0201d00 <commands+0x628>
}
ffffffffc0200afe:	0141                	addi	sp,sp,16
    cprintf("Freed %lu pages at index %lu with size %lu.\n", n, index, size);
ffffffffc0200b00:	daaff06f          	j	ffffffffc02000aa <cprintf>
            record_area[parent].property = max(record_area[left].property, record_area[right].property);
ffffffffc0200b04:	8846                	mv	a6,a7
ffffffffc0200b06:	bf75                	j	ffffffffc0200ac2 <buddy_free_pages+0x134>
    for (p = base; p != base + n; ++p) {
ffffffffc0200b08:	00259713          	slli	a4,a1,0x2
ffffffffc0200b0c:	972e                	add	a4,a4,a1
ffffffffc0200b0e:	070e                	slli	a4,a4,0x3
ffffffffc0200b10:	972a                	add	a4,a4,a0
ffffffffc0200b12:	f2a711e3          	bne	a4,a0,ffffffffc0200a34 <buddy_free_pages+0xa6>
    record_area[block].property = size;    // 标记当前节点为可用的块大小
ffffffffc0200b16:	00d8a823          	sw	a3,16(a7)
    while (block > 0) {
ffffffffc0200b1a:	b7b5                	j	ffffffffc0200a86 <buddy_free_pages+0xf8>
ffffffffc0200b1c:	4681                	li	a3,0
ffffffffc0200b1e:	b5d1                	j	ffffffffc02009e2 <buddy_free_pages+0x54>
    record_area[block].property = size;    // 标记当前节点为可用的块大小
ffffffffc0200b20:	00006317          	auipc	t1,0x6
ffffffffc0200b24:	92033303          	ld	t1,-1760(t1) # ffffffffc0206440 <record_area>
ffffffffc0200b28:	00d32823          	sw	a3,16(t1)
    while (block > 0) {
ffffffffc0200b2c:	b755                	j	ffffffffc0200ad0 <buddy_free_pages+0x142>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200b2e:	00001697          	auipc	a3,0x1
ffffffffc0200b32:	1aa68693          	addi	a3,a3,426 # ffffffffc0201cd8 <commands+0x600>
ffffffffc0200b36:	00001617          	auipc	a2,0x1
ffffffffc0200b3a:	0f260613          	addi	a2,a2,242 # ffffffffc0201c28 <commands+0x550>
ffffffffc0200b3e:	0f600593          	li	a1,246
ffffffffc0200b42:	00001517          	auipc	a0,0x1
ffffffffc0200b46:	0fe50513          	addi	a0,a0,254 # ffffffffc0201c40 <commands+0x568>
ffffffffc0200b4a:	85bff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(n > 0);
ffffffffc0200b4e:	00001697          	auipc	a3,0x1
ffffffffc0200b52:	18268693          	addi	a3,a3,386 # ffffffffc0201cd0 <commands+0x5f8>
ffffffffc0200b56:	00001617          	auipc	a2,0x1
ffffffffc0200b5a:	0d260613          	addi	a2,a2,210 # ffffffffc0201c28 <commands+0x550>
ffffffffc0200b5e:	0e500593          	li	a1,229
ffffffffc0200b62:	00001517          	auipc	a0,0x1
ffffffffc0200b66:	0de50513          	addi	a0,a0,222 # ffffffffc0201c40 <commands+0x568>
ffffffffc0200b6a:	83bff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc0200b6e <buddy_init_memmap>:
static void buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200b6e:	7139                	addi	sp,sp,-64
ffffffffc0200b70:	fc06                	sd	ra,56(sp)
ffffffffc0200b72:	f822                	sd	s0,48(sp)
ffffffffc0200b74:	f426                	sd	s1,40(sp)
ffffffffc0200b76:	f04a                	sd	s2,32(sp)
ffffffffc0200b78:	ec4e                	sd	s3,24(sp)
ffffffffc0200b7a:	e852                	sd	s4,16(sp)
ffffffffc0200b7c:	e456                	sd	s5,8(sp)
ffffffffc0200b7e:	e05a                	sd	s6,0(sp)
    assert(n > 0);
ffffffffc0200b80:	1e058a63          	beqz	a1,ffffffffc0200d74 <buddy_init_memmap+0x206>
ffffffffc0200b84:	89aa                	mv	s3,a0
    cprintf("[DEBUG] buddy_init_memmap: Initializing %lu pages starting at %p\n", n, base);
ffffffffc0200b86:	862a                	mv	a2,a0
ffffffffc0200b88:	00001517          	auipc	a0,0x1
ffffffffc0200b8c:	1a850513          	addi	a0,a0,424 # ffffffffc0201d30 <commands+0x658>
ffffffffc0200b90:	842e                	mv	s0,a1
ffffffffc0200b92:	d18ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    for (size_t i = 0; i < n; i++) {
ffffffffc0200b96:	4a01                	li	s4,0
    cprintf("[DEBUG] buddy_init_memmap: Initializing %lu pages starting at %p\n", n, base);
ffffffffc0200b98:	874e                	mv	a4,s3
ffffffffc0200b9a:	a011                	j	ffffffffc0200b9e <buddy_init_memmap+0x30>
ffffffffc0200b9c:	8a26                	mv	s4,s1
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b9e:	671c                	ld	a5,8(a4)
        assert(PageReserved(page));
ffffffffc0200ba0:	8b85                	andi	a5,a5,1
ffffffffc0200ba2:	1a078963          	beqz	a5,ffffffffc0200d54 <buddy_init_memmap+0x1e6>
    for (size_t i = 0; i < n; i++) {
ffffffffc0200ba6:	001a0493          	addi	s1,s4,1
ffffffffc0200baa:	02870713          	addi	a4,a4,40
ffffffffc0200bae:	fe9417e3          	bne	s0,s1,ffffffffc0200b9c <buddy_init_memmap+0x2e>
    cprintf("[DEBUG] All pages are reserved, starting property initialization.\n");
ffffffffc0200bb2:	00001517          	auipc	a0,0x1
ffffffffc0200bb6:	1de50513          	addi	a0,a0,478 # ffffffffc0201d90 <commands+0x6b8>
ffffffffc0200bba:	cf0ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    for (size_t i = 0; i < n; i++) {
ffffffffc0200bbe:	00249713          	slli	a4,s1,0x2
ffffffffc0200bc2:	9726                	add	a4,a4,s1
ffffffffc0200bc4:	00898793          	addi	a5,s3,8
ffffffffc0200bc8:	070e                	slli	a4,a4,0x3
ffffffffc0200bca:	973e                	add	a4,a4,a5
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200bcc:	4689                	li	a3,2
        page->flags = 0;
ffffffffc0200bce:	0007b023          	sd	zero,0(a5)
        page->property = 0;
ffffffffc0200bd2:	0007a423          	sw	zero,8(a5)
        page->ref = 0;
ffffffffc0200bd6:	fe07ac23          	sw	zero,-8(a5)
ffffffffc0200bda:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200bde:	02878793          	addi	a5,a5,40
ffffffffc0200be2:	fef716e3          	bne	a4,a5,ffffffffc0200bce <buddy_init_memmap+0x60>
    cprintf("[DEBUG] All pages initialized with flags, property, and ref set to zero.\n");
ffffffffc0200be6:	00001517          	auipc	a0,0x1
ffffffffc0200bea:	1f250513          	addi	a0,a0,498 # ffffffffc0201dd8 <commands+0x700>
ffffffffc0200bee:	cbcff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    if (n < 512) {
ffffffffc0200bf2:	1ff00793          	li	a5,511
ffffffffc0200bf6:	1297e663          	bltu	a5,s1,ffffffffc0200d22 <buddy_init_memmap+0x1b4>
    if (x == 0) return sizeof(x) * 8; // 如果是0，返回位数
ffffffffc0200bfa:	140a0163          	beqz	s4,ffffffffc0200d3c <buddy_init_memmap+0x1ce>
    size_t count = 0;
ffffffffc0200bfe:	4701                	li	a4,0
        if (x & ((size_t)1 << i)) break;
ffffffffc0200c00:	03f00613          	li	a2,63
        count++;
ffffffffc0200c04:	0705                	addi	a4,a4,1
        if (x & ((size_t)1 << i)) break;
ffffffffc0200c06:	40e607bb          	subw	a5,a2,a4
ffffffffc0200c0a:	00fa57b3          	srl	a5,s4,a5
ffffffffc0200c0e:	8b85                	andi	a5,a5,1
ffffffffc0200c10:	0007069b          	sext.w	a3,a4
ffffffffc0200c14:	dbe5                	beqz	a5,ffffffffc0200c04 <buddy_init_memmap+0x96>
        full_tree_size = 1 << (32 - clz(n));
ffffffffc0200c16:	02000b13          	li	s6,32
ffffffffc0200c1a:	40db06bb          	subw	a3,s6,a3
ffffffffc0200c1e:	4b05                	li	s6,1
ffffffffc0200c20:	00db1b3b          	sllw	s6,s6,a3
    size_t record_area_size = (full_tree_size * sizeof(struct Page)) / PGSIZE + 1;
ffffffffc0200c24:	002b1693          	slli	a3,s6,0x2
ffffffffc0200c28:	96da                	add	a3,a3,s6
ffffffffc0200c2a:	068e                	slli	a3,a3,0x3
ffffffffc0200c2c:	82b1                	srli	a3,a3,0xc
ffffffffc0200c2e:	00168613          	addi	a2,a3,1
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200c32:	00161913          	slli	s2,a2,0x1
    size_t real_tree_size = n - record_area_size;
ffffffffc0200c36:	40da0433          	sub	s0,s4,a3
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200c3a:	995a                	add	s2,s2,s6
    cprintf("[DEBUG] Calculated full_tree_size: %lu, record_area_size: %lu, real_tree_size: %lu\n",
ffffffffc0200c3c:	86a2                	mv	a3,s0
ffffffffc0200c3e:	85da                	mv	a1,s6
ffffffffc0200c40:	00001517          	auipc	a0,0x1
ffffffffc0200c44:	1e850513          	addi	a0,a0,488 # ffffffffc0201e28 <commands+0x750>
ffffffffc0200c48:	c62ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200c4c:	02997a63          	bgeu	s2,s1,ffffffffc0200c80 <buddy_init_memmap+0x112>
        cprintf("[DEBUG] Adjusting tree size, new full_tree_size: %lu, record_area_size: %lu, real_tree_size: %lu\n",
ffffffffc0200c50:	00001a97          	auipc	s5,0x1
ffffffffc0200c54:	230a8a93          	addi	s5,s5,560 # ffffffffc0201e80 <commands+0x7a8>
        full_tree_size <<= 1; // 扩展树的大小，向上翻倍
ffffffffc0200c58:	0b06                	slli	s6,s6,0x1
        record_area_size = (full_tree_size * sizeof(struct Page)) / PGSIZE + 1;
ffffffffc0200c5a:	002b1693          	slli	a3,s6,0x2
ffffffffc0200c5e:	96da                	add	a3,a3,s6
ffffffffc0200c60:	068e                	slli	a3,a3,0x3
ffffffffc0200c62:	82b1                	srli	a3,a3,0xc
ffffffffc0200c64:	00168913          	addi	s2,a3,1
        cprintf("[DEBUG] Adjusting tree size, new full_tree_size: %lu, record_area_size: %lu, real_tree_size: %lu\n",
ffffffffc0200c68:	864a                	mv	a2,s2
        real_tree_size = n - record_area_size;
ffffffffc0200c6a:	40da0433          	sub	s0,s4,a3
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200c6e:	0906                	slli	s2,s2,0x1
        cprintf("[DEBUG] Adjusting tree size, new full_tree_size: %lu, record_area_size: %lu, real_tree_size: %lu\n",
ffffffffc0200c70:	86a2                	mv	a3,s0
ffffffffc0200c72:	85da                	mv	a1,s6
ffffffffc0200c74:	8556                	mv	a0,s5
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200c76:	995a                	add	s2,s2,s6
        cprintf("[DEBUG] Adjusting tree size, new full_tree_size: %lu, record_area_size: %lu, real_tree_size: %lu\n",
ffffffffc0200c78:	c32ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    while (n > full_tree_size + (record_area_size << 1)) {
ffffffffc0200c7c:	fc996ee3          	bltu	s2,s1,ffffffffc0200c58 <buddy_init_memmap+0xea>
    record_area = base + real_tree_size;
ffffffffc0200c80:	00241613          	slli	a2,s0,0x2
ffffffffc0200c84:	9622                	add	a2,a2,s0
ffffffffc0200c86:	060e                	slli	a2,a2,0x3
ffffffffc0200c88:	964e                	add	a2,a2,s3
ffffffffc0200c8a:	00005917          	auipc	s2,0x5
ffffffffc0200c8e:	7b690913          	addi	s2,s2,1974 # ffffffffc0206440 <record_area>
    cprintf("[DEBUG] physical_area: %p, record_area: %p, allocate_area: %p\n",
ffffffffc0200c92:	86ce                	mv	a3,s3
ffffffffc0200c94:	85ce                	mv	a1,s3
ffffffffc0200c96:	00001517          	auipc	a0,0x1
ffffffffc0200c9a:	25250513          	addi	a0,a0,594 # ffffffffc0201ee8 <commands+0x810>
    record_area = base + real_tree_size;
ffffffffc0200c9e:	00c93023          	sd	a2,0(s2)
    allocate_area = physical_area;
ffffffffc0200ca2:	00005797          	auipc	a5,0x5
ffffffffc0200ca6:	7937bb23          	sd	s3,1942(a5) # ffffffffc0206438 <allocate_area>
    cprintf("[DEBUG] physical_area: %p, record_area: %p, allocate_area: %p\n",
ffffffffc0200caa:	c00ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    build_buddy_tree(TREE_ROOT, full_tree_size, real_tree_size, allocate_area, record_area);
ffffffffc0200cae:	00093683          	ld	a3,0(s2)
ffffffffc0200cb2:	8622                	mv	a2,s0
ffffffffc0200cb4:	85da                	mv	a1,s6
ffffffffc0200cb6:	4501                	li	a0,0
ffffffffc0200cb8:	9e5ff0ef          	jal	ra,ffffffffc020069c <build_buddy_tree.isra.0>
    cprintf("[DEBUG] Buddy tree initialized.\n");
ffffffffc0200cbc:	00001517          	auipc	a0,0x1
ffffffffc0200cc0:	26c50513          	addi	a0,a0,620 # ffffffffc0201f28 <commands+0x850>
ffffffffc0200cc4:	be6ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200cc8:	00005797          	auipc	a5,0x5
ffffffffc0200ccc:	34878793          	addi	a5,a5,840 # ffffffffc0206010 <free_area>
ffffffffc0200cd0:	6790                	ld	a2,8(a5)
    nr_free += real_tree_size;
ffffffffc0200cd2:	4b98                	lw	a4,16(a5)
    base->property = real_tree_size;
ffffffffc0200cd4:	0004059b          	sext.w	a1,s0
ffffffffc0200cd8:	00b9a823          	sw	a1,16(s3)
    list_add(&free_list, &(base->page_link));
ffffffffc0200cdc:	01898693          	addi	a3,s3,24
    prev->next = next->prev = elm;
ffffffffc0200ce0:	e214                	sd	a3,0(a2)
    nr_free += real_tree_size;
ffffffffc0200ce2:	9f2d                	addw	a4,a4,a1
    elm->next = next;
ffffffffc0200ce4:	02c9b023          	sd	a2,32(s3)
    cprintf("[DEBUG] Added initial block to free_list, real_tree_size: %lu, nr_free: %lu\n",
ffffffffc0200ce8:	85a2                	mv	a1,s0
    elm->prev = prev;
ffffffffc0200cea:	00f9bc23          	sd	a5,24(s3)
ffffffffc0200cee:	0007061b          	sext.w	a2,a4
ffffffffc0200cf2:	00001517          	auipc	a0,0x1
ffffffffc0200cf6:	25e50513          	addi	a0,a0,606 # ffffffffc0201f50 <commands+0x878>
    prev->next = next->prev = elm;
ffffffffc0200cfa:	e794                	sd	a3,8(a5)
    nr_free += real_tree_size;
ffffffffc0200cfc:	cb98                	sw	a4,16(a5)
    cprintf("[DEBUG] Added initial block to free_list, real_tree_size: %lu, nr_free: %lu\n",
ffffffffc0200cfe:	bacff0ef          	jal	ra,ffffffffc02000aa <cprintf>
}
ffffffffc0200d02:	7442                	ld	s0,48(sp)
ffffffffc0200d04:	70e2                	ld	ra,56(sp)
ffffffffc0200d06:	7902                	ld	s2,32(sp)
ffffffffc0200d08:	69e2                	ld	s3,24(sp)
ffffffffc0200d0a:	6a42                	ld	s4,16(sp)
ffffffffc0200d0c:	6aa2                	ld	s5,8(sp)
ffffffffc0200d0e:	6b02                	ld	s6,0(sp)
    cprintf("[DEBUG] buddy_init_memmap: Finished initialization for %lu pages.\n", n);
ffffffffc0200d10:	85a6                	mv	a1,s1
}
ffffffffc0200d12:	74a2                	ld	s1,40(sp)
    cprintf("[DEBUG] buddy_init_memmap: Finished initialization for %lu pages.\n", n);
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	28c50513          	addi	a0,a0,652 # ffffffffc0201fa0 <commands+0x8c8>
}
ffffffffc0200d1c:	6121                	addi	sp,sp,64
    cprintf("[DEBUG] buddy_init_memmap: Finished initialization for %lu pages.\n", n);
ffffffffc0200d1e:	b8cff06f          	j	ffffffffc02000aa <cprintf>
    size_t count = 0;
ffffffffc0200d22:	4701                	li	a4,0
        if (x & ((size_t)1 << i)) break;
ffffffffc0200d24:	03f00613          	li	a2,63
        count++;
ffffffffc0200d28:	0705                	addi	a4,a4,1
        if (x & ((size_t)1 << i)) break;
ffffffffc0200d2a:	40e607bb          	subw	a5,a2,a4
ffffffffc0200d2e:	00f4d7b3          	srl	a5,s1,a5
ffffffffc0200d32:	8b85                	andi	a5,a5,1
ffffffffc0200d34:	0007069b          	sext.w	a3,a4
ffffffffc0200d38:	dbe5                	beqz	a5,ffffffffc0200d28 <buddy_init_memmap+0x1ba>
ffffffffc0200d3a:	bdf1                	j	ffffffffc0200c16 <buddy_init_memmap+0xa8>
    cprintf("[DEBUG] Calculated full_tree_size: %lu, record_area_size: %lu, real_tree_size: %lu\n",
ffffffffc0200d3c:	4681                	li	a3,0
ffffffffc0200d3e:	4605                	li	a2,1
ffffffffc0200d40:	4581                	li	a1,0
ffffffffc0200d42:	00001517          	auipc	a0,0x1
ffffffffc0200d46:	0e650513          	addi	a0,a0,230 # ffffffffc0201e28 <commands+0x750>
ffffffffc0200d4a:	b60ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
ffffffffc0200d4e:	4401                	li	s0,0
ffffffffc0200d50:	4b01                	li	s6,0
ffffffffc0200d52:	b73d                	j	ffffffffc0200c80 <buddy_init_memmap+0x112>
        assert(PageReserved(page));
ffffffffc0200d54:	00001697          	auipc	a3,0x1
ffffffffc0200d58:	02468693          	addi	a3,a3,36 # ffffffffc0201d78 <commands+0x6a0>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	ecc60613          	addi	a2,a2,-308 # ffffffffc0201c28 <commands+0x550>
ffffffffc0200d64:	06500593          	li	a1,101
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	ed850513          	addi	a0,a0,-296 # ffffffffc0201c40 <commands+0x568>
ffffffffc0200d70:	e34ff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    assert(n > 0);
ffffffffc0200d74:	00001697          	auipc	a3,0x1
ffffffffc0200d78:	f5c68693          	addi	a3,a3,-164 # ffffffffc0201cd0 <commands+0x5f8>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	eac60613          	addi	a2,a2,-340 # ffffffffc0201c28 <commands+0x550>
ffffffffc0200d84:	05f00593          	li	a1,95
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	eb850513          	addi	a0,a0,-328 # ffffffffc0201c40 <commands+0x568>
ffffffffc0200d90:	e14ff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc0200d94 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200d94:	00001797          	auipc	a5,0x1
ffffffffc0200d98:	26c78793          	addi	a5,a5,620 # ffffffffc0202000 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d9c:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200d9e:	1101                	addi	sp,sp,-32
ffffffffc0200da0:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200da2:	00001517          	auipc	a0,0x1
ffffffffc0200da6:	29650513          	addi	a0,a0,662 # ffffffffc0202038 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200daa:	00005497          	auipc	s1,0x5
ffffffffc0200dae:	6b648493          	addi	s1,s1,1718 # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc0200db2:	ec06                	sd	ra,24(sp)
ffffffffc0200db4:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200db6:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200db8:	af2ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    pmm_manager->init();
ffffffffc0200dbc:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dbe:	00005417          	auipc	s0,0x5
ffffffffc0200dc2:	6ba40413          	addi	s0,s0,1722 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200dc6:	679c                	ld	a5,8(a5)
ffffffffc0200dc8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dca:	57f5                	li	a5,-3
ffffffffc0200dcc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200dce:	00001517          	auipc	a0,0x1
ffffffffc0200dd2:	28250513          	addi	a0,a0,642 # ffffffffc0202050 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dd6:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200dd8:	ad2ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200ddc:	46c5                	li	a3,17
ffffffffc0200dde:	06ee                	slli	a3,a3,0x1b
ffffffffc0200de0:	40100613          	li	a2,1025
ffffffffc0200de4:	16fd                	addi	a3,a3,-1
ffffffffc0200de6:	07e005b7          	lui	a1,0x7e00
ffffffffc0200dea:	0656                	slli	a2,a2,0x15
ffffffffc0200dec:	00001517          	auipc	a0,0x1
ffffffffc0200df0:	27c50513          	addi	a0,a0,636 # ffffffffc0202068 <buddy_pmm_manager+0x68>
ffffffffc0200df4:	ab6ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200df8:	777d                	lui	a4,0xfffff
ffffffffc0200dfa:	00006797          	auipc	a5,0x6
ffffffffc0200dfe:	68d78793          	addi	a5,a5,1677 # ffffffffc0207487 <end+0xfff>
ffffffffc0200e02:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200e04:	00005517          	auipc	a0,0x5
ffffffffc0200e08:	64c50513          	addi	a0,a0,1612 # ffffffffc0206450 <npage>
ffffffffc0200e0c:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e10:	00005597          	auipc	a1,0x5
ffffffffc0200e14:	64858593          	addi	a1,a1,1608 # ffffffffc0206458 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200e18:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e1a:	e19c                	sd	a5,0(a1)
ffffffffc0200e1c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e1e:	4701                	li	a4,0
ffffffffc0200e20:	4885                	li	a7,1
ffffffffc0200e22:	fff80837          	lui	a6,0xfff80
ffffffffc0200e26:	a011                	j	ffffffffc0200e2a <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200e28:	619c                	ld	a5,0(a1)
ffffffffc0200e2a:	97b6                	add	a5,a5,a3
ffffffffc0200e2c:	07a1                	addi	a5,a5,8
ffffffffc0200e2e:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e32:	611c                	ld	a5,0(a0)
ffffffffc0200e34:	0705                	addi	a4,a4,1
ffffffffc0200e36:	02868693          	addi	a3,a3,40
ffffffffc0200e3a:	01078633          	add	a2,a5,a6
ffffffffc0200e3e:	fec765e3          	bltu	a4,a2,ffffffffc0200e28 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e42:	6190                	ld	a2,0(a1)
ffffffffc0200e44:	00279713          	slli	a4,a5,0x2
ffffffffc0200e48:	973e                	add	a4,a4,a5
ffffffffc0200e4a:	fec006b7          	lui	a3,0xfec00
ffffffffc0200e4e:	070e                	slli	a4,a4,0x3
ffffffffc0200e50:	96b2                	add	a3,a3,a2
ffffffffc0200e52:	96ba                	add	a3,a3,a4
ffffffffc0200e54:	c0200737          	lui	a4,0xc0200
ffffffffc0200e58:	08e6ef63          	bltu	a3,a4,ffffffffc0200ef6 <pmm_init+0x162>
ffffffffc0200e5c:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200e5e:	45c5                	li	a1,17
ffffffffc0200e60:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e62:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200e64:	04b6e863          	bltu	a3,a1,ffffffffc0200eb4 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200e68:	609c                	ld	a5,0(s1)
ffffffffc0200e6a:	7b9c                	ld	a5,48(a5)
ffffffffc0200e6c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200e6e:	00001517          	auipc	a0,0x1
ffffffffc0200e72:	29250513          	addi	a0,a0,658 # ffffffffc0202100 <buddy_pmm_manager+0x100>
ffffffffc0200e76:	a34ff0ef          	jal	ra,ffffffffc02000aa <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200e7a:	00004597          	auipc	a1,0x4
ffffffffc0200e7e:	18658593          	addi	a1,a1,390 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200e82:	00005797          	auipc	a5,0x5
ffffffffc0200e86:	5eb7b723          	sd	a1,1518(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e8a:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e8e:	08f5e063          	bltu	a1,a5,ffffffffc0200f0e <pmm_init+0x17a>
ffffffffc0200e92:	6010                	ld	a2,0(s0)
}
ffffffffc0200e94:	6442                	ld	s0,16(sp)
ffffffffc0200e96:	60e2                	ld	ra,24(sp)
ffffffffc0200e98:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e9a:	40c58633          	sub	a2,a1,a2
ffffffffc0200e9e:	00005797          	auipc	a5,0x5
ffffffffc0200ea2:	5cc7b523          	sd	a2,1482(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ea6:	00001517          	auipc	a0,0x1
ffffffffc0200eaa:	27a50513          	addi	a0,a0,634 # ffffffffc0202120 <buddy_pmm_manager+0x120>
}
ffffffffc0200eae:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200eb0:	9faff06f          	j	ffffffffc02000aa <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200eb4:	6705                	lui	a4,0x1
ffffffffc0200eb6:	177d                	addi	a4,a4,-1
ffffffffc0200eb8:	96ba                	add	a3,a3,a4
ffffffffc0200eba:	777d                	lui	a4,0xfffff
ffffffffc0200ebc:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200ebe:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200ec2:	00f57e63          	bgeu	a0,a5,ffffffffc0200ede <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200ec6:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200ec8:	982a                	add	a6,a6,a0
ffffffffc0200eca:	00281513          	slli	a0,a6,0x2
ffffffffc0200ece:	9542                	add	a0,a0,a6
ffffffffc0200ed0:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200ed2:	8d95                	sub	a1,a1,a3
ffffffffc0200ed4:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200ed6:	81b1                	srli	a1,a1,0xc
ffffffffc0200ed8:	9532                	add	a0,a0,a2
ffffffffc0200eda:	9782                	jalr	a5
}
ffffffffc0200edc:	b771                	j	ffffffffc0200e68 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200ede:	00001617          	auipc	a2,0x1
ffffffffc0200ee2:	1f260613          	addi	a2,a2,498 # ffffffffc02020d0 <buddy_pmm_manager+0xd0>
ffffffffc0200ee6:	06b00593          	li	a1,107
ffffffffc0200eea:	00001517          	auipc	a0,0x1
ffffffffc0200eee:	20650513          	addi	a0,a0,518 # ffffffffc02020f0 <buddy_pmm_manager+0xf0>
ffffffffc0200ef2:	cb2ff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ef6:	00001617          	auipc	a2,0x1
ffffffffc0200efa:	1a260613          	addi	a2,a2,418 # ffffffffc0202098 <buddy_pmm_manager+0x98>
ffffffffc0200efe:	06f00593          	li	a1,111
ffffffffc0200f02:	00001517          	auipc	a0,0x1
ffffffffc0200f06:	1be50513          	addi	a0,a0,446 # ffffffffc02020c0 <buddy_pmm_manager+0xc0>
ffffffffc0200f0a:	c9aff0ef          	jal	ra,ffffffffc02003a4 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f0e:	86ae                	mv	a3,a1
ffffffffc0200f10:	00001617          	auipc	a2,0x1
ffffffffc0200f14:	18860613          	addi	a2,a2,392 # ffffffffc0202098 <buddy_pmm_manager+0x98>
ffffffffc0200f18:	08a00593          	li	a1,138
ffffffffc0200f1c:	00001517          	auipc	a0,0x1
ffffffffc0200f20:	1a450513          	addi	a0,a0,420 # ffffffffc02020c0 <buddy_pmm_manager+0xc0>
ffffffffc0200f24:	c80ff0ef          	jal	ra,ffffffffc02003a4 <__panic>

ffffffffc0200f28 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200f28:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f2c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200f2e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f32:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200f34:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200f38:	f022                	sd	s0,32(sp)
ffffffffc0200f3a:	ec26                	sd	s1,24(sp)
ffffffffc0200f3c:	e84a                	sd	s2,16(sp)
ffffffffc0200f3e:	f406                	sd	ra,40(sp)
ffffffffc0200f40:	e44e                	sd	s3,8(sp)
ffffffffc0200f42:	84aa                	mv	s1,a0
ffffffffc0200f44:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200f46:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200f4a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200f4c:	03067e63          	bgeu	a2,a6,ffffffffc0200f88 <printnum+0x60>
ffffffffc0200f50:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200f52:	00805763          	blez	s0,ffffffffc0200f60 <printnum+0x38>
ffffffffc0200f56:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200f58:	85ca                	mv	a1,s2
ffffffffc0200f5a:	854e                	mv	a0,s3
ffffffffc0200f5c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200f5e:	fc65                	bnez	s0,ffffffffc0200f56 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f60:	1a02                	slli	s4,s4,0x20
ffffffffc0200f62:	00001797          	auipc	a5,0x1
ffffffffc0200f66:	1fe78793          	addi	a5,a5,510 # ffffffffc0202160 <buddy_pmm_manager+0x160>
ffffffffc0200f6a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200f6e:	9a3e                	add	s4,s4,a5
}
ffffffffc0200f70:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f72:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200f76:	70a2                	ld	ra,40(sp)
ffffffffc0200f78:	69a2                	ld	s3,8(sp)
ffffffffc0200f7a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f7c:	85ca                	mv	a1,s2
ffffffffc0200f7e:	87a6                	mv	a5,s1
}
ffffffffc0200f80:	6942                	ld	s2,16(sp)
ffffffffc0200f82:	64e2                	ld	s1,24(sp)
ffffffffc0200f84:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f86:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200f88:	03065633          	divu	a2,a2,a6
ffffffffc0200f8c:	8722                	mv	a4,s0
ffffffffc0200f8e:	f9bff0ef          	jal	ra,ffffffffc0200f28 <printnum>
ffffffffc0200f92:	b7f9                	j	ffffffffc0200f60 <printnum+0x38>

ffffffffc0200f94 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200f94:	7119                	addi	sp,sp,-128
ffffffffc0200f96:	f4a6                	sd	s1,104(sp)
ffffffffc0200f98:	f0ca                	sd	s2,96(sp)
ffffffffc0200f9a:	ecce                	sd	s3,88(sp)
ffffffffc0200f9c:	e8d2                	sd	s4,80(sp)
ffffffffc0200f9e:	e4d6                	sd	s5,72(sp)
ffffffffc0200fa0:	e0da                	sd	s6,64(sp)
ffffffffc0200fa2:	fc5e                	sd	s7,56(sp)
ffffffffc0200fa4:	f06a                	sd	s10,32(sp)
ffffffffc0200fa6:	fc86                	sd	ra,120(sp)
ffffffffc0200fa8:	f8a2                	sd	s0,112(sp)
ffffffffc0200faa:	f862                	sd	s8,48(sp)
ffffffffc0200fac:	f466                	sd	s9,40(sp)
ffffffffc0200fae:	ec6e                	sd	s11,24(sp)
ffffffffc0200fb0:	892a                	mv	s2,a0
ffffffffc0200fb2:	84ae                	mv	s1,a1
ffffffffc0200fb4:	8d32                	mv	s10,a2
ffffffffc0200fb6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200fb8:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200fbc:	5b7d                	li	s6,-1
ffffffffc0200fbe:	00001a97          	auipc	s5,0x1
ffffffffc0200fc2:	1d6a8a93          	addi	s5,s5,470 # ffffffffc0202194 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200fc6:	00001b97          	auipc	s7,0x1
ffffffffc0200fca:	3aab8b93          	addi	s7,s7,938 # ffffffffc0202370 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200fce:	000d4503          	lbu	a0,0(s10)
ffffffffc0200fd2:	001d0413          	addi	s0,s10,1
ffffffffc0200fd6:	01350a63          	beq	a0,s3,ffffffffc0200fea <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0200fda:	c121                	beqz	a0,ffffffffc020101a <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0200fdc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200fde:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200fe0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200fe2:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200fe6:	ff351ae3          	bne	a0,s3,ffffffffc0200fda <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200fea:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200fee:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200ff2:	4c81                	li	s9,0
ffffffffc0200ff4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0200ff6:	5c7d                	li	s8,-1
ffffffffc0200ff8:	5dfd                	li	s11,-1
ffffffffc0200ffa:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0200ffe:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201000:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201004:	0ff5f593          	zext.b	a1,a1
ffffffffc0201008:	00140d13          	addi	s10,s0,1
ffffffffc020100c:	04b56263          	bltu	a0,a1,ffffffffc0201050 <vprintfmt+0xbc>
ffffffffc0201010:	058a                	slli	a1,a1,0x2
ffffffffc0201012:	95d6                	add	a1,a1,s5
ffffffffc0201014:	4194                	lw	a3,0(a1)
ffffffffc0201016:	96d6                	add	a3,a3,s5
ffffffffc0201018:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020101a:	70e6                	ld	ra,120(sp)
ffffffffc020101c:	7446                	ld	s0,112(sp)
ffffffffc020101e:	74a6                	ld	s1,104(sp)
ffffffffc0201020:	7906                	ld	s2,96(sp)
ffffffffc0201022:	69e6                	ld	s3,88(sp)
ffffffffc0201024:	6a46                	ld	s4,80(sp)
ffffffffc0201026:	6aa6                	ld	s5,72(sp)
ffffffffc0201028:	6b06                	ld	s6,64(sp)
ffffffffc020102a:	7be2                	ld	s7,56(sp)
ffffffffc020102c:	7c42                	ld	s8,48(sp)
ffffffffc020102e:	7ca2                	ld	s9,40(sp)
ffffffffc0201030:	7d02                	ld	s10,32(sp)
ffffffffc0201032:	6de2                	ld	s11,24(sp)
ffffffffc0201034:	6109                	addi	sp,sp,128
ffffffffc0201036:	8082                	ret
            padc = '0';
ffffffffc0201038:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020103a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020103e:	846a                	mv	s0,s10
ffffffffc0201040:	00140d13          	addi	s10,s0,1
ffffffffc0201044:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201048:	0ff5f593          	zext.b	a1,a1
ffffffffc020104c:	fcb572e3          	bgeu	a0,a1,ffffffffc0201010 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201050:	85a6                	mv	a1,s1
ffffffffc0201052:	02500513          	li	a0,37
ffffffffc0201056:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201058:	fff44783          	lbu	a5,-1(s0)
ffffffffc020105c:	8d22                	mv	s10,s0
ffffffffc020105e:	f73788e3          	beq	a5,s3,ffffffffc0200fce <vprintfmt+0x3a>
ffffffffc0201062:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201066:	1d7d                	addi	s10,s10,-1
ffffffffc0201068:	ff379de3          	bne	a5,s3,ffffffffc0201062 <vprintfmt+0xce>
ffffffffc020106c:	b78d                	j	ffffffffc0200fce <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020106e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0201072:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201076:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201078:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020107c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201080:	02d86463          	bltu	a6,a3,ffffffffc02010a8 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201084:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201088:	002c169b          	slliw	a3,s8,0x2
ffffffffc020108c:	0186873b          	addw	a4,a3,s8
ffffffffc0201090:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201094:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201096:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020109a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020109c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02010a0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02010a4:	fed870e3          	bgeu	a6,a3,ffffffffc0201084 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02010a8:	f40ddce3          	bgez	s11,ffffffffc0201000 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02010ac:	8de2                	mv	s11,s8
ffffffffc02010ae:	5c7d                	li	s8,-1
ffffffffc02010b0:	bf81                	j	ffffffffc0201000 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02010b2:	fffdc693          	not	a3,s11
ffffffffc02010b6:	96fd                	srai	a3,a3,0x3f
ffffffffc02010b8:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010bc:	00144603          	lbu	a2,1(s0)
ffffffffc02010c0:	2d81                	sext.w	s11,s11
ffffffffc02010c2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02010c4:	bf35                	j	ffffffffc0201000 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02010c6:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010ca:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02010ce:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02010d0:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02010d2:	bfd9                	j	ffffffffc02010a8 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02010d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02010d6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02010da:	01174463          	blt	a4,a7,ffffffffc02010e2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02010de:	1a088e63          	beqz	a7,ffffffffc020129a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02010e2:	000a3603          	ld	a2,0(s4)
ffffffffc02010e6:	46c1                	li	a3,16
ffffffffc02010e8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02010ea:	2781                	sext.w	a5,a5
ffffffffc02010ec:	876e                	mv	a4,s11
ffffffffc02010ee:	85a6                	mv	a1,s1
ffffffffc02010f0:	854a                	mv	a0,s2
ffffffffc02010f2:	e37ff0ef          	jal	ra,ffffffffc0200f28 <printnum>
            break;
ffffffffc02010f6:	bde1                	j	ffffffffc0200fce <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02010f8:	000a2503          	lw	a0,0(s4)
ffffffffc02010fc:	85a6                	mv	a1,s1
ffffffffc02010fe:	0a21                	addi	s4,s4,8
ffffffffc0201100:	9902                	jalr	s2
            break;
ffffffffc0201102:	b5f1                	j	ffffffffc0200fce <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201104:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201106:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020110a:	01174463          	blt	a4,a7,ffffffffc0201112 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020110e:	18088163          	beqz	a7,ffffffffc0201290 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201112:	000a3603          	ld	a2,0(s4)
ffffffffc0201116:	46a9                	li	a3,10
ffffffffc0201118:	8a2e                	mv	s4,a1
ffffffffc020111a:	bfc1                	j	ffffffffc02010ea <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020111c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201120:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201122:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201124:	bdf1                	j	ffffffffc0201000 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0201126:	85a6                	mv	a1,s1
ffffffffc0201128:	02500513          	li	a0,37
ffffffffc020112c:	9902                	jalr	s2
            break;
ffffffffc020112e:	b545                	j	ffffffffc0200fce <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201130:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201134:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201136:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201138:	b5e1                	j	ffffffffc0201000 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020113a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020113c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201140:	01174463          	blt	a4,a7,ffffffffc0201148 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201144:	14088163          	beqz	a7,ffffffffc0201286 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201148:	000a3603          	ld	a2,0(s4)
ffffffffc020114c:	46a1                	li	a3,8
ffffffffc020114e:	8a2e                	mv	s4,a1
ffffffffc0201150:	bf69                	j	ffffffffc02010ea <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201152:	03000513          	li	a0,48
ffffffffc0201156:	85a6                	mv	a1,s1
ffffffffc0201158:	e03e                	sd	a5,0(sp)
ffffffffc020115a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020115c:	85a6                	mv	a1,s1
ffffffffc020115e:	07800513          	li	a0,120
ffffffffc0201162:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201164:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201166:	6782                	ld	a5,0(sp)
ffffffffc0201168:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020116a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020116e:	bfb5                	j	ffffffffc02010ea <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201170:	000a3403          	ld	s0,0(s4)
ffffffffc0201174:	008a0713          	addi	a4,s4,8
ffffffffc0201178:	e03a                	sd	a4,0(sp)
ffffffffc020117a:	14040263          	beqz	s0,ffffffffc02012be <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020117e:	0fb05763          	blez	s11,ffffffffc020126c <vprintfmt+0x2d8>
ffffffffc0201182:	02d00693          	li	a3,45
ffffffffc0201186:	0cd79163          	bne	a5,a3,ffffffffc0201248 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020118a:	00044783          	lbu	a5,0(s0)
ffffffffc020118e:	0007851b          	sext.w	a0,a5
ffffffffc0201192:	cf85                	beqz	a5,ffffffffc02011ca <vprintfmt+0x236>
ffffffffc0201194:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201198:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020119c:	000c4563          	bltz	s8,ffffffffc02011a6 <vprintfmt+0x212>
ffffffffc02011a0:	3c7d                	addiw	s8,s8,-1
ffffffffc02011a2:	036c0263          	beq	s8,s6,ffffffffc02011c6 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02011a6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011a8:	0e0c8e63          	beqz	s9,ffffffffc02012a4 <vprintfmt+0x310>
ffffffffc02011ac:	3781                	addiw	a5,a5,-32
ffffffffc02011ae:	0ef47b63          	bgeu	s0,a5,ffffffffc02012a4 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02011b2:	03f00513          	li	a0,63
ffffffffc02011b6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02011b8:	000a4783          	lbu	a5,0(s4)
ffffffffc02011bc:	3dfd                	addiw	s11,s11,-1
ffffffffc02011be:	0a05                	addi	s4,s4,1
ffffffffc02011c0:	0007851b          	sext.w	a0,a5
ffffffffc02011c4:	ffe1                	bnez	a5,ffffffffc020119c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02011c6:	01b05963          	blez	s11,ffffffffc02011d8 <vprintfmt+0x244>
ffffffffc02011ca:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02011cc:	85a6                	mv	a1,s1
ffffffffc02011ce:	02000513          	li	a0,32
ffffffffc02011d2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02011d4:	fe0d9be3          	bnez	s11,ffffffffc02011ca <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02011d8:	6a02                	ld	s4,0(sp)
ffffffffc02011da:	bbd5                	j	ffffffffc0200fce <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02011dc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02011de:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02011e2:	01174463          	blt	a4,a7,ffffffffc02011ea <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02011e6:	08088d63          	beqz	a7,ffffffffc0201280 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02011ea:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02011ee:	0a044d63          	bltz	s0,ffffffffc02012a8 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02011f2:	8622                	mv	a2,s0
ffffffffc02011f4:	8a66                	mv	s4,s9
ffffffffc02011f6:	46a9                	li	a3,10
ffffffffc02011f8:	bdcd                	j	ffffffffc02010ea <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02011fa:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011fe:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201200:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201202:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201206:	8fb5                	xor	a5,a5,a3
ffffffffc0201208:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020120c:	02d74163          	blt	a4,a3,ffffffffc020122e <vprintfmt+0x29a>
ffffffffc0201210:	00369793          	slli	a5,a3,0x3
ffffffffc0201214:	97de                	add	a5,a5,s7
ffffffffc0201216:	639c                	ld	a5,0(a5)
ffffffffc0201218:	cb99                	beqz	a5,ffffffffc020122e <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020121a:	86be                	mv	a3,a5
ffffffffc020121c:	00001617          	auipc	a2,0x1
ffffffffc0201220:	f7460613          	addi	a2,a2,-140 # ffffffffc0202190 <buddy_pmm_manager+0x190>
ffffffffc0201224:	85a6                	mv	a1,s1
ffffffffc0201226:	854a                	mv	a0,s2
ffffffffc0201228:	0ce000ef          	jal	ra,ffffffffc02012f6 <printfmt>
ffffffffc020122c:	b34d                	j	ffffffffc0200fce <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020122e:	00001617          	auipc	a2,0x1
ffffffffc0201232:	f5260613          	addi	a2,a2,-174 # ffffffffc0202180 <buddy_pmm_manager+0x180>
ffffffffc0201236:	85a6                	mv	a1,s1
ffffffffc0201238:	854a                	mv	a0,s2
ffffffffc020123a:	0bc000ef          	jal	ra,ffffffffc02012f6 <printfmt>
ffffffffc020123e:	bb41                	j	ffffffffc0200fce <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201240:	00001417          	auipc	s0,0x1
ffffffffc0201244:	f3840413          	addi	s0,s0,-200 # ffffffffc0202178 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201248:	85e2                	mv	a1,s8
ffffffffc020124a:	8522                	mv	a0,s0
ffffffffc020124c:	e43e                	sd	a5,8(sp)
ffffffffc020124e:	1cc000ef          	jal	ra,ffffffffc020141a <strnlen>
ffffffffc0201252:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201256:	01b05b63          	blez	s11,ffffffffc020126c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020125a:	67a2                	ld	a5,8(sp)
ffffffffc020125c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201260:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201262:	85a6                	mv	a1,s1
ffffffffc0201264:	8552                	mv	a0,s4
ffffffffc0201266:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201268:	fe0d9ce3          	bnez	s11,ffffffffc0201260 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020126c:	00044783          	lbu	a5,0(s0)
ffffffffc0201270:	00140a13          	addi	s4,s0,1
ffffffffc0201274:	0007851b          	sext.w	a0,a5
ffffffffc0201278:	d3a5                	beqz	a5,ffffffffc02011d8 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020127a:	05e00413          	li	s0,94
ffffffffc020127e:	bf39                	j	ffffffffc020119c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201280:	000a2403          	lw	s0,0(s4)
ffffffffc0201284:	b7ad                	j	ffffffffc02011ee <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201286:	000a6603          	lwu	a2,0(s4)
ffffffffc020128a:	46a1                	li	a3,8
ffffffffc020128c:	8a2e                	mv	s4,a1
ffffffffc020128e:	bdb1                	j	ffffffffc02010ea <vprintfmt+0x156>
ffffffffc0201290:	000a6603          	lwu	a2,0(s4)
ffffffffc0201294:	46a9                	li	a3,10
ffffffffc0201296:	8a2e                	mv	s4,a1
ffffffffc0201298:	bd89                	j	ffffffffc02010ea <vprintfmt+0x156>
ffffffffc020129a:	000a6603          	lwu	a2,0(s4)
ffffffffc020129e:	46c1                	li	a3,16
ffffffffc02012a0:	8a2e                	mv	s4,a1
ffffffffc02012a2:	b5a1                	j	ffffffffc02010ea <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02012a4:	9902                	jalr	s2
ffffffffc02012a6:	bf09                	j	ffffffffc02011b8 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02012a8:	85a6                	mv	a1,s1
ffffffffc02012aa:	02d00513          	li	a0,45
ffffffffc02012ae:	e03e                	sd	a5,0(sp)
ffffffffc02012b0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02012b2:	6782                	ld	a5,0(sp)
ffffffffc02012b4:	8a66                	mv	s4,s9
ffffffffc02012b6:	40800633          	neg	a2,s0
ffffffffc02012ba:	46a9                	li	a3,10
ffffffffc02012bc:	b53d                	j	ffffffffc02010ea <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02012be:	03b05163          	blez	s11,ffffffffc02012e0 <vprintfmt+0x34c>
ffffffffc02012c2:	02d00693          	li	a3,45
ffffffffc02012c6:	f6d79de3          	bne	a5,a3,ffffffffc0201240 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02012ca:	00001417          	auipc	s0,0x1
ffffffffc02012ce:	eae40413          	addi	s0,s0,-338 # ffffffffc0202178 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012d2:	02800793          	li	a5,40
ffffffffc02012d6:	02800513          	li	a0,40
ffffffffc02012da:	00140a13          	addi	s4,s0,1
ffffffffc02012de:	bd6d                	j	ffffffffc0201198 <vprintfmt+0x204>
ffffffffc02012e0:	00001a17          	auipc	s4,0x1
ffffffffc02012e4:	e99a0a13          	addi	s4,s4,-359 # ffffffffc0202179 <buddy_pmm_manager+0x179>
ffffffffc02012e8:	02800513          	li	a0,40
ffffffffc02012ec:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02012f0:	05e00413          	li	s0,94
ffffffffc02012f4:	b565                	j	ffffffffc020119c <vprintfmt+0x208>

ffffffffc02012f6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02012f6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02012f8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02012fc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02012fe:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201300:	ec06                	sd	ra,24(sp)
ffffffffc0201302:	f83a                	sd	a4,48(sp)
ffffffffc0201304:	fc3e                	sd	a5,56(sp)
ffffffffc0201306:	e0c2                	sd	a6,64(sp)
ffffffffc0201308:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020130a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020130c:	c89ff0ef          	jal	ra,ffffffffc0200f94 <vprintfmt>
}
ffffffffc0201310:	60e2                	ld	ra,24(sp)
ffffffffc0201312:	6161                	addi	sp,sp,80
ffffffffc0201314:	8082                	ret

ffffffffc0201316 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201316:	715d                	addi	sp,sp,-80
ffffffffc0201318:	e486                	sd	ra,72(sp)
ffffffffc020131a:	e0a6                	sd	s1,64(sp)
ffffffffc020131c:	fc4a                	sd	s2,56(sp)
ffffffffc020131e:	f84e                	sd	s3,48(sp)
ffffffffc0201320:	f452                	sd	s4,40(sp)
ffffffffc0201322:	f056                	sd	s5,32(sp)
ffffffffc0201324:	ec5a                	sd	s6,24(sp)
ffffffffc0201326:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201328:	c901                	beqz	a0,ffffffffc0201338 <readline+0x22>
ffffffffc020132a:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020132c:	00001517          	auipc	a0,0x1
ffffffffc0201330:	e6450513          	addi	a0,a0,-412 # ffffffffc0202190 <buddy_pmm_manager+0x190>
ffffffffc0201334:	d77fe0ef          	jal	ra,ffffffffc02000aa <cprintf>
readline(const char *prompt) {
ffffffffc0201338:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020133a:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020133c:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020133e:	4aa9                	li	s5,10
ffffffffc0201340:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201342:	00005b97          	auipc	s7,0x5
ffffffffc0201346:	ce6b8b93          	addi	s7,s7,-794 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020134a:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020134e:	dd5fe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc0201352:	00054a63          	bltz	a0,ffffffffc0201366 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201356:	00a95a63          	bge	s2,a0,ffffffffc020136a <readline+0x54>
ffffffffc020135a:	029a5263          	bge	s4,s1,ffffffffc020137e <readline+0x68>
        c = getchar();
ffffffffc020135e:	dc5fe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc0201362:	fe055ae3          	bgez	a0,ffffffffc0201356 <readline+0x40>
            return NULL;
ffffffffc0201366:	4501                	li	a0,0
ffffffffc0201368:	a091                	j	ffffffffc02013ac <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020136a:	03351463          	bne	a0,s3,ffffffffc0201392 <readline+0x7c>
ffffffffc020136e:	e8a9                	bnez	s1,ffffffffc02013c0 <readline+0xaa>
        c = getchar();
ffffffffc0201370:	db3fe0ef          	jal	ra,ffffffffc0200122 <getchar>
        if (c < 0) {
ffffffffc0201374:	fe0549e3          	bltz	a0,ffffffffc0201366 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201378:	fea959e3          	bge	s2,a0,ffffffffc020136a <readline+0x54>
ffffffffc020137c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020137e:	e42a                	sd	a0,8(sp)
ffffffffc0201380:	d61fe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            buf[i ++] = c;
ffffffffc0201384:	6522                	ld	a0,8(sp)
ffffffffc0201386:	009b87b3          	add	a5,s7,s1
ffffffffc020138a:	2485                	addiw	s1,s1,1
ffffffffc020138c:	00a78023          	sb	a0,0(a5)
ffffffffc0201390:	bf7d                	j	ffffffffc020134e <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201392:	01550463          	beq	a0,s5,ffffffffc020139a <readline+0x84>
ffffffffc0201396:	fb651ce3          	bne	a0,s6,ffffffffc020134e <readline+0x38>
            cputchar(c);
ffffffffc020139a:	d47fe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            buf[i] = '\0';
ffffffffc020139e:	00005517          	auipc	a0,0x5
ffffffffc02013a2:	c8a50513          	addi	a0,a0,-886 # ffffffffc0206028 <buf>
ffffffffc02013a6:	94aa                	add	s1,s1,a0
ffffffffc02013a8:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02013ac:	60a6                	ld	ra,72(sp)
ffffffffc02013ae:	6486                	ld	s1,64(sp)
ffffffffc02013b0:	7962                	ld	s2,56(sp)
ffffffffc02013b2:	79c2                	ld	s3,48(sp)
ffffffffc02013b4:	7a22                	ld	s4,40(sp)
ffffffffc02013b6:	7a82                	ld	s5,32(sp)
ffffffffc02013b8:	6b62                	ld	s6,24(sp)
ffffffffc02013ba:	6bc2                	ld	s7,16(sp)
ffffffffc02013bc:	6161                	addi	sp,sp,80
ffffffffc02013be:	8082                	ret
            cputchar(c);
ffffffffc02013c0:	4521                	li	a0,8
ffffffffc02013c2:	d1ffe0ef          	jal	ra,ffffffffc02000e0 <cputchar>
            i --;
ffffffffc02013c6:	34fd                	addiw	s1,s1,-1
ffffffffc02013c8:	b759                	j	ffffffffc020134e <readline+0x38>

ffffffffc02013ca <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02013ca:	4781                	li	a5,0
ffffffffc02013cc:	00005717          	auipc	a4,0x5
ffffffffc02013d0:	c3c73703          	ld	a4,-964(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02013d4:	88ba                	mv	a7,a4
ffffffffc02013d6:	852a                	mv	a0,a0
ffffffffc02013d8:	85be                	mv	a1,a5
ffffffffc02013da:	863e                	mv	a2,a5
ffffffffc02013dc:	00000073          	ecall
ffffffffc02013e0:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02013e2:	8082                	ret

ffffffffc02013e4 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02013e4:	4781                	li	a5,0
ffffffffc02013e6:	00005717          	auipc	a4,0x5
ffffffffc02013ea:	09a73703          	ld	a4,154(a4) # ffffffffc0206480 <SBI_SET_TIMER>
ffffffffc02013ee:	88ba                	mv	a7,a4
ffffffffc02013f0:	852a                	mv	a0,a0
ffffffffc02013f2:	85be                	mv	a1,a5
ffffffffc02013f4:	863e                	mv	a2,a5
ffffffffc02013f6:	00000073          	ecall
ffffffffc02013fa:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02013fc:	8082                	ret

ffffffffc02013fe <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02013fe:	4501                	li	a0,0
ffffffffc0201400:	00005797          	auipc	a5,0x5
ffffffffc0201404:	c007b783          	ld	a5,-1024(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201408:	88be                	mv	a7,a5
ffffffffc020140a:	852a                	mv	a0,a0
ffffffffc020140c:	85aa                	mv	a1,a0
ffffffffc020140e:	862a                	mv	a2,a0
ffffffffc0201410:	00000073          	ecall
ffffffffc0201414:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201416:	2501                	sext.w	a0,a0
ffffffffc0201418:	8082                	ret

ffffffffc020141a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020141a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020141c:	e589                	bnez	a1,ffffffffc0201426 <strnlen+0xc>
ffffffffc020141e:	a811                	j	ffffffffc0201432 <strnlen+0x18>
        cnt ++;
ffffffffc0201420:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201422:	00f58863          	beq	a1,a5,ffffffffc0201432 <strnlen+0x18>
ffffffffc0201426:	00f50733          	add	a4,a0,a5
ffffffffc020142a:	00074703          	lbu	a4,0(a4)
ffffffffc020142e:	fb6d                	bnez	a4,ffffffffc0201420 <strnlen+0x6>
ffffffffc0201430:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201432:	852e                	mv	a0,a1
ffffffffc0201434:	8082                	ret

ffffffffc0201436 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201436:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020143a:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020143e:	cb89                	beqz	a5,ffffffffc0201450 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201440:	0505                	addi	a0,a0,1
ffffffffc0201442:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201444:	fee789e3          	beq	a5,a4,ffffffffc0201436 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201448:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020144c:	9d19                	subw	a0,a0,a4
ffffffffc020144e:	8082                	ret
ffffffffc0201450:	4501                	li	a0,0
ffffffffc0201452:	bfed                	j	ffffffffc020144c <strcmp+0x16>

ffffffffc0201454 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201454:	00054783          	lbu	a5,0(a0)
ffffffffc0201458:	c799                	beqz	a5,ffffffffc0201466 <strchr+0x12>
        if (*s == c) {
ffffffffc020145a:	00f58763          	beq	a1,a5,ffffffffc0201468 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020145e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201462:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201464:	fbfd                	bnez	a5,ffffffffc020145a <strchr+0x6>
    }
    return NULL;
ffffffffc0201466:	4501                	li	a0,0
}
ffffffffc0201468:	8082                	ret

ffffffffc020146a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020146a:	ca01                	beqz	a2,ffffffffc020147a <memset+0x10>
ffffffffc020146c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020146e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201470:	0785                	addi	a5,a5,1
ffffffffc0201472:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201476:	fec79de3          	bne	a5,a2,ffffffffc0201470 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020147a:	8082                	ret
