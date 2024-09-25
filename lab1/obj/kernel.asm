
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
    80200016:	00e60613          	addi	a2,a2,14 # 80204020 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	2dd000ef          	jal	ra,80200afe <memset>

    cons_init();  // init the console
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	ae658593          	addi	a1,a1,-1306 # 80200b10 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	afe50513          	addi	a0,a0,-1282 # 80200b30 <etext+0x20>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	062000ef          	jal	ra,802000a0 <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	11a000ef          	jal	ra,80200172 <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end+0x8>
int cprintf(const char *fmt, ...) {
    80200070:	8e2a                	mv	t3,a0
    80200072:	f42e                	sd	a1,40(sp)
    80200074:	f832                	sd	a2,48(sp)
    80200076:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200078:	00000517          	auipc	a0,0x0
    8020007c:	fd850513          	addi	a0,a0,-40 # 80200050 <cputch>
    80200080:	004c                	addi	a1,sp,4
    80200082:	869a                	mv	a3,t1
    80200084:	8672                	mv	a2,t3
int cprintf(const char *fmt, ...) {
    80200086:	ec06                	sd	ra,24(sp)
    80200088:	e0ba                	sd	a4,64(sp)
    8020008a:	e4be                	sd	a5,72(sp)
    8020008c:	e8c2                	sd	a6,80(sp)
    8020008e:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    80200090:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200092:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200094:	67e000ef          	jal	ra,80200712 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200098:	60e2                	ld	ra,24(sp)
    8020009a:	4512                	lw	a0,4(sp)
    8020009c:	6125                	addi	sp,sp,96
    8020009e:	8082                	ret

00000000802000a0 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    802000a0:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a2:	00001517          	auipc	a0,0x1
    802000a6:	a9650513          	addi	a0,a0,-1386 # 80200b38 <etext+0x28>
void print_kerninfo(void) {
    802000aa:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000ac:	fbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000b0:	00000597          	auipc	a1,0x0
    802000b4:	f5a58593          	addi	a1,a1,-166 # 8020000a <kern_init>
    802000b8:	00001517          	auipc	a0,0x1
    802000bc:	aa050513          	addi	a0,a0,-1376 # 80200b58 <etext+0x48>
    802000c0:	fabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c4:	00001597          	auipc	a1,0x1
    802000c8:	a4c58593          	addi	a1,a1,-1460 # 80200b10 <etext>
    802000cc:	00001517          	auipc	a0,0x1
    802000d0:	aac50513          	addi	a0,a0,-1364 # 80200b78 <etext+0x68>
    802000d4:	f97ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d8:	00004597          	auipc	a1,0x4
    802000dc:	f3858593          	addi	a1,a1,-200 # 80204010 <ticks>
    802000e0:	00001517          	auipc	a0,0x1
    802000e4:	ab850513          	addi	a0,a0,-1352 # 80200b98 <etext+0x88>
    802000e8:	f83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ec:	00004597          	auipc	a1,0x4
    802000f0:	f3458593          	addi	a1,a1,-204 # 80204020 <end>
    802000f4:	00001517          	auipc	a0,0x1
    802000f8:	ac450513          	addi	a0,a0,-1340 # 80200bb8 <etext+0xa8>
    802000fc:	f6fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    80200100:	00004597          	auipc	a1,0x4
    80200104:	31f58593          	addi	a1,a1,799 # 8020441f <end+0x3ff>
    80200108:	00000797          	auipc	a5,0x0
    8020010c:	f0278793          	addi	a5,a5,-254 # 8020000a <kern_init>
    80200110:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200114:	43f7d593          	srai	a1,a5,0x3f
}
    80200118:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020011a:	3ff5f593          	andi	a1,a1,1023
    8020011e:	95be                	add	a1,a1,a5
    80200120:	85a9                	srai	a1,a1,0xa
    80200122:	00001517          	auipc	a0,0x1
    80200126:	ab650513          	addi	a0,a0,-1354 # 80200bd8 <etext+0xc8>
}
    8020012a:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012c:	bf3d                	j	8020006a <cprintf>

000000008020012e <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020013a:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	169000ef          	jal	ra,80200aae <sbi_set_timer>
}
    8020014a:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200154:	00001517          	auipc	a0,0x1
    80200158:	ab450513          	addi	a0,a0,-1356 # 80200c08 <etext+0xf8>
}
    8020015c:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015e:	b731                	j	8020006a <cprintf>

0000000080200160 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200160:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	1430006f          	j	80200aae <sbi_set_timer>

0000000080200170 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    80200170:	8082                	ret

0000000080200172 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200172:	0ff57513          	zext.b	a0,a0
    80200176:	11f0006f          	j	80200a94 <sbi_console_putchar>

000000008020017a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200180:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200184:	00000797          	auipc	a5,0x0
    80200188:	46c78793          	addi	a5,a5,1132 # 802005f0 <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
}
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200192:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	a8e50513          	addi	a0,a0,-1394 # 80200c28 <etext+0x118>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	ec7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	a9650513          	addi	a0,a0,-1386 # 80200c40 <etext+0x130>
    802001b2:	eb9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	aa050513          	addi	a0,a0,-1376 # 80200c58 <etext+0x148>
    802001c0:	eabff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	aaa50513          	addi	a0,a0,-1366 # 80200c70 <etext+0x160>
    802001ce:	e9dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	ab450513          	addi	a0,a0,-1356 # 80200c88 <etext+0x178>
    802001dc:	e8fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	abe50513          	addi	a0,a0,-1346 # 80200ca0 <etext+0x190>
    802001ea:	e81ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	ac850513          	addi	a0,a0,-1336 # 80200cb8 <etext+0x1a8>
    802001f8:	e73ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	ad250513          	addi	a0,a0,-1326 # 80200cd0 <etext+0x1c0>
    80200206:	e65ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	adc50513          	addi	a0,a0,-1316 # 80200ce8 <etext+0x1d8>
    80200214:	e57ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	ae650513          	addi	a0,a0,-1306 # 80200d00 <etext+0x1f0>
    80200222:	e49ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	af050513          	addi	a0,a0,-1296 # 80200d18 <etext+0x208>
    80200230:	e3bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	afa50513          	addi	a0,a0,-1286 # 80200d30 <etext+0x220>
    8020023e:	e2dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	b0450513          	addi	a0,a0,-1276 # 80200d48 <etext+0x238>
    8020024c:	e1fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	b0e50513          	addi	a0,a0,-1266 # 80200d60 <etext+0x250>
    8020025a:	e11ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	b1850513          	addi	a0,a0,-1256 # 80200d78 <etext+0x268>
    80200268:	e03ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	b2250513          	addi	a0,a0,-1246 # 80200d90 <etext+0x280>
    80200276:	df5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	b2c50513          	addi	a0,a0,-1236 # 80200da8 <etext+0x298>
    80200284:	de7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	b3650513          	addi	a0,a0,-1226 # 80200dc0 <etext+0x2b0>
    80200292:	dd9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	b4050513          	addi	a0,a0,-1216 # 80200dd8 <etext+0x2c8>
    802002a0:	dcbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	b4a50513          	addi	a0,a0,-1206 # 80200df0 <etext+0x2e0>
    802002ae:	dbdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	b5450513          	addi	a0,a0,-1196 # 80200e08 <etext+0x2f8>
    802002bc:	dafff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	b5e50513          	addi	a0,a0,-1186 # 80200e20 <etext+0x310>
    802002ca:	da1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	b6850513          	addi	a0,a0,-1176 # 80200e38 <etext+0x328>
    802002d8:	d93ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	b7250513          	addi	a0,a0,-1166 # 80200e50 <etext+0x340>
    802002e6:	d85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	b7c50513          	addi	a0,a0,-1156 # 80200e68 <etext+0x358>
    802002f4:	d77ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	b8650513          	addi	a0,a0,-1146 # 80200e80 <etext+0x370>
    80200302:	d69ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	b9050513          	addi	a0,a0,-1136 # 80200e98 <etext+0x388>
    80200310:	d5bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	b9a50513          	addi	a0,a0,-1126 # 80200eb0 <etext+0x3a0>
    8020031e:	d4dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	ba450513          	addi	a0,a0,-1116 # 80200ec8 <etext+0x3b8>
    8020032c:	d3fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	bae50513          	addi	a0,a0,-1106 # 80200ee0 <etext+0x3d0>
    8020033a:	d31ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	bb850513          	addi	a0,a0,-1096 # 80200ef8 <etext+0x3e8>
    80200348:	d23ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	bbe50513          	addi	a0,a0,-1090 # 80200f10 <etext+0x400>
}
    8020035a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200362:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200364:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	bc250513          	addi	a0,a0,-1086 # 80200f28 <etext+0x418>
void print_trapframe(struct trapframe *tf) {
    8020036e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	cfbff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	bc250513          	addi	a0,a0,-1086 # 80200f40 <etext+0x430>
    80200386:	ce5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	bca50513          	addi	a0,a0,-1078 # 80200f58 <etext+0x448>
    80200396:	cd5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	bd250513          	addi	a0,a0,-1070 # 80200f70 <etext+0x460>
    802003a6:	cc5ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	bd650513          	addi	a0,a0,-1066 # 80200f88 <etext+0x478>
}
    802003ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	08f76163          	bltu	a4,a5,8020044a <interrupt_handler+0x8c>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	c8470713          	addi	a4,a4,-892 # 80201050 <etext+0x540>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	c2250513          	addi	a0,a0,-990 # 80201000 <etext+0x4f0>
    802003e6:	b151                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	bf850513          	addi	a0,a0,-1032 # 80200fe0 <etext+0x4d0>
    802003f0:	b9ad                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	bae50513          	addi	a0,a0,-1106 # 80200fa0 <etext+0x490>
    802003fa:	b985                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	bc450513          	addi	a0,a0,-1084 # 80200fc0 <etext+0x4b0>
    80200404:	b19d                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e022                	sd	s0,0(sp)
    8020040a:	e406                	sd	ra,8(sp)
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
           clock_set_next_event();
           ticks++;
    8020040c:	00004417          	auipc	s0,0x4
    80200410:	c0440413          	addi	s0,s0,-1020 # 80204010 <ticks>
           clock_set_next_event();
    80200414:	d4dff0ef          	jal	ra,80200160 <clock_set_next_event>
           ticks++;
    80200418:	601c                	ld	a5,0(s0)
           if(ticks%100==0)
    8020041a:	06400713          	li	a4,100
           ticks++;
    8020041e:	0785                	addi	a5,a5,1
    80200420:	e01c                	sd	a5,0(s0)
           if(ticks%100==0)
    80200422:	601c                	ld	a5,0(s0)
    80200424:	02e7f7b3          	remu	a5,a5,a4
    80200428:	c395                	beqz	a5,8020044c <interrupt_handler+0x8e>
           {
            print_ticks();
           }
            if(ticks/100==10){
    8020042a:	601c                	ld	a5,0(s0)
    8020042c:	06300713          	li	a4,99
    80200430:	c1878793          	addi	a5,a5,-1000
    80200434:	02f77563          	bgeu	a4,a5,8020045e <interrupt_handler+0xa0>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200438:	60a2                	ld	ra,8(sp)
    8020043a:	6402                	ld	s0,0(sp)
    8020043c:	0141                	addi	sp,sp,16
    8020043e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200440:	00001517          	auipc	a0,0x1
    80200444:	bf050513          	addi	a0,a0,-1040 # 80201030 <etext+0x520>
    80200448:	b10d                	j	8020006a <cprintf>
            print_trapframe(tf);
    8020044a:	bf11                	j	8020035e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020044c:	06400593          	li	a1,100
    80200450:	00001517          	auipc	a0,0x1
    80200454:	bd050513          	addi	a0,a0,-1072 # 80201020 <etext+0x510>
    80200458:	c13ff0ef          	jal	ra,8020006a <cprintf>
}
    8020045c:	b7f9                	j	8020042a <interrupt_handler+0x6c>
}
    8020045e:	6402                	ld	s0,0(sp)
    80200460:	60a2                	ld	ra,8(sp)
    80200462:	0141                	addi	sp,sp,16
                sbi_shutdown();
    80200464:	a595                	j	80200ac8 <sbi_shutdown>

0000000080200466 <exception_handler>:

#include <stdio.h>

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200466:	11853783          	ld	a5,280(a0)
    8020046a:	472d                	li	a4,11
    8020046c:	16f76a63          	bltu	a4,a5,802005e0 <exception_handler+0x17a>
    80200470:	00001717          	auipc	a4,0x1
    80200474:	eb070713          	addi	a4,a4,-336 # 80201320 <etext+0x810>
    80200478:	078a                	slli	a5,a5,0x2
    8020047a:	97ba                	add	a5,a5,a4
    8020047c:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
    8020047e:	1141                	addi	sp,sp,-16
    80200480:	e022                	sd	s0,0(sp)
    80200482:	97ba                	add	a5,a5,a4
    80200484:	e406                	sd	ra,8(sp)
    80200486:	842a                	mv	s0,a0
    80200488:	8782                	jr	a5
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Exception type: Supervisor ecall\n");
            cprintf("Supervisor call at: 0x%x\n", tf->epc);
            break;
        case CAUSE_HYPERVISOR_ECALL:
            cprintf("Exception type: Hypervisor ecall\n");
    8020048a:	00001517          	auipc	a0,0x1
    8020048e:	e1650513          	addi	a0,a0,-490 # 802012a0 <etext+0x790>
    80200492:	bd9ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Hypervisor call at: 0x%x\n", tf->epc);
    80200496:	10843583          	ld	a1,264(s0)
    8020049a:	00001517          	auipc	a0,0x1
    8020049e:	e2e50513          	addi	a0,a0,-466 # 802012c8 <etext+0x7b8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004a2:	6402                	ld	s0,0(sp)
    802004a4:	60a2                	ld	ra,8(sp)
    802004a6:	0141                	addi	sp,sp,16
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004a8:	b6c9                	j	8020006a <cprintf>
            cprintf("Exception type: Machine ecall\n");
    802004aa:	00001517          	auipc	a0,0x1
    802004ae:	e3e50513          	addi	a0,a0,-450 # 802012e8 <etext+0x7d8>
    802004b2:	bb9ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Machine call at: 0x%x\n", tf->epc);
    802004b6:	10843583          	ld	a1,264(s0)
    802004ba:	00001517          	auipc	a0,0x1
    802004be:	e4e50513          	addi	a0,a0,-434 # 80201308 <etext+0x7f8>
    802004c2:	b7c5                	j	802004a2 <exception_handler+0x3c>
            cprintf("Exception type: Misaligned fetch\n");
    802004c4:	00001517          	auipc	a0,0x1
    802004c8:	bbc50513          	addi	a0,a0,-1092 # 80201080 <etext+0x570>
            cprintf("Exception type: Fault fetch\n");
    802004cc:	b9fff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004d0:	10843583          	ld	a1,264(s0)
}
    802004d4:	6402                	ld	s0,0(sp)
    802004d6:	60a2                	ld	ra,8(sp)
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004d8:	00001517          	auipc	a0,0x1
    802004dc:	bd050513          	addi	a0,a0,-1072 # 802010a8 <etext+0x598>
}
    802004e0:	0141                	addi	sp,sp,16
            cprintf("Faulty instruction address: 0x%x\n", tf->epc);
    802004e2:	b661                	j	8020006a <cprintf>
            cprintf("Exception type: Fault fetch\n");
    802004e4:	00001517          	auipc	a0,0x1
    802004e8:	bec50513          	addi	a0,a0,-1044 # 802010d0 <etext+0x5c0>
    802004ec:	b7c5                	j	802004cc <exception_handler+0x66>
            cprintf("Exception type: Illegal instruction\n");
    802004ee:	00001517          	auipc	a0,0x1
    802004f2:	c0250513          	addi	a0,a0,-1022 # 802010f0 <etext+0x5e0>
    802004f6:	b75ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Illegal instruction caught at 0x%x\n", tf->epc);
    802004fa:	10843583          	ld	a1,264(s0)
    802004fe:	00001517          	auipc	a0,0x1
    80200502:	c1a50513          	addi	a0,a0,-998 # 80201118 <etext+0x608>
    80200506:	b65ff0ef          	jal	ra,8020006a <cprintf>
            tf->epc += 4; // 更新epc
    8020050a:	10843783          	ld	a5,264(s0)
    8020050e:	0791                	addi	a5,a5,4
    80200510:	10f43423          	sd	a5,264(s0)
}
    80200514:	60a2                	ld	ra,8(sp)
    80200516:	6402                	ld	s0,0(sp)
    80200518:	0141                	addi	sp,sp,16
    8020051a:	8082                	ret
            cprintf("Exception type: Breakpoint\n");
    8020051c:	00001517          	auipc	a0,0x1
    80200520:	c2450513          	addi	a0,a0,-988 # 80201140 <etext+0x630>
    80200524:	b47ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("ebreak caught at 0x%x\n", tf->epc);
    80200528:	10843583          	ld	a1,264(s0)
    8020052c:	00001517          	auipc	a0,0x1
    80200530:	c3450513          	addi	a0,a0,-972 # 80201160 <etext+0x650>
    80200534:	b37ff0ef          	jal	ra,8020006a <cprintf>
            tf->epc += 4; // 更新epc
    80200538:	10843783          	ld	a5,264(s0)
    8020053c:	0791                	addi	a5,a5,4
    8020053e:	10f43423          	sd	a5,264(s0)
            break;
    80200542:	bfc9                	j	80200514 <exception_handler+0xae>
            cprintf("Exception type: Misaligned load\n");
    80200544:	00001517          	auipc	a0,0x1
    80200548:	c3450513          	addi	a0,a0,-972 # 80201178 <etext+0x668>
    8020054c:	b1fff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    80200550:	10843583          	ld	a1,264(s0)
    80200554:	00001517          	auipc	a0,0x1
    80200558:	c4c50513          	addi	a0,a0,-948 # 802011a0 <etext+0x690>
    8020055c:	b799                	j	802004a2 <exception_handler+0x3c>
            cprintf("Exception type: Fault load\n");
    8020055e:	00001517          	auipc	a0,0x1
    80200562:	c5a50513          	addi	a0,a0,-934 # 802011b8 <etext+0x6a8>
    80200566:	b05ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    8020056a:	10843583          	ld	a1,264(s0)
    8020056e:	00001517          	auipc	a0,0x1
    80200572:	c3250513          	addi	a0,a0,-974 # 802011a0 <etext+0x690>
    80200576:	b735                	j	802004a2 <exception_handler+0x3c>
            cprintf("Exception type: Misaligned store\n");
    80200578:	00001517          	auipc	a0,0x1
    8020057c:	c6050513          	addi	a0,a0,-928 # 802011d8 <etext+0x6c8>
    80200580:	aebff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    80200584:	10843583          	ld	a1,264(s0)
    80200588:	00001517          	auipc	a0,0x1
    8020058c:	c1850513          	addi	a0,a0,-1000 # 802011a0 <etext+0x690>
    80200590:	bf09                	j	802004a2 <exception_handler+0x3c>
            cprintf("Exception type: Fault store\n");
    80200592:	00001517          	auipc	a0,0x1
    80200596:	c6e50513          	addi	a0,a0,-914 # 80201200 <etext+0x6f0>
    8020059a:	ad1ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Faulty address: 0x%x\n", tf->epc);
    8020059e:	10843583          	ld	a1,264(s0)
    802005a2:	00001517          	auipc	a0,0x1
    802005a6:	bfe50513          	addi	a0,a0,-1026 # 802011a0 <etext+0x690>
    802005aa:	bde5                	j	802004a2 <exception_handler+0x3c>
            cprintf("Exception type: User ecall\n");
    802005ac:	00001517          	auipc	a0,0x1
    802005b0:	c7450513          	addi	a0,a0,-908 # 80201220 <etext+0x710>
    802005b4:	ab7ff0ef          	jal	ra,8020006a <cprintf>
            cprintf("User call at: 0x%x\n", tf->epc);
    802005b8:	10843583          	ld	a1,264(s0)
    802005bc:	00001517          	auipc	a0,0x1
    802005c0:	c8450513          	addi	a0,a0,-892 # 80201240 <etext+0x730>
    802005c4:	bdf9                	j	802004a2 <exception_handler+0x3c>
            cprintf("Exception type: Supervisor ecall\n");
    802005c6:	00001517          	auipc	a0,0x1
    802005ca:	c9250513          	addi	a0,a0,-878 # 80201258 <etext+0x748>
    802005ce:	a9dff0ef          	jal	ra,8020006a <cprintf>
            cprintf("Supervisor call at: 0x%x\n", tf->epc);
    802005d2:	10843583          	ld	a1,264(s0)
    802005d6:	00001517          	auipc	a0,0x1
    802005da:	caa50513          	addi	a0,a0,-854 # 80201280 <etext+0x770>
    802005de:	b5d1                	j	802004a2 <exception_handler+0x3c>
            print_trapframe(tf);
    802005e0:	bbbd                	j	8020035e <print_trapframe>

00000000802005e2 <trap>:


/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802005e2:	11853783          	ld	a5,280(a0)
    802005e6:	0007c363          	bltz	a5,802005ec <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802005ea:	bdb5                	j	80200466 <exception_handler>
        interrupt_handler(tf);
    802005ec:	bbc9                	j	802003be <interrupt_handler>
	...

00000000802005f0 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802005f0:	14011073          	csrw	sscratch,sp
    802005f4:	712d                	addi	sp,sp,-288
    802005f6:	e002                	sd	zero,0(sp)
    802005f8:	e406                	sd	ra,8(sp)
    802005fa:	ec0e                	sd	gp,24(sp)
    802005fc:	f012                	sd	tp,32(sp)
    802005fe:	f416                	sd	t0,40(sp)
    80200600:	f81a                	sd	t1,48(sp)
    80200602:	fc1e                	sd	t2,56(sp)
    80200604:	e0a2                	sd	s0,64(sp)
    80200606:	e4a6                	sd	s1,72(sp)
    80200608:	e8aa                	sd	a0,80(sp)
    8020060a:	ecae                	sd	a1,88(sp)
    8020060c:	f0b2                	sd	a2,96(sp)
    8020060e:	f4b6                	sd	a3,104(sp)
    80200610:	f8ba                	sd	a4,112(sp)
    80200612:	fcbe                	sd	a5,120(sp)
    80200614:	e142                	sd	a6,128(sp)
    80200616:	e546                	sd	a7,136(sp)
    80200618:	e94a                	sd	s2,144(sp)
    8020061a:	ed4e                	sd	s3,152(sp)
    8020061c:	f152                	sd	s4,160(sp)
    8020061e:	f556                	sd	s5,168(sp)
    80200620:	f95a                	sd	s6,176(sp)
    80200622:	fd5e                	sd	s7,184(sp)
    80200624:	e1e2                	sd	s8,192(sp)
    80200626:	e5e6                	sd	s9,200(sp)
    80200628:	e9ea                	sd	s10,208(sp)
    8020062a:	edee                	sd	s11,216(sp)
    8020062c:	f1f2                	sd	t3,224(sp)
    8020062e:	f5f6                	sd	t4,232(sp)
    80200630:	f9fa                	sd	t5,240(sp)
    80200632:	fdfe                	sd	t6,248(sp)
    80200634:	14001473          	csrrw	s0,sscratch,zero
    80200638:	100024f3          	csrr	s1,sstatus
    8020063c:	14102973          	csrr	s2,sepc
    80200640:	143029f3          	csrr	s3,stval
    80200644:	14202a73          	csrr	s4,scause
    80200648:	e822                	sd	s0,16(sp)
    8020064a:	e226                	sd	s1,256(sp)
    8020064c:	e64a                	sd	s2,264(sp)
    8020064e:	ea4e                	sd	s3,272(sp)
    80200650:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200652:	850a                	mv	a0,sp
    jal trap
    80200654:	f8fff0ef          	jal	ra,802005e2 <trap>

0000000080200658 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200658:	6492                	ld	s1,256(sp)
    8020065a:	6932                	ld	s2,264(sp)
    8020065c:	10049073          	csrw	sstatus,s1
    80200660:	14191073          	csrw	sepc,s2
    80200664:	60a2                	ld	ra,8(sp)
    80200666:	61e2                	ld	gp,24(sp)
    80200668:	7202                	ld	tp,32(sp)
    8020066a:	72a2                	ld	t0,40(sp)
    8020066c:	7342                	ld	t1,48(sp)
    8020066e:	73e2                	ld	t2,56(sp)
    80200670:	6406                	ld	s0,64(sp)
    80200672:	64a6                	ld	s1,72(sp)
    80200674:	6546                	ld	a0,80(sp)
    80200676:	65e6                	ld	a1,88(sp)
    80200678:	7606                	ld	a2,96(sp)
    8020067a:	76a6                	ld	a3,104(sp)
    8020067c:	7746                	ld	a4,112(sp)
    8020067e:	77e6                	ld	a5,120(sp)
    80200680:	680a                	ld	a6,128(sp)
    80200682:	68aa                	ld	a7,136(sp)
    80200684:	694a                	ld	s2,144(sp)
    80200686:	69ea                	ld	s3,152(sp)
    80200688:	7a0a                	ld	s4,160(sp)
    8020068a:	7aaa                	ld	s5,168(sp)
    8020068c:	7b4a                	ld	s6,176(sp)
    8020068e:	7bea                	ld	s7,184(sp)
    80200690:	6c0e                	ld	s8,192(sp)
    80200692:	6cae                	ld	s9,200(sp)
    80200694:	6d4e                	ld	s10,208(sp)
    80200696:	6dee                	ld	s11,216(sp)
    80200698:	7e0e                	ld	t3,224(sp)
    8020069a:	7eae                	ld	t4,232(sp)
    8020069c:	7f4e                	ld	t5,240(sp)
    8020069e:	7fee                	ld	t6,248(sp)
    802006a0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802006a2:	10200073          	sret

00000000802006a6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802006a6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802006aa:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802006ac:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802006b0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802006b2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802006b6:	f022                	sd	s0,32(sp)
    802006b8:	ec26                	sd	s1,24(sp)
    802006ba:	e84a                	sd	s2,16(sp)
    802006bc:	f406                	sd	ra,40(sp)
    802006be:	e44e                	sd	s3,8(sp)
    802006c0:	84aa                	mv	s1,a0
    802006c2:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802006c4:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802006c8:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802006ca:	03067e63          	bgeu	a2,a6,80200706 <printnum+0x60>
    802006ce:	89be                	mv	s3,a5
        while (-- width > 0)
    802006d0:	00805763          	blez	s0,802006de <printnum+0x38>
    802006d4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802006d6:	85ca                	mv	a1,s2
    802006d8:	854e                	mv	a0,s3
    802006da:	9482                	jalr	s1
        while (-- width > 0)
    802006dc:	fc65                	bnez	s0,802006d4 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802006de:	1a02                	slli	s4,s4,0x20
    802006e0:	00001797          	auipc	a5,0x1
    802006e4:	c7078793          	addi	a5,a5,-912 # 80201350 <etext+0x840>
    802006e8:	020a5a13          	srli	s4,s4,0x20
    802006ec:	9a3e                	add	s4,s4,a5
}
    802006ee:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802006f0:	000a4503          	lbu	a0,0(s4)
}
    802006f4:	70a2                	ld	ra,40(sp)
    802006f6:	69a2                	ld	s3,8(sp)
    802006f8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    802006fa:	85ca                	mv	a1,s2
    802006fc:	87a6                	mv	a5,s1
}
    802006fe:	6942                	ld	s2,16(sp)
    80200700:	64e2                	ld	s1,24(sp)
    80200702:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200704:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200706:	03065633          	divu	a2,a2,a6
    8020070a:	8722                	mv	a4,s0
    8020070c:	f9bff0ef          	jal	ra,802006a6 <printnum>
    80200710:	b7f9                	j	802006de <printnum+0x38>

0000000080200712 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200712:	7119                	addi	sp,sp,-128
    80200714:	f4a6                	sd	s1,104(sp)
    80200716:	f0ca                	sd	s2,96(sp)
    80200718:	ecce                	sd	s3,88(sp)
    8020071a:	e8d2                	sd	s4,80(sp)
    8020071c:	e4d6                	sd	s5,72(sp)
    8020071e:	e0da                	sd	s6,64(sp)
    80200720:	fc5e                	sd	s7,56(sp)
    80200722:	f06a                	sd	s10,32(sp)
    80200724:	fc86                	sd	ra,120(sp)
    80200726:	f8a2                	sd	s0,112(sp)
    80200728:	f862                	sd	s8,48(sp)
    8020072a:	f466                	sd	s9,40(sp)
    8020072c:	ec6e                	sd	s11,24(sp)
    8020072e:	892a                	mv	s2,a0
    80200730:	84ae                	mv	s1,a1
    80200732:	8d32                	mv	s10,a2
    80200734:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200736:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020073a:	5b7d                	li	s6,-1
    8020073c:	00001a97          	auipc	s5,0x1
    80200740:	c48a8a93          	addi	s5,s5,-952 # 80201384 <etext+0x874>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200744:	00001b97          	auipc	s7,0x1
    80200748:	e1cb8b93          	addi	s7,s7,-484 # 80201560 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020074c:	000d4503          	lbu	a0,0(s10)
    80200750:	001d0413          	addi	s0,s10,1
    80200754:	01350a63          	beq	a0,s3,80200768 <vprintfmt+0x56>
            if (ch == '\0') {
    80200758:	c121                	beqz	a0,80200798 <vprintfmt+0x86>
            putch(ch, putdat);
    8020075a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020075c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    8020075e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200760:	fff44503          	lbu	a0,-1(s0)
    80200764:	ff351ae3          	bne	a0,s3,80200758 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
    80200768:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    8020076c:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200770:	4c81                	li	s9,0
    80200772:	4881                	li	a7,0
        width = precision = -1;
    80200774:	5c7d                	li	s8,-1
    80200776:	5dfd                	li	s11,-1
    80200778:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
    8020077c:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
    8020077e:	fdd6059b          	addiw	a1,a2,-35
    80200782:	0ff5f593          	zext.b	a1,a1
    80200786:	00140d13          	addi	s10,s0,1
    8020078a:	04b56263          	bltu	a0,a1,802007ce <vprintfmt+0xbc>
    8020078e:	058a                	slli	a1,a1,0x2
    80200790:	95d6                	add	a1,a1,s5
    80200792:	4194                	lw	a3,0(a1)
    80200794:	96d6                	add	a3,a3,s5
    80200796:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    80200798:	70e6                	ld	ra,120(sp)
    8020079a:	7446                	ld	s0,112(sp)
    8020079c:	74a6                	ld	s1,104(sp)
    8020079e:	7906                	ld	s2,96(sp)
    802007a0:	69e6                	ld	s3,88(sp)
    802007a2:	6a46                	ld	s4,80(sp)
    802007a4:	6aa6                	ld	s5,72(sp)
    802007a6:	6b06                	ld	s6,64(sp)
    802007a8:	7be2                	ld	s7,56(sp)
    802007aa:	7c42                	ld	s8,48(sp)
    802007ac:	7ca2                	ld	s9,40(sp)
    802007ae:	7d02                	ld	s10,32(sp)
    802007b0:	6de2                	ld	s11,24(sp)
    802007b2:	6109                	addi	sp,sp,128
    802007b4:	8082                	ret
            padc = '0';
    802007b6:	87b2                	mv	a5,a2
            goto reswitch;
    802007b8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802007bc:	846a                	mv	s0,s10
    802007be:	00140d13          	addi	s10,s0,1
    802007c2:	fdd6059b          	addiw	a1,a2,-35
    802007c6:	0ff5f593          	zext.b	a1,a1
    802007ca:	fcb572e3          	bgeu	a0,a1,8020078e <vprintfmt+0x7c>
            putch('%', putdat);
    802007ce:	85a6                	mv	a1,s1
    802007d0:	02500513          	li	a0,37
    802007d4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802007d6:	fff44783          	lbu	a5,-1(s0)
    802007da:	8d22                	mv	s10,s0
    802007dc:	f73788e3          	beq	a5,s3,8020074c <vprintfmt+0x3a>
    802007e0:	ffed4783          	lbu	a5,-2(s10)
    802007e4:	1d7d                	addi	s10,s10,-1
    802007e6:	ff379de3          	bne	a5,s3,802007e0 <vprintfmt+0xce>
    802007ea:	b78d                	j	8020074c <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
    802007ec:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
    802007f0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    802007f4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    802007f6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    802007fa:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    802007fe:	02d86463          	bltu	a6,a3,80200826 <vprintfmt+0x114>
                ch = *fmt;
    80200802:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
    80200806:	002c169b          	slliw	a3,s8,0x2
    8020080a:	0186873b          	addw	a4,a3,s8
    8020080e:	0017171b          	slliw	a4,a4,0x1
    80200812:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
    80200814:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
    80200818:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020081a:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
    8020081e:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
    80200822:	fed870e3          	bgeu	a6,a3,80200802 <vprintfmt+0xf0>
            if (width < 0)
    80200826:	f40ddce3          	bgez	s11,8020077e <vprintfmt+0x6c>
                width = precision, precision = -1;
    8020082a:	8de2                	mv	s11,s8
    8020082c:	5c7d                	li	s8,-1
    8020082e:	bf81                	j	8020077e <vprintfmt+0x6c>
            if (width < 0)
    80200830:	fffdc693          	not	a3,s11
    80200834:	96fd                	srai	a3,a3,0x3f
    80200836:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
    8020083a:	00144603          	lbu	a2,1(s0)
    8020083e:	2d81                	sext.w	s11,s11
    80200840:	846a                	mv	s0,s10
            goto reswitch;
    80200842:	bf35                	j	8020077e <vprintfmt+0x6c>
            precision = va_arg(ap, int);
    80200844:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    80200848:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    8020084c:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
    8020084e:	846a                	mv	s0,s10
            goto process_precision;
    80200850:	bfd9                	j	80200826 <vprintfmt+0x114>
    if (lflag >= 2) {
    80200852:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200854:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200858:	01174463          	blt	a4,a7,80200860 <vprintfmt+0x14e>
    else if (lflag) {
    8020085c:	1a088e63          	beqz	a7,80200a18 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
    80200860:	000a3603          	ld	a2,0(s4)
    80200864:	46c1                	li	a3,16
    80200866:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
    80200868:	2781                	sext.w	a5,a5
    8020086a:	876e                	mv	a4,s11
    8020086c:	85a6                	mv	a1,s1
    8020086e:	854a                	mv	a0,s2
    80200870:	e37ff0ef          	jal	ra,802006a6 <printnum>
            break;
    80200874:	bde1                	j	8020074c <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
    80200876:	000a2503          	lw	a0,0(s4)
    8020087a:	85a6                	mv	a1,s1
    8020087c:	0a21                	addi	s4,s4,8
    8020087e:	9902                	jalr	s2
            break;
    80200880:	b5f1                	j	8020074c <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200882:	4705                	li	a4,1
            precision = va_arg(ap, int);
    80200884:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    80200888:	01174463          	blt	a4,a7,80200890 <vprintfmt+0x17e>
    else if (lflag) {
    8020088c:	18088163          	beqz	a7,80200a0e <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
    80200890:	000a3603          	ld	a2,0(s4)
    80200894:	46a9                	li	a3,10
    80200896:	8a2e                	mv	s4,a1
    80200898:	bfc1                	j	80200868 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
    8020089a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    8020089e:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
    802008a0:	846a                	mv	s0,s10
            goto reswitch;
    802008a2:	bdf1                	j	8020077e <vprintfmt+0x6c>
            putch(ch, putdat);
    802008a4:	85a6                	mv	a1,s1
    802008a6:	02500513          	li	a0,37
    802008aa:	9902                	jalr	s2
            break;
    802008ac:	b545                	j	8020074c <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
    802008ae:	00144603          	lbu	a2,1(s0)
            lflag ++;
    802008b2:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
    802008b4:	846a                	mv	s0,s10
            goto reswitch;
    802008b6:	b5e1                	j	8020077e <vprintfmt+0x6c>
    if (lflag >= 2) {
    802008b8:	4705                	li	a4,1
            precision = va_arg(ap, int);
    802008ba:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
    802008be:	01174463          	blt	a4,a7,802008c6 <vprintfmt+0x1b4>
    else if (lflag) {
    802008c2:	14088163          	beqz	a7,80200a04 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
    802008c6:	000a3603          	ld	a2,0(s4)
    802008ca:	46a1                	li	a3,8
    802008cc:	8a2e                	mv	s4,a1
    802008ce:	bf69                	j	80200868 <vprintfmt+0x156>
            putch('0', putdat);
    802008d0:	03000513          	li	a0,48
    802008d4:	85a6                	mv	a1,s1
    802008d6:	e03e                	sd	a5,0(sp)
    802008d8:	9902                	jalr	s2
            putch('x', putdat);
    802008da:	85a6                	mv	a1,s1
    802008dc:	07800513          	li	a0,120
    802008e0:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    802008e2:	0a21                	addi	s4,s4,8
            goto number;
    802008e4:	6782                	ld	a5,0(sp)
    802008e6:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    802008e8:	ff8a3603          	ld	a2,-8(s4)
            goto number;
    802008ec:	bfb5                	j	80200868 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
    802008ee:	000a3403          	ld	s0,0(s4)
    802008f2:	008a0713          	addi	a4,s4,8
    802008f6:	e03a                	sd	a4,0(sp)
    802008f8:	14040263          	beqz	s0,80200a3c <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
    802008fc:	0fb05763          	blez	s11,802009ea <vprintfmt+0x2d8>
    80200900:	02d00693          	li	a3,45
    80200904:	0cd79163          	bne	a5,a3,802009c6 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200908:	00044783          	lbu	a5,0(s0)
    8020090c:	0007851b          	sext.w	a0,a5
    80200910:	cf85                	beqz	a5,80200948 <vprintfmt+0x236>
    80200912:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200916:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020091a:	000c4563          	bltz	s8,80200924 <vprintfmt+0x212>
    8020091e:	3c7d                	addiw	s8,s8,-1
    80200920:	036c0263          	beq	s8,s6,80200944 <vprintfmt+0x232>
                    putch('?', putdat);
    80200924:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200926:	0e0c8e63          	beqz	s9,80200a22 <vprintfmt+0x310>
    8020092a:	3781                	addiw	a5,a5,-32
    8020092c:	0ef47b63          	bgeu	s0,a5,80200a22 <vprintfmt+0x310>
                    putch('?', putdat);
    80200930:	03f00513          	li	a0,63
    80200934:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200936:	000a4783          	lbu	a5,0(s4)
    8020093a:	3dfd                	addiw	s11,s11,-1
    8020093c:	0a05                	addi	s4,s4,1
    8020093e:	0007851b          	sext.w	a0,a5
    80200942:	ffe1                	bnez	a5,8020091a <vprintfmt+0x208>
            for (; width > 0; width --) {
    80200944:	01b05963          	blez	s11,80200956 <vprintfmt+0x244>
    80200948:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020094a:	85a6                	mv	a1,s1
    8020094c:	02000513          	li	a0,32
    80200950:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200952:	fe0d9be3          	bnez	s11,80200948 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200956:	6a02                	ld	s4,0(sp)
    80200958:	bbd5                	j	8020074c <vprintfmt+0x3a>
    if (lflag >= 2) {
    8020095a:	4705                	li	a4,1
            precision = va_arg(ap, int);
    8020095c:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
    80200960:	01174463          	blt	a4,a7,80200968 <vprintfmt+0x256>
    else if (lflag) {
    80200964:	08088d63          	beqz	a7,802009fe <vprintfmt+0x2ec>
        return va_arg(*ap, long);
    80200968:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    8020096c:	0a044d63          	bltz	s0,80200a26 <vprintfmt+0x314>
            num = getint(&ap, lflag);
    80200970:	8622                	mv	a2,s0
    80200972:	8a66                	mv	s4,s9
    80200974:	46a9                	li	a3,10
    80200976:	bdcd                	j	80200868 <vprintfmt+0x156>
            err = va_arg(ap, int);
    80200978:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020097c:	4719                	li	a4,6
            err = va_arg(ap, int);
    8020097e:	0a21                	addi	s4,s4,8
            if (err < 0) {
    80200980:	41f7d69b          	sraiw	a3,a5,0x1f
    80200984:	8fb5                	xor	a5,a5,a3
    80200986:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020098a:	02d74163          	blt	a4,a3,802009ac <vprintfmt+0x29a>
    8020098e:	00369793          	slli	a5,a3,0x3
    80200992:	97de                	add	a5,a5,s7
    80200994:	639c                	ld	a5,0(a5)
    80200996:	cb99                	beqz	a5,802009ac <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
    80200998:	86be                	mv	a3,a5
    8020099a:	00001617          	auipc	a2,0x1
    8020099e:	9e660613          	addi	a2,a2,-1562 # 80201380 <etext+0x870>
    802009a2:	85a6                	mv	a1,s1
    802009a4:	854a                	mv	a0,s2
    802009a6:	0ce000ef          	jal	ra,80200a74 <printfmt>
    802009aa:	b34d                	j	8020074c <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802009ac:	00001617          	auipc	a2,0x1
    802009b0:	9c460613          	addi	a2,a2,-1596 # 80201370 <etext+0x860>
    802009b4:	85a6                	mv	a1,s1
    802009b6:	854a                	mv	a0,s2
    802009b8:	0bc000ef          	jal	ra,80200a74 <printfmt>
    802009bc:	bb41                	j	8020074c <vprintfmt+0x3a>
                p = "(null)";
    802009be:	00001417          	auipc	s0,0x1
    802009c2:	9aa40413          	addi	s0,s0,-1622 # 80201368 <etext+0x858>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009c6:	85e2                	mv	a1,s8
    802009c8:	8522                	mv	a0,s0
    802009ca:	e43e                	sd	a5,8(sp)
    802009cc:	116000ef          	jal	ra,80200ae2 <strnlen>
    802009d0:	40ad8dbb          	subw	s11,s11,a0
    802009d4:	01b05b63          	blez	s11,802009ea <vprintfmt+0x2d8>
                    putch(padc, putdat);
    802009d8:	67a2                	ld	a5,8(sp)
    802009da:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009de:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    802009e0:	85a6                	mv	a1,s1
    802009e2:	8552                	mv	a0,s4
    802009e4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    802009e6:	fe0d9ce3          	bnez	s11,802009de <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802009ea:	00044783          	lbu	a5,0(s0)
    802009ee:	00140a13          	addi	s4,s0,1
    802009f2:	0007851b          	sext.w	a0,a5
    802009f6:	d3a5                	beqz	a5,80200956 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
    802009f8:	05e00413          	li	s0,94
    802009fc:	bf39                	j	8020091a <vprintfmt+0x208>
        return va_arg(*ap, int);
    802009fe:	000a2403          	lw	s0,0(s4)
    80200a02:	b7ad                	j	8020096c <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
    80200a04:	000a6603          	lwu	a2,0(s4)
    80200a08:	46a1                	li	a3,8
    80200a0a:	8a2e                	mv	s4,a1
    80200a0c:	bdb1                	j	80200868 <vprintfmt+0x156>
    80200a0e:	000a6603          	lwu	a2,0(s4)
    80200a12:	46a9                	li	a3,10
    80200a14:	8a2e                	mv	s4,a1
    80200a16:	bd89                	j	80200868 <vprintfmt+0x156>
    80200a18:	000a6603          	lwu	a2,0(s4)
    80200a1c:	46c1                	li	a3,16
    80200a1e:	8a2e                	mv	s4,a1
    80200a20:	b5a1                	j	80200868 <vprintfmt+0x156>
                    putch(ch, putdat);
    80200a22:	9902                	jalr	s2
    80200a24:	bf09                	j	80200936 <vprintfmt+0x224>
                putch('-', putdat);
    80200a26:	85a6                	mv	a1,s1
    80200a28:	02d00513          	li	a0,45
    80200a2c:	e03e                	sd	a5,0(sp)
    80200a2e:	9902                	jalr	s2
                num = -(long long)num;
    80200a30:	6782                	ld	a5,0(sp)
    80200a32:	8a66                	mv	s4,s9
    80200a34:	40800633          	neg	a2,s0
    80200a38:	46a9                	li	a3,10
    80200a3a:	b53d                	j	80200868 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
    80200a3c:	03b05163          	blez	s11,80200a5e <vprintfmt+0x34c>
    80200a40:	02d00693          	li	a3,45
    80200a44:	f6d79de3          	bne	a5,a3,802009be <vprintfmt+0x2ac>
                p = "(null)";
    80200a48:	00001417          	auipc	s0,0x1
    80200a4c:	92040413          	addi	s0,s0,-1760 # 80201368 <etext+0x858>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200a50:	02800793          	li	a5,40
    80200a54:	02800513          	li	a0,40
    80200a58:	00140a13          	addi	s4,s0,1
    80200a5c:	bd6d                	j	80200916 <vprintfmt+0x204>
    80200a5e:	00001a17          	auipc	s4,0x1
    80200a62:	90ba0a13          	addi	s4,s4,-1781 # 80201369 <etext+0x859>
    80200a66:	02800513          	li	a0,40
    80200a6a:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
    80200a6e:	05e00413          	li	s0,94
    80200a72:	b565                	j	8020091a <vprintfmt+0x208>

0000000080200a74 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a74:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200a76:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a7a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a7c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200a7e:	ec06                	sd	ra,24(sp)
    80200a80:	f83a                	sd	a4,48(sp)
    80200a82:	fc3e                	sd	a5,56(sp)
    80200a84:	e0c2                	sd	a6,64(sp)
    80200a86:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200a88:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200a8a:	c89ff0ef          	jal	ra,80200712 <vprintfmt>
}
    80200a8e:	60e2                	ld	ra,24(sp)
    80200a90:	6161                	addi	sp,sp,80
    80200a92:	8082                	ret

0000000080200a94 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    80200a94:	4781                	li	a5,0
    80200a96:	00003717          	auipc	a4,0x3
    80200a9a:	56a73703          	ld	a4,1386(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    80200a9e:	88ba                	mv	a7,a4
    80200aa0:	852a                	mv	a0,a0
    80200aa2:	85be                	mv	a1,a5
    80200aa4:	863e                	mv	a2,a5
    80200aa6:	00000073          	ecall
    80200aaa:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    80200aac:	8082                	ret

0000000080200aae <sbi_set_timer>:
    __asm__ volatile (
    80200aae:	4781                	li	a5,0
    80200ab0:	00003717          	auipc	a4,0x3
    80200ab4:	56873703          	ld	a4,1384(a4) # 80204018 <SBI_SET_TIMER>
    80200ab8:	88ba                	mv	a7,a4
    80200aba:	852a                	mv	a0,a0
    80200abc:	85be                	mv	a1,a5
    80200abe:	863e                	mv	a2,a5
    80200ac0:	00000073          	ecall
    80200ac4:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    80200ac6:	8082                	ret

0000000080200ac8 <sbi_shutdown>:
    __asm__ volatile (
    80200ac8:	4781                	li	a5,0
    80200aca:	00003717          	auipc	a4,0x3
    80200ace:	53e73703          	ld	a4,1342(a4) # 80204008 <SBI_SHUTDOWN>
    80200ad2:	88ba                	mv	a7,a4
    80200ad4:	853e                	mv	a0,a5
    80200ad6:	85be                	mv	a1,a5
    80200ad8:	863e                	mv	a2,a5
    80200ada:	00000073          	ecall
    80200ade:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    80200ae0:	8082                	ret

0000000080200ae2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    80200ae2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    80200ae4:	e589                	bnez	a1,80200aee <strnlen+0xc>
    80200ae6:	a811                	j	80200afa <strnlen+0x18>
        cnt ++;
    80200ae8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200aea:	00f58863          	beq	a1,a5,80200afa <strnlen+0x18>
    80200aee:	00f50733          	add	a4,a0,a5
    80200af2:	00074703          	lbu	a4,0(a4)
    80200af6:	fb6d                	bnez	a4,80200ae8 <strnlen+0x6>
    80200af8:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200afa:	852e                	mv	a0,a1
    80200afc:	8082                	ret

0000000080200afe <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200afe:	ca01                	beqz	a2,80200b0e <memset+0x10>
    80200b00:	962a                	add	a2,a2,a0
    char *p = s;
    80200b02:	87aa                	mv	a5,a0
        *p ++ = c;
    80200b04:	0785                	addi	a5,a5,1
    80200b06:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200b0a:	fec79de3          	bne	a5,a2,80200b04 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200b0e:	8082                	ret
