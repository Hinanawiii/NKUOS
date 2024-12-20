
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	51e50513          	addi	a0,a0,1310 # ffffffffc02a7550 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	a7260613          	addi	a2,a2,-1422 # ffffffffc02b2aac <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	508060ef          	jal	ra,ffffffffc0206552 <memset>
    cons_init();                // init the console
ffffffffc020004e:	52a000ef          	jal	ra,ffffffffc0200578 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	52e58593          	addi	a1,a1,1326 # ffffffffc0206580 <etext+0x4>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	54650513          	addi	a0,a0,1350 # ffffffffc02065a0 <etext+0x24>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a2000ef          	jal	ra,ffffffffc0200208 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	4be020ef          	jal	ra,ffffffffc0202528 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5de000ef          	jal	ra,ffffffffc020064c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	3fe040ef          	jal	ra,ffffffffc0204474 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	451050ef          	jal	ra,ffffffffc0205cca <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	56c000ef          	jal	ra,ffffffffc02005ea <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	34c030ef          	jal	ra,ffffffffc02033ce <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4a0000ef          	jal	ra,ffffffffc0200526 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b6000ef          	jal	ra,ffffffffc0200640 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	5d5050ef          	jal	ra,ffffffffc0205e62 <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	50050513          	addi	a0,a0,1280 # ffffffffc02065a8 <etext+0x2c>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	000a7b97          	auipc	s7,0xa7
ffffffffc02000c2:	492b8b93          	addi	s7,s7,1170 # ffffffffc02a7550 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	12e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	11e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	10c000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	000a7517          	auipc	a0,0xa7
ffffffffc020011e:	43650513          	addi	a0,a0,1078 # ffffffffc02a7550 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	42c000ef          	jal	ra,ffffffffc020057a <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	7e1050ef          	jal	ra,ffffffffc0206154 <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	7ab050ef          	jal	ra,ffffffffc0206154 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a6d1                	j	ffffffffc020057a <cons_putc>

ffffffffc02001b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b8:	1101                	addi	sp,sp,-32
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	ec06                	sd	ra,24(sp)
ffffffffc02001be:	e426                	sd	s1,8(sp)
ffffffffc02001c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c2:	00054503          	lbu	a0,0(a0)
ffffffffc02001c6:	c51d                	beqz	a0,ffffffffc02001f4 <cputs+0x3c>
ffffffffc02001c8:	0405                	addi	s0,s0,1
ffffffffc02001ca:	4485                	li	s1,1
ffffffffc02001cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001ce:	3ac000ef          	jal	ra,ffffffffc020057a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d2:	00044503          	lbu	a0,0(s0)
ffffffffc02001d6:	008487bb          	addw	a5,s1,s0
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	f96d                	bnez	a0,ffffffffc02001ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02001de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e2:	4529                	li	a0,10
ffffffffc02001e4:	396000ef          	jal	ra,ffffffffc020057a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	64a2                	ld	s1,8(sp)
ffffffffc02001f0:	6105                	addi	sp,sp,32
ffffffffc02001f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f4:	4405                	li	s0,1
ffffffffc02001f6:	b7f5                	j	ffffffffc02001e2 <cputs+0x2a>

ffffffffc02001f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001f8:	1141                	addi	sp,sp,-16
ffffffffc02001fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001fc:	3b2000ef          	jal	ra,ffffffffc02005ae <cons_getc>
ffffffffc0200200:	dd75                	beqz	a0,ffffffffc02001fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020a:	00006517          	auipc	a0,0x6
ffffffffc020020e:	3a650513          	addi	a0,a0,934 # ffffffffc02065b0 <etext+0x34>
void print_kerninfo(void) {
ffffffffc0200212:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200214:	f6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200218:	00000597          	auipc	a1,0x0
ffffffffc020021c:	e1a58593          	addi	a1,a1,-486 # ffffffffc0200032 <kern_init>
ffffffffc0200220:	00006517          	auipc	a0,0x6
ffffffffc0200224:	3b050513          	addi	a0,a0,944 # ffffffffc02065d0 <etext+0x54>
ffffffffc0200228:	f59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020022c:	00006597          	auipc	a1,0x6
ffffffffc0200230:	35058593          	addi	a1,a1,848 # ffffffffc020657c <etext>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	3bc50513          	addi	a0,a0,956 # ffffffffc02065f0 <etext+0x74>
ffffffffc020023c:	f45ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200240:	000a7597          	auipc	a1,0xa7
ffffffffc0200244:	31058593          	addi	a1,a1,784 # ffffffffc02a7550 <buf>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	3c850513          	addi	a0,a0,968 # ffffffffc0206610 <etext+0x94>
ffffffffc0200250:	f31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200254:	000b3597          	auipc	a1,0xb3
ffffffffc0200258:	85858593          	addi	a1,a1,-1960 # ffffffffc02b2aac <end>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	3d450513          	addi	a0,a0,980 # ffffffffc0206630 <etext+0xb4>
ffffffffc0200264:	f1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200268:	000b3597          	auipc	a1,0xb3
ffffffffc020026c:	c4358593          	addi	a1,a1,-957 # ffffffffc02b2eab <end+0x3ff>
ffffffffc0200270:	00000797          	auipc	a5,0x0
ffffffffc0200274:	dc278793          	addi	a5,a5,-574 # ffffffffc0200032 <kern_init>
ffffffffc0200278:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020027c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200282:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200286:	95be                	add	a1,a1,a5
ffffffffc0200288:	85a9                	srai	a1,a1,0xa
ffffffffc020028a:	00006517          	auipc	a0,0x6
ffffffffc020028e:	3c650513          	addi	a0,a0,966 # ffffffffc0206650 <etext+0xd4>
}
ffffffffc0200292:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	b5f5                	j	ffffffffc0200180 <cprintf>

ffffffffc0200296 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200296:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200298:	00006617          	auipc	a2,0x6
ffffffffc020029c:	3e860613          	addi	a2,a2,1000 # ffffffffc0206680 <etext+0x104>
ffffffffc02002a0:	04d00593          	li	a1,77
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	3f450513          	addi	a0,a0,1012 # ffffffffc0206698 <etext+0x11c>
void print_stackframe(void) {
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ae:	1cc000ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02002b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b4:	00006617          	auipc	a2,0x6
ffffffffc02002b8:	3fc60613          	addi	a2,a2,1020 # ffffffffc02066b0 <etext+0x134>
ffffffffc02002bc:	00006597          	auipc	a1,0x6
ffffffffc02002c0:	41458593          	addi	a1,a1,1044 # ffffffffc02066d0 <etext+0x154>
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	41450513          	addi	a0,a0,1044 # ffffffffc02066d8 <etext+0x15c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	eb3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002d2:	00006617          	auipc	a2,0x6
ffffffffc02002d6:	41660613          	addi	a2,a2,1046 # ffffffffc02066e8 <etext+0x16c>
ffffffffc02002da:	00006597          	auipc	a1,0x6
ffffffffc02002de:	43658593          	addi	a1,a1,1078 # ffffffffc0206710 <etext+0x194>
ffffffffc02002e2:	00006517          	auipc	a0,0x6
ffffffffc02002e6:	3f650513          	addi	a0,a0,1014 # ffffffffc02066d8 <etext+0x15c>
ffffffffc02002ea:	e97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ee:	00006617          	auipc	a2,0x6
ffffffffc02002f2:	43260613          	addi	a2,a2,1074 # ffffffffc0206720 <etext+0x1a4>
ffffffffc02002f6:	00006597          	auipc	a1,0x6
ffffffffc02002fa:	44a58593          	addi	a1,a1,1098 # ffffffffc0206740 <etext+0x1c4>
ffffffffc02002fe:	00006517          	auipc	a0,0x6
ffffffffc0200302:	3da50513          	addi	a0,a0,986 # ffffffffc02066d8 <etext+0x15c>
ffffffffc0200306:	e7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc020030a:	60a2                	ld	ra,8(sp)
ffffffffc020030c:	4501                	li	a0,0
ffffffffc020030e:	0141                	addi	sp,sp,16
ffffffffc0200310:	8082                	ret

ffffffffc0200312 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200312:	1141                	addi	sp,sp,-16
ffffffffc0200314:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200316:	ef3ff0ef          	jal	ra,ffffffffc0200208 <print_kerninfo>
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200326:	f71ff0ef          	jal	ra,ffffffffc0200296 <print_stackframe>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200332:	7115                	addi	sp,sp,-224
ffffffffc0200334:	ed5e                	sd	s7,152(sp)
ffffffffc0200336:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200338:	00006517          	auipc	a0,0x6
ffffffffc020033c:	41850513          	addi	a0,a0,1048 # ffffffffc0206750 <etext+0x1d4>
kmonitor(struct trapframe *tf) {
ffffffffc0200340:	ed86                	sd	ra,216(sp)
ffffffffc0200342:	e9a2                	sd	s0,208(sp)
ffffffffc0200344:	e5a6                	sd	s1,200(sp)
ffffffffc0200346:	e1ca                	sd	s2,192(sp)
ffffffffc0200348:	fd4e                	sd	s3,184(sp)
ffffffffc020034a:	f952                	sd	s4,176(sp)
ffffffffc020034c:	f556                	sd	s5,168(sp)
ffffffffc020034e:	f15a                	sd	s6,160(sp)
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	e566                	sd	s9,136(sp)
ffffffffc0200354:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200356:	e2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	41e50513          	addi	a0,a0,1054 # ffffffffc0206778 <etext+0x1fc>
ffffffffc0200362:	e1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200366:	000b8563          	beqz	s7,ffffffffc0200370 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036a:	855e                	mv	a0,s7
ffffffffc020036c:	4c8000ef          	jal	ra,ffffffffc0200834 <print_trapframe>
ffffffffc0200370:	00006c17          	auipc	s8,0x6
ffffffffc0200374:	478c0c13          	addi	s8,s8,1144 # ffffffffc02067e8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	00006917          	auipc	s2,0x6
ffffffffc020037c:	42890913          	addi	s2,s2,1064 # ffffffffc02067a0 <etext+0x224>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	00006497          	auipc	s1,0x6
ffffffffc0200384:	42848493          	addi	s1,s1,1064 # ffffffffc02067a8 <etext+0x22c>
        if (argc == MAXARGS - 1) {
ffffffffc0200388:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	00006b17          	auipc	s6,0x6
ffffffffc020038e:	426b0b13          	addi	s6,s6,1062 # ffffffffc02067b0 <etext+0x234>
        argv[argc ++] = buf;
ffffffffc0200392:	00006a17          	auipc	s4,0x6
ffffffffc0200396:	33ea0a13          	addi	s4,s4,830 # ffffffffc02066d0 <etext+0x154>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020039c:	854a                	mv	a0,s2
ffffffffc020039e:	cf5ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc02003a2:	842a                	mv	s0,a0
ffffffffc02003a4:	dd65                	beqz	a0,ffffffffc020039c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003aa:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ac:	e1bd                	bnez	a1,ffffffffc0200412 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003ae:	fe0c87e3          	beqz	s9,ffffffffc020039c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	00006d17          	auipc	s10,0x6
ffffffffc02003b8:	434d0d13          	addi	s10,s10,1076 # ffffffffc02067e8 <commands>
        argv[argc ++] = buf;
ffffffffc02003bc:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	4401                	li	s0,0
ffffffffc02003c0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c2:	15c060ef          	jal	ra,ffffffffc020651e <strcmp>
ffffffffc02003c6:	c919                	beqz	a0,ffffffffc02003dc <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c8:	2405                	addiw	s0,s0,1
ffffffffc02003ca:	0b540063          	beq	s0,s5,ffffffffc020046a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ce:	000d3503          	ld	a0,0(s10)
ffffffffc02003d2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d6:	148060ef          	jal	ra,ffffffffc020651e <strcmp>
ffffffffc02003da:	f57d                	bnez	a0,ffffffffc02003c8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003dc:	00141793          	slli	a5,s0,0x1
ffffffffc02003e0:	97a2                	add	a5,a5,s0
ffffffffc02003e2:	078e                	slli	a5,a5,0x3
ffffffffc02003e4:	97e2                	add	a5,a5,s8
ffffffffc02003e6:	6b9c                	ld	a5,16(a5)
ffffffffc02003e8:	865e                	mv	a2,s7
ffffffffc02003ea:	002c                	addi	a1,sp,8
ffffffffc02003ec:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f2:	fa0555e3          	bgez	a0,ffffffffc020039c <kmonitor+0x6a>
}
ffffffffc02003f6:	60ee                	ld	ra,216(sp)
ffffffffc02003f8:	644e                	ld	s0,208(sp)
ffffffffc02003fa:	64ae                	ld	s1,200(sp)
ffffffffc02003fc:	690e                	ld	s2,192(sp)
ffffffffc02003fe:	79ea                	ld	s3,184(sp)
ffffffffc0200400:	7a4a                	ld	s4,176(sp)
ffffffffc0200402:	7aaa                	ld	s5,168(sp)
ffffffffc0200404:	7b0a                	ld	s6,160(sp)
ffffffffc0200406:	6bea                	ld	s7,152(sp)
ffffffffc0200408:	6c4a                	ld	s8,144(sp)
ffffffffc020040a:	6caa                	ld	s9,136(sp)
ffffffffc020040c:	6d0a                	ld	s10,128(sp)
ffffffffc020040e:	612d                	addi	sp,sp,224
ffffffffc0200410:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	8526                	mv	a0,s1
ffffffffc0200414:	128060ef          	jal	ra,ffffffffc020653c <strchr>
ffffffffc0200418:	c901                	beqz	a0,ffffffffc0200428 <kmonitor+0xf6>
ffffffffc020041a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020041e:	00040023          	sb	zero,0(s0)
ffffffffc0200422:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	d5c9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200426:	b7f5                	j	ffffffffc0200412 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200428:	00044783          	lbu	a5,0(s0)
ffffffffc020042c:	d3c9                	beqz	a5,ffffffffc02003ae <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020042e:	033c8963          	beq	s9,s3,ffffffffc0200460 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200432:	003c9793          	slli	a5,s9,0x3
ffffffffc0200436:	0118                	addi	a4,sp,128
ffffffffc0200438:	97ba                	add	a5,a5,a4
ffffffffc020043a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020043e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200442:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200444:	e591                	bnez	a1,ffffffffc0200450 <kmonitor+0x11e>
ffffffffc0200446:	b7b5                	j	ffffffffc02003b2 <kmonitor+0x80>
ffffffffc0200448:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020044c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	d1a5                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	0ea060ef          	jal	ra,ffffffffc020653c <strchr>
ffffffffc0200456:	d96d                	beqz	a0,ffffffffc0200448 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	00044583          	lbu	a1,0(s0)
ffffffffc020045c:	d9a9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc020045e:	bf55                	j	ffffffffc0200412 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200460:	45c1                	li	a1,16
ffffffffc0200462:	855a                	mv	a0,s6
ffffffffc0200464:	d1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200468:	b7e9                	j	ffffffffc0200432 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046a:	6582                	ld	a1,0(sp)
ffffffffc020046c:	00006517          	auipc	a0,0x6
ffffffffc0200470:	36450513          	addi	a0,a0,868 # ffffffffc02067d0 <etext+0x254>
ffffffffc0200474:	d0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200478:	b715                	j	ffffffffc020039c <kmonitor+0x6a>

ffffffffc020047a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047a:	000b2317          	auipc	t1,0xb2
ffffffffc020047e:	59e30313          	addi	t1,t1,1438 # ffffffffc02b2a18 <is_panic>
ffffffffc0200482:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200486:	715d                	addi	sp,sp,-80
ffffffffc0200488:	ec06                	sd	ra,24(sp)
ffffffffc020048a:	e822                	sd	s0,16(sp)
ffffffffc020048c:	f436                	sd	a3,40(sp)
ffffffffc020048e:	f83a                	sd	a4,48(sp)
ffffffffc0200490:	fc3e                	sd	a5,56(sp)
ffffffffc0200492:	e0c2                	sd	a6,64(sp)
ffffffffc0200494:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200496:	020e1a63          	bnez	t3,ffffffffc02004ca <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049a:	4785                	li	a5,1
ffffffffc020049c:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a0:	8432                	mv	s0,a2
ffffffffc02004a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a4:	862e                	mv	a2,a1
ffffffffc02004a6:	85aa                	mv	a1,a0
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	38850513          	addi	a0,a0,904 # ffffffffc0206830 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b0:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b2:	ccfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b6:	65a2                	ld	a1,8(sp)
ffffffffc02004b8:	8522                	mv	a0,s0
ffffffffc02004ba:	ca7ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004be:	00007517          	auipc	a0,0x7
ffffffffc02004c2:	32a50513          	addi	a0,a0,810 # ffffffffc02077e8 <default_pmm_manager+0x518>
ffffffffc02004c6:	cbbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	4581                	li	a1,0
ffffffffc02004ce:	4601                	li	a2,0
ffffffffc02004d0:	48a1                	li	a7,8
ffffffffc02004d2:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d6:	170000ef          	jal	ra,ffffffffc0200646 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	e57ff0ef          	jal	ra,ffffffffc0200332 <kmonitor>
    while (1) {
ffffffffc02004e0:	bfed                	j	ffffffffc02004da <__panic+0x60>

ffffffffc02004e2 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	715d                	addi	sp,sp,-80
ffffffffc02004e4:	832e                	mv	t1,a1
ffffffffc02004e6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ea:	8432                	mv	s0,a2
ffffffffc02004ec:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ee:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f0:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	00006517          	auipc	a0,0x6
ffffffffc02004f6:	35e50513          	addi	a0,a0,862 # ffffffffc0206850 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	ec06                	sd	ra,24(sp)
ffffffffc02004fc:	f436                	sd	a3,40(sp)
ffffffffc02004fe:	f83a                	sd	a4,48(sp)
ffffffffc0200500:	e0c2                	sd	a6,64(sp)
ffffffffc0200502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200504:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	c7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050a:	65a2                	ld	a1,8(sp)
ffffffffc020050c:	8522                	mv	a0,s0
ffffffffc020050e:	c53ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc0200512:	00007517          	auipc	a0,0x7
ffffffffc0200516:	2d650513          	addi	a0,a0,726 # ffffffffc02077e8 <default_pmm_manager+0x518>
ffffffffc020051a:	c67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc020051e:	60e2                	ld	ra,24(sp)
ffffffffc0200520:	6442                	ld	s0,16(sp)
ffffffffc0200522:	6161                	addi	sp,sp,80
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200526:	67e1                	lui	a5,0x18
ffffffffc0200528:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd558>
ffffffffc020052c:	000b2717          	auipc	a4,0xb2
ffffffffc0200530:	4ef73e23          	sd	a5,1276(a4) # ffffffffc02b2a28 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200534:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200538:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020053a:	953e                	add	a0,a0,a5
ffffffffc020053c:	4601                	li	a2,0
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200544:	02000793          	li	a5,32
ffffffffc0200548:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020054c:	00006517          	auipc	a0,0x6
ffffffffc0200550:	32450513          	addi	a0,a0,804 # ffffffffc0206870 <commands+0x88>
    ticks = 0;
ffffffffc0200554:	000b2797          	auipc	a5,0xb2
ffffffffc0200558:	4c07b623          	sd	zero,1228(a5) # ffffffffc02b2a20 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	b115                	j	ffffffffc0200180 <cprintf>

ffffffffc020055e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200562:	000b2797          	auipc	a5,0xb2
ffffffffc0200566:	4c67b783          	ld	a5,1222(a5) # ffffffffc02b2a28 <timebase>
ffffffffc020056a:	953e                	add	a0,a0,a5
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
ffffffffc0200576:	8082                	ret

ffffffffc0200578 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200578:	8082                	ret

ffffffffc020057a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200580:	0ff57513          	zext.b	a0,a0
ffffffffc0200584:	e799                	bnez	a5,ffffffffc0200592 <cons_putc+0x18>
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4885                	li	a7,1
ffffffffc020058c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200590:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
ffffffffc0200596:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200598:	0ae000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020059c:	6522                	ld	a0,8(sp)
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4885                	li	a7,1
ffffffffc02005a4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a8:	60e2                	ld	ra,24(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ac:	a851                	j	ffffffffc0200640 <intr_enable>

ffffffffc02005ae <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ae:	100027f3          	csrr	a5,sstatus
ffffffffc02005b2:	8b89                	andi	a5,a5,2
ffffffffc02005b4:	eb89                	bnez	a5,ffffffffc02005c6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005c4:	8082                	ret
int cons_getc(void) {
ffffffffc02005c6:	1101                	addi	sp,sp,-32
ffffffffc02005c8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005ca:	07c000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc02005ce:	4501                	li	a0,0
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4889                	li	a7,2
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	2501                	sext.w	a0,a0
ffffffffc02005dc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005de:	062000ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6522                	ld	a0,8(sp)
ffffffffc02005e6:	6105                	addi	sp,sp,32
ffffffffc02005e8:	8082                	ret

ffffffffc02005ea <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005ec:	00253513          	sltiu	a0,a0,2
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005f2:	03800513          	li	a0,56
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f8:	000a7797          	auipc	a5,0xa7
ffffffffc02005fc:	35878793          	addi	a5,a5,856 # ffffffffc02a7950 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200600:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200604:	1141                	addi	sp,sp,-16
ffffffffc0200606:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200608:	95be                	add	a1,a1,a5
ffffffffc020060a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020060e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200610:	755050ef          	jal	ra,ffffffffc0206564 <memcpy>
    return 0;
}
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	4501                	li	a0,0
ffffffffc0200618:	0141                	addi	sp,sp,16
ffffffffc020061a:	8082                	ret

ffffffffc020061c <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc020061c:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200620:	000a7517          	auipc	a0,0xa7
ffffffffc0200624:	33050513          	addi	a0,a0,816 # ffffffffc02a7950 <ide>
                   size_t nsecs) {
ffffffffc0200628:	1141                	addi	sp,sp,-16
ffffffffc020062a:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062c:	953e                	add	a0,a0,a5
ffffffffc020062e:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200632:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200634:	731050ef          	jal	ra,ffffffffc0206564 <memcpy>
    return 0;
}
ffffffffc0200638:	60a2                	ld	ra,8(sp)
ffffffffc020063a:	4501                	li	a0,0
ffffffffc020063c:	0141                	addi	sp,sp,16
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200646:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064a:	8082                	ret

ffffffffc020064c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	60678793          	addi	a5,a5,1542 # ffffffffc0200c58 <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	22050513          	addi	a0,a0,544 # ffffffffc0206890 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	b07ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	22850513          	addi	a0,a0,552 # ffffffffc02068a8 <commands+0xc0>
ffffffffc0200688:	af9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	23250513          	addi	a0,a0,562 # ffffffffc02068c0 <commands+0xd8>
ffffffffc0200696:	aebff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	23c50513          	addi	a0,a0,572 # ffffffffc02068d8 <commands+0xf0>
ffffffffc02006a4:	addff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	24650513          	addi	a0,a0,582 # ffffffffc02068f0 <commands+0x108>
ffffffffc02006b2:	acfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	25050513          	addi	a0,a0,592 # ffffffffc0206908 <commands+0x120>
ffffffffc02006c0:	ac1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	25a50513          	addi	a0,a0,602 # ffffffffc0206920 <commands+0x138>
ffffffffc02006ce:	ab3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	26450513          	addi	a0,a0,612 # ffffffffc0206938 <commands+0x150>
ffffffffc02006dc:	aa5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	26e50513          	addi	a0,a0,622 # ffffffffc0206950 <commands+0x168>
ffffffffc02006ea:	a97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	27850513          	addi	a0,a0,632 # ffffffffc0206968 <commands+0x180>
ffffffffc02006f8:	a89ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	28250513          	addi	a0,a0,642 # ffffffffc0206980 <commands+0x198>
ffffffffc0200706:	a7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	28c50513          	addi	a0,a0,652 # ffffffffc0206998 <commands+0x1b0>
ffffffffc0200714:	a6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	29650513          	addi	a0,a0,662 # ffffffffc02069b0 <commands+0x1c8>
ffffffffc0200722:	a5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	2a050513          	addi	a0,a0,672 # ffffffffc02069c8 <commands+0x1e0>
ffffffffc0200730:	a51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	2aa50513          	addi	a0,a0,682 # ffffffffc02069e0 <commands+0x1f8>
ffffffffc020073e:	a43ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	2b450513          	addi	a0,a0,692 # ffffffffc02069f8 <commands+0x210>
ffffffffc020074c:	a35ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	2be50513          	addi	a0,a0,702 # ffffffffc0206a10 <commands+0x228>
ffffffffc020075a:	a27ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	2c850513          	addi	a0,a0,712 # ffffffffc0206a28 <commands+0x240>
ffffffffc0200768:	a19ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	2d250513          	addi	a0,a0,722 # ffffffffc0206a40 <commands+0x258>
ffffffffc0200776:	a0bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	2dc50513          	addi	a0,a0,732 # ffffffffc0206a58 <commands+0x270>
ffffffffc0200784:	9fdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	2e650513          	addi	a0,a0,742 # ffffffffc0206a70 <commands+0x288>
ffffffffc0200792:	9efff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	2f050513          	addi	a0,a0,752 # ffffffffc0206a88 <commands+0x2a0>
ffffffffc02007a0:	9e1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	2fa50513          	addi	a0,a0,762 # ffffffffc0206aa0 <commands+0x2b8>
ffffffffc02007ae:	9d3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	30450513          	addi	a0,a0,772 # ffffffffc0206ab8 <commands+0x2d0>
ffffffffc02007bc:	9c5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	30e50513          	addi	a0,a0,782 # ffffffffc0206ad0 <commands+0x2e8>
ffffffffc02007ca:	9b7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	31850513          	addi	a0,a0,792 # ffffffffc0206ae8 <commands+0x300>
ffffffffc02007d8:	9a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	32250513          	addi	a0,a0,802 # ffffffffc0206b00 <commands+0x318>
ffffffffc02007e6:	99bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	32c50513          	addi	a0,a0,812 # ffffffffc0206b18 <commands+0x330>
ffffffffc02007f4:	98dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	33650513          	addi	a0,a0,822 # ffffffffc0206b30 <commands+0x348>
ffffffffc0200802:	97fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	34050513          	addi	a0,a0,832 # ffffffffc0206b48 <commands+0x360>
ffffffffc0200810:	971ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	34a50513          	addi	a0,a0,842 # ffffffffc0206b60 <commands+0x378>
ffffffffc020081e:	963ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	35050513          	addi	a0,a0,848 # ffffffffc0206b78 <commands+0x390>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	b2b9                	j	ffffffffc0200180 <cprintf>

ffffffffc0200834 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200834:	1141                	addi	sp,sp,-16
ffffffffc0200836:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	35450513          	addi	a0,a0,852 # ffffffffc0206b90 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200844:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	93bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084a:	8522                	mv	a0,s0
ffffffffc020084c:	e1dff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200850:	10043583          	ld	a1,256(s0)
ffffffffc0200854:	00006517          	auipc	a0,0x6
ffffffffc0200858:	35450513          	addi	a0,a0,852 # ffffffffc0206ba8 <commands+0x3c0>
ffffffffc020085c:	925ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200860:	10843583          	ld	a1,264(s0)
ffffffffc0200864:	00006517          	auipc	a0,0x6
ffffffffc0200868:	35c50513          	addi	a0,a0,860 # ffffffffc0206bc0 <commands+0x3d8>
ffffffffc020086c:	915ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200870:	11043583          	ld	a1,272(s0)
ffffffffc0200874:	00006517          	auipc	a0,0x6
ffffffffc0200878:	36450513          	addi	a0,a0,868 # ffffffffc0206bd8 <commands+0x3f0>
ffffffffc020087c:	905ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	11843583          	ld	a1,280(s0)
}
ffffffffc0200884:	6402                	ld	s0,0(sp)
ffffffffc0200886:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200888:	00006517          	auipc	a0,0x6
ffffffffc020088c:	36050513          	addi	a0,a0,864 # ffffffffc0206be8 <commands+0x400>
}
ffffffffc0200890:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200892:	8efff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200896 <pgfault_handler>:
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200896:	10053783          	ld	a5,256(a0)
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
// trap.c 中的 pgfault_handler 函数
pgfault_handler(struct trapframe *tf) {
ffffffffc020089a:	1141                	addi	sp,sp,-16
ffffffffc020089c:	e022                	sd	s0,0(sp)
ffffffffc020089e:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008a0:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008a4:	11053583          	ld	a1,272(a0)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a8:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008aa:	05500613          	li	a2,85
ffffffffc02008ae:	c399                	beqz	a5,ffffffffc02008b4 <pgfault_handler+0x1e>
ffffffffc02008b0:	04b00613          	li	a2,75
ffffffffc02008b4:	11843703          	ld	a4,280(s0)
ffffffffc02008b8:	47bd                	li	a5,15
ffffffffc02008ba:	05700693          	li	a3,87
ffffffffc02008be:	00f70463          	beq	a4,a5,ffffffffc02008c6 <pgfault_handler+0x30>
ffffffffc02008c2:	05200693          	li	a3,82
ffffffffc02008c6:	00006517          	auipc	a0,0x6
ffffffffc02008ca:	33a50513          	addi	a0,a0,826 # ffffffffc0206c00 <commands+0x418>
ffffffffc02008ce:	8b3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);  // 添加这行来打印更多信息
    
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008d2:	000b2517          	auipc	a0,0xb2
ffffffffc02008d6:	1ae53503          	ld	a0,430(a0) # ffffffffc02b2a80 <check_mm_struct>
ffffffffc02008da:	c505                	beqz	a0,ffffffffc0200902 <pgfault_handler+0x6c>
        assert(current == idleproc);
ffffffffc02008dc:	000b2717          	auipc	a4,0xb2
ffffffffc02008e0:	1b473703          	ld	a4,436(a4) # ffffffffc02b2a90 <current>
ffffffffc02008e4:	000b2797          	auipc	a5,0xb2
ffffffffc02008e8:	1b47b783          	ld	a5,436(a5) # ffffffffc02b2a98 <idleproc>
ffffffffc02008ec:	02f71a63          	bne	a4,a5,ffffffffc0200920 <pgfault_handler+0x8a>
            print_trapframe(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f0:	11043603          	ld	a2,272(s0)
ffffffffc02008f4:	11843583          	ld	a1,280(s0)
}
ffffffffc02008f8:	6402                	ld	s0,0(sp)
ffffffffc02008fa:	60a2                	ld	ra,8(sp)
ffffffffc02008fc:	0141                	addi	sp,sp,16
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008fe:	0b60406f          	j	ffffffffc02049b4 <do_pgfault>
        if (current == NULL) {
ffffffffc0200902:	000b2797          	auipc	a5,0xb2
ffffffffc0200906:	18e7b783          	ld	a5,398(a5) # ffffffffc02b2a90 <current>
ffffffffc020090a:	cb9d                	beqz	a5,ffffffffc0200940 <pgfault_handler+0xaa>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090c:	11043603          	ld	a2,272(s0)
ffffffffc0200910:	11843583          	ld	a1,280(s0)
}
ffffffffc0200914:	6402                	ld	s0,0(sp)
ffffffffc0200916:	60a2                	ld	ra,8(sp)
        mm = current->mm;
ffffffffc0200918:	7788                	ld	a0,40(a5)
}
ffffffffc020091a:	0141                	addi	sp,sp,16
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091c:	0980406f          	j	ffffffffc02049b4 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200920:	00006697          	auipc	a3,0x6
ffffffffc0200924:	30068693          	addi	a3,a3,768 # ffffffffc0206c20 <commands+0x438>
ffffffffc0200928:	00006617          	auipc	a2,0x6
ffffffffc020092c:	31060613          	addi	a2,a2,784 # ffffffffc0206c38 <commands+0x450>
ffffffffc0200930:	06b00593          	li	a1,107
ffffffffc0200934:	00006517          	auipc	a0,0x6
ffffffffc0200938:	31c50513          	addi	a0,a0,796 # ffffffffc0206c50 <commands+0x468>
ffffffffc020093c:	b3fff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200940:	8522                	mv	a0,s0
ffffffffc0200942:	ef3ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
            panic("unhandled page fault.\n");
ffffffffc0200946:	00006617          	auipc	a2,0x6
ffffffffc020094a:	32260613          	addi	a2,a2,802 # ffffffffc0206c68 <commands+0x480>
ffffffffc020094e:	07100593          	li	a1,113
ffffffffc0200952:	00006517          	auipc	a0,0x6
ffffffffc0200956:	2fe50513          	addi	a0,a0,766 # ffffffffc0206c50 <commands+0x468>
ffffffffc020095a:	b21ff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020095e <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc020095e:	11853783          	ld	a5,280(a0)
ffffffffc0200962:	472d                	li	a4,11
ffffffffc0200964:	0786                	slli	a5,a5,0x1
ffffffffc0200966:	8385                	srli	a5,a5,0x1
ffffffffc0200968:	08f76363          	bltu	a4,a5,ffffffffc02009ee <interrupt_handler+0x90>
ffffffffc020096c:	00006717          	auipc	a4,0x6
ffffffffc0200970:	3b470713          	addi	a4,a4,948 # ffffffffc0206d20 <commands+0x538>
ffffffffc0200974:	078a                	slli	a5,a5,0x2
ffffffffc0200976:	97ba                	add	a5,a5,a4
ffffffffc0200978:	439c                	lw	a5,0(a5)
ffffffffc020097a:	97ba                	add	a5,a5,a4
ffffffffc020097c:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc020097e:	00006517          	auipc	a0,0x6
ffffffffc0200982:	36250513          	addi	a0,a0,866 # ffffffffc0206ce0 <commands+0x4f8>
ffffffffc0200986:	ffaff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc020098a:	00006517          	auipc	a0,0x6
ffffffffc020098e:	33650513          	addi	a0,a0,822 # ffffffffc0206cc0 <commands+0x4d8>
ffffffffc0200992:	feeff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200996:	00006517          	auipc	a0,0x6
ffffffffc020099a:	2ea50513          	addi	a0,a0,746 # ffffffffc0206c80 <commands+0x498>
ffffffffc020099e:	fe2ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	2fe50513          	addi	a0,a0,766 # ffffffffc0206ca0 <commands+0x4b8>
ffffffffc02009aa:	fd6ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02009ae:	1141                	addi	sp,sp,-16
ffffffffc02009b0:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02009b2:	badff0ef          	jal	ra,ffffffffc020055e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc02009b6:	000b2697          	auipc	a3,0xb2
ffffffffc02009ba:	06a68693          	addi	a3,a3,106 # ffffffffc02b2a20 <ticks>
ffffffffc02009be:	629c                	ld	a5,0(a3)
ffffffffc02009c0:	06400713          	li	a4,100
ffffffffc02009c4:	0785                	addi	a5,a5,1
ffffffffc02009c6:	02e7f733          	remu	a4,a5,a4
ffffffffc02009ca:	e29c                	sd	a5,0(a3)
ffffffffc02009cc:	eb01                	bnez	a4,ffffffffc02009dc <interrupt_handler+0x7e>
ffffffffc02009ce:	000b2797          	auipc	a5,0xb2
ffffffffc02009d2:	0c27b783          	ld	a5,194(a5) # ffffffffc02b2a90 <current>
ffffffffc02009d6:	c399                	beqz	a5,ffffffffc02009dc <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc02009d8:	4705                	li	a4,1
ffffffffc02009da:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02009dc:	60a2                	ld	ra,8(sp)
ffffffffc02009de:	0141                	addi	sp,sp,16
ffffffffc02009e0:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02009e2:	00006517          	auipc	a0,0x6
ffffffffc02009e6:	31e50513          	addi	a0,a0,798 # ffffffffc0206d00 <commands+0x518>
ffffffffc02009ea:	f96ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc02009ee:	b599                	j	ffffffffc0200834 <print_trapframe>

ffffffffc02009f0 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc02009f0:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc02009f4:	1101                	addi	sp,sp,-32
ffffffffc02009f6:	e822                	sd	s0,16(sp)
ffffffffc02009f8:	ec06                	sd	ra,24(sp)
ffffffffc02009fa:	e426                	sd	s1,8(sp)
ffffffffc02009fc:	473d                	li	a4,15
ffffffffc02009fe:	842a                	mv	s0,a0
ffffffffc0200a00:	18f76563          	bltu	a4,a5,ffffffffc0200b8a <exception_handler+0x19a>
ffffffffc0200a04:	00006717          	auipc	a4,0x6
ffffffffc0200a08:	4e470713          	addi	a4,a4,1252 # ffffffffc0206ee8 <commands+0x700>
ffffffffc0200a0c:	078a                	slli	a5,a5,0x2
ffffffffc0200a0e:	97ba                	add	a5,a5,a4
ffffffffc0200a10:	439c                	lw	a5,0(a5)
ffffffffc0200a12:	97ba                	add	a5,a5,a4
ffffffffc0200a14:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a16:	00006517          	auipc	a0,0x6
ffffffffc0200a1a:	42a50513          	addi	a0,a0,1066 # ffffffffc0206e40 <commands+0x658>
ffffffffc0200a1e:	f62ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a22:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a26:	60e2                	ld	ra,24(sp)
ffffffffc0200a28:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a2a:	0791                	addi	a5,a5,4
ffffffffc0200a2c:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a30:	6442                	ld	s0,16(sp)
ffffffffc0200a32:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a34:	61e0506f          	j	ffffffffc0206052 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a38:	00006517          	auipc	a0,0x6
ffffffffc0200a3c:	42850513          	addi	a0,a0,1064 # ffffffffc0206e60 <commands+0x678>
}
ffffffffc0200a40:	6442                	ld	s0,16(sp)
ffffffffc0200a42:	60e2                	ld	ra,24(sp)
ffffffffc0200a44:	64a2                	ld	s1,8(sp)
ffffffffc0200a46:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a48:	f38ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a4c:	00006517          	auipc	a0,0x6
ffffffffc0200a50:	43450513          	addi	a0,a0,1076 # ffffffffc0206e80 <commands+0x698>
ffffffffc0200a54:	b7f5                	j	ffffffffc0200a40 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a56:	00006517          	auipc	a0,0x6
ffffffffc0200a5a:	44a50513          	addi	a0,a0,1098 # ffffffffc0206ea0 <commands+0x6b8>
ffffffffc0200a5e:	b7cd                	j	ffffffffc0200a40 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a60:	00006517          	auipc	a0,0x6
ffffffffc0200a64:	45850513          	addi	a0,a0,1112 # ffffffffc0206eb8 <commands+0x6d0>
ffffffffc0200a68:	f18ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a6c:	8522                	mv	a0,s0
ffffffffc0200a6e:	e29ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200a72:	84aa                	mv	s1,a0
ffffffffc0200a74:	12051d63          	bnez	a0,ffffffffc0200bae <exception_handler+0x1be>
}
ffffffffc0200a78:	60e2                	ld	ra,24(sp)
ffffffffc0200a7a:	6442                	ld	s0,16(sp)
ffffffffc0200a7c:	64a2                	ld	s1,8(sp)
ffffffffc0200a7e:	6105                	addi	sp,sp,32
ffffffffc0200a80:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200a82:	00006517          	auipc	a0,0x6
ffffffffc0200a86:	44e50513          	addi	a0,a0,1102 # ffffffffc0206ed0 <commands+0x6e8>
ffffffffc0200a8a:	ef6ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a8e:	8522                	mv	a0,s0
ffffffffc0200a90:	e07ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200a94:	84aa                	mv	s1,a0
ffffffffc0200a96:	d16d                	beqz	a0,ffffffffc0200a78 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200a98:	8522                	mv	a0,s0
ffffffffc0200a9a:	d9bff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a9e:	86a6                	mv	a3,s1
ffffffffc0200aa0:	00006617          	auipc	a2,0x6
ffffffffc0200aa4:	35060613          	addi	a2,a2,848 # ffffffffc0206df0 <commands+0x608>
ffffffffc0200aa8:	0f700593          	li	a1,247
ffffffffc0200aac:	00006517          	auipc	a0,0x6
ffffffffc0200ab0:	1a450513          	addi	a0,a0,420 # ffffffffc0206c50 <commands+0x468>
ffffffffc0200ab4:	9c7ff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200ab8:	00006517          	auipc	a0,0x6
ffffffffc0200abc:	29850513          	addi	a0,a0,664 # ffffffffc0206d50 <commands+0x568>
ffffffffc0200ac0:	b741                	j	ffffffffc0200a40 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	00006517          	auipc	a0,0x6
ffffffffc0200ac6:	2ae50513          	addi	a0,a0,686 # ffffffffc0206d70 <commands+0x588>
ffffffffc0200aca:	bf9d                	j	ffffffffc0200a40 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200acc:	00006517          	auipc	a0,0x6
ffffffffc0200ad0:	2c450513          	addi	a0,a0,708 # ffffffffc0206d90 <commands+0x5a8>
ffffffffc0200ad4:	b7b5                	j	ffffffffc0200a40 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200ad6:	00006517          	auipc	a0,0x6
ffffffffc0200ada:	2d250513          	addi	a0,a0,722 # ffffffffc0206da8 <commands+0x5c0>
ffffffffc0200ade:	ea2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200ae2:	6458                	ld	a4,136(s0)
ffffffffc0200ae4:	47a9                	li	a5,10
ffffffffc0200ae6:	f8f719e3          	bne	a4,a5,ffffffffc0200a78 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200aea:	10843783          	ld	a5,264(s0)
ffffffffc0200aee:	0791                	addi	a5,a5,4
ffffffffc0200af0:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200af4:	55e050ef          	jal	ra,ffffffffc0206052 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200af8:	000b2797          	auipc	a5,0xb2
ffffffffc0200afc:	f987b783          	ld	a5,-104(a5) # ffffffffc02b2a90 <current>
ffffffffc0200b00:	6b9c                	ld	a5,16(a5)
ffffffffc0200b02:	8522                	mv	a0,s0
}
ffffffffc0200b04:	6442                	ld	s0,16(sp)
ffffffffc0200b06:	60e2                	ld	ra,24(sp)
ffffffffc0200b08:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b0a:	6589                	lui	a1,0x2
ffffffffc0200b0c:	95be                	add	a1,a1,a5
}
ffffffffc0200b0e:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b10:	ac19                	j	ffffffffc0200d26 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b12:	00006517          	auipc	a0,0x6
ffffffffc0200b16:	2a650513          	addi	a0,a0,678 # ffffffffc0206db8 <commands+0x5d0>
ffffffffc0200b1a:	b71d                	j	ffffffffc0200a40 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b1c:	00006517          	auipc	a0,0x6
ffffffffc0200b20:	2bc50513          	addi	a0,a0,700 # ffffffffc0206dd8 <commands+0x5f0>
ffffffffc0200b24:	e5cff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b28:	8522                	mv	a0,s0
ffffffffc0200b2a:	d6dff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200b2e:	84aa                	mv	s1,a0
ffffffffc0200b30:	d521                	beqz	a0,ffffffffc0200a78 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b32:	8522                	mv	a0,s0
ffffffffc0200b34:	d01ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b38:	86a6                	mv	a3,s1
ffffffffc0200b3a:	00006617          	auipc	a2,0x6
ffffffffc0200b3e:	2b660613          	addi	a2,a2,694 # ffffffffc0206df0 <commands+0x608>
ffffffffc0200b42:	0cc00593          	li	a1,204
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	10a50513          	addi	a0,a0,266 # ffffffffc0206c50 <commands+0x468>
ffffffffc0200b4e:	92dff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200b52:	00006517          	auipc	a0,0x6
ffffffffc0200b56:	2d650513          	addi	a0,a0,726 # ffffffffc0206e28 <commands+0x640>
ffffffffc0200b5a:	e26ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b5e:	8522                	mv	a0,s0
ffffffffc0200b60:	d37ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200b64:	84aa                	mv	s1,a0
ffffffffc0200b66:	f00509e3          	beqz	a0,ffffffffc0200a78 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b6a:	8522                	mv	a0,s0
ffffffffc0200b6c:	cc9ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b70:	86a6                	mv	a3,s1
ffffffffc0200b72:	00006617          	auipc	a2,0x6
ffffffffc0200b76:	27e60613          	addi	a2,a2,638 # ffffffffc0206df0 <commands+0x608>
ffffffffc0200b7a:	0d600593          	li	a1,214
ffffffffc0200b7e:	00006517          	auipc	a0,0x6
ffffffffc0200b82:	0d250513          	addi	a0,a0,210 # ffffffffc0206c50 <commands+0x468>
ffffffffc0200b86:	8f5ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200b8a:	8522                	mv	a0,s0
}
ffffffffc0200b8c:	6442                	ld	s0,16(sp)
ffffffffc0200b8e:	60e2                	ld	ra,24(sp)
ffffffffc0200b90:	64a2                	ld	s1,8(sp)
ffffffffc0200b92:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200b94:	b145                	j	ffffffffc0200834 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200b96:	00006617          	auipc	a2,0x6
ffffffffc0200b9a:	27a60613          	addi	a2,a2,634 # ffffffffc0206e10 <commands+0x628>
ffffffffc0200b9e:	0d000593          	li	a1,208
ffffffffc0200ba2:	00006517          	auipc	a0,0x6
ffffffffc0200ba6:	0ae50513          	addi	a0,a0,174 # ffffffffc0206c50 <commands+0x468>
ffffffffc0200baa:	8d1ff0ef          	jal	ra,ffffffffc020047a <__panic>
                print_trapframe(tf);
ffffffffc0200bae:	8522                	mv	a0,s0
ffffffffc0200bb0:	c85ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb4:	86a6                	mv	a3,s1
ffffffffc0200bb6:	00006617          	auipc	a2,0x6
ffffffffc0200bba:	23a60613          	addi	a2,a2,570 # ffffffffc0206df0 <commands+0x608>
ffffffffc0200bbe:	0f000593          	li	a1,240
ffffffffc0200bc2:	00006517          	auipc	a0,0x6
ffffffffc0200bc6:	08e50513          	addi	a0,a0,142 # ffffffffc0206c50 <commands+0x468>
ffffffffc0200bca:	8b1ff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200bce <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200bce:	1101                	addi	sp,sp,-32
ffffffffc0200bd0:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200bd2:	000b2417          	auipc	s0,0xb2
ffffffffc0200bd6:	ebe40413          	addi	s0,s0,-322 # ffffffffc02b2a90 <current>
ffffffffc0200bda:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200bdc:	ec06                	sd	ra,24(sp)
ffffffffc0200bde:	e426                	sd	s1,8(sp)
ffffffffc0200be0:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200be2:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200be6:	cf1d                	beqz	a4,ffffffffc0200c24 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200be8:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200bec:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200bf0:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200bf2:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200bf6:	0206c463          	bltz	a3,ffffffffc0200c1e <trap+0x50>
        exception_handler(tf);
ffffffffc0200bfa:	df7ff0ef          	jal	ra,ffffffffc02009f0 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200bfe:	601c                	ld	a5,0(s0)
ffffffffc0200c00:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c04:	e499                	bnez	s1,ffffffffc0200c12 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c06:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c0a:	8b05                	andi	a4,a4,1
ffffffffc0200c0c:	e329                	bnez	a4,ffffffffc0200c4e <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c0e:	6f9c                	ld	a5,24(a5)
ffffffffc0200c10:	eb85                	bnez	a5,ffffffffc0200c40 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c12:	60e2                	ld	ra,24(sp)
ffffffffc0200c14:	6442                	ld	s0,16(sp)
ffffffffc0200c16:	64a2                	ld	s1,8(sp)
ffffffffc0200c18:	6902                	ld	s2,0(sp)
ffffffffc0200c1a:	6105                	addi	sp,sp,32
ffffffffc0200c1c:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c1e:	d41ff0ef          	jal	ra,ffffffffc020095e <interrupt_handler>
ffffffffc0200c22:	bff1                	j	ffffffffc0200bfe <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c24:	0006c863          	bltz	a3,ffffffffc0200c34 <trap+0x66>
}
ffffffffc0200c28:	6442                	ld	s0,16(sp)
ffffffffc0200c2a:	60e2                	ld	ra,24(sp)
ffffffffc0200c2c:	64a2                	ld	s1,8(sp)
ffffffffc0200c2e:	6902                	ld	s2,0(sp)
ffffffffc0200c30:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c32:	bb7d                	j	ffffffffc02009f0 <exception_handler>
}
ffffffffc0200c34:	6442                	ld	s0,16(sp)
ffffffffc0200c36:	60e2                	ld	ra,24(sp)
ffffffffc0200c38:	64a2                	ld	s1,8(sp)
ffffffffc0200c3a:	6902                	ld	s2,0(sp)
ffffffffc0200c3c:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c3e:	b305                	j	ffffffffc020095e <interrupt_handler>
}
ffffffffc0200c40:	6442                	ld	s0,16(sp)
ffffffffc0200c42:	60e2                	ld	ra,24(sp)
ffffffffc0200c44:	64a2                	ld	s1,8(sp)
ffffffffc0200c46:	6902                	ld	s2,0(sp)
ffffffffc0200c48:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c4a:	31c0506f          	j	ffffffffc0205f66 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200c4e:	555d                	li	a0,-9
ffffffffc0200c50:	65c040ef          	jal	ra,ffffffffc02052ac <do_exit>
            if (current->need_resched) {
ffffffffc0200c54:	601c                	ld	a5,0(s0)
ffffffffc0200c56:	bf65                	j	ffffffffc0200c0e <trap+0x40>

ffffffffc0200c58 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200c58:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200c5c:	00011463          	bnez	sp,ffffffffc0200c64 <__alltraps+0xc>
ffffffffc0200c60:	14002173          	csrr	sp,sscratch
ffffffffc0200c64:	712d                	addi	sp,sp,-288
ffffffffc0200c66:	e002                	sd	zero,0(sp)
ffffffffc0200c68:	e406                	sd	ra,8(sp)
ffffffffc0200c6a:	ec0e                	sd	gp,24(sp)
ffffffffc0200c6c:	f012                	sd	tp,32(sp)
ffffffffc0200c6e:	f416                	sd	t0,40(sp)
ffffffffc0200c70:	f81a                	sd	t1,48(sp)
ffffffffc0200c72:	fc1e                	sd	t2,56(sp)
ffffffffc0200c74:	e0a2                	sd	s0,64(sp)
ffffffffc0200c76:	e4a6                	sd	s1,72(sp)
ffffffffc0200c78:	e8aa                	sd	a0,80(sp)
ffffffffc0200c7a:	ecae                	sd	a1,88(sp)
ffffffffc0200c7c:	f0b2                	sd	a2,96(sp)
ffffffffc0200c7e:	f4b6                	sd	a3,104(sp)
ffffffffc0200c80:	f8ba                	sd	a4,112(sp)
ffffffffc0200c82:	fcbe                	sd	a5,120(sp)
ffffffffc0200c84:	e142                	sd	a6,128(sp)
ffffffffc0200c86:	e546                	sd	a7,136(sp)
ffffffffc0200c88:	e94a                	sd	s2,144(sp)
ffffffffc0200c8a:	ed4e                	sd	s3,152(sp)
ffffffffc0200c8c:	f152                	sd	s4,160(sp)
ffffffffc0200c8e:	f556                	sd	s5,168(sp)
ffffffffc0200c90:	f95a                	sd	s6,176(sp)
ffffffffc0200c92:	fd5e                	sd	s7,184(sp)
ffffffffc0200c94:	e1e2                	sd	s8,192(sp)
ffffffffc0200c96:	e5e6                	sd	s9,200(sp)
ffffffffc0200c98:	e9ea                	sd	s10,208(sp)
ffffffffc0200c9a:	edee                	sd	s11,216(sp)
ffffffffc0200c9c:	f1f2                	sd	t3,224(sp)
ffffffffc0200c9e:	f5f6                	sd	t4,232(sp)
ffffffffc0200ca0:	f9fa                	sd	t5,240(sp)
ffffffffc0200ca2:	fdfe                	sd	t6,248(sp)
ffffffffc0200ca4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200ca8:	100024f3          	csrr	s1,sstatus
ffffffffc0200cac:	14102973          	csrr	s2,sepc
ffffffffc0200cb0:	143029f3          	csrr	s3,stval
ffffffffc0200cb4:	14202a73          	csrr	s4,scause
ffffffffc0200cb8:	e822                	sd	s0,16(sp)
ffffffffc0200cba:	e226                	sd	s1,256(sp)
ffffffffc0200cbc:	e64a                	sd	s2,264(sp)
ffffffffc0200cbe:	ea4e                	sd	s3,272(sp)
ffffffffc0200cc0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200cc2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200cc4:	f0bff0ef          	jal	ra,ffffffffc0200bce <trap>

ffffffffc0200cc8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200cc8:	6492                	ld	s1,256(sp)
ffffffffc0200cca:	6932                	ld	s2,264(sp)
ffffffffc0200ccc:	1004f413          	andi	s0,s1,256
ffffffffc0200cd0:	e401                	bnez	s0,ffffffffc0200cd8 <__trapret+0x10>
ffffffffc0200cd2:	1200                	addi	s0,sp,288
ffffffffc0200cd4:	14041073          	csrw	sscratch,s0
ffffffffc0200cd8:	10049073          	csrw	sstatus,s1
ffffffffc0200cdc:	14191073          	csrw	sepc,s2
ffffffffc0200ce0:	60a2                	ld	ra,8(sp)
ffffffffc0200ce2:	61e2                	ld	gp,24(sp)
ffffffffc0200ce4:	7202                	ld	tp,32(sp)
ffffffffc0200ce6:	72a2                	ld	t0,40(sp)
ffffffffc0200ce8:	7342                	ld	t1,48(sp)
ffffffffc0200cea:	73e2                	ld	t2,56(sp)
ffffffffc0200cec:	6406                	ld	s0,64(sp)
ffffffffc0200cee:	64a6                	ld	s1,72(sp)
ffffffffc0200cf0:	6546                	ld	a0,80(sp)
ffffffffc0200cf2:	65e6                	ld	a1,88(sp)
ffffffffc0200cf4:	7606                	ld	a2,96(sp)
ffffffffc0200cf6:	76a6                	ld	a3,104(sp)
ffffffffc0200cf8:	7746                	ld	a4,112(sp)
ffffffffc0200cfa:	77e6                	ld	a5,120(sp)
ffffffffc0200cfc:	680a                	ld	a6,128(sp)
ffffffffc0200cfe:	68aa                	ld	a7,136(sp)
ffffffffc0200d00:	694a                	ld	s2,144(sp)
ffffffffc0200d02:	69ea                	ld	s3,152(sp)
ffffffffc0200d04:	7a0a                	ld	s4,160(sp)
ffffffffc0200d06:	7aaa                	ld	s5,168(sp)
ffffffffc0200d08:	7b4a                	ld	s6,176(sp)
ffffffffc0200d0a:	7bea                	ld	s7,184(sp)
ffffffffc0200d0c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d0e:	6cae                	ld	s9,200(sp)
ffffffffc0200d10:	6d4e                	ld	s10,208(sp)
ffffffffc0200d12:	6dee                	ld	s11,216(sp)
ffffffffc0200d14:	7e0e                	ld	t3,224(sp)
ffffffffc0200d16:	7eae                	ld	t4,232(sp)
ffffffffc0200d18:	7f4e                	ld	t5,240(sp)
ffffffffc0200d1a:	7fee                	ld	t6,248(sp)
ffffffffc0200d1c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d1e:	10200073          	sret

ffffffffc0200d22 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d22:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d24:	b755                	j	ffffffffc0200cc8 <__trapret>

ffffffffc0200d26 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d26:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cf8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d2a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d2e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d32:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d36:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d3a:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d3e:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d42:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d46:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d4a:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200d4c:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200d4e:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200d50:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200d52:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200d54:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200d56:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200d58:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200d5a:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200d5c:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200d5e:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200d60:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200d62:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200d64:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200d66:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200d68:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200d6a:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200d6c:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200d6e:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200d70:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200d72:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200d74:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200d76:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200d78:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200d7a:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200d7c:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200d7e:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200d80:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200d82:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200d84:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200d86:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200d88:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200d8a:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200d8c:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200d8e:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200d90:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200d92:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200d94:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200d96:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200d98:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200d9a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200d9c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200d9e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200da0:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200da2:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200da4:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200da6:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200da8:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200daa:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200dac:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200dae:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200db0:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200db2:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200db4:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200db6:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200db8:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200dba:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200dbc:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200dbe:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200dc0:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200dc2:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200dc4:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200dc6:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200dc8:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200dca:	812e                	mv	sp,a1
ffffffffc0200dcc:	bdf5                	j	ffffffffc0200cc8 <__trapret>

ffffffffc0200dce <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200dce:	000ae797          	auipc	a5,0xae
ffffffffc0200dd2:	b8278793          	addi	a5,a5,-1150 # ffffffffc02ae950 <free_area>
ffffffffc0200dd6:	e79c                	sd	a5,8(a5)
ffffffffc0200dd8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200dda:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200dde:	8082                	ret

ffffffffc0200de0 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200de0:	000ae517          	auipc	a0,0xae
ffffffffc0200de4:	b8056503          	lwu	a0,-1152(a0) # ffffffffc02ae960 <free_area+0x10>
ffffffffc0200de8:	8082                	ret

ffffffffc0200dea <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200dea:	715d                	addi	sp,sp,-80
ffffffffc0200dec:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200dee:	000ae417          	auipc	s0,0xae
ffffffffc0200df2:	b6240413          	addi	s0,s0,-1182 # ffffffffc02ae950 <free_area>
ffffffffc0200df6:	641c                	ld	a5,8(s0)
ffffffffc0200df8:	e486                	sd	ra,72(sp)
ffffffffc0200dfa:	fc26                	sd	s1,56(sp)
ffffffffc0200dfc:	f84a                	sd	s2,48(sp)
ffffffffc0200dfe:	f44e                	sd	s3,40(sp)
ffffffffc0200e00:	f052                	sd	s4,32(sp)
ffffffffc0200e02:	ec56                	sd	s5,24(sp)
ffffffffc0200e04:	e85a                	sd	s6,16(sp)
ffffffffc0200e06:	e45e                	sd	s7,8(sp)
ffffffffc0200e08:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e0a:	2a878d63          	beq	a5,s0,ffffffffc02010c4 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e0e:	4481                	li	s1,0
ffffffffc0200e10:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e12:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e16:	8b09                	andi	a4,a4,2
ffffffffc0200e18:	2a070a63          	beqz	a4,ffffffffc02010cc <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e1c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e20:	679c                	ld	a5,8(a5)
ffffffffc0200e22:	2905                	addiw	s2,s2,1
ffffffffc0200e24:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e26:	fe8796e3          	bne	a5,s0,ffffffffc0200e12 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e2a:	89a6                	mv	s3,s1
ffffffffc0200e2c:	733000ef          	jal	ra,ffffffffc0201d5e <nr_free_pages>
ffffffffc0200e30:	6f351e63          	bne	a0,s3,ffffffffc020152c <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e34:	4505                	li	a0,1
ffffffffc0200e36:	657000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200e3a:	8aaa                	mv	s5,a0
ffffffffc0200e3c:	42050863          	beqz	a0,ffffffffc020126c <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e40:	4505                	li	a0,1
ffffffffc0200e42:	64b000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200e46:	89aa                	mv	s3,a0
ffffffffc0200e48:	70050263          	beqz	a0,ffffffffc020154c <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e4c:	4505                	li	a0,1
ffffffffc0200e4e:	63f000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200e52:	8a2a                	mv	s4,a0
ffffffffc0200e54:	48050c63          	beqz	a0,ffffffffc02012ec <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e58:	293a8a63          	beq	s5,s3,ffffffffc02010ec <default_check+0x302>
ffffffffc0200e5c:	28aa8863          	beq	s5,a0,ffffffffc02010ec <default_check+0x302>
ffffffffc0200e60:	28a98663          	beq	s3,a0,ffffffffc02010ec <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e64:	000aa783          	lw	a5,0(s5)
ffffffffc0200e68:	2a079263          	bnez	a5,ffffffffc020110c <default_check+0x322>
ffffffffc0200e6c:	0009a783          	lw	a5,0(s3)
ffffffffc0200e70:	28079e63          	bnez	a5,ffffffffc020110c <default_check+0x322>
ffffffffc0200e74:	411c                	lw	a5,0(a0)
ffffffffc0200e76:	28079b63          	bnez	a5,ffffffffc020110c <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200e7a:	000b2797          	auipc	a5,0xb2
ffffffffc0200e7e:	bd67b783          	ld	a5,-1066(a5) # ffffffffc02b2a50 <pages>
ffffffffc0200e82:	40fa8733          	sub	a4,s5,a5
ffffffffc0200e86:	00008617          	auipc	a2,0x8
ffffffffc0200e8a:	db263603          	ld	a2,-590(a2) # ffffffffc0208c38 <nbase>
ffffffffc0200e8e:	8719                	srai	a4,a4,0x6
ffffffffc0200e90:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e92:	000b2697          	auipc	a3,0xb2
ffffffffc0200e96:	bb66b683          	ld	a3,-1098(a3) # ffffffffc02b2a48 <npage>
ffffffffc0200e9a:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200e9c:	0732                	slli	a4,a4,0xc
ffffffffc0200e9e:	28d77763          	bgeu	a4,a3,ffffffffc020112c <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ea2:	40f98733          	sub	a4,s3,a5
ffffffffc0200ea6:	8719                	srai	a4,a4,0x6
ffffffffc0200ea8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eaa:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eac:	4cd77063          	bgeu	a4,a3,ffffffffc020136c <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200eb0:	40f507b3          	sub	a5,a0,a5
ffffffffc0200eb4:	8799                	srai	a5,a5,0x6
ffffffffc0200eb6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200eb8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200eba:	30d7f963          	bgeu	a5,a3,ffffffffc02011cc <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200ebe:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ec0:	00043c03          	ld	s8,0(s0)
ffffffffc0200ec4:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ec8:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200ecc:	e400                	sd	s0,8(s0)
ffffffffc0200ece:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200ed0:	000ae797          	auipc	a5,0xae
ffffffffc0200ed4:	a807a823          	sw	zero,-1392(a5) # ffffffffc02ae960 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200ed8:	5b5000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200edc:	2c051863          	bnez	a0,ffffffffc02011ac <default_check+0x3c2>
    free_page(p0);
ffffffffc0200ee0:	4585                	li	a1,1
ffffffffc0200ee2:	8556                	mv	a0,s5
ffffffffc0200ee4:	63b000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    free_page(p1);
ffffffffc0200ee8:	4585                	li	a1,1
ffffffffc0200eea:	854e                	mv	a0,s3
ffffffffc0200eec:	633000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    free_page(p2);
ffffffffc0200ef0:	4585                	li	a1,1
ffffffffc0200ef2:	8552                	mv	a0,s4
ffffffffc0200ef4:	62b000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    assert(nr_free == 3);
ffffffffc0200ef8:	4818                	lw	a4,16(s0)
ffffffffc0200efa:	478d                	li	a5,3
ffffffffc0200efc:	28f71863          	bne	a4,a5,ffffffffc020118c <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f00:	4505                	li	a0,1
ffffffffc0200f02:	58b000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200f06:	89aa                	mv	s3,a0
ffffffffc0200f08:	26050263          	beqz	a0,ffffffffc020116c <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f0c:	4505                	li	a0,1
ffffffffc0200f0e:	57f000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200f12:	8aaa                	mv	s5,a0
ffffffffc0200f14:	3a050c63          	beqz	a0,ffffffffc02012cc <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f18:	4505                	li	a0,1
ffffffffc0200f1a:	573000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200f1e:	8a2a                	mv	s4,a0
ffffffffc0200f20:	38050663          	beqz	a0,ffffffffc02012ac <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f24:	4505                	li	a0,1
ffffffffc0200f26:	567000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200f2a:	36051163          	bnez	a0,ffffffffc020128c <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f2e:	4585                	li	a1,1
ffffffffc0200f30:	854e                	mv	a0,s3
ffffffffc0200f32:	5ed000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f36:	641c                	ld	a5,8(s0)
ffffffffc0200f38:	20878a63          	beq	a5,s0,ffffffffc020114c <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f3c:	4505                	li	a0,1
ffffffffc0200f3e:	54f000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200f42:	30a99563          	bne	s3,a0,ffffffffc020124c <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f46:	4505                	li	a0,1
ffffffffc0200f48:	545000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200f4c:	2e051063          	bnez	a0,ffffffffc020122c <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200f50:	481c                	lw	a5,16(s0)
ffffffffc0200f52:	2a079d63          	bnez	a5,ffffffffc020120c <default_check+0x422>
    free_page(p);
ffffffffc0200f56:	854e                	mv	a0,s3
ffffffffc0200f58:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200f5a:	01843023          	sd	s8,0(s0)
ffffffffc0200f5e:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200f62:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200f66:	5b9000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    free_page(p1);
ffffffffc0200f6a:	4585                	li	a1,1
ffffffffc0200f6c:	8556                	mv	a0,s5
ffffffffc0200f6e:	5b1000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    free_page(p2);
ffffffffc0200f72:	4585                	li	a1,1
ffffffffc0200f74:	8552                	mv	a0,s4
ffffffffc0200f76:	5a9000ef          	jal	ra,ffffffffc0201d1e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200f7a:	4515                	li	a0,5
ffffffffc0200f7c:	511000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200f80:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200f82:	26050563          	beqz	a0,ffffffffc02011ec <default_check+0x402>
ffffffffc0200f86:	651c                	ld	a5,8(a0)
ffffffffc0200f88:	8385                	srli	a5,a5,0x1
ffffffffc0200f8a:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0200f8c:	54079063          	bnez	a5,ffffffffc02014cc <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200f90:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f92:	00043b03          	ld	s6,0(s0)
ffffffffc0200f96:	00843a83          	ld	s5,8(s0)
ffffffffc0200f9a:	e000                	sd	s0,0(s0)
ffffffffc0200f9c:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200f9e:	4ef000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200fa2:	50051563          	bnez	a0,ffffffffc02014ac <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200fa6:	08098a13          	addi	s4,s3,128
ffffffffc0200faa:	8552                	mv	a0,s4
ffffffffc0200fac:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200fae:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200fb2:	000ae797          	auipc	a5,0xae
ffffffffc0200fb6:	9a07a723          	sw	zero,-1618(a5) # ffffffffc02ae960 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200fba:	565000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200fbe:	4511                	li	a0,4
ffffffffc0200fc0:	4cd000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200fc4:	4c051463          	bnez	a0,ffffffffc020148c <default_check+0x6a2>
ffffffffc0200fc8:	0889b783          	ld	a5,136(s3)
ffffffffc0200fcc:	8385                	srli	a5,a5,0x1
ffffffffc0200fce:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200fd0:	48078e63          	beqz	a5,ffffffffc020146c <default_check+0x682>
ffffffffc0200fd4:	0909a703          	lw	a4,144(s3)
ffffffffc0200fd8:	478d                	li	a5,3
ffffffffc0200fda:	48f71963          	bne	a4,a5,ffffffffc020146c <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200fde:	450d                	li	a0,3
ffffffffc0200fe0:	4ad000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200fe4:	8c2a                	mv	s8,a0
ffffffffc0200fe6:	46050363          	beqz	a0,ffffffffc020144c <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0200fea:	4505                	li	a0,1
ffffffffc0200fec:	4a1000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0200ff0:	42051e63          	bnez	a0,ffffffffc020142c <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0200ff4:	418a1c63          	bne	s4,s8,ffffffffc020140c <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200ff8:	4585                	li	a1,1
ffffffffc0200ffa:	854e                	mv	a0,s3
ffffffffc0200ffc:	523000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    free_pages(p1, 3);
ffffffffc0201000:	458d                	li	a1,3
ffffffffc0201002:	8552                	mv	a0,s4
ffffffffc0201004:	51b000ef          	jal	ra,ffffffffc0201d1e <free_pages>
ffffffffc0201008:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc020100c:	04098c13          	addi	s8,s3,64
ffffffffc0201010:	8385                	srli	a5,a5,0x1
ffffffffc0201012:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201014:	3c078c63          	beqz	a5,ffffffffc02013ec <default_check+0x602>
ffffffffc0201018:	0109a703          	lw	a4,16(s3)
ffffffffc020101c:	4785                	li	a5,1
ffffffffc020101e:	3cf71763          	bne	a4,a5,ffffffffc02013ec <default_check+0x602>
ffffffffc0201022:	008a3783          	ld	a5,8(s4)
ffffffffc0201026:	8385                	srli	a5,a5,0x1
ffffffffc0201028:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020102a:	3a078163          	beqz	a5,ffffffffc02013cc <default_check+0x5e2>
ffffffffc020102e:	010a2703          	lw	a4,16(s4)
ffffffffc0201032:	478d                	li	a5,3
ffffffffc0201034:	38f71c63          	bne	a4,a5,ffffffffc02013cc <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201038:	4505                	li	a0,1
ffffffffc020103a:	453000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc020103e:	36a99763          	bne	s3,a0,ffffffffc02013ac <default_check+0x5c2>
    free_page(p0);
ffffffffc0201042:	4585                	li	a1,1
ffffffffc0201044:	4db000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201048:	4509                	li	a0,2
ffffffffc020104a:	443000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc020104e:	32aa1f63          	bne	s4,a0,ffffffffc020138c <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc0201052:	4589                	li	a1,2
ffffffffc0201054:	4cb000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    free_page(p2);
ffffffffc0201058:	4585                	li	a1,1
ffffffffc020105a:	8562                	mv	a0,s8
ffffffffc020105c:	4c3000ef          	jal	ra,ffffffffc0201d1e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201060:	4515                	li	a0,5
ffffffffc0201062:	42b000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0201066:	89aa                	mv	s3,a0
ffffffffc0201068:	48050263          	beqz	a0,ffffffffc02014ec <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc020106c:	4505                	li	a0,1
ffffffffc020106e:	41f000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0201072:	2c051d63          	bnez	a0,ffffffffc020134c <default_check+0x562>

    assert(nr_free == 0);
ffffffffc0201076:	481c                	lw	a5,16(s0)
ffffffffc0201078:	2a079a63          	bnez	a5,ffffffffc020132c <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020107c:	4595                	li	a1,5
ffffffffc020107e:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201080:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201084:	01643023          	sd	s6,0(s0)
ffffffffc0201088:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc020108c:	493000ef          	jal	ra,ffffffffc0201d1e <free_pages>
    return listelm->next;
ffffffffc0201090:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201092:	00878963          	beq	a5,s0,ffffffffc02010a4 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201096:	ff87a703          	lw	a4,-8(a5)
ffffffffc020109a:	679c                	ld	a5,8(a5)
ffffffffc020109c:	397d                	addiw	s2,s2,-1
ffffffffc020109e:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010a0:	fe879be3          	bne	a5,s0,ffffffffc0201096 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010a4:	26091463          	bnez	s2,ffffffffc020130c <default_check+0x522>
    assert(total == 0);
ffffffffc02010a8:	46049263          	bnez	s1,ffffffffc020150c <default_check+0x722>
}
ffffffffc02010ac:	60a6                	ld	ra,72(sp)
ffffffffc02010ae:	6406                	ld	s0,64(sp)
ffffffffc02010b0:	74e2                	ld	s1,56(sp)
ffffffffc02010b2:	7942                	ld	s2,48(sp)
ffffffffc02010b4:	79a2                	ld	s3,40(sp)
ffffffffc02010b6:	7a02                	ld	s4,32(sp)
ffffffffc02010b8:	6ae2                	ld	s5,24(sp)
ffffffffc02010ba:	6b42                	ld	s6,16(sp)
ffffffffc02010bc:	6ba2                	ld	s7,8(sp)
ffffffffc02010be:	6c02                	ld	s8,0(sp)
ffffffffc02010c0:	6161                	addi	sp,sp,80
ffffffffc02010c2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010c4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02010c6:	4481                	li	s1,0
ffffffffc02010c8:	4901                	li	s2,0
ffffffffc02010ca:	b38d                	j	ffffffffc0200e2c <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02010cc:	00006697          	auipc	a3,0x6
ffffffffc02010d0:	e5c68693          	addi	a3,a3,-420 # ffffffffc0206f28 <commands+0x740>
ffffffffc02010d4:	00006617          	auipc	a2,0x6
ffffffffc02010d8:	b6460613          	addi	a2,a2,-1180 # ffffffffc0206c38 <commands+0x450>
ffffffffc02010dc:	0f000593          	li	a1,240
ffffffffc02010e0:	00006517          	auipc	a0,0x6
ffffffffc02010e4:	e5850513          	addi	a0,a0,-424 # ffffffffc0206f38 <commands+0x750>
ffffffffc02010e8:	b92ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02010ec:	00006697          	auipc	a3,0x6
ffffffffc02010f0:	ee468693          	addi	a3,a3,-284 # ffffffffc0206fd0 <commands+0x7e8>
ffffffffc02010f4:	00006617          	auipc	a2,0x6
ffffffffc02010f8:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206c38 <commands+0x450>
ffffffffc02010fc:	0bd00593          	li	a1,189
ffffffffc0201100:	00006517          	auipc	a0,0x6
ffffffffc0201104:	e3850513          	addi	a0,a0,-456 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201108:	b72ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020110c:	00006697          	auipc	a3,0x6
ffffffffc0201110:	eec68693          	addi	a3,a3,-276 # ffffffffc0206ff8 <commands+0x810>
ffffffffc0201114:	00006617          	auipc	a2,0x6
ffffffffc0201118:	b2460613          	addi	a2,a2,-1244 # ffffffffc0206c38 <commands+0x450>
ffffffffc020111c:	0be00593          	li	a1,190
ffffffffc0201120:	00006517          	auipc	a0,0x6
ffffffffc0201124:	e1850513          	addi	a0,a0,-488 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201128:	b52ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020112c:	00006697          	auipc	a3,0x6
ffffffffc0201130:	f0c68693          	addi	a3,a3,-244 # ffffffffc0207038 <commands+0x850>
ffffffffc0201134:	00006617          	auipc	a2,0x6
ffffffffc0201138:	b0460613          	addi	a2,a2,-1276 # ffffffffc0206c38 <commands+0x450>
ffffffffc020113c:	0c000593          	li	a1,192
ffffffffc0201140:	00006517          	auipc	a0,0x6
ffffffffc0201144:	df850513          	addi	a0,a0,-520 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201148:	b32ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!list_empty(&free_list));
ffffffffc020114c:	00006697          	auipc	a3,0x6
ffffffffc0201150:	f7468693          	addi	a3,a3,-140 # ffffffffc02070c0 <commands+0x8d8>
ffffffffc0201154:	00006617          	auipc	a2,0x6
ffffffffc0201158:	ae460613          	addi	a2,a2,-1308 # ffffffffc0206c38 <commands+0x450>
ffffffffc020115c:	0d900593          	li	a1,217
ffffffffc0201160:	00006517          	auipc	a0,0x6
ffffffffc0201164:	dd850513          	addi	a0,a0,-552 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201168:	b12ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020116c:	00006697          	auipc	a3,0x6
ffffffffc0201170:	e0468693          	addi	a3,a3,-508 # ffffffffc0206f70 <commands+0x788>
ffffffffc0201174:	00006617          	auipc	a2,0x6
ffffffffc0201178:	ac460613          	addi	a2,a2,-1340 # ffffffffc0206c38 <commands+0x450>
ffffffffc020117c:	0d200593          	li	a1,210
ffffffffc0201180:	00006517          	auipc	a0,0x6
ffffffffc0201184:	db850513          	addi	a0,a0,-584 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201188:	af2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 3);
ffffffffc020118c:	00006697          	auipc	a3,0x6
ffffffffc0201190:	f2468693          	addi	a3,a3,-220 # ffffffffc02070b0 <commands+0x8c8>
ffffffffc0201194:	00006617          	auipc	a2,0x6
ffffffffc0201198:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206c38 <commands+0x450>
ffffffffc020119c:	0d000593          	li	a1,208
ffffffffc02011a0:	00006517          	auipc	a0,0x6
ffffffffc02011a4:	d9850513          	addi	a0,a0,-616 # ffffffffc0206f38 <commands+0x750>
ffffffffc02011a8:	ad2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011ac:	00006697          	auipc	a3,0x6
ffffffffc02011b0:	eec68693          	addi	a3,a3,-276 # ffffffffc0207098 <commands+0x8b0>
ffffffffc02011b4:	00006617          	auipc	a2,0x6
ffffffffc02011b8:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206c38 <commands+0x450>
ffffffffc02011bc:	0cb00593          	li	a1,203
ffffffffc02011c0:	00006517          	auipc	a0,0x6
ffffffffc02011c4:	d7850513          	addi	a0,a0,-648 # ffffffffc0206f38 <commands+0x750>
ffffffffc02011c8:	ab2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02011cc:	00006697          	auipc	a3,0x6
ffffffffc02011d0:	eac68693          	addi	a3,a3,-340 # ffffffffc0207078 <commands+0x890>
ffffffffc02011d4:	00006617          	auipc	a2,0x6
ffffffffc02011d8:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206c38 <commands+0x450>
ffffffffc02011dc:	0c200593          	li	a1,194
ffffffffc02011e0:	00006517          	auipc	a0,0x6
ffffffffc02011e4:	d5850513          	addi	a0,a0,-680 # ffffffffc0206f38 <commands+0x750>
ffffffffc02011e8:	a92ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != NULL);
ffffffffc02011ec:	00006697          	auipc	a3,0x6
ffffffffc02011f0:	f1c68693          	addi	a3,a3,-228 # ffffffffc0207108 <commands+0x920>
ffffffffc02011f4:	00006617          	auipc	a2,0x6
ffffffffc02011f8:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206c38 <commands+0x450>
ffffffffc02011fc:	0f800593          	li	a1,248
ffffffffc0201200:	00006517          	auipc	a0,0x6
ffffffffc0201204:	d3850513          	addi	a0,a0,-712 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201208:	a72ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc020120c:	00006697          	auipc	a3,0x6
ffffffffc0201210:	eec68693          	addi	a3,a3,-276 # ffffffffc02070f8 <commands+0x910>
ffffffffc0201214:	00006617          	auipc	a2,0x6
ffffffffc0201218:	a2460613          	addi	a2,a2,-1500 # ffffffffc0206c38 <commands+0x450>
ffffffffc020121c:	0df00593          	li	a1,223
ffffffffc0201220:	00006517          	auipc	a0,0x6
ffffffffc0201224:	d1850513          	addi	a0,a0,-744 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201228:	a52ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020122c:	00006697          	auipc	a3,0x6
ffffffffc0201230:	e6c68693          	addi	a3,a3,-404 # ffffffffc0207098 <commands+0x8b0>
ffffffffc0201234:	00006617          	auipc	a2,0x6
ffffffffc0201238:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206c38 <commands+0x450>
ffffffffc020123c:	0dd00593          	li	a1,221
ffffffffc0201240:	00006517          	auipc	a0,0x6
ffffffffc0201244:	cf850513          	addi	a0,a0,-776 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201248:	a32ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020124c:	00006697          	auipc	a3,0x6
ffffffffc0201250:	e8c68693          	addi	a3,a3,-372 # ffffffffc02070d8 <commands+0x8f0>
ffffffffc0201254:	00006617          	auipc	a2,0x6
ffffffffc0201258:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206c38 <commands+0x450>
ffffffffc020125c:	0dc00593          	li	a1,220
ffffffffc0201260:	00006517          	auipc	a0,0x6
ffffffffc0201264:	cd850513          	addi	a0,a0,-808 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201268:	a12ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020126c:	00006697          	auipc	a3,0x6
ffffffffc0201270:	d0468693          	addi	a3,a3,-764 # ffffffffc0206f70 <commands+0x788>
ffffffffc0201274:	00006617          	auipc	a2,0x6
ffffffffc0201278:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206c38 <commands+0x450>
ffffffffc020127c:	0b900593          	li	a1,185
ffffffffc0201280:	00006517          	auipc	a0,0x6
ffffffffc0201284:	cb850513          	addi	a0,a0,-840 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201288:	9f2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020128c:	00006697          	auipc	a3,0x6
ffffffffc0201290:	e0c68693          	addi	a3,a3,-500 # ffffffffc0207098 <commands+0x8b0>
ffffffffc0201294:	00006617          	auipc	a2,0x6
ffffffffc0201298:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206c38 <commands+0x450>
ffffffffc020129c:	0d600593          	li	a1,214
ffffffffc02012a0:	00006517          	auipc	a0,0x6
ffffffffc02012a4:	c9850513          	addi	a0,a0,-872 # ffffffffc0206f38 <commands+0x750>
ffffffffc02012a8:	9d2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012ac:	00006697          	auipc	a3,0x6
ffffffffc02012b0:	d0468693          	addi	a3,a3,-764 # ffffffffc0206fb0 <commands+0x7c8>
ffffffffc02012b4:	00006617          	auipc	a2,0x6
ffffffffc02012b8:	98460613          	addi	a2,a2,-1660 # ffffffffc0206c38 <commands+0x450>
ffffffffc02012bc:	0d400593          	li	a1,212
ffffffffc02012c0:	00006517          	auipc	a0,0x6
ffffffffc02012c4:	c7850513          	addi	a0,a0,-904 # ffffffffc0206f38 <commands+0x750>
ffffffffc02012c8:	9b2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012cc:	00006697          	auipc	a3,0x6
ffffffffc02012d0:	cc468693          	addi	a3,a3,-828 # ffffffffc0206f90 <commands+0x7a8>
ffffffffc02012d4:	00006617          	auipc	a2,0x6
ffffffffc02012d8:	96460613          	addi	a2,a2,-1692 # ffffffffc0206c38 <commands+0x450>
ffffffffc02012dc:	0d300593          	li	a1,211
ffffffffc02012e0:	00006517          	auipc	a0,0x6
ffffffffc02012e4:	c5850513          	addi	a0,a0,-936 # ffffffffc0206f38 <commands+0x750>
ffffffffc02012e8:	992ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02012ec:	00006697          	auipc	a3,0x6
ffffffffc02012f0:	cc468693          	addi	a3,a3,-828 # ffffffffc0206fb0 <commands+0x7c8>
ffffffffc02012f4:	00006617          	auipc	a2,0x6
ffffffffc02012f8:	94460613          	addi	a2,a2,-1724 # ffffffffc0206c38 <commands+0x450>
ffffffffc02012fc:	0bb00593          	li	a1,187
ffffffffc0201300:	00006517          	auipc	a0,0x6
ffffffffc0201304:	c3850513          	addi	a0,a0,-968 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201308:	972ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(count == 0);
ffffffffc020130c:	00006697          	auipc	a3,0x6
ffffffffc0201310:	f4c68693          	addi	a3,a3,-180 # ffffffffc0207258 <commands+0xa70>
ffffffffc0201314:	00006617          	auipc	a2,0x6
ffffffffc0201318:	92460613          	addi	a2,a2,-1756 # ffffffffc0206c38 <commands+0x450>
ffffffffc020131c:	12500593          	li	a1,293
ffffffffc0201320:	00006517          	auipc	a0,0x6
ffffffffc0201324:	c1850513          	addi	a0,a0,-1000 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201328:	952ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc020132c:	00006697          	auipc	a3,0x6
ffffffffc0201330:	dcc68693          	addi	a3,a3,-564 # ffffffffc02070f8 <commands+0x910>
ffffffffc0201334:	00006617          	auipc	a2,0x6
ffffffffc0201338:	90460613          	addi	a2,a2,-1788 # ffffffffc0206c38 <commands+0x450>
ffffffffc020133c:	11a00593          	li	a1,282
ffffffffc0201340:	00006517          	auipc	a0,0x6
ffffffffc0201344:	bf850513          	addi	a0,a0,-1032 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201348:	932ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020134c:	00006697          	auipc	a3,0x6
ffffffffc0201350:	d4c68693          	addi	a3,a3,-692 # ffffffffc0207098 <commands+0x8b0>
ffffffffc0201354:	00006617          	auipc	a2,0x6
ffffffffc0201358:	8e460613          	addi	a2,a2,-1820 # ffffffffc0206c38 <commands+0x450>
ffffffffc020135c:	11800593          	li	a1,280
ffffffffc0201360:	00006517          	auipc	a0,0x6
ffffffffc0201364:	bd850513          	addi	a0,a0,-1064 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201368:	912ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020136c:	00006697          	auipc	a3,0x6
ffffffffc0201370:	cec68693          	addi	a3,a3,-788 # ffffffffc0207058 <commands+0x870>
ffffffffc0201374:	00006617          	auipc	a2,0x6
ffffffffc0201378:	8c460613          	addi	a2,a2,-1852 # ffffffffc0206c38 <commands+0x450>
ffffffffc020137c:	0c100593          	li	a1,193
ffffffffc0201380:	00006517          	auipc	a0,0x6
ffffffffc0201384:	bb850513          	addi	a0,a0,-1096 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201388:	8f2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020138c:	00006697          	auipc	a3,0x6
ffffffffc0201390:	e8c68693          	addi	a3,a3,-372 # ffffffffc0207218 <commands+0xa30>
ffffffffc0201394:	00006617          	auipc	a2,0x6
ffffffffc0201398:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206c38 <commands+0x450>
ffffffffc020139c:	11200593          	li	a1,274
ffffffffc02013a0:	00006517          	auipc	a0,0x6
ffffffffc02013a4:	b9850513          	addi	a0,a0,-1128 # ffffffffc0206f38 <commands+0x750>
ffffffffc02013a8:	8d2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02013ac:	00006697          	auipc	a3,0x6
ffffffffc02013b0:	e4c68693          	addi	a3,a3,-436 # ffffffffc02071f8 <commands+0xa10>
ffffffffc02013b4:	00006617          	auipc	a2,0x6
ffffffffc02013b8:	88460613          	addi	a2,a2,-1916 # ffffffffc0206c38 <commands+0x450>
ffffffffc02013bc:	11000593          	li	a1,272
ffffffffc02013c0:	00006517          	auipc	a0,0x6
ffffffffc02013c4:	b7850513          	addi	a0,a0,-1160 # ffffffffc0206f38 <commands+0x750>
ffffffffc02013c8:	8b2ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02013cc:	00006697          	auipc	a3,0x6
ffffffffc02013d0:	e0468693          	addi	a3,a3,-508 # ffffffffc02071d0 <commands+0x9e8>
ffffffffc02013d4:	00006617          	auipc	a2,0x6
ffffffffc02013d8:	86460613          	addi	a2,a2,-1948 # ffffffffc0206c38 <commands+0x450>
ffffffffc02013dc:	10e00593          	li	a1,270
ffffffffc02013e0:	00006517          	auipc	a0,0x6
ffffffffc02013e4:	b5850513          	addi	a0,a0,-1192 # ffffffffc0206f38 <commands+0x750>
ffffffffc02013e8:	892ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02013ec:	00006697          	auipc	a3,0x6
ffffffffc02013f0:	dbc68693          	addi	a3,a3,-580 # ffffffffc02071a8 <commands+0x9c0>
ffffffffc02013f4:	00006617          	auipc	a2,0x6
ffffffffc02013f8:	84460613          	addi	a2,a2,-1980 # ffffffffc0206c38 <commands+0x450>
ffffffffc02013fc:	10d00593          	li	a1,269
ffffffffc0201400:	00006517          	auipc	a0,0x6
ffffffffc0201404:	b3850513          	addi	a0,a0,-1224 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201408:	872ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 + 2 == p1);
ffffffffc020140c:	00006697          	auipc	a3,0x6
ffffffffc0201410:	d8c68693          	addi	a3,a3,-628 # ffffffffc0207198 <commands+0x9b0>
ffffffffc0201414:	00006617          	auipc	a2,0x6
ffffffffc0201418:	82460613          	addi	a2,a2,-2012 # ffffffffc0206c38 <commands+0x450>
ffffffffc020141c:	10800593          	li	a1,264
ffffffffc0201420:	00006517          	auipc	a0,0x6
ffffffffc0201424:	b1850513          	addi	a0,a0,-1256 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201428:	852ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc020142c:	00006697          	auipc	a3,0x6
ffffffffc0201430:	c6c68693          	addi	a3,a3,-916 # ffffffffc0207098 <commands+0x8b0>
ffffffffc0201434:	00006617          	auipc	a2,0x6
ffffffffc0201438:	80460613          	addi	a2,a2,-2044 # ffffffffc0206c38 <commands+0x450>
ffffffffc020143c:	10700593          	li	a1,263
ffffffffc0201440:	00006517          	auipc	a0,0x6
ffffffffc0201444:	af850513          	addi	a0,a0,-1288 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201448:	832ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020144c:	00006697          	auipc	a3,0x6
ffffffffc0201450:	d2c68693          	addi	a3,a3,-724 # ffffffffc0207178 <commands+0x990>
ffffffffc0201454:	00005617          	auipc	a2,0x5
ffffffffc0201458:	7e460613          	addi	a2,a2,2020 # ffffffffc0206c38 <commands+0x450>
ffffffffc020145c:	10600593          	li	a1,262
ffffffffc0201460:	00006517          	auipc	a0,0x6
ffffffffc0201464:	ad850513          	addi	a0,a0,-1320 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201468:	812ff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020146c:	00006697          	auipc	a3,0x6
ffffffffc0201470:	cdc68693          	addi	a3,a3,-804 # ffffffffc0207148 <commands+0x960>
ffffffffc0201474:	00005617          	auipc	a2,0x5
ffffffffc0201478:	7c460613          	addi	a2,a2,1988 # ffffffffc0206c38 <commands+0x450>
ffffffffc020147c:	10500593          	li	a1,261
ffffffffc0201480:	00006517          	auipc	a0,0x6
ffffffffc0201484:	ab850513          	addi	a0,a0,-1352 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201488:	ff3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020148c:	00006697          	auipc	a3,0x6
ffffffffc0201490:	ca468693          	addi	a3,a3,-860 # ffffffffc0207130 <commands+0x948>
ffffffffc0201494:	00005617          	auipc	a2,0x5
ffffffffc0201498:	7a460613          	addi	a2,a2,1956 # ffffffffc0206c38 <commands+0x450>
ffffffffc020149c:	10400593          	li	a1,260
ffffffffc02014a0:	00006517          	auipc	a0,0x6
ffffffffc02014a4:	a9850513          	addi	a0,a0,-1384 # ffffffffc0206f38 <commands+0x750>
ffffffffc02014a8:	fd3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014ac:	00006697          	auipc	a3,0x6
ffffffffc02014b0:	bec68693          	addi	a3,a3,-1044 # ffffffffc0207098 <commands+0x8b0>
ffffffffc02014b4:	00005617          	auipc	a2,0x5
ffffffffc02014b8:	78460613          	addi	a2,a2,1924 # ffffffffc0206c38 <commands+0x450>
ffffffffc02014bc:	0fe00593          	li	a1,254
ffffffffc02014c0:	00006517          	auipc	a0,0x6
ffffffffc02014c4:	a7850513          	addi	a0,a0,-1416 # ffffffffc0206f38 <commands+0x750>
ffffffffc02014c8:	fb3fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!PageProperty(p0));
ffffffffc02014cc:	00006697          	auipc	a3,0x6
ffffffffc02014d0:	c4c68693          	addi	a3,a3,-948 # ffffffffc0207118 <commands+0x930>
ffffffffc02014d4:	00005617          	auipc	a2,0x5
ffffffffc02014d8:	76460613          	addi	a2,a2,1892 # ffffffffc0206c38 <commands+0x450>
ffffffffc02014dc:	0f900593          	li	a1,249
ffffffffc02014e0:	00006517          	auipc	a0,0x6
ffffffffc02014e4:	a5850513          	addi	a0,a0,-1448 # ffffffffc0206f38 <commands+0x750>
ffffffffc02014e8:	f93fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02014ec:	00006697          	auipc	a3,0x6
ffffffffc02014f0:	d4c68693          	addi	a3,a3,-692 # ffffffffc0207238 <commands+0xa50>
ffffffffc02014f4:	00005617          	auipc	a2,0x5
ffffffffc02014f8:	74460613          	addi	a2,a2,1860 # ffffffffc0206c38 <commands+0x450>
ffffffffc02014fc:	11700593          	li	a1,279
ffffffffc0201500:	00006517          	auipc	a0,0x6
ffffffffc0201504:	a3850513          	addi	a0,a0,-1480 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201508:	f73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == 0);
ffffffffc020150c:	00006697          	auipc	a3,0x6
ffffffffc0201510:	d5c68693          	addi	a3,a3,-676 # ffffffffc0207268 <commands+0xa80>
ffffffffc0201514:	00005617          	auipc	a2,0x5
ffffffffc0201518:	72460613          	addi	a2,a2,1828 # ffffffffc0206c38 <commands+0x450>
ffffffffc020151c:	12600593          	li	a1,294
ffffffffc0201520:	00006517          	auipc	a0,0x6
ffffffffc0201524:	a1850513          	addi	a0,a0,-1512 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201528:	f53fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == nr_free_pages());
ffffffffc020152c:	00006697          	auipc	a3,0x6
ffffffffc0201530:	a2468693          	addi	a3,a3,-1500 # ffffffffc0206f50 <commands+0x768>
ffffffffc0201534:	00005617          	auipc	a2,0x5
ffffffffc0201538:	70460613          	addi	a2,a2,1796 # ffffffffc0206c38 <commands+0x450>
ffffffffc020153c:	0f300593          	li	a1,243
ffffffffc0201540:	00006517          	auipc	a0,0x6
ffffffffc0201544:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201548:	f33fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020154c:	00006697          	auipc	a3,0x6
ffffffffc0201550:	a4468693          	addi	a3,a3,-1468 # ffffffffc0206f90 <commands+0x7a8>
ffffffffc0201554:	00005617          	auipc	a2,0x5
ffffffffc0201558:	6e460613          	addi	a2,a2,1764 # ffffffffc0206c38 <commands+0x450>
ffffffffc020155c:	0ba00593          	li	a1,186
ffffffffc0201560:	00006517          	auipc	a0,0x6
ffffffffc0201564:	9d850513          	addi	a0,a0,-1576 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201568:	f13fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020156c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020156c:	1141                	addi	sp,sp,-16
ffffffffc020156e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201570:	14058463          	beqz	a1,ffffffffc02016b8 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0201574:	00659693          	slli	a3,a1,0x6
ffffffffc0201578:	96aa                	add	a3,a3,a0
ffffffffc020157a:	87aa                	mv	a5,a0
ffffffffc020157c:	02d50263          	beq	a0,a3,ffffffffc02015a0 <default_free_pages+0x34>
ffffffffc0201580:	6798                	ld	a4,8(a5)
ffffffffc0201582:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201584:	10071a63          	bnez	a4,ffffffffc0201698 <default_free_pages+0x12c>
ffffffffc0201588:	6798                	ld	a4,8(a5)
ffffffffc020158a:	8b09                	andi	a4,a4,2
ffffffffc020158c:	10071663          	bnez	a4,ffffffffc0201698 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0201590:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201594:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201598:	04078793          	addi	a5,a5,64
ffffffffc020159c:	fed792e3          	bne	a5,a3,ffffffffc0201580 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015a0:	2581                	sext.w	a1,a1
ffffffffc02015a2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015a4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015a8:	4789                	li	a5,2
ffffffffc02015aa:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02015ae:	000ad697          	auipc	a3,0xad
ffffffffc02015b2:	3a268693          	addi	a3,a3,930 # ffffffffc02ae950 <free_area>
ffffffffc02015b6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015b8:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02015ba:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02015be:	9db9                	addw	a1,a1,a4
ffffffffc02015c0:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02015c2:	0ad78463          	beq	a5,a3,ffffffffc020166a <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc02015c6:	fe878713          	addi	a4,a5,-24
ffffffffc02015ca:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ce:	4581                	li	a1,0
            if (base < page) {
ffffffffc02015d0:	00e56a63          	bltu	a0,a4,ffffffffc02015e4 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02015d4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015d6:	04d70c63          	beq	a4,a3,ffffffffc020162e <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc02015da:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015dc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02015e0:	fee57ae3          	bgeu	a0,a4,ffffffffc02015d4 <default_free_pages+0x68>
ffffffffc02015e4:	c199                	beqz	a1,ffffffffc02015ea <default_free_pages+0x7e>
ffffffffc02015e6:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015ea:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02015ec:	e390                	sd	a2,0(a5)
ffffffffc02015ee:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015f0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015f2:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc02015f4:	00d70d63          	beq	a4,a3,ffffffffc020160e <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc02015f8:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc02015fc:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201600:	02059813          	slli	a6,a1,0x20
ffffffffc0201604:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201608:	97b2                	add	a5,a5,a2
ffffffffc020160a:	02f50c63          	beq	a0,a5,ffffffffc0201642 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc020160e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201610:	00d78c63          	beq	a5,a3,ffffffffc0201628 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201614:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0201616:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020161a:	02061593          	slli	a1,a2,0x20
ffffffffc020161e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201622:	972a                	add	a4,a4,a0
ffffffffc0201624:	04e68a63          	beq	a3,a4,ffffffffc0201678 <default_free_pages+0x10c>
}
ffffffffc0201628:	60a2                	ld	ra,8(sp)
ffffffffc020162a:	0141                	addi	sp,sp,16
ffffffffc020162c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020162e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201630:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201632:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201634:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201636:	02d70763          	beq	a4,a3,ffffffffc0201664 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020163a:	8832                	mv	a6,a2
ffffffffc020163c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020163e:	87ba                	mv	a5,a4
ffffffffc0201640:	bf71                	j	ffffffffc02015dc <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201642:	491c                	lw	a5,16(a0)
ffffffffc0201644:	9dbd                	addw	a1,a1,a5
ffffffffc0201646:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020164a:	57f5                	li	a5,-3
ffffffffc020164c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201650:	01853803          	ld	a6,24(a0)
ffffffffc0201654:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0201656:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201658:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc020165c:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc020165e:	0105b023          	sd	a6,0(a1)
ffffffffc0201662:	b77d                	j	ffffffffc0201610 <default_free_pages+0xa4>
ffffffffc0201664:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201666:	873e                	mv	a4,a5
ffffffffc0201668:	bf41                	j	ffffffffc02015f8 <default_free_pages+0x8c>
}
ffffffffc020166a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020166c:	e390                	sd	a2,0(a5)
ffffffffc020166e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201670:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201672:	ed1c                	sd	a5,24(a0)
ffffffffc0201674:	0141                	addi	sp,sp,16
ffffffffc0201676:	8082                	ret
            base->property += p->property;
ffffffffc0201678:	ff87a703          	lw	a4,-8(a5)
ffffffffc020167c:	ff078693          	addi	a3,a5,-16
ffffffffc0201680:	9e39                	addw	a2,a2,a4
ffffffffc0201682:	c910                	sw	a2,16(a0)
ffffffffc0201684:	5775                	li	a4,-3
ffffffffc0201686:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020168a:	6398                	ld	a4,0(a5)
ffffffffc020168c:	679c                	ld	a5,8(a5)
}
ffffffffc020168e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201690:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201692:	e398                	sd	a4,0(a5)
ffffffffc0201694:	0141                	addi	sp,sp,16
ffffffffc0201696:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201698:	00006697          	auipc	a3,0x6
ffffffffc020169c:	be868693          	addi	a3,a3,-1048 # ffffffffc0207280 <commands+0xa98>
ffffffffc02016a0:	00005617          	auipc	a2,0x5
ffffffffc02016a4:	59860613          	addi	a2,a2,1432 # ffffffffc0206c38 <commands+0x450>
ffffffffc02016a8:	08300593          	li	a1,131
ffffffffc02016ac:	00006517          	auipc	a0,0x6
ffffffffc02016b0:	88c50513          	addi	a0,a0,-1908 # ffffffffc0206f38 <commands+0x750>
ffffffffc02016b4:	dc7fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc02016b8:	00006697          	auipc	a3,0x6
ffffffffc02016bc:	bc068693          	addi	a3,a3,-1088 # ffffffffc0207278 <commands+0xa90>
ffffffffc02016c0:	00005617          	auipc	a2,0x5
ffffffffc02016c4:	57860613          	addi	a2,a2,1400 # ffffffffc0206c38 <commands+0x450>
ffffffffc02016c8:	08000593          	li	a1,128
ffffffffc02016cc:	00006517          	auipc	a0,0x6
ffffffffc02016d0:	86c50513          	addi	a0,a0,-1940 # ffffffffc0206f38 <commands+0x750>
ffffffffc02016d4:	da7fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02016d8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02016d8:	c941                	beqz	a0,ffffffffc0201768 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc02016da:	000ad597          	auipc	a1,0xad
ffffffffc02016de:	27658593          	addi	a1,a1,630 # ffffffffc02ae950 <free_area>
ffffffffc02016e2:	0105a803          	lw	a6,16(a1)
ffffffffc02016e6:	872a                	mv	a4,a0
ffffffffc02016e8:	02081793          	slli	a5,a6,0x20
ffffffffc02016ec:	9381                	srli	a5,a5,0x20
ffffffffc02016ee:	00a7ee63          	bltu	a5,a0,ffffffffc020170a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02016f2:	87ae                	mv	a5,a1
ffffffffc02016f4:	a801                	j	ffffffffc0201704 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02016f6:	ff87a683          	lw	a3,-8(a5)
ffffffffc02016fa:	02069613          	slli	a2,a3,0x20
ffffffffc02016fe:	9201                	srli	a2,a2,0x20
ffffffffc0201700:	00e67763          	bgeu	a2,a4,ffffffffc020170e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201704:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201706:	feb798e3          	bne	a5,a1,ffffffffc02016f6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020170a:	4501                	li	a0,0
}
ffffffffc020170c:	8082                	ret
    return listelm->prev;
ffffffffc020170e:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201712:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201716:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020171a:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc020171e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201722:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201726:	02c77863          	bgeu	a4,a2,ffffffffc0201756 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020172a:	071a                	slli	a4,a4,0x6
ffffffffc020172c:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020172e:	41c686bb          	subw	a3,a3,t3
ffffffffc0201732:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201734:	00870613          	addi	a2,a4,8
ffffffffc0201738:	4689                	li	a3,2
ffffffffc020173a:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc020173e:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201742:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0201746:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020174a:	e290                	sd	a2,0(a3)
ffffffffc020174c:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201750:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0201752:	01173c23          	sd	a7,24(a4)
ffffffffc0201756:	41c8083b          	subw	a6,a6,t3
ffffffffc020175a:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020175e:	5775                	li	a4,-3
ffffffffc0201760:	17c1                	addi	a5,a5,-16
ffffffffc0201762:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201766:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201768:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020176a:	00006697          	auipc	a3,0x6
ffffffffc020176e:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0207278 <commands+0xa90>
ffffffffc0201772:	00005617          	auipc	a2,0x5
ffffffffc0201776:	4c660613          	addi	a2,a2,1222 # ffffffffc0206c38 <commands+0x450>
ffffffffc020177a:	06200593          	li	a1,98
ffffffffc020177e:	00005517          	auipc	a0,0x5
ffffffffc0201782:	7ba50513          	addi	a0,a0,1978 # ffffffffc0206f38 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc0201786:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201788:	cf3fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020178c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020178c:	1141                	addi	sp,sp,-16
ffffffffc020178e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201790:	c5f1                	beqz	a1,ffffffffc020185c <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0201792:	00659693          	slli	a3,a1,0x6
ffffffffc0201796:	96aa                	add	a3,a3,a0
ffffffffc0201798:	87aa                	mv	a5,a0
ffffffffc020179a:	00d50f63          	beq	a0,a3,ffffffffc02017b8 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020179e:	6798                	ld	a4,8(a5)
ffffffffc02017a0:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02017a2:	cf49                	beqz	a4,ffffffffc020183c <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017a4:	0007a823          	sw	zero,16(a5)
ffffffffc02017a8:	0007b423          	sd	zero,8(a5)
ffffffffc02017ac:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02017b0:	04078793          	addi	a5,a5,64
ffffffffc02017b4:	fed795e3          	bne	a5,a3,ffffffffc020179e <default_init_memmap+0x12>
    base->property = n;
ffffffffc02017b8:	2581                	sext.w	a1,a1
ffffffffc02017ba:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017bc:	4789                	li	a5,2
ffffffffc02017be:	00850713          	addi	a4,a0,8
ffffffffc02017c2:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02017c6:	000ad697          	auipc	a3,0xad
ffffffffc02017ca:	18a68693          	addi	a3,a3,394 # ffffffffc02ae950 <free_area>
ffffffffc02017ce:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02017d0:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02017d2:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc02017d6:	9db9                	addw	a1,a1,a4
ffffffffc02017d8:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02017da:	04d78a63          	beq	a5,a3,ffffffffc020182e <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc02017de:	fe878713          	addi	a4,a5,-24
ffffffffc02017e2:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02017e6:	4581                	li	a1,0
            if (base < page) {
ffffffffc02017e8:	00e56a63          	bltu	a0,a4,ffffffffc02017fc <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02017ec:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02017ee:	02d70263          	beq	a4,a3,ffffffffc0201812 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc02017f2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02017f4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02017f8:	fee57ae3          	bgeu	a0,a4,ffffffffc02017ec <default_init_memmap+0x60>
ffffffffc02017fc:	c199                	beqz	a1,ffffffffc0201802 <default_init_memmap+0x76>
ffffffffc02017fe:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201802:	6398                	ld	a4,0(a5)
}
ffffffffc0201804:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201806:	e390                	sd	a2,0(a5)
ffffffffc0201808:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020180a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020180c:	ed18                	sd	a4,24(a0)
ffffffffc020180e:	0141                	addi	sp,sp,16
ffffffffc0201810:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201812:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201814:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201816:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201818:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020181a:	00d70663          	beq	a4,a3,ffffffffc0201826 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc020181e:	8832                	mv	a6,a2
ffffffffc0201820:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201822:	87ba                	mv	a5,a4
ffffffffc0201824:	bfc1                	j	ffffffffc02017f4 <default_init_memmap+0x68>
}
ffffffffc0201826:	60a2                	ld	ra,8(sp)
ffffffffc0201828:	e290                	sd	a2,0(a3)
ffffffffc020182a:	0141                	addi	sp,sp,16
ffffffffc020182c:	8082                	ret
ffffffffc020182e:	60a2                	ld	ra,8(sp)
ffffffffc0201830:	e390                	sd	a2,0(a5)
ffffffffc0201832:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201834:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201836:	ed1c                	sd	a5,24(a0)
ffffffffc0201838:	0141                	addi	sp,sp,16
ffffffffc020183a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020183c:	00006697          	auipc	a3,0x6
ffffffffc0201840:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02072a8 <commands+0xac0>
ffffffffc0201844:	00005617          	auipc	a2,0x5
ffffffffc0201848:	3f460613          	addi	a2,a2,1012 # ffffffffc0206c38 <commands+0x450>
ffffffffc020184c:	04900593          	li	a1,73
ffffffffc0201850:	00005517          	auipc	a0,0x5
ffffffffc0201854:	6e850513          	addi	a0,a0,1768 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201858:	c23fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc020185c:	00006697          	auipc	a3,0x6
ffffffffc0201860:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0207278 <commands+0xa90>
ffffffffc0201864:	00005617          	auipc	a2,0x5
ffffffffc0201868:	3d460613          	addi	a2,a2,980 # ffffffffc0206c38 <commands+0x450>
ffffffffc020186c:	04600593          	li	a1,70
ffffffffc0201870:	00005517          	auipc	a0,0x5
ffffffffc0201874:	6c850513          	addi	a0,a0,1736 # ffffffffc0206f38 <commands+0x750>
ffffffffc0201878:	c03fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020187c <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020187c:	c94d                	beqz	a0,ffffffffc020192e <slob_free+0xb2>
{
ffffffffc020187e:	1141                	addi	sp,sp,-16
ffffffffc0201880:	e022                	sd	s0,0(sp)
ffffffffc0201882:	e406                	sd	ra,8(sp)
ffffffffc0201884:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201886:	e9c1                	bnez	a1,ffffffffc0201916 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201888:	100027f3          	csrr	a5,sstatus
ffffffffc020188c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020188e:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201890:	ebd9                	bnez	a5,ffffffffc0201926 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201892:	000a6617          	auipc	a2,0xa6
ffffffffc0201896:	cae60613          	addi	a2,a2,-850 # ffffffffc02a7540 <slobfree>
ffffffffc020189a:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020189c:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020189e:	679c                	ld	a5,8(a5)
ffffffffc02018a0:	02877a63          	bgeu	a4,s0,ffffffffc02018d4 <slob_free+0x58>
ffffffffc02018a4:	00f46463          	bltu	s0,a5,ffffffffc02018ac <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018a8:	fef76ae3          	bltu	a4,a5,ffffffffc020189c <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc02018ac:	400c                	lw	a1,0(s0)
ffffffffc02018ae:	00459693          	slli	a3,a1,0x4
ffffffffc02018b2:	96a2                	add	a3,a3,s0
ffffffffc02018b4:	02d78a63          	beq	a5,a3,ffffffffc02018e8 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02018b8:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc02018ba:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02018bc:	00469793          	slli	a5,a3,0x4
ffffffffc02018c0:	97ba                	add	a5,a5,a4
ffffffffc02018c2:	02f40e63          	beq	s0,a5,ffffffffc02018fe <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02018c6:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc02018c8:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc02018ca:	e129                	bnez	a0,ffffffffc020190c <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02018cc:	60a2                	ld	ra,8(sp)
ffffffffc02018ce:	6402                	ld	s0,0(sp)
ffffffffc02018d0:	0141                	addi	sp,sp,16
ffffffffc02018d2:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018d4:	fcf764e3          	bltu	a4,a5,ffffffffc020189c <slob_free+0x20>
ffffffffc02018d8:	fcf472e3          	bgeu	s0,a5,ffffffffc020189c <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc02018dc:	400c                	lw	a1,0(s0)
ffffffffc02018de:	00459693          	slli	a3,a1,0x4
ffffffffc02018e2:	96a2                	add	a3,a3,s0
ffffffffc02018e4:	fcd79ae3          	bne	a5,a3,ffffffffc02018b8 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc02018e8:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02018ea:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc02018ec:	9db5                	addw	a1,a1,a3
ffffffffc02018ee:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc02018f0:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02018f2:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc02018f4:	00469793          	slli	a5,a3,0x4
ffffffffc02018f8:	97ba                	add	a5,a5,a4
ffffffffc02018fa:	fcf416e3          	bne	s0,a5,ffffffffc02018c6 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc02018fe:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201900:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201902:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201904:	9ebd                	addw	a3,a3,a5
ffffffffc0201906:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201908:	e70c                	sd	a1,8(a4)
ffffffffc020190a:	d169                	beqz	a0,ffffffffc02018cc <slob_free+0x50>
}
ffffffffc020190c:	6402                	ld	s0,0(sp)
ffffffffc020190e:	60a2                	ld	ra,8(sp)
ffffffffc0201910:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201912:	d2ffe06f          	j	ffffffffc0200640 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201916:	25bd                	addiw	a1,a1,15
ffffffffc0201918:	8191                	srli	a1,a1,0x4
ffffffffc020191a:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020191c:	100027f3          	csrr	a5,sstatus
ffffffffc0201920:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201922:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201924:	d7bd                	beqz	a5,ffffffffc0201892 <slob_free+0x16>
        intr_disable();
ffffffffc0201926:	d21fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020192a:	4505                	li	a0,1
ffffffffc020192c:	b79d                	j	ffffffffc0201892 <slob_free+0x16>
ffffffffc020192e:	8082                	ret

ffffffffc0201930 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201930:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201932:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201934:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201938:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020193a:	352000ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
  if(!page)
ffffffffc020193e:	c91d                	beqz	a0,ffffffffc0201974 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201940:	000b1697          	auipc	a3,0xb1
ffffffffc0201944:	1106b683          	ld	a3,272(a3) # ffffffffc02b2a50 <pages>
ffffffffc0201948:	8d15                	sub	a0,a0,a3
ffffffffc020194a:	8519                	srai	a0,a0,0x6
ffffffffc020194c:	00007697          	auipc	a3,0x7
ffffffffc0201950:	2ec6b683          	ld	a3,748(a3) # ffffffffc0208c38 <nbase>
ffffffffc0201954:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201956:	00c51793          	slli	a5,a0,0xc
ffffffffc020195a:	83b1                	srli	a5,a5,0xc
ffffffffc020195c:	000b1717          	auipc	a4,0xb1
ffffffffc0201960:	0ec73703          	ld	a4,236(a4) # ffffffffc02b2a48 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201964:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201966:	00e7fa63          	bgeu	a5,a4,ffffffffc020197a <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc020196a:	000b1697          	auipc	a3,0xb1
ffffffffc020196e:	0f66b683          	ld	a3,246(a3) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0201972:	9536                	add	a0,a0,a3
}
ffffffffc0201974:	60a2                	ld	ra,8(sp)
ffffffffc0201976:	0141                	addi	sp,sp,16
ffffffffc0201978:	8082                	ret
ffffffffc020197a:	86aa                	mv	a3,a0
ffffffffc020197c:	00006617          	auipc	a2,0x6
ffffffffc0201980:	98c60613          	addi	a2,a2,-1652 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0201984:	06900593          	li	a1,105
ffffffffc0201988:	00006517          	auipc	a0,0x6
ffffffffc020198c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0201990:	aebfe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201994 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201994:	1101                	addi	sp,sp,-32
ffffffffc0201996:	ec06                	sd	ra,24(sp)
ffffffffc0201998:	e822                	sd	s0,16(sp)
ffffffffc020199a:	e426                	sd	s1,8(sp)
ffffffffc020199c:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020199e:	01050713          	addi	a4,a0,16
ffffffffc02019a2:	6785                	lui	a5,0x1
ffffffffc02019a4:	0cf77363          	bgeu	a4,a5,ffffffffc0201a6a <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019a8:	00f50493          	addi	s1,a0,15
ffffffffc02019ac:	8091                	srli	s1,s1,0x4
ffffffffc02019ae:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b0:	10002673          	csrr	a2,sstatus
ffffffffc02019b4:	8a09                	andi	a2,a2,2
ffffffffc02019b6:	e25d                	bnez	a2,ffffffffc0201a5c <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc02019b8:	000a6917          	auipc	s2,0xa6
ffffffffc02019bc:	b8890913          	addi	s2,s2,-1144 # ffffffffc02a7540 <slobfree>
ffffffffc02019c0:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02019c4:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019c6:	4398                	lw	a4,0(a5)
ffffffffc02019c8:	08975e63          	bge	a4,s1,ffffffffc0201a64 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc02019cc:	00f68b63          	beq	a3,a5,ffffffffc02019e2 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02019d0:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02019d2:	4018                	lw	a4,0(s0)
ffffffffc02019d4:	02975a63          	bge	a4,s1,ffffffffc0201a08 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc02019d8:	00093683          	ld	a3,0(s2)
ffffffffc02019dc:	87a2                	mv	a5,s0
ffffffffc02019de:	fef699e3          	bne	a3,a5,ffffffffc02019d0 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc02019e2:	ee31                	bnez	a2,ffffffffc0201a3e <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02019e4:	4501                	li	a0,0
ffffffffc02019e6:	f4bff0ef          	jal	ra,ffffffffc0201930 <__slob_get_free_pages.constprop.0>
ffffffffc02019ea:	842a                	mv	s0,a0
			if (!cur)
ffffffffc02019ec:	cd05                	beqz	a0,ffffffffc0201a24 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc02019ee:	6585                	lui	a1,0x1
ffffffffc02019f0:	e8dff0ef          	jal	ra,ffffffffc020187c <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019f4:	10002673          	csrr	a2,sstatus
ffffffffc02019f8:	8a09                	andi	a2,a2,2
ffffffffc02019fa:	ee05                	bnez	a2,ffffffffc0201a32 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc02019fc:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a00:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a02:	4018                	lw	a4,0(s0)
ffffffffc0201a04:	fc974ae3          	blt	a4,s1,ffffffffc02019d8 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a08:	04e48763          	beq	s1,a4,ffffffffc0201a56 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a0c:	00449693          	slli	a3,s1,0x4
ffffffffc0201a10:	96a2                	add	a3,a3,s0
ffffffffc0201a12:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a14:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a16:	9f05                	subw	a4,a4,s1
ffffffffc0201a18:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a1a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a1c:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a1e:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a22:	e20d                	bnez	a2,ffffffffc0201a44 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a24:	60e2                	ld	ra,24(sp)
ffffffffc0201a26:	8522                	mv	a0,s0
ffffffffc0201a28:	6442                	ld	s0,16(sp)
ffffffffc0201a2a:	64a2                	ld	s1,8(sp)
ffffffffc0201a2c:	6902                	ld	s2,0(sp)
ffffffffc0201a2e:	6105                	addi	sp,sp,32
ffffffffc0201a30:	8082                	ret
        intr_disable();
ffffffffc0201a32:	c15fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
			cur = slobfree;
ffffffffc0201a36:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a3a:	4605                	li	a2,1
ffffffffc0201a3c:	b7d1                	j	ffffffffc0201a00 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a3e:	c03fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201a42:	b74d                	j	ffffffffc02019e4 <slob_alloc.constprop.0+0x50>
ffffffffc0201a44:	bfdfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc0201a48:	60e2                	ld	ra,24(sp)
ffffffffc0201a4a:	8522                	mv	a0,s0
ffffffffc0201a4c:	6442                	ld	s0,16(sp)
ffffffffc0201a4e:	64a2                	ld	s1,8(sp)
ffffffffc0201a50:	6902                	ld	s2,0(sp)
ffffffffc0201a52:	6105                	addi	sp,sp,32
ffffffffc0201a54:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201a56:	6418                	ld	a4,8(s0)
ffffffffc0201a58:	e798                	sd	a4,8(a5)
ffffffffc0201a5a:	b7d1                	j	ffffffffc0201a1e <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201a5c:	bebfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0201a60:	4605                	li	a2,1
ffffffffc0201a62:	bf99                	j	ffffffffc02019b8 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a64:	843e                	mv	s0,a5
ffffffffc0201a66:	87b6                	mv	a5,a3
ffffffffc0201a68:	b745                	j	ffffffffc0201a08 <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201a6a:	00006697          	auipc	a3,0x6
ffffffffc0201a6e:	8d668693          	addi	a3,a3,-1834 # ffffffffc0207340 <default_pmm_manager+0x70>
ffffffffc0201a72:	00005617          	auipc	a2,0x5
ffffffffc0201a76:	1c660613          	addi	a2,a2,454 # ffffffffc0206c38 <commands+0x450>
ffffffffc0201a7a:	06400593          	li	a1,100
ffffffffc0201a7e:	00006517          	auipc	a0,0x6
ffffffffc0201a82:	8e250513          	addi	a0,a0,-1822 # ffffffffc0207360 <default_pmm_manager+0x90>
ffffffffc0201a86:	9f5fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201a8a <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201a8a:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201a8c:	00006517          	auipc	a0,0x6
ffffffffc0201a90:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0207378 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201a94:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201a96:	eeafe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201a9a:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201a9c:	00006517          	auipc	a0,0x6
ffffffffc0201aa0:	8f450513          	addi	a0,a0,-1804 # ffffffffc0207390 <default_pmm_manager+0xc0>
}
ffffffffc0201aa4:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201aa6:	edafe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201aaa <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201aaa:	4501                	li	a0,0
ffffffffc0201aac:	8082                	ret

ffffffffc0201aae <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201aae:	1101                	addi	sp,sp,-32
ffffffffc0201ab0:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ab2:	6905                	lui	s2,0x1
{
ffffffffc0201ab4:	e822                	sd	s0,16(sp)
ffffffffc0201ab6:	ec06                	sd	ra,24(sp)
ffffffffc0201ab8:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201aba:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8be9>
{
ffffffffc0201abe:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201ac0:	04a7f963          	bgeu	a5,a0,ffffffffc0201b12 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201ac4:	4561                	li	a0,24
ffffffffc0201ac6:	ecfff0ef          	jal	ra,ffffffffc0201994 <slob_alloc.constprop.0>
ffffffffc0201aca:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201acc:	c929                	beqz	a0,ffffffffc0201b1e <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201ace:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201ad2:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201ad4:	00f95763          	bge	s2,a5,ffffffffc0201ae2 <kmalloc+0x34>
ffffffffc0201ad8:	6705                	lui	a4,0x1
ffffffffc0201ada:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201adc:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201ade:	fef74ee3          	blt	a4,a5,ffffffffc0201ada <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201ae2:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201ae4:	e4dff0ef          	jal	ra,ffffffffc0201930 <__slob_get_free_pages.constprop.0>
ffffffffc0201ae8:	e488                	sd	a0,8(s1)
ffffffffc0201aea:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201aec:	c525                	beqz	a0,ffffffffc0201b54 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201aee:	100027f3          	csrr	a5,sstatus
ffffffffc0201af2:	8b89                	andi	a5,a5,2
ffffffffc0201af4:	ef8d                	bnez	a5,ffffffffc0201b2e <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201af6:	000b1797          	auipc	a5,0xb1
ffffffffc0201afa:	f3a78793          	addi	a5,a5,-198 # ffffffffc02b2a30 <bigblocks>
ffffffffc0201afe:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b00:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b02:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201b04:	60e2                	ld	ra,24(sp)
ffffffffc0201b06:	8522                	mv	a0,s0
ffffffffc0201b08:	6442                	ld	s0,16(sp)
ffffffffc0201b0a:	64a2                	ld	s1,8(sp)
ffffffffc0201b0c:	6902                	ld	s2,0(sp)
ffffffffc0201b0e:	6105                	addi	sp,sp,32
ffffffffc0201b10:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b12:	0541                	addi	a0,a0,16
ffffffffc0201b14:	e81ff0ef          	jal	ra,ffffffffc0201994 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b18:	01050413          	addi	s0,a0,16
ffffffffc0201b1c:	f565                	bnez	a0,ffffffffc0201b04 <kmalloc+0x56>
ffffffffc0201b1e:	4401                	li	s0,0
}
ffffffffc0201b20:	60e2                	ld	ra,24(sp)
ffffffffc0201b22:	8522                	mv	a0,s0
ffffffffc0201b24:	6442                	ld	s0,16(sp)
ffffffffc0201b26:	64a2                	ld	s1,8(sp)
ffffffffc0201b28:	6902                	ld	s2,0(sp)
ffffffffc0201b2a:	6105                	addi	sp,sp,32
ffffffffc0201b2c:	8082                	ret
        intr_disable();
ffffffffc0201b2e:	b19fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b32:	000b1797          	auipc	a5,0xb1
ffffffffc0201b36:	efe78793          	addi	a5,a5,-258 # ffffffffc02b2a30 <bigblocks>
ffffffffc0201b3a:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b3c:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b3e:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b40:	b01fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
		return bb->pages;
ffffffffc0201b44:	6480                	ld	s0,8(s1)
}
ffffffffc0201b46:	60e2                	ld	ra,24(sp)
ffffffffc0201b48:	64a2                	ld	s1,8(sp)
ffffffffc0201b4a:	8522                	mv	a0,s0
ffffffffc0201b4c:	6442                	ld	s0,16(sp)
ffffffffc0201b4e:	6902                	ld	s2,0(sp)
ffffffffc0201b50:	6105                	addi	sp,sp,32
ffffffffc0201b52:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b54:	45e1                	li	a1,24
ffffffffc0201b56:	8526                	mv	a0,s1
ffffffffc0201b58:	d25ff0ef          	jal	ra,ffffffffc020187c <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201b5c:	b765                	j	ffffffffc0201b04 <kmalloc+0x56>

ffffffffc0201b5e <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201b5e:	c169                	beqz	a0,ffffffffc0201c20 <kfree+0xc2>
{
ffffffffc0201b60:	1101                	addi	sp,sp,-32
ffffffffc0201b62:	e822                	sd	s0,16(sp)
ffffffffc0201b64:	ec06                	sd	ra,24(sp)
ffffffffc0201b66:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201b68:	03451793          	slli	a5,a0,0x34
ffffffffc0201b6c:	842a                	mv	s0,a0
ffffffffc0201b6e:	e3d9                	bnez	a5,ffffffffc0201bf4 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b70:	100027f3          	csrr	a5,sstatus
ffffffffc0201b74:	8b89                	andi	a5,a5,2
ffffffffc0201b76:	e7d9                	bnez	a5,ffffffffc0201c04 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b78:	000b1797          	auipc	a5,0xb1
ffffffffc0201b7c:	eb87b783          	ld	a5,-328(a5) # ffffffffc02b2a30 <bigblocks>
    return 0;
ffffffffc0201b80:	4601                	li	a2,0
ffffffffc0201b82:	cbad                	beqz	a5,ffffffffc0201bf4 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201b84:	000b1697          	auipc	a3,0xb1
ffffffffc0201b88:	eac68693          	addi	a3,a3,-340 # ffffffffc02b2a30 <bigblocks>
ffffffffc0201b8c:	a021                	j	ffffffffc0201b94 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201b8e:	01048693          	addi	a3,s1,16
ffffffffc0201b92:	c3a5                	beqz	a5,ffffffffc0201bf2 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201b94:	6798                	ld	a4,8(a5)
ffffffffc0201b96:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201b98:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201b9a:	fe871ae3          	bne	a4,s0,ffffffffc0201b8e <kfree+0x30>
				*last = bb->next;
ffffffffc0201b9e:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201ba0:	ee2d                	bnez	a2,ffffffffc0201c1a <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201ba2:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201ba6:	4098                	lw	a4,0(s1)
ffffffffc0201ba8:	08f46963          	bltu	s0,a5,ffffffffc0201c3a <kfree+0xdc>
ffffffffc0201bac:	000b1697          	auipc	a3,0xb1
ffffffffc0201bb0:	eb46b683          	ld	a3,-332(a3) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0201bb4:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201bb6:	8031                	srli	s0,s0,0xc
ffffffffc0201bb8:	000b1797          	auipc	a5,0xb1
ffffffffc0201bbc:	e907b783          	ld	a5,-368(a5) # ffffffffc02b2a48 <npage>
ffffffffc0201bc0:	06f47163          	bgeu	s0,a5,ffffffffc0201c22 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201bc4:	00007517          	auipc	a0,0x7
ffffffffc0201bc8:	07453503          	ld	a0,116(a0) # ffffffffc0208c38 <nbase>
ffffffffc0201bcc:	8c09                	sub	s0,s0,a0
ffffffffc0201bce:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201bd0:	000b1517          	auipc	a0,0xb1
ffffffffc0201bd4:	e8053503          	ld	a0,-384(a0) # ffffffffc02b2a50 <pages>
ffffffffc0201bd8:	4585                	li	a1,1
ffffffffc0201bda:	9522                	add	a0,a0,s0
ffffffffc0201bdc:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201be0:	13e000ef          	jal	ra,ffffffffc0201d1e <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201be4:	6442                	ld	s0,16(sp)
ffffffffc0201be6:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201be8:	8526                	mv	a0,s1
}
ffffffffc0201bea:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201bec:	45e1                	li	a1,24
}
ffffffffc0201bee:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201bf0:	b171                	j	ffffffffc020187c <slob_free>
ffffffffc0201bf2:	e20d                	bnez	a2,ffffffffc0201c14 <kfree+0xb6>
ffffffffc0201bf4:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201bf8:	6442                	ld	s0,16(sp)
ffffffffc0201bfa:	60e2                	ld	ra,24(sp)
ffffffffc0201bfc:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201bfe:	4581                	li	a1,0
}
ffffffffc0201c00:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c02:	b9ad                	j	ffffffffc020187c <slob_free>
        intr_disable();
ffffffffc0201c04:	a43fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c08:	000b1797          	auipc	a5,0xb1
ffffffffc0201c0c:	e287b783          	ld	a5,-472(a5) # ffffffffc02b2a30 <bigblocks>
        return 1;
ffffffffc0201c10:	4605                	li	a2,1
ffffffffc0201c12:	fbad                	bnez	a5,ffffffffc0201b84 <kfree+0x26>
        intr_enable();
ffffffffc0201c14:	a2dfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c18:	bff1                	j	ffffffffc0201bf4 <kfree+0x96>
ffffffffc0201c1a:	a27fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c1e:	b751                	j	ffffffffc0201ba2 <kfree+0x44>
ffffffffc0201c20:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c22:	00005617          	auipc	a2,0x5
ffffffffc0201c26:	7b660613          	addi	a2,a2,1974 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc0201c2a:	06200593          	li	a1,98
ffffffffc0201c2e:	00005517          	auipc	a0,0x5
ffffffffc0201c32:	70250513          	addi	a0,a0,1794 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0201c36:	845fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c3a:	86a2                	mv	a3,s0
ffffffffc0201c3c:	00005617          	auipc	a2,0x5
ffffffffc0201c40:	77460613          	addi	a2,a2,1908 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc0201c44:	06e00593          	li	a1,110
ffffffffc0201c48:	00005517          	auipc	a0,0x5
ffffffffc0201c4c:	6e850513          	addi	a0,a0,1768 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0201c50:	82bfe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201c54 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201c54:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201c56:	00005617          	auipc	a2,0x5
ffffffffc0201c5a:	78260613          	addi	a2,a2,1922 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc0201c5e:	06200593          	li	a1,98
ffffffffc0201c62:	00005517          	auipc	a0,0x5
ffffffffc0201c66:	6ce50513          	addi	a0,a0,1742 # ffffffffc0207330 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201c6a:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201c6c:	80ffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201c70 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201c70:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201c72:	00005617          	auipc	a2,0x5
ffffffffc0201c76:	78660613          	addi	a2,a2,1926 # ffffffffc02073f8 <default_pmm_manager+0x128>
ffffffffc0201c7a:	07400593          	li	a1,116
ffffffffc0201c7e:	00005517          	auipc	a0,0x5
ffffffffc0201c82:	6b250513          	addi	a0,a0,1714 # ffffffffc0207330 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201c86:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201c88:	ff2fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201c8c <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201c8c:	7139                	addi	sp,sp,-64
ffffffffc0201c8e:	f426                	sd	s1,40(sp)
ffffffffc0201c90:	f04a                	sd	s2,32(sp)
ffffffffc0201c92:	ec4e                	sd	s3,24(sp)
ffffffffc0201c94:	e852                	sd	s4,16(sp)
ffffffffc0201c96:	e456                	sd	s5,8(sp)
ffffffffc0201c98:	e05a                	sd	s6,0(sp)
ffffffffc0201c9a:	fc06                	sd	ra,56(sp)
ffffffffc0201c9c:	f822                	sd	s0,48(sp)
ffffffffc0201c9e:	84aa                	mv	s1,a0
ffffffffc0201ca0:	000b1917          	auipc	s2,0xb1
ffffffffc0201ca4:	db890913          	addi	s2,s2,-584 # ffffffffc02b2a58 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ca8:	4a05                	li	s4,1
ffffffffc0201caa:	000b1a97          	auipc	s5,0xb1
ffffffffc0201cae:	dcea8a93          	addi	s5,s5,-562 # ffffffffc02b2a78 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cb2:	0005099b          	sext.w	s3,a0
ffffffffc0201cb6:	000b1b17          	auipc	s6,0xb1
ffffffffc0201cba:	dcab0b13          	addi	s6,s6,-566 # ffffffffc02b2a80 <check_mm_struct>
ffffffffc0201cbe:	a01d                	j	ffffffffc0201ce4 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201cc0:	00093783          	ld	a5,0(s2)
ffffffffc0201cc4:	6f9c                	ld	a5,24(a5)
ffffffffc0201cc6:	9782                	jalr	a5
ffffffffc0201cc8:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cca:	4601                	li	a2,0
ffffffffc0201ccc:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cce:	ec0d                	bnez	s0,ffffffffc0201d08 <alloc_pages+0x7c>
ffffffffc0201cd0:	029a6c63          	bltu	s4,s1,ffffffffc0201d08 <alloc_pages+0x7c>
ffffffffc0201cd4:	000aa783          	lw	a5,0(s5)
ffffffffc0201cd8:	2781                	sext.w	a5,a5
ffffffffc0201cda:	c79d                	beqz	a5,ffffffffc0201d08 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201cdc:	000b3503          	ld	a0,0(s6)
ffffffffc0201ce0:	64d010ef          	jal	ra,ffffffffc0203b2c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ce4:	100027f3          	csrr	a5,sstatus
ffffffffc0201ce8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201cea:	8526                	mv	a0,s1
ffffffffc0201cec:	dbf1                	beqz	a5,ffffffffc0201cc0 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201cee:	959fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0201cf2:	00093783          	ld	a5,0(s2)
ffffffffc0201cf6:	8526                	mv	a0,s1
ffffffffc0201cf8:	6f9c                	ld	a5,24(a5)
ffffffffc0201cfa:	9782                	jalr	a5
ffffffffc0201cfc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201cfe:	943fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d02:	4601                	li	a2,0
ffffffffc0201d04:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d06:	d469                	beqz	s0,ffffffffc0201cd0 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d08:	70e2                	ld	ra,56(sp)
ffffffffc0201d0a:	8522                	mv	a0,s0
ffffffffc0201d0c:	7442                	ld	s0,48(sp)
ffffffffc0201d0e:	74a2                	ld	s1,40(sp)
ffffffffc0201d10:	7902                	ld	s2,32(sp)
ffffffffc0201d12:	69e2                	ld	s3,24(sp)
ffffffffc0201d14:	6a42                	ld	s4,16(sp)
ffffffffc0201d16:	6aa2                	ld	s5,8(sp)
ffffffffc0201d18:	6b02                	ld	s6,0(sp)
ffffffffc0201d1a:	6121                	addi	sp,sp,64
ffffffffc0201d1c:	8082                	ret

ffffffffc0201d1e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201d22:	8b89                	andi	a5,a5,2
ffffffffc0201d24:	e799                	bnez	a5,ffffffffc0201d32 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d26:	000b1797          	auipc	a5,0xb1
ffffffffc0201d2a:	d327b783          	ld	a5,-718(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc0201d2e:	739c                	ld	a5,32(a5)
ffffffffc0201d30:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d32:	1101                	addi	sp,sp,-32
ffffffffc0201d34:	ec06                	sd	ra,24(sp)
ffffffffc0201d36:	e822                	sd	s0,16(sp)
ffffffffc0201d38:	e426                	sd	s1,8(sp)
ffffffffc0201d3a:	842a                	mv	s0,a0
ffffffffc0201d3c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d3e:	909fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d42:	000b1797          	auipc	a5,0xb1
ffffffffc0201d46:	d167b783          	ld	a5,-746(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc0201d4a:	739c                	ld	a5,32(a5)
ffffffffc0201d4c:	85a6                	mv	a1,s1
ffffffffc0201d4e:	8522                	mv	a0,s0
ffffffffc0201d50:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201d52:	6442                	ld	s0,16(sp)
ffffffffc0201d54:	60e2                	ld	ra,24(sp)
ffffffffc0201d56:	64a2                	ld	s1,8(sp)
ffffffffc0201d58:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201d5a:	8e7fe06f          	j	ffffffffc0200640 <intr_enable>

ffffffffc0201d5e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d5e:	100027f3          	csrr	a5,sstatus
ffffffffc0201d62:	8b89                	andi	a5,a5,2
ffffffffc0201d64:	e799                	bnez	a5,ffffffffc0201d72 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d66:	000b1797          	auipc	a5,0xb1
ffffffffc0201d6a:	cf27b783          	ld	a5,-782(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc0201d6e:	779c                	ld	a5,40(a5)
ffffffffc0201d70:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201d72:	1141                	addi	sp,sp,-16
ffffffffc0201d74:	e406                	sd	ra,8(sp)
ffffffffc0201d76:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201d78:	8cffe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201d7c:	000b1797          	auipc	a5,0xb1
ffffffffc0201d80:	cdc7b783          	ld	a5,-804(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc0201d84:	779c                	ld	a5,40(a5)
ffffffffc0201d86:	9782                	jalr	a5
ffffffffc0201d88:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d8a:	8b7fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201d8e:	60a2                	ld	ra,8(sp)
ffffffffc0201d90:	8522                	mv	a0,s0
ffffffffc0201d92:	6402                	ld	s0,0(sp)
ffffffffc0201d94:	0141                	addi	sp,sp,16
ffffffffc0201d96:	8082                	ret

ffffffffc0201d98 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201d98:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201d9c:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201da0:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201da2:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201da4:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201da6:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201daa:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dac:	f04a                	sd	s2,32(sp)
ffffffffc0201dae:	ec4e                	sd	s3,24(sp)
ffffffffc0201db0:	e852                	sd	s4,16(sp)
ffffffffc0201db2:	fc06                	sd	ra,56(sp)
ffffffffc0201db4:	f822                	sd	s0,48(sp)
ffffffffc0201db6:	e456                	sd	s5,8(sp)
ffffffffc0201db8:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dba:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201dbe:	892e                	mv	s2,a1
ffffffffc0201dc0:	89b2                	mv	s3,a2
ffffffffc0201dc2:	000b1a17          	auipc	s4,0xb1
ffffffffc0201dc6:	c86a0a13          	addi	s4,s4,-890 # ffffffffc02b2a48 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dca:	e7b5                	bnez	a5,ffffffffc0201e36 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201dcc:	12060b63          	beqz	a2,ffffffffc0201f02 <get_pte+0x16a>
ffffffffc0201dd0:	4505                	li	a0,1
ffffffffc0201dd2:	ebbff0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0201dd6:	842a                	mv	s0,a0
ffffffffc0201dd8:	12050563          	beqz	a0,ffffffffc0201f02 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201ddc:	000b1b17          	auipc	s6,0xb1
ffffffffc0201de0:	c74b0b13          	addi	s6,s6,-908 # ffffffffc02b2a50 <pages>
ffffffffc0201de4:	000b3503          	ld	a0,0(s6)
ffffffffc0201de8:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201dec:	000b1a17          	auipc	s4,0xb1
ffffffffc0201df0:	c5ca0a13          	addi	s4,s4,-932 # ffffffffc02b2a48 <npage>
ffffffffc0201df4:	40a40533          	sub	a0,s0,a0
ffffffffc0201df8:	8519                	srai	a0,a0,0x6
ffffffffc0201dfa:	9556                	add	a0,a0,s5
ffffffffc0201dfc:	000a3703          	ld	a4,0(s4)
ffffffffc0201e00:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e04:	4685                	li	a3,1
ffffffffc0201e06:	c014                	sw	a3,0(s0)
ffffffffc0201e08:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e0a:	0532                	slli	a0,a0,0xc
ffffffffc0201e0c:	14e7f263          	bgeu	a5,a4,ffffffffc0201f50 <get_pte+0x1b8>
ffffffffc0201e10:	000b1797          	auipc	a5,0xb1
ffffffffc0201e14:	c507b783          	ld	a5,-944(a5) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0201e18:	6605                	lui	a2,0x1
ffffffffc0201e1a:	4581                	li	a1,0
ffffffffc0201e1c:	953e                	add	a0,a0,a5
ffffffffc0201e1e:	734040ef          	jal	ra,ffffffffc0206552 <memset>
    return page - pages + nbase;
ffffffffc0201e22:	000b3683          	ld	a3,0(s6)
ffffffffc0201e26:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e2a:	8699                	srai	a3,a3,0x6
ffffffffc0201e2c:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e2e:	06aa                	slli	a3,a3,0xa
ffffffffc0201e30:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e34:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e36:	77fd                	lui	a5,0xfffff
ffffffffc0201e38:	068a                	slli	a3,a3,0x2
ffffffffc0201e3a:	000a3703          	ld	a4,0(s4)
ffffffffc0201e3e:	8efd                	and	a3,a3,a5
ffffffffc0201e40:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e44:	0ce7f163          	bgeu	a5,a4,ffffffffc0201f06 <get_pte+0x16e>
ffffffffc0201e48:	000b1a97          	auipc	s5,0xb1
ffffffffc0201e4c:	c18a8a93          	addi	s5,s5,-1000 # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0201e50:	000ab403          	ld	s0,0(s5)
ffffffffc0201e54:	01595793          	srli	a5,s2,0x15
ffffffffc0201e58:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e5c:	96a2                	add	a3,a3,s0
ffffffffc0201e5e:	00379413          	slli	s0,a5,0x3
ffffffffc0201e62:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201e64:	6014                	ld	a3,0(s0)
ffffffffc0201e66:	0016f793          	andi	a5,a3,1
ffffffffc0201e6a:	e3ad                	bnez	a5,ffffffffc0201ecc <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e6c:	08098b63          	beqz	s3,ffffffffc0201f02 <get_pte+0x16a>
ffffffffc0201e70:	4505                	li	a0,1
ffffffffc0201e72:	e1bff0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0201e76:	84aa                	mv	s1,a0
ffffffffc0201e78:	c549                	beqz	a0,ffffffffc0201f02 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201e7a:	000b1b17          	auipc	s6,0xb1
ffffffffc0201e7e:	bd6b0b13          	addi	s6,s6,-1066 # ffffffffc02b2a50 <pages>
ffffffffc0201e82:	000b3503          	ld	a0,0(s6)
ffffffffc0201e86:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e8a:	000a3703          	ld	a4,0(s4)
ffffffffc0201e8e:	40a48533          	sub	a0,s1,a0
ffffffffc0201e92:	8519                	srai	a0,a0,0x6
ffffffffc0201e94:	954e                	add	a0,a0,s3
ffffffffc0201e96:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e9a:	4685                	li	a3,1
ffffffffc0201e9c:	c094                	sw	a3,0(s1)
ffffffffc0201e9e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ea0:	0532                	slli	a0,a0,0xc
ffffffffc0201ea2:	08e7fa63          	bgeu	a5,a4,ffffffffc0201f36 <get_pte+0x19e>
ffffffffc0201ea6:	000ab783          	ld	a5,0(s5)
ffffffffc0201eaa:	6605                	lui	a2,0x1
ffffffffc0201eac:	4581                	li	a1,0
ffffffffc0201eae:	953e                	add	a0,a0,a5
ffffffffc0201eb0:	6a2040ef          	jal	ra,ffffffffc0206552 <memset>
    return page - pages + nbase;
ffffffffc0201eb4:	000b3683          	ld	a3,0(s6)
ffffffffc0201eb8:	40d486b3          	sub	a3,s1,a3
ffffffffc0201ebc:	8699                	srai	a3,a3,0x6
ffffffffc0201ebe:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ec0:	06aa                	slli	a3,a3,0xa
ffffffffc0201ec2:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ec6:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201ec8:	000a3703          	ld	a4,0(s4)
ffffffffc0201ecc:	068a                	slli	a3,a3,0x2
ffffffffc0201ece:	757d                	lui	a0,0xfffff
ffffffffc0201ed0:	8ee9                	and	a3,a3,a0
ffffffffc0201ed2:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201ed6:	04e7f463          	bgeu	a5,a4,ffffffffc0201f1e <get_pte+0x186>
ffffffffc0201eda:	000ab503          	ld	a0,0(s5)
ffffffffc0201ede:	00c95913          	srli	s2,s2,0xc
ffffffffc0201ee2:	1ff97913          	andi	s2,s2,511
ffffffffc0201ee6:	96aa                	add	a3,a3,a0
ffffffffc0201ee8:	00391513          	slli	a0,s2,0x3
ffffffffc0201eec:	9536                	add	a0,a0,a3
}
ffffffffc0201eee:	70e2                	ld	ra,56(sp)
ffffffffc0201ef0:	7442                	ld	s0,48(sp)
ffffffffc0201ef2:	74a2                	ld	s1,40(sp)
ffffffffc0201ef4:	7902                	ld	s2,32(sp)
ffffffffc0201ef6:	69e2                	ld	s3,24(sp)
ffffffffc0201ef8:	6a42                	ld	s4,16(sp)
ffffffffc0201efa:	6aa2                	ld	s5,8(sp)
ffffffffc0201efc:	6b02                	ld	s6,0(sp)
ffffffffc0201efe:	6121                	addi	sp,sp,64
ffffffffc0201f00:	8082                	ret
            return NULL;
ffffffffc0201f02:	4501                	li	a0,0
ffffffffc0201f04:	b7ed                	j	ffffffffc0201eee <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f06:	00005617          	auipc	a2,0x5
ffffffffc0201f0a:	40260613          	addi	a2,a2,1026 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0201f0e:	0e300593          	li	a1,227
ffffffffc0201f12:	00005517          	auipc	a0,0x5
ffffffffc0201f16:	50e50513          	addi	a0,a0,1294 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0201f1a:	d60fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f1e:	00005617          	auipc	a2,0x5
ffffffffc0201f22:	3ea60613          	addi	a2,a2,1002 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0201f26:	0ee00593          	li	a1,238
ffffffffc0201f2a:	00005517          	auipc	a0,0x5
ffffffffc0201f2e:	4f650513          	addi	a0,a0,1270 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0201f32:	d48fe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f36:	86aa                	mv	a3,a0
ffffffffc0201f38:	00005617          	auipc	a2,0x5
ffffffffc0201f3c:	3d060613          	addi	a2,a2,976 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0201f40:	0eb00593          	li	a1,235
ffffffffc0201f44:	00005517          	auipc	a0,0x5
ffffffffc0201f48:	4dc50513          	addi	a0,a0,1244 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0201f4c:	d2efe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f50:	86aa                	mv	a3,a0
ffffffffc0201f52:	00005617          	auipc	a2,0x5
ffffffffc0201f56:	3b660613          	addi	a2,a2,950 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0201f5a:	0df00593          	li	a1,223
ffffffffc0201f5e:	00005517          	auipc	a0,0x5
ffffffffc0201f62:	4c250513          	addi	a0,a0,1218 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0201f66:	d14fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201f6a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f6a:	1141                	addi	sp,sp,-16
ffffffffc0201f6c:	e022                	sd	s0,0(sp)
ffffffffc0201f6e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f70:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201f72:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f74:	e25ff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201f78:	c011                	beqz	s0,ffffffffc0201f7c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201f7a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201f7c:	c511                	beqz	a0,ffffffffc0201f88 <get_page+0x1e>
ffffffffc0201f7e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201f80:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201f82:	0017f713          	andi	a4,a5,1
ffffffffc0201f86:	e709                	bnez	a4,ffffffffc0201f90 <get_page+0x26>
}
ffffffffc0201f88:	60a2                	ld	ra,8(sp)
ffffffffc0201f8a:	6402                	ld	s0,0(sp)
ffffffffc0201f8c:	0141                	addi	sp,sp,16
ffffffffc0201f8e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f90:	078a                	slli	a5,a5,0x2
ffffffffc0201f92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f94:	000b1717          	auipc	a4,0xb1
ffffffffc0201f98:	ab473703          	ld	a4,-1356(a4) # ffffffffc02b2a48 <npage>
ffffffffc0201f9c:	00e7ff63          	bgeu	a5,a4,ffffffffc0201fba <get_page+0x50>
ffffffffc0201fa0:	60a2                	ld	ra,8(sp)
ffffffffc0201fa2:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201fa4:	fff80537          	lui	a0,0xfff80
ffffffffc0201fa8:	97aa                	add	a5,a5,a0
ffffffffc0201faa:	079a                	slli	a5,a5,0x6
ffffffffc0201fac:	000b1517          	auipc	a0,0xb1
ffffffffc0201fb0:	aa453503          	ld	a0,-1372(a0) # ffffffffc02b2a50 <pages>
ffffffffc0201fb4:	953e                	add	a0,a0,a5
ffffffffc0201fb6:	0141                	addi	sp,sp,16
ffffffffc0201fb8:	8082                	ret
ffffffffc0201fba:	c9bff0ef          	jal	ra,ffffffffc0201c54 <pa2page.part.0>

ffffffffc0201fbe <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201fbe:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201fc0:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0201fc4:	f486                	sd	ra,104(sp)
ffffffffc0201fc6:	f0a2                	sd	s0,96(sp)
ffffffffc0201fc8:	eca6                	sd	s1,88(sp)
ffffffffc0201fca:	e8ca                	sd	s2,80(sp)
ffffffffc0201fcc:	e4ce                	sd	s3,72(sp)
ffffffffc0201fce:	e0d2                	sd	s4,64(sp)
ffffffffc0201fd0:	fc56                	sd	s5,56(sp)
ffffffffc0201fd2:	f85a                	sd	s6,48(sp)
ffffffffc0201fd4:	f45e                	sd	s7,40(sp)
ffffffffc0201fd6:	f062                	sd	s8,32(sp)
ffffffffc0201fd8:	ec66                	sd	s9,24(sp)
ffffffffc0201fda:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201fdc:	17d2                	slli	a5,a5,0x34
ffffffffc0201fde:	e3ed                	bnez	a5,ffffffffc02020c0 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0201fe0:	002007b7          	lui	a5,0x200
ffffffffc0201fe4:	842e                	mv	s0,a1
ffffffffc0201fe6:	0ef5ed63          	bltu	a1,a5,ffffffffc02020e0 <unmap_range+0x122>
ffffffffc0201fea:	8932                	mv	s2,a2
ffffffffc0201fec:	0ec5fa63          	bgeu	a1,a2,ffffffffc02020e0 <unmap_range+0x122>
ffffffffc0201ff0:	4785                	li	a5,1
ffffffffc0201ff2:	07fe                	slli	a5,a5,0x1f
ffffffffc0201ff4:	0ec7e663          	bltu	a5,a2,ffffffffc02020e0 <unmap_range+0x122>
ffffffffc0201ff8:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0201ffa:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201ffc:	000b1c97          	auipc	s9,0xb1
ffffffffc0202000:	a4cc8c93          	addi	s9,s9,-1460 # ffffffffc02b2a48 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202004:	000b1c17          	auipc	s8,0xb1
ffffffffc0202008:	a4cc0c13          	addi	s8,s8,-1460 # ffffffffc02b2a50 <pages>
ffffffffc020200c:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202010:	000b1d17          	auipc	s10,0xb1
ffffffffc0202014:	a48d0d13          	addi	s10,s10,-1464 # ffffffffc02b2a58 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202018:	00200b37          	lui	s6,0x200
ffffffffc020201c:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202020:	4601                	li	a2,0
ffffffffc0202022:	85a2                	mv	a1,s0
ffffffffc0202024:	854e                	mv	a0,s3
ffffffffc0202026:	d73ff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc020202a:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020202c:	cd29                	beqz	a0,ffffffffc0202086 <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc020202e:	611c                	ld	a5,0(a0)
ffffffffc0202030:	e395                	bnez	a5,ffffffffc0202054 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202032:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202034:	ff2466e3          	bltu	s0,s2,ffffffffc0202020 <unmap_range+0x62>
}
ffffffffc0202038:	70a6                	ld	ra,104(sp)
ffffffffc020203a:	7406                	ld	s0,96(sp)
ffffffffc020203c:	64e6                	ld	s1,88(sp)
ffffffffc020203e:	6946                	ld	s2,80(sp)
ffffffffc0202040:	69a6                	ld	s3,72(sp)
ffffffffc0202042:	6a06                	ld	s4,64(sp)
ffffffffc0202044:	7ae2                	ld	s5,56(sp)
ffffffffc0202046:	7b42                	ld	s6,48(sp)
ffffffffc0202048:	7ba2                	ld	s7,40(sp)
ffffffffc020204a:	7c02                	ld	s8,32(sp)
ffffffffc020204c:	6ce2                	ld	s9,24(sp)
ffffffffc020204e:	6d42                	ld	s10,16(sp)
ffffffffc0202050:	6165                	addi	sp,sp,112
ffffffffc0202052:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202054:	0017f713          	andi	a4,a5,1
ffffffffc0202058:	df69                	beqz	a4,ffffffffc0202032 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc020205a:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020205e:	078a                	slli	a5,a5,0x2
ffffffffc0202060:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202062:	08e7ff63          	bgeu	a5,a4,ffffffffc0202100 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc0202066:	000c3503          	ld	a0,0(s8)
ffffffffc020206a:	97de                	add	a5,a5,s7
ffffffffc020206c:	079a                	slli	a5,a5,0x6
ffffffffc020206e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202070:	411c                	lw	a5,0(a0)
ffffffffc0202072:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202076:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202078:	cf11                	beqz	a4,ffffffffc0202094 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020207a:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020207e:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202082:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202084:	bf45                	j	ffffffffc0202034 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202086:	945a                	add	s0,s0,s6
ffffffffc0202088:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc020208c:	d455                	beqz	s0,ffffffffc0202038 <unmap_range+0x7a>
ffffffffc020208e:	f92469e3          	bltu	s0,s2,ffffffffc0202020 <unmap_range+0x62>
ffffffffc0202092:	b75d                	j	ffffffffc0202038 <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202094:	100027f3          	csrr	a5,sstatus
ffffffffc0202098:	8b89                	andi	a5,a5,2
ffffffffc020209a:	e799                	bnez	a5,ffffffffc02020a8 <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc020209c:	000d3783          	ld	a5,0(s10)
ffffffffc02020a0:	4585                	li	a1,1
ffffffffc02020a2:	739c                	ld	a5,32(a5)
ffffffffc02020a4:	9782                	jalr	a5
    if (flag) {
ffffffffc02020a6:	bfd1                	j	ffffffffc020207a <unmap_range+0xbc>
ffffffffc02020a8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020aa:	d9cfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc02020ae:	000d3783          	ld	a5,0(s10)
ffffffffc02020b2:	6522                	ld	a0,8(sp)
ffffffffc02020b4:	4585                	li	a1,1
ffffffffc02020b6:	739c                	ld	a5,32(a5)
ffffffffc02020b8:	9782                	jalr	a5
        intr_enable();
ffffffffc02020ba:	d86fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02020be:	bf75                	j	ffffffffc020207a <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020c0:	00005697          	auipc	a3,0x5
ffffffffc02020c4:	37068693          	addi	a3,a3,880 # ffffffffc0207430 <default_pmm_manager+0x160>
ffffffffc02020c8:	00005617          	auipc	a2,0x5
ffffffffc02020cc:	b7060613          	addi	a2,a2,-1168 # ffffffffc0206c38 <commands+0x450>
ffffffffc02020d0:	10f00593          	li	a1,271
ffffffffc02020d4:	00005517          	auipc	a0,0x5
ffffffffc02020d8:	34c50513          	addi	a0,a0,844 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc02020dc:	b9efe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02020e0:	00005697          	auipc	a3,0x5
ffffffffc02020e4:	38068693          	addi	a3,a3,896 # ffffffffc0207460 <default_pmm_manager+0x190>
ffffffffc02020e8:	00005617          	auipc	a2,0x5
ffffffffc02020ec:	b5060613          	addi	a2,a2,-1200 # ffffffffc0206c38 <commands+0x450>
ffffffffc02020f0:	11000593          	li	a1,272
ffffffffc02020f4:	00005517          	auipc	a0,0x5
ffffffffc02020f8:	32c50513          	addi	a0,a0,812 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc02020fc:	b7efe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202100:	b55ff0ef          	jal	ra,ffffffffc0201c54 <pa2page.part.0>

ffffffffc0202104 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202104:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202106:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020210a:	fc86                	sd	ra,120(sp)
ffffffffc020210c:	f8a2                	sd	s0,112(sp)
ffffffffc020210e:	f4a6                	sd	s1,104(sp)
ffffffffc0202110:	f0ca                	sd	s2,96(sp)
ffffffffc0202112:	ecce                	sd	s3,88(sp)
ffffffffc0202114:	e8d2                	sd	s4,80(sp)
ffffffffc0202116:	e4d6                	sd	s5,72(sp)
ffffffffc0202118:	e0da                	sd	s6,64(sp)
ffffffffc020211a:	fc5e                	sd	s7,56(sp)
ffffffffc020211c:	f862                	sd	s8,48(sp)
ffffffffc020211e:	f466                	sd	s9,40(sp)
ffffffffc0202120:	f06a                	sd	s10,32(sp)
ffffffffc0202122:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202124:	17d2                	slli	a5,a5,0x34
ffffffffc0202126:	20079a63          	bnez	a5,ffffffffc020233a <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc020212a:	002007b7          	lui	a5,0x200
ffffffffc020212e:	24f5e463          	bltu	a1,a5,ffffffffc0202376 <exit_range+0x272>
ffffffffc0202132:	8ab2                	mv	s5,a2
ffffffffc0202134:	24c5f163          	bgeu	a1,a2,ffffffffc0202376 <exit_range+0x272>
ffffffffc0202138:	4785                	li	a5,1
ffffffffc020213a:	07fe                	slli	a5,a5,0x1f
ffffffffc020213c:	22c7ed63          	bltu	a5,a2,ffffffffc0202376 <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202140:	c00009b7          	lui	s3,0xc0000
ffffffffc0202144:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202148:	ffe00937          	lui	s2,0xffe00
ffffffffc020214c:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc0202150:	5cfd                	li	s9,-1
ffffffffc0202152:	8c2a                	mv	s8,a0
ffffffffc0202154:	0125f933          	and	s2,a1,s2
ffffffffc0202158:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc020215a:	000b1d17          	auipc	s10,0xb1
ffffffffc020215e:	8eed0d13          	addi	s10,s10,-1810 # ffffffffc02b2a48 <npage>
    return KADDR(page2pa(page));
ffffffffc0202162:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202166:	000b1717          	auipc	a4,0xb1
ffffffffc020216a:	8ea70713          	addi	a4,a4,-1814 # ffffffffc02b2a50 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc020216e:	000b1d97          	auipc	s11,0xb1
ffffffffc0202172:	8ead8d93          	addi	s11,s11,-1814 # ffffffffc02b2a58 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202176:	c0000437          	lui	s0,0xc0000
ffffffffc020217a:	944e                	add	s0,s0,s3
ffffffffc020217c:	8079                	srli	s0,s0,0x1e
ffffffffc020217e:	1ff47413          	andi	s0,s0,511
ffffffffc0202182:	040e                	slli	s0,s0,0x3
ffffffffc0202184:	9462                	add	s0,s0,s8
ffffffffc0202186:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4eb8>
        if (pde1&PTE_V){
ffffffffc020218a:	001a7793          	andi	a5,s4,1
ffffffffc020218e:	eb99                	bnez	a5,ffffffffc02021a4 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc0202190:	12098463          	beqz	s3,ffffffffc02022b8 <exit_range+0x1b4>
ffffffffc0202194:	400007b7          	lui	a5,0x40000
ffffffffc0202198:	97ce                	add	a5,a5,s3
ffffffffc020219a:	894e                	mv	s2,s3
ffffffffc020219c:	1159fe63          	bgeu	s3,s5,ffffffffc02022b8 <exit_range+0x1b4>
ffffffffc02021a0:	89be                	mv	s3,a5
ffffffffc02021a2:	bfd1                	j	ffffffffc0202176 <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02021a4:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021a8:	0a0a                	slli	s4,s4,0x2
ffffffffc02021aa:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021ae:	1cfa7263          	bgeu	s4,a5,ffffffffc0202372 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02021b2:	fff80637          	lui	a2,0xfff80
ffffffffc02021b6:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc02021b8:	000806b7          	lui	a3,0x80
ffffffffc02021bc:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc02021be:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc02021c2:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02021c4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02021c6:	18f5fa63          	bgeu	a1,a5,ffffffffc020235a <exit_range+0x256>
ffffffffc02021ca:	000b1817          	auipc	a6,0xb1
ffffffffc02021ce:	89680813          	addi	a6,a6,-1898 # ffffffffc02b2a60 <va_pa_offset>
ffffffffc02021d2:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc02021d6:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc02021d8:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc02021dc:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc02021de:	00080337          	lui	t1,0x80
ffffffffc02021e2:	6885                	lui	a7,0x1
ffffffffc02021e4:	a819                	j	ffffffffc02021fa <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc02021e6:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc02021e8:	002007b7          	lui	a5,0x200
ffffffffc02021ec:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02021ee:	08090c63          	beqz	s2,ffffffffc0202286 <exit_range+0x182>
ffffffffc02021f2:	09397a63          	bgeu	s2,s3,ffffffffc0202286 <exit_range+0x182>
ffffffffc02021f6:	0f597063          	bgeu	s2,s5,ffffffffc02022d6 <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02021fa:	01595493          	srli	s1,s2,0x15
ffffffffc02021fe:	1ff4f493          	andi	s1,s1,511
ffffffffc0202202:	048e                	slli	s1,s1,0x3
ffffffffc0202204:	94da                	add	s1,s1,s6
ffffffffc0202206:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc0202208:	0017f693          	andi	a3,a5,1
ffffffffc020220c:	dee9                	beqz	a3,ffffffffc02021e6 <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc020220e:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202212:	078a                	slli	a5,a5,0x2
ffffffffc0202214:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202216:	14b7fe63          	bgeu	a5,a1,ffffffffc0202372 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020221a:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc020221c:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202220:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202224:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202228:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020222a:	12bef863          	bgeu	t4,a1,ffffffffc020235a <exit_range+0x256>
ffffffffc020222e:	00083783          	ld	a5,0(a6)
ffffffffc0202232:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202234:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc0202238:	629c                	ld	a5,0(a3)
ffffffffc020223a:	8b85                	andi	a5,a5,1
ffffffffc020223c:	f7d5                	bnez	a5,ffffffffc02021e8 <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020223e:	06a1                	addi	a3,a3,8
ffffffffc0202240:	fed59ce3          	bne	a1,a3,ffffffffc0202238 <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202244:	631c                	ld	a5,0(a4)
ffffffffc0202246:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202248:	100027f3          	csrr	a5,sstatus
ffffffffc020224c:	8b89                	andi	a5,a5,2
ffffffffc020224e:	e7d9                	bnez	a5,ffffffffc02022dc <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc0202250:	000db783          	ld	a5,0(s11)
ffffffffc0202254:	4585                	li	a1,1
ffffffffc0202256:	e032                	sd	a2,0(sp)
ffffffffc0202258:	739c                	ld	a5,32(a5)
ffffffffc020225a:	9782                	jalr	a5
    if (flag) {
ffffffffc020225c:	6602                	ld	a2,0(sp)
ffffffffc020225e:	000b1817          	auipc	a6,0xb1
ffffffffc0202262:	80280813          	addi	a6,a6,-2046 # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0202266:	fff80e37          	lui	t3,0xfff80
ffffffffc020226a:	00080337          	lui	t1,0x80
ffffffffc020226e:	6885                	lui	a7,0x1
ffffffffc0202270:	000b0717          	auipc	a4,0xb0
ffffffffc0202274:	7e070713          	addi	a4,a4,2016 # ffffffffc02b2a50 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202278:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc020227c:	002007b7          	lui	a5,0x200
ffffffffc0202280:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202282:	f60918e3          	bnez	s2,ffffffffc02021f2 <exit_range+0xee>
            if (free_pd0) {
ffffffffc0202286:	f00b85e3          	beqz	s7,ffffffffc0202190 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc020228a:	000d3783          	ld	a5,0(s10)
ffffffffc020228e:	0efa7263          	bgeu	s4,a5,ffffffffc0202372 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202292:	6308                	ld	a0,0(a4)
ffffffffc0202294:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202296:	100027f3          	csrr	a5,sstatus
ffffffffc020229a:	8b89                	andi	a5,a5,2
ffffffffc020229c:	efad                	bnez	a5,ffffffffc0202316 <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc020229e:	000db783          	ld	a5,0(s11)
ffffffffc02022a2:	4585                	li	a1,1
ffffffffc02022a4:	739c                	ld	a5,32(a5)
ffffffffc02022a6:	9782                	jalr	a5
ffffffffc02022a8:	000b0717          	auipc	a4,0xb0
ffffffffc02022ac:	7a870713          	addi	a4,a4,1960 # ffffffffc02b2a50 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02022b0:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc02022b4:	ee0990e3          	bnez	s3,ffffffffc0202194 <exit_range+0x90>
}
ffffffffc02022b8:	70e6                	ld	ra,120(sp)
ffffffffc02022ba:	7446                	ld	s0,112(sp)
ffffffffc02022bc:	74a6                	ld	s1,104(sp)
ffffffffc02022be:	7906                	ld	s2,96(sp)
ffffffffc02022c0:	69e6                	ld	s3,88(sp)
ffffffffc02022c2:	6a46                	ld	s4,80(sp)
ffffffffc02022c4:	6aa6                	ld	s5,72(sp)
ffffffffc02022c6:	6b06                	ld	s6,64(sp)
ffffffffc02022c8:	7be2                	ld	s7,56(sp)
ffffffffc02022ca:	7c42                	ld	s8,48(sp)
ffffffffc02022cc:	7ca2                	ld	s9,40(sp)
ffffffffc02022ce:	7d02                	ld	s10,32(sp)
ffffffffc02022d0:	6de2                	ld	s11,24(sp)
ffffffffc02022d2:	6109                	addi	sp,sp,128
ffffffffc02022d4:	8082                	ret
            if (free_pd0) {
ffffffffc02022d6:	ea0b8fe3          	beqz	s7,ffffffffc0202194 <exit_range+0x90>
ffffffffc02022da:	bf45                	j	ffffffffc020228a <exit_range+0x186>
ffffffffc02022dc:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc02022de:	e42a                	sd	a0,8(sp)
ffffffffc02022e0:	b66fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02022e4:	000db783          	ld	a5,0(s11)
ffffffffc02022e8:	6522                	ld	a0,8(sp)
ffffffffc02022ea:	4585                	li	a1,1
ffffffffc02022ec:	739c                	ld	a5,32(a5)
ffffffffc02022ee:	9782                	jalr	a5
        intr_enable();
ffffffffc02022f0:	b50fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02022f4:	6602                	ld	a2,0(sp)
ffffffffc02022f6:	000b0717          	auipc	a4,0xb0
ffffffffc02022fa:	75a70713          	addi	a4,a4,1882 # ffffffffc02b2a50 <pages>
ffffffffc02022fe:	6885                	lui	a7,0x1
ffffffffc0202300:	00080337          	lui	t1,0x80
ffffffffc0202304:	fff80e37          	lui	t3,0xfff80
ffffffffc0202308:	000b0817          	auipc	a6,0xb0
ffffffffc020230c:	75880813          	addi	a6,a6,1880 # ffffffffc02b2a60 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202310:	0004b023          	sd	zero,0(s1)
ffffffffc0202314:	b7a5                	j	ffffffffc020227c <exit_range+0x178>
ffffffffc0202316:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0202318:	b2efe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020231c:	000db783          	ld	a5,0(s11)
ffffffffc0202320:	6502                	ld	a0,0(sp)
ffffffffc0202322:	4585                	li	a1,1
ffffffffc0202324:	739c                	ld	a5,32(a5)
ffffffffc0202326:	9782                	jalr	a5
        intr_enable();
ffffffffc0202328:	b18fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020232c:	000b0717          	auipc	a4,0xb0
ffffffffc0202330:	72470713          	addi	a4,a4,1828 # ffffffffc02b2a50 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202334:	00043023          	sd	zero,0(s0)
ffffffffc0202338:	bfb5                	j	ffffffffc02022b4 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020233a:	00005697          	auipc	a3,0x5
ffffffffc020233e:	0f668693          	addi	a3,a3,246 # ffffffffc0207430 <default_pmm_manager+0x160>
ffffffffc0202342:	00005617          	auipc	a2,0x5
ffffffffc0202346:	8f660613          	addi	a2,a2,-1802 # ffffffffc0206c38 <commands+0x450>
ffffffffc020234a:	12000593          	li	a1,288
ffffffffc020234e:	00005517          	auipc	a0,0x5
ffffffffc0202352:	0d250513          	addi	a0,a0,210 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202356:	924fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc020235a:	00005617          	auipc	a2,0x5
ffffffffc020235e:	fae60613          	addi	a2,a2,-82 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0202362:	06900593          	li	a1,105
ffffffffc0202366:	00005517          	auipc	a0,0x5
ffffffffc020236a:	fca50513          	addi	a0,a0,-54 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc020236e:	90cfe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202372:	8e3ff0ef          	jal	ra,ffffffffc0201c54 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202376:	00005697          	auipc	a3,0x5
ffffffffc020237a:	0ea68693          	addi	a3,a3,234 # ffffffffc0207460 <default_pmm_manager+0x190>
ffffffffc020237e:	00005617          	auipc	a2,0x5
ffffffffc0202382:	8ba60613          	addi	a2,a2,-1862 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202386:	12100593          	li	a1,289
ffffffffc020238a:	00005517          	auipc	a0,0x5
ffffffffc020238e:	09650513          	addi	a0,a0,150 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202392:	8e8fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0202396 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202396:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202398:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc020239a:	ec26                	sd	s1,24(sp)
ffffffffc020239c:	f406                	sd	ra,40(sp)
ffffffffc020239e:	f022                	sd	s0,32(sp)
ffffffffc02023a0:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023a2:	9f7ff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
    if (ptep != NULL) {
ffffffffc02023a6:	c511                	beqz	a0,ffffffffc02023b2 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023a8:	611c                	ld	a5,0(a0)
ffffffffc02023aa:	842a                	mv	s0,a0
ffffffffc02023ac:	0017f713          	andi	a4,a5,1
ffffffffc02023b0:	e711                	bnez	a4,ffffffffc02023bc <page_remove+0x26>
}
ffffffffc02023b2:	70a2                	ld	ra,40(sp)
ffffffffc02023b4:	7402                	ld	s0,32(sp)
ffffffffc02023b6:	64e2                	ld	s1,24(sp)
ffffffffc02023b8:	6145                	addi	sp,sp,48
ffffffffc02023ba:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02023bc:	078a                	slli	a5,a5,0x2
ffffffffc02023be:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023c0:	000b0717          	auipc	a4,0xb0
ffffffffc02023c4:	68873703          	ld	a4,1672(a4) # ffffffffc02b2a48 <npage>
ffffffffc02023c8:	06e7f363          	bgeu	a5,a4,ffffffffc020242e <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02023cc:	fff80537          	lui	a0,0xfff80
ffffffffc02023d0:	97aa                	add	a5,a5,a0
ffffffffc02023d2:	079a                	slli	a5,a5,0x6
ffffffffc02023d4:	000b0517          	auipc	a0,0xb0
ffffffffc02023d8:	67c53503          	ld	a0,1660(a0) # ffffffffc02b2a50 <pages>
ffffffffc02023dc:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02023de:	411c                	lw	a5,0(a0)
ffffffffc02023e0:	fff7871b          	addiw	a4,a5,-1
ffffffffc02023e4:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02023e6:	cb11                	beqz	a4,ffffffffc02023fa <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02023e8:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02023ec:	12048073          	sfence.vma	s1
}
ffffffffc02023f0:	70a2                	ld	ra,40(sp)
ffffffffc02023f2:	7402                	ld	s0,32(sp)
ffffffffc02023f4:	64e2                	ld	s1,24(sp)
ffffffffc02023f6:	6145                	addi	sp,sp,48
ffffffffc02023f8:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023fa:	100027f3          	csrr	a5,sstatus
ffffffffc02023fe:	8b89                	andi	a5,a5,2
ffffffffc0202400:	eb89                	bnez	a5,ffffffffc0202412 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202402:	000b0797          	auipc	a5,0xb0
ffffffffc0202406:	6567b783          	ld	a5,1622(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc020240a:	739c                	ld	a5,32(a5)
ffffffffc020240c:	4585                	li	a1,1
ffffffffc020240e:	9782                	jalr	a5
    if (flag) {
ffffffffc0202410:	bfe1                	j	ffffffffc02023e8 <page_remove+0x52>
        intr_disable();
ffffffffc0202412:	e42a                	sd	a0,8(sp)
ffffffffc0202414:	a32fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202418:	000b0797          	auipc	a5,0xb0
ffffffffc020241c:	6407b783          	ld	a5,1600(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc0202420:	739c                	ld	a5,32(a5)
ffffffffc0202422:	6522                	ld	a0,8(sp)
ffffffffc0202424:	4585                	li	a1,1
ffffffffc0202426:	9782                	jalr	a5
        intr_enable();
ffffffffc0202428:	a18fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020242c:	bf75                	j	ffffffffc02023e8 <page_remove+0x52>
ffffffffc020242e:	827ff0ef          	jal	ra,ffffffffc0201c54 <pa2page.part.0>

ffffffffc0202432 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202432:	7139                	addi	sp,sp,-64
ffffffffc0202434:	e852                	sd	s4,16(sp)
ffffffffc0202436:	8a32                	mv	s4,a2
ffffffffc0202438:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020243a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020243c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020243e:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202440:	f426                	sd	s1,40(sp)
ffffffffc0202442:	fc06                	sd	ra,56(sp)
ffffffffc0202444:	f04a                	sd	s2,32(sp)
ffffffffc0202446:	ec4e                	sd	s3,24(sp)
ffffffffc0202448:	e456                	sd	s5,8(sp)
ffffffffc020244a:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020244c:	94dff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
    if (ptep == NULL) {
ffffffffc0202450:	c961                	beqz	a0,ffffffffc0202520 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202452:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202454:	611c                	ld	a5,0(a0)
ffffffffc0202456:	89aa                	mv	s3,a0
ffffffffc0202458:	0016871b          	addiw	a4,a3,1
ffffffffc020245c:	c018                	sw	a4,0(s0)
ffffffffc020245e:	0017f713          	andi	a4,a5,1
ffffffffc0202462:	ef05                	bnez	a4,ffffffffc020249a <page_insert+0x68>
    return page - pages + nbase;
ffffffffc0202464:	000b0717          	auipc	a4,0xb0
ffffffffc0202468:	5ec73703          	ld	a4,1516(a4) # ffffffffc02b2a50 <pages>
ffffffffc020246c:	8c19                	sub	s0,s0,a4
ffffffffc020246e:	000807b7          	lui	a5,0x80
ffffffffc0202472:	8419                	srai	s0,s0,0x6
ffffffffc0202474:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202476:	042a                	slli	s0,s0,0xa
ffffffffc0202478:	8cc1                	or	s1,s1,s0
ffffffffc020247a:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020247e:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4eb8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202482:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0202486:	4501                	li	a0,0
}
ffffffffc0202488:	70e2                	ld	ra,56(sp)
ffffffffc020248a:	7442                	ld	s0,48(sp)
ffffffffc020248c:	74a2                	ld	s1,40(sp)
ffffffffc020248e:	7902                	ld	s2,32(sp)
ffffffffc0202490:	69e2                	ld	s3,24(sp)
ffffffffc0202492:	6a42                	ld	s4,16(sp)
ffffffffc0202494:	6aa2                	ld	s5,8(sp)
ffffffffc0202496:	6121                	addi	sp,sp,64
ffffffffc0202498:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc020249a:	078a                	slli	a5,a5,0x2
ffffffffc020249c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020249e:	000b0717          	auipc	a4,0xb0
ffffffffc02024a2:	5aa73703          	ld	a4,1450(a4) # ffffffffc02b2a48 <npage>
ffffffffc02024a6:	06e7ff63          	bgeu	a5,a4,ffffffffc0202524 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02024aa:	000b0a97          	auipc	s5,0xb0
ffffffffc02024ae:	5a6a8a93          	addi	s5,s5,1446 # ffffffffc02b2a50 <pages>
ffffffffc02024b2:	000ab703          	ld	a4,0(s5)
ffffffffc02024b6:	fff80937          	lui	s2,0xfff80
ffffffffc02024ba:	993e                	add	s2,s2,a5
ffffffffc02024bc:	091a                	slli	s2,s2,0x6
ffffffffc02024be:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc02024c0:	01240c63          	beq	s0,s2,ffffffffc02024d8 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc02024c4:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd554>
ffffffffc02024c8:	fff7869b          	addiw	a3,a5,-1
ffffffffc02024cc:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc02024d0:	c691                	beqz	a3,ffffffffc02024dc <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024d2:	120a0073          	sfence.vma	s4
}
ffffffffc02024d6:	bf59                	j	ffffffffc020246c <page_insert+0x3a>
ffffffffc02024d8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02024da:	bf49                	j	ffffffffc020246c <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02024dc:	100027f3          	csrr	a5,sstatus
ffffffffc02024e0:	8b89                	andi	a5,a5,2
ffffffffc02024e2:	ef91                	bnez	a5,ffffffffc02024fe <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc02024e4:	000b0797          	auipc	a5,0xb0
ffffffffc02024e8:	5747b783          	ld	a5,1396(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc02024ec:	739c                	ld	a5,32(a5)
ffffffffc02024ee:	4585                	li	a1,1
ffffffffc02024f0:	854a                	mv	a0,s2
ffffffffc02024f2:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02024f4:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024f8:	120a0073          	sfence.vma	s4
ffffffffc02024fc:	bf85                	j	ffffffffc020246c <page_insert+0x3a>
        intr_disable();
ffffffffc02024fe:	948fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202502:	000b0797          	auipc	a5,0xb0
ffffffffc0202506:	5567b783          	ld	a5,1366(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc020250a:	739c                	ld	a5,32(a5)
ffffffffc020250c:	4585                	li	a1,1
ffffffffc020250e:	854a                	mv	a0,s2
ffffffffc0202510:	9782                	jalr	a5
        intr_enable();
ffffffffc0202512:	92efe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202516:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020251a:	120a0073          	sfence.vma	s4
ffffffffc020251e:	b7b9                	j	ffffffffc020246c <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202520:	5571                	li	a0,-4
ffffffffc0202522:	b79d                	j	ffffffffc0202488 <page_insert+0x56>
ffffffffc0202524:	f30ff0ef          	jal	ra,ffffffffc0201c54 <pa2page.part.0>

ffffffffc0202528 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202528:	00005797          	auipc	a5,0x5
ffffffffc020252c:	da878793          	addi	a5,a5,-600 # ffffffffc02072d0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202530:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202532:	711d                	addi	sp,sp,-96
ffffffffc0202534:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202536:	00005517          	auipc	a0,0x5
ffffffffc020253a:	f4250513          	addi	a0,a0,-190 # ffffffffc0207478 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc020253e:	000b0b97          	auipc	s7,0xb0
ffffffffc0202542:	51ab8b93          	addi	s7,s7,1306 # ffffffffc02b2a58 <pmm_manager>
void pmm_init(void) {
ffffffffc0202546:	ec86                	sd	ra,88(sp)
ffffffffc0202548:	e4a6                	sd	s1,72(sp)
ffffffffc020254a:	fc4e                	sd	s3,56(sp)
ffffffffc020254c:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020254e:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202552:	e8a2                	sd	s0,80(sp)
ffffffffc0202554:	e0ca                	sd	s2,64(sp)
ffffffffc0202556:	f852                	sd	s4,48(sp)
ffffffffc0202558:	f456                	sd	s5,40(sp)
ffffffffc020255a:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020255c:	c25fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc0202560:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202564:	000b0997          	auipc	s3,0xb0
ffffffffc0202568:	4fc98993          	addi	s3,s3,1276 # ffffffffc02b2a60 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020256c:	000b0497          	auipc	s1,0xb0
ffffffffc0202570:	4dc48493          	addi	s1,s1,1244 # ffffffffc02b2a48 <npage>
    pmm_manager->init();
ffffffffc0202574:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202576:	000b0b17          	auipc	s6,0xb0
ffffffffc020257a:	4dab0b13          	addi	s6,s6,1242 # ffffffffc02b2a50 <pages>
    pmm_manager->init();
ffffffffc020257e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202580:	57f5                	li	a5,-3
ffffffffc0202582:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202584:	00005517          	auipc	a0,0x5
ffffffffc0202588:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207490 <default_pmm_manager+0x1c0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020258c:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc0202590:	bf1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202594:	46c5                	li	a3,17
ffffffffc0202596:	06ee                	slli	a3,a3,0x1b
ffffffffc0202598:	40100613          	li	a2,1025
ffffffffc020259c:	07e005b7          	lui	a1,0x7e00
ffffffffc02025a0:	16fd                	addi	a3,a3,-1
ffffffffc02025a2:	0656                	slli	a2,a2,0x15
ffffffffc02025a4:	00005517          	auipc	a0,0x5
ffffffffc02025a8:	f0450513          	addi	a0,a0,-252 # ffffffffc02074a8 <default_pmm_manager+0x1d8>
ffffffffc02025ac:	bd5fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025b0:	777d                	lui	a4,0xfffff
ffffffffc02025b2:	000b1797          	auipc	a5,0xb1
ffffffffc02025b6:	4f978793          	addi	a5,a5,1273 # ffffffffc02b3aab <end+0xfff>
ffffffffc02025ba:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02025bc:	00088737          	lui	a4,0x88
ffffffffc02025c0:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025c2:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02025c6:	4701                	li	a4,0
ffffffffc02025c8:	4585                	li	a1,1
ffffffffc02025ca:	fff80837          	lui	a6,0xfff80
ffffffffc02025ce:	a019                	j	ffffffffc02025d4 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc02025d0:	000b3783          	ld	a5,0(s6)
ffffffffc02025d4:	00671693          	slli	a3,a4,0x6
ffffffffc02025d8:	97b6                	add	a5,a5,a3
ffffffffc02025da:	07a1                	addi	a5,a5,8
ffffffffc02025dc:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02025e0:	6090                	ld	a2,0(s1)
ffffffffc02025e2:	0705                	addi	a4,a4,1
ffffffffc02025e4:	010607b3          	add	a5,a2,a6
ffffffffc02025e8:	fef764e3          	bltu	a4,a5,ffffffffc02025d0 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02025ec:	000b3503          	ld	a0,0(s6)
ffffffffc02025f0:	079a                	slli	a5,a5,0x6
ffffffffc02025f2:	c0200737          	lui	a4,0xc0200
ffffffffc02025f6:	00f506b3          	add	a3,a0,a5
ffffffffc02025fa:	60e6e563          	bltu	a3,a4,ffffffffc0202c04 <pmm_init+0x6dc>
ffffffffc02025fe:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202602:	4745                	li	a4,17
ffffffffc0202604:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202606:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202608:	4ae6e563          	bltu	a3,a4,ffffffffc0202ab2 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020260c:	00005517          	auipc	a0,0x5
ffffffffc0202610:	ec450513          	addi	a0,a0,-316 # ffffffffc02074d0 <default_pmm_manager+0x200>
ffffffffc0202614:	b6dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202618:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020261c:	000b0917          	auipc	s2,0xb0
ffffffffc0202620:	42490913          	addi	s2,s2,1060 # ffffffffc02b2a40 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202624:	7b9c                	ld	a5,48(a5)
ffffffffc0202626:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202628:	00005517          	auipc	a0,0x5
ffffffffc020262c:	ec050513          	addi	a0,a0,-320 # ffffffffc02074e8 <default_pmm_manager+0x218>
ffffffffc0202630:	b51fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202634:	00009697          	auipc	a3,0x9
ffffffffc0202638:	9cc68693          	addi	a3,a3,-1588 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020263c:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202640:	c02007b7          	lui	a5,0xc0200
ffffffffc0202644:	5cf6ec63          	bltu	a3,a5,ffffffffc0202c1c <pmm_init+0x6f4>
ffffffffc0202648:	0009b783          	ld	a5,0(s3)
ffffffffc020264c:	8e9d                	sub	a3,a3,a5
ffffffffc020264e:	000b0797          	auipc	a5,0xb0
ffffffffc0202652:	3ed7b523          	sd	a3,1002(a5) # ffffffffc02b2a38 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202656:	100027f3          	csrr	a5,sstatus
ffffffffc020265a:	8b89                	andi	a5,a5,2
ffffffffc020265c:	48079263          	bnez	a5,ffffffffc0202ae0 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202660:	000bb783          	ld	a5,0(s7)
ffffffffc0202664:	779c                	ld	a5,40(a5)
ffffffffc0202666:	9782                	jalr	a5
ffffffffc0202668:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020266a:	6098                	ld	a4,0(s1)
ffffffffc020266c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202670:	83b1                	srli	a5,a5,0xc
ffffffffc0202672:	5ee7e163          	bltu	a5,a4,ffffffffc0202c54 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202676:	00093503          	ld	a0,0(s2)
ffffffffc020267a:	5a050d63          	beqz	a0,ffffffffc0202c34 <pmm_init+0x70c>
ffffffffc020267e:	03451793          	slli	a5,a0,0x34
ffffffffc0202682:	5a079963          	bnez	a5,ffffffffc0202c34 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202686:	4601                	li	a2,0
ffffffffc0202688:	4581                	li	a1,0
ffffffffc020268a:	8e1ff0ef          	jal	ra,ffffffffc0201f6a <get_page>
ffffffffc020268e:	62051563          	bnez	a0,ffffffffc0202cb8 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202692:	4505                	li	a0,1
ffffffffc0202694:	df8ff0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0202698:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020269a:	00093503          	ld	a0,0(s2)
ffffffffc020269e:	4681                	li	a3,0
ffffffffc02026a0:	4601                	li	a2,0
ffffffffc02026a2:	85d2                	mv	a1,s4
ffffffffc02026a4:	d8fff0ef          	jal	ra,ffffffffc0202432 <page_insert>
ffffffffc02026a8:	5e051863          	bnez	a0,ffffffffc0202c98 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02026ac:	00093503          	ld	a0,0(s2)
ffffffffc02026b0:	4601                	li	a2,0
ffffffffc02026b2:	4581                	li	a1,0
ffffffffc02026b4:	ee4ff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc02026b8:	5c050063          	beqz	a0,ffffffffc0202c78 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc02026bc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02026be:	0017f713          	andi	a4,a5,1
ffffffffc02026c2:	5a070963          	beqz	a4,ffffffffc0202c74 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02026c6:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02026c8:	078a                	slli	a5,a5,0x2
ffffffffc02026ca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026cc:	52e7fa63          	bgeu	a5,a4,ffffffffc0202c00 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02026d0:	000b3683          	ld	a3,0(s6)
ffffffffc02026d4:	fff80637          	lui	a2,0xfff80
ffffffffc02026d8:	97b2                	add	a5,a5,a2
ffffffffc02026da:	079a                	slli	a5,a5,0x6
ffffffffc02026dc:	97b6                	add	a5,a5,a3
ffffffffc02026de:	10fa16e3          	bne	s4,a5,ffffffffc0202fea <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc02026e2:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc02026e6:	4785                	li	a5,1
ffffffffc02026e8:	12f69de3          	bne	a3,a5,ffffffffc0203022 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02026ec:	00093503          	ld	a0,0(s2)
ffffffffc02026f0:	77fd                	lui	a5,0xfffff
ffffffffc02026f2:	6114                	ld	a3,0(a0)
ffffffffc02026f4:	068a                	slli	a3,a3,0x2
ffffffffc02026f6:	8efd                	and	a3,a3,a5
ffffffffc02026f8:	00c6d613          	srli	a2,a3,0xc
ffffffffc02026fc:	10e677e3          	bgeu	a2,a4,ffffffffc020300a <pmm_init+0xae2>
ffffffffc0202700:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202704:	96e2                	add	a3,a3,s8
ffffffffc0202706:	0006ba83          	ld	s5,0(a3)
ffffffffc020270a:	0a8a                	slli	s5,s5,0x2
ffffffffc020270c:	00fafab3          	and	s5,s5,a5
ffffffffc0202710:	00cad793          	srli	a5,s5,0xc
ffffffffc0202714:	62e7f263          	bgeu	a5,a4,ffffffffc0202d38 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202718:	4601                	li	a2,0
ffffffffc020271a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020271c:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020271e:	e7aff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202722:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202724:	5f551a63          	bne	a0,s5,ffffffffc0202d18 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc0202728:	4505                	li	a0,1
ffffffffc020272a:	d62ff0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc020272e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202730:	00093503          	ld	a0,0(s2)
ffffffffc0202734:	46d1                	li	a3,20
ffffffffc0202736:	6605                	lui	a2,0x1
ffffffffc0202738:	85d6                	mv	a1,s5
ffffffffc020273a:	cf9ff0ef          	jal	ra,ffffffffc0202432 <page_insert>
ffffffffc020273e:	58051d63          	bnez	a0,ffffffffc0202cd8 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202742:	00093503          	ld	a0,0(s2)
ffffffffc0202746:	4601                	li	a2,0
ffffffffc0202748:	6585                	lui	a1,0x1
ffffffffc020274a:	e4eff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc020274e:	0e050ae3          	beqz	a0,ffffffffc0203042 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc0202752:	611c                	ld	a5,0(a0)
ffffffffc0202754:	0107f713          	andi	a4,a5,16
ffffffffc0202758:	6e070d63          	beqz	a4,ffffffffc0202e52 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc020275c:	8b91                	andi	a5,a5,4
ffffffffc020275e:	6a078a63          	beqz	a5,ffffffffc0202e12 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202762:	00093503          	ld	a0,0(s2)
ffffffffc0202766:	611c                	ld	a5,0(a0)
ffffffffc0202768:	8bc1                	andi	a5,a5,16
ffffffffc020276a:	68078463          	beqz	a5,ffffffffc0202df2 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc020276e:	000aa703          	lw	a4,0(s5)
ffffffffc0202772:	4785                	li	a5,1
ffffffffc0202774:	58f71263          	bne	a4,a5,ffffffffc0202cf8 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202778:	4681                	li	a3,0
ffffffffc020277a:	6605                	lui	a2,0x1
ffffffffc020277c:	85d2                	mv	a1,s4
ffffffffc020277e:	cb5ff0ef          	jal	ra,ffffffffc0202432 <page_insert>
ffffffffc0202782:	62051863          	bnez	a0,ffffffffc0202db2 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0202786:	000a2703          	lw	a4,0(s4)
ffffffffc020278a:	4789                	li	a5,2
ffffffffc020278c:	60f71363          	bne	a4,a5,ffffffffc0202d92 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc0202790:	000aa783          	lw	a5,0(s5)
ffffffffc0202794:	5c079f63          	bnez	a5,ffffffffc0202d72 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202798:	00093503          	ld	a0,0(s2)
ffffffffc020279c:	4601                	li	a2,0
ffffffffc020279e:	6585                	lui	a1,0x1
ffffffffc02027a0:	df8ff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc02027a4:	5a050763          	beqz	a0,ffffffffc0202d52 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02027a8:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027aa:	00177793          	andi	a5,a4,1
ffffffffc02027ae:	4c078363          	beqz	a5,ffffffffc0202c74 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc02027b2:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027b4:	00271793          	slli	a5,a4,0x2
ffffffffc02027b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027ba:	44d7f363          	bgeu	a5,a3,ffffffffc0202c00 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02027be:	000b3683          	ld	a3,0(s6)
ffffffffc02027c2:	fff80637          	lui	a2,0xfff80
ffffffffc02027c6:	97b2                	add	a5,a5,a2
ffffffffc02027c8:	079a                	slli	a5,a5,0x6
ffffffffc02027ca:	97b6                	add	a5,a5,a3
ffffffffc02027cc:	6efa1363          	bne	s4,a5,ffffffffc0202eb2 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc02027d0:	8b41                	andi	a4,a4,16
ffffffffc02027d2:	6c071063          	bnez	a4,ffffffffc0202e92 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc02027d6:	00093503          	ld	a0,0(s2)
ffffffffc02027da:	4581                	li	a1,0
ffffffffc02027dc:	bbbff0ef          	jal	ra,ffffffffc0202396 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02027e0:	000a2703          	lw	a4,0(s4)
ffffffffc02027e4:	4785                	li	a5,1
ffffffffc02027e6:	68f71663          	bne	a4,a5,ffffffffc0202e72 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc02027ea:	000aa783          	lw	a5,0(s5)
ffffffffc02027ee:	74079e63          	bnez	a5,ffffffffc0202f4a <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02027f2:	00093503          	ld	a0,0(s2)
ffffffffc02027f6:	6585                	lui	a1,0x1
ffffffffc02027f8:	b9fff0ef          	jal	ra,ffffffffc0202396 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02027fc:	000a2783          	lw	a5,0(s4)
ffffffffc0202800:	72079563          	bnez	a5,ffffffffc0202f2a <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0202804:	000aa783          	lw	a5,0(s5)
ffffffffc0202808:	70079163          	bnez	a5,ffffffffc0202f0a <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020280c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202810:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202812:	000a3683          	ld	a3,0(s4)
ffffffffc0202816:	068a                	slli	a3,a3,0x2
ffffffffc0202818:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020281a:	3ee6f363          	bgeu	a3,a4,ffffffffc0202c00 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020281e:	fff807b7          	lui	a5,0xfff80
ffffffffc0202822:	000b3503          	ld	a0,0(s6)
ffffffffc0202826:	96be                	add	a3,a3,a5
ffffffffc0202828:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020282a:	00d507b3          	add	a5,a0,a3
ffffffffc020282e:	4390                	lw	a2,0(a5)
ffffffffc0202830:	4785                	li	a5,1
ffffffffc0202832:	6af61c63          	bne	a2,a5,ffffffffc0202eea <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc0202836:	8699                	srai	a3,a3,0x6
ffffffffc0202838:	000805b7          	lui	a1,0x80
ffffffffc020283c:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc020283e:	00c69613          	slli	a2,a3,0xc
ffffffffc0202842:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202844:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202846:	68e67663          	bgeu	a2,a4,ffffffffc0202ed2 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020284a:	0009b603          	ld	a2,0(s3)
ffffffffc020284e:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc0202850:	629c                	ld	a5,0(a3)
ffffffffc0202852:	078a                	slli	a5,a5,0x2
ffffffffc0202854:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202856:	3ae7f563          	bgeu	a5,a4,ffffffffc0202c00 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020285a:	8f8d                	sub	a5,a5,a1
ffffffffc020285c:	079a                	slli	a5,a5,0x6
ffffffffc020285e:	953e                	add	a0,a0,a5
ffffffffc0202860:	100027f3          	csrr	a5,sstatus
ffffffffc0202864:	8b89                	andi	a5,a5,2
ffffffffc0202866:	2c079763          	bnez	a5,ffffffffc0202b34 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc020286a:	000bb783          	ld	a5,0(s7)
ffffffffc020286e:	4585                	li	a1,1
ffffffffc0202870:	739c                	ld	a5,32(a5)
ffffffffc0202872:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202874:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202878:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020287a:	078a                	slli	a5,a5,0x2
ffffffffc020287c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020287e:	38e7f163          	bgeu	a5,a4,ffffffffc0202c00 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202882:	000b3503          	ld	a0,0(s6)
ffffffffc0202886:	fff80737          	lui	a4,0xfff80
ffffffffc020288a:	97ba                	add	a5,a5,a4
ffffffffc020288c:	079a                	slli	a5,a5,0x6
ffffffffc020288e:	953e                	add	a0,a0,a5
ffffffffc0202890:	100027f3          	csrr	a5,sstatus
ffffffffc0202894:	8b89                	andi	a5,a5,2
ffffffffc0202896:	28079363          	bnez	a5,ffffffffc0202b1c <pmm_init+0x5f4>
ffffffffc020289a:	000bb783          	ld	a5,0(s7)
ffffffffc020289e:	4585                	li	a1,1
ffffffffc02028a0:	739c                	ld	a5,32(a5)
ffffffffc02028a2:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028a4:	00093783          	ld	a5,0(s2)
ffffffffc02028a8:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd554>
  asm volatile("sfence.vma");
ffffffffc02028ac:	12000073          	sfence.vma
ffffffffc02028b0:	100027f3          	csrr	a5,sstatus
ffffffffc02028b4:	8b89                	andi	a5,a5,2
ffffffffc02028b6:	24079963          	bnez	a5,ffffffffc0202b08 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02028ba:	000bb783          	ld	a5,0(s7)
ffffffffc02028be:	779c                	ld	a5,40(a5)
ffffffffc02028c0:	9782                	jalr	a5
ffffffffc02028c2:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02028c4:	71441363          	bne	s0,s4,ffffffffc0202fca <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02028c8:	00005517          	auipc	a0,0x5
ffffffffc02028cc:	f0850513          	addi	a0,a0,-248 # ffffffffc02077d0 <default_pmm_manager+0x500>
ffffffffc02028d0:	8b1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02028d4:	100027f3          	csrr	a5,sstatus
ffffffffc02028d8:	8b89                	andi	a5,a5,2
ffffffffc02028da:	20079d63          	bnez	a5,ffffffffc0202af4 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc02028de:	000bb783          	ld	a5,0(s7)
ffffffffc02028e2:	779c                	ld	a5,40(a5)
ffffffffc02028e4:	9782                	jalr	a5
ffffffffc02028e6:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02028e8:	6098                	ld	a4,0(s1)
ffffffffc02028ea:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02028ee:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02028f0:	00c71793          	slli	a5,a4,0xc
ffffffffc02028f4:	6a05                	lui	s4,0x1
ffffffffc02028f6:	02f47c63          	bgeu	s0,a5,ffffffffc020292e <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02028fa:	00c45793          	srli	a5,s0,0xc
ffffffffc02028fe:	00093503          	ld	a0,0(s2)
ffffffffc0202902:	2ee7f263          	bgeu	a5,a4,ffffffffc0202be6 <pmm_init+0x6be>
ffffffffc0202906:	0009b583          	ld	a1,0(s3)
ffffffffc020290a:	4601                	li	a2,0
ffffffffc020290c:	95a2                	add	a1,a1,s0
ffffffffc020290e:	c8aff0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc0202912:	2a050a63          	beqz	a0,ffffffffc0202bc6 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202916:	611c                	ld	a5,0(a0)
ffffffffc0202918:	078a                	slli	a5,a5,0x2
ffffffffc020291a:	0157f7b3          	and	a5,a5,s5
ffffffffc020291e:	28879463          	bne	a5,s0,ffffffffc0202ba6 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202922:	6098                	ld	a4,0(s1)
ffffffffc0202924:	9452                	add	s0,s0,s4
ffffffffc0202926:	00c71793          	slli	a5,a4,0xc
ffffffffc020292a:	fcf468e3          	bltu	s0,a5,ffffffffc02028fa <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020292e:	00093783          	ld	a5,0(s2)
ffffffffc0202932:	639c                	ld	a5,0(a5)
ffffffffc0202934:	66079b63          	bnez	a5,ffffffffc0202faa <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc0202938:	4505                	li	a0,1
ffffffffc020293a:	b52ff0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc020293e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202940:	00093503          	ld	a0,0(s2)
ffffffffc0202944:	4699                	li	a3,6
ffffffffc0202946:	10000613          	li	a2,256
ffffffffc020294a:	85d6                	mv	a1,s5
ffffffffc020294c:	ae7ff0ef          	jal	ra,ffffffffc0202432 <page_insert>
ffffffffc0202950:	62051d63          	bnez	a0,ffffffffc0202f8a <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc0202954:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c554>
ffffffffc0202958:	4785                	li	a5,1
ffffffffc020295a:	60f71863          	bne	a4,a5,ffffffffc0202f6a <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020295e:	00093503          	ld	a0,0(s2)
ffffffffc0202962:	6405                	lui	s0,0x1
ffffffffc0202964:	4699                	li	a3,6
ffffffffc0202966:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ad8>
ffffffffc020296a:	85d6                	mv	a1,s5
ffffffffc020296c:	ac7ff0ef          	jal	ra,ffffffffc0202432 <page_insert>
ffffffffc0202970:	46051163          	bnez	a0,ffffffffc0202dd2 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc0202974:	000aa703          	lw	a4,0(s5)
ffffffffc0202978:	4789                	li	a5,2
ffffffffc020297a:	72f71463          	bne	a4,a5,ffffffffc02030a2 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020297e:	00005597          	auipc	a1,0x5
ffffffffc0202982:	f8a58593          	addi	a1,a1,-118 # ffffffffc0207908 <default_pmm_manager+0x638>
ffffffffc0202986:	10000513          	li	a0,256
ffffffffc020298a:	383030ef          	jal	ra,ffffffffc020650c <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020298e:	10040593          	addi	a1,s0,256
ffffffffc0202992:	10000513          	li	a0,256
ffffffffc0202996:	389030ef          	jal	ra,ffffffffc020651e <strcmp>
ffffffffc020299a:	6e051463          	bnez	a0,ffffffffc0203082 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc020299e:	000b3683          	ld	a3,0(s6)
ffffffffc02029a2:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02029a6:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02029a8:	40da86b3          	sub	a3,s5,a3
ffffffffc02029ac:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02029ae:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc02029b0:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc02029b2:	8031                	srli	s0,s0,0xc
ffffffffc02029b4:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02029b8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029ba:	50f77c63          	bgeu	a4,a5,ffffffffc0202ed2 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02029be:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029c2:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02029c6:	96be                	add	a3,a3,a5
ffffffffc02029c8:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029cc:	30b030ef          	jal	ra,ffffffffc02064d6 <strlen>
ffffffffc02029d0:	68051963          	bnez	a0,ffffffffc0203062 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02029d4:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02029d8:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02029da:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc02029de:	068a                	slli	a3,a3,0x2
ffffffffc02029e0:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02029e2:	20f6ff63          	bgeu	a3,a5,ffffffffc0202c00 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc02029e6:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02029e8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02029ea:	4ef47463          	bgeu	s0,a5,ffffffffc0202ed2 <pmm_init+0x9aa>
ffffffffc02029ee:	0009b403          	ld	s0,0(s3)
ffffffffc02029f2:	9436                	add	s0,s0,a3
ffffffffc02029f4:	100027f3          	csrr	a5,sstatus
ffffffffc02029f8:	8b89                	andi	a5,a5,2
ffffffffc02029fa:	18079b63          	bnez	a5,ffffffffc0202b90 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc02029fe:	000bb783          	ld	a5,0(s7)
ffffffffc0202a02:	4585                	li	a1,1
ffffffffc0202a04:	8556                	mv	a0,s5
ffffffffc0202a06:	739c                	ld	a5,32(a5)
ffffffffc0202a08:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a0a:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a0c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a0e:	078a                	slli	a5,a5,0x2
ffffffffc0202a10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a12:	1ee7f763          	bgeu	a5,a4,ffffffffc0202c00 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a16:	000b3503          	ld	a0,0(s6)
ffffffffc0202a1a:	fff80737          	lui	a4,0xfff80
ffffffffc0202a1e:	97ba                	add	a5,a5,a4
ffffffffc0202a20:	079a                	slli	a5,a5,0x6
ffffffffc0202a22:	953e                	add	a0,a0,a5
ffffffffc0202a24:	100027f3          	csrr	a5,sstatus
ffffffffc0202a28:	8b89                	andi	a5,a5,2
ffffffffc0202a2a:	14079763          	bnez	a5,ffffffffc0202b78 <pmm_init+0x650>
ffffffffc0202a2e:	000bb783          	ld	a5,0(s7)
ffffffffc0202a32:	4585                	li	a1,1
ffffffffc0202a34:	739c                	ld	a5,32(a5)
ffffffffc0202a36:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a38:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a3c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a3e:	078a                	slli	a5,a5,0x2
ffffffffc0202a40:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a42:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202c00 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a46:	000b3503          	ld	a0,0(s6)
ffffffffc0202a4a:	fff80737          	lui	a4,0xfff80
ffffffffc0202a4e:	97ba                	add	a5,a5,a4
ffffffffc0202a50:	079a                	slli	a5,a5,0x6
ffffffffc0202a52:	953e                	add	a0,a0,a5
ffffffffc0202a54:	100027f3          	csrr	a5,sstatus
ffffffffc0202a58:	8b89                	andi	a5,a5,2
ffffffffc0202a5a:	10079363          	bnez	a5,ffffffffc0202b60 <pmm_init+0x638>
ffffffffc0202a5e:	000bb783          	ld	a5,0(s7)
ffffffffc0202a62:	4585                	li	a1,1
ffffffffc0202a64:	739c                	ld	a5,32(a5)
ffffffffc0202a66:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202a68:	00093783          	ld	a5,0(s2)
ffffffffc0202a6c:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202a70:	12000073          	sfence.vma
ffffffffc0202a74:	100027f3          	csrr	a5,sstatus
ffffffffc0202a78:	8b89                	andi	a5,a5,2
ffffffffc0202a7a:	0c079963          	bnez	a5,ffffffffc0202b4c <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202a7e:	000bb783          	ld	a5,0(s7)
ffffffffc0202a82:	779c                	ld	a5,40(a5)
ffffffffc0202a84:	9782                	jalr	a5
ffffffffc0202a86:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202a88:	3a8c1563          	bne	s8,s0,ffffffffc0202e32 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202a8c:	00005517          	auipc	a0,0x5
ffffffffc0202a90:	ef450513          	addi	a0,a0,-268 # ffffffffc0207980 <default_pmm_manager+0x6b0>
ffffffffc0202a94:	eecfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202a98:	6446                	ld	s0,80(sp)
ffffffffc0202a9a:	60e6                	ld	ra,88(sp)
ffffffffc0202a9c:	64a6                	ld	s1,72(sp)
ffffffffc0202a9e:	6906                	ld	s2,64(sp)
ffffffffc0202aa0:	79e2                	ld	s3,56(sp)
ffffffffc0202aa2:	7a42                	ld	s4,48(sp)
ffffffffc0202aa4:	7aa2                	ld	s5,40(sp)
ffffffffc0202aa6:	7b02                	ld	s6,32(sp)
ffffffffc0202aa8:	6be2                	ld	s7,24(sp)
ffffffffc0202aaa:	6c42                	ld	s8,16(sp)
ffffffffc0202aac:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202aae:	fddfe06f          	j	ffffffffc0201a8a <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202ab2:	6785                	lui	a5,0x1
ffffffffc0202ab4:	17fd                	addi	a5,a5,-1
ffffffffc0202ab6:	96be                	add	a3,a3,a5
ffffffffc0202ab8:	77fd                	lui	a5,0xfffff
ffffffffc0202aba:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202abc:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202ac0:	14c6f063          	bgeu	a3,a2,ffffffffc0202c00 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202ac4:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202ac8:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202aca:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202ace:	6a10                	ld	a2,16(a2)
ffffffffc0202ad0:	069a                	slli	a3,a3,0x6
ffffffffc0202ad2:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202ad6:	9536                	add	a0,a0,a3
ffffffffc0202ad8:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202ada:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202ade:	b63d                	j	ffffffffc020260c <pmm_init+0xe4>
        intr_disable();
ffffffffc0202ae0:	b67fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ae4:	000bb783          	ld	a5,0(s7)
ffffffffc0202ae8:	779c                	ld	a5,40(a5)
ffffffffc0202aea:	9782                	jalr	a5
ffffffffc0202aec:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202aee:	b53fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202af2:	bea5                	j	ffffffffc020266a <pmm_init+0x142>
        intr_disable();
ffffffffc0202af4:	b53fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202af8:	000bb783          	ld	a5,0(s7)
ffffffffc0202afc:	779c                	ld	a5,40(a5)
ffffffffc0202afe:	9782                	jalr	a5
ffffffffc0202b00:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b02:	b3ffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b06:	b3cd                	j	ffffffffc02028e8 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202b08:	b3ffd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b0c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b10:	779c                	ld	a5,40(a5)
ffffffffc0202b12:	9782                	jalr	a5
ffffffffc0202b14:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b16:	b2bfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b1a:	b36d                	j	ffffffffc02028c4 <pmm_init+0x39c>
ffffffffc0202b1c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b1e:	b29fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b22:	000bb783          	ld	a5,0(s7)
ffffffffc0202b26:	6522                	ld	a0,8(sp)
ffffffffc0202b28:	4585                	li	a1,1
ffffffffc0202b2a:	739c                	ld	a5,32(a5)
ffffffffc0202b2c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b2e:	b13fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b32:	bb8d                	j	ffffffffc02028a4 <pmm_init+0x37c>
ffffffffc0202b34:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b36:	b11fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b3a:	000bb783          	ld	a5,0(s7)
ffffffffc0202b3e:	6522                	ld	a0,8(sp)
ffffffffc0202b40:	4585                	li	a1,1
ffffffffc0202b42:	739c                	ld	a5,32(a5)
ffffffffc0202b44:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b46:	afbfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b4a:	b32d                	j	ffffffffc0202874 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202b4c:	afbfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b50:	000bb783          	ld	a5,0(s7)
ffffffffc0202b54:	779c                	ld	a5,40(a5)
ffffffffc0202b56:	9782                	jalr	a5
ffffffffc0202b58:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b5a:	ae7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b5e:	b72d                	j	ffffffffc0202a88 <pmm_init+0x560>
ffffffffc0202b60:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b62:	ae5fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b66:	000bb783          	ld	a5,0(s7)
ffffffffc0202b6a:	6522                	ld	a0,8(sp)
ffffffffc0202b6c:	4585                	li	a1,1
ffffffffc0202b6e:	739c                	ld	a5,32(a5)
ffffffffc0202b70:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b72:	acffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b76:	bdcd                	j	ffffffffc0202a68 <pmm_init+0x540>
ffffffffc0202b78:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b7a:	acdfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b7e:	000bb783          	ld	a5,0(s7)
ffffffffc0202b82:	6522                	ld	a0,8(sp)
ffffffffc0202b84:	4585                	li	a1,1
ffffffffc0202b86:	739c                	ld	a5,32(a5)
ffffffffc0202b88:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b8a:	ab7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b8e:	b56d                	j	ffffffffc0202a38 <pmm_init+0x510>
        intr_disable();
ffffffffc0202b90:	ab7fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b94:	000bb783          	ld	a5,0(s7)
ffffffffc0202b98:	4585                	li	a1,1
ffffffffc0202b9a:	8556                	mv	a0,s5
ffffffffc0202b9c:	739c                	ld	a5,32(a5)
ffffffffc0202b9e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ba0:	aa1fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202ba4:	b59d                	j	ffffffffc0202a0a <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202ba6:	00005697          	auipc	a3,0x5
ffffffffc0202baa:	c8a68693          	addi	a3,a3,-886 # ffffffffc0207830 <default_pmm_manager+0x560>
ffffffffc0202bae:	00004617          	auipc	a2,0x4
ffffffffc0202bb2:	08a60613          	addi	a2,a2,138 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202bb6:	22700593          	li	a1,551
ffffffffc0202bba:	00005517          	auipc	a0,0x5
ffffffffc0202bbe:	86650513          	addi	a0,a0,-1946 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202bc2:	8b9fd0ef          	jal	ra,ffffffffc020047a <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202bc6:	00005697          	auipc	a3,0x5
ffffffffc0202bca:	c2a68693          	addi	a3,a3,-982 # ffffffffc02077f0 <default_pmm_manager+0x520>
ffffffffc0202bce:	00004617          	auipc	a2,0x4
ffffffffc0202bd2:	06a60613          	addi	a2,a2,106 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202bd6:	22600593          	li	a1,550
ffffffffc0202bda:	00005517          	auipc	a0,0x5
ffffffffc0202bde:	84650513          	addi	a0,a0,-1978 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202be2:	899fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202be6:	86a2                	mv	a3,s0
ffffffffc0202be8:	00004617          	auipc	a2,0x4
ffffffffc0202bec:	72060613          	addi	a2,a2,1824 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0202bf0:	22600593          	li	a1,550
ffffffffc0202bf4:	00005517          	auipc	a0,0x5
ffffffffc0202bf8:	82c50513          	addi	a0,a0,-2004 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202bfc:	87ffd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c00:	854ff0ef          	jal	ra,ffffffffc0201c54 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c04:	00004617          	auipc	a2,0x4
ffffffffc0202c08:	7ac60613          	addi	a2,a2,1964 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc0202c0c:	07f00593          	li	a1,127
ffffffffc0202c10:	00005517          	auipc	a0,0x5
ffffffffc0202c14:	81050513          	addi	a0,a0,-2032 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202c18:	863fd0ef          	jal	ra,ffffffffc020047a <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c1c:	00004617          	auipc	a2,0x4
ffffffffc0202c20:	79460613          	addi	a2,a2,1940 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc0202c24:	0c100593          	li	a1,193
ffffffffc0202c28:	00004517          	auipc	a0,0x4
ffffffffc0202c2c:	7f850513          	addi	a0,a0,2040 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202c30:	84bfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c34:	00005697          	auipc	a3,0x5
ffffffffc0202c38:	8f468693          	addi	a3,a3,-1804 # ffffffffc0207528 <default_pmm_manager+0x258>
ffffffffc0202c3c:	00004617          	auipc	a2,0x4
ffffffffc0202c40:	ffc60613          	addi	a2,a2,-4 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202c44:	1ea00593          	li	a1,490
ffffffffc0202c48:	00004517          	auipc	a0,0x4
ffffffffc0202c4c:	7d850513          	addi	a0,a0,2008 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202c50:	82bfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202c54:	00005697          	auipc	a3,0x5
ffffffffc0202c58:	8b468693          	addi	a3,a3,-1868 # ffffffffc0207508 <default_pmm_manager+0x238>
ffffffffc0202c5c:	00004617          	auipc	a2,0x4
ffffffffc0202c60:	fdc60613          	addi	a2,a2,-36 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202c64:	1e900593          	li	a1,489
ffffffffc0202c68:	00004517          	auipc	a0,0x4
ffffffffc0202c6c:	7b850513          	addi	a0,a0,1976 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202c70:	80bfd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c74:	ffdfe0ef          	jal	ra,ffffffffc0201c70 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202c78:	00005697          	auipc	a3,0x5
ffffffffc0202c7c:	94068693          	addi	a3,a3,-1728 # ffffffffc02075b8 <default_pmm_manager+0x2e8>
ffffffffc0202c80:	00004617          	auipc	a2,0x4
ffffffffc0202c84:	fb860613          	addi	a2,a2,-72 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202c88:	1f200593          	li	a1,498
ffffffffc0202c8c:	00004517          	auipc	a0,0x4
ffffffffc0202c90:	79450513          	addi	a0,a0,1940 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202c94:	fe6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202c98:	00005697          	auipc	a3,0x5
ffffffffc0202c9c:	8f068693          	addi	a3,a3,-1808 # ffffffffc0207588 <default_pmm_manager+0x2b8>
ffffffffc0202ca0:	00004617          	auipc	a2,0x4
ffffffffc0202ca4:	f9860613          	addi	a2,a2,-104 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202ca8:	1ef00593          	li	a1,495
ffffffffc0202cac:	00004517          	auipc	a0,0x4
ffffffffc0202cb0:	77450513          	addi	a0,a0,1908 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202cb4:	fc6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202cb8:	00005697          	auipc	a3,0x5
ffffffffc0202cbc:	8a868693          	addi	a3,a3,-1880 # ffffffffc0207560 <default_pmm_manager+0x290>
ffffffffc0202cc0:	00004617          	auipc	a2,0x4
ffffffffc0202cc4:	f7860613          	addi	a2,a2,-136 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202cc8:	1eb00593          	li	a1,491
ffffffffc0202ccc:	00004517          	auipc	a0,0x4
ffffffffc0202cd0:	75450513          	addi	a0,a0,1876 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202cd4:	fa6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202cd8:	00005697          	auipc	a3,0x5
ffffffffc0202cdc:	96868693          	addi	a3,a3,-1688 # ffffffffc0207640 <default_pmm_manager+0x370>
ffffffffc0202ce0:	00004617          	auipc	a2,0x4
ffffffffc0202ce4:	f5860613          	addi	a2,a2,-168 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202ce8:	1fb00593          	li	a1,507
ffffffffc0202cec:	00004517          	auipc	a0,0x4
ffffffffc0202cf0:	73450513          	addi	a0,a0,1844 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202cf4:	f86fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cf8:	00005697          	auipc	a3,0x5
ffffffffc0202cfc:	9e868693          	addi	a3,a3,-1560 # ffffffffc02076e0 <default_pmm_manager+0x410>
ffffffffc0202d00:	00004617          	auipc	a2,0x4
ffffffffc0202d04:	f3860613          	addi	a2,a2,-200 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202d08:	20000593          	li	a1,512
ffffffffc0202d0c:	00004517          	auipc	a0,0x4
ffffffffc0202d10:	71450513          	addi	a0,a0,1812 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202d14:	f66fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d18:	00005697          	auipc	a3,0x5
ffffffffc0202d1c:	90068693          	addi	a3,a3,-1792 # ffffffffc0207618 <default_pmm_manager+0x348>
ffffffffc0202d20:	00004617          	auipc	a2,0x4
ffffffffc0202d24:	f1860613          	addi	a2,a2,-232 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202d28:	1f800593          	li	a1,504
ffffffffc0202d2c:	00004517          	auipc	a0,0x4
ffffffffc0202d30:	6f450513          	addi	a0,a0,1780 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202d34:	f46fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d38:	86d6                	mv	a3,s5
ffffffffc0202d3a:	00004617          	auipc	a2,0x4
ffffffffc0202d3e:	5ce60613          	addi	a2,a2,1486 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0202d42:	1f700593          	li	a1,503
ffffffffc0202d46:	00004517          	auipc	a0,0x4
ffffffffc0202d4a:	6da50513          	addi	a0,a0,1754 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202d4e:	f2cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d52:	00005697          	auipc	a3,0x5
ffffffffc0202d56:	92668693          	addi	a3,a3,-1754 # ffffffffc0207678 <default_pmm_manager+0x3a8>
ffffffffc0202d5a:	00004617          	auipc	a2,0x4
ffffffffc0202d5e:	ede60613          	addi	a2,a2,-290 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202d62:	20500593          	li	a1,517
ffffffffc0202d66:	00004517          	auipc	a0,0x4
ffffffffc0202d6a:	6ba50513          	addi	a0,a0,1722 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202d6e:	f0cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202d72:	00005697          	auipc	a3,0x5
ffffffffc0202d76:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0207740 <default_pmm_manager+0x470>
ffffffffc0202d7a:	00004617          	auipc	a2,0x4
ffffffffc0202d7e:	ebe60613          	addi	a2,a2,-322 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202d82:	20400593          	li	a1,516
ffffffffc0202d86:	00004517          	auipc	a0,0x4
ffffffffc0202d8a:	69a50513          	addi	a0,a0,1690 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202d8e:	eecfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202d92:	00005697          	auipc	a3,0x5
ffffffffc0202d96:	99668693          	addi	a3,a3,-1642 # ffffffffc0207728 <default_pmm_manager+0x458>
ffffffffc0202d9a:	00004617          	auipc	a2,0x4
ffffffffc0202d9e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202da2:	20300593          	li	a1,515
ffffffffc0202da6:	00004517          	auipc	a0,0x4
ffffffffc0202daa:	67a50513          	addi	a0,a0,1658 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202dae:	eccfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202db2:	00005697          	auipc	a3,0x5
ffffffffc0202db6:	94668693          	addi	a3,a3,-1722 # ffffffffc02076f8 <default_pmm_manager+0x428>
ffffffffc0202dba:	00004617          	auipc	a2,0x4
ffffffffc0202dbe:	e7e60613          	addi	a2,a2,-386 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202dc2:	20200593          	li	a1,514
ffffffffc0202dc6:	00004517          	auipc	a0,0x4
ffffffffc0202dca:	65a50513          	addi	a0,a0,1626 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202dce:	eacfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202dd2:	00005697          	auipc	a3,0x5
ffffffffc0202dd6:	ade68693          	addi	a3,a3,-1314 # ffffffffc02078b0 <default_pmm_manager+0x5e0>
ffffffffc0202dda:	00004617          	auipc	a2,0x4
ffffffffc0202dde:	e5e60613          	addi	a2,a2,-418 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202de2:	23100593          	li	a1,561
ffffffffc0202de6:	00004517          	auipc	a0,0x4
ffffffffc0202dea:	63a50513          	addi	a0,a0,1594 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202dee:	e8cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202df2:	00005697          	auipc	a3,0x5
ffffffffc0202df6:	8d668693          	addi	a3,a3,-1834 # ffffffffc02076c8 <default_pmm_manager+0x3f8>
ffffffffc0202dfa:	00004617          	auipc	a2,0x4
ffffffffc0202dfe:	e3e60613          	addi	a2,a2,-450 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202e02:	1ff00593          	li	a1,511
ffffffffc0202e06:	00004517          	auipc	a0,0x4
ffffffffc0202e0a:	61a50513          	addi	a0,a0,1562 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202e0e:	e6cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e12:	00005697          	auipc	a3,0x5
ffffffffc0202e16:	8a668693          	addi	a3,a3,-1882 # ffffffffc02076b8 <default_pmm_manager+0x3e8>
ffffffffc0202e1a:	00004617          	auipc	a2,0x4
ffffffffc0202e1e:	e1e60613          	addi	a2,a2,-482 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202e22:	1fe00593          	li	a1,510
ffffffffc0202e26:	00004517          	auipc	a0,0x4
ffffffffc0202e2a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202e2e:	e4cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202e32:	00005697          	auipc	a3,0x5
ffffffffc0202e36:	97e68693          	addi	a3,a3,-1666 # ffffffffc02077b0 <default_pmm_manager+0x4e0>
ffffffffc0202e3a:	00004617          	auipc	a2,0x4
ffffffffc0202e3e:	dfe60613          	addi	a2,a2,-514 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202e42:	24200593          	li	a1,578
ffffffffc0202e46:	00004517          	auipc	a0,0x4
ffffffffc0202e4a:	5da50513          	addi	a0,a0,1498 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202e4e:	e2cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202e52:	00005697          	auipc	a3,0x5
ffffffffc0202e56:	85668693          	addi	a3,a3,-1962 # ffffffffc02076a8 <default_pmm_manager+0x3d8>
ffffffffc0202e5a:	00004617          	auipc	a2,0x4
ffffffffc0202e5e:	dde60613          	addi	a2,a2,-546 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202e62:	1fd00593          	li	a1,509
ffffffffc0202e66:	00004517          	auipc	a0,0x4
ffffffffc0202e6a:	5ba50513          	addi	a0,a0,1466 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202e6e:	e0cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202e72:	00004697          	auipc	a3,0x4
ffffffffc0202e76:	78e68693          	addi	a3,a3,1934 # ffffffffc0207600 <default_pmm_manager+0x330>
ffffffffc0202e7a:	00004617          	auipc	a2,0x4
ffffffffc0202e7e:	dbe60613          	addi	a2,a2,-578 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202e82:	20a00593          	li	a1,522
ffffffffc0202e86:	00004517          	auipc	a0,0x4
ffffffffc0202e8a:	59a50513          	addi	a0,a0,1434 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202e8e:	decfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202e92:	00005697          	auipc	a3,0x5
ffffffffc0202e96:	8c668693          	addi	a3,a3,-1850 # ffffffffc0207758 <default_pmm_manager+0x488>
ffffffffc0202e9a:	00004617          	auipc	a2,0x4
ffffffffc0202e9e:	d9e60613          	addi	a2,a2,-610 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202ea2:	20700593          	li	a1,519
ffffffffc0202ea6:	00004517          	auipc	a0,0x4
ffffffffc0202eaa:	57a50513          	addi	a0,a0,1402 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202eae:	dccfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202eb2:	00004697          	auipc	a3,0x4
ffffffffc0202eb6:	73668693          	addi	a3,a3,1846 # ffffffffc02075e8 <default_pmm_manager+0x318>
ffffffffc0202eba:	00004617          	auipc	a2,0x4
ffffffffc0202ebe:	d7e60613          	addi	a2,a2,-642 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202ec2:	20600593          	li	a1,518
ffffffffc0202ec6:	00004517          	auipc	a0,0x4
ffffffffc0202eca:	55a50513          	addi	a0,a0,1370 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202ece:	dacfd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0202ed2:	00004617          	auipc	a2,0x4
ffffffffc0202ed6:	43660613          	addi	a2,a2,1078 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0202eda:	06900593          	li	a1,105
ffffffffc0202ede:	00004517          	auipc	a0,0x4
ffffffffc0202ee2:	45250513          	addi	a0,a0,1106 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0202ee6:	d94fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202eea:	00005697          	auipc	a3,0x5
ffffffffc0202eee:	89e68693          	addi	a3,a3,-1890 # ffffffffc0207788 <default_pmm_manager+0x4b8>
ffffffffc0202ef2:	00004617          	auipc	a2,0x4
ffffffffc0202ef6:	d4660613          	addi	a2,a2,-698 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202efa:	21100593          	li	a1,529
ffffffffc0202efe:	00004517          	auipc	a0,0x4
ffffffffc0202f02:	52250513          	addi	a0,a0,1314 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202f06:	d74fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f0a:	00005697          	auipc	a3,0x5
ffffffffc0202f0e:	83668693          	addi	a3,a3,-1994 # ffffffffc0207740 <default_pmm_manager+0x470>
ffffffffc0202f12:	00004617          	auipc	a2,0x4
ffffffffc0202f16:	d2660613          	addi	a2,a2,-730 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202f1a:	20f00593          	li	a1,527
ffffffffc0202f1e:	00004517          	auipc	a0,0x4
ffffffffc0202f22:	50250513          	addi	a0,a0,1282 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202f26:	d54fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f2a:	00005697          	auipc	a3,0x5
ffffffffc0202f2e:	84668693          	addi	a3,a3,-1978 # ffffffffc0207770 <default_pmm_manager+0x4a0>
ffffffffc0202f32:	00004617          	auipc	a2,0x4
ffffffffc0202f36:	d0660613          	addi	a2,a2,-762 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202f3a:	20e00593          	li	a1,526
ffffffffc0202f3e:	00004517          	auipc	a0,0x4
ffffffffc0202f42:	4e250513          	addi	a0,a0,1250 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202f46:	d34fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f4a:	00004697          	auipc	a3,0x4
ffffffffc0202f4e:	7f668693          	addi	a3,a3,2038 # ffffffffc0207740 <default_pmm_manager+0x470>
ffffffffc0202f52:	00004617          	auipc	a2,0x4
ffffffffc0202f56:	ce660613          	addi	a2,a2,-794 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202f5a:	20b00593          	li	a1,523
ffffffffc0202f5e:	00004517          	auipc	a0,0x4
ffffffffc0202f62:	4c250513          	addi	a0,a0,1218 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202f66:	d14fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202f6a:	00005697          	auipc	a3,0x5
ffffffffc0202f6e:	92e68693          	addi	a3,a3,-1746 # ffffffffc0207898 <default_pmm_manager+0x5c8>
ffffffffc0202f72:	00004617          	auipc	a2,0x4
ffffffffc0202f76:	cc660613          	addi	a2,a2,-826 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202f7a:	23000593          	li	a1,560
ffffffffc0202f7e:	00004517          	auipc	a0,0x4
ffffffffc0202f82:	4a250513          	addi	a0,a0,1186 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202f86:	cf4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202f8a:	00005697          	auipc	a3,0x5
ffffffffc0202f8e:	8d668693          	addi	a3,a3,-1834 # ffffffffc0207860 <default_pmm_manager+0x590>
ffffffffc0202f92:	00004617          	auipc	a2,0x4
ffffffffc0202f96:	ca660613          	addi	a2,a2,-858 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202f9a:	22f00593          	li	a1,559
ffffffffc0202f9e:	00004517          	auipc	a0,0x4
ffffffffc0202fa2:	48250513          	addi	a0,a0,1154 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202fa6:	cd4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202faa:	00005697          	auipc	a3,0x5
ffffffffc0202fae:	89e68693          	addi	a3,a3,-1890 # ffffffffc0207848 <default_pmm_manager+0x578>
ffffffffc0202fb2:	00004617          	auipc	a2,0x4
ffffffffc0202fb6:	c8660613          	addi	a2,a2,-890 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202fba:	22b00593          	li	a1,555
ffffffffc0202fbe:	00004517          	auipc	a0,0x4
ffffffffc0202fc2:	46250513          	addi	a0,a0,1122 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202fc6:	cb4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202fca:	00004697          	auipc	a3,0x4
ffffffffc0202fce:	7e668693          	addi	a3,a3,2022 # ffffffffc02077b0 <default_pmm_manager+0x4e0>
ffffffffc0202fd2:	00004617          	auipc	a2,0x4
ffffffffc0202fd6:	c6660613          	addi	a2,a2,-922 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202fda:	21900593          	li	a1,537
ffffffffc0202fde:	00004517          	auipc	a0,0x4
ffffffffc0202fe2:	44250513          	addi	a0,a0,1090 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0202fe6:	c94fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202fea:	00004697          	auipc	a3,0x4
ffffffffc0202fee:	5fe68693          	addi	a3,a3,1534 # ffffffffc02075e8 <default_pmm_manager+0x318>
ffffffffc0202ff2:	00004617          	auipc	a2,0x4
ffffffffc0202ff6:	c4660613          	addi	a2,a2,-954 # ffffffffc0206c38 <commands+0x450>
ffffffffc0202ffa:	1f300593          	li	a1,499
ffffffffc0202ffe:	00004517          	auipc	a0,0x4
ffffffffc0203002:	42250513          	addi	a0,a0,1058 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc0203006:	c74fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020300a:	00004617          	auipc	a2,0x4
ffffffffc020300e:	2fe60613          	addi	a2,a2,766 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0203012:	1f600593          	li	a1,502
ffffffffc0203016:	00004517          	auipc	a0,0x4
ffffffffc020301a:	40a50513          	addi	a0,a0,1034 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020301e:	c5cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203022:	00004697          	auipc	a3,0x4
ffffffffc0203026:	5de68693          	addi	a3,a3,1502 # ffffffffc0207600 <default_pmm_manager+0x330>
ffffffffc020302a:	00004617          	auipc	a2,0x4
ffffffffc020302e:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203032:	1f400593          	li	a1,500
ffffffffc0203036:	00004517          	auipc	a0,0x4
ffffffffc020303a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020303e:	c3cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203042:	00004697          	auipc	a3,0x4
ffffffffc0203046:	63668693          	addi	a3,a3,1590 # ffffffffc0207678 <default_pmm_manager+0x3a8>
ffffffffc020304a:	00004617          	auipc	a2,0x4
ffffffffc020304e:	bee60613          	addi	a2,a2,-1042 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203052:	1fc00593          	li	a1,508
ffffffffc0203056:	00004517          	auipc	a0,0x4
ffffffffc020305a:	3ca50513          	addi	a0,a0,970 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020305e:	c1cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203062:	00005697          	auipc	a3,0x5
ffffffffc0203066:	8f668693          	addi	a3,a3,-1802 # ffffffffc0207958 <default_pmm_manager+0x688>
ffffffffc020306a:	00004617          	auipc	a2,0x4
ffffffffc020306e:	bce60613          	addi	a2,a2,-1074 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203072:	23900593          	li	a1,569
ffffffffc0203076:	00004517          	auipc	a0,0x4
ffffffffc020307a:	3aa50513          	addi	a0,a0,938 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020307e:	bfcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203082:	00005697          	auipc	a3,0x5
ffffffffc0203086:	89e68693          	addi	a3,a3,-1890 # ffffffffc0207920 <default_pmm_manager+0x650>
ffffffffc020308a:	00004617          	auipc	a2,0x4
ffffffffc020308e:	bae60613          	addi	a2,a2,-1106 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203092:	23600593          	li	a1,566
ffffffffc0203096:	00004517          	auipc	a0,0x4
ffffffffc020309a:	38a50513          	addi	a0,a0,906 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020309e:	bdcfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 2);
ffffffffc02030a2:	00005697          	auipc	a3,0x5
ffffffffc02030a6:	84e68693          	addi	a3,a3,-1970 # ffffffffc02078f0 <default_pmm_manager+0x620>
ffffffffc02030aa:	00004617          	auipc	a2,0x4
ffffffffc02030ae:	b8e60613          	addi	a2,a2,-1138 # ffffffffc0206c38 <commands+0x450>
ffffffffc02030b2:	23200593          	li	a1,562
ffffffffc02030b6:	00004517          	auipc	a0,0x4
ffffffffc02030ba:	36a50513          	addi	a0,a0,874 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc02030be:	bbcfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02030c2 <copy_range>:
               bool share) {
ffffffffc02030c2:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030c4:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02030c8:	f486                	sd	ra,104(sp)
ffffffffc02030ca:	f0a2                	sd	s0,96(sp)
ffffffffc02030cc:	eca6                	sd	s1,88(sp)
ffffffffc02030ce:	e8ca                	sd	s2,80(sp)
ffffffffc02030d0:	e4ce                	sd	s3,72(sp)
ffffffffc02030d2:	e0d2                	sd	s4,64(sp)
ffffffffc02030d4:	fc56                	sd	s5,56(sp)
ffffffffc02030d6:	f85a                	sd	s6,48(sp)
ffffffffc02030d8:	f45e                	sd	s7,40(sp)
ffffffffc02030da:	f062                	sd	s8,32(sp)
ffffffffc02030dc:	ec66                	sd	s9,24(sp)
ffffffffc02030de:	e86a                	sd	s10,16(sp)
ffffffffc02030e0:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030e2:	17d2                	slli	a5,a5,0x34
ffffffffc02030e4:	1e079763          	bnez	a5,ffffffffc02032d2 <copy_range+0x210>
    assert(USER_ACCESS(start, end));
ffffffffc02030e8:	002007b7          	lui	a5,0x200
ffffffffc02030ec:	8432                	mv	s0,a2
ffffffffc02030ee:	16f66a63          	bltu	a2,a5,ffffffffc0203262 <copy_range+0x1a0>
ffffffffc02030f2:	8936                	mv	s2,a3
ffffffffc02030f4:	16d67763          	bgeu	a2,a3,ffffffffc0203262 <copy_range+0x1a0>
ffffffffc02030f8:	4785                	li	a5,1
ffffffffc02030fa:	07fe                	slli	a5,a5,0x1f
ffffffffc02030fc:	16d7e363          	bltu	a5,a3,ffffffffc0203262 <copy_range+0x1a0>
ffffffffc0203100:	5b7d                	li	s6,-1
ffffffffc0203102:	8aaa                	mv	s5,a0
ffffffffc0203104:	89ae                	mv	s3,a1
        start += PGSIZE;
ffffffffc0203106:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203108:	000b0c97          	auipc	s9,0xb0
ffffffffc020310c:	940c8c93          	addi	s9,s9,-1728 # ffffffffc02b2a48 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203110:	000b0c17          	auipc	s8,0xb0
ffffffffc0203114:	940c0c13          	addi	s8,s8,-1728 # ffffffffc02b2a50 <pages>
    return page - pages + nbase;
ffffffffc0203118:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc020311c:	00cb5b13          	srli	s6,s6,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203120:	4601                	li	a2,0
ffffffffc0203122:	85a2                	mv	a1,s0
ffffffffc0203124:	854e                	mv	a0,s3
ffffffffc0203126:	c73fe0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc020312a:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020312c:	c175                	beqz	a0,ffffffffc0203210 <copy_range+0x14e>
        if (*ptep & PTE_V) {
ffffffffc020312e:	611c                	ld	a5,0(a0)
ffffffffc0203130:	8b85                	andi	a5,a5,1
ffffffffc0203132:	e785                	bnez	a5,ffffffffc020315a <copy_range+0x98>
        start += PGSIZE;
ffffffffc0203134:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0203136:	ff2465e3          	bltu	s0,s2,ffffffffc0203120 <copy_range+0x5e>
    return 0;
ffffffffc020313a:	4501                	li	a0,0
}
ffffffffc020313c:	70a6                	ld	ra,104(sp)
ffffffffc020313e:	7406                	ld	s0,96(sp)
ffffffffc0203140:	64e6                	ld	s1,88(sp)
ffffffffc0203142:	6946                	ld	s2,80(sp)
ffffffffc0203144:	69a6                	ld	s3,72(sp)
ffffffffc0203146:	6a06                	ld	s4,64(sp)
ffffffffc0203148:	7ae2                	ld	s5,56(sp)
ffffffffc020314a:	7b42                	ld	s6,48(sp)
ffffffffc020314c:	7ba2                	ld	s7,40(sp)
ffffffffc020314e:	7c02                	ld	s8,32(sp)
ffffffffc0203150:	6ce2                	ld	s9,24(sp)
ffffffffc0203152:	6d42                	ld	s10,16(sp)
ffffffffc0203154:	6da2                	ld	s11,8(sp)
ffffffffc0203156:	6165                	addi	sp,sp,112
ffffffffc0203158:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020315a:	4605                	li	a2,1
ffffffffc020315c:	85a2                	mv	a1,s0
ffffffffc020315e:	8556                	mv	a0,s5
ffffffffc0203160:	c39fe0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc0203164:	c161                	beqz	a0,ffffffffc0203224 <copy_range+0x162>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203166:	609c                	ld	a5,0(s1)
    if (!(pte & PTE_V)) {
ffffffffc0203168:	0017f713          	andi	a4,a5,1
ffffffffc020316c:	01f7f493          	andi	s1,a5,31
ffffffffc0203170:	14070563          	beqz	a4,ffffffffc02032ba <copy_range+0x1f8>
    if (PPN(pa) >= npage) {
ffffffffc0203174:	000cb683          	ld	a3,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203178:	078a                	slli	a5,a5,0x2
ffffffffc020317a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020317e:	12d77263          	bgeu	a4,a3,ffffffffc02032a2 <copy_range+0x1e0>
    return &pages[PPN(pa) - nbase];
ffffffffc0203182:	000c3783          	ld	a5,0(s8)
ffffffffc0203186:	fff806b7          	lui	a3,0xfff80
ffffffffc020318a:	9736                	add	a4,a4,a3
ffffffffc020318c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020318e:	4505                	li	a0,1
ffffffffc0203190:	00e78db3          	add	s11,a5,a4
ffffffffc0203194:	af9fe0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0203198:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020319a:	0a0d8463          	beqz	s11,ffffffffc0203242 <copy_range+0x180>
            assert(npage != NULL);
ffffffffc020319e:	c175                	beqz	a0,ffffffffc0203282 <copy_range+0x1c0>
    return page - pages + nbase;
ffffffffc02031a0:	000c3703          	ld	a4,0(s8)
    return KADDR(page2pa(page));
ffffffffc02031a4:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02031a8:	40ed86b3          	sub	a3,s11,a4
ffffffffc02031ac:	8699                	srai	a3,a3,0x6
ffffffffc02031ae:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02031b0:	0166f7b3          	and	a5,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031b6:	06c7fa63          	bgeu	a5,a2,ffffffffc020322a <copy_range+0x168>
    return page - pages + nbase;
ffffffffc02031ba:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031be:	000b0717          	auipc	a4,0xb0
ffffffffc02031c2:	8a270713          	addi	a4,a4,-1886 # ffffffffc02b2a60 <va_pa_offset>
ffffffffc02031c6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031c8:	8799                	srai	a5,a5,0x6
ffffffffc02031ca:	97de                	add	a5,a5,s7
    return KADDR(page2pa(page));
ffffffffc02031cc:	0167f733          	and	a4,a5,s6
ffffffffc02031d0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031d4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031d6:	04c77963          	bgeu	a4,a2,ffffffffc0203228 <copy_range+0x166>
            memcpy((void *)dst_kvaddr, (void *)src_kvaddr, PGSIZE);
ffffffffc02031da:	6605                	lui	a2,0x1
ffffffffc02031dc:	953e                	add	a0,a0,a5
ffffffffc02031de:	386030ef          	jal	ra,ffffffffc0206564 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031e2:	86a6                	mv	a3,s1
ffffffffc02031e4:	8622                	mv	a2,s0
ffffffffc02031e6:	85ea                	mv	a1,s10
ffffffffc02031e8:	8556                	mv	a0,s5
ffffffffc02031ea:	a48ff0ef          	jal	ra,ffffffffc0202432 <page_insert>
            assert(ret == 0);
ffffffffc02031ee:	d139                	beqz	a0,ffffffffc0203134 <copy_range+0x72>
ffffffffc02031f0:	00004697          	auipc	a3,0x4
ffffffffc02031f4:	7d068693          	addi	a3,a3,2000 # ffffffffc02079c0 <default_pmm_manager+0x6f0>
ffffffffc02031f8:	00004617          	auipc	a2,0x4
ffffffffc02031fc:	a4060613          	addi	a2,a2,-1472 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203200:	18b00593          	li	a1,395
ffffffffc0203204:	00004517          	auipc	a0,0x4
ffffffffc0203208:	21c50513          	addi	a0,a0,540 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020320c:	a6efd0ef          	jal	ra,ffffffffc020047a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203210:	00200637          	lui	a2,0x200
ffffffffc0203214:	9432                	add	s0,s0,a2
ffffffffc0203216:	ffe00637          	lui	a2,0xffe00
ffffffffc020321a:	8c71                	and	s0,s0,a2
    } while (start != 0 && start < end);
ffffffffc020321c:	dc19                	beqz	s0,ffffffffc020313a <copy_range+0x78>
ffffffffc020321e:	f12461e3          	bltu	s0,s2,ffffffffc0203120 <copy_range+0x5e>
ffffffffc0203222:	bf21                	j	ffffffffc020313a <copy_range+0x78>
                return -E_NO_MEM;
ffffffffc0203224:	5571                	li	a0,-4
ffffffffc0203226:	bf19                	j	ffffffffc020313c <copy_range+0x7a>
ffffffffc0203228:	86be                	mv	a3,a5
ffffffffc020322a:	00004617          	auipc	a2,0x4
ffffffffc020322e:	0de60613          	addi	a2,a2,222 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0203232:	06900593          	li	a1,105
ffffffffc0203236:	00004517          	auipc	a0,0x4
ffffffffc020323a:	0fa50513          	addi	a0,a0,250 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc020323e:	a3cfd0ef          	jal	ra,ffffffffc020047a <__panic>
            assert(page != NULL);
ffffffffc0203242:	00004697          	auipc	a3,0x4
ffffffffc0203246:	75e68693          	addi	a3,a3,1886 # ffffffffc02079a0 <default_pmm_manager+0x6d0>
ffffffffc020324a:	00004617          	auipc	a2,0x4
ffffffffc020324e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203252:	17200593          	li	a1,370
ffffffffc0203256:	00004517          	auipc	a0,0x4
ffffffffc020325a:	1ca50513          	addi	a0,a0,458 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020325e:	a1cfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203262:	00004697          	auipc	a3,0x4
ffffffffc0203266:	1fe68693          	addi	a3,a3,510 # ffffffffc0207460 <default_pmm_manager+0x190>
ffffffffc020326a:	00004617          	auipc	a2,0x4
ffffffffc020326e:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203272:	15e00593          	li	a1,350
ffffffffc0203276:	00004517          	auipc	a0,0x4
ffffffffc020327a:	1aa50513          	addi	a0,a0,426 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020327e:	9fcfd0ef          	jal	ra,ffffffffc020047a <__panic>
            assert(npage != NULL);
ffffffffc0203282:	00004697          	auipc	a3,0x4
ffffffffc0203286:	72e68693          	addi	a3,a3,1838 # ffffffffc02079b0 <default_pmm_manager+0x6e0>
ffffffffc020328a:	00004617          	auipc	a2,0x4
ffffffffc020328e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203292:	17300593          	li	a1,371
ffffffffc0203296:	00004517          	auipc	a0,0x4
ffffffffc020329a:	18a50513          	addi	a0,a0,394 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc020329e:	9dcfd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02032a2:	00004617          	auipc	a2,0x4
ffffffffc02032a6:	13660613          	addi	a2,a2,310 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc02032aa:	06200593          	li	a1,98
ffffffffc02032ae:	00004517          	auipc	a0,0x4
ffffffffc02032b2:	08250513          	addi	a0,a0,130 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc02032b6:	9c4fd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032ba:	00004617          	auipc	a2,0x4
ffffffffc02032be:	13e60613          	addi	a2,a2,318 # ffffffffc02073f8 <default_pmm_manager+0x128>
ffffffffc02032c2:	07400593          	li	a1,116
ffffffffc02032c6:	00004517          	auipc	a0,0x4
ffffffffc02032ca:	06a50513          	addi	a0,a0,106 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc02032ce:	9acfd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032d2:	00004697          	auipc	a3,0x4
ffffffffc02032d6:	15e68693          	addi	a3,a3,350 # ffffffffc0207430 <default_pmm_manager+0x160>
ffffffffc02032da:	00004617          	auipc	a2,0x4
ffffffffc02032de:	95e60613          	addi	a2,a2,-1698 # ffffffffc0206c38 <commands+0x450>
ffffffffc02032e2:	15d00593          	li	a1,349
ffffffffc02032e6:	00004517          	auipc	a0,0x4
ffffffffc02032ea:	13a50513          	addi	a0,a0,314 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc02032ee:	98cfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02032f2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032f2:	12058073          	sfence.vma	a1
}
ffffffffc02032f6:	8082                	ret

ffffffffc02032f8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032f8:	7179                	addi	sp,sp,-48
ffffffffc02032fa:	e84a                	sd	s2,16(sp)
ffffffffc02032fc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032fe:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203300:	f022                	sd	s0,32(sp)
ffffffffc0203302:	ec26                	sd	s1,24(sp)
ffffffffc0203304:	e44e                	sd	s3,8(sp)
ffffffffc0203306:	f406                	sd	ra,40(sp)
ffffffffc0203308:	84ae                	mv	s1,a1
ffffffffc020330a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020330c:	981fe0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0203310:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203312:	cd05                	beqz	a0,ffffffffc020334a <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203314:	85aa                	mv	a1,a0
ffffffffc0203316:	86ce                	mv	a3,s3
ffffffffc0203318:	8626                	mv	a2,s1
ffffffffc020331a:	854a                	mv	a0,s2
ffffffffc020331c:	916ff0ef          	jal	ra,ffffffffc0202432 <page_insert>
ffffffffc0203320:	ed0d                	bnez	a0,ffffffffc020335a <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc0203322:	000af797          	auipc	a5,0xaf
ffffffffc0203326:	7567a783          	lw	a5,1878(a5) # ffffffffc02b2a78 <swap_init_ok>
ffffffffc020332a:	c385                	beqz	a5,ffffffffc020334a <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc020332c:	000af517          	auipc	a0,0xaf
ffffffffc0203330:	75453503          	ld	a0,1876(a0) # ffffffffc02b2a80 <check_mm_struct>
ffffffffc0203334:	c919                	beqz	a0,ffffffffc020334a <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203336:	4681                	li	a3,0
ffffffffc0203338:	8622                	mv	a2,s0
ffffffffc020333a:	85a6                	mv	a1,s1
ffffffffc020333c:	7e4000ef          	jal	ra,ffffffffc0203b20 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203340:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203342:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203344:	4785                	li	a5,1
ffffffffc0203346:	04f71663          	bne	a4,a5,ffffffffc0203392 <pgdir_alloc_page+0x9a>
}
ffffffffc020334a:	70a2                	ld	ra,40(sp)
ffffffffc020334c:	8522                	mv	a0,s0
ffffffffc020334e:	7402                	ld	s0,32(sp)
ffffffffc0203350:	64e2                	ld	s1,24(sp)
ffffffffc0203352:	6942                	ld	s2,16(sp)
ffffffffc0203354:	69a2                	ld	s3,8(sp)
ffffffffc0203356:	6145                	addi	sp,sp,48
ffffffffc0203358:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020335a:	100027f3          	csrr	a5,sstatus
ffffffffc020335e:	8b89                	andi	a5,a5,2
ffffffffc0203360:	eb99                	bnez	a5,ffffffffc0203376 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc0203362:	000af797          	auipc	a5,0xaf
ffffffffc0203366:	6f67b783          	ld	a5,1782(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc020336a:	739c                	ld	a5,32(a5)
ffffffffc020336c:	8522                	mv	a0,s0
ffffffffc020336e:	4585                	li	a1,1
ffffffffc0203370:	9782                	jalr	a5
            return NULL;
ffffffffc0203372:	4401                	li	s0,0
ffffffffc0203374:	bfd9                	j	ffffffffc020334a <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0203376:	ad0fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020337a:	000af797          	auipc	a5,0xaf
ffffffffc020337e:	6de7b783          	ld	a5,1758(a5) # ffffffffc02b2a58 <pmm_manager>
ffffffffc0203382:	739c                	ld	a5,32(a5)
ffffffffc0203384:	8522                	mv	a0,s0
ffffffffc0203386:	4585                	li	a1,1
ffffffffc0203388:	9782                	jalr	a5
            return NULL;
ffffffffc020338a:	4401                	li	s0,0
        intr_enable();
ffffffffc020338c:	ab4fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0203390:	bf6d                	j	ffffffffc020334a <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc0203392:	00004697          	auipc	a3,0x4
ffffffffc0203396:	63e68693          	addi	a3,a3,1598 # ffffffffc02079d0 <default_pmm_manager+0x700>
ffffffffc020339a:	00004617          	auipc	a2,0x4
ffffffffc020339e:	89e60613          	addi	a2,a2,-1890 # ffffffffc0206c38 <commands+0x450>
ffffffffc02033a2:	1ca00593          	li	a1,458
ffffffffc02033a6:	00004517          	auipc	a0,0x4
ffffffffc02033aa:	07a50513          	addi	a0,a0,122 # ffffffffc0207420 <default_pmm_manager+0x150>
ffffffffc02033ae:	8ccfd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02033b2 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02033b2:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02033b4:	00004617          	auipc	a2,0x4
ffffffffc02033b8:	02460613          	addi	a2,a2,36 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc02033bc:	06200593          	li	a1,98
ffffffffc02033c0:	00004517          	auipc	a0,0x4
ffffffffc02033c4:	f7050513          	addi	a0,a0,-144 # ffffffffc0207330 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc02033c8:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02033ca:	8b0fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02033ce <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02033ce:	7135                	addi	sp,sp,-160
ffffffffc02033d0:	ed06                	sd	ra,152(sp)
ffffffffc02033d2:	e922                	sd	s0,144(sp)
ffffffffc02033d4:	e526                	sd	s1,136(sp)
ffffffffc02033d6:	e14a                	sd	s2,128(sp)
ffffffffc02033d8:	fcce                	sd	s3,120(sp)
ffffffffc02033da:	f8d2                	sd	s4,112(sp)
ffffffffc02033dc:	f4d6                	sd	s5,104(sp)
ffffffffc02033de:	f0da                	sd	s6,96(sp)
ffffffffc02033e0:	ecde                	sd	s7,88(sp)
ffffffffc02033e2:	e8e2                	sd	s8,80(sp)
ffffffffc02033e4:	e4e6                	sd	s9,72(sp)
ffffffffc02033e6:	e0ea                	sd	s10,64(sp)
ffffffffc02033e8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02033ea:	72c010ef          	jal	ra,ffffffffc0204b16 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02033ee:	000af697          	auipc	a3,0xaf
ffffffffc02033f2:	67a6b683          	ld	a3,1658(a3) # ffffffffc02b2a68 <max_swap_offset>
ffffffffc02033f6:	010007b7          	lui	a5,0x1000
ffffffffc02033fa:	ff968713          	addi	a4,a3,-7
ffffffffc02033fe:	17e1                	addi	a5,a5,-8
ffffffffc0203400:	42e7e663          	bltu	a5,a4,ffffffffc020382c <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203404:	000a4797          	auipc	a5,0xa4
ffffffffc0203408:	0fc78793          	addi	a5,a5,252 # ffffffffc02a7500 <swap_manager_fifo>
     int r = sm->init();
ffffffffc020340c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020340e:	000afb97          	auipc	s7,0xaf
ffffffffc0203412:	662b8b93          	addi	s7,s7,1634 # ffffffffc02b2a70 <sm>
ffffffffc0203416:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc020341a:	9702                	jalr	a4
ffffffffc020341c:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc020341e:	c10d                	beqz	a0,ffffffffc0203440 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0203420:	60ea                	ld	ra,152(sp)
ffffffffc0203422:	644a                	ld	s0,144(sp)
ffffffffc0203424:	64aa                	ld	s1,136(sp)
ffffffffc0203426:	79e6                	ld	s3,120(sp)
ffffffffc0203428:	7a46                	ld	s4,112(sp)
ffffffffc020342a:	7aa6                	ld	s5,104(sp)
ffffffffc020342c:	7b06                	ld	s6,96(sp)
ffffffffc020342e:	6be6                	ld	s7,88(sp)
ffffffffc0203430:	6c46                	ld	s8,80(sp)
ffffffffc0203432:	6ca6                	ld	s9,72(sp)
ffffffffc0203434:	6d06                	ld	s10,64(sp)
ffffffffc0203436:	7de2                	ld	s11,56(sp)
ffffffffc0203438:	854a                	mv	a0,s2
ffffffffc020343a:	690a                	ld	s2,128(sp)
ffffffffc020343c:	610d                	addi	sp,sp,160
ffffffffc020343e:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203440:	000bb783          	ld	a5,0(s7)
ffffffffc0203444:	00004517          	auipc	a0,0x4
ffffffffc0203448:	5d450513          	addi	a0,a0,1492 # ffffffffc0207a18 <default_pmm_manager+0x748>
    return listelm->next;
ffffffffc020344c:	000ab417          	auipc	s0,0xab
ffffffffc0203450:	50440413          	addi	s0,s0,1284 # ffffffffc02ae950 <free_area>
ffffffffc0203454:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203456:	4785                	li	a5,1
ffffffffc0203458:	000af717          	auipc	a4,0xaf
ffffffffc020345c:	62f72023          	sw	a5,1568(a4) # ffffffffc02b2a78 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203460:	d21fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203464:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0203466:	4d01                	li	s10,0
ffffffffc0203468:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020346a:	34878163          	beq	a5,s0,ffffffffc02037ac <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020346e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203472:	8b09                	andi	a4,a4,2
ffffffffc0203474:	32070e63          	beqz	a4,ffffffffc02037b0 <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203478:	ff87a703          	lw	a4,-8(a5)
ffffffffc020347c:	679c                	ld	a5,8(a5)
ffffffffc020347e:	2d85                	addiw	s11,s11,1
ffffffffc0203480:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203484:	fe8795e3          	bne	a5,s0,ffffffffc020346e <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0203488:	84ea                	mv	s1,s10
ffffffffc020348a:	8d5fe0ef          	jal	ra,ffffffffc0201d5e <nr_free_pages>
ffffffffc020348e:	42951763          	bne	a0,s1,ffffffffc02038bc <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203492:	866a                	mv	a2,s10
ffffffffc0203494:	85ee                	mv	a1,s11
ffffffffc0203496:	00004517          	auipc	a0,0x4
ffffffffc020349a:	59a50513          	addi	a0,a0,1434 # ffffffffc0207a30 <default_pmm_manager+0x760>
ffffffffc020349e:	ce3fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02034a2:	43b000ef          	jal	ra,ffffffffc02040dc <mm_create>
ffffffffc02034a6:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02034a8:	46050a63          	beqz	a0,ffffffffc020391c <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02034ac:	000af797          	auipc	a5,0xaf
ffffffffc02034b0:	5d478793          	addi	a5,a5,1492 # ffffffffc02b2a80 <check_mm_struct>
ffffffffc02034b4:	6398                	ld	a4,0(a5)
ffffffffc02034b6:	3e071363          	bnez	a4,ffffffffc020389c <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034ba:	000af717          	auipc	a4,0xaf
ffffffffc02034be:	58670713          	addi	a4,a4,1414 # ffffffffc02b2a40 <boot_pgdir>
ffffffffc02034c2:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02034c6:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02034c8:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02034cc:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02034d0:	42079663          	bnez	a5,ffffffffc02038fc <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02034d4:	6599                	lui	a1,0x6
ffffffffc02034d6:	460d                	li	a2,3
ffffffffc02034d8:	6505                	lui	a0,0x1
ffffffffc02034da:	44b000ef          	jal	ra,ffffffffc0204124 <vma_create>
ffffffffc02034de:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034e0:	52050a63          	beqz	a0,ffffffffc0203a14 <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc02034e4:	8556                	mv	a0,s5
ffffffffc02034e6:	4ad000ef          	jal	ra,ffffffffc0204192 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034ea:	00004517          	auipc	a0,0x4
ffffffffc02034ee:	5b650513          	addi	a0,a0,1462 # ffffffffc0207aa0 <default_pmm_manager+0x7d0>
ffffffffc02034f2:	c8ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034f6:	018ab503          	ld	a0,24(s5)
ffffffffc02034fa:	4605                	li	a2,1
ffffffffc02034fc:	6585                	lui	a1,0x1
ffffffffc02034fe:	89bfe0ef          	jal	ra,ffffffffc0201d98 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0203502:	4c050963          	beqz	a0,ffffffffc02039d4 <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203506:	00004517          	auipc	a0,0x4
ffffffffc020350a:	5ea50513          	addi	a0,a0,1514 # ffffffffc0207af0 <default_pmm_manager+0x820>
ffffffffc020350e:	000ab497          	auipc	s1,0xab
ffffffffc0203512:	47a48493          	addi	s1,s1,1146 # ffffffffc02ae988 <check_rp>
ffffffffc0203516:	c6bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020351a:	000ab997          	auipc	s3,0xab
ffffffffc020351e:	48e98993          	addi	s3,s3,1166 # ffffffffc02ae9a8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203522:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0203524:	4505                	li	a0,1
ffffffffc0203526:	f66fe0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc020352a:	00aa3023          	sd	a0,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
          assert(check_rp[i] != NULL );
ffffffffc020352e:	2c050f63          	beqz	a0,ffffffffc020380c <swap_init+0x43e>
ffffffffc0203532:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203534:	8b89                	andi	a5,a5,2
ffffffffc0203536:	34079363          	bnez	a5,ffffffffc020387c <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020353a:	0a21                	addi	s4,s4,8
ffffffffc020353c:	ff3a14e3          	bne	s4,s3,ffffffffc0203524 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203540:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203542:	000aba17          	auipc	s4,0xab
ffffffffc0203546:	446a0a13          	addi	s4,s4,1094 # ffffffffc02ae988 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020354a:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc020354c:	ec3e                	sd	a5,24(sp)
ffffffffc020354e:	641c                	ld	a5,8(s0)
ffffffffc0203550:	e400                	sd	s0,8(s0)
ffffffffc0203552:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203554:	481c                	lw	a5,16(s0)
ffffffffc0203556:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0203558:	000ab797          	auipc	a5,0xab
ffffffffc020355c:	4007a423          	sw	zero,1032(a5) # ffffffffc02ae960 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203560:	000a3503          	ld	a0,0(s4)
ffffffffc0203564:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203566:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc0203568:	fb6fe0ef          	jal	ra,ffffffffc0201d1e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020356c:	ff3a1ae3          	bne	s4,s3,ffffffffc0203560 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203570:	01042a03          	lw	s4,16(s0)
ffffffffc0203574:	4791                	li	a5,4
ffffffffc0203576:	42fa1f63          	bne	s4,a5,ffffffffc02039b4 <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020357a:	00004517          	auipc	a0,0x4
ffffffffc020357e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0207b78 <default_pmm_manager+0x8a8>
ffffffffc0203582:	bfffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203586:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203588:	000af797          	auipc	a5,0xaf
ffffffffc020358c:	5007a023          	sw	zero,1280(a5) # ffffffffc02b2a88 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203590:	4629                	li	a2,10
ffffffffc0203592:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
     assert(pgfault_num==1);
ffffffffc0203596:	000af697          	auipc	a3,0xaf
ffffffffc020359a:	4f26a683          	lw	a3,1266(a3) # ffffffffc02b2a88 <pgfault_num>
ffffffffc020359e:	4585                	li	a1,1
ffffffffc02035a0:	000af797          	auipc	a5,0xaf
ffffffffc02035a4:	4e878793          	addi	a5,a5,1256 # ffffffffc02b2a88 <pgfault_num>
ffffffffc02035a8:	54b69663          	bne	a3,a1,ffffffffc0203af4 <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02035ac:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc02035b0:	4398                	lw	a4,0(a5)
ffffffffc02035b2:	2701                	sext.w	a4,a4
ffffffffc02035b4:	3ed71063          	bne	a4,a3,ffffffffc0203994 <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02035b8:	6689                	lui	a3,0x2
ffffffffc02035ba:	462d                	li	a2,11
ffffffffc02035bc:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7bd8>
     assert(pgfault_num==2);
ffffffffc02035c0:	4398                	lw	a4,0(a5)
ffffffffc02035c2:	4589                	li	a1,2
ffffffffc02035c4:	2701                	sext.w	a4,a4
ffffffffc02035c6:	4ab71763          	bne	a4,a1,ffffffffc0203a74 <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02035ca:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02035ce:	4394                	lw	a3,0(a5)
ffffffffc02035d0:	2681                	sext.w	a3,a3
ffffffffc02035d2:	4ce69163          	bne	a3,a4,ffffffffc0203a94 <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035d6:	668d                	lui	a3,0x3
ffffffffc02035d8:	4631                	li	a2,12
ffffffffc02035da:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6bd8>
     assert(pgfault_num==3);
ffffffffc02035de:	4398                	lw	a4,0(a5)
ffffffffc02035e0:	458d                	li	a1,3
ffffffffc02035e2:	2701                	sext.w	a4,a4
ffffffffc02035e4:	4cb71863          	bne	a4,a1,ffffffffc0203ab4 <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035e8:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035ec:	4394                	lw	a3,0(a5)
ffffffffc02035ee:	2681                	sext.w	a3,a3
ffffffffc02035f0:	4ee69263          	bne	a3,a4,ffffffffc0203ad4 <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035f4:	6691                	lui	a3,0x4
ffffffffc02035f6:	4635                	li	a2,13
ffffffffc02035f8:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5bd8>
     assert(pgfault_num==4);
ffffffffc02035fc:	4398                	lw	a4,0(a5)
ffffffffc02035fe:	2701                	sext.w	a4,a4
ffffffffc0203600:	43471a63          	bne	a4,s4,ffffffffc0203a34 <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0203604:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203608:	439c                	lw	a5,0(a5)
ffffffffc020360a:	2781                	sext.w	a5,a5
ffffffffc020360c:	44e79463          	bne	a5,a4,ffffffffc0203a54 <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0203610:	481c                	lw	a5,16(s0)
ffffffffc0203612:	2c079563          	bnez	a5,ffffffffc02038dc <swap_init+0x50e>
ffffffffc0203616:	000ab797          	auipc	a5,0xab
ffffffffc020361a:	39278793          	addi	a5,a5,914 # ffffffffc02ae9a8 <swap_in_seq_no>
ffffffffc020361e:	000ab717          	auipc	a4,0xab
ffffffffc0203622:	3b270713          	addi	a4,a4,946 # ffffffffc02ae9d0 <swap_out_seq_no>
ffffffffc0203626:	000ab617          	auipc	a2,0xab
ffffffffc020362a:	3aa60613          	addi	a2,a2,938 # ffffffffc02ae9d0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc020362e:	56fd                	li	a3,-1
ffffffffc0203630:	c394                	sw	a3,0(a5)
ffffffffc0203632:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203634:	0791                	addi	a5,a5,4
ffffffffc0203636:	0711                	addi	a4,a4,4
ffffffffc0203638:	fec79ce3          	bne	a5,a2,ffffffffc0203630 <swap_init+0x262>
ffffffffc020363c:	000ab717          	auipc	a4,0xab
ffffffffc0203640:	32c70713          	addi	a4,a4,812 # ffffffffc02ae968 <check_ptep>
ffffffffc0203644:	000ab697          	auipc	a3,0xab
ffffffffc0203648:	34468693          	addi	a3,a3,836 # ffffffffc02ae988 <check_rp>
ffffffffc020364c:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc020364e:	000afc17          	auipc	s8,0xaf
ffffffffc0203652:	3fac0c13          	addi	s8,s8,1018 # ffffffffc02b2a48 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203656:	000afc97          	auipc	s9,0xaf
ffffffffc020365a:	3fac8c93          	addi	s9,s9,1018 # ffffffffc02b2a50 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020365e:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203662:	4601                	li	a2,0
ffffffffc0203664:	855a                	mv	a0,s6
ffffffffc0203666:	e836                	sd	a3,16(sp)
ffffffffc0203668:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc020366a:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020366c:	f2cfe0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc0203670:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203672:	65a2                	ld	a1,8(sp)
ffffffffc0203674:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203676:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203678:	1c050663          	beqz	a0,ffffffffc0203844 <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020367c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020367e:	0017f613          	andi	a2,a5,1
ffffffffc0203682:	1e060163          	beqz	a2,ffffffffc0203864 <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203686:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020368a:	078a                	slli	a5,a5,0x2
ffffffffc020368c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020368e:	14c7f363          	bgeu	a5,a2,ffffffffc02037d4 <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc0203692:	00005617          	auipc	a2,0x5
ffffffffc0203696:	5a660613          	addi	a2,a2,1446 # ffffffffc0208c38 <nbase>
ffffffffc020369a:	00063a03          	ld	s4,0(a2)
ffffffffc020369e:	000cb603          	ld	a2,0(s9)
ffffffffc02036a2:	6288                	ld	a0,0(a3)
ffffffffc02036a4:	414787b3          	sub	a5,a5,s4
ffffffffc02036a8:	079a                	slli	a5,a5,0x6
ffffffffc02036aa:	97b2                	add	a5,a5,a2
ffffffffc02036ac:	14f51063          	bne	a0,a5,ffffffffc02037ec <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036b0:	6785                	lui	a5,0x1
ffffffffc02036b2:	95be                	add	a1,a1,a5
ffffffffc02036b4:	6795                	lui	a5,0x5
ffffffffc02036b6:	0721                	addi	a4,a4,8
ffffffffc02036b8:	06a1                	addi	a3,a3,8
ffffffffc02036ba:	faf592e3          	bne	a1,a5,ffffffffc020365e <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02036be:	00004517          	auipc	a0,0x4
ffffffffc02036c2:	56250513          	addi	a0,a0,1378 # ffffffffc0207c20 <default_pmm_manager+0x950>
ffffffffc02036c6:	abbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc02036ca:	000bb783          	ld	a5,0(s7)
ffffffffc02036ce:	7f9c                	ld	a5,56(a5)
ffffffffc02036d0:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036d2:	32051163          	bnez	a0,ffffffffc02039f4 <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc02036d6:	77a2                	ld	a5,40(sp)
ffffffffc02036d8:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc02036da:	67e2                	ld	a5,24(sp)
ffffffffc02036dc:	e01c                	sd	a5,0(s0)
ffffffffc02036de:	7782                	ld	a5,32(sp)
ffffffffc02036e0:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036e2:	6088                	ld	a0,0(s1)
ffffffffc02036e4:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036e6:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc02036e8:	e36fe0ef          	jal	ra,ffffffffc0201d1e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036ec:	ff349be3          	bne	s1,s3,ffffffffc02036e2 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036f0:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc02036f4:	8556                	mv	a0,s5
ffffffffc02036f6:	36d000ef          	jal	ra,ffffffffc0204262 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036fa:	000af797          	auipc	a5,0xaf
ffffffffc02036fe:	34678793          	addi	a5,a5,838 # ffffffffc02b2a40 <boot_pgdir>
ffffffffc0203702:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0203704:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203708:	000af697          	auipc	a3,0xaf
ffffffffc020370c:	3606bc23          	sd	zero,888(a3) # ffffffffc02b2a80 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203710:	639c                	ld	a5,0(a5)
ffffffffc0203712:	078a                	slli	a5,a5,0x2
ffffffffc0203714:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203716:	0ae7fd63          	bgeu	a5,a4,ffffffffc02037d0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc020371a:	414786b3          	sub	a3,a5,s4
ffffffffc020371e:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203720:	8699                	srai	a3,a3,0x6
ffffffffc0203722:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203724:	00c69793          	slli	a5,a3,0xc
ffffffffc0203728:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc020372a:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc020372e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203730:	22e7f663          	bgeu	a5,a4,ffffffffc020395c <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc0203734:	000af797          	auipc	a5,0xaf
ffffffffc0203738:	32c7b783          	ld	a5,812(a5) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc020373c:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020373e:	629c                	ld	a5,0(a3)
ffffffffc0203740:	078a                	slli	a5,a5,0x2
ffffffffc0203742:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203744:	08e7f663          	bgeu	a5,a4,ffffffffc02037d0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203748:	414787b3          	sub	a5,a5,s4
ffffffffc020374c:	079a                	slli	a5,a5,0x6
ffffffffc020374e:	953e                	add	a0,a0,a5
ffffffffc0203750:	4585                	li	a1,1
ffffffffc0203752:	dccfe0ef          	jal	ra,ffffffffc0201d1e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203756:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020375a:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc020375e:	078a                	slli	a5,a5,0x2
ffffffffc0203760:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203762:	06e7f763          	bgeu	a5,a4,ffffffffc02037d0 <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc0203766:	000cb503          	ld	a0,0(s9)
ffffffffc020376a:	414787b3          	sub	a5,a5,s4
ffffffffc020376e:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203770:	4585                	li	a1,1
ffffffffc0203772:	953e                	add	a0,a0,a5
ffffffffc0203774:	daafe0ef          	jal	ra,ffffffffc0201d1e <free_pages>
     pgdir[0] = 0;
ffffffffc0203778:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020377c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203780:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203782:	00878a63          	beq	a5,s0,ffffffffc0203796 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203786:	ff87a703          	lw	a4,-8(a5)
ffffffffc020378a:	679c                	ld	a5,8(a5)
ffffffffc020378c:	3dfd                	addiw	s11,s11,-1
ffffffffc020378e:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203792:	fe879ae3          	bne	a5,s0,ffffffffc0203786 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203796:	1c0d9f63          	bnez	s11,ffffffffc0203974 <swap_init+0x5a6>
     assert(total==0);
ffffffffc020379a:	1a0d1163          	bnez	s10,ffffffffc020393c <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc020379e:	00004517          	auipc	a0,0x4
ffffffffc02037a2:	4d250513          	addi	a0,a0,1234 # ffffffffc0207c70 <default_pmm_manager+0x9a0>
ffffffffc02037a6:	9dbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc02037aa:	b99d                	j	ffffffffc0203420 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02037ac:	4481                	li	s1,0
ffffffffc02037ae:	b9f1                	j	ffffffffc020348a <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc02037b0:	00003697          	auipc	a3,0x3
ffffffffc02037b4:	77868693          	addi	a3,a3,1912 # ffffffffc0206f28 <commands+0x740>
ffffffffc02037b8:	00003617          	auipc	a2,0x3
ffffffffc02037bc:	48060613          	addi	a2,a2,1152 # ffffffffc0206c38 <commands+0x450>
ffffffffc02037c0:	0bc00593          	li	a1,188
ffffffffc02037c4:	00004517          	auipc	a0,0x4
ffffffffc02037c8:	24450513          	addi	a0,a0,580 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc02037cc:	caffc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02037d0:	be3ff0ef          	jal	ra,ffffffffc02033b2 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc02037d4:	00004617          	auipc	a2,0x4
ffffffffc02037d8:	c0460613          	addi	a2,a2,-1020 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc02037dc:	06200593          	li	a1,98
ffffffffc02037e0:	00004517          	auipc	a0,0x4
ffffffffc02037e4:	b5050513          	addi	a0,a0,-1200 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc02037e8:	c93fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037ec:	00004697          	auipc	a3,0x4
ffffffffc02037f0:	40c68693          	addi	a3,a3,1036 # ffffffffc0207bf8 <default_pmm_manager+0x928>
ffffffffc02037f4:	00003617          	auipc	a2,0x3
ffffffffc02037f8:	44460613          	addi	a2,a2,1092 # ffffffffc0206c38 <commands+0x450>
ffffffffc02037fc:	0fc00593          	li	a1,252
ffffffffc0203800:	00004517          	auipc	a0,0x4
ffffffffc0203804:	20850513          	addi	a0,a0,520 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203808:	c73fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020380c:	00004697          	auipc	a3,0x4
ffffffffc0203810:	30c68693          	addi	a3,a3,780 # ffffffffc0207b18 <default_pmm_manager+0x848>
ffffffffc0203814:	00003617          	auipc	a2,0x3
ffffffffc0203818:	42460613          	addi	a2,a2,1060 # ffffffffc0206c38 <commands+0x450>
ffffffffc020381c:	0dc00593          	li	a1,220
ffffffffc0203820:	00004517          	auipc	a0,0x4
ffffffffc0203824:	1e850513          	addi	a0,a0,488 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203828:	c53fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020382c:	00004617          	auipc	a2,0x4
ffffffffc0203830:	1bc60613          	addi	a2,a2,444 # ffffffffc02079e8 <default_pmm_manager+0x718>
ffffffffc0203834:	02800593          	li	a1,40
ffffffffc0203838:	00004517          	auipc	a0,0x4
ffffffffc020383c:	1d050513          	addi	a0,a0,464 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203840:	c3bfc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203844:	00004697          	auipc	a3,0x4
ffffffffc0203848:	39c68693          	addi	a3,a3,924 # ffffffffc0207be0 <default_pmm_manager+0x910>
ffffffffc020384c:	00003617          	auipc	a2,0x3
ffffffffc0203850:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203854:	0fb00593          	li	a1,251
ffffffffc0203858:	00004517          	auipc	a0,0x4
ffffffffc020385c:	1b050513          	addi	a0,a0,432 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203860:	c1bfc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203864:	00004617          	auipc	a2,0x4
ffffffffc0203868:	b9460613          	addi	a2,a2,-1132 # ffffffffc02073f8 <default_pmm_manager+0x128>
ffffffffc020386c:	07400593          	li	a1,116
ffffffffc0203870:	00004517          	auipc	a0,0x4
ffffffffc0203874:	ac050513          	addi	a0,a0,-1344 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0203878:	c03fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020387c:	00004697          	auipc	a3,0x4
ffffffffc0203880:	2b468693          	addi	a3,a3,692 # ffffffffc0207b30 <default_pmm_manager+0x860>
ffffffffc0203884:	00003617          	auipc	a2,0x3
ffffffffc0203888:	3b460613          	addi	a2,a2,948 # ffffffffc0206c38 <commands+0x450>
ffffffffc020388c:	0dd00593          	li	a1,221
ffffffffc0203890:	00004517          	auipc	a0,0x4
ffffffffc0203894:	17850513          	addi	a0,a0,376 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203898:	be3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020389c:	00004697          	auipc	a3,0x4
ffffffffc02038a0:	1cc68693          	addi	a3,a3,460 # ffffffffc0207a68 <default_pmm_manager+0x798>
ffffffffc02038a4:	00003617          	auipc	a2,0x3
ffffffffc02038a8:	39460613          	addi	a2,a2,916 # ffffffffc0206c38 <commands+0x450>
ffffffffc02038ac:	0c700593          	li	a1,199
ffffffffc02038b0:	00004517          	auipc	a0,0x4
ffffffffc02038b4:	15850513          	addi	a0,a0,344 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc02038b8:	bc3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total == nr_free_pages());
ffffffffc02038bc:	00003697          	auipc	a3,0x3
ffffffffc02038c0:	69468693          	addi	a3,a3,1684 # ffffffffc0206f50 <commands+0x768>
ffffffffc02038c4:	00003617          	auipc	a2,0x3
ffffffffc02038c8:	37460613          	addi	a2,a2,884 # ffffffffc0206c38 <commands+0x450>
ffffffffc02038cc:	0bf00593          	li	a1,191
ffffffffc02038d0:	00004517          	auipc	a0,0x4
ffffffffc02038d4:	13850513          	addi	a0,a0,312 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc02038d8:	ba3fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert( nr_free == 0);         
ffffffffc02038dc:	00004697          	auipc	a3,0x4
ffffffffc02038e0:	81c68693          	addi	a3,a3,-2020 # ffffffffc02070f8 <commands+0x910>
ffffffffc02038e4:	00003617          	auipc	a2,0x3
ffffffffc02038e8:	35460613          	addi	a2,a2,852 # ffffffffc0206c38 <commands+0x450>
ffffffffc02038ec:	0f300593          	li	a1,243
ffffffffc02038f0:	00004517          	auipc	a0,0x4
ffffffffc02038f4:	11850513          	addi	a0,a0,280 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc02038f8:	b83fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgdir[0] == 0);
ffffffffc02038fc:	00004697          	auipc	a3,0x4
ffffffffc0203900:	18468693          	addi	a3,a3,388 # ffffffffc0207a80 <default_pmm_manager+0x7b0>
ffffffffc0203904:	00003617          	auipc	a2,0x3
ffffffffc0203908:	33460613          	addi	a2,a2,820 # ffffffffc0206c38 <commands+0x450>
ffffffffc020390c:	0cc00593          	li	a1,204
ffffffffc0203910:	00004517          	auipc	a0,0x4
ffffffffc0203914:	0f850513          	addi	a0,a0,248 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203918:	b63fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(mm != NULL);
ffffffffc020391c:	00004697          	auipc	a3,0x4
ffffffffc0203920:	13c68693          	addi	a3,a3,316 # ffffffffc0207a58 <default_pmm_manager+0x788>
ffffffffc0203924:	00003617          	auipc	a2,0x3
ffffffffc0203928:	31460613          	addi	a2,a2,788 # ffffffffc0206c38 <commands+0x450>
ffffffffc020392c:	0c400593          	li	a1,196
ffffffffc0203930:	00004517          	auipc	a0,0x4
ffffffffc0203934:	0d850513          	addi	a0,a0,216 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203938:	b43fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total==0);
ffffffffc020393c:	00004697          	auipc	a3,0x4
ffffffffc0203940:	32468693          	addi	a3,a3,804 # ffffffffc0207c60 <default_pmm_manager+0x990>
ffffffffc0203944:	00003617          	auipc	a2,0x3
ffffffffc0203948:	2f460613          	addi	a2,a2,756 # ffffffffc0206c38 <commands+0x450>
ffffffffc020394c:	11e00593          	li	a1,286
ffffffffc0203950:	00004517          	auipc	a0,0x4
ffffffffc0203954:	0b850513          	addi	a0,a0,184 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203958:	b23fc0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc020395c:	00004617          	auipc	a2,0x4
ffffffffc0203960:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0203964:	06900593          	li	a1,105
ffffffffc0203968:	00004517          	auipc	a0,0x4
ffffffffc020396c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0203970:	b0bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(count==0);
ffffffffc0203974:	00004697          	auipc	a3,0x4
ffffffffc0203978:	2dc68693          	addi	a3,a3,732 # ffffffffc0207c50 <default_pmm_manager+0x980>
ffffffffc020397c:	00003617          	auipc	a2,0x3
ffffffffc0203980:	2bc60613          	addi	a2,a2,700 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203984:	11d00593          	li	a1,285
ffffffffc0203988:	00004517          	auipc	a0,0x4
ffffffffc020398c:	08050513          	addi	a0,a0,128 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203990:	aebfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203994:	00004697          	auipc	a3,0x4
ffffffffc0203998:	20c68693          	addi	a3,a3,524 # ffffffffc0207ba0 <default_pmm_manager+0x8d0>
ffffffffc020399c:	00003617          	auipc	a2,0x3
ffffffffc02039a0:	29c60613          	addi	a2,a2,668 # ffffffffc0206c38 <commands+0x450>
ffffffffc02039a4:	09500593          	li	a1,149
ffffffffc02039a8:	00004517          	auipc	a0,0x4
ffffffffc02039ac:	06050513          	addi	a0,a0,96 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc02039b0:	acbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02039b4:	00004697          	auipc	a3,0x4
ffffffffc02039b8:	19c68693          	addi	a3,a3,412 # ffffffffc0207b50 <default_pmm_manager+0x880>
ffffffffc02039bc:	00003617          	auipc	a2,0x3
ffffffffc02039c0:	27c60613          	addi	a2,a2,636 # ffffffffc0206c38 <commands+0x450>
ffffffffc02039c4:	0ea00593          	li	a1,234
ffffffffc02039c8:	00004517          	auipc	a0,0x4
ffffffffc02039cc:	04050513          	addi	a0,a0,64 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc02039d0:	aabfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039d4:	00004697          	auipc	a3,0x4
ffffffffc02039d8:	10468693          	addi	a3,a3,260 # ffffffffc0207ad8 <default_pmm_manager+0x808>
ffffffffc02039dc:	00003617          	auipc	a2,0x3
ffffffffc02039e0:	25c60613          	addi	a2,a2,604 # ffffffffc0206c38 <commands+0x450>
ffffffffc02039e4:	0d700593          	li	a1,215
ffffffffc02039e8:	00004517          	auipc	a0,0x4
ffffffffc02039ec:	02050513          	addi	a0,a0,32 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc02039f0:	a8bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(ret==0);
ffffffffc02039f4:	00004697          	auipc	a3,0x4
ffffffffc02039f8:	25468693          	addi	a3,a3,596 # ffffffffc0207c48 <default_pmm_manager+0x978>
ffffffffc02039fc:	00003617          	auipc	a2,0x3
ffffffffc0203a00:	23c60613          	addi	a2,a2,572 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203a04:	10200593          	li	a1,258
ffffffffc0203a08:	00004517          	auipc	a0,0x4
ffffffffc0203a0c:	00050513          	mv	a0,a0
ffffffffc0203a10:	a6bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(vma != NULL);
ffffffffc0203a14:	00004697          	auipc	a3,0x4
ffffffffc0203a18:	07c68693          	addi	a3,a3,124 # ffffffffc0207a90 <default_pmm_manager+0x7c0>
ffffffffc0203a1c:	00003617          	auipc	a2,0x3
ffffffffc0203a20:	21c60613          	addi	a2,a2,540 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203a24:	0cf00593          	li	a1,207
ffffffffc0203a28:	00004517          	auipc	a0,0x4
ffffffffc0203a2c:	fe050513          	addi	a0,a0,-32 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203a30:	a4bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203a34:	00004697          	auipc	a3,0x4
ffffffffc0203a38:	19c68693          	addi	a3,a3,412 # ffffffffc0207bd0 <default_pmm_manager+0x900>
ffffffffc0203a3c:	00003617          	auipc	a2,0x3
ffffffffc0203a40:	1fc60613          	addi	a2,a2,508 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203a44:	09f00593          	li	a1,159
ffffffffc0203a48:	00004517          	auipc	a0,0x4
ffffffffc0203a4c:	fc050513          	addi	a0,a0,-64 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203a50:	a2bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203a54:	00004697          	auipc	a3,0x4
ffffffffc0203a58:	17c68693          	addi	a3,a3,380 # ffffffffc0207bd0 <default_pmm_manager+0x900>
ffffffffc0203a5c:	00003617          	auipc	a2,0x3
ffffffffc0203a60:	1dc60613          	addi	a2,a2,476 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203a64:	0a100593          	li	a1,161
ffffffffc0203a68:	00004517          	auipc	a0,0x4
ffffffffc0203a6c:	fa050513          	addi	a0,a0,-96 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203a70:	a0bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203a74:	00004697          	auipc	a3,0x4
ffffffffc0203a78:	13c68693          	addi	a3,a3,316 # ffffffffc0207bb0 <default_pmm_manager+0x8e0>
ffffffffc0203a7c:	00003617          	auipc	a2,0x3
ffffffffc0203a80:	1bc60613          	addi	a2,a2,444 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203a84:	09700593          	li	a1,151
ffffffffc0203a88:	00004517          	auipc	a0,0x4
ffffffffc0203a8c:	f8050513          	addi	a0,a0,-128 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203a90:	9ebfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203a94:	00004697          	auipc	a3,0x4
ffffffffc0203a98:	11c68693          	addi	a3,a3,284 # ffffffffc0207bb0 <default_pmm_manager+0x8e0>
ffffffffc0203a9c:	00003617          	auipc	a2,0x3
ffffffffc0203aa0:	19c60613          	addi	a2,a2,412 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203aa4:	09900593          	li	a1,153
ffffffffc0203aa8:	00004517          	auipc	a0,0x4
ffffffffc0203aac:	f6050513          	addi	a0,a0,-160 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203ab0:	9cbfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203ab4:	00004697          	auipc	a3,0x4
ffffffffc0203ab8:	10c68693          	addi	a3,a3,268 # ffffffffc0207bc0 <default_pmm_manager+0x8f0>
ffffffffc0203abc:	00003617          	auipc	a2,0x3
ffffffffc0203ac0:	17c60613          	addi	a2,a2,380 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203ac4:	09b00593          	li	a1,155
ffffffffc0203ac8:	00004517          	auipc	a0,0x4
ffffffffc0203acc:	f4050513          	addi	a0,a0,-192 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203ad0:	9abfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203ad4:	00004697          	auipc	a3,0x4
ffffffffc0203ad8:	0ec68693          	addi	a3,a3,236 # ffffffffc0207bc0 <default_pmm_manager+0x8f0>
ffffffffc0203adc:	00003617          	auipc	a2,0x3
ffffffffc0203ae0:	15c60613          	addi	a2,a2,348 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203ae4:	09d00593          	li	a1,157
ffffffffc0203ae8:	00004517          	auipc	a0,0x4
ffffffffc0203aec:	f2050513          	addi	a0,a0,-224 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203af0:	98bfc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203af4:	00004697          	auipc	a3,0x4
ffffffffc0203af8:	0ac68693          	addi	a3,a3,172 # ffffffffc0207ba0 <default_pmm_manager+0x8d0>
ffffffffc0203afc:	00003617          	auipc	a2,0x3
ffffffffc0203b00:	13c60613          	addi	a2,a2,316 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203b04:	09300593          	li	a1,147
ffffffffc0203b08:	00004517          	auipc	a0,0x4
ffffffffc0203b0c:	f0050513          	addi	a0,a0,-256 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203b10:	96bfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203b14 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b14:	000af797          	auipc	a5,0xaf
ffffffffc0203b18:	f5c7b783          	ld	a5,-164(a5) # ffffffffc02b2a70 <sm>
ffffffffc0203b1c:	6b9c                	ld	a5,16(a5)
ffffffffc0203b1e:	8782                	jr	a5

ffffffffc0203b20 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b20:	000af797          	auipc	a5,0xaf
ffffffffc0203b24:	f507b783          	ld	a5,-176(a5) # ffffffffc02b2a70 <sm>
ffffffffc0203b28:	739c                	ld	a5,32(a5)
ffffffffc0203b2a:	8782                	jr	a5

ffffffffc0203b2c <swap_out>:
{
ffffffffc0203b2c:	711d                	addi	sp,sp,-96
ffffffffc0203b2e:	ec86                	sd	ra,88(sp)
ffffffffc0203b30:	e8a2                	sd	s0,80(sp)
ffffffffc0203b32:	e4a6                	sd	s1,72(sp)
ffffffffc0203b34:	e0ca                	sd	s2,64(sp)
ffffffffc0203b36:	fc4e                	sd	s3,56(sp)
ffffffffc0203b38:	f852                	sd	s4,48(sp)
ffffffffc0203b3a:	f456                	sd	s5,40(sp)
ffffffffc0203b3c:	f05a                	sd	s6,32(sp)
ffffffffc0203b3e:	ec5e                	sd	s7,24(sp)
ffffffffc0203b40:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b42:	cde9                	beqz	a1,ffffffffc0203c1c <swap_out+0xf0>
ffffffffc0203b44:	8a2e                	mv	s4,a1
ffffffffc0203b46:	892a                	mv	s2,a0
ffffffffc0203b48:	8ab2                	mv	s5,a2
ffffffffc0203b4a:	4401                	li	s0,0
ffffffffc0203b4c:	000af997          	auipc	s3,0xaf
ffffffffc0203b50:	f2498993          	addi	s3,s3,-220 # ffffffffc02b2a70 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b54:	00004b17          	auipc	s6,0x4
ffffffffc0203b58:	19cb0b13          	addi	s6,s6,412 # ffffffffc0207cf0 <default_pmm_manager+0xa20>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b5c:	00004b97          	auipc	s7,0x4
ffffffffc0203b60:	17cb8b93          	addi	s7,s7,380 # ffffffffc0207cd8 <default_pmm_manager+0xa08>
ffffffffc0203b64:	a825                	j	ffffffffc0203b9c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b66:	67a2                	ld	a5,8(sp)
ffffffffc0203b68:	8626                	mv	a2,s1
ffffffffc0203b6a:	85a2                	mv	a1,s0
ffffffffc0203b6c:	7f94                	ld	a3,56(a5)
ffffffffc0203b6e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b70:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b72:	82b1                	srli	a3,a3,0xc
ffffffffc0203b74:	0685                	addi	a3,a3,1
ffffffffc0203b76:	e0afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b7a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b7c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b7e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b80:	83b1                	srli	a5,a5,0xc
ffffffffc0203b82:	0785                	addi	a5,a5,1
ffffffffc0203b84:	07a2                	slli	a5,a5,0x8
ffffffffc0203b86:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b8a:	994fe0ef          	jal	ra,ffffffffc0201d1e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b8e:	01893503          	ld	a0,24(s2)
ffffffffc0203b92:	85a6                	mv	a1,s1
ffffffffc0203b94:	f5eff0ef          	jal	ra,ffffffffc02032f2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b98:	048a0d63          	beq	s4,s0,ffffffffc0203bf2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b9c:	0009b783          	ld	a5,0(s3)
ffffffffc0203ba0:	8656                	mv	a2,s5
ffffffffc0203ba2:	002c                	addi	a1,sp,8
ffffffffc0203ba4:	7b9c                	ld	a5,48(a5)
ffffffffc0203ba6:	854a                	mv	a0,s2
ffffffffc0203ba8:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203baa:	e12d                	bnez	a0,ffffffffc0203c0c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203bac:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bae:	01893503          	ld	a0,24(s2)
ffffffffc0203bb2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203bb4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bb6:	85a6                	mv	a1,s1
ffffffffc0203bb8:	9e0fe0ef          	jal	ra,ffffffffc0201d98 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bbc:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bbe:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bc0:	8b85                	andi	a5,a5,1
ffffffffc0203bc2:	cfb9                	beqz	a5,ffffffffc0203c20 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bc4:	65a2                	ld	a1,8(sp)
ffffffffc0203bc6:	7d9c                	ld	a5,56(a1)
ffffffffc0203bc8:	83b1                	srli	a5,a5,0xc
ffffffffc0203bca:	0785                	addi	a5,a5,1
ffffffffc0203bcc:	00879513          	slli	a0,a5,0x8
ffffffffc0203bd0:	00c010ef          	jal	ra,ffffffffc0204bdc <swapfs_write>
ffffffffc0203bd4:	d949                	beqz	a0,ffffffffc0203b66 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bd6:	855e                	mv	a0,s7
ffffffffc0203bd8:	da8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bdc:	0009b783          	ld	a5,0(s3)
ffffffffc0203be0:	6622                	ld	a2,8(sp)
ffffffffc0203be2:	4681                	li	a3,0
ffffffffc0203be4:	739c                	ld	a5,32(a5)
ffffffffc0203be6:	85a6                	mv	a1,s1
ffffffffc0203be8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bea:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bec:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bee:	fa8a17e3          	bne	s4,s0,ffffffffc0203b9c <swap_out+0x70>
}
ffffffffc0203bf2:	60e6                	ld	ra,88(sp)
ffffffffc0203bf4:	8522                	mv	a0,s0
ffffffffc0203bf6:	6446                	ld	s0,80(sp)
ffffffffc0203bf8:	64a6                	ld	s1,72(sp)
ffffffffc0203bfa:	6906                	ld	s2,64(sp)
ffffffffc0203bfc:	79e2                	ld	s3,56(sp)
ffffffffc0203bfe:	7a42                	ld	s4,48(sp)
ffffffffc0203c00:	7aa2                	ld	s5,40(sp)
ffffffffc0203c02:	7b02                	ld	s6,32(sp)
ffffffffc0203c04:	6be2                	ld	s7,24(sp)
ffffffffc0203c06:	6c42                	ld	s8,16(sp)
ffffffffc0203c08:	6125                	addi	sp,sp,96
ffffffffc0203c0a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c0c:	85a2                	mv	a1,s0
ffffffffc0203c0e:	00004517          	auipc	a0,0x4
ffffffffc0203c12:	08250513          	addi	a0,a0,130 # ffffffffc0207c90 <default_pmm_manager+0x9c0>
ffffffffc0203c16:	d6afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203c1a:	bfe1                	j	ffffffffc0203bf2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c1c:	4401                	li	s0,0
ffffffffc0203c1e:	bfd1                	j	ffffffffc0203bf2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c20:	00004697          	auipc	a3,0x4
ffffffffc0203c24:	0a068693          	addi	a3,a3,160 # ffffffffc0207cc0 <default_pmm_manager+0x9f0>
ffffffffc0203c28:	00003617          	auipc	a2,0x3
ffffffffc0203c2c:	01060613          	addi	a2,a2,16 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203c30:	06800593          	li	a1,104
ffffffffc0203c34:	00004517          	auipc	a0,0x4
ffffffffc0203c38:	dd450513          	addi	a0,a0,-556 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203c3c:	83ffc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203c40 <swap_in>:
{
ffffffffc0203c40:	7179                	addi	sp,sp,-48
ffffffffc0203c42:	e84a                	sd	s2,16(sp)
ffffffffc0203c44:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c46:	4505                	li	a0,1
{
ffffffffc0203c48:	ec26                	sd	s1,24(sp)
ffffffffc0203c4a:	e44e                	sd	s3,8(sp)
ffffffffc0203c4c:	f406                	sd	ra,40(sp)
ffffffffc0203c4e:	f022                	sd	s0,32(sp)
ffffffffc0203c50:	84ae                	mv	s1,a1
ffffffffc0203c52:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c54:	838fe0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c58:	c129                	beqz	a0,ffffffffc0203c9a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c5a:	842a                	mv	s0,a0
ffffffffc0203c5c:	01893503          	ld	a0,24(s2)
ffffffffc0203c60:	4601                	li	a2,0
ffffffffc0203c62:	85a6                	mv	a1,s1
ffffffffc0203c64:	934fe0ef          	jal	ra,ffffffffc0201d98 <get_pte>
ffffffffc0203c68:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c6a:	6108                	ld	a0,0(a0)
ffffffffc0203c6c:	85a2                	mv	a1,s0
ffffffffc0203c6e:	6e1000ef          	jal	ra,ffffffffc0204b4e <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c72:	00093583          	ld	a1,0(s2)
ffffffffc0203c76:	8626                	mv	a2,s1
ffffffffc0203c78:	00004517          	auipc	a0,0x4
ffffffffc0203c7c:	0c850513          	addi	a0,a0,200 # ffffffffc0207d40 <default_pmm_manager+0xa70>
ffffffffc0203c80:	81a1                	srli	a1,a1,0x8
ffffffffc0203c82:	cfefc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203c86:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c88:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c8c:	7402                	ld	s0,32(sp)
ffffffffc0203c8e:	64e2                	ld	s1,24(sp)
ffffffffc0203c90:	6942                	ld	s2,16(sp)
ffffffffc0203c92:	69a2                	ld	s3,8(sp)
ffffffffc0203c94:	4501                	li	a0,0
ffffffffc0203c96:	6145                	addi	sp,sp,48
ffffffffc0203c98:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c9a:	00004697          	auipc	a3,0x4
ffffffffc0203c9e:	09668693          	addi	a3,a3,150 # ffffffffc0207d30 <default_pmm_manager+0xa60>
ffffffffc0203ca2:	00003617          	auipc	a2,0x3
ffffffffc0203ca6:	f9660613          	addi	a2,a2,-106 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203caa:	07e00593          	li	a1,126
ffffffffc0203cae:	00004517          	auipc	a0,0x4
ffffffffc0203cb2:	d5a50513          	addi	a0,a0,-678 # ffffffffc0207a08 <default_pmm_manager+0x738>
ffffffffc0203cb6:	fc4fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203cba <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203cba:	000ab797          	auipc	a5,0xab
ffffffffc0203cbe:	d3e78793          	addi	a5,a5,-706 # ffffffffc02ae9f8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203cc2:	f51c                	sd	a5,40(a0)
ffffffffc0203cc4:	e79c                	sd	a5,8(a5)
ffffffffc0203cc6:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203cc8:	4501                	li	a0,0
ffffffffc0203cca:	8082                	ret

ffffffffc0203ccc <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203ccc:	4501                	li	a0,0
ffffffffc0203cce:	8082                	ret

ffffffffc0203cd0 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cd0:	4501                	li	a0,0
ffffffffc0203cd2:	8082                	ret

ffffffffc0203cd4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203cd4:	4501                	li	a0,0
ffffffffc0203cd6:	8082                	ret

ffffffffc0203cd8 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203cd8:	711d                	addi	sp,sp,-96
ffffffffc0203cda:	fc4e                	sd	s3,56(sp)
ffffffffc0203cdc:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cde:	00004517          	auipc	a0,0x4
ffffffffc0203ce2:	0a250513          	addi	a0,a0,162 # ffffffffc0207d80 <default_pmm_manager+0xab0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ce6:	698d                	lui	s3,0x3
ffffffffc0203ce8:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203cea:	e0ca                	sd	s2,64(sp)
ffffffffc0203cec:	ec86                	sd	ra,88(sp)
ffffffffc0203cee:	e8a2                	sd	s0,80(sp)
ffffffffc0203cf0:	e4a6                	sd	s1,72(sp)
ffffffffc0203cf2:	f456                	sd	s5,40(sp)
ffffffffc0203cf4:	f05a                	sd	s6,32(sp)
ffffffffc0203cf6:	ec5e                	sd	s7,24(sp)
ffffffffc0203cf8:	e862                	sd	s8,16(sp)
ffffffffc0203cfa:	e466                	sd	s9,8(sp)
ffffffffc0203cfc:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cfe:	c82fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d02:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6bd8>
    assert(pgfault_num==4);
ffffffffc0203d06:	000af917          	auipc	s2,0xaf
ffffffffc0203d0a:	d8292903          	lw	s2,-638(s2) # ffffffffc02b2a88 <pgfault_num>
ffffffffc0203d0e:	4791                	li	a5,4
ffffffffc0203d10:	14f91e63          	bne	s2,a5,ffffffffc0203e6c <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d14:	00004517          	auipc	a0,0x4
ffffffffc0203d18:	0ac50513          	addi	a0,a0,172 # ffffffffc0207dc0 <default_pmm_manager+0xaf0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d1c:	6a85                	lui	s5,0x1
ffffffffc0203d1e:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d20:	c60fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203d24:	000af417          	auipc	s0,0xaf
ffffffffc0203d28:	d6440413          	addi	s0,s0,-668 # ffffffffc02b2a88 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d2c:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
    assert(pgfault_num==4);
ffffffffc0203d30:	4004                	lw	s1,0(s0)
ffffffffc0203d32:	2481                	sext.w	s1,s1
ffffffffc0203d34:	2b249c63          	bne	s1,s2,ffffffffc0203fec <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d38:	00004517          	auipc	a0,0x4
ffffffffc0203d3c:	0b050513          	addi	a0,a0,176 # ffffffffc0207de8 <default_pmm_manager+0xb18>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d40:	6b91                	lui	s7,0x4
ffffffffc0203d42:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d44:	c3cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d48:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5bd8>
    assert(pgfault_num==4);
ffffffffc0203d4c:	00042903          	lw	s2,0(s0)
ffffffffc0203d50:	2901                	sext.w	s2,s2
ffffffffc0203d52:	26991d63          	bne	s2,s1,ffffffffc0203fcc <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d56:	00004517          	auipc	a0,0x4
ffffffffc0203d5a:	0ba50513          	addi	a0,a0,186 # ffffffffc0207e10 <default_pmm_manager+0xb40>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d5e:	6c89                	lui	s9,0x2
ffffffffc0203d60:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d62:	c1efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d66:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7bd8>
    assert(pgfault_num==4);
ffffffffc0203d6a:	401c                	lw	a5,0(s0)
ffffffffc0203d6c:	2781                	sext.w	a5,a5
ffffffffc0203d6e:	23279f63          	bne	a5,s2,ffffffffc0203fac <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d72:	00004517          	auipc	a0,0x4
ffffffffc0203d76:	0c650513          	addi	a0,a0,198 # ffffffffc0207e38 <default_pmm_manager+0xb68>
ffffffffc0203d7a:	c06fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d7e:	6795                	lui	a5,0x5
ffffffffc0203d80:	4739                	li	a4,14
ffffffffc0203d82:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bd8>
    assert(pgfault_num==5);
ffffffffc0203d86:	4004                	lw	s1,0(s0)
ffffffffc0203d88:	4795                	li	a5,5
ffffffffc0203d8a:	2481                	sext.w	s1,s1
ffffffffc0203d8c:	20f49063          	bne	s1,a5,ffffffffc0203f8c <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d90:	00004517          	auipc	a0,0x4
ffffffffc0203d94:	08050513          	addi	a0,a0,128 # ffffffffc0207e10 <default_pmm_manager+0xb40>
ffffffffc0203d98:	be8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d9c:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203da0:	401c                	lw	a5,0(s0)
ffffffffc0203da2:	2781                	sext.w	a5,a5
ffffffffc0203da4:	1c979463          	bne	a5,s1,ffffffffc0203f6c <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203da8:	00004517          	auipc	a0,0x4
ffffffffc0203dac:	01850513          	addi	a0,a0,24 # ffffffffc0207dc0 <default_pmm_manager+0xaf0>
ffffffffc0203db0:	bd0fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203db4:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203db8:	401c                	lw	a5,0(s0)
ffffffffc0203dba:	4719                	li	a4,6
ffffffffc0203dbc:	2781                	sext.w	a5,a5
ffffffffc0203dbe:	18e79763          	bne	a5,a4,ffffffffc0203f4c <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dc2:	00004517          	auipc	a0,0x4
ffffffffc0203dc6:	04e50513          	addi	a0,a0,78 # ffffffffc0207e10 <default_pmm_manager+0xb40>
ffffffffc0203dca:	bb6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203dce:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203dd2:	401c                	lw	a5,0(s0)
ffffffffc0203dd4:	471d                	li	a4,7
ffffffffc0203dd6:	2781                	sext.w	a5,a5
ffffffffc0203dd8:	14e79a63          	bne	a5,a4,ffffffffc0203f2c <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203ddc:	00004517          	auipc	a0,0x4
ffffffffc0203de0:	fa450513          	addi	a0,a0,-92 # ffffffffc0207d80 <default_pmm_manager+0xab0>
ffffffffc0203de4:	b9cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203de8:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203dec:	401c                	lw	a5,0(s0)
ffffffffc0203dee:	4721                	li	a4,8
ffffffffc0203df0:	2781                	sext.w	a5,a5
ffffffffc0203df2:	10e79d63          	bne	a5,a4,ffffffffc0203f0c <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203df6:	00004517          	auipc	a0,0x4
ffffffffc0203dfa:	ff250513          	addi	a0,a0,-14 # ffffffffc0207de8 <default_pmm_manager+0xb18>
ffffffffc0203dfe:	b82fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e02:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e06:	401c                	lw	a5,0(s0)
ffffffffc0203e08:	4725                	li	a4,9
ffffffffc0203e0a:	2781                	sext.w	a5,a5
ffffffffc0203e0c:	0ee79063          	bne	a5,a4,ffffffffc0203eec <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e10:	00004517          	auipc	a0,0x4
ffffffffc0203e14:	02850513          	addi	a0,a0,40 # ffffffffc0207e38 <default_pmm_manager+0xb68>
ffffffffc0203e18:	b68fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e1c:	6795                	lui	a5,0x5
ffffffffc0203e1e:	4739                	li	a4,14
ffffffffc0203e20:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4bd8>
    assert(pgfault_num==10);
ffffffffc0203e24:	4004                	lw	s1,0(s0)
ffffffffc0203e26:	47a9                	li	a5,10
ffffffffc0203e28:	2481                	sext.w	s1,s1
ffffffffc0203e2a:	0af49163          	bne	s1,a5,ffffffffc0203ecc <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e2e:	00004517          	auipc	a0,0x4
ffffffffc0203e32:	f9250513          	addi	a0,a0,-110 # ffffffffc0207dc0 <default_pmm_manager+0xaf0>
ffffffffc0203e36:	b4afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e3a:	6785                	lui	a5,0x1
ffffffffc0203e3c:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
ffffffffc0203e40:	06979663          	bne	a5,s1,ffffffffc0203eac <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203e44:	401c                	lw	a5,0(s0)
ffffffffc0203e46:	472d                	li	a4,11
ffffffffc0203e48:	2781                	sext.w	a5,a5
ffffffffc0203e4a:	04e79163          	bne	a5,a4,ffffffffc0203e8c <_fifo_check_swap+0x1b4>
}
ffffffffc0203e4e:	60e6                	ld	ra,88(sp)
ffffffffc0203e50:	6446                	ld	s0,80(sp)
ffffffffc0203e52:	64a6                	ld	s1,72(sp)
ffffffffc0203e54:	6906                	ld	s2,64(sp)
ffffffffc0203e56:	79e2                	ld	s3,56(sp)
ffffffffc0203e58:	7a42                	ld	s4,48(sp)
ffffffffc0203e5a:	7aa2                	ld	s5,40(sp)
ffffffffc0203e5c:	7b02                	ld	s6,32(sp)
ffffffffc0203e5e:	6be2                	ld	s7,24(sp)
ffffffffc0203e60:	6c42                	ld	s8,16(sp)
ffffffffc0203e62:	6ca2                	ld	s9,8(sp)
ffffffffc0203e64:	6d02                	ld	s10,0(sp)
ffffffffc0203e66:	4501                	li	a0,0
ffffffffc0203e68:	6125                	addi	sp,sp,96
ffffffffc0203e6a:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e6c:	00004697          	auipc	a3,0x4
ffffffffc0203e70:	d6468693          	addi	a3,a3,-668 # ffffffffc0207bd0 <default_pmm_manager+0x900>
ffffffffc0203e74:	00003617          	auipc	a2,0x3
ffffffffc0203e78:	dc460613          	addi	a2,a2,-572 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203e7c:	05400593          	li	a1,84
ffffffffc0203e80:	00004517          	auipc	a0,0x4
ffffffffc0203e84:	f2850513          	addi	a0,a0,-216 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203e88:	df2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==11);
ffffffffc0203e8c:	00004697          	auipc	a3,0x4
ffffffffc0203e90:	05c68693          	addi	a3,a3,92 # ffffffffc0207ee8 <default_pmm_manager+0xc18>
ffffffffc0203e94:	00003617          	auipc	a2,0x3
ffffffffc0203e98:	da460613          	addi	a2,a2,-604 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203e9c:	07600593          	li	a1,118
ffffffffc0203ea0:	00004517          	auipc	a0,0x4
ffffffffc0203ea4:	f0850513          	addi	a0,a0,-248 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203ea8:	dd2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203eac:	00004697          	auipc	a3,0x4
ffffffffc0203eb0:	01468693          	addi	a3,a3,20 # ffffffffc0207ec0 <default_pmm_manager+0xbf0>
ffffffffc0203eb4:	00003617          	auipc	a2,0x3
ffffffffc0203eb8:	d8460613          	addi	a2,a2,-636 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203ebc:	07400593          	li	a1,116
ffffffffc0203ec0:	00004517          	auipc	a0,0x4
ffffffffc0203ec4:	ee850513          	addi	a0,a0,-280 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203ec8:	db2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==10);
ffffffffc0203ecc:	00004697          	auipc	a3,0x4
ffffffffc0203ed0:	fe468693          	addi	a3,a3,-28 # ffffffffc0207eb0 <default_pmm_manager+0xbe0>
ffffffffc0203ed4:	00003617          	auipc	a2,0x3
ffffffffc0203ed8:	d6460613          	addi	a2,a2,-668 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203edc:	07200593          	li	a1,114
ffffffffc0203ee0:	00004517          	auipc	a0,0x4
ffffffffc0203ee4:	ec850513          	addi	a0,a0,-312 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203ee8:	d92fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==9);
ffffffffc0203eec:	00004697          	auipc	a3,0x4
ffffffffc0203ef0:	fb468693          	addi	a3,a3,-76 # ffffffffc0207ea0 <default_pmm_manager+0xbd0>
ffffffffc0203ef4:	00003617          	auipc	a2,0x3
ffffffffc0203ef8:	d4460613          	addi	a2,a2,-700 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203efc:	06f00593          	li	a1,111
ffffffffc0203f00:	00004517          	auipc	a0,0x4
ffffffffc0203f04:	ea850513          	addi	a0,a0,-344 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203f08:	d72fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==8);
ffffffffc0203f0c:	00004697          	auipc	a3,0x4
ffffffffc0203f10:	f8468693          	addi	a3,a3,-124 # ffffffffc0207e90 <default_pmm_manager+0xbc0>
ffffffffc0203f14:	00003617          	auipc	a2,0x3
ffffffffc0203f18:	d2460613          	addi	a2,a2,-732 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203f1c:	06c00593          	li	a1,108
ffffffffc0203f20:	00004517          	auipc	a0,0x4
ffffffffc0203f24:	e8850513          	addi	a0,a0,-376 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203f28:	d52fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==7);
ffffffffc0203f2c:	00004697          	auipc	a3,0x4
ffffffffc0203f30:	f5468693          	addi	a3,a3,-172 # ffffffffc0207e80 <default_pmm_manager+0xbb0>
ffffffffc0203f34:	00003617          	auipc	a2,0x3
ffffffffc0203f38:	d0460613          	addi	a2,a2,-764 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203f3c:	06900593          	li	a1,105
ffffffffc0203f40:	00004517          	auipc	a0,0x4
ffffffffc0203f44:	e6850513          	addi	a0,a0,-408 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203f48:	d32fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==6);
ffffffffc0203f4c:	00004697          	auipc	a3,0x4
ffffffffc0203f50:	f2468693          	addi	a3,a3,-220 # ffffffffc0207e70 <default_pmm_manager+0xba0>
ffffffffc0203f54:	00003617          	auipc	a2,0x3
ffffffffc0203f58:	ce460613          	addi	a2,a2,-796 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203f5c:	06600593          	li	a1,102
ffffffffc0203f60:	00004517          	auipc	a0,0x4
ffffffffc0203f64:	e4850513          	addi	a0,a0,-440 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203f68:	d12fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0203f6c:	00004697          	auipc	a3,0x4
ffffffffc0203f70:	ef468693          	addi	a3,a3,-268 # ffffffffc0207e60 <default_pmm_manager+0xb90>
ffffffffc0203f74:	00003617          	auipc	a2,0x3
ffffffffc0203f78:	cc460613          	addi	a2,a2,-828 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203f7c:	06300593          	li	a1,99
ffffffffc0203f80:	00004517          	auipc	a0,0x4
ffffffffc0203f84:	e2850513          	addi	a0,a0,-472 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203f88:	cf2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0203f8c:	00004697          	auipc	a3,0x4
ffffffffc0203f90:	ed468693          	addi	a3,a3,-300 # ffffffffc0207e60 <default_pmm_manager+0xb90>
ffffffffc0203f94:	00003617          	auipc	a2,0x3
ffffffffc0203f98:	ca460613          	addi	a2,a2,-860 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203f9c:	06000593          	li	a1,96
ffffffffc0203fa0:	00004517          	auipc	a0,0x4
ffffffffc0203fa4:	e0850513          	addi	a0,a0,-504 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203fa8:	cd2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203fac:	00004697          	auipc	a3,0x4
ffffffffc0203fb0:	c2468693          	addi	a3,a3,-988 # ffffffffc0207bd0 <default_pmm_manager+0x900>
ffffffffc0203fb4:	00003617          	auipc	a2,0x3
ffffffffc0203fb8:	c8460613          	addi	a2,a2,-892 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203fbc:	05d00593          	li	a1,93
ffffffffc0203fc0:	00004517          	auipc	a0,0x4
ffffffffc0203fc4:	de850513          	addi	a0,a0,-536 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203fc8:	cb2fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203fcc:	00004697          	auipc	a3,0x4
ffffffffc0203fd0:	c0468693          	addi	a3,a3,-1020 # ffffffffc0207bd0 <default_pmm_manager+0x900>
ffffffffc0203fd4:	00003617          	auipc	a2,0x3
ffffffffc0203fd8:	c6460613          	addi	a2,a2,-924 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203fdc:	05a00593          	li	a1,90
ffffffffc0203fe0:	00004517          	auipc	a0,0x4
ffffffffc0203fe4:	dc850513          	addi	a0,a0,-568 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0203fe8:	c92fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0203fec:	00004697          	auipc	a3,0x4
ffffffffc0203ff0:	be468693          	addi	a3,a3,-1052 # ffffffffc0207bd0 <default_pmm_manager+0x900>
ffffffffc0203ff4:	00003617          	auipc	a2,0x3
ffffffffc0203ff8:	c4460613          	addi	a2,a2,-956 # ffffffffc0206c38 <commands+0x450>
ffffffffc0203ffc:	05700593          	li	a1,87
ffffffffc0204000:	00004517          	auipc	a0,0x4
ffffffffc0204004:	da850513          	addi	a0,a0,-600 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc0204008:	c72fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020400c <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020400c:	7518                	ld	a4,40(a0)
{
ffffffffc020400e:	1141                	addi	sp,sp,-16
ffffffffc0204010:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204012:	c731                	beqz	a4,ffffffffc020405e <_fifo_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc0204014:	e60d                	bnez	a2,ffffffffc020403e <_fifo_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc0204016:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0204018:	00f70d63          	beq	a4,a5,ffffffffc0204032 <_fifo_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020401c:	6394                	ld	a3,0(a5)
ffffffffc020401e:	6798                	ld	a4,8(a5)
}
ffffffffc0204020:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204022:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0204026:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204028:	e314                	sd	a3,0(a4)
ffffffffc020402a:	e19c                	sd	a5,0(a1)
}
ffffffffc020402c:	4501                	li	a0,0
ffffffffc020402e:	0141                	addi	sp,sp,16
ffffffffc0204030:	8082                	ret
ffffffffc0204032:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0204034:	0005b023          	sd	zero,0(a1) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
}
ffffffffc0204038:	4501                	li	a0,0
ffffffffc020403a:	0141                	addi	sp,sp,16
ffffffffc020403c:	8082                	ret
     assert(in_tick==0);
ffffffffc020403e:	00004697          	auipc	a3,0x4
ffffffffc0204042:	eca68693          	addi	a3,a3,-310 # ffffffffc0207f08 <default_pmm_manager+0xc38>
ffffffffc0204046:	00003617          	auipc	a2,0x3
ffffffffc020404a:	bf260613          	addi	a2,a2,-1038 # ffffffffc0206c38 <commands+0x450>
ffffffffc020404e:	04200593          	li	a1,66
ffffffffc0204052:	00004517          	auipc	a0,0x4
ffffffffc0204056:	d5650513          	addi	a0,a0,-682 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc020405a:	c20fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(head != NULL);
ffffffffc020405e:	00004697          	auipc	a3,0x4
ffffffffc0204062:	e9a68693          	addi	a3,a3,-358 # ffffffffc0207ef8 <default_pmm_manager+0xc28>
ffffffffc0204066:	00003617          	auipc	a2,0x3
ffffffffc020406a:	bd260613          	addi	a2,a2,-1070 # ffffffffc0206c38 <commands+0x450>
ffffffffc020406e:	04100593          	li	a1,65
ffffffffc0204072:	00004517          	auipc	a0,0x4
ffffffffc0204076:	d3650513          	addi	a0,a0,-714 # ffffffffc0207da8 <default_pmm_manager+0xad8>
ffffffffc020407a:	c00fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020407e <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020407e:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0204080:	cb91                	beqz	a5,ffffffffc0204094 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm, listelm->next);
ffffffffc0204082:	6794                	ld	a3,8(a5)
ffffffffc0204084:	02860713          	addi	a4,a2,40
}
ffffffffc0204088:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020408a:	e298                	sd	a4,0(a3)
ffffffffc020408c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020408e:	fa14                	sd	a3,48(a2)
    elm->prev = prev;
ffffffffc0204090:	f61c                	sd	a5,40(a2)
ffffffffc0204092:	8082                	ret
{
ffffffffc0204094:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204096:	00004697          	auipc	a3,0x4
ffffffffc020409a:	e8268693          	addi	a3,a3,-382 # ffffffffc0207f18 <default_pmm_manager+0xc48>
ffffffffc020409e:	00003617          	auipc	a2,0x3
ffffffffc02040a2:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206c38 <commands+0x450>
ffffffffc02040a6:	03200593          	li	a1,50
ffffffffc02040aa:	00004517          	auipc	a0,0x4
ffffffffc02040ae:	cfe50513          	addi	a0,a0,-770 # ffffffffc0207da8 <default_pmm_manager+0xad8>
{
ffffffffc02040b2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02040b4:	bc6fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02040b8 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040b8:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02040ba:	00004697          	auipc	a3,0x4
ffffffffc02040be:	e9668693          	addi	a3,a3,-362 # ffffffffc0207f50 <default_pmm_manager+0xc80>
ffffffffc02040c2:	00003617          	auipc	a2,0x3
ffffffffc02040c6:	b7660613          	addi	a2,a2,-1162 # ffffffffc0206c38 <commands+0x450>
ffffffffc02040ca:	06d00593          	li	a1,109
ffffffffc02040ce:	00004517          	auipc	a0,0x4
ffffffffc02040d2:	ea250513          	addi	a0,a0,-350 # ffffffffc0207f70 <default_pmm_manager+0xca0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040d6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040d8:	ba2fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02040dc <mm_create>:
mm_create(void) {
ffffffffc02040dc:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040de:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02040e2:	e022                	sd	s0,0(sp)
ffffffffc02040e4:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040e6:	9c9fd0ef          	jal	ra,ffffffffc0201aae <kmalloc>
ffffffffc02040ea:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02040ec:	c505                	beqz	a0,ffffffffc0204114 <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc02040ee:	e408                	sd	a0,8(s0)
ffffffffc02040f0:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040f2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040f6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040fa:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040fe:	000af797          	auipc	a5,0xaf
ffffffffc0204102:	97a7a783          	lw	a5,-1670(a5) # ffffffffc02b2a78 <swap_init_ok>
ffffffffc0204106:	ef81                	bnez	a5,ffffffffc020411e <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc0204108:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020410c:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0204110:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204114:	60a2                	ld	ra,8(sp)
ffffffffc0204116:	8522                	mv	a0,s0
ffffffffc0204118:	6402                	ld	s0,0(sp)
ffffffffc020411a:	0141                	addi	sp,sp,16
ffffffffc020411c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020411e:	9f7ff0ef          	jal	ra,ffffffffc0203b14 <swap_init_mm>
ffffffffc0204122:	b7ed                	j	ffffffffc020410c <mm_create+0x30>

ffffffffc0204124 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204124:	1101                	addi	sp,sp,-32
ffffffffc0204126:	e04a                	sd	s2,0(sp)
ffffffffc0204128:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020412a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020412e:	e822                	sd	s0,16(sp)
ffffffffc0204130:	e426                	sd	s1,8(sp)
ffffffffc0204132:	ec06                	sd	ra,24(sp)
ffffffffc0204134:	84ae                	mv	s1,a1
ffffffffc0204136:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204138:	977fd0ef          	jal	ra,ffffffffc0201aae <kmalloc>
    if (vma != NULL) {
ffffffffc020413c:	c509                	beqz	a0,ffffffffc0204146 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020413e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204142:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204144:	cd00                	sw	s0,24(a0)
}
ffffffffc0204146:	60e2                	ld	ra,24(sp)
ffffffffc0204148:	6442                	ld	s0,16(sp)
ffffffffc020414a:	64a2                	ld	s1,8(sp)
ffffffffc020414c:	6902                	ld	s2,0(sp)
ffffffffc020414e:	6105                	addi	sp,sp,32
ffffffffc0204150:	8082                	ret

ffffffffc0204152 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0204152:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0204154:	c505                	beqz	a0,ffffffffc020417c <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0204156:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204158:	c501                	beqz	a0,ffffffffc0204160 <find_vma+0xe>
ffffffffc020415a:	651c                	ld	a5,8(a0)
ffffffffc020415c:	02f5f263          	bgeu	a1,a5,ffffffffc0204180 <find_vma+0x2e>
    return listelm->next;
ffffffffc0204160:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0204162:	00f68d63          	beq	a3,a5,ffffffffc020417c <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204166:	fe87b703          	ld	a4,-24(a5)
ffffffffc020416a:	00e5e663          	bltu	a1,a4,ffffffffc0204176 <find_vma+0x24>
ffffffffc020416e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204172:	00e5ec63          	bltu	a1,a4,ffffffffc020418a <find_vma+0x38>
ffffffffc0204176:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204178:	fef697e3          	bne	a3,a5,ffffffffc0204166 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020417c:	4501                	li	a0,0
}
ffffffffc020417e:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204180:	691c                	ld	a5,16(a0)
ffffffffc0204182:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0204160 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0204186:	ea88                	sd	a0,16(a3)
ffffffffc0204188:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc020418a:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020418e:	ea88                	sd	a0,16(a3)
ffffffffc0204190:	8082                	ret

ffffffffc0204192 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204192:	6590                	ld	a2,8(a1)
ffffffffc0204194:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204198:	1141                	addi	sp,sp,-16
ffffffffc020419a:	e406                	sd	ra,8(sp)
ffffffffc020419c:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020419e:	01066763          	bltu	a2,a6,ffffffffc02041ac <insert_vma_struct+0x1a>
ffffffffc02041a2:	a085                	j	ffffffffc0204202 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02041a4:	fe87b703          	ld	a4,-24(a5)
ffffffffc02041a8:	04e66863          	bltu	a2,a4,ffffffffc02041f8 <insert_vma_struct+0x66>
ffffffffc02041ac:	86be                	mv	a3,a5
ffffffffc02041ae:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02041b0:	fef51ae3          	bne	a0,a5,ffffffffc02041a4 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02041b4:	02a68463          	beq	a3,a0,ffffffffc02041dc <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02041b8:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041bc:	fe86b883          	ld	a7,-24(a3)
ffffffffc02041c0:	08e8f163          	bgeu	a7,a4,ffffffffc0204242 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041c4:	04e66f63          	bltu	a2,a4,ffffffffc0204222 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc02041c8:	00f50a63          	beq	a0,a5,ffffffffc02041dc <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02041cc:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041d0:	05076963          	bltu	a4,a6,ffffffffc0204222 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02041d4:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041d8:	02c77363          	bgeu	a4,a2,ffffffffc02041fe <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02041dc:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02041de:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041e0:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041e4:	e390                	sd	a2,0(a5)
ffffffffc02041e6:	e690                	sd	a2,8(a3)
}
ffffffffc02041e8:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041ea:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041ec:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc02041ee:	0017079b          	addiw	a5,a4,1
ffffffffc02041f2:	d11c                	sw	a5,32(a0)
}
ffffffffc02041f4:	0141                	addi	sp,sp,16
ffffffffc02041f6:	8082                	ret
    if (le_prev != list) {
ffffffffc02041f8:	fca690e3          	bne	a3,a0,ffffffffc02041b8 <insert_vma_struct+0x26>
ffffffffc02041fc:	bfd1                	j	ffffffffc02041d0 <insert_vma_struct+0x3e>
ffffffffc02041fe:	ebbff0ef          	jal	ra,ffffffffc02040b8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204202:	00004697          	auipc	a3,0x4
ffffffffc0204206:	d7e68693          	addi	a3,a3,-642 # ffffffffc0207f80 <default_pmm_manager+0xcb0>
ffffffffc020420a:	00003617          	auipc	a2,0x3
ffffffffc020420e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204212:	07400593          	li	a1,116
ffffffffc0204216:	00004517          	auipc	a0,0x4
ffffffffc020421a:	d5a50513          	addi	a0,a0,-678 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc020421e:	a5cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204222:	00004697          	auipc	a3,0x4
ffffffffc0204226:	d9e68693          	addi	a3,a3,-610 # ffffffffc0207fc0 <default_pmm_manager+0xcf0>
ffffffffc020422a:	00003617          	auipc	a2,0x3
ffffffffc020422e:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204232:	06c00593          	li	a1,108
ffffffffc0204236:	00004517          	auipc	a0,0x4
ffffffffc020423a:	d3a50513          	addi	a0,a0,-710 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc020423e:	a3cfc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204242:	00004697          	auipc	a3,0x4
ffffffffc0204246:	d5e68693          	addi	a3,a3,-674 # ffffffffc0207fa0 <default_pmm_manager+0xcd0>
ffffffffc020424a:	00003617          	auipc	a2,0x3
ffffffffc020424e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204252:	06b00593          	li	a1,107
ffffffffc0204256:	00004517          	auipc	a0,0x4
ffffffffc020425a:	d1a50513          	addi	a0,a0,-742 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc020425e:	a1cfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204262 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0204262:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204264:	1141                	addi	sp,sp,-16
ffffffffc0204266:	e406                	sd	ra,8(sp)
ffffffffc0204268:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020426a:	e78d                	bnez	a5,ffffffffc0204294 <mm_destroy+0x32>
ffffffffc020426c:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020426e:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204270:	00a40c63          	beq	s0,a0,ffffffffc0204288 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204274:	6118                	ld	a4,0(a0)
ffffffffc0204276:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204278:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020427a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020427c:	e398                	sd	a4,0(a5)
ffffffffc020427e:	8e1fd0ef          	jal	ra,ffffffffc0201b5e <kfree>
    return listelm->next;
ffffffffc0204282:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204284:	fea418e3          	bne	s0,a0,ffffffffc0204274 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204288:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020428a:	6402                	ld	s0,0(sp)
ffffffffc020428c:	60a2                	ld	ra,8(sp)
ffffffffc020428e:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0204290:	8cffd06f          	j	ffffffffc0201b5e <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204294:	00004697          	auipc	a3,0x4
ffffffffc0204298:	d4c68693          	addi	a3,a3,-692 # ffffffffc0207fe0 <default_pmm_manager+0xd10>
ffffffffc020429c:	00003617          	auipc	a2,0x3
ffffffffc02042a0:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206c38 <commands+0x450>
ffffffffc02042a4:	09400593          	li	a1,148
ffffffffc02042a8:	00004517          	auipc	a0,0x4
ffffffffc02042ac:	cc850513          	addi	a0,a0,-824 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02042b0:	9cafc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02042b4 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc02042b4:	7139                	addi	sp,sp,-64
ffffffffc02042b6:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042b8:	6405                	lui	s0,0x1
ffffffffc02042ba:	147d                	addi	s0,s0,-1
ffffffffc02042bc:	77fd                	lui	a5,0xfffff
ffffffffc02042be:	9622                	add	a2,a2,s0
ffffffffc02042c0:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc02042c2:	f426                	sd	s1,40(sp)
ffffffffc02042c4:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042c6:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc02042ca:	f04a                	sd	s2,32(sp)
ffffffffc02042cc:	ec4e                	sd	s3,24(sp)
ffffffffc02042ce:	e852                	sd	s4,16(sp)
ffffffffc02042d0:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc02042d2:	002005b7          	lui	a1,0x200
ffffffffc02042d6:	00f67433          	and	s0,a2,a5
ffffffffc02042da:	06b4e363          	bltu	s1,a1,ffffffffc0204340 <mm_map+0x8c>
ffffffffc02042de:	0684f163          	bgeu	s1,s0,ffffffffc0204340 <mm_map+0x8c>
ffffffffc02042e2:	4785                	li	a5,1
ffffffffc02042e4:	07fe                	slli	a5,a5,0x1f
ffffffffc02042e6:	0487ed63          	bltu	a5,s0,ffffffffc0204340 <mm_map+0x8c>
ffffffffc02042ea:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042ec:	cd21                	beqz	a0,ffffffffc0204344 <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042ee:	85a6                	mv	a1,s1
ffffffffc02042f0:	8ab6                	mv	s5,a3
ffffffffc02042f2:	8a3a                	mv	s4,a4
ffffffffc02042f4:	e5fff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc02042f8:	c501                	beqz	a0,ffffffffc0204300 <mm_map+0x4c>
ffffffffc02042fa:	651c                	ld	a5,8(a0)
ffffffffc02042fc:	0487e263          	bltu	a5,s0,ffffffffc0204340 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204300:	03000513          	li	a0,48
ffffffffc0204304:	faafd0ef          	jal	ra,ffffffffc0201aae <kmalloc>
ffffffffc0204308:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020430a:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020430c:	02090163          	beqz	s2,ffffffffc020432e <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0204310:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0204312:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204316:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc020431a:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020431e:	85ca                	mv	a1,s2
ffffffffc0204320:	e73ff0ef          	jal	ra,ffffffffc0204192 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204324:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204326:	000a0463          	beqz	s4,ffffffffc020432e <mm_map+0x7a>
        *vma_store = vma;
ffffffffc020432a:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020432e:	70e2                	ld	ra,56(sp)
ffffffffc0204330:	7442                	ld	s0,48(sp)
ffffffffc0204332:	74a2                	ld	s1,40(sp)
ffffffffc0204334:	7902                	ld	s2,32(sp)
ffffffffc0204336:	69e2                	ld	s3,24(sp)
ffffffffc0204338:	6a42                	ld	s4,16(sp)
ffffffffc020433a:	6aa2                	ld	s5,8(sp)
ffffffffc020433c:	6121                	addi	sp,sp,64
ffffffffc020433e:	8082                	ret
        return -E_INVAL;
ffffffffc0204340:	5575                	li	a0,-3
ffffffffc0204342:	b7f5                	j	ffffffffc020432e <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc0204344:	00003697          	auipc	a3,0x3
ffffffffc0204348:	71468693          	addi	a3,a3,1812 # ffffffffc0207a58 <default_pmm_manager+0x788>
ffffffffc020434c:	00003617          	auipc	a2,0x3
ffffffffc0204350:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204354:	0a700593          	li	a1,167
ffffffffc0204358:	00004517          	auipc	a0,0x4
ffffffffc020435c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204360:	91afc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204364 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204364:	7139                	addi	sp,sp,-64
ffffffffc0204366:	fc06                	sd	ra,56(sp)
ffffffffc0204368:	f822                	sd	s0,48(sp)
ffffffffc020436a:	f426                	sd	s1,40(sp)
ffffffffc020436c:	f04a                	sd	s2,32(sp)
ffffffffc020436e:	ec4e                	sd	s3,24(sp)
ffffffffc0204370:	e852                	sd	s4,16(sp)
ffffffffc0204372:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204374:	c52d                	beqz	a0,ffffffffc02043de <dup_mmap+0x7a>
ffffffffc0204376:	892a                	mv	s2,a0
ffffffffc0204378:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020437a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020437c:	e595                	bnez	a1,ffffffffc02043a8 <dup_mmap+0x44>
ffffffffc020437e:	a085                	j	ffffffffc02043de <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204380:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0204382:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4ec0>
        vma->vm_end = vm_end;
ffffffffc0204386:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc020438a:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc020438e:	e05ff0ef          	jal	ra,ffffffffc0204192 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204392:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8be8>
ffffffffc0204396:	fe843603          	ld	a2,-24(s0)
ffffffffc020439a:	6c8c                	ld	a1,24(s1)
ffffffffc020439c:	01893503          	ld	a0,24(s2)
ffffffffc02043a0:	4701                	li	a4,0
ffffffffc02043a2:	d21fe0ef          	jal	ra,ffffffffc02030c2 <copy_range>
ffffffffc02043a6:	e105                	bnez	a0,ffffffffc02043c6 <dup_mmap+0x62>
    return listelm->prev;
ffffffffc02043a8:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02043aa:	02848863          	beq	s1,s0,ffffffffc02043da <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043ae:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02043b2:	fe843a83          	ld	s5,-24(s0)
ffffffffc02043b6:	ff043a03          	ld	s4,-16(s0)
ffffffffc02043ba:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043be:	ef0fd0ef          	jal	ra,ffffffffc0201aae <kmalloc>
ffffffffc02043c2:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc02043c4:	fd55                	bnez	a0,ffffffffc0204380 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043c6:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043c8:	70e2                	ld	ra,56(sp)
ffffffffc02043ca:	7442                	ld	s0,48(sp)
ffffffffc02043cc:	74a2                	ld	s1,40(sp)
ffffffffc02043ce:	7902                	ld	s2,32(sp)
ffffffffc02043d0:	69e2                	ld	s3,24(sp)
ffffffffc02043d2:	6a42                	ld	s4,16(sp)
ffffffffc02043d4:	6aa2                	ld	s5,8(sp)
ffffffffc02043d6:	6121                	addi	sp,sp,64
ffffffffc02043d8:	8082                	ret
    return 0;
ffffffffc02043da:	4501                	li	a0,0
ffffffffc02043dc:	b7f5                	j	ffffffffc02043c8 <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc02043de:	00004697          	auipc	a3,0x4
ffffffffc02043e2:	c1a68693          	addi	a3,a3,-998 # ffffffffc0207ff8 <default_pmm_manager+0xd28>
ffffffffc02043e6:	00003617          	auipc	a2,0x3
ffffffffc02043ea:	85260613          	addi	a2,a2,-1966 # ffffffffc0206c38 <commands+0x450>
ffffffffc02043ee:	0c000593          	li	a1,192
ffffffffc02043f2:	00004517          	auipc	a0,0x4
ffffffffc02043f6:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02043fa:	880fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02043fe <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043fe:	1101                	addi	sp,sp,-32
ffffffffc0204400:	ec06                	sd	ra,24(sp)
ffffffffc0204402:	e822                	sd	s0,16(sp)
ffffffffc0204404:	e426                	sd	s1,8(sp)
ffffffffc0204406:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204408:	c531                	beqz	a0,ffffffffc0204454 <exit_mmap+0x56>
ffffffffc020440a:	591c                	lw	a5,48(a0)
ffffffffc020440c:	84aa                	mv	s1,a0
ffffffffc020440e:	e3b9                	bnez	a5,ffffffffc0204454 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0204410:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204412:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204416:	02850663          	beq	a0,s0,ffffffffc0204442 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020441a:	ff043603          	ld	a2,-16(s0)
ffffffffc020441e:	fe843583          	ld	a1,-24(s0)
ffffffffc0204422:	854a                	mv	a0,s2
ffffffffc0204424:	b9bfd0ef          	jal	ra,ffffffffc0201fbe <unmap_range>
ffffffffc0204428:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020442a:	fe8498e3          	bne	s1,s0,ffffffffc020441a <exit_mmap+0x1c>
ffffffffc020442e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0204430:	00848c63          	beq	s1,s0,ffffffffc0204448 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204434:	ff043603          	ld	a2,-16(s0)
ffffffffc0204438:	fe843583          	ld	a1,-24(s0)
ffffffffc020443c:	854a                	mv	a0,s2
ffffffffc020443e:	cc7fd0ef          	jal	ra,ffffffffc0202104 <exit_range>
ffffffffc0204442:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204444:	fe8498e3          	bne	s1,s0,ffffffffc0204434 <exit_mmap+0x36>
    }
}
ffffffffc0204448:	60e2                	ld	ra,24(sp)
ffffffffc020444a:	6442                	ld	s0,16(sp)
ffffffffc020444c:	64a2                	ld	s1,8(sp)
ffffffffc020444e:	6902                	ld	s2,0(sp)
ffffffffc0204450:	6105                	addi	sp,sp,32
ffffffffc0204452:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204454:	00004697          	auipc	a3,0x4
ffffffffc0204458:	bc468693          	addi	a3,a3,-1084 # ffffffffc0208018 <default_pmm_manager+0xd48>
ffffffffc020445c:	00002617          	auipc	a2,0x2
ffffffffc0204460:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204464:	0d600593          	li	a1,214
ffffffffc0204468:	00004517          	auipc	a0,0x4
ffffffffc020446c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204470:	80afc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204474 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204474:	7139                	addi	sp,sp,-64
ffffffffc0204476:	f822                	sd	s0,48(sp)
ffffffffc0204478:	f426                	sd	s1,40(sp)
ffffffffc020447a:	fc06                	sd	ra,56(sp)
ffffffffc020447c:	f04a                	sd	s2,32(sp)
ffffffffc020447e:	ec4e                	sd	s3,24(sp)
ffffffffc0204480:	e852                	sd	s4,16(sp)
ffffffffc0204482:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204484:	c59ff0ef          	jal	ra,ffffffffc02040dc <mm_create>
    assert(mm != NULL);
ffffffffc0204488:	84aa                	mv	s1,a0
ffffffffc020448a:	03200413          	li	s0,50
ffffffffc020448e:	e919                	bnez	a0,ffffffffc02044a4 <vmm_init+0x30>
ffffffffc0204490:	a991                	j	ffffffffc02048e4 <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0204492:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204494:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204496:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc020449a:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020449c:	8526                	mv	a0,s1
ffffffffc020449e:	cf5ff0ef          	jal	ra,ffffffffc0204192 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02044a2:	c80d                	beqz	s0,ffffffffc02044d4 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044a4:	03000513          	li	a0,48
ffffffffc02044a8:	e06fd0ef          	jal	ra,ffffffffc0201aae <kmalloc>
ffffffffc02044ac:	85aa                	mv	a1,a0
ffffffffc02044ae:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc02044b2:	f165                	bnez	a0,ffffffffc0204492 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02044b4:	00003697          	auipc	a3,0x3
ffffffffc02044b8:	5dc68693          	addi	a3,a3,1500 # ffffffffc0207a90 <default_pmm_manager+0x7c0>
ffffffffc02044bc:	00002617          	auipc	a2,0x2
ffffffffc02044c0:	77c60613          	addi	a2,a2,1916 # ffffffffc0206c38 <commands+0x450>
ffffffffc02044c4:	11300593          	li	a1,275
ffffffffc02044c8:	00004517          	auipc	a0,0x4
ffffffffc02044cc:	aa850513          	addi	a0,a0,-1368 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02044d0:	fabfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02044d4:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044d8:	1f900913          	li	s2,505
ffffffffc02044dc:	a819                	j	ffffffffc02044f2 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044de:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044e0:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044e2:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044e6:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044e8:	8526                	mv	a0,s1
ffffffffc02044ea:	ca9ff0ef          	jal	ra,ffffffffc0204192 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044ee:	03240a63          	beq	s0,s2,ffffffffc0204522 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044f2:	03000513          	li	a0,48
ffffffffc02044f6:	db8fd0ef          	jal	ra,ffffffffc0201aae <kmalloc>
ffffffffc02044fa:	85aa                	mv	a1,a0
ffffffffc02044fc:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0204500:	fd79                	bnez	a0,ffffffffc02044de <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204502:	00003697          	auipc	a3,0x3
ffffffffc0204506:	58e68693          	addi	a3,a3,1422 # ffffffffc0207a90 <default_pmm_manager+0x7c0>
ffffffffc020450a:	00002617          	auipc	a2,0x2
ffffffffc020450e:	72e60613          	addi	a2,a2,1838 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204512:	11900593          	li	a1,281
ffffffffc0204516:	00004517          	auipc	a0,0x4
ffffffffc020451a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc020451e:	f5dfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204522:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc0204524:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc0204526:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020452a:	2cf48d63          	beq	s1,a5,ffffffffc0204804 <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020452e:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c53c>
ffffffffc0204532:	ffe70613          	addi	a2,a4,-2
ffffffffc0204536:	24d61763          	bne	a2,a3,ffffffffc0204784 <vmm_init+0x310>
ffffffffc020453a:	ff07b683          	ld	a3,-16(a5)
ffffffffc020453e:	24e69363          	bne	a3,a4,ffffffffc0204784 <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc0204542:	0715                	addi	a4,a4,5
ffffffffc0204544:	679c                	ld	a5,8(a5)
ffffffffc0204546:	feb712e3          	bne	a4,a1,ffffffffc020452a <vmm_init+0xb6>
ffffffffc020454a:	4a1d                	li	s4,7
ffffffffc020454c:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020454e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204552:	85a2                	mv	a1,s0
ffffffffc0204554:	8526                	mv	a0,s1
ffffffffc0204556:	bfdff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc020455a:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc020455c:	30050463          	beqz	a0,ffffffffc0204864 <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204560:	00140593          	addi	a1,s0,1
ffffffffc0204564:	8526                	mv	a0,s1
ffffffffc0204566:	bedff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc020456a:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020456c:	2c050c63          	beqz	a0,ffffffffc0204844 <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204570:	85d2                	mv	a1,s4
ffffffffc0204572:	8526                	mv	a0,s1
ffffffffc0204574:	bdfff0ef          	jal	ra,ffffffffc0204152 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204578:	2a051663          	bnez	a0,ffffffffc0204824 <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020457c:	00340593          	addi	a1,s0,3
ffffffffc0204580:	8526                	mv	a0,s1
ffffffffc0204582:	bd1ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204586:	30051f63          	bnez	a0,ffffffffc02048a4 <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020458a:	00440593          	addi	a1,s0,4
ffffffffc020458e:	8526                	mv	a0,s1
ffffffffc0204590:	bc3ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204594:	2e051863          	bnez	a0,ffffffffc0204884 <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204598:	00893783          	ld	a5,8(s2)
ffffffffc020459c:	20879463          	bne	a5,s0,ffffffffc02047a4 <vmm_init+0x330>
ffffffffc02045a0:	01093783          	ld	a5,16(s2)
ffffffffc02045a4:	20fa1063          	bne	s4,a5,ffffffffc02047a4 <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02045a8:	0089b783          	ld	a5,8(s3)
ffffffffc02045ac:	20879c63          	bne	a5,s0,ffffffffc02047c4 <vmm_init+0x350>
ffffffffc02045b0:	0109b783          	ld	a5,16(s3)
ffffffffc02045b4:	20fa1863          	bne	s4,a5,ffffffffc02047c4 <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045b8:	0415                	addi	s0,s0,5
ffffffffc02045ba:	0a15                	addi	s4,s4,5
ffffffffc02045bc:	f9541be3          	bne	s0,s5,ffffffffc0204552 <vmm_init+0xde>
ffffffffc02045c0:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045c2:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045c4:	85a2                	mv	a1,s0
ffffffffc02045c6:	8526                	mv	a0,s1
ffffffffc02045c8:	b8bff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc02045cc:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc02045d0:	c90d                	beqz	a0,ffffffffc0204602 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045d2:	6914                	ld	a3,16(a0)
ffffffffc02045d4:	6510                	ld	a2,8(a0)
ffffffffc02045d6:	00004517          	auipc	a0,0x4
ffffffffc02045da:	b6250513          	addi	a0,a0,-1182 # ffffffffc0208138 <default_pmm_manager+0xe68>
ffffffffc02045de:	ba3fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045e2:	00004697          	auipc	a3,0x4
ffffffffc02045e6:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0208160 <default_pmm_manager+0xe90>
ffffffffc02045ea:	00002617          	auipc	a2,0x2
ffffffffc02045ee:	64e60613          	addi	a2,a2,1614 # ffffffffc0206c38 <commands+0x450>
ffffffffc02045f2:	13b00593          	li	a1,315
ffffffffc02045f6:	00004517          	auipc	a0,0x4
ffffffffc02045fa:	97a50513          	addi	a0,a0,-1670 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02045fe:	e7dfb0ef          	jal	ra,ffffffffc020047a <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0204602:	147d                	addi	s0,s0,-1
ffffffffc0204604:	fd2410e3          	bne	s0,s2,ffffffffc02045c4 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204608:	8526                	mv	a0,s1
ffffffffc020460a:	c59ff0ef          	jal	ra,ffffffffc0204262 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020460e:	00004517          	auipc	a0,0x4
ffffffffc0204612:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0208178 <default_pmm_manager+0xea8>
ffffffffc0204616:	b6bfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020461a:	f44fd0ef          	jal	ra,ffffffffc0201d5e <nr_free_pages>
ffffffffc020461e:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc0204620:	abdff0ef          	jal	ra,ffffffffc02040dc <mm_create>
ffffffffc0204624:	000ae797          	auipc	a5,0xae
ffffffffc0204628:	44a7be23          	sd	a0,1116(a5) # ffffffffc02b2a80 <check_mm_struct>
ffffffffc020462c:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc020462e:	28050b63          	beqz	a0,ffffffffc02048c4 <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204632:	000ae497          	auipc	s1,0xae
ffffffffc0204636:	40e4b483          	ld	s1,1038(s1) # ffffffffc02b2a40 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc020463a:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020463c:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020463e:	2e079f63          	bnez	a5,ffffffffc020493c <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204642:	03000513          	li	a0,48
ffffffffc0204646:	c68fd0ef          	jal	ra,ffffffffc0201aae <kmalloc>
ffffffffc020464a:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc020464c:	18050c63          	beqz	a0,ffffffffc02047e4 <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc0204650:	002007b7          	lui	a5,0x200
ffffffffc0204654:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0204658:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020465a:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020465c:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204660:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0204662:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0204666:	b2dff0ef          	jal	ra,ffffffffc0204192 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020466a:	10000593          	li	a1,256
ffffffffc020466e:	8522                	mv	a0,s0
ffffffffc0204670:	ae3ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc0204674:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc0204678:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020467c:	2ea99063          	bne	s3,a0,ffffffffc020495c <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0204680:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4eb8>
    for (i = 0; i < 100; i ++) {
ffffffffc0204684:	0785                	addi	a5,a5,1
ffffffffc0204686:	fee79de3          	bne	a5,a4,ffffffffc0204680 <vmm_init+0x20c>
        sum += i;
ffffffffc020468a:	6705                	lui	a4,0x1
ffffffffc020468c:	10000793          	li	a5,256
ffffffffc0204690:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8882>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204694:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0204698:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc020469c:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc020469e:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02046a0:	fec79ce3          	bne	a5,a2,ffffffffc0204698 <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc02046a4:	2e071863          	bnez	a4,ffffffffc0204994 <vmm_init+0x520>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046a8:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02046aa:	000aea97          	auipc	s5,0xae
ffffffffc02046ae:	39ea8a93          	addi	s5,s5,926 # ffffffffc02b2a48 <npage>
ffffffffc02046b2:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046b6:	078a                	slli	a5,a5,0x2
ffffffffc02046b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046ba:	2cc7f163          	bgeu	a5,a2,ffffffffc020497c <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02046be:	00004a17          	auipc	s4,0x4
ffffffffc02046c2:	57aa3a03          	ld	s4,1402(s4) # ffffffffc0208c38 <nbase>
ffffffffc02046c6:	414787b3          	sub	a5,a5,s4
ffffffffc02046ca:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc02046cc:	8799                	srai	a5,a5,0x6
ffffffffc02046ce:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc02046d0:	00c79713          	slli	a4,a5,0xc
ffffffffc02046d4:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02046d6:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02046da:	24c77563          	bgeu	a4,a2,ffffffffc0204924 <vmm_init+0x4b0>
ffffffffc02046de:	000ae997          	auipc	s3,0xae
ffffffffc02046e2:	3829b983          	ld	s3,898(s3) # ffffffffc02b2a60 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046e6:	4581                	li	a1,0
ffffffffc02046e8:	8526                	mv	a0,s1
ffffffffc02046ea:	99b6                	add	s3,s3,a3
ffffffffc02046ec:	cabfd0ef          	jal	ra,ffffffffc0202396 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046f0:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02046f4:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046f8:	078a                	slli	a5,a5,0x2
ffffffffc02046fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046fc:	28e7f063          	bgeu	a5,a4,ffffffffc020497c <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204700:	000ae997          	auipc	s3,0xae
ffffffffc0204704:	35098993          	addi	s3,s3,848 # ffffffffc02b2a50 <pages>
ffffffffc0204708:	0009b503          	ld	a0,0(s3)
ffffffffc020470c:	414787b3          	sub	a5,a5,s4
ffffffffc0204710:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204712:	953e                	add	a0,a0,a5
ffffffffc0204714:	4585                	li	a1,1
ffffffffc0204716:	e08fd0ef          	jal	ra,ffffffffc0201d1e <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020471a:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020471c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204720:	078a                	slli	a5,a5,0x2
ffffffffc0204722:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204724:	24e7fc63          	bgeu	a5,a4,ffffffffc020497c <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204728:	0009b503          	ld	a0,0(s3)
ffffffffc020472c:	414787b3          	sub	a5,a5,s4
ffffffffc0204730:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204732:	4585                	li	a1,1
ffffffffc0204734:	953e                	add	a0,a0,a5
ffffffffc0204736:	de8fd0ef          	jal	ra,ffffffffc0201d1e <free_pages>
    pgdir[0] = 0;
ffffffffc020473a:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc020473e:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc0204742:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc0204744:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0204748:	b1bff0ef          	jal	ra,ffffffffc0204262 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc020474c:	000ae797          	auipc	a5,0xae
ffffffffc0204750:	3207ba23          	sd	zero,820(a5) # ffffffffc02b2a80 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204754:	e0afd0ef          	jal	ra,ffffffffc0201d5e <nr_free_pages>
ffffffffc0204758:	1aa91663          	bne	s2,a0,ffffffffc0204904 <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc020475c:	00004517          	auipc	a0,0x4
ffffffffc0204760:	aac50513          	addi	a0,a0,-1364 # ffffffffc0208208 <default_pmm_manager+0xf38>
ffffffffc0204764:	a1dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0204768:	7442                	ld	s0,48(sp)
ffffffffc020476a:	70e2                	ld	ra,56(sp)
ffffffffc020476c:	74a2                	ld	s1,40(sp)
ffffffffc020476e:	7902                	ld	s2,32(sp)
ffffffffc0204770:	69e2                	ld	s3,24(sp)
ffffffffc0204772:	6a42                	ld	s4,16(sp)
ffffffffc0204774:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204776:	00004517          	auipc	a0,0x4
ffffffffc020477a:	ab250513          	addi	a0,a0,-1358 # ffffffffc0208228 <default_pmm_manager+0xf58>
}
ffffffffc020477e:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204780:	a01fb06f          	j	ffffffffc0200180 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204784:	00004697          	auipc	a3,0x4
ffffffffc0204788:	8cc68693          	addi	a3,a3,-1844 # ffffffffc0208050 <default_pmm_manager+0xd80>
ffffffffc020478c:	00002617          	auipc	a2,0x2
ffffffffc0204790:	4ac60613          	addi	a2,a2,1196 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204794:	12200593          	li	a1,290
ffffffffc0204798:	00003517          	auipc	a0,0x3
ffffffffc020479c:	7d850513          	addi	a0,a0,2008 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02047a0:	cdbfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02047a4:	00004697          	auipc	a3,0x4
ffffffffc02047a8:	93468693          	addi	a3,a3,-1740 # ffffffffc02080d8 <default_pmm_manager+0xe08>
ffffffffc02047ac:	00002617          	auipc	a2,0x2
ffffffffc02047b0:	48c60613          	addi	a2,a2,1164 # ffffffffc0206c38 <commands+0x450>
ffffffffc02047b4:	13200593          	li	a1,306
ffffffffc02047b8:	00003517          	auipc	a0,0x3
ffffffffc02047bc:	7b850513          	addi	a0,a0,1976 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02047c0:	cbbfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047c4:	00004697          	auipc	a3,0x4
ffffffffc02047c8:	94468693          	addi	a3,a3,-1724 # ffffffffc0208108 <default_pmm_manager+0xe38>
ffffffffc02047cc:	00002617          	auipc	a2,0x2
ffffffffc02047d0:	46c60613          	addi	a2,a2,1132 # ffffffffc0206c38 <commands+0x450>
ffffffffc02047d4:	13300593          	li	a1,307
ffffffffc02047d8:	00003517          	auipc	a0,0x3
ffffffffc02047dc:	79850513          	addi	a0,a0,1944 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02047e0:	c9bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(vma != NULL);
ffffffffc02047e4:	00003697          	auipc	a3,0x3
ffffffffc02047e8:	2ac68693          	addi	a3,a3,684 # ffffffffc0207a90 <default_pmm_manager+0x7c0>
ffffffffc02047ec:	00002617          	auipc	a2,0x2
ffffffffc02047f0:	44c60613          	addi	a2,a2,1100 # ffffffffc0206c38 <commands+0x450>
ffffffffc02047f4:	15200593          	li	a1,338
ffffffffc02047f8:	00003517          	auipc	a0,0x3
ffffffffc02047fc:	77850513          	addi	a0,a0,1912 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204800:	c7bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204804:	00004697          	auipc	a3,0x4
ffffffffc0204808:	83468693          	addi	a3,a3,-1996 # ffffffffc0208038 <default_pmm_manager+0xd68>
ffffffffc020480c:	00002617          	auipc	a2,0x2
ffffffffc0204810:	42c60613          	addi	a2,a2,1068 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204814:	12000593          	li	a1,288
ffffffffc0204818:	00003517          	auipc	a0,0x3
ffffffffc020481c:	75850513          	addi	a0,a0,1880 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204820:	c5bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma3 == NULL);
ffffffffc0204824:	00004697          	auipc	a3,0x4
ffffffffc0204828:	88468693          	addi	a3,a3,-1916 # ffffffffc02080a8 <default_pmm_manager+0xdd8>
ffffffffc020482c:	00002617          	auipc	a2,0x2
ffffffffc0204830:	40c60613          	addi	a2,a2,1036 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204834:	12c00593          	li	a1,300
ffffffffc0204838:	00003517          	auipc	a0,0x3
ffffffffc020483c:	73850513          	addi	a0,a0,1848 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204840:	c3bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2 != NULL);
ffffffffc0204844:	00004697          	auipc	a3,0x4
ffffffffc0204848:	85468693          	addi	a3,a3,-1964 # ffffffffc0208098 <default_pmm_manager+0xdc8>
ffffffffc020484c:	00002617          	auipc	a2,0x2
ffffffffc0204850:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204854:	12a00593          	li	a1,298
ffffffffc0204858:	00003517          	auipc	a0,0x3
ffffffffc020485c:	71850513          	addi	a0,a0,1816 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204860:	c1bfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1 != NULL);
ffffffffc0204864:	00004697          	auipc	a3,0x4
ffffffffc0204868:	82468693          	addi	a3,a3,-2012 # ffffffffc0208088 <default_pmm_manager+0xdb8>
ffffffffc020486c:	00002617          	auipc	a2,0x2
ffffffffc0204870:	3cc60613          	addi	a2,a2,972 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204874:	12800593          	li	a1,296
ffffffffc0204878:	00003517          	auipc	a0,0x3
ffffffffc020487c:	6f850513          	addi	a0,a0,1784 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204880:	bfbfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma5 == NULL);
ffffffffc0204884:	00004697          	auipc	a3,0x4
ffffffffc0204888:	84468693          	addi	a3,a3,-1980 # ffffffffc02080c8 <default_pmm_manager+0xdf8>
ffffffffc020488c:	00002617          	auipc	a2,0x2
ffffffffc0204890:	3ac60613          	addi	a2,a2,940 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204894:	13000593          	li	a1,304
ffffffffc0204898:	00003517          	auipc	a0,0x3
ffffffffc020489c:	6d850513          	addi	a0,a0,1752 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02048a0:	bdbfb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma4 == NULL);
ffffffffc02048a4:	00004697          	auipc	a3,0x4
ffffffffc02048a8:	81468693          	addi	a3,a3,-2028 # ffffffffc02080b8 <default_pmm_manager+0xde8>
ffffffffc02048ac:	00002617          	auipc	a2,0x2
ffffffffc02048b0:	38c60613          	addi	a2,a2,908 # ffffffffc0206c38 <commands+0x450>
ffffffffc02048b4:	12e00593          	li	a1,302
ffffffffc02048b8:	00003517          	auipc	a0,0x3
ffffffffc02048bc:	6b850513          	addi	a0,a0,1720 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02048c0:	bbbfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02048c4:	00004697          	auipc	a3,0x4
ffffffffc02048c8:	8d468693          	addi	a3,a3,-1836 # ffffffffc0208198 <default_pmm_manager+0xec8>
ffffffffc02048cc:	00002617          	auipc	a2,0x2
ffffffffc02048d0:	36c60613          	addi	a2,a2,876 # ffffffffc0206c38 <commands+0x450>
ffffffffc02048d4:	14b00593          	li	a1,331
ffffffffc02048d8:	00003517          	auipc	a0,0x3
ffffffffc02048dc:	69850513          	addi	a0,a0,1688 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02048e0:	b9bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(mm != NULL);
ffffffffc02048e4:	00003697          	auipc	a3,0x3
ffffffffc02048e8:	17468693          	addi	a3,a3,372 # ffffffffc0207a58 <default_pmm_manager+0x788>
ffffffffc02048ec:	00002617          	auipc	a2,0x2
ffffffffc02048f0:	34c60613          	addi	a2,a2,844 # ffffffffc0206c38 <commands+0x450>
ffffffffc02048f4:	10c00593          	li	a1,268
ffffffffc02048f8:	00003517          	auipc	a0,0x3
ffffffffc02048fc:	67850513          	addi	a0,a0,1656 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204900:	b7bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204904:	00004697          	auipc	a3,0x4
ffffffffc0204908:	8dc68693          	addi	a3,a3,-1828 # ffffffffc02081e0 <default_pmm_manager+0xf10>
ffffffffc020490c:	00002617          	auipc	a2,0x2
ffffffffc0204910:	32c60613          	addi	a2,a2,812 # ffffffffc0206c38 <commands+0x450>
ffffffffc0204914:	17000593          	li	a1,368
ffffffffc0204918:	00003517          	auipc	a0,0x3
ffffffffc020491c:	65850513          	addi	a0,a0,1624 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204920:	b5bfb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204924:	00003617          	auipc	a2,0x3
ffffffffc0204928:	9e460613          	addi	a2,a2,-1564 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc020492c:	06900593          	li	a1,105
ffffffffc0204930:	00003517          	auipc	a0,0x3
ffffffffc0204934:	a0050513          	addi	a0,a0,-1536 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0204938:	b43fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir[0] == 0);
ffffffffc020493c:	00003697          	auipc	a3,0x3
ffffffffc0204940:	14468693          	addi	a3,a3,324 # ffffffffc0207a80 <default_pmm_manager+0x7b0>
ffffffffc0204944:	00002617          	auipc	a2,0x2
ffffffffc0204948:	2f460613          	addi	a2,a2,756 # ffffffffc0206c38 <commands+0x450>
ffffffffc020494c:	14f00593          	li	a1,335
ffffffffc0204950:	00003517          	auipc	a0,0x3
ffffffffc0204954:	62050513          	addi	a0,a0,1568 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204958:	b23fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020495c:	00004697          	auipc	a3,0x4
ffffffffc0204960:	85468693          	addi	a3,a3,-1964 # ffffffffc02081b0 <default_pmm_manager+0xee0>
ffffffffc0204964:	00002617          	auipc	a2,0x2
ffffffffc0204968:	2d460613          	addi	a2,a2,724 # ffffffffc0206c38 <commands+0x450>
ffffffffc020496c:	15700593          	li	a1,343
ffffffffc0204970:	00003517          	auipc	a0,0x3
ffffffffc0204974:	60050513          	addi	a0,a0,1536 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc0204978:	b03fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020497c:	00003617          	auipc	a2,0x3
ffffffffc0204980:	a5c60613          	addi	a2,a2,-1444 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc0204984:	06200593          	li	a1,98
ffffffffc0204988:	00003517          	auipc	a0,0x3
ffffffffc020498c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0204990:	aebfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(sum == 0);
ffffffffc0204994:	00004697          	auipc	a3,0x4
ffffffffc0204998:	83c68693          	addi	a3,a3,-1988 # ffffffffc02081d0 <default_pmm_manager+0xf00>
ffffffffc020499c:	00002617          	auipc	a2,0x2
ffffffffc02049a0:	29c60613          	addi	a2,a2,668 # ffffffffc0206c38 <commands+0x450>
ffffffffc02049a4:	16300593          	li	a1,355
ffffffffc02049a8:	00003517          	auipc	a0,0x3
ffffffffc02049ac:	5c850513          	addi	a0,a0,1480 # ffffffffc0207f70 <default_pmm_manager+0xca0>
ffffffffc02049b0:	acbfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02049b4 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049b4:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049b6:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02049b8:	f022                	sd	s0,32(sp)
ffffffffc02049ba:	ec26                	sd	s1,24(sp)
ffffffffc02049bc:	f406                	sd	ra,40(sp)
ffffffffc02049be:	e84a                	sd	s2,16(sp)
ffffffffc02049c0:	8432                	mv	s0,a2
ffffffffc02049c2:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049c4:	f8eff0ef          	jal	ra,ffffffffc0204152 <find_vma>

    pgfault_num++;
ffffffffc02049c8:	000ae797          	auipc	a5,0xae
ffffffffc02049cc:	0c07a783          	lw	a5,192(a5) # ffffffffc02b2a88 <pgfault_num>
ffffffffc02049d0:	2785                	addiw	a5,a5,1
ffffffffc02049d2:	000ae717          	auipc	a4,0xae
ffffffffc02049d6:	0af72b23          	sw	a5,182(a4) # ffffffffc02b2a88 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02049da:	c159                	beqz	a0,ffffffffc0204a60 <do_pgfault+0xac>
ffffffffc02049dc:	651c                	ld	a5,8(a0)
ffffffffc02049de:	08f46163          	bltu	s0,a5,ffffffffc0204a60 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049e2:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049e4:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049e6:	8b89                	andi	a5,a5,2
ffffffffc02049e8:	ebb1                	bnez	a5,ffffffffc0204a3c <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049ea:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02049ec:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049ee:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02049f0:	85a2                	mv	a1,s0
ffffffffc02049f2:	4605                	li	a2,1
ffffffffc02049f4:	ba4fd0ef          	jal	ra,ffffffffc0201d98 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02049f8:	610c                	ld	a1,0(a0)
ffffffffc02049fa:	c1b9                	beqz	a1,ffffffffc0204a40 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02049fc:	000ae797          	auipc	a5,0xae
ffffffffc0204a00:	07c7a783          	lw	a5,124(a5) # ffffffffc02b2a78 <swap_init_ok>
ffffffffc0204a04:	c7bd                	beqz	a5,ffffffffc0204a72 <do_pgfault+0xbe>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            swap_in(mm, addr, &page);  
ffffffffc0204a06:	85a2                	mv	a1,s0
ffffffffc0204a08:	0030                	addi	a2,sp,8
ffffffffc0204a0a:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204a0c:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);  
ffffffffc0204a0e:	a32ff0ef          	jal	ra,ffffffffc0203c40 <swap_in>
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204a12:	65a2                	ld	a1,8(sp)
ffffffffc0204a14:	6c88                	ld	a0,24(s1)
ffffffffc0204a16:	86ca                	mv	a3,s2
ffffffffc0204a18:	8622                	mv	a2,s0
ffffffffc0204a1a:	a19fd0ef          	jal	ra,ffffffffc0202432 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a1e:	6622                	ld	a2,8(sp)
ffffffffc0204a20:	4685                	li	a3,1
ffffffffc0204a22:	85a2                	mv	a1,s0
ffffffffc0204a24:	8526                	mv	a0,s1
ffffffffc0204a26:	8faff0ef          	jal	ra,ffffffffc0203b20 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a2a:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0204a2c:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0204a2e:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0204a30:	70a2                	ld	ra,40(sp)
ffffffffc0204a32:	7402                	ld	s0,32(sp)
ffffffffc0204a34:	64e2                	ld	s1,24(sp)
ffffffffc0204a36:	6942                	ld	s2,16(sp)
ffffffffc0204a38:	6145                	addi	sp,sp,48
ffffffffc0204a3a:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0204a3c:	4959                	li	s2,22
ffffffffc0204a3e:	b775                	j	ffffffffc02049ea <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a40:	6c88                	ld	a0,24(s1)
ffffffffc0204a42:	864a                	mv	a2,s2
ffffffffc0204a44:	85a2                	mv	a1,s0
ffffffffc0204a46:	8b3fe0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc0204a4a:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0204a4c:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a4e:	f3ed                	bnez	a5,ffffffffc0204a30 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a50:	00004517          	auipc	a0,0x4
ffffffffc0204a54:	82050513          	addi	a0,a0,-2016 # ffffffffc0208270 <default_pmm_manager+0xfa0>
ffffffffc0204a58:	f28fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a5c:	5571                	li	a0,-4
            goto failed;
ffffffffc0204a5e:	bfc9                	j	ffffffffc0204a30 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a60:	85a2                	mv	a1,s0
ffffffffc0204a62:	00003517          	auipc	a0,0x3
ffffffffc0204a66:	7de50513          	addi	a0,a0,2014 # ffffffffc0208240 <default_pmm_manager+0xf70>
ffffffffc0204a6a:	f16fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a6e:	5575                	li	a0,-3
        goto failed;
ffffffffc0204a70:	b7c1                	j	ffffffffc0204a30 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204a72:	00004517          	auipc	a0,0x4
ffffffffc0204a76:	82650513          	addi	a0,a0,-2010 # ffffffffc0208298 <default_pmm_manager+0xfc8>
ffffffffc0204a7a:	f06fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a7e:	5571                	li	a0,-4
            goto failed;
ffffffffc0204a80:	bf45                	j	ffffffffc0204a30 <do_pgfault+0x7c>

ffffffffc0204a82 <user_mem_check>:


bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204a82:	7179                	addi	sp,sp,-48
ffffffffc0204a84:	f022                	sd	s0,32(sp)
ffffffffc0204a86:	f406                	sd	ra,40(sp)
ffffffffc0204a88:	ec26                	sd	s1,24(sp)
ffffffffc0204a8a:	e84a                	sd	s2,16(sp)
ffffffffc0204a8c:	e44e                	sd	s3,8(sp)
ffffffffc0204a8e:	e052                	sd	s4,0(sp)
ffffffffc0204a90:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204a92:	c135                	beqz	a0,ffffffffc0204af6 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204a94:	002007b7          	lui	a5,0x200
ffffffffc0204a98:	04f5e663          	bltu	a1,a5,ffffffffc0204ae4 <user_mem_check+0x62>
ffffffffc0204a9c:	00c584b3          	add	s1,a1,a2
ffffffffc0204aa0:	0495f263          	bgeu	a1,s1,ffffffffc0204ae4 <user_mem_check+0x62>
ffffffffc0204aa4:	4785                	li	a5,1
ffffffffc0204aa6:	07fe                	slli	a5,a5,0x1f
ffffffffc0204aa8:	0297ee63          	bltu	a5,s1,ffffffffc0204ae4 <user_mem_check+0x62>
ffffffffc0204aac:	892a                	mv	s2,a0
ffffffffc0204aae:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ab0:	6a05                	lui	s4,0x1
ffffffffc0204ab2:	a821                	j	ffffffffc0204aca <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ab4:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ab8:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204aba:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204abc:	c685                	beqz	a3,ffffffffc0204ae4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204abe:	c399                	beqz	a5,ffffffffc0204ac4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ac0:	02e46263          	bltu	s0,a4,ffffffffc0204ae4 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204ac4:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204ac6:	04947663          	bgeu	s0,s1,ffffffffc0204b12 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204aca:	85a2                	mv	a1,s0
ffffffffc0204acc:	854a                	mv	a0,s2
ffffffffc0204ace:	e84ff0ef          	jal	ra,ffffffffc0204152 <find_vma>
ffffffffc0204ad2:	c909                	beqz	a0,ffffffffc0204ae4 <user_mem_check+0x62>
ffffffffc0204ad4:	6518                	ld	a4,8(a0)
ffffffffc0204ad6:	00e46763          	bltu	s0,a4,ffffffffc0204ae4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ada:	4d1c                	lw	a5,24(a0)
ffffffffc0204adc:	fc099ce3          	bnez	s3,ffffffffc0204ab4 <user_mem_check+0x32>
ffffffffc0204ae0:	8b85                	andi	a5,a5,1
ffffffffc0204ae2:	f3ed                	bnez	a5,ffffffffc0204ac4 <user_mem_check+0x42>
            return 0;
ffffffffc0204ae4:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204ae6:	70a2                	ld	ra,40(sp)
ffffffffc0204ae8:	7402                	ld	s0,32(sp)
ffffffffc0204aea:	64e2                	ld	s1,24(sp)
ffffffffc0204aec:	6942                	ld	s2,16(sp)
ffffffffc0204aee:	69a2                	ld	s3,8(sp)
ffffffffc0204af0:	6a02                	ld	s4,0(sp)
ffffffffc0204af2:	6145                	addi	sp,sp,48
ffffffffc0204af4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204af6:	c02007b7          	lui	a5,0xc0200
ffffffffc0204afa:	4501                	li	a0,0
ffffffffc0204afc:	fef5e5e3          	bltu	a1,a5,ffffffffc0204ae6 <user_mem_check+0x64>
ffffffffc0204b00:	962e                	add	a2,a2,a1
ffffffffc0204b02:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204ae6 <user_mem_check+0x64>
ffffffffc0204b06:	c8000537          	lui	a0,0xc8000
ffffffffc0204b0a:	0505                	addi	a0,a0,1
ffffffffc0204b0c:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b10:	bfd9                	j	ffffffffc0204ae6 <user_mem_check+0x64>
        return 1;
ffffffffc0204b12:	4505                	li	a0,1
ffffffffc0204b14:	bfc9                	j	ffffffffc0204ae6 <user_mem_check+0x64>

ffffffffc0204b16 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b16:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b18:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b1a:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b1c:	ad1fb0ef          	jal	ra,ffffffffc02005ec <ide_device_valid>
ffffffffc0204b20:	cd01                	beqz	a0,ffffffffc0204b38 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b22:	4505                	li	a0,1
ffffffffc0204b24:	acffb0ef          	jal	ra,ffffffffc02005f2 <ide_device_size>
}
ffffffffc0204b28:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b2a:	810d                	srli	a0,a0,0x3
ffffffffc0204b2c:	000ae797          	auipc	a5,0xae
ffffffffc0204b30:	f2a7be23          	sd	a0,-196(a5) # ffffffffc02b2a68 <max_swap_offset>
}
ffffffffc0204b34:	0141                	addi	sp,sp,16
ffffffffc0204b36:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b38:	00003617          	auipc	a2,0x3
ffffffffc0204b3c:	78860613          	addi	a2,a2,1928 # ffffffffc02082c0 <default_pmm_manager+0xff0>
ffffffffc0204b40:	45b5                	li	a1,13
ffffffffc0204b42:	00003517          	auipc	a0,0x3
ffffffffc0204b46:	79e50513          	addi	a0,a0,1950 # ffffffffc02082e0 <default_pmm_manager+0x1010>
ffffffffc0204b4a:	931fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204b4e <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b4e:	1141                	addi	sp,sp,-16
ffffffffc0204b50:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b52:	00855793          	srli	a5,a0,0x8
ffffffffc0204b56:	cbb1                	beqz	a5,ffffffffc0204baa <swapfs_read+0x5c>
ffffffffc0204b58:	000ae717          	auipc	a4,0xae
ffffffffc0204b5c:	f1073703          	ld	a4,-240(a4) # ffffffffc02b2a68 <max_swap_offset>
ffffffffc0204b60:	04e7f563          	bgeu	a5,a4,ffffffffc0204baa <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204b64:	000ae617          	auipc	a2,0xae
ffffffffc0204b68:	eec63603          	ld	a2,-276(a2) # ffffffffc02b2a50 <pages>
ffffffffc0204b6c:	8d91                	sub	a1,a1,a2
ffffffffc0204b6e:	4065d613          	srai	a2,a1,0x6
ffffffffc0204b72:	00004717          	auipc	a4,0x4
ffffffffc0204b76:	0c673703          	ld	a4,198(a4) # ffffffffc0208c38 <nbase>
ffffffffc0204b7a:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204b7c:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b80:	8331                	srli	a4,a4,0xc
ffffffffc0204b82:	000ae697          	auipc	a3,0xae
ffffffffc0204b86:	ec66b683          	ld	a3,-314(a3) # ffffffffc02b2a48 <npage>
ffffffffc0204b8a:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b8e:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b90:	02d77963          	bgeu	a4,a3,ffffffffc0204bc2 <swapfs_read+0x74>
}
ffffffffc0204b94:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b96:	000ae797          	auipc	a5,0xae
ffffffffc0204b9a:	eca7b783          	ld	a5,-310(a5) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0204b9e:	46a1                	li	a3,8
ffffffffc0204ba0:	963e                	add	a2,a2,a5
ffffffffc0204ba2:	4505                	li	a0,1
}
ffffffffc0204ba4:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ba6:	a53fb06f          	j	ffffffffc02005f8 <ide_read_secs>
ffffffffc0204baa:	86aa                	mv	a3,a0
ffffffffc0204bac:	00003617          	auipc	a2,0x3
ffffffffc0204bb0:	74c60613          	addi	a2,a2,1868 # ffffffffc02082f8 <default_pmm_manager+0x1028>
ffffffffc0204bb4:	45d1                	li	a1,20
ffffffffc0204bb6:	00003517          	auipc	a0,0x3
ffffffffc0204bba:	72a50513          	addi	a0,a0,1834 # ffffffffc02082e0 <default_pmm_manager+0x1010>
ffffffffc0204bbe:	8bdfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204bc2:	86b2                	mv	a3,a2
ffffffffc0204bc4:	06900593          	li	a1,105
ffffffffc0204bc8:	00002617          	auipc	a2,0x2
ffffffffc0204bcc:	74060613          	addi	a2,a2,1856 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0204bd0:	00002517          	auipc	a0,0x2
ffffffffc0204bd4:	76050513          	addi	a0,a0,1888 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0204bd8:	8a3fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204bdc <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204bdc:	1141                	addi	sp,sp,-16
ffffffffc0204bde:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204be0:	00855793          	srli	a5,a0,0x8
ffffffffc0204be4:	cbb1                	beqz	a5,ffffffffc0204c38 <swapfs_write+0x5c>
ffffffffc0204be6:	000ae717          	auipc	a4,0xae
ffffffffc0204bea:	e8273703          	ld	a4,-382(a4) # ffffffffc02b2a68 <max_swap_offset>
ffffffffc0204bee:	04e7f563          	bgeu	a5,a4,ffffffffc0204c38 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204bf2:	000ae617          	auipc	a2,0xae
ffffffffc0204bf6:	e5e63603          	ld	a2,-418(a2) # ffffffffc02b2a50 <pages>
ffffffffc0204bfa:	8d91                	sub	a1,a1,a2
ffffffffc0204bfc:	4065d613          	srai	a2,a1,0x6
ffffffffc0204c00:	00004717          	auipc	a4,0x4
ffffffffc0204c04:	03873703          	ld	a4,56(a4) # ffffffffc0208c38 <nbase>
ffffffffc0204c08:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204c0a:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c0e:	8331                	srli	a4,a4,0xc
ffffffffc0204c10:	000ae697          	auipc	a3,0xae
ffffffffc0204c14:	e386b683          	ld	a3,-456(a3) # ffffffffc02b2a48 <npage>
ffffffffc0204c18:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c1c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c1e:	02d77963          	bgeu	a4,a3,ffffffffc0204c50 <swapfs_write+0x74>
}
ffffffffc0204c22:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c24:	000ae797          	auipc	a5,0xae
ffffffffc0204c28:	e3c7b783          	ld	a5,-452(a5) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0204c2c:	46a1                	li	a3,8
ffffffffc0204c2e:	963e                	add	a2,a2,a5
ffffffffc0204c30:	4505                	li	a0,1
}
ffffffffc0204c32:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c34:	9e9fb06f          	j	ffffffffc020061c <ide_write_secs>
ffffffffc0204c38:	86aa                	mv	a3,a0
ffffffffc0204c3a:	00003617          	auipc	a2,0x3
ffffffffc0204c3e:	6be60613          	addi	a2,a2,1726 # ffffffffc02082f8 <default_pmm_manager+0x1028>
ffffffffc0204c42:	45e5                	li	a1,25
ffffffffc0204c44:	00003517          	auipc	a0,0x3
ffffffffc0204c48:	69c50513          	addi	a0,a0,1692 # ffffffffc02082e0 <default_pmm_manager+0x1010>
ffffffffc0204c4c:	82ffb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204c50:	86b2                	mv	a3,a2
ffffffffc0204c52:	06900593          	li	a1,105
ffffffffc0204c56:	00002617          	auipc	a2,0x2
ffffffffc0204c5a:	6b260613          	addi	a2,a2,1714 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0204c5e:	00002517          	auipc	a0,0x2
ffffffffc0204c62:	6d250513          	addi	a0,a0,1746 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0204c66:	815fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204c6a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c6a:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c6c:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c6e:	63e000ef          	jal	ra,ffffffffc02052ac <do_exit>

ffffffffc0204c72 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204c72:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c74:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204c78:	e022                	sd	s0,0(sp)
ffffffffc0204c7a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c7c:	e33fc0ef          	jal	ra,ffffffffc0201aae <kmalloc>
ffffffffc0204c80:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204c82:	c931                	beqz	a0,ffffffffc0204cd6 <alloc_proc+0x64>
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        proc->state = PROC_UNINIT;                           // 设置进程状态为未初始化
        proc->pid = -1;                                      // 设置进程ID为-1（还未分配）
        proc->cr3 = boot_cr3;                                // 设置CR3寄存器的值（页目录基址）
ffffffffc0204c84:	000ae797          	auipc	a5,0xae
ffffffffc0204c88:	db47b783          	ld	a5,-588(a5) # ffffffffc02b2a38 <boot_cr3>
ffffffffc0204c8c:	f55c                	sd	a5,168(a0)
        proc->state = PROC_UNINIT;                           // 设置进程状态为未初始化
ffffffffc0204c8e:	57fd                	li	a5,-1
ffffffffc0204c90:	1782                	slli	a5,a5,0x20
ffffffffc0204c92:	e11c                	sd	a5,0(a0)
        proc->runs = 0;                                      // 设置进程运行次数为0
        proc->kstack = 0;                                    // 设置内核栈地址为0（还未分配）
        proc->need_resched = 0;                              // 设置不需要重新调度
        proc->parent = NULL;                                 // 设置父进程为空
        proc->mm = NULL;                                     // 设置内存管理字段为空
        memset(&(proc->context), 0, sizeof(struct context)); // 初始化上下文信息为0
ffffffffc0204c94:	07000613          	li	a2,112
ffffffffc0204c98:	4581                	li	a1,0
        proc->runs = 0;                                      // 设置进程运行次数为0
ffffffffc0204c9a:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                                    // 设置内核栈地址为0（还未分配）
ffffffffc0204c9e:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;                              // 设置不需要重新调度
ffffffffc0204ca2:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;                                 // 设置父进程为空
ffffffffc0204ca6:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                                     // 设置内存管理字段为空
ffffffffc0204caa:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context)); // 初始化上下文信息为0
ffffffffc0204cae:	03050513          	addi	a0,a0,48
ffffffffc0204cb2:	0a1010ef          	jal	ra,ffffffffc0206552 <memset>
        proc->tf = NULL;                                     // 设置trapframe为空
        proc->flags = 0;                                     // 设置进程标志为0
        memset(proc->name, 0, PROC_NAME_LEN);                // 初始化进程名为0
ffffffffc0204cb6:	463d                	li	a2,15
        proc->tf = NULL;                                     // 设置trapframe为空
ffffffffc0204cb8:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;                                     // 设置进程标志为0
ffffffffc0204cbc:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN);                // 初始化进程名为0
ffffffffc0204cc0:	4581                	li	a1,0
ffffffffc0204cc2:	0b440513          	addi	a0,s0,180
ffffffffc0204cc6:	08d010ef          	jal	ra,ffffffffc0206552 <memset>
        proc->cptr = NULL; // Child Pointer 表示当前进程的子进程
ffffffffc0204cca:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL; // Older Sibling Pointer 表示当前进程的上一个兄弟进程
ffffffffc0204cce:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL; // Younger Sibling Pointer 表示当前进程的下一个兄弟进程
ffffffffc0204cd2:	0e043c23          	sd	zero,248(s0)

    }
    return proc;
}
ffffffffc0204cd6:	60a2                	ld	ra,8(sp)
ffffffffc0204cd8:	8522                	mv	a0,s0
ffffffffc0204cda:	6402                	ld	s0,0(sp)
ffffffffc0204cdc:	0141                	addi	sp,sp,16
ffffffffc0204cde:	8082                	ret

ffffffffc0204ce0 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204ce0:	000ae797          	auipc	a5,0xae
ffffffffc0204ce4:	db07b783          	ld	a5,-592(a5) # ffffffffc02b2a90 <current>
ffffffffc0204ce8:	73c8                	ld	a0,160(a5)
ffffffffc0204cea:	838fc06f          	j	ffffffffc0200d22 <forkrets>

ffffffffc0204cee <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204cee:	000ae797          	auipc	a5,0xae
ffffffffc0204cf2:	da27b783          	ld	a5,-606(a5) # ffffffffc02b2a90 <current>
ffffffffc0204cf6:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204cf8:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204cfa:	00003617          	auipc	a2,0x3
ffffffffc0204cfe:	61e60613          	addi	a2,a2,1566 # ffffffffc0208318 <default_pmm_manager+0x1048>
ffffffffc0204d02:	00003517          	auipc	a0,0x3
ffffffffc0204d06:	62650513          	addi	a0,a0,1574 # ffffffffc0208328 <default_pmm_manager+0x1058>
user_main(void *arg) {
ffffffffc0204d0a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d0c:	c74fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0204d10:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204d14:	c8078793          	addi	a5,a5,-896 # a990 <_binary_obj___user_forktest_out_size>
ffffffffc0204d18:	e43e                	sd	a5,8(sp)
ffffffffc0204d1a:	00003517          	auipc	a0,0x3
ffffffffc0204d1e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0208318 <default_pmm_manager+0x1048>
ffffffffc0204d22:	00046797          	auipc	a5,0x46
ffffffffc0204d26:	ace78793          	addi	a5,a5,-1330 # ffffffffc024a7f0 <_binary_obj___user_forktest_out_start>
ffffffffc0204d2a:	f03e                	sd	a5,32(sp)
ffffffffc0204d2c:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d2e:	e802                	sd	zero,16(sp)
ffffffffc0204d30:	7a6010ef          	jal	ra,ffffffffc02064d6 <strlen>
ffffffffc0204d34:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d36:	4511                	li	a0,4
ffffffffc0204d38:	55a2                	lw	a1,40(sp)
ffffffffc0204d3a:	4662                	lw	a2,24(sp)
ffffffffc0204d3c:	5682                	lw	a3,32(sp)
ffffffffc0204d3e:	4722                	lw	a4,8(sp)
ffffffffc0204d40:	48a9                	li	a7,10
ffffffffc0204d42:	9002                	ebreak
ffffffffc0204d44:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204d46:	65c2                	ld	a1,16(sp)
ffffffffc0204d48:	00003517          	auipc	a0,0x3
ffffffffc0204d4c:	60850513          	addi	a0,a0,1544 # ffffffffc0208350 <default_pmm_manager+0x1080>
ffffffffc0204d50:	c30fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204d54:	00003617          	auipc	a2,0x3
ffffffffc0204d58:	60c60613          	addi	a2,a2,1548 # ffffffffc0208360 <default_pmm_manager+0x1090>
ffffffffc0204d5c:	34600593          	li	a1,838
ffffffffc0204d60:	00003517          	auipc	a0,0x3
ffffffffc0204d64:	62050513          	addi	a0,a0,1568 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0204d68:	f12fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204d6c <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204d6c:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204d6e:	1141                	addi	sp,sp,-16
ffffffffc0204d70:	e406                	sd	ra,8(sp)
ffffffffc0204d72:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d76:	02f6ee63          	bltu	a3,a5,ffffffffc0204db2 <put_pgdir+0x46>
ffffffffc0204d7a:	000ae517          	auipc	a0,0xae
ffffffffc0204d7e:	ce653503          	ld	a0,-794(a0) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0204d82:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204d84:	82b1                	srli	a3,a3,0xc
ffffffffc0204d86:	000ae797          	auipc	a5,0xae
ffffffffc0204d8a:	cc27b783          	ld	a5,-830(a5) # ffffffffc02b2a48 <npage>
ffffffffc0204d8e:	02f6fe63          	bgeu	a3,a5,ffffffffc0204dca <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204d92:	00004517          	auipc	a0,0x4
ffffffffc0204d96:	ea653503          	ld	a0,-346(a0) # ffffffffc0208c38 <nbase>
}
ffffffffc0204d9a:	60a2                	ld	ra,8(sp)
ffffffffc0204d9c:	8e89                	sub	a3,a3,a0
ffffffffc0204d9e:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204da0:	000ae517          	auipc	a0,0xae
ffffffffc0204da4:	cb053503          	ld	a0,-848(a0) # ffffffffc02b2a50 <pages>
ffffffffc0204da8:	4585                	li	a1,1
ffffffffc0204daa:	9536                	add	a0,a0,a3
}
ffffffffc0204dac:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204dae:	f71fc06f          	j	ffffffffc0201d1e <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204db2:	00002617          	auipc	a2,0x2
ffffffffc0204db6:	5fe60613          	addi	a2,a2,1534 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc0204dba:	06e00593          	li	a1,110
ffffffffc0204dbe:	00002517          	auipc	a0,0x2
ffffffffc0204dc2:	57250513          	addi	a0,a0,1394 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0204dc6:	eb4fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204dca:	00002617          	auipc	a2,0x2
ffffffffc0204dce:	60e60613          	addi	a2,a2,1550 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc0204dd2:	06200593          	li	a1,98
ffffffffc0204dd6:	00002517          	auipc	a0,0x2
ffffffffc0204dda:	55a50513          	addi	a0,a0,1370 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0204dde:	e9cfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204de2 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204de2:	7179                	addi	sp,sp,-48
ffffffffc0204de4:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204de6:	000ae917          	auipc	s2,0xae
ffffffffc0204dea:	caa90913          	addi	s2,s2,-854 # ffffffffc02b2a90 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204dee:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204df0:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204df4:	f406                	sd	ra,40(sp)
ffffffffc0204df6:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204df8:	02a48863          	beq	s1,a0,ffffffffc0204e28 <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204dfc:	100027f3          	csrr	a5,sstatus
ffffffffc0204e00:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204e02:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204e04:	ef9d                	bnez	a5,ffffffffc0204e42 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204e06:	755c                	ld	a5,168(a0)
ffffffffc0204e08:	577d                	li	a4,-1
ffffffffc0204e0a:	177e                	slli	a4,a4,0x3f
ffffffffc0204e0c:	83b1                	srli	a5,a5,0xc
              current = proc;
ffffffffc0204e0e:	00a93023          	sd	a0,0(s2)
ffffffffc0204e12:	8fd9                	or	a5,a5,a4
ffffffffc0204e14:	18079073          	csrw	satp,a5
              switch_to(&(prev->context), &(next->context));
ffffffffc0204e18:	03050593          	addi	a1,a0,48
ffffffffc0204e1c:	03048513          	addi	a0,s1,48
ffffffffc0204e20:	05c010ef          	jal	ra,ffffffffc0205e7c <switch_to>
    if (flag) {
ffffffffc0204e24:	00099863          	bnez	s3,ffffffffc0204e34 <proc_run+0x52>
}
ffffffffc0204e28:	70a2                	ld	ra,40(sp)
ffffffffc0204e2a:	7482                	ld	s1,32(sp)
ffffffffc0204e2c:	6962                	ld	s2,24(sp)
ffffffffc0204e2e:	69c2                	ld	s3,16(sp)
ffffffffc0204e30:	6145                	addi	sp,sp,48
ffffffffc0204e32:	8082                	ret
ffffffffc0204e34:	70a2                	ld	ra,40(sp)
ffffffffc0204e36:	7482                	ld	s1,32(sp)
ffffffffc0204e38:	6962                	ld	s2,24(sp)
ffffffffc0204e3a:	69c2                	ld	s3,16(sp)
ffffffffc0204e3c:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204e3e:	803fb06f          	j	ffffffffc0200640 <intr_enable>
ffffffffc0204e42:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204e44:	803fb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0204e48:	6522                	ld	a0,8(sp)
ffffffffc0204e4a:	4985                	li	s3,1
ffffffffc0204e4c:	bf6d                	j	ffffffffc0204e06 <proc_run+0x24>

ffffffffc0204e4e <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204e4e:	7159                	addi	sp,sp,-112
ffffffffc0204e50:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204e52:	000ae917          	auipc	s2,0xae
ffffffffc0204e56:	c5690913          	addi	s2,s2,-938 # ffffffffc02b2aa8 <nr_process>
ffffffffc0204e5a:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204e5e:	f486                	sd	ra,104(sp)
ffffffffc0204e60:	f0a2                	sd	s0,96(sp)
ffffffffc0204e62:	eca6                	sd	s1,88(sp)
ffffffffc0204e64:	e4ce                	sd	s3,72(sp)
ffffffffc0204e66:	e0d2                	sd	s4,64(sp)
ffffffffc0204e68:	fc56                	sd	s5,56(sp)
ffffffffc0204e6a:	f85a                	sd	s6,48(sp)
ffffffffc0204e6c:	f45e                	sd	s7,40(sp)
ffffffffc0204e6e:	f062                	sd	s8,32(sp)
ffffffffc0204e70:	ec66                	sd	s9,24(sp)
ffffffffc0204e72:	e86a                	sd	s10,16(sp)
ffffffffc0204e74:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204e76:	6785                	lui	a5,0x1
ffffffffc0204e78:	34f75063          	bge	a4,a5,ffffffffc02051b8 <do_fork+0x36a>
ffffffffc0204e7c:	8a2a                	mv	s4,a0
ffffffffc0204e7e:	89ae                	mv	s3,a1
ffffffffc0204e80:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204e82:	df1ff0ef          	jal	ra,ffffffffc0204c72 <alloc_proc>
ffffffffc0204e86:	84aa                	mv	s1,a0
ffffffffc0204e88:	2c050863          	beqz	a0,ffffffffc0205158 <do_fork+0x30a>
    proc->parent = current;
ffffffffc0204e8c:	000aea97          	auipc	s5,0xae
ffffffffc0204e90:	c04a8a93          	addi	s5,s5,-1020 # ffffffffc02b2a90 <current>
ffffffffc0204e94:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0); // 确保当前进程的等待状态为0
ffffffffc0204e98:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8aec>
    proc->parent = current;
ffffffffc0204e9c:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0); // 确保当前进程的等待状态为0
ffffffffc0204e9e:	38071363          	bnez	a4,ffffffffc0205224 <do_fork+0x3d6>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204ea2:	4509                	li	a0,2
ffffffffc0204ea4:	de9fc0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
    if (page != NULL) {
ffffffffc0204ea8:	2c050763          	beqz	a0,ffffffffc0205176 <do_fork+0x328>
    return page - pages + nbase;
ffffffffc0204eac:	000aed97          	auipc	s11,0xae
ffffffffc0204eb0:	ba4d8d93          	addi	s11,s11,-1116 # ffffffffc02b2a50 <pages>
ffffffffc0204eb4:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0204eb8:	000aed17          	auipc	s10,0xae
ffffffffc0204ebc:	b90d0d13          	addi	s10,s10,-1136 # ffffffffc02b2a48 <npage>
    return page - pages + nbase;
ffffffffc0204ec0:	00004c97          	auipc	s9,0x4
ffffffffc0204ec4:	d78cbc83          	ld	s9,-648(s9) # ffffffffc0208c38 <nbase>
ffffffffc0204ec8:	40d506b3          	sub	a3,a0,a3
ffffffffc0204ecc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204ece:	5c7d                	li	s8,-1
ffffffffc0204ed0:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0204ed4:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0204ed6:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0204eda:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ede:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ee0:	30f77963          	bgeu	a4,a5,ffffffffc02051f2 <do_fork+0x3a4>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204ee4:	000ab703          	ld	a4,0(s5)
ffffffffc0204ee8:	000aea97          	auipc	s5,0xae
ffffffffc0204eec:	b78a8a93          	addi	s5,s5,-1160 # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0204ef0:	000ab783          	ld	a5,0(s5)
ffffffffc0204ef4:	02873b83          	ld	s7,40(a4)
ffffffffc0204ef8:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204efa:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc0204efc:	020b8863          	beqz	s7,ffffffffc0204f2c <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0204f00:	100a7a13          	andi	s4,s4,256
ffffffffc0204f04:	1c0a0163          	beqz	s4,ffffffffc02050c6 <do_fork+0x278>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204f08:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f0c:	018bb783          	ld	a5,24(s7)
ffffffffc0204f10:	c02006b7          	lui	a3,0xc0200
ffffffffc0204f14:	2705                	addiw	a4,a4,1
ffffffffc0204f16:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0204f1a:	0374b423          	sd	s7,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f1e:	2ed7e663          	bltu	a5,a3,ffffffffc020520a <do_fork+0x3bc>
ffffffffc0204f22:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204f26:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204f28:	8f99                	sub	a5,a5,a4
ffffffffc0204f2a:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204f2c:	6789                	lui	a5,0x2
ffffffffc0204f2e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7cf8>
ffffffffc0204f32:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204f34:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204f36:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0204f38:	87b6                	mv	a5,a3
ffffffffc0204f3a:	12040893          	addi	a7,s0,288
ffffffffc0204f3e:	00063803          	ld	a6,0(a2)
ffffffffc0204f42:	6608                	ld	a0,8(a2)
ffffffffc0204f44:	6a0c                	ld	a1,16(a2)
ffffffffc0204f46:	6e18                	ld	a4,24(a2)
ffffffffc0204f48:	0107b023          	sd	a6,0(a5)
ffffffffc0204f4c:	e788                	sd	a0,8(a5)
ffffffffc0204f4e:	eb8c                	sd	a1,16(a5)
ffffffffc0204f50:	ef98                	sd	a4,24(a5)
ffffffffc0204f52:	02060613          	addi	a2,a2,32
ffffffffc0204f56:	02078793          	addi	a5,a5,32
ffffffffc0204f5a:	ff1612e3          	bne	a2,a7,ffffffffc0204f3e <do_fork+0xf0>
    proc->tf->gpr.a0 = 0;
ffffffffc0204f5e:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204f62:	12098f63          	beqz	s3,ffffffffc02050a0 <do_fork+0x252>
ffffffffc0204f66:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204f6a:	00000797          	auipc	a5,0x0
ffffffffc0204f6e:	d7678793          	addi	a5,a5,-650 # ffffffffc0204ce0 <forkret>
ffffffffc0204f72:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204f74:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f76:	100027f3          	csrr	a5,sstatus
ffffffffc0204f7a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f7c:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f7e:	14079063          	bnez	a5,ffffffffc02050be <do_fork+0x270>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204f82:	000a2817          	auipc	a6,0xa2
ffffffffc0204f86:	5c680813          	addi	a6,a6,1478 # ffffffffc02a7548 <last_pid.1>
ffffffffc0204f8a:	00082783          	lw	a5,0(a6)
ffffffffc0204f8e:	6709                	lui	a4,0x2
ffffffffc0204f90:	0017851b          	addiw	a0,a5,1
ffffffffc0204f94:	00a82023          	sw	a0,0(a6)
ffffffffc0204f98:	08e55d63          	bge	a0,a4,ffffffffc0205032 <do_fork+0x1e4>
    if (last_pid >= next_safe) {
ffffffffc0204f9c:	000a2317          	auipc	t1,0xa2
ffffffffc0204fa0:	5b030313          	addi	t1,t1,1456 # ffffffffc02a754c <next_safe.0>
ffffffffc0204fa4:	00032783          	lw	a5,0(t1)
ffffffffc0204fa8:	000ae417          	auipc	s0,0xae
ffffffffc0204fac:	a6040413          	addi	s0,s0,-1440 # ffffffffc02b2a08 <proc_list>
ffffffffc0204fb0:	08f55963          	bge	a0,a5,ffffffffc0205042 <do_fork+0x1f4>
        proc->pid = get_pid(); // 为新进程分配PID
ffffffffc0204fb4:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204fb6:	45a9                	li	a1,10
ffffffffc0204fb8:	2501                	sext.w	a0,a0
ffffffffc0204fba:	118010ef          	jal	ra,ffffffffc02060d2 <hash32>
ffffffffc0204fbe:	02051793          	slli	a5,a0,0x20
ffffffffc0204fc2:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204fc6:	000aa797          	auipc	a5,0xaa
ffffffffc0204fca:	a4278793          	addi	a5,a5,-1470 # ffffffffc02aea08 <hash_list>
ffffffffc0204fce:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204fd0:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204fd2:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204fd4:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0204fd8:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0204fda:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204fdc:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204fde:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204fe0:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0204fe4:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0204fe6:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0204fe8:	e21c                	sd	a5,0(a2)
ffffffffc0204fea:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc0204fec:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc0204fee:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc0204ff0:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0204ff4:	10e4b023          	sd	a4,256(s1)
ffffffffc0204ff8:	c311                	beqz	a4,ffffffffc0204ffc <do_fork+0x1ae>
        proc->optr->yptr = proc;
ffffffffc0204ffa:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc0204ffc:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc0205000:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0205002:	2785                	addiw	a5,a5,1
ffffffffc0205004:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0205008:	14099a63          	bnez	s3,ffffffffc020515c <do_fork+0x30e>
    wakeup_proc(proc); 
ffffffffc020500c:	8526                	mv	a0,s1
ffffffffc020500e:	6d9000ef          	jal	ra,ffffffffc0205ee6 <wakeup_proc>
    ret = proc->pid; 
ffffffffc0205012:	40c8                	lw	a0,4(s1)
}
ffffffffc0205014:	70a6                	ld	ra,104(sp)
ffffffffc0205016:	7406                	ld	s0,96(sp)
ffffffffc0205018:	64e6                	ld	s1,88(sp)
ffffffffc020501a:	6946                	ld	s2,80(sp)
ffffffffc020501c:	69a6                	ld	s3,72(sp)
ffffffffc020501e:	6a06                	ld	s4,64(sp)
ffffffffc0205020:	7ae2                	ld	s5,56(sp)
ffffffffc0205022:	7b42                	ld	s6,48(sp)
ffffffffc0205024:	7ba2                	ld	s7,40(sp)
ffffffffc0205026:	7c02                	ld	s8,32(sp)
ffffffffc0205028:	6ce2                	ld	s9,24(sp)
ffffffffc020502a:	6d42                	ld	s10,16(sp)
ffffffffc020502c:	6da2                	ld	s11,8(sp)
ffffffffc020502e:	6165                	addi	sp,sp,112
ffffffffc0205030:	8082                	ret
        last_pid = 1;
ffffffffc0205032:	4785                	li	a5,1
ffffffffc0205034:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205038:	4505                	li	a0,1
ffffffffc020503a:	000a2317          	auipc	t1,0xa2
ffffffffc020503e:	51230313          	addi	t1,t1,1298 # ffffffffc02a754c <next_safe.0>
    return listelm->next;
ffffffffc0205042:	000ae417          	auipc	s0,0xae
ffffffffc0205046:	9c640413          	addi	s0,s0,-1594 # ffffffffc02b2a08 <proc_list>
ffffffffc020504a:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc020504e:	6789                	lui	a5,0x2
ffffffffc0205050:	00f32023          	sw	a5,0(t1)
ffffffffc0205054:	86aa                	mv	a3,a0
ffffffffc0205056:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc0205058:	6e89                	lui	t4,0x2
ffffffffc020505a:	108e0963          	beq	t3,s0,ffffffffc020516c <do_fork+0x31e>
ffffffffc020505e:	88ae                	mv	a7,a1
ffffffffc0205060:	87f2                	mv	a5,t3
ffffffffc0205062:	6609                	lui	a2,0x2
ffffffffc0205064:	a811                	j	ffffffffc0205078 <do_fork+0x22a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205066:	00e6d663          	bge	a3,a4,ffffffffc0205072 <do_fork+0x224>
ffffffffc020506a:	00c75463          	bge	a4,a2,ffffffffc0205072 <do_fork+0x224>
ffffffffc020506e:	863a                	mv	a2,a4
ffffffffc0205070:	4885                	li	a7,1
ffffffffc0205072:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205074:	00878d63          	beq	a5,s0,ffffffffc020508e <do_fork+0x240>
            if (proc->pid == last_pid) {
ffffffffc0205078:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7c9c>
ffffffffc020507c:	fed715e3          	bne	a4,a3,ffffffffc0205066 <do_fork+0x218>
                if (++ last_pid >= next_safe) {
ffffffffc0205080:	2685                	addiw	a3,a3,1
ffffffffc0205082:	0ec6d063          	bge	a3,a2,ffffffffc0205162 <do_fork+0x314>
ffffffffc0205086:	679c                	ld	a5,8(a5)
ffffffffc0205088:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc020508a:	fe8797e3          	bne	a5,s0,ffffffffc0205078 <do_fork+0x22a>
ffffffffc020508e:	c581                	beqz	a1,ffffffffc0205096 <do_fork+0x248>
ffffffffc0205090:	00d82023          	sw	a3,0(a6)
ffffffffc0205094:	8536                	mv	a0,a3
ffffffffc0205096:	f0088fe3          	beqz	a7,ffffffffc0204fb4 <do_fork+0x166>
ffffffffc020509a:	00c32023          	sw	a2,0(t1)
ffffffffc020509e:	bf19                	j	ffffffffc0204fb4 <do_fork+0x166>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050a0:	89b6                	mv	s3,a3
ffffffffc02050a2:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050a6:	00000797          	auipc	a5,0x0
ffffffffc02050aa:	c3a78793          	addi	a5,a5,-966 # ffffffffc0204ce0 <forkret>
ffffffffc02050ae:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050b0:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050b2:	100027f3          	csrr	a5,sstatus
ffffffffc02050b6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050b8:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050ba:	ec0784e3          	beqz	a5,ffffffffc0204f82 <do_fork+0x134>
        intr_disable();
ffffffffc02050be:	d88fb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc02050c2:	4985                	li	s3,1
ffffffffc02050c4:	bd7d                	j	ffffffffc0204f82 <do_fork+0x134>
    if ((mm = mm_create()) == NULL) {
ffffffffc02050c6:	816ff0ef          	jal	ra,ffffffffc02040dc <mm_create>
ffffffffc02050ca:	8b2a                	mv	s6,a0
ffffffffc02050cc:	c159                	beqz	a0,ffffffffc0205152 <do_fork+0x304>
    if ((page = alloc_page()) == NULL) {
ffffffffc02050ce:	4505                	li	a0,1
ffffffffc02050d0:	bbdfc0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc02050d4:	cd25                	beqz	a0,ffffffffc020514c <do_fork+0x2fe>
    return page - pages + nbase;
ffffffffc02050d6:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc02050da:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc02050de:	40d506b3          	sub	a3,a0,a3
ffffffffc02050e2:	8699                	srai	a3,a3,0x6
ffffffffc02050e4:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc02050e6:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc02050ea:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02050ec:	10fc7363          	bgeu	s8,a5,ffffffffc02051f2 <do_fork+0x3a4>
ffffffffc02050f0:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02050f4:	6605                	lui	a2,0x1
ffffffffc02050f6:	000ae597          	auipc	a1,0xae
ffffffffc02050fa:	94a5b583          	ld	a1,-1718(a1) # ffffffffc02b2a40 <boot_pgdir>
ffffffffc02050fe:	9a36                	add	s4,s4,a3
ffffffffc0205100:	8552                	mv	a0,s4
ffffffffc0205102:	462010ef          	jal	ra,ffffffffc0206564 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205106:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc020510a:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020510e:	4785                	li	a5,1
ffffffffc0205110:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205114:	8b85                	andi	a5,a5,1
ffffffffc0205116:	4a05                	li	s4,1
ffffffffc0205118:	c799                	beqz	a5,ffffffffc0205126 <do_fork+0x2d8>
        schedule();
ffffffffc020511a:	64d000ef          	jal	ra,ffffffffc0205f66 <schedule>
ffffffffc020511e:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc0205122:	8b85                	andi	a5,a5,1
ffffffffc0205124:	fbfd                	bnez	a5,ffffffffc020511a <do_fork+0x2cc>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205126:	85de                	mv	a1,s7
ffffffffc0205128:	855a                	mv	a0,s6
ffffffffc020512a:	a3aff0ef          	jal	ra,ffffffffc0204364 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020512e:	57f9                	li	a5,-2
ffffffffc0205130:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc0205134:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205136:	10078763          	beqz	a5,ffffffffc0205244 <do_fork+0x3f6>
good_mm:
ffffffffc020513a:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc020513c:	dc0506e3          	beqz	a0,ffffffffc0204f08 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205140:	855a                	mv	a0,s6
ffffffffc0205142:	abcff0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
    put_pgdir(mm);
ffffffffc0205146:	855a                	mv	a0,s6
ffffffffc0205148:	c25ff0ef          	jal	ra,ffffffffc0204d6c <put_pgdir>
    mm_destroy(mm);
ffffffffc020514c:	855a                	mv	a0,s6
ffffffffc020514e:	914ff0ef          	jal	ra,ffffffffc0204262 <mm_destroy>
    kfree(proc);
ffffffffc0205152:	8526                	mv	a0,s1
ffffffffc0205154:	a0bfc0ef          	jal	ra,ffffffffc0201b5e <kfree>
    ret = -E_NO_MEM;
ffffffffc0205158:	5571                	li	a0,-4
    return ret;
ffffffffc020515a:	bd6d                	j	ffffffffc0205014 <do_fork+0x1c6>
        intr_enable();
ffffffffc020515c:	ce4fb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0205160:	b575                	j	ffffffffc020500c <do_fork+0x1be>
                    if (last_pid >= MAX_PID) {
ffffffffc0205162:	01d6c363          	blt	a3,t4,ffffffffc0205168 <do_fork+0x31a>
                        last_pid = 1;
ffffffffc0205166:	4685                	li	a3,1
                    goto repeat;
ffffffffc0205168:	4585                	li	a1,1
ffffffffc020516a:	bdc5                	j	ffffffffc020505a <do_fork+0x20c>
ffffffffc020516c:	c9a1                	beqz	a1,ffffffffc02051bc <do_fork+0x36e>
ffffffffc020516e:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc0205172:	8536                	mv	a0,a3
ffffffffc0205174:	b581                	j	ffffffffc0204fb4 <do_fork+0x166>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205176:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc0205178:	c02007b7          	lui	a5,0xc0200
ffffffffc020517c:	04f6ef63          	bltu	a3,a5,ffffffffc02051da <do_fork+0x38c>
ffffffffc0205180:	000ae797          	auipc	a5,0xae
ffffffffc0205184:	8e07b783          	ld	a5,-1824(a5) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0205188:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020518c:	83b1                	srli	a5,a5,0xc
ffffffffc020518e:	000ae717          	auipc	a4,0xae
ffffffffc0205192:	8ba73703          	ld	a4,-1862(a4) # ffffffffc02b2a48 <npage>
ffffffffc0205196:	02e7f663          	bgeu	a5,a4,ffffffffc02051c2 <do_fork+0x374>
    return &pages[PPN(pa) - nbase];
ffffffffc020519a:	00004717          	auipc	a4,0x4
ffffffffc020519e:	a9e73703          	ld	a4,-1378(a4) # ffffffffc0208c38 <nbase>
ffffffffc02051a2:	8f99                	sub	a5,a5,a4
ffffffffc02051a4:	079a                	slli	a5,a5,0x6
ffffffffc02051a6:	000ae517          	auipc	a0,0xae
ffffffffc02051aa:	8aa53503          	ld	a0,-1878(a0) # ffffffffc02b2a50 <pages>
ffffffffc02051ae:	4589                	li	a1,2
ffffffffc02051b0:	953e                	add	a0,a0,a5
ffffffffc02051b2:	b6dfc0ef          	jal	ra,ffffffffc0201d1e <free_pages>
}
ffffffffc02051b6:	bf71                	j	ffffffffc0205152 <do_fork+0x304>
    int ret = -E_NO_FREE_PROC;
ffffffffc02051b8:	556d                	li	a0,-5
ffffffffc02051ba:	bda9                	j	ffffffffc0205014 <do_fork+0x1c6>
    return last_pid;
ffffffffc02051bc:	00082503          	lw	a0,0(a6)
ffffffffc02051c0:	bbd5                	j	ffffffffc0204fb4 <do_fork+0x166>
        panic("pa2page called with invalid pa");
ffffffffc02051c2:	00002617          	auipc	a2,0x2
ffffffffc02051c6:	21660613          	addi	a2,a2,534 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc02051ca:	06200593          	li	a1,98
ffffffffc02051ce:	00002517          	auipc	a0,0x2
ffffffffc02051d2:	16250513          	addi	a0,a0,354 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc02051d6:	aa4fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc02051da:	00002617          	auipc	a2,0x2
ffffffffc02051de:	1d660613          	addi	a2,a2,470 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc02051e2:	06e00593          	li	a1,110
ffffffffc02051e6:	00002517          	auipc	a0,0x2
ffffffffc02051ea:	14a50513          	addi	a0,a0,330 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc02051ee:	a8cfb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02051f2:	00002617          	auipc	a2,0x2
ffffffffc02051f6:	11660613          	addi	a2,a2,278 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc02051fa:	06900593          	li	a1,105
ffffffffc02051fe:	00002517          	auipc	a0,0x2
ffffffffc0205202:	13250513          	addi	a0,a0,306 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0205206:	a74fb0ef          	jal	ra,ffffffffc020047a <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020520a:	86be                	mv	a3,a5
ffffffffc020520c:	00002617          	auipc	a2,0x2
ffffffffc0205210:	1a460613          	addi	a2,a2,420 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc0205214:	15f00593          	li	a1,351
ffffffffc0205218:	00003517          	auipc	a0,0x3
ffffffffc020521c:	16850513          	addi	a0,a0,360 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205220:	a5afb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(current->wait_state == 0); // 确保当前进程的等待状态为0
ffffffffc0205224:	00003697          	auipc	a3,0x3
ffffffffc0205228:	17468693          	addi	a3,a3,372 # ffffffffc0208398 <default_pmm_manager+0x10c8>
ffffffffc020522c:	00002617          	auipc	a2,0x2
ffffffffc0205230:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205234:	1ab00593          	li	a1,427
ffffffffc0205238:	00003517          	auipc	a0,0x3
ffffffffc020523c:	14850513          	addi	a0,a0,328 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205240:	a3afb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("Unlock failed.\n");
ffffffffc0205244:	00003617          	auipc	a2,0x3
ffffffffc0205248:	17460613          	addi	a2,a2,372 # ffffffffc02083b8 <default_pmm_manager+0x10e8>
ffffffffc020524c:	03100593          	li	a1,49
ffffffffc0205250:	00003517          	auipc	a0,0x3
ffffffffc0205254:	17850513          	addi	a0,a0,376 # ffffffffc02083c8 <default_pmm_manager+0x10f8>
ffffffffc0205258:	a22fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020525c <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020525c:	7129                	addi	sp,sp,-320
ffffffffc020525e:	fa22                	sd	s0,304(sp)
ffffffffc0205260:	f626                	sd	s1,296(sp)
ffffffffc0205262:	f24a                	sd	s2,288(sp)
ffffffffc0205264:	84ae                	mv	s1,a1
ffffffffc0205266:	892a                	mv	s2,a0
ffffffffc0205268:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020526a:	4581                	li	a1,0
ffffffffc020526c:	12000613          	li	a2,288
ffffffffc0205270:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205272:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205274:	2de010ef          	jal	ra,ffffffffc0206552 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205278:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020527a:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020527c:	100027f3          	csrr	a5,sstatus
ffffffffc0205280:	edd7f793          	andi	a5,a5,-291
ffffffffc0205284:	1207e793          	ori	a5,a5,288
ffffffffc0205288:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020528a:	860a                	mv	a2,sp
ffffffffc020528c:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205290:	00000797          	auipc	a5,0x0
ffffffffc0205294:	9da78793          	addi	a5,a5,-1574 # ffffffffc0204c6a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205298:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020529a:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020529c:	bb3ff0ef          	jal	ra,ffffffffc0204e4e <do_fork>
}
ffffffffc02052a0:	70f2                	ld	ra,312(sp)
ffffffffc02052a2:	7452                	ld	s0,304(sp)
ffffffffc02052a4:	74b2                	ld	s1,296(sp)
ffffffffc02052a6:	7912                	ld	s2,288(sp)
ffffffffc02052a8:	6131                	addi	sp,sp,320
ffffffffc02052aa:	8082                	ret

ffffffffc02052ac <do_exit>:
do_exit(int error_code) {
ffffffffc02052ac:	7179                	addi	sp,sp,-48
ffffffffc02052ae:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc02052b0:	000ad417          	auipc	s0,0xad
ffffffffc02052b4:	7e040413          	addi	s0,s0,2016 # ffffffffc02b2a90 <current>
ffffffffc02052b8:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02052ba:	f406                	sd	ra,40(sp)
ffffffffc02052bc:	ec26                	sd	s1,24(sp)
ffffffffc02052be:	e84a                	sd	s2,16(sp)
ffffffffc02052c0:	e44e                	sd	s3,8(sp)
ffffffffc02052c2:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02052c4:	000ad717          	auipc	a4,0xad
ffffffffc02052c8:	7d473703          	ld	a4,2004(a4) # ffffffffc02b2a98 <idleproc>
ffffffffc02052cc:	0ce78c63          	beq	a5,a4,ffffffffc02053a4 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc02052d0:	000ad497          	auipc	s1,0xad
ffffffffc02052d4:	7d048493          	addi	s1,s1,2000 # ffffffffc02b2aa0 <initproc>
ffffffffc02052d8:	6098                	ld	a4,0(s1)
ffffffffc02052da:	0ee78b63          	beq	a5,a4,ffffffffc02053d0 <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc02052de:	0287b983          	ld	s3,40(a5)
ffffffffc02052e2:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc02052e4:	02098663          	beqz	s3,ffffffffc0205310 <do_exit+0x64>
ffffffffc02052e8:	000ad797          	auipc	a5,0xad
ffffffffc02052ec:	7507b783          	ld	a5,1872(a5) # ffffffffc02b2a38 <boot_cr3>
ffffffffc02052f0:	577d                	li	a4,-1
ffffffffc02052f2:	177e                	slli	a4,a4,0x3f
ffffffffc02052f4:	83b1                	srli	a5,a5,0xc
ffffffffc02052f6:	8fd9                	or	a5,a5,a4
ffffffffc02052f8:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02052fc:	0309a783          	lw	a5,48(s3)
ffffffffc0205300:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205304:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205308:	cb55                	beqz	a4,ffffffffc02053bc <do_exit+0x110>
        current->mm = NULL;
ffffffffc020530a:	601c                	ld	a5,0(s0)
ffffffffc020530c:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0205310:	601c                	ld	a5,0(s0)
ffffffffc0205312:	470d                	li	a4,3
ffffffffc0205314:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205316:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020531a:	100027f3          	csrr	a5,sstatus
ffffffffc020531e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205320:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205322:	e3f9                	bnez	a5,ffffffffc02053e8 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0205324:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205326:	800007b7          	lui	a5,0x80000
ffffffffc020532a:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020532c:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020532e:	0ec52703          	lw	a4,236(a0)
ffffffffc0205332:	0af70f63          	beq	a4,a5,ffffffffc02053f0 <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0205336:	6018                	ld	a4,0(s0)
ffffffffc0205338:	7b7c                	ld	a5,240(a4)
ffffffffc020533a:	c3a1                	beqz	a5,ffffffffc020537a <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020533c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205340:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205342:	0985                	addi	s3,s3,1
ffffffffc0205344:	a021                	j	ffffffffc020534c <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0205346:	6018                	ld	a4,0(s0)
ffffffffc0205348:	7b7c                	ld	a5,240(a4)
ffffffffc020534a:	cb85                	beqz	a5,ffffffffc020537a <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc020534c:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fb8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205350:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0205352:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205354:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205356:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020535a:	10e7b023          	sd	a4,256(a5)
ffffffffc020535e:	c311                	beqz	a4,ffffffffc0205362 <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc0205360:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205362:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205364:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205366:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205368:	fd271fe3          	bne	a4,s2,ffffffffc0205346 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020536c:	0ec52783          	lw	a5,236(a0)
ffffffffc0205370:	fd379be3          	bne	a5,s3,ffffffffc0205346 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205374:	373000ef          	jal	ra,ffffffffc0205ee6 <wakeup_proc>
ffffffffc0205378:	b7f9                	j	ffffffffc0205346 <do_exit+0x9a>
    if (flag) {
ffffffffc020537a:	020a1263          	bnez	s4,ffffffffc020539e <do_exit+0xf2>
    schedule();
ffffffffc020537e:	3e9000ef          	jal	ra,ffffffffc0205f66 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205382:	601c                	ld	a5,0(s0)
ffffffffc0205384:	00003617          	auipc	a2,0x3
ffffffffc0205388:	07c60613          	addi	a2,a2,124 # ffffffffc0208400 <default_pmm_manager+0x1130>
ffffffffc020538c:	1f900593          	li	a1,505
ffffffffc0205390:	43d4                	lw	a3,4(a5)
ffffffffc0205392:	00003517          	auipc	a0,0x3
ffffffffc0205396:	fee50513          	addi	a0,a0,-18 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc020539a:	8e0fb0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_enable();
ffffffffc020539e:	aa2fb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02053a2:	bff1                	j	ffffffffc020537e <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02053a4:	00003617          	auipc	a2,0x3
ffffffffc02053a8:	03c60613          	addi	a2,a2,60 # ffffffffc02083e0 <default_pmm_manager+0x1110>
ffffffffc02053ac:	1cd00593          	li	a1,461
ffffffffc02053b0:	00003517          	auipc	a0,0x3
ffffffffc02053b4:	fd050513          	addi	a0,a0,-48 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc02053b8:	8c2fb0ef          	jal	ra,ffffffffc020047a <__panic>
            exit_mmap(mm);
ffffffffc02053bc:	854e                	mv	a0,s3
ffffffffc02053be:	840ff0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
            put_pgdir(mm);
ffffffffc02053c2:	854e                	mv	a0,s3
ffffffffc02053c4:	9a9ff0ef          	jal	ra,ffffffffc0204d6c <put_pgdir>
            mm_destroy(mm);
ffffffffc02053c8:	854e                	mv	a0,s3
ffffffffc02053ca:	e99fe0ef          	jal	ra,ffffffffc0204262 <mm_destroy>
ffffffffc02053ce:	bf35                	j	ffffffffc020530a <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc02053d0:	00003617          	auipc	a2,0x3
ffffffffc02053d4:	02060613          	addi	a2,a2,32 # ffffffffc02083f0 <default_pmm_manager+0x1120>
ffffffffc02053d8:	1d000593          	li	a1,464
ffffffffc02053dc:	00003517          	auipc	a0,0x3
ffffffffc02053e0:	fa450513          	addi	a0,a0,-92 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc02053e4:	896fb0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_disable();
ffffffffc02053e8:	a5efb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc02053ec:	4a05                	li	s4,1
ffffffffc02053ee:	bf1d                	j	ffffffffc0205324 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc02053f0:	2f7000ef          	jal	ra,ffffffffc0205ee6 <wakeup_proc>
ffffffffc02053f4:	b789                	j	ffffffffc0205336 <do_exit+0x8a>

ffffffffc02053f6 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc02053f6:	715d                	addi	sp,sp,-80
ffffffffc02053f8:	f84a                	sd	s2,48(sp)
ffffffffc02053fa:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc02053fc:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205400:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc0205402:	fc26                	sd	s1,56(sp)
ffffffffc0205404:	f052                	sd	s4,32(sp)
ffffffffc0205406:	ec56                	sd	s5,24(sp)
ffffffffc0205408:	e85a                	sd	s6,16(sp)
ffffffffc020540a:	e45e                	sd	s7,8(sp)
ffffffffc020540c:	e486                	sd	ra,72(sp)
ffffffffc020540e:	e0a2                	sd	s0,64(sp)
ffffffffc0205410:	84aa                	mv	s1,a0
ffffffffc0205412:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205414:	000adb97          	auipc	s7,0xad
ffffffffc0205418:	67cb8b93          	addi	s7,s7,1660 # ffffffffc02b2a90 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020541c:	00050b1b          	sext.w	s6,a0
ffffffffc0205420:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0205424:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0205426:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205428:	ccbd                	beqz	s1,ffffffffc02054a6 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc020542a:	0359e863          	bltu	s3,s5,ffffffffc020545a <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020542e:	45a9                	li	a1,10
ffffffffc0205430:	855a                	mv	a0,s6
ffffffffc0205432:	4a1000ef          	jal	ra,ffffffffc02060d2 <hash32>
ffffffffc0205436:	02051793          	slli	a5,a0,0x20
ffffffffc020543a:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020543e:	000a9797          	auipc	a5,0xa9
ffffffffc0205442:	5ca78793          	addi	a5,a5,1482 # ffffffffc02aea08 <hash_list>
ffffffffc0205446:	953e                	add	a0,a0,a5
ffffffffc0205448:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc020544a:	a029                	j	ffffffffc0205454 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc020544c:	f2c42783          	lw	a5,-212(s0)
ffffffffc0205450:	02978163          	beq	a5,s1,ffffffffc0205472 <do_wait.part.0+0x7c>
ffffffffc0205454:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205456:	fe851be3          	bne	a0,s0,ffffffffc020544c <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc020545a:	5579                	li	a0,-2
}
ffffffffc020545c:	60a6                	ld	ra,72(sp)
ffffffffc020545e:	6406                	ld	s0,64(sp)
ffffffffc0205460:	74e2                	ld	s1,56(sp)
ffffffffc0205462:	7942                	ld	s2,48(sp)
ffffffffc0205464:	79a2                	ld	s3,40(sp)
ffffffffc0205466:	7a02                	ld	s4,32(sp)
ffffffffc0205468:	6ae2                	ld	s5,24(sp)
ffffffffc020546a:	6b42                	ld	s6,16(sp)
ffffffffc020546c:	6ba2                	ld	s7,8(sp)
ffffffffc020546e:	6161                	addi	sp,sp,80
ffffffffc0205470:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc0205472:	000bb683          	ld	a3,0(s7)
ffffffffc0205476:	f4843783          	ld	a5,-184(s0)
ffffffffc020547a:	fed790e3          	bne	a5,a3,ffffffffc020545a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020547e:	f2842703          	lw	a4,-216(s0)
ffffffffc0205482:	478d                	li	a5,3
ffffffffc0205484:	0ef70b63          	beq	a4,a5,ffffffffc020557a <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc0205488:	4785                	li	a5,1
ffffffffc020548a:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc020548c:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc0205490:	2d7000ef          	jal	ra,ffffffffc0205f66 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205494:	000bb783          	ld	a5,0(s7)
ffffffffc0205498:	0b07a783          	lw	a5,176(a5)
ffffffffc020549c:	8b85                	andi	a5,a5,1
ffffffffc020549e:	d7c9                	beqz	a5,ffffffffc0205428 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02054a0:	555d                	li	a0,-9
ffffffffc02054a2:	e0bff0ef          	jal	ra,ffffffffc02052ac <do_exit>
        proc = current->cptr;
ffffffffc02054a6:	000bb683          	ld	a3,0(s7)
ffffffffc02054aa:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02054ac:	d45d                	beqz	s0,ffffffffc020545a <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054ae:	470d                	li	a4,3
ffffffffc02054b0:	a021                	j	ffffffffc02054b8 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02054b2:	10043403          	ld	s0,256(s0)
ffffffffc02054b6:	d869                	beqz	s0,ffffffffc0205488 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054b8:	401c                	lw	a5,0(s0)
ffffffffc02054ba:	fee79ce3          	bne	a5,a4,ffffffffc02054b2 <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc02054be:	000ad797          	auipc	a5,0xad
ffffffffc02054c2:	5da7b783          	ld	a5,1498(a5) # ffffffffc02b2a98 <idleproc>
ffffffffc02054c6:	0c878963          	beq	a5,s0,ffffffffc0205598 <do_wait.part.0+0x1a2>
ffffffffc02054ca:	000ad797          	auipc	a5,0xad
ffffffffc02054ce:	5d67b783          	ld	a5,1494(a5) # ffffffffc02b2aa0 <initproc>
ffffffffc02054d2:	0cf40363          	beq	s0,a5,ffffffffc0205598 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc02054d6:	000a0663          	beqz	s4,ffffffffc02054e2 <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc02054da:	0e842783          	lw	a5,232(s0)
ffffffffc02054de:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8bd8>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054e2:	100027f3          	csrr	a5,sstatus
ffffffffc02054e6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02054e8:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02054ea:	e7c1                	bnez	a5,ffffffffc0205572 <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02054ec:	6c70                	ld	a2,216(s0)
ffffffffc02054ee:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02054f0:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc02054f4:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02054f6:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02054f8:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02054fa:	6470                	ld	a2,200(s0)
ffffffffc02054fc:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02054fe:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205500:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc0205502:	c319                	beqz	a4,ffffffffc0205508 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205504:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205506:	7c7c                	ld	a5,248(s0)
ffffffffc0205508:	c3b5                	beqz	a5,ffffffffc020556c <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc020550a:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020550e:	000ad717          	auipc	a4,0xad
ffffffffc0205512:	59a70713          	addi	a4,a4,1434 # ffffffffc02b2aa8 <nr_process>
ffffffffc0205516:	431c                	lw	a5,0(a4)
ffffffffc0205518:	37fd                	addiw	a5,a5,-1
ffffffffc020551a:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc020551c:	e5a9                	bnez	a1,ffffffffc0205566 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020551e:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0205520:	c02007b7          	lui	a5,0xc0200
ffffffffc0205524:	04f6ee63          	bltu	a3,a5,ffffffffc0205580 <do_wait.part.0+0x18a>
ffffffffc0205528:	000ad797          	auipc	a5,0xad
ffffffffc020552c:	5387b783          	ld	a5,1336(a5) # ffffffffc02b2a60 <va_pa_offset>
ffffffffc0205530:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205532:	82b1                	srli	a3,a3,0xc
ffffffffc0205534:	000ad797          	auipc	a5,0xad
ffffffffc0205538:	5147b783          	ld	a5,1300(a5) # ffffffffc02b2a48 <npage>
ffffffffc020553c:	06f6fa63          	bgeu	a3,a5,ffffffffc02055b0 <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0205540:	00003517          	auipc	a0,0x3
ffffffffc0205544:	6f853503          	ld	a0,1784(a0) # ffffffffc0208c38 <nbase>
ffffffffc0205548:	8e89                	sub	a3,a3,a0
ffffffffc020554a:	069a                	slli	a3,a3,0x6
ffffffffc020554c:	000ad517          	auipc	a0,0xad
ffffffffc0205550:	50453503          	ld	a0,1284(a0) # ffffffffc02b2a50 <pages>
ffffffffc0205554:	9536                	add	a0,a0,a3
ffffffffc0205556:	4589                	li	a1,2
ffffffffc0205558:	fc6fc0ef          	jal	ra,ffffffffc0201d1e <free_pages>
    kfree(proc);
ffffffffc020555c:	8522                	mv	a0,s0
ffffffffc020555e:	e00fc0ef          	jal	ra,ffffffffc0201b5e <kfree>
    return 0;
ffffffffc0205562:	4501                	li	a0,0
ffffffffc0205564:	bde5                	j	ffffffffc020545c <do_wait.part.0+0x66>
        intr_enable();
ffffffffc0205566:	8dafb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020556a:	bf55                	j	ffffffffc020551e <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc020556c:	701c                	ld	a5,32(s0)
ffffffffc020556e:	fbf8                	sd	a4,240(a5)
ffffffffc0205570:	bf79                	j	ffffffffc020550e <do_wait.part.0+0x118>
        intr_disable();
ffffffffc0205572:	8d4fb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205576:	4585                	li	a1,1
ffffffffc0205578:	bf95                	j	ffffffffc02054ec <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020557a:	f2840413          	addi	s0,s0,-216
ffffffffc020557e:	b781                	j	ffffffffc02054be <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc0205580:	00002617          	auipc	a2,0x2
ffffffffc0205584:	e3060613          	addi	a2,a2,-464 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc0205588:	06e00593          	li	a1,110
ffffffffc020558c:	00002517          	auipc	a0,0x2
ffffffffc0205590:	da450513          	addi	a0,a0,-604 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0205594:	ee7fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc0205598:	00003617          	auipc	a2,0x3
ffffffffc020559c:	e8860613          	addi	a2,a2,-376 # ffffffffc0208420 <default_pmm_manager+0x1150>
ffffffffc02055a0:	2f400593          	li	a1,756
ffffffffc02055a4:	00003517          	auipc	a0,0x3
ffffffffc02055a8:	ddc50513          	addi	a0,a0,-548 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc02055ac:	ecffa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02055b0:	00002617          	auipc	a2,0x2
ffffffffc02055b4:	e2860613          	addi	a2,a2,-472 # ffffffffc02073d8 <default_pmm_manager+0x108>
ffffffffc02055b8:	06200593          	li	a1,98
ffffffffc02055bc:	00002517          	auipc	a0,0x2
ffffffffc02055c0:	d7450513          	addi	a0,a0,-652 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc02055c4:	eb7fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02055c8 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02055c8:	1141                	addi	sp,sp,-16
ffffffffc02055ca:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02055cc:	f92fc0ef          	jal	ra,ffffffffc0201d5e <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02055d0:	cdafc0ef          	jal	ra,ffffffffc0201aaa <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02055d4:	4601                	li	a2,0
ffffffffc02055d6:	4581                	li	a1,0
ffffffffc02055d8:	fffff517          	auipc	a0,0xfffff
ffffffffc02055dc:	71650513          	addi	a0,a0,1814 # ffffffffc0204cee <user_main>
ffffffffc02055e0:	c7dff0ef          	jal	ra,ffffffffc020525c <kernel_thread>
    if (pid <= 0) {
ffffffffc02055e4:	00a04563          	bgtz	a0,ffffffffc02055ee <init_main+0x26>
ffffffffc02055e8:	a071                	j	ffffffffc0205674 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02055ea:	17d000ef          	jal	ra,ffffffffc0205f66 <schedule>
    if (code_store != NULL) {
ffffffffc02055ee:	4581                	li	a1,0
ffffffffc02055f0:	4501                	li	a0,0
ffffffffc02055f2:	e05ff0ef          	jal	ra,ffffffffc02053f6 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc02055f6:	d975                	beqz	a0,ffffffffc02055ea <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02055f8:	00003517          	auipc	a0,0x3
ffffffffc02055fc:	e6850513          	addi	a0,a0,-408 # ffffffffc0208460 <default_pmm_manager+0x1190>
ffffffffc0205600:	b81fa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205604:	000ad797          	auipc	a5,0xad
ffffffffc0205608:	49c7b783          	ld	a5,1180(a5) # ffffffffc02b2aa0 <initproc>
ffffffffc020560c:	7bf8                	ld	a4,240(a5)
ffffffffc020560e:	e339                	bnez	a4,ffffffffc0205654 <init_main+0x8c>
ffffffffc0205610:	7ff8                	ld	a4,248(a5)
ffffffffc0205612:	e329                	bnez	a4,ffffffffc0205654 <init_main+0x8c>
ffffffffc0205614:	1007b703          	ld	a4,256(a5)
ffffffffc0205618:	ef15                	bnez	a4,ffffffffc0205654 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020561a:	000ad697          	auipc	a3,0xad
ffffffffc020561e:	48e6a683          	lw	a3,1166(a3) # ffffffffc02b2aa8 <nr_process>
ffffffffc0205622:	4709                	li	a4,2
ffffffffc0205624:	0ae69463          	bne	a3,a4,ffffffffc02056cc <init_main+0x104>
    return listelm->next;
ffffffffc0205628:	000ad697          	auipc	a3,0xad
ffffffffc020562c:	3e068693          	addi	a3,a3,992 # ffffffffc02b2a08 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205630:	6698                	ld	a4,8(a3)
ffffffffc0205632:	0c878793          	addi	a5,a5,200
ffffffffc0205636:	06f71b63          	bne	a4,a5,ffffffffc02056ac <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020563a:	629c                	ld	a5,0(a3)
ffffffffc020563c:	04f71863          	bne	a4,a5,ffffffffc020568c <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc0205640:	00003517          	auipc	a0,0x3
ffffffffc0205644:	f0850513          	addi	a0,a0,-248 # ffffffffc0208548 <default_pmm_manager+0x1278>
ffffffffc0205648:	b39fa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc020564c:	60a2                	ld	ra,8(sp)
ffffffffc020564e:	4501                	li	a0,0
ffffffffc0205650:	0141                	addi	sp,sp,16
ffffffffc0205652:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205654:	00003697          	auipc	a3,0x3
ffffffffc0205658:	e3468693          	addi	a3,a3,-460 # ffffffffc0208488 <default_pmm_manager+0x11b8>
ffffffffc020565c:	00001617          	auipc	a2,0x1
ffffffffc0205660:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205664:	35900593          	li	a1,857
ffffffffc0205668:	00003517          	auipc	a0,0x3
ffffffffc020566c:	d1850513          	addi	a0,a0,-744 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205670:	e0bfa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("create user_main failed.\n");
ffffffffc0205674:	00003617          	auipc	a2,0x3
ffffffffc0205678:	dcc60613          	addi	a2,a2,-564 # ffffffffc0208440 <default_pmm_manager+0x1170>
ffffffffc020567c:	35100593          	li	a1,849
ffffffffc0205680:	00003517          	auipc	a0,0x3
ffffffffc0205684:	d0050513          	addi	a0,a0,-768 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205688:	df3fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020568c:	00003697          	auipc	a3,0x3
ffffffffc0205690:	e8c68693          	addi	a3,a3,-372 # ffffffffc0208518 <default_pmm_manager+0x1248>
ffffffffc0205694:	00001617          	auipc	a2,0x1
ffffffffc0205698:	5a460613          	addi	a2,a2,1444 # ffffffffc0206c38 <commands+0x450>
ffffffffc020569c:	35c00593          	li	a1,860
ffffffffc02056a0:	00003517          	auipc	a0,0x3
ffffffffc02056a4:	ce050513          	addi	a0,a0,-800 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc02056a8:	dd3fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02056ac:	00003697          	auipc	a3,0x3
ffffffffc02056b0:	e3c68693          	addi	a3,a3,-452 # ffffffffc02084e8 <default_pmm_manager+0x1218>
ffffffffc02056b4:	00001617          	auipc	a2,0x1
ffffffffc02056b8:	58460613          	addi	a2,a2,1412 # ffffffffc0206c38 <commands+0x450>
ffffffffc02056bc:	35b00593          	li	a1,859
ffffffffc02056c0:	00003517          	auipc	a0,0x3
ffffffffc02056c4:	cc050513          	addi	a0,a0,-832 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc02056c8:	db3fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_process == 2);
ffffffffc02056cc:	00003697          	auipc	a3,0x3
ffffffffc02056d0:	e0c68693          	addi	a3,a3,-500 # ffffffffc02084d8 <default_pmm_manager+0x1208>
ffffffffc02056d4:	00001617          	auipc	a2,0x1
ffffffffc02056d8:	56460613          	addi	a2,a2,1380 # ffffffffc0206c38 <commands+0x450>
ffffffffc02056dc:	35a00593          	li	a1,858
ffffffffc02056e0:	00003517          	auipc	a0,0x3
ffffffffc02056e4:	ca050513          	addi	a0,a0,-864 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc02056e8:	d93fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02056ec <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02056ec:	7171                	addi	sp,sp,-176
ffffffffc02056ee:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02056f0:	000add97          	auipc	s11,0xad
ffffffffc02056f4:	3a0d8d93          	addi	s11,s11,928 # ffffffffc02b2a90 <current>
ffffffffc02056f8:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02056fc:	e54e                	sd	s3,136(sp)
ffffffffc02056fe:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205700:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205704:	e94a                	sd	s2,144(sp)
ffffffffc0205706:	f4de                	sd	s7,104(sp)
ffffffffc0205708:	892a                	mv	s2,a0
ffffffffc020570a:	8bb2                	mv	s7,a2
ffffffffc020570c:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020570e:	862e                	mv	a2,a1
ffffffffc0205710:	4681                	li	a3,0
ffffffffc0205712:	85aa                	mv	a1,a0
ffffffffc0205714:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205716:	f506                	sd	ra,168(sp)
ffffffffc0205718:	f122                	sd	s0,160(sp)
ffffffffc020571a:	e152                	sd	s4,128(sp)
ffffffffc020571c:	fcd6                	sd	s5,120(sp)
ffffffffc020571e:	f8da                	sd	s6,112(sp)
ffffffffc0205720:	f0e2                	sd	s8,96(sp)
ffffffffc0205722:	ece6                	sd	s9,88(sp)
ffffffffc0205724:	e8ea                	sd	s10,80(sp)
ffffffffc0205726:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205728:	b5aff0ef          	jal	ra,ffffffffc0204a82 <user_mem_check>
ffffffffc020572c:	40050a63          	beqz	a0,ffffffffc0205b40 <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205730:	4641                	li	a2,16
ffffffffc0205732:	4581                	li	a1,0
ffffffffc0205734:	1808                	addi	a0,sp,48
ffffffffc0205736:	61d000ef          	jal	ra,ffffffffc0206552 <memset>
    memcpy(local_name, name, len);
ffffffffc020573a:	47bd                	li	a5,15
ffffffffc020573c:	8626                	mv	a2,s1
ffffffffc020573e:	1e97e263          	bltu	a5,s1,ffffffffc0205922 <do_execve+0x236>
ffffffffc0205742:	85ca                	mv	a1,s2
ffffffffc0205744:	1808                	addi	a0,sp,48
ffffffffc0205746:	61f000ef          	jal	ra,ffffffffc0206564 <memcpy>
    if (mm != NULL) {
ffffffffc020574a:	1e098363          	beqz	s3,ffffffffc0205930 <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc020574e:	00002517          	auipc	a0,0x2
ffffffffc0205752:	30a50513          	addi	a0,a0,778 # ffffffffc0207a58 <default_pmm_manager+0x788>
ffffffffc0205756:	a63fa0ef          	jal	ra,ffffffffc02001b8 <cputs>
ffffffffc020575a:	000ad797          	auipc	a5,0xad
ffffffffc020575e:	2de7b783          	ld	a5,734(a5) # ffffffffc02b2a38 <boot_cr3>
ffffffffc0205762:	577d                	li	a4,-1
ffffffffc0205764:	177e                	slli	a4,a4,0x3f
ffffffffc0205766:	83b1                	srli	a5,a5,0xc
ffffffffc0205768:	8fd9                	or	a5,a5,a4
ffffffffc020576a:	18079073          	csrw	satp,a5
ffffffffc020576e:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7ba8>
ffffffffc0205772:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205776:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc020577a:	2c070463          	beqz	a4,ffffffffc0205a42 <do_execve+0x356>
        current->mm = NULL;
ffffffffc020577e:	000db783          	ld	a5,0(s11)
ffffffffc0205782:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205786:	957fe0ef          	jal	ra,ffffffffc02040dc <mm_create>
ffffffffc020578a:	84aa                	mv	s1,a0
ffffffffc020578c:	1c050d63          	beqz	a0,ffffffffc0205966 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL) {
ffffffffc0205790:	4505                	li	a0,1
ffffffffc0205792:	cfafc0ef          	jal	ra,ffffffffc0201c8c <alloc_pages>
ffffffffc0205796:	3a050963          	beqz	a0,ffffffffc0205b48 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc020579a:	000adc97          	auipc	s9,0xad
ffffffffc020579e:	2b6c8c93          	addi	s9,s9,694 # ffffffffc02b2a50 <pages>
ffffffffc02057a2:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02057a6:	000adc17          	auipc	s8,0xad
ffffffffc02057aa:	2a2c0c13          	addi	s8,s8,674 # ffffffffc02b2a48 <npage>
    return page - pages + nbase;
ffffffffc02057ae:	00003717          	auipc	a4,0x3
ffffffffc02057b2:	48a73703          	ld	a4,1162(a4) # ffffffffc0208c38 <nbase>
ffffffffc02057b6:	40d506b3          	sub	a3,a0,a3
ffffffffc02057ba:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02057bc:	5afd                	li	s5,-1
ffffffffc02057be:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02057c2:	96ba                	add	a3,a3,a4
ffffffffc02057c4:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc02057c6:	00cad713          	srli	a4,s5,0xc
ffffffffc02057ca:	ec3a                	sd	a4,24(sp)
ffffffffc02057cc:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02057ce:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02057d0:	38f77063          	bgeu	a4,a5,ffffffffc0205b50 <do_execve+0x464>
ffffffffc02057d4:	000adb17          	auipc	s6,0xad
ffffffffc02057d8:	28cb0b13          	addi	s6,s6,652 # ffffffffc02b2a60 <va_pa_offset>
ffffffffc02057dc:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02057e0:	6605                	lui	a2,0x1
ffffffffc02057e2:	000ad597          	auipc	a1,0xad
ffffffffc02057e6:	25e5b583          	ld	a1,606(a1) # ffffffffc02b2a40 <boot_pgdir>
ffffffffc02057ea:	9936                	add	s2,s2,a3
ffffffffc02057ec:	854a                	mv	a0,s2
ffffffffc02057ee:	577000ef          	jal	ra,ffffffffc0206564 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02057f2:	7782                	ld	a5,32(sp)
ffffffffc02057f4:	4398                	lw	a4,0(a5)
ffffffffc02057f6:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc02057fa:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02057fe:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9437>
ffffffffc0205802:	14f71863          	bne	a4,a5,ffffffffc0205952 <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205806:	7682                	ld	a3,32(sp)
ffffffffc0205808:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020580c:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205810:	00371793          	slli	a5,a4,0x3
ffffffffc0205814:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205816:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205818:	078e                	slli	a5,a5,0x3
ffffffffc020581a:	97ce                	add	a5,a5,s3
ffffffffc020581c:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020581e:	00f9fc63          	bgeu	s3,a5,ffffffffc0205836 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205822:	0009a783          	lw	a5,0(s3)
ffffffffc0205826:	4705                	li	a4,1
ffffffffc0205828:	14e78163          	beq	a5,a4,ffffffffc020596a <do_execve+0x27e>
    for (; ph < ph_end; ph ++) {
ffffffffc020582c:	77a2                	ld	a5,40(sp)
ffffffffc020582e:	03898993          	addi	s3,s3,56
ffffffffc0205832:	fef9e8e3          	bltu	s3,a5,ffffffffc0205822 <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205836:	4701                	li	a4,0
ffffffffc0205838:	46ad                	li	a3,11
ffffffffc020583a:	00100637          	lui	a2,0x100
ffffffffc020583e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205842:	8526                	mv	a0,s1
ffffffffc0205844:	a71fe0ef          	jal	ra,ffffffffc02042b4 <mm_map>
ffffffffc0205848:	892a                	mv	s2,a0
ffffffffc020584a:	1e051263          	bnez	a0,ffffffffc0205a2e <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020584e:	6c88                	ld	a0,24(s1)
ffffffffc0205850:	467d                	li	a2,31
ffffffffc0205852:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205856:	aa3fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc020585a:	38050363          	beqz	a0,ffffffffc0205be0 <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020585e:	6c88                	ld	a0,24(s1)
ffffffffc0205860:	467d                	li	a2,31
ffffffffc0205862:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205866:	a93fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc020586a:	34050b63          	beqz	a0,ffffffffc0205bc0 <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc020586e:	6c88                	ld	a0,24(s1)
ffffffffc0205870:	467d                	li	a2,31
ffffffffc0205872:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205876:	a83fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc020587a:	32050363          	beqz	a0,ffffffffc0205ba0 <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020587e:	6c88                	ld	a0,24(s1)
ffffffffc0205880:	467d                	li	a2,31
ffffffffc0205882:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205886:	a73fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc020588a:	2e050b63          	beqz	a0,ffffffffc0205b80 <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc020588e:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205890:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205894:	6c94                	ld	a3,24(s1)
ffffffffc0205896:	2785                	addiw	a5,a5,1
ffffffffc0205898:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc020589a:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc020589c:	c02007b7          	lui	a5,0xc0200
ffffffffc02058a0:	2cf6e463          	bltu	a3,a5,ffffffffc0205b68 <do_execve+0x47c>
ffffffffc02058a4:	000b3783          	ld	a5,0(s6)
ffffffffc02058a8:	577d                	li	a4,-1
ffffffffc02058aa:	177e                	slli	a4,a4,0x3f
ffffffffc02058ac:	8e9d                	sub	a3,a3,a5
ffffffffc02058ae:	00c6d793          	srli	a5,a3,0xc
ffffffffc02058b2:	f654                	sd	a3,168(a2)
ffffffffc02058b4:	8fd9                	or	a5,a5,a4
ffffffffc02058b6:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02058ba:	7244                	ld	s1,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02058bc:	4581                	li	a1,0
ffffffffc02058be:	12000613          	li	a2,288
ffffffffc02058c2:	8526                	mv	a0,s1
ffffffffc02058c4:	48f000ef          	jal	ra,ffffffffc0206552 <memset>
    tf->epc = elf->e_entry;
ffffffffc02058c8:	7782                	ld	a5,32(sp)
ffffffffc02058ca:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc02058cc:	4785                	li	a5,1
ffffffffc02058ce:	07fe                	slli	a5,a5,0x1f
ffffffffc02058d0:	e89c                	sd	a5,16(s1)
    tf->epc = elf->e_entry;
ffffffffc02058d2:	10e4b423          	sd	a4,264(s1)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE) | SSTATUS_SPIE;
ffffffffc02058d6:	100027f3          	csrr	a5,sstatus
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02058da:	000db403          	ld	s0,0(s11)
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE) | SSTATUS_SPIE;
ffffffffc02058de:	edf7f793          	andi	a5,a5,-289
ffffffffc02058e2:	0207e793          	ori	a5,a5,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02058e6:	0b440413          	addi	s0,s0,180
ffffffffc02058ea:	4641                	li	a2,16
ffffffffc02058ec:	4581                	li	a1,0
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE) | SSTATUS_SPIE;
ffffffffc02058ee:	10f4b023          	sd	a5,256(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02058f2:	8522                	mv	a0,s0
ffffffffc02058f4:	45f000ef          	jal	ra,ffffffffc0206552 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02058f8:	463d                	li	a2,15
ffffffffc02058fa:	180c                	addi	a1,sp,48
ffffffffc02058fc:	8522                	mv	a0,s0
ffffffffc02058fe:	467000ef          	jal	ra,ffffffffc0206564 <memcpy>
}
ffffffffc0205902:	70aa                	ld	ra,168(sp)
ffffffffc0205904:	740a                	ld	s0,160(sp)
ffffffffc0205906:	64ea                	ld	s1,152(sp)
ffffffffc0205908:	69aa                	ld	s3,136(sp)
ffffffffc020590a:	6a0a                	ld	s4,128(sp)
ffffffffc020590c:	7ae6                	ld	s5,120(sp)
ffffffffc020590e:	7b46                	ld	s6,112(sp)
ffffffffc0205910:	7ba6                	ld	s7,104(sp)
ffffffffc0205912:	7c06                	ld	s8,96(sp)
ffffffffc0205914:	6ce6                	ld	s9,88(sp)
ffffffffc0205916:	6d46                	ld	s10,80(sp)
ffffffffc0205918:	6da6                	ld	s11,72(sp)
ffffffffc020591a:	854a                	mv	a0,s2
ffffffffc020591c:	694a                	ld	s2,144(sp)
ffffffffc020591e:	614d                	addi	sp,sp,176
ffffffffc0205920:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205922:	463d                	li	a2,15
ffffffffc0205924:	85ca                	mv	a1,s2
ffffffffc0205926:	1808                	addi	a0,sp,48
ffffffffc0205928:	43d000ef          	jal	ra,ffffffffc0206564 <memcpy>
    if (mm != NULL) {
ffffffffc020592c:	e20991e3          	bnez	s3,ffffffffc020574e <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205930:	000db783          	ld	a5,0(s11)
ffffffffc0205934:	779c                	ld	a5,40(a5)
ffffffffc0205936:	e40788e3          	beqz	a5,ffffffffc0205786 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020593a:	00003617          	auipc	a2,0x3
ffffffffc020593e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0208568 <default_pmm_manager+0x1298>
ffffffffc0205942:	20300593          	li	a1,515
ffffffffc0205946:	00003517          	auipc	a0,0x3
ffffffffc020594a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc020594e:	b2dfa0ef          	jal	ra,ffffffffc020047a <__panic>
    put_pgdir(mm);
ffffffffc0205952:	8526                	mv	a0,s1
ffffffffc0205954:	c18ff0ef          	jal	ra,ffffffffc0204d6c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205958:	8526                	mv	a0,s1
ffffffffc020595a:	909fe0ef          	jal	ra,ffffffffc0204262 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020595e:	5961                	li	s2,-8
    do_exit(ret);
ffffffffc0205960:	854a                	mv	a0,s2
ffffffffc0205962:	94bff0ef          	jal	ra,ffffffffc02052ac <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205966:	5971                	li	s2,-4
ffffffffc0205968:	bfe5                	j	ffffffffc0205960 <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc020596a:	0289b603          	ld	a2,40(s3)
ffffffffc020596e:	0209b783          	ld	a5,32(s3)
ffffffffc0205972:	1cf66d63          	bltu	a2,a5,ffffffffc0205b4c <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205976:	0049a783          	lw	a5,4(s3)
ffffffffc020597a:	0017f693          	andi	a3,a5,1
ffffffffc020597e:	c291                	beqz	a3,ffffffffc0205982 <do_execve+0x296>
ffffffffc0205980:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205982:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205986:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205988:	e779                	bnez	a4,ffffffffc0205a56 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc020598a:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc020598c:	c781                	beqz	a5,ffffffffc0205994 <do_execve+0x2a8>
ffffffffc020598e:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205992:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205994:	0026f793          	andi	a5,a3,2
ffffffffc0205998:	e3f1                	bnez	a5,ffffffffc0205a5c <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc020599a:	0046f793          	andi	a5,a3,4
ffffffffc020599e:	c399                	beqz	a5,ffffffffc02059a4 <do_execve+0x2b8>
ffffffffc02059a0:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc02059a4:	0109b583          	ld	a1,16(s3)
ffffffffc02059a8:	4701                	li	a4,0
ffffffffc02059aa:	8526                	mv	a0,s1
ffffffffc02059ac:	909fe0ef          	jal	ra,ffffffffc02042b4 <mm_map>
ffffffffc02059b0:	892a                	mv	s2,a0
ffffffffc02059b2:	ed35                	bnez	a0,ffffffffc0205a2e <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02059b4:	0109bb83          	ld	s7,16(s3)
ffffffffc02059b8:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc02059ba:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02059be:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02059c2:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc02059c6:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc02059c8:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc02059ca:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc02059cc:	054be963          	bltu	s7,s4,ffffffffc0205a1e <do_execve+0x332>
ffffffffc02059d0:	aa95                	j	ffffffffc0205b44 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02059d2:	6785                	lui	a5,0x1
ffffffffc02059d4:	415b8533          	sub	a0,s7,s5
ffffffffc02059d8:	9abe                	add	s5,s5,a5
ffffffffc02059da:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc02059de:	015a7463          	bgeu	s4,s5,ffffffffc02059e6 <do_execve+0x2fa>
                size -= la - end;
ffffffffc02059e2:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc02059e6:	000cb683          	ld	a3,0(s9)
ffffffffc02059ea:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc02059ec:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc02059f0:	40d406b3          	sub	a3,s0,a3
ffffffffc02059f4:	8699                	srai	a3,a3,0x6
ffffffffc02059f6:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02059f8:	67e2                	ld	a5,24(sp)
ffffffffc02059fa:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02059fe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a00:	14b87863          	bgeu	a6,a1,ffffffffc0205b50 <do_execve+0x464>
ffffffffc0205a04:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a08:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205a0a:	9bb2                	add	s7,s7,a2
ffffffffc0205a0c:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a0e:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205a10:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205a12:	353000ef          	jal	ra,ffffffffc0206564 <memcpy>
            start += size, from += size;
ffffffffc0205a16:	6622                	ld	a2,8(sp)
ffffffffc0205a18:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205a1a:	054bf363          	bgeu	s7,s4,ffffffffc0205a60 <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205a1e:	6c88                	ld	a0,24(s1)
ffffffffc0205a20:	866a                	mv	a2,s10
ffffffffc0205a22:	85d6                	mv	a1,s5
ffffffffc0205a24:	8d5fd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc0205a28:	842a                	mv	s0,a0
ffffffffc0205a2a:	f545                	bnez	a0,ffffffffc02059d2 <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0205a2c:	5971                	li	s2,-4
    exit_mmap(mm);
ffffffffc0205a2e:	8526                	mv	a0,s1
ffffffffc0205a30:	9cffe0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
    put_pgdir(mm);
ffffffffc0205a34:	8526                	mv	a0,s1
ffffffffc0205a36:	b36ff0ef          	jal	ra,ffffffffc0204d6c <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a3a:	8526                	mv	a0,s1
ffffffffc0205a3c:	827fe0ef          	jal	ra,ffffffffc0204262 <mm_destroy>
    return ret;
ffffffffc0205a40:	b705                	j	ffffffffc0205960 <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0205a42:	854e                	mv	a0,s3
ffffffffc0205a44:	9bbfe0ef          	jal	ra,ffffffffc02043fe <exit_mmap>
            put_pgdir(mm);
ffffffffc0205a48:	854e                	mv	a0,s3
ffffffffc0205a4a:	b22ff0ef          	jal	ra,ffffffffc0204d6c <put_pgdir>
            mm_destroy(mm);
ffffffffc0205a4e:	854e                	mv	a0,s3
ffffffffc0205a50:	813fe0ef          	jal	ra,ffffffffc0204262 <mm_destroy>
ffffffffc0205a54:	b32d                	j	ffffffffc020577e <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a56:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a5a:	fb95                	bnez	a5,ffffffffc020598e <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a5c:	4d5d                	li	s10,23
ffffffffc0205a5e:	bf35                	j	ffffffffc020599a <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205a60:	0109b683          	ld	a3,16(s3)
ffffffffc0205a64:	0289b903          	ld	s2,40(s3)
ffffffffc0205a68:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205a6a:	075bfd63          	bgeu	s7,s5,ffffffffc0205ae4 <do_execve+0x3f8>
            if (start == end) {
ffffffffc0205a6e:	db790fe3          	beq	s2,s7,ffffffffc020582c <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205a72:	6785                	lui	a5,0x1
ffffffffc0205a74:	00fb8533          	add	a0,s7,a5
ffffffffc0205a78:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205a7c:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205a80:	0b597d63          	bgeu	s2,s5,ffffffffc0205b3a <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0205a84:	000cb683          	ld	a3,0(s9)
ffffffffc0205a88:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205a8a:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205a8e:	40d406b3          	sub	a3,s0,a3
ffffffffc0205a92:	8699                	srai	a3,a3,0x6
ffffffffc0205a94:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205a96:	67e2                	ld	a5,24(sp)
ffffffffc0205a98:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a9c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a9e:	0ac5f963          	bgeu	a1,a2,ffffffffc0205b50 <do_execve+0x464>
ffffffffc0205aa2:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205aa6:	8652                	mv	a2,s4
ffffffffc0205aa8:	4581                	li	a1,0
ffffffffc0205aaa:	96c2                	add	a3,a3,a6
ffffffffc0205aac:	9536                	add	a0,a0,a3
ffffffffc0205aae:	2a5000ef          	jal	ra,ffffffffc0206552 <memset>
            start += size;
ffffffffc0205ab2:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205ab6:	03597463          	bgeu	s2,s5,ffffffffc0205ade <do_execve+0x3f2>
ffffffffc0205aba:	d6e909e3          	beq	s2,a4,ffffffffc020582c <do_execve+0x140>
ffffffffc0205abe:	00003697          	auipc	a3,0x3
ffffffffc0205ac2:	ad268693          	addi	a3,a3,-1326 # ffffffffc0208590 <default_pmm_manager+0x12c0>
ffffffffc0205ac6:	00001617          	auipc	a2,0x1
ffffffffc0205aca:	17260613          	addi	a2,a2,370 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205ace:	25800593          	li	a1,600
ffffffffc0205ad2:	00003517          	auipc	a0,0x3
ffffffffc0205ad6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205ada:	9a1fa0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0205ade:	ff5710e3          	bne	a4,s5,ffffffffc0205abe <do_execve+0x3d2>
ffffffffc0205ae2:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205ae4:	d52bf4e3          	bgeu	s7,s2,ffffffffc020582c <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205ae8:	6c88                	ld	a0,24(s1)
ffffffffc0205aea:	866a                	mv	a2,s10
ffffffffc0205aec:	85d6                	mv	a1,s5
ffffffffc0205aee:	80bfd0ef          	jal	ra,ffffffffc02032f8 <pgdir_alloc_page>
ffffffffc0205af2:	842a                	mv	s0,a0
ffffffffc0205af4:	dd05                	beqz	a0,ffffffffc0205a2c <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205af6:	6785                	lui	a5,0x1
ffffffffc0205af8:	415b8533          	sub	a0,s7,s5
ffffffffc0205afc:	9abe                	add	s5,s5,a5
ffffffffc0205afe:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205b02:	01597463          	bgeu	s2,s5,ffffffffc0205b0a <do_execve+0x41e>
                size -= la - end;
ffffffffc0205b06:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205b0a:	000cb683          	ld	a3,0(s9)
ffffffffc0205b0e:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b10:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205b14:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b18:	8699                	srai	a3,a3,0x6
ffffffffc0205b1a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b1c:	67e2                	ld	a5,24(sp)
ffffffffc0205b1e:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b22:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b24:	02b87663          	bgeu	a6,a1,ffffffffc0205b50 <do_execve+0x464>
ffffffffc0205b28:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b2c:	4581                	li	a1,0
            start += size;
ffffffffc0205b2e:	9bb2                	add	s7,s7,a2
ffffffffc0205b30:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b32:	9536                	add	a0,a0,a3
ffffffffc0205b34:	21f000ef          	jal	ra,ffffffffc0206552 <memset>
ffffffffc0205b38:	b775                	j	ffffffffc0205ae4 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b3a:	417a8a33          	sub	s4,s5,s7
ffffffffc0205b3e:	b799                	j	ffffffffc0205a84 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0205b40:	5975                	li	s2,-3
ffffffffc0205b42:	b3c1                	j	ffffffffc0205902 <do_execve+0x216>
        while (start < end) {
ffffffffc0205b44:	86de                	mv	a3,s7
ffffffffc0205b46:	bf39                	j	ffffffffc0205a64 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0205b48:	5971                	li	s2,-4
ffffffffc0205b4a:	bdc5                	j	ffffffffc0205a3a <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205b4c:	5961                	li	s2,-8
ffffffffc0205b4e:	b5c5                	j	ffffffffc0205a2e <do_execve+0x342>
ffffffffc0205b50:	00001617          	auipc	a2,0x1
ffffffffc0205b54:	7b860613          	addi	a2,a2,1976 # ffffffffc0207308 <default_pmm_manager+0x38>
ffffffffc0205b58:	06900593          	li	a1,105
ffffffffc0205b5c:	00001517          	auipc	a0,0x1
ffffffffc0205b60:	7d450513          	addi	a0,a0,2004 # ffffffffc0207330 <default_pmm_manager+0x60>
ffffffffc0205b64:	917fa0ef          	jal	ra,ffffffffc020047a <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b68:	00002617          	auipc	a2,0x2
ffffffffc0205b6c:	84860613          	addi	a2,a2,-1976 # ffffffffc02073b0 <default_pmm_manager+0xe0>
ffffffffc0205b70:	27300593          	li	a1,627
ffffffffc0205b74:	00003517          	auipc	a0,0x3
ffffffffc0205b78:	80c50513          	addi	a0,a0,-2036 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205b7c:	8fffa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205b80:	00003697          	auipc	a3,0x3
ffffffffc0205b84:	b2868693          	addi	a3,a3,-1240 # ffffffffc02086a8 <default_pmm_manager+0x13d8>
ffffffffc0205b88:	00001617          	auipc	a2,0x1
ffffffffc0205b8c:	0b060613          	addi	a2,a2,176 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205b90:	26e00593          	li	a1,622
ffffffffc0205b94:	00002517          	auipc	a0,0x2
ffffffffc0205b98:	7ec50513          	addi	a0,a0,2028 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205b9c:	8dffa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ba0:	00003697          	auipc	a3,0x3
ffffffffc0205ba4:	ac068693          	addi	a3,a3,-1344 # ffffffffc0208660 <default_pmm_manager+0x1390>
ffffffffc0205ba8:	00001617          	auipc	a2,0x1
ffffffffc0205bac:	09060613          	addi	a2,a2,144 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205bb0:	26d00593          	li	a1,621
ffffffffc0205bb4:	00002517          	auipc	a0,0x2
ffffffffc0205bb8:	7cc50513          	addi	a0,a0,1996 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205bbc:	8bffa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205bc0:	00003697          	auipc	a3,0x3
ffffffffc0205bc4:	a5868693          	addi	a3,a3,-1448 # ffffffffc0208618 <default_pmm_manager+0x1348>
ffffffffc0205bc8:	00001617          	auipc	a2,0x1
ffffffffc0205bcc:	07060613          	addi	a2,a2,112 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205bd0:	26c00593          	li	a1,620
ffffffffc0205bd4:	00002517          	auipc	a0,0x2
ffffffffc0205bd8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205bdc:	89ffa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205be0:	00003697          	auipc	a3,0x3
ffffffffc0205be4:	9f068693          	addi	a3,a3,-1552 # ffffffffc02085d0 <default_pmm_manager+0x1300>
ffffffffc0205be8:	00001617          	auipc	a2,0x1
ffffffffc0205bec:	05060613          	addi	a2,a2,80 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205bf0:	26b00593          	li	a1,619
ffffffffc0205bf4:	00002517          	auipc	a0,0x2
ffffffffc0205bf8:	78c50513          	addi	a0,a0,1932 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205bfc:	87ffa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205c00 <do_yield>:
    current->need_resched = 1;
ffffffffc0205c00:	000ad797          	auipc	a5,0xad
ffffffffc0205c04:	e907b783          	ld	a5,-368(a5) # ffffffffc02b2a90 <current>
ffffffffc0205c08:	4705                	li	a4,1
ffffffffc0205c0a:	ef98                	sd	a4,24(a5)
}
ffffffffc0205c0c:	4501                	li	a0,0
ffffffffc0205c0e:	8082                	ret

ffffffffc0205c10 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205c10:	1101                	addi	sp,sp,-32
ffffffffc0205c12:	e822                	sd	s0,16(sp)
ffffffffc0205c14:	e426                	sd	s1,8(sp)
ffffffffc0205c16:	ec06                	sd	ra,24(sp)
ffffffffc0205c18:	842e                	mv	s0,a1
ffffffffc0205c1a:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205c1c:	c999                	beqz	a1,ffffffffc0205c32 <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205c1e:	000ad797          	auipc	a5,0xad
ffffffffc0205c22:	e727b783          	ld	a5,-398(a5) # ffffffffc02b2a90 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205c26:	7788                	ld	a0,40(a5)
ffffffffc0205c28:	4685                	li	a3,1
ffffffffc0205c2a:	4611                	li	a2,4
ffffffffc0205c2c:	e57fe0ef          	jal	ra,ffffffffc0204a82 <user_mem_check>
ffffffffc0205c30:	c909                	beqz	a0,ffffffffc0205c42 <do_wait+0x32>
ffffffffc0205c32:	85a2                	mv	a1,s0
}
ffffffffc0205c34:	6442                	ld	s0,16(sp)
ffffffffc0205c36:	60e2                	ld	ra,24(sp)
ffffffffc0205c38:	8526                	mv	a0,s1
ffffffffc0205c3a:	64a2                	ld	s1,8(sp)
ffffffffc0205c3c:	6105                	addi	sp,sp,32
ffffffffc0205c3e:	fb8ff06f          	j	ffffffffc02053f6 <do_wait.part.0>
ffffffffc0205c42:	60e2                	ld	ra,24(sp)
ffffffffc0205c44:	6442                	ld	s0,16(sp)
ffffffffc0205c46:	64a2                	ld	s1,8(sp)
ffffffffc0205c48:	5575                	li	a0,-3
ffffffffc0205c4a:	6105                	addi	sp,sp,32
ffffffffc0205c4c:	8082                	ret

ffffffffc0205c4e <do_kill>:
do_kill(int pid) {
ffffffffc0205c4e:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205c50:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205c52:	e406                	sd	ra,8(sp)
ffffffffc0205c54:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205c56:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205c5a:	17f9                	addi	a5,a5,-2
ffffffffc0205c5c:	02e7e963          	bltu	a5,a4,ffffffffc0205c8e <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205c60:	842a                	mv	s0,a0
ffffffffc0205c62:	45a9                	li	a1,10
ffffffffc0205c64:	2501                	sext.w	a0,a0
ffffffffc0205c66:	46c000ef          	jal	ra,ffffffffc02060d2 <hash32>
ffffffffc0205c6a:	02051793          	slli	a5,a0,0x20
ffffffffc0205c6e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205c72:	000a9797          	auipc	a5,0xa9
ffffffffc0205c76:	d9678793          	addi	a5,a5,-618 # ffffffffc02aea08 <hash_list>
ffffffffc0205c7a:	953e                	add	a0,a0,a5
ffffffffc0205c7c:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205c7e:	a029                	j	ffffffffc0205c88 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205c80:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205c84:	00870b63          	beq	a4,s0,ffffffffc0205c9a <do_kill+0x4c>
ffffffffc0205c88:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205c8a:	fef51be3          	bne	a0,a5,ffffffffc0205c80 <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205c8e:	5475                	li	s0,-3
}
ffffffffc0205c90:	60a2                	ld	ra,8(sp)
ffffffffc0205c92:	8522                	mv	a0,s0
ffffffffc0205c94:	6402                	ld	s0,0(sp)
ffffffffc0205c96:	0141                	addi	sp,sp,16
ffffffffc0205c98:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205c9a:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205c9e:	00177693          	andi	a3,a4,1
ffffffffc0205ca2:	e295                	bnez	a3,ffffffffc0205cc6 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205ca4:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205ca6:	00176713          	ori	a4,a4,1
ffffffffc0205caa:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205cae:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205cb0:	fe06d0e3          	bgez	a3,ffffffffc0205c90 <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205cb4:	f2878513          	addi	a0,a5,-216
ffffffffc0205cb8:	22e000ef          	jal	ra,ffffffffc0205ee6 <wakeup_proc>
}
ffffffffc0205cbc:	60a2                	ld	ra,8(sp)
ffffffffc0205cbe:	8522                	mv	a0,s0
ffffffffc0205cc0:	6402                	ld	s0,0(sp)
ffffffffc0205cc2:	0141                	addi	sp,sp,16
ffffffffc0205cc4:	8082                	ret
        return -E_KILLED;
ffffffffc0205cc6:	545d                	li	s0,-9
ffffffffc0205cc8:	b7e1                	j	ffffffffc0205c90 <do_kill+0x42>

ffffffffc0205cca <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205cca:	1101                	addi	sp,sp,-32
ffffffffc0205ccc:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205cce:	000ad797          	auipc	a5,0xad
ffffffffc0205cd2:	d3a78793          	addi	a5,a5,-710 # ffffffffc02b2a08 <proc_list>
ffffffffc0205cd6:	ec06                	sd	ra,24(sp)
ffffffffc0205cd8:	e822                	sd	s0,16(sp)
ffffffffc0205cda:	e04a                	sd	s2,0(sp)
ffffffffc0205cdc:	000a9497          	auipc	s1,0xa9
ffffffffc0205ce0:	d2c48493          	addi	s1,s1,-724 # ffffffffc02aea08 <hash_list>
ffffffffc0205ce4:	e79c                	sd	a5,8(a5)
ffffffffc0205ce6:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205ce8:	000ad717          	auipc	a4,0xad
ffffffffc0205cec:	d2070713          	addi	a4,a4,-736 # ffffffffc02b2a08 <proc_list>
ffffffffc0205cf0:	87a6                	mv	a5,s1
ffffffffc0205cf2:	e79c                	sd	a5,8(a5)
ffffffffc0205cf4:	e39c                	sd	a5,0(a5)
ffffffffc0205cf6:	07c1                	addi	a5,a5,16
ffffffffc0205cf8:	fef71de3          	bne	a4,a5,ffffffffc0205cf2 <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205cfc:	f77fe0ef          	jal	ra,ffffffffc0204c72 <alloc_proc>
ffffffffc0205d00:	000ad917          	auipc	s2,0xad
ffffffffc0205d04:	d9890913          	addi	s2,s2,-616 # ffffffffc02b2a98 <idleproc>
ffffffffc0205d08:	00a93023          	sd	a0,0(s2)
ffffffffc0205d0c:	0e050f63          	beqz	a0,ffffffffc0205e0a <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205d10:	4789                	li	a5,2
ffffffffc0205d12:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d14:	00003797          	auipc	a5,0x3
ffffffffc0205d18:	2ec78793          	addi	a5,a5,748 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d1c:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205d20:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205d22:	4785                	li	a5,1
ffffffffc0205d24:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205d26:	4641                	li	a2,16
ffffffffc0205d28:	4581                	li	a1,0
ffffffffc0205d2a:	8522                	mv	a0,s0
ffffffffc0205d2c:	027000ef          	jal	ra,ffffffffc0206552 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205d30:	463d                	li	a2,15
ffffffffc0205d32:	00003597          	auipc	a1,0x3
ffffffffc0205d36:	9d658593          	addi	a1,a1,-1578 # ffffffffc0208708 <default_pmm_manager+0x1438>
ffffffffc0205d3a:	8522                	mv	a0,s0
ffffffffc0205d3c:	029000ef          	jal	ra,ffffffffc0206564 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205d40:	000ad717          	auipc	a4,0xad
ffffffffc0205d44:	d6870713          	addi	a4,a4,-664 # ffffffffc02b2aa8 <nr_process>
ffffffffc0205d48:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205d4a:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205d4e:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205d50:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205d52:	4581                	li	a1,0
ffffffffc0205d54:	00000517          	auipc	a0,0x0
ffffffffc0205d58:	87450513          	addi	a0,a0,-1932 # ffffffffc02055c8 <init_main>
    nr_process ++;
ffffffffc0205d5c:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205d5e:	000ad797          	auipc	a5,0xad
ffffffffc0205d62:	d2d7b923          	sd	a3,-718(a5) # ffffffffc02b2a90 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205d66:	cf6ff0ef          	jal	ra,ffffffffc020525c <kernel_thread>
ffffffffc0205d6a:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205d6c:	08a05363          	blez	a0,ffffffffc0205df2 <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d70:	6789                	lui	a5,0x2
ffffffffc0205d72:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d76:	17f9                	addi	a5,a5,-2
ffffffffc0205d78:	2501                	sext.w	a0,a0
ffffffffc0205d7a:	02e7e363          	bltu	a5,a4,ffffffffc0205da0 <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d7e:	45a9                	li	a1,10
ffffffffc0205d80:	352000ef          	jal	ra,ffffffffc02060d2 <hash32>
ffffffffc0205d84:	02051793          	slli	a5,a0,0x20
ffffffffc0205d88:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205d8c:	96a6                	add	a3,a3,s1
ffffffffc0205d8e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205d90:	a029                	j	ffffffffc0205d9a <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205d92:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7cac>
ffffffffc0205d96:	04870b63          	beq	a4,s0,ffffffffc0205dec <proc_init+0x122>
    return listelm->next;
ffffffffc0205d9a:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205d9c:	fef69be3          	bne	a3,a5,ffffffffc0205d92 <proc_init+0xc8>
    return NULL;
ffffffffc0205da0:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205da2:	0b478493          	addi	s1,a5,180
ffffffffc0205da6:	4641                	li	a2,16
ffffffffc0205da8:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205daa:	000ad417          	auipc	s0,0xad
ffffffffc0205dae:	cf640413          	addi	s0,s0,-778 # ffffffffc02b2aa0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205db2:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205db4:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205db6:	79c000ef          	jal	ra,ffffffffc0206552 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205dba:	463d                	li	a2,15
ffffffffc0205dbc:	00003597          	auipc	a1,0x3
ffffffffc0205dc0:	97458593          	addi	a1,a1,-1676 # ffffffffc0208730 <default_pmm_manager+0x1460>
ffffffffc0205dc4:	8526                	mv	a0,s1
ffffffffc0205dc6:	79e000ef          	jal	ra,ffffffffc0206564 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205dca:	00093783          	ld	a5,0(s2)
ffffffffc0205dce:	cbb5                	beqz	a5,ffffffffc0205e42 <proc_init+0x178>
ffffffffc0205dd0:	43dc                	lw	a5,4(a5)
ffffffffc0205dd2:	eba5                	bnez	a5,ffffffffc0205e42 <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205dd4:	601c                	ld	a5,0(s0)
ffffffffc0205dd6:	c7b1                	beqz	a5,ffffffffc0205e22 <proc_init+0x158>
ffffffffc0205dd8:	43d8                	lw	a4,4(a5)
ffffffffc0205dda:	4785                	li	a5,1
ffffffffc0205ddc:	04f71363          	bne	a4,a5,ffffffffc0205e22 <proc_init+0x158>
}
ffffffffc0205de0:	60e2                	ld	ra,24(sp)
ffffffffc0205de2:	6442                	ld	s0,16(sp)
ffffffffc0205de4:	64a2                	ld	s1,8(sp)
ffffffffc0205de6:	6902                	ld	s2,0(sp)
ffffffffc0205de8:	6105                	addi	sp,sp,32
ffffffffc0205dea:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205dec:	f2878793          	addi	a5,a5,-216
ffffffffc0205df0:	bf4d                	j	ffffffffc0205da2 <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205df2:	00003617          	auipc	a2,0x3
ffffffffc0205df6:	91e60613          	addi	a2,a2,-1762 # ffffffffc0208710 <default_pmm_manager+0x1440>
ffffffffc0205dfa:	37c00593          	li	a1,892
ffffffffc0205dfe:	00002517          	auipc	a0,0x2
ffffffffc0205e02:	58250513          	addi	a0,a0,1410 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205e06:	e74fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205e0a:	00003617          	auipc	a2,0x3
ffffffffc0205e0e:	8e660613          	addi	a2,a2,-1818 # ffffffffc02086f0 <default_pmm_manager+0x1420>
ffffffffc0205e12:	36e00593          	li	a1,878
ffffffffc0205e16:	00002517          	auipc	a0,0x2
ffffffffc0205e1a:	56a50513          	addi	a0,a0,1386 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205e1e:	e5cfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e22:	00003697          	auipc	a3,0x3
ffffffffc0205e26:	93e68693          	addi	a3,a3,-1730 # ffffffffc0208760 <default_pmm_manager+0x1490>
ffffffffc0205e2a:	00001617          	auipc	a2,0x1
ffffffffc0205e2e:	e0e60613          	addi	a2,a2,-498 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205e32:	38300593          	li	a1,899
ffffffffc0205e36:	00002517          	auipc	a0,0x2
ffffffffc0205e3a:	54a50513          	addi	a0,a0,1354 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205e3e:	e3cfa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e42:	00003697          	auipc	a3,0x3
ffffffffc0205e46:	8f668693          	addi	a3,a3,-1802 # ffffffffc0208738 <default_pmm_manager+0x1468>
ffffffffc0205e4a:	00001617          	auipc	a2,0x1
ffffffffc0205e4e:	dee60613          	addi	a2,a2,-530 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205e52:	38200593          	li	a1,898
ffffffffc0205e56:	00002517          	auipc	a0,0x2
ffffffffc0205e5a:	52a50513          	addi	a0,a0,1322 # ffffffffc0208380 <default_pmm_manager+0x10b0>
ffffffffc0205e5e:	e1cfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205e62 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205e62:	1141                	addi	sp,sp,-16
ffffffffc0205e64:	e022                	sd	s0,0(sp)
ffffffffc0205e66:	e406                	sd	ra,8(sp)
ffffffffc0205e68:	000ad417          	auipc	s0,0xad
ffffffffc0205e6c:	c2840413          	addi	s0,s0,-984 # ffffffffc02b2a90 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205e70:	6018                	ld	a4,0(s0)
ffffffffc0205e72:	6f1c                	ld	a5,24(a4)
ffffffffc0205e74:	dffd                	beqz	a5,ffffffffc0205e72 <cpu_idle+0x10>
            schedule();
ffffffffc0205e76:	0f0000ef          	jal	ra,ffffffffc0205f66 <schedule>
ffffffffc0205e7a:	bfdd                	j	ffffffffc0205e70 <cpu_idle+0xe>

ffffffffc0205e7c <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205e7c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205e80:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205e84:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205e86:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205e88:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205e8c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205e90:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205e94:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205e98:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205e9c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205ea0:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205ea4:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205ea8:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205eac:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205eb0:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205eb4:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205eb8:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205eba:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205ebc:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205ec0:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205ec4:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205ec8:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205ecc:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205ed0:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205ed4:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205ed8:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205edc:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205ee0:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205ee4:	8082                	ret

ffffffffc0205ee6 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ee6:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205ee8:	1101                	addi	sp,sp,-32
ffffffffc0205eea:	ec06                	sd	ra,24(sp)
ffffffffc0205eec:	e822                	sd	s0,16(sp)
ffffffffc0205eee:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ef0:	478d                	li	a5,3
ffffffffc0205ef2:	04f70b63          	beq	a4,a5,ffffffffc0205f48 <wakeup_proc+0x62>
ffffffffc0205ef6:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ef8:	100027f3          	csrr	a5,sstatus
ffffffffc0205efc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205efe:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f00:	ef9d                	bnez	a5,ffffffffc0205f3e <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f02:	4789                	li	a5,2
ffffffffc0205f04:	02f70163          	beq	a4,a5,ffffffffc0205f26 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f08:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0205f0a:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc0205f0e:	e491                	bnez	s1,ffffffffc0205f1a <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f10:	60e2                	ld	ra,24(sp)
ffffffffc0205f12:	6442                	ld	s0,16(sp)
ffffffffc0205f14:	64a2                	ld	s1,8(sp)
ffffffffc0205f16:	6105                	addi	sp,sp,32
ffffffffc0205f18:	8082                	ret
ffffffffc0205f1a:	6442                	ld	s0,16(sp)
ffffffffc0205f1c:	60e2                	ld	ra,24(sp)
ffffffffc0205f1e:	64a2                	ld	s1,8(sp)
ffffffffc0205f20:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f22:	f1efa06f          	j	ffffffffc0200640 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f26:	00003617          	auipc	a2,0x3
ffffffffc0205f2a:	89a60613          	addi	a2,a2,-1894 # ffffffffc02087c0 <default_pmm_manager+0x14f0>
ffffffffc0205f2e:	45c9                	li	a1,18
ffffffffc0205f30:	00003517          	auipc	a0,0x3
ffffffffc0205f34:	87850513          	addi	a0,a0,-1928 # ffffffffc02087a8 <default_pmm_manager+0x14d8>
ffffffffc0205f38:	daafa0ef          	jal	ra,ffffffffc02004e2 <__warn>
ffffffffc0205f3c:	bfc9                	j	ffffffffc0205f0e <wakeup_proc+0x28>
        intr_disable();
ffffffffc0205f3e:	f08fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f42:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0205f44:	4485                	li	s1,1
ffffffffc0205f46:	bf75                	j	ffffffffc0205f02 <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f48:	00003697          	auipc	a3,0x3
ffffffffc0205f4c:	84068693          	addi	a3,a3,-1984 # ffffffffc0208788 <default_pmm_manager+0x14b8>
ffffffffc0205f50:	00001617          	auipc	a2,0x1
ffffffffc0205f54:	ce860613          	addi	a2,a2,-792 # ffffffffc0206c38 <commands+0x450>
ffffffffc0205f58:	45a5                	li	a1,9
ffffffffc0205f5a:	00003517          	auipc	a0,0x3
ffffffffc0205f5e:	84e50513          	addi	a0,a0,-1970 # ffffffffc02087a8 <default_pmm_manager+0x14d8>
ffffffffc0205f62:	d18fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205f66 <schedule>:

void
schedule(void) {
ffffffffc0205f66:	1141                	addi	sp,sp,-16
ffffffffc0205f68:	e406                	sd	ra,8(sp)
ffffffffc0205f6a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f6c:	100027f3          	csrr	a5,sstatus
ffffffffc0205f70:	8b89                	andi	a5,a5,2
ffffffffc0205f72:	4401                	li	s0,0
ffffffffc0205f74:	efbd                	bnez	a5,ffffffffc0205ff2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205f76:	000ad897          	auipc	a7,0xad
ffffffffc0205f7a:	b1a8b883          	ld	a7,-1254(a7) # ffffffffc02b2a90 <current>
ffffffffc0205f7e:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205f82:	000ad517          	auipc	a0,0xad
ffffffffc0205f86:	b1653503          	ld	a0,-1258(a0) # ffffffffc02b2a98 <idleproc>
ffffffffc0205f8a:	04a88e63          	beq	a7,a0,ffffffffc0205fe6 <schedule+0x80>
ffffffffc0205f8e:	0c888693          	addi	a3,a7,200
ffffffffc0205f92:	000ad617          	auipc	a2,0xad
ffffffffc0205f96:	a7660613          	addi	a2,a2,-1418 # ffffffffc02b2a08 <proc_list>
        le = last;
ffffffffc0205f9a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205f9c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205f9e:	4809                	li	a6,2
ffffffffc0205fa0:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205fa2:	00c78863          	beq	a5,a2,ffffffffc0205fb2 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fa6:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205faa:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fae:	03070163          	beq	a4,a6,ffffffffc0205fd0 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205fb2:	fef697e3          	bne	a3,a5,ffffffffc0205fa0 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fb6:	ed89                	bnez	a1,ffffffffc0205fd0 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205fb8:	451c                	lw	a5,8(a0)
ffffffffc0205fba:	2785                	addiw	a5,a5,1
ffffffffc0205fbc:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205fbe:	00a88463          	beq	a7,a0,ffffffffc0205fc6 <schedule+0x60>
            proc_run(next);
ffffffffc0205fc2:	e21fe0ef          	jal	ra,ffffffffc0204de2 <proc_run>
    if (flag) {
ffffffffc0205fc6:	e819                	bnez	s0,ffffffffc0205fdc <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205fc8:	60a2                	ld	ra,8(sp)
ffffffffc0205fca:	6402                	ld	s0,0(sp)
ffffffffc0205fcc:	0141                	addi	sp,sp,16
ffffffffc0205fce:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fd0:	4198                	lw	a4,0(a1)
ffffffffc0205fd2:	4789                	li	a5,2
ffffffffc0205fd4:	fef712e3          	bne	a4,a5,ffffffffc0205fb8 <schedule+0x52>
ffffffffc0205fd8:	852e                	mv	a0,a1
ffffffffc0205fda:	bff9                	j	ffffffffc0205fb8 <schedule+0x52>
}
ffffffffc0205fdc:	6402                	ld	s0,0(sp)
ffffffffc0205fde:	60a2                	ld	ra,8(sp)
ffffffffc0205fe0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205fe2:	e5efa06f          	j	ffffffffc0200640 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fe6:	000ad617          	auipc	a2,0xad
ffffffffc0205fea:	a2260613          	addi	a2,a2,-1502 # ffffffffc02b2a08 <proc_list>
ffffffffc0205fee:	86b2                	mv	a3,a2
ffffffffc0205ff0:	b76d                	j	ffffffffc0205f9a <schedule+0x34>
        intr_disable();
ffffffffc0205ff2:	e54fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205ff6:	4405                	li	s0,1
ffffffffc0205ff8:	bfbd                	j	ffffffffc0205f76 <schedule+0x10>

ffffffffc0205ffa <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205ffa:	000ad797          	auipc	a5,0xad
ffffffffc0205ffe:	a967b783          	ld	a5,-1386(a5) # ffffffffc02b2a90 <current>
}
ffffffffc0206002:	43c8                	lw	a0,4(a5)
ffffffffc0206004:	8082                	ret

ffffffffc0206006 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206006:	4501                	li	a0,0
ffffffffc0206008:	8082                	ret

ffffffffc020600a <sys_putc>:
    cputchar(c);
ffffffffc020600a:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc020600c:	1141                	addi	sp,sp,-16
ffffffffc020600e:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0206010:	9a6fa0ef          	jal	ra,ffffffffc02001b6 <cputchar>
}
ffffffffc0206014:	60a2                	ld	ra,8(sp)
ffffffffc0206016:	4501                	li	a0,0
ffffffffc0206018:	0141                	addi	sp,sp,16
ffffffffc020601a:	8082                	ret

ffffffffc020601c <sys_kill>:
    return do_kill(pid);
ffffffffc020601c:	4108                	lw	a0,0(a0)
ffffffffc020601e:	c31ff06f          	j	ffffffffc0205c4e <do_kill>

ffffffffc0206022 <sys_yield>:
    return do_yield();
ffffffffc0206022:	bdfff06f          	j	ffffffffc0205c00 <do_yield>

ffffffffc0206026 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206026:	6d14                	ld	a3,24(a0)
ffffffffc0206028:	6910                	ld	a2,16(a0)
ffffffffc020602a:	650c                	ld	a1,8(a0)
ffffffffc020602c:	6108                	ld	a0,0(a0)
ffffffffc020602e:	ebeff06f          	j	ffffffffc02056ec <do_execve>

ffffffffc0206032 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206032:	650c                	ld	a1,8(a0)
ffffffffc0206034:	4108                	lw	a0,0(a0)
ffffffffc0206036:	bdbff06f          	j	ffffffffc0205c10 <do_wait>

ffffffffc020603a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020603a:	000ad797          	auipc	a5,0xad
ffffffffc020603e:	a567b783          	ld	a5,-1450(a5) # ffffffffc02b2a90 <current>
ffffffffc0206042:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206044:	4501                	li	a0,0
ffffffffc0206046:	6a0c                	ld	a1,16(a2)
ffffffffc0206048:	e07fe06f          	j	ffffffffc0204e4e <do_fork>

ffffffffc020604c <sys_exit>:
    return do_exit(error_code);
ffffffffc020604c:	4108                	lw	a0,0(a0)
ffffffffc020604e:	a5eff06f          	j	ffffffffc02052ac <do_exit>

ffffffffc0206052 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206052:	715d                	addi	sp,sp,-80
ffffffffc0206054:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206056:	000ad497          	auipc	s1,0xad
ffffffffc020605a:	a3a48493          	addi	s1,s1,-1478 # ffffffffc02b2a90 <current>
ffffffffc020605e:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206060:	e0a2                	sd	s0,64(sp)
ffffffffc0206062:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206064:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206066:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206068:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020606a:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020606e:	0327ee63          	bltu	a5,s2,ffffffffc02060aa <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206072:	00391713          	slli	a4,s2,0x3
ffffffffc0206076:	00002797          	auipc	a5,0x2
ffffffffc020607a:	7b278793          	addi	a5,a5,1970 # ffffffffc0208828 <syscalls>
ffffffffc020607e:	97ba                	add	a5,a5,a4
ffffffffc0206080:	639c                	ld	a5,0(a5)
ffffffffc0206082:	c785                	beqz	a5,ffffffffc02060aa <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206084:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206086:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0206088:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020608a:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020608c:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc020608e:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206090:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206092:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206094:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206096:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206098:	0028                	addi	a0,sp,8
ffffffffc020609a:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc020609c:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020609e:	e828                	sd	a0,80(s0)
}
ffffffffc02060a0:	6406                	ld	s0,64(sp)
ffffffffc02060a2:	74e2                	ld	s1,56(sp)
ffffffffc02060a4:	7942                	ld	s2,48(sp)
ffffffffc02060a6:	6161                	addi	sp,sp,80
ffffffffc02060a8:	8082                	ret
    print_trapframe(tf);
ffffffffc02060aa:	8522                	mv	a0,s0
ffffffffc02060ac:	f88fa0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02060b0:	609c                	ld	a5,0(s1)
ffffffffc02060b2:	86ca                	mv	a3,s2
ffffffffc02060b4:	00002617          	auipc	a2,0x2
ffffffffc02060b8:	72c60613          	addi	a2,a2,1836 # ffffffffc02087e0 <default_pmm_manager+0x1510>
ffffffffc02060bc:	43d8                	lw	a4,4(a5)
ffffffffc02060be:	06200593          	li	a1,98
ffffffffc02060c2:	0b478793          	addi	a5,a5,180
ffffffffc02060c6:	00002517          	auipc	a0,0x2
ffffffffc02060ca:	74a50513          	addi	a0,a0,1866 # ffffffffc0208810 <default_pmm_manager+0x1540>
ffffffffc02060ce:	bacfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02060d2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02060d2:	9e3707b7          	lui	a5,0x9e370
ffffffffc02060d6:	2785                	addiw	a5,a5,1
ffffffffc02060d8:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc02060dc:	02000793          	li	a5,32
ffffffffc02060e0:	9f8d                	subw	a5,a5,a1
}
ffffffffc02060e2:	00f5553b          	srlw	a0,a0,a5
ffffffffc02060e6:	8082                	ret

ffffffffc02060e8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02060e8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060ec:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02060ee:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060f2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02060f4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02060f8:	f022                	sd	s0,32(sp)
ffffffffc02060fa:	ec26                	sd	s1,24(sp)
ffffffffc02060fc:	e84a                	sd	s2,16(sp)
ffffffffc02060fe:	f406                	sd	ra,40(sp)
ffffffffc0206100:	e44e                	sd	s3,8(sp)
ffffffffc0206102:	84aa                	mv	s1,a0
ffffffffc0206104:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206106:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020610a:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc020610c:	03067e63          	bgeu	a2,a6,ffffffffc0206148 <printnum+0x60>
ffffffffc0206110:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206112:	00805763          	blez	s0,ffffffffc0206120 <printnum+0x38>
ffffffffc0206116:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206118:	85ca                	mv	a1,s2
ffffffffc020611a:	854e                	mv	a0,s3
ffffffffc020611c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020611e:	fc65                	bnez	s0,ffffffffc0206116 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206120:	1a02                	slli	s4,s4,0x20
ffffffffc0206122:	00003797          	auipc	a5,0x3
ffffffffc0206126:	80678793          	addi	a5,a5,-2042 # ffffffffc0208928 <syscalls+0x100>
ffffffffc020612a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020612e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206130:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206132:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206136:	70a2                	ld	ra,40(sp)
ffffffffc0206138:	69a2                	ld	s3,8(sp)
ffffffffc020613a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020613c:	85ca                	mv	a1,s2
ffffffffc020613e:	87a6                	mv	a5,s1
}
ffffffffc0206140:	6942                	ld	s2,16(sp)
ffffffffc0206142:	64e2                	ld	s1,24(sp)
ffffffffc0206144:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206146:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206148:	03065633          	divu	a2,a2,a6
ffffffffc020614c:	8722                	mv	a4,s0
ffffffffc020614e:	f9bff0ef          	jal	ra,ffffffffc02060e8 <printnum>
ffffffffc0206152:	b7f9                	j	ffffffffc0206120 <printnum+0x38>

ffffffffc0206154 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206154:	7119                	addi	sp,sp,-128
ffffffffc0206156:	f4a6                	sd	s1,104(sp)
ffffffffc0206158:	f0ca                	sd	s2,96(sp)
ffffffffc020615a:	ecce                	sd	s3,88(sp)
ffffffffc020615c:	e8d2                	sd	s4,80(sp)
ffffffffc020615e:	e4d6                	sd	s5,72(sp)
ffffffffc0206160:	e0da                	sd	s6,64(sp)
ffffffffc0206162:	fc5e                	sd	s7,56(sp)
ffffffffc0206164:	f06a                	sd	s10,32(sp)
ffffffffc0206166:	fc86                	sd	ra,120(sp)
ffffffffc0206168:	f8a2                	sd	s0,112(sp)
ffffffffc020616a:	f862                	sd	s8,48(sp)
ffffffffc020616c:	f466                	sd	s9,40(sp)
ffffffffc020616e:	ec6e                	sd	s11,24(sp)
ffffffffc0206170:	892a                	mv	s2,a0
ffffffffc0206172:	84ae                	mv	s1,a1
ffffffffc0206174:	8d32                	mv	s10,a2
ffffffffc0206176:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206178:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020617c:	5b7d                	li	s6,-1
ffffffffc020617e:	00002a97          	auipc	s5,0x2
ffffffffc0206182:	7d6a8a93          	addi	s5,s5,2006 # ffffffffc0208954 <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206186:	00003b97          	auipc	s7,0x3
ffffffffc020618a:	9eab8b93          	addi	s7,s7,-1558 # ffffffffc0208b70 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020618e:	000d4503          	lbu	a0,0(s10)
ffffffffc0206192:	001d0413          	addi	s0,s10,1
ffffffffc0206196:	01350a63          	beq	a0,s3,ffffffffc02061aa <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020619a:	c121                	beqz	a0,ffffffffc02061da <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020619c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020619e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02061a0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02061a2:	fff44503          	lbu	a0,-1(s0)
ffffffffc02061a6:	ff351ae3          	bne	a0,s3,ffffffffc020619a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061aa:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02061ae:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02061b2:	4c81                	li	s9,0
ffffffffc02061b4:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02061b6:	5c7d                	li	s8,-1
ffffffffc02061b8:	5dfd                	li	s11,-1
ffffffffc02061ba:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02061be:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061c0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02061c4:	0ff5f593          	zext.b	a1,a1
ffffffffc02061c8:	00140d13          	addi	s10,s0,1
ffffffffc02061cc:	04b56263          	bltu	a0,a1,ffffffffc0206210 <vprintfmt+0xbc>
ffffffffc02061d0:	058a                	slli	a1,a1,0x2
ffffffffc02061d2:	95d6                	add	a1,a1,s5
ffffffffc02061d4:	4194                	lw	a3,0(a1)
ffffffffc02061d6:	96d6                	add	a3,a3,s5
ffffffffc02061d8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02061da:	70e6                	ld	ra,120(sp)
ffffffffc02061dc:	7446                	ld	s0,112(sp)
ffffffffc02061de:	74a6                	ld	s1,104(sp)
ffffffffc02061e0:	7906                	ld	s2,96(sp)
ffffffffc02061e2:	69e6                	ld	s3,88(sp)
ffffffffc02061e4:	6a46                	ld	s4,80(sp)
ffffffffc02061e6:	6aa6                	ld	s5,72(sp)
ffffffffc02061e8:	6b06                	ld	s6,64(sp)
ffffffffc02061ea:	7be2                	ld	s7,56(sp)
ffffffffc02061ec:	7c42                	ld	s8,48(sp)
ffffffffc02061ee:	7ca2                	ld	s9,40(sp)
ffffffffc02061f0:	7d02                	ld	s10,32(sp)
ffffffffc02061f2:	6de2                	ld	s11,24(sp)
ffffffffc02061f4:	6109                	addi	sp,sp,128
ffffffffc02061f6:	8082                	ret
            padc = '0';
ffffffffc02061f8:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02061fa:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061fe:	846a                	mv	s0,s10
ffffffffc0206200:	00140d13          	addi	s10,s0,1
ffffffffc0206204:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206208:	0ff5f593          	zext.b	a1,a1
ffffffffc020620c:	fcb572e3          	bgeu	a0,a1,ffffffffc02061d0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0206210:	85a6                	mv	a1,s1
ffffffffc0206212:	02500513          	li	a0,37
ffffffffc0206216:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206218:	fff44783          	lbu	a5,-1(s0)
ffffffffc020621c:	8d22                	mv	s10,s0
ffffffffc020621e:	f73788e3          	beq	a5,s3,ffffffffc020618e <vprintfmt+0x3a>
ffffffffc0206222:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206226:	1d7d                	addi	s10,s10,-1
ffffffffc0206228:	ff379de3          	bne	a5,s3,ffffffffc0206222 <vprintfmt+0xce>
ffffffffc020622c:	b78d                	j	ffffffffc020618e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020622e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0206232:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206236:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206238:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020623c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206240:	02d86463          	bltu	a6,a3,ffffffffc0206268 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0206244:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206248:	002c169b          	slliw	a3,s8,0x2
ffffffffc020624c:	0186873b          	addw	a4,a3,s8
ffffffffc0206250:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206254:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206256:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020625a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020625c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0206260:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206264:	fed870e3          	bgeu	a6,a3,ffffffffc0206244 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0206268:	f40ddce3          	bgez	s11,ffffffffc02061c0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020626c:	8de2                	mv	s11,s8
ffffffffc020626e:	5c7d                	li	s8,-1
ffffffffc0206270:	bf81                	j	ffffffffc02061c0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0206272:	fffdc693          	not	a3,s11
ffffffffc0206276:	96fd                	srai	a3,a3,0x3f
ffffffffc0206278:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020627c:	00144603          	lbu	a2,1(s0)
ffffffffc0206280:	2d81                	sext.w	s11,s11
ffffffffc0206282:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206284:	bf35                	j	ffffffffc02061c0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0206286:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020628a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020628e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206290:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0206292:	bfd9                	j	ffffffffc0206268 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0206294:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206296:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020629a:	01174463          	blt	a4,a7,ffffffffc02062a2 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020629e:	1a088e63          	beqz	a7,ffffffffc020645a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02062a2:	000a3603          	ld	a2,0(s4)
ffffffffc02062a6:	46c1                	li	a3,16
ffffffffc02062a8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02062aa:	2781                	sext.w	a5,a5
ffffffffc02062ac:	876e                	mv	a4,s11
ffffffffc02062ae:	85a6                	mv	a1,s1
ffffffffc02062b0:	854a                	mv	a0,s2
ffffffffc02062b2:	e37ff0ef          	jal	ra,ffffffffc02060e8 <printnum>
            break;
ffffffffc02062b6:	bde1                	j	ffffffffc020618e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02062b8:	000a2503          	lw	a0,0(s4)
ffffffffc02062bc:	85a6                	mv	a1,s1
ffffffffc02062be:	0a21                	addi	s4,s4,8
ffffffffc02062c0:	9902                	jalr	s2
            break;
ffffffffc02062c2:	b5f1                	j	ffffffffc020618e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02062c4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02062c6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02062ca:	01174463          	blt	a4,a7,ffffffffc02062d2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02062ce:	18088163          	beqz	a7,ffffffffc0206450 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02062d2:	000a3603          	ld	a2,0(s4)
ffffffffc02062d6:	46a9                	li	a3,10
ffffffffc02062d8:	8a2e                	mv	s4,a1
ffffffffc02062da:	bfc1                	j	ffffffffc02062aa <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062dc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02062e0:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062e2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062e4:	bdf1                	j	ffffffffc02061c0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02062e6:	85a6                	mv	a1,s1
ffffffffc02062e8:	02500513          	li	a0,37
ffffffffc02062ec:	9902                	jalr	s2
            break;
ffffffffc02062ee:	b545                	j	ffffffffc020618e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062f0:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02062f4:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062f6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02062f8:	b5e1                	j	ffffffffc02061c0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02062fa:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02062fc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206300:	01174463          	blt	a4,a7,ffffffffc0206308 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0206304:	14088163          	beqz	a7,ffffffffc0206446 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0206308:	000a3603          	ld	a2,0(s4)
ffffffffc020630c:	46a1                	li	a3,8
ffffffffc020630e:	8a2e                	mv	s4,a1
ffffffffc0206310:	bf69                	j	ffffffffc02062aa <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0206312:	03000513          	li	a0,48
ffffffffc0206316:	85a6                	mv	a1,s1
ffffffffc0206318:	e03e                	sd	a5,0(sp)
ffffffffc020631a:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020631c:	85a6                	mv	a1,s1
ffffffffc020631e:	07800513          	li	a0,120
ffffffffc0206322:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206324:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206326:	6782                	ld	a5,0(sp)
ffffffffc0206328:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020632a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020632e:	bfb5                	j	ffffffffc02062aa <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206330:	000a3403          	ld	s0,0(s4)
ffffffffc0206334:	008a0713          	addi	a4,s4,8
ffffffffc0206338:	e03a                	sd	a4,0(sp)
ffffffffc020633a:	14040263          	beqz	s0,ffffffffc020647e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020633e:	0fb05763          	blez	s11,ffffffffc020642c <vprintfmt+0x2d8>
ffffffffc0206342:	02d00693          	li	a3,45
ffffffffc0206346:	0cd79163          	bne	a5,a3,ffffffffc0206408 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020634a:	00044783          	lbu	a5,0(s0)
ffffffffc020634e:	0007851b          	sext.w	a0,a5
ffffffffc0206352:	cf85                	beqz	a5,ffffffffc020638a <vprintfmt+0x236>
ffffffffc0206354:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206358:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020635c:	000c4563          	bltz	s8,ffffffffc0206366 <vprintfmt+0x212>
ffffffffc0206360:	3c7d                	addiw	s8,s8,-1
ffffffffc0206362:	036c0263          	beq	s8,s6,ffffffffc0206386 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0206366:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206368:	0e0c8e63          	beqz	s9,ffffffffc0206464 <vprintfmt+0x310>
ffffffffc020636c:	3781                	addiw	a5,a5,-32
ffffffffc020636e:	0ef47b63          	bgeu	s0,a5,ffffffffc0206464 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0206372:	03f00513          	li	a0,63
ffffffffc0206376:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206378:	000a4783          	lbu	a5,0(s4)
ffffffffc020637c:	3dfd                	addiw	s11,s11,-1
ffffffffc020637e:	0a05                	addi	s4,s4,1
ffffffffc0206380:	0007851b          	sext.w	a0,a5
ffffffffc0206384:	ffe1                	bnez	a5,ffffffffc020635c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0206386:	01b05963          	blez	s11,ffffffffc0206398 <vprintfmt+0x244>
ffffffffc020638a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020638c:	85a6                	mv	a1,s1
ffffffffc020638e:	02000513          	li	a0,32
ffffffffc0206392:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206394:	fe0d9be3          	bnez	s11,ffffffffc020638a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206398:	6a02                	ld	s4,0(sp)
ffffffffc020639a:	bbd5                	j	ffffffffc020618e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020639c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020639e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02063a2:	01174463          	blt	a4,a7,ffffffffc02063aa <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02063a6:	08088d63          	beqz	a7,ffffffffc0206440 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02063aa:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02063ae:	0a044d63          	bltz	s0,ffffffffc0206468 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02063b2:	8622                	mv	a2,s0
ffffffffc02063b4:	8a66                	mv	s4,s9
ffffffffc02063b6:	46a9                	li	a3,10
ffffffffc02063b8:	bdcd                	j	ffffffffc02062aa <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02063ba:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063be:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02063c0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02063c2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02063c6:	8fb5                	xor	a5,a5,a3
ffffffffc02063c8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02063cc:	02d74163          	blt	a4,a3,ffffffffc02063ee <vprintfmt+0x29a>
ffffffffc02063d0:	00369793          	slli	a5,a3,0x3
ffffffffc02063d4:	97de                	add	a5,a5,s7
ffffffffc02063d6:	639c                	ld	a5,0(a5)
ffffffffc02063d8:	cb99                	beqz	a5,ffffffffc02063ee <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02063da:	86be                	mv	a3,a5
ffffffffc02063dc:	00000617          	auipc	a2,0x0
ffffffffc02063e0:	1cc60613          	addi	a2,a2,460 # ffffffffc02065a8 <etext+0x2c>
ffffffffc02063e4:	85a6                	mv	a1,s1
ffffffffc02063e6:	854a                	mv	a0,s2
ffffffffc02063e8:	0ce000ef          	jal	ra,ffffffffc02064b6 <printfmt>
ffffffffc02063ec:	b34d                	j	ffffffffc020618e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02063ee:	00002617          	auipc	a2,0x2
ffffffffc02063f2:	55a60613          	addi	a2,a2,1370 # ffffffffc0208948 <syscalls+0x120>
ffffffffc02063f6:	85a6                	mv	a1,s1
ffffffffc02063f8:	854a                	mv	a0,s2
ffffffffc02063fa:	0bc000ef          	jal	ra,ffffffffc02064b6 <printfmt>
ffffffffc02063fe:	bb41                	j	ffffffffc020618e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206400:	00002417          	auipc	s0,0x2
ffffffffc0206404:	54040413          	addi	s0,s0,1344 # ffffffffc0208940 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206408:	85e2                	mv	a1,s8
ffffffffc020640a:	8522                	mv	a0,s0
ffffffffc020640c:	e43e                	sd	a5,8(sp)
ffffffffc020640e:	0e2000ef          	jal	ra,ffffffffc02064f0 <strnlen>
ffffffffc0206412:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206416:	01b05b63          	blez	s11,ffffffffc020642c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020641a:	67a2                	ld	a5,8(sp)
ffffffffc020641c:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206420:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206422:	85a6                	mv	a1,s1
ffffffffc0206424:	8552                	mv	a0,s4
ffffffffc0206426:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206428:	fe0d9ce3          	bnez	s11,ffffffffc0206420 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020642c:	00044783          	lbu	a5,0(s0)
ffffffffc0206430:	00140a13          	addi	s4,s0,1
ffffffffc0206434:	0007851b          	sext.w	a0,a5
ffffffffc0206438:	d3a5                	beqz	a5,ffffffffc0206398 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020643a:	05e00413          	li	s0,94
ffffffffc020643e:	bf39                	j	ffffffffc020635c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0206440:	000a2403          	lw	s0,0(s4)
ffffffffc0206444:	b7ad                	j	ffffffffc02063ae <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206446:	000a6603          	lwu	a2,0(s4)
ffffffffc020644a:	46a1                	li	a3,8
ffffffffc020644c:	8a2e                	mv	s4,a1
ffffffffc020644e:	bdb1                	j	ffffffffc02062aa <vprintfmt+0x156>
ffffffffc0206450:	000a6603          	lwu	a2,0(s4)
ffffffffc0206454:	46a9                	li	a3,10
ffffffffc0206456:	8a2e                	mv	s4,a1
ffffffffc0206458:	bd89                	j	ffffffffc02062aa <vprintfmt+0x156>
ffffffffc020645a:	000a6603          	lwu	a2,0(s4)
ffffffffc020645e:	46c1                	li	a3,16
ffffffffc0206460:	8a2e                	mv	s4,a1
ffffffffc0206462:	b5a1                	j	ffffffffc02062aa <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0206464:	9902                	jalr	s2
ffffffffc0206466:	bf09                	j	ffffffffc0206378 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0206468:	85a6                	mv	a1,s1
ffffffffc020646a:	02d00513          	li	a0,45
ffffffffc020646e:	e03e                	sd	a5,0(sp)
ffffffffc0206470:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206472:	6782                	ld	a5,0(sp)
ffffffffc0206474:	8a66                	mv	s4,s9
ffffffffc0206476:	40800633          	neg	a2,s0
ffffffffc020647a:	46a9                	li	a3,10
ffffffffc020647c:	b53d                	j	ffffffffc02062aa <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020647e:	03b05163          	blez	s11,ffffffffc02064a0 <vprintfmt+0x34c>
ffffffffc0206482:	02d00693          	li	a3,45
ffffffffc0206486:	f6d79de3          	bne	a5,a3,ffffffffc0206400 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020648a:	00002417          	auipc	s0,0x2
ffffffffc020648e:	4b640413          	addi	s0,s0,1206 # ffffffffc0208940 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206492:	02800793          	li	a5,40
ffffffffc0206496:	02800513          	li	a0,40
ffffffffc020649a:	00140a13          	addi	s4,s0,1
ffffffffc020649e:	bd6d                	j	ffffffffc0206358 <vprintfmt+0x204>
ffffffffc02064a0:	00002a17          	auipc	s4,0x2
ffffffffc02064a4:	4a1a0a13          	addi	s4,s4,1185 # ffffffffc0208941 <syscalls+0x119>
ffffffffc02064a8:	02800513          	li	a0,40
ffffffffc02064ac:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064b0:	05e00413          	li	s0,94
ffffffffc02064b4:	b565                	j	ffffffffc020635c <vprintfmt+0x208>

ffffffffc02064b6 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064b6:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02064b8:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064bc:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02064be:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064c0:	ec06                	sd	ra,24(sp)
ffffffffc02064c2:	f83a                	sd	a4,48(sp)
ffffffffc02064c4:	fc3e                	sd	a5,56(sp)
ffffffffc02064c6:	e0c2                	sd	a6,64(sp)
ffffffffc02064c8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02064ca:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02064cc:	c89ff0ef          	jal	ra,ffffffffc0206154 <vprintfmt>
}
ffffffffc02064d0:	60e2                	ld	ra,24(sp)
ffffffffc02064d2:	6161                	addi	sp,sp,80
ffffffffc02064d4:	8082                	ret

ffffffffc02064d6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02064d6:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02064da:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02064dc:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02064de:	cb81                	beqz	a5,ffffffffc02064ee <strlen+0x18>
        cnt ++;
ffffffffc02064e0:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02064e2:	00a707b3          	add	a5,a4,a0
ffffffffc02064e6:	0007c783          	lbu	a5,0(a5)
ffffffffc02064ea:	fbfd                	bnez	a5,ffffffffc02064e0 <strlen+0xa>
ffffffffc02064ec:	8082                	ret
    }
    return cnt;
}
ffffffffc02064ee:	8082                	ret

ffffffffc02064f0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02064f0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02064f2:	e589                	bnez	a1,ffffffffc02064fc <strnlen+0xc>
ffffffffc02064f4:	a811                	j	ffffffffc0206508 <strnlen+0x18>
        cnt ++;
ffffffffc02064f6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02064f8:	00f58863          	beq	a1,a5,ffffffffc0206508 <strnlen+0x18>
ffffffffc02064fc:	00f50733          	add	a4,a0,a5
ffffffffc0206500:	00074703          	lbu	a4,0(a4)
ffffffffc0206504:	fb6d                	bnez	a4,ffffffffc02064f6 <strnlen+0x6>
ffffffffc0206506:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206508:	852e                	mv	a0,a1
ffffffffc020650a:	8082                	ret

ffffffffc020650c <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020650c:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020650e:	0005c703          	lbu	a4,0(a1)
ffffffffc0206512:	0785                	addi	a5,a5,1
ffffffffc0206514:	0585                	addi	a1,a1,1
ffffffffc0206516:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020651a:	fb75                	bnez	a4,ffffffffc020650e <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020651c:	8082                	ret

ffffffffc020651e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020651e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206522:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206526:	cb89                	beqz	a5,ffffffffc0206538 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206528:	0505                	addi	a0,a0,1
ffffffffc020652a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020652c:	fee789e3          	beq	a5,a4,ffffffffc020651e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206530:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206534:	9d19                	subw	a0,a0,a4
ffffffffc0206536:	8082                	ret
ffffffffc0206538:	4501                	li	a0,0
ffffffffc020653a:	bfed                	j	ffffffffc0206534 <strcmp+0x16>

ffffffffc020653c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020653c:	00054783          	lbu	a5,0(a0)
ffffffffc0206540:	c799                	beqz	a5,ffffffffc020654e <strchr+0x12>
        if (*s == c) {
ffffffffc0206542:	00f58763          	beq	a1,a5,ffffffffc0206550 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0206546:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020654a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020654c:	fbfd                	bnez	a5,ffffffffc0206542 <strchr+0x6>
    }
    return NULL;
ffffffffc020654e:	4501                	li	a0,0
}
ffffffffc0206550:	8082                	ret

ffffffffc0206552 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206552:	ca01                	beqz	a2,ffffffffc0206562 <memset+0x10>
ffffffffc0206554:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206556:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206558:	0785                	addi	a5,a5,1
ffffffffc020655a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020655e:	fec79de3          	bne	a5,a2,ffffffffc0206558 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206562:	8082                	ret

ffffffffc0206564 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206564:	ca19                	beqz	a2,ffffffffc020657a <memcpy+0x16>
ffffffffc0206566:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206568:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020656a:	0005c703          	lbu	a4,0(a1)
ffffffffc020656e:	0585                	addi	a1,a1,1
ffffffffc0206570:	0785                	addi	a5,a5,1
ffffffffc0206572:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206576:	fec59ae3          	bne	a1,a2,ffffffffc020656a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020657a:	8082                	ret
