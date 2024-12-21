
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
	({ register uintptr_t a0 asm ("a0") = (uintptr_t)(0); register uintptr_t a1 asm ("a1") = (uintptr_t)(0); register uintptr_t a2 asm ("a2") = (uintptr_t)(0); register uintptr_t a7 asm ("a7") = (uintptr_t)(8); asm volatile ("ecall" : "+r" (a0) : "r" (a1), "r" (a2), "r" (a7) : "memory"); a0; });
}

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	01e50513          	addi	a0,a0,30 # ffffffffc0206050 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0206570 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	671010ef          	jal	ffffffffc0201eba <memset>
    cons_init();  // init the console
ffffffffc020004e:	3e8000ef          	jal	ffffffffc0200436 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	e7e50513          	addi	a0,a0,-386 # ffffffffc0201ed0 <etext+0x4>
ffffffffc020005a:	08e000ef          	jal	ffffffffc02000e8 <cputs>

    print_kerninfo();
ffffffffc020005e:	0e8000ef          	jal	ffffffffc0200146 <print_kerninfo>

    // grade_backtrace();
    //idt_init();  // init interrupt descriptor table
    
    pmm_init();  // init physical memory management
ffffffffc0200062:	0f8010ef          	jal	ffffffffc020115a <pmm_init>
    
    //idt_init();  // init interrupt descriptor table

    clock_init();   // init clock interrupt
ffffffffc0200066:	39e000ef          	jal	ffffffffc0200404 <clock_init>
	({ register uintptr_t a0 asm ("a0") = (uintptr_t)(0); register uintptr_t a1 asm ("a1") = (uintptr_t)(0); register uintptr_t a2 asm ("a2") = (uintptr_t)(0); register uintptr_t a7 asm ("a7") = (uintptr_t)(8); asm volatile ("ecall" : "+r" (a0) : "r" (a1), "r" (a2), "r" (a7) : "memory"); a0; });
ffffffffc020006a:	4501                	li	a0,0
ffffffffc020006c:	4581                	li	a1,0
ffffffffc020006e:	4601                	li	a2,0
ffffffffc0200070:	48a1                	li	a7,8
ffffffffc0200072:	00000073          	ecall
    //intr_enable();  // enable irq interrupt

    
    
    /* do nothing */
    while (1)
ffffffffc0200076:	bfd5                	j	ffffffffc020006a <kern_init+0x38>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3b8000ef          	jal	ffffffffc0200438 <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	12d010ef          	jal	ffffffffc02019d2 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	f42e                	sd	a1,40(sp)
ffffffffc02000ba:	f832                	sd	a2,48(sp)
ffffffffc02000bc:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000be:	862a                	mv	a2,a0
ffffffffc02000c0:	004c                	addi	a1,sp,4
ffffffffc02000c2:	00000517          	auipc	a0,0x0
ffffffffc02000c6:	fb650513          	addi	a0,a0,-74 # ffffffffc0200078 <cputch>
ffffffffc02000ca:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	ec06                	sd	ra,24(sp)
ffffffffc02000ce:	e0ba                	sd	a4,64(sp)
ffffffffc02000d0:	e4be                	sd	a5,72(sp)
ffffffffc02000d2:	e8c2                	sd	a6,80(sp)
ffffffffc02000d4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000d8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	0f9010ef          	jal	ffffffffc02019d2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000de:	60e2                	ld	ra,24(sp)
ffffffffc02000e0:	4512                	lw	a0,4(sp)
ffffffffc02000e2:	6125                	addi	sp,sp,96
ffffffffc02000e4:	8082                	ret

ffffffffc02000e6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e6:	ae89                	j	ffffffffc0200438 <cons_putc>

ffffffffc02000e8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000e8:	1101                	addi	sp,sp,-32
ffffffffc02000ea:	ec06                	sd	ra,24(sp)
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	87aa                	mv	a5,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f0:	00054503          	lbu	a0,0(a0)
ffffffffc02000f4:	c905                	beqz	a0,ffffffffc0200124 <cputs+0x3c>
ffffffffc02000f6:	e426                	sd	s1,8(sp)
ffffffffc02000f8:	00178493          	addi	s1,a5,1
ffffffffc02000fc:	8426                	mv	s0,s1
    cons_putc(c);
ffffffffc02000fe:	33a000ef          	jal	ffffffffc0200438 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200102:	00044503          	lbu	a0,0(s0)
ffffffffc0200106:	87a2                	mv	a5,s0
ffffffffc0200108:	0405                	addi	s0,s0,1
ffffffffc020010a:	f975                	bnez	a0,ffffffffc02000fe <cputs+0x16>
    (*cnt) ++;
ffffffffc020010c:	9f85                	subw	a5,a5,s1
    cons_putc(c);
ffffffffc020010e:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc0200110:	0027841b          	addiw	s0,a5,2
ffffffffc0200114:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc0200116:	322000ef          	jal	ffffffffc0200438 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	6105                	addi	sp,sp,32
ffffffffc0200122:	8082                	ret
    cons_putc(c);
ffffffffc0200124:	4529                	li	a0,10
ffffffffc0200126:	312000ef          	jal	ffffffffc0200438 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
}
ffffffffc020012c:	60e2                	ld	ra,24(sp)
ffffffffc020012e:	8522                	mv	a0,s0
ffffffffc0200130:	6442                	ld	s0,16(sp)
ffffffffc0200132:	6105                	addi	sp,sp,32
ffffffffc0200134:	8082                	ret

ffffffffc0200136 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200136:	1141                	addi	sp,sp,-16
ffffffffc0200138:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020013a:	306000ef          	jal	ffffffffc0200440 <cons_getc>
ffffffffc020013e:	dd75                	beqz	a0,ffffffffc020013a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200140:	60a2                	ld	ra,8(sp)
ffffffffc0200142:	0141                	addi	sp,sp,16
ffffffffc0200144:	8082                	ret

ffffffffc0200146 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	00002517          	auipc	a0,0x2
ffffffffc020014c:	da850513          	addi	a0,a0,-600 # ffffffffc0201ef0 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200150:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200152:	f61ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200156:	00000597          	auipc	a1,0x0
ffffffffc020015a:	edc58593          	addi	a1,a1,-292 # ffffffffc0200032 <kern_init>
ffffffffc020015e:	00002517          	auipc	a0,0x2
ffffffffc0200162:	db250513          	addi	a0,a0,-590 # ffffffffc0201f10 <etext+0x44>
ffffffffc0200166:	f4dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020016a:	00002597          	auipc	a1,0x2
ffffffffc020016e:	d6258593          	addi	a1,a1,-670 # ffffffffc0201ecc <etext>
ffffffffc0200172:	00002517          	auipc	a0,0x2
ffffffffc0200176:	dbe50513          	addi	a0,a0,-578 # ffffffffc0201f30 <etext+0x64>
ffffffffc020017a:	f39ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020017e:	00006597          	auipc	a1,0x6
ffffffffc0200182:	ed258593          	addi	a1,a1,-302 # ffffffffc0206050 <free_area>
ffffffffc0200186:	00002517          	auipc	a0,0x2
ffffffffc020018a:	dca50513          	addi	a0,a0,-566 # ffffffffc0201f50 <etext+0x84>
ffffffffc020018e:	f25ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200192:	00006597          	auipc	a1,0x6
ffffffffc0200196:	3de58593          	addi	a1,a1,990 # ffffffffc0206570 <end>
ffffffffc020019a:	00002517          	auipc	a0,0x2
ffffffffc020019e:	dd650513          	addi	a0,a0,-554 # ffffffffc0201f70 <etext+0xa4>
ffffffffc02001a2:	f11ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001a6:	00006797          	auipc	a5,0x6
ffffffffc02001aa:	7c978793          	addi	a5,a5,1993 # ffffffffc020696f <end+0x3ff>
ffffffffc02001ae:	00000717          	auipc	a4,0x0
ffffffffc02001b2:	e8470713          	addi	a4,a4,-380 # ffffffffc0200032 <kern_init>
ffffffffc02001b6:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001bc:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001be:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001c2:	95be                	add	a1,a1,a5
ffffffffc02001c4:	85a9                	srai	a1,a1,0xa
ffffffffc02001c6:	00002517          	auipc	a0,0x2
ffffffffc02001ca:	dca50513          	addi	a0,a0,-566 # ffffffffc0201f90 <etext+0xc4>
}
ffffffffc02001ce:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d0:	b5cd                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001d2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001d2:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d4:	00002617          	auipc	a2,0x2
ffffffffc02001d8:	dec60613          	addi	a2,a2,-532 # ffffffffc0201fc0 <etext+0xf4>
ffffffffc02001dc:	04e00593          	li	a1,78
ffffffffc02001e0:	00002517          	auipc	a0,0x2
ffffffffc02001e4:	df850513          	addi	a0,a0,-520 # ffffffffc0201fd8 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001e8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ea:	1bc000ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc02001ee <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ee:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f0:	00002617          	auipc	a2,0x2
ffffffffc02001f4:	e0060613          	addi	a2,a2,-512 # ffffffffc0201ff0 <etext+0x124>
ffffffffc02001f8:	00002597          	auipc	a1,0x2
ffffffffc02001fc:	e1858593          	addi	a1,a1,-488 # ffffffffc0202010 <etext+0x144>
ffffffffc0200200:	00002517          	auipc	a0,0x2
ffffffffc0200204:	e1850513          	addi	a0,a0,-488 # ffffffffc0202018 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	ea9ff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc020020e:	00002617          	auipc	a2,0x2
ffffffffc0200212:	e1a60613          	addi	a2,a2,-486 # ffffffffc0202028 <etext+0x15c>
ffffffffc0200216:	00002597          	auipc	a1,0x2
ffffffffc020021a:	e3a58593          	addi	a1,a1,-454 # ffffffffc0202050 <etext+0x184>
ffffffffc020021e:	00002517          	auipc	a0,0x2
ffffffffc0200222:	dfa50513          	addi	a0,a0,-518 # ffffffffc0202018 <etext+0x14c>
ffffffffc0200226:	e8dff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc020022a:	00002617          	auipc	a2,0x2
ffffffffc020022e:	e3660613          	addi	a2,a2,-458 # ffffffffc0202060 <etext+0x194>
ffffffffc0200232:	00002597          	auipc	a1,0x2
ffffffffc0200236:	e4e58593          	addi	a1,a1,-434 # ffffffffc0202080 <etext+0x1b4>
ffffffffc020023a:	00002517          	auipc	a0,0x2
ffffffffc020023e:	dde50513          	addi	a0,a0,-546 # ffffffffc0202018 <etext+0x14c>
ffffffffc0200242:	e71ff0ef          	jal	ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc0200246:	60a2                	ld	ra,8(sp)
ffffffffc0200248:	4501                	li	a0,0
ffffffffc020024a:	0141                	addi	sp,sp,16
ffffffffc020024c:	8082                	ret

ffffffffc020024e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024e:	1141                	addi	sp,sp,-16
ffffffffc0200250:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200252:	ef5ff0ef          	jal	ffffffffc0200146 <print_kerninfo>
    return 0;
}
ffffffffc0200256:	60a2                	ld	ra,8(sp)
ffffffffc0200258:	4501                	li	a0,0
ffffffffc020025a:	0141                	addi	sp,sp,16
ffffffffc020025c:	8082                	ret

ffffffffc020025e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025e:	1141                	addi	sp,sp,-16
ffffffffc0200260:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200262:	f71ff0ef          	jal	ffffffffc02001d2 <print_stackframe>
    return 0;
}
ffffffffc0200266:	60a2                	ld	ra,8(sp)
ffffffffc0200268:	4501                	li	a0,0
ffffffffc020026a:	0141                	addi	sp,sp,16
ffffffffc020026c:	8082                	ret

ffffffffc020026e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026e:	7115                	addi	sp,sp,-224
ffffffffc0200270:	f15a                	sd	s6,160(sp)
ffffffffc0200272:	8b2a                	mv	s6,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200274:	00002517          	auipc	a0,0x2
ffffffffc0200278:	e1c50513          	addi	a0,a0,-484 # ffffffffc0202090 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
ffffffffc020027c:	ed86                	sd	ra,216(sp)
ffffffffc020027e:	e9a2                	sd	s0,208(sp)
ffffffffc0200280:	e5a6                	sd	s1,200(sp)
ffffffffc0200282:	e1ca                	sd	s2,192(sp)
ffffffffc0200284:	fd4e                	sd	s3,184(sp)
ffffffffc0200286:	f952                	sd	s4,176(sp)
ffffffffc0200288:	f556                	sd	s5,168(sp)
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	e962                	sd	s8,144(sp)
ffffffffc020028e:	e566                	sd	s9,136(sp)
ffffffffc0200290:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200292:	e21ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200296:	00002517          	auipc	a0,0x2
ffffffffc020029a:	e2250513          	addi	a0,a0,-478 # ffffffffc02020b8 <etext+0x1ec>
ffffffffc020029e:	e15ff0ef          	jal	ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc02002a2:	000b0563          	beqz	s6,ffffffffc02002ac <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a6:	855a                	mv	a0,s6
ffffffffc02002a8:	374000ef          	jal	ffffffffc020061c <print_trapframe>
ffffffffc02002ac:	00003c17          	auipc	s8,0x3
ffffffffc02002b0:	a0cc0c13          	addi	s8,s8,-1524 # ffffffffc0202cb8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b4:	00002917          	auipc	s2,0x2
ffffffffc02002b8:	e2c90913          	addi	s2,s2,-468 # ffffffffc02020e0 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002bc:	00002497          	auipc	s1,0x2
ffffffffc02002c0:	e2c48493          	addi	s1,s1,-468 # ffffffffc02020e8 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002c4:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c6:	00002a97          	auipc	s5,0x2
ffffffffc02002ca:	e2aa8a93          	addi	s5,s5,-470 # ffffffffc02020f0 <etext+0x224>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002d0:	00002b97          	auipc	s7,0x2
ffffffffc02002d4:	e40b8b93          	addi	s7,s7,-448 # ffffffffc0202110 <etext+0x244>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d8:	854a                	mv	a0,s2
ffffffffc02002da:	273010ef          	jal	ffffffffc0201d4c <readline>
ffffffffc02002de:	842a                	mv	s0,a0
ffffffffc02002e0:	dd65                	beqz	a0,ffffffffc02002d8 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e6:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e8:	e59d                	bnez	a1,ffffffffc0200316 <kmonitor+0xa8>
    if (argc == 0) {
ffffffffc02002ea:	fe0c87e3          	beqz	s9,ffffffffc02002d8 <kmonitor+0x6a>
ffffffffc02002ee:	00003d17          	auipc	s10,0x3
ffffffffc02002f2:	9cad0d13          	addi	s10,s10,-1590 # ffffffffc0202cb8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f6:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f8:	6582                	ld	a1,0(sp)
ffffffffc02002fa:	000d3503          	ld	a0,0(s10)
ffffffffc02002fe:	36f010ef          	jal	ffffffffc0201e6c <strcmp>
ffffffffc0200302:	c53d                	beqz	a0,ffffffffc0200370 <kmonitor+0x102>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	2405                	addiw	s0,s0,1
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	ff4418e3          	bne	s0,s4,ffffffffc02002f8 <kmonitor+0x8a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020030c:	6582                	ld	a1,0(sp)
ffffffffc020030e:	855e                	mv	a0,s7
ffffffffc0200310:	da3ff0ef          	jal	ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc0200314:	b7d1                	j	ffffffffc02002d8 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200316:	8526                	mv	a0,s1
ffffffffc0200318:	38d010ef          	jal	ffffffffc0201ea4 <strchr>
ffffffffc020031c:	c901                	beqz	a0,ffffffffc020032c <kmonitor+0xbe>
ffffffffc020031e:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200322:	00040023          	sb	zero,0(s0)
ffffffffc0200326:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200328:	d1e9                	beqz	a1,ffffffffc02002ea <kmonitor+0x7c>
ffffffffc020032a:	b7f5                	j	ffffffffc0200316 <kmonitor+0xa8>
        if (*buf == '\0') {
ffffffffc020032c:	00044783          	lbu	a5,0(s0)
ffffffffc0200330:	dfcd                	beqz	a5,ffffffffc02002ea <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200332:	033c8a63          	beq	s9,s3,ffffffffc0200366 <kmonitor+0xf8>
        argv[argc ++] = buf;
ffffffffc0200336:	003c9793          	slli	a5,s9,0x3
ffffffffc020033a:	08078793          	addi	a5,a5,128
ffffffffc020033e:	978a                	add	a5,a5,sp
ffffffffc0200340:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200344:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200348:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020034a:	e591                	bnez	a1,ffffffffc0200356 <kmonitor+0xe8>
ffffffffc020034c:	bf79                	j	ffffffffc02002ea <kmonitor+0x7c>
ffffffffc020034e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200352:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200354:	d9d9                	beqz	a1,ffffffffc02002ea <kmonitor+0x7c>
ffffffffc0200356:	8526                	mv	a0,s1
ffffffffc0200358:	34d010ef          	jal	ffffffffc0201ea4 <strchr>
ffffffffc020035c:	d96d                	beqz	a0,ffffffffc020034e <kmonitor+0xe0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035e:	00044583          	lbu	a1,0(s0)
ffffffffc0200362:	d5c1                	beqz	a1,ffffffffc02002ea <kmonitor+0x7c>
ffffffffc0200364:	bf4d                	j	ffffffffc0200316 <kmonitor+0xa8>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	45c1                	li	a1,16
ffffffffc0200368:	8556                	mv	a0,s5
ffffffffc020036a:	d49ff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc020036e:	b7e1                	j	ffffffffc0200336 <kmonitor+0xc8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200370:	00141793          	slli	a5,s0,0x1
ffffffffc0200374:	97a2                	add	a5,a5,s0
ffffffffc0200376:	078e                	slli	a5,a5,0x3
ffffffffc0200378:	97e2                	add	a5,a5,s8
ffffffffc020037a:	6b9c                	ld	a5,16(a5)
ffffffffc020037c:	865a                	mv	a2,s6
ffffffffc020037e:	002c                	addi	a1,sp,8
ffffffffc0200380:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200384:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200386:	f40559e3          	bgez	a0,ffffffffc02002d8 <kmonitor+0x6a>
}
ffffffffc020038a:	60ee                	ld	ra,216(sp)
ffffffffc020038c:	644e                	ld	s0,208(sp)
ffffffffc020038e:	64ae                	ld	s1,200(sp)
ffffffffc0200390:	690e                	ld	s2,192(sp)
ffffffffc0200392:	79ea                	ld	s3,184(sp)
ffffffffc0200394:	7a4a                	ld	s4,176(sp)
ffffffffc0200396:	7aaa                	ld	s5,168(sp)
ffffffffc0200398:	7b0a                	ld	s6,160(sp)
ffffffffc020039a:	6bea                	ld	s7,152(sp)
ffffffffc020039c:	6c4a                	ld	s8,144(sp)
ffffffffc020039e:	6caa                	ld	s9,136(sp)
ffffffffc02003a0:	6d0a                	ld	s10,128(sp)
ffffffffc02003a2:	612d                	addi	sp,sp,224
ffffffffc02003a4:	8082                	ret

ffffffffc02003a6 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003a6:	00006317          	auipc	t1,0x6
ffffffffc02003aa:	18230313          	addi	t1,t1,386 # ffffffffc0206528 <is_panic>
ffffffffc02003ae:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b2:	715d                	addi	sp,sp,-80
ffffffffc02003b4:	ec06                	sd	ra,24(sp)
ffffffffc02003b6:	f436                	sd	a3,40(sp)
ffffffffc02003b8:	f83a                	sd	a4,48(sp)
ffffffffc02003ba:	fc3e                	sd	a5,56(sp)
ffffffffc02003bc:	e0c2                	sd	a6,64(sp)
ffffffffc02003be:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c0:	020e1c63          	bnez	t3,ffffffffc02003f8 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003c4:	4785                	li	a5,1
ffffffffc02003c6:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003ca:	e822                	sd	s0,16(sp)
ffffffffc02003cc:	103c                	addi	a5,sp,40
ffffffffc02003ce:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d0:	862e                	mv	a2,a1
ffffffffc02003d2:	85aa                	mv	a1,a0
ffffffffc02003d4:	00002517          	auipc	a0,0x2
ffffffffc02003d8:	d5450513          	addi	a0,a0,-684 # ffffffffc0202128 <etext+0x25c>
    va_start(ap, fmt);
ffffffffc02003dc:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003de:	cd5ff0ef          	jal	ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e2:	65a2                	ld	a1,8(sp)
ffffffffc02003e4:	8522                	mv	a0,s0
ffffffffc02003e6:	cadff0ef          	jal	ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003ea:	00002517          	auipc	a0,0x2
ffffffffc02003ee:	d5e50513          	addi	a0,a0,-674 # ffffffffc0202148 <etext+0x27c>
ffffffffc02003f2:	cc1ff0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003f8:	052000ef          	jal	ffffffffc020044a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	e71ff0ef          	jal	ffffffffc020026e <kmonitor>
    while (1) {
ffffffffc0200402:	bfed                	j	ffffffffc02003fc <__panic+0x56>

ffffffffc0200404 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200404:	1141                	addi	sp,sp,-16
ffffffffc0200406:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200408:	02000793          	li	a5,32
ffffffffc020040c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200410:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200414:	67e1                	lui	a5,0x18
ffffffffc0200416:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041a:	953e                	add	a0,a0,a5
ffffffffc020041c:	1ff010ef          	jal	ffffffffc0201e1a <sbi_set_timer>
}
ffffffffc0200420:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200422:	00006797          	auipc	a5,0x6
ffffffffc0200426:	1007b723          	sd	zero,270(a5) # ffffffffc0206530 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042a:	00002517          	auipc	a0,0x2
ffffffffc020042e:	d2650513          	addi	a0,a0,-730 # ffffffffc0202150 <etext+0x284>
}
ffffffffc0200432:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200434:	b9bd                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200436 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200436:	8082                	ret

ffffffffc0200438 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200438:	0ff57513          	zext.b	a0,a0
ffffffffc020043c:	1c50106f          	j	ffffffffc0201e00 <sbi_console_putchar>

ffffffffc0200440 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200440:	1f50106f          	j	ffffffffc0201e34 <sbi_console_getchar>

ffffffffc0200444 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200444:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200448:	8082                	ret

ffffffffc020044a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020044a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020044e:	8082                	ret

ffffffffc0200450 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->stval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200450:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200452:	1141                	addi	sp,sp,-16
ffffffffc0200454:	e022                	sd	s0,0(sp)
ffffffffc0200456:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200458:	00002517          	auipc	a0,0x2
ffffffffc020045c:	d1850513          	addi	a0,a0,-744 # ffffffffc0202170 <etext+0x2a4>
void print_regs(struct pushregs *gpr) {
ffffffffc0200460:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200462:	c51ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200466:	640c                	ld	a1,8(s0)
ffffffffc0200468:	00002517          	auipc	a0,0x2
ffffffffc020046c:	d2050513          	addi	a0,a0,-736 # ffffffffc0202188 <etext+0x2bc>
ffffffffc0200470:	c43ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200474:	680c                	ld	a1,16(s0)
ffffffffc0200476:	00002517          	auipc	a0,0x2
ffffffffc020047a:	d2a50513          	addi	a0,a0,-726 # ffffffffc02021a0 <etext+0x2d4>
ffffffffc020047e:	c35ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200482:	6c0c                	ld	a1,24(s0)
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	d3450513          	addi	a0,a0,-716 # ffffffffc02021b8 <etext+0x2ec>
ffffffffc020048c:	c27ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200490:	700c                	ld	a1,32(s0)
ffffffffc0200492:	00002517          	auipc	a0,0x2
ffffffffc0200496:	d3e50513          	addi	a0,a0,-706 # ffffffffc02021d0 <etext+0x304>
ffffffffc020049a:	c19ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020049e:	740c                	ld	a1,40(s0)
ffffffffc02004a0:	00002517          	auipc	a0,0x2
ffffffffc02004a4:	d4850513          	addi	a0,a0,-696 # ffffffffc02021e8 <etext+0x31c>
ffffffffc02004a8:	c0bff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004ac:	780c                	ld	a1,48(s0)
ffffffffc02004ae:	00002517          	auipc	a0,0x2
ffffffffc02004b2:	d5250513          	addi	a0,a0,-686 # ffffffffc0202200 <etext+0x334>
ffffffffc02004b6:	bfdff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004ba:	7c0c                	ld	a1,56(s0)
ffffffffc02004bc:	00002517          	auipc	a0,0x2
ffffffffc02004c0:	d5c50513          	addi	a0,a0,-676 # ffffffffc0202218 <etext+0x34c>
ffffffffc02004c4:	befff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004c8:	602c                	ld	a1,64(s0)
ffffffffc02004ca:	00002517          	auipc	a0,0x2
ffffffffc02004ce:	d6650513          	addi	a0,a0,-666 # ffffffffc0202230 <etext+0x364>
ffffffffc02004d2:	be1ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004d6:	642c                	ld	a1,72(s0)
ffffffffc02004d8:	00002517          	auipc	a0,0x2
ffffffffc02004dc:	d7050513          	addi	a0,a0,-656 # ffffffffc0202248 <etext+0x37c>
ffffffffc02004e0:	bd3ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02004e4:	682c                	ld	a1,80(s0)
ffffffffc02004e6:	00002517          	auipc	a0,0x2
ffffffffc02004ea:	d7a50513          	addi	a0,a0,-646 # ffffffffc0202260 <etext+0x394>
ffffffffc02004ee:	bc5ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02004f2:	6c2c                	ld	a1,88(s0)
ffffffffc02004f4:	00002517          	auipc	a0,0x2
ffffffffc02004f8:	d8450513          	addi	a0,a0,-636 # ffffffffc0202278 <etext+0x3ac>
ffffffffc02004fc:	bb7ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200500:	702c                	ld	a1,96(s0)
ffffffffc0200502:	00002517          	auipc	a0,0x2
ffffffffc0200506:	d8e50513          	addi	a0,a0,-626 # ffffffffc0202290 <etext+0x3c4>
ffffffffc020050a:	ba9ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020050e:	742c                	ld	a1,104(s0)
ffffffffc0200510:	00002517          	auipc	a0,0x2
ffffffffc0200514:	d9850513          	addi	a0,a0,-616 # ffffffffc02022a8 <etext+0x3dc>
ffffffffc0200518:	b9bff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020051c:	782c                	ld	a1,112(s0)
ffffffffc020051e:	00002517          	auipc	a0,0x2
ffffffffc0200522:	da250513          	addi	a0,a0,-606 # ffffffffc02022c0 <etext+0x3f4>
ffffffffc0200526:	b8dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020052a:	7c2c                	ld	a1,120(s0)
ffffffffc020052c:	00002517          	auipc	a0,0x2
ffffffffc0200530:	dac50513          	addi	a0,a0,-596 # ffffffffc02022d8 <etext+0x40c>
ffffffffc0200534:	b7fff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200538:	604c                	ld	a1,128(s0)
ffffffffc020053a:	00002517          	auipc	a0,0x2
ffffffffc020053e:	db650513          	addi	a0,a0,-586 # ffffffffc02022f0 <etext+0x424>
ffffffffc0200542:	b71ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200546:	644c                	ld	a1,136(s0)
ffffffffc0200548:	00002517          	auipc	a0,0x2
ffffffffc020054c:	dc050513          	addi	a0,a0,-576 # ffffffffc0202308 <etext+0x43c>
ffffffffc0200550:	b63ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200554:	684c                	ld	a1,144(s0)
ffffffffc0200556:	00002517          	auipc	a0,0x2
ffffffffc020055a:	dca50513          	addi	a0,a0,-566 # ffffffffc0202320 <etext+0x454>
ffffffffc020055e:	b55ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200562:	6c4c                	ld	a1,152(s0)
ffffffffc0200564:	00002517          	auipc	a0,0x2
ffffffffc0200568:	dd450513          	addi	a0,a0,-556 # ffffffffc0202338 <etext+0x46c>
ffffffffc020056c:	b47ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200570:	704c                	ld	a1,160(s0)
ffffffffc0200572:	00002517          	auipc	a0,0x2
ffffffffc0200576:	dde50513          	addi	a0,a0,-546 # ffffffffc0202350 <etext+0x484>
ffffffffc020057a:	b39ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020057e:	744c                	ld	a1,168(s0)
ffffffffc0200580:	00002517          	auipc	a0,0x2
ffffffffc0200584:	de850513          	addi	a0,a0,-536 # ffffffffc0202368 <etext+0x49c>
ffffffffc0200588:	b2bff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020058c:	784c                	ld	a1,176(s0)
ffffffffc020058e:	00002517          	auipc	a0,0x2
ffffffffc0200592:	df250513          	addi	a0,a0,-526 # ffffffffc0202380 <etext+0x4b4>
ffffffffc0200596:	b1dff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020059a:	7c4c                	ld	a1,184(s0)
ffffffffc020059c:	00002517          	auipc	a0,0x2
ffffffffc02005a0:	dfc50513          	addi	a0,a0,-516 # ffffffffc0202398 <etext+0x4cc>
ffffffffc02005a4:	b0fff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005a8:	606c                	ld	a1,192(s0)
ffffffffc02005aa:	00002517          	auipc	a0,0x2
ffffffffc02005ae:	e0650513          	addi	a0,a0,-506 # ffffffffc02023b0 <etext+0x4e4>
ffffffffc02005b2:	b01ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005b6:	646c                	ld	a1,200(s0)
ffffffffc02005b8:	00002517          	auipc	a0,0x2
ffffffffc02005bc:	e1050513          	addi	a0,a0,-496 # ffffffffc02023c8 <etext+0x4fc>
ffffffffc02005c0:	af3ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005c4:	686c                	ld	a1,208(s0)
ffffffffc02005c6:	00002517          	auipc	a0,0x2
ffffffffc02005ca:	e1a50513          	addi	a0,a0,-486 # ffffffffc02023e0 <etext+0x514>
ffffffffc02005ce:	ae5ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005d2:	6c6c                	ld	a1,216(s0)
ffffffffc02005d4:	00002517          	auipc	a0,0x2
ffffffffc02005d8:	e2450513          	addi	a0,a0,-476 # ffffffffc02023f8 <etext+0x52c>
ffffffffc02005dc:	ad7ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02005e0:	706c                	ld	a1,224(s0)
ffffffffc02005e2:	00002517          	auipc	a0,0x2
ffffffffc02005e6:	e2e50513          	addi	a0,a0,-466 # ffffffffc0202410 <etext+0x544>
ffffffffc02005ea:	ac9ff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02005ee:	746c                	ld	a1,232(s0)
ffffffffc02005f0:	00002517          	auipc	a0,0x2
ffffffffc02005f4:	e3850513          	addi	a0,a0,-456 # ffffffffc0202428 <etext+0x55c>
ffffffffc02005f8:	abbff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02005fc:	786c                	ld	a1,240(s0)
ffffffffc02005fe:	00002517          	auipc	a0,0x2
ffffffffc0200602:	e4250513          	addi	a0,a0,-446 # ffffffffc0202440 <etext+0x574>
ffffffffc0200606:	aadff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020060a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020060c:	6402                	ld	s0,0(sp)
ffffffffc020060e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200610:	00002517          	auipc	a0,0x2
ffffffffc0200614:	e4850513          	addi	a0,a0,-440 # ffffffffc0202458 <etext+0x58c>
}
ffffffffc0200618:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020061a:	bc61                	j	ffffffffc02000b2 <cprintf>

ffffffffc020061c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020061c:	1141                	addi	sp,sp,-16
ffffffffc020061e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200620:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200622:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	e4c50513          	addi	a0,a0,-436 # ffffffffc0202470 <etext+0x5a4>
void print_trapframe(struct trapframe *tf) {
ffffffffc020062c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020062e:	a85ff0ef          	jal	ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200632:	8522                	mv	a0,s0
ffffffffc0200634:	e1dff0ef          	jal	ffffffffc0200450 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200638:	10043583          	ld	a1,256(s0)
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	e4c50513          	addi	a0,a0,-436 # ffffffffc0202488 <etext+0x5bc>
ffffffffc0200644:	a6fff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200648:	10843583          	ld	a1,264(s0)
ffffffffc020064c:	00002517          	auipc	a0,0x2
ffffffffc0200650:	e5450513          	addi	a0,a0,-428 # ffffffffc02024a0 <etext+0x5d4>
ffffffffc0200654:	a5fff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->stval);
ffffffffc0200658:	11043583          	ld	a1,272(s0)
ffffffffc020065c:	00002517          	auipc	a0,0x2
ffffffffc0200660:	e5c50513          	addi	a0,a0,-420 # ffffffffc02024b8 <etext+0x5ec>
ffffffffc0200664:	a4fff0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200668:	11843583          	ld	a1,280(s0)
}
ffffffffc020066c:	6402                	ld	s0,0(sp)
ffffffffc020066e:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200670:	00002517          	auipc	a0,0x2
ffffffffc0200674:	e6050513          	addi	a0,a0,-416 # ffffffffc02024d0 <etext+0x604>
}
ffffffffc0200678:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020067a:	bc25                	j	ffffffffc02000b2 <cprintf>

ffffffffc020067c <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020067c:	00006797          	auipc	a5,0x6
ffffffffc0200680:	9d478793          	addi	a5,a5,-1580 # ffffffffc0206050 <free_area>
ffffffffc0200684:	e79c                	sd	a5,8(a5)
ffffffffc0200686:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200688:	0007a823          	sw	zero,16(a5)
}
ffffffffc020068c:	8082                	ret

ffffffffc020068e <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	9d256503          	lwu	a0,-1582(a0) # ffffffffc0206060 <free_area+0x10>
ffffffffc0200696:	8082                	ret

ffffffffc0200698 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200698:	c54d                	beqz	a0,ffffffffc0200742 <best_fit_alloc_pages+0xaa>
    if (n > nr_free) {
ffffffffc020069a:	00006617          	auipc	a2,0x6
ffffffffc020069e:	9b660613          	addi	a2,a2,-1610 # ffffffffc0206050 <free_area>
ffffffffc02006a2:	01062803          	lw	a6,16(a2)
ffffffffc02006a6:	86aa                	mv	a3,a0
ffffffffc02006a8:	02081793          	slli	a5,a6,0x20
ffffffffc02006ac:	9381                	srli	a5,a5,0x20
ffffffffc02006ae:	08a7e863          	bltu	a5,a0,ffffffffc020073e <best_fit_alloc_pages+0xa6>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02006b2:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc02006b4:	0018059b          	addiw	a1,a6,1
ffffffffc02006b8:	1582                	slli	a1,a1,0x20
ffffffffc02006ba:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc02006bc:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc02006be:	00c79663          	bne	a5,a2,ffffffffc02006ca <best_fit_alloc_pages+0x32>
ffffffffc02006c2:	8082                	ret
ffffffffc02006c4:	679c                	ld	a5,8(a5)
ffffffffc02006c6:	00c78e63          	beq	a5,a2,ffffffffc02006e2 <best_fit_alloc_pages+0x4a>
        if (p->property >= n) {
ffffffffc02006ca:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02006ce:	fed76be3          	bltu	a4,a3,ffffffffc02006c4 <best_fit_alloc_pages+0x2c>
            if(p->property < min_size){
ffffffffc02006d2:	feb779e3          	bgeu	a4,a1,ffffffffc02006c4 <best_fit_alloc_pages+0x2c>
        struct Page *p = le2page(le, page_link);
ffffffffc02006d6:	fe878513          	addi	a0,a5,-24
ffffffffc02006da:	679c                	ld	a5,8(a5)
                min_size = p->property;
ffffffffc02006dc:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02006de:	fec796e3          	bne	a5,a2,ffffffffc02006ca <best_fit_alloc_pages+0x32>
    if (page != NULL) {
ffffffffc02006e2:	cd29                	beqz	a0,ffffffffc020073c <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc02006e4:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc02006e6:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc02006e8:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc02006ea:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02006ee:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02006f0:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc02006f2:	02059793          	slli	a5,a1,0x20
ffffffffc02006f6:	9381                	srli	a5,a5,0x20
ffffffffc02006f8:	02f6f863          	bgeu	a3,a5,ffffffffc0200728 <best_fit_alloc_pages+0x90>
            struct Page *p = page + n;
ffffffffc02006fc:	00369793          	slli	a5,a3,0x3
ffffffffc0200700:	8f95                	sub	a5,a5,a3
ffffffffc0200702:	078e                	slli	a5,a5,0x3
ffffffffc0200704:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200706:	411585bb          	subw	a1,a1,a7
ffffffffc020070a:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020070c:	4689                	li	a3,2
ffffffffc020070e:	00878593          	addi	a1,a5,8
ffffffffc0200712:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200716:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200718:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc020071c:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200720:	e28c                	sd	a1,0(a3)
ffffffffc0200722:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc0200724:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200726:	ef98                	sd	a4,24(a5)
ffffffffc0200728:	4118083b          	subw	a6,a6,a7
ffffffffc020072c:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200730:	57f5                	li	a5,-3
ffffffffc0200732:	00850713          	addi	a4,a0,8
ffffffffc0200736:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc020073a:	8082                	ret
}
ffffffffc020073c:	8082                	ret
        return NULL;
ffffffffc020073e:	4501                	li	a0,0
ffffffffc0200740:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200742:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200744:	00002697          	auipc	a3,0x2
ffffffffc0200748:	da468693          	addi	a3,a3,-604 # ffffffffc02024e8 <etext+0x61c>
ffffffffc020074c:	00002617          	auipc	a2,0x2
ffffffffc0200750:	da460613          	addi	a2,a2,-604 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200754:	06c00593          	li	a1,108
ffffffffc0200758:	00002517          	auipc	a0,0x2
ffffffffc020075c:	db050513          	addi	a0,a0,-592 # ffffffffc0202508 <etext+0x63c>
best_fit_alloc_pages(size_t n) {
ffffffffc0200760:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200762:	c45ff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc0200766 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200766:	715d                	addi	sp,sp,-80
ffffffffc0200768:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020076a:	00006417          	auipc	s0,0x6
ffffffffc020076e:	8e640413          	addi	s0,s0,-1818 # ffffffffc0206050 <free_area>
ffffffffc0200772:	641c                	ld	a5,8(s0)
ffffffffc0200774:	e486                	sd	ra,72(sp)
ffffffffc0200776:	fc26                	sd	s1,56(sp)
ffffffffc0200778:	f84a                	sd	s2,48(sp)
ffffffffc020077a:	f44e                	sd	s3,40(sp)
ffffffffc020077c:	f052                	sd	s4,32(sp)
ffffffffc020077e:	ec56                	sd	s5,24(sp)
ffffffffc0200780:	e85a                	sd	s6,16(sp)
ffffffffc0200782:	e45e                	sd	s7,8(sp)
ffffffffc0200784:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200786:	28878463          	beq	a5,s0,ffffffffc0200a0e <best_fit_check+0x2a8>
    int count = 0, total = 0;
ffffffffc020078a:	4481                	li	s1,0
ffffffffc020078c:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020078e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200792:	8b09                	andi	a4,a4,2
ffffffffc0200794:	28070163          	beqz	a4,ffffffffc0200a16 <best_fit_check+0x2b0>
        count ++, total += p->property;
ffffffffc0200798:	ff87a703          	lw	a4,-8(a5)
ffffffffc020079c:	679c                	ld	a5,8(a5)
ffffffffc020079e:	2905                	addiw	s2,s2,1
ffffffffc02007a0:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02007a2:	fe8796e3          	bne	a5,s0,ffffffffc020078e <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc02007a6:	89a6                	mv	s3,s1
ffffffffc02007a8:	179000ef          	jal	ffffffffc0201120 <nr_free_pages>
ffffffffc02007ac:	35351563          	bne	a0,s3,ffffffffc0200af6 <best_fit_check+0x390>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02007b0:	4505                	li	a0,1
ffffffffc02007b2:	0f1000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02007b6:	8a2a                	mv	s4,a0
ffffffffc02007b8:	36050f63          	beqz	a0,ffffffffc0200b36 <best_fit_check+0x3d0>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02007bc:	4505                	li	a0,1
ffffffffc02007be:	0e5000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02007c2:	89aa                	mv	s3,a0
ffffffffc02007c4:	34050963          	beqz	a0,ffffffffc0200b16 <best_fit_check+0x3b0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02007c8:	4505                	li	a0,1
ffffffffc02007ca:	0d9000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02007ce:	8aaa                	mv	s5,a0
ffffffffc02007d0:	2e050363          	beqz	a0,ffffffffc0200ab6 <best_fit_check+0x350>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02007d4:	273a0163          	beq	s4,s3,ffffffffc0200a36 <best_fit_check+0x2d0>
ffffffffc02007d8:	24aa0f63          	beq	s4,a0,ffffffffc0200a36 <best_fit_check+0x2d0>
ffffffffc02007dc:	24a98d63          	beq	s3,a0,ffffffffc0200a36 <best_fit_check+0x2d0>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02007e0:	000a2783          	lw	a5,0(s4)
ffffffffc02007e4:	26079963          	bnez	a5,ffffffffc0200a56 <best_fit_check+0x2f0>
ffffffffc02007e8:	0009a783          	lw	a5,0(s3)
ffffffffc02007ec:	26079563          	bnez	a5,ffffffffc0200a56 <best_fit_check+0x2f0>
ffffffffc02007f0:	411c                	lw	a5,0(a0)
ffffffffc02007f2:	26079263          	bnez	a5,ffffffffc0200a56 <best_fit_check+0x2f0>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02007f6:	06db77b7          	lui	a5,0x6db7
ffffffffc02007fa:	db778793          	addi	a5,a5,-585 # 6db6db7 <kern_entry-0xffffffffb9449249>
ffffffffc02007fe:	07b2                	slli	a5,a5,0xc
ffffffffc0200800:	db778793          	addi	a5,a5,-585
ffffffffc0200804:	07b2                	slli	a5,a5,0xc
ffffffffc0200806:	00006717          	auipc	a4,0x6
ffffffffc020080a:	d5a73703          	ld	a4,-678(a4) # ffffffffc0206560 <pages>
ffffffffc020080e:	db778793          	addi	a5,a5,-585
ffffffffc0200812:	40ea06b3          	sub	a3,s4,a4
ffffffffc0200816:	07b2                	slli	a5,a5,0xc
ffffffffc0200818:	868d                	srai	a3,a3,0x3
ffffffffc020081a:	db778793          	addi	a5,a5,-585
ffffffffc020081e:	02f686b3          	mul	a3,a3,a5
ffffffffc0200822:	00002597          	auipc	a1,0x2
ffffffffc0200826:	6a65b583          	ld	a1,1702(a1) # ffffffffc0202ec8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020082a:	00006617          	auipc	a2,0x6
ffffffffc020082e:	d2e63603          	ld	a2,-722(a2) # ffffffffc0206558 <npage>
ffffffffc0200832:	0632                	slli	a2,a2,0xc
ffffffffc0200834:	96ae                	add	a3,a3,a1

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200836:	06b2                	slli	a3,a3,0xc
ffffffffc0200838:	22c6ff63          	bgeu	a3,a2,ffffffffc0200a76 <best_fit_check+0x310>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020083c:	40e986b3          	sub	a3,s3,a4
ffffffffc0200840:	868d                	srai	a3,a3,0x3
ffffffffc0200842:	02f686b3          	mul	a3,a3,a5
ffffffffc0200846:	96ae                	add	a3,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200848:	06b2                	slli	a3,a3,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020084a:	3ec6f663          	bgeu	a3,a2,ffffffffc0200c36 <best_fit_check+0x4d0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020084e:	40e50733          	sub	a4,a0,a4
ffffffffc0200852:	870d                	srai	a4,a4,0x3
ffffffffc0200854:	02f707b3          	mul	a5,a4,a5
ffffffffc0200858:	97ae                	add	a5,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc020085a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020085c:	3ac7fd63          	bgeu	a5,a2,ffffffffc0200c16 <best_fit_check+0x4b0>
    assert(alloc_page() == NULL);
ffffffffc0200860:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200862:	00043c03          	ld	s8,0(s0)
ffffffffc0200866:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc020086a:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc020086e:	e400                	sd	s0,8(s0)
ffffffffc0200870:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200872:	00005797          	auipc	a5,0x5
ffffffffc0200876:	7e07a723          	sw	zero,2030(a5) # ffffffffc0206060 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc020087a:	029000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc020087e:	36051c63          	bnez	a0,ffffffffc0200bf6 <best_fit_check+0x490>
    free_page(p0);
ffffffffc0200882:	4585                	li	a1,1
ffffffffc0200884:	8552                	mv	a0,s4
ffffffffc0200886:	05b000ef          	jal	ffffffffc02010e0 <free_pages>
    free_page(p1);
ffffffffc020088a:	4585                	li	a1,1
ffffffffc020088c:	854e                	mv	a0,s3
ffffffffc020088e:	053000ef          	jal	ffffffffc02010e0 <free_pages>
    free_page(p2);
ffffffffc0200892:	4585                	li	a1,1
ffffffffc0200894:	8556                	mv	a0,s5
ffffffffc0200896:	04b000ef          	jal	ffffffffc02010e0 <free_pages>
    assert(nr_free == 3);
ffffffffc020089a:	4818                	lw	a4,16(s0)
ffffffffc020089c:	478d                	li	a5,3
ffffffffc020089e:	32f71c63          	bne	a4,a5,ffffffffc0200bd6 <best_fit_check+0x470>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02008a2:	4505                	li	a0,1
ffffffffc02008a4:	7fe000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02008a8:	89aa                	mv	s3,a0
ffffffffc02008aa:	30050663          	beqz	a0,ffffffffc0200bb6 <best_fit_check+0x450>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02008ae:	4505                	li	a0,1
ffffffffc02008b0:	7f2000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02008b4:	8aaa                	mv	s5,a0
ffffffffc02008b6:	2e050063          	beqz	a0,ffffffffc0200b96 <best_fit_check+0x430>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02008ba:	4505                	li	a0,1
ffffffffc02008bc:	7e6000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02008c0:	8a2a                	mv	s4,a0
ffffffffc02008c2:	2a050a63          	beqz	a0,ffffffffc0200b76 <best_fit_check+0x410>
    assert(alloc_page() == NULL);
ffffffffc02008c6:	4505                	li	a0,1
ffffffffc02008c8:	7da000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02008cc:	28051563          	bnez	a0,ffffffffc0200b56 <best_fit_check+0x3f0>
    free_page(p0);
ffffffffc02008d0:	4585                	li	a1,1
ffffffffc02008d2:	854e                	mv	a0,s3
ffffffffc02008d4:	00d000ef          	jal	ffffffffc02010e0 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02008d8:	641c                	ld	a5,8(s0)
ffffffffc02008da:	1a878e63          	beq	a5,s0,ffffffffc0200a96 <best_fit_check+0x330>
    assert((p = alloc_page()) == p0);
ffffffffc02008de:	4505                	li	a0,1
ffffffffc02008e0:	7c2000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02008e4:	52a99963          	bne	s3,a0,ffffffffc0200e16 <best_fit_check+0x6b0>
    assert(alloc_page() == NULL);
ffffffffc02008e8:	4505                	li	a0,1
ffffffffc02008ea:	7b8000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02008ee:	50051463          	bnez	a0,ffffffffc0200df6 <best_fit_check+0x690>
    assert(nr_free == 0);
ffffffffc02008f2:	481c                	lw	a5,16(s0)
ffffffffc02008f4:	4e079163          	bnez	a5,ffffffffc0200dd6 <best_fit_check+0x670>
    free_page(p);
ffffffffc02008f8:	854e                	mv	a0,s3
ffffffffc02008fa:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02008fc:	01843023          	sd	s8,0(s0)
ffffffffc0200900:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200904:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200908:	7d8000ef          	jal	ffffffffc02010e0 <free_pages>
    free_page(p1);
ffffffffc020090c:	4585                	li	a1,1
ffffffffc020090e:	8556                	mv	a0,s5
ffffffffc0200910:	7d0000ef          	jal	ffffffffc02010e0 <free_pages>
    free_page(p2);
ffffffffc0200914:	4585                	li	a1,1
ffffffffc0200916:	8552                	mv	a0,s4
ffffffffc0200918:	7c8000ef          	jal	ffffffffc02010e0 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020091c:	4515                	li	a0,5
ffffffffc020091e:	784000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc0200922:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200924:	48050963          	beqz	a0,ffffffffc0200db6 <best_fit_check+0x650>
ffffffffc0200928:	651c                	ld	a5,8(a0)
ffffffffc020092a:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc020092c:	8b85                	andi	a5,a5,1
ffffffffc020092e:	46079463          	bnez	a5,ffffffffc0200d96 <best_fit_check+0x630>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200932:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200934:	00043a83          	ld	s5,0(s0)
ffffffffc0200938:	00843a03          	ld	s4,8(s0)
ffffffffc020093c:	e000                	sd	s0,0(s0)
ffffffffc020093e:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200940:	762000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc0200944:	42051963          	bnez	a0,ffffffffc0200d76 <best_fit_check+0x610>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200948:	4589                	li	a1,2
ffffffffc020094a:	03898513          	addi	a0,s3,56
    unsigned int nr_free_store = nr_free;
ffffffffc020094e:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200952:	0e098c13          	addi	s8,s3,224
    nr_free = 0;
ffffffffc0200956:	00005797          	auipc	a5,0x5
ffffffffc020095a:	7007a523          	sw	zero,1802(a5) # ffffffffc0206060 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc020095e:	782000ef          	jal	ffffffffc02010e0 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200962:	8562                	mv	a0,s8
ffffffffc0200964:	4585                	li	a1,1
ffffffffc0200966:	77a000ef          	jal	ffffffffc02010e0 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020096a:	4511                	li	a0,4
ffffffffc020096c:	736000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc0200970:	3e051363          	bnez	a0,ffffffffc0200d56 <best_fit_check+0x5f0>
ffffffffc0200974:	0409b783          	ld	a5,64(s3)
ffffffffc0200978:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc020097a:	8b85                	andi	a5,a5,1
ffffffffc020097c:	3a078d63          	beqz	a5,ffffffffc0200d36 <best_fit_check+0x5d0>
ffffffffc0200980:	0489a703          	lw	a4,72(s3)
ffffffffc0200984:	4789                	li	a5,2
ffffffffc0200986:	3af71863          	bne	a4,a5,ffffffffc0200d36 <best_fit_check+0x5d0>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc020098a:	4505                	li	a0,1
ffffffffc020098c:	716000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc0200990:	8baa                	mv	s7,a0
ffffffffc0200992:	38050263          	beqz	a0,ffffffffc0200d16 <best_fit_check+0x5b0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200996:	4509                	li	a0,2
ffffffffc0200998:	70a000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc020099c:	34050d63          	beqz	a0,ffffffffc0200cf6 <best_fit_check+0x590>
    assert(p0 + 4 == p1);
ffffffffc02009a0:	337c1b63          	bne	s8,s7,ffffffffc0200cd6 <best_fit_check+0x570>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc02009a4:	854e                	mv	a0,s3
ffffffffc02009a6:	4595                	li	a1,5
ffffffffc02009a8:	738000ef          	jal	ffffffffc02010e0 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02009ac:	4515                	li	a0,5
ffffffffc02009ae:	6f4000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02009b2:	89aa                	mv	s3,a0
ffffffffc02009b4:	30050163          	beqz	a0,ffffffffc0200cb6 <best_fit_check+0x550>
    assert(alloc_page() == NULL);
ffffffffc02009b8:	4505                	li	a0,1
ffffffffc02009ba:	6e8000ef          	jal	ffffffffc02010a2 <alloc_pages>
ffffffffc02009be:	2c051c63          	bnez	a0,ffffffffc0200c96 <best_fit_check+0x530>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc02009c2:	481c                	lw	a5,16(s0)
ffffffffc02009c4:	2a079963          	bnez	a5,ffffffffc0200c76 <best_fit_check+0x510>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02009c8:	4595                	li	a1,5
ffffffffc02009ca:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02009cc:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc02009d0:	01543023          	sd	s5,0(s0)
ffffffffc02009d4:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc02009d8:	708000ef          	jal	ffffffffc02010e0 <free_pages>
    return listelm->next;
ffffffffc02009dc:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009de:	00878963          	beq	a5,s0,ffffffffc02009f0 <best_fit_check+0x28a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02009e2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02009e6:	679c                	ld	a5,8(a5)
ffffffffc02009e8:	397d                	addiw	s2,s2,-1
ffffffffc02009ea:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009ec:	fe879be3          	bne	a5,s0,ffffffffc02009e2 <best_fit_check+0x27c>
    }
    assert(count == 0);
ffffffffc02009f0:	26091363          	bnez	s2,ffffffffc0200c56 <best_fit_check+0x4f0>
    assert(total == 0);
ffffffffc02009f4:	e0ed                	bnez	s1,ffffffffc0200ad6 <best_fit_check+0x370>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc02009f6:	60a6                	ld	ra,72(sp)
ffffffffc02009f8:	6406                	ld	s0,64(sp)
ffffffffc02009fa:	74e2                	ld	s1,56(sp)
ffffffffc02009fc:	7942                	ld	s2,48(sp)
ffffffffc02009fe:	79a2                	ld	s3,40(sp)
ffffffffc0200a00:	7a02                	ld	s4,32(sp)
ffffffffc0200a02:	6ae2                	ld	s5,24(sp)
ffffffffc0200a04:	6b42                	ld	s6,16(sp)
ffffffffc0200a06:	6ba2                	ld	s7,8(sp)
ffffffffc0200a08:	6c02                	ld	s8,0(sp)
ffffffffc0200a0a:	6161                	addi	sp,sp,80
ffffffffc0200a0c:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a0e:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200a10:	4481                	li	s1,0
ffffffffc0200a12:	4901                	li	s2,0
ffffffffc0200a14:	bb51                	j	ffffffffc02007a8 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200a16:	00002697          	auipc	a3,0x2
ffffffffc0200a1a:	b0a68693          	addi	a3,a3,-1270 # ffffffffc0202520 <etext+0x654>
ffffffffc0200a1e:	00002617          	auipc	a2,0x2
ffffffffc0200a22:	ad260613          	addi	a2,a2,-1326 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200a26:	10c00593          	li	a1,268
ffffffffc0200a2a:	00002517          	auipc	a0,0x2
ffffffffc0200a2e:	ade50513          	addi	a0,a0,-1314 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200a32:	975ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200a36:	00002697          	auipc	a3,0x2
ffffffffc0200a3a:	b7a68693          	addi	a3,a3,-1158 # ffffffffc02025b0 <etext+0x6e4>
ffffffffc0200a3e:	00002617          	auipc	a2,0x2
ffffffffc0200a42:	ab260613          	addi	a2,a2,-1358 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200a46:	0d800593          	li	a1,216
ffffffffc0200a4a:	00002517          	auipc	a0,0x2
ffffffffc0200a4e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200a52:	955ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200a56:	00002697          	auipc	a3,0x2
ffffffffc0200a5a:	b8268693          	addi	a3,a3,-1150 # ffffffffc02025d8 <etext+0x70c>
ffffffffc0200a5e:	00002617          	auipc	a2,0x2
ffffffffc0200a62:	a9260613          	addi	a2,a2,-1390 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200a66:	0d900593          	li	a1,217
ffffffffc0200a6a:	00002517          	auipc	a0,0x2
ffffffffc0200a6e:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200a72:	935ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200a76:	00002697          	auipc	a3,0x2
ffffffffc0200a7a:	ba268693          	addi	a3,a3,-1118 # ffffffffc0202618 <etext+0x74c>
ffffffffc0200a7e:	00002617          	auipc	a2,0x2
ffffffffc0200a82:	a7260613          	addi	a2,a2,-1422 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200a86:	0db00593          	li	a1,219
ffffffffc0200a8a:	00002517          	auipc	a0,0x2
ffffffffc0200a8e:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200a92:	915ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200a96:	00002697          	auipc	a3,0x2
ffffffffc0200a9a:	c0a68693          	addi	a3,a3,-1014 # ffffffffc02026a0 <etext+0x7d4>
ffffffffc0200a9e:	00002617          	auipc	a2,0x2
ffffffffc0200aa2:	a5260613          	addi	a2,a2,-1454 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200aa6:	0f400593          	li	a1,244
ffffffffc0200aaa:	00002517          	auipc	a0,0x2
ffffffffc0200aae:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200ab2:	8f5ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ab6:	00002697          	auipc	a3,0x2
ffffffffc0200aba:	ada68693          	addi	a3,a3,-1318 # ffffffffc0202590 <etext+0x6c4>
ffffffffc0200abe:	00002617          	auipc	a2,0x2
ffffffffc0200ac2:	a3260613          	addi	a2,a2,-1486 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200ac6:	0d600593          	li	a1,214
ffffffffc0200aca:	00002517          	auipc	a0,0x2
ffffffffc0200ace:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200ad2:	8d5ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(total == 0);
ffffffffc0200ad6:	00002697          	auipc	a3,0x2
ffffffffc0200ada:	cfa68693          	addi	a3,a3,-774 # ffffffffc02027d0 <etext+0x904>
ffffffffc0200ade:	00002617          	auipc	a2,0x2
ffffffffc0200ae2:	a1260613          	addi	a2,a2,-1518 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200ae6:	14e00593          	li	a1,334
ffffffffc0200aea:	00002517          	auipc	a0,0x2
ffffffffc0200aee:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200af2:	8b5ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200af6:	00002697          	auipc	a3,0x2
ffffffffc0200afa:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0202530 <etext+0x664>
ffffffffc0200afe:	00002617          	auipc	a2,0x2
ffffffffc0200b02:	9f260613          	addi	a2,a2,-1550 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200b06:	10f00593          	li	a1,271
ffffffffc0200b0a:	00002517          	auipc	a0,0x2
ffffffffc0200b0e:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200b12:	895ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b16:	00002697          	auipc	a3,0x2
ffffffffc0200b1a:	a5a68693          	addi	a3,a3,-1446 # ffffffffc0202570 <etext+0x6a4>
ffffffffc0200b1e:	00002617          	auipc	a2,0x2
ffffffffc0200b22:	9d260613          	addi	a2,a2,-1582 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200b26:	0d500593          	li	a1,213
ffffffffc0200b2a:	00002517          	auipc	a0,0x2
ffffffffc0200b2e:	9de50513          	addi	a0,a0,-1570 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200b32:	875ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b36:	00002697          	auipc	a3,0x2
ffffffffc0200b3a:	a1a68693          	addi	a3,a3,-1510 # ffffffffc0202550 <etext+0x684>
ffffffffc0200b3e:	00002617          	auipc	a2,0x2
ffffffffc0200b42:	9b260613          	addi	a2,a2,-1614 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200b46:	0d400593          	li	a1,212
ffffffffc0200b4a:	00002517          	auipc	a0,0x2
ffffffffc0200b4e:	9be50513          	addi	a0,a0,-1602 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200b52:	855ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200b56:	00002697          	auipc	a3,0x2
ffffffffc0200b5a:	b2268693          	addi	a3,a3,-1246 # ffffffffc0202678 <etext+0x7ac>
ffffffffc0200b5e:	00002617          	auipc	a2,0x2
ffffffffc0200b62:	99260613          	addi	a2,a2,-1646 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200b66:	0f100593          	li	a1,241
ffffffffc0200b6a:	00002517          	auipc	a0,0x2
ffffffffc0200b6e:	99e50513          	addi	a0,a0,-1634 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200b72:	835ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b76:	00002697          	auipc	a3,0x2
ffffffffc0200b7a:	a1a68693          	addi	a3,a3,-1510 # ffffffffc0202590 <etext+0x6c4>
ffffffffc0200b7e:	00002617          	auipc	a2,0x2
ffffffffc0200b82:	97260613          	addi	a2,a2,-1678 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200b86:	0ef00593          	li	a1,239
ffffffffc0200b8a:	00002517          	auipc	a0,0x2
ffffffffc0200b8e:	97e50513          	addi	a0,a0,-1666 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200b92:	815ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b96:	00002697          	auipc	a3,0x2
ffffffffc0200b9a:	9da68693          	addi	a3,a3,-1574 # ffffffffc0202570 <etext+0x6a4>
ffffffffc0200b9e:	00002617          	auipc	a2,0x2
ffffffffc0200ba2:	95260613          	addi	a2,a2,-1710 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200ba6:	0ee00593          	li	a1,238
ffffffffc0200baa:	00002517          	auipc	a0,0x2
ffffffffc0200bae:	95e50513          	addi	a0,a0,-1698 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200bb2:	ff4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bb6:	00002697          	auipc	a3,0x2
ffffffffc0200bba:	99a68693          	addi	a3,a3,-1638 # ffffffffc0202550 <etext+0x684>
ffffffffc0200bbe:	00002617          	auipc	a2,0x2
ffffffffc0200bc2:	93260613          	addi	a2,a2,-1742 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200bc6:	0ed00593          	li	a1,237
ffffffffc0200bca:	00002517          	auipc	a0,0x2
ffffffffc0200bce:	93e50513          	addi	a0,a0,-1730 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200bd2:	fd4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(nr_free == 3);
ffffffffc0200bd6:	00002697          	auipc	a3,0x2
ffffffffc0200bda:	aba68693          	addi	a3,a3,-1350 # ffffffffc0202690 <etext+0x7c4>
ffffffffc0200bde:	00002617          	auipc	a2,0x2
ffffffffc0200be2:	91260613          	addi	a2,a2,-1774 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200be6:	0eb00593          	li	a1,235
ffffffffc0200bea:	00002517          	auipc	a0,0x2
ffffffffc0200bee:	91e50513          	addi	a0,a0,-1762 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200bf2:	fb4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200bf6:	00002697          	auipc	a3,0x2
ffffffffc0200bfa:	a8268693          	addi	a3,a3,-1406 # ffffffffc0202678 <etext+0x7ac>
ffffffffc0200bfe:	00002617          	auipc	a2,0x2
ffffffffc0200c02:	8f260613          	addi	a2,a2,-1806 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200c06:	0e600593          	li	a1,230
ffffffffc0200c0a:	00002517          	auipc	a0,0x2
ffffffffc0200c0e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200c12:	f94ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c16:	00002697          	auipc	a3,0x2
ffffffffc0200c1a:	a4268693          	addi	a3,a3,-1470 # ffffffffc0202658 <etext+0x78c>
ffffffffc0200c1e:	00002617          	auipc	a2,0x2
ffffffffc0200c22:	8d260613          	addi	a2,a2,-1838 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200c26:	0dd00593          	li	a1,221
ffffffffc0200c2a:	00002517          	auipc	a0,0x2
ffffffffc0200c2e:	8de50513          	addi	a0,a0,-1826 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200c32:	f74ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c36:	00002697          	auipc	a3,0x2
ffffffffc0200c3a:	a0268693          	addi	a3,a3,-1534 # ffffffffc0202638 <etext+0x76c>
ffffffffc0200c3e:	00002617          	auipc	a2,0x2
ffffffffc0200c42:	8b260613          	addi	a2,a2,-1870 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200c46:	0dc00593          	li	a1,220
ffffffffc0200c4a:	00002517          	auipc	a0,0x2
ffffffffc0200c4e:	8be50513          	addi	a0,a0,-1858 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200c52:	f54ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(count == 0);
ffffffffc0200c56:	00002697          	auipc	a3,0x2
ffffffffc0200c5a:	b6a68693          	addi	a3,a3,-1174 # ffffffffc02027c0 <etext+0x8f4>
ffffffffc0200c5e:	00002617          	auipc	a2,0x2
ffffffffc0200c62:	89260613          	addi	a2,a2,-1902 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200c66:	14d00593          	li	a1,333
ffffffffc0200c6a:	00002517          	auipc	a0,0x2
ffffffffc0200c6e:	89e50513          	addi	a0,a0,-1890 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200c72:	f34ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(nr_free == 0);
ffffffffc0200c76:	00002697          	auipc	a3,0x2
ffffffffc0200c7a:	a6268693          	addi	a3,a3,-1438 # ffffffffc02026d8 <etext+0x80c>
ffffffffc0200c7e:	00002617          	auipc	a2,0x2
ffffffffc0200c82:	87260613          	addi	a2,a2,-1934 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200c86:	14200593          	li	a1,322
ffffffffc0200c8a:	00002517          	auipc	a0,0x2
ffffffffc0200c8e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200c92:	f14ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c96:	00002697          	auipc	a3,0x2
ffffffffc0200c9a:	9e268693          	addi	a3,a3,-1566 # ffffffffc0202678 <etext+0x7ac>
ffffffffc0200c9e:	00002617          	auipc	a2,0x2
ffffffffc0200ca2:	85260613          	addi	a2,a2,-1966 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200ca6:	13c00593          	li	a1,316
ffffffffc0200caa:	00002517          	auipc	a0,0x2
ffffffffc0200cae:	85e50513          	addi	a0,a0,-1954 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200cb2:	ef4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200cb6:	00002697          	auipc	a3,0x2
ffffffffc0200cba:	aea68693          	addi	a3,a3,-1302 # ffffffffc02027a0 <etext+0x8d4>
ffffffffc0200cbe:	00002617          	auipc	a2,0x2
ffffffffc0200cc2:	83260613          	addi	a2,a2,-1998 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200cc6:	13b00593          	li	a1,315
ffffffffc0200cca:	00002517          	auipc	a0,0x2
ffffffffc0200cce:	83e50513          	addi	a0,a0,-1986 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200cd2:	ed4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200cd6:	00002697          	auipc	a3,0x2
ffffffffc0200cda:	aba68693          	addi	a3,a3,-1350 # ffffffffc0202790 <etext+0x8c4>
ffffffffc0200cde:	00002617          	auipc	a2,0x2
ffffffffc0200ce2:	81260613          	addi	a2,a2,-2030 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200ce6:	13300593          	li	a1,307
ffffffffc0200cea:	00002517          	auipc	a0,0x2
ffffffffc0200cee:	81e50513          	addi	a0,a0,-2018 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200cf2:	eb4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200cf6:	00002697          	auipc	a3,0x2
ffffffffc0200cfa:	a8268693          	addi	a3,a3,-1406 # ffffffffc0202778 <etext+0x8ac>
ffffffffc0200cfe:	00001617          	auipc	a2,0x1
ffffffffc0200d02:	7f260613          	addi	a2,a2,2034 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200d06:	13200593          	li	a1,306
ffffffffc0200d0a:	00001517          	auipc	a0,0x1
ffffffffc0200d0e:	7fe50513          	addi	a0,a0,2046 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200d12:	e94ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200d16:	00002697          	auipc	a3,0x2
ffffffffc0200d1a:	a4268693          	addi	a3,a3,-1470 # ffffffffc0202758 <etext+0x88c>
ffffffffc0200d1e:	00001617          	auipc	a2,0x1
ffffffffc0200d22:	7d260613          	addi	a2,a2,2002 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200d26:	13100593          	li	a1,305
ffffffffc0200d2a:	00001517          	auipc	a0,0x1
ffffffffc0200d2e:	7de50513          	addi	a0,a0,2014 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200d32:	e74ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200d36:	00002697          	auipc	a3,0x2
ffffffffc0200d3a:	9f268693          	addi	a3,a3,-1550 # ffffffffc0202728 <etext+0x85c>
ffffffffc0200d3e:	00001617          	auipc	a2,0x1
ffffffffc0200d42:	7b260613          	addi	a2,a2,1970 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200d46:	12f00593          	li	a1,303
ffffffffc0200d4a:	00001517          	auipc	a0,0x1
ffffffffc0200d4e:	7be50513          	addi	a0,a0,1982 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200d52:	e54ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d56:	00002697          	auipc	a3,0x2
ffffffffc0200d5a:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0202710 <etext+0x844>
ffffffffc0200d5e:	00001617          	auipc	a2,0x1
ffffffffc0200d62:	79260613          	addi	a2,a2,1938 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200d66:	12e00593          	li	a1,302
ffffffffc0200d6a:	00001517          	auipc	a0,0x1
ffffffffc0200d6e:	79e50513          	addi	a0,a0,1950 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200d72:	e34ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d76:	00002697          	auipc	a3,0x2
ffffffffc0200d7a:	90268693          	addi	a3,a3,-1790 # ffffffffc0202678 <etext+0x7ac>
ffffffffc0200d7e:	00001617          	auipc	a2,0x1
ffffffffc0200d82:	77260613          	addi	a2,a2,1906 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200d86:	12200593          	li	a1,290
ffffffffc0200d8a:	00001517          	auipc	a0,0x1
ffffffffc0200d8e:	77e50513          	addi	a0,a0,1918 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200d92:	e14ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(!PageProperty(p0));
ffffffffc0200d96:	00002697          	auipc	a3,0x2
ffffffffc0200d9a:	96268693          	addi	a3,a3,-1694 # ffffffffc02026f8 <etext+0x82c>
ffffffffc0200d9e:	00001617          	auipc	a2,0x1
ffffffffc0200da2:	75260613          	addi	a2,a2,1874 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200da6:	11900593          	li	a1,281
ffffffffc0200daa:	00001517          	auipc	a0,0x1
ffffffffc0200dae:	75e50513          	addi	a0,a0,1886 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200db2:	df4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(p0 != NULL);
ffffffffc0200db6:	00002697          	auipc	a3,0x2
ffffffffc0200dba:	93268693          	addi	a3,a3,-1742 # ffffffffc02026e8 <etext+0x81c>
ffffffffc0200dbe:	00001617          	auipc	a2,0x1
ffffffffc0200dc2:	73260613          	addi	a2,a2,1842 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200dc6:	11800593          	li	a1,280
ffffffffc0200dca:	00001517          	auipc	a0,0x1
ffffffffc0200dce:	73e50513          	addi	a0,a0,1854 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200dd2:	dd4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(nr_free == 0);
ffffffffc0200dd6:	00002697          	auipc	a3,0x2
ffffffffc0200dda:	90268693          	addi	a3,a3,-1790 # ffffffffc02026d8 <etext+0x80c>
ffffffffc0200dde:	00001617          	auipc	a2,0x1
ffffffffc0200de2:	71260613          	addi	a2,a2,1810 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200de6:	0fa00593          	li	a1,250
ffffffffc0200dea:	00001517          	auipc	a0,0x1
ffffffffc0200dee:	71e50513          	addi	a0,a0,1822 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200df2:	db4ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200df6:	00002697          	auipc	a3,0x2
ffffffffc0200dfa:	88268693          	addi	a3,a3,-1918 # ffffffffc0202678 <etext+0x7ac>
ffffffffc0200dfe:	00001617          	auipc	a2,0x1
ffffffffc0200e02:	6f260613          	addi	a2,a2,1778 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200e06:	0f800593          	li	a1,248
ffffffffc0200e0a:	00001517          	auipc	a0,0x1
ffffffffc0200e0e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200e12:	d94ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200e16:	00002697          	auipc	a3,0x2
ffffffffc0200e1a:	8a268693          	addi	a3,a3,-1886 # ffffffffc02026b8 <etext+0x7ec>
ffffffffc0200e1e:	00001617          	auipc	a2,0x1
ffffffffc0200e22:	6d260613          	addi	a2,a2,1746 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200e26:	0f700593          	li	a1,247
ffffffffc0200e2a:	00001517          	auipc	a0,0x1
ffffffffc0200e2e:	6de50513          	addi	a0,a0,1758 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200e32:	d74ff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc0200e36 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200e36:	1141                	addi	sp,sp,-16
ffffffffc0200e38:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e3a:	14058a63          	beqz	a1,ffffffffc0200f8e <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200e3e:	00359713          	slli	a4,a1,0x3
ffffffffc0200e42:	8f0d                	sub	a4,a4,a1
ffffffffc0200e44:	070e                	slli	a4,a4,0x3
ffffffffc0200e46:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0200e4a:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0200e4c:	c30d                	beqz	a4,ffffffffc0200e6e <best_fit_free_pages+0x38>
ffffffffc0200e4e:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200e50:	8b05                	andi	a4,a4,1
ffffffffc0200e52:	10071e63          	bnez	a4,ffffffffc0200f6e <best_fit_free_pages+0x138>
ffffffffc0200e56:	6798                	ld	a4,8(a5)
ffffffffc0200e58:	8b09                	andi	a4,a4,2
ffffffffc0200e5a:	10071a63          	bnez	a4,ffffffffc0200f6e <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200e5e:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200e62:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200e66:	03878793          	addi	a5,a5,56
ffffffffc0200e6a:	fed792e3          	bne	a5,a3,ffffffffc0200e4e <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0200e6e:	2581                	sext.w	a1,a1
ffffffffc0200e70:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200e72:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200e76:	4789                	li	a5,2
ffffffffc0200e78:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0200e7c:	00005697          	auipc	a3,0x5
ffffffffc0200e80:	1d468693          	addi	a3,a3,468 # ffffffffc0206050 <free_area>
ffffffffc0200e84:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200e86:	669c                	ld	a5,8(a3)
ffffffffc0200e88:	9f2d                	addw	a4,a4,a1
ffffffffc0200e8a:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200e8c:	0ad78563          	beq	a5,a3,ffffffffc0200f36 <best_fit_free_pages+0x100>
            struct Page* page = le2page(le, page_link);
ffffffffc0200e90:	fe878713          	addi	a4,a5,-24
ffffffffc0200e94:	4581                	li	a1,0
ffffffffc0200e96:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0200e9a:	00e56a63          	bltu	a0,a4,ffffffffc0200eae <best_fit_free_pages+0x78>
    return listelm->next;
ffffffffc0200e9e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200ea0:	06d70263          	beq	a4,a3,ffffffffc0200f04 <best_fit_free_pages+0xce>
    struct Page *p = base;
ffffffffc0200ea4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200ea6:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200eaa:	fee57ae3          	bgeu	a0,a4,ffffffffc0200e9e <best_fit_free_pages+0x68>
ffffffffc0200eae:	c199                	beqz	a1,ffffffffc0200eb4 <best_fit_free_pages+0x7e>
ffffffffc0200eb0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200eb4:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0200eb6:	e390                	sd	a2,0(a5)
ffffffffc0200eb8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200eba:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200ebc:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0200ebe:	02d70063          	beq	a4,a3,ffffffffc0200ede <best_fit_free_pages+0xa8>
        if(p+p->property == base){
ffffffffc0200ec2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0200ec6:	fe870593          	addi	a1,a4,-24
        if(p+p->property == base){
ffffffffc0200eca:	02081613          	slli	a2,a6,0x20
ffffffffc0200ece:	9201                	srli	a2,a2,0x20
ffffffffc0200ed0:	00361793          	slli	a5,a2,0x3
ffffffffc0200ed4:	8f91                	sub	a5,a5,a2
ffffffffc0200ed6:	078e                	slli	a5,a5,0x3
ffffffffc0200ed8:	97ae                	add	a5,a5,a1
ffffffffc0200eda:	02f50f63          	beq	a0,a5,ffffffffc0200f18 <best_fit_free_pages+0xe2>
    return listelm->next;
ffffffffc0200ede:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0200ee0:	00d70f63          	beq	a4,a3,ffffffffc0200efe <best_fit_free_pages+0xc8>
        if (base + base->property == p) {
ffffffffc0200ee4:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0200ee6:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0200eea:	02059613          	slli	a2,a1,0x20
ffffffffc0200eee:	9201                	srli	a2,a2,0x20
ffffffffc0200ef0:	00361793          	slli	a5,a2,0x3
ffffffffc0200ef4:	8f91                	sub	a5,a5,a2
ffffffffc0200ef6:	078e                	slli	a5,a5,0x3
ffffffffc0200ef8:	97aa                	add	a5,a5,a0
ffffffffc0200efa:	04f68a63          	beq	a3,a5,ffffffffc0200f4e <best_fit_free_pages+0x118>
}
ffffffffc0200efe:	60a2                	ld	ra,8(sp)
ffffffffc0200f00:	0141                	addi	sp,sp,16
ffffffffc0200f02:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200f04:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200f06:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200f08:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200f0a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0200f0c:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200f0e:	02d70d63          	beq	a4,a3,ffffffffc0200f48 <best_fit_free_pages+0x112>
ffffffffc0200f12:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0200f14:	87ba                	mv	a5,a4
ffffffffc0200f16:	bf41                	j	ffffffffc0200ea6 <best_fit_free_pages+0x70>
            p->property += base->property;
ffffffffc0200f18:	491c                	lw	a5,16(a0)
ffffffffc0200f1a:	010787bb          	addw	a5,a5,a6
ffffffffc0200f1e:	fef72c23          	sw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200f22:	57f5                	li	a5,-3
ffffffffc0200f24:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f28:	6d10                	ld	a2,24(a0)
ffffffffc0200f2a:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0200f2c:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc0200f2e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0200f30:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0200f32:	e390                	sd	a2,0(a5)
ffffffffc0200f34:	b775                	j	ffffffffc0200ee0 <best_fit_free_pages+0xaa>
}
ffffffffc0200f36:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0200f38:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0200f3c:	e398                	sd	a4,0(a5)
ffffffffc0200f3e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0200f40:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f42:	ed1c                	sd	a5,24(a0)
}
ffffffffc0200f44:	0141                	addi	sp,sp,16
ffffffffc0200f46:	8082                	ret
ffffffffc0200f48:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0200f4a:	873e                	mv	a4,a5
ffffffffc0200f4c:	bf8d                	j	ffffffffc0200ebe <best_fit_free_pages+0x88>
            base->property += p->property;
ffffffffc0200f4e:	ff872783          	lw	a5,-8(a4)
ffffffffc0200f52:	ff070693          	addi	a3,a4,-16
ffffffffc0200f56:	9fad                	addw	a5,a5,a1
ffffffffc0200f58:	c91c                	sw	a5,16(a0)
ffffffffc0200f5a:	57f5                	li	a5,-3
ffffffffc0200f5c:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f60:	6314                	ld	a3,0(a4)
ffffffffc0200f62:	671c                	ld	a5,8(a4)
}
ffffffffc0200f64:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0200f66:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200f68:	e394                	sd	a3,0(a5)
ffffffffc0200f6a:	0141                	addi	sp,sp,16
ffffffffc0200f6c:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200f6e:	00002697          	auipc	a3,0x2
ffffffffc0200f72:	87268693          	addi	a3,a3,-1934 # ffffffffc02027e0 <etext+0x914>
ffffffffc0200f76:	00001617          	auipc	a2,0x1
ffffffffc0200f7a:	57a60613          	addi	a2,a2,1402 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200f7e:	09600593          	li	a1,150
ffffffffc0200f82:	00001517          	auipc	a0,0x1
ffffffffc0200f86:	58650513          	addi	a0,a0,1414 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200f8a:	c1cff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(n > 0);
ffffffffc0200f8e:	00001697          	auipc	a3,0x1
ffffffffc0200f92:	55a68693          	addi	a3,a3,1370 # ffffffffc02024e8 <etext+0x61c>
ffffffffc0200f96:	00001617          	auipc	a2,0x1
ffffffffc0200f9a:	55a60613          	addi	a2,a2,1370 # ffffffffc02024f0 <etext+0x624>
ffffffffc0200f9e:	09300593          	li	a1,147
ffffffffc0200fa2:	00001517          	auipc	a0,0x1
ffffffffc0200fa6:	56650513          	addi	a0,a0,1382 # ffffffffc0202508 <etext+0x63c>
ffffffffc0200faa:	bfcff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc0200fae <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0200fae:	1141                	addi	sp,sp,-16
ffffffffc0200fb0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fb2:	c9e1                	beqz	a1,ffffffffc0201082 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0200fb4:	00359713          	slli	a4,a1,0x3
ffffffffc0200fb8:	8f0d                	sub	a4,a4,a1
ffffffffc0200fba:	070e                	slli	a4,a4,0x3
ffffffffc0200fbc:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0200fc0:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0200fc2:	cf11                	beqz	a4,ffffffffc0200fde <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200fc4:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200fc6:	8b05                	andi	a4,a4,1
ffffffffc0200fc8:	cf49                	beqz	a4,ffffffffc0201062 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0200fca:	0007a823          	sw	zero,16(a5)
ffffffffc0200fce:	0007b423          	sd	zero,8(a5)
ffffffffc0200fd2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200fd6:	03878793          	addi	a5,a5,56
ffffffffc0200fda:	fed795e3          	bne	a5,a3,ffffffffc0200fc4 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc0200fde:	2581                	sext.w	a1,a1
ffffffffc0200fe0:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fe2:	4789                	li	a5,2
ffffffffc0200fe4:	00850713          	addi	a4,a0,8
ffffffffc0200fe8:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0200fec:	00005697          	auipc	a3,0x5
ffffffffc0200ff0:	06468693          	addi	a3,a3,100 # ffffffffc0206050 <free_area>
ffffffffc0200ff4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200ff6:	669c                	ld	a5,8(a3)
ffffffffc0200ff8:	9f2d                	addw	a4,a4,a1
ffffffffc0200ffa:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200ffc:	04d78663          	beq	a5,a3,ffffffffc0201048 <best_fit_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc0201000:	fe878713          	addi	a4,a5,-24
ffffffffc0201004:	4581                	li	a1,0
ffffffffc0201006:	01850613          	addi	a2,a0,24
            if(base<page){
ffffffffc020100a:	00e56a63          	bltu	a0,a4,ffffffffc020101e <best_fit_init_memmap+0x70>
    return listelm->next;
ffffffffc020100e:	6798                	ld	a4,8(a5)
            else if(list_next(le) == &free_list){
ffffffffc0201010:	02d70263          	beq	a4,a3,ffffffffc0201034 <best_fit_init_memmap+0x86>
    struct Page *p = base;
ffffffffc0201014:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201016:	fe878713          	addi	a4,a5,-24
            if(base<page){
ffffffffc020101a:	fee57ae3          	bgeu	a0,a4,ffffffffc020100e <best_fit_init_memmap+0x60>
ffffffffc020101e:	c199                	beqz	a1,ffffffffc0201024 <best_fit_init_memmap+0x76>
ffffffffc0201020:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201024:	6398                	ld	a4,0(a5)
}
ffffffffc0201026:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201028:	e390                	sd	a2,0(a5)
ffffffffc020102a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020102c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020102e:	ed18                	sd	a4,24(a0)
ffffffffc0201030:	0141                	addi	sp,sp,16
ffffffffc0201032:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201034:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201036:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201038:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020103a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020103c:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020103e:	00d70e63          	beq	a4,a3,ffffffffc020105a <best_fit_init_memmap+0xac>
ffffffffc0201042:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201044:	87ba                	mv	a5,a4
ffffffffc0201046:	bfc1                	j	ffffffffc0201016 <best_fit_init_memmap+0x68>
}
ffffffffc0201048:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020104a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020104e:	e398                	sd	a4,0(a5)
ffffffffc0201050:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201052:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201054:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201056:	0141                	addi	sp,sp,16
ffffffffc0201058:	8082                	ret
ffffffffc020105a:	60a2                	ld	ra,8(sp)
ffffffffc020105c:	e290                	sd	a2,0(a3)
ffffffffc020105e:	0141                	addi	sp,sp,16
ffffffffc0201060:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201062:	00001697          	auipc	a3,0x1
ffffffffc0201066:	7a668693          	addi	a3,a3,1958 # ffffffffc0202808 <etext+0x93c>
ffffffffc020106a:	00001617          	auipc	a2,0x1
ffffffffc020106e:	48660613          	addi	a2,a2,1158 # ffffffffc02024f0 <etext+0x624>
ffffffffc0201072:	04a00593          	li	a1,74
ffffffffc0201076:	00001517          	auipc	a0,0x1
ffffffffc020107a:	49250513          	addi	a0,a0,1170 # ffffffffc0202508 <etext+0x63c>
ffffffffc020107e:	b28ff0ef          	jal	ffffffffc02003a6 <__panic>
    assert(n > 0);
ffffffffc0201082:	00001697          	auipc	a3,0x1
ffffffffc0201086:	46668693          	addi	a3,a3,1126 # ffffffffc02024e8 <etext+0x61c>
ffffffffc020108a:	00001617          	auipc	a2,0x1
ffffffffc020108e:	46660613          	addi	a2,a2,1126 # ffffffffc02024f0 <etext+0x624>
ffffffffc0201092:	04700593          	li	a1,71
ffffffffc0201096:	00001517          	auipc	a0,0x1
ffffffffc020109a:	47250513          	addi	a0,a0,1138 # ffffffffc0202508 <etext+0x63c>
ffffffffc020109e:	b08ff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc02010a2 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010a2:	100027f3          	csrr	a5,sstatus
ffffffffc02010a6:	8b89                	andi	a5,a5,2
ffffffffc02010a8:	e799                	bnez	a5,ffffffffc02010b6 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02010aa:	00005797          	auipc	a5,0x5
ffffffffc02010ae:	48e7b783          	ld	a5,1166(a5) # ffffffffc0206538 <pmm_manager>
ffffffffc02010b2:	6f9c                	ld	a5,24(a5)
ffffffffc02010b4:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02010b6:	1141                	addi	sp,sp,-16
ffffffffc02010b8:	e406                	sd	ra,8(sp)
ffffffffc02010ba:	e022                	sd	s0,0(sp)
ffffffffc02010bc:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02010be:	b8cff0ef          	jal	ffffffffc020044a <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02010c2:	00005797          	auipc	a5,0x5
ffffffffc02010c6:	4767b783          	ld	a5,1142(a5) # ffffffffc0206538 <pmm_manager>
ffffffffc02010ca:	6f9c                	ld	a5,24(a5)
ffffffffc02010cc:	8522                	mv	a0,s0
ffffffffc02010ce:	9782                	jalr	a5
ffffffffc02010d0:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02010d2:	b72ff0ef          	jal	ffffffffc0200444 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02010d6:	60a2                	ld	ra,8(sp)
ffffffffc02010d8:	8522                	mv	a0,s0
ffffffffc02010da:	6402                	ld	s0,0(sp)
ffffffffc02010dc:	0141                	addi	sp,sp,16
ffffffffc02010de:	8082                	ret

ffffffffc02010e0 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010e0:	100027f3          	csrr	a5,sstatus
ffffffffc02010e4:	8b89                	andi	a5,a5,2
ffffffffc02010e6:	e799                	bnez	a5,ffffffffc02010f4 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02010e8:	00005797          	auipc	a5,0x5
ffffffffc02010ec:	4507b783          	ld	a5,1104(a5) # ffffffffc0206538 <pmm_manager>
ffffffffc02010f0:	739c                	ld	a5,32(a5)
ffffffffc02010f2:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02010f4:	1101                	addi	sp,sp,-32
ffffffffc02010f6:	ec06                	sd	ra,24(sp)
ffffffffc02010f8:	e822                	sd	s0,16(sp)
ffffffffc02010fa:	e426                	sd	s1,8(sp)
ffffffffc02010fc:	842a                	mv	s0,a0
ffffffffc02010fe:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201100:	b4aff0ef          	jal	ffffffffc020044a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201104:	00005797          	auipc	a5,0x5
ffffffffc0201108:	4347b783          	ld	a5,1076(a5) # ffffffffc0206538 <pmm_manager>
ffffffffc020110c:	739c                	ld	a5,32(a5)
ffffffffc020110e:	85a6                	mv	a1,s1
ffffffffc0201110:	8522                	mv	a0,s0
ffffffffc0201112:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201114:	6442                	ld	s0,16(sp)
ffffffffc0201116:	60e2                	ld	ra,24(sp)
ffffffffc0201118:	64a2                	ld	s1,8(sp)
ffffffffc020111a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020111c:	b28ff06f          	j	ffffffffc0200444 <intr_enable>

ffffffffc0201120 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201120:	100027f3          	csrr	a5,sstatus
ffffffffc0201124:	8b89                	andi	a5,a5,2
ffffffffc0201126:	e799                	bnez	a5,ffffffffc0201134 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201128:	00005797          	auipc	a5,0x5
ffffffffc020112c:	4107b783          	ld	a5,1040(a5) # ffffffffc0206538 <pmm_manager>
ffffffffc0201130:	779c                	ld	a5,40(a5)
ffffffffc0201132:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201134:	1141                	addi	sp,sp,-16
ffffffffc0201136:	e406                	sd	ra,8(sp)
ffffffffc0201138:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020113a:	b10ff0ef          	jal	ffffffffc020044a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020113e:	00005797          	auipc	a5,0x5
ffffffffc0201142:	3fa7b783          	ld	a5,1018(a5) # ffffffffc0206538 <pmm_manager>
ffffffffc0201146:	779c                	ld	a5,40(a5)
ffffffffc0201148:	9782                	jalr	a5
ffffffffc020114a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020114c:	af8ff0ef          	jal	ffffffffc0200444 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201150:	60a2                	ld	ra,8(sp)
ffffffffc0201152:	8522                	mv	a0,s0
ffffffffc0201154:	6402                	ld	s0,0(sp)
ffffffffc0201156:	0141                	addi	sp,sp,16
ffffffffc0201158:	8082                	ret

ffffffffc020115a <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020115a:	00002797          	auipc	a5,0x2
ffffffffc020115e:	ba678793          	addi	a5,a5,-1114 # ffffffffc0202d00 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201162:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201164:	1101                	addi	sp,sp,-32
ffffffffc0201166:	ec06                	sd	ra,24(sp)
ffffffffc0201168:	e822                	sd	s0,16(sp)
ffffffffc020116a:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020116c:	00005417          	auipc	s0,0x5
ffffffffc0201170:	3cc40413          	addi	s0,s0,972 # ffffffffc0206538 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201174:	00001517          	auipc	a0,0x1
ffffffffc0201178:	6bc50513          	addi	a0,a0,1724 # ffffffffc0202830 <etext+0x964>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020117c:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020117e:	f35fe0ef          	jal	ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0201182:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201184:	00005497          	auipc	s1,0x5
ffffffffc0201188:	3cc48493          	addi	s1,s1,972 # ffffffffc0206550 <va_pa_offset>
    pmm_manager->init();
ffffffffc020118c:	679c                	ld	a5,8(a5)
ffffffffc020118e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201190:	57f5                	li	a5,-3
ffffffffc0201192:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201194:	00001517          	auipc	a0,0x1
ffffffffc0201198:	6b450513          	addi	a0,a0,1716 # ffffffffc0202848 <etext+0x97c>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020119c:	e09c                	sd	a5,0(s1)
    cprintf("physcial memory map:\n");
ffffffffc020119e:	f15fe0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02011a2:	46c5                	li	a3,17
ffffffffc02011a4:	06ee                	slli	a3,a3,0x1b
ffffffffc02011a6:	40100613          	li	a2,1025
ffffffffc02011aa:	16fd                	addi	a3,a3,-1
ffffffffc02011ac:	0656                	slli	a2,a2,0x15
ffffffffc02011ae:	07e005b7          	lui	a1,0x7e00
ffffffffc02011b2:	00001517          	auipc	a0,0x1
ffffffffc02011b6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0202860 <etext+0x994>
ffffffffc02011ba:	ef9fe0ef          	jal	ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011be:	777d                	lui	a4,0xfffff
ffffffffc02011c0:	00006797          	auipc	a5,0x6
ffffffffc02011c4:	3af78793          	addi	a5,a5,943 # ffffffffc020756f <end+0xfff>
ffffffffc02011c8:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02011ca:	00005517          	auipc	a0,0x5
ffffffffc02011ce:	38e50513          	addi	a0,a0,910 # ffffffffc0206558 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011d2:	00005597          	auipc	a1,0x5
ffffffffc02011d6:	38e58593          	addi	a1,a1,910 # ffffffffc0206560 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02011da:	00088737          	lui	a4,0x88
ffffffffc02011de:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011e0:	e19c                	sd	a5,0(a1)
ffffffffc02011e2:	4705                	li	a4,1
ffffffffc02011e4:	07a1                	addi	a5,a5,8
ffffffffc02011e6:	40e7b02f          	amoor.d	zero,a4,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011ea:	03800693          	li	a3,56
ffffffffc02011ee:	4885                	li	a7,1
ffffffffc02011f0:	fff80837          	lui	a6,0xfff80
        SetPageReserved(pages + i);
ffffffffc02011f4:	619c                	ld	a5,0(a1)
ffffffffc02011f6:	97b6                	add	a5,a5,a3
ffffffffc02011f8:	07a1                	addi	a5,a5,8
ffffffffc02011fa:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011fe:	611c                	ld	a5,0(a0)
ffffffffc0201200:	0705                	addi	a4,a4,1 # 88001 <kern_entry-0xffffffffc0177fff>
ffffffffc0201202:	03868693          	addi	a3,a3,56
ffffffffc0201206:	01078633          	add	a2,a5,a6
ffffffffc020120a:	fec765e3          	bltu	a4,a2,ffffffffc02011f4 <pmm_init+0x9a>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020120e:	6190                	ld	a2,0(a1)
ffffffffc0201210:	00379693          	slli	a3,a5,0x3
ffffffffc0201214:	8e9d                	sub	a3,a3,a5
ffffffffc0201216:	fe400737          	lui	a4,0xfe400
ffffffffc020121a:	9732                	add	a4,a4,a2
ffffffffc020121c:	068e                	slli	a3,a3,0x3
ffffffffc020121e:	96ba                	add	a3,a3,a4
ffffffffc0201220:	c0200737          	lui	a4,0xc0200
ffffffffc0201224:	0ae6ea63          	bltu	a3,a4,ffffffffc02012d8 <pmm_init+0x17e>
ffffffffc0201228:	6098                	ld	a4,0(s1)
    if (freemem < mem_end) {
ffffffffc020122a:	45c5                	li	a1,17
ffffffffc020122c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020122e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201230:	04b6ef63          	bltu	a3,a1,ffffffffc020128e <pmm_init+0x134>
    // then use pmm->init_memmap to create free page list
    page_init();
   
    
    //sbi_shutdown();
    init_cache();
ffffffffc0201234:	0d6000ef          	jal	ffffffffc020130a <init_cache>
    debug_print_slab_caches();
ffffffffc0201238:	5d0000ef          	jal	ffffffffc0201808 <debug_print_slab_caches>
    check();
ffffffffc020123c:	4f4000ef          	jal	ffffffffc0201730 <check>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
    
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201240:	601c                	ld	a5,0(s0)
ffffffffc0201242:	7b9c                	ld	a5,48(a5)
ffffffffc0201244:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201246:	00001517          	auipc	a0,0x1
ffffffffc020124a:	6b250513          	addi	a0,a0,1714 # ffffffffc02028f8 <etext+0xa2c>
ffffffffc020124e:	e65fe0ef          	jal	ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201252:	00004597          	auipc	a1,0x4
ffffffffc0201256:	dae58593          	addi	a1,a1,-594 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020125a:	00005797          	auipc	a5,0x5
ffffffffc020125e:	2eb7b723          	sd	a1,750(a5) # ffffffffc0206548 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201262:	c02007b7          	lui	a5,0xc0200
ffffffffc0201266:	08f5e563          	bltu	a1,a5,ffffffffc02012f0 <pmm_init+0x196>
ffffffffc020126a:	609c                	ld	a5,0(s1)
}
ffffffffc020126c:	6442                	ld	s0,16(sp)
ffffffffc020126e:	60e2                	ld	ra,24(sp)
ffffffffc0201270:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201272:	40f586b3          	sub	a3,a1,a5
ffffffffc0201276:	00005797          	auipc	a5,0x5
ffffffffc020127a:	2cd7b523          	sd	a3,714(a5) # ffffffffc0206540 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020127e:	00001517          	auipc	a0,0x1
ffffffffc0201282:	69a50513          	addi	a0,a0,1690 # ffffffffc0202918 <etext+0xa4c>
ffffffffc0201286:	8636                	mv	a2,a3
}
ffffffffc0201288:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020128a:	e29fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020128e:	6705                	lui	a4,0x1
ffffffffc0201290:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0201292:	96ba                	add	a3,a3,a4
ffffffffc0201294:	777d                	lui	a4,0xfffff
ffffffffc0201296:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201298:	00c6d713          	srli	a4,a3,0xc
ffffffffc020129c:	02f77263          	bgeu	a4,a5,ffffffffc02012c0 <pmm_init+0x166>
    pmm_manager->init_memmap(base, n);
ffffffffc02012a0:	00043803          	ld	a6,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02012a4:	fff807b7          	lui	a5,0xfff80
ffffffffc02012a8:	97ba                	add	a5,a5,a4
ffffffffc02012aa:	00379513          	slli	a0,a5,0x3
ffffffffc02012ae:	8d1d                	sub	a0,a0,a5
ffffffffc02012b0:	01083783          	ld	a5,16(a6) # fffffffffff80010 <end+0x3fd79aa0>
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02012b4:	8d95                	sub	a1,a1,a3
ffffffffc02012b6:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02012b8:	81b1                	srli	a1,a1,0xc
ffffffffc02012ba:	9532                	add	a0,a0,a2
ffffffffc02012bc:	9782                	jalr	a5
}
ffffffffc02012be:	bf9d                	j	ffffffffc0201234 <pmm_init+0xda>
        panic("pa2page called with invalid pa");
ffffffffc02012c0:	00001617          	auipc	a2,0x1
ffffffffc02012c4:	60860613          	addi	a2,a2,1544 # ffffffffc02028c8 <etext+0x9fc>
ffffffffc02012c8:	06b00593          	li	a1,107
ffffffffc02012cc:	00001517          	auipc	a0,0x1
ffffffffc02012d0:	61c50513          	addi	a0,a0,1564 # ffffffffc02028e8 <etext+0xa1c>
ffffffffc02012d4:	8d2ff0ef          	jal	ffffffffc02003a6 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02012d8:	00001617          	auipc	a2,0x1
ffffffffc02012dc:	5b860613          	addi	a2,a2,1464 # ffffffffc0202890 <etext+0x9c4>
ffffffffc02012e0:	06f00593          	li	a1,111
ffffffffc02012e4:	00001517          	auipc	a0,0x1
ffffffffc02012e8:	5d450513          	addi	a0,a0,1492 # ffffffffc02028b8 <etext+0x9ec>
ffffffffc02012ec:	8baff0ef          	jal	ffffffffc02003a6 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012f0:	86ae                	mv	a3,a1
ffffffffc02012f2:	00001617          	auipc	a2,0x1
ffffffffc02012f6:	59e60613          	addi	a2,a2,1438 # ffffffffc0202890 <etext+0x9c4>
ffffffffc02012fa:	09100593          	li	a1,145
ffffffffc02012fe:	00001517          	auipc	a0,0x1
ffffffffc0201302:	5ba50513          	addi	a0,a0,1466 # ffffffffc02028b8 <etext+0x9ec>
ffffffffc0201306:	8a0ff0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc020130a <init_cache>:
    return size;
}



void init_cache(){
ffffffffc020130a:	7135                	addi	sp,sp,-160
    int size = 8;
    int order = 1;
    slab_cache_t  * ptr2cache = NULL;
    //用于存储slab
    struct Page *page = (struct Page *)KADDR(page2pa(alloc_pages(1)));
ffffffffc020130c:	4505                	li	a0,1
void init_cache(){
ffffffffc020130e:	e14a                	sd	s2,128(sp)
ffffffffc0201310:	f8d2                	sd	s4,112(sp)
ffffffffc0201312:	f4d6                	sd	s5,104(sp)
ffffffffc0201314:	ed06                	sd	ra,152(sp)
ffffffffc0201316:	e922                	sd	s0,144(sp)
ffffffffc0201318:	e526                	sd	s1,136(sp)
ffffffffc020131a:	fcce                	sd	s3,120(sp)
ffffffffc020131c:	f0da                	sd	s6,96(sp)
ffffffffc020131e:	ecde                	sd	s7,88(sp)
ffffffffc0201320:	e8e2                	sd	s8,80(sp)
ffffffffc0201322:	e4e6                	sd	s9,72(sp)
ffffffffc0201324:	e0ea                	sd	s10,64(sp)
ffffffffc0201326:	fc6e                	sd	s11,56(sp)
    struct Page *page = (struct Page *)KADDR(page2pa(alloc_pages(1)));
ffffffffc0201328:	d7bff0ef          	jal	ffffffffc02010a2 <alloc_pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020132c:	06db7f37          	lui	t5,0x6db7
ffffffffc0201330:	db7f0f13          	addi	t5,t5,-585 # 6db6db7 <kern_entry-0xffffffffb9449249>
ffffffffc0201334:	00005a17          	auipc	s4,0x5
ffffffffc0201338:	22ca0a13          	addi	s4,s4,556 # ffffffffc0206560 <pages>
ffffffffc020133c:	0f32                	slli	t5,t5,0xc
ffffffffc020133e:	000a3783          	ld	a5,0(s4)
ffffffffc0201342:	db7f0f13          	addi	t5,t5,-585
ffffffffc0201346:	0f32                	slli	t5,t5,0xc
ffffffffc0201348:	db7f0f13          	addi	t5,t5,-585
ffffffffc020134c:	40f506b3          	sub	a3,a0,a5
ffffffffc0201350:	0f32                	slli	t5,t5,0xc
ffffffffc0201352:	868d                	srai	a3,a3,0x3
ffffffffc0201354:	db7f0f13          	addi	t5,t5,-585
ffffffffc0201358:	03e686b3          	mul	a3,a3,t5
ffffffffc020135c:	00005a97          	auipc	s5,0x5
ffffffffc0201360:	1fca8a93          	addi	s5,s5,508 # ffffffffc0206558 <npage>
ffffffffc0201364:	00002f97          	auipc	t6,0x2
ffffffffc0201368:	b64fbf83          	ld	t6,-1180(t6) # ffffffffc0202ec8 <nbase>
ffffffffc020136c:	597d                	li	s2,-1
ffffffffc020136e:	000ab703          	ld	a4,0(s5)
ffffffffc0201372:	00c95913          	srli	s2,s2,0xc
ffffffffc0201376:	96fe                	add	a3,a3,t6
ffffffffc0201378:	0126f7b3          	and	a5,a3,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc020137c:	06b2                	slli	a3,a3,0xc
ffffffffc020137e:	22e7f163          	bgeu	a5,a4,ffffffffc02015a0 <init_cache+0x296>
ffffffffc0201382:	00005997          	auipc	s3,0x5
ffffffffc0201386:	1ce98993          	addi	s3,s3,462 # ffffffffc0206550 <va_pa_offset>
ffffffffc020138a:	0009b783          	ld	a5,0(s3)
ffffffffc020138e:	00f68b33          	add	s6,a3,a5
    assert(8*sizeof(struct Page) < 4096);
    assert(page !=NULL);
ffffffffc0201392:	280b0863          	beqz	s6,ffffffffc0201622 <init_cache+0x318>
ffffffffc0201396:	1c0b0793          	addi	a5,s6,448
    int size = 8;
ffffffffc020139a:	4421                	li	s0,8
    page = page+1;
    ptr2cache -> order = order;
    struct Page *objspace = alloc_pages(order);
    assert(objspace !=NULL);
    char * color = (char *)KADDR(page2pa(objspace));
    int perpagespace = (4096 - 0x10)/size;
ffffffffc020139c:	6e05                	lui	t3,0x1
ffffffffc020139e:	f03e                	sd	a5,32(sp)
    slab_cache_t  * ptr2cache = NULL;
ffffffffc02013a0:	4b81                	li	s7,0





    ptr2cache ->page->freelist =(struct obj_list_entry *)KADDR(page2pa(\
ffffffffc02013a2:	87a2                	mv	a5,s0
    int order = 1;
ffffffffc02013a4:	4d85                	li	s11,1
    int perpagespace = (4096 - 0x10)/size;
ffffffffc02013a6:	3e41                	addiw	t3,t3,-16 # ff0 <kern_entry-0xffffffffc01ff010>
    ptr2cache ->page->freelist =(struct obj_list_entry *)KADDR(page2pa(\
ffffffffc02013a8:	845a                	mv	s0,s6
    for(int i = 0; i < 4096*order; i+=4096){
ffffffffc02013aa:	6c85                	lui	s9,0x1
    ptr2cache ->page->freelist =(struct obj_list_entry *)KADDR(page2pa(\
ffffffffc02013ac:	8d5e                	mv	s10,s7
ffffffffc02013ae:	84ee                	mv	s1,s11
ffffffffc02013b0:	e47e                	sd	t6,8(sp)
ffffffffc02013b2:	8c7a                	mv	s8,t5
ffffffffc02013b4:	d672                	sw	t3,44(sp)
ffffffffc02013b6:	8b3e                	mv	s6,a5
            switch (size) {
ffffffffc02013b8:	08000793          	li	a5,128
ffffffffc02013bc:	1cfb0363          	beq	s6,a5,ffffffffc0201582 <init_cache+0x278>
ffffffffc02013c0:	1767cd63          	blt	a5,s6,ffffffffc020153a <init_cache+0x230>
ffffffffc02013c4:	02000793          	li	a5,32
ffffffffc02013c8:	1afb0363          	beq	s6,a5,ffffffffc020156e <init_cache+0x264>
ffffffffc02013cc:	1967c863          	blt	a5,s6,ffffffffc020155c <init_cache+0x252>
ffffffffc02013d0:	47a1                	li	a5,8
ffffffffc02013d2:	1afb0363          	beq	s6,a5,ffffffffc0201578 <init_cache+0x26e>
ffffffffc02013d6:	47c1                	li	a5,16
ffffffffc02013d8:	00fb1663          	bne	s6,a5,ffffffffc02013e4 <init_cache+0xda>
        ptr2cache = &kmallo_cache_16;
ffffffffc02013dc:	00005d17          	auipc	s10,0x5
ffffffffc02013e0:	d1cd0d13          	addi	s10,s10,-740 # ffffffffc02060f8 <kmallo_cache_16>
    ptr2cache -> page = page;
ffffffffc02013e4:	008d3023          	sd	s0,0(s10)
    ptr2cache -> order = order;
ffffffffc02013e8:	009d2423          	sw	s1,8(s10)
    struct Page *objspace = alloc_pages(order);
ffffffffc02013ec:	8526                	mv	a0,s1
ffffffffc02013ee:	cb5ff0ef          	jal	ffffffffc02010a2 <alloc_pages>
    page = page+1;
ffffffffc02013f2:	03840413          	addi	s0,s0,56
    struct Page *objspace = alloc_pages(order);
ffffffffc02013f6:	832a                	mv	t1,a0
    assert(objspace !=NULL);
ffffffffc02013f8:	20050563          	beqz	a0,ffffffffc0201602 <init_cache+0x2f8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02013fc:	000a3783          	ld	a5,0(s4)
ffffffffc0201400:	6722                	ld	a4,8(sp)
    char * color = (char *)KADDR(page2pa(objspace));
ffffffffc0201402:	000ab503          	ld	a0,0(s5)
ffffffffc0201406:	40f307b3          	sub	a5,t1,a5
ffffffffc020140a:	878d                	srai	a5,a5,0x3
ffffffffc020140c:	038787b3          	mul	a5,a5,s8
ffffffffc0201410:	97ba                	add	a5,a5,a4
ffffffffc0201412:	0127f733          	and	a4,a5,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201416:	00c79693          	slli	a3,a5,0xc
ffffffffc020141a:	1ca77863          	bgeu	a4,a0,ffffffffc02015ea <init_cache+0x2e0>
    int perpagespace = (4096 - 0x10)/size;
ffffffffc020141e:	57b2                	lw	a5,44(sp)
    for(int i = 0; i < 4096*order; i+=4096){
ffffffffc0201420:	00c49d9b          	slliw	s11,s1,0xc
    int perpagespace = (4096 - 0x10)/size;
ffffffffc0201424:	0367cbbb          	divw	s7,a5,s6
    char * color = (char *)KADDR(page2pa(objspace));
ffffffffc0201428:	0009b783          	ld	a5,0(s3)
ffffffffc020142c:	00f68533          	add	a0,a3,a5
        *((unsigned long *)(color + i)) = size;
ffffffffc0201430:	4781                	li	a5,0
    int perpagespace = (4096 - 0x10)/size;
ffffffffc0201432:	875e                	mv	a4,s7
    for(int i = 0; i < 4096*order; i+=4096){
ffffffffc0201434:	01b05d63          	blez	s11,ffffffffc020144e <init_cache+0x144>
        *((unsigned long *)(color + i)) = size;
ffffffffc0201438:	00f506b3          	add	a3,a0,a5
    for(int i = 0; i < 4096*order; i+=4096){
ffffffffc020143c:	97e6                	add	a5,a5,s9
        *((unsigned long *)(color + i)) = size;
ffffffffc020143e:	0166b023          	sd	s6,0(a3)
        *((unsigned long *)(color + i+8)) = 0;//保留可以留在以后
ffffffffc0201442:	0006b423          	sd	zero,8(a3)
    for(int i = 0; i < 4096*order; i+=4096){
ffffffffc0201446:	0007869b          	sext.w	a3,a5
ffffffffc020144a:	ffb6c7e3          	blt	a3,s11,ffffffffc0201438 <init_cache+0x12e>
    ptr2cache ->page->freelist =(struct obj_list_entry *)KADDR(page2pa(\
ffffffffc020144e:	029708bb          	mulw	a7,a4,s1
ffffffffc0201452:	6785                	lui	a5,0x1
ffffffffc0201454:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0201456:	ec1a                	sd	t1,24(sp)
ffffffffc0201458:	00189513          	slli	a0,a7,0x1
ffffffffc020145c:	9546                	add	a0,a0,a7
ffffffffc020145e:	050e                	slli	a0,a0,0x3
ffffffffc0201460:	953e                	add	a0,a0,a5
ffffffffc0201462:	8131                	srli	a0,a0,0xc
ffffffffc0201464:	d446                	sw	a7,40(sp)
ffffffffc0201466:	e846                	sd	a7,16(sp)
ffffffffc0201468:	c3bff0ef          	jal	ffffffffc02010a2 <alloc_pages>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020146c:	000a3683          	ld	a3,0(s4)
ffffffffc0201470:	6722                	ld	a4,8(sp)
ffffffffc0201472:	000abe03          	ld	t3,0(s5)
ffffffffc0201476:	40d507b3          	sub	a5,a0,a3
ffffffffc020147a:	878d                	srai	a5,a5,0x3
ffffffffc020147c:	038787b3          	mul	a5,a5,s8
ffffffffc0201480:	68c2                	ld	a7,16(sp)
ffffffffc0201482:	6362                	ld	t1,24(sp)
ffffffffc0201484:	97ba                	add	a5,a5,a4
ffffffffc0201486:	0127f533          	and	a0,a5,s2
ffffffffc020148a:	5722                	lw	a4,40(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020148c:	07b2                	slli	a5,a5,0xc
ffffffffc020148e:	15c57163          	bgeu	a0,t3,ffffffffc02015d0 <init_cache+0x2c6>
ffffffffc0201492:	0009b283          	ld	t0,0(s3)
ffffffffc0201496:	000d3f03          	ld	t5,0(s10)
ffffffffc020149a:	9796                	add	a5,a5,t0
ffffffffc020149c:	02ff3823          	sd	a5,48(t5)
    cprintf("freelist count = %d,",perpagespace*order);
    cprintf("freelist page order = %d\n",((perpagespace*order*sizeof(struct obj_list_entry)+4095)&(~4095))/4096);
    #endif
    
    //obj数量
    ptr2cache->objnum = perpagespace*order;
ffffffffc02014a0:	00ed2623          	sw	a4,12(s10)
    //obj大小
    ptr2cache->sizeofobj = size;
ffffffffc02014a4:	016d2823          	sw	s6,16(s10)
    //初始化freelist
    struct obj_list_entry * setup =  ptr2cache ->page->freelist;
    for(int i = 0; i!= perpagespace*order;i++){
ffffffffc02014a8:	02088063          	beqz	a7,ffffffffc02014c8 <init_cache+0x1be>
        
        #ifdef DEBUG
        cprintf("%p,%p,%p\n",setup,setup->next,setup->next->prev);
        #endif
        setup = setup + 1;
        if(i == perpagespace*order -1){
ffffffffc02014ac:	377d                	addiw	a4,a4,-1 # ffffffffffffefff <end+0x3fdf8a8f>
    struct obj_list_entry * setup =  ptr2cache ->page->freelist;
ffffffffc02014ae:	853e                	mv	a0,a5
    for(int i = 0; i!= perpagespace*order;i++){
ffffffffc02014b0:	4e81                	li	t4,0
        setup->next->prev = setup;
ffffffffc02014b2:	ed08                	sd	a0,24(a0)
ffffffffc02014b4:	862a                	mv	a2,a0
            setup->prev->next = NULL;
ffffffffc02014b6:	4581                	li	a1,0
        setup->next = (struct obj_list_entry *)setup + 1;
ffffffffc02014b8:	0561                	addi	a0,a0,24
        if(i == perpagespace*order -1){
ffffffffc02014ba:	00ee8363          	beq	t4,a4,ffffffffc02014c0 <init_cache+0x1b6>
            setup->prev->next = NULL;
ffffffffc02014be:	85aa                	mv	a1,a0
ffffffffc02014c0:	e60c                	sd	a1,8(a2)
    for(int i = 0; i!= perpagespace*order;i++){
ffffffffc02014c2:	2e85                	addiw	t4,t4,1
ffffffffc02014c4:	ffd897e3          	bne	a7,t4,ffffffffc02014b2 <init_cache+0x1a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02014c8:	40d30733          	sub	a4,t1,a3
ffffffffc02014cc:	870d                	srai	a4,a4,0x3
ffffffffc02014ce:	03870733          	mul	a4,a4,s8
ffffffffc02014d2:	66a2                	ld	a3,8(sp)
ffffffffc02014d4:	9736                	add	a4,a4,a3
    #endif


    //给freelist赋值
    struct obj_list_entry * temp = (struct obj_list_entry*)ptr2cache ->page->freelist;
    char * position = (char *)KADDR(page2pa(objspace));
ffffffffc02014d6:	01277533          	and	a0,a4,s2
    return page2ppn(page) << PGSHIFT;
ffffffffc02014da:	00c71693          	slli	a3,a4,0xc
ffffffffc02014de:	0dc57d63          	bgeu	a0,t3,ffffffffc02015b8 <init_cache+0x2ae>
ffffffffc02014e2:	92b6                	add	t0,t0,a3
    for(int i = 0; i < 4096*order; i+=4096){
ffffffffc02014e4:	03b05363          	blez	s11,ffffffffc020150a <init_cache+0x200>
        for(int j = 0;j<perpagespace;j++){
ffffffffc02014e8:	4541                	li	a0,16
ffffffffc02014ea:	03705063          	blez	s7,ffffffffc020150a <init_cache+0x200>
ffffffffc02014ee:	00a286b3          	add	a3,t0,a0
ffffffffc02014f2:	4701                	li	a4,0
                temp->obj = (char*)(position+i+0x10)+j*size;
ffffffffc02014f4:	eb94                	sd	a3,16(a5)
        for(int j = 0;j<perpagespace;j++){
ffffffffc02014f6:	2705                	addiw	a4,a4,1
                temp = temp->next;
ffffffffc02014f8:	679c                	ld	a5,8(a5)
        for(int j = 0;j<perpagespace;j++){
ffffffffc02014fa:	96da                	add	a3,a3,s6
ffffffffc02014fc:	feeb9ce3          	bne	s7,a4,ffffffffc02014f4 <init_cache+0x1ea>
    for(int i = 0; i < 4096*order; i+=4096){
ffffffffc0201500:	9566                	add	a0,a0,s9
ffffffffc0201502:	ff05071b          	addiw	a4,a0,-16
ffffffffc0201506:	ffb744e3          	blt	a4,s11,ffffffffc02014ee <init_cache+0x1e4>
    while(size <= 1024){
ffffffffc020150a:	7782                	ld	a5,32(sp)
            }
    }
    ptr2cache->page->active = 0;
ffffffffc020150c:	020f2423          	sw	zero,40(t5)
    order *= 2;
ffffffffc0201510:	0014949b          	slliw	s1,s1,0x1
    size *= 2;
ffffffffc0201514:	001b1b1b          	slliw	s6,s6,0x1
    while(size <= 1024){
ffffffffc0201518:	eaf410e3          	bne	s0,a5,ffffffffc02013b8 <init_cache+0xae>
    }
}
ffffffffc020151c:	60ea                	ld	ra,152(sp)
ffffffffc020151e:	644a                	ld	s0,144(sp)
ffffffffc0201520:	64aa                	ld	s1,136(sp)
ffffffffc0201522:	690a                	ld	s2,128(sp)
ffffffffc0201524:	79e6                	ld	s3,120(sp)
ffffffffc0201526:	7a46                	ld	s4,112(sp)
ffffffffc0201528:	7aa6                	ld	s5,104(sp)
ffffffffc020152a:	7b06                	ld	s6,96(sp)
ffffffffc020152c:	6be6                	ld	s7,88(sp)
ffffffffc020152e:	6c46                	ld	s8,80(sp)
ffffffffc0201530:	6ca6                	ld	s9,72(sp)
ffffffffc0201532:	6d06                	ld	s10,64(sp)
ffffffffc0201534:	7de2                	ld	s11,56(sp)
ffffffffc0201536:	610d                	addi	sp,sp,160
ffffffffc0201538:	8082                	ret
            switch (size) {
ffffffffc020153a:	20000793          	li	a5,512
ffffffffc020153e:	04fb0c63          	beq	s6,a5,ffffffffc0201596 <init_cache+0x28c>
ffffffffc0201542:	40000793          	li	a5,1024
ffffffffc0201546:	04fb0363          	beq	s6,a5,ffffffffc020158c <init_cache+0x282>
ffffffffc020154a:	10000793          	li	a5,256
ffffffffc020154e:	e8fb1be3          	bne	s6,a5,ffffffffc02013e4 <init_cache+0xda>
        ptr2cache = &kmallo_cache_256;
ffffffffc0201552:	00005d17          	auipc	s10,0x5
ffffffffc0201556:	b46d0d13          	addi	s10,s10,-1210 # ffffffffc0206098 <kmallo_cache_256>
ffffffffc020155a:	b569                	j	ffffffffc02013e4 <init_cache+0xda>
            switch (size) {
ffffffffc020155c:	04000793          	li	a5,64
ffffffffc0201560:	e8fb12e3          	bne	s6,a5,ffffffffc02013e4 <init_cache+0xda>
        ptr2cache = &kmallo_cache_64;
ffffffffc0201564:	00005d17          	auipc	s10,0x5
ffffffffc0201568:	b64d0d13          	addi	s10,s10,-1180 # ffffffffc02060c8 <kmallo_cache_64>
ffffffffc020156c:	bda5                	j	ffffffffc02013e4 <init_cache+0xda>
        ptr2cache = &kmallo_cache_32;
ffffffffc020156e:	00005d17          	auipc	s10,0x5
ffffffffc0201572:	b72d0d13          	addi	s10,s10,-1166 # ffffffffc02060e0 <kmallo_cache_32>
ffffffffc0201576:	b5bd                	j	ffffffffc02013e4 <init_cache+0xda>
            switch (size) {
ffffffffc0201578:	00005d17          	auipc	s10,0x5
ffffffffc020157c:	b98d0d13          	addi	s10,s10,-1128 # ffffffffc0206110 <kmallo_cache_8>
ffffffffc0201580:	b595                	j	ffffffffc02013e4 <init_cache+0xda>
        ptr2cache = &kmallo_cache_128;
ffffffffc0201582:	00005d17          	auipc	s10,0x5
ffffffffc0201586:	b2ed0d13          	addi	s10,s10,-1234 # ffffffffc02060b0 <kmallo_cache_128>
ffffffffc020158a:	bda9                	j	ffffffffc02013e4 <init_cache+0xda>
        ptr2cache = &kmallo_cache_1024;
ffffffffc020158c:	00005d17          	auipc	s10,0x5
ffffffffc0201590:	adcd0d13          	addi	s10,s10,-1316 # ffffffffc0206068 <kmallo_cache_1024>
ffffffffc0201594:	bd81                	j	ffffffffc02013e4 <init_cache+0xda>
        ptr2cache = &kmallo_cache_512;
ffffffffc0201596:	00005d17          	auipc	s10,0x5
ffffffffc020159a:	aead0d13          	addi	s10,s10,-1302 # ffffffffc0206080 <kmallo_cache_512>
ffffffffc020159e:	b599                	j	ffffffffc02013e4 <init_cache+0xda>
    struct Page *page = (struct Page *)KADDR(page2pa(alloc_pages(1)));
ffffffffc02015a0:	00001617          	auipc	a2,0x1
ffffffffc02015a4:	3b860613          	addi	a2,a2,952 # ffffffffc0202958 <etext+0xa8c>
ffffffffc02015a8:	02e00593          	li	a1,46
ffffffffc02015ac:	00001517          	auipc	a0,0x1
ffffffffc02015b0:	3d450513          	addi	a0,a0,980 # ffffffffc0202980 <etext+0xab4>
ffffffffc02015b4:	df3fe0ef          	jal	ffffffffc02003a6 <__panic>
    char * position = (char *)KADDR(page2pa(objspace));
ffffffffc02015b8:	00001617          	auipc	a2,0x1
ffffffffc02015bc:	3a060613          	addi	a2,a2,928 # ffffffffc0202958 <etext+0xa8c>
ffffffffc02015c0:	08f00593          	li	a1,143
ffffffffc02015c4:	00001517          	auipc	a0,0x1
ffffffffc02015c8:	3bc50513          	addi	a0,a0,956 # ffffffffc0202980 <etext+0xab4>
ffffffffc02015cc:	ddbfe0ef          	jal	ffffffffc02003a6 <__panic>
    ptr2cache ->page->freelist =(struct obj_list_entry *)KADDR(page2pa(\
ffffffffc02015d0:	86be                	mv	a3,a5
ffffffffc02015d2:	00001617          	auipc	a2,0x1
ffffffffc02015d6:	38660613          	addi	a2,a2,902 # ffffffffc0202958 <etext+0xa8c>
ffffffffc02015da:	06500593          	li	a1,101
ffffffffc02015de:	00001517          	auipc	a0,0x1
ffffffffc02015e2:	3a250513          	addi	a0,a0,930 # ffffffffc0202980 <etext+0xab4>
ffffffffc02015e6:	dc1fe0ef          	jal	ffffffffc02003a6 <__panic>
    char * color = (char *)KADDR(page2pa(objspace));
ffffffffc02015ea:	00001617          	auipc	a2,0x1
ffffffffc02015ee:	36e60613          	addi	a2,a2,878 # ffffffffc0202958 <etext+0xa8c>
ffffffffc02015f2:	05200593          	li	a1,82
ffffffffc02015f6:	00001517          	auipc	a0,0x1
ffffffffc02015fa:	38a50513          	addi	a0,a0,906 # ffffffffc0202980 <etext+0xab4>
ffffffffc02015fe:	da9fe0ef          	jal	ffffffffc02003a6 <__panic>
    assert(objspace !=NULL);
ffffffffc0201602:	00001697          	auipc	a3,0x1
ffffffffc0201606:	39e68693          	addi	a3,a3,926 # ffffffffc02029a0 <etext+0xad4>
ffffffffc020160a:	00001617          	auipc	a2,0x1
ffffffffc020160e:	ee660613          	addi	a2,a2,-282 # ffffffffc02024f0 <etext+0x624>
ffffffffc0201612:	05100593          	li	a1,81
ffffffffc0201616:	00001517          	auipc	a0,0x1
ffffffffc020161a:	36a50513          	addi	a0,a0,874 # ffffffffc0202980 <etext+0xab4>
ffffffffc020161e:	d89fe0ef          	jal	ffffffffc02003a6 <__panic>
    assert(page !=NULL);
ffffffffc0201622:	00001697          	auipc	a3,0x1
ffffffffc0201626:	36e68693          	addi	a3,a3,878 # ffffffffc0202990 <etext+0xac4>
ffffffffc020162a:	00001617          	auipc	a2,0x1
ffffffffc020162e:	ec660613          	addi	a2,a2,-314 # ffffffffc02024f0 <etext+0x624>
ffffffffc0201632:	03000593          	li	a1,48
ffffffffc0201636:	00001517          	auipc	a0,0x1
ffffffffc020163a:	34a50513          	addi	a0,a0,842 # ffffffffc0202980 <etext+0xab4>
ffffffffc020163e:	d69fe0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc0201642 <kmalloc>:
void *kmalloc(int size){
    slab_cache_t* malloc_cache = NULL;
    if(size == 0){
ffffffffc0201642:	c52d                	beqz	a0,ffffffffc02016ac <kmalloc+0x6a>
    size = size>>1 | size;
ffffffffc0201644:	40155793          	srai	a5,a0,0x1
ffffffffc0201648:	8fc9                	or	a5,a5,a0
    size = size >> 2 | size;
ffffffffc020164a:	4027d713          	srai	a4,a5,0x2
ffffffffc020164e:	8fd9                	or	a5,a5,a4
    size = size >> 4 | size;
ffffffffc0201650:	4047d713          	srai	a4,a5,0x4
ffffffffc0201654:	8fd9                	or	a5,a5,a4
    size = size >> 8 | size;
ffffffffc0201656:	4087d713          	srai	a4,a5,0x8
ffffffffc020165a:	8fd9                	or	a5,a5,a4
    size = size >> 16 | size;
ffffffffc020165c:	4107d713          	srai	a4,a5,0x10
ffffffffc0201660:	8fd9                	or	a5,a5,a4
    size = (size + 1)>>1;
ffffffffc0201662:	2785                	addiw	a5,a5,1
    if(size <= 8){
ffffffffc0201664:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc0201668:	4721                	li	a4,8
ffffffffc020166a:	02e7cf63          	blt	a5,a4,ffffffffc02016a8 <kmalloc+0x66>
        return NULL;
    }
    size = standardsize(size);
    int index = 0;
ffffffffc020166e:	4701                	li	a4,0
    while(size){
        size = size >> 1;
ffffffffc0201670:	4017d79b          	sraiw	a5,a5,0x1
        index++;
ffffffffc0201674:	86ba                	mv	a3,a4
ffffffffc0201676:	2705                	addiw	a4,a4,1
    while(size){
ffffffffc0201678:	ffe5                	bnez	a5,ffffffffc0201670 <kmalloc+0x2e>
    }
    malloc_cache = slab_caches[index-4];
ffffffffc020167a:	36f5                	addiw	a3,a3,-3
ffffffffc020167c:	068e                	slli	a3,a3,0x3
ffffffffc020167e:	00005797          	auipc	a5,0x5
ffffffffc0201682:	98278793          	addi	a5,a5,-1662 # ffffffffc0206000 <slab_caches>
ffffffffc0201686:	97b6                	add	a5,a5,a3
ffffffffc0201688:	6398                	ld	a4,0(a5)
    assert(malloc_cache != NULL);
ffffffffc020168a:	c31d                	beqz	a4,ffffffffc02016b0 <kmalloc+0x6e>
    if(malloc_cache->objnum == malloc_cache->page->active){
ffffffffc020168c:	631c                	ld	a5,0(a4)
ffffffffc020168e:	4754                	lw	a3,12(a4)
ffffffffc0201690:	5798                	lw	a4,40(a5)
ffffffffc0201692:	00e68d63          	beq	a3,a4,ffffffffc02016ac <kmalloc+0x6a>
        return NULL;
    }
    struct obj_list_entry * temp = malloc_cache->page->freelist;
ffffffffc0201696:	7b94                	ld	a3,48(a5)
    void * victim = temp->obj;
    temp -> obj =NULL;
    malloc_cache->page->freelist = temp->next;
    malloc_cache->page->active++;
ffffffffc0201698:	2705                	addiw	a4,a4,1
    malloc_cache->page->freelist = temp->next;
ffffffffc020169a:	6690                	ld	a2,8(a3)
    void * victim = temp->obj;
ffffffffc020169c:	6a88                	ld	a0,16(a3)
    temp -> obj =NULL;
ffffffffc020169e:	0006b823          	sd	zero,16(a3)
    malloc_cache->page->freelist = temp->next;
ffffffffc02016a2:	fb90                	sd	a2,48(a5)
    malloc_cache->page->active++;
ffffffffc02016a4:	d798                	sw	a4,40(a5)
    return victim;
ffffffffc02016a6:	8082                	ret
ffffffffc02016a8:	47a1                	li	a5,8
ffffffffc02016aa:	b7d1                	j	ffffffffc020166e <kmalloc+0x2c>
        return NULL;
ffffffffc02016ac:	4501                	li	a0,0
}
ffffffffc02016ae:	8082                	ret
void *kmalloc(int size){
ffffffffc02016b0:	1141                	addi	sp,sp,-16
    assert(malloc_cache != NULL);
ffffffffc02016b2:	00001697          	auipc	a3,0x1
ffffffffc02016b6:	2fe68693          	addi	a3,a3,766 # ffffffffc02029b0 <etext+0xae4>
ffffffffc02016ba:	00001617          	auipc	a2,0x1
ffffffffc02016be:	e3660613          	addi	a2,a2,-458 # ffffffffc02024f0 <etext+0x624>
ffffffffc02016c2:	0a700593          	li	a1,167
ffffffffc02016c6:	00001517          	auipc	a0,0x1
ffffffffc02016ca:	2ba50513          	addi	a0,a0,698 # ffffffffc0202980 <etext+0xab4>
void *kmalloc(int size){
ffffffffc02016ce:	e406                	sd	ra,8(sp)
    assert(malloc_cache != NULL);
ffffffffc02016d0:	cd7fe0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc02016d4 <kfree>:
void kfree(void *obj){
    unsigned long head = (unsigned long)obj & 0xFFFFFFFFFFFFF000;
ffffffffc02016d4:	77fd                	lui	a5,0xfffff
ffffffffc02016d6:	8d7d                	and	a0,a0,a5
    int size =*(unsigned long*)head;
ffffffffc02016d8:	411c                	lw	a5,0(a0)
    int index = 0;
    while(size){
ffffffffc02016da:	c79d                	beqz	a5,ffffffffc0201708 <kfree+0x34>
    int index = 0;
ffffffffc02016dc:	4701                	li	a4,0
        size = size >> 1;
ffffffffc02016de:	8785                	srai	a5,a5,0x1
        index++;
ffffffffc02016e0:	86ba                	mv	a3,a4
ffffffffc02016e2:	2705                	addiw	a4,a4,1
    while(size){
ffffffffc02016e4:	ffed                	bnez	a5,ffffffffc02016de <kfree+0xa>
    }
    slab_cache_t* free_cache = slab_caches[index-4];
ffffffffc02016e6:	36f5                	addiw	a3,a3,-3
ffffffffc02016e8:	068e                	slli	a3,a3,0x3
ffffffffc02016ea:	00005797          	auipc	a5,0x5
ffffffffc02016ee:	91678793          	addi	a5,a5,-1770 # ffffffffc0206000 <slab_caches>
ffffffffc02016f2:	97b6                	add	a5,a5,a3
ffffffffc02016f4:	639c                	ld	a5,0(a5)
    assert(free_cache != NULL);
ffffffffc02016f6:	cb99                	beqz	a5,ffffffffc020170c <kfree+0x38>
    free_cache->page->freelist->prev->obj == obj ;
ffffffffc02016f8:	639c                	ld	a5,0(a5)
ffffffffc02016fa:	7b94                	ld	a3,48(a5)
    free_cache->page->freelist = free_cache->page->freelist->prev;
    free_cache->page ->active--;
ffffffffc02016fc:	5798                	lw	a4,40(a5)
    free_cache->page->freelist = free_cache->page->freelist->prev;
ffffffffc02016fe:	6294                	ld	a3,0(a3)
    free_cache->page ->active--;
ffffffffc0201700:	377d                	addiw	a4,a4,-1
ffffffffc0201702:	d798                	sw	a4,40(a5)
    free_cache->page->freelist = free_cache->page->freelist->prev;
ffffffffc0201704:	fb94                	sd	a3,48(a5)
ffffffffc0201706:	8082                	ret
    while(size){
ffffffffc0201708:	56f1                	li	a3,-4
ffffffffc020170a:	bff9                	j	ffffffffc02016e8 <kfree+0x14>
void kfree(void *obj){
ffffffffc020170c:	1141                	addi	sp,sp,-16
    assert(free_cache != NULL);
ffffffffc020170e:	00001697          	auipc	a3,0x1
ffffffffc0201712:	2ba68693          	addi	a3,a3,698 # ffffffffc02029c8 <etext+0xafc>
ffffffffc0201716:	00001617          	auipc	a2,0x1
ffffffffc020171a:	dda60613          	addi	a2,a2,-550 # ffffffffc02024f0 <etext+0x624>
ffffffffc020171e:	0bb00593          	li	a1,187
ffffffffc0201722:	00001517          	auipc	a0,0x1
ffffffffc0201726:	25e50513          	addi	a0,a0,606 # ffffffffc0202980 <etext+0xab4>
void kfree(void *obj){
ffffffffc020172a:	e406                	sd	ra,8(sp)
    assert(free_cache != NULL);
ffffffffc020172c:	c7bfe0ef          	jal	ffffffffc02003a6 <__panic>

ffffffffc0201730 <check>:
}



void print_slab_cache_status(int size);
void check(){
ffffffffc0201730:	1101                	addi	sp,sp,-32
ffffffffc0201732:	e04a                	sd	s2,0(sp)
    // 测试 size = 8
    void *obj = kmalloc(8);
ffffffffc0201734:	4521                	li	a0,8
    int index = 0;
    while(size){
        size = size >> 1;
        index++;
    }
    slab_cache_t* cache = slab_caches[index-4];
ffffffffc0201736:	00005917          	auipc	s2,0x5
ffffffffc020173a:	8ca90913          	addi	s2,s2,-1846 # ffffffffc0206000 <slab_caches>
void check(){
ffffffffc020173e:	e822                	sd	s0,16(sp)
ffffffffc0201740:	e426                	sd	s1,8(sp)
ffffffffc0201742:	ec06                	sd	ra,24(sp)
    void *obj = kmalloc(8);
ffffffffc0201744:	effff0ef          	jal	ffffffffc0201642 <kmalloc>
    slab_cache_t* cache = slab_caches[index-4];
ffffffffc0201748:	00093403          	ld	s0,0(s2)
    void *obj = kmalloc(8);
ffffffffc020174c:	84aa                	mv	s1,a0
    if (cache == NULL) {
        cprintf("Slab cache %d is NULL.\n", index-4);
ffffffffc020174e:	4581                	li	a1,0
    if (cache == NULL) {
ffffffffc0201750:	c44d                	beqz	s0,ffffffffc02017fa <check+0xca>
        return;
    }

    cprintf("Slab cache %d status:\n", index-4);
ffffffffc0201752:	00001517          	auipc	a0,0x1
ffffffffc0201756:	2a650513          	addi	a0,a0,678 # ffffffffc02029f8 <etext+0xb2c>
ffffffffc020175a:	959fe0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  Total objects: %d\n", cache->objnum);
ffffffffc020175e:	444c                	lw	a1,12(s0)
ffffffffc0201760:	00001517          	auipc	a0,0x1
ffffffffc0201764:	2b050513          	addi	a0,a0,688 # ffffffffc0202a10 <etext+0xb44>
ffffffffc0201768:	94bfe0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  Active objects: %d\n", cache->page->active);
ffffffffc020176c:	601c                	ld	a5,0(s0)
ffffffffc020176e:	00001517          	auipc	a0,0x1
ffffffffc0201772:	2ba50513          	addi	a0,a0,698 # ffffffffc0202a28 <etext+0xb5c>
ffffffffc0201776:	578c                	lw	a1,40(a5)
ffffffffc0201778:	93bfe0ef          	jal	ffffffffc02000b2 <cprintf>

    struct obj_list_entry* temp = cache->page->freelist;
ffffffffc020177c:	601c                	ld	a5,0(s0)
    int free_count = 0;
ffffffffc020177e:	4581                	li	a1,0
    struct obj_list_entry* temp = cache->page->freelist;
ffffffffc0201780:	7b9c                	ld	a5,48(a5)
    while (temp != NULL) {
ffffffffc0201782:	c781                	beqz	a5,ffffffffc020178a <check+0x5a>
        free_count++;
        temp = temp->next;
ffffffffc0201784:	679c                	ld	a5,8(a5)
        free_count++;
ffffffffc0201786:	2585                	addiw	a1,a1,1
    while (temp != NULL) {
ffffffffc0201788:	fff5                	bnez	a5,ffffffffc0201784 <check+0x54>
    }
    cprintf("  Free objects in freelist: %d\n", free_count);
ffffffffc020178a:	00001517          	auipc	a0,0x1
ffffffffc020178e:	2b650513          	addi	a0,a0,694 # ffffffffc0202a40 <etext+0xb74>
ffffffffc0201792:	921fe0ef          	jal	ffffffffc02000b2 <cprintf>
    kfree(obj);
ffffffffc0201796:	8526                	mv	a0,s1
ffffffffc0201798:	f3dff0ef          	jal	ffffffffc02016d4 <kfree>
    slab_cache_t* cache = slab_caches[index-4];
ffffffffc020179c:	00093403          	ld	s0,0(s2)
        cprintf("Slab cache %d is NULL.\n", index-4);
ffffffffc02017a0:	4581                	li	a1,0
ffffffffc02017a2:	00001517          	auipc	a0,0x1
ffffffffc02017a6:	23e50513          	addi	a0,a0,574 # ffffffffc02029e0 <etext+0xb14>
    if (cache == NULL) {
ffffffffc02017aa:	c029                	beqz	s0,ffffffffc02017ec <check+0xbc>
    cprintf("Slab cache %d status:\n", index-4);
ffffffffc02017ac:	00001517          	auipc	a0,0x1
ffffffffc02017b0:	24c50513          	addi	a0,a0,588 # ffffffffc02029f8 <etext+0xb2c>
ffffffffc02017b4:	8fffe0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  Total objects: %d\n", cache->objnum);
ffffffffc02017b8:	444c                	lw	a1,12(s0)
ffffffffc02017ba:	00001517          	auipc	a0,0x1
ffffffffc02017be:	25650513          	addi	a0,a0,598 # ffffffffc0202a10 <etext+0xb44>
ffffffffc02017c2:	8f1fe0ef          	jal	ffffffffc02000b2 <cprintf>
    cprintf("  Active objects: %d\n", cache->page->active);
ffffffffc02017c6:	601c                	ld	a5,0(s0)
ffffffffc02017c8:	00001517          	auipc	a0,0x1
ffffffffc02017cc:	26050513          	addi	a0,a0,608 # ffffffffc0202a28 <etext+0xb5c>
ffffffffc02017d0:	578c                	lw	a1,40(a5)
ffffffffc02017d2:	8e1fe0ef          	jal	ffffffffc02000b2 <cprintf>
    struct obj_list_entry* temp = cache->page->freelist;
ffffffffc02017d6:	601c                	ld	a5,0(s0)
    int free_count = 0;
ffffffffc02017d8:	4581                	li	a1,0
    struct obj_list_entry* temp = cache->page->freelist;
ffffffffc02017da:	7b9c                	ld	a5,48(a5)
    while (temp != NULL) {
ffffffffc02017dc:	c781                	beqz	a5,ffffffffc02017e4 <check+0xb4>
        temp = temp->next;
ffffffffc02017de:	679c                	ld	a5,8(a5)
        free_count++;
ffffffffc02017e0:	2585                	addiw	a1,a1,1
    while (temp != NULL) {
ffffffffc02017e2:	fff5                	bnez	a5,ffffffffc02017de <check+0xae>
    cprintf("  Free objects in freelist: %d\n", free_count);
ffffffffc02017e4:	00001517          	auipc	a0,0x1
ffffffffc02017e8:	25c50513          	addi	a0,a0,604 # ffffffffc0202a40 <etext+0xb74>
}
ffffffffc02017ec:	6442                	ld	s0,16(sp)
ffffffffc02017ee:	60e2                	ld	ra,24(sp)
ffffffffc02017f0:	64a2                	ld	s1,8(sp)
ffffffffc02017f2:	6902                	ld	s2,0(sp)
ffffffffc02017f4:	6105                	addi	sp,sp,32
    cprintf("  Free objects in freelist: %d\n", free_count);
ffffffffc02017f6:	8bdfe06f          	j	ffffffffc02000b2 <cprintf>
        cprintf("Slab cache %d is NULL.\n", index-4);
ffffffffc02017fa:	00001517          	auipc	a0,0x1
ffffffffc02017fe:	1e650513          	addi	a0,a0,486 # ffffffffc02029e0 <etext+0xb14>
ffffffffc0201802:	8b1fe0ef          	jal	ffffffffc02000b2 <cprintf>
        return;
ffffffffc0201806:	bf41                	j	ffffffffc0201796 <check+0x66>

ffffffffc0201808 <debug_print_slab_caches>:





void debug_print_slab_caches() {
ffffffffc0201808:	7159                	addi	sp,sp,-112
    cprintf("===== Slab Cache Layout =====\n");
ffffffffc020180a:	00001517          	auipc	a0,0x1
ffffffffc020180e:	25650513          	addi	a0,a0,598 # ffffffffc0202a60 <etext+0xb94>
void debug_print_slab_caches() {
ffffffffc0201812:	e8ca                	sd	s2,80(sp)
ffffffffc0201814:	e4ce                	sd	s3,72(sp)
ffffffffc0201816:	e0d2                	sd	s4,64(sp)
ffffffffc0201818:	fc56                	sd	s5,56(sp)
ffffffffc020181a:	f85a                	sd	s6,48(sp)
ffffffffc020181c:	f45e                	sd	s7,40(sp)
ffffffffc020181e:	f062                	sd	s8,32(sp)
ffffffffc0201820:	ec66                	sd	s9,24(sp)
ffffffffc0201822:	e86a                	sd	s10,16(sp)
ffffffffc0201824:	e46e                	sd	s11,8(sp)
ffffffffc0201826:	f486                	sd	ra,104(sp)
ffffffffc0201828:	f0a2                	sd	s0,96(sp)
ffffffffc020182a:	eca6                	sd	s1,88(sp)
ffffffffc020182c:	00004a17          	auipc	s4,0x4
ffffffffc0201830:	7d4a0a13          	addi	s4,s4,2004 # ffffffffc0206000 <slab_caches>
    cprintf("===== Slab Cache Layout =====\n");
ffffffffc0201834:	87ffe0ef          	jal	ffffffffc02000b2 <cprintf>

    for (int i = 0; i < NUM_SLAB_CACHES; i++) {
ffffffffc0201838:	4901                	li	s2,0
        slab_cache_t *cache = slab_caches[i];
        cprintf("Slab Cache %d:\n", i + 1);
ffffffffc020183a:	00001c17          	auipc	s8,0x1
ffffffffc020183e:	246c0c13          	addi	s8,s8,582 # ffffffffc0202a80 <etext+0xbb4>
        cprintf("  Order: %d\n", cache->order);
ffffffffc0201842:	00001b97          	auipc	s7,0x1
ffffffffc0201846:	24eb8b93          	addi	s7,s7,590 # ffffffffc0202a90 <etext+0xbc4>
        cprintf("  Object Number: %d\n", cache->objnum);
ffffffffc020184a:	00001b17          	auipc	s6,0x1
ffffffffc020184e:	256b0b13          	addi	s6,s6,598 # ffffffffc0202aa0 <etext+0xbd4>
        cprintf("  Size of Object: %d bytes\n", cache->sizeofobj);
ffffffffc0201852:	00001a97          	auipc	s5,0x1
ffffffffc0201856:	266a8a93          	addi	s5,s5,614 # ffffffffc0202ab8 <etext+0xbec>
            }
            if (count == 0) {
                cprintf("      No free objects in this slab.\n");
            }
        } else {
            cprintf("  No associated Page.\n");
ffffffffc020185a:	00001c97          	auipc	s9,0x1
ffffffffc020185e:	366c8c93          	addi	s9,s9,870 # ffffffffc0202bc0 <etext+0xcf4>
            cprintf("  Page Details:\n");
ffffffffc0201862:	00001d97          	auipc	s11,0x1
ffffffffc0201866:	276d8d93          	addi	s11,s11,630 # ffffffffc0202ad8 <etext+0xc0c>
            cprintf("    Reference Count: %d\n", page->ref);
ffffffffc020186a:	00001d17          	auipc	s10,0x1
ffffffffc020186e:	286d0d13          	addi	s10,s10,646 # ffffffffc0202af0 <etext+0xc24>
                cprintf("      Free Object %d: %p\n", count, entry->obj);
ffffffffc0201872:	00001997          	auipc	s3,0x1
ffffffffc0201876:	30698993          	addi	s3,s3,774 # ffffffffc0202b78 <etext+0xcac>
ffffffffc020187a:	a831                	j	ffffffffc0201896 <debug_print_slab_caches+0x8e>
            cprintf("  No associated Page.\n");
ffffffffc020187c:	8566                	mv	a0,s9
ffffffffc020187e:	835fe0ef          	jal	ffffffffc02000b2 <cprintf>
        }

        cprintf("\n");
ffffffffc0201882:	00001517          	auipc	a0,0x1
ffffffffc0201886:	8c650513          	addi	a0,a0,-1850 # ffffffffc0202148 <etext+0x27c>
ffffffffc020188a:	829fe0ef          	jal	ffffffffc02000b2 <cprintf>
    for (int i = 0; i < NUM_SLAB_CACHES; i++) {
ffffffffc020188e:	47a1                	li	a5,8
ffffffffc0201890:	0a21                	addi	s4,s4,8
ffffffffc0201892:	08f90e63          	beq	s2,a5,ffffffffc020192e <debug_print_slab_caches+0x126>
        slab_cache_t *cache = slab_caches[i];
ffffffffc0201896:	000a3403          	ld	s0,0(s4)
        cprintf("Slab Cache %d:\n", i + 1);
ffffffffc020189a:	2905                	addiw	s2,s2,1
ffffffffc020189c:	85ca                	mv	a1,s2
ffffffffc020189e:	8562                	mv	a0,s8
ffffffffc02018a0:	813fe0ef          	jal	ffffffffc02000b2 <cprintf>
        cprintf("  Order: %d\n", cache->order);
ffffffffc02018a4:	440c                	lw	a1,8(s0)
ffffffffc02018a6:	855e                	mv	a0,s7
ffffffffc02018a8:	80bfe0ef          	jal	ffffffffc02000b2 <cprintf>
        cprintf("  Object Number: %d\n", cache->objnum);
ffffffffc02018ac:	444c                	lw	a1,12(s0)
ffffffffc02018ae:	855a                	mv	a0,s6
ffffffffc02018b0:	803fe0ef          	jal	ffffffffc02000b2 <cprintf>
        cprintf("  Size of Object: %d bytes\n", cache->sizeofobj);
ffffffffc02018b4:	480c                	lw	a1,16(s0)
ffffffffc02018b6:	8556                	mv	a0,s5
ffffffffc02018b8:	ffafe0ef          	jal	ffffffffc02000b2 <cprintf>
        struct Page *page = cache->page;
ffffffffc02018bc:	6000                	ld	s0,0(s0)
        if (page) {
ffffffffc02018be:	dc5d                	beqz	s0,ffffffffc020187c <debug_print_slab_caches+0x74>
            cprintf("  Page Details:\n");
ffffffffc02018c0:	856e                	mv	a0,s11
ffffffffc02018c2:	ff0fe0ef          	jal	ffffffffc02000b2 <cprintf>
            cprintf("    Reference Count: %d\n", page->ref);
ffffffffc02018c6:	400c                	lw	a1,0(s0)
ffffffffc02018c8:	856a                	mv	a0,s10
ffffffffc02018ca:	fe8fe0ef          	jal	ffffffffc02000b2 <cprintf>
            cprintf("    Flags: 0x%lx\n", page->flags);
ffffffffc02018ce:	640c                	ld	a1,8(s0)
ffffffffc02018d0:	00001517          	auipc	a0,0x1
ffffffffc02018d4:	24050513          	addi	a0,a0,576 # ffffffffc0202b10 <etext+0xc44>
ffffffffc02018d8:	fdafe0ef          	jal	ffffffffc02000b2 <cprintf>
            cprintf("    Property: %u\n", page->property);
ffffffffc02018dc:	480c                	lw	a1,16(s0)
ffffffffc02018de:	00001517          	auipc	a0,0x1
ffffffffc02018e2:	24a50513          	addi	a0,a0,586 # ffffffffc0202b28 <etext+0xc5c>
ffffffffc02018e6:	fccfe0ef          	jal	ffffffffc02000b2 <cprintf>
            cprintf("    Active Objects: %d\n", page->active);
ffffffffc02018ea:	540c                	lw	a1,40(s0)
ffffffffc02018ec:	00001517          	auipc	a0,0x1
ffffffffc02018f0:	25450513          	addi	a0,a0,596 # ffffffffc0202b40 <etext+0xc74>
ffffffffc02018f4:	fbefe0ef          	jal	ffffffffc02000b2 <cprintf>
            struct obj_list_entry *entry = page->freelist;
ffffffffc02018f8:	7800                	ld	s0,48(s0)
            cprintf("    Free Objects in Slab:\n");
ffffffffc02018fa:	00001517          	auipc	a0,0x1
ffffffffc02018fe:	25e50513          	addi	a0,a0,606 # ffffffffc0202b58 <etext+0xc8c>
ffffffffc0201902:	fb0fe0ef          	jal	ffffffffc02000b2 <cprintf>
            while (entry) {
ffffffffc0201906:	c821                	beqz	s0,ffffffffc0201956 <debug_print_slab_caches+0x14e>
            int count = 0;
ffffffffc0201908:	4481                	li	s1,0
                cprintf("      Free Object %d: %p\n", count, entry->obj);
ffffffffc020190a:	6810                	ld	a2,16(s0)
ffffffffc020190c:	85a6                	mv	a1,s1
ffffffffc020190e:	854e                	mv	a0,s3
ffffffffc0201910:	fa2fe0ef          	jal	ffffffffc02000b2 <cprintf>
                entry = entry->next;
ffffffffc0201914:	6400                	ld	s0,8(s0)
                count++;
ffffffffc0201916:	2485                	addiw	s1,s1,1
            while (entry) {
ffffffffc0201918:	f86d                	bnez	s0,ffffffffc020190a <debug_print_slab_caches+0x102>
        cprintf("\n");
ffffffffc020191a:	00001517          	auipc	a0,0x1
ffffffffc020191e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0202148 <etext+0x27c>
ffffffffc0201922:	f90fe0ef          	jal	ffffffffc02000b2 <cprintf>
    for (int i = 0; i < NUM_SLAB_CACHES; i++) {
ffffffffc0201926:	47a1                	li	a5,8
ffffffffc0201928:	0a21                	addi	s4,s4,8
ffffffffc020192a:	f6f916e3          	bne	s2,a5,ffffffffc0201896 <debug_print_slab_caches+0x8e>
    }

    cprintf("===== End of Slab Cache Layout =====\n");
ffffffffc020192e:	7406                	ld	s0,96(sp)
ffffffffc0201930:	70a6                	ld	ra,104(sp)
ffffffffc0201932:	64e6                	ld	s1,88(sp)
ffffffffc0201934:	6946                	ld	s2,80(sp)
ffffffffc0201936:	69a6                	ld	s3,72(sp)
ffffffffc0201938:	6a06                	ld	s4,64(sp)
ffffffffc020193a:	7ae2                	ld	s5,56(sp)
ffffffffc020193c:	7b42                	ld	s6,48(sp)
ffffffffc020193e:	7ba2                	ld	s7,40(sp)
ffffffffc0201940:	7c02                	ld	s8,32(sp)
ffffffffc0201942:	6ce2                	ld	s9,24(sp)
ffffffffc0201944:	6d42                	ld	s10,16(sp)
ffffffffc0201946:	6da2                	ld	s11,8(sp)
    cprintf("===== End of Slab Cache Layout =====\n");
ffffffffc0201948:	00001517          	auipc	a0,0x1
ffffffffc020194c:	29050513          	addi	a0,a0,656 # ffffffffc0202bd8 <etext+0xd0c>
ffffffffc0201950:	6165                	addi	sp,sp,112
    cprintf("===== End of Slab Cache Layout =====\n");
ffffffffc0201952:	f60fe06f          	j	ffffffffc02000b2 <cprintf>
                cprintf("      No free objects in this slab.\n");
ffffffffc0201956:	00001517          	auipc	a0,0x1
ffffffffc020195a:	24250513          	addi	a0,a0,578 # ffffffffc0202b98 <etext+0xccc>
ffffffffc020195e:	f54fe0ef          	jal	ffffffffc02000b2 <cprintf>
ffffffffc0201962:	b705                	j	ffffffffc0201882 <debug_print_slab_caches+0x7a>

ffffffffc0201964 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201964:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201968:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020196a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020196e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201970:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201974:	f022                	sd	s0,32(sp)
ffffffffc0201976:	ec26                	sd	s1,24(sp)
ffffffffc0201978:	e84a                	sd	s2,16(sp)
ffffffffc020197a:	f406                	sd	ra,40(sp)
ffffffffc020197c:	84aa                	mv	s1,a0
ffffffffc020197e:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201980:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201984:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201986:	05067063          	bgeu	a2,a6,ffffffffc02019c6 <printnum+0x62>
ffffffffc020198a:	e44e                	sd	s3,8(sp)
ffffffffc020198c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020198e:	4785                	li	a5,1
ffffffffc0201990:	00e7d763          	bge	a5,a4,ffffffffc020199e <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0201994:	85ca                	mv	a1,s2
ffffffffc0201996:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0201998:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020199a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020199c:	fc65                	bnez	s0,ffffffffc0201994 <printnum+0x30>
ffffffffc020199e:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019a0:	1a02                	slli	s4,s4,0x20
ffffffffc02019a2:	020a5a13          	srli	s4,s4,0x20
ffffffffc02019a6:	00001797          	auipc	a5,0x1
ffffffffc02019aa:	25a78793          	addi	a5,a5,602 # ffffffffc0202c00 <etext+0xd34>
ffffffffc02019ae:	97d2                	add	a5,a5,s4
}
ffffffffc02019b0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019b2:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02019b6:	70a2                	ld	ra,40(sp)
ffffffffc02019b8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019ba:	85ca                	mv	a1,s2
ffffffffc02019bc:	87a6                	mv	a5,s1
}
ffffffffc02019be:	6942                	ld	s2,16(sp)
ffffffffc02019c0:	64e2                	ld	s1,24(sp)
ffffffffc02019c2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02019c4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02019c6:	03065633          	divu	a2,a2,a6
ffffffffc02019ca:	8722                	mv	a4,s0
ffffffffc02019cc:	f99ff0ef          	jal	ffffffffc0201964 <printnum>
ffffffffc02019d0:	bfc1                	j	ffffffffc02019a0 <printnum+0x3c>

ffffffffc02019d2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02019d2:	7119                	addi	sp,sp,-128
ffffffffc02019d4:	f4a6                	sd	s1,104(sp)
ffffffffc02019d6:	f0ca                	sd	s2,96(sp)
ffffffffc02019d8:	ecce                	sd	s3,88(sp)
ffffffffc02019da:	e8d2                	sd	s4,80(sp)
ffffffffc02019dc:	e4d6                	sd	s5,72(sp)
ffffffffc02019de:	e0da                	sd	s6,64(sp)
ffffffffc02019e0:	f862                	sd	s8,48(sp)
ffffffffc02019e2:	fc86                	sd	ra,120(sp)
ffffffffc02019e4:	f8a2                	sd	s0,112(sp)
ffffffffc02019e6:	fc5e                	sd	s7,56(sp)
ffffffffc02019e8:	f466                	sd	s9,40(sp)
ffffffffc02019ea:	f06a                	sd	s10,32(sp)
ffffffffc02019ec:	ec6e                	sd	s11,24(sp)
ffffffffc02019ee:	892a                	mv	s2,a0
ffffffffc02019f0:	84ae                	mv	s1,a1
ffffffffc02019f2:	8c32                	mv	s8,a2
ffffffffc02019f4:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02019f6:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02019fa:	05500b13          	li	s6,85
ffffffffc02019fe:	00001a97          	auipc	s5,0x1
ffffffffc0201a02:	33aa8a93          	addi	s5,s5,826 # ffffffffc0202d38 <best_fit_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a06:	000c4503          	lbu	a0,0(s8)
ffffffffc0201a0a:	001c0413          	addi	s0,s8,1
ffffffffc0201a0e:	01350a63          	beq	a0,s3,ffffffffc0201a22 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0201a12:	cd0d                	beqz	a0,ffffffffc0201a4c <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0201a14:	85a6                	mv	a1,s1
ffffffffc0201a16:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201a18:	00044503          	lbu	a0,0(s0)
ffffffffc0201a1c:	0405                	addi	s0,s0,1
ffffffffc0201a1e:	ff351ae3          	bne	a0,s3,ffffffffc0201a12 <vprintfmt+0x40>
        char padc = ' ';
ffffffffc0201a22:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0201a26:	4b81                	li	s7,0
ffffffffc0201a28:	4601                	li	a2,0
        width = precision = -1;
ffffffffc0201a2a:	5d7d                	li	s10,-1
ffffffffc0201a2c:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a2e:	00044683          	lbu	a3,0(s0)
ffffffffc0201a32:	00140c13          	addi	s8,s0,1
ffffffffc0201a36:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0201a3a:	0ff5f593          	zext.b	a1,a1
ffffffffc0201a3e:	02bb6663          	bltu	s6,a1,ffffffffc0201a6a <vprintfmt+0x98>
ffffffffc0201a42:	058a                	slli	a1,a1,0x2
ffffffffc0201a44:	95d6                	add	a1,a1,s5
ffffffffc0201a46:	4198                	lw	a4,0(a1)
ffffffffc0201a48:	9756                	add	a4,a4,s5
ffffffffc0201a4a:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201a4c:	70e6                	ld	ra,120(sp)
ffffffffc0201a4e:	7446                	ld	s0,112(sp)
ffffffffc0201a50:	74a6                	ld	s1,104(sp)
ffffffffc0201a52:	7906                	ld	s2,96(sp)
ffffffffc0201a54:	69e6                	ld	s3,88(sp)
ffffffffc0201a56:	6a46                	ld	s4,80(sp)
ffffffffc0201a58:	6aa6                	ld	s5,72(sp)
ffffffffc0201a5a:	6b06                	ld	s6,64(sp)
ffffffffc0201a5c:	7be2                	ld	s7,56(sp)
ffffffffc0201a5e:	7c42                	ld	s8,48(sp)
ffffffffc0201a60:	7ca2                	ld	s9,40(sp)
ffffffffc0201a62:	7d02                	ld	s10,32(sp)
ffffffffc0201a64:	6de2                	ld	s11,24(sp)
ffffffffc0201a66:	6109                	addi	sp,sp,128
ffffffffc0201a68:	8082                	ret
            putch('%', putdat);
ffffffffc0201a6a:	85a6                	mv	a1,s1
ffffffffc0201a6c:	02500513          	li	a0,37
ffffffffc0201a70:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201a72:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201a76:	02500793          	li	a5,37
ffffffffc0201a7a:	8c22                	mv	s8,s0
ffffffffc0201a7c:	f8f705e3          	beq	a4,a5,ffffffffc0201a06 <vprintfmt+0x34>
ffffffffc0201a80:	02500713          	li	a4,37
ffffffffc0201a84:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0201a88:	1c7d                	addi	s8,s8,-1
ffffffffc0201a8a:	fee79de3          	bne	a5,a4,ffffffffc0201a84 <vprintfmt+0xb2>
ffffffffc0201a8e:	bfa5                	j	ffffffffc0201a06 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0201a90:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0201a94:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc0201a96:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0201a9a:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc0201a9e:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aa2:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc0201aa4:	02b76563          	bltu	a4,a1,ffffffffc0201ace <vprintfmt+0xfc>
ffffffffc0201aa8:	4525                	li	a0,9
                ch = *fmt;
ffffffffc0201aaa:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201aae:	002d171b          	slliw	a4,s10,0x2
ffffffffc0201ab2:	01a7073b          	addw	a4,a4,s10
ffffffffc0201ab6:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201aba:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc0201abc:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201ac0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201ac2:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc0201ac6:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc0201aca:	feb570e3          	bgeu	a0,a1,ffffffffc0201aaa <vprintfmt+0xd8>
            if (width < 0)
ffffffffc0201ace:	f60cd0e3          	bgez	s9,ffffffffc0201a2e <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0201ad2:	8cea                	mv	s9,s10
ffffffffc0201ad4:	5d7d                	li	s10,-1
ffffffffc0201ad6:	bfa1                	j	ffffffffc0201a2e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201ad8:	8db6                	mv	s11,a3
ffffffffc0201ada:	8462                	mv	s0,s8
ffffffffc0201adc:	bf89                	j	ffffffffc0201a2e <vprintfmt+0x5c>
ffffffffc0201ade:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0201ae0:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0201ae2:	b7b1                	j	ffffffffc0201a2e <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0201ae4:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201ae6:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201aea:	00c7c463          	blt	a5,a2,ffffffffc0201af2 <vprintfmt+0x120>
    else if (lflag) {
ffffffffc0201aee:	1a060163          	beqz	a2,ffffffffc0201c90 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc0201af2:	000a3603          	ld	a2,0(s4)
ffffffffc0201af6:	46c1                	li	a3,16
ffffffffc0201af8:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201afa:	000d879b          	sext.w	a5,s11
ffffffffc0201afe:	8766                	mv	a4,s9
ffffffffc0201b00:	85a6                	mv	a1,s1
ffffffffc0201b02:	854a                	mv	a0,s2
ffffffffc0201b04:	e61ff0ef          	jal	ffffffffc0201964 <printnum>
            break;
ffffffffc0201b08:	bdfd                	j	ffffffffc0201a06 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0201b0a:	000a2503          	lw	a0,0(s4)
ffffffffc0201b0e:	85a6                	mv	a1,s1
ffffffffc0201b10:	0a21                	addi	s4,s4,8
ffffffffc0201b12:	9902                	jalr	s2
            break;
ffffffffc0201b14:	bdcd                	j	ffffffffc0201a06 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201b16:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201b18:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201b1c:	00c7c463          	blt	a5,a2,ffffffffc0201b24 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc0201b20:	16060363          	beqz	a2,ffffffffc0201c86 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc0201b24:	000a3603          	ld	a2,0(s4)
ffffffffc0201b28:	46a9                	li	a3,10
ffffffffc0201b2a:	8a3a                	mv	s4,a4
ffffffffc0201b2c:	b7f9                	j	ffffffffc0201afa <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc0201b2e:	85a6                	mv	a1,s1
ffffffffc0201b30:	03000513          	li	a0,48
ffffffffc0201b34:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201b36:	85a6                	mv	a1,s1
ffffffffc0201b38:	07800513          	li	a0,120
ffffffffc0201b3c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201b3e:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0201b42:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201b44:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201b46:	bf55                	j	ffffffffc0201afa <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc0201b48:	85a6                	mv	a1,s1
ffffffffc0201b4a:	02500513          	li	a0,37
ffffffffc0201b4e:	9902                	jalr	s2
            break;
ffffffffc0201b50:	bd5d                	j	ffffffffc0201a06 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0201b52:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b56:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0201b58:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0201b5a:	bf95                	j	ffffffffc0201ace <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc0201b5c:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201b5e:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201b62:	00c7c463          	blt	a5,a2,ffffffffc0201b6a <vprintfmt+0x198>
    else if (lflag) {
ffffffffc0201b66:	10060b63          	beqz	a2,ffffffffc0201c7c <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc0201b6a:	000a3603          	ld	a2,0(s4)
ffffffffc0201b6e:	46a1                	li	a3,8
ffffffffc0201b70:	8a3a                	mv	s4,a4
ffffffffc0201b72:	b761                	j	ffffffffc0201afa <vprintfmt+0x128>
            if (width < 0)
ffffffffc0201b74:	fffcc793          	not	a5,s9
ffffffffc0201b78:	97fd                	srai	a5,a5,0x3f
ffffffffc0201b7a:	00fcf7b3          	and	a5,s9,a5
ffffffffc0201b7e:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b82:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201b84:	b56d                	j	ffffffffc0201a2e <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201b86:	000a3403          	ld	s0,0(s4)
ffffffffc0201b8a:	008a0793          	addi	a5,s4,8
ffffffffc0201b8e:	e43e                	sd	a5,8(sp)
ffffffffc0201b90:	12040063          	beqz	s0,ffffffffc0201cb0 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0201b94:	0d905963          	blez	s9,ffffffffc0201c66 <vprintfmt+0x294>
ffffffffc0201b98:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b9c:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc0201ba0:	12fd9763          	bne	s11,a5,ffffffffc0201cce <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ba4:	00044783          	lbu	a5,0(s0)
ffffffffc0201ba8:	0007851b          	sext.w	a0,a5
ffffffffc0201bac:	cb9d                	beqz	a5,ffffffffc0201be2 <vprintfmt+0x210>
ffffffffc0201bae:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201bb0:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bb4:	000d4563          	bltz	s10,ffffffffc0201bbe <vprintfmt+0x1ec>
ffffffffc0201bb8:	3d7d                	addiw	s10,s10,-1
ffffffffc0201bba:	028d0263          	beq	s10,s0,ffffffffc0201bde <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc0201bbe:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201bc0:	0c0b8d63          	beqz	s7,ffffffffc0201c9a <vprintfmt+0x2c8>
ffffffffc0201bc4:	3781                	addiw	a5,a5,-32
ffffffffc0201bc6:	0cfdfa63          	bgeu	s11,a5,ffffffffc0201c9a <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc0201bca:	03f00513          	li	a0,63
ffffffffc0201bce:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201bd0:	000a4783          	lbu	a5,0(s4)
ffffffffc0201bd4:	3cfd                	addiw	s9,s9,-1
ffffffffc0201bd6:	0a05                	addi	s4,s4,1
ffffffffc0201bd8:	0007851b          	sext.w	a0,a5
ffffffffc0201bdc:	ffe1                	bnez	a5,ffffffffc0201bb4 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc0201bde:	01905963          	blez	s9,ffffffffc0201bf0 <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc0201be2:	85a6                	mv	a1,s1
ffffffffc0201be4:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0201be8:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc0201bea:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201bec:	fe0c9be3          	bnez	s9,ffffffffc0201be2 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201bf0:	6a22                	ld	s4,8(sp)
ffffffffc0201bf2:	bd11                	j	ffffffffc0201a06 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201bf4:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201bf6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0201bfa:	00c7c363          	blt	a5,a2,ffffffffc0201c00 <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc0201bfe:	ce25                	beqz	a2,ffffffffc0201c76 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc0201c00:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201c04:	08044d63          	bltz	s0,ffffffffc0201c9e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0201c08:	8622                	mv	a2,s0
ffffffffc0201c0a:	8a5e                	mv	s4,s7
ffffffffc0201c0c:	46a9                	li	a3,10
ffffffffc0201c0e:	b5f5                	j	ffffffffc0201afa <vprintfmt+0x128>
            if (err < 0) {
ffffffffc0201c10:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c14:	4619                	li	a2,6
            if (err < 0) {
ffffffffc0201c16:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0201c1a:	8fb9                	xor	a5,a5,a4
ffffffffc0201c1c:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201c20:	02d64663          	blt	a2,a3,ffffffffc0201c4c <vprintfmt+0x27a>
ffffffffc0201c24:	00369713          	slli	a4,a3,0x3
ffffffffc0201c28:	00001797          	auipc	a5,0x1
ffffffffc0201c2c:	26878793          	addi	a5,a5,616 # ffffffffc0202e90 <error_string>
ffffffffc0201c30:	97ba                	add	a5,a5,a4
ffffffffc0201c32:	639c                	ld	a5,0(a5)
ffffffffc0201c34:	cf81                	beqz	a5,ffffffffc0201c4c <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201c36:	86be                	mv	a3,a5
ffffffffc0201c38:	00001617          	auipc	a2,0x1
ffffffffc0201c3c:	ff860613          	addi	a2,a2,-8 # ffffffffc0202c30 <etext+0xd64>
ffffffffc0201c40:	85a6                	mv	a1,s1
ffffffffc0201c42:	854a                	mv	a0,s2
ffffffffc0201c44:	0e8000ef          	jal	ffffffffc0201d2c <printfmt>
            err = va_arg(ap, int);
ffffffffc0201c48:	0a21                	addi	s4,s4,8
ffffffffc0201c4a:	bb75                	j	ffffffffc0201a06 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201c4c:	00001617          	auipc	a2,0x1
ffffffffc0201c50:	fd460613          	addi	a2,a2,-44 # ffffffffc0202c20 <etext+0xd54>
ffffffffc0201c54:	85a6                	mv	a1,s1
ffffffffc0201c56:	854a                	mv	a0,s2
ffffffffc0201c58:	0d4000ef          	jal	ffffffffc0201d2c <printfmt>
            err = va_arg(ap, int);
ffffffffc0201c5c:	0a21                	addi	s4,s4,8
ffffffffc0201c5e:	b365                	j	ffffffffc0201a06 <vprintfmt+0x34>
            lflag ++;
ffffffffc0201c60:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c62:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201c64:	b3e9                	j	ffffffffc0201a2e <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c66:	00044783          	lbu	a5,0(s0)
ffffffffc0201c6a:	0007851b          	sext.w	a0,a5
ffffffffc0201c6e:	d3c9                	beqz	a5,ffffffffc0201bf0 <vprintfmt+0x21e>
ffffffffc0201c70:	00140a13          	addi	s4,s0,1
ffffffffc0201c74:	bf2d                	j	ffffffffc0201bae <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc0201c76:	000a2403          	lw	s0,0(s4)
ffffffffc0201c7a:	b769                	j	ffffffffc0201c04 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc0201c7c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c80:	46a1                	li	a3,8
ffffffffc0201c82:	8a3a                	mv	s4,a4
ffffffffc0201c84:	bd9d                	j	ffffffffc0201afa <vprintfmt+0x128>
ffffffffc0201c86:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c8a:	46a9                	li	a3,10
ffffffffc0201c8c:	8a3a                	mv	s4,a4
ffffffffc0201c8e:	b5b5                	j	ffffffffc0201afa <vprintfmt+0x128>
ffffffffc0201c90:	000a6603          	lwu	a2,0(s4)
ffffffffc0201c94:	46c1                	li	a3,16
ffffffffc0201c96:	8a3a                	mv	s4,a4
ffffffffc0201c98:	b58d                	j	ffffffffc0201afa <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc0201c9a:	9902                	jalr	s2
ffffffffc0201c9c:	bf15                	j	ffffffffc0201bd0 <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc0201c9e:	85a6                	mv	a1,s1
ffffffffc0201ca0:	02d00513          	li	a0,45
ffffffffc0201ca4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201ca6:	40800633          	neg	a2,s0
ffffffffc0201caa:	8a5e                	mv	s4,s7
ffffffffc0201cac:	46a9                	li	a3,10
ffffffffc0201cae:	b5b1                	j	ffffffffc0201afa <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc0201cb0:	01905663          	blez	s9,ffffffffc0201cbc <vprintfmt+0x2ea>
ffffffffc0201cb4:	02d00793          	li	a5,45
ffffffffc0201cb8:	04fd9263          	bne	s11,a5,ffffffffc0201cfc <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cbc:	02800793          	li	a5,40
ffffffffc0201cc0:	00001a17          	auipc	s4,0x1
ffffffffc0201cc4:	f59a0a13          	addi	s4,s4,-167 # ffffffffc0202c19 <etext+0xd4d>
ffffffffc0201cc8:	02800513          	li	a0,40
ffffffffc0201ccc:	b5cd                	j	ffffffffc0201bae <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cce:	85ea                	mv	a1,s10
ffffffffc0201cd0:	8522                	mv	a0,s0
ffffffffc0201cd2:	17e000ef          	jal	ffffffffc0201e50 <strnlen>
ffffffffc0201cd6:	40ac8cbb          	subw	s9,s9,a0
ffffffffc0201cda:	01905963          	blez	s9,ffffffffc0201cec <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc0201cde:	2d81                	sext.w	s11,s11
ffffffffc0201ce0:	85a6                	mv	a1,s1
ffffffffc0201ce2:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201ce4:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc0201ce6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201ce8:	fe0c9ce3          	bnez	s9,ffffffffc0201ce0 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cec:	00044783          	lbu	a5,0(s0)
ffffffffc0201cf0:	0007851b          	sext.w	a0,a5
ffffffffc0201cf4:	ea079de3          	bnez	a5,ffffffffc0201bae <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201cf8:	6a22                	ld	s4,8(sp)
ffffffffc0201cfa:	b331                	j	ffffffffc0201a06 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201cfc:	85ea                	mv	a1,s10
ffffffffc0201cfe:	00001517          	auipc	a0,0x1
ffffffffc0201d02:	f1a50513          	addi	a0,a0,-230 # ffffffffc0202c18 <etext+0xd4c>
ffffffffc0201d06:	14a000ef          	jal	ffffffffc0201e50 <strnlen>
ffffffffc0201d0a:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc0201d0e:	00001417          	auipc	s0,0x1
ffffffffc0201d12:	f0a40413          	addi	s0,s0,-246 # ffffffffc0202c18 <etext+0xd4c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201d16:	00001a17          	auipc	s4,0x1
ffffffffc0201d1a:	f03a0a13          	addi	s4,s4,-253 # ffffffffc0202c19 <etext+0xd4d>
ffffffffc0201d1e:	02800793          	li	a5,40
ffffffffc0201d22:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201d26:	fb904ce3          	bgtz	s9,ffffffffc0201cde <vprintfmt+0x30c>
ffffffffc0201d2a:	b551                	j	ffffffffc0201bae <vprintfmt+0x1dc>

ffffffffc0201d2c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d2c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201d2e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d32:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d34:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201d36:	ec06                	sd	ra,24(sp)
ffffffffc0201d38:	f83a                	sd	a4,48(sp)
ffffffffc0201d3a:	fc3e                	sd	a5,56(sp)
ffffffffc0201d3c:	e0c2                	sd	a6,64(sp)
ffffffffc0201d3e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201d40:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201d42:	c91ff0ef          	jal	ffffffffc02019d2 <vprintfmt>
}
ffffffffc0201d46:	60e2                	ld	ra,24(sp)
ffffffffc0201d48:	6161                	addi	sp,sp,80
ffffffffc0201d4a:	8082                	ret

ffffffffc0201d4c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201d4c:	715d                	addi	sp,sp,-80
ffffffffc0201d4e:	e486                	sd	ra,72(sp)
ffffffffc0201d50:	e0a2                	sd	s0,64(sp)
ffffffffc0201d52:	fc26                	sd	s1,56(sp)
ffffffffc0201d54:	f84a                	sd	s2,48(sp)
ffffffffc0201d56:	f44e                	sd	s3,40(sp)
ffffffffc0201d58:	f052                	sd	s4,32(sp)
ffffffffc0201d5a:	ec56                	sd	s5,24(sp)
ffffffffc0201d5c:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc0201d5e:	c901                	beqz	a0,ffffffffc0201d6e <readline+0x22>
ffffffffc0201d60:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201d62:	00001517          	auipc	a0,0x1
ffffffffc0201d66:	ece50513          	addi	a0,a0,-306 # ffffffffc0202c30 <etext+0xd64>
ffffffffc0201d6a:	b48fe0ef          	jal	ffffffffc02000b2 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0201d6e:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d70:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201d72:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201d74:	4a29                	li	s4,10
ffffffffc0201d76:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc0201d78:	00004b17          	auipc	s6,0x4
ffffffffc0201d7c:	3b0b0b13          	addi	s6,s6,944 # ffffffffc0206128 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d80:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc0201d84:	bb2fe0ef          	jal	ffffffffc0200136 <getchar>
        if (c < 0) {
ffffffffc0201d88:	00054a63          	bltz	a0,ffffffffc0201d9c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201d8c:	00a4da63          	bge	s1,a0,ffffffffc0201da0 <readline+0x54>
ffffffffc0201d90:	0289d263          	bge	s3,s0,ffffffffc0201db4 <readline+0x68>
        c = getchar();
ffffffffc0201d94:	ba2fe0ef          	jal	ffffffffc0200136 <getchar>
        if (c < 0) {
ffffffffc0201d98:	fe055ae3          	bgez	a0,ffffffffc0201d8c <readline+0x40>
            return NULL;
ffffffffc0201d9c:	4501                	li	a0,0
ffffffffc0201d9e:	a091                	j	ffffffffc0201de2 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201da0:	03251463          	bne	a0,s2,ffffffffc0201dc8 <readline+0x7c>
ffffffffc0201da4:	04804963          	bgtz	s0,ffffffffc0201df6 <readline+0xaa>
        c = getchar();
ffffffffc0201da8:	b8efe0ef          	jal	ffffffffc0200136 <getchar>
        if (c < 0) {
ffffffffc0201dac:	fe0548e3          	bltz	a0,ffffffffc0201d9c <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201db0:	fea4d8e3          	bge	s1,a0,ffffffffc0201da0 <readline+0x54>
            cputchar(c);
ffffffffc0201db4:	e42a                	sd	a0,8(sp)
ffffffffc0201db6:	b30fe0ef          	jal	ffffffffc02000e6 <cputchar>
            buf[i ++] = c;
ffffffffc0201dba:	6522                	ld	a0,8(sp)
ffffffffc0201dbc:	008b07b3          	add	a5,s6,s0
ffffffffc0201dc0:	2405                	addiw	s0,s0,1
ffffffffc0201dc2:	00a78023          	sb	a0,0(a5)
ffffffffc0201dc6:	bf7d                	j	ffffffffc0201d84 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201dc8:	01450463          	beq	a0,s4,ffffffffc0201dd0 <readline+0x84>
ffffffffc0201dcc:	fb551ce3          	bne	a0,s5,ffffffffc0201d84 <readline+0x38>
            cputchar(c);
ffffffffc0201dd0:	b16fe0ef          	jal	ffffffffc02000e6 <cputchar>
            buf[i] = '\0';
ffffffffc0201dd4:	00004517          	auipc	a0,0x4
ffffffffc0201dd8:	35450513          	addi	a0,a0,852 # ffffffffc0206128 <buf>
ffffffffc0201ddc:	942a                	add	s0,s0,a0
ffffffffc0201dde:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0201de2:	60a6                	ld	ra,72(sp)
ffffffffc0201de4:	6406                	ld	s0,64(sp)
ffffffffc0201de6:	74e2                	ld	s1,56(sp)
ffffffffc0201de8:	7942                	ld	s2,48(sp)
ffffffffc0201dea:	79a2                	ld	s3,40(sp)
ffffffffc0201dec:	7a02                	ld	s4,32(sp)
ffffffffc0201dee:	6ae2                	ld	s5,24(sp)
ffffffffc0201df0:	6b42                	ld	s6,16(sp)
ffffffffc0201df2:	6161                	addi	sp,sp,80
ffffffffc0201df4:	8082                	ret
            cputchar(c);
ffffffffc0201df6:	4521                	li	a0,8
ffffffffc0201df8:	aeefe0ef          	jal	ffffffffc02000e6 <cputchar>
            i --;
ffffffffc0201dfc:	347d                	addiw	s0,s0,-1
ffffffffc0201dfe:	b759                	j	ffffffffc0201d84 <readline+0x38>

ffffffffc0201e00 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201e00:	4781                	li	a5,0
ffffffffc0201e02:	00004717          	auipc	a4,0x4
ffffffffc0201e06:	24673703          	ld	a4,582(a4) # ffffffffc0206048 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201e0a:	88ba                	mv	a7,a4
ffffffffc0201e0c:	852a                	mv	a0,a0
ffffffffc0201e0e:	85be                	mv	a1,a5
ffffffffc0201e10:	863e                	mv	a2,a5
ffffffffc0201e12:	00000073          	ecall
ffffffffc0201e16:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201e18:	8082                	ret

ffffffffc0201e1a <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201e1a:	4781                	li	a5,0
ffffffffc0201e1c:	00004717          	auipc	a4,0x4
ffffffffc0201e20:	74c73703          	ld	a4,1868(a4) # ffffffffc0206568 <SBI_SET_TIMER>
ffffffffc0201e24:	88ba                	mv	a7,a4
ffffffffc0201e26:	852a                	mv	a0,a0
ffffffffc0201e28:	85be                	mv	a1,a5
ffffffffc0201e2a:	863e                	mv	a2,a5
ffffffffc0201e2c:	00000073          	ecall
ffffffffc0201e30:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201e32:	8082                	ret

ffffffffc0201e34 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201e34:	4501                	li	a0,0
ffffffffc0201e36:	00004797          	auipc	a5,0x4
ffffffffc0201e3a:	20a7b783          	ld	a5,522(a5) # ffffffffc0206040 <SBI_CONSOLE_GETCHAR>
ffffffffc0201e3e:	88be                	mv	a7,a5
ffffffffc0201e40:	852a                	mv	a0,a0
ffffffffc0201e42:	85aa                	mv	a1,a0
ffffffffc0201e44:	862a                	mv	a2,a0
ffffffffc0201e46:	00000073          	ecall
ffffffffc0201e4a:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201e4c:	2501                	sext.w	a0,a0
ffffffffc0201e4e:	8082                	ret

ffffffffc0201e50 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201e50:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201e52:	e589                	bnez	a1,ffffffffc0201e5c <strnlen+0xc>
ffffffffc0201e54:	a811                	j	ffffffffc0201e68 <strnlen+0x18>
        cnt ++;
ffffffffc0201e56:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201e58:	00f58863          	beq	a1,a5,ffffffffc0201e68 <strnlen+0x18>
ffffffffc0201e5c:	00f50733          	add	a4,a0,a5
ffffffffc0201e60:	00074703          	lbu	a4,0(a4)
ffffffffc0201e64:	fb6d                	bnez	a4,ffffffffc0201e56 <strnlen+0x6>
ffffffffc0201e66:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201e68:	852e                	mv	a0,a1
ffffffffc0201e6a:	8082                	ret

ffffffffc0201e6c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201e6c:	00054783          	lbu	a5,0(a0)
ffffffffc0201e70:	e791                	bnez	a5,ffffffffc0201e7c <strcmp+0x10>
ffffffffc0201e72:	a02d                	j	ffffffffc0201e9c <strcmp+0x30>
ffffffffc0201e74:	00054783          	lbu	a5,0(a0)
ffffffffc0201e78:	cf89                	beqz	a5,ffffffffc0201e92 <strcmp+0x26>
ffffffffc0201e7a:	85b6                	mv	a1,a3
ffffffffc0201e7c:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0201e80:	0505                	addi	a0,a0,1
ffffffffc0201e82:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201e86:	fef707e3          	beq	a4,a5,ffffffffc0201e74 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201e8a:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201e8e:	9d19                	subw	a0,a0,a4
ffffffffc0201e90:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201e92:	0015c703          	lbu	a4,1(a1)
ffffffffc0201e96:	4501                	li	a0,0
}
ffffffffc0201e98:	9d19                	subw	a0,a0,a4
ffffffffc0201e9a:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201e9c:	0005c703          	lbu	a4,0(a1)
ffffffffc0201ea0:	4501                	li	a0,0
ffffffffc0201ea2:	b7f5                	j	ffffffffc0201e8e <strcmp+0x22>

ffffffffc0201ea4 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201ea4:	00054783          	lbu	a5,0(a0)
ffffffffc0201ea8:	c799                	beqz	a5,ffffffffc0201eb6 <strchr+0x12>
        if (*s == c) {
ffffffffc0201eaa:	00f58763          	beq	a1,a5,ffffffffc0201eb8 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201eae:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201eb2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201eb4:	fbfd                	bnez	a5,ffffffffc0201eaa <strchr+0x6>
    }
    return NULL;
ffffffffc0201eb6:	4501                	li	a0,0
}
ffffffffc0201eb8:	8082                	ret

ffffffffc0201eba <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201eba:	ca01                	beqz	a2,ffffffffc0201eca <memset+0x10>
ffffffffc0201ebc:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201ebe:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ec0:	0785                	addi	a5,a5,1
ffffffffc0201ec2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201ec6:	fef61de3          	bne	a2,a5,ffffffffc0201ec0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201eca:	8082                	ret
