
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0211570 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc0208ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	234040ef          	jal	ffffffffc020427e <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	25a58593          	addi	a1,a1,602 # ffffffffc02042a8 <etext>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	27250513          	addi	a0,a0,626 # ffffffffc02042c8 <etext+0x20>
ffffffffc020005e:	05c000ef          	jal	ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	09e000ef          	jal	ffffffffc0200100 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	287010ef          	jal	ffffffffc0201aec <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4d6000ef          	jal	ffffffffc0200540 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	4ac030ef          	jal	ffffffffc020351a <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	3fc000ef          	jal	ffffffffc020046e <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	109020ef          	jal	ffffffffc020297e <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	332000ef          	jal	ffffffffc02003ac <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	376000ef          	jal	ffffffffc02003fe <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	513030ef          	jal	ffffffffc0203dc0 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	f42e                	sd	a1,40(sp)
ffffffffc02000c2:	f832                	sd	a2,48(sp)
ffffffffc02000c4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c6:	862a                	mv	a2,a0
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	00000517          	auipc	a0,0x0
ffffffffc02000ce:	fb650513          	addi	a0,a0,-74 # ffffffffc0200080 <cputch>
ffffffffc02000d2:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d4:	ec06                	sd	ra,24(sp)
ffffffffc02000d6:	e0ba                	sd	a4,64(sp)
ffffffffc02000d8:	e4be                	sd	a5,72(sp)
ffffffffc02000da:	e8c2                	sd	a6,80(sp)
ffffffffc02000dc:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc02000de:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e2:	4df030ef          	jal	ffffffffc0203dc0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e6:	60e2                	ld	ra,24(sp)
ffffffffc02000e8:	4512                	lw	a0,4(sp)
ffffffffc02000ea:	6125                	addi	sp,sp,96
ffffffffc02000ec:	8082                	ret

ffffffffc02000ee <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ee:	ae01                	j	ffffffffc02003fe <cons_putc>

ffffffffc02000f0 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f0:	1141                	addi	sp,sp,-16
ffffffffc02000f2:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f4:	33e000ef          	jal	ffffffffc0200432 <cons_getc>
ffffffffc02000f8:	dd75                	beqz	a0,ffffffffc02000f4 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fa:	60a2                	ld	ra,8(sp)
ffffffffc02000fc:	0141                	addi	sp,sp,16
ffffffffc02000fe:	8082                	ret

ffffffffc0200100 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200100:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200102:	00004517          	auipc	a0,0x4
ffffffffc0200106:	1ce50513          	addi	a0,a0,462 # ffffffffc02042d0 <etext+0x28>
void print_kerninfo(void) {
ffffffffc020010a:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010c:	fafff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200110:	00000597          	auipc	a1,0x0
ffffffffc0200114:	f2258593          	addi	a1,a1,-222 # ffffffffc0200032 <kern_init>
ffffffffc0200118:	00004517          	auipc	a0,0x4
ffffffffc020011c:	1d850513          	addi	a0,a0,472 # ffffffffc02042f0 <etext+0x48>
ffffffffc0200120:	f9bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200124:	00004597          	auipc	a1,0x4
ffffffffc0200128:	18458593          	addi	a1,a1,388 # ffffffffc02042a8 <etext>
ffffffffc020012c:	00004517          	auipc	a0,0x4
ffffffffc0200130:	1e450513          	addi	a0,a0,484 # ffffffffc0204310 <etext+0x68>
ffffffffc0200134:	f87ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200138:	0000a597          	auipc	a1,0xa
ffffffffc020013c:	f0858593          	addi	a1,a1,-248 # ffffffffc020a040 <ide>
ffffffffc0200140:	00004517          	auipc	a0,0x4
ffffffffc0200144:	1f050513          	addi	a0,a0,496 # ffffffffc0204330 <etext+0x88>
ffffffffc0200148:	f73ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014c:	00011597          	auipc	a1,0x11
ffffffffc0200150:	42458593          	addi	a1,a1,1060 # ffffffffc0211570 <end>
ffffffffc0200154:	00004517          	auipc	a0,0x4
ffffffffc0200158:	1fc50513          	addi	a0,a0,508 # ffffffffc0204350 <etext+0xa8>
ffffffffc020015c:	f5fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200160:	00000717          	auipc	a4,0x0
ffffffffc0200164:	ed270713          	addi	a4,a4,-302 # ffffffffc0200032 <kern_init>
ffffffffc0200168:	00012797          	auipc	a5,0x12
ffffffffc020016c:	80778793          	addi	a5,a5,-2041 # ffffffffc021196f <end+0x3ff>
ffffffffc0200170:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200172:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200176:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200178:	3ff5f593          	andi	a1,a1,1023
ffffffffc020017c:	95be                	add	a1,a1,a5
ffffffffc020017e:	85a9                	srai	a1,a1,0xa
ffffffffc0200180:	00004517          	auipc	a0,0x4
ffffffffc0200184:	1f050513          	addi	a0,a0,496 # ffffffffc0204370 <etext+0xc8>
}
ffffffffc0200188:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018a:	bf05                	j	ffffffffc02000ba <cprintf>

ffffffffc020018c <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020018c:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc020018e:	00004617          	auipc	a2,0x4
ffffffffc0200192:	21260613          	addi	a2,a2,530 # ffffffffc02043a0 <etext+0xf8>
ffffffffc0200196:	04e00593          	li	a1,78
ffffffffc020019a:	00004517          	auipc	a0,0x4
ffffffffc020019e:	21e50513          	addi	a0,a0,542 # ffffffffc02043b8 <etext+0x110>
void print_stackframe(void) {
ffffffffc02001a2:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a4:	1a8000ef          	jal	ffffffffc020034c <__panic>

ffffffffc02001a8 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001a8:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001aa:	00004617          	auipc	a2,0x4
ffffffffc02001ae:	22660613          	addi	a2,a2,550 # ffffffffc02043d0 <etext+0x128>
ffffffffc02001b2:	00004597          	auipc	a1,0x4
ffffffffc02001b6:	23e58593          	addi	a1,a1,574 # ffffffffc02043f0 <etext+0x148>
ffffffffc02001ba:	00004517          	auipc	a0,0x4
ffffffffc02001be:	23e50513          	addi	a0,a0,574 # ffffffffc02043f8 <etext+0x150>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c2:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c4:	ef7ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02001c8:	00004617          	auipc	a2,0x4
ffffffffc02001cc:	24060613          	addi	a2,a2,576 # ffffffffc0204408 <etext+0x160>
ffffffffc02001d0:	00004597          	auipc	a1,0x4
ffffffffc02001d4:	26058593          	addi	a1,a1,608 # ffffffffc0204430 <etext+0x188>
ffffffffc02001d8:	00004517          	auipc	a0,0x4
ffffffffc02001dc:	22050513          	addi	a0,a0,544 # ffffffffc02043f8 <etext+0x150>
ffffffffc02001e0:	edbff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02001e4:	00004617          	auipc	a2,0x4
ffffffffc02001e8:	25c60613          	addi	a2,a2,604 # ffffffffc0204440 <etext+0x198>
ffffffffc02001ec:	00004597          	auipc	a1,0x4
ffffffffc02001f0:	27458593          	addi	a1,a1,628 # ffffffffc0204460 <etext+0x1b8>
ffffffffc02001f4:	00004517          	auipc	a0,0x4
ffffffffc02001f8:	20450513          	addi	a0,a0,516 # ffffffffc02043f8 <etext+0x150>
ffffffffc02001fc:	ebfff0ef          	jal	ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200200:	60a2                	ld	ra,8(sp)
ffffffffc0200202:	4501                	li	a0,0
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
ffffffffc020020a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020020c:	ef5ff0ef          	jal	ffffffffc0200100 <print_kerninfo>
    return 0;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	4501                	li	a0,0
ffffffffc0200214:	0141                	addi	sp,sp,16
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200218:	1141                	addi	sp,sp,-16
ffffffffc020021a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020021c:	f71ff0ef          	jal	ffffffffc020018c <print_stackframe>
    return 0;
}
ffffffffc0200220:	60a2                	ld	ra,8(sp)
ffffffffc0200222:	4501                	li	a0,0
ffffffffc0200224:	0141                	addi	sp,sp,16
ffffffffc0200226:	8082                	ret

ffffffffc0200228 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200228:	7131                	addi	sp,sp,-192
ffffffffc020022a:	e952                	sd	s4,144(sp)
ffffffffc020022c:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020022e:	00004517          	auipc	a0,0x4
ffffffffc0200232:	24250513          	addi	a0,a0,578 # ffffffffc0204470 <etext+0x1c8>
kmonitor(struct trapframe *tf) {
ffffffffc0200236:	fd06                	sd	ra,184(sp)
ffffffffc0200238:	f922                	sd	s0,176(sp)
ffffffffc020023a:	f526                	sd	s1,168(sp)
ffffffffc020023c:	f14a                	sd	s2,160(sp)
ffffffffc020023e:	ed4e                	sd	s3,152(sp)
ffffffffc0200240:	e556                	sd	s5,136(sp)
ffffffffc0200242:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200244:	e77ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200248:	00004517          	auipc	a0,0x4
ffffffffc020024c:	25050513          	addi	a0,a0,592 # ffffffffc0204498 <etext+0x1f0>
ffffffffc0200250:	e6bff0ef          	jal	ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200254:	000a0563          	beqz	s4,ffffffffc020025e <kmonitor+0x36>
        print_trapframe(tf);
ffffffffc0200258:	8552                	mv	a0,s4
ffffffffc020025a:	4d0000ef          	jal	ffffffffc020072a <print_trapframe>
ffffffffc020025e:	00006a97          	auipc	s5,0x6
ffffffffc0200262:	b92a8a93          	addi	s5,s5,-1134 # ffffffffc0205df0 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc0200266:	49bd                	li	s3,15
        argv[argc ++] = buf;
ffffffffc0200268:	890a                	mv	s2,sp
        if ((buf = readline("")) != NULL) {
ffffffffc020026a:	00005517          	auipc	a0,0x5
ffffffffc020026e:	5b650513          	addi	a0,a0,1462 # ffffffffc0205820 <etext+0x1578>
ffffffffc0200272:	6b7030ef          	jal	ffffffffc0204128 <readline>
ffffffffc0200276:	842a                	mv	s0,a0
ffffffffc0200278:	d96d                	beqz	a0,ffffffffc020026a <kmonitor+0x42>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020027e:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	e99d                	bnez	a1,ffffffffc02002b6 <kmonitor+0x8e>
    int argc = 0;
ffffffffc0200282:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc0200284:	fe0b03e3          	beqz	s6,ffffffffc020026a <kmonitor+0x42>
ffffffffc0200288:	00006497          	auipc	s1,0x6
ffffffffc020028c:	b6848493          	addi	s1,s1,-1176 # ffffffffc0205df0 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200290:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200292:	6582                	ld	a1,0(sp)
ffffffffc0200294:	6088                	ld	a0,0(s1)
ffffffffc0200296:	79f030ef          	jal	ffffffffc0204234 <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020029c:	c149                	beqz	a0,ffffffffc020031e <kmonitor+0xf6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029e:	2405                	addiw	s0,s0,1
ffffffffc02002a0:	04e1                	addi	s1,s1,24
ffffffffc02002a2:	fef418e3          	bne	s0,a5,ffffffffc0200292 <kmonitor+0x6a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002a6:	6582                	ld	a1,0(sp)
ffffffffc02002a8:	00004517          	auipc	a0,0x4
ffffffffc02002ac:	24050513          	addi	a0,a0,576 # ffffffffc02044e8 <etext+0x240>
ffffffffc02002b0:	e0bff0ef          	jal	ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02002b4:	bf5d                	j	ffffffffc020026a <kmonitor+0x42>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b6:	00004517          	auipc	a0,0x4
ffffffffc02002ba:	20a50513          	addi	a0,a0,522 # ffffffffc02044c0 <etext+0x218>
ffffffffc02002be:	7af030ef          	jal	ffffffffc020426c <strchr>
ffffffffc02002c2:	c901                	beqz	a0,ffffffffc02002d2 <kmonitor+0xaa>
ffffffffc02002c4:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02002c8:	00040023          	sb	zero,0(s0)
ffffffffc02002cc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ce:	d9d5                	beqz	a1,ffffffffc0200282 <kmonitor+0x5a>
ffffffffc02002d0:	b7dd                	j	ffffffffc02002b6 <kmonitor+0x8e>
        if (*buf == '\0') {
ffffffffc02002d2:	00044783          	lbu	a5,0(s0)
ffffffffc02002d6:	d7d5                	beqz	a5,ffffffffc0200282 <kmonitor+0x5a>
        if (argc == MAXARGS - 1) {
ffffffffc02002d8:	03348b63          	beq	s1,s3,ffffffffc020030e <kmonitor+0xe6>
        argv[argc ++] = buf;
ffffffffc02002dc:	00349793          	slli	a5,s1,0x3
ffffffffc02002e0:	97ca                	add	a5,a5,s2
ffffffffc02002e2:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002e4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02002e8:	2485                	addiw	s1,s1,1
ffffffffc02002ea:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002ec:	e591                	bnez	a1,ffffffffc02002f8 <kmonitor+0xd0>
ffffffffc02002ee:	bf59                	j	ffffffffc0200284 <kmonitor+0x5c>
ffffffffc02002f0:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02002f4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02002f6:	d5d1                	beqz	a1,ffffffffc0200282 <kmonitor+0x5a>
ffffffffc02002f8:	00004517          	auipc	a0,0x4
ffffffffc02002fc:	1c850513          	addi	a0,a0,456 # ffffffffc02044c0 <etext+0x218>
ffffffffc0200300:	76d030ef          	jal	ffffffffc020426c <strchr>
ffffffffc0200304:	d575                	beqz	a0,ffffffffc02002f0 <kmonitor+0xc8>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200306:	00044583          	lbu	a1,0(s0)
ffffffffc020030a:	dda5                	beqz	a1,ffffffffc0200282 <kmonitor+0x5a>
ffffffffc020030c:	b76d                	j	ffffffffc02002b6 <kmonitor+0x8e>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020030e:	45c1                	li	a1,16
ffffffffc0200310:	00004517          	auipc	a0,0x4
ffffffffc0200314:	1b850513          	addi	a0,a0,440 # ffffffffc02044c8 <etext+0x220>
ffffffffc0200318:	da3ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc020031c:	b7c1                	j	ffffffffc02002dc <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020031e:	00141793          	slli	a5,s0,0x1
ffffffffc0200322:	97a2                	add	a5,a5,s0
ffffffffc0200324:	078e                	slli	a5,a5,0x3
ffffffffc0200326:	97d6                	add	a5,a5,s5
ffffffffc0200328:	6b9c                	ld	a5,16(a5)
ffffffffc020032a:	fffb051b          	addiw	a0,s6,-1
ffffffffc020032e:	8652                	mv	a2,s4
ffffffffc0200330:	002c                	addi	a1,sp,8
ffffffffc0200332:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200334:	f2055be3          	bgez	a0,ffffffffc020026a <kmonitor+0x42>
}
ffffffffc0200338:	70ea                	ld	ra,184(sp)
ffffffffc020033a:	744a                	ld	s0,176(sp)
ffffffffc020033c:	74aa                	ld	s1,168(sp)
ffffffffc020033e:	790a                	ld	s2,160(sp)
ffffffffc0200340:	69ea                	ld	s3,152(sp)
ffffffffc0200342:	6a4a                	ld	s4,144(sp)
ffffffffc0200344:	6aaa                	ld	s5,136(sp)
ffffffffc0200346:	6b0a                	ld	s6,128(sp)
ffffffffc0200348:	6129                	addi	sp,sp,192
ffffffffc020034a:	8082                	ret

ffffffffc020034c <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020034c:	00011317          	auipc	t1,0x11
ffffffffc0200350:	1ac32303          	lw	t1,428(t1) # ffffffffc02114f8 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200354:	715d                	addi	sp,sp,-80
ffffffffc0200356:	ec06                	sd	ra,24(sp)
ffffffffc0200358:	f436                	sd	a3,40(sp)
ffffffffc020035a:	f83a                	sd	a4,48(sp)
ffffffffc020035c:	fc3e                	sd	a5,56(sp)
ffffffffc020035e:	e0c2                	sd	a6,64(sp)
ffffffffc0200360:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200362:	02031f63          	bnez	t1,ffffffffc02003a0 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200366:	e822                	sd	s0,16(sp)
ffffffffc0200368:	00011797          	auipc	a5,0x11
ffffffffc020036c:	19078793          	addi	a5,a5,400 # ffffffffc02114f8 <is_panic>
ffffffffc0200370:	4685                	li	a3,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200372:	1038                	addi	a4,sp,40
ffffffffc0200374:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200376:	862e                	mv	a2,a1
ffffffffc0200378:	85aa                	mv	a1,a0
ffffffffc020037a:	00004517          	auipc	a0,0x4
ffffffffc020037e:	18650513          	addi	a0,a0,390 # ffffffffc0204500 <etext+0x258>
    is_panic = 1;
ffffffffc0200382:	c394                	sw	a3,0(a5)
    va_start(ap, fmt);
ffffffffc0200384:	e43a                	sd	a4,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200386:	d35ff0ef          	jal	ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020038a:	65a2                	ld	a1,8(sp)
ffffffffc020038c:	8522                	mv	a0,s0
ffffffffc020038e:	d0dff0ef          	jal	ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200392:	00005517          	auipc	a0,0x5
ffffffffc0200396:	fde50513          	addi	a0,a0,-34 # ffffffffc0205370 <etext+0x10c8>
ffffffffc020039a:	d21ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc020039e:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003a0:	12a000ef          	jal	ffffffffc02004ca <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003a4:	4501                	li	a0,0
ffffffffc02003a6:	e83ff0ef          	jal	ffffffffc0200228 <kmonitor>
    while (1) {
ffffffffc02003aa:	bfed                	j	ffffffffc02003a4 <__panic+0x58>

ffffffffc02003ac <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003ac:	67e1                	lui	a5,0x18
ffffffffc02003ae:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003b2:	00011717          	auipc	a4,0x11
ffffffffc02003b6:	14f73723          	sd	a5,334(a4) # ffffffffc0211500 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003ba:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003be:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003c0:	953e                	add	a0,a0,a5
ffffffffc02003c2:	4601                	li	a2,0
ffffffffc02003c4:	4881                	li	a7,0
ffffffffc02003c6:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ca:	02000793          	li	a5,32
ffffffffc02003ce:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003d2:	00004517          	auipc	a0,0x4
ffffffffc02003d6:	14e50513          	addi	a0,a0,334 # ffffffffc0204520 <etext+0x278>
    ticks = 0;
ffffffffc02003da:	00011797          	auipc	a5,0x11
ffffffffc02003de:	1207b723          	sd	zero,302(a5) # ffffffffc0211508 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02003e2:	b9e1                	j	ffffffffc02000ba <cprintf>

ffffffffc02003e4 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e4:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	00011797          	auipc	a5,0x11
ffffffffc02003ec:	1187b783          	ld	a5,280(a5) # ffffffffc0211500 <timebase>
ffffffffc02003f0:	4581                	li	a1,0
ffffffffc02003f2:	4601                	li	a2,0
ffffffffc02003f4:	953e                	add	a0,a0,a5
ffffffffc02003f6:	4881                	li	a7,0
ffffffffc02003f8:	00000073          	ecall
ffffffffc02003fc:	8082                	ret

ffffffffc02003fe <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02003fe:	100027f3          	csrr	a5,sstatus
ffffffffc0200402:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200404:	0ff57513          	zext.b	a0,a0
ffffffffc0200408:	e799                	bnez	a5,ffffffffc0200416 <cons_putc+0x18>
ffffffffc020040a:	4581                	li	a1,0
ffffffffc020040c:	4601                	li	a2,0
ffffffffc020040e:	4885                	li	a7,1
ffffffffc0200410:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200414:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200416:	1101                	addi	sp,sp,-32
ffffffffc0200418:	ec06                	sd	ra,24(sp)
ffffffffc020041a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020041c:	0ae000ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc0200420:	6522                	ld	a0,8(sp)
ffffffffc0200422:	4581                	li	a1,0
ffffffffc0200424:	4601                	li	a2,0
ffffffffc0200426:	4885                	li	a7,1
ffffffffc0200428:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc020042c:	60e2                	ld	ra,24(sp)
ffffffffc020042e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200430:	a851                	j	ffffffffc02004c4 <intr_enable>

ffffffffc0200432 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200432:	100027f3          	csrr	a5,sstatus
ffffffffc0200436:	8b89                	andi	a5,a5,2
ffffffffc0200438:	eb89                	bnez	a5,ffffffffc020044a <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020043a:	4501                	li	a0,0
ffffffffc020043c:	4581                	li	a1,0
ffffffffc020043e:	4601                	li	a2,0
ffffffffc0200440:	4889                	li	a7,2
ffffffffc0200442:	00000073          	ecall
ffffffffc0200446:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200448:	8082                	ret
int cons_getc(void) {
ffffffffc020044a:	1101                	addi	sp,sp,-32
ffffffffc020044c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020044e:	07c000ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc0200452:	4501                	li	a0,0
ffffffffc0200454:	4581                	li	a1,0
ffffffffc0200456:	4601                	li	a2,0
ffffffffc0200458:	4889                	li	a7,2
ffffffffc020045a:	00000073          	ecall
ffffffffc020045e:	2501                	sext.w	a0,a0
ffffffffc0200460:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200462:	062000ef          	jal	ffffffffc02004c4 <intr_enable>
}
ffffffffc0200466:	60e2                	ld	ra,24(sp)
ffffffffc0200468:	6522                	ld	a0,8(sp)
ffffffffc020046a:	6105                	addi	sp,sp,32
ffffffffc020046c:	8082                	ret

ffffffffc020046e <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020046e:	8082                	ret

ffffffffc0200470 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200470:	00253513          	sltiu	a0,a0,2
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200476:	03800513          	li	a0,56
ffffffffc020047a:	8082                	ret

ffffffffc020047c <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020047c:	0000a797          	auipc	a5,0xa
ffffffffc0200480:	bc478793          	addi	a5,a5,-1084 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200484:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200488:	1141                	addi	sp,sp,-16
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020048a:	8532                	mv	a0,a2
ffffffffc020048c:	95be                	add	a1,a1,a5
ffffffffc020048e:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200492:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200494:	5fd030ef          	jal	ffffffffc0204290 <memcpy>
    return 0;
}
ffffffffc0200498:	60a2                	ld	ra,8(sp)
ffffffffc020049a:	4501                	li	a0,0
ffffffffc020049c:	0141                	addi	sp,sp,16
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004a0:	0095951b          	slliw	a0,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004a4:	0000a797          	auipc	a5,0xa
ffffffffc02004a8:	b9c78793          	addi	a5,a5,-1124 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004ae:	85b2                	mv	a1,a2
ffffffffc02004b0:	953e                	add	a0,a0,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004b8:	5d9030ef          	jal	ffffffffc0204290 <memcpy>
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004c4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004c8:	8082                	ret

ffffffffc02004ca <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ca:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004ce:	8082                	ret

ffffffffc02004d0 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004d0:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004d4:	1141                	addi	sp,sp,-16
ffffffffc02004d6:	e022                	sd	s0,0(sp)
ffffffffc02004d8:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004da:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004de:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004e2:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02004e4:	04b00613          	li	a2,75
ffffffffc02004e8:	e399                	bnez	a5,ffffffffc02004ee <pgfault_handler+0x1e>
ffffffffc02004ea:	05500613          	li	a2,85
ffffffffc02004ee:	11843703          	ld	a4,280(s0)
ffffffffc02004f2:	47bd                	li	a5,15
ffffffffc02004f4:	05200693          	li	a3,82
ffffffffc02004f8:	00f71463          	bne	a4,a5,ffffffffc0200500 <pgfault_handler+0x30>
ffffffffc02004fc:	05700693          	li	a3,87
ffffffffc0200500:	00004517          	auipc	a0,0x4
ffffffffc0200504:	04050513          	addi	a0,a0,64 # ffffffffc0204540 <etext+0x298>
ffffffffc0200508:	bb3ff0ef          	jal	ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020050c:	00011517          	auipc	a0,0x11
ffffffffc0200510:	05c53503          	ld	a0,92(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0200514:	c911                	beqz	a0,ffffffffc0200528 <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200516:	11043603          	ld	a2,272(s0)
ffffffffc020051a:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020051e:	6402                	ld	s0,0(sp)
ffffffffc0200520:	60a2                	ld	ra,8(sp)
ffffffffc0200522:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200524:	5e00306f          	j	ffffffffc0203b04 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200528:	00004617          	auipc	a2,0x4
ffffffffc020052c:	03860613          	addi	a2,a2,56 # ffffffffc0204560 <etext+0x2b8>
ffffffffc0200530:	07800593          	li	a1,120
ffffffffc0200534:	00004517          	auipc	a0,0x4
ffffffffc0200538:	04450513          	addi	a0,a0,68 # ffffffffc0204578 <etext+0x2d0>
ffffffffc020053c:	e11ff0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0200540 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200540:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200544:	00000797          	auipc	a5,0x0
ffffffffc0200548:	49c78793          	addi	a5,a5,1180 # ffffffffc02009e0 <__alltraps>
ffffffffc020054c:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200550:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200554:	000407b7          	lui	a5,0x40
ffffffffc0200558:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020055c:	8082                	ret

ffffffffc020055e <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020055e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200560:	1141                	addi	sp,sp,-16
ffffffffc0200562:	e022                	sd	s0,0(sp)
ffffffffc0200564:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	02a50513          	addi	a0,a0,42 # ffffffffc0204590 <etext+0x2e8>
void print_regs(struct pushregs *gpr) {
ffffffffc020056e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200570:	b4bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200574:	640c                	ld	a1,8(s0)
ffffffffc0200576:	00004517          	auipc	a0,0x4
ffffffffc020057a:	03250513          	addi	a0,a0,50 # ffffffffc02045a8 <etext+0x300>
ffffffffc020057e:	b3dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200582:	680c                	ld	a1,16(s0)
ffffffffc0200584:	00004517          	auipc	a0,0x4
ffffffffc0200588:	03c50513          	addi	a0,a0,60 # ffffffffc02045c0 <etext+0x318>
ffffffffc020058c:	b2fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200590:	6c0c                	ld	a1,24(s0)
ffffffffc0200592:	00004517          	auipc	a0,0x4
ffffffffc0200596:	04650513          	addi	a0,a0,70 # ffffffffc02045d8 <etext+0x330>
ffffffffc020059a:	b21ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc020059e:	700c                	ld	a1,32(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	05050513          	addi	a0,a0,80 # ffffffffc02045f0 <etext+0x348>
ffffffffc02005a8:	b13ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005ac:	740c                	ld	a1,40(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	05a50513          	addi	a0,a0,90 # ffffffffc0204608 <etext+0x360>
ffffffffc02005b6:	b05ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ba:	780c                	ld	a1,48(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	06450513          	addi	a0,a0,100 # ffffffffc0204620 <etext+0x378>
ffffffffc02005c4:	af7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005c8:	7c0c                	ld	a1,56(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	06e50513          	addi	a0,a0,110 # ffffffffc0204638 <etext+0x390>
ffffffffc02005d2:	ae9ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005d6:	602c                	ld	a1,64(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	07850513          	addi	a0,a0,120 # ffffffffc0204650 <etext+0x3a8>
ffffffffc02005e0:	adbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02005e4:	642c                	ld	a1,72(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	08250513          	addi	a0,a0,130 # ffffffffc0204668 <etext+0x3c0>
ffffffffc02005ee:	acdff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02005f2:	682c                	ld	a1,80(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	08c50513          	addi	a0,a0,140 # ffffffffc0204680 <etext+0x3d8>
ffffffffc02005fc:	abfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200600:	6c2c                	ld	a1,88(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	09650513          	addi	a0,a0,150 # ffffffffc0204698 <etext+0x3f0>
ffffffffc020060a:	ab1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020060e:	702c                	ld	a1,96(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	0a050513          	addi	a0,a0,160 # ffffffffc02046b0 <etext+0x408>
ffffffffc0200618:	aa3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020061c:	742c                	ld	a1,104(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	0aa50513          	addi	a0,a0,170 # ffffffffc02046c8 <etext+0x420>
ffffffffc0200626:	a95ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020062a:	782c                	ld	a1,112(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	0b450513          	addi	a0,a0,180 # ffffffffc02046e0 <etext+0x438>
ffffffffc0200634:	a87ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200638:	7c2c                	ld	a1,120(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	0be50513          	addi	a0,a0,190 # ffffffffc02046f8 <etext+0x450>
ffffffffc0200642:	a79ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200646:	604c                	ld	a1,128(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	0c850513          	addi	a0,a0,200 # ffffffffc0204710 <etext+0x468>
ffffffffc0200650:	a6bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200654:	644c                	ld	a1,136(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	0d250513          	addi	a0,a0,210 # ffffffffc0204728 <etext+0x480>
ffffffffc020065e:	a5dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200662:	684c                	ld	a1,144(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	0dc50513          	addi	a0,a0,220 # ffffffffc0204740 <etext+0x498>
ffffffffc020066c:	a4fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200670:	6c4c                	ld	a1,152(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	0e650513          	addi	a0,a0,230 # ffffffffc0204758 <etext+0x4b0>
ffffffffc020067a:	a41ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020067e:	704c                	ld	a1,160(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	0f050513          	addi	a0,a0,240 # ffffffffc0204770 <etext+0x4c8>
ffffffffc0200688:	a33ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020068c:	744c                	ld	a1,168(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	0fa50513          	addi	a0,a0,250 # ffffffffc0204788 <etext+0x4e0>
ffffffffc0200696:	a25ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020069a:	784c                	ld	a1,176(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	10450513          	addi	a0,a0,260 # ffffffffc02047a0 <etext+0x4f8>
ffffffffc02006a4:	a17ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006a8:	7c4c                	ld	a1,184(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	10e50513          	addi	a0,a0,270 # ffffffffc02047b8 <etext+0x510>
ffffffffc02006b2:	a09ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006b6:	606c                	ld	a1,192(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	11850513          	addi	a0,a0,280 # ffffffffc02047d0 <etext+0x528>
ffffffffc02006c0:	9fbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006c4:	646c                	ld	a1,200(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	12250513          	addi	a0,a0,290 # ffffffffc02047e8 <etext+0x540>
ffffffffc02006ce:	9edff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006d2:	686c                	ld	a1,208(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	12c50513          	addi	a0,a0,300 # ffffffffc0204800 <etext+0x558>
ffffffffc02006dc:	9dfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02006e0:	6c6c                	ld	a1,216(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	13650513          	addi	a0,a0,310 # ffffffffc0204818 <etext+0x570>
ffffffffc02006ea:	9d1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02006ee:	706c                	ld	a1,224(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	14050513          	addi	a0,a0,320 # ffffffffc0204830 <etext+0x588>
ffffffffc02006f8:	9c3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02006fc:	746c                	ld	a1,232(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	14a50513          	addi	a0,a0,330 # ffffffffc0204848 <etext+0x5a0>
ffffffffc0200706:	9b5ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020070a:	786c                	ld	a1,240(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	15450513          	addi	a0,a0,340 # ffffffffc0204860 <etext+0x5b8>
ffffffffc0200714:	9a7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200718:	7c6c                	ld	a1,248(s0)
}
ffffffffc020071a:	6402                	ld	s0,0(sp)
ffffffffc020071c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020071e:	00004517          	auipc	a0,0x4
ffffffffc0200722:	15a50513          	addi	a0,a0,346 # ffffffffc0204878 <etext+0x5d0>
}
ffffffffc0200726:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200728:	ba49                	j	ffffffffc02000ba <cprintf>

ffffffffc020072a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020072a:	1141                	addi	sp,sp,-16
ffffffffc020072c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020072e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200730:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200732:	00004517          	auipc	a0,0x4
ffffffffc0200736:	15e50513          	addi	a0,a0,350 # ffffffffc0204890 <etext+0x5e8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020073a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020073c:	97fff0ef          	jal	ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200740:	8522                	mv	a0,s0
ffffffffc0200742:	e1dff0ef          	jal	ffffffffc020055e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200746:	10043583          	ld	a1,256(s0)
ffffffffc020074a:	00004517          	auipc	a0,0x4
ffffffffc020074e:	15e50513          	addi	a0,a0,350 # ffffffffc02048a8 <etext+0x600>
ffffffffc0200752:	969ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200756:	10843583          	ld	a1,264(s0)
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	16650513          	addi	a0,a0,358 # ffffffffc02048c0 <etext+0x618>
ffffffffc0200762:	959ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200766:	11043583          	ld	a1,272(s0)
ffffffffc020076a:	00004517          	auipc	a0,0x4
ffffffffc020076e:	16e50513          	addi	a0,a0,366 # ffffffffc02048d8 <etext+0x630>
ffffffffc0200772:	949ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200776:	11843583          	ld	a1,280(s0)
}
ffffffffc020077a:	6402                	ld	s0,0(sp)
ffffffffc020077c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	17250513          	addi	a0,a0,370 # ffffffffc02048f0 <etext+0x648>
}
ffffffffc0200786:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200788:	933ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc020078c <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc020078c:	11853783          	ld	a5,280(a0)
ffffffffc0200790:	472d                	li	a4,11
ffffffffc0200792:	0786                	slli	a5,a5,0x1
ffffffffc0200794:	8385                	srli	a5,a5,0x1
ffffffffc0200796:	08f76c63          	bltu	a4,a5,ffffffffc020082e <interrupt_handler+0xa2>
ffffffffc020079a:	00005717          	auipc	a4,0x5
ffffffffc020079e:	69e70713          	addi	a4,a4,1694 # ffffffffc0205e38 <commands+0x48>
ffffffffc02007a2:	078a                	slli	a5,a5,0x2
ffffffffc02007a4:	97ba                	add	a5,a5,a4
ffffffffc02007a6:	439c                	lw	a5,0(a5)
ffffffffc02007a8:	97ba                	add	a5,a5,a4
ffffffffc02007aa:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007ac:	00004517          	auipc	a0,0x4
ffffffffc02007b0:	1bc50513          	addi	a0,a0,444 # ffffffffc0204968 <etext+0x6c0>
ffffffffc02007b4:	907ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007b8:	00004517          	auipc	a0,0x4
ffffffffc02007bc:	19050513          	addi	a0,a0,400 # ffffffffc0204948 <etext+0x6a0>
ffffffffc02007c0:	8fbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007c4:	00004517          	auipc	a0,0x4
ffffffffc02007c8:	14450513          	addi	a0,a0,324 # ffffffffc0204908 <etext+0x660>
ffffffffc02007cc:	8efff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	15850513          	addi	a0,a0,344 # ffffffffc0204928 <etext+0x680>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02007dc:	1141                	addi	sp,sp,-16
ffffffffc02007de:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02007e0:	c05ff0ef          	jal	ffffffffc02003e4 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02007e4:	00011517          	auipc	a0,0x11
ffffffffc02007e8:	d2450513          	addi	a0,a0,-732 # ffffffffc0211508 <ticks>
ffffffffc02007ec:	6114                	ld	a3,0(a0)
ffffffffc02007ee:	28f5c737          	lui	a4,0x28f5c
ffffffffc02007f2:	28f70713          	addi	a4,a4,655 # 28f5c28f <kern_entry-0xffffffff972a3d71>
ffffffffc02007f6:	5c28f637          	lui	a2,0x5c28f
ffffffffc02007fa:	0685                	addi	a3,a3,1
ffffffffc02007fc:	1702                	slli	a4,a4,0x20
ffffffffc02007fe:	5c360613          	addi	a2,a2,1475 # 5c28f5c3 <kern_entry-0xffffffff63f70a3d>
ffffffffc0200802:	0026d793          	srli	a5,a3,0x2
ffffffffc0200806:	9732                	add	a4,a4,a2
ffffffffc0200808:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc020080c:	06400593          	li	a1,100
ffffffffc0200810:	e114                	sd	a3,0(a0)
ffffffffc0200812:	8389                	srli	a5,a5,0x2
ffffffffc0200814:	02b787b3          	mul	a5,a5,a1
ffffffffc0200818:	00f68c63          	beq	a3,a5,ffffffffc0200830 <interrupt_handler+0xa4>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020081c:	60a2                	ld	ra,8(sp)
ffffffffc020081e:	0141                	addi	sp,sp,16
ffffffffc0200820:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200822:	00004517          	auipc	a0,0x4
ffffffffc0200826:	17650513          	addi	a0,a0,374 # ffffffffc0204998 <etext+0x6f0>
ffffffffc020082a:	891ff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc020082e:	bdf5                	j	ffffffffc020072a <print_trapframe>
}
ffffffffc0200830:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200832:	00004517          	auipc	a0,0x4
ffffffffc0200836:	15650513          	addi	a0,a0,342 # ffffffffc0204988 <etext+0x6e0>
}
ffffffffc020083a:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020083c:	87fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200840 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200840:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200844:	1101                	addi	sp,sp,-32
ffffffffc0200846:	e822                	sd	s0,16(sp)
ffffffffc0200848:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc020084a:	473d                	li	a4,15
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc020084e:	14f76763          	bltu	a4,a5,ffffffffc020099c <exception_handler+0x15c>
ffffffffc0200852:	00005717          	auipc	a4,0x5
ffffffffc0200856:	61670713          	addi	a4,a4,1558 # ffffffffc0205e68 <commands+0x78>
ffffffffc020085a:	078a                	slli	a5,a5,0x2
ffffffffc020085c:	97ba                	add	a5,a5,a4
ffffffffc020085e:	439c                	lw	a5,0(a5)
ffffffffc0200860:	97ba                	add	a5,a5,a4
ffffffffc0200862:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200864:	00004517          	auipc	a0,0x4
ffffffffc0200868:	2f450513          	addi	a0,a0,756 # ffffffffc0204b58 <etext+0x8b0>
ffffffffc020086c:	84fff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200870:	8522                	mv	a0,s0
ffffffffc0200872:	c5fff0ef          	jal	ffffffffc02004d0 <pgfault_handler>
ffffffffc0200876:	12051863          	bnez	a0,ffffffffc02009a6 <exception_handler+0x166>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020087a:	60e2                	ld	ra,24(sp)
ffffffffc020087c:	6442                	ld	s0,16(sp)
ffffffffc020087e:	6105                	addi	sp,sp,32
ffffffffc0200880:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200882:	00004517          	auipc	a0,0x4
ffffffffc0200886:	13650513          	addi	a0,a0,310 # ffffffffc02049b8 <etext+0x710>
}
ffffffffc020088a:	6442                	ld	s0,16(sp)
ffffffffc020088c:	60e2                	ld	ra,24(sp)
ffffffffc020088e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200890:	82bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc0200894:	00004517          	auipc	a0,0x4
ffffffffc0200898:	14450513          	addi	a0,a0,324 # ffffffffc02049d8 <etext+0x730>
ffffffffc020089c:	b7fd                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Illegal instruction\n");
ffffffffc020089e:	00004517          	auipc	a0,0x4
ffffffffc02008a2:	15a50513          	addi	a0,a0,346 # ffffffffc02049f8 <etext+0x750>
ffffffffc02008a6:	b7d5                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Breakpoint\n");
ffffffffc02008a8:	00004517          	auipc	a0,0x4
ffffffffc02008ac:	16850513          	addi	a0,a0,360 # ffffffffc0204a10 <etext+0x768>
ffffffffc02008b0:	bfe9                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Load address misaligned\n");
ffffffffc02008b2:	00004517          	auipc	a0,0x4
ffffffffc02008b6:	16e50513          	addi	a0,a0,366 # ffffffffc0204a20 <etext+0x778>
ffffffffc02008ba:	bfc1                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Load access fault\n");
ffffffffc02008bc:	00004517          	auipc	a0,0x4
ffffffffc02008c0:	18450513          	addi	a0,a0,388 # ffffffffc0204a40 <etext+0x798>
ffffffffc02008c4:	ff6ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008c8:	8522                	mv	a0,s0
ffffffffc02008ca:	c07ff0ef          	jal	ffffffffc02004d0 <pgfault_handler>
ffffffffc02008ce:	d555                	beqz	a0,ffffffffc020087a <exception_handler+0x3a>
ffffffffc02008d0:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc02008d2:	8522                	mv	a0,s0
ffffffffc02008d4:	e57ff0ef          	jal	ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008d8:	66a2                	ld	a3,8(sp)
ffffffffc02008da:	00004617          	auipc	a2,0x4
ffffffffc02008de:	17e60613          	addi	a2,a2,382 # ffffffffc0204a58 <etext+0x7b0>
ffffffffc02008e2:	0ca00593          	li	a1,202
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	c9250513          	addi	a0,a0,-878 # ffffffffc0204578 <etext+0x2d0>
ffffffffc02008ee:	a5fff0ef          	jal	ffffffffc020034c <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02008f2:	00004517          	auipc	a0,0x4
ffffffffc02008f6:	18650513          	addi	a0,a0,390 # ffffffffc0204a78 <etext+0x7d0>
ffffffffc02008fa:	bf41                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Store/AMO access fault\n");
ffffffffc02008fc:	00004517          	auipc	a0,0x4
ffffffffc0200900:	19450513          	addi	a0,a0,404 # ffffffffc0204a90 <etext+0x7e8>
ffffffffc0200904:	fb6ff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200908:	8522                	mv	a0,s0
ffffffffc020090a:	bc7ff0ef          	jal	ffffffffc02004d0 <pgfault_handler>
ffffffffc020090e:	d535                	beqz	a0,ffffffffc020087a <exception_handler+0x3a>
ffffffffc0200910:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc0200912:	8522                	mv	a0,s0
ffffffffc0200914:	e17ff0ef          	jal	ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200918:	66a2                	ld	a3,8(sp)
ffffffffc020091a:	00004617          	auipc	a2,0x4
ffffffffc020091e:	13e60613          	addi	a2,a2,318 # ffffffffc0204a58 <etext+0x7b0>
ffffffffc0200922:	0d400593          	li	a1,212
ffffffffc0200926:	00004517          	auipc	a0,0x4
ffffffffc020092a:	c5250513          	addi	a0,a0,-942 # ffffffffc0204578 <etext+0x2d0>
ffffffffc020092e:	a1fff0ef          	jal	ffffffffc020034c <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200932:	00004517          	auipc	a0,0x4
ffffffffc0200936:	17650513          	addi	a0,a0,374 # ffffffffc0204aa8 <etext+0x800>
ffffffffc020093a:	bf81                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Environment call from S-mode\n");
ffffffffc020093c:	00004517          	auipc	a0,0x4
ffffffffc0200940:	18c50513          	addi	a0,a0,396 # ffffffffc0204ac8 <etext+0x820>
ffffffffc0200944:	b799                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Environment call from H-mode\n");
ffffffffc0200946:	00004517          	auipc	a0,0x4
ffffffffc020094a:	1a250513          	addi	a0,a0,418 # ffffffffc0204ae8 <etext+0x840>
ffffffffc020094e:	bf35                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Environment call from M-mode\n");
ffffffffc0200950:	00004517          	auipc	a0,0x4
ffffffffc0200954:	1b850513          	addi	a0,a0,440 # ffffffffc0204b08 <etext+0x860>
ffffffffc0200958:	bf0d                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Instruction page fault\n");
ffffffffc020095a:	00004517          	auipc	a0,0x4
ffffffffc020095e:	1ce50513          	addi	a0,a0,462 # ffffffffc0204b28 <etext+0x880>
ffffffffc0200962:	b725                	j	ffffffffc020088a <exception_handler+0x4a>
            cprintf("Load page fault\n");
ffffffffc0200964:	00004517          	auipc	a0,0x4
ffffffffc0200968:	1dc50513          	addi	a0,a0,476 # ffffffffc0204b40 <etext+0x898>
ffffffffc020096c:	f4eff0ef          	jal	ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200970:	8522                	mv	a0,s0
ffffffffc0200972:	b5fff0ef          	jal	ffffffffc02004d0 <pgfault_handler>
ffffffffc0200976:	f00502e3          	beqz	a0,ffffffffc020087a <exception_handler+0x3a>
ffffffffc020097a:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc020097c:	8522                	mv	a0,s0
ffffffffc020097e:	dadff0ef          	jal	ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200982:	66a2                	ld	a3,8(sp)
ffffffffc0200984:	00004617          	auipc	a2,0x4
ffffffffc0200988:	0d460613          	addi	a2,a2,212 # ffffffffc0204a58 <etext+0x7b0>
ffffffffc020098c:	0ea00593          	li	a1,234
ffffffffc0200990:	00004517          	auipc	a0,0x4
ffffffffc0200994:	be850513          	addi	a0,a0,-1048 # ffffffffc0204578 <etext+0x2d0>
ffffffffc0200998:	9b5ff0ef          	jal	ffffffffc020034c <__panic>
            print_trapframe(tf);
ffffffffc020099c:	8522                	mv	a0,s0
}
ffffffffc020099e:	6442                	ld	s0,16(sp)
ffffffffc02009a0:	60e2                	ld	ra,24(sp)
ffffffffc02009a2:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009a4:	b359                	j	ffffffffc020072a <print_trapframe>
ffffffffc02009a6:	e42a                	sd	a0,8(sp)
                print_trapframe(tf);
ffffffffc02009a8:	8522                	mv	a0,s0
ffffffffc02009aa:	d81ff0ef          	jal	ffffffffc020072a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ae:	66a2                	ld	a3,8(sp)
ffffffffc02009b0:	00004617          	auipc	a2,0x4
ffffffffc02009b4:	0a860613          	addi	a2,a2,168 # ffffffffc0204a58 <etext+0x7b0>
ffffffffc02009b8:	0f100593          	li	a1,241
ffffffffc02009bc:	00004517          	auipc	a0,0x4
ffffffffc02009c0:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0204578 <etext+0x2d0>
ffffffffc02009c4:	989ff0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02009c8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009c8:	11853783          	ld	a5,280(a0)
ffffffffc02009cc:	0007c363          	bltz	a5,ffffffffc02009d2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009d0:	bd85                	j	ffffffffc0200840 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009d2:	bb6d                	j	ffffffffc020078c <interrupt_handler>
	...

ffffffffc02009e0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009e0:	14011073          	csrw	sscratch,sp
ffffffffc02009e4:	712d                	addi	sp,sp,-288
ffffffffc02009e6:	e406                	sd	ra,8(sp)
ffffffffc02009e8:	ec0e                	sd	gp,24(sp)
ffffffffc02009ea:	f012                	sd	tp,32(sp)
ffffffffc02009ec:	f416                	sd	t0,40(sp)
ffffffffc02009ee:	f81a                	sd	t1,48(sp)
ffffffffc02009f0:	fc1e                	sd	t2,56(sp)
ffffffffc02009f2:	e0a2                	sd	s0,64(sp)
ffffffffc02009f4:	e4a6                	sd	s1,72(sp)
ffffffffc02009f6:	e8aa                	sd	a0,80(sp)
ffffffffc02009f8:	ecae                	sd	a1,88(sp)
ffffffffc02009fa:	f0b2                	sd	a2,96(sp)
ffffffffc02009fc:	f4b6                	sd	a3,104(sp)
ffffffffc02009fe:	f8ba                	sd	a4,112(sp)
ffffffffc0200a00:	fcbe                	sd	a5,120(sp)
ffffffffc0200a02:	e142                	sd	a6,128(sp)
ffffffffc0200a04:	e546                	sd	a7,136(sp)
ffffffffc0200a06:	e94a                	sd	s2,144(sp)
ffffffffc0200a08:	ed4e                	sd	s3,152(sp)
ffffffffc0200a0a:	f152                	sd	s4,160(sp)
ffffffffc0200a0c:	f556                	sd	s5,168(sp)
ffffffffc0200a0e:	f95a                	sd	s6,176(sp)
ffffffffc0200a10:	fd5e                	sd	s7,184(sp)
ffffffffc0200a12:	e1e2                	sd	s8,192(sp)
ffffffffc0200a14:	e5e6                	sd	s9,200(sp)
ffffffffc0200a16:	e9ea                	sd	s10,208(sp)
ffffffffc0200a18:	edee                	sd	s11,216(sp)
ffffffffc0200a1a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a1c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a1e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a20:	fdfe                	sd	t6,248(sp)
ffffffffc0200a22:	14002473          	csrr	s0,sscratch
ffffffffc0200a26:	100024f3          	csrr	s1,sstatus
ffffffffc0200a2a:	14102973          	csrr	s2,sepc
ffffffffc0200a2e:	143029f3          	csrr	s3,stval
ffffffffc0200a32:	14202a73          	csrr	s4,scause
ffffffffc0200a36:	e822                	sd	s0,16(sp)
ffffffffc0200a38:	e226                	sd	s1,256(sp)
ffffffffc0200a3a:	e64a                	sd	s2,264(sp)
ffffffffc0200a3c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a3e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a40:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a42:	f87ff0ef          	jal	ffffffffc02009c8 <trap>

ffffffffc0200a46 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a46:	6492                	ld	s1,256(sp)
ffffffffc0200a48:	6932                	ld	s2,264(sp)
ffffffffc0200a4a:	10049073          	csrw	sstatus,s1
ffffffffc0200a4e:	14191073          	csrw	sepc,s2
ffffffffc0200a52:	60a2                	ld	ra,8(sp)
ffffffffc0200a54:	61e2                	ld	gp,24(sp)
ffffffffc0200a56:	7202                	ld	tp,32(sp)
ffffffffc0200a58:	72a2                	ld	t0,40(sp)
ffffffffc0200a5a:	7342                	ld	t1,48(sp)
ffffffffc0200a5c:	73e2                	ld	t2,56(sp)
ffffffffc0200a5e:	6406                	ld	s0,64(sp)
ffffffffc0200a60:	64a6                	ld	s1,72(sp)
ffffffffc0200a62:	6546                	ld	a0,80(sp)
ffffffffc0200a64:	65e6                	ld	a1,88(sp)
ffffffffc0200a66:	7606                	ld	a2,96(sp)
ffffffffc0200a68:	76a6                	ld	a3,104(sp)
ffffffffc0200a6a:	7746                	ld	a4,112(sp)
ffffffffc0200a6c:	77e6                	ld	a5,120(sp)
ffffffffc0200a6e:	680a                	ld	a6,128(sp)
ffffffffc0200a70:	68aa                	ld	a7,136(sp)
ffffffffc0200a72:	694a                	ld	s2,144(sp)
ffffffffc0200a74:	69ea                	ld	s3,152(sp)
ffffffffc0200a76:	7a0a                	ld	s4,160(sp)
ffffffffc0200a78:	7aaa                	ld	s5,168(sp)
ffffffffc0200a7a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a7c:	7bea                	ld	s7,184(sp)
ffffffffc0200a7e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a80:	6cae                	ld	s9,200(sp)
ffffffffc0200a82:	6d4e                	ld	s10,208(sp)
ffffffffc0200a84:	6dee                	ld	s11,216(sp)
ffffffffc0200a86:	7e0e                	ld	t3,224(sp)
ffffffffc0200a88:	7eae                	ld	t4,232(sp)
ffffffffc0200a8a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a8c:	7fee                	ld	t6,248(sp)
ffffffffc0200a8e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200a90:	10200073          	sret
	...

ffffffffc0200aa0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200aa0:	00010797          	auipc	a5,0x10
ffffffffc0200aa4:	5a078793          	addi	a5,a5,1440 # ffffffffc0211040 <free_area>
ffffffffc0200aa8:	e79c                	sd	a5,8(a5)
ffffffffc0200aaa:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aac:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ab0:	8082                	ret

ffffffffc0200ab2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ab2:	00010517          	auipc	a0,0x10
ffffffffc0200ab6:	59e56503          	lwu	a0,1438(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200aba:	8082                	ret

ffffffffc0200abc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200abc:	711d                	addi	sp,sp,-96
ffffffffc0200abe:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ac0:	00010917          	auipc	s2,0x10
ffffffffc0200ac4:	58090913          	addi	s2,s2,1408 # ffffffffc0211040 <free_area>
ffffffffc0200ac8:	00893783          	ld	a5,8(s2)
ffffffffc0200acc:	ec86                	sd	ra,88(sp)
ffffffffc0200ace:	e8a2                	sd	s0,80(sp)
ffffffffc0200ad0:	e4a6                	sd	s1,72(sp)
ffffffffc0200ad2:	fc4e                	sd	s3,56(sp)
ffffffffc0200ad4:	f852                	sd	s4,48(sp)
ffffffffc0200ad6:	f456                	sd	s5,40(sp)
ffffffffc0200ad8:	f05a                	sd	s6,32(sp)
ffffffffc0200ada:	ec5e                	sd	s7,24(sp)
ffffffffc0200adc:	e862                	sd	s8,16(sp)
ffffffffc0200ade:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ae0:	31278063          	beq	a5,s2,ffffffffc0200de0 <default_check+0x324>
    int count = 0, total = 0;
ffffffffc0200ae4:	4401                	li	s0,0
ffffffffc0200ae6:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ae8:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200aec:	8b09                	andi	a4,a4,2
ffffffffc0200aee:	2e070d63          	beqz	a4,ffffffffc0200de8 <default_check+0x32c>
        count ++, total += p->property;
ffffffffc0200af2:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200af6:	679c                	ld	a5,8(a5)
ffffffffc0200af8:	2485                	addiw	s1,s1,1
ffffffffc0200afa:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200afc:	ff2796e3          	bne	a5,s2,ffffffffc0200ae8 <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200b00:	89a2                	mv	s3,s0
ffffffffc0200b02:	3a3000ef          	jal	ffffffffc02016a4 <nr_free_pages>
ffffffffc0200b06:	75351163          	bne	a0,s3,ffffffffc0201248 <default_check+0x78c>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b0a:	4505                	li	a0,1
ffffffffc0200b0c:	2d1000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200b10:	8aaa                	mv	s5,a0
ffffffffc0200b12:	46050b63          	beqz	a0,ffffffffc0200f88 <default_check+0x4cc>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b16:	4505                	li	a0,1
ffffffffc0200b18:	2c5000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200b1c:	89aa                	mv	s3,a0
ffffffffc0200b1e:	74050563          	beqz	a0,ffffffffc0201268 <default_check+0x7ac>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b22:	4505                	li	a0,1
ffffffffc0200b24:	2b9000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200b28:	8a2a                	mv	s4,a0
ffffffffc0200b2a:	4c050f63          	beqz	a0,ffffffffc0201008 <default_check+0x54c>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b2e:	2d3a8d63          	beq	s5,s3,ffffffffc0200e08 <default_check+0x34c>
ffffffffc0200b32:	2caa8b63          	beq	s5,a0,ffffffffc0200e08 <default_check+0x34c>
ffffffffc0200b36:	2ca98963          	beq	s3,a0,ffffffffc0200e08 <default_check+0x34c>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b3a:	000aa783          	lw	a5,0(s5)
ffffffffc0200b3e:	2e079563          	bnez	a5,ffffffffc0200e28 <default_check+0x36c>
ffffffffc0200b42:	0009a783          	lw	a5,0(s3)
ffffffffc0200b46:	2e079163          	bnez	a5,ffffffffc0200e28 <default_check+0x36c>
ffffffffc0200b4a:	411c                	lw	a5,0(a0)
ffffffffc0200b4c:	2c079e63          	bnez	a5,ffffffffc0200e28 <default_check+0x36c>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b50:	00011797          	auipc	a5,0x11
ffffffffc0200b54:	9e87b783          	ld	a5,-1560(a5) # ffffffffc0211538 <pages>
ffffffffc0200b58:	8e38e737          	lui	a4,0x8e38e
ffffffffc0200b5c:	38e70713          	addi	a4,a4,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc0200b60:	38e39637          	lui	a2,0x38e39
ffffffffc0200b64:	e3960613          	addi	a2,a2,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0200b68:	1702                	slli	a4,a4,0x20
ffffffffc0200b6a:	40fa86b3          	sub	a3,s5,a5
ffffffffc0200b6e:	9732                	add	a4,a4,a2
ffffffffc0200b70:	868d                	srai	a3,a3,0x3
ffffffffc0200b72:	02e686b3          	mul	a3,a3,a4
ffffffffc0200b76:	00005597          	auipc	a1,0x5
ffffffffc0200b7a:	4fa5b583          	ld	a1,1274(a1) # ffffffffc0206070 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b7e:	00011617          	auipc	a2,0x11
ffffffffc0200b82:	9b263603          	ld	a2,-1614(a2) # ffffffffc0211530 <npage>
ffffffffc0200b86:	0632                	slli	a2,a2,0xc
ffffffffc0200b88:	96ae                	add	a3,a3,a1

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b8a:	06b2                	slli	a3,a3,0xc
ffffffffc0200b8c:	2ac6fe63          	bgeu	a3,a2,ffffffffc0200e48 <default_check+0x38c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b90:	40f986b3          	sub	a3,s3,a5
ffffffffc0200b94:	868d                	srai	a3,a3,0x3
ffffffffc0200b96:	02e686b3          	mul	a3,a3,a4
ffffffffc0200b9a:	96ae                	add	a3,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b9c:	06b2                	slli	a3,a3,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b9e:	4ec6f563          	bgeu	a3,a2,ffffffffc0201088 <default_check+0x5cc>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ba6:	878d                	srai	a5,a5,0x3
ffffffffc0200ba8:	02e787b3          	mul	a5,a5,a4
ffffffffc0200bac:	97ae                	add	a5,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bae:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bb0:	32c7fc63          	bgeu	a5,a2,ffffffffc0200ee8 <default_check+0x42c>
    assert(alloc_page() == NULL);
ffffffffc0200bb4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bb6:	00093c03          	ld	s8,0(s2)
ffffffffc0200bba:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bbe:	00010b17          	auipc	s6,0x10
ffffffffc0200bc2:	492b2b03          	lw	s6,1170(s6) # ffffffffc0211050 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200bc6:	01293023          	sd	s2,0(s2)
ffffffffc0200bca:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200bce:	00010797          	auipc	a5,0x10
ffffffffc0200bd2:	4807a123          	sw	zero,1154(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bd6:	207000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200bda:	2e051763          	bnez	a0,ffffffffc0200ec8 <default_check+0x40c>
    free_page(p0);
ffffffffc0200bde:	8556                	mv	a0,s5
ffffffffc0200be0:	4585                	li	a1,1
ffffffffc0200be2:	283000ef          	jal	ffffffffc0201664 <free_pages>
    free_page(p1);
ffffffffc0200be6:	854e                	mv	a0,s3
ffffffffc0200be8:	4585                	li	a1,1
ffffffffc0200bea:	27b000ef          	jal	ffffffffc0201664 <free_pages>
    free_page(p2);
ffffffffc0200bee:	8552                	mv	a0,s4
ffffffffc0200bf0:	4585                	li	a1,1
ffffffffc0200bf2:	273000ef          	jal	ffffffffc0201664 <free_pages>
    assert(nr_free == 3);
ffffffffc0200bf6:	00010717          	auipc	a4,0x10
ffffffffc0200bfa:	45a72703          	lw	a4,1114(a4) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200bfe:	478d                	li	a5,3
ffffffffc0200c00:	2af71463          	bne	a4,a5,ffffffffc0200ea8 <default_check+0x3ec>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c04:	4505                	li	a0,1
ffffffffc0200c06:	1d7000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200c0a:	89aa                	mv	s3,a0
ffffffffc0200c0c:	26050e63          	beqz	a0,ffffffffc0200e88 <default_check+0x3cc>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c10:	4505                	li	a0,1
ffffffffc0200c12:	1cb000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200c16:	8aaa                	mv	s5,a0
ffffffffc0200c18:	3c050863          	beqz	a0,ffffffffc0200fe8 <default_check+0x52c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c1c:	4505                	li	a0,1
ffffffffc0200c1e:	1bf000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200c22:	8a2a                	mv	s4,a0
ffffffffc0200c24:	3a050263          	beqz	a0,ffffffffc0200fc8 <default_check+0x50c>
    assert(alloc_page() == NULL);
ffffffffc0200c28:	4505                	li	a0,1
ffffffffc0200c2a:	1b3000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200c2e:	36051d63          	bnez	a0,ffffffffc0200fa8 <default_check+0x4ec>
    free_page(p0);
ffffffffc0200c32:	4585                	li	a1,1
ffffffffc0200c34:	854e                	mv	a0,s3
ffffffffc0200c36:	22f000ef          	jal	ffffffffc0201664 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c3a:	00893783          	ld	a5,8(s2)
ffffffffc0200c3e:	23278563          	beq	a5,s2,ffffffffc0200e68 <default_check+0x3ac>
    assert((p = alloc_page()) == p0);
ffffffffc0200c42:	4505                	li	a0,1
ffffffffc0200c44:	199000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200c48:	32a99063          	bne	s3,a0,ffffffffc0200f68 <default_check+0x4ac>
    assert(alloc_page() == NULL);
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	18f000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200c52:	2e051b63          	bnez	a0,ffffffffc0200f48 <default_check+0x48c>
    assert(nr_free == 0);
ffffffffc0200c56:	00010797          	auipc	a5,0x10
ffffffffc0200c5a:	3fa7a783          	lw	a5,1018(a5) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200c5e:	2c079563          	bnez	a5,ffffffffc0200f28 <default_check+0x46c>
    free_page(p);
ffffffffc0200c62:	854e                	mv	a0,s3
ffffffffc0200c64:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c66:	01893023          	sd	s8,0(s2)
ffffffffc0200c6a:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0200c6e:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0200c72:	1f3000ef          	jal	ffffffffc0201664 <free_pages>
    free_page(p1);
ffffffffc0200c76:	8556                	mv	a0,s5
ffffffffc0200c78:	4585                	li	a1,1
ffffffffc0200c7a:	1eb000ef          	jal	ffffffffc0201664 <free_pages>
    free_page(p2);
ffffffffc0200c7e:	8552                	mv	a0,s4
ffffffffc0200c80:	4585                	li	a1,1
ffffffffc0200c82:	1e3000ef          	jal	ffffffffc0201664 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c86:	4515                	li	a0,5
ffffffffc0200c88:	155000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200c8c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c8e:	26050d63          	beqz	a0,ffffffffc0200f08 <default_check+0x44c>
ffffffffc0200c92:	651c                	ld	a5,8(a0)
ffffffffc0200c94:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c96:	8b85                	andi	a5,a5,1
ffffffffc0200c98:	54079863          	bnez	a5,ffffffffc02011e8 <default_check+0x72c>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c9c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c9e:	00093b83          	ld	s7,0(s2)
ffffffffc0200ca2:	00893b03          	ld	s6,8(s2)
ffffffffc0200ca6:	01293023          	sd	s2,0(s2)
ffffffffc0200caa:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0200cae:	12f000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200cb2:	50051b63          	bnez	a0,ffffffffc02011c8 <default_check+0x70c>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cb6:	09098a13          	addi	s4,s3,144
ffffffffc0200cba:	8552                	mv	a0,s4
ffffffffc0200cbc:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200cbe:	00010c17          	auipc	s8,0x10
ffffffffc0200cc2:	392c2c03          	lw	s8,914(s8) # ffffffffc0211050 <free_area+0x10>
    nr_free = 0;
ffffffffc0200cc6:	00010797          	auipc	a5,0x10
ffffffffc0200cca:	3807a523          	sw	zero,906(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cce:	197000ef          	jal	ffffffffc0201664 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cd2:	4511                	li	a0,4
ffffffffc0200cd4:	109000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200cd8:	4c051863          	bnez	a0,ffffffffc02011a8 <default_check+0x6ec>
ffffffffc0200cdc:	0989b783          	ld	a5,152(s3)
ffffffffc0200ce0:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200ce2:	8b85                	andi	a5,a5,1
ffffffffc0200ce4:	4a078263          	beqz	a5,ffffffffc0201188 <default_check+0x6cc>
ffffffffc0200ce8:	0a89a503          	lw	a0,168(s3)
ffffffffc0200cec:	478d                	li	a5,3
ffffffffc0200cee:	48f51d63          	bne	a0,a5,ffffffffc0201188 <default_check+0x6cc>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cf2:	0eb000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200cf6:	8aaa                	mv	s5,a0
ffffffffc0200cf8:	46050863          	beqz	a0,ffffffffc0201168 <default_check+0x6ac>
    assert(alloc_page() == NULL);
ffffffffc0200cfc:	4505                	li	a0,1
ffffffffc0200cfe:	0df000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200d02:	44051363          	bnez	a0,ffffffffc0201148 <default_check+0x68c>
    assert(p0 + 2 == p1);
ffffffffc0200d06:	435a1163          	bne	s4,s5,ffffffffc0201128 <default_check+0x66c>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d0a:	4585                	li	a1,1
ffffffffc0200d0c:	854e                	mv	a0,s3
ffffffffc0200d0e:	157000ef          	jal	ffffffffc0201664 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d12:	8552                	mv	a0,s4
ffffffffc0200d14:	458d                	li	a1,3
ffffffffc0200d16:	14f000ef          	jal	ffffffffc0201664 <free_pages>
ffffffffc0200d1a:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d1e:	04898c93          	addi	s9,s3,72
ffffffffc0200d22:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d24:	8b85                	andi	a5,a5,1
ffffffffc0200d26:	3e078163          	beqz	a5,ffffffffc0201108 <default_check+0x64c>
ffffffffc0200d2a:	0189aa83          	lw	s5,24(s3)
ffffffffc0200d2e:	4785                	li	a5,1
ffffffffc0200d30:	3cfa9c63          	bne	s5,a5,ffffffffc0201108 <default_check+0x64c>
ffffffffc0200d34:	008a3783          	ld	a5,8(s4)
ffffffffc0200d38:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d3a:	8b85                	andi	a5,a5,1
ffffffffc0200d3c:	3a078663          	beqz	a5,ffffffffc02010e8 <default_check+0x62c>
ffffffffc0200d40:	018a2703          	lw	a4,24(s4)
ffffffffc0200d44:	478d                	li	a5,3
ffffffffc0200d46:	3af71163          	bne	a4,a5,ffffffffc02010e8 <default_check+0x62c>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d4a:	8556                	mv	a0,s5
ffffffffc0200d4c:	091000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200d50:	36a99c63          	bne	s3,a0,ffffffffc02010c8 <default_check+0x60c>
    free_page(p0);
ffffffffc0200d54:	85d6                	mv	a1,s5
ffffffffc0200d56:	10f000ef          	jal	ffffffffc0201664 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d5a:	4509                	li	a0,2
ffffffffc0200d5c:	081000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200d60:	34aa1463          	bne	s4,a0,ffffffffc02010a8 <default_check+0x5ec>

    free_pages(p0, 2);
ffffffffc0200d64:	4589                	li	a1,2
ffffffffc0200d66:	0ff000ef          	jal	ffffffffc0201664 <free_pages>
    free_page(p2);
ffffffffc0200d6a:	85d6                	mv	a1,s5
ffffffffc0200d6c:	8566                	mv	a0,s9
ffffffffc0200d6e:	0f7000ef          	jal	ffffffffc0201664 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d72:	4515                	li	a0,5
ffffffffc0200d74:	069000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200d78:	89aa                	mv	s3,a0
ffffffffc0200d7a:	48050763          	beqz	a0,ffffffffc0201208 <default_check+0x74c>
    assert(alloc_page() == NULL);
ffffffffc0200d7e:	8556                	mv	a0,s5
ffffffffc0200d80:	05d000ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0200d84:	2e051263          	bnez	a0,ffffffffc0201068 <default_check+0x5ac>

    assert(nr_free == 0);
ffffffffc0200d88:	00010797          	auipc	a5,0x10
ffffffffc0200d8c:	2c87a783          	lw	a5,712(a5) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200d90:	2a079c63          	bnez	a5,ffffffffc0201048 <default_check+0x58c>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d94:	854e                	mv	a0,s3
ffffffffc0200d96:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0200d98:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0200d9c:	01793023          	sd	s7,0(s2)
ffffffffc0200da0:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0200da4:	0c1000ef          	jal	ffffffffc0201664 <free_pages>
    return listelm->next;
ffffffffc0200da8:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dac:	01278963          	beq	a5,s2,ffffffffc0200dbe <default_check+0x302>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200db0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200db4:	679c                	ld	a5,8(a5)
ffffffffc0200db6:	34fd                	addiw	s1,s1,-1
ffffffffc0200db8:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dba:	ff279be3          	bne	a5,s2,ffffffffc0200db0 <default_check+0x2f4>
    }
    assert(count == 0);
ffffffffc0200dbe:	26049563          	bnez	s1,ffffffffc0201028 <default_check+0x56c>
    assert(total == 0);
ffffffffc0200dc2:	46041363          	bnez	s0,ffffffffc0201228 <default_check+0x76c>
}
ffffffffc0200dc6:	60e6                	ld	ra,88(sp)
ffffffffc0200dc8:	6446                	ld	s0,80(sp)
ffffffffc0200dca:	64a6                	ld	s1,72(sp)
ffffffffc0200dcc:	6906                	ld	s2,64(sp)
ffffffffc0200dce:	79e2                	ld	s3,56(sp)
ffffffffc0200dd0:	7a42                	ld	s4,48(sp)
ffffffffc0200dd2:	7aa2                	ld	s5,40(sp)
ffffffffc0200dd4:	7b02                	ld	s6,32(sp)
ffffffffc0200dd6:	6be2                	ld	s7,24(sp)
ffffffffc0200dd8:	6c42                	ld	s8,16(sp)
ffffffffc0200dda:	6ca2                	ld	s9,8(sp)
ffffffffc0200ddc:	6125                	addi	sp,sp,96
ffffffffc0200dde:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200de0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200de2:	4401                	li	s0,0
ffffffffc0200de4:	4481                	li	s1,0
ffffffffc0200de6:	bb31                	j	ffffffffc0200b02 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0200de8:	00004697          	auipc	a3,0x4
ffffffffc0200dec:	d8868693          	addi	a3,a3,-632 # ffffffffc0204b70 <etext+0x8c8>
ffffffffc0200df0:	00004617          	auipc	a2,0x4
ffffffffc0200df4:	d9060613          	addi	a2,a2,-624 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200df8:	0f000593          	li	a1,240
ffffffffc0200dfc:	00004517          	auipc	a0,0x4
ffffffffc0200e00:	d9c50513          	addi	a0,a0,-612 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200e04:	d48ff0ef          	jal	ffffffffc020034c <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e08:	00004697          	auipc	a3,0x4
ffffffffc0200e0c:	e2868693          	addi	a3,a3,-472 # ffffffffc0204c30 <etext+0x988>
ffffffffc0200e10:	00004617          	auipc	a2,0x4
ffffffffc0200e14:	d7060613          	addi	a2,a2,-656 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200e18:	0bd00593          	li	a1,189
ffffffffc0200e1c:	00004517          	auipc	a0,0x4
ffffffffc0200e20:	d7c50513          	addi	a0,a0,-644 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200e24:	d28ff0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e28:	00004697          	auipc	a3,0x4
ffffffffc0200e2c:	e3068693          	addi	a3,a3,-464 # ffffffffc0204c58 <etext+0x9b0>
ffffffffc0200e30:	00004617          	auipc	a2,0x4
ffffffffc0200e34:	d5060613          	addi	a2,a2,-688 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200e38:	0be00593          	li	a1,190
ffffffffc0200e3c:	00004517          	auipc	a0,0x4
ffffffffc0200e40:	d5c50513          	addi	a0,a0,-676 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200e44:	d08ff0ef          	jal	ffffffffc020034c <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e48:	00004697          	auipc	a3,0x4
ffffffffc0200e4c:	e5068693          	addi	a3,a3,-432 # ffffffffc0204c98 <etext+0x9f0>
ffffffffc0200e50:	00004617          	auipc	a2,0x4
ffffffffc0200e54:	d3060613          	addi	a2,a2,-720 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200e58:	0c000593          	li	a1,192
ffffffffc0200e5c:	00004517          	auipc	a0,0x4
ffffffffc0200e60:	d3c50513          	addi	a0,a0,-708 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200e64:	ce8ff0ef          	jal	ffffffffc020034c <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e68:	00004697          	auipc	a3,0x4
ffffffffc0200e6c:	eb868693          	addi	a3,a3,-328 # ffffffffc0204d20 <etext+0xa78>
ffffffffc0200e70:	00004617          	auipc	a2,0x4
ffffffffc0200e74:	d1060613          	addi	a2,a2,-752 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200e78:	0d900593          	li	a1,217
ffffffffc0200e7c:	00004517          	auipc	a0,0x4
ffffffffc0200e80:	d1c50513          	addi	a0,a0,-740 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200e84:	cc8ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e88:	00004697          	auipc	a3,0x4
ffffffffc0200e8c:	d4868693          	addi	a3,a3,-696 # ffffffffc0204bd0 <etext+0x928>
ffffffffc0200e90:	00004617          	auipc	a2,0x4
ffffffffc0200e94:	cf060613          	addi	a2,a2,-784 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200e98:	0d200593          	li	a1,210
ffffffffc0200e9c:	00004517          	auipc	a0,0x4
ffffffffc0200ea0:	cfc50513          	addi	a0,a0,-772 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200ea4:	ca8ff0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free == 3);
ffffffffc0200ea8:	00004697          	auipc	a3,0x4
ffffffffc0200eac:	e6868693          	addi	a3,a3,-408 # ffffffffc0204d10 <etext+0xa68>
ffffffffc0200eb0:	00004617          	auipc	a2,0x4
ffffffffc0200eb4:	cd060613          	addi	a2,a2,-816 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200eb8:	0d000593          	li	a1,208
ffffffffc0200ebc:	00004517          	auipc	a0,0x4
ffffffffc0200ec0:	cdc50513          	addi	a0,a0,-804 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200ec4:	c88ff0ef          	jal	ffffffffc020034c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ec8:	00004697          	auipc	a3,0x4
ffffffffc0200ecc:	e3068693          	addi	a3,a3,-464 # ffffffffc0204cf8 <etext+0xa50>
ffffffffc0200ed0:	00004617          	auipc	a2,0x4
ffffffffc0200ed4:	cb060613          	addi	a2,a2,-848 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200ed8:	0cb00593          	li	a1,203
ffffffffc0200edc:	00004517          	auipc	a0,0x4
ffffffffc0200ee0:	cbc50513          	addi	a0,a0,-836 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200ee4:	c68ff0ef          	jal	ffffffffc020034c <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ee8:	00004697          	auipc	a3,0x4
ffffffffc0200eec:	df068693          	addi	a3,a3,-528 # ffffffffc0204cd8 <etext+0xa30>
ffffffffc0200ef0:	00004617          	auipc	a2,0x4
ffffffffc0200ef4:	c9060613          	addi	a2,a2,-880 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200ef8:	0c200593          	li	a1,194
ffffffffc0200efc:	00004517          	auipc	a0,0x4
ffffffffc0200f00:	c9c50513          	addi	a0,a0,-868 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200f04:	c48ff0ef          	jal	ffffffffc020034c <__panic>
    assert(p0 != NULL);
ffffffffc0200f08:	00004697          	auipc	a3,0x4
ffffffffc0200f0c:	e6068693          	addi	a3,a3,-416 # ffffffffc0204d68 <etext+0xac0>
ffffffffc0200f10:	00004617          	auipc	a2,0x4
ffffffffc0200f14:	c7060613          	addi	a2,a2,-912 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200f18:	0f800593          	li	a1,248
ffffffffc0200f1c:	00004517          	auipc	a0,0x4
ffffffffc0200f20:	c7c50513          	addi	a0,a0,-900 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200f24:	c28ff0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free == 0);
ffffffffc0200f28:	00004697          	auipc	a3,0x4
ffffffffc0200f2c:	e3068693          	addi	a3,a3,-464 # ffffffffc0204d58 <etext+0xab0>
ffffffffc0200f30:	00004617          	auipc	a2,0x4
ffffffffc0200f34:	c5060613          	addi	a2,a2,-944 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200f38:	0df00593          	li	a1,223
ffffffffc0200f3c:	00004517          	auipc	a0,0x4
ffffffffc0200f40:	c5c50513          	addi	a0,a0,-932 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200f44:	c08ff0ef          	jal	ffffffffc020034c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f48:	00004697          	auipc	a3,0x4
ffffffffc0200f4c:	db068693          	addi	a3,a3,-592 # ffffffffc0204cf8 <etext+0xa50>
ffffffffc0200f50:	00004617          	auipc	a2,0x4
ffffffffc0200f54:	c3060613          	addi	a2,a2,-976 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200f58:	0dd00593          	li	a1,221
ffffffffc0200f5c:	00004517          	auipc	a0,0x4
ffffffffc0200f60:	c3c50513          	addi	a0,a0,-964 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200f64:	be8ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f68:	00004697          	auipc	a3,0x4
ffffffffc0200f6c:	dd068693          	addi	a3,a3,-560 # ffffffffc0204d38 <etext+0xa90>
ffffffffc0200f70:	00004617          	auipc	a2,0x4
ffffffffc0200f74:	c1060613          	addi	a2,a2,-1008 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200f78:	0dc00593          	li	a1,220
ffffffffc0200f7c:	00004517          	auipc	a0,0x4
ffffffffc0200f80:	c1c50513          	addi	a0,a0,-996 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200f84:	bc8ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f88:	00004697          	auipc	a3,0x4
ffffffffc0200f8c:	c4868693          	addi	a3,a3,-952 # ffffffffc0204bd0 <etext+0x928>
ffffffffc0200f90:	00004617          	auipc	a2,0x4
ffffffffc0200f94:	bf060613          	addi	a2,a2,-1040 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200f98:	0b900593          	li	a1,185
ffffffffc0200f9c:	00004517          	auipc	a0,0x4
ffffffffc0200fa0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200fa4:	ba8ff0ef          	jal	ffffffffc020034c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa8:	00004697          	auipc	a3,0x4
ffffffffc0200fac:	d5068693          	addi	a3,a3,-688 # ffffffffc0204cf8 <etext+0xa50>
ffffffffc0200fb0:	00004617          	auipc	a2,0x4
ffffffffc0200fb4:	bd060613          	addi	a2,a2,-1072 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200fb8:	0d600593          	li	a1,214
ffffffffc0200fbc:	00004517          	auipc	a0,0x4
ffffffffc0200fc0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200fc4:	b88ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fc8:	00004697          	auipc	a3,0x4
ffffffffc0200fcc:	c4868693          	addi	a3,a3,-952 # ffffffffc0204c10 <etext+0x968>
ffffffffc0200fd0:	00004617          	auipc	a2,0x4
ffffffffc0200fd4:	bb060613          	addi	a2,a2,-1104 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200fd8:	0d400593          	li	a1,212
ffffffffc0200fdc:	00004517          	auipc	a0,0x4
ffffffffc0200fe0:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0200fe4:	b68ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fe8:	00004697          	auipc	a3,0x4
ffffffffc0200fec:	c0868693          	addi	a3,a3,-1016 # ffffffffc0204bf0 <etext+0x948>
ffffffffc0200ff0:	00004617          	auipc	a2,0x4
ffffffffc0200ff4:	b9060613          	addi	a2,a2,-1136 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0200ff8:	0d300593          	li	a1,211
ffffffffc0200ffc:	00004517          	auipc	a0,0x4
ffffffffc0201000:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201004:	b48ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	c0868693          	addi	a3,a3,-1016 # ffffffffc0204c10 <etext+0x968>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	b7060613          	addi	a2,a2,-1168 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201018:	0bb00593          	li	a1,187
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201024:	b28ff0ef          	jal	ffffffffc020034c <__panic>
    assert(count == 0);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	e9068693          	addi	a3,a3,-368 # ffffffffc0204eb8 <etext+0xc10>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	b5060613          	addi	a2,a2,-1200 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201038:	12500593          	li	a1,293
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201044:	b08ff0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free == 0);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	d1068693          	addi	a3,a3,-752 # ffffffffc0204d58 <etext+0xab0>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	b3060613          	addi	a2,a2,-1232 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201058:	11a00593          	li	a1,282
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201064:	ae8ff0ef          	jal	ffffffffc020034c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	c9068693          	addi	a3,a3,-880 # ffffffffc0204cf8 <etext+0xa50>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	b1060613          	addi	a2,a2,-1264 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201078:	11800593          	li	a1,280
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201084:	ac8ff0ef          	jal	ffffffffc020034c <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	c3068693          	addi	a3,a3,-976 # ffffffffc0204cb8 <etext+0xa10>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	af060613          	addi	a2,a2,-1296 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201098:	0c100593          	li	a1,193
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	afc50513          	addi	a0,a0,-1284 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02010a4:	aa8ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	dd068693          	addi	a3,a3,-560 # ffffffffc0204e78 <etext+0xbd0>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	ad060613          	addi	a2,a2,-1328 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02010b8:	11200593          	li	a1,274
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	adc50513          	addi	a0,a0,-1316 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02010c4:	a88ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	d9068693          	addi	a3,a3,-624 # ffffffffc0204e58 <etext+0xbb0>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02010d8:	11000593          	li	a1,272
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	abc50513          	addi	a0,a0,-1348 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02010e4:	a68ff0ef          	jal	ffffffffc020034c <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	d4868693          	addi	a3,a3,-696 # ffffffffc0204e30 <etext+0xb88>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02010f8:	10e00593          	li	a1,270
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	a9c50513          	addi	a0,a0,-1380 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201104:	a48ff0ef          	jal	ffffffffc020034c <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	d0068693          	addi	a3,a3,-768 # ffffffffc0204e08 <etext+0xb60>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	a7060613          	addi	a2,a2,-1424 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201118:	10d00593          	li	a1,269
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201124:	a28ff0ef          	jal	ffffffffc020034c <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	cd068693          	addi	a3,a3,-816 # ffffffffc0204df8 <etext+0xb50>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201138:	10800593          	li	a1,264
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201144:	a08ff0ef          	jal	ffffffffc020034c <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	bb068693          	addi	a3,a3,-1104 # ffffffffc0204cf8 <etext+0xa50>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201158:	10700593          	li	a1,263
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201164:	9e8ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201168:	00004697          	auipc	a3,0x4
ffffffffc020116c:	c7068693          	addi	a3,a3,-912 # ffffffffc0204dd8 <etext+0xb30>
ffffffffc0201170:	00004617          	auipc	a2,0x4
ffffffffc0201174:	a1060613          	addi	a2,a2,-1520 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201178:	10600593          	li	a1,262
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201184:	9c8ff0ef          	jal	ffffffffc020034c <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201188:	00004697          	auipc	a3,0x4
ffffffffc020118c:	c2068693          	addi	a3,a3,-992 # ffffffffc0204da8 <etext+0xb00>
ffffffffc0201190:	00004617          	auipc	a2,0x4
ffffffffc0201194:	9f060613          	addi	a2,a2,-1552 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201198:	10500593          	li	a1,261
ffffffffc020119c:	00004517          	auipc	a0,0x4
ffffffffc02011a0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02011a4:	9a8ff0ef          	jal	ffffffffc020034c <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011a8:	00004697          	auipc	a3,0x4
ffffffffc02011ac:	be868693          	addi	a3,a3,-1048 # ffffffffc0204d90 <etext+0xae8>
ffffffffc02011b0:	00004617          	auipc	a2,0x4
ffffffffc02011b4:	9d060613          	addi	a2,a2,-1584 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02011b8:	10400593          	li	a1,260
ffffffffc02011bc:	00004517          	auipc	a0,0x4
ffffffffc02011c0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02011c4:	988ff0ef          	jal	ffffffffc020034c <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011c8:	00004697          	auipc	a3,0x4
ffffffffc02011cc:	b3068693          	addi	a3,a3,-1232 # ffffffffc0204cf8 <etext+0xa50>
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	9b060613          	addi	a2,a2,-1616 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02011d8:	0fe00593          	li	a1,254
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	9bc50513          	addi	a0,a0,-1604 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02011e4:	968ff0ef          	jal	ffffffffc020034c <__panic>
    assert(!PageProperty(p0));
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	b9068693          	addi	a3,a3,-1136 # ffffffffc0204d78 <etext+0xad0>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	99060613          	addi	a2,a2,-1648 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02011f8:	0f900593          	li	a1,249
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	99c50513          	addi	a0,a0,-1636 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201204:	948ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	c9068693          	addi	a3,a3,-880 # ffffffffc0204e98 <etext+0xbf0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	97060613          	addi	a2,a2,-1680 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201218:	11700593          	li	a1,279
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	97c50513          	addi	a0,a0,-1668 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201224:	928ff0ef          	jal	ffffffffc020034c <__panic>
    assert(total == 0);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	ca068693          	addi	a3,a3,-864 # ffffffffc0204ec8 <etext+0xc20>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	95060613          	addi	a2,a2,-1712 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201238:	12600593          	li	a1,294
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	95c50513          	addi	a0,a0,-1700 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201244:	908ff0ef          	jal	ffffffffc020034c <__panic>
    assert(total == nr_free_pages());
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	96868693          	addi	a3,a3,-1688 # ffffffffc0204bb0 <etext+0x908>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	93060613          	addi	a2,a2,-1744 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201258:	0f300593          	li	a1,243
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	93c50513          	addi	a0,a0,-1732 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201264:	8e8ff0ef          	jal	ffffffffc020034c <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201268:	00004697          	auipc	a3,0x4
ffffffffc020126c:	98868693          	addi	a3,a3,-1656 # ffffffffc0204bf0 <etext+0x948>
ffffffffc0201270:	00004617          	auipc	a2,0x4
ffffffffc0201274:	91060613          	addi	a2,a2,-1776 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201278:	0ba00593          	li	a1,186
ffffffffc020127c:	00004517          	auipc	a0,0x4
ffffffffc0201280:	91c50513          	addi	a0,a0,-1764 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201284:	8c8ff0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0201288 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201288:	1141                	addi	sp,sp,-16
ffffffffc020128a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020128c:	14058d63          	beqz	a1,ffffffffc02013e6 <default_free_pages+0x15e>
    for (; p != base + n; p ++) {
ffffffffc0201290:	00359713          	slli	a4,a1,0x3
ffffffffc0201294:	972e                	add	a4,a4,a1
ffffffffc0201296:	070e                	slli	a4,a4,0x3
ffffffffc0201298:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020129c:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020129e:	c30d                	beqz	a4,ffffffffc02012c0 <default_free_pages+0x38>
ffffffffc02012a0:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012a2:	8b05                	andi	a4,a4,1
ffffffffc02012a4:	12071163          	bnez	a4,ffffffffc02013c6 <default_free_pages+0x13e>
ffffffffc02012a8:	6798                	ld	a4,8(a5)
ffffffffc02012aa:	8b09                	andi	a4,a4,2
ffffffffc02012ac:	10071d63          	bnez	a4,ffffffffc02013c6 <default_free_pages+0x13e>
        p->flags = 0;
ffffffffc02012b0:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012b4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012b8:	04878793          	addi	a5,a5,72
ffffffffc02012bc:	fed792e3          	bne	a5,a3,ffffffffc02012a0 <default_free_pages+0x18>
    base->property = n;
ffffffffc02012c0:	2581                	sext.w	a1,a1
ffffffffc02012c2:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc02012c4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012c8:	4789                	li	a5,2
ffffffffc02012ca:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012ce:	00010717          	auipc	a4,0x10
ffffffffc02012d2:	d8272703          	lw	a4,-638(a4) # ffffffffc0211050 <free_area+0x10>
ffffffffc02012d6:	00010697          	auipc	a3,0x10
ffffffffc02012da:	d6a68693          	addi	a3,a3,-662 # ffffffffc0211040 <free_area>
    return list->next == list;
ffffffffc02012de:	669c                	ld	a5,8(a3)
ffffffffc02012e0:	9f2d                	addw	a4,a4,a1
ffffffffc02012e2:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012e4:	0ad78563          	beq	a5,a3,ffffffffc020138e <default_free_pages+0x106>
            struct Page* page = le2page(le, page_link);
ffffffffc02012e8:	fe078713          	addi	a4,a5,-32
ffffffffc02012ec:	4581                	li	a1,0
ffffffffc02012ee:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02012f2:	00e56a63          	bltu	a0,a4,ffffffffc0201306 <default_free_pages+0x7e>
    return listelm->next;
ffffffffc02012f6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012f8:	06d70263          	beq	a4,a3,ffffffffc020135c <default_free_pages+0xd4>
    struct Page *p = base;
ffffffffc02012fc:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012fe:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201302:	fee57ae3          	bgeu	a0,a4,ffffffffc02012f6 <default_free_pages+0x6e>
ffffffffc0201306:	c199                	beqz	a1,ffffffffc020130c <default_free_pages+0x84>
ffffffffc0201308:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020130c:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020130e:	e390                	sd	a2,0(a5)
ffffffffc0201310:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201312:	f118                	sd	a4,32(a0)
    elm->next = next;
ffffffffc0201314:	f51c                	sd	a5,40(a0)
    if (le != &free_list) {
ffffffffc0201316:	02d70063          	beq	a4,a3,ffffffffc0201336 <default_free_pages+0xae>
        if (p + p->property == base) {
ffffffffc020131a:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020131e:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0201322:	02081613          	slli	a2,a6,0x20
ffffffffc0201326:	9201                	srli	a2,a2,0x20
ffffffffc0201328:	00361793          	slli	a5,a2,0x3
ffffffffc020132c:	97b2                	add	a5,a5,a2
ffffffffc020132e:	078e                	slli	a5,a5,0x3
ffffffffc0201330:	97ae                	add	a5,a5,a1
ffffffffc0201332:	02f50f63          	beq	a0,a5,ffffffffc0201370 <default_free_pages+0xe8>
    return listelm->next;
ffffffffc0201336:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201338:	00d70f63          	beq	a4,a3,ffffffffc0201356 <default_free_pages+0xce>
        if (base + base->property == p) {
ffffffffc020133c:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc020133e:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc0201342:	02059613          	slli	a2,a1,0x20
ffffffffc0201346:	9201                	srli	a2,a2,0x20
ffffffffc0201348:	00361793          	slli	a5,a2,0x3
ffffffffc020134c:	97b2                	add	a5,a5,a2
ffffffffc020134e:	078e                	slli	a5,a5,0x3
ffffffffc0201350:	97aa                	add	a5,a5,a0
ffffffffc0201352:	04f68a63          	beq	a3,a5,ffffffffc02013a6 <default_free_pages+0x11e>
}
ffffffffc0201356:	60a2                	ld	ra,8(sp)
ffffffffc0201358:	0141                	addi	sp,sp,16
ffffffffc020135a:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020135c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020135e:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201360:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201362:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc0201364:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201366:	02d70d63          	beq	a4,a3,ffffffffc02013a0 <default_free_pages+0x118>
ffffffffc020136a:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020136c:	87ba                	mv	a5,a4
ffffffffc020136e:	bf41                	j	ffffffffc02012fe <default_free_pages+0x76>
            p->property += base->property;
ffffffffc0201370:	4d1c                	lw	a5,24(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201372:	5675                	li	a2,-3
ffffffffc0201374:	010787bb          	addw	a5,a5,a6
ffffffffc0201378:	fef72c23          	sw	a5,-8(a4)
ffffffffc020137c:	60c8b02f          	amoand.d	zero,a2,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201380:	7110                	ld	a2,32(a0)
ffffffffc0201382:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc0201384:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201386:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201388:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc020138a:	e390                	sd	a2,0(a5)
ffffffffc020138c:	b775                	j	ffffffffc0201338 <default_free_pages+0xb0>
}
ffffffffc020138e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201390:	02050713          	addi	a4,a0,32
    elm->next = next;
ffffffffc0201394:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201396:	f11c                	sd	a5,32(a0)
    prev->next = next->prev = elm;
ffffffffc0201398:	e398                	sd	a4,0(a5)
ffffffffc020139a:	e798                	sd	a4,8(a5)
}
ffffffffc020139c:	0141                	addi	sp,sp,16
ffffffffc020139e:	8082                	ret
ffffffffc02013a0:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013a2:	873e                	mv	a4,a5
ffffffffc02013a4:	bf8d                	j	ffffffffc0201316 <default_free_pages+0x8e>
            base->property += p->property;
ffffffffc02013a6:	ff872783          	lw	a5,-8(a4)
ffffffffc02013aa:	56f5                	li	a3,-3
ffffffffc02013ac:	9fad                	addw	a5,a5,a1
ffffffffc02013ae:	cd1c                	sw	a5,24(a0)
ffffffffc02013b0:	fe870793          	addi	a5,a4,-24
ffffffffc02013b4:	60d7b02f          	amoand.d	zero,a3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013b8:	6314                	ld	a3,0(a4)
ffffffffc02013ba:	671c                	ld	a5,8(a4)
}
ffffffffc02013bc:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02013be:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02013c0:	e394                	sd	a3,0(a5)
ffffffffc02013c2:	0141                	addi	sp,sp,16
ffffffffc02013c4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02013c6:	00004697          	auipc	a3,0x4
ffffffffc02013ca:	b1a68693          	addi	a3,a3,-1254 # ffffffffc0204ee0 <etext+0xc38>
ffffffffc02013ce:	00003617          	auipc	a2,0x3
ffffffffc02013d2:	7b260613          	addi	a2,a2,1970 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02013d6:	08300593          	li	a1,131
ffffffffc02013da:	00003517          	auipc	a0,0x3
ffffffffc02013de:	7be50513          	addi	a0,a0,1982 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02013e2:	f6bfe0ef          	jal	ffffffffc020034c <__panic>
    assert(n > 0);
ffffffffc02013e6:	00004697          	auipc	a3,0x4
ffffffffc02013ea:	af268693          	addi	a3,a3,-1294 # ffffffffc0204ed8 <etext+0xc30>
ffffffffc02013ee:	00003617          	auipc	a2,0x3
ffffffffc02013f2:	79260613          	addi	a2,a2,1938 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02013f6:	08000593          	li	a1,128
ffffffffc02013fa:	00003517          	auipc	a0,0x3
ffffffffc02013fe:	79e50513          	addi	a0,a0,1950 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc0201402:	f4bfe0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0201406 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201406:	cd51                	beqz	a0,ffffffffc02014a2 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc0201408:	00010597          	auipc	a1,0x10
ffffffffc020140c:	c485a583          	lw	a1,-952(a1) # ffffffffc0211050 <free_area+0x10>
ffffffffc0201410:	86aa                	mv	a3,a0
ffffffffc0201412:	00010617          	auipc	a2,0x10
ffffffffc0201416:	c2e60613          	addi	a2,a2,-978 # ffffffffc0211040 <free_area>
ffffffffc020141a:	02059793          	slli	a5,a1,0x20
ffffffffc020141e:	9381                	srli	a5,a5,0x20
ffffffffc0201420:	00a7eb63          	bltu	a5,a0,ffffffffc0201436 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0201424:	87b2                	mv	a5,a2
ffffffffc0201426:	a029                	j	ffffffffc0201430 <default_alloc_pages+0x2a>
        if (p->property >= n) {
ffffffffc0201428:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020142c:	00d77763          	bgeu	a4,a3,ffffffffc020143a <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc0201430:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201432:	fec79be3          	bne	a5,a2,ffffffffc0201428 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201436:	4501                	li	a0,0
}
ffffffffc0201438:	8082                	ret
        if (page->property > n) {
ffffffffc020143a:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc020143e:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201442:	6798                	ld	a4,8(a5)
ffffffffc0201444:	02089e13          	slli	t3,a7,0x20
ffffffffc0201448:	020e5e13          	srli	t3,t3,0x20
    prev->next = next;
ffffffffc020144c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201450:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0201454:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc0201458:	0006831b          	sext.w	t1,a3
        if (page->property > n) {
ffffffffc020145c:	03c6fb63          	bgeu	a3,t3,ffffffffc0201492 <default_alloc_pages+0x8c>
            struct Page *p = page + n;
ffffffffc0201460:	00369713          	slli	a4,a3,0x3
ffffffffc0201464:	9736                	add	a4,a4,a3
ffffffffc0201466:	070e                	slli	a4,a4,0x3
            p->property = page->property - n;
ffffffffc0201468:	406888bb          	subw	a7,a7,t1
            struct Page *p = page + n;
ffffffffc020146c:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020146e:	01172c23          	sw	a7,24(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201472:	4689                	li	a3,2
ffffffffc0201474:	00870893          	addi	a7,a4,8
ffffffffc0201478:	40d8b02f          	amoor.d	zero,a3,(a7)
    __list_add(elm, listelm, listelm->next);
ffffffffc020147c:	00883683          	ld	a3,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0201480:	02070893          	addi	a7,a4,32
    prev->next = next->prev = elm;
ffffffffc0201484:	0116b023          	sd	a7,0(a3)
ffffffffc0201488:	01183423          	sd	a7,8(a6)
    elm->next = next;
ffffffffc020148c:	f714                	sd	a3,40(a4)
    elm->prev = prev;
ffffffffc020148e:	03073023          	sd	a6,32(a4)
        nr_free -= n;
ffffffffc0201492:	406585bb          	subw	a1,a1,t1
ffffffffc0201496:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201498:	5775                	li	a4,-3
ffffffffc020149a:	17a1                	addi	a5,a5,-24
ffffffffc020149c:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02014a0:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014a2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014a4:	00004697          	auipc	a3,0x4
ffffffffc02014a8:	a3468693          	addi	a3,a3,-1484 # ffffffffc0204ed8 <etext+0xc30>
ffffffffc02014ac:	00003617          	auipc	a2,0x3
ffffffffc02014b0:	6d460613          	addi	a2,a2,1748 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02014b4:	06200593          	li	a1,98
ffffffffc02014b8:	00003517          	auipc	a0,0x3
ffffffffc02014bc:	6e050513          	addi	a0,a0,1760 # ffffffffc0204b98 <etext+0x8f0>
default_alloc_pages(size_t n) {
ffffffffc02014c0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014c2:	e8bfe0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02014c6 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02014c6:	1141                	addi	sp,sp,-16
ffffffffc02014c8:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014ca:	c9f9                	beqz	a1,ffffffffc02015a0 <default_init_memmap+0xda>
    for (; p != base + n; p ++) {
ffffffffc02014cc:	00359713          	slli	a4,a1,0x3
ffffffffc02014d0:	972e                	add	a4,a4,a1
ffffffffc02014d2:	070e                	slli	a4,a4,0x3
ffffffffc02014d4:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02014d8:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02014da:	cf11                	beqz	a4,ffffffffc02014f6 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014dc:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014de:	8b05                	andi	a4,a4,1
ffffffffc02014e0:	c345                	beqz	a4,ffffffffc0201580 <default_init_memmap+0xba>
        p->flags = p->property = 0;
ffffffffc02014e2:	0007ac23          	sw	zero,24(a5)
ffffffffc02014e6:	0007b423          	sd	zero,8(a5)
ffffffffc02014ea:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014ee:	04878793          	addi	a5,a5,72
ffffffffc02014f2:	fed795e3          	bne	a5,a3,ffffffffc02014dc <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014f6:	2581                	sext.w	a1,a1
ffffffffc02014f8:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014fa:	4789                	li	a5,2
ffffffffc02014fc:	00850713          	addi	a4,a0,8
ffffffffc0201500:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201504:	00010717          	auipc	a4,0x10
ffffffffc0201508:	b4c72703          	lw	a4,-1204(a4) # ffffffffc0211050 <free_area+0x10>
ffffffffc020150c:	00010697          	auipc	a3,0x10
ffffffffc0201510:	b3468693          	addi	a3,a3,-1228 # ffffffffc0211040 <free_area>
    return list->next == list;
ffffffffc0201514:	669c                	ld	a5,8(a3)
ffffffffc0201516:	9f2d                	addw	a4,a4,a1
ffffffffc0201518:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020151a:	04d78663          	beq	a5,a3,ffffffffc0201566 <default_init_memmap+0xa0>
            struct Page* page = le2page(le, page_link);
ffffffffc020151e:	fe078713          	addi	a4,a5,-32
ffffffffc0201522:	4581                	li	a1,0
ffffffffc0201524:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201528:	00e56a63          	bltu	a0,a4,ffffffffc020153c <default_init_memmap+0x76>
    return listelm->next;
ffffffffc020152c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020152e:	02d70263          	beq	a4,a3,ffffffffc0201552 <default_init_memmap+0x8c>
    struct Page *p = base;
ffffffffc0201532:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201534:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201538:	fee57ae3          	bgeu	a0,a4,ffffffffc020152c <default_init_memmap+0x66>
ffffffffc020153c:	c199                	beqz	a1,ffffffffc0201542 <default_init_memmap+0x7c>
ffffffffc020153e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201542:	6398                	ld	a4,0(a5)
}
ffffffffc0201544:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201546:	e390                	sd	a2,0(a5)
ffffffffc0201548:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc020154a:	f118                	sd	a4,32(a0)
    elm->next = next;
ffffffffc020154c:	f51c                	sd	a5,40(a0)
ffffffffc020154e:	0141                	addi	sp,sp,16
ffffffffc0201550:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201552:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201554:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201556:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201558:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020155a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020155c:	00d70e63          	beq	a4,a3,ffffffffc0201578 <default_init_memmap+0xb2>
ffffffffc0201560:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201562:	87ba                	mv	a5,a4
ffffffffc0201564:	bfc1                	j	ffffffffc0201534 <default_init_memmap+0x6e>
}
ffffffffc0201566:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201568:	02050713          	addi	a4,a0,32
    elm->next = next;
ffffffffc020156c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020156e:	f11c                	sd	a5,32(a0)
    prev->next = next->prev = elm;
ffffffffc0201570:	e398                	sd	a4,0(a5)
ffffffffc0201572:	e798                	sd	a4,8(a5)
}
ffffffffc0201574:	0141                	addi	sp,sp,16
ffffffffc0201576:	8082                	ret
ffffffffc0201578:	60a2                	ld	ra,8(sp)
ffffffffc020157a:	e290                	sd	a2,0(a3)
ffffffffc020157c:	0141                	addi	sp,sp,16
ffffffffc020157e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201580:	00004697          	auipc	a3,0x4
ffffffffc0201584:	98868693          	addi	a3,a3,-1656 # ffffffffc0204f08 <etext+0xc60>
ffffffffc0201588:	00003617          	auipc	a2,0x3
ffffffffc020158c:	5f860613          	addi	a2,a2,1528 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0201590:	04900593          	li	a1,73
ffffffffc0201594:	00003517          	auipc	a0,0x3
ffffffffc0201598:	60450513          	addi	a0,a0,1540 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc020159c:	db1fe0ef          	jal	ffffffffc020034c <__panic>
    assert(n > 0);
ffffffffc02015a0:	00004697          	auipc	a3,0x4
ffffffffc02015a4:	93868693          	addi	a3,a3,-1736 # ffffffffc0204ed8 <etext+0xc30>
ffffffffc02015a8:	00003617          	auipc	a2,0x3
ffffffffc02015ac:	5d860613          	addi	a2,a2,1496 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02015b0:	04600593          	li	a1,70
ffffffffc02015b4:	00003517          	auipc	a0,0x3
ffffffffc02015b8:	5e450513          	addi	a0,a0,1508 # ffffffffc0204b98 <etext+0x8f0>
ffffffffc02015bc:	d91fe0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02015c0 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015c0:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02015c2:	00004617          	auipc	a2,0x4
ffffffffc02015c6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204f30 <etext+0xc88>
ffffffffc02015ca:	06800593          	li	a1,104
ffffffffc02015ce:	00004517          	auipc	a0,0x4
ffffffffc02015d2:	98250513          	addi	a0,a0,-1662 # ffffffffc0204f50 <etext+0xca8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02015d6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02015d8:	d75fe0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02015dc <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02015dc:	7139                	addi	sp,sp,-64
ffffffffc02015de:	f426                	sd	s1,40(sp)
ffffffffc02015e0:	f04a                	sd	s2,32(sp)
ffffffffc02015e2:	ec4e                	sd	s3,24(sp)
ffffffffc02015e4:	e852                	sd	s4,16(sp)
ffffffffc02015e6:	e456                	sd	s5,8(sp)
ffffffffc02015e8:	fc06                	sd	ra,56(sp)
ffffffffc02015ea:	f822                	sd	s0,48(sp)
ffffffffc02015ec:	84aa                	mv	s1,a0

        if (page != NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02015ee:	0005099b          	sext.w	s3,a0
ffffffffc02015f2:	00010917          	auipc	s2,0x10
ffffffffc02015f6:	f1e90913          	addi	s2,s2,-226 # ffffffffc0211510 <pmm_manager>
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02015fa:	4a05                	li	s4,1
        swap_out(check_mm_struct, n, 0);
ffffffffc02015fc:	00010a97          	auipc	s5,0x10
ffffffffc0201600:	f6ca8a93          	addi	s5,s5,-148 # ffffffffc0211568 <check_mm_struct>
ffffffffc0201604:	a025                	j	ffffffffc020162c <alloc_pages+0x50>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201606:	00093783          	ld	a5,0(s2)
ffffffffc020160a:	6f9c                	ld	a5,24(a5)
ffffffffc020160c:	9782                	jalr	a5
ffffffffc020160e:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201610:	4601                	li	a2,0
ffffffffc0201612:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201614:	ec15                	bnez	s0,ffffffffc0201650 <alloc_pages+0x74>
ffffffffc0201616:	029a6d63          	bltu	s4,s1,ffffffffc0201650 <alloc_pages+0x74>
ffffffffc020161a:	00010797          	auipc	a5,0x10
ffffffffc020161e:	f267a783          	lw	a5,-218(a5) # ffffffffc0211540 <swap_init_ok>
ffffffffc0201622:	c79d                	beqz	a5,ffffffffc0201650 <alloc_pages+0x74>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201624:	000ab503          	ld	a0,0(s5)
ffffffffc0201628:	225010ef          	jal	ffffffffc020304c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020162c:	100027f3          	csrr	a5,sstatus
ffffffffc0201630:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201632:	8526                	mv	a0,s1
ffffffffc0201634:	dbe9                	beqz	a5,ffffffffc0201606 <alloc_pages+0x2a>
        intr_disable();
ffffffffc0201636:	e95fe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc020163a:	00093783          	ld	a5,0(s2)
ffffffffc020163e:	8526                	mv	a0,s1
ffffffffc0201640:	6f9c                	ld	a5,24(a5)
ffffffffc0201642:	9782                	jalr	a5
ffffffffc0201644:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201646:	e7ffe0ef          	jal	ffffffffc02004c4 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc020164a:	4601                	li	a2,0
ffffffffc020164c:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020164e:	d461                	beqz	s0,ffffffffc0201616 <alloc_pages+0x3a>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201650:	70e2                	ld	ra,56(sp)
ffffffffc0201652:	8522                	mv	a0,s0
ffffffffc0201654:	7442                	ld	s0,48(sp)
ffffffffc0201656:	74a2                	ld	s1,40(sp)
ffffffffc0201658:	7902                	ld	s2,32(sp)
ffffffffc020165a:	69e2                	ld	s3,24(sp)
ffffffffc020165c:	6a42                	ld	s4,16(sp)
ffffffffc020165e:	6aa2                	ld	s5,8(sp)
ffffffffc0201660:	6121                	addi	sp,sp,64
ffffffffc0201662:	8082                	ret

ffffffffc0201664 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201664:	100027f3          	csrr	a5,sstatus
ffffffffc0201668:	8b89                	andi	a5,a5,2
ffffffffc020166a:	e799                	bnez	a5,ffffffffc0201678 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020166c:	00010797          	auipc	a5,0x10
ffffffffc0201670:	ea47b783          	ld	a5,-348(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0201674:	739c                	ld	a5,32(a5)
ffffffffc0201676:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201678:	1101                	addi	sp,sp,-32
ffffffffc020167a:	ec06                	sd	ra,24(sp)
ffffffffc020167c:	e822                	sd	s0,16(sp)
ffffffffc020167e:	e426                	sd	s1,8(sp)
ffffffffc0201680:	842a                	mv	s0,a0
ffffffffc0201682:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201684:	e47fe0ef          	jal	ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201688:	00010797          	auipc	a5,0x10
ffffffffc020168c:	e887b783          	ld	a5,-376(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0201690:	85a6                	mv	a1,s1
ffffffffc0201692:	8522                	mv	a0,s0
ffffffffc0201694:	739c                	ld	a5,32(a5)
ffffffffc0201696:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201698:	6442                	ld	s0,16(sp)
ffffffffc020169a:	60e2                	ld	ra,24(sp)
ffffffffc020169c:	64a2                	ld	s1,8(sp)
ffffffffc020169e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02016a0:	e25fe06f          	j	ffffffffc02004c4 <intr_enable>

ffffffffc02016a4 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016a4:	100027f3          	csrr	a5,sstatus
ffffffffc02016a8:	8b89                	andi	a5,a5,2
ffffffffc02016aa:	e799                	bnez	a5,ffffffffc02016b8 <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016ac:	00010797          	auipc	a5,0x10
ffffffffc02016b0:	e647b783          	ld	a5,-412(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02016b4:	779c                	ld	a5,40(a5)
ffffffffc02016b6:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02016b8:	1141                	addi	sp,sp,-16
ffffffffc02016ba:	e406                	sd	ra,8(sp)
ffffffffc02016bc:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02016be:	e0dfe0ef          	jal	ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02016c2:	00010797          	auipc	a5,0x10
ffffffffc02016c6:	e4e7b783          	ld	a5,-434(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02016ca:	779c                	ld	a5,40(a5)
ffffffffc02016cc:	9782                	jalr	a5
ffffffffc02016ce:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02016d0:	df5fe0ef          	jal	ffffffffc02004c4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02016d4:	60a2                	ld	ra,8(sp)
ffffffffc02016d6:	8522                	mv	a0,s0
ffffffffc02016d8:	6402                	ld	s0,0(sp)
ffffffffc02016da:	0141                	addi	sp,sp,16
ffffffffc02016dc:	8082                	ret

ffffffffc02016de <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016de:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02016e2:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016e6:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016e8:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016ea:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02016ec:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016f0:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02016f2:	f84a                	sd	s2,48(sp)
ffffffffc02016f4:	f44e                	sd	s3,40(sp)
ffffffffc02016f6:	f052                	sd	s4,32(sp)
ffffffffc02016f8:	e486                	sd	ra,72(sp)
ffffffffc02016fa:	e0a2                	sd	s0,64(sp)
ffffffffc02016fc:	ec56                	sd	s5,24(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02016fe:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201702:	892e                	mv	s2,a1
ffffffffc0201704:	8a32                	mv	s4,a2
ffffffffc0201706:	00010997          	auipc	s3,0x10
ffffffffc020170a:	e2a98993          	addi	s3,s3,-470 # ffffffffc0211530 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020170e:	ebc1                	bnez	a5,ffffffffc020179e <get_pte+0xc0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201710:	16060e63          	beqz	a2,ffffffffc020188c <get_pte+0x1ae>
ffffffffc0201714:	4505                	li	a0,1
ffffffffc0201716:	ec7ff0ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc020171a:	842a                	mv	s0,a0
ffffffffc020171c:	16050863          	beqz	a0,ffffffffc020188c <get_pte+0x1ae>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201720:	e45e                	sd	s7,8(sp)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201722:	00010b97          	auipc	s7,0x10
ffffffffc0201726:	e16b8b93          	addi	s7,s7,-490 # ffffffffc0211538 <pages>
ffffffffc020172a:	000bb503          	ld	a0,0(s7)
ffffffffc020172e:	8e38eab7          	lui	s5,0x8e38e
ffffffffc0201732:	38ea8a93          	addi	s5,s5,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc0201736:	38e397b7          	lui	a5,0x38e39
ffffffffc020173a:	e3978793          	addi	a5,a5,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc020173e:	40a40533          	sub	a0,s0,a0
ffffffffc0201742:	1a82                	slli	s5,s5,0x20
ffffffffc0201744:	9abe                	add	s5,s5,a5
ffffffffc0201746:	850d                	srai	a0,a0,0x3
ffffffffc0201748:	03550533          	mul	a0,a0,s5
ffffffffc020174c:	e85a                	sd	s6,16(sp)
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020174e:	00010997          	auipc	s3,0x10
ffffffffc0201752:	de298993          	addi	s3,s3,-542 # ffffffffc0211530 <npage>
ffffffffc0201756:	00080b37          	lui	s6,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020175a:	4785                	li	a5,1
ffffffffc020175c:	0009b703          	ld	a4,0(s3)
ffffffffc0201760:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201762:	955a                	add	a0,a0,s6
ffffffffc0201764:	00c51793          	slli	a5,a0,0xc
ffffffffc0201768:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020176a:	0532                	slli	a0,a0,0xc
ffffffffc020176c:	16e7fa63          	bgeu	a5,a4,ffffffffc02018e0 <get_pte+0x202>
ffffffffc0201770:	00010797          	auipc	a5,0x10
ffffffffc0201774:	db87b783          	ld	a5,-584(a5) # ffffffffc0211528 <va_pa_offset>
ffffffffc0201778:	6605                	lui	a2,0x1
ffffffffc020177a:	4581                	li	a1,0
ffffffffc020177c:	953e                	add	a0,a0,a5
ffffffffc020177e:	301020ef          	jal	ffffffffc020427e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201782:	000bb783          	ld	a5,0(s7)
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201786:	6ba2                	ld	s7,8(sp)
ffffffffc0201788:	40f406b3          	sub	a3,s0,a5
ffffffffc020178c:	868d                	srai	a3,a3,0x3
ffffffffc020178e:	035686b3          	mul	a3,a3,s5
ffffffffc0201792:	96da                	add	a3,a3,s6

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201794:	06aa                	slli	a3,a3,0xa
ffffffffc0201796:	6b42                	ld	s6,16(sp)
ffffffffc0201798:	0116e693          	ori	a3,a3,17
ffffffffc020179c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020179e:	77fd                	lui	a5,0xfffff
ffffffffc02017a0:	068a                	slli	a3,a3,0x2
ffffffffc02017a2:	0009b703          	ld	a4,0(s3)
ffffffffc02017a6:	8efd                	and	a3,a3,a5
ffffffffc02017a8:	00c6d793          	srli	a5,a3,0xc
ffffffffc02017ac:	0ee7f263          	bgeu	a5,a4,ffffffffc0201890 <get_pte+0x1b2>
ffffffffc02017b0:	00010a97          	auipc	s5,0x10
ffffffffc02017b4:	d78a8a93          	addi	s5,s5,-648 # ffffffffc0211528 <va_pa_offset>
ffffffffc02017b8:	000ab603          	ld	a2,0(s5)
ffffffffc02017bc:	01595793          	srli	a5,s2,0x15
ffffffffc02017c0:	1ff7f793          	andi	a5,a5,511
ffffffffc02017c4:	96b2                	add	a3,a3,a2
ffffffffc02017c6:	078e                	slli	a5,a5,0x3
ffffffffc02017c8:	00f68433          	add	s0,a3,a5
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc02017cc:	6014                	ld	a3,0(s0)
ffffffffc02017ce:	0016f793          	andi	a5,a3,1
ffffffffc02017d2:	e3d9                	bnez	a5,ffffffffc0201858 <get_pte+0x17a>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017d4:	0a0a0c63          	beqz	s4,ffffffffc020188c <get_pte+0x1ae>
ffffffffc02017d8:	4505                	li	a0,1
ffffffffc02017da:	e03ff0ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc02017de:	84aa                	mv	s1,a0
ffffffffc02017e0:	c555                	beqz	a0,ffffffffc020188c <get_pte+0x1ae>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017e2:	e45e                	sd	s7,8(sp)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017e4:	00010b97          	auipc	s7,0x10
ffffffffc02017e8:	d54b8b93          	addi	s7,s7,-684 # ffffffffc0211538 <pages>
ffffffffc02017ec:	000bb683          	ld	a3,0(s7)
ffffffffc02017f0:	8e38ea37          	lui	s4,0x8e38e
ffffffffc02017f4:	38ea0a13          	addi	s4,s4,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc02017f8:	38e397b7          	lui	a5,0x38e39
ffffffffc02017fc:	e3978793          	addi	a5,a5,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0201800:	40d506b3          	sub	a3,a0,a3
ffffffffc0201804:	1a02                	slli	s4,s4,0x20
ffffffffc0201806:	9a3e                	add	s4,s4,a5
ffffffffc0201808:	868d                	srai	a3,a3,0x3
ffffffffc020180a:	034686b3          	mul	a3,a3,s4
ffffffffc020180e:	e85a                	sd	s6,16(sp)
ffffffffc0201810:	00080b37          	lui	s6,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201814:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201816:	0009b703          	ld	a4,0(s3)
ffffffffc020181a:	c11c                	sw	a5,0(a0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020181c:	96da                	add	a3,a3,s6
ffffffffc020181e:	00c69793          	slli	a5,a3,0xc
ffffffffc0201822:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201824:	06b2                	slli	a3,a3,0xc
ffffffffc0201826:	0ae7f163          	bgeu	a5,a4,ffffffffc02018c8 <get_pte+0x1ea>
ffffffffc020182a:	000ab503          	ld	a0,0(s5)
ffffffffc020182e:	6605                	lui	a2,0x1
ffffffffc0201830:	4581                	li	a1,0
ffffffffc0201832:	9536                	add	a0,a0,a3
ffffffffc0201834:	24b020ef          	jal	ffffffffc020427e <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201838:	000bb783          	ld	a5,0(s7)
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020183c:	6ba2                	ld	s7,8(sp)
ffffffffc020183e:	40f486b3          	sub	a3,s1,a5
ffffffffc0201842:	868d                	srai	a3,a3,0x3
ffffffffc0201844:	034686b3          	mul	a3,a3,s4
ffffffffc0201848:	96da                	add	a3,a3,s6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020184a:	06aa                	slli	a3,a3,0xa
ffffffffc020184c:	0116e693          	ori	a3,a3,17
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201850:	e014                	sd	a3,0(s0)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201852:	0009b703          	ld	a4,0(s3)
ffffffffc0201856:	6b42                	ld	s6,16(sp)
ffffffffc0201858:	77fd                	lui	a5,0xfffff
ffffffffc020185a:	068a                	slli	a3,a3,0x2
ffffffffc020185c:	8efd                	and	a3,a3,a5
ffffffffc020185e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201862:	04e7f563          	bgeu	a5,a4,ffffffffc02018ac <get_pte+0x1ce>
ffffffffc0201866:	000ab783          	ld	a5,0(s5)
ffffffffc020186a:	00c95913          	srli	s2,s2,0xc
ffffffffc020186e:	1ff97913          	andi	s2,s2,511
ffffffffc0201872:	090e                	slli	s2,s2,0x3
ffffffffc0201874:	96be                	add	a3,a3,a5
ffffffffc0201876:	01268533          	add	a0,a3,s2
}
ffffffffc020187a:	60a6                	ld	ra,72(sp)
ffffffffc020187c:	6406                	ld	s0,64(sp)
ffffffffc020187e:	74e2                	ld	s1,56(sp)
ffffffffc0201880:	7942                	ld	s2,48(sp)
ffffffffc0201882:	79a2                	ld	s3,40(sp)
ffffffffc0201884:	7a02                	ld	s4,32(sp)
ffffffffc0201886:	6ae2                	ld	s5,24(sp)
ffffffffc0201888:	6161                	addi	sp,sp,80
ffffffffc020188a:	8082                	ret
            return NULL;
ffffffffc020188c:	4501                	li	a0,0
ffffffffc020188e:	b7f5                	j	ffffffffc020187a <get_pte+0x19c>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201890:	00003617          	auipc	a2,0x3
ffffffffc0201894:	6d060613          	addi	a2,a2,1744 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc0201898:	10200593          	li	a1,258
ffffffffc020189c:	00003517          	auipc	a0,0x3
ffffffffc02018a0:	6ec50513          	addi	a0,a0,1772 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02018a4:	e85a                	sd	s6,16(sp)
ffffffffc02018a6:	e45e                	sd	s7,8(sp)
ffffffffc02018a8:	aa5fe0ef          	jal	ffffffffc020034c <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018ac:	00003617          	auipc	a2,0x3
ffffffffc02018b0:	6b460613          	addi	a2,a2,1716 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc02018b4:	10f00593          	li	a1,271
ffffffffc02018b8:	00003517          	auipc	a0,0x3
ffffffffc02018bc:	6d050513          	addi	a0,a0,1744 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02018c0:	e85a                	sd	s6,16(sp)
ffffffffc02018c2:	e45e                	sd	s7,8(sp)
ffffffffc02018c4:	a89fe0ef          	jal	ffffffffc020034c <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018c8:	00003617          	auipc	a2,0x3
ffffffffc02018cc:	69860613          	addi	a2,a2,1688 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc02018d0:	10b00593          	li	a1,267
ffffffffc02018d4:	00003517          	auipc	a0,0x3
ffffffffc02018d8:	6b450513          	addi	a0,a0,1716 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02018dc:	a71fe0ef          	jal	ffffffffc020034c <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018e0:	86aa                	mv	a3,a0
ffffffffc02018e2:	00003617          	auipc	a2,0x3
ffffffffc02018e6:	67e60613          	addi	a2,a2,1662 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc02018ea:	0ff00593          	li	a1,255
ffffffffc02018ee:	00003517          	auipc	a0,0x3
ffffffffc02018f2:	69a50513          	addi	a0,a0,1690 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02018f6:	a57fe0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02018fa <get_page>:
    pde_t *pdep1 = &pgdir[PDX1(la)];
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}
// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02018fa:	1141                	addi	sp,sp,-16
ffffffffc02018fc:	e022                	sd	s0,0(sp)
ffffffffc02018fe:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201900:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201902:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201904:	ddbff0ef          	jal	ffffffffc02016de <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201908:	c011                	beqz	s0,ffffffffc020190c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020190a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020190c:	c511                	beqz	a0,ffffffffc0201918 <get_page+0x1e>
ffffffffc020190e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201910:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201912:	0017f713          	andi	a4,a5,1
ffffffffc0201916:	e709                	bnez	a4,ffffffffc0201920 <get_page+0x26>
}
ffffffffc0201918:	60a2                	ld	ra,8(sp)
ffffffffc020191a:	6402                	ld	s0,0(sp)
ffffffffc020191c:	0141                	addi	sp,sp,16
ffffffffc020191e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201920:	00010717          	auipc	a4,0x10
ffffffffc0201924:	c1073703          	ld	a4,-1008(a4) # ffffffffc0211530 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0201928:	078a                	slli	a5,a5,0x2
ffffffffc020192a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020192c:	02e7f263          	bgeu	a5,a4,ffffffffc0201950 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201930:	fff80737          	lui	a4,0xfff80
ffffffffc0201934:	97ba                	add	a5,a5,a4
ffffffffc0201936:	00010517          	auipc	a0,0x10
ffffffffc020193a:	c0253503          	ld	a0,-1022(a0) # ffffffffc0211538 <pages>
ffffffffc020193e:	60a2                	ld	ra,8(sp)
ffffffffc0201940:	6402                	ld	s0,0(sp)
ffffffffc0201942:	00379713          	slli	a4,a5,0x3
ffffffffc0201946:	97ba                	add	a5,a5,a4
ffffffffc0201948:	078e                	slli	a5,a5,0x3
ffffffffc020194a:	953e                	add	a0,a0,a5
ffffffffc020194c:	0141                	addi	sp,sp,16
ffffffffc020194e:	8082                	ret
ffffffffc0201950:	c71ff0ef          	jal	ffffffffc02015c0 <pa2page.part.0>

ffffffffc0201954 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201954:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201956:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201958:	ec06                	sd	ra,24(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020195a:	d85ff0ef          	jal	ffffffffc02016de <get_pte>
    if (ptep != NULL) {
ffffffffc020195e:	c901                	beqz	a0,ffffffffc020196e <page_remove+0x1a>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201960:	611c                	ld	a5,0(a0)
ffffffffc0201962:	e822                	sd	s0,16(sp)
ffffffffc0201964:	842a                	mv	s0,a0
ffffffffc0201966:	0017f713          	andi	a4,a5,1
ffffffffc020196a:	e709                	bnez	a4,ffffffffc0201974 <page_remove+0x20>
ffffffffc020196c:	6442                	ld	s0,16(sp)
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc020196e:	60e2                	ld	ra,24(sp)
ffffffffc0201970:	6105                	addi	sp,sp,32
ffffffffc0201972:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201974:	00010717          	auipc	a4,0x10
ffffffffc0201978:	bbc73703          	ld	a4,-1092(a4) # ffffffffc0211530 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020197c:	078a                	slli	a5,a5,0x2
ffffffffc020197e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201980:	06e7f463          	bgeu	a5,a4,ffffffffc02019e8 <page_remove+0x94>
    return &pages[PPN(pa) - nbase];
ffffffffc0201984:	fff80737          	lui	a4,0xfff80
ffffffffc0201988:	97ba                	add	a5,a5,a4
ffffffffc020198a:	00010517          	auipc	a0,0x10
ffffffffc020198e:	bae53503          	ld	a0,-1106(a0) # ffffffffc0211538 <pages>
ffffffffc0201992:	00379713          	slli	a4,a5,0x3
ffffffffc0201996:	97ba                	add	a5,a5,a4
ffffffffc0201998:	078e                	slli	a5,a5,0x3
ffffffffc020199a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020199c:	411c                	lw	a5,0(a0)
ffffffffc020199e:	37fd                	addiw	a5,a5,-1 # ffffffffffffefff <end+0x3fdeda8f>
ffffffffc02019a0:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc02019a2:	cb89                	beqz	a5,ffffffffc02019b4 <page_remove+0x60>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02019a4:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02019a8:	12000073          	sfence.vma
ffffffffc02019ac:	6442                	ld	s0,16(sp)
}
ffffffffc02019ae:	60e2                	ld	ra,24(sp)
ffffffffc02019b0:	6105                	addi	sp,sp,32
ffffffffc02019b2:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b4:	100027f3          	csrr	a5,sstatus
ffffffffc02019b8:	8b89                	andi	a5,a5,2
ffffffffc02019ba:	eb89                	bnez	a5,ffffffffc02019cc <page_remove+0x78>
    { pmm_manager->free_pages(base, n); }
ffffffffc02019bc:	00010797          	auipc	a5,0x10
ffffffffc02019c0:	b547b783          	ld	a5,-1196(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02019c4:	4585                	li	a1,1
ffffffffc02019c6:	739c                	ld	a5,32(a5)
ffffffffc02019c8:	9782                	jalr	a5
    if (flag) {
ffffffffc02019ca:	bfe9                	j	ffffffffc02019a4 <page_remove+0x50>
        intr_disable();
ffffffffc02019cc:	e42a                	sd	a0,8(sp)
ffffffffc02019ce:	afdfe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc02019d2:	00010797          	auipc	a5,0x10
ffffffffc02019d6:	b3e7b783          	ld	a5,-1218(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02019da:	6522                	ld	a0,8(sp)
ffffffffc02019dc:	4585                	li	a1,1
ffffffffc02019de:	739c                	ld	a5,32(a5)
ffffffffc02019e0:	9782                	jalr	a5
        intr_enable();
ffffffffc02019e2:	ae3fe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc02019e6:	bf7d                	j	ffffffffc02019a4 <page_remove+0x50>
ffffffffc02019e8:	bd9ff0ef          	jal	ffffffffc02015c0 <pa2page.part.0>

ffffffffc02019ec <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019ec:	7139                	addi	sp,sp,-64
ffffffffc02019ee:	f822                	sd	s0,48(sp)
ffffffffc02019f0:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019f2:	85b2                	mv	a1,a2
ffffffffc02019f4:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02019f6:	f426                	sd	s1,40(sp)
ffffffffc02019f8:	fc06                	sd	ra,56(sp)
ffffffffc02019fa:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02019fc:	ce3ff0ef          	jal	ffffffffc02016de <get_pte>
    if (ptep == NULL) {
ffffffffc0201a00:	c175                	beqz	a0,ffffffffc0201ae4 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0201a02:	4018                	lw	a4,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a04:	611c                	ld	a5,0(a0)
ffffffffc0201a06:	f04a                	sd	s2,32(sp)
ffffffffc0201a08:	0017069b          	addiw	a3,a4,1 # fffffffffff80001 <end+0x3fd6ea91>
ffffffffc0201a0c:	c014                	sw	a3,0(s0)
ffffffffc0201a0e:	0017f693          	andi	a3,a5,1
ffffffffc0201a12:	892a                	mv	s2,a0
ffffffffc0201a14:	e6b1                	bnez	a3,ffffffffc0201a60 <page_insert+0x74>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a16:	00010617          	auipc	a2,0x10
ffffffffc0201a1a:	b2263603          	ld	a2,-1246(a2) # ffffffffc0211538 <pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a1e:	8e38e737          	lui	a4,0x8e38e
ffffffffc0201a22:	38e70713          	addi	a4,a4,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc0201a26:	38e396b7          	lui	a3,0x38e39
ffffffffc0201a2a:	40c407b3          	sub	a5,s0,a2
ffffffffc0201a2e:	e3968693          	addi	a3,a3,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0201a32:	1702                	slli	a4,a4,0x20
ffffffffc0201a34:	9736                	add	a4,a4,a3
ffffffffc0201a36:	878d                	srai	a5,a5,0x3
ffffffffc0201a38:	02e787b3          	mul	a5,a5,a4
ffffffffc0201a3c:	00080737          	lui	a4,0x80
ffffffffc0201a40:	97ba                	add	a5,a5,a4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a42:	07aa                	slli	a5,a5,0xa
ffffffffc0201a44:	8cdd                	or	s1,s1,a5
ffffffffc0201a46:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a4a:	00993023          	sd	s1,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a4e:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a52:	7902                	ld	s2,32(sp)
ffffffffc0201a54:	4501                	li	a0,0
}
ffffffffc0201a56:	70e2                	ld	ra,56(sp)
ffffffffc0201a58:	7442                	ld	s0,48(sp)
ffffffffc0201a5a:	74a2                	ld	s1,40(sp)
ffffffffc0201a5c:	6121                	addi	sp,sp,64
ffffffffc0201a5e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a60:	00010697          	auipc	a3,0x10
ffffffffc0201a64:	ad06b683          	ld	a3,-1328(a3) # ffffffffc0211530 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a68:	078a                	slli	a5,a5,0x2
ffffffffc0201a6a:	ec4e                	sd	s3,24(sp)
ffffffffc0201a6c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a6e:	06d7fd63          	bgeu	a5,a3,ffffffffc0201ae8 <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a72:	fff806b7          	lui	a3,0xfff80
ffffffffc0201a76:	97b6                	add	a5,a5,a3
ffffffffc0201a78:	00010997          	auipc	s3,0x10
ffffffffc0201a7c:	ac098993          	addi	s3,s3,-1344 # ffffffffc0211538 <pages>
ffffffffc0201a80:	0009b603          	ld	a2,0(s3)
ffffffffc0201a84:	00379513          	slli	a0,a5,0x3
ffffffffc0201a88:	953e                	add	a0,a0,a5
ffffffffc0201a8a:	050e                	slli	a0,a0,0x3
ffffffffc0201a8c:	9532                	add	a0,a0,a2
        if (p == page) {
ffffffffc0201a8e:	00a40e63          	beq	s0,a0,ffffffffc0201aaa <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201a92:	411c                	lw	a5,0(a0)
ffffffffc0201a94:	37fd                	addiw	a5,a5,-1
ffffffffc0201a96:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc0201a98:	cf81                	beqz	a5,ffffffffc0201ab0 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a9a:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a9e:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201aa2:	0009b603          	ld	a2,0(s3)
ffffffffc0201aa6:	69e2                	ld	s3,24(sp)
}
ffffffffc0201aa8:	bf9d                	j	ffffffffc0201a1e <page_insert+0x32>
    return page->ref;
ffffffffc0201aaa:	69e2                	ld	s3,24(sp)
    page->ref -= 1;
ffffffffc0201aac:	c018                	sw	a4,0(s0)
    return page->ref;
ffffffffc0201aae:	bf85                	j	ffffffffc0201a1e <page_insert+0x32>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ab0:	100027f3          	csrr	a5,sstatus
ffffffffc0201ab4:	8b89                	andi	a5,a5,2
ffffffffc0201ab6:	eb89                	bnez	a5,ffffffffc0201ac8 <page_insert+0xdc>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201ab8:	00010797          	auipc	a5,0x10
ffffffffc0201abc:	a587b783          	ld	a5,-1448(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0201ac0:	4585                	li	a1,1
ffffffffc0201ac2:	739c                	ld	a5,32(a5)
ffffffffc0201ac4:	9782                	jalr	a5
    if (flag) {
ffffffffc0201ac6:	bfd1                	j	ffffffffc0201a9a <page_insert+0xae>
        intr_disable();
ffffffffc0201ac8:	e42a                	sd	a0,8(sp)
ffffffffc0201aca:	a01fe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc0201ace:	00010797          	auipc	a5,0x10
ffffffffc0201ad2:	a427b783          	ld	a5,-1470(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0201ad6:	6522                	ld	a0,8(sp)
ffffffffc0201ad8:	4585                	li	a1,1
ffffffffc0201ada:	739c                	ld	a5,32(a5)
ffffffffc0201adc:	9782                	jalr	a5
        intr_enable();
ffffffffc0201ade:	9e7fe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc0201ae2:	bf65                	j	ffffffffc0201a9a <page_insert+0xae>
        return -E_NO_MEM;
ffffffffc0201ae4:	5571                	li	a0,-4
ffffffffc0201ae6:	bf85                	j	ffffffffc0201a56 <page_insert+0x6a>
ffffffffc0201ae8:	ad9ff0ef          	jal	ffffffffc02015c0 <pa2page.part.0>

ffffffffc0201aec <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201aec:	00004797          	auipc	a5,0x4
ffffffffc0201af0:	3bc78793          	addi	a5,a5,956 # ffffffffc0205ea8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201af4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201af6:	7159                	addi	sp,sp,-112
ffffffffc0201af8:	f486                	sd	ra,104(sp)
ffffffffc0201afa:	eca6                	sd	s1,88(sp)
ffffffffc0201afc:	e4ce                	sd	s3,72(sp)
ffffffffc0201afe:	f85a                	sd	s6,48(sp)
ffffffffc0201b00:	f45e                	sd	s7,40(sp)
ffffffffc0201b02:	f0a2                	sd	s0,96(sp)
ffffffffc0201b04:	e8ca                	sd	s2,80(sp)
ffffffffc0201b06:	e0d2                	sd	s4,64(sp)
ffffffffc0201b08:	fc56                	sd	s5,56(sp)
ffffffffc0201b0a:	f062                	sd	s8,32(sp)
ffffffffc0201b0c:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b0e:	00010b97          	auipc	s7,0x10
ffffffffc0201b12:	a02b8b93          	addi	s7,s7,-1534 # ffffffffc0211510 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b16:	00003517          	auipc	a0,0x3
ffffffffc0201b1a:	48250513          	addi	a0,a0,1154 # ffffffffc0204f98 <etext+0xcf0>
    pmm_manager = &default_pmm_manager;
ffffffffc0201b1e:	00fbb023          	sd	a5,0(s7)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b22:	d98fe0ef          	jal	ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201b26:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b2a:	00010997          	auipc	s3,0x10
ffffffffc0201b2e:	9fe98993          	addi	s3,s3,-1538 # ffffffffc0211528 <va_pa_offset>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b32:	00010b17          	auipc	s6,0x10
ffffffffc0201b36:	a06b0b13          	addi	s6,s6,-1530 # ffffffffc0211538 <pages>
    pmm_manager->init();
ffffffffc0201b3a:	679c                	ld	a5,8(a5)
    npage = maxpa / PGSIZE;
ffffffffc0201b3c:	00010497          	auipc	s1,0x10
ffffffffc0201b40:	9f448493          	addi	s1,s1,-1548 # ffffffffc0211530 <npage>
    pmm_manager->init();
ffffffffc0201b44:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b46:	57f5                	li	a5,-3
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b48:	4645                	li	a2,17
ffffffffc0201b4a:	40100593          	li	a1,1025
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b4e:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b50:	066e                	slli	a2,a2,0x1b
ffffffffc0201b52:	05d6                	slli	a1,a1,0x15
ffffffffc0201b54:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b58:	00003517          	auipc	a0,0x3
ffffffffc0201b5c:	45850513          	addi	a0,a0,1112 # ffffffffc0204fb0 <etext+0xd08>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b60:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b64:	d56fe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b68:	00003517          	auipc	a0,0x3
ffffffffc0201b6c:	47850513          	addi	a0,a0,1144 # ffffffffc0204fe0 <etext+0xd38>
ffffffffc0201b70:	d4afe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b74:	46c5                	li	a3,17
ffffffffc0201b76:	06ee                	slli	a3,a3,0x1b
ffffffffc0201b78:	40100613          	li	a2,1025
ffffffffc0201b7c:	16fd                	addi	a3,a3,-1 # 7dfffff <kern_entry-0xffffffffb8400001>
ffffffffc0201b7e:	0656                	slli	a2,a2,0x15
ffffffffc0201b80:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b84:	00003517          	auipc	a0,0x3
ffffffffc0201b88:	47450513          	addi	a0,a0,1140 # ffffffffc0204ff8 <etext+0xd50>
ffffffffc0201b8c:	d2efe0ef          	jal	ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b90:	77fd                	lui	a5,0xfffff
ffffffffc0201b92:	00011697          	auipc	a3,0x11
ffffffffc0201b96:	9dd68693          	addi	a3,a3,-1571 # ffffffffc021256f <end+0xfff>
ffffffffc0201b9a:	8efd                	and	a3,a3,a5
    npage = maxpa / PGSIZE;
ffffffffc0201b9c:	000887b7          	lui	a5,0x88
ffffffffc0201ba0:	e09c                	sd	a5,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201ba2:	00db3023          	sd	a3,0(s6)
ffffffffc0201ba6:	4701                	li	a4,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201ba8:	4781                	li	a5,0
ffffffffc0201baa:	4805                	li	a6,1
ffffffffc0201bac:	fff80537          	lui	a0,0xfff80
        SetPageReserved(pages + i);
ffffffffc0201bb0:	96ba                	add	a3,a3,a4
ffffffffc0201bb2:	06a1                	addi	a3,a3,8
ffffffffc0201bb4:	4106b02f          	amoor.d	zero,a6,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bb8:	6090                	ld	a2,0(s1)
ffffffffc0201bba:	0785                	addi	a5,a5,1 # 88001 <kern_entry-0xffffffffc0177fff>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bbc:	000b3683          	ld	a3,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bc0:	00a605b3          	add	a1,a2,a0
ffffffffc0201bc4:	04870713          	addi	a4,a4,72 # 80048 <kern_entry-0xffffffffc017ffb8>
ffffffffc0201bc8:	feb7e4e3          	bltu	a5,a1,ffffffffc0201bb0 <pmm_init+0xc4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bcc:	00361793          	slli	a5,a2,0x3
ffffffffc0201bd0:	97b2                	add	a5,a5,a2
ffffffffc0201bd2:	078e                	slli	a5,a5,0x3
ffffffffc0201bd4:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201bd8:	97b6                	add	a5,a5,a3
ffffffffc0201bda:	97ba                	add	a5,a5,a4
ffffffffc0201bdc:	c0200737          	lui	a4,0xc0200
ffffffffc0201be0:	66e7e063          	bltu	a5,a4,ffffffffc0202240 <pmm_init+0x754>
ffffffffc0201be4:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0201be8:	4745                	li	a4,17
ffffffffc0201bea:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bec:	8f8d                	sub	a5,a5,a1
    if (freemem < mem_end) {
ffffffffc0201bee:	4ee7ed63          	bltu	a5,a4,ffffffffc02020e8 <pmm_init+0x5fc>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201bf2:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201bf6:	00010917          	auipc	s2,0x10
ffffffffc0201bfa:	92a90913          	addi	s2,s2,-1750 # ffffffffc0211520 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201bfe:	7b9c                	ld	a5,48(a5)
ffffffffc0201c00:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c02:	00003517          	auipc	a0,0x3
ffffffffc0201c06:	44650513          	addi	a0,a0,1094 # ffffffffc0205048 <etext+0xda0>
ffffffffc0201c0a:	cb0fe0ef          	jal	ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c0e:	00007697          	auipc	a3,0x7
ffffffffc0201c12:	3f268693          	addi	a3,a3,1010 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c16:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c1a:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c1e:	62f6ee63          	bltu	a3,a5,ffffffffc020225a <pmm_init+0x76e>
ffffffffc0201c22:	0009b783          	ld	a5,0(s3)
ffffffffc0201c26:	8e9d                	sub	a3,a3,a5
ffffffffc0201c28:	00010797          	auipc	a5,0x10
ffffffffc0201c2c:	8ed7b823          	sd	a3,-1808(a5) # ffffffffc0211518 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c30:	100027f3          	csrr	a5,sstatus
ffffffffc0201c34:	8b89                	andi	a5,a5,2
ffffffffc0201c36:	4e079263          	bnez	a5,ffffffffc020211a <pmm_init+0x62e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201c3a:	000bb783          	ld	a5,0(s7)
ffffffffc0201c3e:	779c                	ld	a5,40(a5)
ffffffffc0201c40:	9782                	jalr	a5
ffffffffc0201c42:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c44:	6098                	ld	a4,0(s1)
ffffffffc0201c46:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c4a:	83b1                	srli	a5,a5,0xc
ffffffffc0201c4c:	64e7e363          	bltu	a5,a4,ffffffffc0202292 <pmm_init+0x7a6>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c50:	00093503          	ld	a0,0(s2)
ffffffffc0201c54:	60050f63          	beqz	a0,ffffffffc0202272 <pmm_init+0x786>
ffffffffc0201c58:	03451793          	slli	a5,a0,0x34
ffffffffc0201c5c:	60079b63          	bnez	a5,ffffffffc0202272 <pmm_init+0x786>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c60:	4601                	li	a2,0
ffffffffc0201c62:	4581                	li	a1,0
ffffffffc0201c64:	c97ff0ef          	jal	ffffffffc02018fa <get_page>
ffffffffc0201c68:	6a051163          	bnez	a0,ffffffffc020230a <pmm_init+0x81e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c6c:	4505                	li	a0,1
ffffffffc0201c6e:	96fff0ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0201c72:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c74:	00093503          	ld	a0,0(s2)
ffffffffc0201c78:	85d2                	mv	a1,s4
ffffffffc0201c7a:	4681                	li	a3,0
ffffffffc0201c7c:	4601                	li	a2,0
ffffffffc0201c7e:	d6fff0ef          	jal	ffffffffc02019ec <page_insert>
ffffffffc0201c82:	66051463          	bnez	a0,ffffffffc02022ea <pmm_init+0x7fe>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c86:	00093503          	ld	a0,0(s2)
ffffffffc0201c8a:	4601                	li	a2,0
ffffffffc0201c8c:	4581                	li	a1,0
ffffffffc0201c8e:	a51ff0ef          	jal	ffffffffc02016de <get_pte>
ffffffffc0201c92:	62050c63          	beqz	a0,ffffffffc02022ca <pmm_init+0x7de>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c96:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c98:	0017f713          	andi	a4,a5,1
ffffffffc0201c9c:	60070b63          	beqz	a4,ffffffffc02022b2 <pmm_init+0x7c6>
    if (PPN(pa) >= npage) {
ffffffffc0201ca0:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ca2:	078a                	slli	a5,a5,0x2
ffffffffc0201ca4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ca6:	58c7fb63          	bgeu	a5,a2,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc0201caa:	fff80737          	lui	a4,0xfff80
ffffffffc0201cae:	97ba                	add	a5,a5,a4
ffffffffc0201cb0:	000b3683          	ld	a3,0(s6)
ffffffffc0201cb4:	00379713          	slli	a4,a5,0x3
ffffffffc0201cb8:	97ba                	add	a5,a5,a4
ffffffffc0201cba:	078e                	slli	a5,a5,0x3
ffffffffc0201cbc:	97b6                	add	a5,a5,a3
ffffffffc0201cbe:	16fa1fe3          	bne	s4,a5,ffffffffc020263c <pmm_init+0xb50>
    assert(page_ref(p1) == 1);
ffffffffc0201cc2:	000a2703          	lw	a4,0(s4)
ffffffffc0201cc6:	4785                	li	a5,1
ffffffffc0201cc8:	1af716e3          	bne	a4,a5,ffffffffc0202674 <pmm_init+0xb88>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201ccc:	00093503          	ld	a0,0(s2)
ffffffffc0201cd0:	77fd                	lui	a5,0xfffff
ffffffffc0201cd2:	6114                	ld	a3,0(a0)
ffffffffc0201cd4:	068a                	slli	a3,a3,0x2
ffffffffc0201cd6:	8efd                	and	a3,a3,a5
ffffffffc0201cd8:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201cdc:	18c770e3          	bgeu	a4,a2,ffffffffc020265c <pmm_init+0xb70>
ffffffffc0201ce0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ce4:	96e2                	add	a3,a3,s8
ffffffffc0201ce6:	0006ba83          	ld	s5,0(a3)
ffffffffc0201cea:	0a8a                	slli	s5,s5,0x2
ffffffffc0201cec:	00fafab3          	and	s5,s5,a5
ffffffffc0201cf0:	00cad793          	srli	a5,s5,0xc
ffffffffc0201cf4:	68c7fb63          	bgeu	a5,a2,ffffffffc020238a <pmm_init+0x89e>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cf8:	4601                	li	a2,0
ffffffffc0201cfa:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201cfc:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cfe:	9e1ff0ef          	jal	ffffffffc02016de <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d02:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d04:	67851363          	bne	a0,s8,ffffffffc020236a <pmm_init+0x87e>

    p2 = alloc_page();
ffffffffc0201d08:	4505                	li	a0,1
ffffffffc0201d0a:	8d3ff0ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0201d0e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d10:	00093503          	ld	a0,0(s2)
ffffffffc0201d14:	85d6                	mv	a1,s5
ffffffffc0201d16:	46d1                	li	a3,20
ffffffffc0201d18:	6605                	lui	a2,0x1
ffffffffc0201d1a:	cd3ff0ef          	jal	ffffffffc02019ec <page_insert>
ffffffffc0201d1e:	60051663          	bnez	a0,ffffffffc020232a <pmm_init+0x83e>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d22:	00093503          	ld	a0,0(s2)
ffffffffc0201d26:	4601                	li	a2,0
ffffffffc0201d28:	6585                	lui	a1,0x1
ffffffffc0201d2a:	9b5ff0ef          	jal	ffffffffc02016de <get_pte>
ffffffffc0201d2e:	160503e3          	beqz	a0,ffffffffc0202694 <pmm_init+0xba8>
    assert(*ptep & PTE_U);
ffffffffc0201d32:	611c                	ld	a5,0(a0)
ffffffffc0201d34:	0107f713          	andi	a4,a5,16
ffffffffc0201d38:	76070663          	beqz	a4,ffffffffc02024a4 <pmm_init+0x9b8>
    assert(*ptep & PTE_W);
ffffffffc0201d3c:	8b91                	andi	a5,a5,4
ffffffffc0201d3e:	72078363          	beqz	a5,ffffffffc0202464 <pmm_init+0x978>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d42:	00093503          	ld	a0,0(s2)
ffffffffc0201d46:	611c                	ld	a5,0(a0)
ffffffffc0201d48:	8bc1                	andi	a5,a5,16
ffffffffc0201d4a:	6e078d63          	beqz	a5,ffffffffc0202444 <pmm_init+0x958>
    assert(page_ref(p2) == 1);
ffffffffc0201d4e:	000aa703          	lw	a4,0(s5)
ffffffffc0201d52:	4785                	li	a5,1
ffffffffc0201d54:	5ef71b63          	bne	a4,a5,ffffffffc020234a <pmm_init+0x85e>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d58:	4681                	li	a3,0
ffffffffc0201d5a:	6605                	lui	a2,0x1
ffffffffc0201d5c:	85d2                	mv	a1,s4
ffffffffc0201d5e:	c8fff0ef          	jal	ffffffffc02019ec <page_insert>
ffffffffc0201d62:	6a051163          	bnez	a0,ffffffffc0202404 <pmm_init+0x918>
    assert(page_ref(p1) == 2);
ffffffffc0201d66:	000a2703          	lw	a4,0(s4)
ffffffffc0201d6a:	4789                	li	a5,2
ffffffffc0201d6c:	66f71c63          	bne	a4,a5,ffffffffc02023e4 <pmm_init+0x8f8>
    assert(page_ref(p2) == 0);
ffffffffc0201d70:	000aa783          	lw	a5,0(s5)
ffffffffc0201d74:	64079863          	bnez	a5,ffffffffc02023c4 <pmm_init+0x8d8>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d78:	00093503          	ld	a0,0(s2)
ffffffffc0201d7c:	4601                	li	a2,0
ffffffffc0201d7e:	6585                	lui	a1,0x1
ffffffffc0201d80:	95fff0ef          	jal	ffffffffc02016de <get_pte>
ffffffffc0201d84:	62050063          	beqz	a0,ffffffffc02023a4 <pmm_init+0x8b8>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d88:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d8a:	00177793          	andi	a5,a4,1
ffffffffc0201d8e:	52078263          	beqz	a5,ffffffffc02022b2 <pmm_init+0x7c6>
    if (PPN(pa) >= npage) {
ffffffffc0201d92:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d94:	00271793          	slli	a5,a4,0x2
ffffffffc0201d98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d9a:	4ad7f163          	bgeu	a5,a3,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d9e:	fff806b7          	lui	a3,0xfff80
ffffffffc0201da2:	97b6                	add	a5,a5,a3
ffffffffc0201da4:	000b3603          	ld	a2,0(s6)
ffffffffc0201da8:	00379693          	slli	a3,a5,0x3
ffffffffc0201dac:	97b6                	add	a5,a5,a3
ffffffffc0201dae:	078e                	slli	a5,a5,0x3
ffffffffc0201db0:	97b2                	add	a5,a5,a2
ffffffffc0201db2:	74fa1963          	bne	s4,a5,ffffffffc0202504 <pmm_init+0xa18>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201db6:	8b41                	andi	a4,a4,16
ffffffffc0201db8:	72071663          	bnez	a4,ffffffffc02024e4 <pmm_init+0x9f8>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201dbc:	00093503          	ld	a0,0(s2)
ffffffffc0201dc0:	4581                	li	a1,0
ffffffffc0201dc2:	b93ff0ef          	jal	ffffffffc0201954 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dc6:	000a2703          	lw	a4,0(s4)
ffffffffc0201dca:	4785                	li	a5,1
ffffffffc0201dcc:	6ef71c63          	bne	a4,a5,ffffffffc02024c4 <pmm_init+0x9d8>
    assert(page_ref(p2) == 0);
ffffffffc0201dd0:	000aa783          	lw	a5,0(s5)
ffffffffc0201dd4:	7c079463          	bnez	a5,ffffffffc020259c <pmm_init+0xab0>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201dd8:	00093503          	ld	a0,0(s2)
ffffffffc0201ddc:	6585                	lui	a1,0x1
ffffffffc0201dde:	b77ff0ef          	jal	ffffffffc0201954 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201de2:	000a2783          	lw	a5,0(s4)
ffffffffc0201de6:	78079b63          	bnez	a5,ffffffffc020257c <pmm_init+0xa90>
    assert(page_ref(p2) == 0);
ffffffffc0201dea:	000aa783          	lw	a5,0(s5)
ffffffffc0201dee:	76079763          	bnez	a5,ffffffffc020255c <pmm_init+0xa70>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201df2:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201df6:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201df8:	000a3703          	ld	a4,0(s4)
ffffffffc0201dfc:	070a                	slli	a4,a4,0x2
ffffffffc0201dfe:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e00:	42c77e63          	bgeu	a4,a2,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e04:	fff807b7          	lui	a5,0xfff80
ffffffffc0201e08:	973e                	add	a4,a4,a5
ffffffffc0201e0a:	00371793          	slli	a5,a4,0x3
ffffffffc0201e0e:	000b3503          	ld	a0,0(s6)
ffffffffc0201e12:	97ba                	add	a5,a5,a4
ffffffffc0201e14:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201e16:	00f50733          	add	a4,a0,a5
ffffffffc0201e1a:	430c                	lw	a1,0(a4)
ffffffffc0201e1c:	4705                	li	a4,1
ffffffffc0201e1e:	70e59f63          	bne	a1,a4,ffffffffc020253c <pmm_init+0xa50>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e22:	8e38e737          	lui	a4,0x8e38e
ffffffffc0201e26:	38e70713          	addi	a4,a4,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc0201e2a:	38e396b7          	lui	a3,0x38e39
ffffffffc0201e2e:	e3968693          	addi	a3,a3,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0201e32:	1702                	slli	a4,a4,0x20
ffffffffc0201e34:	9736                	add	a4,a4,a3
ffffffffc0201e36:	878d                	srai	a5,a5,0x3
ffffffffc0201e38:	02e787b3          	mul	a5,a5,a4
ffffffffc0201e3c:	00080737          	lui	a4,0x80
ffffffffc0201e40:	97ba                	add	a5,a5,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e42:	00c79693          	slli	a3,a5,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e46:	6cc7ff63          	bgeu	a5,a2,ffffffffc0202524 <pmm_init+0xa38>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e4a:	0009b783          	ld	a5,0(s3)
ffffffffc0201e4e:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e50:	639c                	ld	a5,0(a5)
ffffffffc0201e52:	078a                	slli	a5,a5,0x2
ffffffffc0201e54:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e56:	3ec7f363          	bgeu	a5,a2,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e5a:	8f99                	sub	a5,a5,a4
ffffffffc0201e5c:	00379713          	slli	a4,a5,0x3
ffffffffc0201e60:	97ba                	add	a5,a5,a4
ffffffffc0201e62:	078e                	slli	a5,a5,0x3
ffffffffc0201e64:	953e                	add	a0,a0,a5
ffffffffc0201e66:	100027f3          	csrr	a5,sstatus
ffffffffc0201e6a:	8b89                	andi	a5,a5,2
ffffffffc0201e6c:	30079163          	bnez	a5,ffffffffc020216e <pmm_init+0x682>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201e70:	000bb783          	ld	a5,0(s7)
ffffffffc0201e74:	739c                	ld	a5,32(a5)
ffffffffc0201e76:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e78:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201e7c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e7e:	078a                	slli	a5,a5,0x2
ffffffffc0201e80:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e82:	3ae7fd63          	bgeu	a5,a4,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e86:	fff80737          	lui	a4,0xfff80
ffffffffc0201e8a:	97ba                	add	a5,a5,a4
ffffffffc0201e8c:	000b3503          	ld	a0,0(s6)
ffffffffc0201e90:	00379713          	slli	a4,a5,0x3
ffffffffc0201e94:	97ba                	add	a5,a5,a4
ffffffffc0201e96:	078e                	slli	a5,a5,0x3
ffffffffc0201e98:	953e                	add	a0,a0,a5
ffffffffc0201e9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201e9e:	8b89                	andi	a5,a5,2
ffffffffc0201ea0:	2a079b63          	bnez	a5,ffffffffc0202156 <pmm_init+0x66a>
ffffffffc0201ea4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ea8:	4585                	li	a1,1
ffffffffc0201eaa:	739c                	ld	a5,32(a5)
ffffffffc0201eac:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0201eae:	00093783          	ld	a5,0(s2)
ffffffffc0201eb2:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6ea90>
ffffffffc0201eb6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eba:	8b89                	andi	a5,a5,2
ffffffffc0201ebc:	28079363          	bnez	a5,ffffffffc0202142 <pmm_init+0x656>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ec0:	000bb783          	ld	a5,0(s7)
ffffffffc0201ec4:	779c                	ld	a5,40(a5)
ffffffffc0201ec6:	9782                	jalr	a5
ffffffffc0201ec8:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0201eca:	75441963          	bne	s0,s4,ffffffffc020261c <pmm_init+0xb30>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ece:	00003517          	auipc	a0,0x3
ffffffffc0201ed2:	48a50513          	addi	a0,a0,1162 # ffffffffc0205358 <etext+0x10b0>
ffffffffc0201ed6:	9e4fe0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0201eda:	100027f3          	csrr	a5,sstatus
ffffffffc0201ede:	8b89                	andi	a5,a5,2
ffffffffc0201ee0:	24079763          	bnez	a5,ffffffffc020212e <pmm_init+0x642>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201ee4:	000bb783          	ld	a5,0(s7)
ffffffffc0201ee8:	779c                	ld	a5,40(a5)
ffffffffc0201eea:	9782                	jalr	a5
ffffffffc0201eec:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eee:	6098                	ld	a4,0(s1)
ffffffffc0201ef0:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ef4:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ef6:	00c71793          	slli	a5,a4,0xc
ffffffffc0201efa:	6a85                	lui	s5,0x1
ffffffffc0201efc:	02f47c63          	bgeu	s0,a5,ffffffffc0201f34 <pmm_init+0x448>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f00:	00c45793          	srli	a5,s0,0xc
ffffffffc0201f04:	00093503          	ld	a0,0(s2)
ffffffffc0201f08:	30e7fd63          	bgeu	a5,a4,ffffffffc0202222 <pmm_init+0x736>
ffffffffc0201f0c:	0009b583          	ld	a1,0(s3)
ffffffffc0201f10:	4601                	li	a2,0
ffffffffc0201f12:	95a2                	add	a1,a1,s0
ffffffffc0201f14:	fcaff0ef          	jal	ffffffffc02016de <get_pte>
ffffffffc0201f18:	2e050563          	beqz	a0,ffffffffc0202202 <pmm_init+0x716>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f1c:	611c                	ld	a5,0(a0)
ffffffffc0201f1e:	078a                	slli	a5,a5,0x2
ffffffffc0201f20:	0147f7b3          	and	a5,a5,s4
ffffffffc0201f24:	2a879f63          	bne	a5,s0,ffffffffc02021e2 <pmm_init+0x6f6>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f28:	6098                	ld	a4,0(s1)
ffffffffc0201f2a:	9456                	add	s0,s0,s5
ffffffffc0201f2c:	00c71793          	slli	a5,a4,0xc
ffffffffc0201f30:	fcf468e3          	bltu	s0,a5,ffffffffc0201f00 <pmm_init+0x414>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f34:	00093783          	ld	a5,0(s2)
ffffffffc0201f38:	639c                	ld	a5,0(a5)
ffffffffc0201f3a:	6c079163          	bnez	a5,ffffffffc02025fc <pmm_init+0xb10>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f3e:	4505                	li	a0,1
ffffffffc0201f40:	e9cff0ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0201f44:	842a                	mv	s0,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f46:	00093503          	ld	a0,0(s2)
ffffffffc0201f4a:	85a2                	mv	a1,s0
ffffffffc0201f4c:	4699                	li	a3,6
ffffffffc0201f4e:	10000613          	li	a2,256
ffffffffc0201f52:	a9bff0ef          	jal	ffffffffc02019ec <page_insert>
ffffffffc0201f56:	68051363          	bnez	a0,ffffffffc02025dc <pmm_init+0xaf0>
    assert(page_ref(p) == 1);
ffffffffc0201f5a:	4018                	lw	a4,0(s0)
ffffffffc0201f5c:	4785                	li	a5,1
ffffffffc0201f5e:	64f71f63          	bne	a4,a5,ffffffffc02025bc <pmm_init+0xad0>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f62:	00093503          	ld	a0,0(s2)
ffffffffc0201f66:	6605                	lui	a2,0x1
ffffffffc0201f68:	10060613          	addi	a2,a2,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f6c:	4699                	li	a3,6
ffffffffc0201f6e:	85a2                	mv	a1,s0
ffffffffc0201f70:	a7dff0ef          	jal	ffffffffc02019ec <page_insert>
ffffffffc0201f74:	4a051863          	bnez	a0,ffffffffc0202424 <pmm_init+0x938>
    assert(page_ref(p) == 2);
ffffffffc0201f78:	4018                	lw	a4,0(s0)
ffffffffc0201f7a:	4789                	li	a5,2
ffffffffc0201f7c:	76f71c63          	bne	a4,a5,ffffffffc02026f4 <pmm_init+0xc08>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f80:	00003597          	auipc	a1,0x3
ffffffffc0201f84:	51058593          	addi	a1,a1,1296 # ffffffffc0205490 <etext+0x11e8>
ffffffffc0201f88:	10000513          	li	a0,256
ffffffffc0201f8c:	296020ef          	jal	ffffffffc0204222 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f90:	6585                	lui	a1,0x1
ffffffffc0201f92:	10058593          	addi	a1,a1,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0201f96:	10000513          	li	a0,256
ffffffffc0201f9a:	29a020ef          	jal	ffffffffc0204234 <strcmp>
ffffffffc0201f9e:	72051b63          	bnez	a0,ffffffffc02026d4 <pmm_init+0xbe8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fa2:	000b3683          	ld	a3,0(s6)
ffffffffc0201fa6:	8e38e7b7          	lui	a5,0x8e38e
ffffffffc0201faa:	38e78793          	addi	a5,a5,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc0201fae:	38e39737          	lui	a4,0x38e39
ffffffffc0201fb2:	1782                	slli	a5,a5,0x20
ffffffffc0201fb4:	e3970713          	addi	a4,a4,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0201fb8:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fbc:	00e78ab3          	add	s5,a5,a4
ffffffffc0201fc0:	868d                	srai	a3,a3,0x3
ffffffffc0201fc2:	035686b3          	mul	a3,a3,s5
ffffffffc0201fc6:	00080cb7          	lui	s9,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fca:	609c                	ld	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fcc:	96e6                	add	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fce:	00c69713          	slli	a4,a3,0xc
ffffffffc0201fd2:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd4:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fd6:	54f77763          	bgeu	a4,a5,ffffffffc0202524 <pmm_init+0xa38>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fda:	0009b703          	ld	a4,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fde:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fe2:	9736                	add	a4,a4,a3
ffffffffc0201fe4:	10070023          	sb	zero,256(a4)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fe8:	204020ef          	jal	ffffffffc02041ec <strlen>
ffffffffc0201fec:	6c051463          	bnez	a0,ffffffffc02026b4 <pmm_init+0xbc8>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201ff0:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201ff4:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ff6:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc0201ffa:	078a                	slli	a5,a5,0x2
ffffffffc0201ffc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ffe:	22c7ff63          	bgeu	a5,a2,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc0202002:	419787b3          	sub	a5,a5,s9
ffffffffc0202006:	00379713          	slli	a4,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020200a:	97ba                	add	a5,a5,a4
ffffffffc020200c:	035787b3          	mul	a5,a5,s5
ffffffffc0202010:	97e6                	add	a5,a5,s9
    return page2ppn(page) << PGSHIFT;
ffffffffc0202012:	00c79693          	slli	a3,a5,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202016:	50c7f763          	bgeu	a5,a2,ffffffffc0202524 <pmm_init+0xa38>
ffffffffc020201a:	0009b783          	ld	a5,0(s3)
ffffffffc020201e:	00f689b3          	add	s3,a3,a5
ffffffffc0202022:	100027f3          	csrr	a5,sstatus
ffffffffc0202026:	8b89                	andi	a5,a5,2
ffffffffc0202028:	1a079263          	bnez	a5,ffffffffc02021cc <pmm_init+0x6e0>
    { pmm_manager->free_pages(base, n); }
ffffffffc020202c:	000bb783          	ld	a5,0(s7)
ffffffffc0202030:	8522                	mv	a0,s0
ffffffffc0202032:	4585                	li	a1,1
ffffffffc0202034:	739c                	ld	a5,32(a5)
ffffffffc0202036:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202038:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020203c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020203e:	078a                	slli	a5,a5,0x2
ffffffffc0202040:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202042:	1ee7fd63          	bgeu	a5,a4,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc0202046:	fff80737          	lui	a4,0xfff80
ffffffffc020204a:	97ba                	add	a5,a5,a4
ffffffffc020204c:	000b3503          	ld	a0,0(s6)
ffffffffc0202050:	00379713          	slli	a4,a5,0x3
ffffffffc0202054:	97ba                	add	a5,a5,a4
ffffffffc0202056:	078e                	slli	a5,a5,0x3
ffffffffc0202058:	953e                	add	a0,a0,a5
ffffffffc020205a:	100027f3          	csrr	a5,sstatus
ffffffffc020205e:	8b89                	andi	a5,a5,2
ffffffffc0202060:	14079a63          	bnez	a5,ffffffffc02021b4 <pmm_init+0x6c8>
ffffffffc0202064:	000bb783          	ld	a5,0(s7)
ffffffffc0202068:	4585                	li	a1,1
ffffffffc020206a:	739c                	ld	a5,32(a5)
ffffffffc020206c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020206e:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202072:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202074:	078a                	slli	a5,a5,0x2
ffffffffc0202076:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202078:	1ce7f263          	bgeu	a5,a4,ffffffffc020223c <pmm_init+0x750>
    return &pages[PPN(pa) - nbase];
ffffffffc020207c:	fff80737          	lui	a4,0xfff80
ffffffffc0202080:	97ba                	add	a5,a5,a4
ffffffffc0202082:	000b3503          	ld	a0,0(s6)
ffffffffc0202086:	00379713          	slli	a4,a5,0x3
ffffffffc020208a:	97ba                	add	a5,a5,a4
ffffffffc020208c:	078e                	slli	a5,a5,0x3
ffffffffc020208e:	953e                	add	a0,a0,a5
ffffffffc0202090:	100027f3          	csrr	a5,sstatus
ffffffffc0202094:	8b89                	andi	a5,a5,2
ffffffffc0202096:	10079363          	bnez	a5,ffffffffc020219c <pmm_init+0x6b0>
ffffffffc020209a:	000bb783          	ld	a5,0(s7)
ffffffffc020209e:	4585                	li	a1,1
ffffffffc02020a0:	739c                	ld	a5,32(a5)
ffffffffc02020a2:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02020a4:	00093783          	ld	a5,0(s2)
ffffffffc02020a8:	0007b023          	sd	zero,0(a5)
ffffffffc02020ac:	100027f3          	csrr	a5,sstatus
ffffffffc02020b0:	8b89                	andi	a5,a5,2
ffffffffc02020b2:	0c079b63          	bnez	a5,ffffffffc0202188 <pmm_init+0x69c>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02020b6:	000bb783          	ld	a5,0(s7)
ffffffffc02020ba:	779c                	ld	a5,40(a5)
ffffffffc02020bc:	9782                	jalr	a5
ffffffffc02020be:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02020c0:	3c8c1263          	bne	s8,s0,ffffffffc0202484 <pmm_init+0x998>
}
ffffffffc02020c4:	7406                	ld	s0,96(sp)
ffffffffc02020c6:	70a6                	ld	ra,104(sp)
ffffffffc02020c8:	64e6                	ld	s1,88(sp)
ffffffffc02020ca:	6946                	ld	s2,80(sp)
ffffffffc02020cc:	69a6                	ld	s3,72(sp)
ffffffffc02020ce:	6a06                	ld	s4,64(sp)
ffffffffc02020d0:	7ae2                	ld	s5,56(sp)
ffffffffc02020d2:	7b42                	ld	s6,48(sp)
ffffffffc02020d4:	7ba2                	ld	s7,40(sp)
ffffffffc02020d6:	7c02                	ld	s8,32(sp)
ffffffffc02020d8:	6ce2                	ld	s9,24(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020da:	00003517          	auipc	a0,0x3
ffffffffc02020de:	42e50513          	addi	a0,a0,1070 # ffffffffc0205508 <etext+0x1260>
}
ffffffffc02020e2:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020e4:	fd7fd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020e8:	6585                	lui	a1,0x1
ffffffffc02020ea:	15fd                	addi	a1,a1,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02020ec:	97ae                	add	a5,a5,a1
ffffffffc02020ee:	75fd                	lui	a1,0xfffff
ffffffffc02020f0:	8fed                	and	a5,a5,a1
    if (PPN(pa) >= npage) {
ffffffffc02020f2:	00c7d593          	srli	a1,a5,0xc
ffffffffc02020f6:	14c5f363          	bgeu	a1,a2,ffffffffc020223c <pmm_init+0x750>
    pmm_manager->init_memmap(base, n);
ffffffffc02020fa:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02020fe:	00a58633          	add	a2,a1,a0
ffffffffc0202102:	00361513          	slli	a0,a2,0x3
ffffffffc0202106:	9532                	add	a0,a0,a2
ffffffffc0202108:	01083603          	ld	a2,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020210c:	8f1d                	sub	a4,a4,a5
ffffffffc020210e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202110:	00c75593          	srli	a1,a4,0xc
ffffffffc0202114:	9536                	add	a0,a0,a3
ffffffffc0202116:	9602                	jalr	a2
}
ffffffffc0202118:	bce9                	j	ffffffffc0201bf2 <pmm_init+0x106>
        intr_disable();
ffffffffc020211a:	bb0fe0ef          	jal	ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020211e:	000bb783          	ld	a5,0(s7)
ffffffffc0202122:	779c                	ld	a5,40(a5)
ffffffffc0202124:	9782                	jalr	a5
ffffffffc0202126:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202128:	b9cfe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc020212c:	be21                	j	ffffffffc0201c44 <pmm_init+0x158>
        intr_disable();
ffffffffc020212e:	b9cfe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc0202132:	000bb783          	ld	a5,0(s7)
ffffffffc0202136:	779c                	ld	a5,40(a5)
ffffffffc0202138:	9782                	jalr	a5
ffffffffc020213a:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020213c:	b88fe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc0202140:	b37d                	j	ffffffffc0201eee <pmm_init+0x402>
        intr_disable();
ffffffffc0202142:	b88fe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc0202146:	000bb783          	ld	a5,0(s7)
ffffffffc020214a:	779c                	ld	a5,40(a5)
ffffffffc020214c:	9782                	jalr	a5
ffffffffc020214e:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202150:	b74fe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc0202154:	bb9d                	j	ffffffffc0201eca <pmm_init+0x3de>
ffffffffc0202156:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202158:	b72fe0ef          	jal	ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020215c:	000bb783          	ld	a5,0(s7)
ffffffffc0202160:	6502                	ld	a0,0(sp)
ffffffffc0202162:	4585                	li	a1,1
ffffffffc0202164:	739c                	ld	a5,32(a5)
ffffffffc0202166:	9782                	jalr	a5
        intr_enable();
ffffffffc0202168:	b5cfe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc020216c:	b389                	j	ffffffffc0201eae <pmm_init+0x3c2>
ffffffffc020216e:	e42e                	sd	a1,8(sp)
ffffffffc0202170:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202172:	b58fe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc0202176:	000bb783          	ld	a5,0(s7)
ffffffffc020217a:	65a2                	ld	a1,8(sp)
ffffffffc020217c:	6502                	ld	a0,0(sp)
ffffffffc020217e:	739c                	ld	a5,32(a5)
ffffffffc0202180:	9782                	jalr	a5
        intr_enable();
ffffffffc0202182:	b42fe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc0202186:	b9cd                	j	ffffffffc0201e78 <pmm_init+0x38c>
        intr_disable();
ffffffffc0202188:	b42fe0ef          	jal	ffffffffc02004ca <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020218c:	000bb783          	ld	a5,0(s7)
ffffffffc0202190:	779c                	ld	a5,40(a5)
ffffffffc0202192:	9782                	jalr	a5
ffffffffc0202194:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202196:	b2efe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc020219a:	b71d                	j	ffffffffc02020c0 <pmm_init+0x5d4>
ffffffffc020219c:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020219e:	b2cfe0ef          	jal	ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02021a2:	000bb783          	ld	a5,0(s7)
ffffffffc02021a6:	6502                	ld	a0,0(sp)
ffffffffc02021a8:	4585                	li	a1,1
ffffffffc02021aa:	739c                	ld	a5,32(a5)
ffffffffc02021ac:	9782                	jalr	a5
        intr_enable();
ffffffffc02021ae:	b16fe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc02021b2:	bdcd                	j	ffffffffc02020a4 <pmm_init+0x5b8>
ffffffffc02021b4:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc02021b6:	b14fe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc02021ba:	000bb783          	ld	a5,0(s7)
ffffffffc02021be:	6502                	ld	a0,0(sp)
ffffffffc02021c0:	4585                	li	a1,1
ffffffffc02021c2:	739c                	ld	a5,32(a5)
ffffffffc02021c4:	9782                	jalr	a5
        intr_enable();
ffffffffc02021c6:	afefe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc02021ca:	b555                	j	ffffffffc020206e <pmm_init+0x582>
        intr_disable();
ffffffffc02021cc:	afefe0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc02021d0:	000bb783          	ld	a5,0(s7)
ffffffffc02021d4:	8522                	mv	a0,s0
ffffffffc02021d6:	4585                	li	a1,1
ffffffffc02021d8:	739c                	ld	a5,32(a5)
ffffffffc02021da:	9782                	jalr	a5
        intr_enable();
ffffffffc02021dc:	ae8fe0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc02021e0:	bda1                	j	ffffffffc0202038 <pmm_init+0x54c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02021e2:	00003697          	auipc	a3,0x3
ffffffffc02021e6:	1d668693          	addi	a3,a3,470 # ffffffffc02053b8 <etext+0x1110>
ffffffffc02021ea:	00003617          	auipc	a2,0x3
ffffffffc02021ee:	99660613          	addi	a2,a2,-1642 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02021f2:	1d200593          	li	a1,466
ffffffffc02021f6:	00003517          	auipc	a0,0x3
ffffffffc02021fa:	d9250513          	addi	a0,a0,-622 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02021fe:	94efe0ef          	jal	ffffffffc020034c <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202202:	00003697          	auipc	a3,0x3
ffffffffc0202206:	17668693          	addi	a3,a3,374 # ffffffffc0205378 <etext+0x10d0>
ffffffffc020220a:	00003617          	auipc	a2,0x3
ffffffffc020220e:	97660613          	addi	a2,a2,-1674 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202212:	1d100593          	li	a1,465
ffffffffc0202216:	00003517          	auipc	a0,0x3
ffffffffc020221a:	d7250513          	addi	a0,a0,-654 # ffffffffc0204f88 <etext+0xce0>
ffffffffc020221e:	92efe0ef          	jal	ffffffffc020034c <__panic>
ffffffffc0202222:	86a2                	mv	a3,s0
ffffffffc0202224:	00003617          	auipc	a2,0x3
ffffffffc0202228:	d3c60613          	addi	a2,a2,-708 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc020222c:	1d100593          	li	a1,465
ffffffffc0202230:	00003517          	auipc	a0,0x3
ffffffffc0202234:	d5850513          	addi	a0,a0,-680 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202238:	914fe0ef          	jal	ffffffffc020034c <__panic>
ffffffffc020223c:	b84ff0ef          	jal	ffffffffc02015c0 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202240:	86be                	mv	a3,a5
ffffffffc0202242:	00003617          	auipc	a2,0x3
ffffffffc0202246:	dde60613          	addi	a2,a2,-546 # ffffffffc0205020 <etext+0xd78>
ffffffffc020224a:	07700593          	li	a1,119
ffffffffc020224e:	00003517          	auipc	a0,0x3
ffffffffc0202252:	d3a50513          	addi	a0,a0,-710 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202256:	8f6fe0ef          	jal	ffffffffc020034c <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020225a:	00003617          	auipc	a2,0x3
ffffffffc020225e:	dc660613          	addi	a2,a2,-570 # ffffffffc0205020 <etext+0xd78>
ffffffffc0202262:	0bd00593          	li	a1,189
ffffffffc0202266:	00003517          	auipc	a0,0x3
ffffffffc020226a:	d2250513          	addi	a0,a0,-734 # ffffffffc0204f88 <etext+0xce0>
ffffffffc020226e:	8defe0ef          	jal	ffffffffc020034c <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202272:	00003697          	auipc	a3,0x3
ffffffffc0202276:	e1668693          	addi	a3,a3,-490 # ffffffffc0205088 <etext+0xde0>
ffffffffc020227a:	00003617          	auipc	a2,0x3
ffffffffc020227e:	90660613          	addi	a2,a2,-1786 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202282:	19700593          	li	a1,407
ffffffffc0202286:	00003517          	auipc	a0,0x3
ffffffffc020228a:	d0250513          	addi	a0,a0,-766 # ffffffffc0204f88 <etext+0xce0>
ffffffffc020228e:	8befe0ef          	jal	ffffffffc020034c <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202292:	00003697          	auipc	a3,0x3
ffffffffc0202296:	dd668693          	addi	a3,a3,-554 # ffffffffc0205068 <etext+0xdc0>
ffffffffc020229a:	00003617          	auipc	a2,0x3
ffffffffc020229e:	8e660613          	addi	a2,a2,-1818 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02022a2:	19600593          	li	a1,406
ffffffffc02022a6:	00003517          	auipc	a0,0x3
ffffffffc02022aa:	ce250513          	addi	a0,a0,-798 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02022ae:	89efe0ef          	jal	ffffffffc020034c <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02022b2:	00003617          	auipc	a2,0x3
ffffffffc02022b6:	e9660613          	addi	a2,a2,-362 # ffffffffc0205148 <etext+0xea0>
ffffffffc02022ba:	07300593          	li	a1,115
ffffffffc02022be:	00003517          	auipc	a0,0x3
ffffffffc02022c2:	c9250513          	addi	a0,a0,-878 # ffffffffc0204f50 <etext+0xca8>
ffffffffc02022c6:	886fe0ef          	jal	ffffffffc020034c <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02022ca:	00003697          	auipc	a3,0x3
ffffffffc02022ce:	e4e68693          	addi	a3,a3,-434 # ffffffffc0205118 <etext+0xe70>
ffffffffc02022d2:	00003617          	auipc	a2,0x3
ffffffffc02022d6:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02022da:	19e00593          	li	a1,414
ffffffffc02022de:	00003517          	auipc	a0,0x3
ffffffffc02022e2:	caa50513          	addi	a0,a0,-854 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02022e6:	866fe0ef          	jal	ffffffffc020034c <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02022ea:	00003697          	auipc	a3,0x3
ffffffffc02022ee:	dfe68693          	addi	a3,a3,-514 # ffffffffc02050e8 <etext+0xe40>
ffffffffc02022f2:	00003617          	auipc	a2,0x3
ffffffffc02022f6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02022fa:	19c00593          	li	a1,412
ffffffffc02022fe:	00003517          	auipc	a0,0x3
ffffffffc0202302:	c8a50513          	addi	a0,a0,-886 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202306:	846fe0ef          	jal	ffffffffc020034c <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020230a:	00003697          	auipc	a3,0x3
ffffffffc020230e:	db668693          	addi	a3,a3,-586 # ffffffffc02050c0 <etext+0xe18>
ffffffffc0202312:	00003617          	auipc	a2,0x3
ffffffffc0202316:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020231a:	19800593          	li	a1,408
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	c6a50513          	addi	a0,a0,-918 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202326:	826fe0ef          	jal	ffffffffc020034c <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	e9e68693          	addi	a3,a3,-354 # ffffffffc02051c8 <etext+0xf20>
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020233a:	1a700593          	li	a1,423
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	c4a50513          	addi	a0,a0,-950 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202346:	806fe0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	f1e68693          	addi	a3,a3,-226 # ffffffffc0205268 <etext+0xfc0>
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020235a:	1ac00593          	li	a1,428
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	c2a50513          	addi	a0,a0,-982 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202366:	fe7fd0ef          	jal	ffffffffc020034c <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	e3668693          	addi	a3,a3,-458 # ffffffffc02051a0 <etext+0xef8>
ffffffffc0202372:	00003617          	auipc	a2,0x3
ffffffffc0202376:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020237a:	1a400593          	li	a1,420
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202386:	fc7fd0ef          	jal	ffffffffc020034c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020238a:	86d6                	mv	a3,s5
ffffffffc020238c:	00003617          	auipc	a2,0x3
ffffffffc0202390:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc0202394:	1a300593          	li	a1,419
ffffffffc0202398:	00003517          	auipc	a0,0x3
ffffffffc020239c:	bf050513          	addi	a0,a0,-1040 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02023a0:	fadfd0ef          	jal	ffffffffc020034c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02023a4:	00003697          	auipc	a3,0x3
ffffffffc02023a8:	e5c68693          	addi	a3,a3,-420 # ffffffffc0205200 <etext+0xf58>
ffffffffc02023ac:	00002617          	auipc	a2,0x2
ffffffffc02023b0:	7d460613          	addi	a2,a2,2004 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02023b4:	1b100593          	li	a1,433
ffffffffc02023b8:	00003517          	auipc	a0,0x3
ffffffffc02023bc:	bd050513          	addi	a0,a0,-1072 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02023c0:	f8dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02023c4:	00003697          	auipc	a3,0x3
ffffffffc02023c8:	f0468693          	addi	a3,a3,-252 # ffffffffc02052c8 <etext+0x1020>
ffffffffc02023cc:	00002617          	auipc	a2,0x2
ffffffffc02023d0:	7b460613          	addi	a2,a2,1972 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02023d4:	1b000593          	li	a1,432
ffffffffc02023d8:	00003517          	auipc	a0,0x3
ffffffffc02023dc:	bb050513          	addi	a0,a0,-1104 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02023e0:	f6dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02023e4:	00003697          	auipc	a3,0x3
ffffffffc02023e8:	ecc68693          	addi	a3,a3,-308 # ffffffffc02052b0 <etext+0x1008>
ffffffffc02023ec:	00002617          	auipc	a2,0x2
ffffffffc02023f0:	79460613          	addi	a2,a2,1940 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02023f4:	1af00593          	li	a1,431
ffffffffc02023f8:	00003517          	auipc	a0,0x3
ffffffffc02023fc:	b9050513          	addi	a0,a0,-1136 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202400:	f4dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202404:	00003697          	auipc	a3,0x3
ffffffffc0202408:	e7c68693          	addi	a3,a3,-388 # ffffffffc0205280 <etext+0xfd8>
ffffffffc020240c:	00002617          	auipc	a2,0x2
ffffffffc0202410:	77460613          	addi	a2,a2,1908 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202414:	1ae00593          	li	a1,430
ffffffffc0202418:	00003517          	auipc	a0,0x3
ffffffffc020241c:	b7050513          	addi	a0,a0,-1168 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202420:	f2dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202424:	00003697          	auipc	a3,0x3
ffffffffc0202428:	01468693          	addi	a3,a3,20 # ffffffffc0205438 <etext+0x1190>
ffffffffc020242c:	00002617          	auipc	a2,0x2
ffffffffc0202430:	75460613          	addi	a2,a2,1876 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202434:	1dc00593          	li	a1,476
ffffffffc0202438:	00003517          	auipc	a0,0x3
ffffffffc020243c:	b5050513          	addi	a0,a0,-1200 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202440:	f0dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202444:	00003697          	auipc	a3,0x3
ffffffffc0202448:	e0c68693          	addi	a3,a3,-500 # ffffffffc0205250 <etext+0xfa8>
ffffffffc020244c:	00002617          	auipc	a2,0x2
ffffffffc0202450:	73460613          	addi	a2,a2,1844 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202454:	1ab00593          	li	a1,427
ffffffffc0202458:	00003517          	auipc	a0,0x3
ffffffffc020245c:	b3050513          	addi	a0,a0,-1232 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202460:	eedfd0ef          	jal	ffffffffc020034c <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202464:	00003697          	auipc	a3,0x3
ffffffffc0202468:	ddc68693          	addi	a3,a3,-548 # ffffffffc0205240 <etext+0xf98>
ffffffffc020246c:	00002617          	auipc	a2,0x2
ffffffffc0202470:	71460613          	addi	a2,a2,1812 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202474:	1aa00593          	li	a1,426
ffffffffc0202478:	00003517          	auipc	a0,0x3
ffffffffc020247c:	b1050513          	addi	a0,a0,-1264 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202480:	ecdfd0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202484:	00003697          	auipc	a3,0x3
ffffffffc0202488:	eb468693          	addi	a3,a3,-332 # ffffffffc0205338 <etext+0x1090>
ffffffffc020248c:	00002617          	auipc	a2,0x2
ffffffffc0202490:	6f460613          	addi	a2,a2,1780 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202494:	1ec00593          	li	a1,492
ffffffffc0202498:	00003517          	auipc	a0,0x3
ffffffffc020249c:	af050513          	addi	a0,a0,-1296 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02024a0:	eadfd0ef          	jal	ffffffffc020034c <__panic>
    assert(*ptep & PTE_U);
ffffffffc02024a4:	00003697          	auipc	a3,0x3
ffffffffc02024a8:	d8c68693          	addi	a3,a3,-628 # ffffffffc0205230 <etext+0xf88>
ffffffffc02024ac:	00002617          	auipc	a2,0x2
ffffffffc02024b0:	6d460613          	addi	a2,a2,1748 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02024b4:	1a900593          	li	a1,425
ffffffffc02024b8:	00003517          	auipc	a0,0x3
ffffffffc02024bc:	ad050513          	addi	a0,a0,-1328 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02024c0:	e8dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024c4:	00003697          	auipc	a3,0x3
ffffffffc02024c8:	cc468693          	addi	a3,a3,-828 # ffffffffc0205188 <etext+0xee0>
ffffffffc02024cc:	00002617          	auipc	a2,0x2
ffffffffc02024d0:	6b460613          	addi	a2,a2,1716 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02024d4:	1b600593          	li	a1,438
ffffffffc02024d8:	00003517          	auipc	a0,0x3
ffffffffc02024dc:	ab050513          	addi	a0,a0,-1360 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02024e0:	e6dfd0ef          	jal	ffffffffc020034c <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024e4:	00003697          	auipc	a3,0x3
ffffffffc02024e8:	dfc68693          	addi	a3,a3,-516 # ffffffffc02052e0 <etext+0x1038>
ffffffffc02024ec:	00002617          	auipc	a2,0x2
ffffffffc02024f0:	69460613          	addi	a2,a2,1684 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02024f4:	1b300593          	li	a1,435
ffffffffc02024f8:	00003517          	auipc	a0,0x3
ffffffffc02024fc:	a9050513          	addi	a0,a0,-1392 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202500:	e4dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202504:	00003697          	auipc	a3,0x3
ffffffffc0202508:	c6c68693          	addi	a3,a3,-916 # ffffffffc0205170 <etext+0xec8>
ffffffffc020250c:	00002617          	auipc	a2,0x2
ffffffffc0202510:	67460613          	addi	a2,a2,1652 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202514:	1b200593          	li	a1,434
ffffffffc0202518:	00003517          	auipc	a0,0x3
ffffffffc020251c:	a7050513          	addi	a0,a0,-1424 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202520:	e2dfd0ef          	jal	ffffffffc020034c <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202524:	00003617          	auipc	a2,0x3
ffffffffc0202528:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc020252c:	06d00593          	li	a1,109
ffffffffc0202530:	00003517          	auipc	a0,0x3
ffffffffc0202534:	a2050513          	addi	a0,a0,-1504 # ffffffffc0204f50 <etext+0xca8>
ffffffffc0202538:	e15fd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020253c:	00003697          	auipc	a3,0x3
ffffffffc0202540:	dd468693          	addi	a3,a3,-556 # ffffffffc0205310 <etext+0x1068>
ffffffffc0202544:	00002617          	auipc	a2,0x2
ffffffffc0202548:	63c60613          	addi	a2,a2,1596 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020254c:	1bd00593          	li	a1,445
ffffffffc0202550:	00003517          	auipc	a0,0x3
ffffffffc0202554:	a3850513          	addi	a0,a0,-1480 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202558:	df5fd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020255c:	00003697          	auipc	a3,0x3
ffffffffc0202560:	d6c68693          	addi	a3,a3,-660 # ffffffffc02052c8 <etext+0x1020>
ffffffffc0202564:	00002617          	auipc	a2,0x2
ffffffffc0202568:	61c60613          	addi	a2,a2,1564 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020256c:	1bb00593          	li	a1,443
ffffffffc0202570:	00003517          	auipc	a0,0x3
ffffffffc0202574:	a1850513          	addi	a0,a0,-1512 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202578:	dd5fd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020257c:	00003697          	auipc	a3,0x3
ffffffffc0202580:	d7c68693          	addi	a3,a3,-644 # ffffffffc02052f8 <etext+0x1050>
ffffffffc0202584:	00002617          	auipc	a2,0x2
ffffffffc0202588:	5fc60613          	addi	a2,a2,1532 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020258c:	1ba00593          	li	a1,442
ffffffffc0202590:	00003517          	auipc	a0,0x3
ffffffffc0202594:	9f850513          	addi	a0,a0,-1544 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202598:	db5fd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020259c:	00003697          	auipc	a3,0x3
ffffffffc02025a0:	d2c68693          	addi	a3,a3,-724 # ffffffffc02052c8 <etext+0x1020>
ffffffffc02025a4:	00002617          	auipc	a2,0x2
ffffffffc02025a8:	5dc60613          	addi	a2,a2,1500 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02025ac:	1b700593          	li	a1,439
ffffffffc02025b0:	00003517          	auipc	a0,0x3
ffffffffc02025b4:	9d850513          	addi	a0,a0,-1576 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02025b8:	d95fd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025bc:	00003697          	auipc	a3,0x3
ffffffffc02025c0:	e6468693          	addi	a3,a3,-412 # ffffffffc0205420 <etext+0x1178>
ffffffffc02025c4:	00002617          	auipc	a2,0x2
ffffffffc02025c8:	5bc60613          	addi	a2,a2,1468 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02025cc:	1db00593          	li	a1,475
ffffffffc02025d0:	00003517          	auipc	a0,0x3
ffffffffc02025d4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02025d8:	d75fd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025dc:	00003697          	auipc	a3,0x3
ffffffffc02025e0:	e0c68693          	addi	a3,a3,-500 # ffffffffc02053e8 <etext+0x1140>
ffffffffc02025e4:	00002617          	auipc	a2,0x2
ffffffffc02025e8:	59c60613          	addi	a2,a2,1436 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02025ec:	1da00593          	li	a1,474
ffffffffc02025f0:	00003517          	auipc	a0,0x3
ffffffffc02025f4:	99850513          	addi	a0,a0,-1640 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02025f8:	d55fd0ef          	jal	ffffffffc020034c <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025fc:	00003697          	auipc	a3,0x3
ffffffffc0202600:	dd468693          	addi	a3,a3,-556 # ffffffffc02053d0 <etext+0x1128>
ffffffffc0202604:	00002617          	auipc	a2,0x2
ffffffffc0202608:	57c60613          	addi	a2,a2,1404 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020260c:	1d600593          	li	a1,470
ffffffffc0202610:	00003517          	auipc	a0,0x3
ffffffffc0202614:	97850513          	addi	a0,a0,-1672 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202618:	d35fd0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020261c:	00003697          	auipc	a3,0x3
ffffffffc0202620:	d1c68693          	addi	a3,a3,-740 # ffffffffc0205338 <etext+0x1090>
ffffffffc0202624:	00002617          	auipc	a2,0x2
ffffffffc0202628:	55c60613          	addi	a2,a2,1372 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020262c:	1c400593          	li	a1,452
ffffffffc0202630:	00003517          	auipc	a0,0x3
ffffffffc0202634:	95850513          	addi	a0,a0,-1704 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202638:	d15fd0ef          	jal	ffffffffc020034c <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020263c:	00003697          	auipc	a3,0x3
ffffffffc0202640:	b3468693          	addi	a3,a3,-1228 # ffffffffc0205170 <etext+0xec8>
ffffffffc0202644:	00002617          	auipc	a2,0x2
ffffffffc0202648:	53c60613          	addi	a2,a2,1340 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020264c:	19f00593          	li	a1,415
ffffffffc0202650:	00003517          	auipc	a0,0x3
ffffffffc0202654:	93850513          	addi	a0,a0,-1736 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202658:	cf5fd0ef          	jal	ffffffffc020034c <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020265c:	00003617          	auipc	a2,0x3
ffffffffc0202660:	90460613          	addi	a2,a2,-1788 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc0202664:	1a200593          	li	a1,418
ffffffffc0202668:	00003517          	auipc	a0,0x3
ffffffffc020266c:	92050513          	addi	a0,a0,-1760 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202670:	cddfd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202674:	00003697          	auipc	a3,0x3
ffffffffc0202678:	b1468693          	addi	a3,a3,-1260 # ffffffffc0205188 <etext+0xee0>
ffffffffc020267c:	00002617          	auipc	a2,0x2
ffffffffc0202680:	50460613          	addi	a2,a2,1284 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202684:	1a000593          	li	a1,416
ffffffffc0202688:	00003517          	auipc	a0,0x3
ffffffffc020268c:	90050513          	addi	a0,a0,-1792 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202690:	cbdfd0ef          	jal	ffffffffc020034c <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202694:	00003697          	auipc	a3,0x3
ffffffffc0202698:	b6c68693          	addi	a3,a3,-1172 # ffffffffc0205200 <etext+0xf58>
ffffffffc020269c:	00002617          	auipc	a2,0x2
ffffffffc02026a0:	4e460613          	addi	a2,a2,1252 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02026a4:	1a800593          	li	a1,424
ffffffffc02026a8:	00003517          	auipc	a0,0x3
ffffffffc02026ac:	8e050513          	addi	a0,a0,-1824 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02026b0:	c9dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02026b4:	00003697          	auipc	a3,0x3
ffffffffc02026b8:	e2c68693          	addi	a3,a3,-468 # ffffffffc02054e0 <etext+0x1238>
ffffffffc02026bc:	00002617          	auipc	a2,0x2
ffffffffc02026c0:	4c460613          	addi	a2,a2,1220 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02026c4:	1e400593          	li	a1,484
ffffffffc02026c8:	00003517          	auipc	a0,0x3
ffffffffc02026cc:	8c050513          	addi	a0,a0,-1856 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02026d0:	c7dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02026d4:	00003697          	auipc	a3,0x3
ffffffffc02026d8:	dd468693          	addi	a3,a3,-556 # ffffffffc02054a8 <etext+0x1200>
ffffffffc02026dc:	00002617          	auipc	a2,0x2
ffffffffc02026e0:	4a460613          	addi	a2,a2,1188 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02026e4:	1e100593          	li	a1,481
ffffffffc02026e8:	00003517          	auipc	a0,0x3
ffffffffc02026ec:	8a050513          	addi	a0,a0,-1888 # ffffffffc0204f88 <etext+0xce0>
ffffffffc02026f0:	c5dfd0ef          	jal	ffffffffc020034c <__panic>
    assert(page_ref(p) == 2);
ffffffffc02026f4:	00003697          	auipc	a3,0x3
ffffffffc02026f8:	d8468693          	addi	a3,a3,-636 # ffffffffc0205478 <etext+0x11d0>
ffffffffc02026fc:	00002617          	auipc	a2,0x2
ffffffffc0202700:	48460613          	addi	a2,a2,1156 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202704:	1dd00593          	li	a1,477
ffffffffc0202708:	00003517          	auipc	a0,0x3
ffffffffc020270c:	88050513          	addi	a0,a0,-1920 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202710:	c3dfd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0202714 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202714:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202718:	8082                	ret

ffffffffc020271a <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020271a:	7179                	addi	sp,sp,-48
ffffffffc020271c:	e84a                	sd	s2,16(sp)
ffffffffc020271e:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202720:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202722:	ec26                	sd	s1,24(sp)
ffffffffc0202724:	e44e                	sd	s3,8(sp)
ffffffffc0202726:	f406                	sd	ra,40(sp)
ffffffffc0202728:	f022                	sd	s0,32(sp)
ffffffffc020272a:	84ae                	mv	s1,a1
ffffffffc020272c:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020272e:	eaffe0ef          	jal	ffffffffc02015dc <alloc_pages>
    if (page != NULL) {
ffffffffc0202732:	c925                	beqz	a0,ffffffffc02027a2 <pgdir_alloc_page+0x88>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202734:	842a                	mv	s0,a0
ffffffffc0202736:	86ce                	mv	a3,s3
ffffffffc0202738:	854a                	mv	a0,s2
ffffffffc020273a:	8626                	mv	a2,s1
ffffffffc020273c:	85a2                	mv	a1,s0
ffffffffc020273e:	aaeff0ef          	jal	ffffffffc02019ec <page_insert>
ffffffffc0202742:	e521                	bnez	a0,ffffffffc020278a <pgdir_alloc_page+0x70>
        if (swap_init_ok) {
ffffffffc0202744:	0000f797          	auipc	a5,0xf
ffffffffc0202748:	dfc7a783          	lw	a5,-516(a5) # ffffffffc0211540 <swap_init_ok>
ffffffffc020274c:	cfa1                	beqz	a5,ffffffffc02027a4 <pgdir_alloc_page+0x8a>
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020274e:	0000f517          	auipc	a0,0xf
ffffffffc0202752:	e1a53503          	ld	a0,-486(a0) # ffffffffc0211568 <check_mm_struct>
ffffffffc0202756:	4681                	li	a3,0
ffffffffc0202758:	8622                	mv	a2,s0
ffffffffc020275a:	85a6                	mv	a1,s1
ffffffffc020275c:	0e5000ef          	jal	ffffffffc0203040 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202760:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202762:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202764:	4785                	li	a5,1
ffffffffc0202766:	02f70f63          	beq	a4,a5,ffffffffc02027a4 <pgdir_alloc_page+0x8a>
ffffffffc020276a:	00003697          	auipc	a3,0x3
ffffffffc020276e:	dbe68693          	addi	a3,a3,-578 # ffffffffc0205528 <etext+0x1280>
ffffffffc0202772:	00002617          	auipc	a2,0x2
ffffffffc0202776:	40e60613          	addi	a2,a2,1038 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020277a:	17e00593          	li	a1,382
ffffffffc020277e:	00003517          	auipc	a0,0x3
ffffffffc0202782:	80a50513          	addi	a0,a0,-2038 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202786:	bc7fd0ef          	jal	ffffffffc020034c <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020278a:	100027f3          	csrr	a5,sstatus
ffffffffc020278e:	8b89                	andi	a5,a5,2
ffffffffc0202790:	e395                	bnez	a5,ffffffffc02027b4 <pgdir_alloc_page+0x9a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202792:	0000f797          	auipc	a5,0xf
ffffffffc0202796:	d7e7b783          	ld	a5,-642(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc020279a:	8522                	mv	a0,s0
ffffffffc020279c:	4585                	li	a1,1
ffffffffc020279e:	739c                	ld	a5,32(a5)
ffffffffc02027a0:	9782                	jalr	a5
            return NULL;
ffffffffc02027a2:	4401                	li	s0,0
}
ffffffffc02027a4:	70a2                	ld	ra,40(sp)
ffffffffc02027a6:	8522                	mv	a0,s0
ffffffffc02027a8:	7402                	ld	s0,32(sp)
ffffffffc02027aa:	64e2                	ld	s1,24(sp)
ffffffffc02027ac:	6942                	ld	s2,16(sp)
ffffffffc02027ae:	69a2                	ld	s3,8(sp)
ffffffffc02027b0:	6145                	addi	sp,sp,48
ffffffffc02027b2:	8082                	ret
        intr_disable();
ffffffffc02027b4:	d17fd0ef          	jal	ffffffffc02004ca <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02027b8:	0000f797          	auipc	a5,0xf
ffffffffc02027bc:	d587b783          	ld	a5,-680(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc02027c0:	8522                	mv	a0,s0
ffffffffc02027c2:	4585                	li	a1,1
ffffffffc02027c4:	739c                	ld	a5,32(a5)
ffffffffc02027c6:	9782                	jalr	a5
        intr_enable();
ffffffffc02027c8:	cfdfd0ef          	jal	ffffffffc02004c4 <intr_enable>
ffffffffc02027cc:	bfd9                	j	ffffffffc02027a2 <pgdir_alloc_page+0x88>

ffffffffc02027ce <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02027ce:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027d0:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02027d2:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027d4:	fff50713          	addi	a4,a0,-1
ffffffffc02027d8:	17f9                	addi	a5,a5,-2 # 14ffe <kern_entry-0xffffffffc01eb002>
ffffffffc02027da:	06e7e063          	bltu	a5,a4,ffffffffc020283a <kmalloc+0x6c>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02027de:	6785                	lui	a5,0x1
ffffffffc02027e0:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02027e2:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02027e4:	8131                	srli	a0,a0,0xc
ffffffffc02027e6:	df7fe0ef          	jal	ffffffffc02015dc <alloc_pages>
    assert(base != NULL);
ffffffffc02027ea:	c549                	beqz	a0,ffffffffc0202874 <kmalloc+0xa6>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02027ec:	0000f697          	auipc	a3,0xf
ffffffffc02027f0:	d4c6b683          	ld	a3,-692(a3) # ffffffffc0211538 <pages>
ffffffffc02027f4:	8e38e7b7          	lui	a5,0x8e38e
ffffffffc02027f8:	38e78793          	addi	a5,a5,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc02027fc:	38e39737          	lui	a4,0x38e39
ffffffffc0202800:	e3970713          	addi	a4,a4,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0202804:	1782                	slli	a5,a5,0x20
ffffffffc0202806:	8d15                	sub	a0,a0,a3
ffffffffc0202808:	97ba                	add	a5,a5,a4
ffffffffc020280a:	850d                	srai	a0,a0,0x3
ffffffffc020280c:	02f50533          	mul	a0,a0,a5
ffffffffc0202810:	000807b7          	lui	a5,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202814:	0000f717          	auipc	a4,0xf
ffffffffc0202818:	d1c73703          	ld	a4,-740(a4) # ffffffffc0211530 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020281c:	953e                	add	a0,a0,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020281e:	00c51793          	slli	a5,a0,0xc
ffffffffc0202822:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202824:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202826:	02e7fa63          	bgeu	a5,a4,ffffffffc020285a <kmalloc+0x8c>
ffffffffc020282a:	0000f797          	auipc	a5,0xf
ffffffffc020282e:	cfe7b783          	ld	a5,-770(a5) # ffffffffc0211528 <va_pa_offset>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0202832:	60a2                	ld	ra,8(sp)
ffffffffc0202834:	953e                	add	a0,a0,a5
ffffffffc0202836:	0141                	addi	sp,sp,16
ffffffffc0202838:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020283a:	00003697          	auipc	a3,0x3
ffffffffc020283e:	d0668693          	addi	a3,a3,-762 # ffffffffc0205540 <etext+0x1298>
ffffffffc0202842:	00002617          	auipc	a2,0x2
ffffffffc0202846:	33e60613          	addi	a2,a2,830 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020284a:	1f400593          	li	a1,500
ffffffffc020284e:	00002517          	auipc	a0,0x2
ffffffffc0202852:	73a50513          	addi	a0,a0,1850 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202856:	af7fd0ef          	jal	ffffffffc020034c <__panic>
ffffffffc020285a:	86aa                	mv	a3,a0
ffffffffc020285c:	00002617          	auipc	a2,0x2
ffffffffc0202860:	70460613          	addi	a2,a2,1796 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc0202864:	06d00593          	li	a1,109
ffffffffc0202868:	00002517          	auipc	a0,0x2
ffffffffc020286c:	6e850513          	addi	a0,a0,1768 # ffffffffc0204f50 <etext+0xca8>
ffffffffc0202870:	addfd0ef          	jal	ffffffffc020034c <__panic>
    assert(base != NULL);
ffffffffc0202874:	00003697          	auipc	a3,0x3
ffffffffc0202878:	cec68693          	addi	a3,a3,-788 # ffffffffc0205560 <etext+0x12b8>
ffffffffc020287c:	00002617          	auipc	a2,0x2
ffffffffc0202880:	30460613          	addi	a2,a2,772 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202884:	1f700593          	li	a1,503
ffffffffc0202888:	00002517          	auipc	a0,0x2
ffffffffc020288c:	70050513          	addi	a0,a0,1792 # ffffffffc0204f88 <etext+0xce0>
ffffffffc0202890:	abdfd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0202894 <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0202894:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202896:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202898:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020289a:	fff58713          	addi	a4,a1,-1 # ffffffffffffefff <end+0x3fdeda8f>
ffffffffc020289e:	17f9                	addi	a5,a5,-2 # 14ffe <kern_entry-0xffffffffc01eb002>
ffffffffc02028a0:	0ae7ef63          	bltu	a5,a4,ffffffffc020295e <kfree+0xca>
    assert(ptr != NULL);
ffffffffc02028a4:	cd49                	beqz	a0,ffffffffc020293e <kfree+0xaa>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02028a6:	6785                	lui	a5,0x1
ffffffffc02028a8:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02028aa:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028ac:	c02007b7          	lui	a5,0xc0200
ffffffffc02028b0:	81b1                	srli	a1,a1,0xc
ffffffffc02028b2:	06f56963          	bltu	a0,a5,ffffffffc0202924 <kfree+0x90>
ffffffffc02028b6:	0000f717          	auipc	a4,0xf
ffffffffc02028ba:	c7273703          	ld	a4,-910(a4) # ffffffffc0211528 <va_pa_offset>
    if (PPN(pa) >= npage) {
ffffffffc02028be:	0000f797          	auipc	a5,0xf
ffffffffc02028c2:	c727b783          	ld	a5,-910(a5) # ffffffffc0211530 <npage>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02028c6:	40e506b3          	sub	a3,a0,a4
    if (PPN(pa) >= npage) {
ffffffffc02028ca:	82b1                	srli	a3,a3,0xc
ffffffffc02028cc:	04f6fa63          	bgeu	a3,a5,ffffffffc0202920 <kfree+0x8c>
    return &pages[PPN(pa) - nbase];
ffffffffc02028d0:	fff807b7          	lui	a5,0xfff80
ffffffffc02028d4:	96be                	add	a3,a3,a5
ffffffffc02028d6:	0000f517          	auipc	a0,0xf
ffffffffc02028da:	c6253503          	ld	a0,-926(a0) # ffffffffc0211538 <pages>
ffffffffc02028de:	00369793          	slli	a5,a3,0x3
ffffffffc02028e2:	97b6                	add	a5,a5,a3
ffffffffc02028e4:	078e                	slli	a5,a5,0x3
ffffffffc02028e6:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028e8:	100027f3          	csrr	a5,sstatus
ffffffffc02028ec:	8b89                	andi	a5,a5,2
ffffffffc02028ee:	eb89                	bnez	a5,ffffffffc0202900 <kfree+0x6c>
    { pmm_manager->free_pages(base, n); }
ffffffffc02028f0:	0000f797          	auipc	a5,0xf
ffffffffc02028f4:	c207b783          	ld	a5,-992(a5) # ffffffffc0211510 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02028f8:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02028fa:	739c                	ld	a5,32(a5)
}
ffffffffc02028fc:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02028fe:	8782                	jr	a5
        intr_disable();
ffffffffc0202900:	e42a                	sd	a0,8(sp)
ffffffffc0202902:	e02e                	sd	a1,0(sp)
ffffffffc0202904:	bc7fd0ef          	jal	ffffffffc02004ca <intr_disable>
ffffffffc0202908:	0000f797          	auipc	a5,0xf
ffffffffc020290c:	c087b783          	ld	a5,-1016(a5) # ffffffffc0211510 <pmm_manager>
ffffffffc0202910:	6582                	ld	a1,0(sp)
ffffffffc0202912:	6522                	ld	a0,8(sp)
ffffffffc0202914:	739c                	ld	a5,32(a5)
ffffffffc0202916:	9782                	jalr	a5
}
ffffffffc0202918:	60e2                	ld	ra,24(sp)
ffffffffc020291a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020291c:	ba9fd06f          	j	ffffffffc02004c4 <intr_enable>
ffffffffc0202920:	ca1fe0ef          	jal	ffffffffc02015c0 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202924:	86aa                	mv	a3,a0
ffffffffc0202926:	00002617          	auipc	a2,0x2
ffffffffc020292a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0205020 <etext+0xd78>
ffffffffc020292e:	06f00593          	li	a1,111
ffffffffc0202932:	00002517          	auipc	a0,0x2
ffffffffc0202936:	61e50513          	addi	a0,a0,1566 # ffffffffc0204f50 <etext+0xca8>
ffffffffc020293a:	a13fd0ef          	jal	ffffffffc020034c <__panic>
    assert(ptr != NULL);
ffffffffc020293e:	00003697          	auipc	a3,0x3
ffffffffc0202942:	c3268693          	addi	a3,a3,-974 # ffffffffc0205570 <etext+0x12c8>
ffffffffc0202946:	00002617          	auipc	a2,0x2
ffffffffc020294a:	23a60613          	addi	a2,a2,570 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020294e:	1fe00593          	li	a1,510
ffffffffc0202952:	00002517          	auipc	a0,0x2
ffffffffc0202956:	63650513          	addi	a0,a0,1590 # ffffffffc0204f88 <etext+0xce0>
ffffffffc020295a:	9f3fd0ef          	jal	ffffffffc020034c <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020295e:	00003697          	auipc	a3,0x3
ffffffffc0202962:	be268693          	addi	a3,a3,-1054 # ffffffffc0205540 <etext+0x1298>
ffffffffc0202966:	00002617          	auipc	a2,0x2
ffffffffc020296a:	21a60613          	addi	a2,a2,538 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020296e:	1fd00593          	li	a1,509
ffffffffc0202972:	00002517          	auipc	a0,0x2
ffffffffc0202976:	61650513          	addi	a0,a0,1558 # ffffffffc0204f88 <etext+0xce0>
ffffffffc020297a:	9d3fd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc020297e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020297e:	7135                	addi	sp,sp,-160
ffffffffc0202980:	ed06                	sd	ra,152(sp)
     swapfs_init();
ffffffffc0202982:	24c010ef          	jal	ffffffffc0203bce <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202986:	0000f697          	auipc	a3,0xf
ffffffffc020298a:	bc26b683          	ld	a3,-1086(a3) # ffffffffc0211548 <max_swap_offset>
ffffffffc020298e:	010007b7          	lui	a5,0x1000
ffffffffc0202992:	17e1                	addi	a5,a5,-8 # fffff8 <kern_entry-0xffffffffbf200008>
ffffffffc0202994:	ff968713          	addi	a4,a3,-7
ffffffffc0202998:	42e7e663          	bltu	a5,a4,ffffffffc0202dc4 <swap_init+0x446>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     //sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
     sm = &swap_manager_clock;
ffffffffc020299c:	00007797          	auipc	a5,0x7
ffffffffc02029a0:	66478793          	addi	a5,a5,1636 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc02029a4:	6798                	ld	a4,8(a5)
ffffffffc02029a6:	fcce                	sd	s3,120(sp)
ffffffffc02029a8:	f0da                	sd	s6,96(sp)
     sm = &swap_manager_clock;
ffffffffc02029aa:	0000fb17          	auipc	s6,0xf
ffffffffc02029ae:	ba6b0b13          	addi	s6,s6,-1114 # ffffffffc0211550 <sm>
ffffffffc02029b2:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc02029b6:	9702                	jalr	a4
ffffffffc02029b8:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc02029ba:	c519                	beqz	a0,ffffffffc02029c8 <swap_init+0x4a>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02029bc:	60ea                	ld	ra,152(sp)
ffffffffc02029be:	7b06                	ld	s6,96(sp)
ffffffffc02029c0:	854e                	mv	a0,s3
ffffffffc02029c2:	79e6                	ld	s3,120(sp)
ffffffffc02029c4:	610d                	addi	sp,sp,160
ffffffffc02029c6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029c8:	000b3703          	ld	a4,0(s6)
          swap_init_ok = 1;
ffffffffc02029cc:	4785                	li	a5,1
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029ce:	00003517          	auipc	a0,0x3
ffffffffc02029d2:	be250513          	addi	a0,a0,-1054 # ffffffffc02055b0 <etext+0x1308>
ffffffffc02029d6:	630c                	ld	a1,0(a4)
ffffffffc02029d8:	e922                	sd	s0,144(sp)
ffffffffc02029da:	e526                	sd	s1,136(sp)
ffffffffc02029dc:	e0ea                	sd	s10,64(sp)
          swap_init_ok = 1;
ffffffffc02029de:	0000f717          	auipc	a4,0xf
ffffffffc02029e2:	b6f72123          	sw	a5,-1182(a4) # ffffffffc0211540 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02029e6:	e14a                	sd	s2,128(sp)
ffffffffc02029e8:	f8d2                	sd	s4,112(sp)
ffffffffc02029ea:	f4d6                	sd	s5,104(sp)
ffffffffc02029ec:	ecde                	sd	s7,88(sp)
ffffffffc02029ee:	e8e2                	sd	s8,80(sp)
ffffffffc02029f0:	e4e6                	sd	s9,72(sp)
ffffffffc02029f2:	fc6e                	sd	s11,56(sp)
    return listelm->next;
ffffffffc02029f4:	0000e497          	auipc	s1,0xe
ffffffffc02029f8:	64c48493          	addi	s1,s1,1612 # ffffffffc0211040 <free_area>
ffffffffc02029fc:	ebefd0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0202a00:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202a02:	4401                	li	s0,0
ffffffffc0202a04:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a06:	30978563          	beq	a5,s1,ffffffffc0202d10 <swap_init+0x392>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202a0a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202a0e:	8b09                	andi	a4,a4,2
ffffffffc0202a10:	30070263          	beqz	a4,ffffffffc0202d14 <swap_init+0x396>
        count ++, total += p->property;
ffffffffc0202a14:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202a18:	679c                	ld	a5,8(a5)
ffffffffc0202a1a:	2d05                	addiw	s10,s10,1
ffffffffc0202a1c:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202a1e:	fe9796e3          	bne	a5,s1,ffffffffc0202a0a <swap_init+0x8c>
     }
     assert(total == nr_free_pages());
ffffffffc0202a22:	8922                	mv	s2,s0
ffffffffc0202a24:	c81fe0ef          	jal	ffffffffc02016a4 <nr_free_pages>
ffffffffc0202a28:	4d251663          	bne	a0,s2,ffffffffc0202ef4 <swap_init+0x576>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202a2c:	8622                	mv	a2,s0
ffffffffc0202a2e:	85ea                	mv	a1,s10
ffffffffc0202a30:	00003517          	auipc	a0,0x3
ffffffffc0202a34:	b9850513          	addi	a0,a0,-1128 # ffffffffc02055c8 <etext+0x1320>
ffffffffc0202a38:	e82fd0ef          	jal	ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202a3c:	123000ef          	jal	ffffffffc020335e <mm_create>
ffffffffc0202a40:	ec2a                	sd	a0,24(sp)
     assert(mm != NULL);
ffffffffc0202a42:	58050963          	beqz	a0,ffffffffc0202fd4 <swap_init+0x656>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202a46:	0000f797          	auipc	a5,0xf
ffffffffc0202a4a:	b2278793          	addi	a5,a5,-1246 # ffffffffc0211568 <check_mm_struct>
ffffffffc0202a4e:	6398                	ld	a4,0(a5)
ffffffffc0202a50:	5a071263          	bnez	a4,ffffffffc0202ff4 <swap_init+0x676>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a54:	0000f717          	auipc	a4,0xf
ffffffffc0202a58:	acc73703          	ld	a4,-1332(a4) # ffffffffc0211520 <boot_pgdir>
     check_mm_struct = mm;
ffffffffc0202a5c:	66e2                	ld	a3,24(sp)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a5e:	e83a                	sd	a4,16(sp)
     check_mm_struct = mm;
ffffffffc0202a60:	e394                	sd	a3,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0202a62:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202a64:	ee98                	sd	a4,24(a3)
     assert(pgdir[0] == 0);
ffffffffc0202a66:	42079763          	bnez	a5,ffffffffc0202e94 <swap_init+0x516>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202a6a:	6599                	lui	a1,0x6
ffffffffc0202a6c:	460d                	li	a2,3
ffffffffc0202a6e:	6505                	lui	a0,0x1
ffffffffc0202a70:	137000ef          	jal	ffffffffc02033a6 <vma_create>
ffffffffc0202a74:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202a76:	42050f63          	beqz	a0,ffffffffc0202eb4 <swap_init+0x536>

     insert_vma_struct(mm, vma);
ffffffffc0202a7a:	6962                	ld	s2,24(sp)
ffffffffc0202a7c:	854a                	mv	a0,s2
ffffffffc0202a7e:	197000ef          	jal	ffffffffc0203414 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202a82:	00003517          	auipc	a0,0x3
ffffffffc0202a86:	bb650513          	addi	a0,a0,-1098 # ffffffffc0205638 <etext+0x1390>
ffffffffc0202a8a:	e30fd0ef          	jal	ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202a8e:	01893503          	ld	a0,24(s2)
ffffffffc0202a92:	4605                	li	a2,1
ffffffffc0202a94:	6585                	lui	a1,0x1
ffffffffc0202a96:	c49fe0ef          	jal	ffffffffc02016de <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202a9a:	42050d63          	beqz	a0,ffffffffc0202ed4 <swap_init+0x556>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202a9e:	00003517          	auipc	a0,0x3
ffffffffc0202aa2:	bea50513          	addi	a0,a0,-1046 # ffffffffc0205688 <etext+0x13e0>
ffffffffc0202aa6:	0000e917          	auipc	s2,0xe
ffffffffc0202aaa:	5d290913          	addi	s2,s2,1490 # ffffffffc0211078 <check_rp>
ffffffffc0202aae:	e0cfd0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0202ab2:	8c4a                	mv	s8,s2
ffffffffc0202ab4:	0000ea17          	auipc	s4,0xe
ffffffffc0202ab8:	5e4a0a13          	addi	s4,s4,1508 # ffffffffc0211098 <swap_out_seq_no>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
          check_rp[i] = alloc_page();
ffffffffc0202abc:	4505                	li	a0,1
ffffffffc0202abe:	b1ffe0ef          	jal	ffffffffc02015dc <alloc_pages>
ffffffffc0202ac2:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202ac6:	2c050f63          	beqz	a0,ffffffffc0202da4 <swap_init+0x426>
ffffffffc0202aca:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202acc:	8b89                	andi	a5,a5,2
ffffffffc0202ace:	2a079b63          	bnez	a5,ffffffffc0202d84 <swap_init+0x406>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ad2:	0c21                	addi	s8,s8,8
ffffffffc0202ad4:	ff4c14e3          	bne	s8,s4,ffffffffc0202abc <swap_init+0x13e>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202ad8:	609c                	ld	a5,0(s1)
ffffffffc0202ada:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202ade:	e084                	sd	s1,0(s1)
ffffffffc0202ae0:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202ae2:	0000e797          	auipc	a5,0xe
ffffffffc0202ae6:	56e7a783          	lw	a5,1390(a5) # ffffffffc0211050 <free_area+0x10>
ffffffffc0202aea:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202aec:	0000ec17          	auipc	s8,0xe
ffffffffc0202af0:	58cc0c13          	addi	s8,s8,1420 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202af4:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202af6:	0000e797          	auipc	a5,0xe
ffffffffc0202afa:	5407ad23          	sw	zero,1370(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202afe:	000c3503          	ld	a0,0(s8)
ffffffffc0202b02:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b04:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202b06:	b5ffe0ef          	jal	ffffffffc0201664 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b0a:	ff4c1ae3          	bne	s8,s4,ffffffffc0202afe <swap_init+0x180>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202b0e:	0000ec17          	auipc	s8,0xe
ffffffffc0202b12:	542c2c03          	lw	s8,1346(s8) # ffffffffc0211050 <free_area+0x10>
ffffffffc0202b16:	4791                	li	a5,4
ffffffffc0202b18:	4efc1e63          	bne	s8,a5,ffffffffc0203014 <swap_init+0x696>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202b1c:	00003517          	auipc	a0,0x3
ffffffffc0202b20:	bf450513          	addi	a0,a0,-1036 # ffffffffc0205710 <etext+0x1468>
ffffffffc0202b24:	d96fd0ef          	jal	ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b28:	6785                	lui	a5,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202b2a:	0000f617          	auipc	a2,0xf
ffffffffc0202b2e:	a2062d23          	sw	zero,-1478(a2) # ffffffffc0211564 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202b32:	45a9                	li	a1,10
ffffffffc0202b34:	00b78023          	sb	a1,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202b38:	0000f617          	auipc	a2,0xf
ffffffffc0202b3c:	a2c62603          	lw	a2,-1492(a2) # ffffffffc0211564 <pgfault_num>
ffffffffc0202b40:	4785                	li	a5,1
ffffffffc0202b42:	44f61963          	bne	a2,a5,ffffffffc0202f94 <swap_init+0x616>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202b46:	6785                	lui	a5,0x1
ffffffffc0202b48:	00b78823          	sb	a1,16(a5) # 1010 <kern_entry-0xffffffffc01feff0>
     assert(pgfault_num==1);
ffffffffc0202b4c:	0000f797          	auipc	a5,0xf
ffffffffc0202b50:	a187a783          	lw	a5,-1512(a5) # ffffffffc0211564 <pgfault_num>
ffffffffc0202b54:	46c79063          	bne	a5,a2,ffffffffc0202fb4 <swap_init+0x636>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202b58:	6789                	lui	a5,0x2
ffffffffc0202b5a:	45ad                	li	a1,11
ffffffffc0202b5c:	00b78023          	sb	a1,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202b60:	0000f617          	auipc	a2,0xf
ffffffffc0202b64:	a0462603          	lw	a2,-1532(a2) # ffffffffc0211564 <pgfault_num>
ffffffffc0202b68:	4789                	li	a5,2
ffffffffc0202b6a:	3af61563          	bne	a2,a5,ffffffffc0202f14 <swap_init+0x596>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202b6e:	6789                	lui	a5,0x2
ffffffffc0202b70:	00b78823          	sb	a1,16(a5) # 2010 <kern_entry-0xffffffffc01fdff0>
     assert(pgfault_num==2);
ffffffffc0202b74:	0000f797          	auipc	a5,0xf
ffffffffc0202b78:	9f07a783          	lw	a5,-1552(a5) # ffffffffc0211564 <pgfault_num>
ffffffffc0202b7c:	3ac79c63          	bne	a5,a2,ffffffffc0202f34 <swap_init+0x5b6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202b80:	678d                	lui	a5,0x3
ffffffffc0202b82:	45b1                	li	a1,12
ffffffffc0202b84:	00b78023          	sb	a1,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202b88:	0000f617          	auipc	a2,0xf
ffffffffc0202b8c:	9dc62603          	lw	a2,-1572(a2) # ffffffffc0211564 <pgfault_num>
ffffffffc0202b90:	478d                	li	a5,3
ffffffffc0202b92:	3cf61163          	bne	a2,a5,ffffffffc0202f54 <swap_init+0x5d6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202b96:	678d                	lui	a5,0x3
ffffffffc0202b98:	00b78823          	sb	a1,16(a5) # 3010 <kern_entry-0xffffffffc01fcff0>
     assert(pgfault_num==3);
ffffffffc0202b9c:	0000f797          	auipc	a5,0xf
ffffffffc0202ba0:	9c87a783          	lw	a5,-1592(a5) # ffffffffc0211564 <pgfault_num>
ffffffffc0202ba4:	3cc79863          	bne	a5,a2,ffffffffc0202f74 <swap_init+0x5f6>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202ba8:	6791                	lui	a5,0x4
ffffffffc0202baa:	45b5                	li	a1,13
ffffffffc0202bac:	00b78023          	sb	a1,0(a5) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202bb0:	0000f617          	auipc	a2,0xf
ffffffffc0202bb4:	9b462603          	lw	a2,-1612(a2) # ffffffffc0211564 <pgfault_num>
ffffffffc0202bb8:	25861e63          	bne	a2,s8,ffffffffc0202e14 <swap_init+0x496>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202bbc:	6791                	lui	a5,0x4
ffffffffc0202bbe:	00b78823          	sb	a1,16(a5) # 4010 <kern_entry-0xffffffffc01fbff0>
     assert(pgfault_num==4);
ffffffffc0202bc2:	0000f797          	auipc	a5,0xf
ffffffffc0202bc6:	9a27a783          	lw	a5,-1630(a5) # ffffffffc0211564 <pgfault_num>
ffffffffc0202bca:	26c79563          	bne	a5,a2,ffffffffc0202e34 <swap_init+0x4b6>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202bce:	0000e797          	auipc	a5,0xe
ffffffffc0202bd2:	4827a783          	lw	a5,1154(a5) # ffffffffc0211050 <free_area+0x10>
ffffffffc0202bd6:	26079f63          	bnez	a5,ffffffffc0202e54 <swap_init+0x4d6>
ffffffffc0202bda:	0000e797          	auipc	a5,0xe
ffffffffc0202bde:	4e678793          	addi	a5,a5,1254 # ffffffffc02110c0 <swap_in_seq_no>
ffffffffc0202be2:	0000e617          	auipc	a2,0xe
ffffffffc0202be6:	4b660613          	addi	a2,a2,1206 # ffffffffc0211098 <swap_out_seq_no>
ffffffffc0202bea:	0000e517          	auipc	a0,0xe
ffffffffc0202bee:	4fe50513          	addi	a0,a0,1278 # ffffffffc02110e8 <pra_list_head>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202bf2:	55fd                	li	a1,-1
ffffffffc0202bf4:	c38c                	sw	a1,0(a5)
ffffffffc0202bf6:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202bf8:	0791                	addi	a5,a5,4
ffffffffc0202bfa:	0611                	addi	a2,a2,4
ffffffffc0202bfc:	fea79ce3          	bne	a5,a0,ffffffffc0202bf4 <swap_init+0x276>
ffffffffc0202c00:	6585                	lui	a1,0x1
ffffffffc0202c02:	0000e817          	auipc	a6,0xe
ffffffffc0202c06:	45680813          	addi	a6,a6,1110 # ffffffffc0211058 <check_ptep>
ffffffffc0202c0a:	0000ea97          	auipc	s5,0xe
ffffffffc0202c0e:	46ea8a93          	addi	s5,s5,1134 # ffffffffc0211078 <check_rp>
    if (PPN(pa) >= npage) {
ffffffffc0202c12:	0000fb97          	auipc	s7,0xf
ffffffffc0202c16:	91eb8b93          	addi	s7,s7,-1762 # ffffffffc0211530 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c1a:	0000fc97          	auipc	s9,0xf
ffffffffc0202c1e:	91ec8c93          	addi	s9,s9,-1762 # ffffffffc0211538 <pages>
ffffffffc0202c22:	00003c17          	auipc	s8,0x3
ffffffffc0202c26:	44ec0c13          	addi	s8,s8,1102 # ffffffffc0206070 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c2a:	6542                	ld	a0,16(sp)
         check_ptep[i]=0;
ffffffffc0202c2c:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c30:	4601                	li	a2,0
ffffffffc0202c32:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc0202c34:	e042                	sd	a6,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c36:	aa9fe0ef          	jal	ffffffffc02016de <get_pte>
ffffffffc0202c3a:	6802                	ld	a6,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202c3c:	65a2                	ld	a1,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202c3e:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202c42:	1a050963          	beqz	a0,ffffffffc0202df4 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c46:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202c48:	0017f613          	andi	a2,a5,1
ffffffffc0202c4c:	10060463          	beqz	a2,ffffffffc0202d54 <swap_init+0x3d6>
    if (PPN(pa) >= npage) {
ffffffffc0202c50:	000bb603          	ld	a2,0(s7)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c54:	078a                	slli	a5,a5,0x2
ffffffffc0202c56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202c58:	10c7fa63          	bgeu	a5,a2,ffffffffc0202d6c <swap_init+0x3ee>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c5c:	000c3603          	ld	a2,0(s8)
ffffffffc0202c60:	000cb503          	ld	a0,0(s9)
ffffffffc0202c64:	8f91                	sub	a5,a5,a2
ffffffffc0202c66:	00379613          	slli	a2,a5,0x3
ffffffffc0202c6a:	97b2                	add	a5,a5,a2
ffffffffc0202c6c:	000ab603          	ld	a2,0(s5)
ffffffffc0202c70:	078e                	slli	a5,a5,0x3
ffffffffc0202c72:	97aa                	add	a5,a5,a0
ffffffffc0202c74:	0cf61063          	bne	a2,a5,ffffffffc0202d34 <swap_init+0x3b6>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c78:	6785                	lui	a5,0x1
ffffffffc0202c7a:	95be                	add	a1,a1,a5
ffffffffc0202c7c:	6795                	lui	a5,0x5
ffffffffc0202c7e:	0821                	addi	a6,a6,8
ffffffffc0202c80:	0aa1                	addi	s5,s5,8
ffffffffc0202c82:	faf594e3          	bne	a1,a5,ffffffffc0202c2a <swap_init+0x2ac>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202c86:	00003517          	auipc	a0,0x3
ffffffffc0202c8a:	b3250513          	addi	a0,a0,-1230 # ffffffffc02057b8 <etext+0x1510>
ffffffffc0202c8e:	c2cfd0ef          	jal	ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202c92:	000b3783          	ld	a5,0(s6)
ffffffffc0202c96:	7f9c                	ld	a5,56(a5)
ffffffffc0202c98:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202c9a:	1c051d63          	bnez	a0,ffffffffc0202e74 <swap_init+0x4f6>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202c9e:	00093503          	ld	a0,0(s2)
ffffffffc0202ca2:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ca4:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202ca6:	9bffe0ef          	jal	ffffffffc0201664 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202caa:	ff491ae3          	bne	s2,s4,ffffffffc0202c9e <swap_init+0x320>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202cae:	6562                	ld	a0,24(sp)
ffffffffc0202cb0:	035000ef          	jal	ffffffffc02034e4 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202cb4:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202cb6:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202cba:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202cbc:	7782                	ld	a5,32(sp)
ffffffffc0202cbe:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cc0:	009d8a63          	beq	s11,s1,ffffffffc0202cd4 <swap_init+0x356>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202cc4:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202cc8:	008dbd83          	ld	s11,8(s11)
ffffffffc0202ccc:	3d7d                	addiw	s10,s10,-1
ffffffffc0202cce:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202cd0:	fe9d9ae3          	bne	s11,s1,ffffffffc0202cc4 <swap_init+0x346>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202cd4:	8622                	mv	a2,s0
ffffffffc0202cd6:	85ea                	mv	a1,s10
ffffffffc0202cd8:	00003517          	auipc	a0,0x3
ffffffffc0202cdc:	b1050513          	addi	a0,a0,-1264 # ffffffffc02057e8 <etext+0x1540>
ffffffffc0202ce0:	bdafd0ef          	jal	ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202ce4:	00003517          	auipc	a0,0x3
ffffffffc0202ce8:	b2450513          	addi	a0,a0,-1244 # ffffffffc0205808 <etext+0x1560>
ffffffffc0202cec:	bcefd0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc0202cf0:	60ea                	ld	ra,152(sp)
     cprintf("check_swap() succeeded!\n");
ffffffffc0202cf2:	644a                	ld	s0,144(sp)
ffffffffc0202cf4:	64aa                	ld	s1,136(sp)
ffffffffc0202cf6:	690a                	ld	s2,128(sp)
ffffffffc0202cf8:	7a46                	ld	s4,112(sp)
ffffffffc0202cfa:	7aa6                	ld	s5,104(sp)
ffffffffc0202cfc:	6be6                	ld	s7,88(sp)
ffffffffc0202cfe:	6c46                	ld	s8,80(sp)
ffffffffc0202d00:	6ca6                	ld	s9,72(sp)
ffffffffc0202d02:	6d06                	ld	s10,64(sp)
ffffffffc0202d04:	7de2                	ld	s11,56(sp)
}
ffffffffc0202d06:	7b06                	ld	s6,96(sp)
ffffffffc0202d08:	854e                	mv	a0,s3
ffffffffc0202d0a:	79e6                	ld	s3,120(sp)
ffffffffc0202d0c:	610d                	addi	sp,sp,160
ffffffffc0202d0e:	8082                	ret
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202d10:	4901                	li	s2,0
ffffffffc0202d12:	bb09                	j	ffffffffc0202a24 <swap_init+0xa6>
        assert(PageProperty(p));
ffffffffc0202d14:	00002697          	auipc	a3,0x2
ffffffffc0202d18:	e5c68693          	addi	a3,a3,-420 # ffffffffc0204b70 <etext+0x8c8>
ffffffffc0202d1c:	00002617          	auipc	a2,0x2
ffffffffc0202d20:	e6460613          	addi	a2,a2,-412 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202d24:	0bc00593          	li	a1,188
ffffffffc0202d28:	00003517          	auipc	a0,0x3
ffffffffc0202d2c:	87850513          	addi	a0,a0,-1928 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202d30:	e1cfd0ef          	jal	ffffffffc020034c <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202d34:	00003697          	auipc	a3,0x3
ffffffffc0202d38:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0205790 <etext+0x14e8>
ffffffffc0202d3c:	00002617          	auipc	a2,0x2
ffffffffc0202d40:	e4460613          	addi	a2,a2,-444 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202d44:	0fc00593          	li	a1,252
ffffffffc0202d48:	00003517          	auipc	a0,0x3
ffffffffc0202d4c:	85850513          	addi	a0,a0,-1960 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202d50:	dfcfd0ef          	jal	ffffffffc020034c <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	3f460613          	addi	a2,a2,1012 # ffffffffc0205148 <etext+0xea0>
ffffffffc0202d5c:	07300593          	li	a1,115
ffffffffc0202d60:	00002517          	auipc	a0,0x2
ffffffffc0202d64:	1f050513          	addi	a0,a0,496 # ffffffffc0204f50 <etext+0xca8>
ffffffffc0202d68:	de4fd0ef          	jal	ffffffffc020034c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202d6c:	00002617          	auipc	a2,0x2
ffffffffc0202d70:	1c460613          	addi	a2,a2,452 # ffffffffc0204f30 <etext+0xc88>
ffffffffc0202d74:	06800593          	li	a1,104
ffffffffc0202d78:	00002517          	auipc	a0,0x2
ffffffffc0202d7c:	1d850513          	addi	a0,a0,472 # ffffffffc0204f50 <etext+0xca8>
ffffffffc0202d80:	dccfd0ef          	jal	ffffffffc020034c <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202d84:	00003697          	auipc	a3,0x3
ffffffffc0202d88:	94468693          	addi	a3,a3,-1724 # ffffffffc02056c8 <etext+0x1420>
ffffffffc0202d8c:	00002617          	auipc	a2,0x2
ffffffffc0202d90:	df460613          	addi	a2,a2,-524 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202d94:	0dd00593          	li	a1,221
ffffffffc0202d98:	00003517          	auipc	a0,0x3
ffffffffc0202d9c:	80850513          	addi	a0,a0,-2040 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202da0:	dacfd0ef          	jal	ffffffffc020034c <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202da4:	00003697          	auipc	a3,0x3
ffffffffc0202da8:	90c68693          	addi	a3,a3,-1780 # ffffffffc02056b0 <etext+0x1408>
ffffffffc0202dac:	00002617          	auipc	a2,0x2
ffffffffc0202db0:	dd460613          	addi	a2,a2,-556 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202db4:	0dc00593          	li	a1,220
ffffffffc0202db8:	00002517          	auipc	a0,0x2
ffffffffc0202dbc:	7e850513          	addi	a0,a0,2024 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202dc0:	d8cfd0ef          	jal	ffffffffc020034c <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	7bc60613          	addi	a2,a2,1980 # ffffffffc0205580 <etext+0x12d8>
ffffffffc0202dcc:	02800593          	li	a1,40
ffffffffc0202dd0:	00002517          	auipc	a0,0x2
ffffffffc0202dd4:	7d050513          	addi	a0,a0,2000 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202dd8:	e922                	sd	s0,144(sp)
ffffffffc0202dda:	e526                	sd	s1,136(sp)
ffffffffc0202ddc:	e14a                	sd	s2,128(sp)
ffffffffc0202dde:	fcce                	sd	s3,120(sp)
ffffffffc0202de0:	f8d2                	sd	s4,112(sp)
ffffffffc0202de2:	f4d6                	sd	s5,104(sp)
ffffffffc0202de4:	f0da                	sd	s6,96(sp)
ffffffffc0202de6:	ecde                	sd	s7,88(sp)
ffffffffc0202de8:	e8e2                	sd	s8,80(sp)
ffffffffc0202dea:	e4e6                	sd	s9,72(sp)
ffffffffc0202dec:	e0ea                	sd	s10,64(sp)
ffffffffc0202dee:	fc6e                	sd	s11,56(sp)
ffffffffc0202df0:	d5cfd0ef          	jal	ffffffffc020034c <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202df4:	00003697          	auipc	a3,0x3
ffffffffc0202df8:	98468693          	addi	a3,a3,-1660 # ffffffffc0205778 <etext+0x14d0>
ffffffffc0202dfc:	00002617          	auipc	a2,0x2
ffffffffc0202e00:	d8460613          	addi	a2,a2,-636 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202e04:	0fb00593          	li	a1,251
ffffffffc0202e08:	00002517          	auipc	a0,0x2
ffffffffc0202e0c:	79850513          	addi	a0,a0,1944 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202e10:	d3cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==4);
ffffffffc0202e14:	00003697          	auipc	a3,0x3
ffffffffc0202e18:	95468693          	addi	a3,a3,-1708 # ffffffffc0205768 <etext+0x14c0>
ffffffffc0202e1c:	00002617          	auipc	a2,0x2
ffffffffc0202e20:	d6460613          	addi	a2,a2,-668 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202e24:	09f00593          	li	a1,159
ffffffffc0202e28:	00002517          	auipc	a0,0x2
ffffffffc0202e2c:	77850513          	addi	a0,a0,1912 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202e30:	d1cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==4);
ffffffffc0202e34:	00003697          	auipc	a3,0x3
ffffffffc0202e38:	93468693          	addi	a3,a3,-1740 # ffffffffc0205768 <etext+0x14c0>
ffffffffc0202e3c:	00002617          	auipc	a2,0x2
ffffffffc0202e40:	d4460613          	addi	a2,a2,-700 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202e44:	0a100593          	li	a1,161
ffffffffc0202e48:	00002517          	auipc	a0,0x2
ffffffffc0202e4c:	75850513          	addi	a0,a0,1880 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202e50:	cfcfd0ef          	jal	ffffffffc020034c <__panic>
     assert( nr_free == 0);         
ffffffffc0202e54:	00002697          	auipc	a3,0x2
ffffffffc0202e58:	f0468693          	addi	a3,a3,-252 # ffffffffc0204d58 <etext+0xab0>
ffffffffc0202e5c:	00002617          	auipc	a2,0x2
ffffffffc0202e60:	d2460613          	addi	a2,a2,-732 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202e64:	0f300593          	li	a1,243
ffffffffc0202e68:	00002517          	auipc	a0,0x2
ffffffffc0202e6c:	73850513          	addi	a0,a0,1848 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202e70:	cdcfd0ef          	jal	ffffffffc020034c <__panic>
     assert(ret==0);
ffffffffc0202e74:	00003697          	auipc	a3,0x3
ffffffffc0202e78:	96c68693          	addi	a3,a3,-1684 # ffffffffc02057e0 <etext+0x1538>
ffffffffc0202e7c:	00002617          	auipc	a2,0x2
ffffffffc0202e80:	d0460613          	addi	a2,a2,-764 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202e84:	10200593          	li	a1,258
ffffffffc0202e88:	00002517          	auipc	a0,0x2
ffffffffc0202e8c:	71850513          	addi	a0,a0,1816 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202e90:	cbcfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e94:	00002697          	auipc	a3,0x2
ffffffffc0202e98:	78468693          	addi	a3,a3,1924 # ffffffffc0205618 <etext+0x1370>
ffffffffc0202e9c:	00002617          	auipc	a2,0x2
ffffffffc0202ea0:	ce460613          	addi	a2,a2,-796 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202ea4:	0cc00593          	li	a1,204
ffffffffc0202ea8:	00002517          	auipc	a0,0x2
ffffffffc0202eac:	6f850513          	addi	a0,a0,1784 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202eb0:	c9cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(vma != NULL);
ffffffffc0202eb4:	00002697          	auipc	a3,0x2
ffffffffc0202eb8:	77468693          	addi	a3,a3,1908 # ffffffffc0205628 <etext+0x1380>
ffffffffc0202ebc:	00002617          	auipc	a2,0x2
ffffffffc0202ec0:	cc460613          	addi	a2,a2,-828 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202ec4:	0cf00593          	li	a1,207
ffffffffc0202ec8:	00002517          	auipc	a0,0x2
ffffffffc0202ecc:	6d850513          	addi	a0,a0,1752 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202ed0:	c7cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202ed4:	00002697          	auipc	a3,0x2
ffffffffc0202ed8:	79c68693          	addi	a3,a3,1948 # ffffffffc0205670 <etext+0x13c8>
ffffffffc0202edc:	00002617          	auipc	a2,0x2
ffffffffc0202ee0:	ca460613          	addi	a2,a2,-860 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202ee4:	0d700593          	li	a1,215
ffffffffc0202ee8:	00002517          	auipc	a0,0x2
ffffffffc0202eec:	6b850513          	addi	a0,a0,1720 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202ef0:	c5cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(total == nr_free_pages());
ffffffffc0202ef4:	00002697          	auipc	a3,0x2
ffffffffc0202ef8:	cbc68693          	addi	a3,a3,-836 # ffffffffc0204bb0 <etext+0x908>
ffffffffc0202efc:	00002617          	auipc	a2,0x2
ffffffffc0202f00:	c8460613          	addi	a2,a2,-892 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202f04:	0bf00593          	li	a1,191
ffffffffc0202f08:	00002517          	auipc	a0,0x2
ffffffffc0202f0c:	69850513          	addi	a0,a0,1688 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202f10:	c3cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==2);
ffffffffc0202f14:	00003697          	auipc	a3,0x3
ffffffffc0202f18:	83468693          	addi	a3,a3,-1996 # ffffffffc0205748 <etext+0x14a0>
ffffffffc0202f1c:	00002617          	auipc	a2,0x2
ffffffffc0202f20:	c6460613          	addi	a2,a2,-924 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202f24:	09700593          	li	a1,151
ffffffffc0202f28:	00002517          	auipc	a0,0x2
ffffffffc0202f2c:	67850513          	addi	a0,a0,1656 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202f30:	c1cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==2);
ffffffffc0202f34:	00003697          	auipc	a3,0x3
ffffffffc0202f38:	81468693          	addi	a3,a3,-2028 # ffffffffc0205748 <etext+0x14a0>
ffffffffc0202f3c:	00002617          	auipc	a2,0x2
ffffffffc0202f40:	c4460613          	addi	a2,a2,-956 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202f44:	09900593          	li	a1,153
ffffffffc0202f48:	00002517          	auipc	a0,0x2
ffffffffc0202f4c:	65850513          	addi	a0,a0,1624 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202f50:	bfcfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==3);
ffffffffc0202f54:	00003697          	auipc	a3,0x3
ffffffffc0202f58:	80468693          	addi	a3,a3,-2044 # ffffffffc0205758 <etext+0x14b0>
ffffffffc0202f5c:	00002617          	auipc	a2,0x2
ffffffffc0202f60:	c2460613          	addi	a2,a2,-988 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202f64:	09b00593          	li	a1,155
ffffffffc0202f68:	00002517          	auipc	a0,0x2
ffffffffc0202f6c:	63850513          	addi	a0,a0,1592 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202f70:	bdcfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==3);
ffffffffc0202f74:	00002697          	auipc	a3,0x2
ffffffffc0202f78:	7e468693          	addi	a3,a3,2020 # ffffffffc0205758 <etext+0x14b0>
ffffffffc0202f7c:	00002617          	auipc	a2,0x2
ffffffffc0202f80:	c0460613          	addi	a2,a2,-1020 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202f84:	09d00593          	li	a1,157
ffffffffc0202f88:	00002517          	auipc	a0,0x2
ffffffffc0202f8c:	61850513          	addi	a0,a0,1560 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202f90:	bbcfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==1);
ffffffffc0202f94:	00002697          	auipc	a3,0x2
ffffffffc0202f98:	7a468693          	addi	a3,a3,1956 # ffffffffc0205738 <etext+0x1490>
ffffffffc0202f9c:	00002617          	auipc	a2,0x2
ffffffffc0202fa0:	be460613          	addi	a2,a2,-1052 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202fa4:	09300593          	li	a1,147
ffffffffc0202fa8:	00002517          	auipc	a0,0x2
ffffffffc0202fac:	5f850513          	addi	a0,a0,1528 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202fb0:	b9cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(pgfault_num==1);
ffffffffc0202fb4:	00002697          	auipc	a3,0x2
ffffffffc0202fb8:	78468693          	addi	a3,a3,1924 # ffffffffc0205738 <etext+0x1490>
ffffffffc0202fbc:	00002617          	auipc	a2,0x2
ffffffffc0202fc0:	bc460613          	addi	a2,a2,-1084 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202fc4:	09500593          	li	a1,149
ffffffffc0202fc8:	00002517          	auipc	a0,0x2
ffffffffc0202fcc:	5d850513          	addi	a0,a0,1496 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202fd0:	b7cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(mm != NULL);
ffffffffc0202fd4:	00002697          	auipc	a3,0x2
ffffffffc0202fd8:	61c68693          	addi	a3,a3,1564 # ffffffffc02055f0 <etext+0x1348>
ffffffffc0202fdc:	00002617          	auipc	a2,0x2
ffffffffc0202fe0:	ba460613          	addi	a2,a2,-1116 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0202fe4:	0c400593          	li	a1,196
ffffffffc0202fe8:	00002517          	auipc	a0,0x2
ffffffffc0202fec:	5b850513          	addi	a0,a0,1464 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0202ff0:	b5cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202ff4:	00002697          	auipc	a3,0x2
ffffffffc0202ff8:	60c68693          	addi	a3,a3,1548 # ffffffffc0205600 <etext+0x1358>
ffffffffc0202ffc:	00002617          	auipc	a2,0x2
ffffffffc0203000:	b8460613          	addi	a2,a2,-1148 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203004:	0c700593          	li	a1,199
ffffffffc0203008:	00002517          	auipc	a0,0x2
ffffffffc020300c:	59850513          	addi	a0,a0,1432 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0203010:	b3cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203014:	00002697          	auipc	a3,0x2
ffffffffc0203018:	6d468693          	addi	a3,a3,1748 # ffffffffc02056e8 <etext+0x1440>
ffffffffc020301c:	00002617          	auipc	a2,0x2
ffffffffc0203020:	b6460613          	addi	a2,a2,-1180 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203024:	0ea00593          	li	a1,234
ffffffffc0203028:	00002517          	auipc	a0,0x2
ffffffffc020302c:	57850513          	addi	a0,a0,1400 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0203030:	b1cfd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0203034 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203034:	0000e797          	auipc	a5,0xe
ffffffffc0203038:	51c7b783          	ld	a5,1308(a5) # ffffffffc0211550 <sm>
ffffffffc020303c:	6b9c                	ld	a5,16(a5)
ffffffffc020303e:	8782                	jr	a5

ffffffffc0203040 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203040:	0000e797          	auipc	a5,0xe
ffffffffc0203044:	5107b783          	ld	a5,1296(a5) # ffffffffc0211550 <sm>
ffffffffc0203048:	739c                	ld	a5,32(a5)
ffffffffc020304a:	8782                	jr	a5

ffffffffc020304c <swap_out>:
{
ffffffffc020304c:	715d                	addi	sp,sp,-80
ffffffffc020304e:	e486                	sd	ra,72(sp)
ffffffffc0203050:	e0a2                	sd	s0,64(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203052:	cdf9                	beqz	a1,ffffffffc0203130 <swap_out+0xe4>
ffffffffc0203054:	f84a                	sd	s2,48(sp)
ffffffffc0203056:	f44e                	sd	s3,40(sp)
ffffffffc0203058:	f052                	sd	s4,32(sp)
ffffffffc020305a:	ec56                	sd	s5,24(sp)
ffffffffc020305c:	fc26                	sd	s1,56(sp)
ffffffffc020305e:	e85a                	sd	s6,16(sp)
ffffffffc0203060:	8a2e                	mv	s4,a1
ffffffffc0203062:	892a                	mv	s2,a0
ffffffffc0203064:	8ab2                	mv	s5,a2
ffffffffc0203066:	4401                	li	s0,0
ffffffffc0203068:	0000e997          	auipc	s3,0xe
ffffffffc020306c:	4e898993          	addi	s3,s3,1256 # ffffffffc0211550 <sm>
ffffffffc0203070:	a83d                	j	ffffffffc02030ae <swap_out+0x62>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203072:	67a2                	ld	a5,8(sp)
ffffffffc0203074:	8626                	mv	a2,s1
ffffffffc0203076:	85a2                	mv	a1,s0
ffffffffc0203078:	63b4                	ld	a3,64(a5)
ffffffffc020307a:	00003517          	auipc	a0,0x3
ffffffffc020307e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205888 <etext+0x15e0>
     for (i = 0; i != n; ++ i)
ffffffffc0203082:	2405                	addiw	s0,s0,1 # ffffffffc0200001 <kern_entry+0x1>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203084:	82b1                	srli	a3,a3,0xc
ffffffffc0203086:	0685                	addi	a3,a3,1
ffffffffc0203088:	832fd0ef          	jal	ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc020308c:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc020308e:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203090:	613c                	ld	a5,64(a0)
ffffffffc0203092:	83b1                	srli	a5,a5,0xc
ffffffffc0203094:	97ae                	add	a5,a5,a1
ffffffffc0203096:	07a2                	slli	a5,a5,0x8
ffffffffc0203098:	00fb3023          	sd	a5,0(s6)
                    free_page(page);
ffffffffc020309c:	dc8fe0ef          	jal	ffffffffc0201664 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02030a0:	01893503          	ld	a0,24(s2)
ffffffffc02030a4:	85a6                	mv	a1,s1
ffffffffc02030a6:	e6eff0ef          	jal	ffffffffc0202714 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc02030aa:	068a0063          	beq	s4,s0,ffffffffc020310a <swap_out+0xbe>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02030ae:	0009b783          	ld	a5,0(s3)
ffffffffc02030b2:	8656                	mv	a2,s5
ffffffffc02030b4:	002c                	addi	a1,sp,8
ffffffffc02030b6:	7b9c                	ld	a5,48(a5)
ffffffffc02030b8:	854a                	mv	a0,s2
ffffffffc02030ba:	9782                	jalr	a5
          if (r != 0) {
ffffffffc02030bc:	e135                	bnez	a0,ffffffffc0203120 <swap_out+0xd4>
          v=page->pra_vaddr; 
ffffffffc02030be:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030c0:	01893503          	ld	a0,24(s2)
ffffffffc02030c4:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc02030c6:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030c8:	85a6                	mv	a1,s1
ffffffffc02030ca:	e14fe0ef          	jal	ffffffffc02016de <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc02030ce:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02030d0:	8b2a                	mv	s6,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc02030d2:	8b85                	andi	a5,a5,1
ffffffffc02030d4:	c3a5                	beqz	a5,ffffffffc0203134 <swap_out+0xe8>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc02030d6:	65a2                	ld	a1,8(sp)
ffffffffc02030d8:	61bc                	ld	a5,64(a1)
ffffffffc02030da:	83b1                	srli	a5,a5,0xc
ffffffffc02030dc:	0785                	addi	a5,a5,1
ffffffffc02030de:	00879513          	slli	a0,a5,0x8
ffffffffc02030e2:	3cb000ef          	jal	ffffffffc0203cac <swapfs_write>
ffffffffc02030e6:	d551                	beqz	a0,ffffffffc0203072 <swap_out+0x26>
                    cprintf("SWAP: failed to save\n");
ffffffffc02030e8:	00002517          	auipc	a0,0x2
ffffffffc02030ec:	78850513          	addi	a0,a0,1928 # ffffffffc0205870 <etext+0x15c8>
ffffffffc02030f0:	fcbfc0ef          	jal	ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc02030f4:	0009b783          	ld	a5,0(s3)
ffffffffc02030f8:	6622                	ld	a2,8(sp)
ffffffffc02030fa:	85a6                	mv	a1,s1
ffffffffc02030fc:	739c                	ld	a5,32(a5)
ffffffffc02030fe:	854a                	mv	a0,s2
ffffffffc0203100:	4681                	li	a3,0
     for (i = 0; i != n; ++ i)
ffffffffc0203102:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203104:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203106:	fa8a14e3          	bne	s4,s0,ffffffffc02030ae <swap_out+0x62>
ffffffffc020310a:	74e2                	ld	s1,56(sp)
ffffffffc020310c:	7942                	ld	s2,48(sp)
ffffffffc020310e:	79a2                	ld	s3,40(sp)
ffffffffc0203110:	7a02                	ld	s4,32(sp)
ffffffffc0203112:	6ae2                	ld	s5,24(sp)
ffffffffc0203114:	6b42                	ld	s6,16(sp)
}
ffffffffc0203116:	60a6                	ld	ra,72(sp)
ffffffffc0203118:	8522                	mv	a0,s0
ffffffffc020311a:	6406                	ld	s0,64(sp)
ffffffffc020311c:	6161                	addi	sp,sp,80
ffffffffc020311e:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203120:	85a2                	mv	a1,s0
ffffffffc0203122:	00002517          	auipc	a0,0x2
ffffffffc0203126:	70650513          	addi	a0,a0,1798 # ffffffffc0205828 <etext+0x1580>
ffffffffc020312a:	f91fc0ef          	jal	ffffffffc02000ba <cprintf>
                  break;
ffffffffc020312e:	bff1                	j	ffffffffc020310a <swap_out+0xbe>
     for (i = 0; i != n; ++ i)
ffffffffc0203130:	4401                	li	s0,0
ffffffffc0203132:	b7d5                	j	ffffffffc0203116 <swap_out+0xca>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203134:	00002697          	auipc	a3,0x2
ffffffffc0203138:	72468693          	addi	a3,a3,1828 # ffffffffc0205858 <etext+0x15b0>
ffffffffc020313c:	00002617          	auipc	a2,0x2
ffffffffc0203140:	a4460613          	addi	a2,a2,-1468 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203144:	06800593          	li	a1,104
ffffffffc0203148:	00002517          	auipc	a0,0x2
ffffffffc020314c:	45850513          	addi	a0,a0,1112 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc0203150:	9fcfd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0203154 <swap_in>:
{
ffffffffc0203154:	7179                	addi	sp,sp,-48
ffffffffc0203156:	e84a                	sd	s2,16(sp)
ffffffffc0203158:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc020315a:	4505                	li	a0,1
{
ffffffffc020315c:	ec26                	sd	s1,24(sp)
ffffffffc020315e:	e44e                	sd	s3,8(sp)
ffffffffc0203160:	f406                	sd	ra,40(sp)
ffffffffc0203162:	f022                	sd	s0,32(sp)
ffffffffc0203164:	84ae                	mv	s1,a1
ffffffffc0203166:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203168:	c74fe0ef          	jal	ffffffffc02015dc <alloc_pages>
     assert(result!=NULL);
ffffffffc020316c:	c129                	beqz	a0,ffffffffc02031ae <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020316e:	842a                	mv	s0,a0
ffffffffc0203170:	01893503          	ld	a0,24(s2)
ffffffffc0203174:	4601                	li	a2,0
ffffffffc0203176:	85a6                	mv	a1,s1
ffffffffc0203178:	d66fe0ef          	jal	ffffffffc02016de <get_pte>
ffffffffc020317c:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020317e:	6108                	ld	a0,0(a0)
ffffffffc0203180:	85a2                	mv	a1,s0
ffffffffc0203182:	285000ef          	jal	ffffffffc0203c06 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203186:	00093583          	ld	a1,0(s2)
ffffffffc020318a:	8626                	mv	a2,s1
ffffffffc020318c:	00002517          	auipc	a0,0x2
ffffffffc0203190:	74c50513          	addi	a0,a0,1868 # ffffffffc02058d8 <etext+0x1630>
ffffffffc0203194:	81a1                	srli	a1,a1,0x8
ffffffffc0203196:	f25fc0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc020319a:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc020319c:	0089b023          	sd	s0,0(s3)
}
ffffffffc02031a0:	7402                	ld	s0,32(sp)
ffffffffc02031a2:	64e2                	ld	s1,24(sp)
ffffffffc02031a4:	6942                	ld	s2,16(sp)
ffffffffc02031a6:	69a2                	ld	s3,8(sp)
ffffffffc02031a8:	4501                	li	a0,0
ffffffffc02031aa:	6145                	addi	sp,sp,48
ffffffffc02031ac:	8082                	ret
     assert(result!=NULL);
ffffffffc02031ae:	00002697          	auipc	a3,0x2
ffffffffc02031b2:	71a68693          	addi	a3,a3,1818 # ffffffffc02058c8 <etext+0x1620>
ffffffffc02031b6:	00002617          	auipc	a2,0x2
ffffffffc02031ba:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02031be:	07e00593          	li	a1,126
ffffffffc02031c2:	00002517          	auipc	a0,0x2
ffffffffc02031c6:	3de50513          	addi	a0,a0,990 # ffffffffc02055a0 <etext+0x12f8>
ffffffffc02031ca:	982fd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02031ce <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02031ce:	0000e797          	auipc	a5,0xe
ffffffffc02031d2:	f1a78793          	addi	a5,a5,-230 # ffffffffc02110e8 <pra_list_head>
     // 初始化pra_list_head为空链表
     list_init(&pra_list_head);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr = &pra_list_head;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv = &pra_list_head;
ffffffffc02031d6:	f51c                	sd	a5,40(a0)
ffffffffc02031d8:	e79c                	sd	a5,8(a5)
ffffffffc02031da:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc02031dc:	0000e717          	auipc	a4,0xe
ffffffffc02031e0:	36f73e23          	sd	a5,892(a4) # ffffffffc0211558 <curr_ptr>
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02031e4:	4501                	li	a0,0
ffffffffc02031e6:	8082                	ret

ffffffffc02031e8 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc02031e8:	4501                	li	a0,0
ffffffffc02031ea:	8082                	ret

ffffffffc02031ec <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02031ec:	4501                	li	a0,0
ffffffffc02031ee:	8082                	ret

ffffffffc02031f0 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02031f0:	4501                	li	a0,0
ffffffffc02031f2:	8082                	ret

ffffffffc02031f4 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02031f4:	1141                	addi	sp,sp,-16
ffffffffc02031f6:	e406                	sd	ra,8(sp)
*(unsigned char *)0x4000 = 0x04;  // 访问页面 4
ffffffffc02031f8:	6311                	lui	t1,0x4
ffffffffc02031fa:	4e11                	li	t3,4
ffffffffc02031fc:	01c30023          	sb	t3,0(t1) # 4000 <kern_entry-0xffffffffc01fc000>
*(unsigned char *)0x5000 = 0x05;  // 页面 5 访问
ffffffffc0203200:	6815                	lui	a6,0x5
ffffffffc0203202:	4895                	li	a7,5
ffffffffc0203204:	01180023          	sb	a7,0(a6) # 5000 <kern_entry-0xffffffffc01fb000>
*(unsigned char *)0x1000 = 0x01;  // 页面 1 重新访问，换入页面 1
ffffffffc0203208:	6585                	lui	a1,0x1
ffffffffc020320a:	4505                	li	a0,1
ffffffffc020320c:	00a58023          	sb	a0,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
*(unsigned char *)0x3000 = 0x03;  // 页面 3 继续访问
ffffffffc0203210:	668d                	lui	a3,0x3
ffffffffc0203212:	460d                	li	a2,3
ffffffffc0203214:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
*(unsigned char *)0x2000 = 0x02;  // 页面 2 继续访问
ffffffffc0203218:	6789                	lui	a5,0x2
ffffffffc020321a:	4709                	li	a4,2
ffffffffc020321c:	00e78023          	sb	a4,0(a5) # 2000 <kern_entry-0xffffffffc01fe000>
    cprintf("countttttttttttttttttttt:%d\n",count);
ffffffffc0203220:	0000e597          	auipc	a1,0xe
ffffffffc0203224:	3405a583          	lw	a1,832(a1) # ffffffffc0211560 <count>
ffffffffc0203228:	00002517          	auipc	a0,0x2
ffffffffc020322c:	6f050513          	addi	a0,a0,1776 # ffffffffc0205918 <etext+0x1670>
ffffffffc0203230:	e8bfc0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc0203234:	60a2                	ld	ra,8(sp)
ffffffffc0203236:	4501                	li	a0,0
ffffffffc0203238:	0141                	addi	sp,sp,16
ffffffffc020323a:	8082                	ret

ffffffffc020323c <_clock_swap_out_victim>:
    count++;
ffffffffc020323c:	0000e797          	auipc	a5,0xe
ffffffffc0203240:	3247a783          	lw	a5,804(a5) # ffffffffc0211560 <count>
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203244:	7508                	ld	a0,40(a0)
{
ffffffffc0203246:	1141                	addi	sp,sp,-16
    count++;
ffffffffc0203248:	2785                	addiw	a5,a5,1
{
ffffffffc020324a:	e406                	sd	ra,8(sp)
    count++;
ffffffffc020324c:	0000e717          	auipc	a4,0xe
ffffffffc0203250:	30f72a23          	sw	a5,788(a4) # ffffffffc0211560 <count>
         assert(head != NULL);
ffffffffc0203254:	c125                	beqz	a0,ffffffffc02032b4 <_clock_swap_out_victim+0x78>
     assert(in_tick==0);
ffffffffc0203256:	ee3d                	bnez	a2,ffffffffc02032d4 <_clock_swap_out_victim+0x98>
    return listelm->next;
ffffffffc0203258:	00853803          	ld	a6,8(a0)
    if(head==list_next(head)){
ffffffffc020325c:	05050263          	beq	a0,a6,ffffffffc02032a0 <_clock_swap_out_victim+0x64>
        list_entry_t *entry = curr_ptr;
ffffffffc0203260:	0000e617          	auipc	a2,0xe
ffffffffc0203264:	2f860613          	addi	a2,a2,760 # ffffffffc0211558 <curr_ptr>
ffffffffc0203268:	621c                	ld	a5,0(a2)
ffffffffc020326a:	a031                	j	ffffffffc0203276 <_clock_swap_out_victim+0x3a>
            (*ptr_page)->visited = 0;
ffffffffc020326c:	fe073023          	sd	zero,-32(a4)
            curr_ptr = list_next(curr_ptr);
ffffffffc0203270:	e21c                	sd	a5,0(a2)
            if (curr_ptr == head) {
ffffffffc0203272:	02f50363          	beq	a0,a5,ffffffffc0203298 <_clock_swap_out_victim+0x5c>
        if ((*ptr_page)->visited == 0) {
ffffffffc0203276:	fe07b683          	ld	a3,-32(a5)
ffffffffc020327a:	873e                	mv	a4,a5
ffffffffc020327c:	679c                	ld	a5,8(a5)
ffffffffc020327e:	f6fd                	bnez	a3,ffffffffc020326c <_clock_swap_out_victim+0x30>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203280:	6314                	ld	a3,0(a4)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203282:	fd070513          	addi	a0,a4,-48
ffffffffc0203286:	e188                	sd	a0,0(a1)
    prev->next = next;
ffffffffc0203288:	e69c                	sd	a5,8(a3)
            curr_ptr = list_next(curr_ptr);
ffffffffc020328a:	6718                	ld	a4,8(a4)
}
ffffffffc020328c:	60a2                	ld	ra,8(sp)
    next->prev = prev;
ffffffffc020328e:	e394                	sd	a3,0(a5)
            curr_ptr = list_next(curr_ptr);
ffffffffc0203290:	e218                	sd	a4,0(a2)
}
ffffffffc0203292:	4501                	li	a0,0
ffffffffc0203294:	0141                	addi	sp,sp,16
ffffffffc0203296:	8082                	ret
                curr_ptr = list_next(head);
ffffffffc0203298:	01063023          	sd	a6,0(a2)
ffffffffc020329c:	87c2                	mv	a5,a6
ffffffffc020329e:	bfe1                	j	ffffffffc0203276 <_clock_swap_out_victim+0x3a>
        cprintf("no page to swap out\n");
ffffffffc02032a0:	00002517          	auipc	a0,0x2
ffffffffc02032a4:	6d050513          	addi	a0,a0,1744 # ffffffffc0205970 <etext+0x16c8>
ffffffffc02032a8:	e13fc0ef          	jal	ffffffffc02000ba <cprintf>
}
ffffffffc02032ac:	60a2                	ld	ra,8(sp)
ffffffffc02032ae:	4501                	li	a0,0
ffffffffc02032b0:	0141                	addi	sp,sp,16
ffffffffc02032b2:	8082                	ret
         assert(head != NULL);
ffffffffc02032b4:	00002697          	auipc	a3,0x2
ffffffffc02032b8:	68468693          	addi	a3,a3,1668 # ffffffffc0205938 <etext+0x1690>
ffffffffc02032bc:	00002617          	auipc	a2,0x2
ffffffffc02032c0:	8c460613          	addi	a2,a2,-1852 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02032c4:	04b00593          	li	a1,75
ffffffffc02032c8:	00002517          	auipc	a0,0x2
ffffffffc02032cc:	68050513          	addi	a0,a0,1664 # ffffffffc0205948 <etext+0x16a0>
ffffffffc02032d0:	87cfd0ef          	jal	ffffffffc020034c <__panic>
     assert(in_tick==0);
ffffffffc02032d4:	00002697          	auipc	a3,0x2
ffffffffc02032d8:	68c68693          	addi	a3,a3,1676 # ffffffffc0205960 <etext+0x16b8>
ffffffffc02032dc:	00002617          	auipc	a2,0x2
ffffffffc02032e0:	8a460613          	addi	a2,a2,-1884 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02032e4:	04c00593          	li	a1,76
ffffffffc02032e8:	00002517          	auipc	a0,0x2
ffffffffc02032ec:	66050513          	addi	a0,a0,1632 # ffffffffc0205948 <etext+0x16a0>
ffffffffc02032f0:	85cfd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02032f4 <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02032f4:	0000e797          	auipc	a5,0xe
ffffffffc02032f8:	2647b783          	ld	a5,612(a5) # ffffffffc0211558 <curr_ptr>
ffffffffc02032fc:	cf89                	beqz	a5,ffffffffc0203316 <_clock_map_swappable+0x22>
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02032fe:	751c                	ld	a5,40(a0)
ffffffffc0203300:	03060713          	addi	a4,a2,48
    page->visited = 1;
ffffffffc0203304:	4585                	li	a1,1
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203306:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203308:	e398                	sd	a4,0(a5)
}
ffffffffc020330a:	4501                	li	a0,0
ffffffffc020330c:	e698                	sd	a4,8(a3)
    elm->prev = prev;
ffffffffc020330e:	fa14                	sd	a3,48(a2)
    elm->next = next;
ffffffffc0203310:	fe1c                	sd	a5,56(a2)
    page->visited = 1;
ffffffffc0203312:	ea0c                	sd	a1,16(a2)
}
ffffffffc0203314:	8082                	ret
{
ffffffffc0203316:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203318:	00002697          	auipc	a3,0x2
ffffffffc020331c:	67068693          	addi	a3,a3,1648 # ffffffffc0205988 <etext+0x16e0>
ffffffffc0203320:	00002617          	auipc	a2,0x2
ffffffffc0203324:	86060613          	addi	a2,a2,-1952 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203328:	03700593          	li	a1,55
ffffffffc020332c:	00002517          	auipc	a0,0x2
ffffffffc0203330:	61c50513          	addi	a0,a0,1564 # ffffffffc0205948 <etext+0x16a0>
{
ffffffffc0203334:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203336:	816fd0ef          	jal	ffffffffc020034c <__panic>

ffffffffc020333a <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc020333a:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020333c:	00002697          	auipc	a3,0x2
ffffffffc0203340:	68c68693          	addi	a3,a3,1676 # ffffffffc02059c8 <etext+0x1720>
ffffffffc0203344:	00002617          	auipc	a2,0x2
ffffffffc0203348:	83c60613          	addi	a2,a2,-1988 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020334c:	07d00593          	li	a1,125
ffffffffc0203350:	00002517          	auipc	a0,0x2
ffffffffc0203354:	69850513          	addi	a0,a0,1688 # ffffffffc02059e8 <etext+0x1740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203358:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020335a:	ff3fc0ef          	jal	ffffffffc020034c <__panic>

ffffffffc020335e <mm_create>:
mm_create(void) {
ffffffffc020335e:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203360:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203364:	e022                	sd	s0,0(sp)
ffffffffc0203366:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203368:	c66ff0ef          	jal	ffffffffc02027ce <kmalloc>
ffffffffc020336c:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020336e:	c105                	beqz	a0,ffffffffc020338e <mm_create+0x30>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203370:	0000e797          	auipc	a5,0xe
ffffffffc0203374:	1d07a783          	lw	a5,464(a5) # ffffffffc0211540 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203378:	e408                	sd	a0,8(s0)
ffffffffc020337a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020337c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203380:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203384:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203388:	eb81                	bnez	a5,ffffffffc0203398 <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc020338a:	02053423          	sd	zero,40(a0)
}
ffffffffc020338e:	60a2                	ld	ra,8(sp)
ffffffffc0203390:	8522                	mv	a0,s0
ffffffffc0203392:	6402                	ld	s0,0(sp)
ffffffffc0203394:	0141                	addi	sp,sp,16
ffffffffc0203396:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203398:	c9dff0ef          	jal	ffffffffc0203034 <swap_init_mm>
}
ffffffffc020339c:	60a2                	ld	ra,8(sp)
ffffffffc020339e:	8522                	mv	a0,s0
ffffffffc02033a0:	6402                	ld	s0,0(sp)
ffffffffc02033a2:	0141                	addi	sp,sp,16
ffffffffc02033a4:	8082                	ret

ffffffffc02033a6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02033a6:	1101                	addi	sp,sp,-32
ffffffffc02033a8:	e04a                	sd	s2,0(sp)
ffffffffc02033aa:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02033ac:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02033b0:	e822                	sd	s0,16(sp)
ffffffffc02033b2:	e426                	sd	s1,8(sp)
ffffffffc02033b4:	ec06                	sd	ra,24(sp)
ffffffffc02033b6:	84ae                	mv	s1,a1
ffffffffc02033b8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02033ba:	c14ff0ef          	jal	ffffffffc02027ce <kmalloc>
    if (vma != NULL) {
ffffffffc02033be:	c509                	beqz	a0,ffffffffc02033c8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02033c0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02033c4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02033c6:	ed00                	sd	s0,24(a0)
}
ffffffffc02033c8:	60e2                	ld	ra,24(sp)
ffffffffc02033ca:	6442                	ld	s0,16(sp)
ffffffffc02033cc:	64a2                	ld	s1,8(sp)
ffffffffc02033ce:	6902                	ld	s2,0(sp)
ffffffffc02033d0:	6105                	addi	sp,sp,32
ffffffffc02033d2:	8082                	ret

ffffffffc02033d4 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02033d4:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02033d6:	c505                	beqz	a0,ffffffffc02033fe <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02033d8:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02033da:	c501                	beqz	a0,ffffffffc02033e2 <find_vma+0xe>
ffffffffc02033dc:	651c                	ld	a5,8(a0)
ffffffffc02033de:	02f5f263          	bgeu	a1,a5,ffffffffc0203402 <find_vma+0x2e>
    return listelm->next;
ffffffffc02033e2:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02033e4:	00f68d63          	beq	a3,a5,ffffffffc02033fe <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02033e8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02033ec:	00e5e663          	bltu	a1,a4,ffffffffc02033f8 <find_vma+0x24>
ffffffffc02033f0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02033f4:	00e5ec63          	bltu	a1,a4,ffffffffc020340c <find_vma+0x38>
ffffffffc02033f8:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02033fa:	fef697e3          	bne	a3,a5,ffffffffc02033e8 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc02033fe:	4501                	li	a0,0
}
ffffffffc0203400:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203402:	691c                	ld	a5,16(a0)
ffffffffc0203404:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02033e2 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203408:	ea88                	sd	a0,16(a3)
ffffffffc020340a:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020340c:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203410:	ea88                	sd	a0,16(a3)
ffffffffc0203412:	8082                	ret

ffffffffc0203414 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203414:	6590                	ld	a2,8(a1)
ffffffffc0203416:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020341a:	1141                	addi	sp,sp,-16
ffffffffc020341c:	e406                	sd	ra,8(sp)
ffffffffc020341e:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203420:	01066763          	bltu	a2,a6,ffffffffc020342e <insert_vma_struct+0x1a>
ffffffffc0203424:	a085                	j	ffffffffc0203484 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203426:	fe87b703          	ld	a4,-24(a5)
ffffffffc020342a:	04e66863          	bltu	a2,a4,ffffffffc020347a <insert_vma_struct+0x66>
ffffffffc020342e:	86be                	mv	a3,a5
ffffffffc0203430:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0203432:	fef51ae3          	bne	a0,a5,ffffffffc0203426 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203436:	02a68463          	beq	a3,a0,ffffffffc020345e <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020343a:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020343e:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203442:	08e8f163          	bgeu	a7,a4,ffffffffc02034c4 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203446:	04e66f63          	bltu	a2,a4,ffffffffc02034a4 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc020344a:	00f50a63          	beq	a0,a5,ffffffffc020345e <insert_vma_struct+0x4a>
ffffffffc020344e:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203452:	05076963          	bltu	a4,a6,ffffffffc02034a4 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0203456:	ff07b603          	ld	a2,-16(a5)
ffffffffc020345a:	02c77363          	bgeu	a4,a2,ffffffffc0203480 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020345e:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203460:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203462:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203466:	e390                	sd	a2,0(a5)
ffffffffc0203468:	e690                	sd	a2,8(a3)
}
ffffffffc020346a:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020346c:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020346e:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0203470:	0017079b          	addiw	a5,a4,1
ffffffffc0203474:	d11c                	sw	a5,32(a0)
}
ffffffffc0203476:	0141                	addi	sp,sp,16
ffffffffc0203478:	8082                	ret
    if (le_prev != list) {
ffffffffc020347a:	fca690e3          	bne	a3,a0,ffffffffc020343a <insert_vma_struct+0x26>
ffffffffc020347e:	bfd1                	j	ffffffffc0203452 <insert_vma_struct+0x3e>
ffffffffc0203480:	ebbff0ef          	jal	ffffffffc020333a <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203484:	00002697          	auipc	a3,0x2
ffffffffc0203488:	57468693          	addi	a3,a3,1396 # ffffffffc02059f8 <etext+0x1750>
ffffffffc020348c:	00001617          	auipc	a2,0x1
ffffffffc0203490:	6f460613          	addi	a2,a2,1780 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203494:	08400593          	li	a1,132
ffffffffc0203498:	00002517          	auipc	a0,0x2
ffffffffc020349c:	55050513          	addi	a0,a0,1360 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02034a0:	eadfc0ef          	jal	ffffffffc020034c <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02034a4:	00002697          	auipc	a3,0x2
ffffffffc02034a8:	59468693          	addi	a3,a3,1428 # ffffffffc0205a38 <etext+0x1790>
ffffffffc02034ac:	00001617          	auipc	a2,0x1
ffffffffc02034b0:	6d460613          	addi	a2,a2,1748 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02034b4:	07c00593          	li	a1,124
ffffffffc02034b8:	00002517          	auipc	a0,0x2
ffffffffc02034bc:	53050513          	addi	a0,a0,1328 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02034c0:	e8dfc0ef          	jal	ffffffffc020034c <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02034c4:	00002697          	auipc	a3,0x2
ffffffffc02034c8:	55468693          	addi	a3,a3,1364 # ffffffffc0205a18 <etext+0x1770>
ffffffffc02034cc:	00001617          	auipc	a2,0x1
ffffffffc02034d0:	6b460613          	addi	a2,a2,1716 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02034d4:	07b00593          	li	a1,123
ffffffffc02034d8:	00002517          	auipc	a0,0x2
ffffffffc02034dc:	51050513          	addi	a0,a0,1296 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02034e0:	e6dfc0ef          	jal	ffffffffc020034c <__panic>

ffffffffc02034e4 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02034e4:	1141                	addi	sp,sp,-16
ffffffffc02034e6:	e022                	sd	s0,0(sp)
ffffffffc02034e8:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02034ea:	6508                	ld	a0,8(a0)
ffffffffc02034ec:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02034ee:	00a40e63          	beq	s0,a0,ffffffffc020350a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02034f2:	6118                	ld	a4,0(a0)
ffffffffc02034f4:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02034f6:	03000593          	li	a1,48
ffffffffc02034fa:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02034fc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02034fe:	e398                	sd	a4,0(a5)
ffffffffc0203500:	b94ff0ef          	jal	ffffffffc0202894 <kfree>
    return listelm->next;
ffffffffc0203504:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203506:	fea416e3          	bne	s0,a0,ffffffffc02034f2 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020350a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020350c:	6402                	ld	s0,0(sp)
ffffffffc020350e:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203510:	03000593          	li	a1,48
}
ffffffffc0203514:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203516:	b7eff06f          	j	ffffffffc0202894 <kfree>

ffffffffc020351a <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020351a:	715d                	addi	sp,sp,-80
ffffffffc020351c:	e486                	sd	ra,72(sp)
ffffffffc020351e:	f44e                	sd	s3,40(sp)
ffffffffc0203520:	f052                	sd	s4,32(sp)
ffffffffc0203522:	e0a2                	sd	s0,64(sp)
ffffffffc0203524:	fc26                	sd	s1,56(sp)
ffffffffc0203526:	f84a                	sd	s2,48(sp)
ffffffffc0203528:	ec56                	sd	s5,24(sp)
ffffffffc020352a:	e85a                	sd	s6,16(sp)
ffffffffc020352c:	e45e                	sd	s7,8(sp)
ffffffffc020352e:	e062                	sd	s8,0(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203530:	974fe0ef          	jal	ffffffffc02016a4 <nr_free_pages>
ffffffffc0203534:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203536:	96efe0ef          	jal	ffffffffc02016a4 <nr_free_pages>
ffffffffc020353a:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020353c:	03000513          	li	a0,48
ffffffffc0203540:	a8eff0ef          	jal	ffffffffc02027ce <kmalloc>
    if (mm != NULL) {
ffffffffc0203544:	16050f63          	beqz	a0,ffffffffc02036c2 <vmm_init+0x1a8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203548:	0000e797          	auipc	a5,0xe
ffffffffc020354c:	ff87a783          	lw	a5,-8(a5) # ffffffffc0211540 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0203550:	e508                	sd	a0,8(a0)
ffffffffc0203552:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203554:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203558:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020355c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203560:	842a                	mv	s0,a0
ffffffffc0203562:	12079d63          	bnez	a5,ffffffffc020369c <vmm_init+0x182>
        else mm->sm_priv = NULL;
ffffffffc0203566:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc020356a:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020356e:	03000513          	li	a0,48
ffffffffc0203572:	a5cff0ef          	jal	ffffffffc02027ce <kmalloc>
ffffffffc0203576:	00248913          	addi	s2,s1,2
ffffffffc020357a:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020357c:	12050363          	beqz	a0,ffffffffc02036a2 <vmm_init+0x188>
        vma->vm_start = vm_start;
ffffffffc0203580:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203582:	01253823          	sd	s2,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203586:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020358a:	14ed                	addi	s1,s1,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020358c:	8522                	mv	a0,s0
ffffffffc020358e:	e87ff0ef          	jal	ffffffffc0203414 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203592:	fcf1                	bnez	s1,ffffffffc020356e <vmm_init+0x54>
ffffffffc0203594:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203598:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020359c:	03000513          	li	a0,48
ffffffffc02035a0:	a2eff0ef          	jal	ffffffffc02027ce <kmalloc>
ffffffffc02035a4:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02035a6:	12050e63          	beqz	a0,ffffffffc02036e2 <vmm_init+0x1c8>
        vma->vm_end = vm_end;
ffffffffc02035aa:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc02035ae:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc02035b0:	00053c23          	sd	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc02035b4:	e91c                	sd	a5,16(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02035b6:	0495                	addi	s1,s1,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02035b8:	8522                	mv	a0,s0
ffffffffc02035ba:	e5bff0ef          	jal	ffffffffc0203414 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02035be:	fd249fe3          	bne	s1,s2,ffffffffc020359c <vmm_init+0x82>
    return listelm->next;
ffffffffc02035c2:	00843b03          	ld	s6,8(s0)
ffffffffc02035c6:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02035c8:	1fb00593          	li	a1,507
    list_entry_t *le = list_next(&(mm->mmap_list));
ffffffffc02035cc:	87da                	mv	a5,s6
        assert(le != &(mm->mmap_list));
ffffffffc02035ce:	3af40563          	beq	s0,a5,ffffffffc0203978 <vmm_init+0x45e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02035d2:	fe87b603          	ld	a2,-24(a5)
ffffffffc02035d6:	ffe70693          	addi	a3,a4,-2
ffffffffc02035da:	2ed61f63          	bne	a2,a3,ffffffffc02038d8 <vmm_init+0x3be>
ffffffffc02035de:	ff07b683          	ld	a3,-16(a5)
ffffffffc02035e2:	2ee69b63          	bne	a3,a4,ffffffffc02038d8 <vmm_init+0x3be>
    for (i = 1; i <= step2; i ++) {
ffffffffc02035e6:	0715                	addi	a4,a4,5
ffffffffc02035e8:	679c                	ld	a5,8(a5)
ffffffffc02035ea:	feb712e3          	bne	a4,a1,ffffffffc02035ce <vmm_init+0xb4>
ffffffffc02035ee:	4b9d                	li	s7,7
ffffffffc02035f0:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02035f2:	1f900c13          	li	s8,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02035f6:	85a6                	mv	a1,s1
ffffffffc02035f8:	8522                	mv	a0,s0
ffffffffc02035fa:	ddbff0ef          	jal	ffffffffc02033d4 <find_vma>
ffffffffc02035fe:	8aaa                	mv	s5,a0
        assert(vma1 != NULL);
ffffffffc0203600:	3a050c63          	beqz	a0,ffffffffc02039b8 <vmm_init+0x49e>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203604:	00148593          	addi	a1,s1,1
ffffffffc0203608:	8522                	mv	a0,s0
ffffffffc020360a:	dcbff0ef          	jal	ffffffffc02033d4 <find_vma>
ffffffffc020360e:	892a                	mv	s2,a0
        assert(vma2 != NULL);
ffffffffc0203610:	38050463          	beqz	a0,ffffffffc0203998 <vmm_init+0x47e>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203614:	85de                	mv	a1,s7
ffffffffc0203616:	8522                	mv	a0,s0
ffffffffc0203618:	dbdff0ef          	jal	ffffffffc02033d4 <find_vma>
        assert(vma3 == NULL);
ffffffffc020361c:	32051e63          	bnez	a0,ffffffffc0203958 <vmm_init+0x43e>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203620:	00348593          	addi	a1,s1,3
ffffffffc0203624:	8522                	mv	a0,s0
ffffffffc0203626:	dafff0ef          	jal	ffffffffc02033d4 <find_vma>
        assert(vma4 == NULL);
ffffffffc020362a:	30051763          	bnez	a0,ffffffffc0203938 <vmm_init+0x41e>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020362e:	00448593          	addi	a1,s1,4
ffffffffc0203632:	8522                	mv	a0,s0
ffffffffc0203634:	da1ff0ef          	jal	ffffffffc02033d4 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203638:	3a051063          	bnez	a0,ffffffffc02039d8 <vmm_init+0x4be>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020363c:	008ab783          	ld	a5,8(s5)
ffffffffc0203640:	2a979c63          	bne	a5,s1,ffffffffc02038f8 <vmm_init+0x3de>
ffffffffc0203644:	010ab783          	ld	a5,16(s5)
ffffffffc0203648:	2b779863          	bne	a5,s7,ffffffffc02038f8 <vmm_init+0x3de>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020364c:	00893783          	ld	a5,8(s2)
ffffffffc0203650:	2c979463          	bne	a5,s1,ffffffffc0203918 <vmm_init+0x3fe>
ffffffffc0203654:	01093783          	ld	a5,16(s2)
ffffffffc0203658:	2d779063          	bne	a5,s7,ffffffffc0203918 <vmm_init+0x3fe>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020365c:	0495                	addi	s1,s1,5
ffffffffc020365e:	0b95                	addi	s7,s7,5
ffffffffc0203660:	f9849be3          	bne	s1,s8,ffffffffc02035f6 <vmm_init+0xdc>
ffffffffc0203664:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203666:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203668:	85a6                	mv	a1,s1
ffffffffc020366a:	8522                	mv	a0,s0
ffffffffc020366c:	d69ff0ef          	jal	ffffffffc02033d4 <find_vma>
        if (vma_below_5 != NULL ) {
ffffffffc0203670:	3a051463          	bnez	a0,ffffffffc0203a18 <vmm_init+0x4fe>
    for (i =4; i>=0; i--) {
ffffffffc0203674:	14fd                	addi	s1,s1,-1
ffffffffc0203676:	ff2499e3          	bne	s1,s2,ffffffffc0203668 <vmm_init+0x14e>
    while ((le = list_next(list)) != list) {
ffffffffc020367a:	09640463          	beq	s0,s6,ffffffffc0203702 <vmm_init+0x1e8>
    __list_del(listelm->prev, listelm->next);
ffffffffc020367e:	000b3703          	ld	a4,0(s6)
ffffffffc0203682:	008b3783          	ld	a5,8(s6)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203686:	fe0b0513          	addi	a0,s6,-32
ffffffffc020368a:	03000593          	li	a1,48
    prev->next = next;
ffffffffc020368e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203690:	e398                	sd	a4,0(a5)
ffffffffc0203692:	a02ff0ef          	jal	ffffffffc0202894 <kfree>
    return listelm->next;
ffffffffc0203696:	00843b03          	ld	s6,8(s0)
ffffffffc020369a:	b7c5                	j	ffffffffc020367a <vmm_init+0x160>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020369c:	999ff0ef          	jal	ffffffffc0203034 <swap_init_mm>
    assert(mm != NULL);
ffffffffc02036a0:	b5e9                	j	ffffffffc020356a <vmm_init+0x50>
        assert(vma != NULL);
ffffffffc02036a2:	00002697          	auipc	a3,0x2
ffffffffc02036a6:	f8668693          	addi	a3,a3,-122 # ffffffffc0205628 <etext+0x1380>
ffffffffc02036aa:	00001617          	auipc	a2,0x1
ffffffffc02036ae:	4d660613          	addi	a2,a2,1238 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02036b2:	0ce00593          	li	a1,206
ffffffffc02036b6:	00002517          	auipc	a0,0x2
ffffffffc02036ba:	33250513          	addi	a0,a0,818 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02036be:	c8ffc0ef          	jal	ffffffffc020034c <__panic>
    assert(mm != NULL);
ffffffffc02036c2:	00002697          	auipc	a3,0x2
ffffffffc02036c6:	f2e68693          	addi	a3,a3,-210 # ffffffffc02055f0 <etext+0x1348>
ffffffffc02036ca:	00001617          	auipc	a2,0x1
ffffffffc02036ce:	4b660613          	addi	a2,a2,1206 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02036d2:	0c700593          	li	a1,199
ffffffffc02036d6:	00002517          	auipc	a0,0x2
ffffffffc02036da:	31250513          	addi	a0,a0,786 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02036de:	c6ffc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma != NULL);
ffffffffc02036e2:	00002697          	auipc	a3,0x2
ffffffffc02036e6:	f4668693          	addi	a3,a3,-186 # ffffffffc0205628 <etext+0x1380>
ffffffffc02036ea:	00001617          	auipc	a2,0x1
ffffffffc02036ee:	49660613          	addi	a2,a2,1174 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02036f2:	0d400593          	li	a1,212
ffffffffc02036f6:	00002517          	auipc	a0,0x2
ffffffffc02036fa:	2f250513          	addi	a0,a0,754 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02036fe:	c4ffc0ef          	jal	ffffffffc020034c <__panic>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203702:	8522                	mv	a0,s0
ffffffffc0203704:	03000593          	li	a1,48
ffffffffc0203708:	98cff0ef          	jal	ffffffffc0202894 <kfree>
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020370c:	f99fd0ef          	jal	ffffffffc02016a4 <nr_free_pages>
ffffffffc0203710:	34aa1e63          	bne	s4,a0,ffffffffc0203a6c <vmm_init+0x552>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203714:	00002517          	auipc	a0,0x2
ffffffffc0203718:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205bc0 <etext+0x1918>
ffffffffc020371c:	99ffc0ef          	jal	ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203720:	f85fd0ef          	jal	ffffffffc02016a4 <nr_free_pages>
ffffffffc0203724:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203726:	03000513          	li	a0,48
ffffffffc020372a:	8a4ff0ef          	jal	ffffffffc02027ce <kmalloc>
ffffffffc020372e:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0203730:	16050d63          	beqz	a0,ffffffffc02038aa <vmm_init+0x390>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203734:	0000e797          	auipc	a5,0xe
ffffffffc0203738:	e0c7a783          	lw	a5,-500(a5) # ffffffffc0211540 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc020373c:	e508                	sd	a0,8(a0)
ffffffffc020373e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203740:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203744:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203748:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020374c:	18079363          	bnez	a5,ffffffffc02038d2 <vmm_init+0x3b8>
        else mm->sm_priv = NULL;
ffffffffc0203750:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203754:	0000e917          	auipc	s2,0xe
ffffffffc0203758:	dcc93903          	ld	s2,-564(s2) # ffffffffc0211520 <boot_pgdir>
    check_mm_struct = mm_create();
ffffffffc020375c:	0000e797          	auipc	a5,0xe
ffffffffc0203760:	e087b623          	sd	s0,-500(a5) # ffffffffc0211568 <check_mm_struct>
    assert(pgdir[0] == 0);
ffffffffc0203764:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203768:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc020376c:	28079663          	bnez	a5,ffffffffc02039f8 <vmm_init+0x4de>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203770:	03000513          	li	a0,48
ffffffffc0203774:	85aff0ef          	jal	ffffffffc02027ce <kmalloc>
ffffffffc0203778:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020377a:	10050863          	beqz	a0,ffffffffc020388a <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc020377e:	00200737          	lui	a4,0x200
        vma->vm_flags = vm_flags;
ffffffffc0203782:	4789                	li	a5,2
        vma->vm_end = vm_end;
ffffffffc0203784:	e918                	sd	a4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203786:	ed1c                	sd	a5,24(a0)

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203788:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020378a:	00053423          	sd	zero,8(a0)
    insert_vma_struct(mm, vma);
ffffffffc020378e:	8522                	mv	a0,s0
ffffffffc0203790:	c85ff0ef          	jal	ffffffffc0203414 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203794:	8522                	mv	a0,s0
ffffffffc0203796:	10000593          	li	a1,256
ffffffffc020379a:	c3bff0ef          	jal	ffffffffc02033d4 <find_vma>
ffffffffc020379e:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02037a2:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02037a6:	2aaa1363          	bne	s4,a0,ffffffffc0203a4c <vmm_init+0x532>
        *(char *)(addr + i) = i;
ffffffffc02037aa:	00f78023          	sb	a5,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02037ae:	0785                	addi	a5,a5,1
ffffffffc02037b0:	fee79de3          	bne	a5,a4,ffffffffc02037aa <vmm_init+0x290>
ffffffffc02037b4:	6705                	lui	a4,0x1
ffffffffc02037b6:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
ffffffffc02037ba:	10000793          	li	a5,256
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02037be:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02037c2:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc02037c6:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc02037c8:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02037ca:	fec79ce3          	bne	a5,a2,ffffffffc02037c2 <vmm_init+0x2a8>
    }
    assert(sum == 0);
ffffffffc02037ce:	2c071b63          	bnez	a4,ffffffffc0203aa4 <vmm_init+0x58a>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02037d2:	4581                	li	a1,0
ffffffffc02037d4:	854a                	mv	a0,s2
ffffffffc02037d6:	97efe0ef          	jal	ffffffffc0201954 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037da:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02037de:	0000e717          	auipc	a4,0xe
ffffffffc02037e2:	d5273703          	ld	a4,-686(a4) # ffffffffc0211530 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037e6:	078a                	slli	a5,a5,0x2
ffffffffc02037e8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037ea:	2ae7f163          	bgeu	a5,a4,ffffffffc0203a8c <vmm_init+0x572>
    return &pages[PPN(pa) - nbase];
ffffffffc02037ee:	00003717          	auipc	a4,0x3
ffffffffc02037f2:	88273703          	ld	a4,-1918(a4) # ffffffffc0206070 <nbase>
ffffffffc02037f6:	0000e517          	auipc	a0,0xe
ffffffffc02037fa:	d4253503          	ld	a0,-702(a0) # ffffffffc0211538 <pages>

    free_page(pde2page(pgdir[0]));
ffffffffc02037fe:	4585                	li	a1,1
ffffffffc0203800:	8f99                	sub	a5,a5,a4
ffffffffc0203802:	00379713          	slli	a4,a5,0x3
ffffffffc0203806:	97ba                	add	a5,a5,a4
ffffffffc0203808:	078e                	slli	a5,a5,0x3
ffffffffc020380a:	953e                	add	a0,a0,a5
ffffffffc020380c:	e59fd0ef          	jal	ffffffffc0201664 <free_pages>
    return listelm->next;
ffffffffc0203810:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0203812:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0203816:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020381a:	00a40e63          	beq	s0,a0,ffffffffc0203836 <vmm_init+0x31c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020381e:	6118                	ld	a4,0(a0)
ffffffffc0203820:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203822:	03000593          	li	a1,48
ffffffffc0203826:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203828:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020382a:	e398                	sd	a4,0(a5)
ffffffffc020382c:	868ff0ef          	jal	ffffffffc0202894 <kfree>
    return listelm->next;
ffffffffc0203830:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203832:	fea416e3          	bne	s0,a0,ffffffffc020381e <vmm_init+0x304>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203836:	8522                	mv	a0,s0
ffffffffc0203838:	03000593          	li	a1,48
ffffffffc020383c:	858ff0ef          	jal	ffffffffc0202894 <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203840:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203842:	0000e797          	auipc	a5,0xe
ffffffffc0203846:	d207b323          	sd	zero,-730(a5) # ffffffffc0211568 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020384a:	e5bfd0ef          	jal	ffffffffc02016a4 <nr_free_pages>
ffffffffc020384e:	28a49b63          	bne	s1,a0,ffffffffc0203ae4 <vmm_init+0x5ca>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203852:	00002517          	auipc	a0,0x2
ffffffffc0203856:	3d650513          	addi	a0,a0,982 # ffffffffc0205c28 <etext+0x1980>
ffffffffc020385a:	861fc0ef          	jal	ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020385e:	e47fd0ef          	jal	ffffffffc02016a4 <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203862:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203864:	26a99063          	bne	s3,a0,ffffffffc0203ac4 <vmm_init+0x5aa>
}
ffffffffc0203868:	6406                	ld	s0,64(sp)
ffffffffc020386a:	60a6                	ld	ra,72(sp)
ffffffffc020386c:	74e2                	ld	s1,56(sp)
ffffffffc020386e:	7942                	ld	s2,48(sp)
ffffffffc0203870:	79a2                	ld	s3,40(sp)
ffffffffc0203872:	7a02                	ld	s4,32(sp)
ffffffffc0203874:	6ae2                	ld	s5,24(sp)
ffffffffc0203876:	6b42                	ld	s6,16(sp)
ffffffffc0203878:	6ba2                	ld	s7,8(sp)
ffffffffc020387a:	6c02                	ld	s8,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020387c:	00002517          	auipc	a0,0x2
ffffffffc0203880:	3cc50513          	addi	a0,a0,972 # ffffffffc0205c48 <etext+0x19a0>
}
ffffffffc0203884:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203886:	835fc06f          	j	ffffffffc02000ba <cprintf>
    assert(vma != NULL);
ffffffffc020388a:	00002697          	auipc	a3,0x2
ffffffffc020388e:	d9e68693          	addi	a3,a3,-610 # ffffffffc0205628 <etext+0x1380>
ffffffffc0203892:	00001617          	auipc	a2,0x1
ffffffffc0203896:	2ee60613          	addi	a2,a2,750 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc020389a:	11100593          	li	a1,273
ffffffffc020389e:	00002517          	auipc	a0,0x2
ffffffffc02038a2:	14a50513          	addi	a0,a0,330 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02038a6:	aa7fc0ef          	jal	ffffffffc020034c <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02038aa:	00002697          	auipc	a3,0x2
ffffffffc02038ae:	33668693          	addi	a3,a3,822 # ffffffffc0205be0 <etext+0x1938>
ffffffffc02038b2:	00001617          	auipc	a2,0x1
ffffffffc02038b6:	2ce60613          	addi	a2,a2,718 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02038ba:	10a00593          	li	a1,266
ffffffffc02038be:	00002517          	auipc	a0,0x2
ffffffffc02038c2:	12a50513          	addi	a0,a0,298 # ffffffffc02059e8 <etext+0x1740>
    check_mm_struct = mm_create();
ffffffffc02038c6:	0000e797          	auipc	a5,0xe
ffffffffc02038ca:	ca07b123          	sd	zero,-862(a5) # ffffffffc0211568 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc02038ce:	a7ffc0ef          	jal	ffffffffc020034c <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02038d2:	f62ff0ef          	jal	ffffffffc0203034 <swap_init_mm>
    assert(check_mm_struct != NULL);
ffffffffc02038d6:	bdbd                	j	ffffffffc0203754 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02038d8:	00002697          	auipc	a3,0x2
ffffffffc02038dc:	19868693          	addi	a3,a3,408 # ffffffffc0205a70 <etext+0x17c8>
ffffffffc02038e0:	00001617          	auipc	a2,0x1
ffffffffc02038e4:	2a060613          	addi	a2,a2,672 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02038e8:	0dd00593          	li	a1,221
ffffffffc02038ec:	00002517          	auipc	a0,0x2
ffffffffc02038f0:	0fc50513          	addi	a0,a0,252 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02038f4:	a59fc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02038f8:	00002697          	auipc	a3,0x2
ffffffffc02038fc:	20068693          	addi	a3,a3,512 # ffffffffc0205af8 <etext+0x1850>
ffffffffc0203900:	00001617          	auipc	a2,0x1
ffffffffc0203904:	28060613          	addi	a2,a2,640 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203908:	0ed00593          	li	a1,237
ffffffffc020390c:	00002517          	auipc	a0,0x2
ffffffffc0203910:	0dc50513          	addi	a0,a0,220 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203914:	a39fc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203918:	00002697          	auipc	a3,0x2
ffffffffc020391c:	21068693          	addi	a3,a3,528 # ffffffffc0205b28 <etext+0x1880>
ffffffffc0203920:	00001617          	auipc	a2,0x1
ffffffffc0203924:	26060613          	addi	a2,a2,608 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203928:	0ee00593          	li	a1,238
ffffffffc020392c:	00002517          	auipc	a0,0x2
ffffffffc0203930:	0bc50513          	addi	a0,a0,188 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203934:	a19fc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma4 == NULL);
ffffffffc0203938:	00002697          	auipc	a3,0x2
ffffffffc020393c:	1a068693          	addi	a3,a3,416 # ffffffffc0205ad8 <etext+0x1830>
ffffffffc0203940:	00001617          	auipc	a2,0x1
ffffffffc0203944:	24060613          	addi	a2,a2,576 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203948:	0e900593          	li	a1,233
ffffffffc020394c:	00002517          	auipc	a0,0x2
ffffffffc0203950:	09c50513          	addi	a0,a0,156 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203954:	9f9fc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma3 == NULL);
ffffffffc0203958:	00002697          	auipc	a3,0x2
ffffffffc020395c:	17068693          	addi	a3,a3,368 # ffffffffc0205ac8 <etext+0x1820>
ffffffffc0203960:	00001617          	auipc	a2,0x1
ffffffffc0203964:	22060613          	addi	a2,a2,544 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203968:	0e700593          	li	a1,231
ffffffffc020396c:	00002517          	auipc	a0,0x2
ffffffffc0203970:	07c50513          	addi	a0,a0,124 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203974:	9d9fc0ef          	jal	ffffffffc020034c <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203978:	00002697          	auipc	a3,0x2
ffffffffc020397c:	0e068693          	addi	a3,a3,224 # ffffffffc0205a58 <etext+0x17b0>
ffffffffc0203980:	00001617          	auipc	a2,0x1
ffffffffc0203984:	20060613          	addi	a2,a2,512 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203988:	0db00593          	li	a1,219
ffffffffc020398c:	00002517          	auipc	a0,0x2
ffffffffc0203990:	05c50513          	addi	a0,a0,92 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203994:	9b9fc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma2 != NULL);
ffffffffc0203998:	00002697          	auipc	a3,0x2
ffffffffc020399c:	12068693          	addi	a3,a3,288 # ffffffffc0205ab8 <etext+0x1810>
ffffffffc02039a0:	00001617          	auipc	a2,0x1
ffffffffc02039a4:	1e060613          	addi	a2,a2,480 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02039a8:	0e500593          	li	a1,229
ffffffffc02039ac:	00002517          	auipc	a0,0x2
ffffffffc02039b0:	03c50513          	addi	a0,a0,60 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02039b4:	999fc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma1 != NULL);
ffffffffc02039b8:	00002697          	auipc	a3,0x2
ffffffffc02039bc:	0f068693          	addi	a3,a3,240 # ffffffffc0205aa8 <etext+0x1800>
ffffffffc02039c0:	00001617          	auipc	a2,0x1
ffffffffc02039c4:	1c060613          	addi	a2,a2,448 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02039c8:	0e300593          	li	a1,227
ffffffffc02039cc:	00002517          	auipc	a0,0x2
ffffffffc02039d0:	01c50513          	addi	a0,a0,28 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02039d4:	979fc0ef          	jal	ffffffffc020034c <__panic>
        assert(vma5 == NULL);
ffffffffc02039d8:	00002697          	auipc	a3,0x2
ffffffffc02039dc:	11068693          	addi	a3,a3,272 # ffffffffc0205ae8 <etext+0x1840>
ffffffffc02039e0:	00001617          	auipc	a2,0x1
ffffffffc02039e4:	1a060613          	addi	a2,a2,416 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc02039e8:	0eb00593          	li	a1,235
ffffffffc02039ec:	00002517          	auipc	a0,0x2
ffffffffc02039f0:	ffc50513          	addi	a0,a0,-4 # ffffffffc02059e8 <etext+0x1740>
ffffffffc02039f4:	959fc0ef          	jal	ffffffffc020034c <__panic>
    assert(pgdir[0] == 0);
ffffffffc02039f8:	00002697          	auipc	a3,0x2
ffffffffc02039fc:	c2068693          	addi	a3,a3,-992 # ffffffffc0205618 <etext+0x1370>
ffffffffc0203a00:	00001617          	auipc	a2,0x1
ffffffffc0203a04:	18060613          	addi	a2,a2,384 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203a08:	10d00593          	li	a1,269
ffffffffc0203a0c:	00002517          	auipc	a0,0x2
ffffffffc0203a10:	fdc50513          	addi	a0,a0,-36 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203a14:	939fc0ef          	jal	ffffffffc020034c <__panic>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203a18:	6914                	ld	a3,16(a0)
ffffffffc0203a1a:	6510                	ld	a2,8(a0)
ffffffffc0203a1c:	0004859b          	sext.w	a1,s1
ffffffffc0203a20:	00002517          	auipc	a0,0x2
ffffffffc0203a24:	13850513          	addi	a0,a0,312 # ffffffffc0205b58 <etext+0x18b0>
ffffffffc0203a28:	e92fc0ef          	jal	ffffffffc02000ba <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203a2c:	00002697          	auipc	a3,0x2
ffffffffc0203a30:	15468693          	addi	a3,a3,340 # ffffffffc0205b80 <etext+0x18d8>
ffffffffc0203a34:	00001617          	auipc	a2,0x1
ffffffffc0203a38:	14c60613          	addi	a2,a2,332 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203a3c:	0f600593          	li	a1,246
ffffffffc0203a40:	00002517          	auipc	a0,0x2
ffffffffc0203a44:	fa850513          	addi	a0,a0,-88 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203a48:	905fc0ef          	jal	ffffffffc020034c <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a4c:	00002697          	auipc	a3,0x2
ffffffffc0203a50:	1ac68693          	addi	a3,a3,428 # ffffffffc0205bf8 <etext+0x1950>
ffffffffc0203a54:	00001617          	auipc	a2,0x1
ffffffffc0203a58:	12c60613          	addi	a2,a2,300 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203a5c:	11600593          	li	a1,278
ffffffffc0203a60:	00002517          	auipc	a0,0x2
ffffffffc0203a64:	f8850513          	addi	a0,a0,-120 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203a68:	8e5fc0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a6c:	00002697          	auipc	a3,0x2
ffffffffc0203a70:	12c68693          	addi	a3,a3,300 # ffffffffc0205b98 <etext+0x18f0>
ffffffffc0203a74:	00001617          	auipc	a2,0x1
ffffffffc0203a78:	10c60613          	addi	a2,a2,268 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203a7c:	0fb00593          	li	a1,251
ffffffffc0203a80:	00002517          	auipc	a0,0x2
ffffffffc0203a84:	f6850513          	addi	a0,a0,-152 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203a88:	8c5fc0ef          	jal	ffffffffc020034c <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203a8c:	00001617          	auipc	a2,0x1
ffffffffc0203a90:	4a460613          	addi	a2,a2,1188 # ffffffffc0204f30 <etext+0xc88>
ffffffffc0203a94:	06800593          	li	a1,104
ffffffffc0203a98:	00001517          	auipc	a0,0x1
ffffffffc0203a9c:	4b850513          	addi	a0,a0,1208 # ffffffffc0204f50 <etext+0xca8>
ffffffffc0203aa0:	8adfc0ef          	jal	ffffffffc020034c <__panic>
    assert(sum == 0);
ffffffffc0203aa4:	00002697          	auipc	a3,0x2
ffffffffc0203aa8:	17468693          	addi	a3,a3,372 # ffffffffc0205c18 <etext+0x1970>
ffffffffc0203aac:	00001617          	auipc	a2,0x1
ffffffffc0203ab0:	0d460613          	addi	a2,a2,212 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203ab4:	12000593          	li	a1,288
ffffffffc0203ab8:	00002517          	auipc	a0,0x2
ffffffffc0203abc:	f3050513          	addi	a0,a0,-208 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203ac0:	88dfc0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ac4:	00002697          	auipc	a3,0x2
ffffffffc0203ac8:	0d468693          	addi	a3,a3,212 # ffffffffc0205b98 <etext+0x18f0>
ffffffffc0203acc:	00001617          	auipc	a2,0x1
ffffffffc0203ad0:	0b460613          	addi	a2,a2,180 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203ad4:	0bd00593          	li	a1,189
ffffffffc0203ad8:	00002517          	auipc	a0,0x2
ffffffffc0203adc:	f1050513          	addi	a0,a0,-240 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203ae0:	86dfc0ef          	jal	ffffffffc020034c <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ae4:	00002697          	auipc	a3,0x2
ffffffffc0203ae8:	0b468693          	addi	a3,a3,180 # ffffffffc0205b98 <etext+0x18f0>
ffffffffc0203aec:	00001617          	auipc	a2,0x1
ffffffffc0203af0:	09460613          	addi	a2,a2,148 # ffffffffc0204b80 <etext+0x8d8>
ffffffffc0203af4:	12e00593          	li	a1,302
ffffffffc0203af8:	00002517          	auipc	a0,0x2
ffffffffc0203afc:	ef050513          	addi	a0,a0,-272 # ffffffffc02059e8 <etext+0x1740>
ffffffffc0203b00:	84dfc0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0203b04 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b04:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b06:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b08:	f022                	sd	s0,32(sp)
ffffffffc0203b0a:	ec26                	sd	s1,24(sp)
ffffffffc0203b0c:	f406                	sd	ra,40(sp)
ffffffffc0203b0e:	8432                	mv	s0,a2
ffffffffc0203b10:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b12:	8c3ff0ef          	jal	ffffffffc02033d4 <find_vma>

    pgfault_num++;
ffffffffc0203b16:	0000e797          	auipc	a5,0xe
ffffffffc0203b1a:	a4e7a783          	lw	a5,-1458(a5) # ffffffffc0211564 <pgfault_num>
ffffffffc0203b1e:	2785                	addiw	a5,a5,1
ffffffffc0203b20:	0000e717          	auipc	a4,0xe
ffffffffc0203b24:	a4f72223          	sw	a5,-1468(a4) # ffffffffc0211564 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b28:	c159                	beqz	a0,ffffffffc0203bae <do_pgfault+0xaa>
ffffffffc0203b2a:	651c                	ld	a5,8(a0)
ffffffffc0203b2c:	08f46163          	bltu	s0,a5,ffffffffc0203bae <do_pgfault+0xaa>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b30:	6d1c                	ld	a5,24(a0)
ffffffffc0203b32:	e84a                	sd	s2,16(sp)
        perm |= (PTE_R | PTE_W);
ffffffffc0203b34:	4959                	li	s2,22
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b36:	8b89                	andi	a5,a5,2
ffffffffc0203b38:	cbb1                	beqz	a5,ffffffffc0203b8c <do_pgfault+0x88>
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b3a:	77fd                	lui	a5,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b3c:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b3e:	8c7d                	and	s0,s0,a5
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b40:	85a2                	mv	a1,s0
ffffffffc0203b42:	4605                	li	a2,1
ffffffffc0203b44:	b9bfd0ef          	jal	ffffffffc02016de <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203b48:	610c                	ld	a1,0(a0)
ffffffffc0203b4a:	c1b9                	beqz	a1,ffffffffc0203b90 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203b4c:	0000e797          	auipc	a5,0xe
ffffffffc0203b50:	9f47a783          	lw	a5,-1548(a5) # ffffffffc0211540 <swap_init_ok>
ffffffffc0203b54:	c7b5                	beqz	a5,ffffffffc0203bc0 <do_pgfault+0xbc>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);  
ffffffffc0203b56:	0030                	addi	a2,sp,8
ffffffffc0203b58:	85a2                	mv	a1,s0
ffffffffc0203b5a:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203b5c:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);  
ffffffffc0203b5e:	df6ff0ef          	jal	ffffffffc0203154 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203b62:	65a2                	ld	a1,8(sp)
ffffffffc0203b64:	6c88                	ld	a0,24(s1)
ffffffffc0203b66:	86ca                	mv	a3,s2
ffffffffc0203b68:	8622                	mv	a2,s0
ffffffffc0203b6a:	e83fd0ef          	jal	ffffffffc02019ec <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203b6e:	6622                	ld	a2,8(sp)
ffffffffc0203b70:	8526                	mv	a0,s1
ffffffffc0203b72:	85a2                	mv	a1,s0
ffffffffc0203b74:	4685                	li	a3,1
ffffffffc0203b76:	ccaff0ef          	jal	ffffffffc0203040 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203b7a:	67a2                	ld	a5,8(sp)
ffffffffc0203b7c:	e3a0                	sd	s0,64(a5)
ffffffffc0203b7e:	6942                	ld	s2,16(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203b80:	4501                	li	a0,0
failed:
    return ret;
}
ffffffffc0203b82:	70a2                	ld	ra,40(sp)
ffffffffc0203b84:	7402                	ld	s0,32(sp)
ffffffffc0203b86:	64e2                	ld	s1,24(sp)
ffffffffc0203b88:	6145                	addi	sp,sp,48
ffffffffc0203b8a:	8082                	ret
    uint32_t perm = PTE_U;
ffffffffc0203b8c:	4941                	li	s2,16
ffffffffc0203b8e:	b775                	j	ffffffffc0203b3a <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203b90:	6c88                	ld	a0,24(s1)
ffffffffc0203b92:	864a                	mv	a2,s2
ffffffffc0203b94:	85a2                	mv	a1,s0
ffffffffc0203b96:	b85fe0ef          	jal	ffffffffc020271a <pgdir_alloc_page>
ffffffffc0203b9a:	f175                	bnez	a0,ffffffffc0203b7e <do_pgfault+0x7a>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203b9c:	00002517          	auipc	a0,0x2
ffffffffc0203ba0:	0f450513          	addi	a0,a0,244 # ffffffffc0205c90 <etext+0x19e8>
ffffffffc0203ba4:	d16fc0ef          	jal	ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ba8:	6942                	ld	s2,16(sp)
ffffffffc0203baa:	5571                	li	a0,-4
ffffffffc0203bac:	bfd9                	j	ffffffffc0203b82 <do_pgfault+0x7e>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203bae:	85a2                	mv	a1,s0
ffffffffc0203bb0:	00002517          	auipc	a0,0x2
ffffffffc0203bb4:	0b050513          	addi	a0,a0,176 # ffffffffc0205c60 <etext+0x19b8>
ffffffffc0203bb8:	d02fc0ef          	jal	ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203bbc:	5575                	li	a0,-3
        goto failed;
ffffffffc0203bbe:	b7d1                	j	ffffffffc0203b82 <do_pgfault+0x7e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203bc0:	00002517          	auipc	a0,0x2
ffffffffc0203bc4:	0f850513          	addi	a0,a0,248 # ffffffffc0205cb8 <etext+0x1a10>
ffffffffc0203bc8:	cf2fc0ef          	jal	ffffffffc02000ba <cprintf>
            goto failed;
ffffffffc0203bcc:	bff1                	j	ffffffffc0203ba8 <do_pgfault+0xa4>

ffffffffc0203bce <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203bce:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bd0:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203bd2:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203bd4:	89dfc0ef          	jal	ffffffffc0200470 <ide_device_valid>
ffffffffc0203bd8:	cd01                	beqz	a0,ffffffffc0203bf0 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203bda:	4505                	li	a0,1
ffffffffc0203bdc:	89bfc0ef          	jal	ffffffffc0200476 <ide_device_size>
}
ffffffffc0203be0:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203be2:	810d                	srli	a0,a0,0x3
ffffffffc0203be4:	0000e797          	auipc	a5,0xe
ffffffffc0203be8:	96a7b223          	sd	a0,-1692(a5) # ffffffffc0211548 <max_swap_offset>
}
ffffffffc0203bec:	0141                	addi	sp,sp,16
ffffffffc0203bee:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203bf0:	00002617          	auipc	a2,0x2
ffffffffc0203bf4:	0f060613          	addi	a2,a2,240 # ffffffffc0205ce0 <etext+0x1a38>
ffffffffc0203bf8:	45b5                	li	a1,13
ffffffffc0203bfa:	00002517          	auipc	a0,0x2
ffffffffc0203bfe:	10650513          	addi	a0,a0,262 # ffffffffc0205d00 <etext+0x1a58>
ffffffffc0203c02:	f4afc0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0203c06 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c06:	1141                	addi	sp,sp,-16
ffffffffc0203c08:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c0a:	00855713          	srli	a4,a0,0x8
ffffffffc0203c0e:	c735                	beqz	a4,ffffffffc0203c7a <swapfs_read+0x74>
ffffffffc0203c10:	0000e797          	auipc	a5,0xe
ffffffffc0203c14:	9387b783          	ld	a5,-1736(a5) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203c18:	06f77163          	bgeu	a4,a5,ffffffffc0203c7a <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c1c:	0000e617          	auipc	a2,0xe
ffffffffc0203c20:	91c63603          	ld	a2,-1764(a2) # ffffffffc0211538 <pages>
ffffffffc0203c24:	8e38e7b7          	lui	a5,0x8e38e
ffffffffc0203c28:	38e78793          	addi	a5,a5,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc0203c2c:	38e396b7          	lui	a3,0x38e39
ffffffffc0203c30:	e3968693          	addi	a3,a3,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0203c34:	40c58633          	sub	a2,a1,a2
ffffffffc0203c38:	1782                	slli	a5,a5,0x20
ffffffffc0203c3a:	97b6                	add	a5,a5,a3
ffffffffc0203c3c:	860d                	srai	a2,a2,0x3
ffffffffc0203c3e:	02f60633          	mul	a2,a2,a5
ffffffffc0203c42:	00002797          	auipc	a5,0x2
ffffffffc0203c46:	42e7b783          	ld	a5,1070(a5) # ffffffffc0206070 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c4a:	0000e697          	auipc	a3,0xe
ffffffffc0203c4e:	8e66b683          	ld	a3,-1818(a3) # ffffffffc0211530 <npage>
ffffffffc0203c52:	0037159b          	slliw	a1,a4,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c56:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c58:	00c61793          	slli	a5,a2,0xc
ffffffffc0203c5c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203c5e:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203c60:	02d7f963          	bgeu	a5,a3,ffffffffc0203c92 <swapfs_read+0x8c>
ffffffffc0203c64:	0000e797          	auipc	a5,0xe
ffffffffc0203c68:	8c47b783          	ld	a5,-1852(a5) # ffffffffc0211528 <va_pa_offset>
}
ffffffffc0203c6c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c6e:	46a1                	li	a3,8
ffffffffc0203c70:	963e                	add	a2,a2,a5
ffffffffc0203c72:	4505                	li	a0,1
}
ffffffffc0203c74:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c76:	807fc06f          	j	ffffffffc020047c <ide_read_secs>
ffffffffc0203c7a:	86aa                	mv	a3,a0
ffffffffc0203c7c:	00002617          	auipc	a2,0x2
ffffffffc0203c80:	09c60613          	addi	a2,a2,156 # ffffffffc0205d18 <etext+0x1a70>
ffffffffc0203c84:	45d1                	li	a1,20
ffffffffc0203c86:	00002517          	auipc	a0,0x2
ffffffffc0203c8a:	07a50513          	addi	a0,a0,122 # ffffffffc0205d00 <etext+0x1a58>
ffffffffc0203c8e:	ebefc0ef          	jal	ffffffffc020034c <__panic>
ffffffffc0203c92:	86b2                	mv	a3,a2
ffffffffc0203c94:	06d00593          	li	a1,109
ffffffffc0203c98:	00001617          	auipc	a2,0x1
ffffffffc0203c9c:	2c860613          	addi	a2,a2,712 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc0203ca0:	00001517          	auipc	a0,0x1
ffffffffc0203ca4:	2b050513          	addi	a0,a0,688 # ffffffffc0204f50 <etext+0xca8>
ffffffffc0203ca8:	ea4fc0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0203cac <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203cac:	1141                	addi	sp,sp,-16
ffffffffc0203cae:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cb0:	00855713          	srli	a4,a0,0x8
ffffffffc0203cb4:	c735                	beqz	a4,ffffffffc0203d20 <swapfs_write+0x74>
ffffffffc0203cb6:	0000e797          	auipc	a5,0xe
ffffffffc0203cba:	8927b783          	ld	a5,-1902(a5) # ffffffffc0211548 <max_swap_offset>
ffffffffc0203cbe:	06f77163          	bgeu	a4,a5,ffffffffc0203d20 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cc2:	0000e617          	auipc	a2,0xe
ffffffffc0203cc6:	87663603          	ld	a2,-1930(a2) # ffffffffc0211538 <pages>
ffffffffc0203cca:	8e38e7b7          	lui	a5,0x8e38e
ffffffffc0203cce:	38e78793          	addi	a5,a5,910 # ffffffff8e38e38e <kern_entry-0x31e71c72>
ffffffffc0203cd2:	38e396b7          	lui	a3,0x38e39
ffffffffc0203cd6:	e3968693          	addi	a3,a3,-455 # 38e38e39 <kern_entry-0xffffffff873c71c7>
ffffffffc0203cda:	40c58633          	sub	a2,a1,a2
ffffffffc0203cde:	1782                	slli	a5,a5,0x20
ffffffffc0203ce0:	97b6                	add	a5,a5,a3
ffffffffc0203ce2:	860d                	srai	a2,a2,0x3
ffffffffc0203ce4:	02f60633          	mul	a2,a2,a5
ffffffffc0203ce8:	00002797          	auipc	a5,0x2
ffffffffc0203cec:	3887b783          	ld	a5,904(a5) # ffffffffc0206070 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cf0:	0000e697          	auipc	a3,0xe
ffffffffc0203cf4:	8406b683          	ld	a3,-1984(a3) # ffffffffc0211530 <npage>
ffffffffc0203cf8:	0037159b          	slliw	a1,a4,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cfc:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cfe:	00c61793          	slli	a5,a2,0xc
ffffffffc0203d02:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d04:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d06:	02d7f963          	bgeu	a5,a3,ffffffffc0203d38 <swapfs_write+0x8c>
ffffffffc0203d0a:	0000e797          	auipc	a5,0xe
ffffffffc0203d0e:	81e7b783          	ld	a5,-2018(a5) # ffffffffc0211528 <va_pa_offset>
}
ffffffffc0203d12:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d14:	46a1                	li	a3,8
ffffffffc0203d16:	963e                	add	a2,a2,a5
ffffffffc0203d18:	4505                	li	a0,1
}
ffffffffc0203d1a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d1c:	f84fc06f          	j	ffffffffc02004a0 <ide_write_secs>
ffffffffc0203d20:	86aa                	mv	a3,a0
ffffffffc0203d22:	00002617          	auipc	a2,0x2
ffffffffc0203d26:	ff660613          	addi	a2,a2,-10 # ffffffffc0205d18 <etext+0x1a70>
ffffffffc0203d2a:	45e5                	li	a1,25
ffffffffc0203d2c:	00002517          	auipc	a0,0x2
ffffffffc0203d30:	fd450513          	addi	a0,a0,-44 # ffffffffc0205d00 <etext+0x1a58>
ffffffffc0203d34:	e18fc0ef          	jal	ffffffffc020034c <__panic>
ffffffffc0203d38:	86b2                	mv	a3,a2
ffffffffc0203d3a:	06d00593          	li	a1,109
ffffffffc0203d3e:	00001617          	auipc	a2,0x1
ffffffffc0203d42:	22260613          	addi	a2,a2,546 # ffffffffc0204f60 <etext+0xcb8>
ffffffffc0203d46:	00001517          	auipc	a0,0x1
ffffffffc0203d4a:	20a50513          	addi	a0,a0,522 # ffffffffc0204f50 <etext+0xca8>
ffffffffc0203d4e:	dfefc0ef          	jal	ffffffffc020034c <__panic>

ffffffffc0203d52 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203d52:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203d56:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203d58:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203d5c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203d5e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203d62:	f022                	sd	s0,32(sp)
ffffffffc0203d64:	ec26                	sd	s1,24(sp)
ffffffffc0203d66:	e84a                	sd	s2,16(sp)
ffffffffc0203d68:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203d6a:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203d6e:	84aa                	mv	s1,a0
ffffffffc0203d70:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
ffffffffc0203d72:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203d74:	05067063          	bgeu	a2,a6,ffffffffc0203db4 <printnum+0x62>
ffffffffc0203d78:	e44e                	sd	s3,8(sp)
ffffffffc0203d7a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203d7c:	4785                	li	a5,1
ffffffffc0203d7e:	00e7d763          	bge	a5,a4,ffffffffc0203d8c <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0203d82:	85ca                	mv	a1,s2
ffffffffc0203d84:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0203d86:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203d88:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203d8a:	fc65                	bnez	s0,ffffffffc0203d82 <printnum+0x30>
ffffffffc0203d8c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203d8e:	1a02                	slli	s4,s4,0x20
ffffffffc0203d90:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203d94:	00002797          	auipc	a5,0x2
ffffffffc0203d98:	fa478793          	addi	a5,a5,-92 # ffffffffc0205d38 <etext+0x1a90>
ffffffffc0203d9c:	97d2                	add	a5,a5,s4
}
ffffffffc0203d9e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203da0:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0203da4:	70a2                	ld	ra,40(sp)
ffffffffc0203da6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203da8:	85ca                	mv	a1,s2
ffffffffc0203daa:	87a6                	mv	a5,s1
}
ffffffffc0203dac:	6942                	ld	s2,16(sp)
ffffffffc0203dae:	64e2                	ld	s1,24(sp)
ffffffffc0203db0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203db2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203db4:	03065633          	divu	a2,a2,a6
ffffffffc0203db8:	8722                	mv	a4,s0
ffffffffc0203dba:	f99ff0ef          	jal	ffffffffc0203d52 <printnum>
ffffffffc0203dbe:	bfc1                	j	ffffffffc0203d8e <printnum+0x3c>

ffffffffc0203dc0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203dc0:	7119                	addi	sp,sp,-128
ffffffffc0203dc2:	f4a6                	sd	s1,104(sp)
ffffffffc0203dc4:	f0ca                	sd	s2,96(sp)
ffffffffc0203dc6:	ecce                	sd	s3,88(sp)
ffffffffc0203dc8:	e8d2                	sd	s4,80(sp)
ffffffffc0203dca:	e4d6                	sd	s5,72(sp)
ffffffffc0203dcc:	e0da                	sd	s6,64(sp)
ffffffffc0203dce:	f862                	sd	s8,48(sp)
ffffffffc0203dd0:	fc86                	sd	ra,120(sp)
ffffffffc0203dd2:	f8a2                	sd	s0,112(sp)
ffffffffc0203dd4:	fc5e                	sd	s7,56(sp)
ffffffffc0203dd6:	f466                	sd	s9,40(sp)
ffffffffc0203dd8:	f06a                	sd	s10,32(sp)
ffffffffc0203dda:	ec6e                	sd	s11,24(sp)
ffffffffc0203ddc:	892a                	mv	s2,a0
ffffffffc0203dde:	84ae                	mv	s1,a1
ffffffffc0203de0:	8c32                	mv	s8,a2
ffffffffc0203de2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203de4:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203de8:	05500b13          	li	s6,85
ffffffffc0203dec:	00002a97          	auipc	s5,0x2
ffffffffc0203df0:	0f4a8a93          	addi	s5,s5,244 # ffffffffc0205ee0 <default_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203df4:	000c4503          	lbu	a0,0(s8)
ffffffffc0203df8:	001c0413          	addi	s0,s8,1
ffffffffc0203dfc:	01350a63          	beq	a0,s3,ffffffffc0203e10 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0203e00:	cd0d                	beqz	a0,ffffffffc0203e3a <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0203e02:	85a6                	mv	a1,s1
ffffffffc0203e04:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e06:	00044503          	lbu	a0,0(s0)
ffffffffc0203e0a:	0405                	addi	s0,s0,1
ffffffffc0203e0c:	ff351ae3          	bne	a0,s3,ffffffffc0203e00 <vprintfmt+0x40>
        width = precision = -1;
ffffffffc0203e10:	5cfd                	li	s9,-1
ffffffffc0203e12:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0203e14:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0203e18:	4b81                	li	s7,0
ffffffffc0203e1a:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e1c:	00044683          	lbu	a3,0(s0)
ffffffffc0203e20:	00140c13          	addi	s8,s0,1
ffffffffc0203e24:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0203e28:	0ff5f593          	zext.b	a1,a1
ffffffffc0203e2c:	02bb6663          	bltu	s6,a1,ffffffffc0203e58 <vprintfmt+0x98>
ffffffffc0203e30:	058a                	slli	a1,a1,0x2
ffffffffc0203e32:	95d6                	add	a1,a1,s5
ffffffffc0203e34:	4198                	lw	a4,0(a1)
ffffffffc0203e36:	9756                	add	a4,a4,s5
ffffffffc0203e38:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203e3a:	70e6                	ld	ra,120(sp)
ffffffffc0203e3c:	7446                	ld	s0,112(sp)
ffffffffc0203e3e:	74a6                	ld	s1,104(sp)
ffffffffc0203e40:	7906                	ld	s2,96(sp)
ffffffffc0203e42:	69e6                	ld	s3,88(sp)
ffffffffc0203e44:	6a46                	ld	s4,80(sp)
ffffffffc0203e46:	6aa6                	ld	s5,72(sp)
ffffffffc0203e48:	6b06                	ld	s6,64(sp)
ffffffffc0203e4a:	7be2                	ld	s7,56(sp)
ffffffffc0203e4c:	7c42                	ld	s8,48(sp)
ffffffffc0203e4e:	7ca2                	ld	s9,40(sp)
ffffffffc0203e50:	7d02                	ld	s10,32(sp)
ffffffffc0203e52:	6de2                	ld	s11,24(sp)
ffffffffc0203e54:	6109                	addi	sp,sp,128
ffffffffc0203e56:	8082                	ret
            putch('%', putdat);
ffffffffc0203e58:	85a6                	mv	a1,s1
ffffffffc0203e5a:	02500513          	li	a0,37
ffffffffc0203e5e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203e60:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203e64:	02500713          	li	a4,37
ffffffffc0203e68:	8c22                	mv	s8,s0
ffffffffc0203e6a:	f8e785e3          	beq	a5,a4,ffffffffc0203df4 <vprintfmt+0x34>
ffffffffc0203e6e:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0203e72:	1c7d                	addi	s8,s8,-1
ffffffffc0203e74:	fee79de3          	bne	a5,a4,ffffffffc0203e6e <vprintfmt+0xae>
ffffffffc0203e78:	bfb5                	j	ffffffffc0203df4 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0203e7a:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0203e7e:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc0203e80:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0203e84:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e88:	8462                	mv	s0,s8
                ch = *fmt;
ffffffffc0203e8a:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
ffffffffc0203e8c:	02e56463          	bltu	a0,a4,ffffffffc0203eb4 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
ffffffffc0203e90:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc0203e94:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203e98:	0197073b          	addw	a4,a4,s9
ffffffffc0203e9c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203ea0:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
ffffffffc0203ea2:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203ea6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203ea8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203eac:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
ffffffffc0203eb0:	feb570e3          	bgeu	a0,a1,ffffffffc0203e90 <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0203eb4:	f60d54e3          	bgez	s10,ffffffffc0203e1c <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0203eb8:	8d66                	mv	s10,s9
ffffffffc0203eba:	5cfd                	li	s9,-1
ffffffffc0203ebc:	b785                	j	ffffffffc0203e1c <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ebe:	8db6                	mv	s11,a3
ffffffffc0203ec0:	8462                	mv	s0,s8
ffffffffc0203ec2:	bfa9                	j	ffffffffc0203e1c <vprintfmt+0x5c>
ffffffffc0203ec4:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0203ec6:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0203ec8:	bf91                	j	ffffffffc0203e1c <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0203eca:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0203ecc:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0203ed0:	00c7c463          	blt	a5,a2,ffffffffc0203ed8 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0203ed4:	18060763          	beqz	a2,ffffffffc0204062 <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
ffffffffc0203ed8:	000a3603          	ld	a2,0(s4)
ffffffffc0203edc:	46c1                	li	a3,16
ffffffffc0203ede:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203ee0:	000d879b          	sext.w	a5,s11
ffffffffc0203ee4:	876a                	mv	a4,s10
ffffffffc0203ee6:	85a6                	mv	a1,s1
ffffffffc0203ee8:	854a                	mv	a0,s2
ffffffffc0203eea:	e69ff0ef          	jal	ffffffffc0203d52 <printnum>
            break;
ffffffffc0203eee:	b719                	j	ffffffffc0203df4 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ef0:	000a2503          	lw	a0,0(s4)
ffffffffc0203ef4:	85a6                	mv	a1,s1
ffffffffc0203ef6:	0a21                	addi	s4,s4,8
ffffffffc0203ef8:	9902                	jalr	s2
            break;
ffffffffc0203efa:	bded                	j	ffffffffc0203df4 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0203efc:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0203efe:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0203f02:	00c7c463          	blt	a5,a2,ffffffffc0203f0a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f06:	14060963          	beqz	a2,ffffffffc0204058 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
ffffffffc0203f0a:	000a3603          	ld	a2,0(s4)
ffffffffc0203f0e:	46a9                	li	a3,10
ffffffffc0203f10:	8a3a                	mv	s4,a4
ffffffffc0203f12:	b7f9                	j	ffffffffc0203ee0 <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0203f14:	85a6                	mv	a1,s1
ffffffffc0203f16:	03000513          	li	a0,48
ffffffffc0203f1a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203f1c:	85a6                	mv	a1,s1
ffffffffc0203f1e:	07800513          	li	a0,120
ffffffffc0203f22:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203f24:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0203f28:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203f2a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203f2c:	bf55                	j	ffffffffc0203ee0 <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0203f2e:	85a6                	mv	a1,s1
ffffffffc0203f30:	02500513          	li	a0,37
ffffffffc0203f34:	9902                	jalr	s2
            break;
ffffffffc0203f36:	bd7d                	j	ffffffffc0203df4 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0203f38:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f3c:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0203f3e:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0203f40:	bf95                	j	ffffffffc0203eb4 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0203f42:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0203f44:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0203f48:	00c7c463          	blt	a5,a2,ffffffffc0203f50 <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0203f4c:	10060163          	beqz	a2,ffffffffc020404e <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
ffffffffc0203f50:	000a3603          	ld	a2,0(s4)
ffffffffc0203f54:	46a1                	li	a3,8
ffffffffc0203f56:	8a3a                	mv	s4,a4
ffffffffc0203f58:	b761                	j	ffffffffc0203ee0 <vprintfmt+0x120>
            if (width < 0)
ffffffffc0203f5a:	87ea                	mv	a5,s10
ffffffffc0203f5c:	000d5363          	bgez	s10,ffffffffc0203f62 <vprintfmt+0x1a2>
ffffffffc0203f60:	4781                	li	a5,0
ffffffffc0203f62:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f66:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0203f68:	bd55                	j	ffffffffc0203e1c <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203f6a:	000a3703          	ld	a4,0(s4)
ffffffffc0203f6e:	12070b63          	beqz	a4,ffffffffc02040a4 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
ffffffffc0203f72:	0da05563          	blez	s10,ffffffffc020403c <vprintfmt+0x27c>
ffffffffc0203f76:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f7a:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
ffffffffc0203f7e:	14fd9a63          	bne	s11,a5,ffffffffc02040d2 <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203f82:	00074783          	lbu	a5,0(a4)
ffffffffc0203f86:	0007851b          	sext.w	a0,a5
ffffffffc0203f8a:	c785                	beqz	a5,ffffffffc0203fb2 <vprintfmt+0x1f2>
ffffffffc0203f8c:	5dfd                	li	s11,-1
ffffffffc0203f8e:	000cc563          	bltz	s9,ffffffffc0203f98 <vprintfmt+0x1d8>
ffffffffc0203f92:	3cfd                	addiw	s9,s9,-1
ffffffffc0203f94:	01bc8d63          	beq	s9,s11,ffffffffc0203fae <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203f98:	0c0b9a63          	bnez	s7,ffffffffc020406c <vprintfmt+0x2ac>
                    putch(ch, putdat);
ffffffffc0203f9c:	85a6                	mv	a1,s1
ffffffffc0203f9e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fa0:	00044783          	lbu	a5,0(s0)
ffffffffc0203fa4:	0405                	addi	s0,s0,1
ffffffffc0203fa6:	3d7d                	addiw	s10,s10,-1
ffffffffc0203fa8:	0007851b          	sext.w	a0,a5
ffffffffc0203fac:	f3ed                	bnez	a5,ffffffffc0203f8e <vprintfmt+0x1ce>
            for (; width > 0; width --) {
ffffffffc0203fae:	01a05963          	blez	s10,ffffffffc0203fc0 <vprintfmt+0x200>
                putch(' ', putdat);
ffffffffc0203fb2:	85a6                	mv	a1,s1
ffffffffc0203fb4:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0203fb8:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0203fba:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203fbc:	fe0d1be3          	bnez	s10,ffffffffc0203fb2 <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203fc0:	0a21                	addi	s4,s4,8
ffffffffc0203fc2:	bd0d                	j	ffffffffc0203df4 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0203fc4:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0203fc6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0203fca:	00c7c363          	blt	a5,a2,ffffffffc0203fd0 <vprintfmt+0x210>
    else if (lflag) {
ffffffffc0203fce:	c625                	beqz	a2,ffffffffc0204036 <vprintfmt+0x276>
        return va_arg(*ap, long);
ffffffffc0203fd0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203fd4:	0a044f63          	bltz	s0,ffffffffc0204092 <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
ffffffffc0203fd8:	8622                	mv	a2,s0
ffffffffc0203fda:	8a5e                	mv	s4,s7
ffffffffc0203fdc:	46a9                	li	a3,10
ffffffffc0203fde:	b709                	j	ffffffffc0203ee0 <vprintfmt+0x120>
            if (err < 0) {
ffffffffc0203fe0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fe4:	4619                	li	a2,6
            if (err < 0) {
ffffffffc0203fe6:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0203fea:	8fb9                	xor	a5,a5,a4
ffffffffc0203fec:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203ff0:	02d64663          	blt	a2,a3,ffffffffc020401c <vprintfmt+0x25c>
ffffffffc0203ff4:	00002797          	auipc	a5,0x2
ffffffffc0203ff8:	04478793          	addi	a5,a5,68 # ffffffffc0206038 <error_string>
ffffffffc0203ffc:	00369713          	slli	a4,a3,0x3
ffffffffc0204000:	97ba                	add	a5,a5,a4
ffffffffc0204002:	639c                	ld	a5,0(a5)
ffffffffc0204004:	cf81                	beqz	a5,ffffffffc020401c <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204006:	86be                	mv	a3,a5
ffffffffc0204008:	00002617          	auipc	a2,0x2
ffffffffc020400c:	d6060613          	addi	a2,a2,-672 # ffffffffc0205d68 <etext+0x1ac0>
ffffffffc0204010:	85a6                	mv	a1,s1
ffffffffc0204012:	854a                	mv	a0,s2
ffffffffc0204014:	0f4000ef          	jal	ffffffffc0204108 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204018:	0a21                	addi	s4,s4,8
ffffffffc020401a:	bbe9                	j	ffffffffc0203df4 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020401c:	00002617          	auipc	a2,0x2
ffffffffc0204020:	d3c60613          	addi	a2,a2,-708 # ffffffffc0205d58 <etext+0x1ab0>
ffffffffc0204024:	85a6                	mv	a1,s1
ffffffffc0204026:	854a                	mv	a0,s2
ffffffffc0204028:	0e0000ef          	jal	ffffffffc0204108 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020402c:	0a21                	addi	s4,s4,8
ffffffffc020402e:	b3d9                	j	ffffffffc0203df4 <vprintfmt+0x34>
            lflag ++;
ffffffffc0204030:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204032:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0204034:	b3e5                	j	ffffffffc0203e1c <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0204036:	000a2403          	lw	s0,0(s4)
ffffffffc020403a:	bf69                	j	ffffffffc0203fd4 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020403c:	00074783          	lbu	a5,0(a4)
ffffffffc0204040:	0007851b          	sext.w	a0,a5
ffffffffc0204044:	dfb5                	beqz	a5,ffffffffc0203fc0 <vprintfmt+0x200>
ffffffffc0204046:	00170413          	addi	s0,a4,1
ffffffffc020404a:	5dfd                	li	s11,-1
ffffffffc020404c:	b789                	j	ffffffffc0203f8e <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
ffffffffc020404e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204052:	46a1                	li	a3,8
ffffffffc0204054:	8a3a                	mv	s4,a4
ffffffffc0204056:	b569                	j	ffffffffc0203ee0 <vprintfmt+0x120>
ffffffffc0204058:	000a6603          	lwu	a2,0(s4)
ffffffffc020405c:	46a9                	li	a3,10
ffffffffc020405e:	8a3a                	mv	s4,a4
ffffffffc0204060:	b541                	j	ffffffffc0203ee0 <vprintfmt+0x120>
ffffffffc0204062:	000a6603          	lwu	a2,0(s4)
ffffffffc0204066:	46c1                	li	a3,16
ffffffffc0204068:	8a3a                	mv	s4,a4
ffffffffc020406a:	bd9d                	j	ffffffffc0203ee0 <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020406c:	3781                	addiw	a5,a5,-32
ffffffffc020406e:	05e00713          	li	a4,94
ffffffffc0204072:	f2f775e3          	bgeu	a4,a5,ffffffffc0203f9c <vprintfmt+0x1dc>
                    putch('?', putdat);
ffffffffc0204076:	03f00513          	li	a0,63
ffffffffc020407a:	85a6                	mv	a1,s1
ffffffffc020407c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020407e:	00044783          	lbu	a5,0(s0)
ffffffffc0204082:	0405                	addi	s0,s0,1
ffffffffc0204084:	3d7d                	addiw	s10,s10,-1
ffffffffc0204086:	0007851b          	sext.w	a0,a5
ffffffffc020408a:	d395                	beqz	a5,ffffffffc0203fae <vprintfmt+0x1ee>
ffffffffc020408c:	f00cd3e3          	bgez	s9,ffffffffc0203f92 <vprintfmt+0x1d2>
ffffffffc0204090:	bff1                	j	ffffffffc020406c <vprintfmt+0x2ac>
                putch('-', putdat);
ffffffffc0204092:	85a6                	mv	a1,s1
ffffffffc0204094:	02d00513          	li	a0,45
ffffffffc0204098:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020409a:	40800633          	neg	a2,s0
ffffffffc020409e:	8a5e                	mv	s4,s7
ffffffffc02040a0:	46a9                	li	a3,10
ffffffffc02040a2:	bd3d                	j	ffffffffc0203ee0 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc02040a4:	01a05663          	blez	s10,ffffffffc02040b0 <vprintfmt+0x2f0>
ffffffffc02040a8:	02d00793          	li	a5,45
ffffffffc02040ac:	00fd9b63          	bne	s11,a5,ffffffffc02040c2 <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02040b0:	02800793          	li	a5,40
ffffffffc02040b4:	853e                	mv	a0,a5
ffffffffc02040b6:	00002417          	auipc	s0,0x2
ffffffffc02040ba:	c9b40413          	addi	s0,s0,-869 # ffffffffc0205d51 <etext+0x1aa9>
ffffffffc02040be:	5dfd                	li	s11,-1
ffffffffc02040c0:	b5f9                	j	ffffffffc0203f8e <vprintfmt+0x1ce>
ffffffffc02040c2:	00002417          	auipc	s0,0x2
ffffffffc02040c6:	c8f40413          	addi	s0,s0,-881 # ffffffffc0205d51 <etext+0x1aa9>
                p = "(null)";
ffffffffc02040ca:	00002717          	auipc	a4,0x2
ffffffffc02040ce:	c8670713          	addi	a4,a4,-890 # ffffffffc0205d50 <etext+0x1aa8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040d2:	853a                	mv	a0,a4
ffffffffc02040d4:	85e6                	mv	a1,s9
ffffffffc02040d6:	e43a                	sd	a4,8(sp)
ffffffffc02040d8:	12e000ef          	jal	ffffffffc0204206 <strnlen>
ffffffffc02040dc:	40ad0d3b          	subw	s10,s10,a0
ffffffffc02040e0:	6722                	ld	a4,8(sp)
ffffffffc02040e2:	01a05b63          	blez	s10,ffffffffc02040f8 <vprintfmt+0x338>
                    putch(padc, putdat);
ffffffffc02040e6:	2d81                	sext.w	s11,s11
ffffffffc02040e8:	85a6                	mv	a1,s1
ffffffffc02040ea:	856e                	mv	a0,s11
ffffffffc02040ec:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040ee:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc02040f0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040f2:	6722                	ld	a4,8(sp)
ffffffffc02040f4:	fe0d1ae3          	bnez	s10,ffffffffc02040e8 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02040f8:	00074783          	lbu	a5,0(a4)
ffffffffc02040fc:	0007851b          	sext.w	a0,a5
ffffffffc0204100:	ec0780e3          	beqz	a5,ffffffffc0203fc0 <vprintfmt+0x200>
ffffffffc0204104:	5dfd                	li	s11,-1
ffffffffc0204106:	b561                	j	ffffffffc0203f8e <vprintfmt+0x1ce>

ffffffffc0204108 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204108:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020410a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020410e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204110:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204112:	ec06                	sd	ra,24(sp)
ffffffffc0204114:	f83a                	sd	a4,48(sp)
ffffffffc0204116:	fc3e                	sd	a5,56(sp)
ffffffffc0204118:	e0c2                	sd	a6,64(sp)
ffffffffc020411a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020411c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020411e:	ca3ff0ef          	jal	ffffffffc0203dc0 <vprintfmt>
}
ffffffffc0204122:	60e2                	ld	ra,24(sp)
ffffffffc0204124:	6161                	addi	sp,sp,80
ffffffffc0204126:	8082                	ret

ffffffffc0204128 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204128:	715d                	addi	sp,sp,-80
ffffffffc020412a:	e486                	sd	ra,72(sp)
ffffffffc020412c:	e0a2                	sd	s0,64(sp)
ffffffffc020412e:	fc26                	sd	s1,56(sp)
ffffffffc0204130:	f84a                	sd	s2,48(sp)
ffffffffc0204132:	f44e                	sd	s3,40(sp)
ffffffffc0204134:	f052                	sd	s4,32(sp)
ffffffffc0204136:	ec56                	sd	s5,24(sp)
ffffffffc0204138:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc020413a:	c901                	beqz	a0,ffffffffc020414a <readline+0x22>
ffffffffc020413c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020413e:	00002517          	auipc	a0,0x2
ffffffffc0204142:	c2a50513          	addi	a0,a0,-982 # ffffffffc0205d68 <etext+0x1ac0>
ffffffffc0204146:	f75fb0ef          	jal	ffffffffc02000ba <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc020414a:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020414c:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc020414e:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204150:	4a29                	li	s4,10
ffffffffc0204152:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc0204154:	0000db17          	auipc	s6,0xd
ffffffffc0204158:	fa4b0b13          	addi	s6,s6,-92 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020415c:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc0204160:	f91fb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc0204164:	02054363          	bltz	a0,ffffffffc020418a <readline+0x62>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204168:	02a4d363          	bge	s1,a0,ffffffffc020418e <readline+0x66>
ffffffffc020416c:	fe89cae3          	blt	s3,s0,ffffffffc0204160 <readline+0x38>
            cputchar(c);
ffffffffc0204170:	e42a                	sd	a0,8(sp)
ffffffffc0204172:	f7dfb0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i ++] = c;
ffffffffc0204176:	6522                	ld	a0,8(sp)
ffffffffc0204178:	008b07b3          	add	a5,s6,s0
ffffffffc020417c:	2405                	addiw	s0,s0,1
ffffffffc020417e:	00a78023          	sb	a0,0(a5)
        c = getchar();
ffffffffc0204182:	f6ffb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc0204186:	fe0551e3          	bgez	a0,ffffffffc0204168 <readline+0x40>
            return NULL;
ffffffffc020418a:	4501                	li	a0,0
ffffffffc020418c:	a089                	j	ffffffffc02041ce <readline+0xa6>
        else if (c == '\b' && i > 0) {
ffffffffc020418e:	03251363          	bne	a0,s2,ffffffffc02041b4 <readline+0x8c>
ffffffffc0204192:	e821                	bnez	s0,ffffffffc02041e2 <readline+0xba>
        c = getchar();
ffffffffc0204194:	f5dfb0ef          	jal	ffffffffc02000f0 <getchar>
        if (c < 0) {
ffffffffc0204198:	fe0549e3          	bltz	a0,ffffffffc020418a <readline+0x62>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020419c:	fea4d9e3          	bge	s1,a0,ffffffffc020418e <readline+0x66>
            cputchar(c);
ffffffffc02041a0:	e42a                	sd	a0,8(sp)
ffffffffc02041a2:	f4dfb0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i ++] = c;
ffffffffc02041a6:	6522                	ld	a0,8(sp)
ffffffffc02041a8:	008b07b3          	add	a5,s6,s0
ffffffffc02041ac:	2405                	addiw	s0,s0,1
ffffffffc02041ae:	00a78023          	sb	a0,0(a5)
ffffffffc02041b2:	bfc1                	j	ffffffffc0204182 <readline+0x5a>
        else if (c == '\n' || c == '\r') {
ffffffffc02041b4:	01450463          	beq	a0,s4,ffffffffc02041bc <readline+0x94>
ffffffffc02041b8:	fb5514e3          	bne	a0,s5,ffffffffc0204160 <readline+0x38>
            cputchar(c);
ffffffffc02041bc:	f33fb0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i] = '\0';
ffffffffc02041c0:	0000d517          	auipc	a0,0xd
ffffffffc02041c4:	f3850513          	addi	a0,a0,-200 # ffffffffc02110f8 <buf>
ffffffffc02041c8:	942a                	add	s0,s0,a0
ffffffffc02041ca:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc02041ce:	60a6                	ld	ra,72(sp)
ffffffffc02041d0:	6406                	ld	s0,64(sp)
ffffffffc02041d2:	74e2                	ld	s1,56(sp)
ffffffffc02041d4:	7942                	ld	s2,48(sp)
ffffffffc02041d6:	79a2                	ld	s3,40(sp)
ffffffffc02041d8:	7a02                	ld	s4,32(sp)
ffffffffc02041da:	6ae2                	ld	s5,24(sp)
ffffffffc02041dc:	6b42                	ld	s6,16(sp)
ffffffffc02041de:	6161                	addi	sp,sp,80
ffffffffc02041e0:	8082                	ret
            cputchar(c);
ffffffffc02041e2:	854a                	mv	a0,s2
ffffffffc02041e4:	f0bfb0ef          	jal	ffffffffc02000ee <cputchar>
            i --;
ffffffffc02041e8:	347d                	addiw	s0,s0,-1
ffffffffc02041ea:	bf9d                	j	ffffffffc0204160 <readline+0x38>

ffffffffc02041ec <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02041ec:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02041f0:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02041f2:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02041f4:	cb81                	beqz	a5,ffffffffc0204204 <strlen+0x18>
        cnt ++;
ffffffffc02041f6:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02041f8:	00a707b3          	add	a5,a4,a0
ffffffffc02041fc:	0007c783          	lbu	a5,0(a5)
ffffffffc0204200:	fbfd                	bnez	a5,ffffffffc02041f6 <strlen+0xa>
ffffffffc0204202:	8082                	ret
    }
    return cnt;
}
ffffffffc0204204:	8082                	ret

ffffffffc0204206 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204206:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204208:	e589                	bnez	a1,ffffffffc0204212 <strnlen+0xc>
ffffffffc020420a:	a811                	j	ffffffffc020421e <strnlen+0x18>
        cnt ++;
ffffffffc020420c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020420e:	00f58863          	beq	a1,a5,ffffffffc020421e <strnlen+0x18>
ffffffffc0204212:	00f50733          	add	a4,a0,a5
ffffffffc0204216:	00074703          	lbu	a4,0(a4)
ffffffffc020421a:	fb6d                	bnez	a4,ffffffffc020420c <strnlen+0x6>
ffffffffc020421c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020421e:	852e                	mv	a0,a1
ffffffffc0204220:	8082                	ret

ffffffffc0204222 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204222:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204224:	0005c703          	lbu	a4,0(a1)
ffffffffc0204228:	0585                	addi	a1,a1,1
ffffffffc020422a:	0785                	addi	a5,a5,1
ffffffffc020422c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204230:	fb75                	bnez	a4,ffffffffc0204224 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204232:	8082                	ret

ffffffffc0204234 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204234:	00054783          	lbu	a5,0(a0)
ffffffffc0204238:	e791                	bnez	a5,ffffffffc0204244 <strcmp+0x10>
ffffffffc020423a:	a02d                	j	ffffffffc0204264 <strcmp+0x30>
ffffffffc020423c:	00054783          	lbu	a5,0(a0)
ffffffffc0204240:	cf89                	beqz	a5,ffffffffc020425a <strcmp+0x26>
ffffffffc0204242:	85b6                	mv	a1,a3
ffffffffc0204244:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0204248:	0505                	addi	a0,a0,1
ffffffffc020424a:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020424e:	fef707e3          	beq	a4,a5,ffffffffc020423c <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204252:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204256:	9d19                	subw	a0,a0,a4
ffffffffc0204258:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020425a:	0015c703          	lbu	a4,1(a1)
ffffffffc020425e:	4501                	li	a0,0
}
ffffffffc0204260:	9d19                	subw	a0,a0,a4
ffffffffc0204262:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204264:	0005c703          	lbu	a4,0(a1)
ffffffffc0204268:	4501                	li	a0,0
ffffffffc020426a:	b7f5                	j	ffffffffc0204256 <strcmp+0x22>

ffffffffc020426c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020426c:	a021                	j	ffffffffc0204274 <strchr+0x8>
        if (*s == c) {
ffffffffc020426e:	00f58763          	beq	a1,a5,ffffffffc020427c <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0204272:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204274:	00054783          	lbu	a5,0(a0)
ffffffffc0204278:	fbfd                	bnez	a5,ffffffffc020426e <strchr+0x2>
    }
    return NULL;
ffffffffc020427a:	4501                	li	a0,0
}
ffffffffc020427c:	8082                	ret

ffffffffc020427e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020427e:	ca01                	beqz	a2,ffffffffc020428e <memset+0x10>
ffffffffc0204280:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204282:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204284:	0785                	addi	a5,a5,1
ffffffffc0204286:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020428a:	fef61de3          	bne	a2,a5,ffffffffc0204284 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020428e:	8082                	ret

ffffffffc0204290 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204290:	ca19                	beqz	a2,ffffffffc02042a6 <memcpy+0x16>
ffffffffc0204292:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204294:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204296:	0005c703          	lbu	a4,0(a1)
ffffffffc020429a:	0585                	addi	a1,a1,1
ffffffffc020429c:	0785                	addi	a5,a5,1
ffffffffc020429e:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02042a2:	feb61ae3          	bne	a2,a1,ffffffffc0204296 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02042a6:	8082                	ret
