
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	2e1000ef          	jal	ra,80200b02 <memset>

    cons_init();  // init the console
    80200026:	150000ef          	jal	ra,80200176 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	aee58593          	addi	a1,a1,-1298 # 80200b18 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	b0650513          	addi	a0,a0,-1274 # 80200b38 <etext+0x24>
    8020003a:	036000ef          	jal	ra,80200070 <cprintf>

    print_kerninfo();
    8020003e:	068000ef          	jal	ra,802000a6 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	144000ef          	jal	ra,80200186 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0ee000ef          	jal	ra,80200134 <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	136000ef          	jal	ra,80200180 <intr_enable>
    asm volatile (
    8020004e:	30200073          	mret
        "mret"
    );
    asm volatile (
    80200052:	9002                	ebreak
       "ebreak"
    );
    
    while (1)
    80200054:	a001                	j	80200054 <kern_init+0x4a>

0000000080200056 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200056:	1141                	addi	sp,sp,-16
    80200058:	e022                	sd	s0,0(sp)
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	842e                	mv	s0,a1
    cons_putc(c);
    8020005e:	11a000ef          	jal	ra,80200178 <cons_putc>
    (*cnt)++;
    80200062:	401c                	lw	a5,0(s0)
}
    80200064:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200066:	2785                	addiw	a5,a5,1
    80200068:	c01c                	sw	a5,0(s0)
}
    8020006a:	6402                	ld	s0,0(sp)
    8020006c:	0141                	addi	sp,sp,16
    8020006e:	8082                	ret

0000000080200070 <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    80200070:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    80200072:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200076:	8e2a                	mv	t3,a0
    80200078:	f42e                	sd	a1,40(sp)
    8020007a:	f832                	sd	a2,48(sp)
    8020007c:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020007e:	00000517          	auipc	a0,0x0
    80200082:	fd850513          	addi	a0,a0,-40 # 80200056 <cputch>
    80200086:	004c                	addi	a1,sp,4
    80200088:	869a                	mv	a3,t1
    8020008a:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    8020008c:	ec06                	sd	ra,24(sp)
    8020008e:	e0ba                	sd	a4,64(sp)
    80200090:	e4be                	sd	a5,72(sp)
    80200092:	e8c2                	sd	a6,80(sp)
    80200094:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200096:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200098:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    8020009a:	67c000ef          	jal	ra,80200716 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    8020009e:	60e2                	ld	ra,24(sp)
    802000a0:	4512                	lw	a0,4(sp)
    802000a2:	6125                	addi	sp,sp,96
    802000a4:	8082                	ret

00000000802000a6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a8:	00001517          	auipc	a0,0x1
    802000ac:	a9850513          	addi	a0,a0,-1384 # 80200b40 <etext+0x2c>
void print_kerninfo(void) {
    802000b0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000b2:	fbfff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b6:	00000597          	auipc	a1,0x0
    802000ba:	f5458593          	addi	a1,a1,-172 # 8020000a <kern_init>
    802000be:	00001517          	auipc	a0,0x1
    802000c2:	aa250513          	addi	a0,a0,-1374 # 80200b60 <etext+0x4c>
    802000c6:	fabff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000ca:	00001597          	auipc	a1,0x1
    802000ce:	a4a58593          	addi	a1,a1,-1462 # 80200b14 <etext>
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	aae50513          	addi	a0,a0,-1362 # 80200b80 <etext+0x6c>
    802000da:	f97ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000de:	00004597          	auipc	a1,0x4
    802000e2:	f3258593          	addi	a1,a1,-206 # 80204010 <ticks>
    802000e6:	00001517          	auipc	a0,0x1
    802000ea:	aba50513          	addi	a0,a0,-1350 # 80200ba0 <etext+0x8c>
    802000ee:	f83ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000f2:	00004597          	auipc	a1,0x4
    802000f6:	f3658593          	addi	a1,a1,-202 # 80204028 <end>
    802000fa:	00001517          	auipc	a0,0x1
    802000fe:	ac650513          	addi	a0,a0,-1338 # 80200bc0 <etext+0xac>
    80200102:	f6fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200106:	00004597          	auipc	a1,0x4
    8020010a:	32158593          	addi	a1,a1,801 # 80204427 <end+0x3ff>
    8020010e:	00000797          	auipc	a5,0x0
    80200112:	efc78793          	addi	a5,a5,-260 # 8020000a <kern_init>
    80200116:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	43f7d593          	srai	a1,a5,0x3f
}
    8020011e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200120:	3ff5f593          	andi	a1,a1,1023
    80200124:	95be                	add	a1,a1,a5
    80200126:	85a9                	srai	a1,a1,0xa
    80200128:	00001517          	auipc	a0,0x1
    8020012c:	ab850513          	addi	a0,a0,-1352 # 80200be0 <etext+0xcc>
}
    80200130:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200132:	bf3d                	j	80200070 <cprintf>

0000000080200134 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    80200134:	1141                	addi	sp,sp,-16
    80200136:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200138:	02000793          	li	a5,32
    8020013c:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200140:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200144:	67e1                	lui	a5,0x18
    80200146:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020014a:	953e                	add	a0,a0,a5
    8020014c:	167000ef          	jal	ra,80200ab2 <sbi_set_timer>
}
    80200150:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200152:	00004797          	auipc	a5,0x4
    80200156:	ea07bf23          	sd	zero,-322(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    8020015a:	00001517          	auipc	a0,0x1
    8020015e:	ab650513          	addi	a0,a0,-1354 # 80200c10 <etext+0xfc>
}
    80200162:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    80200164:	b731                	j	80200070 <cprintf>

0000000080200166 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200166:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020016a:	67e1                	lui	a5,0x18
    8020016c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200170:	953e                	add	a0,a0,a5
    80200172:	1410006f          	j	80200ab2 <sbi_set_timer>

0000000080200176 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200176:	8082                	ret

0000000080200178 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200178:	0ff57513          	zext.b	a0,a0
    8020017c:	11d0006f          	j	80200a98 <sbi_console_putchar>

0000000080200180 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200180:	100167f3          	csrrsi	a5,sstatus,2
    80200184:	8082                	ret

0000000080200186 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200186:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    8020018a:	00000797          	auipc	a5,0x0
    8020018e:	46a78793          	addi	a5,a5,1130 # 802005f4 <__alltraps>
    80200192:	10579073          	csrw	stvec,a5
}
    80200196:	8082                	ret

0000000080200198 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    8020019a:	1141                	addi	sp,sp,-16
    8020019c:	e022                	sd	s0,0(sp)
    8020019e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	00001517          	auipc	a0,0x1
    802001a4:	a9050513          	addi	a0,a0,-1392 # 80200c30 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001a8:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001aa:	ec7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001ae:	640c                	ld	a1,8(s0)
    802001b0:	00001517          	auipc	a0,0x1
    802001b4:	a9850513          	addi	a0,a0,-1384 # 80200c48 <etext+0x134>
    802001b8:	eb9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001bc:	680c                	ld	a1,16(s0)
    802001be:	00001517          	auipc	a0,0x1
    802001c2:	aa250513          	addi	a0,a0,-1374 # 80200c60 <etext+0x14c>
    802001c6:	eabff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001ca:	6c0c                	ld	a1,24(s0)
    802001cc:	00001517          	auipc	a0,0x1
    802001d0:	aac50513          	addi	a0,a0,-1364 # 80200c78 <etext+0x164>
    802001d4:	e9dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d8:	700c                	ld	a1,32(s0)
    802001da:	00001517          	auipc	a0,0x1
    802001de:	ab650513          	addi	a0,a0,-1354 # 80200c90 <etext+0x17c>
    802001e2:	e8fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e6:	740c                	ld	a1,40(s0)
    802001e8:	00001517          	auipc	a0,0x1
    802001ec:	ac050513          	addi	a0,a0,-1344 # 80200ca8 <etext+0x194>
    802001f0:	e81ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001f4:	780c                	ld	a1,48(s0)
    802001f6:	00001517          	auipc	a0,0x1
    802001fa:	aca50513          	addi	a0,a0,-1334 # 80200cc0 <etext+0x1ac>
    802001fe:	e73ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    80200202:	7c0c                	ld	a1,56(s0)
    80200204:	00001517          	auipc	a0,0x1
    80200208:	ad450513          	addi	a0,a0,-1324 # 80200cd8 <etext+0x1c4>
    8020020c:	e65ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200210:	602c                	ld	a1,64(s0)
    80200212:	00001517          	auipc	a0,0x1
    80200216:	ade50513          	addi	a0,a0,-1314 # 80200cf0 <etext+0x1dc>
    8020021a:	e57ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    8020021e:	642c                	ld	a1,72(s0)
    80200220:	00001517          	auipc	a0,0x1
    80200224:	ae850513          	addi	a0,a0,-1304 # 80200d08 <etext+0x1f4>
    80200228:	e49ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    8020022c:	682c                	ld	a1,80(s0)
    8020022e:	00001517          	auipc	a0,0x1
    80200232:	af250513          	addi	a0,a0,-1294 # 80200d20 <etext+0x20c>
    80200236:	e3bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    8020023a:	6c2c                	ld	a1,88(s0)
    8020023c:	00001517          	auipc	a0,0x1
    80200240:	afc50513          	addi	a0,a0,-1284 # 80200d38 <etext+0x224>
    80200244:	e2dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200248:	702c                	ld	a1,96(s0)
    8020024a:	00001517          	auipc	a0,0x1
    8020024e:	b0650513          	addi	a0,a0,-1274 # 80200d50 <etext+0x23c>
    80200252:	e1fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200256:	742c                	ld	a1,104(s0)
    80200258:	00001517          	auipc	a0,0x1
    8020025c:	b1050513          	addi	a0,a0,-1264 # 80200d68 <etext+0x254>
    80200260:	e11ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    80200264:	782c                	ld	a1,112(s0)
    80200266:	00001517          	auipc	a0,0x1
    8020026a:	b1a50513          	addi	a0,a0,-1254 # 80200d80 <etext+0x26c>
    8020026e:	e03ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200272:	7c2c                	ld	a1,120(s0)
    80200274:	00001517          	auipc	a0,0x1
    80200278:	b2450513          	addi	a0,a0,-1244 # 80200d98 <etext+0x284>
    8020027c:	df5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200280:	604c                	ld	a1,128(s0)
    80200282:	00001517          	auipc	a0,0x1
    80200286:	b2e50513          	addi	a0,a0,-1234 # 80200db0 <etext+0x29c>
    8020028a:	de7ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    8020028e:	644c                	ld	a1,136(s0)
    80200290:	00001517          	auipc	a0,0x1
    80200294:	b3850513          	addi	a0,a0,-1224 # 80200dc8 <etext+0x2b4>
    80200298:	dd9ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    8020029c:	684c                	ld	a1,144(s0)
    8020029e:	00001517          	auipc	a0,0x1
    802002a2:	b4250513          	addi	a0,a0,-1214 # 80200de0 <etext+0x2cc>
    802002a6:	dcbff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002aa:	6c4c                	ld	a1,152(s0)
    802002ac:	00001517          	auipc	a0,0x1
    802002b0:	b4c50513          	addi	a0,a0,-1204 # 80200df8 <etext+0x2e4>
    802002b4:	dbdff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b8:	704c                	ld	a1,160(s0)
    802002ba:	00001517          	auipc	a0,0x1
    802002be:	b5650513          	addi	a0,a0,-1194 # 80200e10 <etext+0x2fc>
    802002c2:	dafff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c6:	744c                	ld	a1,168(s0)
    802002c8:	00001517          	auipc	a0,0x1
    802002cc:	b6050513          	addi	a0,a0,-1184 # 80200e28 <etext+0x314>
    802002d0:	da1ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002d4:	784c                	ld	a1,176(s0)
    802002d6:	00001517          	auipc	a0,0x1
    802002da:	b6a50513          	addi	a0,a0,-1174 # 80200e40 <etext+0x32c>
    802002de:	d93ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002e2:	7c4c                	ld	a1,184(s0)
    802002e4:	00001517          	auipc	a0,0x1
    802002e8:	b7450513          	addi	a0,a0,-1164 # 80200e58 <etext+0x344>
    802002ec:	d85ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002f0:	606c                	ld	a1,192(s0)
    802002f2:	00001517          	auipc	a0,0x1
    802002f6:	b7e50513          	addi	a0,a0,-1154 # 80200e70 <etext+0x35c>
    802002fa:	d77ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002fe:	646c                	ld	a1,200(s0)
    80200300:	00001517          	auipc	a0,0x1
    80200304:	b8850513          	addi	a0,a0,-1144 # 80200e88 <etext+0x374>
    80200308:	d69ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    8020030c:	686c                	ld	a1,208(s0)
    8020030e:	00001517          	auipc	a0,0x1
    80200312:	b9250513          	addi	a0,a0,-1134 # 80200ea0 <etext+0x38c>
    80200316:	d5bff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    8020031a:	6c6c                	ld	a1,216(s0)
    8020031c:	00001517          	auipc	a0,0x1
    80200320:	b9c50513          	addi	a0,a0,-1124 # 80200eb8 <etext+0x3a4>
    80200324:	d4dff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200328:	706c                	ld	a1,224(s0)
    8020032a:	00001517          	auipc	a0,0x1
    8020032e:	ba650513          	addi	a0,a0,-1114 # 80200ed0 <etext+0x3bc>
    80200332:	d3fff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200336:	746c                	ld	a1,232(s0)
    80200338:	00001517          	auipc	a0,0x1
    8020033c:	bb050513          	addi	a0,a0,-1104 # 80200ee8 <etext+0x3d4>
    80200340:	d31ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    80200344:	786c                	ld	a1,240(s0)
    80200346:	00001517          	auipc	a0,0x1
    8020034a:	bba50513          	addi	a0,a0,-1094 # 80200f00 <etext+0x3ec>
    8020034e:	d23ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	7c6c                	ld	a1,248(s0)
}
    80200354:	6402                	ld	s0,0(sp)
    80200356:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	00001517          	auipc	a0,0x1
    8020035c:	bc050513          	addi	a0,a0,-1088 # 80200f18 <etext+0x404>
}
    80200360:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200362:	b339                	j	80200070 <cprintf>

0000000080200364 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    80200364:	1141                	addi	sp,sp,-16
    80200366:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200368:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    8020036a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    8020036c:	00001517          	auipc	a0,0x1
    80200370:	bc450513          	addi	a0,a0,-1084 # 80200f30 <etext+0x41c>
void print_trapframe(struct trapframe *tf) {
    80200374:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200376:	cfbff0ef          	jal	ra,80200070 <cprintf>
    print_regs(&tf->gpr);
    8020037a:	8522                	mv	a0,s0
    8020037c:	e1dff0ef          	jal	ra,80200198 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200380:	10043583          	ld	a1,256(s0)
    80200384:	00001517          	auipc	a0,0x1
    80200388:	bc450513          	addi	a0,a0,-1084 # 80200f48 <etext+0x434>
    8020038c:	ce5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200390:	10843583          	ld	a1,264(s0)
    80200394:	00001517          	auipc	a0,0x1
    80200398:	bcc50513          	addi	a0,a0,-1076 # 80200f60 <etext+0x44c>
    8020039c:	cd5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    802003a0:	11043583          	ld	a1,272(s0)
    802003a4:	00001517          	auipc	a0,0x1
    802003a8:	bd450513          	addi	a0,a0,-1068 # 80200f78 <etext+0x464>
    802003ac:	cc5ff0ef          	jal	ra,80200070 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	11843583          	ld	a1,280(s0)
}
    802003b4:	6402                	ld	s0,0(sp)
    802003b6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b8:	00001517          	auipc	a0,0x1
    802003bc:	bd850513          	addi	a0,a0,-1064 # 80200f90 <etext+0x47c>
}
    802003c0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003c2:	b17d                	j	80200070 <cprintf>

00000000802003c4 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c4:	11853783          	ld	a5,280(a0)
    802003c8:	472d                	li	a4,11
    802003ca:	0786                	slli	a5,a5,0x1
    802003cc:	8385                	srli	a5,a5,0x1
    802003ce:	06f76863          	bltu	a4,a5,8020043e <interrupt_handler+0x7a>
    802003d2:	00001717          	auipc	a4,0x1
    802003d6:	c8670713          	addi	a4,a4,-890 # 80201058 <etext+0x544>
    802003da:	078a                	slli	a5,a5,0x2
    802003dc:	97ba                	add	a5,a5,a4
    802003de:	439c                	lw	a5,0(a5)
    802003e0:	97ba                	add	a5,a5,a4
    802003e2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	c2450513          	addi	a0,a0,-988 # 80201008 <etext+0x4f4>
    802003ec:	b151                	j	80200070 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	bfa50513          	addi	a0,a0,-1030 # 80200fe8 <etext+0x4d4>
    802003f6:	b9ad                	j	80200070 <cprintf>
            cprintf("User software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	bb050513          	addi	a0,a0,-1104 # 80200fa8 <etext+0x494>
    80200400:	b985                	j	80200070 <cprintf>
            cprintf("Supervisor software interrupt\n");
    80200402:	00001517          	auipc	a0,0x1
    80200406:	bc650513          	addi	a0,a0,-1082 # 80200fc8 <etext+0x4b4>
    8020040a:	b19d                	j	80200070 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040c:	1141                	addi	sp,sp,-16
    8020040e:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
    80200410:	d57ff0ef          	jal	ra,80200166 <clock_set_next_event>
            ticks++;
    80200414:	00004797          	auipc	a5,0x4
    80200418:	bfc78793          	addi	a5,a5,-1028 # 80204010 <ticks>
    8020041c:	6398                	ld	a4,0(a5)
    8020041e:	0705                	addi	a4,a4,1
    80200420:	e398                	sd	a4,0(a5)
            if(ticks % TICK_NUM == 0)
    80200422:	639c                	ld	a5,0(a5)
    80200424:	06400713          	li	a4,100
    80200428:	02e7f7b3          	remu	a5,a5,a4
    8020042c:	cb91                	beqz	a5,80200440 <interrupt_handler+0x7c>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020042e:	60a2                	ld	ra,8(sp)
    80200430:	0141                	addi	sp,sp,16
    80200432:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200434:	00001517          	auipc	a0,0x1
    80200438:	c0450513          	addi	a0,a0,-1020 # 80201038 <etext+0x524>
    8020043c:	b915                	j	80200070 <cprintf>
            print_trapframe(tf);
    8020043e:	b71d                	j	80200364 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200440:	06400593          	li	a1,100
    80200444:	00001517          	auipc	a0,0x1
    80200448:	be450513          	addi	a0,a0,-1052 # 80201028 <etext+0x514>
    8020044c:	c25ff0ef          	jal	ra,80200070 <cprintf>
                if(++num == 10)
    80200450:	00004717          	auipc	a4,0x4
    80200454:	bc870713          	addi	a4,a4,-1080 # 80204018 <num>
    80200458:	631c                	ld	a5,0(a4)
    8020045a:	46a9                	li	a3,10
    8020045c:	0785                	addi	a5,a5,1
    8020045e:	e31c                	sd	a5,0(a4)
    80200460:	fcd797e3          	bne	a5,a3,8020042e <interrupt_handler+0x6a>
}
    80200464:	60a2                	ld	ra,8(sp)
    80200466:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    80200468:	a595                	j	80200acc <sbi_shutdown>

000000008020046a <exception_handler>:

#include <stdio.h>

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020046a:	11853783          	ld	a5,280(a0)
    8020046e:	472d                	li	a4,11
    80200470:	16f76a63          	bltu	a4,a5,802005e4 <exception_handler+0x17a>
    80200474:	00001717          	auipc	a4,0x1
    80200478:	eb470713          	addi	a4,a4,-332 # 80201328 <etext+0x814>
    8020047c:	078a                	slli	a5,a5,0x2
    8020047e:	97ba                	add	a5,a5,a4
    80200480:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
    80200482:	1141                	addi	sp,sp,-16
    80200484:	e022                	sd	s0,0(sp)
    80200486:	97ba                	add	a5,a5,a4
    80200488:	e406                	sd	ra,8(sp)
    8020048a:	842a                	mv	s0,a0
    8020048c:	8782                	jr	a5
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Exception type: Supervisor ecall\n");
            cprintf("Supervisor call at: 0x%x\n", tf->epc);
            break;
        case CAUSE_HYPERVISOR_ECALL:
            cprintf("Exception type: Hypervisor ecall\n");
    8020048e:	00001517          	auipc	a0,0x1
    80200492:	e1a50513          	addi	a0,a0,-486 # 802012a8 <etext+0x794>
    80200496:	bdbff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Hypervisor call at: 0x%x\n", tf->epc);
    8020049a:	10843583          	ld	a1,264(s0)
    8020049e:	00001517          	auipc	a0,0x1
    802004a2:	e3250513          	addi	a0,a0,-462 # 802012d0 <etext+0x7bc>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004a6:	6402                	ld	s0,0(sp)
    802004a8:	60a2                	ld	ra,8(sp)
    802004aa:	0141                	addi	sp,sp,16
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004ac:	b6d1                	j	80200070 <cprintf>
            cprintf("Exception type: Machine ecall\n");
    802004ae:	00001517          	auipc	a0,0x1
    802004b2:	e4250513          	addi	a0,a0,-446 # 802012f0 <etext+0x7dc>
    802004b6:	bbbff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Machine call at: 0x%x\n", tf->epc);
    802004ba:	10843583          	ld	a1,264(s0)
    802004be:	00001517          	auipc	a0,0x1
    802004c2:	e5250513          	addi	a0,a0,-430 # 80201310 <etext+0x7fc>
    802004c6:	b7c5                	j	802004a6 <exception_handler+0x3c>
            cprintf("Exception type: Misaligned fetch\n");
    802004c8:	00001517          	auipc	a0,0x1
    802004cc:	bc050513          	addi	a0,a0,-1088 # 80201088 <etext+0x574>
            cprintf("Exception type: Fault fetch\n");
    802004d0:	ba1ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004d4:	10843583          	ld	a1,264(s0)
}
    802004d8:	6402                	ld	s0,0(sp)
    802004da:	60a2                	ld	ra,8(sp)
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004dc:	00001517          	auipc	a0,0x1
    802004e0:	bd450513          	addi	a0,a0,-1068 # 802010b0 <etext+0x59c>
}
    802004e4:	0141                	addi	sp,sp,16
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004e6:	b669                	j	80200070 <cprintf>
            cprintf("Exception type: Fault fetch\n");
    802004e8:	00001517          	auipc	a0,0x1
    802004ec:	bf050513          	addi	a0,a0,-1040 # 802010d8 <etext+0x5c4>
    802004f0:	b7c5                	j	802004d0 <exception_handler+0x66>
            cprintf("Exception type: Illegal instruction\n");
    802004f2:	00001517          	auipc	a0,0x1
    802004f6:	c0650513          	addi	a0,a0,-1018 # 802010f8 <etext+0x5e4>
    802004fa:	b77ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Illegal instruction caught at 0x%x\n", tf->epc);
    802004fe:	10843583          	ld	a1,264(s0)
    80200502:	00001517          	auipc	a0,0x1
    80200506:	c1e50513          	addi	a0,a0,-994 # 80201120 <etext+0x60c>
    8020050a:	b67ff0ef          	jal	ra,80200070 <cprintf>
            tf->epc += 4; // 更新epc
    8020050e:	10843783          	ld	a5,264(s0)
    80200512:	0791                	addi	a5,a5,4
    80200514:	10f43423          	sd	a5,264(s0)
}
    80200518:	60a2                	ld	ra,8(sp)
    8020051a:	6402                	ld	s0,0(sp)
    8020051c:	0141                	addi	sp,sp,16
    8020051e:	8082                	ret
            cprintf("Exception type: Breakpoint\n");
    80200520:	00001517          	auipc	a0,0x1
    80200524:	c2850513          	addi	a0,a0,-984 # 80201148 <etext+0x634>
    80200528:	b49ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("ebreak caught at 0x%x\n", tf->epc);
    8020052c:	10843583          	ld	a1,264(s0)
    80200530:	00001517          	auipc	a0,0x1
    80200534:	c3850513          	addi	a0,a0,-968 # 80201168 <etext+0x654>
    80200538:	b39ff0ef          	jal	ra,80200070 <cprintf>
            tf->epc += 2; // 更新epc
    8020053c:	10843783          	ld	a5,264(s0)
    80200540:	0789                	addi	a5,a5,2
    80200542:	10f43423          	sd	a5,264(s0)
            break;
    80200546:	bfc9                	j	80200518 <exception_handler+0xae>
            cprintf("Exception type: Misaligned load\n");
    80200548:	00001517          	auipc	a0,0x1
    8020054c:	c3850513          	addi	a0,a0,-968 # 80201180 <etext+0x66c>
    80200550:	b21ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    80200554:	10843583          	ld	a1,264(s0)
    80200558:	00001517          	auipc	a0,0x1
    8020055c:	c5050513          	addi	a0,a0,-944 # 802011a8 <etext+0x694>
    80200560:	b799                	j	802004a6 <exception_handler+0x3c>
            cprintf("Exception type: Fault load\n");
    80200562:	00001517          	auipc	a0,0x1
    80200566:	c5e50513          	addi	a0,a0,-930 # 802011c0 <etext+0x6ac>
    8020056a:	b07ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    8020056e:	10843583          	ld	a1,264(s0)
    80200572:	00001517          	auipc	a0,0x1
    80200576:	c3650513          	addi	a0,a0,-970 # 802011a8 <etext+0x694>
    8020057a:	b735                	j	802004a6 <exception_handler+0x3c>
            cprintf("Exception type: Misaligned store\n");
    8020057c:	00001517          	auipc	a0,0x1
    80200580:	c6450513          	addi	a0,a0,-924 # 802011e0 <etext+0x6cc>
    80200584:	aedff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    80200588:	10843583          	ld	a1,264(s0)
    8020058c:	00001517          	auipc	a0,0x1
    80200590:	c1c50513          	addi	a0,a0,-996 # 802011a8 <etext+0x694>
    80200594:	bf09                	j	802004a6 <exception_handler+0x3c>
            cprintf("Exception type: Fault store\n");
    80200596:	00001517          	auipc	a0,0x1
    8020059a:	c7250513          	addi	a0,a0,-910 # 80201208 <etext+0x6f4>
    8020059e:	ad3ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    802005a2:	10843583          	ld	a1,264(s0)
    802005a6:	00001517          	auipc	a0,0x1
    802005aa:	c0250513          	addi	a0,a0,-1022 # 802011a8 <etext+0x694>
    802005ae:	bde5                	j	802004a6 <exception_handler+0x3c>
            cprintf("Exception type: User ecall\n");
    802005b0:	00001517          	auipc	a0,0x1
    802005b4:	c7850513          	addi	a0,a0,-904 # 80201228 <etext+0x714>
    802005b8:	ab9ff0ef          	jal	ra,80200070 <cprintf>
            cprintf("User call at: 0x%x\n", tf->epc);
    802005bc:	10843583          	ld	a1,264(s0)
    802005c0:	00001517          	auipc	a0,0x1
    802005c4:	c8850513          	addi	a0,a0,-888 # 80201248 <etext+0x734>
    802005c8:	bdf9                	j	802004a6 <exception_handler+0x3c>
            cprintf("Exception type: Supervisor ecall\n");
    802005ca:	00001517          	auipc	a0,0x1
    802005ce:	c9650513          	addi	a0,a0,-874 # 80201260 <etext+0x74c>
    802005d2:	a9fff0ef          	jal	ra,80200070 <cprintf>
            cprintf("Supervisor call at: 0x%x\n", tf->epc);
    802005d6:	10843583          	ld	a1,264(s0)
    802005da:	00001517          	auipc	a0,0x1
    802005de:	cae50513          	addi	a0,a0,-850 # 80201288 <etext+0x774>
    802005e2:	b5d1                	j	802004a6 <exception_handler+0x3c>
            print_trapframe(tf);
    802005e4:	b341                	j	80200364 <print_trapframe>

00000000802005e6 <trap>:


/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802005e6:	11853783          	ld	a5,280(a0)
    802005ea:	0007c363          	bltz	a5,802005f0 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802005ee:	bdb5                	j	8020046a <exception_handler>
        interrupt_handler(tf);
    802005f0:	bbd1                	j	802003c4 <interrupt_handler>
	...

00000000802005f4 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802005f4:	14011073          	csrw	sscratch,sp
    802005f8:	712d                	addi	sp,sp,-288
    802005fa:	e002                	sd	zero,0(sp)
    802005fc:	e406                	sd	ra,8(sp)
    802005fe:	ec0e                	sd	gp,24(sp)
    80200600:	f012                	sd	tp,32(sp)
    80200602:	f416                	sd	t0,40(sp)
    80200604:	f81a                	sd	t1,48(sp)
    80200606:	fc1e                	sd	t2,56(sp)
    80200608:	e0a2                	sd	s0,64(sp)
    8020060a:	e4a6                	sd	s1,72(sp)
    8020060c:	e8aa                	sd	a0,80(sp)
    8020060e:	ecae                	sd	a1,88(sp)
    80200610:	f0b2                	sd	a2,96(sp)
    80200612:	f4b6                	sd	a3,104(sp)
    80200614:	f8ba                	sd	a4,112(sp)
    80200616:	fcbe                	sd	a5,120(sp)
    80200618:	e142                	sd	a6,128(sp)
    8020061a:	e546                	sd	a7,136(sp)
    8020061c:	e94a                	sd	s2,144(sp)
    8020061e:	ed4e                	sd	s3,152(sp)
    80200620:	f152                	sd	s4,160(sp)
    80200622:	f556                	sd	s5,168(sp)
    80200624:	f95a                	sd	s6,176(sp)
    80200626:	fd5e                	sd	s7,184(sp)
    80200628:	e1e2                	sd	s8,192(sp)
    8020062a:	e5e6                	sd	s9,200(sp)
    8020062c:	e9ea                	sd	s10,208(sp)
    8020062e:	edee                	sd	s11,216(sp)
    80200630:	f1f2                	sd	t3,224(sp)
    80200632:	f5f6                	sd	t4,232(sp)
    80200634:	f9fa                	sd	t5,240(sp)
    80200636:	fdfe                	sd	t6,248(sp)
    80200638:	14001473          	csrrw	s0,sscratch,zero
    8020063c:	100024f3          	csrr	s1,sstatus
    80200640:	14102973          	csrr	s2,sepc
    80200644:	143029f3          	csrr	s3,stval
    80200648:	14202a73          	csrr	s4,scause
    8020064c:	e822                	sd	s0,16(sp)
    8020064e:	e226                	sd	s1,256(sp)
    80200650:	e64a                	sd	s2,264(sp)
    80200652:	ea4e                	sd	s3,272(sp)
    80200654:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200656:	850a                	mv	a0,sp
    jal trap
    80200658:	f8fff0ef          	jal	ra,802005e6 <trap>

000000008020065c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020065c:	6492                	ld	s1,256(sp)
    8020065e:	6932                	ld	s2,264(sp)
    80200660:	10049073          	csrw	sstatus,s1
    80200664:	14191073          	csrw	sepc,s2
    80200668:	60a2                	ld	ra,8(sp)
    8020066a:	61e2                	ld	gp,24(sp)
    8020066c:	7202                	ld	tp,32(sp)
    8020066e:	72a2                	ld	t0,40(sp)
    80200670:	7342                	ld	t1,48(sp)
    80200672:	73e2                	ld	t2,56(sp)
    80200674:	6406                	ld	s0,64(sp)
    80200676:	64a6                	ld	s1,72(sp)
    80200678:	6546                	ld	a0,80(sp)
    8020067a:	65e6                	ld	a1,88(sp)
    8020067c:	7606                	ld	a2,96(sp)
    8020067e:	76a6                	ld	a3,104(sp)
    80200680:	7746                	ld	a4,112(sp)
    80200682:	77e6                	ld	a5,120(sp)
    80200684:	680a                	ld	a6,128(sp)
    80200686:	68aa                	ld	a7,136(sp)
    80200688:	694a                	ld	s2,144(sp)
    8020068a:	69ea                	ld	s3,152(sp)
    8020068c:	7a0a                	ld	s4,160(sp)
    8020068e:	7aaa                	ld	s5,168(sp)
    80200690:	7b4a                	ld	s6,176(sp)
    80200692:	7bea                	ld	s7,184(sp)
    80200694:	6c0e                	ld	s8,192(sp)
    80200696:	6cae                	ld	s9,200(sp)
    80200698:	6d4e                	ld	s10,208(sp)
    8020069a:	6dee                	ld	s11,216(sp)
    8020069c:	7e0e                	ld	t3,224(sp)
    8020069e:	7eae                	ld	t4,232(sp)
    802006a0:	7f4e                	ld	t5,240(sp)
    802006a2:	7fee                	ld	t6,248(sp)
    802006a4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802006a6:	10200073          	sret

00000000802006aa <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802006aa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802006ae:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802006b0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802006b4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802006b6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802006ba:	f022                	sd	s0,32(sp)
    802006bc:	ec26                	sd	s1,24(sp)
    802006be:	e84a                	sd	s2,16(sp)
    802006c0:	f406                	sd	ra,40(sp)
    802006c2:	e44e                	sd	s3,8(sp)
    802006c4:	84aa                	mv	s1,a0
    802006c6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802006c8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802006cc:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802006ce:	03067e63          	bgeu	a2,a6,8020070a <printnum+0x60>
    802006d2:	89be                	mv	s3,a5
        while (-- width > 0)
    802006d4:	00805763          	blez	s0,802006e2 <printnum+0x38>
    802006d8:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802006da:	85ca                	mv	a1,s2
    802006dc:	854e                	mv	a0,s3
    802006de:	9482                	jalr	s1
        while (-- width > 0)
    802006e0:	fc65                	bnez	s0,802006d8 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802006e2:	1a02                	slli	s4,s4,0x20
    802006e4:	00001797          	auipc	a5,0x1
    802006e8:	c7478793          	addi	a5,a5,-908 # 80201358 <etext+0x844>
    802006ec:	020a5a13          	srli	s4,s4,0x20
    802006f0:	9a3e                	add	s4,s4,a5
}
    802006f2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802006f4:	000a4503          	lbu	a0,0(s4)
}
    802006f8:	70a2                	ld	ra,40(sp)
    802006fa:	69a2                	ld	s3,8(sp)
    802006fc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802006fe:	85ca                	mv	a1,s2
    80200700:	87a6                	mv	a5,s1
}
    80200702:	6942                	ld	s2,16(sp)
    80200704:	64e2                	ld	s1,24(sp)
    80200706:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200708:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    8020070a:	03065633          	divu	a2,a2,a6
    8020070e:	8722                	mv	a4,s0
    80200710:	f9bff0ef          	jal	ra,802006aa <printnum>
    80200714:	b7f9                	j	802006e2 <printnum+0x38>

0000000080200716 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200716:	7119                	addi	sp,sp,-128
    80200718:	f4a6                	sd	s1,104(sp)
    8020071a:	f0ca                	sd	s2,96(sp)
    8020071c:	ecce                	sd	s3,88(sp)
    8020071e:	e8d2                	sd	s4,80(sp)
    80200720:	e4d6                	sd	s5,72(sp)
    80200722:	e0da                	sd	s6,64(sp)
    80200724:	fc5e                	sd	s7,56(sp)
    80200726:	f06a                	sd	s10,32(sp)
    80200728:	fc86                	sd	ra,120(sp)
    8020072a:	f8a2                	sd	s0,112(sp)
    8020072c:	f862                	sd	s8,48(sp)
    8020072e:	f466                	sd	s9,40(sp)
    80200730:	ec6e                	sd	s11,24(sp)
    80200732:	892a                	mv	s2,a0
    80200734:	84ae                	mv	s1,a1
    80200736:	8d32                	mv	s10,a2
    80200738:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020073a:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020073e:	5b7d                	li	s6,-1
    80200740:	00001a97          	auipc	s5,0x1
    80200744:	c4ca8a93          	addi	s5,s5,-948 # 8020138c <etext+0x878>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200748:	00001b97          	auipc	s7,0x1
    8020074c:	e20b8b93          	addi	s7,s7,-480 # 80201568 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200750:	000d4503          	lbu	a0,0(s10)
    80200754:	001d0413          	addi	s0,s10,1
    80200758:	01350a63          	beq	a0,s3,8020076c <vprintfmt+0x56>
            if (ch == '\0') {
    8020075c:	c121                	beqz	a0,8020079c <vprintfmt+0x86>
            putch(ch, putdat);
    8020075e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200760:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200762:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200764:	fff44503          	lbu	a0,-1(s0)
    80200768:	ff351ae3          	bne	a0,s3,8020075c <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    8020076c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200770:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200774:	4c81                	li	s9,0
    80200776:	4881                	li	a7,0
        width = precision = -1;
    80200778:	5c7d                	li	s8,-1
    8020077a:	5dfd                	li	s11,-1
    8020077c:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    80200780:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200782:	fdd6059b          	addiw	a1,a2,-35
    80200786:	0ff5f593          	zext.b	a1,a1
    8020078a:	00140d13          	addi	s10,s0,1
    8020078e:	04b56263          	bltu	a0,a1,802007d2 <vprintfmt+0xbc>
    80200792:	058a                	slli	a1,a1,0x2
    80200794:	95d6                	add	a1,a1,s5
    80200796:	4194                	lw	a3,0(a1)
    80200798:	96d6                	add	a3,a3,s5
    8020079a:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020079c:	70e6                	ld	ra,120(sp)
    8020079e:	7446                	ld	s0,112(sp)
    802007a0:	74a6                	ld	s1,104(sp)
    802007a2:	7906                	ld	s2,96(sp)
    802007a4:	69e6                	ld	s3,88(sp)
    802007a6:	6a46                	ld	s4,80(sp)
    802007a8:	6aa6                	ld	s5,72(sp)
    802007aa:	6b06                	ld	s6,64(sp)
    802007ac:	7be2                	ld	s7,56(sp)
    802007ae:	7c42                	ld	s8,48(sp)
    802007b0:	7ca2                	ld	s9,40(sp)
    802007b2:	7d02                	ld	s10,32(sp)
    802007b4:	6de2                	ld	s11,24(sp)
    802007b6:	6109                	addi	sp,sp,128
    802007b8:	8082                	ret
            padc = '0';
    802007ba:	87b2                	mv	a5,a2
            goto reswitch;
    802007bc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802007c0:	846a                	mv	s0,s10
    802007c2:	00140d13          	addi	s10,s0,1
    802007c6:	fdd6059b          	addiw	a1,a2,-35
    802007ca:	0ff5f593          	zext.b	a1,a1
    802007ce:	fcb572e3          	bgeu	a0,a1,80200792 <vprintfmt+0x7c>
            putch('%', putdat);
    802007d2:	85a6                	mv	a1,s1
    802007d4:	02500513          	li	a0,37
    802007d8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802007da:	fff44783          	lbu	a5,-1(s0)
    802007de:	8d22                	mv	s10,s0
    802007e0:	f73788e3          	beq	a5,s3,80200750 <vprintfmt+0x3a>
    802007e4:	ffed4783          	lbu	a5,-2(s10)
    802007e8:	1d7d                	addi	s10,s10,-1
    802007ea:	ff379de3          	bne	a5,s3,802007e4 <vprintfmt+0xce>
    802007ee:	b78d                	j	80200750 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802007f0:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802007f4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802007f8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802007fa:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802007fe:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200802:	02d86463          	bltu	a6,a3,8020082a <vprintfmt+0x114>
                ch = *fmt;
    80200806:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    8020080a:	002c169b          	slliw	a3,s8,0x2
    8020080e:	0186873b          	addw	a4,a3,s8
    80200812:	0017171b          	slliw	a4,a4,0x1
    80200816:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200818:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    8020081c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020081e:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    80200822:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200826:	fed870e3          	bgeu	a6,a3,80200806 <vprintfmt+0xf0>
            if (width < 0)
    8020082a:	f40ddce3          	bgez	s11,80200782 <vprintfmt+0x6c>
                width = precision, precision = -1;
    8020082e:	8de2                	mv	s11,s8
    80200830:	5c7d                	li	s8,-1
    80200832:	bf81                	j	80200782 <vprintfmt+0x6c>
            if (width < 0)
    80200834:	fffdc693          	not	a3,s11
    80200838:	96fd                	srai	a3,a3,0x3f
    8020083a:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    8020083e:	00144603          	lbu	a2,1(s0)
    80200842:	2d81                	sext.w	s11,s11
    80200844:	846a                	mv	s0,s10
            goto reswitch;
    80200846:	bf35                	j	80200782 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200848:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    8020084c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    80200850:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    80200852:	846a                	mv	s0,s10
            goto process_precision;
    80200854:	bfd9                	j	8020082a <vprintfmt+0x114>
    if (lflag >= 2) {
    80200856:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200858:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    8020085c:	01174463          	blt	a4,a7,80200864 <vprintfmt+0x14e>
    else if (lflag) {
    80200860:	1a088e63          	beqz	a7,80200a1c <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    80200864:	000a3603          	ld	a2,0(s4)
    80200868:	46c1                	li	a3,16
    8020086a:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    8020086c:	2781                	sext.w	a5,a5
    8020086e:	876e                	mv	a4,s11
    80200870:	85a6                	mv	a1,s1
    80200872:	854a                	mv	a0,s2
    80200874:	e37ff0ef          	jal	ra,802006aa <printnum>
            break;
    80200878:	bde1                	j	80200750 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    8020087a:	000a2503          	lw	a0,0(s4)
    8020087e:	85a6                	mv	a1,s1
    80200880:	0a21                	addi	s4,s4,8
    80200882:	9902                	jalr	s2
            break;
    80200884:	b5f1                	j	80200750 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200886:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200888:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    8020088c:	01174463          	blt	a4,a7,80200894 <vprintfmt+0x17e>
    else if (lflag) {
    80200890:	18088163          	beqz	a7,80200a12 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    80200894:	000a3603          	ld	a2,0(s4)
    80200898:	46a9                	li	a3,10
    8020089a:	8a2e                	mv	s4,a1
    8020089c:	bfc1                	j	8020086c <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    8020089e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    802008a2:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802008a4:	846a                	mv	s0,s10
            goto reswitch;
    802008a6:	bdf1                	j	80200782 <vprintfmt+0x6c>
            putch(ch, putdat);
    802008a8:	85a6                	mv	a1,s1
    802008aa:	02500513          	li	a0,37
    802008ae:	9902                	jalr	s2
            break;
    802008b0:	b545                	j	80200750 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802008b2:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802008b6:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802008b8:	846a                	mv	s0,s10
            goto reswitch;
    802008ba:	b5e1                	j	80200782 <vprintfmt+0x6c>
    if (lflag >= 2) {
    802008bc:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802008be:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802008c2:	01174463          	blt	a4,a7,802008ca <vprintfmt+0x1b4>
    else if (lflag) {
    802008c6:	14088163          	beqz	a7,80200a08 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802008ca:	000a3603          	ld	a2,0(s4)
    802008ce:	46a1                	li	a3,8
    802008d0:	8a2e                	mv	s4,a1
    802008d2:	bf69                	j	8020086c <vprintfmt+0x156>
            putch('0', putdat);
    802008d4:	03000513          	li	a0,48
    802008d8:	85a6                	mv	a1,s1
    802008da:	e03e                	sd	a5,0(sp)
    802008dc:	9902                	jalr	s2
            putch('x', putdat);
    802008de:	85a6                	mv	a1,s1
    802008e0:	07800513          	li	a0,120
    802008e4:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802008e6:	0a21                	addi	s4,s4,8
            goto number;
    802008e8:	6782                	ld	a5,0(sp)
    802008ea:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    802008ec:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    802008f0:	bfb5                	j	8020086c <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    802008f2:	000a3403          	ld	s0,0(s4)
    802008f6:	008a0713          	addi	a4,s4,8
    802008fa:	e03a                	sd	a4,0(sp)
    802008fc:	14040263          	beqz	s0,80200a40 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    80200900:	0fb05763          	blez	s11,802009ee <vprintfmt+0x2d8>
    80200904:	02d00693          	li	a3,45
    80200908:	0cd79163          	bne	a5,a3,802009ca <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020090c:	00044783          	lbu	a5,0(s0)
    80200910:	0007851b          	sext.w	a0,a5
    80200914:	cf85                	beqz	a5,8020094c <vprintfmt+0x236>
    80200916:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020091a:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020091e:	000c4563          	bltz	s8,80200928 <vprintfmt+0x212>
    80200922:	3c7d                	addiw	s8,s8,-1
    80200924:	036c0263          	beq	s8,s6,80200948 <vprintfmt+0x232>
                    putch('?', putdat);
    80200928:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    8020092a:	0e0c8e63          	beqz	s9,80200a26 <vprintfmt+0x310>
    8020092e:	3781                	addiw	a5,a5,-32
    80200930:	0ef47b63          	bgeu	s0,a5,80200a26 <vprintfmt+0x310>
                    putch('?', putdat);
    80200934:	03f00513          	li	a0,63
    80200938:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020093a:	000a4783          	lbu	a5,0(s4)
    8020093e:	3dfd                	addiw	s11,s11,-1
    80200940:	0a05                	addi	s4,s4,1
    80200942:	0007851b          	sext.w	a0,a5
    80200946:	ffe1                	bnez	a5,8020091e <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200948:	01b05963          	blez	s11,8020095a <vprintfmt+0x244>
    8020094c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020094e:	85a6                	mv	a1,s1
    80200950:	02000513          	li	a0,32
    80200954:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200956:	fe0d9be3          	bnez	s11,8020094c <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020095a:	6a02                	ld	s4,0(sp)
    8020095c:	bbd5                	j	80200750 <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020095e:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200960:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    80200964:	01174463          	blt	a4,a7,8020096c <vprintfmt+0x256>
    else if (lflag) {
    80200968:	08088d63          	beqz	a7,80200a02 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    8020096c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200970:	0a044d63          	bltz	s0,80200a2a <vprintfmt+0x314>
            num = getint(&ap, lflag);
    80200974:	8622                	mv	a2,s0
    80200976:	8a66                	mv	s4,s9
    80200978:	46a9                	li	a3,10
    8020097a:	bdcd                	j	8020086c <vprintfmt+0x156>
            err = va_arg(ap, int);
    8020097c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200980:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200982:	0a21                	addi	s4,s4,8
            if (err < 0) {
    80200984:	41f7d69b          	sraiw	a3,a5,0x1f
    80200988:	8fb5                	xor	a5,a5,a3
    8020098a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020098e:	02d74163          	blt	a4,a3,802009b0 <vprintfmt+0x29a>
    80200992:	00369793          	slli	a5,a3,0x3
    80200996:	97de                	add	a5,a5,s7
    80200998:	639c                	ld	a5,0(a5)
    8020099a:	cb99                	beqz	a5,802009b0 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    8020099c:	86be                	mv	a3,a5
    8020099e:	00001617          	auipc	a2,0x1
    802009a2:	9ea60613          	addi	a2,a2,-1558 # 80201388 <etext+0x874>
    802009a6:	85a6                	mv	a1,s1
    802009a8:	854a                	mv	a0,s2
    802009aa:	0ce000ef          	jal	ra,80200a78 <printfmt>
    802009ae:	b34d                	j	80200750 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802009b0:	00001617          	auipc	a2,0x1
    802009b4:	9c860613          	addi	a2,a2,-1592 # 80201378 <etext+0x864>
    802009b8:	85a6                	mv	a1,s1
    802009ba:	854a                	mv	a0,s2
    802009bc:	0bc000ef          	jal	ra,80200a78 <printfmt>
    802009c0:	bb41                	j	80200750 <vprintfmt+0x3a>
                p = "(null)";
    802009c2:	00001417          	auipc	s0,0x1
    802009c6:	9ae40413          	addi	s0,s0,-1618 # 80201370 <etext+0x85c>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009ca:	85e2                	mv	a1,s8
    802009cc:	8522                	mv	a0,s0
    802009ce:	e43e                	sd	a5,8(sp)
    802009d0:	116000ef          	jal	ra,80200ae6 <strnlen>
    802009d4:	40ad8dbb          	subw	s11,s11,a0
    802009d8:	01b05b63          	blez	s11,802009ee <vprintfmt+0x2d8>
                    putch(padc, putdat);
    802009dc:	67a2                	ld	a5,8(sp)
    802009de:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009e2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802009e4:	85a6                	mv	a1,s1
    802009e6:	8552                	mv	a0,s4
    802009e8:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009ea:	fe0d9ce3          	bnez	s11,802009e2 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009ee:	00044783          	lbu	a5,0(s0)
    802009f2:	00140a13          	addi	s4,s0,1
    802009f6:	0007851b          	sext.w	a0,a5
    802009fa:	d3a5                	beqz	a5,8020095a <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    802009fc:	05e00413          	li	s0,94
    80200a00:	bf39                	j	8020091e <vprintfmt+0x208>
        return va_arg(*ap, int);
    80200a02:	000a2403          	lw	s0,0(s4)
    80200a06:	b7ad                	j	80200970 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200a08:	000a6603          	lwu	a2,0(s4)
    80200a0c:	46a1                	li	a3,8
    80200a0e:	8a2e                	mv	s4,a1
    80200a10:	bdb1                	j	8020086c <vprintfmt+0x156>
    80200a12:	000a6603          	lwu	a2,0(s4)
    80200a16:	46a9                	li	a3,10
    80200a18:	8a2e                	mv	s4,a1
    80200a1a:	bd89                	j	8020086c <vprintfmt+0x156>
    80200a1c:	000a6603          	lwu	a2,0(s4)
    80200a20:	46c1                	li	a3,16
    80200a22:	8a2e                	mv	s4,a1
    80200a24:	b5a1                	j	8020086c <vprintfmt+0x156>
                    putch(ch, putdat);
    80200a26:	9902                	jalr	s2
    80200a28:	bf09                	j	8020093a <vprintfmt+0x224>
                putch('-', putdat);
    80200a2a:	85a6                	mv	a1,s1
    80200a2c:	02d00513          	li	a0,45
    80200a30:	e03e                	sd	a5,0(sp)
    80200a32:	9902                	jalr	s2
                num = -(long long)num;
    80200a34:	6782                	ld	a5,0(sp)
    80200a36:	8a66                	mv	s4,s9
    80200a38:	40800633          	neg	a2,s0
    80200a3c:	46a9                	li	a3,10
    80200a3e:	b53d                	j	8020086c <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200a40:	03b05163          	blez	s11,80200a62 <vprintfmt+0x34c>
    80200a44:	02d00693          	li	a3,45
    80200a48:	f6d79de3          	bne	a5,a3,802009c2 <vprintfmt+0x2ac>
                p = "(null)";
    80200a4c:	00001417          	auipc	s0,0x1
    80200a50:	92440413          	addi	s0,s0,-1756 # 80201370 <etext+0x85c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200a54:	02800793          	li	a5,40
    80200a58:	02800513          	li	a0,40
    80200a5c:	00140a13          	addi	s4,s0,1
    80200a60:	bd6d                	j	8020091a <vprintfmt+0x204>
    80200a62:	00001a17          	auipc	s4,0x1
    80200a66:	90fa0a13          	addi	s4,s4,-1777 # 80201371 <etext+0x85d>
    80200a6a:	02800513          	li	a0,40
    80200a6e:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    80200a72:	05e00413          	li	s0,94
    80200a76:	b565                	j	8020091e <vprintfmt+0x208>

0000000080200a78 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a78:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200a7a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a7e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a80:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a82:	ec06                	sd	ra,24(sp)
    80200a84:	f83a                	sd	a4,48(sp)
    80200a86:	fc3e                	sd	a5,56(sp)
    80200a88:	e0c2                	sd	a6,64(sp)
    80200a8a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200a8c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a8e:	c89ff0ef          	jal	ra,80200716 <vprintfmt>
}
    80200a92:	60e2                	ld	ra,24(sp)
    80200a94:	6161                	addi	sp,sp,80
    80200a96:	8082                	ret

0000000080200a98 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200a98:	4781                	li	a5,0
    80200a9a:	00003717          	auipc	a4,0x3
    80200a9e:	56673703          	ld	a4,1382(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    80200aa2:	88ba                	mv	a7,a4
    80200aa4:	852a                	mv	a0,a0
    80200aa6:	85be                	mv	a1,a5
    80200aa8:	863e                	mv	a2,a5
    80200aaa:	00000073          	ecall
    80200aae:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200ab0:	8082                	ret

0000000080200ab2 <sbi_set_timer>:
    __asm__ volatile (
    80200ab2:	4781                	li	a5,0
    80200ab4:	00003717          	auipc	a4,0x3
    80200ab8:	56c73703          	ld	a4,1388(a4) # 80204020 <SBI_SET_TIMER>
    80200abc:	88ba                	mv	a7,a4
    80200abe:	852a                	mv	a0,a0
    80200ac0:	85be                	mv	a1,a5
    80200ac2:	863e                	mv	a2,a5
    80200ac4:	00000073          	ecall
    80200ac8:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200aca:	8082                	ret

0000000080200acc <sbi_shutdown>:
    __asm__ volatile (
    80200acc:	4781                	li	a5,0
    80200ace:	00003717          	auipc	a4,0x3
    80200ad2:	53a73703          	ld	a4,1338(a4) # 80204008 <SBI_SHUTDOWN>
    80200ad6:	88ba                	mv	a7,a4
    80200ad8:	853e                	mv	a0,a5
    80200ada:	85be                	mv	a1,a5
    80200adc:	863e                	mv	a2,a5
    80200ade:	00000073          	ecall
    80200ae2:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200ae4:	8082                	ret

0000000080200ae6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200ae6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200ae8:	e589                	bnez	a1,80200af2 <strnlen+0xc>
    80200aea:	a811                	j	80200afe <strnlen+0x18>
        cnt ++;
    80200aec:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200aee:	00f58863          	beq	a1,a5,80200afe <strnlen+0x18>
    80200af2:	00f50733          	add	a4,a0,a5
    80200af6:	00074703          	lbu	a4,0(a4)
    80200afa:	fb6d                	bnez	a4,80200aec <strnlen+0x6>
    80200afc:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200afe:	852e                	mv	a0,a1
    80200b00:	8082                	ret

0000000080200b02 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200b02:	ca01                	beqz	a2,80200b12 <memset+0x10>
    80200b04:	962a                	add	a2,a2,a0
    char *p = s;
    80200b06:	87aa                	mv	a5,a0
        *p ++ = c;
    80200b08:	0785                	addi	a5,a5,1
    80200b0a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200b0e:	fec79de3          	bne	a5,a2,80200b08 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200b12:	8082                	ret
