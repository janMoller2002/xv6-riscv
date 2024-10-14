
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	91010113          	addi	sp,sp,-1776 # 80007910 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
// Machine Environment Configuration Register
static inline uint64
r_menvcfg()
{
  uint64 x;
  asm volatile("csrr %0, menvcfg" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4
}

static inline void 
w_menvcfg(uint64 x)
{
  asm volatile("csrw menvcfg, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd9bf>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	1e4020ef          	jal	800022de <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	0000f517          	auipc	a0,0xf
    80000158:	7bc50513          	addi	a0,a0,1980 # 8000f910 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	0000f497          	auipc	s1,0xf
    80000164:	7b048493          	addi	s1,s1,1968 # 8000f910 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	84090913          	addi	s2,s2,-1984 # 8000f9a8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	7ed010ef          	jal	80002170 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	5ab010ef          	jal	80001f38 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	77070713          	addi	a4,a4,1904 # 8000f910 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	0c2020ef          	jal	80002294 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	0000f517          	auipc	a0,0xf
    800001ee:	72650513          	addi	a0,a0,1830 # 8000f910 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	0000f717          	auipc	a4,0xf
    80000218:	78f72a23          	sw	a5,1940(a4) # 8000f9a8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	6e650513          	addi	a0,a0,1766 # 8000f910 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	0000f517          	auipc	a0,0xf
    80000282:	69250513          	addi	a0,a0,1682 # 8000f910 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	088020ef          	jal	80002328 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	66c50513          	addi	a0,a0,1644 # 8000f910 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	64e70713          	addi	a4,a4,1614 # 8000f910 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	62878793          	addi	a5,a5,1576 # 8000f910 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	0000f797          	auipc	a5,0xf
    8000031a:	6927a783          	lw	a5,1682(a5) # 8000f9a8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	5e470713          	addi	a4,a4,1508 # 8000f910 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	5d448493          	addi	s1,s1,1492 # 8000f910 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	59270713          	addi	a4,a4,1426 # 8000f910 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	60f72e23          	sw	a5,1564(a4) # 8000f9b0 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	55e78793          	addi	a5,a5,1374 # 8000f910 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	5cc7ab23          	sw	a2,1494(a5) # 8000f9ac <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	5ca50513          	addi	a0,a0,1482 # 8000f9a8 <cons+0x98>
    800003e6:	39f010ef          	jal	80001f84 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	51450513          	addi	a0,a0,1300 # 8000f910 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	89c78793          	addi	a5,a5,-1892 # 8001fca8 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	32a60613          	addi	a2,a2,810 # 80007770 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	4f07a783          	lw	a5,1264(a5) # 8000f9d0 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	48c50513          	addi	a0,a0,1164 # 8000f9b8 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	084b8b93          	addi	s7,s7,132 # 80007770 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	23250513          	addi	a0,a0,562 # 8000f9b8 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	2207a823          	sw	zero,560(a5) # 8000f9d0 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	10f72623          	sw	a5,268(a4) # 800078d0 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	1e048493          	addi	s1,s1,480 # 8000f9b8 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	19850513          	addi	a0,a0,408 # 8000f9d8 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	06c7a783          	lw	a5,108(a5) # 800078d0 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	03e7b783          	ld	a5,62(a5) # 800078d8 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	03e73703          	ld	a4,62(a4) # 800078e0 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	110a8a93          	addi	s5,s5,272 # 8000f9d8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	00848493          	addi	s1,s1,8 # 800078d8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	00498993          	addi	s3,s3,4 # 800078e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	686010ef          	jal	80001f84 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	08c50513          	addi	a0,a0,140 # 8000f9d8 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	f787a783          	lw	a5,-136(a5) # 800078d0 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	f7e73703          	ld	a4,-130(a4) # 800078e0 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	f6e7b783          	ld	a5,-146(a5) # 800078d8 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	06298993          	addi	s3,s3,98 # 8000f9d8 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	f5a48493          	addi	s1,s1,-166 # 800078d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	f5a90913          	addi	s2,s2,-166 # 800078e0 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	5a2010ef          	jal	80001f38 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	03048493          	addi	s1,s1,48 # 8000f9d8 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f2e7b223          	sd	a4,-220(a5) # 800078e0 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	fb848493          	addi	s1,s1,-72 # 8000f9d8 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00020797          	auipc	a5,0x20
    80000a5a:	3ea78793          	addi	a5,a5,1002 # 80020e40 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	f9e90913          	addi	s2,s2,-98 # 8000fa10 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	f1050513          	addi	a0,a0,-240 # 8000fa10 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	33050513          	addi	a0,a0,816 # 80020e40 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	ee248493          	addi	s1,s1,-286 # 8000fa10 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	ece50513          	addi	a0,a0,-306 # 8000fa10 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	eaa50513          	addi	a0,a0,-342 # 8000fa10 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde1c1>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	a7a70713          	addi	a4,a4,-1414 # 800078e8 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	5c2010ef          	jal	8000245a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	44c040ef          	jal	800052e8 <plicinithart>
  }

  scheduler();        
    80000ea0:	67b000ef          	jal	80001d1a <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	556010ef          	jal	80002436 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	576010ef          	jal	8000245a <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	3e6040ef          	jal	800052ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	3fc040ef          	jal	800052e8 <plicinithart>
    binit();         // buffer cache
    80000ef0:	39d010ef          	jal	80002a8c <binit>
    iinit();         // inode table
    80000ef4:	18e020ef          	jal	80003082 <iinit>
    fileinit();      // file table
    80000ef8:	73b020ef          	jal	80003e32 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	4dc040ef          	jal	800053d8 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	44f000ef          	jal	80001b4e <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	9cf72f23          	sw	a5,-1570(a4) # 800078e8 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00007797          	auipc	a5,0x7
    80000f22:	9d27b783          	ld	a5,-1582(a5) # 800078f0 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde1b7>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00006797          	auipc	a5,0x6
    800011ae:	74a7b323          	sd	a0,1862(a5) # 800078f0 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	0000e497          	auipc	s1,0xe
    80001780:	6e448493          	addi	s1,s1,1764 # 8000fe60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	ff4df937          	lui	s2,0xff4df
    8000178a:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdb7d>
    8000178e:	0936                	slli	s2,s2,0xd
    80001790:	6f590913          	addi	s2,s2,1781
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	bd390913          	addi	s2,s2,-1069
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	7a790913          	addi	s2,s2,1959
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00014a97          	auipc	s5,0x14
    800017ac:	2b8a8a93          	addi	s5,s5,696 # 80015a60 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	8591                	srai	a1,a1,0x4
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	17048493          	addi	s1,s1,368
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	0000e517          	auipc	a0,0xe
    8000181e:	21650513          	addi	a0,a0,534 # 8000fa30 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	0000e517          	auipc	a0,0xe
    80001832:	21a50513          	addi	a0,a0,538 # 8000fa48 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	0000e497          	auipc	s1,0xe
    8000183e:	62648493          	addi	s1,s1,1574 # 8000fe60 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	ff4df937          	lui	s2,0xff4df
    80001850:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bdb7d>
    80001854:	0936                	slli	s2,s2,0xd
    80001856:	6f590913          	addi	s2,s2,1781
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	bd390913          	addi	s2,s2,-1069
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	7a790913          	addi	s2,s2,1959
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00014a17          	auipc	s4,0x14
    80001872:	1f2a0a13          	addi	s4,s4,498 # 80015a60 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	8791                	srai	a5,a5,0x4
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	17048493          	addi	s1,s1,368
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	0000e517          	auipc	a0,0xe
    800018d4:	19050513          	addi	a0,a0,400 # 8000fa60 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	0000e717          	auipc	a4,0xe
    800018f8:	13c70713          	addi	a4,a4,316 # 8000fa30 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00006797          	auipc	a5,0x6
    80001924:	f607a783          	lw	a5,-160(a5) # 80007880 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	349000ef          	jal	80002472 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	6de010ef          	jal	80003016 <fsinit>
    first = 0;
    8000193c:	00006797          	auipc	a5,0x6
    80001940:	f407a223          	sw	zero,-188(a5) # 80007880 <first.1>
    __sync_synchronize();
    80001944:	0ff0000f          	fence
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	0000e917          	auipc	s2,0xe
    8000195a:	0da90913          	addi	s2,s2,218 # 8000fa30 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00006797          	auipc	a5,0x6
    80001968:	f2078793          	addi	a5,a5,-224 # 80007884 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	06093683          	ld	a3,96(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	7128                	ld	a0,96(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001a6a:	6ca8                	ld	a0,88(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	68ac                	ld	a1,80(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001a78:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001a84:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	0000e497          	auipc	s1,0xe
    80001ab2:	3b248493          	addi	s1,s1,946 # 8000fe60 <proc>
    80001ab6:	00014917          	auipc	s2,0x14
    80001aba:	faa90913          	addi	s2,s2,-86 # 80015a60 <tickslock>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	17048493          	addi	s1,s1,368
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a0a1                	j	80001b20 <allocproc+0x7e>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  p->priority = 0;
    80001ae4:	0204aa23          	sw	zero,52(s1)
  p->boost = 1;
    80001ae8:	dc9c                	sw	a5,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001aea:	83aff0ef          	jal	80000b24 <kalloc>
    80001aee:	892a                	mv	s2,a0
    80001af0:	f0a8                	sd	a0,96(s1)
    80001af2:	cd15                	beqz	a0,80001b2e <allocproc+0x8c>
  p->pagetable = proc_pagetable(p);
    80001af4:	8526                	mv	a0,s1
    80001af6:	e93ff0ef          	jal	80001988 <proc_pagetable>
    80001afa:	892a                	mv	s2,a0
    80001afc:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001afe:	c121                	beqz	a0,80001b3e <allocproc+0x9c>
  memset(&p->context, 0, sizeof(p->context));
    80001b00:	07000613          	li	a2,112
    80001b04:	4581                	li	a1,0
    80001b06:	06848513          	addi	a0,s1,104
    80001b0a:	9beff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b0e:	00000797          	auipc	a5,0x0
    80001b12:	e0278793          	addi	a5,a5,-510 # 80001910 <forkret>
    80001b16:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b18:	64bc                	ld	a5,72(s1)
    80001b1a:	6705                	lui	a4,0x1
    80001b1c:	97ba                	add	a5,a5,a4
    80001b1e:	f8bc                	sd	a5,112(s1)
}
    80001b20:	8526                	mv	a0,s1
    80001b22:	60e2                	ld	ra,24(sp)
    80001b24:	6442                	ld	s0,16(sp)
    80001b26:	64a2                	ld	s1,8(sp)
    80001b28:	6902                	ld	s2,0(sp)
    80001b2a:	6105                	addi	sp,sp,32
    80001b2c:	8082                	ret
    freeproc(p);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	f23ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b34:	8526                	mv	a0,s1
    80001b36:	956ff0ef          	jal	80000c8c <release>
    return 0;
    80001b3a:	84ca                	mv	s1,s2
    80001b3c:	b7d5                	j	80001b20 <allocproc+0x7e>
    freeproc(p);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	f13ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b44:	8526                	mv	a0,s1
    80001b46:	946ff0ef          	jal	80000c8c <release>
    return 0;
    80001b4a:	84ca                	mv	s1,s2
    80001b4c:	bfd1                	j	80001b20 <allocproc+0x7e>

0000000080001b4e <userinit>:
{
    80001b4e:	1101                	addi	sp,sp,-32
    80001b50:	ec06                	sd	ra,24(sp)
    80001b52:	e822                	sd	s0,16(sp)
    80001b54:	e426                	sd	s1,8(sp)
    80001b56:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b58:	f4bff0ef          	jal	80001aa2 <allocproc>
    80001b5c:	84aa                	mv	s1,a0
  initproc = p;
    80001b5e:	00006797          	auipc	a5,0x6
    80001b62:	d8a7bd23          	sd	a0,-614(a5) # 800078f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b66:	03400613          	li	a2,52
    80001b6a:	00006597          	auipc	a1,0x6
    80001b6e:	d2658593          	addi	a1,a1,-730 # 80007890 <initcode>
    80001b72:	6d28                	ld	a0,88(a0)
    80001b74:	f28ff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b78:	6785                	lui	a5,0x1
    80001b7a:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b7c:	70b8                	ld	a4,96(s1)
    80001b7e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b82:	70b8                	ld	a4,96(s1)
    80001b84:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b86:	4641                	li	a2,16
    80001b88:	00005597          	auipc	a1,0x5
    80001b8c:	69858593          	addi	a1,a1,1688 # 80007220 <etext+0x220>
    80001b90:	16048513          	addi	a0,s1,352
    80001b94:	a72ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b98:	00005517          	auipc	a0,0x5
    80001b9c:	69850513          	addi	a0,a0,1688 # 80007230 <etext+0x230>
    80001ba0:	585010ef          	jal	80003924 <namei>
    80001ba4:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001ba8:	478d                	li	a5,3
    80001baa:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bac:	8526                	mv	a0,s1
    80001bae:	8deff0ef          	jal	80000c8c <release>
}
    80001bb2:	60e2                	ld	ra,24(sp)
    80001bb4:	6442                	ld	s0,16(sp)
    80001bb6:	64a2                	ld	s1,8(sp)
    80001bb8:	6105                	addi	sp,sp,32
    80001bba:	8082                	ret

0000000080001bbc <growproc>:
{
    80001bbc:	1101                	addi	sp,sp,-32
    80001bbe:	ec06                	sd	ra,24(sp)
    80001bc0:	e822                	sd	s0,16(sp)
    80001bc2:	e426                	sd	s1,8(sp)
    80001bc4:	e04a                	sd	s2,0(sp)
    80001bc6:	1000                	addi	s0,sp,32
    80001bc8:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bca:	d17ff0ef          	jal	800018e0 <myproc>
    80001bce:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bd0:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001bd2:	01204c63          	bgtz	s2,80001bea <growproc+0x2e>
  } else if(n < 0){
    80001bd6:	02094463          	bltz	s2,80001bfe <growproc+0x42>
  p->sz = sz;
    80001bda:	e8ac                	sd	a1,80(s1)
  return 0;
    80001bdc:	4501                	li	a0,0
}
    80001bde:	60e2                	ld	ra,24(sp)
    80001be0:	6442                	ld	s0,16(sp)
    80001be2:	64a2                	ld	s1,8(sp)
    80001be4:	6902                	ld	s2,0(sp)
    80001be6:	6105                	addi	sp,sp,32
    80001be8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bea:	4691                	li	a3,4
    80001bec:	00b90633          	add	a2,s2,a1
    80001bf0:	6d28                	ld	a0,88(a0)
    80001bf2:	f4cff0ef          	jal	8000133e <uvmalloc>
    80001bf6:	85aa                	mv	a1,a0
    80001bf8:	f16d                	bnez	a0,80001bda <growproc+0x1e>
      return -1;
    80001bfa:	557d                	li	a0,-1
    80001bfc:	b7cd                	j	80001bde <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bfe:	00b90633          	add	a2,s2,a1
    80001c02:	6d28                	ld	a0,88(a0)
    80001c04:	ef6ff0ef          	jal	800012fa <uvmdealloc>
    80001c08:	85aa                	mv	a1,a0
    80001c0a:	bfc1                	j	80001bda <growproc+0x1e>

0000000080001c0c <fork>:
{
    80001c0c:	7139                	addi	sp,sp,-64
    80001c0e:	fc06                	sd	ra,56(sp)
    80001c10:	f822                	sd	s0,48(sp)
    80001c12:	f04a                	sd	s2,32(sp)
    80001c14:	e456                	sd	s5,8(sp)
    80001c16:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c18:	cc9ff0ef          	jal	800018e0 <myproc>
    80001c1c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c1e:	e85ff0ef          	jal	80001aa2 <allocproc>
    80001c22:	0e050a63          	beqz	a0,80001d16 <fork+0x10a>
    80001c26:	e852                	sd	s4,16(sp)
    80001c28:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c2a:	050ab603          	ld	a2,80(s5)
    80001c2e:	6d2c                	ld	a1,88(a0)
    80001c30:	058ab503          	ld	a0,88(s5)
    80001c34:	843ff0ef          	jal	80001476 <uvmcopy>
    80001c38:	04054a63          	bltz	a0,80001c8c <fork+0x80>
    80001c3c:	f426                	sd	s1,40(sp)
    80001c3e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c40:	050ab783          	ld	a5,80(s5)
    80001c44:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c48:	060ab683          	ld	a3,96(s5)
    80001c4c:	87b6                	mv	a5,a3
    80001c4e:	060a3703          	ld	a4,96(s4)
    80001c52:	12068693          	addi	a3,a3,288
    80001c56:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c5a:	6788                	ld	a0,8(a5)
    80001c5c:	6b8c                	ld	a1,16(a5)
    80001c5e:	6f90                	ld	a2,24(a5)
    80001c60:	01073023          	sd	a6,0(a4)
    80001c64:	e708                	sd	a0,8(a4)
    80001c66:	eb0c                	sd	a1,16(a4)
    80001c68:	ef10                	sd	a2,24(a4)
    80001c6a:	02078793          	addi	a5,a5,32
    80001c6e:	02070713          	addi	a4,a4,32
    80001c72:	fed792e3          	bne	a5,a3,80001c56 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c76:	060a3783          	ld	a5,96(s4)
    80001c7a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c7e:	0d8a8493          	addi	s1,s5,216
    80001c82:	0d8a0913          	addi	s2,s4,216
    80001c86:	158a8993          	addi	s3,s5,344
    80001c8a:	a831                	j	80001ca6 <fork+0x9a>
    freeproc(np);
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	dc5ff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c92:	8552                	mv	a0,s4
    80001c94:	ff9fe0ef          	jal	80000c8c <release>
    return -1;
    80001c98:	597d                	li	s2,-1
    80001c9a:	6a42                	ld	s4,16(sp)
    80001c9c:	a0b5                	j	80001d08 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c9e:	04a1                	addi	s1,s1,8
    80001ca0:	0921                	addi	s2,s2,8
    80001ca2:	01348963          	beq	s1,s3,80001cb4 <fork+0xa8>
    if(p->ofile[i])
    80001ca6:	6088                	ld	a0,0(s1)
    80001ca8:	d97d                	beqz	a0,80001c9e <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001caa:	20a020ef          	jal	80003eb4 <filedup>
    80001cae:	00a93023          	sd	a0,0(s2)
    80001cb2:	b7f5                	j	80001c9e <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cb4:	158ab503          	ld	a0,344(s5)
    80001cb8:	55c010ef          	jal	80003214 <idup>
    80001cbc:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cc0:	4641                	li	a2,16
    80001cc2:	160a8593          	addi	a1,s5,352
    80001cc6:	160a0513          	addi	a0,s4,352
    80001cca:	93cff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cce:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cd2:	8552                	mv	a0,s4
    80001cd4:	fb9fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cd8:	0000e497          	auipc	s1,0xe
    80001cdc:	d7048493          	addi	s1,s1,-656 # 8000fa48 <wait_lock>
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	f13fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001ce6:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001cea:	8526                	mv	a0,s1
    80001cec:	fa1fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cf0:	8552                	mv	a0,s4
    80001cf2:	f03fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001cf6:	478d                	li	a5,3
    80001cf8:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cfc:	8552                	mv	a0,s4
    80001cfe:	f8ffe0ef          	jal	80000c8c <release>
  return pid;
    80001d02:	74a2                	ld	s1,40(sp)
    80001d04:	69e2                	ld	s3,24(sp)
    80001d06:	6a42                	ld	s4,16(sp)
}
    80001d08:	854a                	mv	a0,s2
    80001d0a:	70e2                	ld	ra,56(sp)
    80001d0c:	7442                	ld	s0,48(sp)
    80001d0e:	7902                	ld	s2,32(sp)
    80001d10:	6aa2                	ld	s5,8(sp)
    80001d12:	6121                	addi	sp,sp,64
    80001d14:	8082                	ret
    return -1;
    80001d16:	597d                	li	s2,-1
    80001d18:	bfc5                	j	80001d08 <fork+0xfc>

0000000080001d1a <scheduler>:
{
    80001d1a:	711d                	addi	sp,sp,-96
    80001d1c:	ec86                	sd	ra,88(sp)
    80001d1e:	e8a2                	sd	s0,80(sp)
    80001d20:	e4a6                	sd	s1,72(sp)
    80001d22:	e0ca                	sd	s2,64(sp)
    80001d24:	fc4e                	sd	s3,56(sp)
    80001d26:	f852                	sd	s4,48(sp)
    80001d28:	f456                	sd	s5,40(sp)
    80001d2a:	f05a                	sd	s6,32(sp)
    80001d2c:	ec5e                	sd	s7,24(sp)
    80001d2e:	e862                	sd	s8,16(sp)
    80001d30:	e466                	sd	s9,8(sp)
    80001d32:	e06a                	sd	s10,0(sp)
    80001d34:	1080                	addi	s0,sp,96
    80001d36:	8792                	mv	a5,tp
  int id = r_tp();
    80001d38:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d3a:	00779c13          	slli	s8,a5,0x7
    80001d3e:	0000e717          	auipc	a4,0xe
    80001d42:	cf270713          	addi	a4,a4,-782 # 8000fa30 <pid_lock>
    80001d46:	9762                	add	a4,a4,s8
    80001d48:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &chosen_proc->context);
    80001d4c:	0000e717          	auipc	a4,0xe
    80001d50:	d1c70713          	addi	a4,a4,-740 # 8000fa68 <cpus+0x8>
    80001d54:	9c3a                	add	s8,s8,a4
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d56:	00014917          	auipc	s2,0x14
    80001d5a:	d0a90913          	addi	s2,s2,-758 # 80015a60 <tickslock>
      c->proc = chosen_proc;
    80001d5e:	079e                	slli	a5,a5,0x7
    80001d60:	0000eb97          	auipc	s7,0xe
    80001d64:	cd0b8b93          	addi	s7,s7,-816 # 8000fa30 <pid_lock>
    80001d68:	9bbe                	add	s7,s7,a5
          if(p->priority >= 9) {
    80001d6a:	4aa1                	li	s5,8
            p->boost = 1;
    80001d6c:	4b05                	li	s6,1
    80001d6e:	a0e1                	j	80001e36 <scheduler+0x11c>
          release(&p->lock);
    80001d70:	8526                	mv	a0,s1
    80001d72:	f1bfe0ef          	jal	80000c8c <release>
    80001d76:	a021                	j	80001d7e <scheduler+0x64>
        release(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	f13fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d7e:	17048493          	addi	s1,s1,368
    80001d82:	03248763          	beq	s1,s2,80001db0 <scheduler+0x96>
      acquire(&p->lock);
    80001d86:	8526                	mv	a0,s1
    80001d88:	e6dfe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d8c:	4c9c                	lw	a5,24(s1)
    80001d8e:	ff4795e3          	bne	a5,s4,80001d78 <scheduler+0x5e>
        if(p->priority < highest_priority) {
    80001d92:	0344a983          	lw	s3,52(s1)
    80001d96:	fda9dde3          	bge	s3,s10,80001d70 <scheduler+0x56>
          if (chosen_proc != 0) {
    80001d9a:	000c8863          	beqz	s9,80001daa <scheduler+0x90>
            release(&chosen_proc->lock);
    80001d9e:	8566                	mv	a0,s9
    80001da0:	eedfe0ef          	jal	80000c8c <release>
          highest_priority = p->priority;
    80001da4:	8d4e                	mv	s10,s3
          chosen_proc = p;
    80001da6:	8ca6                	mv	s9,s1
    80001da8:	bfd9                	j	80001d7e <scheduler+0x64>
          highest_priority = p->priority;
    80001daa:	8d4e                	mv	s10,s3
          chosen_proc = p;
    80001dac:	8ca6                	mv	s9,s1
    80001dae:	bfc1                	j	80001d7e <scheduler+0x64>
    if(chosen_proc != 0) {
    80001db0:	060c8b63          	beqz	s9,80001e26 <scheduler+0x10c>
      chosen_proc->state = RUNNING;
    80001db4:	4791                	li	a5,4
    80001db6:	00fcac23          	sw	a5,24(s9)
      c->proc = chosen_proc;
    80001dba:	039bb823          	sd	s9,48(s7)
      swtch(&c->context, &chosen_proc->context);
    80001dbe:	068c8593          	addi	a1,s9,104
    80001dc2:	8562                	mv	a0,s8
    80001dc4:	608000ef          	jal	800023cc <swtch>
      c->proc = 0;
    80001dc8:	020bb823          	sd	zero,48(s7)
      release(&chosen_proc->lock);
    80001dcc:	8566                	mv	a0,s9
    80001dce:	ebffe0ef          	jal	80000c8c <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001dd2:	0000e497          	auipc	s1,0xe
    80001dd6:	08e48493          	addi	s1,s1,142 # 8000fe60 <proc>
        if(p->state != ZOMBIE && p->state != UNUSED) {
    80001dda:	4995                	li	s3,5
            p->priority = 9;
    80001ddc:	4ca5                	li	s9,9
            p->boost = -1;
    80001dde:	5a7d                	li	s4,-1
    80001de0:	a819                	j	80001df6 <scheduler+0xdc>
          } else if(p->priority <= 0) {
    80001de2:	02e05d63          	blez	a4,80001e1c <scheduler+0x102>
          p->priority += p->boost;
    80001de6:	d8dc                	sw	a5,52(s1)
        release(&p->lock);
    80001de8:	8526                	mv	a0,s1
    80001dea:	ea3fe0ef          	jal	80000c8c <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80001dee:	17048493          	addi	s1,s1,368
    80001df2:	05248263          	beq	s1,s2,80001e36 <scheduler+0x11c>
        acquire(&p->lock);
    80001df6:	8526                	mv	a0,s1
    80001df8:	dfdfe0ef          	jal	80000bf4 <acquire>
        if(p->state != ZOMBIE && p->state != UNUSED) {
    80001dfc:	4c9c                	lw	a5,24(s1)
    80001dfe:	ff3785e3          	beq	a5,s3,80001de8 <scheduler+0xce>
    80001e02:	d3fd                	beqz	a5,80001de8 <scheduler+0xce>
          p->priority += p->boost;
    80001e04:	58d8                	lw	a4,52(s1)
    80001e06:	5c9c                	lw	a5,56(s1)
    80001e08:	9fb9                	addw	a5,a5,a4
    80001e0a:	0007871b          	sext.w	a4,a5
          if(p->priority >= 9) {
    80001e0e:	fceadae3          	bge	s5,a4,80001de2 <scheduler+0xc8>
            p->priority = 9;
    80001e12:	0394aa23          	sw	s9,52(s1)
            p->boost = -1;
    80001e16:	0344ac23          	sw	s4,56(s1)
    80001e1a:	b7f9                	j	80001de8 <scheduler+0xce>
            p->priority = 0;
    80001e1c:	0204aa23          	sw	zero,52(s1)
            p->boost = 1;
    80001e20:	0364ac23          	sw	s6,56(s1)
    80001e24:	b7d1                	j	80001de8 <scheduler+0xce>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e26:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e2a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e2e:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e32:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e3a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e3e:	10079073          	csrw	sstatus,a5
    int highest_priority = 10; // Valores de prioridad están entre 0 y 9
    80001e42:	4d29                	li	s10,10
    chosen_proc = 0;
    80001e44:	4c81                	li	s9,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e46:	0000e497          	auipc	s1,0xe
    80001e4a:	01a48493          	addi	s1,s1,26 # 8000fe60 <proc>
      if(p->state == RUNNABLE) {
    80001e4e:	4a0d                	li	s4,3
    80001e50:	bf1d                	j	80001d86 <scheduler+0x6c>

0000000080001e52 <sched>:
{
    80001e52:	7179                	addi	sp,sp,-48
    80001e54:	f406                	sd	ra,40(sp)
    80001e56:	f022                	sd	s0,32(sp)
    80001e58:	ec26                	sd	s1,24(sp)
    80001e5a:	e84a                	sd	s2,16(sp)
    80001e5c:	e44e                	sd	s3,8(sp)
    80001e5e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e60:	a81ff0ef          	jal	800018e0 <myproc>
    80001e64:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e66:	d25fe0ef          	jal	80000b8a <holding>
    80001e6a:	c92d                	beqz	a0,80001edc <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e6c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e6e:	2781                	sext.w	a5,a5
    80001e70:	079e                	slli	a5,a5,0x7
    80001e72:	0000e717          	auipc	a4,0xe
    80001e76:	bbe70713          	addi	a4,a4,-1090 # 8000fa30 <pid_lock>
    80001e7a:	97ba                	add	a5,a5,a4
    80001e7c:	0a87a703          	lw	a4,168(a5)
    80001e80:	4785                	li	a5,1
    80001e82:	06f71363          	bne	a4,a5,80001ee8 <sched+0x96>
  if(p->state == RUNNING)
    80001e86:	4c98                	lw	a4,24(s1)
    80001e88:	4791                	li	a5,4
    80001e8a:	06f70563          	beq	a4,a5,80001ef4 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e92:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e94:	e7b5                	bnez	a5,80001f00 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e96:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e98:	0000e917          	auipc	s2,0xe
    80001e9c:	b9890913          	addi	s2,s2,-1128 # 8000fa30 <pid_lock>
    80001ea0:	2781                	sext.w	a5,a5
    80001ea2:	079e                	slli	a5,a5,0x7
    80001ea4:	97ca                	add	a5,a5,s2
    80001ea6:	0ac7a983          	lw	s3,172(a5)
    80001eaa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001eac:	2781                	sext.w	a5,a5
    80001eae:	079e                	slli	a5,a5,0x7
    80001eb0:	0000e597          	auipc	a1,0xe
    80001eb4:	bb858593          	addi	a1,a1,-1096 # 8000fa68 <cpus+0x8>
    80001eb8:	95be                	add	a1,a1,a5
    80001eba:	06848513          	addi	a0,s1,104
    80001ebe:	50e000ef          	jal	800023cc <swtch>
    80001ec2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ec4:	2781                	sext.w	a5,a5
    80001ec6:	079e                	slli	a5,a5,0x7
    80001ec8:	993e                	add	s2,s2,a5
    80001eca:	0b392623          	sw	s3,172(s2)
}
    80001ece:	70a2                	ld	ra,40(sp)
    80001ed0:	7402                	ld	s0,32(sp)
    80001ed2:	64e2                	ld	s1,24(sp)
    80001ed4:	6942                	ld	s2,16(sp)
    80001ed6:	69a2                	ld	s3,8(sp)
    80001ed8:	6145                	addi	sp,sp,48
    80001eda:	8082                	ret
    panic("sched p->lock");
    80001edc:	00005517          	auipc	a0,0x5
    80001ee0:	35c50513          	addi	a0,a0,860 # 80007238 <etext+0x238>
    80001ee4:	8b1fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001ee8:	00005517          	auipc	a0,0x5
    80001eec:	36050513          	addi	a0,a0,864 # 80007248 <etext+0x248>
    80001ef0:	8a5fe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001ef4:	00005517          	auipc	a0,0x5
    80001ef8:	36450513          	addi	a0,a0,868 # 80007258 <etext+0x258>
    80001efc:	899fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001f00:	00005517          	auipc	a0,0x5
    80001f04:	36850513          	addi	a0,a0,872 # 80007268 <etext+0x268>
    80001f08:	88dfe0ef          	jal	80000794 <panic>

0000000080001f0c <yield>:
{
    80001f0c:	1101                	addi	sp,sp,-32
    80001f0e:	ec06                	sd	ra,24(sp)
    80001f10:	e822                	sd	s0,16(sp)
    80001f12:	e426                	sd	s1,8(sp)
    80001f14:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f16:	9cbff0ef          	jal	800018e0 <myproc>
    80001f1a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f1c:	cd9fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001f20:	478d                	li	a5,3
    80001f22:	cc9c                	sw	a5,24(s1)
  sched();
    80001f24:	f2fff0ef          	jal	80001e52 <sched>
  release(&p->lock);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	d63fe0ef          	jal	80000c8c <release>
}
    80001f2e:	60e2                	ld	ra,24(sp)
    80001f30:	6442                	ld	s0,16(sp)
    80001f32:	64a2                	ld	s1,8(sp)
    80001f34:	6105                	addi	sp,sp,32
    80001f36:	8082                	ret

0000000080001f38 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f38:	7179                	addi	sp,sp,-48
    80001f3a:	f406                	sd	ra,40(sp)
    80001f3c:	f022                	sd	s0,32(sp)
    80001f3e:	ec26                	sd	s1,24(sp)
    80001f40:	e84a                	sd	s2,16(sp)
    80001f42:	e44e                	sd	s3,8(sp)
    80001f44:	1800                	addi	s0,sp,48
    80001f46:	89aa                	mv	s3,a0
    80001f48:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f4a:	997ff0ef          	jal	800018e0 <myproc>
    80001f4e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f50:	ca5fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001f54:	854a                	mv	a0,s2
    80001f56:	d37fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001f5a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f5e:	4789                	li	a5,2
    80001f60:	cc9c                	sw	a5,24(s1)

  sched();
    80001f62:	ef1ff0ef          	jal	80001e52 <sched>

  // Tidy up.
  p->chan = 0;
    80001f66:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	d21fe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001f70:	854a                	mv	a0,s2
    80001f72:	c83fe0ef          	jal	80000bf4 <acquire>
}
    80001f76:	70a2                	ld	ra,40(sp)
    80001f78:	7402                	ld	s0,32(sp)
    80001f7a:	64e2                	ld	s1,24(sp)
    80001f7c:	6942                	ld	s2,16(sp)
    80001f7e:	69a2                	ld	s3,8(sp)
    80001f80:	6145                	addi	sp,sp,48
    80001f82:	8082                	ret

0000000080001f84 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f84:	7139                	addi	sp,sp,-64
    80001f86:	fc06                	sd	ra,56(sp)
    80001f88:	f822                	sd	s0,48(sp)
    80001f8a:	f426                	sd	s1,40(sp)
    80001f8c:	f04a                	sd	s2,32(sp)
    80001f8e:	ec4e                	sd	s3,24(sp)
    80001f90:	e852                	sd	s4,16(sp)
    80001f92:	e456                	sd	s5,8(sp)
    80001f94:	0080                	addi	s0,sp,64
    80001f96:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f98:	0000e497          	auipc	s1,0xe
    80001f9c:	ec848493          	addi	s1,s1,-312 # 8000fe60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001fa0:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fa2:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fa4:	00014917          	auipc	s2,0x14
    80001fa8:	abc90913          	addi	s2,s2,-1348 # 80015a60 <tickslock>
    80001fac:	a801                	j	80001fbc <wakeup+0x38>
      }
      release(&p->lock);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	cddfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fb4:	17048493          	addi	s1,s1,368
    80001fb8:	03248263          	beq	s1,s2,80001fdc <wakeup+0x58>
    if(p != myproc()){
    80001fbc:	925ff0ef          	jal	800018e0 <myproc>
    80001fc0:	fea48ae3          	beq	s1,a0,80001fb4 <wakeup+0x30>
      acquire(&p->lock);
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	c2ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fca:	4c9c                	lw	a5,24(s1)
    80001fcc:	ff3791e3          	bne	a5,s3,80001fae <wakeup+0x2a>
    80001fd0:	709c                	ld	a5,32(s1)
    80001fd2:	fd479ee3          	bne	a5,s4,80001fae <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fd6:	0154ac23          	sw	s5,24(s1)
    80001fda:	bfd1                	j	80001fae <wakeup+0x2a>
    }
  }
}
    80001fdc:	70e2                	ld	ra,56(sp)
    80001fde:	7442                	ld	s0,48(sp)
    80001fe0:	74a2                	ld	s1,40(sp)
    80001fe2:	7902                	ld	s2,32(sp)
    80001fe4:	69e2                	ld	s3,24(sp)
    80001fe6:	6a42                	ld	s4,16(sp)
    80001fe8:	6aa2                	ld	s5,8(sp)
    80001fea:	6121                	addi	sp,sp,64
    80001fec:	8082                	ret

0000000080001fee <reparent>:
{
    80001fee:	7179                	addi	sp,sp,-48
    80001ff0:	f406                	sd	ra,40(sp)
    80001ff2:	f022                	sd	s0,32(sp)
    80001ff4:	ec26                	sd	s1,24(sp)
    80001ff6:	e84a                	sd	s2,16(sp)
    80001ff8:	e44e                	sd	s3,8(sp)
    80001ffa:	e052                	sd	s4,0(sp)
    80001ffc:	1800                	addi	s0,sp,48
    80001ffe:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002000:	0000e497          	auipc	s1,0xe
    80002004:	e6048493          	addi	s1,s1,-416 # 8000fe60 <proc>
      pp->parent = initproc;
    80002008:	00006a17          	auipc	s4,0x6
    8000200c:	8f0a0a13          	addi	s4,s4,-1808 # 800078f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002010:	00014997          	auipc	s3,0x14
    80002014:	a5098993          	addi	s3,s3,-1456 # 80015a60 <tickslock>
    80002018:	a029                	j	80002022 <reparent+0x34>
    8000201a:	17048493          	addi	s1,s1,368
    8000201e:	01348b63          	beq	s1,s3,80002034 <reparent+0x46>
    if(pp->parent == p){
    80002022:	60bc                	ld	a5,64(s1)
    80002024:	ff279be3          	bne	a5,s2,8000201a <reparent+0x2c>
      pp->parent = initproc;
    80002028:	000a3503          	ld	a0,0(s4)
    8000202c:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    8000202e:	f57ff0ef          	jal	80001f84 <wakeup>
    80002032:	b7e5                	j	8000201a <reparent+0x2c>
}
    80002034:	70a2                	ld	ra,40(sp)
    80002036:	7402                	ld	s0,32(sp)
    80002038:	64e2                	ld	s1,24(sp)
    8000203a:	6942                	ld	s2,16(sp)
    8000203c:	69a2                	ld	s3,8(sp)
    8000203e:	6a02                	ld	s4,0(sp)
    80002040:	6145                	addi	sp,sp,48
    80002042:	8082                	ret

0000000080002044 <exit>:
{
    80002044:	7179                	addi	sp,sp,-48
    80002046:	f406                	sd	ra,40(sp)
    80002048:	f022                	sd	s0,32(sp)
    8000204a:	ec26                	sd	s1,24(sp)
    8000204c:	e84a                	sd	s2,16(sp)
    8000204e:	e44e                	sd	s3,8(sp)
    80002050:	e052                	sd	s4,0(sp)
    80002052:	1800                	addi	s0,sp,48
    80002054:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002056:	88bff0ef          	jal	800018e0 <myproc>
    8000205a:	89aa                	mv	s3,a0
  if(p == initproc)
    8000205c:	00006797          	auipc	a5,0x6
    80002060:	89c7b783          	ld	a5,-1892(a5) # 800078f8 <initproc>
    80002064:	0d850493          	addi	s1,a0,216
    80002068:	15850913          	addi	s2,a0,344
    8000206c:	00a79f63          	bne	a5,a0,8000208a <exit+0x46>
    panic("init exiting");
    80002070:	00005517          	auipc	a0,0x5
    80002074:	21050513          	addi	a0,a0,528 # 80007280 <etext+0x280>
    80002078:	f1cfe0ef          	jal	80000794 <panic>
      fileclose(f);
    8000207c:	67f010ef          	jal	80003efa <fileclose>
      p->ofile[fd] = 0;
    80002080:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002084:	04a1                	addi	s1,s1,8
    80002086:	01248563          	beq	s1,s2,80002090 <exit+0x4c>
    if(p->ofile[fd]){
    8000208a:	6088                	ld	a0,0(s1)
    8000208c:	f965                	bnez	a0,8000207c <exit+0x38>
    8000208e:	bfdd                	j	80002084 <exit+0x40>
  begin_op();
    80002090:	251010ef          	jal	80003ae0 <begin_op>
  iput(p->cwd);
    80002094:	1589b503          	ld	a0,344(s3)
    80002098:	334010ef          	jal	800033cc <iput>
  end_op();
    8000209c:	2af010ef          	jal	80003b4a <end_op>
  p->cwd = 0;
    800020a0:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    800020a4:	0000e497          	auipc	s1,0xe
    800020a8:	9a448493          	addi	s1,s1,-1628 # 8000fa48 <wait_lock>
    800020ac:	8526                	mv	a0,s1
    800020ae:	b47fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    800020b2:	854e                	mv	a0,s3
    800020b4:	f3bff0ef          	jal	80001fee <reparent>
  wakeup(p->parent);
    800020b8:	0409b503          	ld	a0,64(s3)
    800020bc:	ec9ff0ef          	jal	80001f84 <wakeup>
  acquire(&p->lock);
    800020c0:	854e                	mv	a0,s3
    800020c2:	b33fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    800020c6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020ca:	4795                	li	a5,5
    800020cc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	bbbfe0ef          	jal	80000c8c <release>
  sched();
    800020d6:	d7dff0ef          	jal	80001e52 <sched>
  panic("zombie exit");
    800020da:	00005517          	auipc	a0,0x5
    800020de:	1b650513          	addi	a0,a0,438 # 80007290 <etext+0x290>
    800020e2:	eb2fe0ef          	jal	80000794 <panic>

00000000800020e6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800020e6:	7179                	addi	sp,sp,-48
    800020e8:	f406                	sd	ra,40(sp)
    800020ea:	f022                	sd	s0,32(sp)
    800020ec:	ec26                	sd	s1,24(sp)
    800020ee:	e84a                	sd	s2,16(sp)
    800020f0:	e44e                	sd	s3,8(sp)
    800020f2:	1800                	addi	s0,sp,48
    800020f4:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020f6:	0000e497          	auipc	s1,0xe
    800020fa:	d6a48493          	addi	s1,s1,-662 # 8000fe60 <proc>
    800020fe:	00014997          	auipc	s3,0x14
    80002102:	96298993          	addi	s3,s3,-1694 # 80015a60 <tickslock>
    acquire(&p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	aedfe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    8000210c:	589c                	lw	a5,48(s1)
    8000210e:	01278b63          	beq	a5,s2,80002124 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002112:	8526                	mv	a0,s1
    80002114:	b79fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002118:	17048493          	addi	s1,s1,368
    8000211c:	ff3495e3          	bne	s1,s3,80002106 <kill+0x20>
  }
  return -1;
    80002120:	557d                	li	a0,-1
    80002122:	a819                	j	80002138 <kill+0x52>
      p->killed = 1;
    80002124:	4785                	li	a5,1
    80002126:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002128:	4c98                	lw	a4,24(s1)
    8000212a:	4789                	li	a5,2
    8000212c:	00f70d63          	beq	a4,a5,80002146 <kill+0x60>
      release(&p->lock);
    80002130:	8526                	mv	a0,s1
    80002132:	b5bfe0ef          	jal	80000c8c <release>
      return 0;
    80002136:	4501                	li	a0,0
}
    80002138:	70a2                	ld	ra,40(sp)
    8000213a:	7402                	ld	s0,32(sp)
    8000213c:	64e2                	ld	s1,24(sp)
    8000213e:	6942                	ld	s2,16(sp)
    80002140:	69a2                	ld	s3,8(sp)
    80002142:	6145                	addi	sp,sp,48
    80002144:	8082                	ret
        p->state = RUNNABLE;
    80002146:	478d                	li	a5,3
    80002148:	cc9c                	sw	a5,24(s1)
    8000214a:	b7dd                	j	80002130 <kill+0x4a>

000000008000214c <setkilled>:

void
setkilled(struct proc *p)
{
    8000214c:	1101                	addi	sp,sp,-32
    8000214e:	ec06                	sd	ra,24(sp)
    80002150:	e822                	sd	s0,16(sp)
    80002152:	e426                	sd	s1,8(sp)
    80002154:	1000                	addi	s0,sp,32
    80002156:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002158:	a9dfe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    8000215c:	4785                	li	a5,1
    8000215e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	b2bfe0ef          	jal	80000c8c <release>
}
    80002166:	60e2                	ld	ra,24(sp)
    80002168:	6442                	ld	s0,16(sp)
    8000216a:	64a2                	ld	s1,8(sp)
    8000216c:	6105                	addi	sp,sp,32
    8000216e:	8082                	ret

0000000080002170 <killed>:

int
killed(struct proc *p)
{
    80002170:	1101                	addi	sp,sp,-32
    80002172:	ec06                	sd	ra,24(sp)
    80002174:	e822                	sd	s0,16(sp)
    80002176:	e426                	sd	s1,8(sp)
    80002178:	e04a                	sd	s2,0(sp)
    8000217a:	1000                	addi	s0,sp,32
    8000217c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000217e:	a77fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002182:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002186:	8526                	mv	a0,s1
    80002188:	b05fe0ef          	jal	80000c8c <release>
  return k;
}
    8000218c:	854a                	mv	a0,s2
    8000218e:	60e2                	ld	ra,24(sp)
    80002190:	6442                	ld	s0,16(sp)
    80002192:	64a2                	ld	s1,8(sp)
    80002194:	6902                	ld	s2,0(sp)
    80002196:	6105                	addi	sp,sp,32
    80002198:	8082                	ret

000000008000219a <wait>:
{
    8000219a:	715d                	addi	sp,sp,-80
    8000219c:	e486                	sd	ra,72(sp)
    8000219e:	e0a2                	sd	s0,64(sp)
    800021a0:	fc26                	sd	s1,56(sp)
    800021a2:	f84a                	sd	s2,48(sp)
    800021a4:	f44e                	sd	s3,40(sp)
    800021a6:	f052                	sd	s4,32(sp)
    800021a8:	ec56                	sd	s5,24(sp)
    800021aa:	e85a                	sd	s6,16(sp)
    800021ac:	e45e                	sd	s7,8(sp)
    800021ae:	e062                	sd	s8,0(sp)
    800021b0:	0880                	addi	s0,sp,80
    800021b2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021b4:	f2cff0ef          	jal	800018e0 <myproc>
    800021b8:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021ba:	0000e517          	auipc	a0,0xe
    800021be:	88e50513          	addi	a0,a0,-1906 # 8000fa48 <wait_lock>
    800021c2:	a33fe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    800021c6:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800021c8:	4a15                	li	s4,5
        havekids = 1;
    800021ca:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021cc:	00014997          	auipc	s3,0x14
    800021d0:	89498993          	addi	s3,s3,-1900 # 80015a60 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021d4:	0000ec17          	auipc	s8,0xe
    800021d8:	874c0c13          	addi	s8,s8,-1932 # 8000fa48 <wait_lock>
    800021dc:	a871                	j	80002278 <wait+0xde>
          pid = pp->pid;
    800021de:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021e2:	000b0c63          	beqz	s6,800021fa <wait+0x60>
    800021e6:	4691                	li	a3,4
    800021e8:	02c48613          	addi	a2,s1,44
    800021ec:	85da                	mv	a1,s6
    800021ee:	05893503          	ld	a0,88(s2)
    800021f2:	b60ff0ef          	jal	80001552 <copyout>
    800021f6:	02054b63          	bltz	a0,8000222c <wait+0x92>
          freeproc(pp);
    800021fa:	8526                	mv	a0,s1
    800021fc:	857ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    80002200:	8526                	mv	a0,s1
    80002202:	a8bfe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    80002206:	0000e517          	auipc	a0,0xe
    8000220a:	84250513          	addi	a0,a0,-1982 # 8000fa48 <wait_lock>
    8000220e:	a7ffe0ef          	jal	80000c8c <release>
}
    80002212:	854e                	mv	a0,s3
    80002214:	60a6                	ld	ra,72(sp)
    80002216:	6406                	ld	s0,64(sp)
    80002218:	74e2                	ld	s1,56(sp)
    8000221a:	7942                	ld	s2,48(sp)
    8000221c:	79a2                	ld	s3,40(sp)
    8000221e:	7a02                	ld	s4,32(sp)
    80002220:	6ae2                	ld	s5,24(sp)
    80002222:	6b42                	ld	s6,16(sp)
    80002224:	6ba2                	ld	s7,8(sp)
    80002226:	6c02                	ld	s8,0(sp)
    80002228:	6161                	addi	sp,sp,80
    8000222a:	8082                	ret
            release(&pp->lock);
    8000222c:	8526                	mv	a0,s1
    8000222e:	a5ffe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002232:	0000e517          	auipc	a0,0xe
    80002236:	81650513          	addi	a0,a0,-2026 # 8000fa48 <wait_lock>
    8000223a:	a53fe0ef          	jal	80000c8c <release>
            return -1;
    8000223e:	59fd                	li	s3,-1
    80002240:	bfc9                	j	80002212 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002242:	17048493          	addi	s1,s1,368
    80002246:	03348063          	beq	s1,s3,80002266 <wait+0xcc>
      if(pp->parent == p){
    8000224a:	60bc                	ld	a5,64(s1)
    8000224c:	ff279be3          	bne	a5,s2,80002242 <wait+0xa8>
        acquire(&pp->lock);
    80002250:	8526                	mv	a0,s1
    80002252:	9a3fe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    80002256:	4c9c                	lw	a5,24(s1)
    80002258:	f94783e3          	beq	a5,s4,800021de <wait+0x44>
        release(&pp->lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	a2ffe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002262:	8756                	mv	a4,s5
    80002264:	bff9                	j	80002242 <wait+0xa8>
    if(!havekids || killed(p)){
    80002266:	cf19                	beqz	a4,80002284 <wait+0xea>
    80002268:	854a                	mv	a0,s2
    8000226a:	f07ff0ef          	jal	80002170 <killed>
    8000226e:	e919                	bnez	a0,80002284 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002270:	85e2                	mv	a1,s8
    80002272:	854a                	mv	a0,s2
    80002274:	cc5ff0ef          	jal	80001f38 <sleep>
    havekids = 0;
    80002278:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227a:	0000e497          	auipc	s1,0xe
    8000227e:	be648493          	addi	s1,s1,-1050 # 8000fe60 <proc>
    80002282:	b7e1                	j	8000224a <wait+0xb0>
      release(&wait_lock);
    80002284:	0000d517          	auipc	a0,0xd
    80002288:	7c450513          	addi	a0,a0,1988 # 8000fa48 <wait_lock>
    8000228c:	a01fe0ef          	jal	80000c8c <release>
      return -1;
    80002290:	59fd                	li	s3,-1
    80002292:	b741                	j	80002212 <wait+0x78>

0000000080002294 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002294:	7179                	addi	sp,sp,-48
    80002296:	f406                	sd	ra,40(sp)
    80002298:	f022                	sd	s0,32(sp)
    8000229a:	ec26                	sd	s1,24(sp)
    8000229c:	e84a                	sd	s2,16(sp)
    8000229e:	e44e                	sd	s3,8(sp)
    800022a0:	e052                	sd	s4,0(sp)
    800022a2:	1800                	addi	s0,sp,48
    800022a4:	84aa                	mv	s1,a0
    800022a6:	892e                	mv	s2,a1
    800022a8:	89b2                	mv	s3,a2
    800022aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ac:	e34ff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    800022b0:	cc99                	beqz	s1,800022ce <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022b2:	86d2                	mv	a3,s4
    800022b4:	864e                	mv	a2,s3
    800022b6:	85ca                	mv	a1,s2
    800022b8:	6d28                	ld	a0,88(a0)
    800022ba:	a98ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022be:	70a2                	ld	ra,40(sp)
    800022c0:	7402                	ld	s0,32(sp)
    800022c2:	64e2                	ld	s1,24(sp)
    800022c4:	6942                	ld	s2,16(sp)
    800022c6:	69a2                	ld	s3,8(sp)
    800022c8:	6a02                	ld	s4,0(sp)
    800022ca:	6145                	addi	sp,sp,48
    800022cc:	8082                	ret
    memmove((char *)dst, src, len);
    800022ce:	000a061b          	sext.w	a2,s4
    800022d2:	85ce                	mv	a1,s3
    800022d4:	854a                	mv	a0,s2
    800022d6:	a4ffe0ef          	jal	80000d24 <memmove>
    return 0;
    800022da:	8526                	mv	a0,s1
    800022dc:	b7cd                	j	800022be <either_copyout+0x2a>

00000000800022de <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022de:	7179                	addi	sp,sp,-48
    800022e0:	f406                	sd	ra,40(sp)
    800022e2:	f022                	sd	s0,32(sp)
    800022e4:	ec26                	sd	s1,24(sp)
    800022e6:	e84a                	sd	s2,16(sp)
    800022e8:	e44e                	sd	s3,8(sp)
    800022ea:	e052                	sd	s4,0(sp)
    800022ec:	1800                	addi	s0,sp,48
    800022ee:	892a                	mv	s2,a0
    800022f0:	84ae                	mv	s1,a1
    800022f2:	89b2                	mv	s3,a2
    800022f4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022f6:	deaff0ef          	jal	800018e0 <myproc>
  if(user_src){
    800022fa:	cc99                	beqz	s1,80002318 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022fc:	86d2                	mv	a3,s4
    800022fe:	864e                	mv	a2,s3
    80002300:	85ca                	mv	a1,s2
    80002302:	6d28                	ld	a0,88(a0)
    80002304:	b24ff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002308:	70a2                	ld	ra,40(sp)
    8000230a:	7402                	ld	s0,32(sp)
    8000230c:	64e2                	ld	s1,24(sp)
    8000230e:	6942                	ld	s2,16(sp)
    80002310:	69a2                	ld	s3,8(sp)
    80002312:	6a02                	ld	s4,0(sp)
    80002314:	6145                	addi	sp,sp,48
    80002316:	8082                	ret
    memmove(dst, (char*)src, len);
    80002318:	000a061b          	sext.w	a2,s4
    8000231c:	85ce                	mv	a1,s3
    8000231e:	854a                	mv	a0,s2
    80002320:	a05fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002324:	8526                	mv	a0,s1
    80002326:	b7cd                	j	80002308 <either_copyin+0x2a>

0000000080002328 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002328:	715d                	addi	sp,sp,-80
    8000232a:	e486                	sd	ra,72(sp)
    8000232c:	e0a2                	sd	s0,64(sp)
    8000232e:	fc26                	sd	s1,56(sp)
    80002330:	f84a                	sd	s2,48(sp)
    80002332:	f44e                	sd	s3,40(sp)
    80002334:	f052                	sd	s4,32(sp)
    80002336:	ec56                	sd	s5,24(sp)
    80002338:	e85a                	sd	s6,16(sp)
    8000233a:	e45e                	sd	s7,8(sp)
    8000233c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000233e:	00005517          	auipc	a0,0x5
    80002342:	d3a50513          	addi	a0,a0,-710 # 80007078 <etext+0x78>
    80002346:	97cfe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234a:	0000e497          	auipc	s1,0xe
    8000234e:	c7648493          	addi	s1,s1,-906 # 8000ffc0 <proc+0x160>
    80002352:	00014917          	auipc	s2,0x14
    80002356:	86e90913          	addi	s2,s2,-1938 # 80015bc0 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000235a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000235c:	00005997          	auipc	s3,0x5
    80002360:	f4498993          	addi	s3,s3,-188 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002364:	00005a97          	auipc	s5,0x5
    80002368:	f44a8a93          	addi	s5,s5,-188 # 800072a8 <etext+0x2a8>
    printf("\n");
    8000236c:	00005a17          	auipc	s4,0x5
    80002370:	d0ca0a13          	addi	s4,s4,-756 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002374:	00005b97          	auipc	s7,0x5
    80002378:	414b8b93          	addi	s7,s7,1044 # 80007788 <states.0>
    8000237c:	a829                	j	80002396 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000237e:	ed06a583          	lw	a1,-304(a3)
    80002382:	8556                	mv	a0,s5
    80002384:	93efe0ef          	jal	800004c2 <printf>
    printf("\n");
    80002388:	8552                	mv	a0,s4
    8000238a:	938fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000238e:	17048493          	addi	s1,s1,368
    80002392:	03248263          	beq	s1,s2,800023b6 <procdump+0x8e>
    if(p->state == UNUSED)
    80002396:	86a6                	mv	a3,s1
    80002398:	eb84a783          	lw	a5,-328(s1)
    8000239c:	dbed                	beqz	a5,8000238e <procdump+0x66>
      state = "???";
    8000239e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023a0:	fcfb6fe3          	bltu	s6,a5,8000237e <procdump+0x56>
    800023a4:	02079713          	slli	a4,a5,0x20
    800023a8:	01d75793          	srli	a5,a4,0x1d
    800023ac:	97de                	add	a5,a5,s7
    800023ae:	6390                	ld	a2,0(a5)
    800023b0:	f679                	bnez	a2,8000237e <procdump+0x56>
      state = "???";
    800023b2:	864e                	mv	a2,s3
    800023b4:	b7e9                	j	8000237e <procdump+0x56>
  }
}
    800023b6:	60a6                	ld	ra,72(sp)
    800023b8:	6406                	ld	s0,64(sp)
    800023ba:	74e2                	ld	s1,56(sp)
    800023bc:	7942                	ld	s2,48(sp)
    800023be:	79a2                	ld	s3,40(sp)
    800023c0:	7a02                	ld	s4,32(sp)
    800023c2:	6ae2                	ld	s5,24(sp)
    800023c4:	6b42                	ld	s6,16(sp)
    800023c6:	6ba2                	ld	s7,8(sp)
    800023c8:	6161                	addi	sp,sp,80
    800023ca:	8082                	ret

00000000800023cc <swtch>:
    800023cc:	00153023          	sd	ra,0(a0)
    800023d0:	00253423          	sd	sp,8(a0)
    800023d4:	e900                	sd	s0,16(a0)
    800023d6:	ed04                	sd	s1,24(a0)
    800023d8:	03253023          	sd	s2,32(a0)
    800023dc:	03353423          	sd	s3,40(a0)
    800023e0:	03453823          	sd	s4,48(a0)
    800023e4:	03553c23          	sd	s5,56(a0)
    800023e8:	05653023          	sd	s6,64(a0)
    800023ec:	05753423          	sd	s7,72(a0)
    800023f0:	05853823          	sd	s8,80(a0)
    800023f4:	05953c23          	sd	s9,88(a0)
    800023f8:	07a53023          	sd	s10,96(a0)
    800023fc:	07b53423          	sd	s11,104(a0)
    80002400:	0005b083          	ld	ra,0(a1)
    80002404:	0085b103          	ld	sp,8(a1)
    80002408:	6980                	ld	s0,16(a1)
    8000240a:	6d84                	ld	s1,24(a1)
    8000240c:	0205b903          	ld	s2,32(a1)
    80002410:	0285b983          	ld	s3,40(a1)
    80002414:	0305ba03          	ld	s4,48(a1)
    80002418:	0385ba83          	ld	s5,56(a1)
    8000241c:	0405bb03          	ld	s6,64(a1)
    80002420:	0485bb83          	ld	s7,72(a1)
    80002424:	0505bc03          	ld	s8,80(a1)
    80002428:	0585bc83          	ld	s9,88(a1)
    8000242c:	0605bd03          	ld	s10,96(a1)
    80002430:	0685bd83          	ld	s11,104(a1)
    80002434:	8082                	ret

0000000080002436 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002436:	1141                	addi	sp,sp,-16
    80002438:	e406                	sd	ra,8(sp)
    8000243a:	e022                	sd	s0,0(sp)
    8000243c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000243e:	00005597          	auipc	a1,0x5
    80002442:	eaa58593          	addi	a1,a1,-342 # 800072e8 <etext+0x2e8>
    80002446:	00013517          	auipc	a0,0x13
    8000244a:	61a50513          	addi	a0,a0,1562 # 80015a60 <tickslock>
    8000244e:	f26fe0ef          	jal	80000b74 <initlock>
}
    80002452:	60a2                	ld	ra,8(sp)
    80002454:	6402                	ld	s0,0(sp)
    80002456:	0141                	addi	sp,sp,16
    80002458:	8082                	ret

000000008000245a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000245a:	1141                	addi	sp,sp,-16
    8000245c:	e422                	sd	s0,8(sp)
    8000245e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002460:	00003797          	auipc	a5,0x3
    80002464:	e1078793          	addi	a5,a5,-496 # 80005270 <kernelvec>
    80002468:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000246c:	6422                	ld	s0,8(sp)
    8000246e:	0141                	addi	sp,sp,16
    80002470:	8082                	ret

0000000080002472 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002472:	1141                	addi	sp,sp,-16
    80002474:	e406                	sd	ra,8(sp)
    80002476:	e022                	sd	s0,0(sp)
    80002478:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000247a:	c66ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000247e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002482:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002484:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002488:	00004697          	auipc	a3,0x4
    8000248c:	b7868693          	addi	a3,a3,-1160 # 80006000 <_trampoline>
    80002490:	00004717          	auipc	a4,0x4
    80002494:	b7070713          	addi	a4,a4,-1168 # 80006000 <_trampoline>
    80002498:	8f15                	sub	a4,a4,a3
    8000249a:	040007b7          	lui	a5,0x4000
    8000249e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800024a0:	07b2                	slli	a5,a5,0xc
    800024a2:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024a4:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024a8:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024aa:	18002673          	csrr	a2,satp
    800024ae:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024b0:	7130                	ld	a2,96(a0)
    800024b2:	6538                	ld	a4,72(a0)
    800024b4:	6585                	lui	a1,0x1
    800024b6:	972e                	add	a4,a4,a1
    800024b8:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024ba:	7138                	ld	a4,96(a0)
    800024bc:	00000617          	auipc	a2,0x0
    800024c0:	11060613          	addi	a2,a2,272 # 800025cc <usertrap>
    800024c4:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024c6:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024c8:	8612                	mv	a2,tp
    800024ca:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024cc:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024d0:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024d4:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024d8:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024dc:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024de:	6f18                	ld	a4,24(a4)
    800024e0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800024e4:	6d28                	ld	a0,88(a0)
    800024e6:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800024e8:	00004717          	auipc	a4,0x4
    800024ec:	bb470713          	addi	a4,a4,-1100 # 8000609c <userret>
    800024f0:	8f15                	sub	a4,a4,a3
    800024f2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800024f4:	577d                	li	a4,-1
    800024f6:	177e                	slli	a4,a4,0x3f
    800024f8:	8d59                	or	a0,a0,a4
    800024fa:	9782                	jalr	a5
}
    800024fc:	60a2                	ld	ra,8(sp)
    800024fe:	6402                	ld	s0,0(sp)
    80002500:	0141                	addi	sp,sp,16
    80002502:	8082                	ret

0000000080002504 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002504:	1101                	addi	sp,sp,-32
    80002506:	ec06                	sd	ra,24(sp)
    80002508:	e822                	sd	s0,16(sp)
    8000250a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000250c:	ba8ff0ef          	jal	800018b4 <cpuid>
    80002510:	cd11                	beqz	a0,8000252c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002512:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002516:	000f4737          	lui	a4,0xf4
    8000251a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000251e:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    80002520:	14d79073          	csrw	stimecmp,a5
}
    80002524:	60e2                	ld	ra,24(sp)
    80002526:	6442                	ld	s0,16(sp)
    80002528:	6105                	addi	sp,sp,32
    8000252a:	8082                	ret
    8000252c:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000252e:	00013497          	auipc	s1,0x13
    80002532:	53248493          	addi	s1,s1,1330 # 80015a60 <tickslock>
    80002536:	8526                	mv	a0,s1
    80002538:	ebcfe0ef          	jal	80000bf4 <acquire>
    ticks++;
    8000253c:	00005517          	auipc	a0,0x5
    80002540:	3c450513          	addi	a0,a0,964 # 80007900 <ticks>
    80002544:	411c                	lw	a5,0(a0)
    80002546:	2785                	addiw	a5,a5,1
    80002548:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000254a:	a3bff0ef          	jal	80001f84 <wakeup>
    release(&tickslock);
    8000254e:	8526                	mv	a0,s1
    80002550:	f3cfe0ef          	jal	80000c8c <release>
    80002554:	64a2                	ld	s1,8(sp)
    80002556:	bf75                	j	80002512 <clockintr+0xe>

0000000080002558 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002558:	1101                	addi	sp,sp,-32
    8000255a:	ec06                	sd	ra,24(sp)
    8000255c:	e822                	sd	s0,16(sp)
    8000255e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002560:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002564:	57fd                	li	a5,-1
    80002566:	17fe                	slli	a5,a5,0x3f
    80002568:	07a5                	addi	a5,a5,9
    8000256a:	00f70c63          	beq	a4,a5,80002582 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000256e:	57fd                	li	a5,-1
    80002570:	17fe                	slli	a5,a5,0x3f
    80002572:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002574:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002576:	04f70763          	beq	a4,a5,800025c4 <devintr+0x6c>
  }
}
    8000257a:	60e2                	ld	ra,24(sp)
    8000257c:	6442                	ld	s0,16(sp)
    8000257e:	6105                	addi	sp,sp,32
    80002580:	8082                	ret
    80002582:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002584:	599020ef          	jal	8000531c <plic_claim>
    80002588:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000258a:	47a9                	li	a5,10
    8000258c:	00f50963          	beq	a0,a5,8000259e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002590:	4785                	li	a5,1
    80002592:	00f50963          	beq	a0,a5,800025a4 <devintr+0x4c>
    return 1;
    80002596:	4505                	li	a0,1
    } else if(irq){
    80002598:	e889                	bnez	s1,800025aa <devintr+0x52>
    8000259a:	64a2                	ld	s1,8(sp)
    8000259c:	bff9                	j	8000257a <devintr+0x22>
      uartintr();
    8000259e:	c68fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800025a2:	a819                	j	800025b8 <devintr+0x60>
      virtio_disk_intr();
    800025a4:	23e030ef          	jal	800057e2 <virtio_disk_intr>
    if(irq)
    800025a8:	a801                	j	800025b8 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800025aa:	85a6                	mv	a1,s1
    800025ac:	00005517          	auipc	a0,0x5
    800025b0:	d4450513          	addi	a0,a0,-700 # 800072f0 <etext+0x2f0>
    800025b4:	f0ffd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800025b8:	8526                	mv	a0,s1
    800025ba:	583020ef          	jal	8000533c <plic_complete>
    return 1;
    800025be:	4505                	li	a0,1
    800025c0:	64a2                	ld	s1,8(sp)
    800025c2:	bf65                	j	8000257a <devintr+0x22>
    clockintr();
    800025c4:	f41ff0ef          	jal	80002504 <clockintr>
    return 2;
    800025c8:	4509                	li	a0,2
    800025ca:	bf45                	j	8000257a <devintr+0x22>

00000000800025cc <usertrap>:
{
    800025cc:	1101                	addi	sp,sp,-32
    800025ce:	ec06                	sd	ra,24(sp)
    800025d0:	e822                	sd	s0,16(sp)
    800025d2:	e426                	sd	s1,8(sp)
    800025d4:	e04a                	sd	s2,0(sp)
    800025d6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025dc:	1007f793          	andi	a5,a5,256
    800025e0:	ef85                	bnez	a5,80002618 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025e2:	00003797          	auipc	a5,0x3
    800025e6:	c8e78793          	addi	a5,a5,-882 # 80005270 <kernelvec>
    800025ea:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025ee:	af2ff0ef          	jal	800018e0 <myproc>
    800025f2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025f4:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025f6:	14102773          	csrr	a4,sepc
    800025fa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025fc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002600:	47a1                	li	a5,8
    80002602:	02f70163          	beq	a4,a5,80002624 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002606:	f53ff0ef          	jal	80002558 <devintr>
    8000260a:	892a                	mv	s2,a0
    8000260c:	c135                	beqz	a0,80002670 <usertrap+0xa4>
  if(killed(p))
    8000260e:	8526                	mv	a0,s1
    80002610:	b61ff0ef          	jal	80002170 <killed>
    80002614:	cd1d                	beqz	a0,80002652 <usertrap+0x86>
    80002616:	a81d                	j	8000264c <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002618:	00005517          	auipc	a0,0x5
    8000261c:	cf850513          	addi	a0,a0,-776 # 80007310 <etext+0x310>
    80002620:	974fe0ef          	jal	80000794 <panic>
    if(killed(p))
    80002624:	b4dff0ef          	jal	80002170 <killed>
    80002628:	e121                	bnez	a0,80002668 <usertrap+0x9c>
    p->trapframe->epc += 4;
    8000262a:	70b8                	ld	a4,96(s1)
    8000262c:	6f1c                	ld	a5,24(a4)
    8000262e:	0791                	addi	a5,a5,4
    80002630:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002632:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002636:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000263a:	10079073          	csrw	sstatus,a5
    syscall();
    8000263e:	248000ef          	jal	80002886 <syscall>
  if(killed(p))
    80002642:	8526                	mv	a0,s1
    80002644:	b2dff0ef          	jal	80002170 <killed>
    80002648:	c901                	beqz	a0,80002658 <usertrap+0x8c>
    8000264a:	4901                	li	s2,0
    exit(-1);
    8000264c:	557d                	li	a0,-1
    8000264e:	9f7ff0ef          	jal	80002044 <exit>
  if(which_dev == 2)
    80002652:	4789                	li	a5,2
    80002654:	04f90563          	beq	s2,a5,8000269e <usertrap+0xd2>
  usertrapret();
    80002658:	e1bff0ef          	jal	80002472 <usertrapret>
}
    8000265c:	60e2                	ld	ra,24(sp)
    8000265e:	6442                	ld	s0,16(sp)
    80002660:	64a2                	ld	s1,8(sp)
    80002662:	6902                	ld	s2,0(sp)
    80002664:	6105                	addi	sp,sp,32
    80002666:	8082                	ret
      exit(-1);
    80002668:	557d                	li	a0,-1
    8000266a:	9dbff0ef          	jal	80002044 <exit>
    8000266e:	bf75                	j	8000262a <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002670:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002674:	5890                	lw	a2,48(s1)
    80002676:	00005517          	auipc	a0,0x5
    8000267a:	cba50513          	addi	a0,a0,-838 # 80007330 <etext+0x330>
    8000267e:	e45fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002682:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002686:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000268a:	00005517          	auipc	a0,0x5
    8000268e:	cd650513          	addi	a0,a0,-810 # 80007360 <etext+0x360>
    80002692:	e31fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    80002696:	8526                	mv	a0,s1
    80002698:	ab5ff0ef          	jal	8000214c <setkilled>
    8000269c:	b75d                	j	80002642 <usertrap+0x76>
    yield();
    8000269e:	86fff0ef          	jal	80001f0c <yield>
    800026a2:	bf5d                	j	80002658 <usertrap+0x8c>

00000000800026a4 <kerneltrap>:
{
    800026a4:	7179                	addi	sp,sp,-48
    800026a6:	f406                	sd	ra,40(sp)
    800026a8:	f022                	sd	s0,32(sp)
    800026aa:	ec26                	sd	s1,24(sp)
    800026ac:	e84a                	sd	s2,16(sp)
    800026ae:	e44e                	sd	s3,8(sp)
    800026b0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026b2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ba:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026be:	1004f793          	andi	a5,s1,256
    800026c2:	c795                	beqz	a5,800026ee <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026c8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026ca:	eb85                	bnez	a5,800026fa <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026cc:	e8dff0ef          	jal	80002558 <devintr>
    800026d0:	c91d                	beqz	a0,80002706 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026d2:	4789                	li	a5,2
    800026d4:	04f50a63          	beq	a0,a5,80002728 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026d8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026dc:	10049073          	csrw	sstatus,s1
}
    800026e0:	70a2                	ld	ra,40(sp)
    800026e2:	7402                	ld	s0,32(sp)
    800026e4:	64e2                	ld	s1,24(sp)
    800026e6:	6942                	ld	s2,16(sp)
    800026e8:	69a2                	ld	s3,8(sp)
    800026ea:	6145                	addi	sp,sp,48
    800026ec:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026ee:	00005517          	auipc	a0,0x5
    800026f2:	c9a50513          	addi	a0,a0,-870 # 80007388 <etext+0x388>
    800026f6:	89efe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    800026fa:	00005517          	auipc	a0,0x5
    800026fe:	cb650513          	addi	a0,a0,-842 # 800073b0 <etext+0x3b0>
    80002702:	892fe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002706:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000270a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000270e:	85ce                	mv	a1,s3
    80002710:	00005517          	auipc	a0,0x5
    80002714:	cc050513          	addi	a0,a0,-832 # 800073d0 <etext+0x3d0>
    80002718:	dabfd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    8000271c:	00005517          	auipc	a0,0x5
    80002720:	cdc50513          	addi	a0,a0,-804 # 800073f8 <etext+0x3f8>
    80002724:	870fe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002728:	9b8ff0ef          	jal	800018e0 <myproc>
    8000272c:	d555                	beqz	a0,800026d8 <kerneltrap+0x34>
    yield();
    8000272e:	fdeff0ef          	jal	80001f0c <yield>
    80002732:	b75d                	j	800026d8 <kerneltrap+0x34>

0000000080002734 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002734:	1101                	addi	sp,sp,-32
    80002736:	ec06                	sd	ra,24(sp)
    80002738:	e822                	sd	s0,16(sp)
    8000273a:	e426                	sd	s1,8(sp)
    8000273c:	1000                	addi	s0,sp,32
    8000273e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002740:	9a0ff0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002744:	4795                	li	a5,5
    80002746:	0497e163          	bltu	a5,s1,80002788 <argraw+0x54>
    8000274a:	048a                	slli	s1,s1,0x2
    8000274c:	00005717          	auipc	a4,0x5
    80002750:	06c70713          	addi	a4,a4,108 # 800077b8 <states.0+0x30>
    80002754:	94ba                	add	s1,s1,a4
    80002756:	409c                	lw	a5,0(s1)
    80002758:	97ba                	add	a5,a5,a4
    8000275a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000275c:	713c                	ld	a5,96(a0)
    8000275e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002760:	60e2                	ld	ra,24(sp)
    80002762:	6442                	ld	s0,16(sp)
    80002764:	64a2                	ld	s1,8(sp)
    80002766:	6105                	addi	sp,sp,32
    80002768:	8082                	ret
    return p->trapframe->a1;
    8000276a:	713c                	ld	a5,96(a0)
    8000276c:	7fa8                	ld	a0,120(a5)
    8000276e:	bfcd                	j	80002760 <argraw+0x2c>
    return p->trapframe->a2;
    80002770:	713c                	ld	a5,96(a0)
    80002772:	63c8                	ld	a0,128(a5)
    80002774:	b7f5                	j	80002760 <argraw+0x2c>
    return p->trapframe->a3;
    80002776:	713c                	ld	a5,96(a0)
    80002778:	67c8                	ld	a0,136(a5)
    8000277a:	b7dd                	j	80002760 <argraw+0x2c>
    return p->trapframe->a4;
    8000277c:	713c                	ld	a5,96(a0)
    8000277e:	6bc8                	ld	a0,144(a5)
    80002780:	b7c5                	j	80002760 <argraw+0x2c>
    return p->trapframe->a5;
    80002782:	713c                	ld	a5,96(a0)
    80002784:	6fc8                	ld	a0,152(a5)
    80002786:	bfe9                	j	80002760 <argraw+0x2c>
  panic("argraw");
    80002788:	00005517          	auipc	a0,0x5
    8000278c:	c8050513          	addi	a0,a0,-896 # 80007408 <etext+0x408>
    80002790:	804fe0ef          	jal	80000794 <panic>

0000000080002794 <fetchaddr>:
{
    80002794:	1101                	addi	sp,sp,-32
    80002796:	ec06                	sd	ra,24(sp)
    80002798:	e822                	sd	s0,16(sp)
    8000279a:	e426                	sd	s1,8(sp)
    8000279c:	e04a                	sd	s2,0(sp)
    8000279e:	1000                	addi	s0,sp,32
    800027a0:	84aa                	mv	s1,a0
    800027a2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800027a4:	93cff0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800027a8:	693c                	ld	a5,80(a0)
    800027aa:	02f4f663          	bgeu	s1,a5,800027d6 <fetchaddr+0x42>
    800027ae:	00848713          	addi	a4,s1,8
    800027b2:	02e7e463          	bltu	a5,a4,800027da <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027b6:	46a1                	li	a3,8
    800027b8:	8626                	mv	a2,s1
    800027ba:	85ca                	mv	a1,s2
    800027bc:	6d28                	ld	a0,88(a0)
    800027be:	e6bfe0ef          	jal	80001628 <copyin>
    800027c2:	00a03533          	snez	a0,a0
    800027c6:	40a00533          	neg	a0,a0
}
    800027ca:	60e2                	ld	ra,24(sp)
    800027cc:	6442                	ld	s0,16(sp)
    800027ce:	64a2                	ld	s1,8(sp)
    800027d0:	6902                	ld	s2,0(sp)
    800027d2:	6105                	addi	sp,sp,32
    800027d4:	8082                	ret
    return -1;
    800027d6:	557d                	li	a0,-1
    800027d8:	bfcd                	j	800027ca <fetchaddr+0x36>
    800027da:	557d                	li	a0,-1
    800027dc:	b7fd                	j	800027ca <fetchaddr+0x36>

00000000800027de <fetchstr>:
{
    800027de:	7179                	addi	sp,sp,-48
    800027e0:	f406                	sd	ra,40(sp)
    800027e2:	f022                	sd	s0,32(sp)
    800027e4:	ec26                	sd	s1,24(sp)
    800027e6:	e84a                	sd	s2,16(sp)
    800027e8:	e44e                	sd	s3,8(sp)
    800027ea:	1800                	addi	s0,sp,48
    800027ec:	892a                	mv	s2,a0
    800027ee:	84ae                	mv	s1,a1
    800027f0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027f2:	8eeff0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027f6:	86ce                	mv	a3,s3
    800027f8:	864a                	mv	a2,s2
    800027fa:	85a6                	mv	a1,s1
    800027fc:	6d28                	ld	a0,88(a0)
    800027fe:	eb1fe0ef          	jal	800016ae <copyinstr>
    80002802:	00054c63          	bltz	a0,8000281a <fetchstr+0x3c>
  return strlen(buf);
    80002806:	8526                	mv	a0,s1
    80002808:	e30fe0ef          	jal	80000e38 <strlen>
}
    8000280c:	70a2                	ld	ra,40(sp)
    8000280e:	7402                	ld	s0,32(sp)
    80002810:	64e2                	ld	s1,24(sp)
    80002812:	6942                	ld	s2,16(sp)
    80002814:	69a2                	ld	s3,8(sp)
    80002816:	6145                	addi	sp,sp,48
    80002818:	8082                	ret
    return -1;
    8000281a:	557d                	li	a0,-1
    8000281c:	bfc5                	j	8000280c <fetchstr+0x2e>

000000008000281e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000281e:	1101                	addi	sp,sp,-32
    80002820:	ec06                	sd	ra,24(sp)
    80002822:	e822                	sd	s0,16(sp)
    80002824:	e426                	sd	s1,8(sp)
    80002826:	1000                	addi	s0,sp,32
    80002828:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000282a:	f0bff0ef          	jal	80002734 <argraw>
    8000282e:	c088                	sw	a0,0(s1)
}
    80002830:	60e2                	ld	ra,24(sp)
    80002832:	6442                	ld	s0,16(sp)
    80002834:	64a2                	ld	s1,8(sp)
    80002836:	6105                	addi	sp,sp,32
    80002838:	8082                	ret

000000008000283a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000283a:	1101                	addi	sp,sp,-32
    8000283c:	ec06                	sd	ra,24(sp)
    8000283e:	e822                	sd	s0,16(sp)
    80002840:	e426                	sd	s1,8(sp)
    80002842:	1000                	addi	s0,sp,32
    80002844:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002846:	eefff0ef          	jal	80002734 <argraw>
    8000284a:	e088                	sd	a0,0(s1)
}
    8000284c:	60e2                	ld	ra,24(sp)
    8000284e:	6442                	ld	s0,16(sp)
    80002850:	64a2                	ld	s1,8(sp)
    80002852:	6105                	addi	sp,sp,32
    80002854:	8082                	ret

0000000080002856 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002856:	7179                	addi	sp,sp,-48
    80002858:	f406                	sd	ra,40(sp)
    8000285a:	f022                	sd	s0,32(sp)
    8000285c:	ec26                	sd	s1,24(sp)
    8000285e:	e84a                	sd	s2,16(sp)
    80002860:	1800                	addi	s0,sp,48
    80002862:	84ae                	mv	s1,a1
    80002864:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002866:	fd840593          	addi	a1,s0,-40
    8000286a:	fd1ff0ef          	jal	8000283a <argaddr>
  return fetchstr(addr, buf, max);
    8000286e:	864a                	mv	a2,s2
    80002870:	85a6                	mv	a1,s1
    80002872:	fd843503          	ld	a0,-40(s0)
    80002876:	f69ff0ef          	jal	800027de <fetchstr>
}
    8000287a:	70a2                	ld	ra,40(sp)
    8000287c:	7402                	ld	s0,32(sp)
    8000287e:	64e2                	ld	s1,24(sp)
    80002880:	6942                	ld	s2,16(sp)
    80002882:	6145                	addi	sp,sp,48
    80002884:	8082                	ret

0000000080002886 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002886:	1101                	addi	sp,sp,-32
    80002888:	ec06                	sd	ra,24(sp)
    8000288a:	e822                	sd	s0,16(sp)
    8000288c:	e426                	sd	s1,8(sp)
    8000288e:	e04a                	sd	s2,0(sp)
    80002890:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002892:	84eff0ef          	jal	800018e0 <myproc>
    80002896:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002898:	06053903          	ld	s2,96(a0)
    8000289c:	0a893783          	ld	a5,168(s2)
    800028a0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800028a4:	37fd                	addiw	a5,a5,-1
    800028a6:	4751                	li	a4,20
    800028a8:	00f76f63          	bltu	a4,a5,800028c6 <syscall+0x40>
    800028ac:	00369713          	slli	a4,a3,0x3
    800028b0:	00005797          	auipc	a5,0x5
    800028b4:	f2078793          	addi	a5,a5,-224 # 800077d0 <syscalls>
    800028b8:	97ba                	add	a5,a5,a4
    800028ba:	639c                	ld	a5,0(a5)
    800028bc:	c789                	beqz	a5,800028c6 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028be:	9782                	jalr	a5
    800028c0:	06a93823          	sd	a0,112(s2)
    800028c4:	a829                	j	800028de <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028c6:	16048613          	addi	a2,s1,352
    800028ca:	588c                	lw	a1,48(s1)
    800028cc:	00005517          	auipc	a0,0x5
    800028d0:	b4450513          	addi	a0,a0,-1212 # 80007410 <etext+0x410>
    800028d4:	beffd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028d8:	70bc                	ld	a5,96(s1)
    800028da:	577d                	li	a4,-1
    800028dc:	fbb8                	sd	a4,112(a5)
  }
}
    800028de:	60e2                	ld	ra,24(sp)
    800028e0:	6442                	ld	s0,16(sp)
    800028e2:	64a2                	ld	s1,8(sp)
    800028e4:	6902                	ld	s2,0(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret

00000000800028ea <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800028ea:	1101                	addi	sp,sp,-32
    800028ec:	ec06                	sd	ra,24(sp)
    800028ee:	e822                	sd	s0,16(sp)
    800028f0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028f2:	fec40593          	addi	a1,s0,-20
    800028f6:	4501                	li	a0,0
    800028f8:	f27ff0ef          	jal	8000281e <argint>
  exit(n);
    800028fc:	fec42503          	lw	a0,-20(s0)
    80002900:	f44ff0ef          	jal	80002044 <exit>
  return 0;  // not reached
}
    80002904:	4501                	li	a0,0
    80002906:	60e2                	ld	ra,24(sp)
    80002908:	6442                	ld	s0,16(sp)
    8000290a:	6105                	addi	sp,sp,32
    8000290c:	8082                	ret

000000008000290e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000290e:	1141                	addi	sp,sp,-16
    80002910:	e406                	sd	ra,8(sp)
    80002912:	e022                	sd	s0,0(sp)
    80002914:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002916:	fcbfe0ef          	jal	800018e0 <myproc>
}
    8000291a:	5908                	lw	a0,48(a0)
    8000291c:	60a2                	ld	ra,8(sp)
    8000291e:	6402                	ld	s0,0(sp)
    80002920:	0141                	addi	sp,sp,16
    80002922:	8082                	ret

0000000080002924 <sys_fork>:

uint64
sys_fork(void)
{
    80002924:	1141                	addi	sp,sp,-16
    80002926:	e406                	sd	ra,8(sp)
    80002928:	e022                	sd	s0,0(sp)
    8000292a:	0800                	addi	s0,sp,16
  return fork();
    8000292c:	ae0ff0ef          	jal	80001c0c <fork>
}
    80002930:	60a2                	ld	ra,8(sp)
    80002932:	6402                	ld	s0,0(sp)
    80002934:	0141                	addi	sp,sp,16
    80002936:	8082                	ret

0000000080002938 <sys_wait>:

uint64
sys_wait(void)
{
    80002938:	1101                	addi	sp,sp,-32
    8000293a:	ec06                	sd	ra,24(sp)
    8000293c:	e822                	sd	s0,16(sp)
    8000293e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002940:	fe840593          	addi	a1,s0,-24
    80002944:	4501                	li	a0,0
    80002946:	ef5ff0ef          	jal	8000283a <argaddr>
  return wait(p);
    8000294a:	fe843503          	ld	a0,-24(s0)
    8000294e:	84dff0ef          	jal	8000219a <wait>
}
    80002952:	60e2                	ld	ra,24(sp)
    80002954:	6442                	ld	s0,16(sp)
    80002956:	6105                	addi	sp,sp,32
    80002958:	8082                	ret

000000008000295a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000295a:	7179                	addi	sp,sp,-48
    8000295c:	f406                	sd	ra,40(sp)
    8000295e:	f022                	sd	s0,32(sp)
    80002960:	ec26                	sd	s1,24(sp)
    80002962:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002964:	fdc40593          	addi	a1,s0,-36
    80002968:	4501                	li	a0,0
    8000296a:	eb5ff0ef          	jal	8000281e <argint>
  addr = myproc()->sz;
    8000296e:	f73fe0ef          	jal	800018e0 <myproc>
    80002972:	6924                	ld	s1,80(a0)
  if(growproc(n) < 0)
    80002974:	fdc42503          	lw	a0,-36(s0)
    80002978:	a44ff0ef          	jal	80001bbc <growproc>
    8000297c:	00054863          	bltz	a0,8000298c <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002980:	8526                	mv	a0,s1
    80002982:	70a2                	ld	ra,40(sp)
    80002984:	7402                	ld	s0,32(sp)
    80002986:	64e2                	ld	s1,24(sp)
    80002988:	6145                	addi	sp,sp,48
    8000298a:	8082                	ret
    return -1;
    8000298c:	54fd                	li	s1,-1
    8000298e:	bfcd                	j	80002980 <sys_sbrk+0x26>

0000000080002990 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002990:	7139                	addi	sp,sp,-64
    80002992:	fc06                	sd	ra,56(sp)
    80002994:	f822                	sd	s0,48(sp)
    80002996:	f04a                	sd	s2,32(sp)
    80002998:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000299a:	fcc40593          	addi	a1,s0,-52
    8000299e:	4501                	li	a0,0
    800029a0:	e7fff0ef          	jal	8000281e <argint>
  if(n < 0)
    800029a4:	fcc42783          	lw	a5,-52(s0)
    800029a8:	0607c763          	bltz	a5,80002a16 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800029ac:	00013517          	auipc	a0,0x13
    800029b0:	0b450513          	addi	a0,a0,180 # 80015a60 <tickslock>
    800029b4:	a40fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    800029b8:	00005917          	auipc	s2,0x5
    800029bc:	f4892903          	lw	s2,-184(s2) # 80007900 <ticks>
  while(ticks - ticks0 < n){
    800029c0:	fcc42783          	lw	a5,-52(s0)
    800029c4:	cf8d                	beqz	a5,800029fe <sys_sleep+0x6e>
    800029c6:	f426                	sd	s1,40(sp)
    800029c8:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029ca:	00013997          	auipc	s3,0x13
    800029ce:	09698993          	addi	s3,s3,150 # 80015a60 <tickslock>
    800029d2:	00005497          	auipc	s1,0x5
    800029d6:	f2e48493          	addi	s1,s1,-210 # 80007900 <ticks>
    if(killed(myproc())){
    800029da:	f07fe0ef          	jal	800018e0 <myproc>
    800029de:	f92ff0ef          	jal	80002170 <killed>
    800029e2:	ed0d                	bnez	a0,80002a1c <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800029e4:	85ce                	mv	a1,s3
    800029e6:	8526                	mv	a0,s1
    800029e8:	d50ff0ef          	jal	80001f38 <sleep>
  while(ticks - ticks0 < n){
    800029ec:	409c                	lw	a5,0(s1)
    800029ee:	412787bb          	subw	a5,a5,s2
    800029f2:	fcc42703          	lw	a4,-52(s0)
    800029f6:	fee7e2e3          	bltu	a5,a4,800029da <sys_sleep+0x4a>
    800029fa:	74a2                	ld	s1,40(sp)
    800029fc:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029fe:	00013517          	auipc	a0,0x13
    80002a02:	06250513          	addi	a0,a0,98 # 80015a60 <tickslock>
    80002a06:	a86fe0ef          	jal	80000c8c <release>
  return 0;
    80002a0a:	4501                	li	a0,0
}
    80002a0c:	70e2                	ld	ra,56(sp)
    80002a0e:	7442                	ld	s0,48(sp)
    80002a10:	7902                	ld	s2,32(sp)
    80002a12:	6121                	addi	sp,sp,64
    80002a14:	8082                	ret
    n = 0;
    80002a16:	fc042623          	sw	zero,-52(s0)
    80002a1a:	bf49                	j	800029ac <sys_sleep+0x1c>
      release(&tickslock);
    80002a1c:	00013517          	auipc	a0,0x13
    80002a20:	04450513          	addi	a0,a0,68 # 80015a60 <tickslock>
    80002a24:	a68fe0ef          	jal	80000c8c <release>
      return -1;
    80002a28:	557d                	li	a0,-1
    80002a2a:	74a2                	ld	s1,40(sp)
    80002a2c:	69e2                	ld	s3,24(sp)
    80002a2e:	bff9                	j	80002a0c <sys_sleep+0x7c>

0000000080002a30 <sys_kill>:

uint64
sys_kill(void)
{
    80002a30:	1101                	addi	sp,sp,-32
    80002a32:	ec06                	sd	ra,24(sp)
    80002a34:	e822                	sd	s0,16(sp)
    80002a36:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a38:	fec40593          	addi	a1,s0,-20
    80002a3c:	4501                	li	a0,0
    80002a3e:	de1ff0ef          	jal	8000281e <argint>
  return kill(pid);
    80002a42:	fec42503          	lw	a0,-20(s0)
    80002a46:	ea0ff0ef          	jal	800020e6 <kill>
}
    80002a4a:	60e2                	ld	ra,24(sp)
    80002a4c:	6442                	ld	s0,16(sp)
    80002a4e:	6105                	addi	sp,sp,32
    80002a50:	8082                	ret

0000000080002a52 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a52:	1101                	addi	sp,sp,-32
    80002a54:	ec06                	sd	ra,24(sp)
    80002a56:	e822                	sd	s0,16(sp)
    80002a58:	e426                	sd	s1,8(sp)
    80002a5a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a5c:	00013517          	auipc	a0,0x13
    80002a60:	00450513          	addi	a0,a0,4 # 80015a60 <tickslock>
    80002a64:	990fe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002a68:	00005497          	auipc	s1,0x5
    80002a6c:	e984a483          	lw	s1,-360(s1) # 80007900 <ticks>
  release(&tickslock);
    80002a70:	00013517          	auipc	a0,0x13
    80002a74:	ff050513          	addi	a0,a0,-16 # 80015a60 <tickslock>
    80002a78:	a14fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002a7c:	02049513          	slli	a0,s1,0x20
    80002a80:	9101                	srli	a0,a0,0x20
    80002a82:	60e2                	ld	ra,24(sp)
    80002a84:	6442                	ld	s0,16(sp)
    80002a86:	64a2                	ld	s1,8(sp)
    80002a88:	6105                	addi	sp,sp,32
    80002a8a:	8082                	ret

0000000080002a8c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a8c:	7179                	addi	sp,sp,-48
    80002a8e:	f406                	sd	ra,40(sp)
    80002a90:	f022                	sd	s0,32(sp)
    80002a92:	ec26                	sd	s1,24(sp)
    80002a94:	e84a                	sd	s2,16(sp)
    80002a96:	e44e                	sd	s3,8(sp)
    80002a98:	e052                	sd	s4,0(sp)
    80002a9a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a9c:	00005597          	auipc	a1,0x5
    80002aa0:	99458593          	addi	a1,a1,-1644 # 80007430 <etext+0x430>
    80002aa4:	00013517          	auipc	a0,0x13
    80002aa8:	fd450513          	addi	a0,a0,-44 # 80015a78 <bcache>
    80002aac:	8c8fe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ab0:	0001b797          	auipc	a5,0x1b
    80002ab4:	fc878793          	addi	a5,a5,-56 # 8001da78 <bcache+0x8000>
    80002ab8:	0001b717          	auipc	a4,0x1b
    80002abc:	22870713          	addi	a4,a4,552 # 8001dce0 <bcache+0x8268>
    80002ac0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ac4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ac8:	00013497          	auipc	s1,0x13
    80002acc:	fc848493          	addi	s1,s1,-56 # 80015a90 <bcache+0x18>
    b->next = bcache.head.next;
    80002ad0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ad2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ad4:	00005a17          	auipc	s4,0x5
    80002ad8:	964a0a13          	addi	s4,s4,-1692 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002adc:	2b893783          	ld	a5,696(s2)
    80002ae0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002ae2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002ae6:	85d2                	mv	a1,s4
    80002ae8:	01048513          	addi	a0,s1,16
    80002aec:	248010ef          	jal	80003d34 <initsleeplock>
    bcache.head.next->prev = b;
    80002af0:	2b893783          	ld	a5,696(s2)
    80002af4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002af6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002afa:	45848493          	addi	s1,s1,1112
    80002afe:	fd349fe3          	bne	s1,s3,80002adc <binit+0x50>
  }
}
    80002b02:	70a2                	ld	ra,40(sp)
    80002b04:	7402                	ld	s0,32(sp)
    80002b06:	64e2                	ld	s1,24(sp)
    80002b08:	6942                	ld	s2,16(sp)
    80002b0a:	69a2                	ld	s3,8(sp)
    80002b0c:	6a02                	ld	s4,0(sp)
    80002b0e:	6145                	addi	sp,sp,48
    80002b10:	8082                	ret

0000000080002b12 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b12:	7179                	addi	sp,sp,-48
    80002b14:	f406                	sd	ra,40(sp)
    80002b16:	f022                	sd	s0,32(sp)
    80002b18:	ec26                	sd	s1,24(sp)
    80002b1a:	e84a                	sd	s2,16(sp)
    80002b1c:	e44e                	sd	s3,8(sp)
    80002b1e:	1800                	addi	s0,sp,48
    80002b20:	892a                	mv	s2,a0
    80002b22:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b24:	00013517          	auipc	a0,0x13
    80002b28:	f5450513          	addi	a0,a0,-172 # 80015a78 <bcache>
    80002b2c:	8c8fe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b30:	0001b497          	auipc	s1,0x1b
    80002b34:	2004b483          	ld	s1,512(s1) # 8001dd30 <bcache+0x82b8>
    80002b38:	0001b797          	auipc	a5,0x1b
    80002b3c:	1a878793          	addi	a5,a5,424 # 8001dce0 <bcache+0x8268>
    80002b40:	02f48b63          	beq	s1,a5,80002b76 <bread+0x64>
    80002b44:	873e                	mv	a4,a5
    80002b46:	a021                	j	80002b4e <bread+0x3c>
    80002b48:	68a4                	ld	s1,80(s1)
    80002b4a:	02e48663          	beq	s1,a4,80002b76 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b4e:	449c                	lw	a5,8(s1)
    80002b50:	ff279ce3          	bne	a5,s2,80002b48 <bread+0x36>
    80002b54:	44dc                	lw	a5,12(s1)
    80002b56:	ff3799e3          	bne	a5,s3,80002b48 <bread+0x36>
      b->refcnt++;
    80002b5a:	40bc                	lw	a5,64(s1)
    80002b5c:	2785                	addiw	a5,a5,1
    80002b5e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b60:	00013517          	auipc	a0,0x13
    80002b64:	f1850513          	addi	a0,a0,-232 # 80015a78 <bcache>
    80002b68:	924fe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b6c:	01048513          	addi	a0,s1,16
    80002b70:	1fa010ef          	jal	80003d6a <acquiresleep>
      return b;
    80002b74:	a889                	j	80002bc6 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b76:	0001b497          	auipc	s1,0x1b
    80002b7a:	1b24b483          	ld	s1,434(s1) # 8001dd28 <bcache+0x82b0>
    80002b7e:	0001b797          	auipc	a5,0x1b
    80002b82:	16278793          	addi	a5,a5,354 # 8001dce0 <bcache+0x8268>
    80002b86:	00f48863          	beq	s1,a5,80002b96 <bread+0x84>
    80002b8a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b8c:	40bc                	lw	a5,64(s1)
    80002b8e:	cb91                	beqz	a5,80002ba2 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b90:	64a4                	ld	s1,72(s1)
    80002b92:	fee49de3          	bne	s1,a4,80002b8c <bread+0x7a>
  panic("bget: no buffers");
    80002b96:	00005517          	auipc	a0,0x5
    80002b9a:	8aa50513          	addi	a0,a0,-1878 # 80007440 <etext+0x440>
    80002b9e:	bf7fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002ba2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ba6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002baa:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bae:	4785                	li	a5,1
    80002bb0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bb2:	00013517          	auipc	a0,0x13
    80002bb6:	ec650513          	addi	a0,a0,-314 # 80015a78 <bcache>
    80002bba:	8d2fe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002bbe:	01048513          	addi	a0,s1,16
    80002bc2:	1a8010ef          	jal	80003d6a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002bc6:	409c                	lw	a5,0(s1)
    80002bc8:	cb89                	beqz	a5,80002bda <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002bca:	8526                	mv	a0,s1
    80002bcc:	70a2                	ld	ra,40(sp)
    80002bce:	7402                	ld	s0,32(sp)
    80002bd0:	64e2                	ld	s1,24(sp)
    80002bd2:	6942                	ld	s2,16(sp)
    80002bd4:	69a2                	ld	s3,8(sp)
    80002bd6:	6145                	addi	sp,sp,48
    80002bd8:	8082                	ret
    virtio_disk_rw(b, 0);
    80002bda:	4581                	li	a1,0
    80002bdc:	8526                	mv	a0,s1
    80002bde:	1f3020ef          	jal	800055d0 <virtio_disk_rw>
    b->valid = 1;
    80002be2:	4785                	li	a5,1
    80002be4:	c09c                	sw	a5,0(s1)
  return b;
    80002be6:	b7d5                	j	80002bca <bread+0xb8>

0000000080002be8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002be8:	1101                	addi	sp,sp,-32
    80002bea:	ec06                	sd	ra,24(sp)
    80002bec:	e822                	sd	s0,16(sp)
    80002bee:	e426                	sd	s1,8(sp)
    80002bf0:	1000                	addi	s0,sp,32
    80002bf2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002bf4:	0541                	addi	a0,a0,16
    80002bf6:	1f2010ef          	jal	80003de8 <holdingsleep>
    80002bfa:	c911                	beqz	a0,80002c0e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002bfc:	4585                	li	a1,1
    80002bfe:	8526                	mv	a0,s1
    80002c00:	1d1020ef          	jal	800055d0 <virtio_disk_rw>
}
    80002c04:	60e2                	ld	ra,24(sp)
    80002c06:	6442                	ld	s0,16(sp)
    80002c08:	64a2                	ld	s1,8(sp)
    80002c0a:	6105                	addi	sp,sp,32
    80002c0c:	8082                	ret
    panic("bwrite");
    80002c0e:	00005517          	auipc	a0,0x5
    80002c12:	84a50513          	addi	a0,a0,-1974 # 80007458 <etext+0x458>
    80002c16:	b7ffd0ef          	jal	80000794 <panic>

0000000080002c1a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c1a:	1101                	addi	sp,sp,-32
    80002c1c:	ec06                	sd	ra,24(sp)
    80002c1e:	e822                	sd	s0,16(sp)
    80002c20:	e426                	sd	s1,8(sp)
    80002c22:	e04a                	sd	s2,0(sp)
    80002c24:	1000                	addi	s0,sp,32
    80002c26:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c28:	01050913          	addi	s2,a0,16
    80002c2c:	854a                	mv	a0,s2
    80002c2e:	1ba010ef          	jal	80003de8 <holdingsleep>
    80002c32:	c135                	beqz	a0,80002c96 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c34:	854a                	mv	a0,s2
    80002c36:	17a010ef          	jal	80003db0 <releasesleep>

  acquire(&bcache.lock);
    80002c3a:	00013517          	auipc	a0,0x13
    80002c3e:	e3e50513          	addi	a0,a0,-450 # 80015a78 <bcache>
    80002c42:	fb3fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002c46:	40bc                	lw	a5,64(s1)
    80002c48:	37fd                	addiw	a5,a5,-1
    80002c4a:	0007871b          	sext.w	a4,a5
    80002c4e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c50:	e71d                	bnez	a4,80002c7e <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c52:	68b8                	ld	a4,80(s1)
    80002c54:	64bc                	ld	a5,72(s1)
    80002c56:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c58:	68b8                	ld	a4,80(s1)
    80002c5a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c5c:	0001b797          	auipc	a5,0x1b
    80002c60:	e1c78793          	addi	a5,a5,-484 # 8001da78 <bcache+0x8000>
    80002c64:	2b87b703          	ld	a4,696(a5)
    80002c68:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c6a:	0001b717          	auipc	a4,0x1b
    80002c6e:	07670713          	addi	a4,a4,118 # 8001dce0 <bcache+0x8268>
    80002c72:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c74:	2b87b703          	ld	a4,696(a5)
    80002c78:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c7a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c7e:	00013517          	auipc	a0,0x13
    80002c82:	dfa50513          	addi	a0,a0,-518 # 80015a78 <bcache>
    80002c86:	806fe0ef          	jal	80000c8c <release>
}
    80002c8a:	60e2                	ld	ra,24(sp)
    80002c8c:	6442                	ld	s0,16(sp)
    80002c8e:	64a2                	ld	s1,8(sp)
    80002c90:	6902                	ld	s2,0(sp)
    80002c92:	6105                	addi	sp,sp,32
    80002c94:	8082                	ret
    panic("brelse");
    80002c96:	00004517          	auipc	a0,0x4
    80002c9a:	7ca50513          	addi	a0,a0,1994 # 80007460 <etext+0x460>
    80002c9e:	af7fd0ef          	jal	80000794 <panic>

0000000080002ca2 <bpin>:

void
bpin(struct buf *b) {
    80002ca2:	1101                	addi	sp,sp,-32
    80002ca4:	ec06                	sd	ra,24(sp)
    80002ca6:	e822                	sd	s0,16(sp)
    80002ca8:	e426                	sd	s1,8(sp)
    80002caa:	1000                	addi	s0,sp,32
    80002cac:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cae:	00013517          	auipc	a0,0x13
    80002cb2:	dca50513          	addi	a0,a0,-566 # 80015a78 <bcache>
    80002cb6:	f3ffd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002cba:	40bc                	lw	a5,64(s1)
    80002cbc:	2785                	addiw	a5,a5,1
    80002cbe:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cc0:	00013517          	auipc	a0,0x13
    80002cc4:	db850513          	addi	a0,a0,-584 # 80015a78 <bcache>
    80002cc8:	fc5fd0ef          	jal	80000c8c <release>
}
    80002ccc:	60e2                	ld	ra,24(sp)
    80002cce:	6442                	ld	s0,16(sp)
    80002cd0:	64a2                	ld	s1,8(sp)
    80002cd2:	6105                	addi	sp,sp,32
    80002cd4:	8082                	ret

0000000080002cd6 <bunpin>:

void
bunpin(struct buf *b) {
    80002cd6:	1101                	addi	sp,sp,-32
    80002cd8:	ec06                	sd	ra,24(sp)
    80002cda:	e822                	sd	s0,16(sp)
    80002cdc:	e426                	sd	s1,8(sp)
    80002cde:	1000                	addi	s0,sp,32
    80002ce0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ce2:	00013517          	auipc	a0,0x13
    80002ce6:	d9650513          	addi	a0,a0,-618 # 80015a78 <bcache>
    80002cea:	f0bfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002cee:	40bc                	lw	a5,64(s1)
    80002cf0:	37fd                	addiw	a5,a5,-1
    80002cf2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cf4:	00013517          	auipc	a0,0x13
    80002cf8:	d8450513          	addi	a0,a0,-636 # 80015a78 <bcache>
    80002cfc:	f91fd0ef          	jal	80000c8c <release>
}
    80002d00:	60e2                	ld	ra,24(sp)
    80002d02:	6442                	ld	s0,16(sp)
    80002d04:	64a2                	ld	s1,8(sp)
    80002d06:	6105                	addi	sp,sp,32
    80002d08:	8082                	ret

0000000080002d0a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d0a:	1101                	addi	sp,sp,-32
    80002d0c:	ec06                	sd	ra,24(sp)
    80002d0e:	e822                	sd	s0,16(sp)
    80002d10:	e426                	sd	s1,8(sp)
    80002d12:	e04a                	sd	s2,0(sp)
    80002d14:	1000                	addi	s0,sp,32
    80002d16:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d18:	00d5d59b          	srliw	a1,a1,0xd
    80002d1c:	0001b797          	auipc	a5,0x1b
    80002d20:	4387a783          	lw	a5,1080(a5) # 8001e154 <sb+0x1c>
    80002d24:	9dbd                	addw	a1,a1,a5
    80002d26:	dedff0ef          	jal	80002b12 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d2a:	0074f713          	andi	a4,s1,7
    80002d2e:	4785                	li	a5,1
    80002d30:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002d34:	14ce                	slli	s1,s1,0x33
    80002d36:	90d9                	srli	s1,s1,0x36
    80002d38:	00950733          	add	a4,a0,s1
    80002d3c:	05874703          	lbu	a4,88(a4)
    80002d40:	00e7f6b3          	and	a3,a5,a4
    80002d44:	c29d                	beqz	a3,80002d6a <bfree+0x60>
    80002d46:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d48:	94aa                	add	s1,s1,a0
    80002d4a:	fff7c793          	not	a5,a5
    80002d4e:	8f7d                	and	a4,a4,a5
    80002d50:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d54:	711000ef          	jal	80003c64 <log_write>
  brelse(bp);
    80002d58:	854a                	mv	a0,s2
    80002d5a:	ec1ff0ef          	jal	80002c1a <brelse>
}
    80002d5e:	60e2                	ld	ra,24(sp)
    80002d60:	6442                	ld	s0,16(sp)
    80002d62:	64a2                	ld	s1,8(sp)
    80002d64:	6902                	ld	s2,0(sp)
    80002d66:	6105                	addi	sp,sp,32
    80002d68:	8082                	ret
    panic("freeing free block");
    80002d6a:	00004517          	auipc	a0,0x4
    80002d6e:	6fe50513          	addi	a0,a0,1790 # 80007468 <etext+0x468>
    80002d72:	a23fd0ef          	jal	80000794 <panic>

0000000080002d76 <balloc>:
{
    80002d76:	711d                	addi	sp,sp,-96
    80002d78:	ec86                	sd	ra,88(sp)
    80002d7a:	e8a2                	sd	s0,80(sp)
    80002d7c:	e4a6                	sd	s1,72(sp)
    80002d7e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002d80:	0001b797          	auipc	a5,0x1b
    80002d84:	3bc7a783          	lw	a5,956(a5) # 8001e13c <sb+0x4>
    80002d88:	0e078f63          	beqz	a5,80002e86 <balloc+0x110>
    80002d8c:	e0ca                	sd	s2,64(sp)
    80002d8e:	fc4e                	sd	s3,56(sp)
    80002d90:	f852                	sd	s4,48(sp)
    80002d92:	f456                	sd	s5,40(sp)
    80002d94:	f05a                	sd	s6,32(sp)
    80002d96:	ec5e                	sd	s7,24(sp)
    80002d98:	e862                	sd	s8,16(sp)
    80002d9a:	e466                	sd	s9,8(sp)
    80002d9c:	8baa                	mv	s7,a0
    80002d9e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002da0:	0001bb17          	auipc	s6,0x1b
    80002da4:	398b0b13          	addi	s6,s6,920 # 8001e138 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002da8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002daa:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002dac:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002dae:	6c89                	lui	s9,0x2
    80002db0:	a0b5                	j	80002e1c <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002db2:	97ca                	add	a5,a5,s2
    80002db4:	8e55                	or	a2,a2,a3
    80002db6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002dba:	854a                	mv	a0,s2
    80002dbc:	6a9000ef          	jal	80003c64 <log_write>
        brelse(bp);
    80002dc0:	854a                	mv	a0,s2
    80002dc2:	e59ff0ef          	jal	80002c1a <brelse>
  bp = bread(dev, bno);
    80002dc6:	85a6                	mv	a1,s1
    80002dc8:	855e                	mv	a0,s7
    80002dca:	d49ff0ef          	jal	80002b12 <bread>
    80002dce:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002dd0:	40000613          	li	a2,1024
    80002dd4:	4581                	li	a1,0
    80002dd6:	05850513          	addi	a0,a0,88
    80002dda:	eeffd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002dde:	854a                	mv	a0,s2
    80002de0:	685000ef          	jal	80003c64 <log_write>
  brelse(bp);
    80002de4:	854a                	mv	a0,s2
    80002de6:	e35ff0ef          	jal	80002c1a <brelse>
}
    80002dea:	6906                	ld	s2,64(sp)
    80002dec:	79e2                	ld	s3,56(sp)
    80002dee:	7a42                	ld	s4,48(sp)
    80002df0:	7aa2                	ld	s5,40(sp)
    80002df2:	7b02                	ld	s6,32(sp)
    80002df4:	6be2                	ld	s7,24(sp)
    80002df6:	6c42                	ld	s8,16(sp)
    80002df8:	6ca2                	ld	s9,8(sp)
}
    80002dfa:	8526                	mv	a0,s1
    80002dfc:	60e6                	ld	ra,88(sp)
    80002dfe:	6446                	ld	s0,80(sp)
    80002e00:	64a6                	ld	s1,72(sp)
    80002e02:	6125                	addi	sp,sp,96
    80002e04:	8082                	ret
    brelse(bp);
    80002e06:	854a                	mv	a0,s2
    80002e08:	e13ff0ef          	jal	80002c1a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e0c:	015c87bb          	addw	a5,s9,s5
    80002e10:	00078a9b          	sext.w	s5,a5
    80002e14:	004b2703          	lw	a4,4(s6)
    80002e18:	04eaff63          	bgeu	s5,a4,80002e76 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e1c:	41fad79b          	sraiw	a5,s5,0x1f
    80002e20:	0137d79b          	srliw	a5,a5,0x13
    80002e24:	015787bb          	addw	a5,a5,s5
    80002e28:	40d7d79b          	sraiw	a5,a5,0xd
    80002e2c:	01cb2583          	lw	a1,28(s6)
    80002e30:	9dbd                	addw	a1,a1,a5
    80002e32:	855e                	mv	a0,s7
    80002e34:	cdfff0ef          	jal	80002b12 <bread>
    80002e38:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e3a:	004b2503          	lw	a0,4(s6)
    80002e3e:	000a849b          	sext.w	s1,s5
    80002e42:	8762                	mv	a4,s8
    80002e44:	fca4f1e3          	bgeu	s1,a0,80002e06 <balloc+0x90>
      m = 1 << (bi % 8);
    80002e48:	00777693          	andi	a3,a4,7
    80002e4c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e50:	41f7579b          	sraiw	a5,a4,0x1f
    80002e54:	01d7d79b          	srliw	a5,a5,0x1d
    80002e58:	9fb9                	addw	a5,a5,a4
    80002e5a:	4037d79b          	sraiw	a5,a5,0x3
    80002e5e:	00f90633          	add	a2,s2,a5
    80002e62:	05864603          	lbu	a2,88(a2)
    80002e66:	00c6f5b3          	and	a1,a3,a2
    80002e6a:	d5a1                	beqz	a1,80002db2 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e6c:	2705                	addiw	a4,a4,1
    80002e6e:	2485                	addiw	s1,s1,1
    80002e70:	fd471ae3          	bne	a4,s4,80002e44 <balloc+0xce>
    80002e74:	bf49                	j	80002e06 <balloc+0x90>
    80002e76:	6906                	ld	s2,64(sp)
    80002e78:	79e2                	ld	s3,56(sp)
    80002e7a:	7a42                	ld	s4,48(sp)
    80002e7c:	7aa2                	ld	s5,40(sp)
    80002e7e:	7b02                	ld	s6,32(sp)
    80002e80:	6be2                	ld	s7,24(sp)
    80002e82:	6c42                	ld	s8,16(sp)
    80002e84:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002e86:	00004517          	auipc	a0,0x4
    80002e8a:	5fa50513          	addi	a0,a0,1530 # 80007480 <etext+0x480>
    80002e8e:	e34fd0ef          	jal	800004c2 <printf>
  return 0;
    80002e92:	4481                	li	s1,0
    80002e94:	b79d                	j	80002dfa <balloc+0x84>

0000000080002e96 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e96:	7179                	addi	sp,sp,-48
    80002e98:	f406                	sd	ra,40(sp)
    80002e9a:	f022                	sd	s0,32(sp)
    80002e9c:	ec26                	sd	s1,24(sp)
    80002e9e:	e84a                	sd	s2,16(sp)
    80002ea0:	e44e                	sd	s3,8(sp)
    80002ea2:	1800                	addi	s0,sp,48
    80002ea4:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002ea6:	47ad                	li	a5,11
    80002ea8:	02b7e663          	bltu	a5,a1,80002ed4 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002eac:	02059793          	slli	a5,a1,0x20
    80002eb0:	01e7d593          	srli	a1,a5,0x1e
    80002eb4:	00b504b3          	add	s1,a0,a1
    80002eb8:	0504a903          	lw	s2,80(s1)
    80002ebc:	06091a63          	bnez	s2,80002f30 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002ec0:	4108                	lw	a0,0(a0)
    80002ec2:	eb5ff0ef          	jal	80002d76 <balloc>
    80002ec6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002eca:	06090363          	beqz	s2,80002f30 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002ece:	0524a823          	sw	s2,80(s1)
    80002ed2:	a8b9                	j	80002f30 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002ed4:	ff45849b          	addiw	s1,a1,-12
    80002ed8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002edc:	0ff00793          	li	a5,255
    80002ee0:	06e7ee63          	bltu	a5,a4,80002f5c <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002ee4:	08052903          	lw	s2,128(a0)
    80002ee8:	00091d63          	bnez	s2,80002f02 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002eec:	4108                	lw	a0,0(a0)
    80002eee:	e89ff0ef          	jal	80002d76 <balloc>
    80002ef2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002ef6:	02090d63          	beqz	s2,80002f30 <bmap+0x9a>
    80002efa:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002efc:	0929a023          	sw	s2,128(s3)
    80002f00:	a011                	j	80002f04 <bmap+0x6e>
    80002f02:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f04:	85ca                	mv	a1,s2
    80002f06:	0009a503          	lw	a0,0(s3)
    80002f0a:	c09ff0ef          	jal	80002b12 <bread>
    80002f0e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f10:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f14:	02049713          	slli	a4,s1,0x20
    80002f18:	01e75593          	srli	a1,a4,0x1e
    80002f1c:	00b784b3          	add	s1,a5,a1
    80002f20:	0004a903          	lw	s2,0(s1)
    80002f24:	00090e63          	beqz	s2,80002f40 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f28:	8552                	mv	a0,s4
    80002f2a:	cf1ff0ef          	jal	80002c1a <brelse>
    return addr;
    80002f2e:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f30:	854a                	mv	a0,s2
    80002f32:	70a2                	ld	ra,40(sp)
    80002f34:	7402                	ld	s0,32(sp)
    80002f36:	64e2                	ld	s1,24(sp)
    80002f38:	6942                	ld	s2,16(sp)
    80002f3a:	69a2                	ld	s3,8(sp)
    80002f3c:	6145                	addi	sp,sp,48
    80002f3e:	8082                	ret
      addr = balloc(ip->dev);
    80002f40:	0009a503          	lw	a0,0(s3)
    80002f44:	e33ff0ef          	jal	80002d76 <balloc>
    80002f48:	0005091b          	sext.w	s2,a0
      if(addr){
    80002f4c:	fc090ee3          	beqz	s2,80002f28 <bmap+0x92>
        a[bn] = addr;
    80002f50:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f54:	8552                	mv	a0,s4
    80002f56:	50f000ef          	jal	80003c64 <log_write>
    80002f5a:	b7f9                	j	80002f28 <bmap+0x92>
    80002f5c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f5e:	00004517          	auipc	a0,0x4
    80002f62:	53a50513          	addi	a0,a0,1338 # 80007498 <etext+0x498>
    80002f66:	82ffd0ef          	jal	80000794 <panic>

0000000080002f6a <iget>:
{
    80002f6a:	7179                	addi	sp,sp,-48
    80002f6c:	f406                	sd	ra,40(sp)
    80002f6e:	f022                	sd	s0,32(sp)
    80002f70:	ec26                	sd	s1,24(sp)
    80002f72:	e84a                	sd	s2,16(sp)
    80002f74:	e44e                	sd	s3,8(sp)
    80002f76:	e052                	sd	s4,0(sp)
    80002f78:	1800                	addi	s0,sp,48
    80002f7a:	89aa                	mv	s3,a0
    80002f7c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f7e:	0001b517          	auipc	a0,0x1b
    80002f82:	1da50513          	addi	a0,a0,474 # 8001e158 <itable>
    80002f86:	c6ffd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80002f8a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f8c:	0001b497          	auipc	s1,0x1b
    80002f90:	1e448493          	addi	s1,s1,484 # 8001e170 <itable+0x18>
    80002f94:	0001d697          	auipc	a3,0x1d
    80002f98:	c6c68693          	addi	a3,a3,-916 # 8001fc00 <log>
    80002f9c:	a039                	j	80002faa <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f9e:	02090963          	beqz	s2,80002fd0 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fa2:	08848493          	addi	s1,s1,136
    80002fa6:	02d48863          	beq	s1,a3,80002fd6 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002faa:	449c                	lw	a5,8(s1)
    80002fac:	fef059e3          	blez	a5,80002f9e <iget+0x34>
    80002fb0:	4098                	lw	a4,0(s1)
    80002fb2:	ff3716e3          	bne	a4,s3,80002f9e <iget+0x34>
    80002fb6:	40d8                	lw	a4,4(s1)
    80002fb8:	ff4713e3          	bne	a4,s4,80002f9e <iget+0x34>
      ip->ref++;
    80002fbc:	2785                	addiw	a5,a5,1
    80002fbe:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002fc0:	0001b517          	auipc	a0,0x1b
    80002fc4:	19850513          	addi	a0,a0,408 # 8001e158 <itable>
    80002fc8:	cc5fd0ef          	jal	80000c8c <release>
      return ip;
    80002fcc:	8926                	mv	s2,s1
    80002fce:	a02d                	j	80002ff8 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fd0:	fbe9                	bnez	a5,80002fa2 <iget+0x38>
      empty = ip;
    80002fd2:	8926                	mv	s2,s1
    80002fd4:	b7f9                	j	80002fa2 <iget+0x38>
  if(empty == 0)
    80002fd6:	02090a63          	beqz	s2,8000300a <iget+0xa0>
  ip->dev = dev;
    80002fda:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002fde:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fe2:	4785                	li	a5,1
    80002fe4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fe8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002fec:	0001b517          	auipc	a0,0x1b
    80002ff0:	16c50513          	addi	a0,a0,364 # 8001e158 <itable>
    80002ff4:	c99fd0ef          	jal	80000c8c <release>
}
    80002ff8:	854a                	mv	a0,s2
    80002ffa:	70a2                	ld	ra,40(sp)
    80002ffc:	7402                	ld	s0,32(sp)
    80002ffe:	64e2                	ld	s1,24(sp)
    80003000:	6942                	ld	s2,16(sp)
    80003002:	69a2                	ld	s3,8(sp)
    80003004:	6a02                	ld	s4,0(sp)
    80003006:	6145                	addi	sp,sp,48
    80003008:	8082                	ret
    panic("iget: no inodes");
    8000300a:	00004517          	auipc	a0,0x4
    8000300e:	4a650513          	addi	a0,a0,1190 # 800074b0 <etext+0x4b0>
    80003012:	f82fd0ef          	jal	80000794 <panic>

0000000080003016 <fsinit>:
fsinit(int dev) {
    80003016:	7179                	addi	sp,sp,-48
    80003018:	f406                	sd	ra,40(sp)
    8000301a:	f022                	sd	s0,32(sp)
    8000301c:	ec26                	sd	s1,24(sp)
    8000301e:	e84a                	sd	s2,16(sp)
    80003020:	e44e                	sd	s3,8(sp)
    80003022:	1800                	addi	s0,sp,48
    80003024:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003026:	4585                	li	a1,1
    80003028:	aebff0ef          	jal	80002b12 <bread>
    8000302c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000302e:	0001b997          	auipc	s3,0x1b
    80003032:	10a98993          	addi	s3,s3,266 # 8001e138 <sb>
    80003036:	02000613          	li	a2,32
    8000303a:	05850593          	addi	a1,a0,88
    8000303e:	854e                	mv	a0,s3
    80003040:	ce5fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003044:	8526                	mv	a0,s1
    80003046:	bd5ff0ef          	jal	80002c1a <brelse>
  if(sb.magic != FSMAGIC)
    8000304a:	0009a703          	lw	a4,0(s3)
    8000304e:	102037b7          	lui	a5,0x10203
    80003052:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003056:	02f71063          	bne	a4,a5,80003076 <fsinit+0x60>
  initlog(dev, &sb);
    8000305a:	0001b597          	auipc	a1,0x1b
    8000305e:	0de58593          	addi	a1,a1,222 # 8001e138 <sb>
    80003062:	854a                	mv	a0,s2
    80003064:	1f9000ef          	jal	80003a5c <initlog>
}
    80003068:	70a2                	ld	ra,40(sp)
    8000306a:	7402                	ld	s0,32(sp)
    8000306c:	64e2                	ld	s1,24(sp)
    8000306e:	6942                	ld	s2,16(sp)
    80003070:	69a2                	ld	s3,8(sp)
    80003072:	6145                	addi	sp,sp,48
    80003074:	8082                	ret
    panic("invalid file system");
    80003076:	00004517          	auipc	a0,0x4
    8000307a:	44a50513          	addi	a0,a0,1098 # 800074c0 <etext+0x4c0>
    8000307e:	f16fd0ef          	jal	80000794 <panic>

0000000080003082 <iinit>:
{
    80003082:	7179                	addi	sp,sp,-48
    80003084:	f406                	sd	ra,40(sp)
    80003086:	f022                	sd	s0,32(sp)
    80003088:	ec26                	sd	s1,24(sp)
    8000308a:	e84a                	sd	s2,16(sp)
    8000308c:	e44e                	sd	s3,8(sp)
    8000308e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003090:	00004597          	auipc	a1,0x4
    80003094:	44858593          	addi	a1,a1,1096 # 800074d8 <etext+0x4d8>
    80003098:	0001b517          	auipc	a0,0x1b
    8000309c:	0c050513          	addi	a0,a0,192 # 8001e158 <itable>
    800030a0:	ad5fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800030a4:	0001b497          	auipc	s1,0x1b
    800030a8:	0dc48493          	addi	s1,s1,220 # 8001e180 <itable+0x28>
    800030ac:	0001d997          	auipc	s3,0x1d
    800030b0:	b6498993          	addi	s3,s3,-1180 # 8001fc10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030b4:	00004917          	auipc	s2,0x4
    800030b8:	42c90913          	addi	s2,s2,1068 # 800074e0 <etext+0x4e0>
    800030bc:	85ca                	mv	a1,s2
    800030be:	8526                	mv	a0,s1
    800030c0:	475000ef          	jal	80003d34 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800030c4:	08848493          	addi	s1,s1,136
    800030c8:	ff349ae3          	bne	s1,s3,800030bc <iinit+0x3a>
}
    800030cc:	70a2                	ld	ra,40(sp)
    800030ce:	7402                	ld	s0,32(sp)
    800030d0:	64e2                	ld	s1,24(sp)
    800030d2:	6942                	ld	s2,16(sp)
    800030d4:	69a2                	ld	s3,8(sp)
    800030d6:	6145                	addi	sp,sp,48
    800030d8:	8082                	ret

00000000800030da <ialloc>:
{
    800030da:	7139                	addi	sp,sp,-64
    800030dc:	fc06                	sd	ra,56(sp)
    800030de:	f822                	sd	s0,48(sp)
    800030e0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030e2:	0001b717          	auipc	a4,0x1b
    800030e6:	06272703          	lw	a4,98(a4) # 8001e144 <sb+0xc>
    800030ea:	4785                	li	a5,1
    800030ec:	06e7f063          	bgeu	a5,a4,8000314c <ialloc+0x72>
    800030f0:	f426                	sd	s1,40(sp)
    800030f2:	f04a                	sd	s2,32(sp)
    800030f4:	ec4e                	sd	s3,24(sp)
    800030f6:	e852                	sd	s4,16(sp)
    800030f8:	e456                	sd	s5,8(sp)
    800030fa:	e05a                	sd	s6,0(sp)
    800030fc:	8aaa                	mv	s5,a0
    800030fe:	8b2e                	mv	s6,a1
    80003100:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003102:	0001ba17          	auipc	s4,0x1b
    80003106:	036a0a13          	addi	s4,s4,54 # 8001e138 <sb>
    8000310a:	00495593          	srli	a1,s2,0x4
    8000310e:	018a2783          	lw	a5,24(s4)
    80003112:	9dbd                	addw	a1,a1,a5
    80003114:	8556                	mv	a0,s5
    80003116:	9fdff0ef          	jal	80002b12 <bread>
    8000311a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000311c:	05850993          	addi	s3,a0,88
    80003120:	00f97793          	andi	a5,s2,15
    80003124:	079a                	slli	a5,a5,0x6
    80003126:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003128:	00099783          	lh	a5,0(s3)
    8000312c:	cb9d                	beqz	a5,80003162 <ialloc+0x88>
    brelse(bp);
    8000312e:	aedff0ef          	jal	80002c1a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003132:	0905                	addi	s2,s2,1
    80003134:	00ca2703          	lw	a4,12(s4)
    80003138:	0009079b          	sext.w	a5,s2
    8000313c:	fce7e7e3          	bltu	a5,a4,8000310a <ialloc+0x30>
    80003140:	74a2                	ld	s1,40(sp)
    80003142:	7902                	ld	s2,32(sp)
    80003144:	69e2                	ld	s3,24(sp)
    80003146:	6a42                	ld	s4,16(sp)
    80003148:	6aa2                	ld	s5,8(sp)
    8000314a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000314c:	00004517          	auipc	a0,0x4
    80003150:	39c50513          	addi	a0,a0,924 # 800074e8 <etext+0x4e8>
    80003154:	b6efd0ef          	jal	800004c2 <printf>
  return 0;
    80003158:	4501                	li	a0,0
}
    8000315a:	70e2                	ld	ra,56(sp)
    8000315c:	7442                	ld	s0,48(sp)
    8000315e:	6121                	addi	sp,sp,64
    80003160:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003162:	04000613          	li	a2,64
    80003166:	4581                	li	a1,0
    80003168:	854e                	mv	a0,s3
    8000316a:	b5ffd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    8000316e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003172:	8526                	mv	a0,s1
    80003174:	2f1000ef          	jal	80003c64 <log_write>
      brelse(bp);
    80003178:	8526                	mv	a0,s1
    8000317a:	aa1ff0ef          	jal	80002c1a <brelse>
      return iget(dev, inum);
    8000317e:	0009059b          	sext.w	a1,s2
    80003182:	8556                	mv	a0,s5
    80003184:	de7ff0ef          	jal	80002f6a <iget>
    80003188:	74a2                	ld	s1,40(sp)
    8000318a:	7902                	ld	s2,32(sp)
    8000318c:	69e2                	ld	s3,24(sp)
    8000318e:	6a42                	ld	s4,16(sp)
    80003190:	6aa2                	ld	s5,8(sp)
    80003192:	6b02                	ld	s6,0(sp)
    80003194:	b7d9                	j	8000315a <ialloc+0x80>

0000000080003196 <iupdate>:
{
    80003196:	1101                	addi	sp,sp,-32
    80003198:	ec06                	sd	ra,24(sp)
    8000319a:	e822                	sd	s0,16(sp)
    8000319c:	e426                	sd	s1,8(sp)
    8000319e:	e04a                	sd	s2,0(sp)
    800031a0:	1000                	addi	s0,sp,32
    800031a2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031a4:	415c                	lw	a5,4(a0)
    800031a6:	0047d79b          	srliw	a5,a5,0x4
    800031aa:	0001b597          	auipc	a1,0x1b
    800031ae:	fa65a583          	lw	a1,-90(a1) # 8001e150 <sb+0x18>
    800031b2:	9dbd                	addw	a1,a1,a5
    800031b4:	4108                	lw	a0,0(a0)
    800031b6:	95dff0ef          	jal	80002b12 <bread>
    800031ba:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800031bc:	05850793          	addi	a5,a0,88
    800031c0:	40d8                	lw	a4,4(s1)
    800031c2:	8b3d                	andi	a4,a4,15
    800031c4:	071a                	slli	a4,a4,0x6
    800031c6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800031c8:	04449703          	lh	a4,68(s1)
    800031cc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800031d0:	04649703          	lh	a4,70(s1)
    800031d4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031d8:	04849703          	lh	a4,72(s1)
    800031dc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031e0:	04a49703          	lh	a4,74(s1)
    800031e4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031e8:	44f8                	lw	a4,76(s1)
    800031ea:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031ec:	03400613          	li	a2,52
    800031f0:	05048593          	addi	a1,s1,80
    800031f4:	00c78513          	addi	a0,a5,12
    800031f8:	b2dfd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    800031fc:	854a                	mv	a0,s2
    800031fe:	267000ef          	jal	80003c64 <log_write>
  brelse(bp);
    80003202:	854a                	mv	a0,s2
    80003204:	a17ff0ef          	jal	80002c1a <brelse>
}
    80003208:	60e2                	ld	ra,24(sp)
    8000320a:	6442                	ld	s0,16(sp)
    8000320c:	64a2                	ld	s1,8(sp)
    8000320e:	6902                	ld	s2,0(sp)
    80003210:	6105                	addi	sp,sp,32
    80003212:	8082                	ret

0000000080003214 <idup>:
{
    80003214:	1101                	addi	sp,sp,-32
    80003216:	ec06                	sd	ra,24(sp)
    80003218:	e822                	sd	s0,16(sp)
    8000321a:	e426                	sd	s1,8(sp)
    8000321c:	1000                	addi	s0,sp,32
    8000321e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003220:	0001b517          	auipc	a0,0x1b
    80003224:	f3850513          	addi	a0,a0,-200 # 8001e158 <itable>
    80003228:	9cdfd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    8000322c:	449c                	lw	a5,8(s1)
    8000322e:	2785                	addiw	a5,a5,1
    80003230:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003232:	0001b517          	auipc	a0,0x1b
    80003236:	f2650513          	addi	a0,a0,-218 # 8001e158 <itable>
    8000323a:	a53fd0ef          	jal	80000c8c <release>
}
    8000323e:	8526                	mv	a0,s1
    80003240:	60e2                	ld	ra,24(sp)
    80003242:	6442                	ld	s0,16(sp)
    80003244:	64a2                	ld	s1,8(sp)
    80003246:	6105                	addi	sp,sp,32
    80003248:	8082                	ret

000000008000324a <ilock>:
{
    8000324a:	1101                	addi	sp,sp,-32
    8000324c:	ec06                	sd	ra,24(sp)
    8000324e:	e822                	sd	s0,16(sp)
    80003250:	e426                	sd	s1,8(sp)
    80003252:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003254:	cd19                	beqz	a0,80003272 <ilock+0x28>
    80003256:	84aa                	mv	s1,a0
    80003258:	451c                	lw	a5,8(a0)
    8000325a:	00f05c63          	blez	a5,80003272 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000325e:	0541                	addi	a0,a0,16
    80003260:	30b000ef          	jal	80003d6a <acquiresleep>
  if(ip->valid == 0){
    80003264:	40bc                	lw	a5,64(s1)
    80003266:	cf89                	beqz	a5,80003280 <ilock+0x36>
}
    80003268:	60e2                	ld	ra,24(sp)
    8000326a:	6442                	ld	s0,16(sp)
    8000326c:	64a2                	ld	s1,8(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret
    80003272:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003274:	00004517          	auipc	a0,0x4
    80003278:	28c50513          	addi	a0,a0,652 # 80007500 <etext+0x500>
    8000327c:	d18fd0ef          	jal	80000794 <panic>
    80003280:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003282:	40dc                	lw	a5,4(s1)
    80003284:	0047d79b          	srliw	a5,a5,0x4
    80003288:	0001b597          	auipc	a1,0x1b
    8000328c:	ec85a583          	lw	a1,-312(a1) # 8001e150 <sb+0x18>
    80003290:	9dbd                	addw	a1,a1,a5
    80003292:	4088                	lw	a0,0(s1)
    80003294:	87fff0ef          	jal	80002b12 <bread>
    80003298:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000329a:	05850593          	addi	a1,a0,88
    8000329e:	40dc                	lw	a5,4(s1)
    800032a0:	8bbd                	andi	a5,a5,15
    800032a2:	079a                	slli	a5,a5,0x6
    800032a4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032a6:	00059783          	lh	a5,0(a1)
    800032aa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032ae:	00259783          	lh	a5,2(a1)
    800032b2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032b6:	00459783          	lh	a5,4(a1)
    800032ba:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800032be:	00659783          	lh	a5,6(a1)
    800032c2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800032c6:	459c                	lw	a5,8(a1)
    800032c8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800032ca:	03400613          	li	a2,52
    800032ce:	05b1                	addi	a1,a1,12
    800032d0:	05048513          	addi	a0,s1,80
    800032d4:	a51fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    800032d8:	854a                	mv	a0,s2
    800032da:	941ff0ef          	jal	80002c1a <brelse>
    ip->valid = 1;
    800032de:	4785                	li	a5,1
    800032e0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032e2:	04449783          	lh	a5,68(s1)
    800032e6:	c399                	beqz	a5,800032ec <ilock+0xa2>
    800032e8:	6902                	ld	s2,0(sp)
    800032ea:	bfbd                	j	80003268 <ilock+0x1e>
      panic("ilock: no type");
    800032ec:	00004517          	auipc	a0,0x4
    800032f0:	21c50513          	addi	a0,a0,540 # 80007508 <etext+0x508>
    800032f4:	ca0fd0ef          	jal	80000794 <panic>

00000000800032f8 <iunlock>:
{
    800032f8:	1101                	addi	sp,sp,-32
    800032fa:	ec06                	sd	ra,24(sp)
    800032fc:	e822                	sd	s0,16(sp)
    800032fe:	e426                	sd	s1,8(sp)
    80003300:	e04a                	sd	s2,0(sp)
    80003302:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003304:	c505                	beqz	a0,8000332c <iunlock+0x34>
    80003306:	84aa                	mv	s1,a0
    80003308:	01050913          	addi	s2,a0,16
    8000330c:	854a                	mv	a0,s2
    8000330e:	2db000ef          	jal	80003de8 <holdingsleep>
    80003312:	cd09                	beqz	a0,8000332c <iunlock+0x34>
    80003314:	449c                	lw	a5,8(s1)
    80003316:	00f05b63          	blez	a5,8000332c <iunlock+0x34>
  releasesleep(&ip->lock);
    8000331a:	854a                	mv	a0,s2
    8000331c:	295000ef          	jal	80003db0 <releasesleep>
}
    80003320:	60e2                	ld	ra,24(sp)
    80003322:	6442                	ld	s0,16(sp)
    80003324:	64a2                	ld	s1,8(sp)
    80003326:	6902                	ld	s2,0(sp)
    80003328:	6105                	addi	sp,sp,32
    8000332a:	8082                	ret
    panic("iunlock");
    8000332c:	00004517          	auipc	a0,0x4
    80003330:	1ec50513          	addi	a0,a0,492 # 80007518 <etext+0x518>
    80003334:	c60fd0ef          	jal	80000794 <panic>

0000000080003338 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003338:	7179                	addi	sp,sp,-48
    8000333a:	f406                	sd	ra,40(sp)
    8000333c:	f022                	sd	s0,32(sp)
    8000333e:	ec26                	sd	s1,24(sp)
    80003340:	e84a                	sd	s2,16(sp)
    80003342:	e44e                	sd	s3,8(sp)
    80003344:	1800                	addi	s0,sp,48
    80003346:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003348:	05050493          	addi	s1,a0,80
    8000334c:	08050913          	addi	s2,a0,128
    80003350:	a021                	j	80003358 <itrunc+0x20>
    80003352:	0491                	addi	s1,s1,4
    80003354:	01248b63          	beq	s1,s2,8000336a <itrunc+0x32>
    if(ip->addrs[i]){
    80003358:	408c                	lw	a1,0(s1)
    8000335a:	dde5                	beqz	a1,80003352 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000335c:	0009a503          	lw	a0,0(s3)
    80003360:	9abff0ef          	jal	80002d0a <bfree>
      ip->addrs[i] = 0;
    80003364:	0004a023          	sw	zero,0(s1)
    80003368:	b7ed                	j	80003352 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000336a:	0809a583          	lw	a1,128(s3)
    8000336e:	ed89                	bnez	a1,80003388 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003370:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003374:	854e                	mv	a0,s3
    80003376:	e21ff0ef          	jal	80003196 <iupdate>
}
    8000337a:	70a2                	ld	ra,40(sp)
    8000337c:	7402                	ld	s0,32(sp)
    8000337e:	64e2                	ld	s1,24(sp)
    80003380:	6942                	ld	s2,16(sp)
    80003382:	69a2                	ld	s3,8(sp)
    80003384:	6145                	addi	sp,sp,48
    80003386:	8082                	ret
    80003388:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000338a:	0009a503          	lw	a0,0(s3)
    8000338e:	f84ff0ef          	jal	80002b12 <bread>
    80003392:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003394:	05850493          	addi	s1,a0,88
    80003398:	45850913          	addi	s2,a0,1112
    8000339c:	a021                	j	800033a4 <itrunc+0x6c>
    8000339e:	0491                	addi	s1,s1,4
    800033a0:	01248963          	beq	s1,s2,800033b2 <itrunc+0x7a>
      if(a[j])
    800033a4:	408c                	lw	a1,0(s1)
    800033a6:	dde5                	beqz	a1,8000339e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033a8:	0009a503          	lw	a0,0(s3)
    800033ac:	95fff0ef          	jal	80002d0a <bfree>
    800033b0:	b7fd                	j	8000339e <itrunc+0x66>
    brelse(bp);
    800033b2:	8552                	mv	a0,s4
    800033b4:	867ff0ef          	jal	80002c1a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033b8:	0809a583          	lw	a1,128(s3)
    800033bc:	0009a503          	lw	a0,0(s3)
    800033c0:	94bff0ef          	jal	80002d0a <bfree>
    ip->addrs[NDIRECT] = 0;
    800033c4:	0809a023          	sw	zero,128(s3)
    800033c8:	6a02                	ld	s4,0(sp)
    800033ca:	b75d                	j	80003370 <itrunc+0x38>

00000000800033cc <iput>:
{
    800033cc:	1101                	addi	sp,sp,-32
    800033ce:	ec06                	sd	ra,24(sp)
    800033d0:	e822                	sd	s0,16(sp)
    800033d2:	e426                	sd	s1,8(sp)
    800033d4:	1000                	addi	s0,sp,32
    800033d6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033d8:	0001b517          	auipc	a0,0x1b
    800033dc:	d8050513          	addi	a0,a0,-640 # 8001e158 <itable>
    800033e0:	815fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033e4:	4498                	lw	a4,8(s1)
    800033e6:	4785                	li	a5,1
    800033e8:	02f70063          	beq	a4,a5,80003408 <iput+0x3c>
  ip->ref--;
    800033ec:	449c                	lw	a5,8(s1)
    800033ee:	37fd                	addiw	a5,a5,-1
    800033f0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033f2:	0001b517          	auipc	a0,0x1b
    800033f6:	d6650513          	addi	a0,a0,-666 # 8001e158 <itable>
    800033fa:	893fd0ef          	jal	80000c8c <release>
}
    800033fe:	60e2                	ld	ra,24(sp)
    80003400:	6442                	ld	s0,16(sp)
    80003402:	64a2                	ld	s1,8(sp)
    80003404:	6105                	addi	sp,sp,32
    80003406:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003408:	40bc                	lw	a5,64(s1)
    8000340a:	d3ed                	beqz	a5,800033ec <iput+0x20>
    8000340c:	04a49783          	lh	a5,74(s1)
    80003410:	fff1                	bnez	a5,800033ec <iput+0x20>
    80003412:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003414:	01048913          	addi	s2,s1,16
    80003418:	854a                	mv	a0,s2
    8000341a:	151000ef          	jal	80003d6a <acquiresleep>
    release(&itable.lock);
    8000341e:	0001b517          	auipc	a0,0x1b
    80003422:	d3a50513          	addi	a0,a0,-710 # 8001e158 <itable>
    80003426:	867fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    8000342a:	8526                	mv	a0,s1
    8000342c:	f0dff0ef          	jal	80003338 <itrunc>
    ip->type = 0;
    80003430:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003434:	8526                	mv	a0,s1
    80003436:	d61ff0ef          	jal	80003196 <iupdate>
    ip->valid = 0;
    8000343a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000343e:	854a                	mv	a0,s2
    80003440:	171000ef          	jal	80003db0 <releasesleep>
    acquire(&itable.lock);
    80003444:	0001b517          	auipc	a0,0x1b
    80003448:	d1450513          	addi	a0,a0,-748 # 8001e158 <itable>
    8000344c:	fa8fd0ef          	jal	80000bf4 <acquire>
    80003450:	6902                	ld	s2,0(sp)
    80003452:	bf69                	j	800033ec <iput+0x20>

0000000080003454 <iunlockput>:
{
    80003454:	1101                	addi	sp,sp,-32
    80003456:	ec06                	sd	ra,24(sp)
    80003458:	e822                	sd	s0,16(sp)
    8000345a:	e426                	sd	s1,8(sp)
    8000345c:	1000                	addi	s0,sp,32
    8000345e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003460:	e99ff0ef          	jal	800032f8 <iunlock>
  iput(ip);
    80003464:	8526                	mv	a0,s1
    80003466:	f67ff0ef          	jal	800033cc <iput>
}
    8000346a:	60e2                	ld	ra,24(sp)
    8000346c:	6442                	ld	s0,16(sp)
    8000346e:	64a2                	ld	s1,8(sp)
    80003470:	6105                	addi	sp,sp,32
    80003472:	8082                	ret

0000000080003474 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003474:	1141                	addi	sp,sp,-16
    80003476:	e422                	sd	s0,8(sp)
    80003478:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000347a:	411c                	lw	a5,0(a0)
    8000347c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000347e:	415c                	lw	a5,4(a0)
    80003480:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003482:	04451783          	lh	a5,68(a0)
    80003486:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000348a:	04a51783          	lh	a5,74(a0)
    8000348e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003492:	04c56783          	lwu	a5,76(a0)
    80003496:	e99c                	sd	a5,16(a1)
}
    80003498:	6422                	ld	s0,8(sp)
    8000349a:	0141                	addi	sp,sp,16
    8000349c:	8082                	ret

000000008000349e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000349e:	457c                	lw	a5,76(a0)
    800034a0:	0ed7eb63          	bltu	a5,a3,80003596 <readi+0xf8>
{
    800034a4:	7159                	addi	sp,sp,-112
    800034a6:	f486                	sd	ra,104(sp)
    800034a8:	f0a2                	sd	s0,96(sp)
    800034aa:	eca6                	sd	s1,88(sp)
    800034ac:	e0d2                	sd	s4,64(sp)
    800034ae:	fc56                	sd	s5,56(sp)
    800034b0:	f85a                	sd	s6,48(sp)
    800034b2:	f45e                	sd	s7,40(sp)
    800034b4:	1880                	addi	s0,sp,112
    800034b6:	8b2a                	mv	s6,a0
    800034b8:	8bae                	mv	s7,a1
    800034ba:	8a32                	mv	s4,a2
    800034bc:	84b6                	mv	s1,a3
    800034be:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800034c0:	9f35                	addw	a4,a4,a3
    return 0;
    800034c2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800034c4:	0cd76063          	bltu	a4,a3,80003584 <readi+0xe6>
    800034c8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800034ca:	00e7f463          	bgeu	a5,a4,800034d2 <readi+0x34>
    n = ip->size - off;
    800034ce:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034d2:	080a8f63          	beqz	s5,80003570 <readi+0xd2>
    800034d6:	e8ca                	sd	s2,80(sp)
    800034d8:	f062                	sd	s8,32(sp)
    800034da:	ec66                	sd	s9,24(sp)
    800034dc:	e86a                	sd	s10,16(sp)
    800034de:	e46e                	sd	s11,8(sp)
    800034e0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800034e2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800034e6:	5c7d                	li	s8,-1
    800034e8:	a80d                	j	8000351a <readi+0x7c>
    800034ea:	020d1d93          	slli	s11,s10,0x20
    800034ee:	020ddd93          	srli	s11,s11,0x20
    800034f2:	05890613          	addi	a2,s2,88
    800034f6:	86ee                	mv	a3,s11
    800034f8:	963a                	add	a2,a2,a4
    800034fa:	85d2                	mv	a1,s4
    800034fc:	855e                	mv	a0,s7
    800034fe:	d97fe0ef          	jal	80002294 <either_copyout>
    80003502:	05850763          	beq	a0,s8,80003550 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003506:	854a                	mv	a0,s2
    80003508:	f12ff0ef          	jal	80002c1a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000350c:	013d09bb          	addw	s3,s10,s3
    80003510:	009d04bb          	addw	s1,s10,s1
    80003514:	9a6e                	add	s4,s4,s11
    80003516:	0559f763          	bgeu	s3,s5,80003564 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000351a:	00a4d59b          	srliw	a1,s1,0xa
    8000351e:	855a                	mv	a0,s6
    80003520:	977ff0ef          	jal	80002e96 <bmap>
    80003524:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003528:	c5b1                	beqz	a1,80003574 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000352a:	000b2503          	lw	a0,0(s6)
    8000352e:	de4ff0ef          	jal	80002b12 <bread>
    80003532:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003534:	3ff4f713          	andi	a4,s1,1023
    80003538:	40ec87bb          	subw	a5,s9,a4
    8000353c:	413a86bb          	subw	a3,s5,s3
    80003540:	8d3e                	mv	s10,a5
    80003542:	2781                	sext.w	a5,a5
    80003544:	0006861b          	sext.w	a2,a3
    80003548:	faf671e3          	bgeu	a2,a5,800034ea <readi+0x4c>
    8000354c:	8d36                	mv	s10,a3
    8000354e:	bf71                	j	800034ea <readi+0x4c>
      brelse(bp);
    80003550:	854a                	mv	a0,s2
    80003552:	ec8ff0ef          	jal	80002c1a <brelse>
      tot = -1;
    80003556:	59fd                	li	s3,-1
      break;
    80003558:	6946                	ld	s2,80(sp)
    8000355a:	7c02                	ld	s8,32(sp)
    8000355c:	6ce2                	ld	s9,24(sp)
    8000355e:	6d42                	ld	s10,16(sp)
    80003560:	6da2                	ld	s11,8(sp)
    80003562:	a831                	j	8000357e <readi+0xe0>
    80003564:	6946                	ld	s2,80(sp)
    80003566:	7c02                	ld	s8,32(sp)
    80003568:	6ce2                	ld	s9,24(sp)
    8000356a:	6d42                	ld	s10,16(sp)
    8000356c:	6da2                	ld	s11,8(sp)
    8000356e:	a801                	j	8000357e <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003570:	89d6                	mv	s3,s5
    80003572:	a031                	j	8000357e <readi+0xe0>
    80003574:	6946                	ld	s2,80(sp)
    80003576:	7c02                	ld	s8,32(sp)
    80003578:	6ce2                	ld	s9,24(sp)
    8000357a:	6d42                	ld	s10,16(sp)
    8000357c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000357e:	0009851b          	sext.w	a0,s3
    80003582:	69a6                	ld	s3,72(sp)
}
    80003584:	70a6                	ld	ra,104(sp)
    80003586:	7406                	ld	s0,96(sp)
    80003588:	64e6                	ld	s1,88(sp)
    8000358a:	6a06                	ld	s4,64(sp)
    8000358c:	7ae2                	ld	s5,56(sp)
    8000358e:	7b42                	ld	s6,48(sp)
    80003590:	7ba2                	ld	s7,40(sp)
    80003592:	6165                	addi	sp,sp,112
    80003594:	8082                	ret
    return 0;
    80003596:	4501                	li	a0,0
}
    80003598:	8082                	ret

000000008000359a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000359a:	457c                	lw	a5,76(a0)
    8000359c:	10d7e063          	bltu	a5,a3,8000369c <writei+0x102>
{
    800035a0:	7159                	addi	sp,sp,-112
    800035a2:	f486                	sd	ra,104(sp)
    800035a4:	f0a2                	sd	s0,96(sp)
    800035a6:	e8ca                	sd	s2,80(sp)
    800035a8:	e0d2                	sd	s4,64(sp)
    800035aa:	fc56                	sd	s5,56(sp)
    800035ac:	f85a                	sd	s6,48(sp)
    800035ae:	f45e                	sd	s7,40(sp)
    800035b0:	1880                	addi	s0,sp,112
    800035b2:	8aaa                	mv	s5,a0
    800035b4:	8bae                	mv	s7,a1
    800035b6:	8a32                	mv	s4,a2
    800035b8:	8936                	mv	s2,a3
    800035ba:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800035bc:	00e687bb          	addw	a5,a3,a4
    800035c0:	0ed7e063          	bltu	a5,a3,800036a0 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800035c4:	00043737          	lui	a4,0x43
    800035c8:	0cf76e63          	bltu	a4,a5,800036a4 <writei+0x10a>
    800035cc:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035ce:	0a0b0f63          	beqz	s6,8000368c <writei+0xf2>
    800035d2:	eca6                	sd	s1,88(sp)
    800035d4:	f062                	sd	s8,32(sp)
    800035d6:	ec66                	sd	s9,24(sp)
    800035d8:	e86a                	sd	s10,16(sp)
    800035da:	e46e                	sd	s11,8(sp)
    800035dc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035de:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800035e2:	5c7d                	li	s8,-1
    800035e4:	a825                	j	8000361c <writei+0x82>
    800035e6:	020d1d93          	slli	s11,s10,0x20
    800035ea:	020ddd93          	srli	s11,s11,0x20
    800035ee:	05848513          	addi	a0,s1,88
    800035f2:	86ee                	mv	a3,s11
    800035f4:	8652                	mv	a2,s4
    800035f6:	85de                	mv	a1,s7
    800035f8:	953a                	add	a0,a0,a4
    800035fa:	ce5fe0ef          	jal	800022de <either_copyin>
    800035fe:	05850a63          	beq	a0,s8,80003652 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003602:	8526                	mv	a0,s1
    80003604:	660000ef          	jal	80003c64 <log_write>
    brelse(bp);
    80003608:	8526                	mv	a0,s1
    8000360a:	e10ff0ef          	jal	80002c1a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000360e:	013d09bb          	addw	s3,s10,s3
    80003612:	012d093b          	addw	s2,s10,s2
    80003616:	9a6e                	add	s4,s4,s11
    80003618:	0569f063          	bgeu	s3,s6,80003658 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000361c:	00a9559b          	srliw	a1,s2,0xa
    80003620:	8556                	mv	a0,s5
    80003622:	875ff0ef          	jal	80002e96 <bmap>
    80003626:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000362a:	c59d                	beqz	a1,80003658 <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000362c:	000aa503          	lw	a0,0(s5)
    80003630:	ce2ff0ef          	jal	80002b12 <bread>
    80003634:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003636:	3ff97713          	andi	a4,s2,1023
    8000363a:	40ec87bb          	subw	a5,s9,a4
    8000363e:	413b06bb          	subw	a3,s6,s3
    80003642:	8d3e                	mv	s10,a5
    80003644:	2781                	sext.w	a5,a5
    80003646:	0006861b          	sext.w	a2,a3
    8000364a:	f8f67ee3          	bgeu	a2,a5,800035e6 <writei+0x4c>
    8000364e:	8d36                	mv	s10,a3
    80003650:	bf59                	j	800035e6 <writei+0x4c>
      brelse(bp);
    80003652:	8526                	mv	a0,s1
    80003654:	dc6ff0ef          	jal	80002c1a <brelse>
  }

  if(off > ip->size)
    80003658:	04caa783          	lw	a5,76(s5)
    8000365c:	0327fa63          	bgeu	a5,s2,80003690 <writei+0xf6>
    ip->size = off;
    80003660:	052aa623          	sw	s2,76(s5)
    80003664:	64e6                	ld	s1,88(sp)
    80003666:	7c02                	ld	s8,32(sp)
    80003668:	6ce2                	ld	s9,24(sp)
    8000366a:	6d42                	ld	s10,16(sp)
    8000366c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000366e:	8556                	mv	a0,s5
    80003670:	b27ff0ef          	jal	80003196 <iupdate>

  return tot;
    80003674:	0009851b          	sext.w	a0,s3
    80003678:	69a6                	ld	s3,72(sp)
}
    8000367a:	70a6                	ld	ra,104(sp)
    8000367c:	7406                	ld	s0,96(sp)
    8000367e:	6946                	ld	s2,80(sp)
    80003680:	6a06                	ld	s4,64(sp)
    80003682:	7ae2                	ld	s5,56(sp)
    80003684:	7b42                	ld	s6,48(sp)
    80003686:	7ba2                	ld	s7,40(sp)
    80003688:	6165                	addi	sp,sp,112
    8000368a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000368c:	89da                	mv	s3,s6
    8000368e:	b7c5                	j	8000366e <writei+0xd4>
    80003690:	64e6                	ld	s1,88(sp)
    80003692:	7c02                	ld	s8,32(sp)
    80003694:	6ce2                	ld	s9,24(sp)
    80003696:	6d42                	ld	s10,16(sp)
    80003698:	6da2                	ld	s11,8(sp)
    8000369a:	bfd1                	j	8000366e <writei+0xd4>
    return -1;
    8000369c:	557d                	li	a0,-1
}
    8000369e:	8082                	ret
    return -1;
    800036a0:	557d                	li	a0,-1
    800036a2:	bfe1                	j	8000367a <writei+0xe0>
    return -1;
    800036a4:	557d                	li	a0,-1
    800036a6:	bfd1                	j	8000367a <writei+0xe0>

00000000800036a8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800036a8:	1141                	addi	sp,sp,-16
    800036aa:	e406                	sd	ra,8(sp)
    800036ac:	e022                	sd	s0,0(sp)
    800036ae:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800036b0:	4639                	li	a2,14
    800036b2:	ee2fd0ef          	jal	80000d94 <strncmp>
}
    800036b6:	60a2                	ld	ra,8(sp)
    800036b8:	6402                	ld	s0,0(sp)
    800036ba:	0141                	addi	sp,sp,16
    800036bc:	8082                	ret

00000000800036be <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800036be:	7139                	addi	sp,sp,-64
    800036c0:	fc06                	sd	ra,56(sp)
    800036c2:	f822                	sd	s0,48(sp)
    800036c4:	f426                	sd	s1,40(sp)
    800036c6:	f04a                	sd	s2,32(sp)
    800036c8:	ec4e                	sd	s3,24(sp)
    800036ca:	e852                	sd	s4,16(sp)
    800036cc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800036ce:	04451703          	lh	a4,68(a0)
    800036d2:	4785                	li	a5,1
    800036d4:	00f71a63          	bne	a4,a5,800036e8 <dirlookup+0x2a>
    800036d8:	892a                	mv	s2,a0
    800036da:	89ae                	mv	s3,a1
    800036dc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800036de:	457c                	lw	a5,76(a0)
    800036e0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800036e2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036e4:	e39d                	bnez	a5,8000370a <dirlookup+0x4c>
    800036e6:	a095                	j	8000374a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800036e8:	00004517          	auipc	a0,0x4
    800036ec:	e3850513          	addi	a0,a0,-456 # 80007520 <etext+0x520>
    800036f0:	8a4fd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    800036f4:	00004517          	auipc	a0,0x4
    800036f8:	e4450513          	addi	a0,a0,-444 # 80007538 <etext+0x538>
    800036fc:	898fd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003700:	24c1                	addiw	s1,s1,16
    80003702:	04c92783          	lw	a5,76(s2)
    80003706:	04f4f163          	bgeu	s1,a5,80003748 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000370a:	4741                	li	a4,16
    8000370c:	86a6                	mv	a3,s1
    8000370e:	fc040613          	addi	a2,s0,-64
    80003712:	4581                	li	a1,0
    80003714:	854a                	mv	a0,s2
    80003716:	d89ff0ef          	jal	8000349e <readi>
    8000371a:	47c1                	li	a5,16
    8000371c:	fcf51ce3          	bne	a0,a5,800036f4 <dirlookup+0x36>
    if(de.inum == 0)
    80003720:	fc045783          	lhu	a5,-64(s0)
    80003724:	dff1                	beqz	a5,80003700 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003726:	fc240593          	addi	a1,s0,-62
    8000372a:	854e                	mv	a0,s3
    8000372c:	f7dff0ef          	jal	800036a8 <namecmp>
    80003730:	f961                	bnez	a0,80003700 <dirlookup+0x42>
      if(poff)
    80003732:	000a0463          	beqz	s4,8000373a <dirlookup+0x7c>
        *poff = off;
    80003736:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000373a:	fc045583          	lhu	a1,-64(s0)
    8000373e:	00092503          	lw	a0,0(s2)
    80003742:	829ff0ef          	jal	80002f6a <iget>
    80003746:	a011                	j	8000374a <dirlookup+0x8c>
  return 0;
    80003748:	4501                	li	a0,0
}
    8000374a:	70e2                	ld	ra,56(sp)
    8000374c:	7442                	ld	s0,48(sp)
    8000374e:	74a2                	ld	s1,40(sp)
    80003750:	7902                	ld	s2,32(sp)
    80003752:	69e2                	ld	s3,24(sp)
    80003754:	6a42                	ld	s4,16(sp)
    80003756:	6121                	addi	sp,sp,64
    80003758:	8082                	ret

000000008000375a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000375a:	711d                	addi	sp,sp,-96
    8000375c:	ec86                	sd	ra,88(sp)
    8000375e:	e8a2                	sd	s0,80(sp)
    80003760:	e4a6                	sd	s1,72(sp)
    80003762:	e0ca                	sd	s2,64(sp)
    80003764:	fc4e                	sd	s3,56(sp)
    80003766:	f852                	sd	s4,48(sp)
    80003768:	f456                	sd	s5,40(sp)
    8000376a:	f05a                	sd	s6,32(sp)
    8000376c:	ec5e                	sd	s7,24(sp)
    8000376e:	e862                	sd	s8,16(sp)
    80003770:	e466                	sd	s9,8(sp)
    80003772:	1080                	addi	s0,sp,96
    80003774:	84aa                	mv	s1,a0
    80003776:	8b2e                	mv	s6,a1
    80003778:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000377a:	00054703          	lbu	a4,0(a0)
    8000377e:	02f00793          	li	a5,47
    80003782:	00f70e63          	beq	a4,a5,8000379e <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003786:	95afe0ef          	jal	800018e0 <myproc>
    8000378a:	15853503          	ld	a0,344(a0)
    8000378e:	a87ff0ef          	jal	80003214 <idup>
    80003792:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003794:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003798:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000379a:	4b85                	li	s7,1
    8000379c:	a871                	j	80003838 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    8000379e:	4585                	li	a1,1
    800037a0:	4505                	li	a0,1
    800037a2:	fc8ff0ef          	jal	80002f6a <iget>
    800037a6:	8a2a                	mv	s4,a0
    800037a8:	b7f5                	j	80003794 <namex+0x3a>
      iunlockput(ip);
    800037aa:	8552                	mv	a0,s4
    800037ac:	ca9ff0ef          	jal	80003454 <iunlockput>
      return 0;
    800037b0:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800037b2:	8552                	mv	a0,s4
    800037b4:	60e6                	ld	ra,88(sp)
    800037b6:	6446                	ld	s0,80(sp)
    800037b8:	64a6                	ld	s1,72(sp)
    800037ba:	6906                	ld	s2,64(sp)
    800037bc:	79e2                	ld	s3,56(sp)
    800037be:	7a42                	ld	s4,48(sp)
    800037c0:	7aa2                	ld	s5,40(sp)
    800037c2:	7b02                	ld	s6,32(sp)
    800037c4:	6be2                	ld	s7,24(sp)
    800037c6:	6c42                	ld	s8,16(sp)
    800037c8:	6ca2                	ld	s9,8(sp)
    800037ca:	6125                	addi	sp,sp,96
    800037cc:	8082                	ret
      iunlock(ip);
    800037ce:	8552                	mv	a0,s4
    800037d0:	b29ff0ef          	jal	800032f8 <iunlock>
      return ip;
    800037d4:	bff9                	j	800037b2 <namex+0x58>
      iunlockput(ip);
    800037d6:	8552                	mv	a0,s4
    800037d8:	c7dff0ef          	jal	80003454 <iunlockput>
      return 0;
    800037dc:	8a4e                	mv	s4,s3
    800037de:	bfd1                	j	800037b2 <namex+0x58>
  len = path - s;
    800037e0:	40998633          	sub	a2,s3,s1
    800037e4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800037e8:	099c5063          	bge	s8,s9,80003868 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800037ec:	4639                	li	a2,14
    800037ee:	85a6                	mv	a1,s1
    800037f0:	8556                	mv	a0,s5
    800037f2:	d32fd0ef          	jal	80000d24 <memmove>
    800037f6:	84ce                	mv	s1,s3
  while(*path == '/')
    800037f8:	0004c783          	lbu	a5,0(s1)
    800037fc:	01279763          	bne	a5,s2,8000380a <namex+0xb0>
    path++;
    80003800:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003802:	0004c783          	lbu	a5,0(s1)
    80003806:	ff278de3          	beq	a5,s2,80003800 <namex+0xa6>
    ilock(ip);
    8000380a:	8552                	mv	a0,s4
    8000380c:	a3fff0ef          	jal	8000324a <ilock>
    if(ip->type != T_DIR){
    80003810:	044a1783          	lh	a5,68(s4)
    80003814:	f9779be3          	bne	a5,s7,800037aa <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003818:	000b0563          	beqz	s6,80003822 <namex+0xc8>
    8000381c:	0004c783          	lbu	a5,0(s1)
    80003820:	d7dd                	beqz	a5,800037ce <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003822:	4601                	li	a2,0
    80003824:	85d6                	mv	a1,s5
    80003826:	8552                	mv	a0,s4
    80003828:	e97ff0ef          	jal	800036be <dirlookup>
    8000382c:	89aa                	mv	s3,a0
    8000382e:	d545                	beqz	a0,800037d6 <namex+0x7c>
    iunlockput(ip);
    80003830:	8552                	mv	a0,s4
    80003832:	c23ff0ef          	jal	80003454 <iunlockput>
    ip = next;
    80003836:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003838:	0004c783          	lbu	a5,0(s1)
    8000383c:	01279763          	bne	a5,s2,8000384a <namex+0xf0>
    path++;
    80003840:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003842:	0004c783          	lbu	a5,0(s1)
    80003846:	ff278de3          	beq	a5,s2,80003840 <namex+0xe6>
  if(*path == 0)
    8000384a:	cb8d                	beqz	a5,8000387c <namex+0x122>
  while(*path != '/' && *path != 0)
    8000384c:	0004c783          	lbu	a5,0(s1)
    80003850:	89a6                	mv	s3,s1
  len = path - s;
    80003852:	4c81                	li	s9,0
    80003854:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003856:	01278963          	beq	a5,s2,80003868 <namex+0x10e>
    8000385a:	d3d9                	beqz	a5,800037e0 <namex+0x86>
    path++;
    8000385c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000385e:	0009c783          	lbu	a5,0(s3)
    80003862:	ff279ce3          	bne	a5,s2,8000385a <namex+0x100>
    80003866:	bfad                	j	800037e0 <namex+0x86>
    memmove(name, s, len);
    80003868:	2601                	sext.w	a2,a2
    8000386a:	85a6                	mv	a1,s1
    8000386c:	8556                	mv	a0,s5
    8000386e:	cb6fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003872:	9cd6                	add	s9,s9,s5
    80003874:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003878:	84ce                	mv	s1,s3
    8000387a:	bfbd                	j	800037f8 <namex+0x9e>
  if(nameiparent){
    8000387c:	f20b0be3          	beqz	s6,800037b2 <namex+0x58>
    iput(ip);
    80003880:	8552                	mv	a0,s4
    80003882:	b4bff0ef          	jal	800033cc <iput>
    return 0;
    80003886:	4a01                	li	s4,0
    80003888:	b72d                	j	800037b2 <namex+0x58>

000000008000388a <dirlink>:
{
    8000388a:	7139                	addi	sp,sp,-64
    8000388c:	fc06                	sd	ra,56(sp)
    8000388e:	f822                	sd	s0,48(sp)
    80003890:	f04a                	sd	s2,32(sp)
    80003892:	ec4e                	sd	s3,24(sp)
    80003894:	e852                	sd	s4,16(sp)
    80003896:	0080                	addi	s0,sp,64
    80003898:	892a                	mv	s2,a0
    8000389a:	8a2e                	mv	s4,a1
    8000389c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000389e:	4601                	li	a2,0
    800038a0:	e1fff0ef          	jal	800036be <dirlookup>
    800038a4:	e535                	bnez	a0,80003910 <dirlink+0x86>
    800038a6:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038a8:	04c92483          	lw	s1,76(s2)
    800038ac:	c48d                	beqz	s1,800038d6 <dirlink+0x4c>
    800038ae:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038b0:	4741                	li	a4,16
    800038b2:	86a6                	mv	a3,s1
    800038b4:	fc040613          	addi	a2,s0,-64
    800038b8:	4581                	li	a1,0
    800038ba:	854a                	mv	a0,s2
    800038bc:	be3ff0ef          	jal	8000349e <readi>
    800038c0:	47c1                	li	a5,16
    800038c2:	04f51b63          	bne	a0,a5,80003918 <dirlink+0x8e>
    if(de.inum == 0)
    800038c6:	fc045783          	lhu	a5,-64(s0)
    800038ca:	c791                	beqz	a5,800038d6 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038cc:	24c1                	addiw	s1,s1,16
    800038ce:	04c92783          	lw	a5,76(s2)
    800038d2:	fcf4efe3          	bltu	s1,a5,800038b0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800038d6:	4639                	li	a2,14
    800038d8:	85d2                	mv	a1,s4
    800038da:	fc240513          	addi	a0,s0,-62
    800038de:	cecfd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    800038e2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038e6:	4741                	li	a4,16
    800038e8:	86a6                	mv	a3,s1
    800038ea:	fc040613          	addi	a2,s0,-64
    800038ee:	4581                	li	a1,0
    800038f0:	854a                	mv	a0,s2
    800038f2:	ca9ff0ef          	jal	8000359a <writei>
    800038f6:	1541                	addi	a0,a0,-16
    800038f8:	00a03533          	snez	a0,a0
    800038fc:	40a00533          	neg	a0,a0
    80003900:	74a2                	ld	s1,40(sp)
}
    80003902:	70e2                	ld	ra,56(sp)
    80003904:	7442                	ld	s0,48(sp)
    80003906:	7902                	ld	s2,32(sp)
    80003908:	69e2                	ld	s3,24(sp)
    8000390a:	6a42                	ld	s4,16(sp)
    8000390c:	6121                	addi	sp,sp,64
    8000390e:	8082                	ret
    iput(ip);
    80003910:	abdff0ef          	jal	800033cc <iput>
    return -1;
    80003914:	557d                	li	a0,-1
    80003916:	b7f5                	j	80003902 <dirlink+0x78>
      panic("dirlink read");
    80003918:	00004517          	auipc	a0,0x4
    8000391c:	c3050513          	addi	a0,a0,-976 # 80007548 <etext+0x548>
    80003920:	e75fc0ef          	jal	80000794 <panic>

0000000080003924 <namei>:

struct inode*
namei(char *path)
{
    80003924:	1101                	addi	sp,sp,-32
    80003926:	ec06                	sd	ra,24(sp)
    80003928:	e822                	sd	s0,16(sp)
    8000392a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000392c:	fe040613          	addi	a2,s0,-32
    80003930:	4581                	li	a1,0
    80003932:	e29ff0ef          	jal	8000375a <namex>
}
    80003936:	60e2                	ld	ra,24(sp)
    80003938:	6442                	ld	s0,16(sp)
    8000393a:	6105                	addi	sp,sp,32
    8000393c:	8082                	ret

000000008000393e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000393e:	1141                	addi	sp,sp,-16
    80003940:	e406                	sd	ra,8(sp)
    80003942:	e022                	sd	s0,0(sp)
    80003944:	0800                	addi	s0,sp,16
    80003946:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003948:	4585                	li	a1,1
    8000394a:	e11ff0ef          	jal	8000375a <namex>
}
    8000394e:	60a2                	ld	ra,8(sp)
    80003950:	6402                	ld	s0,0(sp)
    80003952:	0141                	addi	sp,sp,16
    80003954:	8082                	ret

0000000080003956 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003956:	1101                	addi	sp,sp,-32
    80003958:	ec06                	sd	ra,24(sp)
    8000395a:	e822                	sd	s0,16(sp)
    8000395c:	e426                	sd	s1,8(sp)
    8000395e:	e04a                	sd	s2,0(sp)
    80003960:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003962:	0001c917          	auipc	s2,0x1c
    80003966:	29e90913          	addi	s2,s2,670 # 8001fc00 <log>
    8000396a:	01892583          	lw	a1,24(s2)
    8000396e:	02892503          	lw	a0,40(s2)
    80003972:	9a0ff0ef          	jal	80002b12 <bread>
    80003976:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003978:	02c92603          	lw	a2,44(s2)
    8000397c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000397e:	00c05f63          	blez	a2,8000399c <write_head+0x46>
    80003982:	0001c717          	auipc	a4,0x1c
    80003986:	2ae70713          	addi	a4,a4,686 # 8001fc30 <log+0x30>
    8000398a:	87aa                	mv	a5,a0
    8000398c:	060a                	slli	a2,a2,0x2
    8000398e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003990:	4314                	lw	a3,0(a4)
    80003992:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003994:	0711                	addi	a4,a4,4
    80003996:	0791                	addi	a5,a5,4
    80003998:	fec79ce3          	bne	a5,a2,80003990 <write_head+0x3a>
  }
  bwrite(buf);
    8000399c:	8526                	mv	a0,s1
    8000399e:	a4aff0ef          	jal	80002be8 <bwrite>
  brelse(buf);
    800039a2:	8526                	mv	a0,s1
    800039a4:	a76ff0ef          	jal	80002c1a <brelse>
}
    800039a8:	60e2                	ld	ra,24(sp)
    800039aa:	6442                	ld	s0,16(sp)
    800039ac:	64a2                	ld	s1,8(sp)
    800039ae:	6902                	ld	s2,0(sp)
    800039b0:	6105                	addi	sp,sp,32
    800039b2:	8082                	ret

00000000800039b4 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800039b4:	0001c797          	auipc	a5,0x1c
    800039b8:	2787a783          	lw	a5,632(a5) # 8001fc2c <log+0x2c>
    800039bc:	08f05f63          	blez	a5,80003a5a <install_trans+0xa6>
{
    800039c0:	7139                	addi	sp,sp,-64
    800039c2:	fc06                	sd	ra,56(sp)
    800039c4:	f822                	sd	s0,48(sp)
    800039c6:	f426                	sd	s1,40(sp)
    800039c8:	f04a                	sd	s2,32(sp)
    800039ca:	ec4e                	sd	s3,24(sp)
    800039cc:	e852                	sd	s4,16(sp)
    800039ce:	e456                	sd	s5,8(sp)
    800039d0:	e05a                	sd	s6,0(sp)
    800039d2:	0080                	addi	s0,sp,64
    800039d4:	8b2a                	mv	s6,a0
    800039d6:	0001ca97          	auipc	s5,0x1c
    800039da:	25aa8a93          	addi	s5,s5,602 # 8001fc30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039de:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039e0:	0001c997          	auipc	s3,0x1c
    800039e4:	22098993          	addi	s3,s3,544 # 8001fc00 <log>
    800039e8:	a829                	j	80003a02 <install_trans+0x4e>
    brelse(lbuf);
    800039ea:	854a                	mv	a0,s2
    800039ec:	a2eff0ef          	jal	80002c1a <brelse>
    brelse(dbuf);
    800039f0:	8526                	mv	a0,s1
    800039f2:	a28ff0ef          	jal	80002c1a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039f6:	2a05                	addiw	s4,s4,1
    800039f8:	0a91                	addi	s5,s5,4
    800039fa:	02c9a783          	lw	a5,44(s3)
    800039fe:	04fa5463          	bge	s4,a5,80003a46 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a02:	0189a583          	lw	a1,24(s3)
    80003a06:	014585bb          	addw	a1,a1,s4
    80003a0a:	2585                	addiw	a1,a1,1
    80003a0c:	0289a503          	lw	a0,40(s3)
    80003a10:	902ff0ef          	jal	80002b12 <bread>
    80003a14:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a16:	000aa583          	lw	a1,0(s5)
    80003a1a:	0289a503          	lw	a0,40(s3)
    80003a1e:	8f4ff0ef          	jal	80002b12 <bread>
    80003a22:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a24:	40000613          	li	a2,1024
    80003a28:	05890593          	addi	a1,s2,88
    80003a2c:	05850513          	addi	a0,a0,88
    80003a30:	af4fd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003a34:	8526                	mv	a0,s1
    80003a36:	9b2ff0ef          	jal	80002be8 <bwrite>
    if(recovering == 0)
    80003a3a:	fa0b18e3          	bnez	s6,800039ea <install_trans+0x36>
      bunpin(dbuf);
    80003a3e:	8526                	mv	a0,s1
    80003a40:	a96ff0ef          	jal	80002cd6 <bunpin>
    80003a44:	b75d                	j	800039ea <install_trans+0x36>
}
    80003a46:	70e2                	ld	ra,56(sp)
    80003a48:	7442                	ld	s0,48(sp)
    80003a4a:	74a2                	ld	s1,40(sp)
    80003a4c:	7902                	ld	s2,32(sp)
    80003a4e:	69e2                	ld	s3,24(sp)
    80003a50:	6a42                	ld	s4,16(sp)
    80003a52:	6aa2                	ld	s5,8(sp)
    80003a54:	6b02                	ld	s6,0(sp)
    80003a56:	6121                	addi	sp,sp,64
    80003a58:	8082                	ret
    80003a5a:	8082                	ret

0000000080003a5c <initlog>:
{
    80003a5c:	7179                	addi	sp,sp,-48
    80003a5e:	f406                	sd	ra,40(sp)
    80003a60:	f022                	sd	s0,32(sp)
    80003a62:	ec26                	sd	s1,24(sp)
    80003a64:	e84a                	sd	s2,16(sp)
    80003a66:	e44e                	sd	s3,8(sp)
    80003a68:	1800                	addi	s0,sp,48
    80003a6a:	892a                	mv	s2,a0
    80003a6c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a6e:	0001c497          	auipc	s1,0x1c
    80003a72:	19248493          	addi	s1,s1,402 # 8001fc00 <log>
    80003a76:	00004597          	auipc	a1,0x4
    80003a7a:	ae258593          	addi	a1,a1,-1310 # 80007558 <etext+0x558>
    80003a7e:	8526                	mv	a0,s1
    80003a80:	8f4fd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003a84:	0149a583          	lw	a1,20(s3)
    80003a88:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a8a:	0109a783          	lw	a5,16(s3)
    80003a8e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003a90:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a94:	854a                	mv	a0,s2
    80003a96:	87cff0ef          	jal	80002b12 <bread>
  log.lh.n = lh->n;
    80003a9a:	4d30                	lw	a2,88(a0)
    80003a9c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a9e:	00c05f63          	blez	a2,80003abc <initlog+0x60>
    80003aa2:	87aa                	mv	a5,a0
    80003aa4:	0001c717          	auipc	a4,0x1c
    80003aa8:	18c70713          	addi	a4,a4,396 # 8001fc30 <log+0x30>
    80003aac:	060a                	slli	a2,a2,0x2
    80003aae:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ab0:	4ff4                	lw	a3,92(a5)
    80003ab2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ab4:	0791                	addi	a5,a5,4
    80003ab6:	0711                	addi	a4,a4,4
    80003ab8:	fec79ce3          	bne	a5,a2,80003ab0 <initlog+0x54>
  brelse(buf);
    80003abc:	95eff0ef          	jal	80002c1a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ac0:	4505                	li	a0,1
    80003ac2:	ef3ff0ef          	jal	800039b4 <install_trans>
  log.lh.n = 0;
    80003ac6:	0001c797          	auipc	a5,0x1c
    80003aca:	1607a323          	sw	zero,358(a5) # 8001fc2c <log+0x2c>
  write_head(); // clear the log
    80003ace:	e89ff0ef          	jal	80003956 <write_head>
}
    80003ad2:	70a2                	ld	ra,40(sp)
    80003ad4:	7402                	ld	s0,32(sp)
    80003ad6:	64e2                	ld	s1,24(sp)
    80003ad8:	6942                	ld	s2,16(sp)
    80003ada:	69a2                	ld	s3,8(sp)
    80003adc:	6145                	addi	sp,sp,48
    80003ade:	8082                	ret

0000000080003ae0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ae0:	1101                	addi	sp,sp,-32
    80003ae2:	ec06                	sd	ra,24(sp)
    80003ae4:	e822                	sd	s0,16(sp)
    80003ae6:	e426                	sd	s1,8(sp)
    80003ae8:	e04a                	sd	s2,0(sp)
    80003aea:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003aec:	0001c517          	auipc	a0,0x1c
    80003af0:	11450513          	addi	a0,a0,276 # 8001fc00 <log>
    80003af4:	900fd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003af8:	0001c497          	auipc	s1,0x1c
    80003afc:	10848493          	addi	s1,s1,264 # 8001fc00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b00:	4979                	li	s2,30
    80003b02:	a029                	j	80003b0c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003b04:	85a6                	mv	a1,s1
    80003b06:	8526                	mv	a0,s1
    80003b08:	c30fe0ef          	jal	80001f38 <sleep>
    if(log.committing){
    80003b0c:	50dc                	lw	a5,36(s1)
    80003b0e:	fbfd                	bnez	a5,80003b04 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b10:	5098                	lw	a4,32(s1)
    80003b12:	2705                	addiw	a4,a4,1
    80003b14:	0027179b          	slliw	a5,a4,0x2
    80003b18:	9fb9                	addw	a5,a5,a4
    80003b1a:	0017979b          	slliw	a5,a5,0x1
    80003b1e:	54d4                	lw	a3,44(s1)
    80003b20:	9fb5                	addw	a5,a5,a3
    80003b22:	00f95763          	bge	s2,a5,80003b30 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003b26:	85a6                	mv	a1,s1
    80003b28:	8526                	mv	a0,s1
    80003b2a:	c0efe0ef          	jal	80001f38 <sleep>
    80003b2e:	bff9                	j	80003b0c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b30:	0001c517          	auipc	a0,0x1c
    80003b34:	0d050513          	addi	a0,a0,208 # 8001fc00 <log>
    80003b38:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003b3a:	952fd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003b3e:	60e2                	ld	ra,24(sp)
    80003b40:	6442                	ld	s0,16(sp)
    80003b42:	64a2                	ld	s1,8(sp)
    80003b44:	6902                	ld	s2,0(sp)
    80003b46:	6105                	addi	sp,sp,32
    80003b48:	8082                	ret

0000000080003b4a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b4a:	7139                	addi	sp,sp,-64
    80003b4c:	fc06                	sd	ra,56(sp)
    80003b4e:	f822                	sd	s0,48(sp)
    80003b50:	f426                	sd	s1,40(sp)
    80003b52:	f04a                	sd	s2,32(sp)
    80003b54:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b56:	0001c497          	auipc	s1,0x1c
    80003b5a:	0aa48493          	addi	s1,s1,170 # 8001fc00 <log>
    80003b5e:	8526                	mv	a0,s1
    80003b60:	894fd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003b64:	509c                	lw	a5,32(s1)
    80003b66:	37fd                	addiw	a5,a5,-1
    80003b68:	0007891b          	sext.w	s2,a5
    80003b6c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003b6e:	50dc                	lw	a5,36(s1)
    80003b70:	ef9d                	bnez	a5,80003bae <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b72:	04091763          	bnez	s2,80003bc0 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b76:	0001c497          	auipc	s1,0x1c
    80003b7a:	08a48493          	addi	s1,s1,138 # 8001fc00 <log>
    80003b7e:	4785                	li	a5,1
    80003b80:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b82:	8526                	mv	a0,s1
    80003b84:	908fd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b88:	54dc                	lw	a5,44(s1)
    80003b8a:	04f04b63          	bgtz	a5,80003be0 <end_op+0x96>
    acquire(&log.lock);
    80003b8e:	0001c497          	auipc	s1,0x1c
    80003b92:	07248493          	addi	s1,s1,114 # 8001fc00 <log>
    80003b96:	8526                	mv	a0,s1
    80003b98:	85cfd0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003b9c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	be2fe0ef          	jal	80001f84 <wakeup>
    release(&log.lock);
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	8e4fd0ef          	jal	80000c8c <release>
}
    80003bac:	a025                	j	80003bd4 <end_op+0x8a>
    80003bae:	ec4e                	sd	s3,24(sp)
    80003bb0:	e852                	sd	s4,16(sp)
    80003bb2:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003bb4:	00004517          	auipc	a0,0x4
    80003bb8:	9ac50513          	addi	a0,a0,-1620 # 80007560 <etext+0x560>
    80003bbc:	bd9fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003bc0:	0001c497          	auipc	s1,0x1c
    80003bc4:	04048493          	addi	s1,s1,64 # 8001fc00 <log>
    80003bc8:	8526                	mv	a0,s1
    80003bca:	bbafe0ef          	jal	80001f84 <wakeup>
  release(&log.lock);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	8bcfd0ef          	jal	80000c8c <release>
}
    80003bd4:	70e2                	ld	ra,56(sp)
    80003bd6:	7442                	ld	s0,48(sp)
    80003bd8:	74a2                	ld	s1,40(sp)
    80003bda:	7902                	ld	s2,32(sp)
    80003bdc:	6121                	addi	sp,sp,64
    80003bde:	8082                	ret
    80003be0:	ec4e                	sd	s3,24(sp)
    80003be2:	e852                	sd	s4,16(sp)
    80003be4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003be6:	0001ca97          	auipc	s5,0x1c
    80003bea:	04aa8a93          	addi	s5,s5,74 # 8001fc30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003bee:	0001ca17          	auipc	s4,0x1c
    80003bf2:	012a0a13          	addi	s4,s4,18 # 8001fc00 <log>
    80003bf6:	018a2583          	lw	a1,24(s4)
    80003bfa:	012585bb          	addw	a1,a1,s2
    80003bfe:	2585                	addiw	a1,a1,1
    80003c00:	028a2503          	lw	a0,40(s4)
    80003c04:	f0ffe0ef          	jal	80002b12 <bread>
    80003c08:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c0a:	000aa583          	lw	a1,0(s5)
    80003c0e:	028a2503          	lw	a0,40(s4)
    80003c12:	f01fe0ef          	jal	80002b12 <bread>
    80003c16:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c18:	40000613          	li	a2,1024
    80003c1c:	05850593          	addi	a1,a0,88
    80003c20:	05848513          	addi	a0,s1,88
    80003c24:	900fd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003c28:	8526                	mv	a0,s1
    80003c2a:	fbffe0ef          	jal	80002be8 <bwrite>
    brelse(from);
    80003c2e:	854e                	mv	a0,s3
    80003c30:	febfe0ef          	jal	80002c1a <brelse>
    brelse(to);
    80003c34:	8526                	mv	a0,s1
    80003c36:	fe5fe0ef          	jal	80002c1a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c3a:	2905                	addiw	s2,s2,1
    80003c3c:	0a91                	addi	s5,s5,4
    80003c3e:	02ca2783          	lw	a5,44(s4)
    80003c42:	faf94ae3          	blt	s2,a5,80003bf6 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c46:	d11ff0ef          	jal	80003956 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c4a:	4501                	li	a0,0
    80003c4c:	d69ff0ef          	jal	800039b4 <install_trans>
    log.lh.n = 0;
    80003c50:	0001c797          	auipc	a5,0x1c
    80003c54:	fc07ae23          	sw	zero,-36(a5) # 8001fc2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003c58:	cffff0ef          	jal	80003956 <write_head>
    80003c5c:	69e2                	ld	s3,24(sp)
    80003c5e:	6a42                	ld	s4,16(sp)
    80003c60:	6aa2                	ld	s5,8(sp)
    80003c62:	b735                	j	80003b8e <end_op+0x44>

0000000080003c64 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c64:	1101                	addi	sp,sp,-32
    80003c66:	ec06                	sd	ra,24(sp)
    80003c68:	e822                	sd	s0,16(sp)
    80003c6a:	e426                	sd	s1,8(sp)
    80003c6c:	e04a                	sd	s2,0(sp)
    80003c6e:	1000                	addi	s0,sp,32
    80003c70:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c72:	0001c917          	auipc	s2,0x1c
    80003c76:	f8e90913          	addi	s2,s2,-114 # 8001fc00 <log>
    80003c7a:	854a                	mv	a0,s2
    80003c7c:	f79fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c80:	02c92603          	lw	a2,44(s2)
    80003c84:	47f5                	li	a5,29
    80003c86:	06c7c363          	blt	a5,a2,80003cec <log_write+0x88>
    80003c8a:	0001c797          	auipc	a5,0x1c
    80003c8e:	f927a783          	lw	a5,-110(a5) # 8001fc1c <log+0x1c>
    80003c92:	37fd                	addiw	a5,a5,-1
    80003c94:	04f65c63          	bge	a2,a5,80003cec <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c98:	0001c797          	auipc	a5,0x1c
    80003c9c:	f887a783          	lw	a5,-120(a5) # 8001fc20 <log+0x20>
    80003ca0:	04f05c63          	blez	a5,80003cf8 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003ca4:	4781                	li	a5,0
    80003ca6:	04c05f63          	blez	a2,80003d04 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003caa:	44cc                	lw	a1,12(s1)
    80003cac:	0001c717          	auipc	a4,0x1c
    80003cb0:	f8470713          	addi	a4,a4,-124 # 8001fc30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003cb4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003cb6:	4314                	lw	a3,0(a4)
    80003cb8:	04b68663          	beq	a3,a1,80003d04 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003cbc:	2785                	addiw	a5,a5,1
    80003cbe:	0711                	addi	a4,a4,4
    80003cc0:	fef61be3          	bne	a2,a5,80003cb6 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003cc4:	0621                	addi	a2,a2,8
    80003cc6:	060a                	slli	a2,a2,0x2
    80003cc8:	0001c797          	auipc	a5,0x1c
    80003ccc:	f3878793          	addi	a5,a5,-200 # 8001fc00 <log>
    80003cd0:	97b2                	add	a5,a5,a2
    80003cd2:	44d8                	lw	a4,12(s1)
    80003cd4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003cd6:	8526                	mv	a0,s1
    80003cd8:	fcbfe0ef          	jal	80002ca2 <bpin>
    log.lh.n++;
    80003cdc:	0001c717          	auipc	a4,0x1c
    80003ce0:	f2470713          	addi	a4,a4,-220 # 8001fc00 <log>
    80003ce4:	575c                	lw	a5,44(a4)
    80003ce6:	2785                	addiw	a5,a5,1
    80003ce8:	d75c                	sw	a5,44(a4)
    80003cea:	a80d                	j	80003d1c <log_write+0xb8>
    panic("too big a transaction");
    80003cec:	00004517          	auipc	a0,0x4
    80003cf0:	88450513          	addi	a0,a0,-1916 # 80007570 <etext+0x570>
    80003cf4:	aa1fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003cf8:	00004517          	auipc	a0,0x4
    80003cfc:	89050513          	addi	a0,a0,-1904 # 80007588 <etext+0x588>
    80003d00:	a95fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003d04:	00878693          	addi	a3,a5,8
    80003d08:	068a                	slli	a3,a3,0x2
    80003d0a:	0001c717          	auipc	a4,0x1c
    80003d0e:	ef670713          	addi	a4,a4,-266 # 8001fc00 <log>
    80003d12:	9736                	add	a4,a4,a3
    80003d14:	44d4                	lw	a3,12(s1)
    80003d16:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d18:	faf60fe3          	beq	a2,a5,80003cd6 <log_write+0x72>
  }
  release(&log.lock);
    80003d1c:	0001c517          	auipc	a0,0x1c
    80003d20:	ee450513          	addi	a0,a0,-284 # 8001fc00 <log>
    80003d24:	f69fc0ef          	jal	80000c8c <release>
}
    80003d28:	60e2                	ld	ra,24(sp)
    80003d2a:	6442                	ld	s0,16(sp)
    80003d2c:	64a2                	ld	s1,8(sp)
    80003d2e:	6902                	ld	s2,0(sp)
    80003d30:	6105                	addi	sp,sp,32
    80003d32:	8082                	ret

0000000080003d34 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d34:	1101                	addi	sp,sp,-32
    80003d36:	ec06                	sd	ra,24(sp)
    80003d38:	e822                	sd	s0,16(sp)
    80003d3a:	e426                	sd	s1,8(sp)
    80003d3c:	e04a                	sd	s2,0(sp)
    80003d3e:	1000                	addi	s0,sp,32
    80003d40:	84aa                	mv	s1,a0
    80003d42:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d44:	00004597          	auipc	a1,0x4
    80003d48:	86458593          	addi	a1,a1,-1948 # 800075a8 <etext+0x5a8>
    80003d4c:	0521                	addi	a0,a0,8
    80003d4e:	e27fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003d52:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d56:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d5a:	0204a423          	sw	zero,40(s1)
}
    80003d5e:	60e2                	ld	ra,24(sp)
    80003d60:	6442                	ld	s0,16(sp)
    80003d62:	64a2                	ld	s1,8(sp)
    80003d64:	6902                	ld	s2,0(sp)
    80003d66:	6105                	addi	sp,sp,32
    80003d68:	8082                	ret

0000000080003d6a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d6a:	1101                	addi	sp,sp,-32
    80003d6c:	ec06                	sd	ra,24(sp)
    80003d6e:	e822                	sd	s0,16(sp)
    80003d70:	e426                	sd	s1,8(sp)
    80003d72:	e04a                	sd	s2,0(sp)
    80003d74:	1000                	addi	s0,sp,32
    80003d76:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d78:	00850913          	addi	s2,a0,8
    80003d7c:	854a                	mv	a0,s2
    80003d7e:	e77fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003d82:	409c                	lw	a5,0(s1)
    80003d84:	c799                	beqz	a5,80003d92 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d86:	85ca                	mv	a1,s2
    80003d88:	8526                	mv	a0,s1
    80003d8a:	9aefe0ef          	jal	80001f38 <sleep>
  while (lk->locked) {
    80003d8e:	409c                	lw	a5,0(s1)
    80003d90:	fbfd                	bnez	a5,80003d86 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003d92:	4785                	li	a5,1
    80003d94:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003d96:	b4bfd0ef          	jal	800018e0 <myproc>
    80003d9a:	591c                	lw	a5,48(a0)
    80003d9c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003d9e:	854a                	mv	a0,s2
    80003da0:	eedfc0ef          	jal	80000c8c <release>
}
    80003da4:	60e2                	ld	ra,24(sp)
    80003da6:	6442                	ld	s0,16(sp)
    80003da8:	64a2                	ld	s1,8(sp)
    80003daa:	6902                	ld	s2,0(sp)
    80003dac:	6105                	addi	sp,sp,32
    80003dae:	8082                	ret

0000000080003db0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003db0:	1101                	addi	sp,sp,-32
    80003db2:	ec06                	sd	ra,24(sp)
    80003db4:	e822                	sd	s0,16(sp)
    80003db6:	e426                	sd	s1,8(sp)
    80003db8:	e04a                	sd	s2,0(sp)
    80003dba:	1000                	addi	s0,sp,32
    80003dbc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dbe:	00850913          	addi	s2,a0,8
    80003dc2:	854a                	mv	a0,s2
    80003dc4:	e31fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003dc8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003dcc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003dd0:	8526                	mv	a0,s1
    80003dd2:	9b2fe0ef          	jal	80001f84 <wakeup>
  release(&lk->lk);
    80003dd6:	854a                	mv	a0,s2
    80003dd8:	eb5fc0ef          	jal	80000c8c <release>
}
    80003ddc:	60e2                	ld	ra,24(sp)
    80003dde:	6442                	ld	s0,16(sp)
    80003de0:	64a2                	ld	s1,8(sp)
    80003de2:	6902                	ld	s2,0(sp)
    80003de4:	6105                	addi	sp,sp,32
    80003de6:	8082                	ret

0000000080003de8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003de8:	7179                	addi	sp,sp,-48
    80003dea:	f406                	sd	ra,40(sp)
    80003dec:	f022                	sd	s0,32(sp)
    80003dee:	ec26                	sd	s1,24(sp)
    80003df0:	e84a                	sd	s2,16(sp)
    80003df2:	1800                	addi	s0,sp,48
    80003df4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003df6:	00850913          	addi	s2,a0,8
    80003dfa:	854a                	mv	a0,s2
    80003dfc:	df9fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e00:	409c                	lw	a5,0(s1)
    80003e02:	ef81                	bnez	a5,80003e1a <holdingsleep+0x32>
    80003e04:	4481                	li	s1,0
  release(&lk->lk);
    80003e06:	854a                	mv	a0,s2
    80003e08:	e85fc0ef          	jal	80000c8c <release>
  return r;
}
    80003e0c:	8526                	mv	a0,s1
    80003e0e:	70a2                	ld	ra,40(sp)
    80003e10:	7402                	ld	s0,32(sp)
    80003e12:	64e2                	ld	s1,24(sp)
    80003e14:	6942                	ld	s2,16(sp)
    80003e16:	6145                	addi	sp,sp,48
    80003e18:	8082                	ret
    80003e1a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e1c:	0284a983          	lw	s3,40(s1)
    80003e20:	ac1fd0ef          	jal	800018e0 <myproc>
    80003e24:	5904                	lw	s1,48(a0)
    80003e26:	413484b3          	sub	s1,s1,s3
    80003e2a:	0014b493          	seqz	s1,s1
    80003e2e:	69a2                	ld	s3,8(sp)
    80003e30:	bfd9                	j	80003e06 <holdingsleep+0x1e>

0000000080003e32 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e32:	1141                	addi	sp,sp,-16
    80003e34:	e406                	sd	ra,8(sp)
    80003e36:	e022                	sd	s0,0(sp)
    80003e38:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e3a:	00003597          	auipc	a1,0x3
    80003e3e:	77e58593          	addi	a1,a1,1918 # 800075b8 <etext+0x5b8>
    80003e42:	0001c517          	auipc	a0,0x1c
    80003e46:	f0650513          	addi	a0,a0,-250 # 8001fd48 <ftable>
    80003e4a:	d2bfc0ef          	jal	80000b74 <initlock>
}
    80003e4e:	60a2                	ld	ra,8(sp)
    80003e50:	6402                	ld	s0,0(sp)
    80003e52:	0141                	addi	sp,sp,16
    80003e54:	8082                	ret

0000000080003e56 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e56:	1101                	addi	sp,sp,-32
    80003e58:	ec06                	sd	ra,24(sp)
    80003e5a:	e822                	sd	s0,16(sp)
    80003e5c:	e426                	sd	s1,8(sp)
    80003e5e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e60:	0001c517          	auipc	a0,0x1c
    80003e64:	ee850513          	addi	a0,a0,-280 # 8001fd48 <ftable>
    80003e68:	d8dfc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e6c:	0001c497          	auipc	s1,0x1c
    80003e70:	ef448493          	addi	s1,s1,-268 # 8001fd60 <ftable+0x18>
    80003e74:	0001d717          	auipc	a4,0x1d
    80003e78:	e8c70713          	addi	a4,a4,-372 # 80020d00 <disk>
    if(f->ref == 0){
    80003e7c:	40dc                	lw	a5,4(s1)
    80003e7e:	cf89                	beqz	a5,80003e98 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e80:	02848493          	addi	s1,s1,40
    80003e84:	fee49ce3          	bne	s1,a4,80003e7c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e88:	0001c517          	auipc	a0,0x1c
    80003e8c:	ec050513          	addi	a0,a0,-320 # 8001fd48 <ftable>
    80003e90:	dfdfc0ef          	jal	80000c8c <release>
  return 0;
    80003e94:	4481                	li	s1,0
    80003e96:	a809                	j	80003ea8 <filealloc+0x52>
      f->ref = 1;
    80003e98:	4785                	li	a5,1
    80003e9a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003e9c:	0001c517          	auipc	a0,0x1c
    80003ea0:	eac50513          	addi	a0,a0,-340 # 8001fd48 <ftable>
    80003ea4:	de9fc0ef          	jal	80000c8c <release>
}
    80003ea8:	8526                	mv	a0,s1
    80003eaa:	60e2                	ld	ra,24(sp)
    80003eac:	6442                	ld	s0,16(sp)
    80003eae:	64a2                	ld	s1,8(sp)
    80003eb0:	6105                	addi	sp,sp,32
    80003eb2:	8082                	ret

0000000080003eb4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003eb4:	1101                	addi	sp,sp,-32
    80003eb6:	ec06                	sd	ra,24(sp)
    80003eb8:	e822                	sd	s0,16(sp)
    80003eba:	e426                	sd	s1,8(sp)
    80003ebc:	1000                	addi	s0,sp,32
    80003ebe:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ec0:	0001c517          	auipc	a0,0x1c
    80003ec4:	e8850513          	addi	a0,a0,-376 # 8001fd48 <ftable>
    80003ec8:	d2dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003ecc:	40dc                	lw	a5,4(s1)
    80003ece:	02f05063          	blez	a5,80003eee <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003ed2:	2785                	addiw	a5,a5,1
    80003ed4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003ed6:	0001c517          	auipc	a0,0x1c
    80003eda:	e7250513          	addi	a0,a0,-398 # 8001fd48 <ftable>
    80003ede:	daffc0ef          	jal	80000c8c <release>
  return f;
}
    80003ee2:	8526                	mv	a0,s1
    80003ee4:	60e2                	ld	ra,24(sp)
    80003ee6:	6442                	ld	s0,16(sp)
    80003ee8:	64a2                	ld	s1,8(sp)
    80003eea:	6105                	addi	sp,sp,32
    80003eec:	8082                	ret
    panic("filedup");
    80003eee:	00003517          	auipc	a0,0x3
    80003ef2:	6d250513          	addi	a0,a0,1746 # 800075c0 <etext+0x5c0>
    80003ef6:	89ffc0ef          	jal	80000794 <panic>

0000000080003efa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003efa:	7139                	addi	sp,sp,-64
    80003efc:	fc06                	sd	ra,56(sp)
    80003efe:	f822                	sd	s0,48(sp)
    80003f00:	f426                	sd	s1,40(sp)
    80003f02:	0080                	addi	s0,sp,64
    80003f04:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f06:	0001c517          	auipc	a0,0x1c
    80003f0a:	e4250513          	addi	a0,a0,-446 # 8001fd48 <ftable>
    80003f0e:	ce7fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f12:	40dc                	lw	a5,4(s1)
    80003f14:	04f05a63          	blez	a5,80003f68 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003f18:	37fd                	addiw	a5,a5,-1
    80003f1a:	0007871b          	sext.w	a4,a5
    80003f1e:	c0dc                	sw	a5,4(s1)
    80003f20:	04e04e63          	bgtz	a4,80003f7c <fileclose+0x82>
    80003f24:	f04a                	sd	s2,32(sp)
    80003f26:	ec4e                	sd	s3,24(sp)
    80003f28:	e852                	sd	s4,16(sp)
    80003f2a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f2c:	0004a903          	lw	s2,0(s1)
    80003f30:	0094ca83          	lbu	s5,9(s1)
    80003f34:	0104ba03          	ld	s4,16(s1)
    80003f38:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f3c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f40:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f44:	0001c517          	auipc	a0,0x1c
    80003f48:	e0450513          	addi	a0,a0,-508 # 8001fd48 <ftable>
    80003f4c:	d41fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003f50:	4785                	li	a5,1
    80003f52:	04f90063          	beq	s2,a5,80003f92 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f56:	3979                	addiw	s2,s2,-2
    80003f58:	4785                	li	a5,1
    80003f5a:	0527f563          	bgeu	a5,s2,80003fa4 <fileclose+0xaa>
    80003f5e:	7902                	ld	s2,32(sp)
    80003f60:	69e2                	ld	s3,24(sp)
    80003f62:	6a42                	ld	s4,16(sp)
    80003f64:	6aa2                	ld	s5,8(sp)
    80003f66:	a00d                	j	80003f88 <fileclose+0x8e>
    80003f68:	f04a                	sd	s2,32(sp)
    80003f6a:	ec4e                	sd	s3,24(sp)
    80003f6c:	e852                	sd	s4,16(sp)
    80003f6e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003f70:	00003517          	auipc	a0,0x3
    80003f74:	65850513          	addi	a0,a0,1624 # 800075c8 <etext+0x5c8>
    80003f78:	81dfc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80003f7c:	0001c517          	auipc	a0,0x1c
    80003f80:	dcc50513          	addi	a0,a0,-564 # 8001fd48 <ftable>
    80003f84:	d09fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f88:	70e2                	ld	ra,56(sp)
    80003f8a:	7442                	ld	s0,48(sp)
    80003f8c:	74a2                	ld	s1,40(sp)
    80003f8e:	6121                	addi	sp,sp,64
    80003f90:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003f92:	85d6                	mv	a1,s5
    80003f94:	8552                	mv	a0,s4
    80003f96:	336000ef          	jal	800042cc <pipeclose>
    80003f9a:	7902                	ld	s2,32(sp)
    80003f9c:	69e2                	ld	s3,24(sp)
    80003f9e:	6a42                	ld	s4,16(sp)
    80003fa0:	6aa2                	ld	s5,8(sp)
    80003fa2:	b7dd                	j	80003f88 <fileclose+0x8e>
    begin_op();
    80003fa4:	b3dff0ef          	jal	80003ae0 <begin_op>
    iput(ff.ip);
    80003fa8:	854e                	mv	a0,s3
    80003faa:	c22ff0ef          	jal	800033cc <iput>
    end_op();
    80003fae:	b9dff0ef          	jal	80003b4a <end_op>
    80003fb2:	7902                	ld	s2,32(sp)
    80003fb4:	69e2                	ld	s3,24(sp)
    80003fb6:	6a42                	ld	s4,16(sp)
    80003fb8:	6aa2                	ld	s5,8(sp)
    80003fba:	b7f9                	j	80003f88 <fileclose+0x8e>

0000000080003fbc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003fbc:	715d                	addi	sp,sp,-80
    80003fbe:	e486                	sd	ra,72(sp)
    80003fc0:	e0a2                	sd	s0,64(sp)
    80003fc2:	fc26                	sd	s1,56(sp)
    80003fc4:	f44e                	sd	s3,40(sp)
    80003fc6:	0880                	addi	s0,sp,80
    80003fc8:	84aa                	mv	s1,a0
    80003fca:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003fcc:	915fd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003fd0:	409c                	lw	a5,0(s1)
    80003fd2:	37f9                	addiw	a5,a5,-2
    80003fd4:	4705                	li	a4,1
    80003fd6:	04f76063          	bltu	a4,a5,80004016 <filestat+0x5a>
    80003fda:	f84a                	sd	s2,48(sp)
    80003fdc:	892a                	mv	s2,a0
    ilock(f->ip);
    80003fde:	6c88                	ld	a0,24(s1)
    80003fe0:	a6aff0ef          	jal	8000324a <ilock>
    stati(f->ip, &st);
    80003fe4:	fb840593          	addi	a1,s0,-72
    80003fe8:	6c88                	ld	a0,24(s1)
    80003fea:	c8aff0ef          	jal	80003474 <stati>
    iunlock(f->ip);
    80003fee:	6c88                	ld	a0,24(s1)
    80003ff0:	b08ff0ef          	jal	800032f8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003ff4:	46e1                	li	a3,24
    80003ff6:	fb840613          	addi	a2,s0,-72
    80003ffa:	85ce                	mv	a1,s3
    80003ffc:	05893503          	ld	a0,88(s2)
    80004000:	d52fd0ef          	jal	80001552 <copyout>
    80004004:	41f5551b          	sraiw	a0,a0,0x1f
    80004008:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000400a:	60a6                	ld	ra,72(sp)
    8000400c:	6406                	ld	s0,64(sp)
    8000400e:	74e2                	ld	s1,56(sp)
    80004010:	79a2                	ld	s3,40(sp)
    80004012:	6161                	addi	sp,sp,80
    80004014:	8082                	ret
  return -1;
    80004016:	557d                	li	a0,-1
    80004018:	bfcd                	j	8000400a <filestat+0x4e>

000000008000401a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000401a:	7179                	addi	sp,sp,-48
    8000401c:	f406                	sd	ra,40(sp)
    8000401e:	f022                	sd	s0,32(sp)
    80004020:	e84a                	sd	s2,16(sp)
    80004022:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004024:	00854783          	lbu	a5,8(a0)
    80004028:	cfd1                	beqz	a5,800040c4 <fileread+0xaa>
    8000402a:	ec26                	sd	s1,24(sp)
    8000402c:	e44e                	sd	s3,8(sp)
    8000402e:	84aa                	mv	s1,a0
    80004030:	89ae                	mv	s3,a1
    80004032:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004034:	411c                	lw	a5,0(a0)
    80004036:	4705                	li	a4,1
    80004038:	04e78363          	beq	a5,a4,8000407e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000403c:	470d                	li	a4,3
    8000403e:	04e78763          	beq	a5,a4,8000408c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004042:	4709                	li	a4,2
    80004044:	06e79a63          	bne	a5,a4,800040b8 <fileread+0x9e>
    ilock(f->ip);
    80004048:	6d08                	ld	a0,24(a0)
    8000404a:	a00ff0ef          	jal	8000324a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000404e:	874a                	mv	a4,s2
    80004050:	5094                	lw	a3,32(s1)
    80004052:	864e                	mv	a2,s3
    80004054:	4585                	li	a1,1
    80004056:	6c88                	ld	a0,24(s1)
    80004058:	c46ff0ef          	jal	8000349e <readi>
    8000405c:	892a                	mv	s2,a0
    8000405e:	00a05563          	blez	a0,80004068 <fileread+0x4e>
      f->off += r;
    80004062:	509c                	lw	a5,32(s1)
    80004064:	9fa9                	addw	a5,a5,a0
    80004066:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004068:	6c88                	ld	a0,24(s1)
    8000406a:	a8eff0ef          	jal	800032f8 <iunlock>
    8000406e:	64e2                	ld	s1,24(sp)
    80004070:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004072:	854a                	mv	a0,s2
    80004074:	70a2                	ld	ra,40(sp)
    80004076:	7402                	ld	s0,32(sp)
    80004078:	6942                	ld	s2,16(sp)
    8000407a:	6145                	addi	sp,sp,48
    8000407c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000407e:	6908                	ld	a0,16(a0)
    80004080:	388000ef          	jal	80004408 <piperead>
    80004084:	892a                	mv	s2,a0
    80004086:	64e2                	ld	s1,24(sp)
    80004088:	69a2                	ld	s3,8(sp)
    8000408a:	b7e5                	j	80004072 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000408c:	02451783          	lh	a5,36(a0)
    80004090:	03079693          	slli	a3,a5,0x30
    80004094:	92c1                	srli	a3,a3,0x30
    80004096:	4725                	li	a4,9
    80004098:	02d76863          	bltu	a4,a3,800040c8 <fileread+0xae>
    8000409c:	0792                	slli	a5,a5,0x4
    8000409e:	0001c717          	auipc	a4,0x1c
    800040a2:	c0a70713          	addi	a4,a4,-1014 # 8001fca8 <devsw>
    800040a6:	97ba                	add	a5,a5,a4
    800040a8:	639c                	ld	a5,0(a5)
    800040aa:	c39d                	beqz	a5,800040d0 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800040ac:	4505                	li	a0,1
    800040ae:	9782                	jalr	a5
    800040b0:	892a                	mv	s2,a0
    800040b2:	64e2                	ld	s1,24(sp)
    800040b4:	69a2                	ld	s3,8(sp)
    800040b6:	bf75                	j	80004072 <fileread+0x58>
    panic("fileread");
    800040b8:	00003517          	auipc	a0,0x3
    800040bc:	52050513          	addi	a0,a0,1312 # 800075d8 <etext+0x5d8>
    800040c0:	ed4fc0ef          	jal	80000794 <panic>
    return -1;
    800040c4:	597d                	li	s2,-1
    800040c6:	b775                	j	80004072 <fileread+0x58>
      return -1;
    800040c8:	597d                	li	s2,-1
    800040ca:	64e2                	ld	s1,24(sp)
    800040cc:	69a2                	ld	s3,8(sp)
    800040ce:	b755                	j	80004072 <fileread+0x58>
    800040d0:	597d                	li	s2,-1
    800040d2:	64e2                	ld	s1,24(sp)
    800040d4:	69a2                	ld	s3,8(sp)
    800040d6:	bf71                	j	80004072 <fileread+0x58>

00000000800040d8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800040d8:	00954783          	lbu	a5,9(a0)
    800040dc:	10078b63          	beqz	a5,800041f2 <filewrite+0x11a>
{
    800040e0:	715d                	addi	sp,sp,-80
    800040e2:	e486                	sd	ra,72(sp)
    800040e4:	e0a2                	sd	s0,64(sp)
    800040e6:	f84a                	sd	s2,48(sp)
    800040e8:	f052                	sd	s4,32(sp)
    800040ea:	e85a                	sd	s6,16(sp)
    800040ec:	0880                	addi	s0,sp,80
    800040ee:	892a                	mv	s2,a0
    800040f0:	8b2e                	mv	s6,a1
    800040f2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800040f4:	411c                	lw	a5,0(a0)
    800040f6:	4705                	li	a4,1
    800040f8:	02e78763          	beq	a5,a4,80004126 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800040fc:	470d                	li	a4,3
    800040fe:	02e78863          	beq	a5,a4,8000412e <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004102:	4709                	li	a4,2
    80004104:	0ce79c63          	bne	a5,a4,800041dc <filewrite+0x104>
    80004108:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000410a:	0ac05863          	blez	a2,800041ba <filewrite+0xe2>
    8000410e:	fc26                	sd	s1,56(sp)
    80004110:	ec56                	sd	s5,24(sp)
    80004112:	e45e                	sd	s7,8(sp)
    80004114:	e062                	sd	s8,0(sp)
    int i = 0;
    80004116:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004118:	6b85                	lui	s7,0x1
    8000411a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000411e:	6c05                	lui	s8,0x1
    80004120:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004124:	a8b5                	j	800041a0 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004126:	6908                	ld	a0,16(a0)
    80004128:	1fc000ef          	jal	80004324 <pipewrite>
    8000412c:	a04d                	j	800041ce <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000412e:	02451783          	lh	a5,36(a0)
    80004132:	03079693          	slli	a3,a5,0x30
    80004136:	92c1                	srli	a3,a3,0x30
    80004138:	4725                	li	a4,9
    8000413a:	0ad76e63          	bltu	a4,a3,800041f6 <filewrite+0x11e>
    8000413e:	0792                	slli	a5,a5,0x4
    80004140:	0001c717          	auipc	a4,0x1c
    80004144:	b6870713          	addi	a4,a4,-1176 # 8001fca8 <devsw>
    80004148:	97ba                	add	a5,a5,a4
    8000414a:	679c                	ld	a5,8(a5)
    8000414c:	c7dd                	beqz	a5,800041fa <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000414e:	4505                	li	a0,1
    80004150:	9782                	jalr	a5
    80004152:	a8b5                	j	800041ce <filewrite+0xf6>
      if(n1 > max)
    80004154:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004158:	989ff0ef          	jal	80003ae0 <begin_op>
      ilock(f->ip);
    8000415c:	01893503          	ld	a0,24(s2)
    80004160:	8eaff0ef          	jal	8000324a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004164:	8756                	mv	a4,s5
    80004166:	02092683          	lw	a3,32(s2)
    8000416a:	01698633          	add	a2,s3,s6
    8000416e:	4585                	li	a1,1
    80004170:	01893503          	ld	a0,24(s2)
    80004174:	c26ff0ef          	jal	8000359a <writei>
    80004178:	84aa                	mv	s1,a0
    8000417a:	00a05763          	blez	a0,80004188 <filewrite+0xb0>
        f->off += r;
    8000417e:	02092783          	lw	a5,32(s2)
    80004182:	9fa9                	addw	a5,a5,a0
    80004184:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004188:	01893503          	ld	a0,24(s2)
    8000418c:	96cff0ef          	jal	800032f8 <iunlock>
      end_op();
    80004190:	9bbff0ef          	jal	80003b4a <end_op>

      if(r != n1){
    80004194:	029a9563          	bne	s5,s1,800041be <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004198:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000419c:	0149da63          	bge	s3,s4,800041b0 <filewrite+0xd8>
      int n1 = n - i;
    800041a0:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800041a4:	0004879b          	sext.w	a5,s1
    800041a8:	fafbd6e3          	bge	s7,a5,80004154 <filewrite+0x7c>
    800041ac:	84e2                	mv	s1,s8
    800041ae:	b75d                	j	80004154 <filewrite+0x7c>
    800041b0:	74e2                	ld	s1,56(sp)
    800041b2:	6ae2                	ld	s5,24(sp)
    800041b4:	6ba2                	ld	s7,8(sp)
    800041b6:	6c02                	ld	s8,0(sp)
    800041b8:	a039                	j	800041c6 <filewrite+0xee>
    int i = 0;
    800041ba:	4981                	li	s3,0
    800041bc:	a029                	j	800041c6 <filewrite+0xee>
    800041be:	74e2                	ld	s1,56(sp)
    800041c0:	6ae2                	ld	s5,24(sp)
    800041c2:	6ba2                	ld	s7,8(sp)
    800041c4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800041c6:	033a1c63          	bne	s4,s3,800041fe <filewrite+0x126>
    800041ca:	8552                	mv	a0,s4
    800041cc:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800041ce:	60a6                	ld	ra,72(sp)
    800041d0:	6406                	ld	s0,64(sp)
    800041d2:	7942                	ld	s2,48(sp)
    800041d4:	7a02                	ld	s4,32(sp)
    800041d6:	6b42                	ld	s6,16(sp)
    800041d8:	6161                	addi	sp,sp,80
    800041da:	8082                	ret
    800041dc:	fc26                	sd	s1,56(sp)
    800041de:	f44e                	sd	s3,40(sp)
    800041e0:	ec56                	sd	s5,24(sp)
    800041e2:	e45e                	sd	s7,8(sp)
    800041e4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800041e6:	00003517          	auipc	a0,0x3
    800041ea:	40250513          	addi	a0,a0,1026 # 800075e8 <etext+0x5e8>
    800041ee:	da6fc0ef          	jal	80000794 <panic>
    return -1;
    800041f2:	557d                	li	a0,-1
}
    800041f4:	8082                	ret
      return -1;
    800041f6:	557d                	li	a0,-1
    800041f8:	bfd9                	j	800041ce <filewrite+0xf6>
    800041fa:	557d                	li	a0,-1
    800041fc:	bfc9                	j	800041ce <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800041fe:	557d                	li	a0,-1
    80004200:	79a2                	ld	s3,40(sp)
    80004202:	b7f1                	j	800041ce <filewrite+0xf6>

0000000080004204 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004204:	7179                	addi	sp,sp,-48
    80004206:	f406                	sd	ra,40(sp)
    80004208:	f022                	sd	s0,32(sp)
    8000420a:	ec26                	sd	s1,24(sp)
    8000420c:	e052                	sd	s4,0(sp)
    8000420e:	1800                	addi	s0,sp,48
    80004210:	84aa                	mv	s1,a0
    80004212:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004214:	0005b023          	sd	zero,0(a1)
    80004218:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000421c:	c3bff0ef          	jal	80003e56 <filealloc>
    80004220:	e088                	sd	a0,0(s1)
    80004222:	c549                	beqz	a0,800042ac <pipealloc+0xa8>
    80004224:	c33ff0ef          	jal	80003e56 <filealloc>
    80004228:	00aa3023          	sd	a0,0(s4)
    8000422c:	cd25                	beqz	a0,800042a4 <pipealloc+0xa0>
    8000422e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004230:	8f5fc0ef          	jal	80000b24 <kalloc>
    80004234:	892a                	mv	s2,a0
    80004236:	c12d                	beqz	a0,80004298 <pipealloc+0x94>
    80004238:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000423a:	4985                	li	s3,1
    8000423c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004240:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004244:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004248:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000424c:	00003597          	auipc	a1,0x3
    80004250:	3ac58593          	addi	a1,a1,940 # 800075f8 <etext+0x5f8>
    80004254:	921fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004258:	609c                	ld	a5,0(s1)
    8000425a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000425e:	609c                	ld	a5,0(s1)
    80004260:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004264:	609c                	ld	a5,0(s1)
    80004266:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000426a:	609c                	ld	a5,0(s1)
    8000426c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004270:	000a3783          	ld	a5,0(s4)
    80004274:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004278:	000a3783          	ld	a5,0(s4)
    8000427c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004280:	000a3783          	ld	a5,0(s4)
    80004284:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004288:	000a3783          	ld	a5,0(s4)
    8000428c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004290:	4501                	li	a0,0
    80004292:	6942                	ld	s2,16(sp)
    80004294:	69a2                	ld	s3,8(sp)
    80004296:	a01d                	j	800042bc <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004298:	6088                	ld	a0,0(s1)
    8000429a:	c119                	beqz	a0,800042a0 <pipealloc+0x9c>
    8000429c:	6942                	ld	s2,16(sp)
    8000429e:	a029                	j	800042a8 <pipealloc+0xa4>
    800042a0:	6942                	ld	s2,16(sp)
    800042a2:	a029                	j	800042ac <pipealloc+0xa8>
    800042a4:	6088                	ld	a0,0(s1)
    800042a6:	c10d                	beqz	a0,800042c8 <pipealloc+0xc4>
    fileclose(*f0);
    800042a8:	c53ff0ef          	jal	80003efa <fileclose>
  if(*f1)
    800042ac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800042b0:	557d                	li	a0,-1
  if(*f1)
    800042b2:	c789                	beqz	a5,800042bc <pipealloc+0xb8>
    fileclose(*f1);
    800042b4:	853e                	mv	a0,a5
    800042b6:	c45ff0ef          	jal	80003efa <fileclose>
  return -1;
    800042ba:	557d                	li	a0,-1
}
    800042bc:	70a2                	ld	ra,40(sp)
    800042be:	7402                	ld	s0,32(sp)
    800042c0:	64e2                	ld	s1,24(sp)
    800042c2:	6a02                	ld	s4,0(sp)
    800042c4:	6145                	addi	sp,sp,48
    800042c6:	8082                	ret
  return -1;
    800042c8:	557d                	li	a0,-1
    800042ca:	bfcd                	j	800042bc <pipealloc+0xb8>

00000000800042cc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800042cc:	1101                	addi	sp,sp,-32
    800042ce:	ec06                	sd	ra,24(sp)
    800042d0:	e822                	sd	s0,16(sp)
    800042d2:	e426                	sd	s1,8(sp)
    800042d4:	e04a                	sd	s2,0(sp)
    800042d6:	1000                	addi	s0,sp,32
    800042d8:	84aa                	mv	s1,a0
    800042da:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800042dc:	919fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    800042e0:	02090763          	beqz	s2,8000430e <pipeclose+0x42>
    pi->writeopen = 0;
    800042e4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800042e8:	21848513          	addi	a0,s1,536
    800042ec:	c99fd0ef          	jal	80001f84 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800042f0:	2204b783          	ld	a5,544(s1)
    800042f4:	e785                	bnez	a5,8000431c <pipeclose+0x50>
    release(&pi->lock);
    800042f6:	8526                	mv	a0,s1
    800042f8:	995fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    800042fc:	8526                	mv	a0,s1
    800042fe:	f44fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004302:	60e2                	ld	ra,24(sp)
    80004304:	6442                	ld	s0,16(sp)
    80004306:	64a2                	ld	s1,8(sp)
    80004308:	6902                	ld	s2,0(sp)
    8000430a:	6105                	addi	sp,sp,32
    8000430c:	8082                	ret
    pi->readopen = 0;
    8000430e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004312:	21c48513          	addi	a0,s1,540
    80004316:	c6ffd0ef          	jal	80001f84 <wakeup>
    8000431a:	bfd9                	j	800042f0 <pipeclose+0x24>
    release(&pi->lock);
    8000431c:	8526                	mv	a0,s1
    8000431e:	96ffc0ef          	jal	80000c8c <release>
}
    80004322:	b7c5                	j	80004302 <pipeclose+0x36>

0000000080004324 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004324:	711d                	addi	sp,sp,-96
    80004326:	ec86                	sd	ra,88(sp)
    80004328:	e8a2                	sd	s0,80(sp)
    8000432a:	e4a6                	sd	s1,72(sp)
    8000432c:	e0ca                	sd	s2,64(sp)
    8000432e:	fc4e                	sd	s3,56(sp)
    80004330:	f852                	sd	s4,48(sp)
    80004332:	f456                	sd	s5,40(sp)
    80004334:	1080                	addi	s0,sp,96
    80004336:	84aa                	mv	s1,a0
    80004338:	8aae                	mv	s5,a1
    8000433a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000433c:	da4fd0ef          	jal	800018e0 <myproc>
    80004340:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004342:	8526                	mv	a0,s1
    80004344:	8b1fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004348:	0b405a63          	blez	s4,800043fc <pipewrite+0xd8>
    8000434c:	f05a                	sd	s6,32(sp)
    8000434e:	ec5e                	sd	s7,24(sp)
    80004350:	e862                	sd	s8,16(sp)
  int i = 0;
    80004352:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004354:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004356:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000435a:	21c48b93          	addi	s7,s1,540
    8000435e:	a81d                	j	80004394 <pipewrite+0x70>
      release(&pi->lock);
    80004360:	8526                	mv	a0,s1
    80004362:	92bfc0ef          	jal	80000c8c <release>
      return -1;
    80004366:	597d                	li	s2,-1
    80004368:	7b02                	ld	s6,32(sp)
    8000436a:	6be2                	ld	s7,24(sp)
    8000436c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000436e:	854a                	mv	a0,s2
    80004370:	60e6                	ld	ra,88(sp)
    80004372:	6446                	ld	s0,80(sp)
    80004374:	64a6                	ld	s1,72(sp)
    80004376:	6906                	ld	s2,64(sp)
    80004378:	79e2                	ld	s3,56(sp)
    8000437a:	7a42                	ld	s4,48(sp)
    8000437c:	7aa2                	ld	s5,40(sp)
    8000437e:	6125                	addi	sp,sp,96
    80004380:	8082                	ret
      wakeup(&pi->nread);
    80004382:	8562                	mv	a0,s8
    80004384:	c01fd0ef          	jal	80001f84 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004388:	85a6                	mv	a1,s1
    8000438a:	855e                	mv	a0,s7
    8000438c:	badfd0ef          	jal	80001f38 <sleep>
  while(i < n){
    80004390:	05495b63          	bge	s2,s4,800043e6 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004394:	2204a783          	lw	a5,544(s1)
    80004398:	d7e1                	beqz	a5,80004360 <pipewrite+0x3c>
    8000439a:	854e                	mv	a0,s3
    8000439c:	dd5fd0ef          	jal	80002170 <killed>
    800043a0:	f161                	bnez	a0,80004360 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800043a2:	2184a783          	lw	a5,536(s1)
    800043a6:	21c4a703          	lw	a4,540(s1)
    800043aa:	2007879b          	addiw	a5,a5,512
    800043ae:	fcf70ae3          	beq	a4,a5,80004382 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043b2:	4685                	li	a3,1
    800043b4:	01590633          	add	a2,s2,s5
    800043b8:	faf40593          	addi	a1,s0,-81
    800043bc:	0589b503          	ld	a0,88(s3)
    800043c0:	a68fd0ef          	jal	80001628 <copyin>
    800043c4:	03650e63          	beq	a0,s6,80004400 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800043c8:	21c4a783          	lw	a5,540(s1)
    800043cc:	0017871b          	addiw	a4,a5,1
    800043d0:	20e4ae23          	sw	a4,540(s1)
    800043d4:	1ff7f793          	andi	a5,a5,511
    800043d8:	97a6                	add	a5,a5,s1
    800043da:	faf44703          	lbu	a4,-81(s0)
    800043de:	00e78c23          	sb	a4,24(a5)
      i++;
    800043e2:	2905                	addiw	s2,s2,1
    800043e4:	b775                	j	80004390 <pipewrite+0x6c>
    800043e6:	7b02                	ld	s6,32(sp)
    800043e8:	6be2                	ld	s7,24(sp)
    800043ea:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800043ec:	21848513          	addi	a0,s1,536
    800043f0:	b95fd0ef          	jal	80001f84 <wakeup>
  release(&pi->lock);
    800043f4:	8526                	mv	a0,s1
    800043f6:	897fc0ef          	jal	80000c8c <release>
  return i;
    800043fa:	bf95                	j	8000436e <pipewrite+0x4a>
  int i = 0;
    800043fc:	4901                	li	s2,0
    800043fe:	b7fd                	j	800043ec <pipewrite+0xc8>
    80004400:	7b02                	ld	s6,32(sp)
    80004402:	6be2                	ld	s7,24(sp)
    80004404:	6c42                	ld	s8,16(sp)
    80004406:	b7dd                	j	800043ec <pipewrite+0xc8>

0000000080004408 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004408:	715d                	addi	sp,sp,-80
    8000440a:	e486                	sd	ra,72(sp)
    8000440c:	e0a2                	sd	s0,64(sp)
    8000440e:	fc26                	sd	s1,56(sp)
    80004410:	f84a                	sd	s2,48(sp)
    80004412:	f44e                	sd	s3,40(sp)
    80004414:	f052                	sd	s4,32(sp)
    80004416:	ec56                	sd	s5,24(sp)
    80004418:	0880                	addi	s0,sp,80
    8000441a:	84aa                	mv	s1,a0
    8000441c:	892e                	mv	s2,a1
    8000441e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004420:	cc0fd0ef          	jal	800018e0 <myproc>
    80004424:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004426:	8526                	mv	a0,s1
    80004428:	fccfc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000442c:	2184a703          	lw	a4,536(s1)
    80004430:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004434:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004438:	02f71563          	bne	a4,a5,80004462 <piperead+0x5a>
    8000443c:	2244a783          	lw	a5,548(s1)
    80004440:	cb85                	beqz	a5,80004470 <piperead+0x68>
    if(killed(pr)){
    80004442:	8552                	mv	a0,s4
    80004444:	d2dfd0ef          	jal	80002170 <killed>
    80004448:	ed19                	bnez	a0,80004466 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000444a:	85a6                	mv	a1,s1
    8000444c:	854e                	mv	a0,s3
    8000444e:	aebfd0ef          	jal	80001f38 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004452:	2184a703          	lw	a4,536(s1)
    80004456:	21c4a783          	lw	a5,540(s1)
    8000445a:	fef701e3          	beq	a4,a5,8000443c <piperead+0x34>
    8000445e:	e85a                	sd	s6,16(sp)
    80004460:	a809                	j	80004472 <piperead+0x6a>
    80004462:	e85a                	sd	s6,16(sp)
    80004464:	a039                	j	80004472 <piperead+0x6a>
      release(&pi->lock);
    80004466:	8526                	mv	a0,s1
    80004468:	825fc0ef          	jal	80000c8c <release>
      return -1;
    8000446c:	59fd                	li	s3,-1
    8000446e:	a8b1                	j	800044ca <piperead+0xc2>
    80004470:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004472:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004474:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004476:	05505263          	blez	s5,800044ba <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000447a:	2184a783          	lw	a5,536(s1)
    8000447e:	21c4a703          	lw	a4,540(s1)
    80004482:	02f70c63          	beq	a4,a5,800044ba <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004486:	0017871b          	addiw	a4,a5,1
    8000448a:	20e4ac23          	sw	a4,536(s1)
    8000448e:	1ff7f793          	andi	a5,a5,511
    80004492:	97a6                	add	a5,a5,s1
    80004494:	0187c783          	lbu	a5,24(a5)
    80004498:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000449c:	4685                	li	a3,1
    8000449e:	fbf40613          	addi	a2,s0,-65
    800044a2:	85ca                	mv	a1,s2
    800044a4:	058a3503          	ld	a0,88(s4)
    800044a8:	8aafd0ef          	jal	80001552 <copyout>
    800044ac:	01650763          	beq	a0,s6,800044ba <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044b0:	2985                	addiw	s3,s3,1
    800044b2:	0905                	addi	s2,s2,1
    800044b4:	fd3a93e3          	bne	s5,s3,8000447a <piperead+0x72>
    800044b8:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800044ba:	21c48513          	addi	a0,s1,540
    800044be:	ac7fd0ef          	jal	80001f84 <wakeup>
  release(&pi->lock);
    800044c2:	8526                	mv	a0,s1
    800044c4:	fc8fc0ef          	jal	80000c8c <release>
    800044c8:	6b42                	ld	s6,16(sp)
  return i;
}
    800044ca:	854e                	mv	a0,s3
    800044cc:	60a6                	ld	ra,72(sp)
    800044ce:	6406                	ld	s0,64(sp)
    800044d0:	74e2                	ld	s1,56(sp)
    800044d2:	7942                	ld	s2,48(sp)
    800044d4:	79a2                	ld	s3,40(sp)
    800044d6:	7a02                	ld	s4,32(sp)
    800044d8:	6ae2                	ld	s5,24(sp)
    800044da:	6161                	addi	sp,sp,80
    800044dc:	8082                	ret

00000000800044de <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800044de:	1141                	addi	sp,sp,-16
    800044e0:	e422                	sd	s0,8(sp)
    800044e2:	0800                	addi	s0,sp,16
    800044e4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800044e6:	8905                	andi	a0,a0,1
    800044e8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800044ea:	8b89                	andi	a5,a5,2
    800044ec:	c399                	beqz	a5,800044f2 <flags2perm+0x14>
      perm |= PTE_W;
    800044ee:	00456513          	ori	a0,a0,4
    return perm;
}
    800044f2:	6422                	ld	s0,8(sp)
    800044f4:	0141                	addi	sp,sp,16
    800044f6:	8082                	ret

00000000800044f8 <exec>:

int
exec(char *path, char **argv)
{
    800044f8:	df010113          	addi	sp,sp,-528
    800044fc:	20113423          	sd	ra,520(sp)
    80004500:	20813023          	sd	s0,512(sp)
    80004504:	ffa6                	sd	s1,504(sp)
    80004506:	fbca                	sd	s2,496(sp)
    80004508:	0c00                	addi	s0,sp,528
    8000450a:	892a                	mv	s2,a0
    8000450c:	dea43c23          	sd	a0,-520(s0)
    80004510:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004514:	bccfd0ef          	jal	800018e0 <myproc>
    80004518:	84aa                	mv	s1,a0

  begin_op();
    8000451a:	dc6ff0ef          	jal	80003ae0 <begin_op>

  if((ip = namei(path)) == 0){
    8000451e:	854a                	mv	a0,s2
    80004520:	c04ff0ef          	jal	80003924 <namei>
    80004524:	c931                	beqz	a0,80004578 <exec+0x80>
    80004526:	f3d2                	sd	s4,480(sp)
    80004528:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000452a:	d21fe0ef          	jal	8000324a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000452e:	04000713          	li	a4,64
    80004532:	4681                	li	a3,0
    80004534:	e5040613          	addi	a2,s0,-432
    80004538:	4581                	li	a1,0
    8000453a:	8552                	mv	a0,s4
    8000453c:	f63fe0ef          	jal	8000349e <readi>
    80004540:	04000793          	li	a5,64
    80004544:	00f51a63          	bne	a0,a5,80004558 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004548:	e5042703          	lw	a4,-432(s0)
    8000454c:	464c47b7          	lui	a5,0x464c4
    80004550:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004554:	02f70663          	beq	a4,a5,80004580 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004558:	8552                	mv	a0,s4
    8000455a:	efbfe0ef          	jal	80003454 <iunlockput>
    end_op();
    8000455e:	decff0ef          	jal	80003b4a <end_op>
  }
  return -1;
    80004562:	557d                	li	a0,-1
    80004564:	7a1e                	ld	s4,480(sp)
}
    80004566:	20813083          	ld	ra,520(sp)
    8000456a:	20013403          	ld	s0,512(sp)
    8000456e:	74fe                	ld	s1,504(sp)
    80004570:	795e                	ld	s2,496(sp)
    80004572:	21010113          	addi	sp,sp,528
    80004576:	8082                	ret
    end_op();
    80004578:	dd2ff0ef          	jal	80003b4a <end_op>
    return -1;
    8000457c:	557d                	li	a0,-1
    8000457e:	b7e5                	j	80004566 <exec+0x6e>
    80004580:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004582:	8526                	mv	a0,s1
    80004584:	c04fd0ef          	jal	80001988 <proc_pagetable>
    80004588:	8b2a                	mv	s6,a0
    8000458a:	2c050b63          	beqz	a0,80004860 <exec+0x368>
    8000458e:	f7ce                	sd	s3,488(sp)
    80004590:	efd6                	sd	s5,472(sp)
    80004592:	e7de                	sd	s7,456(sp)
    80004594:	e3e2                	sd	s8,448(sp)
    80004596:	ff66                	sd	s9,440(sp)
    80004598:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000459a:	e7042d03          	lw	s10,-400(s0)
    8000459e:	e8845783          	lhu	a5,-376(s0)
    800045a2:	12078963          	beqz	a5,800046d4 <exec+0x1dc>
    800045a6:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045a8:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045aa:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800045ac:	6c85                	lui	s9,0x1
    800045ae:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800045b2:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800045b6:	6a85                	lui	s5,0x1
    800045b8:	a085                	j	80004618 <exec+0x120>
      panic("loadseg: address should exist");
    800045ba:	00003517          	auipc	a0,0x3
    800045be:	04650513          	addi	a0,a0,70 # 80007600 <etext+0x600>
    800045c2:	9d2fc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    800045c6:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800045c8:	8726                	mv	a4,s1
    800045ca:	012c06bb          	addw	a3,s8,s2
    800045ce:	4581                	li	a1,0
    800045d0:	8552                	mv	a0,s4
    800045d2:	ecdfe0ef          	jal	8000349e <readi>
    800045d6:	2501                	sext.w	a0,a0
    800045d8:	24a49a63          	bne	s1,a0,8000482c <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800045dc:	012a893b          	addw	s2,s5,s2
    800045e0:	03397363          	bgeu	s2,s3,80004606 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800045e4:	02091593          	slli	a1,s2,0x20
    800045e8:	9181                	srli	a1,a1,0x20
    800045ea:	95de                	add	a1,a1,s7
    800045ec:	855a                	mv	a0,s6
    800045ee:	9e9fc0ef          	jal	80000fd6 <walkaddr>
    800045f2:	862a                	mv	a2,a0
    if(pa == 0)
    800045f4:	d179                	beqz	a0,800045ba <exec+0xc2>
    if(sz - i < PGSIZE)
    800045f6:	412984bb          	subw	s1,s3,s2
    800045fa:	0004879b          	sext.w	a5,s1
    800045fe:	fcfcf4e3          	bgeu	s9,a5,800045c6 <exec+0xce>
    80004602:	84d6                	mv	s1,s5
    80004604:	b7c9                	j	800045c6 <exec+0xce>
    sz = sz1;
    80004606:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000460a:	2d85                	addiw	s11,s11,1
    8000460c:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004610:	e8845783          	lhu	a5,-376(s0)
    80004614:	08fdd063          	bge	s11,a5,80004694 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004618:	2d01                	sext.w	s10,s10
    8000461a:	03800713          	li	a4,56
    8000461e:	86ea                	mv	a3,s10
    80004620:	e1840613          	addi	a2,s0,-488
    80004624:	4581                	li	a1,0
    80004626:	8552                	mv	a0,s4
    80004628:	e77fe0ef          	jal	8000349e <readi>
    8000462c:	03800793          	li	a5,56
    80004630:	1cf51663          	bne	a0,a5,800047fc <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004634:	e1842783          	lw	a5,-488(s0)
    80004638:	4705                	li	a4,1
    8000463a:	fce798e3          	bne	a5,a4,8000460a <exec+0x112>
    if(ph.memsz < ph.filesz)
    8000463e:	e4043483          	ld	s1,-448(s0)
    80004642:	e3843783          	ld	a5,-456(s0)
    80004646:	1af4ef63          	bltu	s1,a5,80004804 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000464a:	e2843783          	ld	a5,-472(s0)
    8000464e:	94be                	add	s1,s1,a5
    80004650:	1af4ee63          	bltu	s1,a5,8000480c <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004654:	df043703          	ld	a4,-528(s0)
    80004658:	8ff9                	and	a5,a5,a4
    8000465a:	1a079d63          	bnez	a5,80004814 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000465e:	e1c42503          	lw	a0,-484(s0)
    80004662:	e7dff0ef          	jal	800044de <flags2perm>
    80004666:	86aa                	mv	a3,a0
    80004668:	8626                	mv	a2,s1
    8000466a:	85ca                	mv	a1,s2
    8000466c:	855a                	mv	a0,s6
    8000466e:	cd1fc0ef          	jal	8000133e <uvmalloc>
    80004672:	e0a43423          	sd	a0,-504(s0)
    80004676:	1a050363          	beqz	a0,8000481c <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000467a:	e2843b83          	ld	s7,-472(s0)
    8000467e:	e2042c03          	lw	s8,-480(s0)
    80004682:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004686:	00098463          	beqz	s3,8000468e <exec+0x196>
    8000468a:	4901                	li	s2,0
    8000468c:	bfa1                	j	800045e4 <exec+0xec>
    sz = sz1;
    8000468e:	e0843903          	ld	s2,-504(s0)
    80004692:	bfa5                	j	8000460a <exec+0x112>
    80004694:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004696:	8552                	mv	a0,s4
    80004698:	dbdfe0ef          	jal	80003454 <iunlockput>
  end_op();
    8000469c:	caeff0ef          	jal	80003b4a <end_op>
  p = myproc();
    800046a0:	a40fd0ef          	jal	800018e0 <myproc>
    800046a4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800046a6:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    800046aa:	6985                	lui	s3,0x1
    800046ac:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800046ae:	99ca                	add	s3,s3,s2
    800046b0:	77fd                	lui	a5,0xfffff
    800046b2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800046b6:	4691                	li	a3,4
    800046b8:	6609                	lui	a2,0x2
    800046ba:	964e                	add	a2,a2,s3
    800046bc:	85ce                	mv	a1,s3
    800046be:	855a                	mv	a0,s6
    800046c0:	c7ffc0ef          	jal	8000133e <uvmalloc>
    800046c4:	892a                	mv	s2,a0
    800046c6:	e0a43423          	sd	a0,-504(s0)
    800046ca:	e519                	bnez	a0,800046d8 <exec+0x1e0>
  if(pagetable)
    800046cc:	e1343423          	sd	s3,-504(s0)
    800046d0:	4a01                	li	s4,0
    800046d2:	aab1                	j	8000482e <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046d4:	4901                	li	s2,0
    800046d6:	b7c1                	j	80004696 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800046d8:	75f9                	lui	a1,0xffffe
    800046da:	95aa                	add	a1,a1,a0
    800046dc:	855a                	mv	a0,s6
    800046de:	e4bfc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800046e2:	7bfd                	lui	s7,0xfffff
    800046e4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800046e6:	e0043783          	ld	a5,-512(s0)
    800046ea:	6388                	ld	a0,0(a5)
    800046ec:	cd39                	beqz	a0,8000474a <exec+0x252>
    800046ee:	e9040993          	addi	s3,s0,-368
    800046f2:	f9040c13          	addi	s8,s0,-112
    800046f6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800046f8:	f40fc0ef          	jal	80000e38 <strlen>
    800046fc:	0015079b          	addiw	a5,a0,1
    80004700:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004704:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004708:	11796e63          	bltu	s2,s7,80004824 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000470c:	e0043d03          	ld	s10,-512(s0)
    80004710:	000d3a03          	ld	s4,0(s10)
    80004714:	8552                	mv	a0,s4
    80004716:	f22fc0ef          	jal	80000e38 <strlen>
    8000471a:	0015069b          	addiw	a3,a0,1
    8000471e:	8652                	mv	a2,s4
    80004720:	85ca                	mv	a1,s2
    80004722:	855a                	mv	a0,s6
    80004724:	e2ffc0ef          	jal	80001552 <copyout>
    80004728:	10054063          	bltz	a0,80004828 <exec+0x330>
    ustack[argc] = sp;
    8000472c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004730:	0485                	addi	s1,s1,1
    80004732:	008d0793          	addi	a5,s10,8
    80004736:	e0f43023          	sd	a5,-512(s0)
    8000473a:	008d3503          	ld	a0,8(s10)
    8000473e:	c909                	beqz	a0,80004750 <exec+0x258>
    if(argc >= MAXARG)
    80004740:	09a1                	addi	s3,s3,8
    80004742:	fb899be3          	bne	s3,s8,800046f8 <exec+0x200>
  ip = 0;
    80004746:	4a01                	li	s4,0
    80004748:	a0dd                	j	8000482e <exec+0x336>
  sp = sz;
    8000474a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000474e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004750:	00349793          	slli	a5,s1,0x3
    80004754:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde150>
    80004758:	97a2                	add	a5,a5,s0
    8000475a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000475e:	00148693          	addi	a3,s1,1
    80004762:	068e                	slli	a3,a3,0x3
    80004764:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004768:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000476c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004770:	f5796ee3          	bltu	s2,s7,800046cc <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004774:	e9040613          	addi	a2,s0,-368
    80004778:	85ca                	mv	a1,s2
    8000477a:	855a                	mv	a0,s6
    8000477c:	dd7fc0ef          	jal	80001552 <copyout>
    80004780:	0e054263          	bltz	a0,80004864 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004784:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    80004788:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000478c:	df843783          	ld	a5,-520(s0)
    80004790:	0007c703          	lbu	a4,0(a5)
    80004794:	cf11                	beqz	a4,800047b0 <exec+0x2b8>
    80004796:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004798:	02f00693          	li	a3,47
    8000479c:	a039                	j	800047aa <exec+0x2b2>
      last = s+1;
    8000479e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800047a2:	0785                	addi	a5,a5,1
    800047a4:	fff7c703          	lbu	a4,-1(a5)
    800047a8:	c701                	beqz	a4,800047b0 <exec+0x2b8>
    if(*s == '/')
    800047aa:	fed71ce3          	bne	a4,a3,800047a2 <exec+0x2aa>
    800047ae:	bfc5                	j	8000479e <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800047b0:	4641                	li	a2,16
    800047b2:	df843583          	ld	a1,-520(s0)
    800047b6:	160a8513          	addi	a0,s5,352
    800047ba:	e4cfc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    800047be:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    800047c2:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    800047c6:	e0843783          	ld	a5,-504(s0)
    800047ca:	04fab823          	sd	a5,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800047ce:	060ab783          	ld	a5,96(s5)
    800047d2:	e6843703          	ld	a4,-408(s0)
    800047d6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800047d8:	060ab783          	ld	a5,96(s5)
    800047dc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800047e0:	85e6                	mv	a1,s9
    800047e2:	a2afd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800047e6:	0004851b          	sext.w	a0,s1
    800047ea:	79be                	ld	s3,488(sp)
    800047ec:	7a1e                	ld	s4,480(sp)
    800047ee:	6afe                	ld	s5,472(sp)
    800047f0:	6b5e                	ld	s6,464(sp)
    800047f2:	6bbe                	ld	s7,456(sp)
    800047f4:	6c1e                	ld	s8,448(sp)
    800047f6:	7cfa                	ld	s9,440(sp)
    800047f8:	7d5a                	ld	s10,432(sp)
    800047fa:	b3b5                	j	80004566 <exec+0x6e>
    800047fc:	e1243423          	sd	s2,-504(s0)
    80004800:	7dba                	ld	s11,424(sp)
    80004802:	a035                	j	8000482e <exec+0x336>
    80004804:	e1243423          	sd	s2,-504(s0)
    80004808:	7dba                	ld	s11,424(sp)
    8000480a:	a015                	j	8000482e <exec+0x336>
    8000480c:	e1243423          	sd	s2,-504(s0)
    80004810:	7dba                	ld	s11,424(sp)
    80004812:	a831                	j	8000482e <exec+0x336>
    80004814:	e1243423          	sd	s2,-504(s0)
    80004818:	7dba                	ld	s11,424(sp)
    8000481a:	a811                	j	8000482e <exec+0x336>
    8000481c:	e1243423          	sd	s2,-504(s0)
    80004820:	7dba                	ld	s11,424(sp)
    80004822:	a031                	j	8000482e <exec+0x336>
  ip = 0;
    80004824:	4a01                	li	s4,0
    80004826:	a021                	j	8000482e <exec+0x336>
    80004828:	4a01                	li	s4,0
  if(pagetable)
    8000482a:	a011                	j	8000482e <exec+0x336>
    8000482c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000482e:	e0843583          	ld	a1,-504(s0)
    80004832:	855a                	mv	a0,s6
    80004834:	9d8fd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    80004838:	557d                	li	a0,-1
  if(ip){
    8000483a:	000a1b63          	bnez	s4,80004850 <exec+0x358>
    8000483e:	79be                	ld	s3,488(sp)
    80004840:	7a1e                	ld	s4,480(sp)
    80004842:	6afe                	ld	s5,472(sp)
    80004844:	6b5e                	ld	s6,464(sp)
    80004846:	6bbe                	ld	s7,456(sp)
    80004848:	6c1e                	ld	s8,448(sp)
    8000484a:	7cfa                	ld	s9,440(sp)
    8000484c:	7d5a                	ld	s10,432(sp)
    8000484e:	bb21                	j	80004566 <exec+0x6e>
    80004850:	79be                	ld	s3,488(sp)
    80004852:	6afe                	ld	s5,472(sp)
    80004854:	6b5e                	ld	s6,464(sp)
    80004856:	6bbe                	ld	s7,456(sp)
    80004858:	6c1e                	ld	s8,448(sp)
    8000485a:	7cfa                	ld	s9,440(sp)
    8000485c:	7d5a                	ld	s10,432(sp)
    8000485e:	b9ed                	j	80004558 <exec+0x60>
    80004860:	6b5e                	ld	s6,464(sp)
    80004862:	b9dd                	j	80004558 <exec+0x60>
  sz = sz1;
    80004864:	e0843983          	ld	s3,-504(s0)
    80004868:	b595                	j	800046cc <exec+0x1d4>

000000008000486a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000486a:	7179                	addi	sp,sp,-48
    8000486c:	f406                	sd	ra,40(sp)
    8000486e:	f022                	sd	s0,32(sp)
    80004870:	ec26                	sd	s1,24(sp)
    80004872:	e84a                	sd	s2,16(sp)
    80004874:	1800                	addi	s0,sp,48
    80004876:	892e                	mv	s2,a1
    80004878:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000487a:	fdc40593          	addi	a1,s0,-36
    8000487e:	fa1fd0ef          	jal	8000281e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004882:	fdc42703          	lw	a4,-36(s0)
    80004886:	47bd                	li	a5,15
    80004888:	02e7e963          	bltu	a5,a4,800048ba <argfd+0x50>
    8000488c:	854fd0ef          	jal	800018e0 <myproc>
    80004890:	fdc42703          	lw	a4,-36(s0)
    80004894:	01a70793          	addi	a5,a4,26
    80004898:	078e                	slli	a5,a5,0x3
    8000489a:	953e                	add	a0,a0,a5
    8000489c:	651c                	ld	a5,8(a0)
    8000489e:	c385                	beqz	a5,800048be <argfd+0x54>
    return -1;
  if(pfd)
    800048a0:	00090463          	beqz	s2,800048a8 <argfd+0x3e>
    *pfd = fd;
    800048a4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800048a8:	4501                	li	a0,0
  if(pf)
    800048aa:	c091                	beqz	s1,800048ae <argfd+0x44>
    *pf = f;
    800048ac:	e09c                	sd	a5,0(s1)
}
    800048ae:	70a2                	ld	ra,40(sp)
    800048b0:	7402                	ld	s0,32(sp)
    800048b2:	64e2                	ld	s1,24(sp)
    800048b4:	6942                	ld	s2,16(sp)
    800048b6:	6145                	addi	sp,sp,48
    800048b8:	8082                	ret
    return -1;
    800048ba:	557d                	li	a0,-1
    800048bc:	bfcd                	j	800048ae <argfd+0x44>
    800048be:	557d                	li	a0,-1
    800048c0:	b7fd                	j	800048ae <argfd+0x44>

00000000800048c2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800048c2:	1101                	addi	sp,sp,-32
    800048c4:	ec06                	sd	ra,24(sp)
    800048c6:	e822                	sd	s0,16(sp)
    800048c8:	e426                	sd	s1,8(sp)
    800048ca:	1000                	addi	s0,sp,32
    800048cc:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800048ce:	812fd0ef          	jal	800018e0 <myproc>
    800048d2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800048d4:	0d850793          	addi	a5,a0,216
    800048d8:	4501                	li	a0,0
    800048da:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800048dc:	6398                	ld	a4,0(a5)
    800048de:	cb19                	beqz	a4,800048f4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800048e0:	2505                	addiw	a0,a0,1
    800048e2:	07a1                	addi	a5,a5,8
    800048e4:	fed51ce3          	bne	a0,a3,800048dc <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800048e8:	557d                	li	a0,-1
}
    800048ea:	60e2                	ld	ra,24(sp)
    800048ec:	6442                	ld	s0,16(sp)
    800048ee:	64a2                	ld	s1,8(sp)
    800048f0:	6105                	addi	sp,sp,32
    800048f2:	8082                	ret
      p->ofile[fd] = f;
    800048f4:	01a50793          	addi	a5,a0,26
    800048f8:	078e                	slli	a5,a5,0x3
    800048fa:	963e                	add	a2,a2,a5
    800048fc:	e604                	sd	s1,8(a2)
      return fd;
    800048fe:	b7f5                	j	800048ea <fdalloc+0x28>

0000000080004900 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004900:	715d                	addi	sp,sp,-80
    80004902:	e486                	sd	ra,72(sp)
    80004904:	e0a2                	sd	s0,64(sp)
    80004906:	fc26                	sd	s1,56(sp)
    80004908:	f84a                	sd	s2,48(sp)
    8000490a:	f44e                	sd	s3,40(sp)
    8000490c:	ec56                	sd	s5,24(sp)
    8000490e:	e85a                	sd	s6,16(sp)
    80004910:	0880                	addi	s0,sp,80
    80004912:	8b2e                	mv	s6,a1
    80004914:	89b2                	mv	s3,a2
    80004916:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004918:	fb040593          	addi	a1,s0,-80
    8000491c:	822ff0ef          	jal	8000393e <nameiparent>
    80004920:	84aa                	mv	s1,a0
    80004922:	10050a63          	beqz	a0,80004a36 <create+0x136>
    return 0;

  ilock(dp);
    80004926:	925fe0ef          	jal	8000324a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000492a:	4601                	li	a2,0
    8000492c:	fb040593          	addi	a1,s0,-80
    80004930:	8526                	mv	a0,s1
    80004932:	d8dfe0ef          	jal	800036be <dirlookup>
    80004936:	8aaa                	mv	s5,a0
    80004938:	c129                	beqz	a0,8000497a <create+0x7a>
    iunlockput(dp);
    8000493a:	8526                	mv	a0,s1
    8000493c:	b19fe0ef          	jal	80003454 <iunlockput>
    ilock(ip);
    80004940:	8556                	mv	a0,s5
    80004942:	909fe0ef          	jal	8000324a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004946:	4789                	li	a5,2
    80004948:	02fb1463          	bne	s6,a5,80004970 <create+0x70>
    8000494c:	044ad783          	lhu	a5,68(s5)
    80004950:	37f9                	addiw	a5,a5,-2
    80004952:	17c2                	slli	a5,a5,0x30
    80004954:	93c1                	srli	a5,a5,0x30
    80004956:	4705                	li	a4,1
    80004958:	00f76c63          	bltu	a4,a5,80004970 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000495c:	8556                	mv	a0,s5
    8000495e:	60a6                	ld	ra,72(sp)
    80004960:	6406                	ld	s0,64(sp)
    80004962:	74e2                	ld	s1,56(sp)
    80004964:	7942                	ld	s2,48(sp)
    80004966:	79a2                	ld	s3,40(sp)
    80004968:	6ae2                	ld	s5,24(sp)
    8000496a:	6b42                	ld	s6,16(sp)
    8000496c:	6161                	addi	sp,sp,80
    8000496e:	8082                	ret
    iunlockput(ip);
    80004970:	8556                	mv	a0,s5
    80004972:	ae3fe0ef          	jal	80003454 <iunlockput>
    return 0;
    80004976:	4a81                	li	s5,0
    80004978:	b7d5                	j	8000495c <create+0x5c>
    8000497a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000497c:	85da                	mv	a1,s6
    8000497e:	4088                	lw	a0,0(s1)
    80004980:	f5afe0ef          	jal	800030da <ialloc>
    80004984:	8a2a                	mv	s4,a0
    80004986:	cd15                	beqz	a0,800049c2 <create+0xc2>
  ilock(ip);
    80004988:	8c3fe0ef          	jal	8000324a <ilock>
  ip->major = major;
    8000498c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004990:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004994:	4905                	li	s2,1
    80004996:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000499a:	8552                	mv	a0,s4
    8000499c:	ffafe0ef          	jal	80003196 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800049a0:	032b0763          	beq	s6,s2,800049ce <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800049a4:	004a2603          	lw	a2,4(s4)
    800049a8:	fb040593          	addi	a1,s0,-80
    800049ac:	8526                	mv	a0,s1
    800049ae:	eddfe0ef          	jal	8000388a <dirlink>
    800049b2:	06054563          	bltz	a0,80004a1c <create+0x11c>
  iunlockput(dp);
    800049b6:	8526                	mv	a0,s1
    800049b8:	a9dfe0ef          	jal	80003454 <iunlockput>
  return ip;
    800049bc:	8ad2                	mv	s5,s4
    800049be:	7a02                	ld	s4,32(sp)
    800049c0:	bf71                	j	8000495c <create+0x5c>
    iunlockput(dp);
    800049c2:	8526                	mv	a0,s1
    800049c4:	a91fe0ef          	jal	80003454 <iunlockput>
    return 0;
    800049c8:	8ad2                	mv	s5,s4
    800049ca:	7a02                	ld	s4,32(sp)
    800049cc:	bf41                	j	8000495c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800049ce:	004a2603          	lw	a2,4(s4)
    800049d2:	00003597          	auipc	a1,0x3
    800049d6:	c4e58593          	addi	a1,a1,-946 # 80007620 <etext+0x620>
    800049da:	8552                	mv	a0,s4
    800049dc:	eaffe0ef          	jal	8000388a <dirlink>
    800049e0:	02054e63          	bltz	a0,80004a1c <create+0x11c>
    800049e4:	40d0                	lw	a2,4(s1)
    800049e6:	00003597          	auipc	a1,0x3
    800049ea:	c4258593          	addi	a1,a1,-958 # 80007628 <etext+0x628>
    800049ee:	8552                	mv	a0,s4
    800049f0:	e9bfe0ef          	jal	8000388a <dirlink>
    800049f4:	02054463          	bltz	a0,80004a1c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800049f8:	004a2603          	lw	a2,4(s4)
    800049fc:	fb040593          	addi	a1,s0,-80
    80004a00:	8526                	mv	a0,s1
    80004a02:	e89fe0ef          	jal	8000388a <dirlink>
    80004a06:	00054b63          	bltz	a0,80004a1c <create+0x11c>
    dp->nlink++;  // for ".."
    80004a0a:	04a4d783          	lhu	a5,74(s1)
    80004a0e:	2785                	addiw	a5,a5,1
    80004a10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a14:	8526                	mv	a0,s1
    80004a16:	f80fe0ef          	jal	80003196 <iupdate>
    80004a1a:	bf71                	j	800049b6 <create+0xb6>
  ip->nlink = 0;
    80004a1c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004a20:	8552                	mv	a0,s4
    80004a22:	f74fe0ef          	jal	80003196 <iupdate>
  iunlockput(ip);
    80004a26:	8552                	mv	a0,s4
    80004a28:	a2dfe0ef          	jal	80003454 <iunlockput>
  iunlockput(dp);
    80004a2c:	8526                	mv	a0,s1
    80004a2e:	a27fe0ef          	jal	80003454 <iunlockput>
  return 0;
    80004a32:	7a02                	ld	s4,32(sp)
    80004a34:	b725                	j	8000495c <create+0x5c>
    return 0;
    80004a36:	8aaa                	mv	s5,a0
    80004a38:	b715                	j	8000495c <create+0x5c>

0000000080004a3a <sys_dup>:
{
    80004a3a:	7179                	addi	sp,sp,-48
    80004a3c:	f406                	sd	ra,40(sp)
    80004a3e:	f022                	sd	s0,32(sp)
    80004a40:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a42:	fd840613          	addi	a2,s0,-40
    80004a46:	4581                	li	a1,0
    80004a48:	4501                	li	a0,0
    80004a4a:	e21ff0ef          	jal	8000486a <argfd>
    return -1;
    80004a4e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a50:	02054363          	bltz	a0,80004a76 <sys_dup+0x3c>
    80004a54:	ec26                	sd	s1,24(sp)
    80004a56:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004a58:	fd843903          	ld	s2,-40(s0)
    80004a5c:	854a                	mv	a0,s2
    80004a5e:	e65ff0ef          	jal	800048c2 <fdalloc>
    80004a62:	84aa                	mv	s1,a0
    return -1;
    80004a64:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004a66:	00054d63          	bltz	a0,80004a80 <sys_dup+0x46>
  filedup(f);
    80004a6a:	854a                	mv	a0,s2
    80004a6c:	c48ff0ef          	jal	80003eb4 <filedup>
  return fd;
    80004a70:	87a6                	mv	a5,s1
    80004a72:	64e2                	ld	s1,24(sp)
    80004a74:	6942                	ld	s2,16(sp)
}
    80004a76:	853e                	mv	a0,a5
    80004a78:	70a2                	ld	ra,40(sp)
    80004a7a:	7402                	ld	s0,32(sp)
    80004a7c:	6145                	addi	sp,sp,48
    80004a7e:	8082                	ret
    80004a80:	64e2                	ld	s1,24(sp)
    80004a82:	6942                	ld	s2,16(sp)
    80004a84:	bfcd                	j	80004a76 <sys_dup+0x3c>

0000000080004a86 <sys_read>:
{
    80004a86:	7179                	addi	sp,sp,-48
    80004a88:	f406                	sd	ra,40(sp)
    80004a8a:	f022                	sd	s0,32(sp)
    80004a8c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a8e:	fd840593          	addi	a1,s0,-40
    80004a92:	4505                	li	a0,1
    80004a94:	da7fd0ef          	jal	8000283a <argaddr>
  argint(2, &n);
    80004a98:	fe440593          	addi	a1,s0,-28
    80004a9c:	4509                	li	a0,2
    80004a9e:	d81fd0ef          	jal	8000281e <argint>
  if(argfd(0, 0, &f) < 0)
    80004aa2:	fe840613          	addi	a2,s0,-24
    80004aa6:	4581                	li	a1,0
    80004aa8:	4501                	li	a0,0
    80004aaa:	dc1ff0ef          	jal	8000486a <argfd>
    80004aae:	87aa                	mv	a5,a0
    return -1;
    80004ab0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ab2:	0007ca63          	bltz	a5,80004ac6 <sys_read+0x40>
  return fileread(f, p, n);
    80004ab6:	fe442603          	lw	a2,-28(s0)
    80004aba:	fd843583          	ld	a1,-40(s0)
    80004abe:	fe843503          	ld	a0,-24(s0)
    80004ac2:	d58ff0ef          	jal	8000401a <fileread>
}
    80004ac6:	70a2                	ld	ra,40(sp)
    80004ac8:	7402                	ld	s0,32(sp)
    80004aca:	6145                	addi	sp,sp,48
    80004acc:	8082                	ret

0000000080004ace <sys_write>:
{
    80004ace:	7179                	addi	sp,sp,-48
    80004ad0:	f406                	sd	ra,40(sp)
    80004ad2:	f022                	sd	s0,32(sp)
    80004ad4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ad6:	fd840593          	addi	a1,s0,-40
    80004ada:	4505                	li	a0,1
    80004adc:	d5ffd0ef          	jal	8000283a <argaddr>
  argint(2, &n);
    80004ae0:	fe440593          	addi	a1,s0,-28
    80004ae4:	4509                	li	a0,2
    80004ae6:	d39fd0ef          	jal	8000281e <argint>
  if(argfd(0, 0, &f) < 0)
    80004aea:	fe840613          	addi	a2,s0,-24
    80004aee:	4581                	li	a1,0
    80004af0:	4501                	li	a0,0
    80004af2:	d79ff0ef          	jal	8000486a <argfd>
    80004af6:	87aa                	mv	a5,a0
    return -1;
    80004af8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004afa:	0007ca63          	bltz	a5,80004b0e <sys_write+0x40>
  return filewrite(f, p, n);
    80004afe:	fe442603          	lw	a2,-28(s0)
    80004b02:	fd843583          	ld	a1,-40(s0)
    80004b06:	fe843503          	ld	a0,-24(s0)
    80004b0a:	dceff0ef          	jal	800040d8 <filewrite>
}
    80004b0e:	70a2                	ld	ra,40(sp)
    80004b10:	7402                	ld	s0,32(sp)
    80004b12:	6145                	addi	sp,sp,48
    80004b14:	8082                	ret

0000000080004b16 <sys_close>:
{
    80004b16:	1101                	addi	sp,sp,-32
    80004b18:	ec06                	sd	ra,24(sp)
    80004b1a:	e822                	sd	s0,16(sp)
    80004b1c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004b1e:	fe040613          	addi	a2,s0,-32
    80004b22:	fec40593          	addi	a1,s0,-20
    80004b26:	4501                	li	a0,0
    80004b28:	d43ff0ef          	jal	8000486a <argfd>
    return -1;
    80004b2c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004b2e:	02054063          	bltz	a0,80004b4e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004b32:	daffc0ef          	jal	800018e0 <myproc>
    80004b36:	fec42783          	lw	a5,-20(s0)
    80004b3a:	07e9                	addi	a5,a5,26
    80004b3c:	078e                	slli	a5,a5,0x3
    80004b3e:	953e                	add	a0,a0,a5
    80004b40:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80004b44:	fe043503          	ld	a0,-32(s0)
    80004b48:	bb2ff0ef          	jal	80003efa <fileclose>
  return 0;
    80004b4c:	4781                	li	a5,0
}
    80004b4e:	853e                	mv	a0,a5
    80004b50:	60e2                	ld	ra,24(sp)
    80004b52:	6442                	ld	s0,16(sp)
    80004b54:	6105                	addi	sp,sp,32
    80004b56:	8082                	ret

0000000080004b58 <sys_fstat>:
{
    80004b58:	1101                	addi	sp,sp,-32
    80004b5a:	ec06                	sd	ra,24(sp)
    80004b5c:	e822                	sd	s0,16(sp)
    80004b5e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004b60:	fe040593          	addi	a1,s0,-32
    80004b64:	4505                	li	a0,1
    80004b66:	cd5fd0ef          	jal	8000283a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b6a:	fe840613          	addi	a2,s0,-24
    80004b6e:	4581                	li	a1,0
    80004b70:	4501                	li	a0,0
    80004b72:	cf9ff0ef          	jal	8000486a <argfd>
    80004b76:	87aa                	mv	a5,a0
    return -1;
    80004b78:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b7a:	0007c863          	bltz	a5,80004b8a <sys_fstat+0x32>
  return filestat(f, st);
    80004b7e:	fe043583          	ld	a1,-32(s0)
    80004b82:	fe843503          	ld	a0,-24(s0)
    80004b86:	c36ff0ef          	jal	80003fbc <filestat>
}
    80004b8a:	60e2                	ld	ra,24(sp)
    80004b8c:	6442                	ld	s0,16(sp)
    80004b8e:	6105                	addi	sp,sp,32
    80004b90:	8082                	ret

0000000080004b92 <sys_link>:
{
    80004b92:	7169                	addi	sp,sp,-304
    80004b94:	f606                	sd	ra,296(sp)
    80004b96:	f222                	sd	s0,288(sp)
    80004b98:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b9a:	08000613          	li	a2,128
    80004b9e:	ed040593          	addi	a1,s0,-304
    80004ba2:	4501                	li	a0,0
    80004ba4:	cb3fd0ef          	jal	80002856 <argstr>
    return -1;
    80004ba8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004baa:	0c054e63          	bltz	a0,80004c86 <sys_link+0xf4>
    80004bae:	08000613          	li	a2,128
    80004bb2:	f5040593          	addi	a1,s0,-176
    80004bb6:	4505                	li	a0,1
    80004bb8:	c9ffd0ef          	jal	80002856 <argstr>
    return -1;
    80004bbc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bbe:	0c054463          	bltz	a0,80004c86 <sys_link+0xf4>
    80004bc2:	ee26                	sd	s1,280(sp)
  begin_op();
    80004bc4:	f1dfe0ef          	jal	80003ae0 <begin_op>
  if((ip = namei(old)) == 0){
    80004bc8:	ed040513          	addi	a0,s0,-304
    80004bcc:	d59fe0ef          	jal	80003924 <namei>
    80004bd0:	84aa                	mv	s1,a0
    80004bd2:	c53d                	beqz	a0,80004c40 <sys_link+0xae>
  ilock(ip);
    80004bd4:	e76fe0ef          	jal	8000324a <ilock>
  if(ip->type == T_DIR){
    80004bd8:	04449703          	lh	a4,68(s1)
    80004bdc:	4785                	li	a5,1
    80004bde:	06f70663          	beq	a4,a5,80004c4a <sys_link+0xb8>
    80004be2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004be4:	04a4d783          	lhu	a5,74(s1)
    80004be8:	2785                	addiw	a5,a5,1
    80004bea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	da6fe0ef          	jal	80003196 <iupdate>
  iunlock(ip);
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	f02fe0ef          	jal	800032f8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004bfa:	fd040593          	addi	a1,s0,-48
    80004bfe:	f5040513          	addi	a0,s0,-176
    80004c02:	d3dfe0ef          	jal	8000393e <nameiparent>
    80004c06:	892a                	mv	s2,a0
    80004c08:	cd21                	beqz	a0,80004c60 <sys_link+0xce>
  ilock(dp);
    80004c0a:	e40fe0ef          	jal	8000324a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c0e:	00092703          	lw	a4,0(s2)
    80004c12:	409c                	lw	a5,0(s1)
    80004c14:	04f71363          	bne	a4,a5,80004c5a <sys_link+0xc8>
    80004c18:	40d0                	lw	a2,4(s1)
    80004c1a:	fd040593          	addi	a1,s0,-48
    80004c1e:	854a                	mv	a0,s2
    80004c20:	c6bfe0ef          	jal	8000388a <dirlink>
    80004c24:	02054b63          	bltz	a0,80004c5a <sys_link+0xc8>
  iunlockput(dp);
    80004c28:	854a                	mv	a0,s2
    80004c2a:	82bfe0ef          	jal	80003454 <iunlockput>
  iput(ip);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	f9cfe0ef          	jal	800033cc <iput>
  end_op();
    80004c34:	f17fe0ef          	jal	80003b4a <end_op>
  return 0;
    80004c38:	4781                	li	a5,0
    80004c3a:	64f2                	ld	s1,280(sp)
    80004c3c:	6952                	ld	s2,272(sp)
    80004c3e:	a0a1                	j	80004c86 <sys_link+0xf4>
    end_op();
    80004c40:	f0bfe0ef          	jal	80003b4a <end_op>
    return -1;
    80004c44:	57fd                	li	a5,-1
    80004c46:	64f2                	ld	s1,280(sp)
    80004c48:	a83d                	j	80004c86 <sys_link+0xf4>
    iunlockput(ip);
    80004c4a:	8526                	mv	a0,s1
    80004c4c:	809fe0ef          	jal	80003454 <iunlockput>
    end_op();
    80004c50:	efbfe0ef          	jal	80003b4a <end_op>
    return -1;
    80004c54:	57fd                	li	a5,-1
    80004c56:	64f2                	ld	s1,280(sp)
    80004c58:	a03d                	j	80004c86 <sys_link+0xf4>
    iunlockput(dp);
    80004c5a:	854a                	mv	a0,s2
    80004c5c:	ff8fe0ef          	jal	80003454 <iunlockput>
  ilock(ip);
    80004c60:	8526                	mv	a0,s1
    80004c62:	de8fe0ef          	jal	8000324a <ilock>
  ip->nlink--;
    80004c66:	04a4d783          	lhu	a5,74(s1)
    80004c6a:	37fd                	addiw	a5,a5,-1
    80004c6c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c70:	8526                	mv	a0,s1
    80004c72:	d24fe0ef          	jal	80003196 <iupdate>
  iunlockput(ip);
    80004c76:	8526                	mv	a0,s1
    80004c78:	fdcfe0ef          	jal	80003454 <iunlockput>
  end_op();
    80004c7c:	ecffe0ef          	jal	80003b4a <end_op>
  return -1;
    80004c80:	57fd                	li	a5,-1
    80004c82:	64f2                	ld	s1,280(sp)
    80004c84:	6952                	ld	s2,272(sp)
}
    80004c86:	853e                	mv	a0,a5
    80004c88:	70b2                	ld	ra,296(sp)
    80004c8a:	7412                	ld	s0,288(sp)
    80004c8c:	6155                	addi	sp,sp,304
    80004c8e:	8082                	ret

0000000080004c90 <sys_unlink>:
{
    80004c90:	7151                	addi	sp,sp,-240
    80004c92:	f586                	sd	ra,232(sp)
    80004c94:	f1a2                	sd	s0,224(sp)
    80004c96:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c98:	08000613          	li	a2,128
    80004c9c:	f3040593          	addi	a1,s0,-208
    80004ca0:	4501                	li	a0,0
    80004ca2:	bb5fd0ef          	jal	80002856 <argstr>
    80004ca6:	16054063          	bltz	a0,80004e06 <sys_unlink+0x176>
    80004caa:	eda6                	sd	s1,216(sp)
  begin_op();
    80004cac:	e35fe0ef          	jal	80003ae0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004cb0:	fb040593          	addi	a1,s0,-80
    80004cb4:	f3040513          	addi	a0,s0,-208
    80004cb8:	c87fe0ef          	jal	8000393e <nameiparent>
    80004cbc:	84aa                	mv	s1,a0
    80004cbe:	c945                	beqz	a0,80004d6e <sys_unlink+0xde>
  ilock(dp);
    80004cc0:	d8afe0ef          	jal	8000324a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004cc4:	00003597          	auipc	a1,0x3
    80004cc8:	95c58593          	addi	a1,a1,-1700 # 80007620 <etext+0x620>
    80004ccc:	fb040513          	addi	a0,s0,-80
    80004cd0:	9d9fe0ef          	jal	800036a8 <namecmp>
    80004cd4:	10050e63          	beqz	a0,80004df0 <sys_unlink+0x160>
    80004cd8:	00003597          	auipc	a1,0x3
    80004cdc:	95058593          	addi	a1,a1,-1712 # 80007628 <etext+0x628>
    80004ce0:	fb040513          	addi	a0,s0,-80
    80004ce4:	9c5fe0ef          	jal	800036a8 <namecmp>
    80004ce8:	10050463          	beqz	a0,80004df0 <sys_unlink+0x160>
    80004cec:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004cee:	f2c40613          	addi	a2,s0,-212
    80004cf2:	fb040593          	addi	a1,s0,-80
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	9c7fe0ef          	jal	800036be <dirlookup>
    80004cfc:	892a                	mv	s2,a0
    80004cfe:	0e050863          	beqz	a0,80004dee <sys_unlink+0x15e>
  ilock(ip);
    80004d02:	d48fe0ef          	jal	8000324a <ilock>
  if(ip->nlink < 1)
    80004d06:	04a91783          	lh	a5,74(s2)
    80004d0a:	06f05763          	blez	a5,80004d78 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004d0e:	04491703          	lh	a4,68(s2)
    80004d12:	4785                	li	a5,1
    80004d14:	06f70963          	beq	a4,a5,80004d86 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004d18:	4641                	li	a2,16
    80004d1a:	4581                	li	a1,0
    80004d1c:	fc040513          	addi	a0,s0,-64
    80004d20:	fa9fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d24:	4741                	li	a4,16
    80004d26:	f2c42683          	lw	a3,-212(s0)
    80004d2a:	fc040613          	addi	a2,s0,-64
    80004d2e:	4581                	li	a1,0
    80004d30:	8526                	mv	a0,s1
    80004d32:	869fe0ef          	jal	8000359a <writei>
    80004d36:	47c1                	li	a5,16
    80004d38:	08f51b63          	bne	a0,a5,80004dce <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004d3c:	04491703          	lh	a4,68(s2)
    80004d40:	4785                	li	a5,1
    80004d42:	08f70d63          	beq	a4,a5,80004ddc <sys_unlink+0x14c>
  iunlockput(dp);
    80004d46:	8526                	mv	a0,s1
    80004d48:	f0cfe0ef          	jal	80003454 <iunlockput>
  ip->nlink--;
    80004d4c:	04a95783          	lhu	a5,74(s2)
    80004d50:	37fd                	addiw	a5,a5,-1
    80004d52:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d56:	854a                	mv	a0,s2
    80004d58:	c3efe0ef          	jal	80003196 <iupdate>
  iunlockput(ip);
    80004d5c:	854a                	mv	a0,s2
    80004d5e:	ef6fe0ef          	jal	80003454 <iunlockput>
  end_op();
    80004d62:	de9fe0ef          	jal	80003b4a <end_op>
  return 0;
    80004d66:	4501                	li	a0,0
    80004d68:	64ee                	ld	s1,216(sp)
    80004d6a:	694e                	ld	s2,208(sp)
    80004d6c:	a849                	j	80004dfe <sys_unlink+0x16e>
    end_op();
    80004d6e:	dddfe0ef          	jal	80003b4a <end_op>
    return -1;
    80004d72:	557d                	li	a0,-1
    80004d74:	64ee                	ld	s1,216(sp)
    80004d76:	a061                	j	80004dfe <sys_unlink+0x16e>
    80004d78:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004d7a:	00003517          	auipc	a0,0x3
    80004d7e:	8b650513          	addi	a0,a0,-1866 # 80007630 <etext+0x630>
    80004d82:	a13fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d86:	04c92703          	lw	a4,76(s2)
    80004d8a:	02000793          	li	a5,32
    80004d8e:	f8e7f5e3          	bgeu	a5,a4,80004d18 <sys_unlink+0x88>
    80004d92:	e5ce                	sd	s3,200(sp)
    80004d94:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d98:	4741                	li	a4,16
    80004d9a:	86ce                	mv	a3,s3
    80004d9c:	f1840613          	addi	a2,s0,-232
    80004da0:	4581                	li	a1,0
    80004da2:	854a                	mv	a0,s2
    80004da4:	efafe0ef          	jal	8000349e <readi>
    80004da8:	47c1                	li	a5,16
    80004daa:	00f51c63          	bne	a0,a5,80004dc2 <sys_unlink+0x132>
    if(de.inum != 0)
    80004dae:	f1845783          	lhu	a5,-232(s0)
    80004db2:	efa1                	bnez	a5,80004e0a <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004db4:	29c1                	addiw	s3,s3,16
    80004db6:	04c92783          	lw	a5,76(s2)
    80004dba:	fcf9efe3          	bltu	s3,a5,80004d98 <sys_unlink+0x108>
    80004dbe:	69ae                	ld	s3,200(sp)
    80004dc0:	bfa1                	j	80004d18 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004dc2:	00003517          	auipc	a0,0x3
    80004dc6:	88650513          	addi	a0,a0,-1914 # 80007648 <etext+0x648>
    80004dca:	9cbfb0ef          	jal	80000794 <panic>
    80004dce:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004dd0:	00003517          	auipc	a0,0x3
    80004dd4:	89050513          	addi	a0,a0,-1904 # 80007660 <etext+0x660>
    80004dd8:	9bdfb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004ddc:	04a4d783          	lhu	a5,74(s1)
    80004de0:	37fd                	addiw	a5,a5,-1
    80004de2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004de6:	8526                	mv	a0,s1
    80004de8:	baefe0ef          	jal	80003196 <iupdate>
    80004dec:	bfa9                	j	80004d46 <sys_unlink+0xb6>
    80004dee:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004df0:	8526                	mv	a0,s1
    80004df2:	e62fe0ef          	jal	80003454 <iunlockput>
  end_op();
    80004df6:	d55fe0ef          	jal	80003b4a <end_op>
  return -1;
    80004dfa:	557d                	li	a0,-1
    80004dfc:	64ee                	ld	s1,216(sp)
}
    80004dfe:	70ae                	ld	ra,232(sp)
    80004e00:	740e                	ld	s0,224(sp)
    80004e02:	616d                	addi	sp,sp,240
    80004e04:	8082                	ret
    return -1;
    80004e06:	557d                	li	a0,-1
    80004e08:	bfdd                	j	80004dfe <sys_unlink+0x16e>
    iunlockput(ip);
    80004e0a:	854a                	mv	a0,s2
    80004e0c:	e48fe0ef          	jal	80003454 <iunlockput>
    goto bad;
    80004e10:	694e                	ld	s2,208(sp)
    80004e12:	69ae                	ld	s3,200(sp)
    80004e14:	bff1                	j	80004df0 <sys_unlink+0x160>

0000000080004e16 <sys_open>:

uint64
sys_open(void)
{
    80004e16:	7131                	addi	sp,sp,-192
    80004e18:	fd06                	sd	ra,184(sp)
    80004e1a:	f922                	sd	s0,176(sp)
    80004e1c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e1e:	f4c40593          	addi	a1,s0,-180
    80004e22:	4505                	li	a0,1
    80004e24:	9fbfd0ef          	jal	8000281e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e28:	08000613          	li	a2,128
    80004e2c:	f5040593          	addi	a1,s0,-176
    80004e30:	4501                	li	a0,0
    80004e32:	a25fd0ef          	jal	80002856 <argstr>
    80004e36:	87aa                	mv	a5,a0
    return -1;
    80004e38:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e3a:	0a07c263          	bltz	a5,80004ede <sys_open+0xc8>
    80004e3e:	f526                	sd	s1,168(sp)

  begin_op();
    80004e40:	ca1fe0ef          	jal	80003ae0 <begin_op>

  if(omode & O_CREATE){
    80004e44:	f4c42783          	lw	a5,-180(s0)
    80004e48:	2007f793          	andi	a5,a5,512
    80004e4c:	c3d5                	beqz	a5,80004ef0 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004e4e:	4681                	li	a3,0
    80004e50:	4601                	li	a2,0
    80004e52:	4589                	li	a1,2
    80004e54:	f5040513          	addi	a0,s0,-176
    80004e58:	aa9ff0ef          	jal	80004900 <create>
    80004e5c:	84aa                	mv	s1,a0
    if(ip == 0){
    80004e5e:	c541                	beqz	a0,80004ee6 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004e60:	04449703          	lh	a4,68(s1)
    80004e64:	478d                	li	a5,3
    80004e66:	00f71763          	bne	a4,a5,80004e74 <sys_open+0x5e>
    80004e6a:	0464d703          	lhu	a4,70(s1)
    80004e6e:	47a5                	li	a5,9
    80004e70:	0ae7ed63          	bltu	a5,a4,80004f2a <sys_open+0x114>
    80004e74:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e76:	fe1fe0ef          	jal	80003e56 <filealloc>
    80004e7a:	892a                	mv	s2,a0
    80004e7c:	c179                	beqz	a0,80004f42 <sys_open+0x12c>
    80004e7e:	ed4e                	sd	s3,152(sp)
    80004e80:	a43ff0ef          	jal	800048c2 <fdalloc>
    80004e84:	89aa                	mv	s3,a0
    80004e86:	0a054a63          	bltz	a0,80004f3a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e8a:	04449703          	lh	a4,68(s1)
    80004e8e:	478d                	li	a5,3
    80004e90:	0cf70263          	beq	a4,a5,80004f54 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e94:	4789                	li	a5,2
    80004e96:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004e9a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004e9e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004ea2:	f4c42783          	lw	a5,-180(s0)
    80004ea6:	0017c713          	xori	a4,a5,1
    80004eaa:	8b05                	andi	a4,a4,1
    80004eac:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004eb0:	0037f713          	andi	a4,a5,3
    80004eb4:	00e03733          	snez	a4,a4
    80004eb8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004ebc:	4007f793          	andi	a5,a5,1024
    80004ec0:	c791                	beqz	a5,80004ecc <sys_open+0xb6>
    80004ec2:	04449703          	lh	a4,68(s1)
    80004ec6:	4789                	li	a5,2
    80004ec8:	08f70d63          	beq	a4,a5,80004f62 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004ecc:	8526                	mv	a0,s1
    80004ece:	c2afe0ef          	jal	800032f8 <iunlock>
  end_op();
    80004ed2:	c79fe0ef          	jal	80003b4a <end_op>

  return fd;
    80004ed6:	854e                	mv	a0,s3
    80004ed8:	74aa                	ld	s1,168(sp)
    80004eda:	790a                	ld	s2,160(sp)
    80004edc:	69ea                	ld	s3,152(sp)
}
    80004ede:	70ea                	ld	ra,184(sp)
    80004ee0:	744a                	ld	s0,176(sp)
    80004ee2:	6129                	addi	sp,sp,192
    80004ee4:	8082                	ret
      end_op();
    80004ee6:	c65fe0ef          	jal	80003b4a <end_op>
      return -1;
    80004eea:	557d                	li	a0,-1
    80004eec:	74aa                	ld	s1,168(sp)
    80004eee:	bfc5                	j	80004ede <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004ef0:	f5040513          	addi	a0,s0,-176
    80004ef4:	a31fe0ef          	jal	80003924 <namei>
    80004ef8:	84aa                	mv	s1,a0
    80004efa:	c11d                	beqz	a0,80004f20 <sys_open+0x10a>
    ilock(ip);
    80004efc:	b4efe0ef          	jal	8000324a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f00:	04449703          	lh	a4,68(s1)
    80004f04:	4785                	li	a5,1
    80004f06:	f4f71de3          	bne	a4,a5,80004e60 <sys_open+0x4a>
    80004f0a:	f4c42783          	lw	a5,-180(s0)
    80004f0e:	d3bd                	beqz	a5,80004e74 <sys_open+0x5e>
      iunlockput(ip);
    80004f10:	8526                	mv	a0,s1
    80004f12:	d42fe0ef          	jal	80003454 <iunlockput>
      end_op();
    80004f16:	c35fe0ef          	jal	80003b4a <end_op>
      return -1;
    80004f1a:	557d                	li	a0,-1
    80004f1c:	74aa                	ld	s1,168(sp)
    80004f1e:	b7c1                	j	80004ede <sys_open+0xc8>
      end_op();
    80004f20:	c2bfe0ef          	jal	80003b4a <end_op>
      return -1;
    80004f24:	557d                	li	a0,-1
    80004f26:	74aa                	ld	s1,168(sp)
    80004f28:	bf5d                	j	80004ede <sys_open+0xc8>
    iunlockput(ip);
    80004f2a:	8526                	mv	a0,s1
    80004f2c:	d28fe0ef          	jal	80003454 <iunlockput>
    end_op();
    80004f30:	c1bfe0ef          	jal	80003b4a <end_op>
    return -1;
    80004f34:	557d                	li	a0,-1
    80004f36:	74aa                	ld	s1,168(sp)
    80004f38:	b75d                	j	80004ede <sys_open+0xc8>
      fileclose(f);
    80004f3a:	854a                	mv	a0,s2
    80004f3c:	fbffe0ef          	jal	80003efa <fileclose>
    80004f40:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004f42:	8526                	mv	a0,s1
    80004f44:	d10fe0ef          	jal	80003454 <iunlockput>
    end_op();
    80004f48:	c03fe0ef          	jal	80003b4a <end_op>
    return -1;
    80004f4c:	557d                	li	a0,-1
    80004f4e:	74aa                	ld	s1,168(sp)
    80004f50:	790a                	ld	s2,160(sp)
    80004f52:	b771                	j	80004ede <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004f54:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004f58:	04649783          	lh	a5,70(s1)
    80004f5c:	02f91223          	sh	a5,36(s2)
    80004f60:	bf3d                	j	80004e9e <sys_open+0x88>
    itrunc(ip);
    80004f62:	8526                	mv	a0,s1
    80004f64:	bd4fe0ef          	jal	80003338 <itrunc>
    80004f68:	b795                	j	80004ecc <sys_open+0xb6>

0000000080004f6a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f6a:	7175                	addi	sp,sp,-144
    80004f6c:	e506                	sd	ra,136(sp)
    80004f6e:	e122                	sd	s0,128(sp)
    80004f70:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f72:	b6ffe0ef          	jal	80003ae0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f76:	08000613          	li	a2,128
    80004f7a:	f7040593          	addi	a1,s0,-144
    80004f7e:	4501                	li	a0,0
    80004f80:	8d7fd0ef          	jal	80002856 <argstr>
    80004f84:	02054363          	bltz	a0,80004faa <sys_mkdir+0x40>
    80004f88:	4681                	li	a3,0
    80004f8a:	4601                	li	a2,0
    80004f8c:	4585                	li	a1,1
    80004f8e:	f7040513          	addi	a0,s0,-144
    80004f92:	96fff0ef          	jal	80004900 <create>
    80004f96:	c911                	beqz	a0,80004faa <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f98:	cbcfe0ef          	jal	80003454 <iunlockput>
  end_op();
    80004f9c:	baffe0ef          	jal	80003b4a <end_op>
  return 0;
    80004fa0:	4501                	li	a0,0
}
    80004fa2:	60aa                	ld	ra,136(sp)
    80004fa4:	640a                	ld	s0,128(sp)
    80004fa6:	6149                	addi	sp,sp,144
    80004fa8:	8082                	ret
    end_op();
    80004faa:	ba1fe0ef          	jal	80003b4a <end_op>
    return -1;
    80004fae:	557d                	li	a0,-1
    80004fb0:	bfcd                	j	80004fa2 <sys_mkdir+0x38>

0000000080004fb2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004fb2:	7135                	addi	sp,sp,-160
    80004fb4:	ed06                	sd	ra,152(sp)
    80004fb6:	e922                	sd	s0,144(sp)
    80004fb8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004fba:	b27fe0ef          	jal	80003ae0 <begin_op>
  argint(1, &major);
    80004fbe:	f6c40593          	addi	a1,s0,-148
    80004fc2:	4505                	li	a0,1
    80004fc4:	85bfd0ef          	jal	8000281e <argint>
  argint(2, &minor);
    80004fc8:	f6840593          	addi	a1,s0,-152
    80004fcc:	4509                	li	a0,2
    80004fce:	851fd0ef          	jal	8000281e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004fd2:	08000613          	li	a2,128
    80004fd6:	f7040593          	addi	a1,s0,-144
    80004fda:	4501                	li	a0,0
    80004fdc:	87bfd0ef          	jal	80002856 <argstr>
    80004fe0:	02054563          	bltz	a0,8000500a <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004fe4:	f6841683          	lh	a3,-152(s0)
    80004fe8:	f6c41603          	lh	a2,-148(s0)
    80004fec:	458d                	li	a1,3
    80004fee:	f7040513          	addi	a0,s0,-144
    80004ff2:	90fff0ef          	jal	80004900 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004ff6:	c911                	beqz	a0,8000500a <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004ff8:	c5cfe0ef          	jal	80003454 <iunlockput>
  end_op();
    80004ffc:	b4ffe0ef          	jal	80003b4a <end_op>
  return 0;
    80005000:	4501                	li	a0,0
}
    80005002:	60ea                	ld	ra,152(sp)
    80005004:	644a                	ld	s0,144(sp)
    80005006:	610d                	addi	sp,sp,160
    80005008:	8082                	ret
    end_op();
    8000500a:	b41fe0ef          	jal	80003b4a <end_op>
    return -1;
    8000500e:	557d                	li	a0,-1
    80005010:	bfcd                	j	80005002 <sys_mknod+0x50>

0000000080005012 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005012:	7135                	addi	sp,sp,-160
    80005014:	ed06                	sd	ra,152(sp)
    80005016:	e922                	sd	s0,144(sp)
    80005018:	e14a                	sd	s2,128(sp)
    8000501a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000501c:	8c5fc0ef          	jal	800018e0 <myproc>
    80005020:	892a                	mv	s2,a0
  
  begin_op();
    80005022:	abffe0ef          	jal	80003ae0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005026:	08000613          	li	a2,128
    8000502a:	f6040593          	addi	a1,s0,-160
    8000502e:	4501                	li	a0,0
    80005030:	827fd0ef          	jal	80002856 <argstr>
    80005034:	04054363          	bltz	a0,8000507a <sys_chdir+0x68>
    80005038:	e526                	sd	s1,136(sp)
    8000503a:	f6040513          	addi	a0,s0,-160
    8000503e:	8e7fe0ef          	jal	80003924 <namei>
    80005042:	84aa                	mv	s1,a0
    80005044:	c915                	beqz	a0,80005078 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005046:	a04fe0ef          	jal	8000324a <ilock>
  if(ip->type != T_DIR){
    8000504a:	04449703          	lh	a4,68(s1)
    8000504e:	4785                	li	a5,1
    80005050:	02f71963          	bne	a4,a5,80005082 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005054:	8526                	mv	a0,s1
    80005056:	aa2fe0ef          	jal	800032f8 <iunlock>
  iput(p->cwd);
    8000505a:	15893503          	ld	a0,344(s2)
    8000505e:	b6efe0ef          	jal	800033cc <iput>
  end_op();
    80005062:	ae9fe0ef          	jal	80003b4a <end_op>
  p->cwd = ip;
    80005066:	14993c23          	sd	s1,344(s2)
  return 0;
    8000506a:	4501                	li	a0,0
    8000506c:	64aa                	ld	s1,136(sp)
}
    8000506e:	60ea                	ld	ra,152(sp)
    80005070:	644a                	ld	s0,144(sp)
    80005072:	690a                	ld	s2,128(sp)
    80005074:	610d                	addi	sp,sp,160
    80005076:	8082                	ret
    80005078:	64aa                	ld	s1,136(sp)
    end_op();
    8000507a:	ad1fe0ef          	jal	80003b4a <end_op>
    return -1;
    8000507e:	557d                	li	a0,-1
    80005080:	b7fd                	j	8000506e <sys_chdir+0x5c>
    iunlockput(ip);
    80005082:	8526                	mv	a0,s1
    80005084:	bd0fe0ef          	jal	80003454 <iunlockput>
    end_op();
    80005088:	ac3fe0ef          	jal	80003b4a <end_op>
    return -1;
    8000508c:	557d                	li	a0,-1
    8000508e:	64aa                	ld	s1,136(sp)
    80005090:	bff9                	j	8000506e <sys_chdir+0x5c>

0000000080005092 <sys_exec>:

uint64
sys_exec(void)
{
    80005092:	7121                	addi	sp,sp,-448
    80005094:	ff06                	sd	ra,440(sp)
    80005096:	fb22                	sd	s0,432(sp)
    80005098:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000509a:	e4840593          	addi	a1,s0,-440
    8000509e:	4505                	li	a0,1
    800050a0:	f9afd0ef          	jal	8000283a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800050a4:	08000613          	li	a2,128
    800050a8:	f5040593          	addi	a1,s0,-176
    800050ac:	4501                	li	a0,0
    800050ae:	fa8fd0ef          	jal	80002856 <argstr>
    800050b2:	87aa                	mv	a5,a0
    return -1;
    800050b4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050b6:	0c07c463          	bltz	a5,8000517e <sys_exec+0xec>
    800050ba:	f726                	sd	s1,424(sp)
    800050bc:	f34a                	sd	s2,416(sp)
    800050be:	ef4e                	sd	s3,408(sp)
    800050c0:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800050c2:	10000613          	li	a2,256
    800050c6:	4581                	li	a1,0
    800050c8:	e5040513          	addi	a0,s0,-432
    800050cc:	bfdfb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800050d0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800050d4:	89a6                	mv	s3,s1
    800050d6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800050d8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800050dc:	00391513          	slli	a0,s2,0x3
    800050e0:	e4040593          	addi	a1,s0,-448
    800050e4:	e4843783          	ld	a5,-440(s0)
    800050e8:	953e                	add	a0,a0,a5
    800050ea:	eaafd0ef          	jal	80002794 <fetchaddr>
    800050ee:	02054663          	bltz	a0,8000511a <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800050f2:	e4043783          	ld	a5,-448(s0)
    800050f6:	c3a9                	beqz	a5,80005138 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800050f8:	a2dfb0ef          	jal	80000b24 <kalloc>
    800050fc:	85aa                	mv	a1,a0
    800050fe:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005102:	cd01                	beqz	a0,8000511a <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005104:	6605                	lui	a2,0x1
    80005106:	e4043503          	ld	a0,-448(s0)
    8000510a:	ed4fd0ef          	jal	800027de <fetchstr>
    8000510e:	00054663          	bltz	a0,8000511a <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005112:	0905                	addi	s2,s2,1
    80005114:	09a1                	addi	s3,s3,8
    80005116:	fd4913e3          	bne	s2,s4,800050dc <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000511a:	f5040913          	addi	s2,s0,-176
    8000511e:	6088                	ld	a0,0(s1)
    80005120:	c931                	beqz	a0,80005174 <sys_exec+0xe2>
    kfree(argv[i]);
    80005122:	921fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005126:	04a1                	addi	s1,s1,8
    80005128:	ff249be3          	bne	s1,s2,8000511e <sys_exec+0x8c>
  return -1;
    8000512c:	557d                	li	a0,-1
    8000512e:	74ba                	ld	s1,424(sp)
    80005130:	791a                	ld	s2,416(sp)
    80005132:	69fa                	ld	s3,408(sp)
    80005134:	6a5a                	ld	s4,400(sp)
    80005136:	a0a1                	j	8000517e <sys_exec+0xec>
      argv[i] = 0;
    80005138:	0009079b          	sext.w	a5,s2
    8000513c:	078e                	slli	a5,a5,0x3
    8000513e:	fd078793          	addi	a5,a5,-48
    80005142:	97a2                	add	a5,a5,s0
    80005144:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005148:	e5040593          	addi	a1,s0,-432
    8000514c:	f5040513          	addi	a0,s0,-176
    80005150:	ba8ff0ef          	jal	800044f8 <exec>
    80005154:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005156:	f5040993          	addi	s3,s0,-176
    8000515a:	6088                	ld	a0,0(s1)
    8000515c:	c511                	beqz	a0,80005168 <sys_exec+0xd6>
    kfree(argv[i]);
    8000515e:	8e5fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005162:	04a1                	addi	s1,s1,8
    80005164:	ff349be3          	bne	s1,s3,8000515a <sys_exec+0xc8>
  return ret;
    80005168:	854a                	mv	a0,s2
    8000516a:	74ba                	ld	s1,424(sp)
    8000516c:	791a                	ld	s2,416(sp)
    8000516e:	69fa                	ld	s3,408(sp)
    80005170:	6a5a                	ld	s4,400(sp)
    80005172:	a031                	j	8000517e <sys_exec+0xec>
  return -1;
    80005174:	557d                	li	a0,-1
    80005176:	74ba                	ld	s1,424(sp)
    80005178:	791a                	ld	s2,416(sp)
    8000517a:	69fa                	ld	s3,408(sp)
    8000517c:	6a5a                	ld	s4,400(sp)
}
    8000517e:	70fa                	ld	ra,440(sp)
    80005180:	745a                	ld	s0,432(sp)
    80005182:	6139                	addi	sp,sp,448
    80005184:	8082                	ret

0000000080005186 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005186:	7139                	addi	sp,sp,-64
    80005188:	fc06                	sd	ra,56(sp)
    8000518a:	f822                	sd	s0,48(sp)
    8000518c:	f426                	sd	s1,40(sp)
    8000518e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005190:	f50fc0ef          	jal	800018e0 <myproc>
    80005194:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005196:	fd840593          	addi	a1,s0,-40
    8000519a:	4501                	li	a0,0
    8000519c:	e9efd0ef          	jal	8000283a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800051a0:	fc840593          	addi	a1,s0,-56
    800051a4:	fd040513          	addi	a0,s0,-48
    800051a8:	85cff0ef          	jal	80004204 <pipealloc>
    return -1;
    800051ac:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051ae:	0a054463          	bltz	a0,80005256 <sys_pipe+0xd0>
  fd0 = -1;
    800051b2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800051b6:	fd043503          	ld	a0,-48(s0)
    800051ba:	f08ff0ef          	jal	800048c2 <fdalloc>
    800051be:	fca42223          	sw	a0,-60(s0)
    800051c2:	08054163          	bltz	a0,80005244 <sys_pipe+0xbe>
    800051c6:	fc843503          	ld	a0,-56(s0)
    800051ca:	ef8ff0ef          	jal	800048c2 <fdalloc>
    800051ce:	fca42023          	sw	a0,-64(s0)
    800051d2:	06054063          	bltz	a0,80005232 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051d6:	4691                	li	a3,4
    800051d8:	fc440613          	addi	a2,s0,-60
    800051dc:	fd843583          	ld	a1,-40(s0)
    800051e0:	6ca8                	ld	a0,88(s1)
    800051e2:	b70fc0ef          	jal	80001552 <copyout>
    800051e6:	00054e63          	bltz	a0,80005202 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800051ea:	4691                	li	a3,4
    800051ec:	fc040613          	addi	a2,s0,-64
    800051f0:	fd843583          	ld	a1,-40(s0)
    800051f4:	0591                	addi	a1,a1,4
    800051f6:	6ca8                	ld	a0,88(s1)
    800051f8:	b5afc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800051fc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051fe:	04055c63          	bgez	a0,80005256 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005202:	fc442783          	lw	a5,-60(s0)
    80005206:	07e9                	addi	a5,a5,26
    80005208:	078e                	slli	a5,a5,0x3
    8000520a:	97a6                	add	a5,a5,s1
    8000520c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005210:	fc042783          	lw	a5,-64(s0)
    80005214:	07e9                	addi	a5,a5,26
    80005216:	078e                	slli	a5,a5,0x3
    80005218:	94be                	add	s1,s1,a5
    8000521a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000521e:	fd043503          	ld	a0,-48(s0)
    80005222:	cd9fe0ef          	jal	80003efa <fileclose>
    fileclose(wf);
    80005226:	fc843503          	ld	a0,-56(s0)
    8000522a:	cd1fe0ef          	jal	80003efa <fileclose>
    return -1;
    8000522e:	57fd                	li	a5,-1
    80005230:	a01d                	j	80005256 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005232:	fc442783          	lw	a5,-60(s0)
    80005236:	0007c763          	bltz	a5,80005244 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000523a:	07e9                	addi	a5,a5,26
    8000523c:	078e                	slli	a5,a5,0x3
    8000523e:	97a6                	add	a5,a5,s1
    80005240:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005244:	fd043503          	ld	a0,-48(s0)
    80005248:	cb3fe0ef          	jal	80003efa <fileclose>
    fileclose(wf);
    8000524c:	fc843503          	ld	a0,-56(s0)
    80005250:	cabfe0ef          	jal	80003efa <fileclose>
    return -1;
    80005254:	57fd                	li	a5,-1
}
    80005256:	853e                	mv	a0,a5
    80005258:	70e2                	ld	ra,56(sp)
    8000525a:	7442                	ld	s0,48(sp)
    8000525c:	74a2                	ld	s1,40(sp)
    8000525e:	6121                	addi	sp,sp,64
    80005260:	8082                	ret
	...

0000000080005270 <kernelvec>:
    80005270:	7111                	addi	sp,sp,-256
    80005272:	e006                	sd	ra,0(sp)
    80005274:	e40a                	sd	sp,8(sp)
    80005276:	e80e                	sd	gp,16(sp)
    80005278:	ec12                	sd	tp,24(sp)
    8000527a:	f016                	sd	t0,32(sp)
    8000527c:	f41a                	sd	t1,40(sp)
    8000527e:	f81e                	sd	t2,48(sp)
    80005280:	e4aa                	sd	a0,72(sp)
    80005282:	e8ae                	sd	a1,80(sp)
    80005284:	ecb2                	sd	a2,88(sp)
    80005286:	f0b6                	sd	a3,96(sp)
    80005288:	f4ba                	sd	a4,104(sp)
    8000528a:	f8be                	sd	a5,112(sp)
    8000528c:	fcc2                	sd	a6,120(sp)
    8000528e:	e146                	sd	a7,128(sp)
    80005290:	edf2                	sd	t3,216(sp)
    80005292:	f1f6                	sd	t4,224(sp)
    80005294:	f5fa                	sd	t5,232(sp)
    80005296:	f9fe                	sd	t6,240(sp)
    80005298:	c0cfd0ef          	jal	800026a4 <kerneltrap>
    8000529c:	6082                	ld	ra,0(sp)
    8000529e:	6122                	ld	sp,8(sp)
    800052a0:	61c2                	ld	gp,16(sp)
    800052a2:	7282                	ld	t0,32(sp)
    800052a4:	7322                	ld	t1,40(sp)
    800052a6:	73c2                	ld	t2,48(sp)
    800052a8:	6526                	ld	a0,72(sp)
    800052aa:	65c6                	ld	a1,80(sp)
    800052ac:	6666                	ld	a2,88(sp)
    800052ae:	7686                	ld	a3,96(sp)
    800052b0:	7726                	ld	a4,104(sp)
    800052b2:	77c6                	ld	a5,112(sp)
    800052b4:	7866                	ld	a6,120(sp)
    800052b6:	688a                	ld	a7,128(sp)
    800052b8:	6e6e                	ld	t3,216(sp)
    800052ba:	7e8e                	ld	t4,224(sp)
    800052bc:	7f2e                	ld	t5,232(sp)
    800052be:	7fce                	ld	t6,240(sp)
    800052c0:	6111                	addi	sp,sp,256
    800052c2:	10200073          	sret
	...

00000000800052ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800052ce:	1141                	addi	sp,sp,-16
    800052d0:	e422                	sd	s0,8(sp)
    800052d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800052d4:	0c0007b7          	lui	a5,0xc000
    800052d8:	4705                	li	a4,1
    800052da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800052dc:	0c0007b7          	lui	a5,0xc000
    800052e0:	c3d8                	sw	a4,4(a5)
}
    800052e2:	6422                	ld	s0,8(sp)
    800052e4:	0141                	addi	sp,sp,16
    800052e6:	8082                	ret

00000000800052e8 <plicinithart>:

void
plicinithart(void)
{
    800052e8:	1141                	addi	sp,sp,-16
    800052ea:	e406                	sd	ra,8(sp)
    800052ec:	e022                	sd	s0,0(sp)
    800052ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800052f0:	dc4fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800052f4:	0085171b          	slliw	a4,a0,0x8
    800052f8:	0c0027b7          	lui	a5,0xc002
    800052fc:	97ba                	add	a5,a5,a4
    800052fe:	40200713          	li	a4,1026
    80005302:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005306:	00d5151b          	slliw	a0,a0,0xd
    8000530a:	0c2017b7          	lui	a5,0xc201
    8000530e:	97aa                	add	a5,a5,a0
    80005310:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005314:	60a2                	ld	ra,8(sp)
    80005316:	6402                	ld	s0,0(sp)
    80005318:	0141                	addi	sp,sp,16
    8000531a:	8082                	ret

000000008000531c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000531c:	1141                	addi	sp,sp,-16
    8000531e:	e406                	sd	ra,8(sp)
    80005320:	e022                	sd	s0,0(sp)
    80005322:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005324:	d90fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005328:	00d5151b          	slliw	a0,a0,0xd
    8000532c:	0c2017b7          	lui	a5,0xc201
    80005330:	97aa                	add	a5,a5,a0
  return irq;
}
    80005332:	43c8                	lw	a0,4(a5)
    80005334:	60a2                	ld	ra,8(sp)
    80005336:	6402                	ld	s0,0(sp)
    80005338:	0141                	addi	sp,sp,16
    8000533a:	8082                	ret

000000008000533c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000533c:	1101                	addi	sp,sp,-32
    8000533e:	ec06                	sd	ra,24(sp)
    80005340:	e822                	sd	s0,16(sp)
    80005342:	e426                	sd	s1,8(sp)
    80005344:	1000                	addi	s0,sp,32
    80005346:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005348:	d6cfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000534c:	00d5151b          	slliw	a0,a0,0xd
    80005350:	0c2017b7          	lui	a5,0xc201
    80005354:	97aa                	add	a5,a5,a0
    80005356:	c3c4                	sw	s1,4(a5)
}
    80005358:	60e2                	ld	ra,24(sp)
    8000535a:	6442                	ld	s0,16(sp)
    8000535c:	64a2                	ld	s1,8(sp)
    8000535e:	6105                	addi	sp,sp,32
    80005360:	8082                	ret

0000000080005362 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005362:	1141                	addi	sp,sp,-16
    80005364:	e406                	sd	ra,8(sp)
    80005366:	e022                	sd	s0,0(sp)
    80005368:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000536a:	479d                	li	a5,7
    8000536c:	04a7ca63          	blt	a5,a0,800053c0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005370:	0001c797          	auipc	a5,0x1c
    80005374:	99078793          	addi	a5,a5,-1648 # 80020d00 <disk>
    80005378:	97aa                	add	a5,a5,a0
    8000537a:	0187c783          	lbu	a5,24(a5)
    8000537e:	e7b9                	bnez	a5,800053cc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005380:	00451693          	slli	a3,a0,0x4
    80005384:	0001c797          	auipc	a5,0x1c
    80005388:	97c78793          	addi	a5,a5,-1668 # 80020d00 <disk>
    8000538c:	6398                	ld	a4,0(a5)
    8000538e:	9736                	add	a4,a4,a3
    80005390:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005394:	6398                	ld	a4,0(a5)
    80005396:	9736                	add	a4,a4,a3
    80005398:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000539c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800053a0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800053a4:	97aa                	add	a5,a5,a0
    800053a6:	4705                	li	a4,1
    800053a8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800053ac:	0001c517          	auipc	a0,0x1c
    800053b0:	96c50513          	addi	a0,a0,-1684 # 80020d18 <disk+0x18>
    800053b4:	bd1fc0ef          	jal	80001f84 <wakeup>
}
    800053b8:	60a2                	ld	ra,8(sp)
    800053ba:	6402                	ld	s0,0(sp)
    800053bc:	0141                	addi	sp,sp,16
    800053be:	8082                	ret
    panic("free_desc 1");
    800053c0:	00002517          	auipc	a0,0x2
    800053c4:	2b050513          	addi	a0,a0,688 # 80007670 <etext+0x670>
    800053c8:	bccfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800053cc:	00002517          	auipc	a0,0x2
    800053d0:	2b450513          	addi	a0,a0,692 # 80007680 <etext+0x680>
    800053d4:	bc0fb0ef          	jal	80000794 <panic>

00000000800053d8 <virtio_disk_init>:
{
    800053d8:	1101                	addi	sp,sp,-32
    800053da:	ec06                	sd	ra,24(sp)
    800053dc:	e822                	sd	s0,16(sp)
    800053de:	e426                	sd	s1,8(sp)
    800053e0:	e04a                	sd	s2,0(sp)
    800053e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800053e4:	00002597          	auipc	a1,0x2
    800053e8:	2ac58593          	addi	a1,a1,684 # 80007690 <etext+0x690>
    800053ec:	0001c517          	auipc	a0,0x1c
    800053f0:	a3c50513          	addi	a0,a0,-1476 # 80020e28 <disk+0x128>
    800053f4:	f80fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053f8:	100017b7          	lui	a5,0x10001
    800053fc:	4398                	lw	a4,0(a5)
    800053fe:	2701                	sext.w	a4,a4
    80005400:	747277b7          	lui	a5,0x74727
    80005404:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005408:	18f71063          	bne	a4,a5,80005588 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000540c:	100017b7          	lui	a5,0x10001
    80005410:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005412:	439c                	lw	a5,0(a5)
    80005414:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005416:	4709                	li	a4,2
    80005418:	16e79863          	bne	a5,a4,80005588 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000541c:	100017b7          	lui	a5,0x10001
    80005420:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005422:	439c                	lw	a5,0(a5)
    80005424:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005426:	16e79163          	bne	a5,a4,80005588 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000542a:	100017b7          	lui	a5,0x10001
    8000542e:	47d8                	lw	a4,12(a5)
    80005430:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005432:	554d47b7          	lui	a5,0x554d4
    80005436:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000543a:	14f71763          	bne	a4,a5,80005588 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000543e:	100017b7          	lui	a5,0x10001
    80005442:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005446:	4705                	li	a4,1
    80005448:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000544a:	470d                	li	a4,3
    8000544c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000544e:	10001737          	lui	a4,0x10001
    80005452:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005454:	c7ffe737          	lui	a4,0xc7ffe
    80005458:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd91f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000545c:	8ef9                	and	a3,a3,a4
    8000545e:	10001737          	lui	a4,0x10001
    80005462:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005464:	472d                	li	a4,11
    80005466:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005468:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000546c:	439c                	lw	a5,0(a5)
    8000546e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005472:	8ba1                	andi	a5,a5,8
    80005474:	12078063          	beqz	a5,80005594 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005478:	100017b7          	lui	a5,0x10001
    8000547c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005480:	100017b7          	lui	a5,0x10001
    80005484:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005488:	439c                	lw	a5,0(a5)
    8000548a:	2781                	sext.w	a5,a5
    8000548c:	10079a63          	bnez	a5,800055a0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005490:	100017b7          	lui	a5,0x10001
    80005494:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005498:	439c                	lw	a5,0(a5)
    8000549a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000549c:	10078863          	beqz	a5,800055ac <virtio_disk_init+0x1d4>
  if(max < NUM)
    800054a0:	471d                	li	a4,7
    800054a2:	10f77b63          	bgeu	a4,a5,800055b8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800054a6:	e7efb0ef          	jal	80000b24 <kalloc>
    800054aa:	0001c497          	auipc	s1,0x1c
    800054ae:	85648493          	addi	s1,s1,-1962 # 80020d00 <disk>
    800054b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800054b4:	e70fb0ef          	jal	80000b24 <kalloc>
    800054b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800054ba:	e6afb0ef          	jal	80000b24 <kalloc>
    800054be:	87aa                	mv	a5,a0
    800054c0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800054c2:	6088                	ld	a0,0(s1)
    800054c4:	10050063          	beqz	a0,800055c4 <virtio_disk_init+0x1ec>
    800054c8:	0001c717          	auipc	a4,0x1c
    800054cc:	84073703          	ld	a4,-1984(a4) # 80020d08 <disk+0x8>
    800054d0:	0e070a63          	beqz	a4,800055c4 <virtio_disk_init+0x1ec>
    800054d4:	0e078863          	beqz	a5,800055c4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800054d8:	6605                	lui	a2,0x1
    800054da:	4581                	li	a1,0
    800054dc:	fecfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800054e0:	0001c497          	auipc	s1,0x1c
    800054e4:	82048493          	addi	s1,s1,-2016 # 80020d00 <disk>
    800054e8:	6605                	lui	a2,0x1
    800054ea:	4581                	li	a1,0
    800054ec:	6488                	ld	a0,8(s1)
    800054ee:	fdafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    800054f2:	6605                	lui	a2,0x1
    800054f4:	4581                	li	a1,0
    800054f6:	6888                	ld	a0,16(s1)
    800054f8:	fd0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800054fc:	100017b7          	lui	a5,0x10001
    80005500:	4721                	li	a4,8
    80005502:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005504:	4098                	lw	a4,0(s1)
    80005506:	100017b7          	lui	a5,0x10001
    8000550a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000550e:	40d8                	lw	a4,4(s1)
    80005510:	100017b7          	lui	a5,0x10001
    80005514:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005518:	649c                	ld	a5,8(s1)
    8000551a:	0007869b          	sext.w	a3,a5
    8000551e:	10001737          	lui	a4,0x10001
    80005522:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005526:	9781                	srai	a5,a5,0x20
    80005528:	10001737          	lui	a4,0x10001
    8000552c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005530:	689c                	ld	a5,16(s1)
    80005532:	0007869b          	sext.w	a3,a5
    80005536:	10001737          	lui	a4,0x10001
    8000553a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000553e:	9781                	srai	a5,a5,0x20
    80005540:	10001737          	lui	a4,0x10001
    80005544:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005548:	10001737          	lui	a4,0x10001
    8000554c:	4785                	li	a5,1
    8000554e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005550:	00f48c23          	sb	a5,24(s1)
    80005554:	00f48ca3          	sb	a5,25(s1)
    80005558:	00f48d23          	sb	a5,26(s1)
    8000555c:	00f48da3          	sb	a5,27(s1)
    80005560:	00f48e23          	sb	a5,28(s1)
    80005564:	00f48ea3          	sb	a5,29(s1)
    80005568:	00f48f23          	sb	a5,30(s1)
    8000556c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005570:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005574:	100017b7          	lui	a5,0x10001
    80005578:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000557c:	60e2                	ld	ra,24(sp)
    8000557e:	6442                	ld	s0,16(sp)
    80005580:	64a2                	ld	s1,8(sp)
    80005582:	6902                	ld	s2,0(sp)
    80005584:	6105                	addi	sp,sp,32
    80005586:	8082                	ret
    panic("could not find virtio disk");
    80005588:	00002517          	auipc	a0,0x2
    8000558c:	11850513          	addi	a0,a0,280 # 800076a0 <etext+0x6a0>
    80005590:	a04fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005594:	00002517          	auipc	a0,0x2
    80005598:	12c50513          	addi	a0,a0,300 # 800076c0 <etext+0x6c0>
    8000559c:	9f8fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800055a0:	00002517          	auipc	a0,0x2
    800055a4:	14050513          	addi	a0,a0,320 # 800076e0 <etext+0x6e0>
    800055a8:	9ecfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800055ac:	00002517          	auipc	a0,0x2
    800055b0:	15450513          	addi	a0,a0,340 # 80007700 <etext+0x700>
    800055b4:	9e0fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800055b8:	00002517          	auipc	a0,0x2
    800055bc:	16850513          	addi	a0,a0,360 # 80007720 <etext+0x720>
    800055c0:	9d4fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    800055c4:	00002517          	auipc	a0,0x2
    800055c8:	17c50513          	addi	a0,a0,380 # 80007740 <etext+0x740>
    800055cc:	9c8fb0ef          	jal	80000794 <panic>

00000000800055d0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800055d0:	7159                	addi	sp,sp,-112
    800055d2:	f486                	sd	ra,104(sp)
    800055d4:	f0a2                	sd	s0,96(sp)
    800055d6:	eca6                	sd	s1,88(sp)
    800055d8:	e8ca                	sd	s2,80(sp)
    800055da:	e4ce                	sd	s3,72(sp)
    800055dc:	e0d2                	sd	s4,64(sp)
    800055de:	fc56                	sd	s5,56(sp)
    800055e0:	f85a                	sd	s6,48(sp)
    800055e2:	f45e                	sd	s7,40(sp)
    800055e4:	f062                	sd	s8,32(sp)
    800055e6:	ec66                	sd	s9,24(sp)
    800055e8:	1880                	addi	s0,sp,112
    800055ea:	8a2a                	mv	s4,a0
    800055ec:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800055ee:	00c52c83          	lw	s9,12(a0)
    800055f2:	001c9c9b          	slliw	s9,s9,0x1
    800055f6:	1c82                	slli	s9,s9,0x20
    800055f8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800055fc:	0001c517          	auipc	a0,0x1c
    80005600:	82c50513          	addi	a0,a0,-2004 # 80020e28 <disk+0x128>
    80005604:	df0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005608:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000560a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000560c:	0001bb17          	auipc	s6,0x1b
    80005610:	6f4b0b13          	addi	s6,s6,1780 # 80020d00 <disk>
  for(int i = 0; i < 3; i++){
    80005614:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005616:	0001cc17          	auipc	s8,0x1c
    8000561a:	812c0c13          	addi	s8,s8,-2030 # 80020e28 <disk+0x128>
    8000561e:	a8b9                	j	8000567c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005620:	00fb0733          	add	a4,s6,a5
    80005624:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005628:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000562a:	0207c563          	bltz	a5,80005654 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000562e:	2905                	addiw	s2,s2,1
    80005630:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005632:	05590963          	beq	s2,s5,80005684 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005636:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005638:	0001b717          	auipc	a4,0x1b
    8000563c:	6c870713          	addi	a4,a4,1736 # 80020d00 <disk>
    80005640:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005642:	01874683          	lbu	a3,24(a4)
    80005646:	fee9                	bnez	a3,80005620 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005648:	2785                	addiw	a5,a5,1
    8000564a:	0705                	addi	a4,a4,1
    8000564c:	fe979be3          	bne	a5,s1,80005642 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005650:	57fd                	li	a5,-1
    80005652:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005654:	01205d63          	blez	s2,8000566e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005658:	f9042503          	lw	a0,-112(s0)
    8000565c:	d07ff0ef          	jal	80005362 <free_desc>
      for(int j = 0; j < i; j++)
    80005660:	4785                	li	a5,1
    80005662:	0127d663          	bge	a5,s2,8000566e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005666:	f9442503          	lw	a0,-108(s0)
    8000566a:	cf9ff0ef          	jal	80005362 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000566e:	85e2                	mv	a1,s8
    80005670:	0001b517          	auipc	a0,0x1b
    80005674:	6a850513          	addi	a0,a0,1704 # 80020d18 <disk+0x18>
    80005678:	8c1fc0ef          	jal	80001f38 <sleep>
  for(int i = 0; i < 3; i++){
    8000567c:	f9040613          	addi	a2,s0,-112
    80005680:	894e                	mv	s2,s3
    80005682:	bf55                	j	80005636 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005684:	f9042503          	lw	a0,-112(s0)
    80005688:	00451693          	slli	a3,a0,0x4

  if(write)
    8000568c:	0001b797          	auipc	a5,0x1b
    80005690:	67478793          	addi	a5,a5,1652 # 80020d00 <disk>
    80005694:	00a50713          	addi	a4,a0,10
    80005698:	0712                	slli	a4,a4,0x4
    8000569a:	973e                	add	a4,a4,a5
    8000569c:	01703633          	snez	a2,s7
    800056a0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800056a2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800056a6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800056aa:	6398                	ld	a4,0(a5)
    800056ac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056ae:	0a868613          	addi	a2,a3,168
    800056b2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800056b4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800056b6:	6390                	ld	a2,0(a5)
    800056b8:	00d605b3          	add	a1,a2,a3
    800056bc:	4741                	li	a4,16
    800056be:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800056c0:	4805                	li	a6,1
    800056c2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800056c6:	f9442703          	lw	a4,-108(s0)
    800056ca:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800056ce:	0712                	slli	a4,a4,0x4
    800056d0:	963a                	add	a2,a2,a4
    800056d2:	058a0593          	addi	a1,s4,88
    800056d6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800056d8:	0007b883          	ld	a7,0(a5)
    800056dc:	9746                	add	a4,a4,a7
    800056de:	40000613          	li	a2,1024
    800056e2:	c710                	sw	a2,8(a4)
  if(write)
    800056e4:	001bb613          	seqz	a2,s7
    800056e8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800056ec:	00166613          	ori	a2,a2,1
    800056f0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800056f4:	f9842583          	lw	a1,-104(s0)
    800056f8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800056fc:	00250613          	addi	a2,a0,2
    80005700:	0612                	slli	a2,a2,0x4
    80005702:	963e                	add	a2,a2,a5
    80005704:	577d                	li	a4,-1
    80005706:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000570a:	0592                	slli	a1,a1,0x4
    8000570c:	98ae                	add	a7,a7,a1
    8000570e:	03068713          	addi	a4,a3,48
    80005712:	973e                	add	a4,a4,a5
    80005714:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005718:	6398                	ld	a4,0(a5)
    8000571a:	972e                	add	a4,a4,a1
    8000571c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005720:	4689                	li	a3,2
    80005722:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005726:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000572a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000572e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005732:	6794                	ld	a3,8(a5)
    80005734:	0026d703          	lhu	a4,2(a3)
    80005738:	8b1d                	andi	a4,a4,7
    8000573a:	0706                	slli	a4,a4,0x1
    8000573c:	96ba                	add	a3,a3,a4
    8000573e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005742:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005746:	6798                	ld	a4,8(a5)
    80005748:	00275783          	lhu	a5,2(a4)
    8000574c:	2785                	addiw	a5,a5,1
    8000574e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005752:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005756:	100017b7          	lui	a5,0x10001
    8000575a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000575e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005762:	0001b917          	auipc	s2,0x1b
    80005766:	6c690913          	addi	s2,s2,1734 # 80020e28 <disk+0x128>
  while(b->disk == 1) {
    8000576a:	4485                	li	s1,1
    8000576c:	01079a63          	bne	a5,a6,80005780 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005770:	85ca                	mv	a1,s2
    80005772:	8552                	mv	a0,s4
    80005774:	fc4fc0ef          	jal	80001f38 <sleep>
  while(b->disk == 1) {
    80005778:	004a2783          	lw	a5,4(s4)
    8000577c:	fe978ae3          	beq	a5,s1,80005770 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005780:	f9042903          	lw	s2,-112(s0)
    80005784:	00290713          	addi	a4,s2,2
    80005788:	0712                	slli	a4,a4,0x4
    8000578a:	0001b797          	auipc	a5,0x1b
    8000578e:	57678793          	addi	a5,a5,1398 # 80020d00 <disk>
    80005792:	97ba                	add	a5,a5,a4
    80005794:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005798:	0001b997          	auipc	s3,0x1b
    8000579c:	56898993          	addi	s3,s3,1384 # 80020d00 <disk>
    800057a0:	00491713          	slli	a4,s2,0x4
    800057a4:	0009b783          	ld	a5,0(s3)
    800057a8:	97ba                	add	a5,a5,a4
    800057aa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800057ae:	854a                	mv	a0,s2
    800057b0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057b4:	bafff0ef          	jal	80005362 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800057b8:	8885                	andi	s1,s1,1
    800057ba:	f0fd                	bnez	s1,800057a0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057bc:	0001b517          	auipc	a0,0x1b
    800057c0:	66c50513          	addi	a0,a0,1644 # 80020e28 <disk+0x128>
    800057c4:	cc8fb0ef          	jal	80000c8c <release>
}
    800057c8:	70a6                	ld	ra,104(sp)
    800057ca:	7406                	ld	s0,96(sp)
    800057cc:	64e6                	ld	s1,88(sp)
    800057ce:	6946                	ld	s2,80(sp)
    800057d0:	69a6                	ld	s3,72(sp)
    800057d2:	6a06                	ld	s4,64(sp)
    800057d4:	7ae2                	ld	s5,56(sp)
    800057d6:	7b42                	ld	s6,48(sp)
    800057d8:	7ba2                	ld	s7,40(sp)
    800057da:	7c02                	ld	s8,32(sp)
    800057dc:	6ce2                	ld	s9,24(sp)
    800057de:	6165                	addi	sp,sp,112
    800057e0:	8082                	ret

00000000800057e2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800057e2:	1101                	addi	sp,sp,-32
    800057e4:	ec06                	sd	ra,24(sp)
    800057e6:	e822                	sd	s0,16(sp)
    800057e8:	e426                	sd	s1,8(sp)
    800057ea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800057ec:	0001b497          	auipc	s1,0x1b
    800057f0:	51448493          	addi	s1,s1,1300 # 80020d00 <disk>
    800057f4:	0001b517          	auipc	a0,0x1b
    800057f8:	63450513          	addi	a0,a0,1588 # 80020e28 <disk+0x128>
    800057fc:	bf8fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005800:	100017b7          	lui	a5,0x10001
    80005804:	53b8                	lw	a4,96(a5)
    80005806:	8b0d                	andi	a4,a4,3
    80005808:	100017b7          	lui	a5,0x10001
    8000580c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000580e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005812:	689c                	ld	a5,16(s1)
    80005814:	0204d703          	lhu	a4,32(s1)
    80005818:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000581c:	04f70663          	beq	a4,a5,80005868 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005820:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005824:	6898                	ld	a4,16(s1)
    80005826:	0204d783          	lhu	a5,32(s1)
    8000582a:	8b9d                	andi	a5,a5,7
    8000582c:	078e                	slli	a5,a5,0x3
    8000582e:	97ba                	add	a5,a5,a4
    80005830:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005832:	00278713          	addi	a4,a5,2
    80005836:	0712                	slli	a4,a4,0x4
    80005838:	9726                	add	a4,a4,s1
    8000583a:	01074703          	lbu	a4,16(a4)
    8000583e:	e321                	bnez	a4,8000587e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005840:	0789                	addi	a5,a5,2
    80005842:	0792                	slli	a5,a5,0x4
    80005844:	97a6                	add	a5,a5,s1
    80005846:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005848:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000584c:	f38fc0ef          	jal	80001f84 <wakeup>

    disk.used_idx += 1;
    80005850:	0204d783          	lhu	a5,32(s1)
    80005854:	2785                	addiw	a5,a5,1
    80005856:	17c2                	slli	a5,a5,0x30
    80005858:	93c1                	srli	a5,a5,0x30
    8000585a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000585e:	6898                	ld	a4,16(s1)
    80005860:	00275703          	lhu	a4,2(a4)
    80005864:	faf71ee3          	bne	a4,a5,80005820 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005868:	0001b517          	auipc	a0,0x1b
    8000586c:	5c050513          	addi	a0,a0,1472 # 80020e28 <disk+0x128>
    80005870:	c1cfb0ef          	jal	80000c8c <release>
}
    80005874:	60e2                	ld	ra,24(sp)
    80005876:	6442                	ld	s0,16(sp)
    80005878:	64a2                	ld	s1,8(sp)
    8000587a:	6105                	addi	sp,sp,32
    8000587c:	8082                	ret
      panic("virtio_disk_intr status");
    8000587e:	00002517          	auipc	a0,0x2
    80005882:	eda50513          	addi	a0,a0,-294 # 80007758 <etext+0x758>
    80005886:	f0ffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
