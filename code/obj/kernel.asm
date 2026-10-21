
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d628293          	addi	t0,t0,214 # ffffffffc02000d6 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	6dc50513          	addi	a0,a0,1756 # ffffffffc0201728 <etext+0x2>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f4000ef          	jal	ffffffffc020014a <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07c58593          	addi	a1,a1,124 # ffffffffc02000d6 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	6e650513          	addi	a0,a0,1766 # ffffffffc0201748 <etext+0x22>
ffffffffc020006a:	0e0000ef          	jal	ffffffffc020014a <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	6b858593          	addi	a1,a1,1720 # ffffffffc0201726 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	6f250513          	addi	a0,a0,1778 # ffffffffc0201768 <etext+0x42>
ffffffffc020007e:	0cc000ef          	jal	ffffffffc020014a <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <free_area>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201788 <etext+0x62>
ffffffffc0200092:	0b8000ef          	jal	ffffffffc020014a <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	fe258593          	addi	a1,a1,-30 # ffffffffc0206078 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	70a50513          	addi	a0,a0,1802 # ffffffffc02017a8 <etext+0x82>
ffffffffc02000a6:	0a4000ef          	jal	ffffffffc020014a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00000717          	auipc	a4,0x0
ffffffffc02000ae:	02c70713          	addi	a4,a4,44 # ffffffffc02000d6 <kern_init>
ffffffffc02000b2:	00006797          	auipc	a5,0x6
ffffffffc02000b6:	3c578793          	addi	a5,a5,965 # ffffffffc0206477 <end+0x3ff>
ffffffffc02000ba:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000bc:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c6:	95be                	add	a1,a1,a5
ffffffffc02000c8:	85a9                	srai	a1,a1,0xa
ffffffffc02000ca:	00001517          	auipc	a0,0x1
ffffffffc02000ce:	6fe50513          	addi	a0,a0,1790 # ffffffffc02017c8 <etext+0xa2>
}
ffffffffc02000d2:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d4:	a89d                	j	ffffffffc020014a <cprintf>

ffffffffc02000d6 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d6:	00006517          	auipc	a0,0x6
ffffffffc02000da:	f4250513          	addi	a0,a0,-190 # ffffffffc0206018 <free_area>
ffffffffc02000de:	00006617          	auipc	a2,0x6
ffffffffc02000e2:	f9a60613          	addi	a2,a2,-102 # ffffffffc0206078 <end>
int kern_init(void) {
ffffffffc02000e6:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000e8:	8e09                	sub	a2,a2,a0
ffffffffc02000ea:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ec:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000ee:	626010ef          	jal	ffffffffc0201714 <memset>
    dtb_init();
ffffffffc02000f2:	13c000ef          	jal	ffffffffc020022e <dtb_init>
    cons_init();  // init the console
ffffffffc02000f6:	12e000ef          	jal	ffffffffc0200224 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fa:	00002517          	auipc	a0,0x2
ffffffffc02000fe:	e5e50513          	addi	a0,a0,-418 # ffffffffc0201f58 <etext+0x832>
ffffffffc0200102:	07c000ef          	jal	ffffffffc020017e <cputs>

    print_kerninfo();
ffffffffc0200106:	f45ff0ef          	jal	ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010a:	6f3000ef          	jal	ffffffffc0200ffc <pmm_init>

    /* do nothing */
    while (1)
ffffffffc020010e:	a001                	j	ffffffffc020010e <kern_init+0x38>

ffffffffc0200110 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200110:	1141                	addi	sp,sp,-16
ffffffffc0200112:	e022                	sd	s0,0(sp)
ffffffffc0200114:	e406                	sd	ra,8(sp)
ffffffffc0200116:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200118:	10e000ef          	jal	ffffffffc0200226 <cons_putc>
    (*cnt) ++;
ffffffffc020011c:	401c                	lw	a5,0(s0)
}
ffffffffc020011e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200120:	2785                	addiw	a5,a5,1
ffffffffc0200122:	c01c                	sw	a5,0(s0)
}
ffffffffc0200124:	6402                	ld	s0,0(sp)
ffffffffc0200126:	0141                	addi	sp,sp,16
ffffffffc0200128:	8082                	ret

ffffffffc020012a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020012a:	1101                	addi	sp,sp,-32
ffffffffc020012c:	862a                	mv	a2,a0
ffffffffc020012e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200130:	00000517          	auipc	a0,0x0
ffffffffc0200134:	fe050513          	addi	a0,a0,-32 # ffffffffc0200110 <cputch>
ffffffffc0200138:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc020013a:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013c:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020013e:	1be010ef          	jal	ffffffffc02012fc <vprintfmt>
    return cnt;
}
ffffffffc0200142:	60e2                	ld	ra,24(sp)
ffffffffc0200144:	4532                	lw	a0,12(sp)
ffffffffc0200146:	6105                	addi	sp,sp,32
ffffffffc0200148:	8082                	ret

ffffffffc020014a <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020014a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014c:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc0200150:	f42e                	sd	a1,40(sp)
ffffffffc0200152:	f832                	sd	a2,48(sp)
ffffffffc0200154:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200156:	862a                	mv	a2,a0
ffffffffc0200158:	004c                	addi	a1,sp,4
ffffffffc020015a:	00000517          	auipc	a0,0x0
ffffffffc020015e:	fb650513          	addi	a0,a0,-74 # ffffffffc0200110 <cputch>
ffffffffc0200162:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc0200164:	ec06                	sd	ra,24(sp)
ffffffffc0200166:	e0ba                	sd	a4,64(sp)
ffffffffc0200168:	e4be                	sd	a5,72(sp)
ffffffffc020016a:	e8c2                	sd	a6,80(sp)
ffffffffc020016c:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc020016e:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc0200170:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200172:	18a010ef          	jal	ffffffffc02012fc <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200176:	60e2                	ld	ra,24(sp)
ffffffffc0200178:	4512                	lw	a0,4(sp)
ffffffffc020017a:	6125                	addi	sp,sp,96
ffffffffc020017c:	8082                	ret

ffffffffc020017e <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020017e:	1101                	addi	sp,sp,-32
ffffffffc0200180:	ec06                	sd	ra,24(sp)
ffffffffc0200182:	e822                	sd	s0,16(sp)
ffffffffc0200184:	87aa                	mv	a5,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200186:	00054503          	lbu	a0,0(a0)
ffffffffc020018a:	c905                	beqz	a0,ffffffffc02001ba <cputs+0x3c>
ffffffffc020018c:	e426                	sd	s1,8(sp)
ffffffffc020018e:	00178493          	addi	s1,a5,1
ffffffffc0200192:	8426                	mv	s0,s1
    cons_putc(c);
ffffffffc0200194:	092000ef          	jal	ffffffffc0200226 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200198:	87a2                	mv	a5,s0
ffffffffc020019a:	00044503          	lbu	a0,0(s0)
ffffffffc020019e:	0405                	addi	s0,s0,1
ffffffffc02001a0:	f975                	bnez	a0,ffffffffc0200194 <cputs+0x16>
    (*cnt) ++;
ffffffffc02001a2:	9f85                	subw	a5,a5,s1
    cons_putc(c);
ffffffffc02001a4:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc02001a6:	0027841b          	addiw	s0,a5,2
ffffffffc02001aa:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001ac:	07a000ef          	jal	ffffffffc0200226 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001b0:	60e2                	ld	ra,24(sp)
ffffffffc02001b2:	8522                	mv	a0,s0
ffffffffc02001b4:	6442                	ld	s0,16(sp)
ffffffffc02001b6:	6105                	addi	sp,sp,32
ffffffffc02001b8:	8082                	ret
    cons_putc(c);
ffffffffc02001ba:	4529                	li	a0,10
ffffffffc02001bc:	06a000ef          	jal	ffffffffc0200226 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001c0:	4405                	li	s0,1
}
ffffffffc02001c2:	60e2                	ld	ra,24(sp)
ffffffffc02001c4:	8522                	mv	a0,s0
ffffffffc02001c6:	6442                	ld	s0,16(sp)
ffffffffc02001c8:	6105                	addi	sp,sp,32
ffffffffc02001ca:	8082                	ret

ffffffffc02001cc <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001cc:	00006317          	auipc	t1,0x6
ffffffffc02001d0:	e6432303          	lw	t1,-412(t1) # ffffffffc0206030 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d4:	715d                	addi	sp,sp,-80
ffffffffc02001d6:	ec06                	sd	ra,24(sp)
ffffffffc02001d8:	f436                	sd	a3,40(sp)
ffffffffc02001da:	f83a                	sd	a4,48(sp)
ffffffffc02001dc:	fc3e                	sd	a5,56(sp)
ffffffffc02001de:	e0c2                	sd	a6,64(sp)
ffffffffc02001e0:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001e2:	00030363          	beqz	t1,ffffffffc02001e8 <__panic+0x1c>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e6:	a001                	j	ffffffffc02001e6 <__panic+0x1a>
    is_panic = 1;
ffffffffc02001e8:	e822                	sd	s0,16(sp)
ffffffffc02001ea:	00006797          	auipc	a5,0x6
ffffffffc02001ee:	e4678793          	addi	a5,a5,-442 # ffffffffc0206030 <is_panic>
ffffffffc02001f2:	4685                	li	a3,1
    va_start(ap, fmt);
ffffffffc02001f4:	1038                	addi	a4,sp,40
ffffffffc02001f6:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f8:	862e                	mv	a2,a1
ffffffffc02001fa:	85aa                	mv	a1,a0
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	5fc50513          	addi	a0,a0,1532 # ffffffffc02017f8 <etext+0xd2>
    is_panic = 1;
ffffffffc0200204:	c394                	sw	a3,0(a5)
    va_start(ap, fmt);
ffffffffc0200206:	e43a                	sd	a4,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200208:	f43ff0ef          	jal	ffffffffc020014a <cprintf>
    vcprintf(fmt, ap);
ffffffffc020020c:	65a2                	ld	a1,8(sp)
ffffffffc020020e:	8522                	mv	a0,s0
ffffffffc0200210:	f1bff0ef          	jal	ffffffffc020012a <vcprintf>
    cprintf("\n");
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	60450513          	addi	a0,a0,1540 # ffffffffc0201818 <etext+0xf2>
ffffffffc020021c:	f2fff0ef          	jal	ffffffffc020014a <cprintf>
ffffffffc0200220:	6442                	ld	s0,16(sp)
ffffffffc0200222:	b7d1                	j	ffffffffc02001e6 <__panic+0x1a>

ffffffffc0200224 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200224:	8082                	ret

ffffffffc0200226 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200226:	0ff57513          	zext.b	a0,a0
ffffffffc020022a:	43a0106f          	j	ffffffffc0201664 <sbi_console_putchar>

ffffffffc020022e <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc020022e:	711d                	addi	sp,sp,-96
    cprintf("DTB Init\n");
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	5f050513          	addi	a0,a0,1520 # ffffffffc0201820 <etext+0xfa>
void dtb_init(void) {
ffffffffc0200238:	ec86                	sd	ra,88(sp)
ffffffffc020023a:	e8a2                	sd	s0,80(sp)
    cprintf("DTB Init\n");
ffffffffc020023c:	f0fff0ef          	jal	ffffffffc020014a <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200240:	00006597          	auipc	a1,0x6
ffffffffc0200244:	dc05b583          	ld	a1,-576(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200248:	00001517          	auipc	a0,0x1
ffffffffc020024c:	5e850513          	addi	a0,a0,1512 # ffffffffc0201830 <etext+0x10a>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200250:	00006417          	auipc	s0,0x6
ffffffffc0200254:	db840413          	addi	s0,s0,-584 # ffffffffc0206008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200258:	ef3ff0ef          	jal	ffffffffc020014a <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020025c:	600c                	ld	a1,0(s0)
ffffffffc020025e:	00001517          	auipc	a0,0x1
ffffffffc0200262:	5e250513          	addi	a0,a0,1506 # ffffffffc0201840 <etext+0x11a>
ffffffffc0200266:	ee5ff0ef          	jal	ffffffffc020014a <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc020026a:	601c                	ld	a5,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc020026c:	00001517          	auipc	a0,0x1
ffffffffc0200270:	5ec50513          	addi	a0,a0,1516 # ffffffffc0201858 <etext+0x132>
    if (boot_dtb == 0) {
ffffffffc0200274:	12078463          	beqz	a5,ffffffffc020039c <dtb_init+0x16e>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200278:	5775                	li	a4,-3
ffffffffc020027a:	077a                	slli	a4,a4,0x1e
ffffffffc020027c:	97ba                	add	a5,a5,a4
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc020027e:	4398                	lw	a4,0(a5)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200280:	f456                	sd	s5,40(sp)
ffffffffc0200282:	00ff0ab7          	lui	s5,0xff0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200286:	0107569b          	srliw	a3,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028a:	0087559b          	srliw	a1,a4,0x8
ffffffffc020028e:	0187151b          	slliw	a0,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200292:	0086969b          	slliw	a3,a3,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200296:	0105959b          	slliw	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020029a:	0187571b          	srliw	a4,a4,0x18
ffffffffc020029e:	8f49                	or	a4,a4,a0
ffffffffc02002a0:	16c2                	slli	a3,a3,0x30
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a2:	0155f5b3          	and	a1,a1,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002a6:	8dd9                	or	a1,a1,a4
    if (magic != 0xd00dfeed) {
ffffffffc02002a8:	d00e0637          	lui	a2,0xd00e0
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ac:	92c1                	srli	a3,a3,0x30
ffffffffc02002ae:	8dd5                	or	a1,a1,a3
    if (magic != 0xd00dfeed) {
ffffffffc02002b0:	eed60713          	addi	a4,a2,-275 # ffffffffd00dfeed <end+0xfed9e75>
ffffffffc02002b4:	0ee59863          	bne	a1,a4,ffffffffc02003a4 <dtb_init+0x176>
ffffffffc02002b8:	4794                	lw	a3,8(a5)
ffffffffc02002ba:	47d8                	lw	a4,12(a5)
ffffffffc02002bc:	e4a6                	sd	s1,72(sp)
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002be:	0106d59b          	srliw	a1,a3,0x10
ffffffffc02002c2:	0107561b          	srliw	a2,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002c6:	0086d41b          	srliw	s0,a3,0x8
ffffffffc02002ca:	0087549b          	srliw	s1,a4,0x8
ffffffffc02002ce:	0186981b          	slliw	a6,a3,0x18
ffffffffc02002d2:	0187151b          	slliw	a0,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d6:	0085959b          	slliw	a1,a1,0x8
ffffffffc02002da:	0086161b          	slliw	a2,a2,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002de:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e2:	0186d69b          	srliw	a3,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e6:	0104949b          	slliw	s1,s1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ea:	0187571b          	srliw	a4,a4,0x18
ffffffffc02002ee:	15c2                	slli	a1,a1,0x30
ffffffffc02002f0:	1642                	slli	a2,a2,0x30
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002f2:	01547433          	and	s0,s0,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002f6:	00d866b3          	or	a3,a6,a3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002fa:	0154f4b3          	and	s1,s1,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002fe:	8f49                	or	a4,a4,a0
ffffffffc0200300:	91c1                	srli	a1,a1,0x30
ffffffffc0200302:	9241                	srli	a2,a2,0x30
ffffffffc0200304:	8c55                	or	s0,s0,a3
ffffffffc0200306:	8cd9                	or	s1,s1,a4
ffffffffc0200308:	8c4d                	or	s0,s0,a1
ffffffffc020030a:	8cd1                	or	s1,s1,a2
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020030c:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020030e:	1482                	slli	s1,s1,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200310:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200312:	9081                	srli	s1,s1,0x20
ffffffffc0200314:	e0ca                	sd	s2,64(sp)
ffffffffc0200316:	fc4e                	sd	s3,56(sp)
ffffffffc0200318:	f05a                	sd	s6,32(sp)
ffffffffc020031a:	ec5e                	sd	s7,24(sp)
ffffffffc020031c:	e862                	sd	s8,16(sp)
ffffffffc020031e:	f852                	sd	s4,48(sp)
ffffffffc0200320:	e466                	sd	s9,8(sp)
    int in_memory_node = 0;
ffffffffc0200322:	4b81                	li	s7,0
        switch (token) {
ffffffffc0200324:	4b0d                	li	s6,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200326:	943e                	add	s0,s0,a5
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200328:	94be                	add	s1,s1,a5
        switch (token) {
ffffffffc020032a:	4991                	li	s3,4
ffffffffc020032c:	4c05                	li	s8,1
ffffffffc020032e:	4909                	li	s2,2
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200330:	4018                	lw	a4,0(s0)
ffffffffc0200332:	00440a13          	addi	s4,s0,4
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200336:	0107569b          	srliw	a3,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020033a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020033e:	0187161b          	slliw	a2,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200342:	0086969b          	slliw	a3,a3,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200346:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020034a:	0187571b          	srliw	a4,a4,0x18
ffffffffc020034e:	16c2                	slli	a3,a3,0x30
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200350:	0157f7b3          	and	a5,a5,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200354:	8f51                	or	a4,a4,a2
ffffffffc0200356:	92c1                	srli	a3,a3,0x30
ffffffffc0200358:	8fd9                	or	a5,a5,a4
ffffffffc020035a:	8fd5                	or	a5,a5,a3
        switch (token) {
ffffffffc020035c:	09678763          	beq	a5,s6,ffffffffc02003ea <dtb_init+0x1bc>
ffffffffc0200360:	00fb6963          	bltu	s6,a5,ffffffffc0200372 <dtb_init+0x144>
ffffffffc0200364:	05878963          	beq	a5,s8,ffffffffc02003b6 <dtb_init+0x188>
ffffffffc0200368:	01279763          	bne	a5,s2,ffffffffc0200376 <dtb_init+0x148>
ffffffffc020036c:	4b81                	li	s7,0
ffffffffc020036e:	8452                	mv	s0,s4
ffffffffc0200370:	b7c1                	j	ffffffffc0200330 <dtb_init+0x102>
ffffffffc0200372:	ff378ee3          	beq	a5,s3,ffffffffc020036e <dtb_init+0x140>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200376:	00001517          	auipc	a0,0x1
ffffffffc020037a:	5aa50513          	addi	a0,a0,1450 # ffffffffc0201920 <etext+0x1fa>
ffffffffc020037e:	dcdff0ef          	jal	ffffffffc020014a <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200382:	64a6                	ld	s1,72(sp)
ffffffffc0200384:	6906                	ld	s2,64(sp)
ffffffffc0200386:	79e2                	ld	s3,56(sp)
ffffffffc0200388:	7a42                	ld	s4,48(sp)
ffffffffc020038a:	7aa2                	ld	s5,40(sp)
ffffffffc020038c:	7b02                	ld	s6,32(sp)
ffffffffc020038e:	6be2                	ld	s7,24(sp)
ffffffffc0200390:	6c42                	ld	s8,16(sp)
ffffffffc0200392:	6ca2                	ld	s9,8(sp)
ffffffffc0200394:	00001517          	auipc	a0,0x1
ffffffffc0200398:	5c450513          	addi	a0,a0,1476 # ffffffffc0201958 <etext+0x232>
}
ffffffffc020039c:	6446                	ld	s0,80(sp)
ffffffffc020039e:	60e6                	ld	ra,88(sp)
ffffffffc02003a0:	6125                	addi	sp,sp,96
    cprintf("DTB init completed\n");
ffffffffc02003a2:	b365                	j	ffffffffc020014a <cprintf>
}
ffffffffc02003a4:	6446                	ld	s0,80(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003a6:	7aa2                	ld	s5,40(sp)
}
ffffffffc02003a8:	60e6                	ld	ra,88(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003aa:	00001517          	auipc	a0,0x1
ffffffffc02003ae:	4ce50513          	addi	a0,a0,1230 # ffffffffc0201878 <etext+0x152>
}
ffffffffc02003b2:	6125                	addi	sp,sp,96
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02003b4:	bb59                	j	ffffffffc020014a <cprintf>
                int name_len = strlen(name);
ffffffffc02003b6:	8552                	mv	a0,s4
ffffffffc02003b8:	2c6010ef          	jal	ffffffffc020167e <strlen>
ffffffffc02003bc:	8caa                	mv	s9,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003be:	4619                	li	a2,6
ffffffffc02003c0:	8552                	mv	a0,s4
ffffffffc02003c2:	00001597          	auipc	a1,0x1
ffffffffc02003c6:	4de58593          	addi	a1,a1,1246 # ffffffffc02018a0 <etext+0x17a>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003ca:	00840a13          	addi	s4,s0,8
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003ce:	31e010ef          	jal	ffffffffc02016ec <strncmp>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003d2:	2c81                	sext.w	s9,s9
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003d4:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003d8:	9a66                	add	s4,s4,s9
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003da:	00abe533          	or	a0,s7,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003de:	ffca7a13          	andi	s4,s4,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e2:	00050b9b          	sext.w	s7,a0
        switch (token) {
ffffffffc02003e6:	8452                	mv	s0,s4
ffffffffc02003e8:	b7a1                	j	ffffffffc0200330 <dtb_init+0x102>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02003ea:	405c                	lw	a5,4(s0)
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02003ec:	00c40a13          	addi	s4,s0,12
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02003f0:	0107d71b          	srliw	a4,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02003f4:	0087d69b          	srliw	a3,a5,0x8
ffffffffc02003f8:	01879c9b          	slliw	s9,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02003fc:	0087171b          	slliw	a4,a4,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200400:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200404:	0187d79b          	srliw	a5,a5,0x18
ffffffffc0200408:	1742                	slli	a4,a4,0x30
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020040a:	0156f6b3          	and	a3,a3,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020040e:	00fcecb3          	or	s9,s9,a5
ffffffffc0200412:	9341                	srli	a4,a4,0x30
ffffffffc0200414:	00dcecb3          	or	s9,s9,a3
ffffffffc0200418:	00ececb3          	or	s9,s9,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020041c:	000b9b63          	bnez	s7,ffffffffc0200432 <dtb_init+0x204>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200420:	1c82                	slli	s9,s9,0x20
ffffffffc0200422:	020cdc93          	srli	s9,s9,0x20
ffffffffc0200426:	0a0d                	addi	s4,s4,3
ffffffffc0200428:	9a66                	add	s4,s4,s9
ffffffffc020042a:	ffca7a13          	andi	s4,s4,-4
        switch (token) {
ffffffffc020042e:	8452                	mv	s0,s4
ffffffffc0200430:	b701                	j	ffffffffc0200330 <dtb_init+0x102>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200432:	441c                	lw	a5,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200434:	00001597          	auipc	a1,0x1
ffffffffc0200438:	47458593          	addi	a1,a1,1140 # ffffffffc02018a8 <etext+0x182>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020043c:	0087d69b          	srliw	a3,a5,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200440:	0107d71b          	srliw	a4,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200444:	0187951b          	slliw	a0,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200448:	0087171b          	slliw	a4,a4,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020044c:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200450:	0187d79b          	srliw	a5,a5,0x18
ffffffffc0200454:	1742                	slli	a4,a4,0x30
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200456:	0156f6b3          	and	a3,a3,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020045a:	8d5d                	or	a0,a0,a5
ffffffffc020045c:	9341                	srli	a4,a4,0x30
ffffffffc020045e:	8d55                	or	a0,a0,a3
ffffffffc0200460:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200462:	1502                	slli	a0,a0,0x20
ffffffffc0200464:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200466:	9526                	add	a0,a0,s1
ffffffffc0200468:	24c010ef          	jal	ffffffffc02016b4 <strcmp>
ffffffffc020046c:	f955                	bnez	a0,ffffffffc0200420 <dtb_init+0x1f2>
ffffffffc020046e:	47bd                	li	a5,15
ffffffffc0200470:	fb97f8e3          	bgeu	a5,s9,ffffffffc0200420 <dtb_init+0x1f2>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200474:	00c43703          	ld	a4,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc0200478:	01443783          	ld	a5,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020047c:	00001517          	auipc	a0,0x1
ffffffffc0200480:	43450513          	addi	a0,a0,1076 # ffffffffc02018b0 <etext+0x18a>
           fdt32_to_cpu(x >> 32);
ffffffffc0200484:	42075813          	srai	a6,a4,0x20
ffffffffc0200488:	4207d593          	srai	a1,a5,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020048c:	01085e9b          	srliw	t4,a6,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200490:	02875613          	srli	a2,a4,0x28
ffffffffc0200494:	0287d693          	srli	a3,a5,0x28
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200498:	00070e1b          	sext.w	t3,a4
ffffffffc020049c:	0007889b          	sext.w	a7,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a0:	01859f9b          	slliw	t6,a1,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a4:	0105d31b          	srliw	t1,a1,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004a8:	0188139b          	slliw	t2,a6,0x18
ffffffffc02004ac:	0106969b          	slliw	a3,a3,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004b0:	0188581b          	srliw	a6,a6,0x18
ffffffffc02004b4:	0185df1b          	srliw	t5,a1,0x18
ffffffffc02004b8:	008e9e9b          	slliw	t4,t4,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004bc:	0106161b          	slliw	a2,a2,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c0:	010e529b          	srliw	t0,t3,0x10
ffffffffc02004c4:	0103e3b3          	or	t2,t2,a6
ffffffffc02004c8:	01efef33          	or	t5,t6,t5
ffffffffc02004cc:	0108d59b          	srliw	a1,a7,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004d0:	01567633          	and	a2,a2,s5
ffffffffc02004d4:	0087549b          	srliw	s1,a4,0x8
ffffffffc02004d8:	0087d41b          	srliw	s0,a5,0x8
ffffffffc02004dc:	0156f733          	and	a4,a3,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e0:	0083131b          	slliw	t1,t1,0x8
ffffffffc02004e4:	1ec2                	slli	t4,t4,0x30
ffffffffc02004e6:	007666b3          	or	a3,a2,t2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ea:	018e1f9b          	slliw	t6,t3,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ee:	030ede93          	srli	t4,t4,0x30
ffffffffc02004f2:	0082981b          	slliw	a6,t0,0x8
ffffffffc02004f6:	018e5e1b          	srliw	t3,t3,0x18
ffffffffc02004fa:	01e767b3          	or	a5,a4,t5
ffffffffc02004fe:	0085959b          	slliw	a1,a1,0x8
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200502:	01889f1b          	slliw	t5,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200506:	1342                	slli	t1,t1,0x30
ffffffffc0200508:	0188d89b          	srliw	a7,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020050c:	0104949b          	slliw	s1,s1,0x10
ffffffffc0200510:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200514:	01d6e733          	or	a4,a3,t4
ffffffffc0200518:	03035313          	srli	t1,t1,0x30
ffffffffc020051c:	011f66b3          	or	a3,t5,a7
ffffffffc0200520:	03059613          	slli	a2,a1,0x30
ffffffffc0200524:	1842                	slli	a6,a6,0x30
ffffffffc0200526:	01cfe5b3          	or	a1,t6,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052a:	0154f4b3          	and	s1,s1,s5
ffffffffc020052e:	01547433          	and	s0,s0,s5
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200532:	03085813          	srli	a6,a6,0x30
ffffffffc0200536:	0067e7b3          	or	a5,a5,t1
ffffffffc020053a:	8c55                	or	s0,s0,a3
ffffffffc020053c:	9241                	srli	a2,a2,0x30
ffffffffc020053e:	8ccd                	or	s1,s1,a1
ffffffffc0200540:	0104e4b3          	or	s1,s1,a6
ffffffffc0200544:	8c51                	or	s0,s0,a2
           fdt32_to_cpu(x >> 32);
ffffffffc0200546:	1702                	slli	a4,a4,0x20
ffffffffc0200548:	1782                	slli	a5,a5,0x20
ffffffffc020054a:	9381                	srli	a5,a5,0x20
ffffffffc020054c:	9301                	srli	a4,a4,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020054e:	1482                	slli	s1,s1,0x20
ffffffffc0200550:	1402                	slli	s0,s0,0x20
ffffffffc0200552:	8c5d                	or	s0,s0,a5
ffffffffc0200554:	8cd9                	or	s1,s1,a4
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200556:	bf5ff0ef          	jal	ffffffffc020014a <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020055a:	85a6                	mv	a1,s1
ffffffffc020055c:	00001517          	auipc	a0,0x1
ffffffffc0200560:	37450513          	addi	a0,a0,884 # ffffffffc02018d0 <etext+0x1aa>
ffffffffc0200564:	be7ff0ef          	jal	ffffffffc020014a <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200568:	01445613          	srli	a2,s0,0x14
ffffffffc020056c:	85a2                	mv	a1,s0
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	37a50513          	addi	a0,a0,890 # ffffffffc02018e8 <etext+0x1c2>
ffffffffc0200576:	bd5ff0ef          	jal	ffffffffc020014a <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020057a:	009405b3          	add	a1,s0,s1
ffffffffc020057e:	15fd                	addi	a1,a1,-1
ffffffffc0200580:	00001517          	auipc	a0,0x1
ffffffffc0200584:	38850513          	addi	a0,a0,904 # ffffffffc0201908 <etext+0x1e2>
ffffffffc0200588:	bc3ff0ef          	jal	ffffffffc020014a <cprintf>
        memory_base = mem_base;
ffffffffc020058c:	00006797          	auipc	a5,0x6
ffffffffc0200590:	aa97ba23          	sd	s1,-1356(a5) # ffffffffc0206040 <memory_base>
        memory_size = mem_size;
ffffffffc0200594:	00006797          	auipc	a5,0x6
ffffffffc0200598:	aa87b223          	sd	s0,-1372(a5) # ffffffffc0206038 <memory_size>
ffffffffc020059c:	b3dd                	j	ffffffffc0200382 <dtb_init+0x154>

ffffffffc020059e <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020059e:	00006517          	auipc	a0,0x6
ffffffffc02005a2:	aa253503          	ld	a0,-1374(a0) # ffffffffc0206040 <memory_base>
ffffffffc02005a6:	8082                	ret

ffffffffc02005a8 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc02005a8:	00006517          	auipc	a0,0x6
ffffffffc02005ac:	a9053503          	ld	a0,-1392(a0) # ffffffffc0206038 <memory_size>
ffffffffc02005b0:	8082                	ret

ffffffffc02005b2 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02005b2:	00006797          	auipc	a5,0x6
ffffffffc02005b6:	a6678793          	addi	a5,a5,-1434 # ffffffffc0206018 <free_area>
ffffffffc02005ba:	e79c                	sd	a5,8(a5)
ffffffffc02005bc:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02005be:	0007a823          	sw	zero,16(a5)
}
ffffffffc02005c2:	8082                	ret

ffffffffc02005c4 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02005c4:	00006517          	auipc	a0,0x6
ffffffffc02005c8:	a6456503          	lwu	a0,-1436(a0) # ffffffffc0206028 <free_area+0x10>
ffffffffc02005cc:	8082                	ret

ffffffffc02005ce <insert_free_block>:
    SetPageProperty(base);
ffffffffc02005ce:	00853803          	ld	a6,8(a0)
    nr_free += n;
ffffffffc02005d2:	00006717          	auipc	a4,0x6
ffffffffc02005d6:	a5672703          	lw	a4,-1450(a4) # ffffffffc0206028 <free_area+0x10>
insert_free_block(struct Page *base, size_t n) {
ffffffffc02005da:	1141                	addi	sp,sp,-16
    nr_free += n;
ffffffffc02005dc:	00006697          	auipc	a3,0x6
ffffffffc02005e0:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0206018 <free_area>
insert_free_block(struct Page *base, size_t n) {
ffffffffc02005e4:	e406                	sd	ra,8(sp)
    base->property = n;
ffffffffc02005e6:	2581                	sext.w	a1,a1
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02005e8:	669c                	ld	a5,8(a3)
    SetPageProperty(base);
ffffffffc02005ea:	00286613          	ori	a2,a6,2
    base->property = n;
ffffffffc02005ee:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02005f0:	e510                	sd	a2,8(a0)
    nr_free += n;
ffffffffc02005f2:	9f2d                	addw	a4,a4,a1
ffffffffc02005f4:	ca98                	sw	a4,16(a3)
    while (le != &free_list && le2page(le, page_link) < base) {
ffffffffc02005f6:	00d79663          	bne	a5,a3,ffffffffc0200602 <insert_free_block+0x34>
ffffffffc02005fa:	a06d                	j	ffffffffc02006a4 <insert_free_block+0xd6>
ffffffffc02005fc:	679c                	ld	a5,8(a5)
ffffffffc02005fe:	00d78663          	beq	a5,a3,ffffffffc020060a <insert_free_block+0x3c>
ffffffffc0200602:	fe878713          	addi	a4,a5,-24
ffffffffc0200606:	fea76be3          	bltu	a4,a0,ffffffffc02005fc <insert_free_block+0x2e>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020060a:	6390                	ld	a2,0(a5)
    list_add_before(le, &base->page_link);
ffffffffc020060c:	01850713          	addi	a4,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200610:	e398                	sd	a4,0(a5)
ffffffffc0200612:	e618                	sd	a4,8(a2)
    elm->next = next;
    elm->prev = prev;
ffffffffc0200614:	ed10                	sd	a2,24(a0)
    elm->next = next;
ffffffffc0200616:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc0200618:	02d60363          	beq	a2,a3,ffffffffc020063e <insert_free_block+0x70>
        assert(prev + prev->property <= base);
ffffffffc020061c:	ff862e03          	lw	t3,-8(a2)
        struct Page *prev = le2page(le, page_link);
ffffffffc0200620:	fe860313          	addi	t1,a2,-24
        assert(prev + prev->property <= base);
ffffffffc0200624:	020e1893          	slli	a7,t3,0x20
ffffffffc0200628:	0208d893          	srli	a7,a7,0x20
ffffffffc020062c:	00289713          	slli	a4,a7,0x2
ffffffffc0200630:	9746                	add	a4,a4,a7
ffffffffc0200632:	070e                	slli	a4,a4,0x3
ffffffffc0200634:	971a                	add	a4,a4,t1
ffffffffc0200636:	08e56163          	bltu	a0,a4,ffffffffc02006b8 <insert_free_block+0xea>
        if (prev + prev->property == base) {
ffffffffc020063a:	02a70663          	beq	a4,a0,ffffffffc0200666 <insert_free_block+0x98>
    if (le != &free_list) {
ffffffffc020063e:	02d78163          	beq	a5,a3,ffffffffc0200660 <insert_free_block+0x92>
        assert(base + base->property <= next);
ffffffffc0200642:	490c                	lw	a1,16(a0)
        struct Page *next = le2page(le, page_link);
ffffffffc0200644:	fe878693          	addi	a3,a5,-24
        assert(base + base->property <= next);
ffffffffc0200648:	02059613          	slli	a2,a1,0x20
ffffffffc020064c:	9201                	srli	a2,a2,0x20
ffffffffc020064e:	00261713          	slli	a4,a2,0x2
ffffffffc0200652:	9732                	add	a4,a4,a2
ffffffffc0200654:	070e                	slli	a4,a4,0x3
ffffffffc0200656:	972a                	add	a4,a4,a0
ffffffffc0200658:	08e6e063          	bltu	a3,a4,ffffffffc02006d8 <insert_free_block+0x10a>
        if (base + base->property == next) {
ffffffffc020065c:	02d70163          	beq	a4,a3,ffffffffc020067e <insert_free_block+0xb0>
}
ffffffffc0200660:	60a2                	ld	ra,8(sp)
ffffffffc0200662:	0141                	addi	sp,sp,16
ffffffffc0200664:	8082                	ret
            prev->property += base->property;
ffffffffc0200666:	01c585bb          	addw	a1,a1,t3
ffffffffc020066a:	feb62c23          	sw	a1,-8(a2)
            ClearPageProperty(base);
ffffffffc020066e:	ffd87813          	andi	a6,a6,-3
ffffffffc0200672:	01053423          	sd	a6,8(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200676:	e61c                	sd	a5,8(a2)
    next->prev = prev;
ffffffffc0200678:	e390                	sd	a2,0(a5)
            base = prev;
ffffffffc020067a:	851a                	mv	a0,t1
ffffffffc020067c:	b7c9                	j	ffffffffc020063e <insert_free_block+0x70>
            base->property += next->property;
ffffffffc020067e:	ff87a683          	lw	a3,-8(a5)
            ClearPageProperty(next);
ffffffffc0200682:	ff07b703          	ld	a4,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200686:	0007b803          	ld	a6,0(a5)
ffffffffc020068a:	6790                	ld	a2,8(a5)
            base->property += next->property;
ffffffffc020068c:	9ead                	addw	a3,a3,a1
ffffffffc020068e:	c914                	sw	a3,16(a0)
            ClearPageProperty(next);
ffffffffc0200690:	9b75                	andi	a4,a4,-3
ffffffffc0200692:	fee7b823          	sd	a4,-16(a5)
}
ffffffffc0200696:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0200698:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020069c:	01063023          	sd	a6,0(a2)
ffffffffc02006a0:	0141                	addi	sp,sp,16
ffffffffc02006a2:	8082                	ret
    __list_add(elm, listelm->prev, listelm);
ffffffffc02006a4:	6390                	ld	a2,0(a5)
    list_add_before(le, &base->page_link);
ffffffffc02006a6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02006aa:	e398                	sd	a4,0(a5)
ffffffffc02006ac:	e618                	sd	a4,8(a2)
    elm->prev = prev;
ffffffffc02006ae:	ed10                	sd	a2,24(a0)
    elm->next = next;
ffffffffc02006b0:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc02006b2:	f6f615e3          	bne	a2,a5,ffffffffc020061c <insert_free_block+0x4e>
ffffffffc02006b6:	b76d                	j	ffffffffc0200660 <insert_free_block+0x92>
        assert(prev + prev->property <= base);
ffffffffc02006b8:	00001697          	auipc	a3,0x1
ffffffffc02006bc:	2b868693          	addi	a3,a3,696 # ffffffffc0201970 <etext+0x24a>
ffffffffc02006c0:	00001617          	auipc	a2,0x1
ffffffffc02006c4:	2d060613          	addi	a2,a2,720 # ffffffffc0201990 <etext+0x26a>
ffffffffc02006c8:	02100593          	li	a1,33
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	2dc50513          	addi	a0,a0,732 # ffffffffc02019a8 <etext+0x282>
ffffffffc02006d4:	af9ff0ef          	jal	ffffffffc02001cc <__panic>
        assert(base + base->property <= next);
ffffffffc02006d8:	00001697          	auipc	a3,0x1
ffffffffc02006dc:	2e868693          	addi	a3,a3,744 # ffffffffc02019c0 <etext+0x29a>
ffffffffc02006e0:	00001617          	auipc	a2,0x1
ffffffffc02006e4:	2b060613          	addi	a2,a2,688 # ffffffffc0201990 <etext+0x26a>
ffffffffc02006e8:	02d00593          	li	a1,45
ffffffffc02006ec:	00001517          	auipc	a0,0x1
ffffffffc02006f0:	2bc50513          	addi	a0,a0,700 # ffffffffc02019a8 <etext+0x282>
ffffffffc02006f4:	ad9ff0ef          	jal	ffffffffc02001cc <__panic>

ffffffffc02006f8 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc02006f8:	c175                	beqz	a0,ffffffffc02007dc <best_fit_alloc_pages+0xe4>
    if (n > nr_free) {
ffffffffc02006fa:	00006897          	auipc	a7,0x6
ffffffffc02006fe:	92e8a883          	lw	a7,-1746(a7) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200702:	862a                	mv	a2,a0
ffffffffc0200704:	00006597          	auipc	a1,0x6
ffffffffc0200708:	91458593          	addi	a1,a1,-1772 # ffffffffc0206018 <free_area>
ffffffffc020070c:	02089793          	slli	a5,a7,0x20
ffffffffc0200710:	9381                	srli	a5,a5,0x20
ffffffffc0200712:	0ca7e363          	bltu	a5,a0,ffffffffc02007d8 <best_fit_alloc_pages+0xe0>
    return listelm->next;
ffffffffc0200716:	659c                	ld	a5,8(a1)
    struct Page *best = NULL;
ffffffffc0200718:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc020071a:	0ab78e63          	beq	a5,a1,ffffffffc02007d6 <best_fit_alloc_pages+0xde>
        if (p->property >= n &&
ffffffffc020071e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200722:	02071693          	slli	a3,a4,0x20
ffffffffc0200726:	9281                	srli	a3,a3,0x20
ffffffffc0200728:	04c6e963          	bltu	a3,a2,ffffffffc020077a <best_fit_alloc_pages+0x82>
ffffffffc020072c:	e90d                	bnez	a0,ffffffffc020075e <best_fit_alloc_pages+0x66>
        struct Page *p = le2page(le, page_link);
ffffffffc020072e:	fe878513          	addi	a0,a5,-24
            if (p->property == n) {
ffffffffc0200732:	04d60863          	beq	a2,a3,ffffffffc0200782 <best_fit_alloc_pages+0x8a>
ffffffffc0200736:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200738:	04b78563          	beq	a5,a1,ffffffffc0200782 <best_fit_alloc_pages+0x8a>
        if (p->property >= n &&
ffffffffc020073c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200740:	02071693          	slli	a3,a4,0x20
ffffffffc0200744:	9281                	srli	a3,a3,0x20
ffffffffc0200746:	00c6fc63          	bgeu	a3,a2,ffffffffc020075e <best_fit_alloc_pages+0x66>
ffffffffc020074a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020074c:	02b78a63          	beq	a5,a1,ffffffffc0200780 <best_fit_alloc_pages+0x88>
        if (p->property >= n &&
ffffffffc0200750:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200754:	02071693          	slli	a3,a4,0x20
ffffffffc0200758:	9281                	srli	a3,a3,0x20
ffffffffc020075a:	02c6e063          	bltu	a3,a2,ffffffffc020077a <best_fit_alloc_pages+0x82>
            (best == NULL || p->property < best->property)) {
ffffffffc020075e:	01052803          	lw	a6,16(a0)
ffffffffc0200762:	fd0766e3          	bltu	a4,a6,ffffffffc020072e <best_fit_alloc_pages+0x36>
ffffffffc0200766:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200768:	00b78d63          	beq	a5,a1,ffffffffc0200782 <best_fit_alloc_pages+0x8a>
        if (p->property >= n &&
ffffffffc020076c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200770:	02071693          	slli	a3,a4,0x20
ffffffffc0200774:	9281                	srli	a3,a3,0x20
ffffffffc0200776:	fec6f6e3          	bgeu	a3,a2,ffffffffc0200762 <best_fit_alloc_pages+0x6a>
ffffffffc020077a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020077c:	fab791e3          	bne	a5,a1,ffffffffc020071e <best_fit_alloc_pages+0x26>
    if (best == NULL) {
ffffffffc0200780:	c939                	beqz	a0,ffffffffc02007d6 <best_fit_alloc_pages+0xde>
    size_t block_size = best->property;
ffffffffc0200782:	01052803          	lw	a6,16(a0)
ffffffffc0200786:	7114                	ld	a3,32(a0)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200788:	6d18                	ld	a4,24(a0)
ffffffffc020078a:	02081793          	slli	a5,a6,0x20
ffffffffc020078e:	9381                	srli	a5,a5,0x20
    prev->next = next;
ffffffffc0200790:	e714                	sd	a3,8(a4)
    next->prev = prev;
ffffffffc0200792:	e298                	sd	a4,0(a3)
        remainder->property = block_size - n;
ffffffffc0200794:	0006031b          	sext.w	t1,a2
    if (block_size > n) {
ffffffffc0200798:	02f67563          	bgeu	a2,a5,ffffffffc02007c2 <best_fit_alloc_pages+0xca>
        struct Page *remainder = best + n;
ffffffffc020079c:	00261793          	slli	a5,a2,0x2
ffffffffc02007a0:	97b2                	add	a5,a5,a2
ffffffffc02007a2:	078e                	slli	a5,a5,0x3
ffffffffc02007a4:	97aa                	add	a5,a5,a0
        SetPageProperty(remainder);
ffffffffc02007a6:	6790                	ld	a2,8(a5)
        remainder->property = block_size - n;
ffffffffc02007a8:	4068083b          	subw	a6,a6,t1
ffffffffc02007ac:	0107a823          	sw	a6,16(a5)
        SetPageProperty(remainder);
ffffffffc02007b0:	00266613          	ori	a2,a2,2
ffffffffc02007b4:	e790                	sd	a2,8(a5)
        list_add_before(le, &remainder->page_link);
ffffffffc02007b6:	01878613          	addi	a2,a5,24
    prev->next = next->prev = elm;
ffffffffc02007ba:	e290                	sd	a2,0(a3)
ffffffffc02007bc:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02007be:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02007c0:	ef98                	sd	a4,24(a5)
    ClearPageProperty(best);
ffffffffc02007c2:	651c                	ld	a5,8(a0)
    best->property = 0;
ffffffffc02007c4:	00052823          	sw	zero,16(a0)
    nr_free -= n;
ffffffffc02007c8:	406888bb          	subw	a7,a7,t1
    ClearPageProperty(best);
ffffffffc02007cc:	9bf5                	andi	a5,a5,-3
ffffffffc02007ce:	e51c                	sd	a5,8(a0)
    nr_free -= n;
ffffffffc02007d0:	0115a823          	sw	a7,16(a1)
    return best;
ffffffffc02007d4:	8082                	ret
}
ffffffffc02007d6:	8082                	ret
        return NULL;
ffffffffc02007d8:	4501                	li	a0,0
ffffffffc02007da:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02007dc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02007de:	00001697          	auipc	a3,0x1
ffffffffc02007e2:	20268693          	addi	a3,a3,514 # ffffffffc02019e0 <etext+0x2ba>
ffffffffc02007e6:	00001617          	auipc	a2,0x1
ffffffffc02007ea:	1aa60613          	addi	a2,a2,426 # ffffffffc0201990 <etext+0x26a>
ffffffffc02007ee:	04300593          	li	a1,67
ffffffffc02007f2:	00001517          	auipc	a0,0x1
ffffffffc02007f6:	1b650513          	addi	a0,a0,438 # ffffffffc02019a8 <etext+0x282>
best_fit_alloc_pages(size_t n) {
ffffffffc02007fa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02007fc:	9d1ff0ef          	jal	ffffffffc02001cc <__panic>

ffffffffc0200800 <best_fit_check>:
    free_page(p1);
    free_page(p2);
}

static void
best_fit_check(void) {
ffffffffc0200800:	715d                	addi	sp,sp,-80
ffffffffc0200802:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc0200804:	00006917          	auipc	s2,0x6
ffffffffc0200808:	81490913          	addi	s2,s2,-2028 # ffffffffc0206018 <free_area>
ffffffffc020080c:	00893783          	ld	a5,8(s2)
ffffffffc0200810:	e486                	sd	ra,72(sp)
ffffffffc0200812:	e0a2                	sd	s0,64(sp)
ffffffffc0200814:	fc26                	sd	s1,56(sp)
ffffffffc0200816:	f44e                	sd	s3,40(sp)
ffffffffc0200818:	f052                	sd	s4,32(sp)
ffffffffc020081a:	ec56                	sd	s5,24(sp)
ffffffffc020081c:	e85a                	sd	s6,16(sp)
ffffffffc020081e:	e45e                	sd	s7,8(sp)
ffffffffc0200820:	e062                	sd	s8,0(sp)
    int score = 0, sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200822:	29278f63          	beq	a5,s2,ffffffffc0200ac0 <best_fit_check+0x2c0>
    int count = 0, total = 0;
ffffffffc0200826:	4401                	li	s0,0
ffffffffc0200828:	4481                	li	s1,0
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020082a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020082e:	8b09                	andi	a4,a4,2
ffffffffc0200830:	28070c63          	beqz	a4,ffffffffc0200ac8 <best_fit_check+0x2c8>
        count++, total += p->property;
ffffffffc0200834:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200838:	679c                	ld	a5,8(a5)
ffffffffc020083a:	2485                	addiw	s1,s1,1
ffffffffc020083c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020083e:	ff2796e3          	bne	a5,s2,ffffffffc020082a <best_fit_check+0x2a>
    }
    assert(total == nr_free_pages());
ffffffffc0200842:	89a2                	mv	s3,s0
ffffffffc0200844:	7ac000ef          	jal	ffffffffc0200ff0 <nr_free_pages>
ffffffffc0200848:	37351063          	bne	a0,s3,ffffffffc0200ba8 <best_fit_check+0x3a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020084c:	4505                	li	a0,1
ffffffffc020084e:	78a000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200852:	8a2a                	mv	s4,a0
ffffffffc0200854:	38050a63          	beqz	a0,ffffffffc0200be8 <best_fit_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200858:	4505                	li	a0,1
ffffffffc020085a:	77e000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc020085e:	89aa                	mv	s3,a0
ffffffffc0200860:	36050463          	beqz	a0,ffffffffc0200bc8 <best_fit_check+0x3c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200864:	4505                	li	a0,1
ffffffffc0200866:	772000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc020086a:	8aaa                	mv	s5,a0
ffffffffc020086c:	2e050e63          	beqz	a0,ffffffffc0200b68 <best_fit_check+0x368>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200870:	273a0c63          	beq	s4,s3,ffffffffc0200ae8 <best_fit_check+0x2e8>
ffffffffc0200874:	26aa0a63          	beq	s4,a0,ffffffffc0200ae8 <best_fit_check+0x2e8>
ffffffffc0200878:	26a98863          	beq	s3,a0,ffffffffc0200ae8 <best_fit_check+0x2e8>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020087c:	000a2783          	lw	a5,0(s4)
ffffffffc0200880:	28079463          	bnez	a5,ffffffffc0200b08 <best_fit_check+0x308>
ffffffffc0200884:	0009a783          	lw	a5,0(s3)
ffffffffc0200888:	28079063          	bnez	a5,ffffffffc0200b08 <best_fit_check+0x308>
ffffffffc020088c:	411c                	lw	a5,0(a0)
ffffffffc020088e:	26079d63          	bnez	a5,ffffffffc0200b08 <best_fit_check+0x308>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200892:	00005797          	auipc	a5,0x5
ffffffffc0200896:	7de7b783          	ld	a5,2014(a5) # ffffffffc0206070 <pages>
ffffffffc020089a:	ccccd6b7          	lui	a3,0xccccd
ffffffffc020089e:	ccd68693          	addi	a3,a3,-819 # ffffffffcccccccd <end+0xcac6c55>
ffffffffc02008a2:	02069613          	slli	a2,a3,0x20
ffffffffc02008a6:	40fa0733          	sub	a4,s4,a5
ffffffffc02008aa:	9636                	add	a2,a2,a3
ffffffffc02008ac:	870d                	srai	a4,a4,0x3
ffffffffc02008ae:	02c70733          	mul	a4,a4,a2
ffffffffc02008b2:	00002597          	auipc	a1,0x2
ffffffffc02008b6:	88e5b583          	ld	a1,-1906(a1) # ffffffffc0202140 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008ba:	00005697          	auipc	a3,0x5
ffffffffc02008be:	7ae6b683          	ld	a3,1966(a3) # ffffffffc0206068 <npage>
ffffffffc02008c2:	06b2                	slli	a3,a3,0xc
ffffffffc02008c4:	972e                	add	a4,a4,a1

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008c6:	0732                	slli	a4,a4,0xc
ffffffffc02008c8:	26d77063          	bgeu	a4,a3,ffffffffc0200b28 <best_fit_check+0x328>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008cc:	40f98733          	sub	a4,s3,a5
ffffffffc02008d0:	870d                	srai	a4,a4,0x3
ffffffffc02008d2:	02c70733          	mul	a4,a4,a2
ffffffffc02008d6:	972e                	add	a4,a4,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc02008d8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008da:	40d77763          	bgeu	a4,a3,ffffffffc0200ce8 <best_fit_check+0x4e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008de:	40f507b3          	sub	a5,a0,a5
ffffffffc02008e2:	878d                	srai	a5,a5,0x3
ffffffffc02008e4:	02c787b3          	mul	a5,a5,a2
ffffffffc02008e8:	97ae                	add	a5,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc02008ea:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02008ec:	3cd7fe63          	bgeu	a5,a3,ffffffffc0200cc8 <best_fit_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc02008f0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02008f2:	00093c03          	ld	s8,0(s2)
ffffffffc02008f6:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02008fa:	00005b17          	auipc	s6,0x5
ffffffffc02008fe:	72eb2b03          	lw	s6,1838(s6) # ffffffffc0206028 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200902:	01293023          	sd	s2,0(s2)
ffffffffc0200906:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc020090a:	00005797          	auipc	a5,0x5
ffffffffc020090e:	7007af23          	sw	zero,1822(a5) # ffffffffc0206028 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200912:	6c6000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200916:	38051963          	bnez	a0,ffffffffc0200ca8 <best_fit_check+0x4a8>
    free_page(p0);
ffffffffc020091a:	8552                	mv	a0,s4
ffffffffc020091c:	4585                	li	a1,1
ffffffffc020091e:	6c6000ef          	jal	ffffffffc0200fe4 <free_pages>
    free_page(p1);
ffffffffc0200922:	854e                	mv	a0,s3
ffffffffc0200924:	4585                	li	a1,1
ffffffffc0200926:	6be000ef          	jal	ffffffffc0200fe4 <free_pages>
    free_page(p2);
ffffffffc020092a:	8556                	mv	a0,s5
ffffffffc020092c:	4585                	li	a1,1
ffffffffc020092e:	6b6000ef          	jal	ffffffffc0200fe4 <free_pages>
    assert(nr_free == 3);
ffffffffc0200932:	00005717          	auipc	a4,0x5
ffffffffc0200936:	6f672703          	lw	a4,1782(a4) # ffffffffc0206028 <free_area+0x10>
ffffffffc020093a:	478d                	li	a5,3
ffffffffc020093c:	34f71663          	bne	a4,a5,ffffffffc0200c88 <best_fit_check+0x488>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200940:	4505                	li	a0,1
ffffffffc0200942:	696000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200946:	89aa                	mv	s3,a0
ffffffffc0200948:	32050063          	beqz	a0,ffffffffc0200c68 <best_fit_check+0x468>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020094c:	4505                	li	a0,1
ffffffffc020094e:	68a000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200952:	8aaa                	mv	s5,a0
ffffffffc0200954:	2e050a63          	beqz	a0,ffffffffc0200c48 <best_fit_check+0x448>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200958:	4505                	li	a0,1
ffffffffc020095a:	67e000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc020095e:	8a2a                	mv	s4,a0
ffffffffc0200960:	2c050463          	beqz	a0,ffffffffc0200c28 <best_fit_check+0x428>
    assert(alloc_page() == NULL);
ffffffffc0200964:	4505                	li	a0,1
ffffffffc0200966:	672000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc020096a:	28051f63          	bnez	a0,ffffffffc0200c08 <best_fit_check+0x408>
    free_page(p0);
ffffffffc020096e:	4585                	li	a1,1
ffffffffc0200970:	854e                	mv	a0,s3
ffffffffc0200972:	672000ef          	jal	ffffffffc0200fe4 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200976:	00893783          	ld	a5,8(s2)
ffffffffc020097a:	1d278763          	beq	a5,s2,ffffffffc0200b48 <best_fit_check+0x348>
    assert((p = alloc_page()) == p0);
ffffffffc020097e:	4505                	li	a0,1
ffffffffc0200980:	658000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200984:	54a99263          	bne	s3,a0,ffffffffc0200ec8 <best_fit_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200988:	4505                	li	a0,1
ffffffffc020098a:	64e000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc020098e:	50051d63          	bnez	a0,ffffffffc0200ea8 <best_fit_check+0x6a8>
    assert(nr_free == 0);
ffffffffc0200992:	00005797          	auipc	a5,0x5
ffffffffc0200996:	6967a783          	lw	a5,1686(a5) # ffffffffc0206028 <free_area+0x10>
ffffffffc020099a:	4e079763          	bnez	a5,ffffffffc0200e88 <best_fit_check+0x688>
    free_page(p);
ffffffffc020099e:	854e                	mv	a0,s3
ffffffffc02009a0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009a2:	01893023          	sd	s8,0(s2)
ffffffffc02009a6:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc02009aa:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc02009ae:	636000ef          	jal	ffffffffc0200fe4 <free_pages>
    free_page(p1);
ffffffffc02009b2:	8556                	mv	a0,s5
ffffffffc02009b4:	4585                	li	a1,1
ffffffffc02009b6:	62e000ef          	jal	ffffffffc0200fe4 <free_pages>
    free_page(p2);
ffffffffc02009ba:	8552                	mv	a0,s4
ffffffffc02009bc:	4585                	li	a1,1
ffffffffc02009be:	626000ef          	jal	ffffffffc0200fe4 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n", score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02009c2:	4515                	li	a0,5
ffffffffc02009c4:	614000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc02009c8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009ca:	48050f63          	beqz	a0,ffffffffc0200e68 <best_fit_check+0x668>
    assert(!PageProperty(p0));
ffffffffc02009ce:	651c                	ld	a5,8(a0)
ffffffffc02009d0:	8b89                	andi	a5,a5,2
ffffffffc02009d2:	46079b63          	bnez	a5,ffffffffc0200e48 <best_fit_check+0x648>
    cprintf("grading: %d / %d points\n", score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02009d6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009d8:	00093b03          	ld	s6,0(s2)
ffffffffc02009dc:	00893a83          	ld	s5,8(s2)
ffffffffc02009e0:	01293023          	sd	s2,0(s2)
ffffffffc02009e4:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc02009e8:	5f0000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc02009ec:	42051e63          	bnez	a0,ffffffffc0200e28 <best_fit_check+0x628>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc02009f0:	4589                	li	a1,2
ffffffffc02009f2:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc02009f6:	00005b97          	auipc	s7,0x5
ffffffffc02009fa:	632bab83          	lw	s7,1586(s7) # ffffffffc0206028 <free_area+0x10>
    free_pages(p0 + 4, 1);
ffffffffc02009fe:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200a02:	00005797          	auipc	a5,0x5
ffffffffc0200a06:	6207a323          	sw	zero,1574(a5) # ffffffffc0206028 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200a0a:	5da000ef          	jal	ffffffffc0200fe4 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200a0e:	8562                	mv	a0,s8
ffffffffc0200a10:	4585                	li	a1,1
ffffffffc0200a12:	5d2000ef          	jal	ffffffffc0200fe4 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a16:	4511                	li	a0,4
ffffffffc0200a18:	5c0000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200a1c:	3e051663          	bnez	a0,ffffffffc0200e08 <best_fit_check+0x608>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200a20:	0309b783          	ld	a5,48(s3)
ffffffffc0200a24:	8b89                	andi	a5,a5,2
ffffffffc0200a26:	3c078163          	beqz	a5,ffffffffc0200de8 <best_fit_check+0x5e8>
ffffffffc0200a2a:	0389a703          	lw	a4,56(s3)
ffffffffc0200a2e:	4789                	li	a5,2
ffffffffc0200a30:	3af71c63          	bne	a4,a5,ffffffffc0200de8 <best_fit_check+0x5e8>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200a34:	4505                	li	a0,1
ffffffffc0200a36:	5a2000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200a3a:	8a2a                	mv	s4,a0
ffffffffc0200a3c:	38050663          	beqz	a0,ffffffffc0200dc8 <best_fit_check+0x5c8>
    assert(alloc_pages(2) != NULL);
ffffffffc0200a40:	4509                	li	a0,2
ffffffffc0200a42:	596000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200a46:	36050163          	beqz	a0,ffffffffc0200da8 <best_fit_check+0x5a8>
    assert(p0 + 4 == p1);
ffffffffc0200a4a:	334c1f63          	bne	s8,s4,ffffffffc0200d88 <best_fit_check+0x588>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n", score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200a4e:	854e                	mv	a0,s3
ffffffffc0200a50:	4595                	li	a1,5
ffffffffc0200a52:	592000ef          	jal	ffffffffc0200fe4 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200a56:	4515                	li	a0,5
ffffffffc0200a58:	580000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200a5c:	89aa                	mv	s3,a0
ffffffffc0200a5e:	30050563          	beqz	a0,ffffffffc0200d68 <best_fit_check+0x568>
    assert(alloc_page() == NULL);
ffffffffc0200a62:	4505                	li	a0,1
ffffffffc0200a64:	574000ef          	jal	ffffffffc0200fd8 <alloc_pages>
ffffffffc0200a68:	2e051063          	bnez	a0,ffffffffc0200d48 <best_fit_check+0x548>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n", score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200a6c:	00005797          	auipc	a5,0x5
ffffffffc0200a70:	5bc7a783          	lw	a5,1468(a5) # ffffffffc0206028 <free_area+0x10>
ffffffffc0200a74:	2a079a63          	bnez	a5,ffffffffc0200d28 <best_fit_check+0x528>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200a78:	854e                	mv	a0,s3
ffffffffc0200a7a:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0200a7c:	01792823          	sw	s7,16(s2)
    free_list = free_list_store;
ffffffffc0200a80:	01693023          	sd	s6,0(s2)
ffffffffc0200a84:	01593423          	sd	s5,8(s2)
    free_pages(p0, 5);
ffffffffc0200a88:	55c000ef          	jal	ffffffffc0200fe4 <free_pages>
    return listelm->next;
ffffffffc0200a8c:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a90:	01278963          	beq	a5,s2,ffffffffc0200aa2 <best_fit_check+0x2a2>
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0200a94:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a98:	679c                	ld	a5,8(a5)
ffffffffc0200a9a:	34fd                	addiw	s1,s1,-1
ffffffffc0200a9c:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a9e:	ff279be3          	bne	a5,s2,ffffffffc0200a94 <best_fit_check+0x294>
    }
    assert(count == 0);
ffffffffc0200aa2:	26049363          	bnez	s1,ffffffffc0200d08 <best_fit_check+0x508>
    assert(total == 0);
ffffffffc0200aa6:	e06d                	bnez	s0,ffffffffc0200b88 <best_fit_check+0x388>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n", score, sumscore);
    #endif
}
ffffffffc0200aa8:	60a6                	ld	ra,72(sp)
ffffffffc0200aaa:	6406                	ld	s0,64(sp)
ffffffffc0200aac:	74e2                	ld	s1,56(sp)
ffffffffc0200aae:	7942                	ld	s2,48(sp)
ffffffffc0200ab0:	79a2                	ld	s3,40(sp)
ffffffffc0200ab2:	7a02                	ld	s4,32(sp)
ffffffffc0200ab4:	6ae2                	ld	s5,24(sp)
ffffffffc0200ab6:	6b42                	ld	s6,16(sp)
ffffffffc0200ab8:	6ba2                	ld	s7,8(sp)
ffffffffc0200aba:	6c02                	ld	s8,0(sp)
ffffffffc0200abc:	6161                	addi	sp,sp,80
ffffffffc0200abe:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ac0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ac2:	4401                	li	s0,0
ffffffffc0200ac4:	4481                	li	s1,0
ffffffffc0200ac6:	bbbd                	j	ffffffffc0200844 <best_fit_check+0x44>
        assert(PageProperty(p));
ffffffffc0200ac8:	00001697          	auipc	a3,0x1
ffffffffc0200acc:	f2068693          	addi	a3,a3,-224 # ffffffffc02019e8 <etext+0x2c2>
ffffffffc0200ad0:	00001617          	auipc	a2,0x1
ffffffffc0200ad4:	ec060613          	addi	a2,a2,-320 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200ad8:	0b200593          	li	a1,178
ffffffffc0200adc:	00001517          	auipc	a0,0x1
ffffffffc0200ae0:	ecc50513          	addi	a0,a0,-308 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200ae4:	ee8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ae8:	00001697          	auipc	a3,0x1
ffffffffc0200aec:	f9068693          	addi	a3,a3,-112 # ffffffffc0201a78 <etext+0x352>
ffffffffc0200af0:	00001617          	auipc	a2,0x1
ffffffffc0200af4:	ea060613          	addi	a2,a2,-352 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200af8:	08000593          	li	a1,128
ffffffffc0200afc:	00001517          	auipc	a0,0x1
ffffffffc0200b00:	eac50513          	addi	a0,a0,-340 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200b04:	ec8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b08:	00001697          	auipc	a3,0x1
ffffffffc0200b0c:	f9868693          	addi	a3,a3,-104 # ffffffffc0201aa0 <etext+0x37a>
ffffffffc0200b10:	00001617          	auipc	a2,0x1
ffffffffc0200b14:	e8060613          	addi	a2,a2,-384 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200b18:	08100593          	li	a1,129
ffffffffc0200b1c:	00001517          	auipc	a0,0x1
ffffffffc0200b20:	e8c50513          	addi	a0,a0,-372 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200b24:	ea8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b28:	00001697          	auipc	a3,0x1
ffffffffc0200b2c:	fb868693          	addi	a3,a3,-72 # ffffffffc0201ae0 <etext+0x3ba>
ffffffffc0200b30:	00001617          	auipc	a2,0x1
ffffffffc0200b34:	e6060613          	addi	a2,a2,-416 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200b38:	08300593          	li	a1,131
ffffffffc0200b3c:	00001517          	auipc	a0,0x1
ffffffffc0200b40:	e6c50513          	addi	a0,a0,-404 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200b44:	e88ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200b48:	00001697          	auipc	a3,0x1
ffffffffc0200b4c:	02068693          	addi	a3,a3,32 # ffffffffc0201b68 <etext+0x442>
ffffffffc0200b50:	00001617          	auipc	a2,0x1
ffffffffc0200b54:	e4060613          	addi	a2,a2,-448 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200b58:	09c00593          	li	a1,156
ffffffffc0200b5c:	00001517          	auipc	a0,0x1
ffffffffc0200b60:	e4c50513          	addi	a0,a0,-436 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200b64:	e68ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b68:	00001697          	auipc	a3,0x1
ffffffffc0200b6c:	ef068693          	addi	a3,a3,-272 # ffffffffc0201a58 <etext+0x332>
ffffffffc0200b70:	00001617          	auipc	a2,0x1
ffffffffc0200b74:	e2060613          	addi	a2,a2,-480 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200b78:	07e00593          	li	a1,126
ffffffffc0200b7c:	00001517          	auipc	a0,0x1
ffffffffc0200b80:	e2c50513          	addi	a0,a0,-468 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200b84:	e48ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(total == 0);
ffffffffc0200b88:	00001697          	auipc	a3,0x1
ffffffffc0200b8c:	11068693          	addi	a3,a3,272 # ffffffffc0201c98 <etext+0x572>
ffffffffc0200b90:	00001617          	auipc	a2,0x1
ffffffffc0200b94:	e0060613          	addi	a2,a2,-512 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200b98:	0f400593          	li	a1,244
ffffffffc0200b9c:	00001517          	auipc	a0,0x1
ffffffffc0200ba0:	e0c50513          	addi	a0,a0,-500 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200ba4:	e28ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ba8:	00001697          	auipc	a3,0x1
ffffffffc0200bac:	e5068693          	addi	a3,a3,-432 # ffffffffc02019f8 <etext+0x2d2>
ffffffffc0200bb0:	00001617          	auipc	a2,0x1
ffffffffc0200bb4:	de060613          	addi	a2,a2,-544 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200bb8:	0b500593          	li	a1,181
ffffffffc0200bbc:	00001517          	auipc	a0,0x1
ffffffffc0200bc0:	dec50513          	addi	a0,a0,-532 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200bc4:	e08ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bc8:	00001697          	auipc	a3,0x1
ffffffffc0200bcc:	e7068693          	addi	a3,a3,-400 # ffffffffc0201a38 <etext+0x312>
ffffffffc0200bd0:	00001617          	auipc	a2,0x1
ffffffffc0200bd4:	dc060613          	addi	a2,a2,-576 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200bd8:	07d00593          	li	a1,125
ffffffffc0200bdc:	00001517          	auipc	a0,0x1
ffffffffc0200be0:	dcc50513          	addi	a0,a0,-564 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200be4:	de8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200be8:	00001697          	auipc	a3,0x1
ffffffffc0200bec:	e3068693          	addi	a3,a3,-464 # ffffffffc0201a18 <etext+0x2f2>
ffffffffc0200bf0:	00001617          	auipc	a2,0x1
ffffffffc0200bf4:	da060613          	addi	a2,a2,-608 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200bf8:	07c00593          	li	a1,124
ffffffffc0200bfc:	00001517          	auipc	a0,0x1
ffffffffc0200c00:	dac50513          	addi	a0,a0,-596 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200c04:	dc8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c08:	00001697          	auipc	a3,0x1
ffffffffc0200c0c:	f3868693          	addi	a3,a3,-200 # ffffffffc0201b40 <etext+0x41a>
ffffffffc0200c10:	00001617          	auipc	a2,0x1
ffffffffc0200c14:	d8060613          	addi	a2,a2,-640 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200c18:	09900593          	li	a1,153
ffffffffc0200c1c:	00001517          	auipc	a0,0x1
ffffffffc0200c20:	d8c50513          	addi	a0,a0,-628 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200c24:	da8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c28:	00001697          	auipc	a3,0x1
ffffffffc0200c2c:	e3068693          	addi	a3,a3,-464 # ffffffffc0201a58 <etext+0x332>
ffffffffc0200c30:	00001617          	auipc	a2,0x1
ffffffffc0200c34:	d6060613          	addi	a2,a2,-672 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200c38:	09700593          	li	a1,151
ffffffffc0200c3c:	00001517          	auipc	a0,0x1
ffffffffc0200c40:	d6c50513          	addi	a0,a0,-660 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200c44:	d88ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c48:	00001697          	auipc	a3,0x1
ffffffffc0200c4c:	df068693          	addi	a3,a3,-528 # ffffffffc0201a38 <etext+0x312>
ffffffffc0200c50:	00001617          	auipc	a2,0x1
ffffffffc0200c54:	d4060613          	addi	a2,a2,-704 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200c58:	09600593          	li	a1,150
ffffffffc0200c5c:	00001517          	auipc	a0,0x1
ffffffffc0200c60:	d4c50513          	addi	a0,a0,-692 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200c64:	d68ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c68:	00001697          	auipc	a3,0x1
ffffffffc0200c6c:	db068693          	addi	a3,a3,-592 # ffffffffc0201a18 <etext+0x2f2>
ffffffffc0200c70:	00001617          	auipc	a2,0x1
ffffffffc0200c74:	d2060613          	addi	a2,a2,-736 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200c78:	09500593          	li	a1,149
ffffffffc0200c7c:	00001517          	auipc	a0,0x1
ffffffffc0200c80:	d2c50513          	addi	a0,a0,-724 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200c84:	d48ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(nr_free == 3);
ffffffffc0200c88:	00001697          	auipc	a3,0x1
ffffffffc0200c8c:	ed068693          	addi	a3,a3,-304 # ffffffffc0201b58 <etext+0x432>
ffffffffc0200c90:	00001617          	auipc	a2,0x1
ffffffffc0200c94:	d0060613          	addi	a2,a2,-768 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200c98:	09300593          	li	a1,147
ffffffffc0200c9c:	00001517          	auipc	a0,0x1
ffffffffc0200ca0:	d0c50513          	addi	a0,a0,-756 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200ca4:	d28ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ca8:	00001697          	auipc	a3,0x1
ffffffffc0200cac:	e9868693          	addi	a3,a3,-360 # ffffffffc0201b40 <etext+0x41a>
ffffffffc0200cb0:	00001617          	auipc	a2,0x1
ffffffffc0200cb4:	ce060613          	addi	a2,a2,-800 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200cb8:	08e00593          	li	a1,142
ffffffffc0200cbc:	00001517          	auipc	a0,0x1
ffffffffc0200cc0:	cec50513          	addi	a0,a0,-788 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200cc4:	d08ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cc8:	00001697          	auipc	a3,0x1
ffffffffc0200ccc:	e5868693          	addi	a3,a3,-424 # ffffffffc0201b20 <etext+0x3fa>
ffffffffc0200cd0:	00001617          	auipc	a2,0x1
ffffffffc0200cd4:	cc060613          	addi	a2,a2,-832 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200cd8:	08500593          	li	a1,133
ffffffffc0200cdc:	00001517          	auipc	a0,0x1
ffffffffc0200ce0:	ccc50513          	addi	a0,a0,-820 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200ce4:	ce8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ce8:	00001697          	auipc	a3,0x1
ffffffffc0200cec:	e1868693          	addi	a3,a3,-488 # ffffffffc0201b00 <etext+0x3da>
ffffffffc0200cf0:	00001617          	auipc	a2,0x1
ffffffffc0200cf4:	ca060613          	addi	a2,a2,-864 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200cf8:	08400593          	li	a1,132
ffffffffc0200cfc:	00001517          	auipc	a0,0x1
ffffffffc0200d00:	cac50513          	addi	a0,a0,-852 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200d04:	cc8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(count == 0);
ffffffffc0200d08:	00001697          	auipc	a3,0x1
ffffffffc0200d0c:	f8068693          	addi	a3,a3,-128 # ffffffffc0201c88 <etext+0x562>
ffffffffc0200d10:	00001617          	auipc	a2,0x1
ffffffffc0200d14:	c8060613          	addi	a2,a2,-896 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200d18:	0f300593          	li	a1,243
ffffffffc0200d1c:	00001517          	auipc	a0,0x1
ffffffffc0200d20:	c8c50513          	addi	a0,a0,-884 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200d24:	ca8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(nr_free == 0);
ffffffffc0200d28:	00001697          	auipc	a3,0x1
ffffffffc0200d2c:	e7868693          	addi	a3,a3,-392 # ffffffffc0201ba0 <etext+0x47a>
ffffffffc0200d30:	00001617          	auipc	a2,0x1
ffffffffc0200d34:	c6060613          	addi	a2,a2,-928 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200d38:	0e800593          	li	a1,232
ffffffffc0200d3c:	00001517          	auipc	a0,0x1
ffffffffc0200d40:	c6c50513          	addi	a0,a0,-916 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200d44:	c88ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d48:	00001697          	auipc	a3,0x1
ffffffffc0200d4c:	df868693          	addi	a3,a3,-520 # ffffffffc0201b40 <etext+0x41a>
ffffffffc0200d50:	00001617          	auipc	a2,0x1
ffffffffc0200d54:	c4060613          	addi	a2,a2,-960 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200d58:	0e200593          	li	a1,226
ffffffffc0200d5c:	00001517          	auipc	a0,0x1
ffffffffc0200d60:	c4c50513          	addi	a0,a0,-948 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200d64:	c68ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d68:	00001697          	auipc	a3,0x1
ffffffffc0200d6c:	f0068693          	addi	a3,a3,-256 # ffffffffc0201c68 <etext+0x542>
ffffffffc0200d70:	00001617          	auipc	a2,0x1
ffffffffc0200d74:	c2060613          	addi	a2,a2,-992 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200d78:	0e100593          	li	a1,225
ffffffffc0200d7c:	00001517          	auipc	a0,0x1
ffffffffc0200d80:	c2c50513          	addi	a0,a0,-980 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200d84:	c48ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200d88:	00001697          	auipc	a3,0x1
ffffffffc0200d8c:	ed068693          	addi	a3,a3,-304 # ffffffffc0201c58 <etext+0x532>
ffffffffc0200d90:	00001617          	auipc	a2,0x1
ffffffffc0200d94:	c0060613          	addi	a2,a2,-1024 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200d98:	0d900593          	li	a1,217
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	c0c50513          	addi	a0,a0,-1012 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200da4:	c28ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(alloc_pages(2) != NULL);
ffffffffc0200da8:	00001697          	auipc	a3,0x1
ffffffffc0200dac:	e9868693          	addi	a3,a3,-360 # ffffffffc0201c40 <etext+0x51a>
ffffffffc0200db0:	00001617          	auipc	a2,0x1
ffffffffc0200db4:	be060613          	addi	a2,a2,-1056 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200db8:	0d800593          	li	a1,216
ffffffffc0200dbc:	00001517          	auipc	a0,0x1
ffffffffc0200dc0:	bec50513          	addi	a0,a0,-1044 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200dc4:	c08ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200dc8:	00001697          	auipc	a3,0x1
ffffffffc0200dcc:	e5868693          	addi	a3,a3,-424 # ffffffffc0201c20 <etext+0x4fa>
ffffffffc0200dd0:	00001617          	auipc	a2,0x1
ffffffffc0200dd4:	bc060613          	addi	a2,a2,-1088 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200dd8:	0d700593          	li	a1,215
ffffffffc0200ddc:	00001517          	auipc	a0,0x1
ffffffffc0200de0:	bcc50513          	addi	a0,a0,-1076 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200de4:	be8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200de8:	00001697          	auipc	a3,0x1
ffffffffc0200dec:	e0868693          	addi	a3,a3,-504 # ffffffffc0201bf0 <etext+0x4ca>
ffffffffc0200df0:	00001617          	auipc	a2,0x1
ffffffffc0200df4:	ba060613          	addi	a2,a2,-1120 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200df8:	0d500593          	li	a1,213
ffffffffc0200dfc:	00001517          	auipc	a0,0x1
ffffffffc0200e00:	bac50513          	addi	a0,a0,-1108 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200e04:	bc8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200e08:	00001697          	auipc	a3,0x1
ffffffffc0200e0c:	dd068693          	addi	a3,a3,-560 # ffffffffc0201bd8 <etext+0x4b2>
ffffffffc0200e10:	00001617          	auipc	a2,0x1
ffffffffc0200e14:	b8060613          	addi	a2,a2,-1152 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200e18:	0d400593          	li	a1,212
ffffffffc0200e1c:	00001517          	auipc	a0,0x1
ffffffffc0200e20:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200e24:	ba8ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e28:	00001697          	auipc	a3,0x1
ffffffffc0200e2c:	d1868693          	addi	a3,a3,-744 # ffffffffc0201b40 <etext+0x41a>
ffffffffc0200e30:	00001617          	auipc	a2,0x1
ffffffffc0200e34:	b6060613          	addi	a2,a2,-1184 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200e38:	0c800593          	li	a1,200
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200e44:	b88ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(!PageProperty(p0));
ffffffffc0200e48:	00001697          	auipc	a3,0x1
ffffffffc0200e4c:	d7868693          	addi	a3,a3,-648 # ffffffffc0201bc0 <etext+0x49a>
ffffffffc0200e50:	00001617          	auipc	a2,0x1
ffffffffc0200e54:	b4060613          	addi	a2,a2,-1216 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200e58:	0bf00593          	li	a1,191
ffffffffc0200e5c:	00001517          	auipc	a0,0x1
ffffffffc0200e60:	b4c50513          	addi	a0,a0,-1204 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200e64:	b68ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(p0 != NULL);
ffffffffc0200e68:	00001697          	auipc	a3,0x1
ffffffffc0200e6c:	d4868693          	addi	a3,a3,-696 # ffffffffc0201bb0 <etext+0x48a>
ffffffffc0200e70:	00001617          	auipc	a2,0x1
ffffffffc0200e74:	b2060613          	addi	a2,a2,-1248 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200e78:	0be00593          	li	a1,190
ffffffffc0200e7c:	00001517          	auipc	a0,0x1
ffffffffc0200e80:	b2c50513          	addi	a0,a0,-1236 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200e84:	b48ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(nr_free == 0);
ffffffffc0200e88:	00001697          	auipc	a3,0x1
ffffffffc0200e8c:	d1868693          	addi	a3,a3,-744 # ffffffffc0201ba0 <etext+0x47a>
ffffffffc0200e90:	00001617          	auipc	a2,0x1
ffffffffc0200e94:	b0060613          	addi	a2,a2,-1280 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200e98:	0a200593          	li	a1,162
ffffffffc0200e9c:	00001517          	auipc	a0,0x1
ffffffffc0200ea0:	b0c50513          	addi	a0,a0,-1268 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200ea4:	b28ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ea8:	00001697          	auipc	a3,0x1
ffffffffc0200eac:	c9868693          	addi	a3,a3,-872 # ffffffffc0201b40 <etext+0x41a>
ffffffffc0200eb0:	00001617          	auipc	a2,0x1
ffffffffc0200eb4:	ae060613          	addi	a2,a2,-1312 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200eb8:	0a000593          	li	a1,160
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	aec50513          	addi	a0,a0,-1300 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200ec4:	b08ff0ef          	jal	ffffffffc02001cc <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ec8:	00001697          	auipc	a3,0x1
ffffffffc0200ecc:	cb868693          	addi	a3,a3,-840 # ffffffffc0201b80 <etext+0x45a>
ffffffffc0200ed0:	00001617          	auipc	a2,0x1
ffffffffc0200ed4:	ac060613          	addi	a2,a2,-1344 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200ed8:	09f00593          	li	a1,159
ffffffffc0200edc:	00001517          	auipc	a0,0x1
ffffffffc0200ee0:	acc50513          	addi	a0,a0,-1332 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200ee4:	ae8ff0ef          	jal	ffffffffc02001cc <__panic>

ffffffffc0200ee8 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200ee8:	1141                	addi	sp,sp,-16
ffffffffc0200eea:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200eec:	c9b1                	beqz	a1,ffffffffc0200f40 <best_fit_free_pages+0x58>
    for (struct Page *p = base; p < base + n; p ++) {
ffffffffc0200eee:	00259693          	slli	a3,a1,0x2
ffffffffc0200ef2:	96ae                	add	a3,a3,a1
ffffffffc0200ef4:	068e                	slli	a3,a3,0x3
ffffffffc0200ef6:	96aa                	add	a3,a3,a0
ffffffffc0200ef8:	87aa                	mv	a5,a0
ffffffffc0200efa:	00d57f63          	bgeu	a0,a3,ffffffffc0200f18 <best_fit_free_pages+0x30>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200efe:	6798                	ld	a4,8(a5)
ffffffffc0200f00:	8b0d                	andi	a4,a4,3
ffffffffc0200f02:	ef19                	bnez	a4,ffffffffc0200f20 <best_fit_free_pages+0x38>
        p->flags = p->property = 0;
ffffffffc0200f04:	0007a823          	sw	zero,16(a5)
ffffffffc0200f08:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f0c:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p ++) {
ffffffffc0200f10:	02878793          	addi	a5,a5,40
ffffffffc0200f14:	fed7e5e3          	bltu	a5,a3,ffffffffc0200efe <best_fit_free_pages+0x16>
}
ffffffffc0200f18:	60a2                	ld	ra,8(sp)
ffffffffc0200f1a:	0141                	addi	sp,sp,16
    insert_free_block(base, n);
ffffffffc0200f1c:	eb2ff06f          	j	ffffffffc02005ce <insert_free_block>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200f20:	00001697          	auipc	a3,0x1
ffffffffc0200f24:	d8868693          	addi	a3,a3,-632 # ffffffffc0201ca8 <etext+0x582>
ffffffffc0200f28:	00001617          	auipc	a2,0x1
ffffffffc0200f2c:	a6860613          	addi	a2,a2,-1432 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200f30:	06b00593          	li	a1,107
ffffffffc0200f34:	00001517          	auipc	a0,0x1
ffffffffc0200f38:	a7450513          	addi	a0,a0,-1420 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200f3c:	a90ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(n > 0);
ffffffffc0200f40:	00001697          	auipc	a3,0x1
ffffffffc0200f44:	aa068693          	addi	a3,a3,-1376 # ffffffffc02019e0 <etext+0x2ba>
ffffffffc0200f48:	00001617          	auipc	a2,0x1
ffffffffc0200f4c:	a4860613          	addi	a2,a2,-1464 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200f50:	06900593          	li	a1,105
ffffffffc0200f54:	00001517          	auipc	a0,0x1
ffffffffc0200f58:	a5450513          	addi	a0,a0,-1452 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200f5c:	a70ff0ef          	jal	ffffffffc02001cc <__panic>

ffffffffc0200f60 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0200f60:	1141                	addi	sp,sp,-16
ffffffffc0200f62:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200f64:	c9b1                	beqz	a1,ffffffffc0200fb8 <best_fit_init_memmap+0x58>
    for (struct Page *p = base; p < base + n; p ++) {
ffffffffc0200f66:	00259693          	slli	a3,a1,0x2
ffffffffc0200f6a:	96ae                	add	a3,a3,a1
ffffffffc0200f6c:	068e                	slli	a3,a3,0x3
ffffffffc0200f6e:	96aa                	add	a3,a3,a0
ffffffffc0200f70:	87aa                	mv	a5,a0
ffffffffc0200f72:	00d57f63          	bgeu	a0,a3,ffffffffc0200f90 <best_fit_init_memmap+0x30>
        assert(PageReserved(p));
ffffffffc0200f76:	6798                	ld	a4,8(a5)
ffffffffc0200f78:	8b05                	andi	a4,a4,1
ffffffffc0200f7a:	cf19                	beqz	a4,ffffffffc0200f98 <best_fit_init_memmap+0x38>
        p->flags = p->property = 0;
ffffffffc0200f7c:	0007a823          	sw	zero,16(a5)
ffffffffc0200f80:	0007b423          	sd	zero,8(a5)
ffffffffc0200f84:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p ++) {
ffffffffc0200f88:	02878793          	addi	a5,a5,40
ffffffffc0200f8c:	fed7e5e3          	bltu	a5,a3,ffffffffc0200f76 <best_fit_init_memmap+0x16>
}
ffffffffc0200f90:	60a2                	ld	ra,8(sp)
ffffffffc0200f92:	0141                	addi	sp,sp,16
    insert_free_block(base, n);
ffffffffc0200f94:	e3aff06f          	j	ffffffffc02005ce <insert_free_block>
        assert(PageReserved(p));
ffffffffc0200f98:	00001697          	auipc	a3,0x1
ffffffffc0200f9c:	d3868693          	addi	a3,a3,-712 # ffffffffc0201cd0 <etext+0x5aa>
ffffffffc0200fa0:	00001617          	auipc	a2,0x1
ffffffffc0200fa4:	9f060613          	addi	a2,a2,-1552 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200fa8:	03a00593          	li	a1,58
ffffffffc0200fac:	00001517          	auipc	a0,0x1
ffffffffc0200fb0:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200fb4:	a18ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(n > 0);
ffffffffc0200fb8:	00001697          	auipc	a3,0x1
ffffffffc0200fbc:	a2868693          	addi	a3,a3,-1496 # ffffffffc02019e0 <etext+0x2ba>
ffffffffc0200fc0:	00001617          	auipc	a2,0x1
ffffffffc0200fc4:	9d060613          	addi	a2,a2,-1584 # ffffffffc0201990 <etext+0x26a>
ffffffffc0200fc8:	03800593          	li	a1,56
ffffffffc0200fcc:	00001517          	auipc	a0,0x1
ffffffffc0200fd0:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02019a8 <etext+0x282>
ffffffffc0200fd4:	9f8ff0ef          	jal	ffffffffc02001cc <__panic>

ffffffffc0200fd8 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc0200fd8:	00005797          	auipc	a5,0x5
ffffffffc0200fdc:	0707b783          	ld	a5,112(a5) # ffffffffc0206048 <pmm_manager>
ffffffffc0200fe0:	6f9c                	ld	a5,24(a5)
ffffffffc0200fe2:	8782                	jr	a5

ffffffffc0200fe4 <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0200fe4:	00005797          	auipc	a5,0x5
ffffffffc0200fe8:	0647b783          	ld	a5,100(a5) # ffffffffc0206048 <pmm_manager>
ffffffffc0200fec:	739c                	ld	a5,32(a5)
ffffffffc0200fee:	8782                	jr	a5

ffffffffc0200ff0 <nr_free_pages>:
}

// nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE)
// of current free memory
size_t nr_free_pages(void) {
    return pmm_manager->nr_free_pages();
ffffffffc0200ff0:	00005797          	auipc	a5,0x5
ffffffffc0200ff4:	0587b783          	ld	a5,88(a5) # ffffffffc0206048 <pmm_manager>
ffffffffc0200ff8:	779c                	ld	a5,40(a5)
ffffffffc0200ffa:	8782                	jr	a5

ffffffffc0200ffc <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0200ffc:	00001797          	auipc	a5,0x1
ffffffffc0201000:	f7c78793          	addi	a5,a5,-132 # ffffffffc0201f78 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201004:	638c                	ld	a1,0(a5)
    assert(free_start < free_end);
    init_memmap(pa2page(free_start), (free_end - free_start) / PGSIZE);
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201006:	1101                	addi	sp,sp,-32
ffffffffc0201008:	ec06                	sd	ra,24(sp)
ffffffffc020100a:	e822                	sd	s0,16(sp)
ffffffffc020100c:	e426                	sd	s1,8(sp)
ffffffffc020100e:	e04a                	sd	s2,0(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201010:	00005497          	auipc	s1,0x5
ffffffffc0201014:	03848493          	addi	s1,s1,56 # ffffffffc0206048 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201018:	00001517          	auipc	a0,0x1
ffffffffc020101c:	ce050513          	addi	a0,a0,-800 # ffffffffc0201cf8 <etext+0x5d2>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201020:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201022:	928ff0ef          	jal	ffffffffc020014a <cprintf>
    pmm_manager->init();
ffffffffc0201026:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201028:	00005917          	auipc	s2,0x5
ffffffffc020102c:	03890913          	addi	s2,s2,56 # ffffffffc0206060 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201030:	679c                	ld	a5,8(a5)
ffffffffc0201032:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201034:	57f5                	li	a5,-3
ffffffffc0201036:	07fa                	slli	a5,a5,0x1e
ffffffffc0201038:	00f93023          	sd	a5,0(s2)
    uint64_t mem_base = get_memory_base();
ffffffffc020103c:	d62ff0ef          	jal	ffffffffc020059e <get_memory_base>
ffffffffc0201040:	842a                	mv	s0,a0
    uint64_t mem_size = get_memory_size();
ffffffffc0201042:	d66ff0ef          	jal	ffffffffc02005a8 <get_memory_size>
    uint64_t mem_end = mem_base + mem_size;
ffffffffc0201046:	00a405b3          	add	a1,s0,a0
    assert(mem_size != 0 && mem_end > mem_base);
ffffffffc020104a:	16050163          	beqz	a0,ffffffffc02011ac <pmm_init+0x1b0>
ffffffffc020104e:	14b47f63          	bgeu	s0,a1,ffffffffc02011ac <pmm_init+0x1b0>
    assert(mem_end > DRAM_BASE);
ffffffffc0201052:	4785                	li	a5,1
ffffffffc0201054:	07fe                	slli	a5,a5,0x1f
ffffffffc0201056:	20b7fc63          	bgeu	a5,a1,ffffffffc020126e <pmm_init+0x272>
    npage = PPN(mem_end);
ffffffffc020105a:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc020105c:	00006697          	auipc	a3,0x6
ffffffffc0201060:	01b68693          	addi	a3,a3,27 # ffffffffc0207077 <end+0xfff>
ffffffffc0201064:	8efd                	and	a3,a3,a5
    npage = PPN(mem_end);
ffffffffc0201066:	00c5d513          	srli	a0,a1,0xc
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc020106a:	00005797          	auipc	a5,0x5
ffffffffc020106e:	00d7b323          	sd	a3,6(a5) # ffffffffc0206070 <pages>
    npage = PPN(mem_end);
ffffffffc0201072:	00005797          	auipc	a5,0x5
ffffffffc0201076:	fea7bb23          	sd	a0,-10(a5) # ffffffffc0206068 <npage>
    size_t page_count = npage - nbase;
ffffffffc020107a:	fff808b7          	lui	a7,0xfff80
    uintptr_t pages_pa = PADDR(pages);
ffffffffc020107e:	c02007b7          	lui	a5,0xc0200
    pages = (struct Page *)ROUNDUP((uintptr_t)end, PGSIZE);
ffffffffc0201082:	8636                	mv	a2,a3
    size_t page_count = npage - nbase;
ffffffffc0201084:	98aa                	add	a7,a7,a0
    uintptr_t pages_pa = PADDR(pages);
ffffffffc0201086:	1cf6e863          	bltu	a3,a5,ffffffffc0201256 <pmm_init+0x25a>
ffffffffc020108a:	00093703          	ld	a4,0(s2)
ffffffffc020108e:	40e687b3          	sub	a5,a3,a4
    assert(mem_base <= pages_pa && pages_pa < mem_end);
ffffffffc0201092:	0e87ed63          	bltu	a5,s0,ffffffffc020118c <pmm_init+0x190>
ffffffffc0201096:	0eb7fb63          	bgeu	a5,a1,ffffffffc020118c <pmm_init+0x190>
    assert(page_count <= (mem_end - pages_pa) / sizeof(struct Page));
ffffffffc020109a:	ccccd837          	lui	a6,0xccccd
ffffffffc020109e:	ccd80813          	addi	a6,a6,-819 # ffffffffcccccccd <end+0xcac6c55>
ffffffffc02010a2:	02081313          	slli	t1,a6,0x20
ffffffffc02010a6:	40d707b3          	sub	a5,a4,a3
ffffffffc02010aa:	981a                	add	a6,a6,t1
ffffffffc02010ac:	97ae                	add	a5,a5,a1
ffffffffc02010ae:	0307b7b3          	mulhu	a5,a5,a6
ffffffffc02010b2:	8395                	srli	a5,a5,0x5
ffffffffc02010b4:	1917e163          	bltu	a5,a7,ffffffffc0201236 <pmm_init+0x23a>
    for (size_t i = 0; i < page_count; i ++) {
ffffffffc02010b8:	02088563          	beqz	a7,ffffffffc02010e2 <pmm_init+0xe6>
ffffffffc02010bc:	00251793          	slli	a5,a0,0x2
ffffffffc02010c0:	97aa                	add	a5,a5,a0
ffffffffc02010c2:	fec00837          	lui	a6,0xfec00
ffffffffc02010c6:	9836                	add	a6,a6,a3
ffffffffc02010c8:	078e                	slli	a5,a5,0x3
ffffffffc02010ca:	97c2                	add	a5,a5,a6
        SetPageReserved(page);
ffffffffc02010cc:	4805                	li	a6,1
        page->property = 0;
ffffffffc02010ce:	0006a823          	sw	zero,16(a3)
ffffffffc02010d2:	0006a023          	sw	zero,0(a3)
        SetPageReserved(page);
ffffffffc02010d6:	0106b423          	sd	a6,8(a3)
    for (size_t i = 0; i < page_count; i ++) {
ffffffffc02010da:	02868693          	addi	a3,a3,40
ffffffffc02010de:	fef698e3          	bne	a3,a5,ffffffffc02010ce <pmm_init+0xd2>
    uintptr_t free_start = ROUNDUP(PADDR(pages + page_count), PGSIZE);
ffffffffc02010e2:	00289693          	slli	a3,a7,0x2
ffffffffc02010e6:	96c6                	add	a3,a3,a7
ffffffffc02010e8:	068e                	slli	a3,a3,0x3
ffffffffc02010ea:	96b2                	add	a3,a3,a2
ffffffffc02010ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02010f0:	12f6e763          	bltu	a3,a5,ffffffffc020121e <pmm_init+0x222>
ffffffffc02010f4:	6785                	lui	a5,0x1
ffffffffc02010f6:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02010f8:	40e78733          	sub	a4,a5,a4
ffffffffc02010fc:	9736                	add	a4,a4,a3
    uintptr_t ram_start = ROUNDUP(mem_base, PGSIZE);
ffffffffc02010fe:	943e                	add	s0,s0,a5
    if (free_start < ram_start) {
ffffffffc0201100:	76fd                	lui	a3,0xfffff
ffffffffc0201102:	00d777b3          	and	a5,a4,a3
ffffffffc0201106:	8c75                	and	s0,s0,a3
ffffffffc0201108:	0887e063          	bltu	a5,s0,ffffffffc0201188 <pmm_init+0x18c>
    uintptr_t free_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020110c:	777d                	lui	a4,0xfffff
ffffffffc020110e:	8df9                	and	a1,a1,a4
    assert(free_start < free_end);
ffffffffc0201110:	0eb7f763          	bgeu	a5,a1,ffffffffc02011fe <pmm_init+0x202>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0201114:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201118:	0ca77763          	bgeu	a4,a0,ffffffffc02011e6 <pmm_init+0x1ea>
    pmm_manager->init_memmap(base, n);
ffffffffc020111c:	6094                	ld	a3,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc020111e:	fff80537          	lui	a0,0xfff80
ffffffffc0201122:	972a                	add	a4,a4,a0
ffffffffc0201124:	00271513          	slli	a0,a4,0x2
ffffffffc0201128:	953a                	add	a0,a0,a4
ffffffffc020112a:	6a98                	ld	a4,16(a3)
    init_memmap(pa2page(free_start), (free_end - free_start) / PGSIZE);
ffffffffc020112c:	8d9d                	sub	a1,a1,a5
ffffffffc020112e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201130:	81b1                	srli	a1,a1,0xc
ffffffffc0201132:	9532                	add	a0,a0,a2
ffffffffc0201134:	9702                	jalr	a4
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201136:	609c                	ld	a5,0(s1)
ffffffffc0201138:	7b9c                	ld	a5,48(a5)
ffffffffc020113a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020113c:	00001517          	auipc	a0,0x1
ffffffffc0201140:	d0450513          	addi	a0,a0,-764 # ffffffffc0201e40 <etext+0x71a>
ffffffffc0201144:	806ff0ef          	jal	ffffffffc020014a <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201148:	00004597          	auipc	a1,0x4
ffffffffc020114c:	eb858593          	addi	a1,a1,-328 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201150:	00005797          	auipc	a5,0x5
ffffffffc0201154:	f0b7b423          	sd	a1,-248(a5) # ffffffffc0206058 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201158:	c02007b7          	lui	a5,0xc0200
ffffffffc020115c:	06f5e863          	bltu	a1,a5,ffffffffc02011cc <pmm_init+0x1d0>
ffffffffc0201160:	00093783          	ld	a5,0(s2)
}
ffffffffc0201164:	6442                	ld	s0,16(sp)
ffffffffc0201166:	60e2                	ld	ra,24(sp)
ffffffffc0201168:	64a2                	ld	s1,8(sp)
ffffffffc020116a:	6902                	ld	s2,0(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020116c:	40f586b3          	sub	a3,a1,a5
ffffffffc0201170:	00005797          	auipc	a5,0x5
ffffffffc0201174:	eed7b023          	sd	a3,-288(a5) # ffffffffc0206050 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201178:	00001517          	auipc	a0,0x1
ffffffffc020117c:	ce850513          	addi	a0,a0,-792 # ffffffffc0201e60 <etext+0x73a>
ffffffffc0201180:	8636                	mv	a2,a3
}
ffffffffc0201182:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201184:	fc7fe06f          	j	ffffffffc020014a <cprintf>
    if (free_start < ram_start) {
ffffffffc0201188:	87a2                	mv	a5,s0
ffffffffc020118a:	b749                	j	ffffffffc020110c <pmm_init+0x110>
    assert(mem_base <= pages_pa && pages_pa < mem_end);
ffffffffc020118c:	00001697          	auipc	a3,0x1
ffffffffc0201190:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0201d88 <etext+0x662>
ffffffffc0201194:	00000617          	auipc	a2,0x0
ffffffffc0201198:	7fc60613          	addi	a2,a2,2044 # ffffffffc0201990 <etext+0x26a>
ffffffffc020119c:	05100593          	li	a1,81
ffffffffc02011a0:	00001517          	auipc	a0,0x1
ffffffffc02011a4:	b9850513          	addi	a0,a0,-1128 # ffffffffc0201d38 <etext+0x612>
ffffffffc02011a8:	824ff0ef          	jal	ffffffffc02001cc <__panic>
    assert(mem_size != 0 && mem_end > mem_base);
ffffffffc02011ac:	00001697          	auipc	a3,0x1
ffffffffc02011b0:	b6468693          	addi	a3,a3,-1180 # ffffffffc0201d10 <etext+0x5ea>
ffffffffc02011b4:	00000617          	auipc	a2,0x0
ffffffffc02011b8:	7dc60613          	addi	a2,a2,2012 # ffffffffc0201990 <etext+0x26a>
ffffffffc02011bc:	04a00593          	li	a1,74
ffffffffc02011c0:	00001517          	auipc	a0,0x1
ffffffffc02011c4:	b7850513          	addi	a0,a0,-1160 # ffffffffc0201d38 <etext+0x612>
ffffffffc02011c8:	804ff0ef          	jal	ffffffffc02001cc <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011cc:	86ae                	mv	a3,a1
ffffffffc02011ce:	00001617          	auipc	a2,0x1
ffffffffc02011d2:	b9260613          	addi	a2,a2,-1134 # ffffffffc0201d60 <etext+0x63a>
ffffffffc02011d6:	07800593          	li	a1,120
ffffffffc02011da:	00001517          	auipc	a0,0x1
ffffffffc02011de:	b5e50513          	addi	a0,a0,-1186 # ffffffffc0201d38 <etext+0x612>
ffffffffc02011e2:	febfe0ef          	jal	ffffffffc02001cc <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011e6:	00001617          	auipc	a2,0x1
ffffffffc02011ea:	c2a60613          	addi	a2,a2,-982 # ffffffffc0201e10 <etext+0x6ea>
ffffffffc02011ee:	06a00593          	li	a1,106
ffffffffc02011f2:	00001517          	auipc	a0,0x1
ffffffffc02011f6:	c3e50513          	addi	a0,a0,-962 # ffffffffc0201e30 <etext+0x70a>
ffffffffc02011fa:	fd3fe0ef          	jal	ffffffffc02001cc <__panic>
    assert(free_start < free_end);
ffffffffc02011fe:	00001697          	auipc	a3,0x1
ffffffffc0201202:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0201df8 <etext+0x6d2>
ffffffffc0201206:	00000617          	auipc	a2,0x0
ffffffffc020120a:	78a60613          	addi	a2,a2,1930 # ffffffffc0201990 <etext+0x26a>
ffffffffc020120e:	06200593          	li	a1,98
ffffffffc0201212:	00001517          	auipc	a0,0x1
ffffffffc0201216:	b2650513          	addi	a0,a0,-1242 # ffffffffc0201d38 <etext+0x612>
ffffffffc020121a:	fb3fe0ef          	jal	ffffffffc02001cc <__panic>
    uintptr_t free_start = ROUNDUP(PADDR(pages + page_count), PGSIZE);
ffffffffc020121e:	00001617          	auipc	a2,0x1
ffffffffc0201222:	b4260613          	addi	a2,a2,-1214 # ffffffffc0201d60 <etext+0x63a>
ffffffffc0201226:	05c00593          	li	a1,92
ffffffffc020122a:	00001517          	auipc	a0,0x1
ffffffffc020122e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0201d38 <etext+0x612>
ffffffffc0201232:	f9bfe0ef          	jal	ffffffffc02001cc <__panic>
    assert(page_count <= (mem_end - pages_pa) / sizeof(struct Page));
ffffffffc0201236:	00001697          	auipc	a3,0x1
ffffffffc020123a:	b8268693          	addi	a3,a3,-1150 # ffffffffc0201db8 <etext+0x692>
ffffffffc020123e:	00000617          	auipc	a2,0x0
ffffffffc0201242:	75260613          	addi	a2,a2,1874 # ffffffffc0201990 <etext+0x26a>
ffffffffc0201246:	05200593          	li	a1,82
ffffffffc020124a:	00001517          	auipc	a0,0x1
ffffffffc020124e:	aee50513          	addi	a0,a0,-1298 # ffffffffc0201d38 <etext+0x612>
ffffffffc0201252:	f7bfe0ef          	jal	ffffffffc02001cc <__panic>
    uintptr_t pages_pa = PADDR(pages);
ffffffffc0201256:	00001617          	auipc	a2,0x1
ffffffffc020125a:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0201d60 <etext+0x63a>
ffffffffc020125e:	05000593          	li	a1,80
ffffffffc0201262:	00001517          	auipc	a0,0x1
ffffffffc0201266:	ad650513          	addi	a0,a0,-1322 # ffffffffc0201d38 <etext+0x612>
ffffffffc020126a:	f63fe0ef          	jal	ffffffffc02001cc <__panic>
    assert(mem_end > DRAM_BASE);
ffffffffc020126e:	00001697          	auipc	a3,0x1
ffffffffc0201272:	ada68693          	addi	a3,a3,-1318 # ffffffffc0201d48 <etext+0x622>
ffffffffc0201276:	00000617          	auipc	a2,0x0
ffffffffc020127a:	71a60613          	addi	a2,a2,1818 # ffffffffc0201990 <etext+0x26a>
ffffffffc020127e:	04b00593          	li	a1,75
ffffffffc0201282:	00001517          	auipc	a0,0x1
ffffffffc0201286:	ab650513          	addi	a0,a0,-1354 # ffffffffc0201d38 <etext+0x612>
ffffffffc020128a:	f43fe0ef          	jal	ffffffffc02001cc <__panic>

ffffffffc020128e <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020128e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201292:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201294:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201298:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020129a:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020129e:	f022                	sd	s0,32(sp)
ffffffffc02012a0:	ec26                	sd	s1,24(sp)
ffffffffc02012a2:	e84a                	sd	s2,16(sp)
ffffffffc02012a4:	f406                	sd	ra,40(sp)
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02012a6:	fff7041b          	addiw	s0,a4,-1 # ffffffffffffefff <end+0x3fdf8f87>
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012aa:	84aa                	mv	s1,a0
ffffffffc02012ac:	892e                	mv	s2,a1
    unsigned mod = do_div(result, base);
ffffffffc02012ae:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02012b0:	05067063          	bgeu	a2,a6,ffffffffc02012f0 <printnum+0x62>
ffffffffc02012b4:	e44e                	sd	s3,8(sp)
ffffffffc02012b6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02012b8:	4785                	li	a5,1
ffffffffc02012ba:	00e7d763          	bge	a5,a4,ffffffffc02012c8 <printnum+0x3a>
            putch(padc, putdat);
ffffffffc02012be:	85ca                	mv	a1,s2
ffffffffc02012c0:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02012c2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02012c4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02012c6:	fc65                	bnez	s0,ffffffffc02012be <printnum+0x30>
ffffffffc02012c8:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012ca:	1a02                	slli	s4,s4,0x20
ffffffffc02012cc:	020a5a13          	srli	s4,s4,0x20
ffffffffc02012d0:	00001797          	auipc	a5,0x1
ffffffffc02012d4:	bd078793          	addi	a5,a5,-1072 # ffffffffc0201ea0 <etext+0x77a>
ffffffffc02012d8:	97d2                	add	a5,a5,s4
}
ffffffffc02012da:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012dc:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02012e0:	70a2                	ld	ra,40(sp)
ffffffffc02012e2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012e4:	85ca                	mv	a1,s2
ffffffffc02012e6:	87a6                	mv	a5,s1
}
ffffffffc02012e8:	6942                	ld	s2,16(sp)
ffffffffc02012ea:	64e2                	ld	s1,24(sp)
ffffffffc02012ec:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02012ee:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02012f0:	03065633          	divu	a2,a2,a6
ffffffffc02012f4:	8722                	mv	a4,s0
ffffffffc02012f6:	f99ff0ef          	jal	ffffffffc020128e <printnum>
ffffffffc02012fa:	bfc1                	j	ffffffffc02012ca <printnum+0x3c>

ffffffffc02012fc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02012fc:	7119                	addi	sp,sp,-128
ffffffffc02012fe:	f4a6                	sd	s1,104(sp)
ffffffffc0201300:	f0ca                	sd	s2,96(sp)
ffffffffc0201302:	ecce                	sd	s3,88(sp)
ffffffffc0201304:	e8d2                	sd	s4,80(sp)
ffffffffc0201306:	e4d6                	sd	s5,72(sp)
ffffffffc0201308:	e0da                	sd	s6,64(sp)
ffffffffc020130a:	f862                	sd	s8,48(sp)
ffffffffc020130c:	fc86                	sd	ra,120(sp)
ffffffffc020130e:	f8a2                	sd	s0,112(sp)
ffffffffc0201310:	fc5e                	sd	s7,56(sp)
ffffffffc0201312:	f466                	sd	s9,40(sp)
ffffffffc0201314:	f06a                	sd	s10,32(sp)
ffffffffc0201316:	ec6e                	sd	s11,24(sp)
ffffffffc0201318:	892a                	mv	s2,a0
ffffffffc020131a:	84ae                	mv	s1,a1
ffffffffc020131c:	8c32                	mv	s8,a2
ffffffffc020131e:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201320:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201324:	05500b13          	li	s6,85
ffffffffc0201328:	00001a97          	auipc	s5,0x1
ffffffffc020132c:	c88a8a93          	addi	s5,s5,-888 # ffffffffc0201fb0 <best_fit_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201330:	000c4503          	lbu	a0,0(s8)
ffffffffc0201334:	001c0413          	addi	s0,s8,1
ffffffffc0201338:	01350a63          	beq	a0,s3,ffffffffc020134c <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020133c:	cd0d                	beqz	a0,ffffffffc0201376 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc020133e:	85a6                	mv	a1,s1
ffffffffc0201340:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201342:	00044503          	lbu	a0,0(s0)
ffffffffc0201346:	0405                	addi	s0,s0,1
ffffffffc0201348:	ff351ae3          	bne	a0,s3,ffffffffc020133c <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020134c:	5cfd                	li	s9,-1
ffffffffc020134e:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0201350:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0201354:	4b81                	li	s7,0
ffffffffc0201356:	4601                	li	a2,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201358:	00044683          	lbu	a3,0(s0)
ffffffffc020135c:	00140c13          	addi	s8,s0,1
ffffffffc0201360:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0201364:	0ff5f593          	zext.b	a1,a1
ffffffffc0201368:	02bb6663          	bltu	s6,a1,ffffffffc0201394 <vprintfmt+0x98>
ffffffffc020136c:	058a                	slli	a1,a1,0x2
ffffffffc020136e:	95d6                	add	a1,a1,s5
ffffffffc0201370:	4198                	lw	a4,0(a1)
ffffffffc0201372:	9756                	add	a4,a4,s5
ffffffffc0201374:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201376:	70e6                	ld	ra,120(sp)
ffffffffc0201378:	7446                	ld	s0,112(sp)
ffffffffc020137a:	74a6                	ld	s1,104(sp)
ffffffffc020137c:	7906                	ld	s2,96(sp)
ffffffffc020137e:	69e6                	ld	s3,88(sp)
ffffffffc0201380:	6a46                	ld	s4,80(sp)
ffffffffc0201382:	6aa6                	ld	s5,72(sp)
ffffffffc0201384:	6b06                	ld	s6,64(sp)
ffffffffc0201386:	7be2                	ld	s7,56(sp)
ffffffffc0201388:	7c42                	ld	s8,48(sp)
ffffffffc020138a:	7ca2                	ld	s9,40(sp)
ffffffffc020138c:	7d02                	ld	s10,32(sp)
ffffffffc020138e:	6de2                	ld	s11,24(sp)
ffffffffc0201390:	6109                	addi	sp,sp,128
ffffffffc0201392:	8082                	ret
            putch('%', putdat);
ffffffffc0201394:	85a6                	mv	a1,s1
ffffffffc0201396:	02500513          	li	a0,37
ffffffffc020139a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020139c:	fff44783          	lbu	a5,-1(s0)
ffffffffc02013a0:	02500713          	li	a4,37
ffffffffc02013a4:	8c22                	mv	s8,s0
ffffffffc02013a6:	f8e785e3          	beq	a5,a4,ffffffffc0201330 <vprintfmt+0x34>
ffffffffc02013aa:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02013ae:	1c7d                	addi	s8,s8,-1
ffffffffc02013b0:	fee79de3          	bne	a5,a4,ffffffffc02013aa <vprintfmt+0xae>
ffffffffc02013b4:	bfb5                	j	ffffffffc0201330 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02013b6:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02013ba:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02013bc:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02013c0:	fd07871b          	addiw	a4,a5,-48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013c4:	8462                	mv	s0,s8
                ch = *fmt;
ffffffffc02013c6:	2781                	sext.w	a5,a5
                if (ch < '0' || ch > '9') {
ffffffffc02013c8:	02e56463          	bltu	a0,a4,ffffffffc02013f0 <vprintfmt+0xf4>
                precision = precision * 10 + ch - '0';
ffffffffc02013cc:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02013d0:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02013d4:	0197073b          	addw	a4,a4,s9
ffffffffc02013d8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02013dc:	9f3d                	addw	a4,a4,a5
                if (ch < '0' || ch > '9') {
ffffffffc02013de:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02013e2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02013e4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02013e8:	0006879b          	sext.w	a5,a3
                if (ch < '0' || ch > '9') {
ffffffffc02013ec:	feb570e3          	bgeu	a0,a1,ffffffffc02013cc <vprintfmt+0xd0>
            if (width < 0)
ffffffffc02013f0:	f60d54e3          	bgez	s10,ffffffffc0201358 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc02013f4:	8d66                	mv	s10,s9
ffffffffc02013f6:	5cfd                	li	s9,-1
ffffffffc02013f8:	b785                	j	ffffffffc0201358 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013fa:	8db6                	mv	s11,a3
ffffffffc02013fc:	8462                	mv	s0,s8
ffffffffc02013fe:	bfa9                	j	ffffffffc0201358 <vprintfmt+0x5c>
ffffffffc0201400:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0201402:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0201404:	bf91                	j	ffffffffc0201358 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0201406:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201408:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020140c:	00c7c463          	blt	a5,a2,ffffffffc0201414 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0201410:	18060763          	beqz	a2,ffffffffc020159e <vprintfmt+0x2a2>
        return va_arg(*ap, unsigned long);
ffffffffc0201414:	000a3603          	ld	a2,0(s4)
ffffffffc0201418:	46c1                	li	a3,16
ffffffffc020141a:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020141c:	000d879b          	sext.w	a5,s11
ffffffffc0201420:	876a                	mv	a4,s10
ffffffffc0201422:	85a6                	mv	a1,s1
ffffffffc0201424:	854a                	mv	a0,s2
ffffffffc0201426:	e69ff0ef          	jal	ffffffffc020128e <printnum>
            break;
ffffffffc020142a:	b719                	j	ffffffffc0201330 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020142c:	000a2503          	lw	a0,0(s4)
ffffffffc0201430:	85a6                	mv	a1,s1
ffffffffc0201432:	0a21                	addi	s4,s4,8
ffffffffc0201434:	9902                	jalr	s2
            break;
ffffffffc0201436:	bded                	j	ffffffffc0201330 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201438:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020143a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020143e:	00c7c463          	blt	a5,a2,ffffffffc0201446 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201442:	14060963          	beqz	a2,ffffffffc0201594 <vprintfmt+0x298>
        return va_arg(*ap, unsigned long);
ffffffffc0201446:	000a3603          	ld	a2,0(s4)
ffffffffc020144a:	46a9                	li	a3,10
ffffffffc020144c:	8a3a                	mv	s4,a4
ffffffffc020144e:	b7f9                	j	ffffffffc020141c <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0201450:	85a6                	mv	a1,s1
ffffffffc0201452:	03000513          	li	a0,48
ffffffffc0201456:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201458:	85a6                	mv	a1,s1
ffffffffc020145a:	07800513          	li	a0,120
ffffffffc020145e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201460:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0201464:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201466:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201468:	bf55                	j	ffffffffc020141c <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc020146a:	85a6                	mv	a1,s1
ffffffffc020146c:	02500513          	li	a0,37
ffffffffc0201470:	9902                	jalr	s2
            break;
ffffffffc0201472:	bd7d                	j	ffffffffc0201330 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0201474:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201478:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc020147a:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020147c:	bf95                	j	ffffffffc02013f0 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc020147e:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201480:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201484:	00c7c463          	blt	a5,a2,ffffffffc020148c <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0201488:	10060163          	beqz	a2,ffffffffc020158a <vprintfmt+0x28e>
        return va_arg(*ap, unsigned long);
ffffffffc020148c:	000a3603          	ld	a2,0(s4)
ffffffffc0201490:	46a1                	li	a3,8
ffffffffc0201492:	8a3a                	mv	s4,a4
ffffffffc0201494:	b761                	j	ffffffffc020141c <vprintfmt+0x120>
            if (width < 0)
ffffffffc0201496:	87ea                	mv	a5,s10
ffffffffc0201498:	000d5363          	bgez	s10,ffffffffc020149e <vprintfmt+0x1a2>
ffffffffc020149c:	4781                	li	a5,0
ffffffffc020149e:	00078d1b          	sext.w	s10,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014a2:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02014a4:	bd55                	j	ffffffffc0201358 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014a6:	000a3703          	ld	a4,0(s4)
ffffffffc02014aa:	12070b63          	beqz	a4,ffffffffc02015e0 <vprintfmt+0x2e4>
            if (width > 0 && padc != '-') {
ffffffffc02014ae:	0da05563          	blez	s10,ffffffffc0201578 <vprintfmt+0x27c>
ffffffffc02014b2:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014b6:	00170413          	addi	s0,a4,1
            if (width > 0 && padc != '-') {
ffffffffc02014ba:	14fd9a63          	bne	s11,a5,ffffffffc020160e <vprintfmt+0x312>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014be:	00074783          	lbu	a5,0(a4)
ffffffffc02014c2:	0007851b          	sext.w	a0,a5
ffffffffc02014c6:	c785                	beqz	a5,ffffffffc02014ee <vprintfmt+0x1f2>
ffffffffc02014c8:	5dfd                	li	s11,-1
ffffffffc02014ca:	000cc563          	bltz	s9,ffffffffc02014d4 <vprintfmt+0x1d8>
ffffffffc02014ce:	3cfd                	addiw	s9,s9,-1
ffffffffc02014d0:	01bc8d63          	beq	s9,s11,ffffffffc02014ea <vprintfmt+0x1ee>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014d4:	0c0b9a63          	bnez	s7,ffffffffc02015a8 <vprintfmt+0x2ac>
                    putch(ch, putdat);
ffffffffc02014d8:	85a6                	mv	a1,s1
ffffffffc02014da:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014dc:	00044783          	lbu	a5,0(s0)
ffffffffc02014e0:	0405                	addi	s0,s0,1
ffffffffc02014e2:	3d7d                	addiw	s10,s10,-1
ffffffffc02014e4:	0007851b          	sext.w	a0,a5
ffffffffc02014e8:	f3ed                	bnez	a5,ffffffffc02014ca <vprintfmt+0x1ce>
            for (; width > 0; width --) {
ffffffffc02014ea:	01a05963          	blez	s10,ffffffffc02014fc <vprintfmt+0x200>
                putch(' ', putdat);
ffffffffc02014ee:	85a6                	mv	a1,s1
ffffffffc02014f0:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc02014f4:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc02014f6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02014f8:	fe0d1be3          	bnez	s10,ffffffffc02014ee <vprintfmt+0x1f2>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014fc:	0a21                	addi	s4,s4,8
ffffffffc02014fe:	bd0d                	j	ffffffffc0201330 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201500:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201502:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0201506:	00c7c363          	blt	a5,a2,ffffffffc020150c <vprintfmt+0x210>
    else if (lflag) {
ffffffffc020150a:	c625                	beqz	a2,ffffffffc0201572 <vprintfmt+0x276>
        return va_arg(*ap, long);
ffffffffc020150c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201510:	0a044f63          	bltz	s0,ffffffffc02015ce <vprintfmt+0x2d2>
            num = getint(&ap, lflag);
ffffffffc0201514:	8622                	mv	a2,s0
ffffffffc0201516:	8a5e                	mv	s4,s7
ffffffffc0201518:	46a9                	li	a3,10
ffffffffc020151a:	b709                	j	ffffffffc020141c <vprintfmt+0x120>
            if (err < 0) {
ffffffffc020151c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201520:	4619                	li	a2,6
            if (err < 0) {
ffffffffc0201522:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0201526:	8fb9                	xor	a5,a5,a4
ffffffffc0201528:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020152c:	02d64663          	blt	a2,a3,ffffffffc0201558 <vprintfmt+0x25c>
ffffffffc0201530:	00001797          	auipc	a5,0x1
ffffffffc0201534:	bd878793          	addi	a5,a5,-1064 # ffffffffc0202108 <error_string>
ffffffffc0201538:	00369713          	slli	a4,a3,0x3
ffffffffc020153c:	97ba                	add	a5,a5,a4
ffffffffc020153e:	639c                	ld	a5,0(a5)
ffffffffc0201540:	cf81                	beqz	a5,ffffffffc0201558 <vprintfmt+0x25c>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201542:	86be                	mv	a3,a5
ffffffffc0201544:	00001617          	auipc	a2,0x1
ffffffffc0201548:	98c60613          	addi	a2,a2,-1652 # ffffffffc0201ed0 <etext+0x7aa>
ffffffffc020154c:	85a6                	mv	a1,s1
ffffffffc020154e:	854a                	mv	a0,s2
ffffffffc0201550:	0f4000ef          	jal	ffffffffc0201644 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201554:	0a21                	addi	s4,s4,8
ffffffffc0201556:	bbe9                	j	ffffffffc0201330 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201558:	00001617          	auipc	a2,0x1
ffffffffc020155c:	96860613          	addi	a2,a2,-1688 # ffffffffc0201ec0 <etext+0x79a>
ffffffffc0201560:	85a6                	mv	a1,s1
ffffffffc0201562:	854a                	mv	a0,s2
ffffffffc0201564:	0e0000ef          	jal	ffffffffc0201644 <printfmt>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201568:	0a21                	addi	s4,s4,8
ffffffffc020156a:	b3d9                	j	ffffffffc0201330 <vprintfmt+0x34>
            lflag ++;
ffffffffc020156c:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020156e:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201570:	b3e5                	j	ffffffffc0201358 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0201572:	000a2403          	lw	s0,0(s4)
ffffffffc0201576:	bf69                	j	ffffffffc0201510 <vprintfmt+0x214>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201578:	00074783          	lbu	a5,0(a4)
ffffffffc020157c:	0007851b          	sext.w	a0,a5
ffffffffc0201580:	dfb5                	beqz	a5,ffffffffc02014fc <vprintfmt+0x200>
ffffffffc0201582:	00170413          	addi	s0,a4,1
ffffffffc0201586:	5dfd                	li	s11,-1
ffffffffc0201588:	b789                	j	ffffffffc02014ca <vprintfmt+0x1ce>
        return va_arg(*ap, unsigned int);
ffffffffc020158a:	000a6603          	lwu	a2,0(s4)
ffffffffc020158e:	46a1                	li	a3,8
ffffffffc0201590:	8a3a                	mv	s4,a4
ffffffffc0201592:	b569                	j	ffffffffc020141c <vprintfmt+0x120>
ffffffffc0201594:	000a6603          	lwu	a2,0(s4)
ffffffffc0201598:	46a9                	li	a3,10
ffffffffc020159a:	8a3a                	mv	s4,a4
ffffffffc020159c:	b541                	j	ffffffffc020141c <vprintfmt+0x120>
ffffffffc020159e:	000a6603          	lwu	a2,0(s4)
ffffffffc02015a2:	46c1                	li	a3,16
ffffffffc02015a4:	8a3a                	mv	s4,a4
ffffffffc02015a6:	bd9d                	j	ffffffffc020141c <vprintfmt+0x120>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015a8:	3781                	addiw	a5,a5,-32
ffffffffc02015aa:	05e00713          	li	a4,94
ffffffffc02015ae:	f2f775e3          	bgeu	a4,a5,ffffffffc02014d8 <vprintfmt+0x1dc>
                    putch('?', putdat);
ffffffffc02015b2:	03f00513          	li	a0,63
ffffffffc02015b6:	85a6                	mv	a1,s1
ffffffffc02015b8:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015ba:	00044783          	lbu	a5,0(s0)
ffffffffc02015be:	0405                	addi	s0,s0,1
ffffffffc02015c0:	3d7d                	addiw	s10,s10,-1
ffffffffc02015c2:	0007851b          	sext.w	a0,a5
ffffffffc02015c6:	d395                	beqz	a5,ffffffffc02014ea <vprintfmt+0x1ee>
ffffffffc02015c8:	f00cd3e3          	bgez	s9,ffffffffc02014ce <vprintfmt+0x1d2>
ffffffffc02015cc:	bff1                	j	ffffffffc02015a8 <vprintfmt+0x2ac>
                putch('-', putdat);
ffffffffc02015ce:	85a6                	mv	a1,s1
ffffffffc02015d0:	02d00513          	li	a0,45
ffffffffc02015d4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02015d6:	40800633          	neg	a2,s0
ffffffffc02015da:	8a5e                	mv	s4,s7
ffffffffc02015dc:	46a9                	li	a3,10
ffffffffc02015de:	bd3d                	j	ffffffffc020141c <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc02015e0:	01a05663          	blez	s10,ffffffffc02015ec <vprintfmt+0x2f0>
ffffffffc02015e4:	02d00793          	li	a5,45
ffffffffc02015e8:	00fd9b63          	bne	s11,a5,ffffffffc02015fe <vprintfmt+0x302>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015ec:	02800793          	li	a5,40
ffffffffc02015f0:	853e                	mv	a0,a5
ffffffffc02015f2:	00001417          	auipc	s0,0x1
ffffffffc02015f6:	8c740413          	addi	s0,s0,-1849 # ffffffffc0201eb9 <etext+0x793>
ffffffffc02015fa:	5dfd                	li	s11,-1
ffffffffc02015fc:	b5f9                	j	ffffffffc02014ca <vprintfmt+0x1ce>
ffffffffc02015fe:	00001417          	auipc	s0,0x1
ffffffffc0201602:	8bb40413          	addi	s0,s0,-1861 # ffffffffc0201eb9 <etext+0x793>
                p = "(null)";
ffffffffc0201606:	00001717          	auipc	a4,0x1
ffffffffc020160a:	8b270713          	addi	a4,a4,-1870 # ffffffffc0201eb8 <etext+0x792>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020160e:	853a                	mv	a0,a4
ffffffffc0201610:	85e6                	mv	a1,s9
ffffffffc0201612:	e43a                	sd	a4,8(sp)
ffffffffc0201614:	084000ef          	jal	ffffffffc0201698 <strnlen>
ffffffffc0201618:	40ad0d3b          	subw	s10,s10,a0
ffffffffc020161c:	6722                	ld	a4,8(sp)
ffffffffc020161e:	01a05b63          	blez	s10,ffffffffc0201634 <vprintfmt+0x338>
                    putch(padc, putdat);
ffffffffc0201622:	2d81                	sext.w	s11,s11
ffffffffc0201624:	85a6                	mv	a1,s1
ffffffffc0201626:	856e                	mv	a0,s11
ffffffffc0201628:	e43a                	sd	a4,8(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020162a:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc020162c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020162e:	6722                	ld	a4,8(sp)
ffffffffc0201630:	fe0d1ae3          	bnez	s10,ffffffffc0201624 <vprintfmt+0x328>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201634:	00074783          	lbu	a5,0(a4)
ffffffffc0201638:	0007851b          	sext.w	a0,a5
ffffffffc020163c:	ec0780e3          	beqz	a5,ffffffffc02014fc <vprintfmt+0x200>
ffffffffc0201640:	5dfd                	li	s11,-1
ffffffffc0201642:	b561                	j	ffffffffc02014ca <vprintfmt+0x1ce>

ffffffffc0201644 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201644:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201646:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020164a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020164c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020164e:	ec06                	sd	ra,24(sp)
ffffffffc0201650:	f83a                	sd	a4,48(sp)
ffffffffc0201652:	fc3e                	sd	a5,56(sp)
ffffffffc0201654:	e0c2                	sd	a6,64(sp)
ffffffffc0201656:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201658:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020165a:	ca3ff0ef          	jal	ffffffffc02012fc <vprintfmt>
}
ffffffffc020165e:	60e2                	ld	ra,24(sp)
ffffffffc0201660:	6161                	addi	sp,sp,80
ffffffffc0201662:	8082                	ret

ffffffffc0201664 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201664:	00005717          	auipc	a4,0x5
ffffffffc0201668:	9ac73703          	ld	a4,-1620(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc020166c:	4781                	li	a5,0
ffffffffc020166e:	88ba                	mv	a7,a4
ffffffffc0201670:	852a                	mv	a0,a0
ffffffffc0201672:	85be                	mv	a1,a5
ffffffffc0201674:	863e                	mv	a2,a5
ffffffffc0201676:	00000073          	ecall
ffffffffc020167a:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020167c:	8082                	ret

ffffffffc020167e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020167e:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0201682:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0201684:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0201686:	cb81                	beqz	a5,ffffffffc0201696 <strlen+0x18>
        cnt ++;
ffffffffc0201688:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020168a:	00a707b3          	add	a5,a4,a0
ffffffffc020168e:	0007c783          	lbu	a5,0(a5)
ffffffffc0201692:	fbfd                	bnez	a5,ffffffffc0201688 <strlen+0xa>
ffffffffc0201694:	8082                	ret
    }
    return cnt;
}
ffffffffc0201696:	8082                	ret

ffffffffc0201698 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201698:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020169a:	e589                	bnez	a1,ffffffffc02016a4 <strnlen+0xc>
ffffffffc020169c:	a811                	j	ffffffffc02016b0 <strnlen+0x18>
        cnt ++;
ffffffffc020169e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02016a0:	00f58863          	beq	a1,a5,ffffffffc02016b0 <strnlen+0x18>
ffffffffc02016a4:	00f50733          	add	a4,a0,a5
ffffffffc02016a8:	00074703          	lbu	a4,0(a4)
ffffffffc02016ac:	fb6d                	bnez	a4,ffffffffc020169e <strnlen+0x6>
ffffffffc02016ae:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02016b0:	852e                	mv	a0,a1
ffffffffc02016b2:	8082                	ret

ffffffffc02016b4 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02016b4:	00054783          	lbu	a5,0(a0)
ffffffffc02016b8:	e791                	bnez	a5,ffffffffc02016c4 <strcmp+0x10>
ffffffffc02016ba:	a02d                	j	ffffffffc02016e4 <strcmp+0x30>
ffffffffc02016bc:	00054783          	lbu	a5,0(a0)
ffffffffc02016c0:	cf89                	beqz	a5,ffffffffc02016da <strcmp+0x26>
ffffffffc02016c2:	85b6                	mv	a1,a3
ffffffffc02016c4:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02016c8:	0505                	addi	a0,a0,1
ffffffffc02016ca:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02016ce:	fef707e3          	beq	a4,a5,ffffffffc02016bc <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02016d2:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02016d6:	9d19                	subw	a0,a0,a4
ffffffffc02016d8:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02016da:	0015c703          	lbu	a4,1(a1)
ffffffffc02016de:	4501                	li	a0,0
}
ffffffffc02016e0:	9d19                	subw	a0,a0,a4
ffffffffc02016e2:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02016e4:	0005c703          	lbu	a4,0(a1)
ffffffffc02016e8:	4501                	li	a0,0
ffffffffc02016ea:	b7f5                	j	ffffffffc02016d6 <strcmp+0x22>

ffffffffc02016ec <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02016ec:	ce01                	beqz	a2,ffffffffc0201704 <strncmp+0x18>
ffffffffc02016ee:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02016f2:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02016f4:	cb91                	beqz	a5,ffffffffc0201708 <strncmp+0x1c>
ffffffffc02016f6:	0005c703          	lbu	a4,0(a1)
ffffffffc02016fa:	00f71763          	bne	a4,a5,ffffffffc0201708 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc02016fe:	0505                	addi	a0,a0,1
ffffffffc0201700:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201702:	f675                	bnez	a2,ffffffffc02016ee <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201704:	4501                	li	a0,0
ffffffffc0201706:	8082                	ret
ffffffffc0201708:	00054503          	lbu	a0,0(a0)
ffffffffc020170c:	0005c783          	lbu	a5,0(a1)
ffffffffc0201710:	9d1d                	subw	a0,a0,a5
}
ffffffffc0201712:	8082                	ret

ffffffffc0201714 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201714:	ca01                	beqz	a2,ffffffffc0201724 <memset+0x10>
ffffffffc0201716:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201718:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020171a:	0785                	addi	a5,a5,1
ffffffffc020171c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201720:	fef61de3          	bne	a2,a5,ffffffffc020171a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201724:	8082                	ret
