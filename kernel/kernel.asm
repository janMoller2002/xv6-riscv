
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	95010113          	addi	sp,sp,-1712 # 80007950 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddb7f>
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
    800000fa:	15a020ef          	jal	80002254 <either_copyin>
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
    80000158:	7fc50513          	addi	a0,a0,2044 # 8000f950 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	0000f497          	auipc	s1,0xf
    80000164:	7f048493          	addi	s1,s1,2032 # 8000f950 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	88090913          	addi	s2,s2,-1920 # 8000f9e8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	763010ef          	jal	800020e6 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	521010ef          	jal	80001eae <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	0000f717          	auipc	a4,0xf
    800001a4:	7b070713          	addi	a4,a4,1968 # 8000f950 <cons>
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
    800001d2:	038020ef          	jal	8000220a <either_copyout>
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
    800001ee:	76650513          	addi	a0,a0,1894 # 8000f950 <cons>
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
    80000218:	7cf72a23          	sw	a5,2004(a4) # 8000f9e8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	0000f517          	auipc	a0,0xf
    8000022e:	72650513          	addi	a0,a0,1830 # 8000f950 <cons>
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
    80000282:	6d250513          	addi	a0,a0,1746 # 8000f950 <cons>
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
    800002a0:	7ff010ef          	jal	8000229e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	6ac50513          	addi	a0,a0,1708 # 8000f950 <cons>
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
    800002c6:	68e70713          	addi	a4,a4,1678 # 8000f950 <cons>
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
    800002ec:	66878793          	addi	a5,a5,1640 # 8000f950 <cons>
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
    8000031a:	6d27a783          	lw	a5,1746(a5) # 8000f9e8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	62470713          	addi	a4,a4,1572 # 8000f950 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	61448493          	addi	s1,s1,1556 # 8000f950 <cons>
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
    80000382:	5d270713          	addi	a4,a4,1490 # 8000f950 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	64f72e23          	sw	a5,1628(a4) # 8000f9f0 <cons+0xa0>
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
    800003b6:	59e78793          	addi	a5,a5,1438 # 8000f950 <cons>
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
    800003da:	60c7ab23          	sw	a2,1558(a5) # 8000f9ec <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	60a50513          	addi	a0,a0,1546 # 8000f9e8 <cons+0x98>
    800003e6:	315010ef          	jal	80001efa <wakeup>
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
    80000400:	55450513          	addi	a0,a0,1364 # 8000f950 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	0001f797          	auipc	a5,0x1f
    80000410:	6dc78793          	addi	a5,a5,1756 # 8001fae8 <devsw>
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
    8000044a:	35a60613          	addi	a2,a2,858 # 800077a0 <digits>
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
    800004e4:	5307a783          	lw	a5,1328(a5) # 8000fa10 <pr+0x18>
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
    80000530:	4cc50513          	addi	a0,a0,1228 # 8000f9f8 <pr>
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
    800006f0:	0b4b8b93          	addi	s7,s7,180 # 800077a0 <digits>
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
    8000078a:	27250513          	addi	a0,a0,626 # 8000f9f8 <pr>
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
    800007a4:	2607a823          	sw	zero,624(a5) # 8000fa10 <pr+0x18>
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
    800007c8:	14f72623          	sw	a5,332(a4) # 80007910 <panicked>
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
    800007dc:	22048493          	addi	s1,s1,544 # 8000f9f8 <pr>
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
    80000844:	1d850513          	addi	a0,a0,472 # 8000fa18 <uart_tx_lock>
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
    80000868:	0ac7a783          	lw	a5,172(a5) # 80007910 <panicked>
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
    8000089e:	07e7b783          	ld	a5,126(a5) # 80007918 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	07e73703          	ld	a4,126(a4) # 80007920 <uart_tx_w>
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
    800008cc:	150a8a93          	addi	s5,s5,336 # 8000fa18 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	04848493          	addi	s1,s1,72 # 80007918 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	04498993          	addi	s3,s3,68 # 80007920 <uart_tx_w>
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
    800008fe:	5fc010ef          	jal	80001efa <wakeup>
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
    80000950:	0cc50513          	addi	a0,a0,204 # 8000fa18 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	fb87a783          	lw	a5,-72(a5) # 80007910 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	fbe73703          	ld	a4,-66(a4) # 80007920 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	fae7b783          	ld	a5,-82(a5) # 80007918 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	0a298993          	addi	s3,s3,162 # 8000fa18 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	f9a48493          	addi	s1,s1,-102 # 80007918 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	f9a90913          	addi	s2,s2,-102 # 80007920 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	518010ef          	jal	80001eae <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	07048493          	addi	s1,s1,112 # 8000fa18 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	f6e7b223          	sd	a4,-156(a5) # 80007920 <uart_tx_w>
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
    80000a24:	ff848493          	addi	s1,s1,-8 # 8000fa18 <uart_tx_lock>
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
    80000a5a:	22a78793          	addi	a5,a5,554 # 80020c80 <end>
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
    80000a76:	fde90913          	addi	s2,s2,-34 # 8000fa50 <kmem>
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
    80000b04:	f5050513          	addi	a0,a0,-176 # 8000fa50 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	17050513          	addi	a0,a0,368 # 80020c80 <end>
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
    80000b32:	f2248493          	addi	s1,s1,-222 # 8000fa50 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	f0e50513          	addi	a0,a0,-242 # 8000fa50 <kmem>
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
    80000b6a:	eea50513          	addi	a0,a0,-278 # 8000fa50 <kmem>
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
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde381>
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
    80000e72:	aba70713          	addi	a4,a4,-1350 # 80007928 <started>
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
    80000e98:	538010ef          	jal	800023d0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	51c040ef          	jal	800053b8 <plicinithart>
  }

  scheduler();        
    80000ea0:	675000ef          	jal	80001d14 <scheduler>
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
    80000ee0:	4cc010ef          	jal	800023ac <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	4ec010ef          	jal	800023d0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	4b6040ef          	jal	8000539e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	4cc040ef          	jal	800053b8 <plicinithart>
    binit();         // buffer cache
    80000ef0:	477010ef          	jal	80002b66 <binit>
    iinit();         // inode table
    80000ef4:	268020ef          	jal	8000315c <iinit>
    fileinit();      // file table
    80000ef8:	014030ef          	jal	80003f0c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	5ac040ef          	jal	800054a8 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	449000ef          	jal	80001b48 <userinit>
    __sync_synchronize();
    80000f04:	0ff0000f          	fence
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00007717          	auipc	a4,0x7
    80000f0e:	a0f72f23          	sw	a5,-1506(a4) # 80007928 <started>
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
    80000f22:	a127b783          	ld	a5,-1518(a5) # 80007930 <kernel_pagetable>
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
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde377>
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
    800011ae:	78a7b323          	sd	a0,1926(a5) # 80007930 <kernel_pagetable>
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
    80001780:	72448493          	addi	s1,s1,1828 # 8000fea0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	04fa5937          	lui	s2,0x4fa5
    8000178a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000178e:	0932                	slli	s2,s2,0xc
    80001790:	fa590913          	addi	s2,s2,-91
    80001794:	0932                	slli	s2,s2,0xc
    80001796:	fa590913          	addi	s2,s2,-91
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	fa590913          	addi	s2,s2,-91
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00014a97          	auipc	s5,0x14
    800017ac:	0f8a8a93          	addi	s5,s5,248 # 800158a0 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	858d                	srai	a1,a1,0x3
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
    800017d6:	16848493          	addi	s1,s1,360
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
    8000181e:	25650513          	addi	a0,a0,598 # 8000fa70 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	0000e517          	auipc	a0,0xe
    80001832:	25a50513          	addi	a0,a0,602 # 8000fa88 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	0000e497          	auipc	s1,0xe
    8000183e:	66648493          	addi	s1,s1,1638 # 8000fea0 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	04fa5937          	lui	s2,0x4fa5
    80001850:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001854:	0932                	slli	s2,s2,0xc
    80001856:	fa590913          	addi	s2,s2,-91
    8000185a:	0932                	slli	s2,s2,0xc
    8000185c:	fa590913          	addi	s2,s2,-91
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	fa590913          	addi	s2,s2,-91
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00014a17          	auipc	s4,0x14
    80001872:	032a0a13          	addi	s4,s4,50 # 800158a0 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	878d                	srai	a5,a5,0x3
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	16848493          	addi	s1,s1,360
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
    800018d4:	1d050513          	addi	a0,a0,464 # 8000faa0 <cpus>
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
    800018f8:	17c70713          	addi	a4,a4,380 # 8000fa70 <pid_lock>
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
    80001924:	fa07a783          	lw	a5,-96(a5) # 800078c0 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	2bf000ef          	jal	800023e8 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	7b8010ef          	jal	800030f0 <fsinit>
    first = 0;
    8000193c:	00006797          	auipc	a5,0x6
    80001940:	f807a223          	sw	zero,-124(a5) # 800078c0 <first.1>
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
    8000195a:	11a90913          	addi	s2,s2,282 # 8000fa70 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00006797          	auipc	a5,0x6
    80001968:	f6078793          	addi	a5,a5,-160 # 800078c4 <nextpid>
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
    800019bc:	05893683          	ld	a3,88(s2)
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
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
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
    80001ab2:	3f248493          	addi	s1,s1,1010 # 8000fea0 <proc>
    80001ab6:	00014917          	auipc	s2,0x14
    80001aba:	dea90913          	addi	s2,s2,-534 # 800158a0 <tickslock>
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
    80001ace:	16848493          	addi	s1,s1,360
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a089                	j	80001b1a <allocproc+0x78>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae4:	840ff0ef          	jal	80000b24 <kalloc>
    80001ae8:	892a                	mv	s2,a0
    80001aea:	eca8                	sd	a0,88(s1)
    80001aec:	cd15                	beqz	a0,80001b28 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001aee:	8526                	mv	a0,s1
    80001af0:	e99ff0ef          	jal	80001988 <proc_pagetable>
    80001af4:	892a                	mv	s2,a0
    80001af6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001af8:	c121                	beqz	a0,80001b38 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001afa:	07000613          	li	a2,112
    80001afe:	4581                	li	a1,0
    80001b00:	06048513          	addi	a0,s1,96
    80001b04:	9c4ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b08:	00000797          	auipc	a5,0x0
    80001b0c:	e0878793          	addi	a5,a5,-504 # 80001910 <forkret>
    80001b10:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b12:	60bc                	ld	a5,64(s1)
    80001b14:	6705                	lui	a4,0x1
    80001b16:	97ba                	add	a5,a5,a4
    80001b18:	f4bc                	sd	a5,104(s1)
}
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6902                	ld	s2,0(sp)
    80001b24:	6105                	addi	sp,sp,32
    80001b26:	8082                	ret
    freeproc(p);
    80001b28:	8526                	mv	a0,s1
    80001b2a:	f29ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	95cff0ef          	jal	80000c8c <release>
    return 0;
    80001b34:	84ca                	mv	s1,s2
    80001b36:	b7d5                	j	80001b1a <allocproc+0x78>
    freeproc(p);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	f19ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	94cff0ef          	jal	80000c8c <release>
    return 0;
    80001b44:	84ca                	mv	s1,s2
    80001b46:	bfd1                	j	80001b1a <allocproc+0x78>

0000000080001b48 <userinit>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b52:	f51ff0ef          	jal	80001aa2 <allocproc>
    80001b56:	84aa                	mv	s1,a0
  initproc = p;
    80001b58:	00006797          	auipc	a5,0x6
    80001b5c:	dea7b023          	sd	a0,-544(a5) # 80007938 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b60:	03400613          	li	a2,52
    80001b64:	00006597          	auipc	a1,0x6
    80001b68:	d6c58593          	addi	a1,a1,-660 # 800078d0 <initcode>
    80001b6c:	6928                	ld	a0,80(a0)
    80001b6e:	f2eff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b72:	6785                	lui	a5,0x1
    80001b74:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b76:	6cb8                	ld	a4,88(s1)
    80001b78:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b7c:	6cb8                	ld	a4,88(s1)
    80001b7e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b80:	4641                	li	a2,16
    80001b82:	00005597          	auipc	a1,0x5
    80001b86:	69e58593          	addi	a1,a1,1694 # 80007220 <etext+0x220>
    80001b8a:	15848513          	addi	a0,s1,344
    80001b8e:	a78ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b92:	00005517          	auipc	a0,0x5
    80001b96:	69e50513          	addi	a0,a0,1694 # 80007230 <etext+0x230>
    80001b9a:	665010ef          	jal	800039fe <namei>
    80001b9e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ba2:	478d                	li	a5,3
    80001ba4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	8e4ff0ef          	jal	80000c8c <release>
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <growproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
    80001bc2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc4:	d1dff0ef          	jal	800018e0 <myproc>
    80001bc8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bca:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bcc:	01204c63          	bgtz	s2,80001be4 <growproc+0x2e>
  } else if(n < 0){
    80001bd0:	02094463          	bltz	s2,80001bf8 <growproc+0x42>
  p->sz = sz;
    80001bd4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bd6:	4501                	li	a0,0
}
    80001bd8:	60e2                	ld	ra,24(sp)
    80001bda:	6442                	ld	s0,16(sp)
    80001bdc:	64a2                	ld	s1,8(sp)
    80001bde:	6902                	ld	s2,0(sp)
    80001be0:	6105                	addi	sp,sp,32
    80001be2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be4:	4691                	li	a3,4
    80001be6:	00b90633          	add	a2,s2,a1
    80001bea:	6928                	ld	a0,80(a0)
    80001bec:	f52ff0ef          	jal	8000133e <uvmalloc>
    80001bf0:	85aa                	mv	a1,a0
    80001bf2:	f16d                	bnez	a0,80001bd4 <growproc+0x1e>
      return -1;
    80001bf4:	557d                	li	a0,-1
    80001bf6:	b7cd                	j	80001bd8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf8:	00b90633          	add	a2,s2,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	efcff0ef          	jal	800012fa <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bfc1                	j	80001bd4 <growproc+0x1e>

0000000080001c06 <fork>:
{
    80001c06:	7139                	addi	sp,sp,-64
    80001c08:	fc06                	sd	ra,56(sp)
    80001c0a:	f822                	sd	s0,48(sp)
    80001c0c:	f04a                	sd	s2,32(sp)
    80001c0e:	e456                	sd	s5,8(sp)
    80001c10:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c12:	ccfff0ef          	jal	800018e0 <myproc>
    80001c16:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c18:	e8bff0ef          	jal	80001aa2 <allocproc>
    80001c1c:	0e050a63          	beqz	a0,80001d10 <fork+0x10a>
    80001c20:	e852                	sd	s4,16(sp)
    80001c22:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c24:	048ab603          	ld	a2,72(s5)
    80001c28:	692c                	ld	a1,80(a0)
    80001c2a:	050ab503          	ld	a0,80(s5)
    80001c2e:	849ff0ef          	jal	80001476 <uvmcopy>
    80001c32:	04054a63          	bltz	a0,80001c86 <fork+0x80>
    80001c36:	f426                	sd	s1,40(sp)
    80001c38:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c3a:	048ab783          	ld	a5,72(s5)
    80001c3e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c42:	058ab683          	ld	a3,88(s5)
    80001c46:	87b6                	mv	a5,a3
    80001c48:	058a3703          	ld	a4,88(s4)
    80001c4c:	12068693          	addi	a3,a3,288
    80001c50:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c54:	6788                	ld	a0,8(a5)
    80001c56:	6b8c                	ld	a1,16(a5)
    80001c58:	6f90                	ld	a2,24(a5)
    80001c5a:	01073023          	sd	a6,0(a4)
    80001c5e:	e708                	sd	a0,8(a4)
    80001c60:	eb0c                	sd	a1,16(a4)
    80001c62:	ef10                	sd	a2,24(a4)
    80001c64:	02078793          	addi	a5,a5,32
    80001c68:	02070713          	addi	a4,a4,32
    80001c6c:	fed792e3          	bne	a5,a3,80001c50 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c70:	058a3783          	ld	a5,88(s4)
    80001c74:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c78:	0d0a8493          	addi	s1,s5,208
    80001c7c:	0d0a0913          	addi	s2,s4,208
    80001c80:	150a8993          	addi	s3,s5,336
    80001c84:	a831                	j	80001ca0 <fork+0x9a>
    freeproc(np);
    80001c86:	8552                	mv	a0,s4
    80001c88:	dcbff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c8c:	8552                	mv	a0,s4
    80001c8e:	ffffe0ef          	jal	80000c8c <release>
    return -1;
    80001c92:	597d                	li	s2,-1
    80001c94:	6a42                	ld	s4,16(sp)
    80001c96:	a0b5                	j	80001d02 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c98:	04a1                	addi	s1,s1,8
    80001c9a:	0921                	addi	s2,s2,8
    80001c9c:	01348963          	beq	s1,s3,80001cae <fork+0xa8>
    if(p->ofile[i])
    80001ca0:	6088                	ld	a0,0(s1)
    80001ca2:	d97d                	beqz	a0,80001c98 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca4:	2ea020ef          	jal	80003f8e <filedup>
    80001ca8:	00a93023          	sd	a0,0(s2)
    80001cac:	b7f5                	j	80001c98 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cae:	150ab503          	ld	a0,336(s5)
    80001cb2:	63c010ef          	jal	800032ee <idup>
    80001cb6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cba:	4641                	li	a2,16
    80001cbc:	158a8593          	addi	a1,s5,344
    80001cc0:	158a0513          	addi	a0,s4,344
    80001cc4:	942ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cc8:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ccc:	8552                	mv	a0,s4
    80001cce:	fbffe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cd2:	0000e497          	auipc	s1,0xe
    80001cd6:	db648493          	addi	s1,s1,-586 # 8000fa88 <wait_lock>
    80001cda:	8526                	mv	a0,s1
    80001cdc:	f19fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001ce0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fa7fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cea:	8552                	mv	a0,s4
    80001cec:	f09fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001cf0:	478d                	li	a5,3
    80001cf2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cf6:	8552                	mv	a0,s4
    80001cf8:	f95fe0ef          	jal	80000c8c <release>
  return pid;
    80001cfc:	74a2                	ld	s1,40(sp)
    80001cfe:	69e2                	ld	s3,24(sp)
    80001d00:	6a42                	ld	s4,16(sp)
}
    80001d02:	854a                	mv	a0,s2
    80001d04:	70e2                	ld	ra,56(sp)
    80001d06:	7442                	ld	s0,48(sp)
    80001d08:	7902                	ld	s2,32(sp)
    80001d0a:	6aa2                	ld	s5,8(sp)
    80001d0c:	6121                	addi	sp,sp,64
    80001d0e:	8082                	ret
    return -1;
    80001d10:	597d                	li	s2,-1
    80001d12:	bfc5                	j	80001d02 <fork+0xfc>

0000000080001d14 <scheduler>:
{
    80001d14:	715d                	addi	sp,sp,-80
    80001d16:	e486                	sd	ra,72(sp)
    80001d18:	e0a2                	sd	s0,64(sp)
    80001d1a:	fc26                	sd	s1,56(sp)
    80001d1c:	f84a                	sd	s2,48(sp)
    80001d1e:	f44e                	sd	s3,40(sp)
    80001d20:	f052                	sd	s4,32(sp)
    80001d22:	ec56                	sd	s5,24(sp)
    80001d24:	e85a                	sd	s6,16(sp)
    80001d26:	e45e                	sd	s7,8(sp)
    80001d28:	e062                	sd	s8,0(sp)
    80001d2a:	0880                	addi	s0,sp,80
    80001d2c:	8792                	mv	a5,tp
  int id = r_tp();
    80001d2e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d30:	00779b13          	slli	s6,a5,0x7
    80001d34:	0000e717          	auipc	a4,0xe
    80001d38:	d3c70713          	addi	a4,a4,-708 # 8000fa70 <pid_lock>
    80001d3c:	975a                	add	a4,a4,s6
    80001d3e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d42:	0000e717          	auipc	a4,0xe
    80001d46:	d6670713          	addi	a4,a4,-666 # 8000faa8 <cpus+0x8>
    80001d4a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d4c:	4c11                	li	s8,4
        c->proc = p;
    80001d4e:	079e                	slli	a5,a5,0x7
    80001d50:	0000ea17          	auipc	s4,0xe
    80001d54:	d20a0a13          	addi	s4,s4,-736 # 8000fa70 <pid_lock>
    80001d58:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d5a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d5c:	00014997          	auipc	s3,0x14
    80001d60:	b4498993          	addi	s3,s3,-1212 # 800158a0 <tickslock>
    80001d64:	a0a9                	j	80001dae <scheduler+0x9a>
      release(&p->lock);
    80001d66:	8526                	mv	a0,s1
    80001d68:	f25fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d6c:	16848493          	addi	s1,s1,360
    80001d70:	03348563          	beq	s1,s3,80001d9a <scheduler+0x86>
      acquire(&p->lock);
    80001d74:	8526                	mv	a0,s1
    80001d76:	e7ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d7a:	4c9c                	lw	a5,24(s1)
    80001d7c:	ff2795e3          	bne	a5,s2,80001d66 <scheduler+0x52>
        p->state = RUNNING;
    80001d80:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d84:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d88:	06048593          	addi	a1,s1,96
    80001d8c:	855a                	mv	a0,s6
    80001d8e:	5b4000ef          	jal	80002342 <swtch>
        c->proc = 0;
    80001d92:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d96:	8ade                	mv	s5,s7
    80001d98:	b7f9                	j	80001d66 <scheduler+0x52>
    if(found == 0) {
    80001d9a:	000a9a63          	bnez	s5,80001dae <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d9e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001da6:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001daa:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dae:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001db6:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dba:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dbc:	0000e497          	auipc	s1,0xe
    80001dc0:	0e448493          	addi	s1,s1,228 # 8000fea0 <proc>
      if(p->state == RUNNABLE) {
    80001dc4:	490d                	li	s2,3
    80001dc6:	b77d                	j	80001d74 <scheduler+0x60>

0000000080001dc8 <sched>:
{
    80001dc8:	7179                	addi	sp,sp,-48
    80001dca:	f406                	sd	ra,40(sp)
    80001dcc:	f022                	sd	s0,32(sp)
    80001dce:	ec26                	sd	s1,24(sp)
    80001dd0:	e84a                	sd	s2,16(sp)
    80001dd2:	e44e                	sd	s3,8(sp)
    80001dd4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dd6:	b0bff0ef          	jal	800018e0 <myproc>
    80001dda:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ddc:	daffe0ef          	jal	80000b8a <holding>
    80001de0:	c92d                	beqz	a0,80001e52 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001de2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de4:	2781                	sext.w	a5,a5
    80001de6:	079e                	slli	a5,a5,0x7
    80001de8:	0000e717          	auipc	a4,0xe
    80001dec:	c8870713          	addi	a4,a4,-888 # 8000fa70 <pid_lock>
    80001df0:	97ba                	add	a5,a5,a4
    80001df2:	0a87a703          	lw	a4,168(a5)
    80001df6:	4785                	li	a5,1
    80001df8:	06f71363          	bne	a4,a5,80001e5e <sched+0x96>
  if(p->state == RUNNING)
    80001dfc:	4c98                	lw	a4,24(s1)
    80001dfe:	4791                	li	a5,4
    80001e00:	06f70563          	beq	a4,a5,80001e6a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e04:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e08:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e0a:	e7b5                	bnez	a5,80001e76 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e0c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e0e:	0000e917          	auipc	s2,0xe
    80001e12:	c6290913          	addi	s2,s2,-926 # 8000fa70 <pid_lock>
    80001e16:	2781                	sext.w	a5,a5
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	97ca                	add	a5,a5,s2
    80001e1c:	0ac7a983          	lw	s3,172(a5)
    80001e20:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e22:	2781                	sext.w	a5,a5
    80001e24:	079e                	slli	a5,a5,0x7
    80001e26:	0000e597          	auipc	a1,0xe
    80001e2a:	c8258593          	addi	a1,a1,-894 # 8000faa8 <cpus+0x8>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	06048513          	addi	a0,s1,96
    80001e34:	50e000ef          	jal	80002342 <swtch>
    80001e38:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	993e                	add	s2,s2,a5
    80001e40:	0b392623          	sw	s3,172(s2)
}
    80001e44:	70a2                	ld	ra,40(sp)
    80001e46:	7402                	ld	s0,32(sp)
    80001e48:	64e2                	ld	s1,24(sp)
    80001e4a:	6942                	ld	s2,16(sp)
    80001e4c:	69a2                	ld	s3,8(sp)
    80001e4e:	6145                	addi	sp,sp,48
    80001e50:	8082                	ret
    panic("sched p->lock");
    80001e52:	00005517          	auipc	a0,0x5
    80001e56:	3e650513          	addi	a0,a0,998 # 80007238 <etext+0x238>
    80001e5a:	93bfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e5e:	00005517          	auipc	a0,0x5
    80001e62:	3ea50513          	addi	a0,a0,1002 # 80007248 <etext+0x248>
    80001e66:	92ffe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	3ee50513          	addi	a0,a0,1006 # 80007258 <etext+0x258>
    80001e72:	923fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001e76:	00005517          	auipc	a0,0x5
    80001e7a:	3f250513          	addi	a0,a0,1010 # 80007268 <etext+0x268>
    80001e7e:	917fe0ef          	jal	80000794 <panic>

0000000080001e82 <yield>:
{
    80001e82:	1101                	addi	sp,sp,-32
    80001e84:	ec06                	sd	ra,24(sp)
    80001e86:	e822                	sd	s0,16(sp)
    80001e88:	e426                	sd	s1,8(sp)
    80001e8a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e8c:	a55ff0ef          	jal	800018e0 <myproc>
    80001e90:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e92:	d63fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001e96:	478d                	li	a5,3
    80001e98:	cc9c                	sw	a5,24(s1)
  sched();
    80001e9a:	f2fff0ef          	jal	80001dc8 <sched>
  release(&p->lock);
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	dedfe0ef          	jal	80000c8c <release>
}
    80001ea4:	60e2                	ld	ra,24(sp)
    80001ea6:	6442                	ld	s0,16(sp)
    80001ea8:	64a2                	ld	s1,8(sp)
    80001eaa:	6105                	addi	sp,sp,32
    80001eac:	8082                	ret

0000000080001eae <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eae:	7179                	addi	sp,sp,-48
    80001eb0:	f406                	sd	ra,40(sp)
    80001eb2:	f022                	sd	s0,32(sp)
    80001eb4:	ec26                	sd	s1,24(sp)
    80001eb6:	e84a                	sd	s2,16(sp)
    80001eb8:	e44e                	sd	s3,8(sp)
    80001eba:	1800                	addi	s0,sp,48
    80001ebc:	89aa                	mv	s3,a0
    80001ebe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec0:	a21ff0ef          	jal	800018e0 <myproc>
    80001ec4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ec6:	d2ffe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001eca:	854a                	mv	a0,s2
    80001ecc:	dc1fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001ed0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed4:	4789                	li	a5,2
    80001ed6:	cc9c                	sw	a5,24(s1)

  sched();
    80001ed8:	ef1ff0ef          	jal	80001dc8 <sched>

  // Tidy up.
  p->chan = 0;
    80001edc:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	dabfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001ee6:	854a                	mv	a0,s2
    80001ee8:	d0dfe0ef          	jal	80000bf4 <acquire>
}
    80001eec:	70a2                	ld	ra,40(sp)
    80001eee:	7402                	ld	s0,32(sp)
    80001ef0:	64e2                	ld	s1,24(sp)
    80001ef2:	6942                	ld	s2,16(sp)
    80001ef4:	69a2                	ld	s3,8(sp)
    80001ef6:	6145                	addi	sp,sp,48
    80001ef8:	8082                	ret

0000000080001efa <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001efa:	7139                	addi	sp,sp,-64
    80001efc:	fc06                	sd	ra,56(sp)
    80001efe:	f822                	sd	s0,48(sp)
    80001f00:	f426                	sd	s1,40(sp)
    80001f02:	f04a                	sd	s2,32(sp)
    80001f04:	ec4e                	sd	s3,24(sp)
    80001f06:	e852                	sd	s4,16(sp)
    80001f08:	e456                	sd	s5,8(sp)
    80001f0a:	0080                	addi	s0,sp,64
    80001f0c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	0000e497          	auipc	s1,0xe
    80001f12:	f9248493          	addi	s1,s1,-110 # 8000fea0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f16:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f18:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f1a:	00014917          	auipc	s2,0x14
    80001f1e:	98690913          	addi	s2,s2,-1658 # 800158a0 <tickslock>
    80001f22:	a801                	j	80001f32 <wakeup+0x38>
      }
      release(&p->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	d67fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2a:	16848493          	addi	s1,s1,360
    80001f2e:	03248263          	beq	s1,s2,80001f52 <wakeup+0x58>
    if(p != myproc()){
    80001f32:	9afff0ef          	jal	800018e0 <myproc>
    80001f36:	fea48ae3          	beq	s1,a0,80001f2a <wakeup+0x30>
      acquire(&p->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	cb9fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4c9c                	lw	a5,24(s1)
    80001f42:	ff3791e3          	bne	a5,s3,80001f24 <wakeup+0x2a>
    80001f46:	709c                	ld	a5,32(s1)
    80001f48:	fd479ee3          	bne	a5,s4,80001f24 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f4c:	0154ac23          	sw	s5,24(s1)
    80001f50:	bfd1                	j	80001f24 <wakeup+0x2a>
    }
  }
}
    80001f52:	70e2                	ld	ra,56(sp)
    80001f54:	7442                	ld	s0,48(sp)
    80001f56:	74a2                	ld	s1,40(sp)
    80001f58:	7902                	ld	s2,32(sp)
    80001f5a:	69e2                	ld	s3,24(sp)
    80001f5c:	6a42                	ld	s4,16(sp)
    80001f5e:	6aa2                	ld	s5,8(sp)
    80001f60:	6121                	addi	sp,sp,64
    80001f62:	8082                	ret

0000000080001f64 <reparent>:
{
    80001f64:	7179                	addi	sp,sp,-48
    80001f66:	f406                	sd	ra,40(sp)
    80001f68:	f022                	sd	s0,32(sp)
    80001f6a:	ec26                	sd	s1,24(sp)
    80001f6c:	e84a                	sd	s2,16(sp)
    80001f6e:	e44e                	sd	s3,8(sp)
    80001f70:	e052                	sd	s4,0(sp)
    80001f72:	1800                	addi	s0,sp,48
    80001f74:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f76:	0000e497          	auipc	s1,0xe
    80001f7a:	f2a48493          	addi	s1,s1,-214 # 8000fea0 <proc>
      pp->parent = initproc;
    80001f7e:	00006a17          	auipc	s4,0x6
    80001f82:	9baa0a13          	addi	s4,s4,-1606 # 80007938 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f86:	00014997          	auipc	s3,0x14
    80001f8a:	91a98993          	addi	s3,s3,-1766 # 800158a0 <tickslock>
    80001f8e:	a029                	j	80001f98 <reparent+0x34>
    80001f90:	16848493          	addi	s1,s1,360
    80001f94:	01348b63          	beq	s1,s3,80001faa <reparent+0x46>
    if(pp->parent == p){
    80001f98:	7c9c                	ld	a5,56(s1)
    80001f9a:	ff279be3          	bne	a5,s2,80001f90 <reparent+0x2c>
      pp->parent = initproc;
    80001f9e:	000a3503          	ld	a0,0(s4)
    80001fa2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fa4:	f57ff0ef          	jal	80001efa <wakeup>
    80001fa8:	b7e5                	j	80001f90 <reparent+0x2c>
}
    80001faa:	70a2                	ld	ra,40(sp)
    80001fac:	7402                	ld	s0,32(sp)
    80001fae:	64e2                	ld	s1,24(sp)
    80001fb0:	6942                	ld	s2,16(sp)
    80001fb2:	69a2                	ld	s3,8(sp)
    80001fb4:	6a02                	ld	s4,0(sp)
    80001fb6:	6145                	addi	sp,sp,48
    80001fb8:	8082                	ret

0000000080001fba <exit>:
{
    80001fba:	7179                	addi	sp,sp,-48
    80001fbc:	f406                	sd	ra,40(sp)
    80001fbe:	f022                	sd	s0,32(sp)
    80001fc0:	ec26                	sd	s1,24(sp)
    80001fc2:	e84a                	sd	s2,16(sp)
    80001fc4:	e44e                	sd	s3,8(sp)
    80001fc6:	e052                	sd	s4,0(sp)
    80001fc8:	1800                	addi	s0,sp,48
    80001fca:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fcc:	915ff0ef          	jal	800018e0 <myproc>
    80001fd0:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fd2:	00006797          	auipc	a5,0x6
    80001fd6:	9667b783          	ld	a5,-1690(a5) # 80007938 <initproc>
    80001fda:	0d050493          	addi	s1,a0,208
    80001fde:	15050913          	addi	s2,a0,336
    80001fe2:	00a79f63          	bne	a5,a0,80002000 <exit+0x46>
    panic("init exiting");
    80001fe6:	00005517          	auipc	a0,0x5
    80001fea:	29a50513          	addi	a0,a0,666 # 80007280 <etext+0x280>
    80001fee:	fa6fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80001ff2:	7e3010ef          	jal	80003fd4 <fileclose>
      p->ofile[fd] = 0;
    80001ff6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001ffa:	04a1                	addi	s1,s1,8
    80001ffc:	01248563          	beq	s1,s2,80002006 <exit+0x4c>
    if(p->ofile[fd]){
    80002000:	6088                	ld	a0,0(s1)
    80002002:	f965                	bnez	a0,80001ff2 <exit+0x38>
    80002004:	bfdd                	j	80001ffa <exit+0x40>
  begin_op();
    80002006:	3b5010ef          	jal	80003bba <begin_op>
  iput(p->cwd);
    8000200a:	1509b503          	ld	a0,336(s3)
    8000200e:	498010ef          	jal	800034a6 <iput>
  end_op();
    80002012:	413010ef          	jal	80003c24 <end_op>
  p->cwd = 0;
    80002016:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000201a:	0000e497          	auipc	s1,0xe
    8000201e:	a6e48493          	addi	s1,s1,-1426 # 8000fa88 <wait_lock>
    80002022:	8526                	mv	a0,s1
    80002024:	bd1fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002028:	854e                	mv	a0,s3
    8000202a:	f3bff0ef          	jal	80001f64 <reparent>
  wakeup(p->parent);
    8000202e:	0389b503          	ld	a0,56(s3)
    80002032:	ec9ff0ef          	jal	80001efa <wakeup>
  acquire(&p->lock);
    80002036:	854e                	mv	a0,s3
    80002038:	bbdfe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    8000203c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002040:	4795                	li	a5,5
    80002042:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002046:	8526                	mv	a0,s1
    80002048:	c45fe0ef          	jal	80000c8c <release>
  sched();
    8000204c:	d7dff0ef          	jal	80001dc8 <sched>
  panic("zombie exit");
    80002050:	00005517          	auipc	a0,0x5
    80002054:	24050513          	addi	a0,a0,576 # 80007290 <etext+0x290>
    80002058:	f3cfe0ef          	jal	80000794 <panic>

000000008000205c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000206c:	0000e497          	auipc	s1,0xe
    80002070:	e3448493          	addi	s1,s1,-460 # 8000fea0 <proc>
    80002074:	00014997          	auipc	s3,0x14
    80002078:	82c98993          	addi	s3,s3,-2004 # 800158a0 <tickslock>
    acquire(&p->lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	b77fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002082:	589c                	lw	a5,48(s1)
    80002084:	01278b63          	beq	a5,s2,8000209a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002088:	8526                	mv	a0,s1
    8000208a:	c03fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000208e:	16848493          	addi	s1,s1,360
    80002092:	ff3495e3          	bne	s1,s3,8000207c <kill+0x20>
  }
  return -1;
    80002096:	557d                	li	a0,-1
    80002098:	a819                	j	800020ae <kill+0x52>
      p->killed = 1;
    8000209a:	4785                	li	a5,1
    8000209c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000209e:	4c98                	lw	a4,24(s1)
    800020a0:	4789                	li	a5,2
    800020a2:	00f70d63          	beq	a4,a5,800020bc <kill+0x60>
      release(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	be5fe0ef          	jal	80000c8c <release>
      return 0;
    800020ac:	4501                	li	a0,0
}
    800020ae:	70a2                	ld	ra,40(sp)
    800020b0:	7402                	ld	s0,32(sp)
    800020b2:	64e2                	ld	s1,24(sp)
    800020b4:	6942                	ld	s2,16(sp)
    800020b6:	69a2                	ld	s3,8(sp)
    800020b8:	6145                	addi	sp,sp,48
    800020ba:	8082                	ret
        p->state = RUNNABLE;
    800020bc:	478d                	li	a5,3
    800020be:	cc9c                	sw	a5,24(s1)
    800020c0:	b7dd                	j	800020a6 <kill+0x4a>

00000000800020c2 <setkilled>:

void
setkilled(struct proc *p)
{
    800020c2:	1101                	addi	sp,sp,-32
    800020c4:	ec06                	sd	ra,24(sp)
    800020c6:	e822                	sd	s0,16(sp)
    800020c8:	e426                	sd	s1,8(sp)
    800020ca:	1000                	addi	s0,sp,32
    800020cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ce:	b27fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800020d2:	4785                	li	a5,1
    800020d4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020d6:	8526                	mv	a0,s1
    800020d8:	bb5fe0ef          	jal	80000c8c <release>
}
    800020dc:	60e2                	ld	ra,24(sp)
    800020de:	6442                	ld	s0,16(sp)
    800020e0:	64a2                	ld	s1,8(sp)
    800020e2:	6105                	addi	sp,sp,32
    800020e4:	8082                	ret

00000000800020e6 <killed>:

int
killed(struct proc *p)
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	e04a                	sd	s2,0(sp)
    800020f0:	1000                	addi	s0,sp,32
    800020f2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800020f4:	b01fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    800020f8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	b8ffe0ef          	jal	80000c8c <release>
  return k;
}
    80002102:	854a                	mv	a0,s2
    80002104:	60e2                	ld	ra,24(sp)
    80002106:	6442                	ld	s0,16(sp)
    80002108:	64a2                	ld	s1,8(sp)
    8000210a:	6902                	ld	s2,0(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <wait>:
{
    80002110:	715d                	addi	sp,sp,-80
    80002112:	e486                	sd	ra,72(sp)
    80002114:	e0a2                	sd	s0,64(sp)
    80002116:	fc26                	sd	s1,56(sp)
    80002118:	f84a                	sd	s2,48(sp)
    8000211a:	f44e                	sd	s3,40(sp)
    8000211c:	f052                	sd	s4,32(sp)
    8000211e:	ec56                	sd	s5,24(sp)
    80002120:	e85a                	sd	s6,16(sp)
    80002122:	e45e                	sd	s7,8(sp)
    80002124:	e062                	sd	s8,0(sp)
    80002126:	0880                	addi	s0,sp,80
    80002128:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000212a:	fb6ff0ef          	jal	800018e0 <myproc>
    8000212e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002130:	0000e517          	auipc	a0,0xe
    80002134:	95850513          	addi	a0,a0,-1704 # 8000fa88 <wait_lock>
    80002138:	abdfe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000213c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000213e:	4a15                	li	s4,5
        havekids = 1;
    80002140:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002142:	00013997          	auipc	s3,0x13
    80002146:	75e98993          	addi	s3,s3,1886 # 800158a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000214a:	0000ec17          	auipc	s8,0xe
    8000214e:	93ec0c13          	addi	s8,s8,-1730 # 8000fa88 <wait_lock>
    80002152:	a871                	j	800021ee <wait+0xde>
          pid = pp->pid;
    80002154:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002158:	000b0c63          	beqz	s6,80002170 <wait+0x60>
    8000215c:	4691                	li	a3,4
    8000215e:	02c48613          	addi	a2,s1,44
    80002162:	85da                	mv	a1,s6
    80002164:	05093503          	ld	a0,80(s2)
    80002168:	beaff0ef          	jal	80001552 <copyout>
    8000216c:	02054b63          	bltz	a0,800021a2 <wait+0x92>
          freeproc(pp);
    80002170:	8526                	mv	a0,s1
    80002172:	8e1ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	b15fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000217c:	0000e517          	auipc	a0,0xe
    80002180:	90c50513          	addi	a0,a0,-1780 # 8000fa88 <wait_lock>
    80002184:	b09fe0ef          	jal	80000c8c <release>
}
    80002188:	854e                	mv	a0,s3
    8000218a:	60a6                	ld	ra,72(sp)
    8000218c:	6406                	ld	s0,64(sp)
    8000218e:	74e2                	ld	s1,56(sp)
    80002190:	7942                	ld	s2,48(sp)
    80002192:	79a2                	ld	s3,40(sp)
    80002194:	7a02                	ld	s4,32(sp)
    80002196:	6ae2                	ld	s5,24(sp)
    80002198:	6b42                	ld	s6,16(sp)
    8000219a:	6ba2                	ld	s7,8(sp)
    8000219c:	6c02                	ld	s8,0(sp)
    8000219e:	6161                	addi	sp,sp,80
    800021a0:	8082                	ret
            release(&pp->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	ae9fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800021a8:	0000e517          	auipc	a0,0xe
    800021ac:	8e050513          	addi	a0,a0,-1824 # 8000fa88 <wait_lock>
    800021b0:	addfe0ef          	jal	80000c8c <release>
            return -1;
    800021b4:	59fd                	li	s3,-1
    800021b6:	bfc9                	j	80002188 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021b8:	16848493          	addi	s1,s1,360
    800021bc:	03348063          	beq	s1,s3,800021dc <wait+0xcc>
      if(pp->parent == p){
    800021c0:	7c9c                	ld	a5,56(s1)
    800021c2:	ff279be3          	bne	a5,s2,800021b8 <wait+0xa8>
        acquire(&pp->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	a2dfe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800021cc:	4c9c                	lw	a5,24(s1)
    800021ce:	f94783e3          	beq	a5,s4,80002154 <wait+0x44>
        release(&pp->lock);
    800021d2:	8526                	mv	a0,s1
    800021d4:	ab9fe0ef          	jal	80000c8c <release>
        havekids = 1;
    800021d8:	8756                	mv	a4,s5
    800021da:	bff9                	j	800021b8 <wait+0xa8>
    if(!havekids || killed(p)){
    800021dc:	cf19                	beqz	a4,800021fa <wait+0xea>
    800021de:	854a                	mv	a0,s2
    800021e0:	f07ff0ef          	jal	800020e6 <killed>
    800021e4:	e919                	bnez	a0,800021fa <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021e6:	85e2                	mv	a1,s8
    800021e8:	854a                	mv	a0,s2
    800021ea:	cc5ff0ef          	jal	80001eae <sleep>
    havekids = 0;
    800021ee:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f0:	0000e497          	auipc	s1,0xe
    800021f4:	cb048493          	addi	s1,s1,-848 # 8000fea0 <proc>
    800021f8:	b7e1                	j	800021c0 <wait+0xb0>
      release(&wait_lock);
    800021fa:	0000e517          	auipc	a0,0xe
    800021fe:	88e50513          	addi	a0,a0,-1906 # 8000fa88 <wait_lock>
    80002202:	a8bfe0ef          	jal	80000c8c <release>
      return -1;
    80002206:	59fd                	li	s3,-1
    80002208:	b741                	j	80002188 <wait+0x78>

000000008000220a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000220a:	7179                	addi	sp,sp,-48
    8000220c:	f406                	sd	ra,40(sp)
    8000220e:	f022                	sd	s0,32(sp)
    80002210:	ec26                	sd	s1,24(sp)
    80002212:	e84a                	sd	s2,16(sp)
    80002214:	e44e                	sd	s3,8(sp)
    80002216:	e052                	sd	s4,0(sp)
    80002218:	1800                	addi	s0,sp,48
    8000221a:	84aa                	mv	s1,a0
    8000221c:	892e                	mv	s2,a1
    8000221e:	89b2                	mv	s3,a2
    80002220:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002222:	ebeff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    80002226:	cc99                	beqz	s1,80002244 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002228:	86d2                	mv	a3,s4
    8000222a:	864e                	mv	a2,s3
    8000222c:	85ca                	mv	a1,s2
    8000222e:	6928                	ld	a0,80(a0)
    80002230:	b22ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002234:	70a2                	ld	ra,40(sp)
    80002236:	7402                	ld	s0,32(sp)
    80002238:	64e2                	ld	s1,24(sp)
    8000223a:	6942                	ld	s2,16(sp)
    8000223c:	69a2                	ld	s3,8(sp)
    8000223e:	6a02                	ld	s4,0(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret
    memmove((char *)dst, src, len);
    80002244:	000a061b          	sext.w	a2,s4
    80002248:	85ce                	mv	a1,s3
    8000224a:	854a                	mv	a0,s2
    8000224c:	ad9fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002250:	8526                	mv	a0,s1
    80002252:	b7cd                	j	80002234 <either_copyout+0x2a>

0000000080002254 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002254:	7179                	addi	sp,sp,-48
    80002256:	f406                	sd	ra,40(sp)
    80002258:	f022                	sd	s0,32(sp)
    8000225a:	ec26                	sd	s1,24(sp)
    8000225c:	e84a                	sd	s2,16(sp)
    8000225e:	e44e                	sd	s3,8(sp)
    80002260:	e052                	sd	s4,0(sp)
    80002262:	1800                	addi	s0,sp,48
    80002264:	892a                	mv	s2,a0
    80002266:	84ae                	mv	s1,a1
    80002268:	89b2                	mv	s3,a2
    8000226a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226c:	e74ff0ef          	jal	800018e0 <myproc>
  if(user_src){
    80002270:	cc99                	beqz	s1,8000228e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002272:	86d2                	mv	a3,s4
    80002274:	864e                	mv	a2,s3
    80002276:	85ca                	mv	a1,s2
    80002278:	6928                	ld	a0,80(a0)
    8000227a:	baeff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000227e:	70a2                	ld	ra,40(sp)
    80002280:	7402                	ld	s0,32(sp)
    80002282:	64e2                	ld	s1,24(sp)
    80002284:	6942                	ld	s2,16(sp)
    80002286:	69a2                	ld	s3,8(sp)
    80002288:	6a02                	ld	s4,0(sp)
    8000228a:	6145                	addi	sp,sp,48
    8000228c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000228e:	000a061b          	sext.w	a2,s4
    80002292:	85ce                	mv	a1,s3
    80002294:	854a                	mv	a0,s2
    80002296:	a8ffe0ef          	jal	80000d24 <memmove>
    return 0;
    8000229a:	8526                	mv	a0,s1
    8000229c:	b7cd                	j	8000227e <either_copyin+0x2a>

000000008000229e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000229e:	715d                	addi	sp,sp,-80
    800022a0:	e486                	sd	ra,72(sp)
    800022a2:	e0a2                	sd	s0,64(sp)
    800022a4:	fc26                	sd	s1,56(sp)
    800022a6:	f84a                	sd	s2,48(sp)
    800022a8:	f44e                	sd	s3,40(sp)
    800022aa:	f052                	sd	s4,32(sp)
    800022ac:	ec56                	sd	s5,24(sp)
    800022ae:	e85a                	sd	s6,16(sp)
    800022b0:	e45e                	sd	s7,8(sp)
    800022b2:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022b4:	00005517          	auipc	a0,0x5
    800022b8:	dc450513          	addi	a0,a0,-572 # 80007078 <etext+0x78>
    800022bc:	a06fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022c0:	0000e497          	auipc	s1,0xe
    800022c4:	d3848493          	addi	s1,s1,-712 # 8000fff8 <proc+0x158>
    800022c8:	00013917          	auipc	s2,0x13
    800022cc:	73090913          	addi	s2,s2,1840 # 800159f8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022d0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022d2:	00005997          	auipc	s3,0x5
    800022d6:	fce98993          	addi	s3,s3,-50 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    800022da:	00005a97          	auipc	s5,0x5
    800022de:	fcea8a93          	addi	s5,s5,-50 # 800072a8 <etext+0x2a8>
    printf("\n");
    800022e2:	00005a17          	auipc	s4,0x5
    800022e6:	d96a0a13          	addi	s4,s4,-618 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022ea:	00005b97          	auipc	s7,0x5
    800022ee:	4ceb8b93          	addi	s7,s7,1230 # 800077b8 <states.0>
    800022f2:	a829                	j	8000230c <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800022f4:	ed86a583          	lw	a1,-296(a3)
    800022f8:	8556                	mv	a0,s5
    800022fa:	9c8fe0ef          	jal	800004c2 <printf>
    printf("\n");
    800022fe:	8552                	mv	a0,s4
    80002300:	9c2fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002304:	16848493          	addi	s1,s1,360
    80002308:	03248263          	beq	s1,s2,8000232c <procdump+0x8e>
    if(p->state == UNUSED)
    8000230c:	86a6                	mv	a3,s1
    8000230e:	ec04a783          	lw	a5,-320(s1)
    80002312:	dbed                	beqz	a5,80002304 <procdump+0x66>
      state = "???";
    80002314:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002316:	fcfb6fe3          	bltu	s6,a5,800022f4 <procdump+0x56>
    8000231a:	02079713          	slli	a4,a5,0x20
    8000231e:	01d75793          	srli	a5,a4,0x1d
    80002322:	97de                	add	a5,a5,s7
    80002324:	6390                	ld	a2,0(a5)
    80002326:	f679                	bnez	a2,800022f4 <procdump+0x56>
      state = "???";
    80002328:	864e                	mv	a2,s3
    8000232a:	b7e9                	j	800022f4 <procdump+0x56>
  }
}
    8000232c:	60a6                	ld	ra,72(sp)
    8000232e:	6406                	ld	s0,64(sp)
    80002330:	74e2                	ld	s1,56(sp)
    80002332:	7942                	ld	s2,48(sp)
    80002334:	79a2                	ld	s3,40(sp)
    80002336:	7a02                	ld	s4,32(sp)
    80002338:	6ae2                	ld	s5,24(sp)
    8000233a:	6b42                	ld	s6,16(sp)
    8000233c:	6ba2                	ld	s7,8(sp)
    8000233e:	6161                	addi	sp,sp,80
    80002340:	8082                	ret

0000000080002342 <swtch>:
    80002342:	00153023          	sd	ra,0(a0)
    80002346:	00253423          	sd	sp,8(a0)
    8000234a:	e900                	sd	s0,16(a0)
    8000234c:	ed04                	sd	s1,24(a0)
    8000234e:	03253023          	sd	s2,32(a0)
    80002352:	03353423          	sd	s3,40(a0)
    80002356:	03453823          	sd	s4,48(a0)
    8000235a:	03553c23          	sd	s5,56(a0)
    8000235e:	05653023          	sd	s6,64(a0)
    80002362:	05753423          	sd	s7,72(a0)
    80002366:	05853823          	sd	s8,80(a0)
    8000236a:	05953c23          	sd	s9,88(a0)
    8000236e:	07a53023          	sd	s10,96(a0)
    80002372:	07b53423          	sd	s11,104(a0)
    80002376:	0005b083          	ld	ra,0(a1)
    8000237a:	0085b103          	ld	sp,8(a1)
    8000237e:	6980                	ld	s0,16(a1)
    80002380:	6d84                	ld	s1,24(a1)
    80002382:	0205b903          	ld	s2,32(a1)
    80002386:	0285b983          	ld	s3,40(a1)
    8000238a:	0305ba03          	ld	s4,48(a1)
    8000238e:	0385ba83          	ld	s5,56(a1)
    80002392:	0405bb03          	ld	s6,64(a1)
    80002396:	0485bb83          	ld	s7,72(a1)
    8000239a:	0505bc03          	ld	s8,80(a1)
    8000239e:	0585bc83          	ld	s9,88(a1)
    800023a2:	0605bd03          	ld	s10,96(a1)
    800023a6:	0685bd83          	ld	s11,104(a1)
    800023aa:	8082                	ret

00000000800023ac <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023ac:	1141                	addi	sp,sp,-16
    800023ae:	e406                	sd	ra,8(sp)
    800023b0:	e022                	sd	s0,0(sp)
    800023b2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023b4:	00005597          	auipc	a1,0x5
    800023b8:	f3458593          	addi	a1,a1,-204 # 800072e8 <etext+0x2e8>
    800023bc:	00013517          	auipc	a0,0x13
    800023c0:	4e450513          	addi	a0,a0,1252 # 800158a0 <tickslock>
    800023c4:	fb0fe0ef          	jal	80000b74 <initlock>
}
    800023c8:	60a2                	ld	ra,8(sp)
    800023ca:	6402                	ld	s0,0(sp)
    800023cc:	0141                	addi	sp,sp,16
    800023ce:	8082                	ret

00000000800023d0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023d0:	1141                	addi	sp,sp,-16
    800023d2:	e422                	sd	s0,8(sp)
    800023d4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023d6:	00003797          	auipc	a5,0x3
    800023da:	f6a78793          	addi	a5,a5,-150 # 80005340 <kernelvec>
    800023de:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023e2:	6422                	ld	s0,8(sp)
    800023e4:	0141                	addi	sp,sp,16
    800023e6:	8082                	ret

00000000800023e8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800023e8:	1141                	addi	sp,sp,-16
    800023ea:	e406                	sd	ra,8(sp)
    800023ec:	e022                	sd	s0,0(sp)
    800023ee:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023f0:	cf0ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023f4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023f8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023fa:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800023fe:	00004697          	auipc	a3,0x4
    80002402:	c0268693          	addi	a3,a3,-1022 # 80006000 <_trampoline>
    80002406:	00004717          	auipc	a4,0x4
    8000240a:	bfa70713          	addi	a4,a4,-1030 # 80006000 <_trampoline>
    8000240e:	8f15                	sub	a4,a4,a3
    80002410:	040007b7          	lui	a5,0x4000
    80002414:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002416:	07b2                	slli	a5,a5,0xc
    80002418:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000241a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000241e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002420:	18002673          	csrr	a2,satp
    80002424:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002426:	6d30                	ld	a2,88(a0)
    80002428:	6138                	ld	a4,64(a0)
    8000242a:	6585                	lui	a1,0x1
    8000242c:	972e                	add	a4,a4,a1
    8000242e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002430:	6d38                	ld	a4,88(a0)
    80002432:	00000617          	auipc	a2,0x0
    80002436:	11060613          	addi	a2,a2,272 # 80002542 <usertrap>
    8000243a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000243c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000243e:	8612                	mv	a2,tp
    80002440:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002442:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002446:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000244a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000244e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002452:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002454:	6f18                	ld	a4,24(a4)
    80002456:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000245a:	6928                	ld	a0,80(a0)
    8000245c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000245e:	00004717          	auipc	a4,0x4
    80002462:	c3e70713          	addi	a4,a4,-962 # 8000609c <userret>
    80002466:	8f15                	sub	a4,a4,a3
    80002468:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000246a:	577d                	li	a4,-1
    8000246c:	177e                	slli	a4,a4,0x3f
    8000246e:	8d59                	or	a0,a0,a4
    80002470:	9782                	jalr	a5
}
    80002472:	60a2                	ld	ra,8(sp)
    80002474:	6402                	ld	s0,0(sp)
    80002476:	0141                	addi	sp,sp,16
    80002478:	8082                	ret

000000008000247a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000247a:	1101                	addi	sp,sp,-32
    8000247c:	ec06                	sd	ra,24(sp)
    8000247e:	e822                	sd	s0,16(sp)
    80002480:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002482:	c32ff0ef          	jal	800018b4 <cpuid>
    80002486:	cd11                	beqz	a0,800024a2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002488:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000248c:	000f4737          	lui	a4,0xf4
    80002490:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002494:	97ba                	add	a5,a5,a4
  asm volatile("csrw stimecmp, %0" : : "r" (x));
    80002496:	14d79073          	csrw	stimecmp,a5
}
    8000249a:	60e2                	ld	ra,24(sp)
    8000249c:	6442                	ld	s0,16(sp)
    8000249e:	6105                	addi	sp,sp,32
    800024a0:	8082                	ret
    800024a2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024a4:	00013497          	auipc	s1,0x13
    800024a8:	3fc48493          	addi	s1,s1,1020 # 800158a0 <tickslock>
    800024ac:	8526                	mv	a0,s1
    800024ae:	f46fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    800024b2:	00005517          	auipc	a0,0x5
    800024b6:	48e50513          	addi	a0,a0,1166 # 80007940 <ticks>
    800024ba:	411c                	lw	a5,0(a0)
    800024bc:	2785                	addiw	a5,a5,1
    800024be:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024c0:	a3bff0ef          	jal	80001efa <wakeup>
    release(&tickslock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fc6fe0ef          	jal	80000c8c <release>
    800024ca:	64a2                	ld	s1,8(sp)
    800024cc:	bf75                	j	80002488 <clockintr+0xe>

00000000800024ce <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024ce:	1101                	addi	sp,sp,-32
    800024d0:	ec06                	sd	ra,24(sp)
    800024d2:	e822                	sd	s0,16(sp)
    800024d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024d6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024da:	57fd                	li	a5,-1
    800024dc:	17fe                	slli	a5,a5,0x3f
    800024de:	07a5                	addi	a5,a5,9
    800024e0:	00f70c63          	beq	a4,a5,800024f8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024e4:	57fd                	li	a5,-1
    800024e6:	17fe                	slli	a5,a5,0x3f
    800024e8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024ea:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024ec:	04f70763          	beq	a4,a5,8000253a <devintr+0x6c>
  }
}
    800024f0:	60e2                	ld	ra,24(sp)
    800024f2:	6442                	ld	s0,16(sp)
    800024f4:	6105                	addi	sp,sp,32
    800024f6:	8082                	ret
    800024f8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800024fa:	6f3020ef          	jal	800053ec <plic_claim>
    800024fe:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002500:	47a9                	li	a5,10
    80002502:	00f50963          	beq	a0,a5,80002514 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002506:	4785                	li	a5,1
    80002508:	00f50963          	beq	a0,a5,8000251a <devintr+0x4c>
    return 1;
    8000250c:	4505                	li	a0,1
    } else if(irq){
    8000250e:	e889                	bnez	s1,80002520 <devintr+0x52>
    80002510:	64a2                	ld	s1,8(sp)
    80002512:	bff9                	j	800024f0 <devintr+0x22>
      uartintr();
    80002514:	cf2fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002518:	a819                	j	8000252e <devintr+0x60>
      virtio_disk_intr();
    8000251a:	398030ef          	jal	800058b2 <virtio_disk_intr>
    if(irq)
    8000251e:	a801                	j	8000252e <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002520:	85a6                	mv	a1,s1
    80002522:	00005517          	auipc	a0,0x5
    80002526:	dce50513          	addi	a0,a0,-562 # 800072f0 <etext+0x2f0>
    8000252a:	f99fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    8000252e:	8526                	mv	a0,s1
    80002530:	6dd020ef          	jal	8000540c <plic_complete>
    return 1;
    80002534:	4505                	li	a0,1
    80002536:	64a2                	ld	s1,8(sp)
    80002538:	bf65                	j	800024f0 <devintr+0x22>
    clockintr();
    8000253a:	f41ff0ef          	jal	8000247a <clockintr>
    return 2;
    8000253e:	4509                	li	a0,2
    80002540:	bf45                	j	800024f0 <devintr+0x22>

0000000080002542 <usertrap>:
{
    80002542:	1101                	addi	sp,sp,-32
    80002544:	ec06                	sd	ra,24(sp)
    80002546:	e822                	sd	s0,16(sp)
    80002548:	e426                	sd	s1,8(sp)
    8000254a:	e04a                	sd	s2,0(sp)
    8000254c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000254e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002552:	1007f793          	andi	a5,a5,256
    80002556:	ebb5                	bnez	a5,800025ca <usertrap+0x88>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002558:	00003797          	auipc	a5,0x3
    8000255c:	de878793          	addi	a5,a5,-536 # 80005340 <kernelvec>
    80002560:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002564:	b7cff0ef          	jal	800018e0 <myproc>
    80002568:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000256a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000256c:	14102773          	csrr	a4,sepc
    80002570:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002572:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002576:	47a1                	li	a5,8
    80002578:	04f70f63          	beq	a4,a5,800025d6 <usertrap+0x94>
} else if ((which_dev = devintr()) != 0) {
    8000257c:	f53ff0ef          	jal	800024ce <devintr>
    80002580:	892a                	mv	s2,a0
    80002582:	e161                	bnez	a0,80002642 <usertrap+0x100>
    80002584:	14202773          	csrr	a4,scause
    if (r_scause() == 13 || r_scause() == 15 || r_scause() == 0xf) {  // Load/Store Access Fault, Store Protection Exception, or Unexpected Protection Fault
    80002588:	47b5                	li	a5,13
    8000258a:	00f70b63          	beq	a4,a5,800025a0 <usertrap+0x5e>
    8000258e:	14202773          	csrr	a4,scause
    80002592:	47bd                	li	a5,15
    80002594:	00f70663          	beq	a4,a5,800025a0 <usertrap+0x5e>
    80002598:	14202773          	csrr	a4,scause
    8000259c:	06f71c63          	bne	a4,a5,80002614 <usertrap+0xd2>
        printf("usertrap(): memory protection violation pid=%d\n", p->pid);
    800025a0:	588c                	lw	a1,48(s1)
    800025a2:	00005517          	auipc	a0,0x5
    800025a6:	d8e50513          	addi	a0,a0,-626 # 80007330 <etext+0x330>
    800025aa:	f19fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025ae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025b2:	14302673          	csrr	a2,stval
        printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025b6:	00005517          	auipc	a0,0x5
    800025ba:	daa50513          	addi	a0,a0,-598 # 80007360 <etext+0x360>
    800025be:	f05fd0ef          	jal	800004c2 <printf>
        setkilled(p);
    800025c2:	8526                	mv	a0,s1
    800025c4:	affff0ef          	jal	800020c2 <setkilled>
    800025c8:	a035                	j	800025f4 <usertrap+0xb2>
    panic("usertrap: not from user mode");
    800025ca:	00005517          	auipc	a0,0x5
    800025ce:	d4650513          	addi	a0,a0,-698 # 80007310 <etext+0x310>
    800025d2:	9c2fe0ef          	jal	80000794 <panic>
    if(killed(p))
    800025d6:	b11ff0ef          	jal	800020e6 <killed>
    800025da:	e90d                	bnez	a0,8000260c <usertrap+0xca>
    p->trapframe->epc += 4;
    800025dc:	6cb8                	ld	a4,88(s1)
    800025de:	6f1c                	ld	a5,24(a4)
    800025e0:	0791                	addi	a5,a5,4
    800025e2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025e8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025ec:	10079073          	csrw	sstatus,a5
   syscall();
    800025f0:	252000ef          	jal	80002842 <syscall>
  if(killed(p))
    800025f4:	8526                	mv	a0,s1
    800025f6:	af1ff0ef          	jal	800020e6 <killed>
    800025fa:	e929                	bnez	a0,8000264c <usertrap+0x10a>
  usertrapret();
    800025fc:	dedff0ef          	jal	800023e8 <usertrapret>
}
    80002600:	60e2                	ld	ra,24(sp)
    80002602:	6442                	ld	s0,16(sp)
    80002604:	64a2                	ld	s1,8(sp)
    80002606:	6902                	ld	s2,0(sp)
    80002608:	6105                	addi	sp,sp,32
    8000260a:	8082                	ret
      exit(-1);
    8000260c:	557d                	li	a0,-1
    8000260e:	9adff0ef          	jal	80001fba <exit>
    80002612:	b7e9                	j	800025dc <usertrap+0x9a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002614:	142025f3          	csrr	a1,scause
        printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002618:	5890                	lw	a2,48(s1)
    8000261a:	00005517          	auipc	a0,0x5
    8000261e:	d6e50513          	addi	a0,a0,-658 # 80007388 <etext+0x388>
    80002622:	ea1fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002626:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000262a:	14302673          	csrr	a2,stval
        printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000262e:	00005517          	auipc	a0,0x5
    80002632:	d3250513          	addi	a0,a0,-718 # 80007360 <etext+0x360>
    80002636:	e8dfd0ef          	jal	800004c2 <printf>
        setkilled(p);
    8000263a:	8526                	mv	a0,s1
    8000263c:	a87ff0ef          	jal	800020c2 <setkilled>
    80002640:	bf55                	j	800025f4 <usertrap+0xb2>
  if(killed(p))
    80002642:	8526                	mv	a0,s1
    80002644:	aa3ff0ef          	jal	800020e6 <killed>
    80002648:	c511                	beqz	a0,80002654 <usertrap+0x112>
    8000264a:	a011                	j	8000264e <usertrap+0x10c>
    8000264c:	4901                	li	s2,0
    exit(-1);
    8000264e:	557d                	li	a0,-1
    80002650:	96bff0ef          	jal	80001fba <exit>
  if(which_dev == 2)
    80002654:	4789                	li	a5,2
    80002656:	faf913e3          	bne	s2,a5,800025fc <usertrap+0xba>
    yield();
    8000265a:	829ff0ef          	jal	80001e82 <yield>
    8000265e:	bf79                	j	800025fc <usertrap+0xba>

0000000080002660 <kerneltrap>:
{
    80002660:	7179                	addi	sp,sp,-48
    80002662:	f406                	sd	ra,40(sp)
    80002664:	f022                	sd	s0,32(sp)
    80002666:	ec26                	sd	s1,24(sp)
    80002668:	e84a                	sd	s2,16(sp)
    8000266a:	e44e                	sd	s3,8(sp)
    8000266c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000266e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002672:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002676:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000267a:	1004f793          	andi	a5,s1,256
    8000267e:	c795                	beqz	a5,800026aa <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002680:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002684:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002686:	eb85                	bnez	a5,800026b6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002688:	e47ff0ef          	jal	800024ce <devintr>
    8000268c:	c91d                	beqz	a0,800026c2 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000268e:	4789                	li	a5,2
    80002690:	04f50a63          	beq	a0,a5,800026e4 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002694:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002698:	10049073          	csrw	sstatus,s1
}
    8000269c:	70a2                	ld	ra,40(sp)
    8000269e:	7402                	ld	s0,32(sp)
    800026a0:	64e2                	ld	s1,24(sp)
    800026a2:	6942                	ld	s2,16(sp)
    800026a4:	69a2                	ld	s3,8(sp)
    800026a6:	6145                	addi	sp,sp,48
    800026a8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026aa:	00005517          	auipc	a0,0x5
    800026ae:	d0e50513          	addi	a0,a0,-754 # 800073b8 <etext+0x3b8>
    800026b2:	8e2fe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    800026b6:	00005517          	auipc	a0,0x5
    800026ba:	d2a50513          	addi	a0,a0,-726 # 800073e0 <etext+0x3e0>
    800026be:	8d6fe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026c2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026c6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026ca:	85ce                	mv	a1,s3
    800026cc:	00005517          	auipc	a0,0x5
    800026d0:	d3450513          	addi	a0,a0,-716 # 80007400 <etext+0x400>
    800026d4:	deffd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    800026d8:	00005517          	auipc	a0,0x5
    800026dc:	d5050513          	addi	a0,a0,-688 # 80007428 <etext+0x428>
    800026e0:	8b4fe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    800026e4:	9fcff0ef          	jal	800018e0 <myproc>
    800026e8:	d555                	beqz	a0,80002694 <kerneltrap+0x34>
    yield();
    800026ea:	f98ff0ef          	jal	80001e82 <yield>
    800026ee:	b75d                	j	80002694 <kerneltrap+0x34>

00000000800026f0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026f0:	1101                	addi	sp,sp,-32
    800026f2:	ec06                	sd	ra,24(sp)
    800026f4:	e822                	sd	s0,16(sp)
    800026f6:	e426                	sd	s1,8(sp)
    800026f8:	1000                	addi	s0,sp,32
    800026fa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026fc:	9e4ff0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002700:	4795                	li	a5,5
    80002702:	0497e163          	bltu	a5,s1,80002744 <argraw+0x54>
    80002706:	048a                	slli	s1,s1,0x2
    80002708:	00005717          	auipc	a4,0x5
    8000270c:	0e070713          	addi	a4,a4,224 # 800077e8 <states.0+0x30>
    80002710:	94ba                	add	s1,s1,a4
    80002712:	409c                	lw	a5,0(s1)
    80002714:	97ba                	add	a5,a5,a4
    80002716:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002718:	6d3c                	ld	a5,88(a0)
    8000271a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000271c:	60e2                	ld	ra,24(sp)
    8000271e:	6442                	ld	s0,16(sp)
    80002720:	64a2                	ld	s1,8(sp)
    80002722:	6105                	addi	sp,sp,32
    80002724:	8082                	ret
    return p->trapframe->a1;
    80002726:	6d3c                	ld	a5,88(a0)
    80002728:	7fa8                	ld	a0,120(a5)
    8000272a:	bfcd                	j	8000271c <argraw+0x2c>
    return p->trapframe->a2;
    8000272c:	6d3c                	ld	a5,88(a0)
    8000272e:	63c8                	ld	a0,128(a5)
    80002730:	b7f5                	j	8000271c <argraw+0x2c>
    return p->trapframe->a3;
    80002732:	6d3c                	ld	a5,88(a0)
    80002734:	67c8                	ld	a0,136(a5)
    80002736:	b7dd                	j	8000271c <argraw+0x2c>
    return p->trapframe->a4;
    80002738:	6d3c                	ld	a5,88(a0)
    8000273a:	6bc8                	ld	a0,144(a5)
    8000273c:	b7c5                	j	8000271c <argraw+0x2c>
    return p->trapframe->a5;
    8000273e:	6d3c                	ld	a5,88(a0)
    80002740:	6fc8                	ld	a0,152(a5)
    80002742:	bfe9                	j	8000271c <argraw+0x2c>
  panic("argraw");
    80002744:	00005517          	auipc	a0,0x5
    80002748:	cf450513          	addi	a0,a0,-780 # 80007438 <etext+0x438>
    8000274c:	848fe0ef          	jal	80000794 <panic>

0000000080002750 <fetchaddr>:
{
    80002750:	1101                	addi	sp,sp,-32
    80002752:	ec06                	sd	ra,24(sp)
    80002754:	e822                	sd	s0,16(sp)
    80002756:	e426                	sd	s1,8(sp)
    80002758:	e04a                	sd	s2,0(sp)
    8000275a:	1000                	addi	s0,sp,32
    8000275c:	84aa                	mv	s1,a0
    8000275e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002760:	980ff0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002764:	653c                	ld	a5,72(a0)
    80002766:	02f4f663          	bgeu	s1,a5,80002792 <fetchaddr+0x42>
    8000276a:	00848713          	addi	a4,s1,8
    8000276e:	02e7e463          	bltu	a5,a4,80002796 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002772:	46a1                	li	a3,8
    80002774:	8626                	mv	a2,s1
    80002776:	85ca                	mv	a1,s2
    80002778:	6928                	ld	a0,80(a0)
    8000277a:	eaffe0ef          	jal	80001628 <copyin>
    8000277e:	00a03533          	snez	a0,a0
    80002782:	40a00533          	neg	a0,a0
}
    80002786:	60e2                	ld	ra,24(sp)
    80002788:	6442                	ld	s0,16(sp)
    8000278a:	64a2                	ld	s1,8(sp)
    8000278c:	6902                	ld	s2,0(sp)
    8000278e:	6105                	addi	sp,sp,32
    80002790:	8082                	ret
    return -1;
    80002792:	557d                	li	a0,-1
    80002794:	bfcd                	j	80002786 <fetchaddr+0x36>
    80002796:	557d                	li	a0,-1
    80002798:	b7fd                	j	80002786 <fetchaddr+0x36>

000000008000279a <fetchstr>:
{
    8000279a:	7179                	addi	sp,sp,-48
    8000279c:	f406                	sd	ra,40(sp)
    8000279e:	f022                	sd	s0,32(sp)
    800027a0:	ec26                	sd	s1,24(sp)
    800027a2:	e84a                	sd	s2,16(sp)
    800027a4:	e44e                	sd	s3,8(sp)
    800027a6:	1800                	addi	s0,sp,48
    800027a8:	892a                	mv	s2,a0
    800027aa:	84ae                	mv	s1,a1
    800027ac:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027ae:	932ff0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027b2:	86ce                	mv	a3,s3
    800027b4:	864a                	mv	a2,s2
    800027b6:	85a6                	mv	a1,s1
    800027b8:	6928                	ld	a0,80(a0)
    800027ba:	ef5fe0ef          	jal	800016ae <copyinstr>
    800027be:	00054c63          	bltz	a0,800027d6 <fetchstr+0x3c>
  return strlen(buf);
    800027c2:	8526                	mv	a0,s1
    800027c4:	e74fe0ef          	jal	80000e38 <strlen>
}
    800027c8:	70a2                	ld	ra,40(sp)
    800027ca:	7402                	ld	s0,32(sp)
    800027cc:	64e2                	ld	s1,24(sp)
    800027ce:	6942                	ld	s2,16(sp)
    800027d0:	69a2                	ld	s3,8(sp)
    800027d2:	6145                	addi	sp,sp,48
    800027d4:	8082                	ret
    return -1;
    800027d6:	557d                	li	a0,-1
    800027d8:	bfc5                	j	800027c8 <fetchstr+0x2e>

00000000800027da <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027da:	1101                	addi	sp,sp,-32
    800027dc:	ec06                	sd	ra,24(sp)
    800027de:	e822                	sd	s0,16(sp)
    800027e0:	e426                	sd	s1,8(sp)
    800027e2:	1000                	addi	s0,sp,32
    800027e4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e6:	f0bff0ef          	jal	800026f0 <argraw>
    800027ea:	c088                	sw	a0,0(s1)
}
    800027ec:	60e2                	ld	ra,24(sp)
    800027ee:	6442                	ld	s0,16(sp)
    800027f0:	64a2                	ld	s1,8(sp)
    800027f2:	6105                	addi	sp,sp,32
    800027f4:	8082                	ret

00000000800027f6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027f6:	1101                	addi	sp,sp,-32
    800027f8:	ec06                	sd	ra,24(sp)
    800027fa:	e822                	sd	s0,16(sp)
    800027fc:	e426                	sd	s1,8(sp)
    800027fe:	1000                	addi	s0,sp,32
    80002800:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002802:	eefff0ef          	jal	800026f0 <argraw>
    80002806:	e088                	sd	a0,0(s1)
}
    80002808:	60e2                	ld	ra,24(sp)
    8000280a:	6442                	ld	s0,16(sp)
    8000280c:	64a2                	ld	s1,8(sp)
    8000280e:	6105                	addi	sp,sp,32
    80002810:	8082                	ret

0000000080002812 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002812:	7179                	addi	sp,sp,-48
    80002814:	f406                	sd	ra,40(sp)
    80002816:	f022                	sd	s0,32(sp)
    80002818:	ec26                	sd	s1,24(sp)
    8000281a:	e84a                	sd	s2,16(sp)
    8000281c:	1800                	addi	s0,sp,48
    8000281e:	84ae                	mv	s1,a1
    80002820:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002822:	fd840593          	addi	a1,s0,-40
    80002826:	fd1ff0ef          	jal	800027f6 <argaddr>
  return fetchstr(addr, buf, max);
    8000282a:	864a                	mv	a2,s2
    8000282c:	85a6                	mv	a1,s1
    8000282e:	fd843503          	ld	a0,-40(s0)
    80002832:	f69ff0ef          	jal	8000279a <fetchstr>
}
    80002836:	70a2                	ld	ra,40(sp)
    80002838:	7402                	ld	s0,32(sp)
    8000283a:	64e2                	ld	s1,24(sp)
    8000283c:	6942                	ld	s2,16(sp)
    8000283e:	6145                	addi	sp,sp,48
    80002840:	8082                	ret

0000000080002842 <syscall>:
[SYS_munprotect] sys_munprotect,
};

void
syscall(void)
{
    80002842:	1101                	addi	sp,sp,-32
    80002844:	ec06                	sd	ra,24(sp)
    80002846:	e822                	sd	s0,16(sp)
    80002848:	e426                	sd	s1,8(sp)
    8000284a:	e04a                	sd	s2,0(sp)
    8000284c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000284e:	892ff0ef          	jal	800018e0 <myproc>
    80002852:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002854:	05853903          	ld	s2,88(a0)
    80002858:	0a893783          	ld	a5,168(s2)
    8000285c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002860:	37fd                	addiw	a5,a5,-1
    80002862:	4759                	li	a4,22
    80002864:	00f76f63          	bltu	a4,a5,80002882 <syscall+0x40>
    80002868:	00369713          	slli	a4,a3,0x3
    8000286c:	00005797          	auipc	a5,0x5
    80002870:	f9478793          	addi	a5,a5,-108 # 80007800 <syscalls>
    80002874:	97ba                	add	a5,a5,a4
    80002876:	639c                	ld	a5,0(a5)
    80002878:	c789                	beqz	a5,80002882 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000287a:	9782                	jalr	a5
    8000287c:	06a93823          	sd	a0,112(s2)
    80002880:	a829                	j	8000289a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002882:	15848613          	addi	a2,s1,344
    80002886:	588c                	lw	a1,48(s1)
    80002888:	00005517          	auipc	a0,0x5
    8000288c:	bb850513          	addi	a0,a0,-1096 # 80007440 <etext+0x440>
    80002890:	c33fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002894:	6cbc                	ld	a5,88(s1)
    80002896:	577d                	li	a4,-1
    80002898:	fbb8                	sd	a4,112(a5)
  }
}
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	64a2                	ld	s1,8(sp)
    800028a0:	6902                	ld	s2,0(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret

00000000800028a6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800028a6:	1101                	addi	sp,sp,-32
    800028a8:	ec06                	sd	ra,24(sp)
    800028aa:	e822                	sd	s0,16(sp)
    800028ac:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028ae:	fec40593          	addi	a1,s0,-20
    800028b2:	4501                	li	a0,0
    800028b4:	f27ff0ef          	jal	800027da <argint>
  exit(n);
    800028b8:	fec42503          	lw	a0,-20(s0)
    800028bc:	efeff0ef          	jal	80001fba <exit>
  return 0;  // not reached
}
    800028c0:	4501                	li	a0,0
    800028c2:	60e2                	ld	ra,24(sp)
    800028c4:	6442                	ld	s0,16(sp)
    800028c6:	6105                	addi	sp,sp,32
    800028c8:	8082                	ret

00000000800028ca <sys_getpid>:

uint64
sys_getpid(void)
{
    800028ca:	1141                	addi	sp,sp,-16
    800028cc:	e406                	sd	ra,8(sp)
    800028ce:	e022                	sd	s0,0(sp)
    800028d0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028d2:	80eff0ef          	jal	800018e0 <myproc>
}
    800028d6:	5908                	lw	a0,48(a0)
    800028d8:	60a2                	ld	ra,8(sp)
    800028da:	6402                	ld	s0,0(sp)
    800028dc:	0141                	addi	sp,sp,16
    800028de:	8082                	ret

00000000800028e0 <sys_fork>:

uint64
sys_fork(void)
{
    800028e0:	1141                	addi	sp,sp,-16
    800028e2:	e406                	sd	ra,8(sp)
    800028e4:	e022                	sd	s0,0(sp)
    800028e6:	0800                	addi	s0,sp,16
  return fork();
    800028e8:	b1eff0ef          	jal	80001c06 <fork>
}
    800028ec:	60a2                	ld	ra,8(sp)
    800028ee:	6402                	ld	s0,0(sp)
    800028f0:	0141                	addi	sp,sp,16
    800028f2:	8082                	ret

00000000800028f4 <sys_wait>:

uint64
sys_wait(void)
{
    800028f4:	1101                	addi	sp,sp,-32
    800028f6:	ec06                	sd	ra,24(sp)
    800028f8:	e822                	sd	s0,16(sp)
    800028fa:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028fc:	fe840593          	addi	a1,s0,-24
    80002900:	4501                	li	a0,0
    80002902:	ef5ff0ef          	jal	800027f6 <argaddr>
  return wait(p);
    80002906:	fe843503          	ld	a0,-24(s0)
    8000290a:	807ff0ef          	jal	80002110 <wait>
}
    8000290e:	60e2                	ld	ra,24(sp)
    80002910:	6442                	ld	s0,16(sp)
    80002912:	6105                	addi	sp,sp,32
    80002914:	8082                	ret

0000000080002916 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002916:	7179                	addi	sp,sp,-48
    80002918:	f406                	sd	ra,40(sp)
    8000291a:	f022                	sd	s0,32(sp)
    8000291c:	ec26                	sd	s1,24(sp)
    8000291e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002920:	fdc40593          	addi	a1,s0,-36
    80002924:	4501                	li	a0,0
    80002926:	eb5ff0ef          	jal	800027da <argint>
  addr = myproc()->sz;
    8000292a:	fb7fe0ef          	jal	800018e0 <myproc>
    8000292e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002930:	fdc42503          	lw	a0,-36(s0)
    80002934:	a82ff0ef          	jal	80001bb6 <growproc>
    80002938:	00054863          	bltz	a0,80002948 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    8000293c:	8526                	mv	a0,s1
    8000293e:	70a2                	ld	ra,40(sp)
    80002940:	7402                	ld	s0,32(sp)
    80002942:	64e2                	ld	s1,24(sp)
    80002944:	6145                	addi	sp,sp,48
    80002946:	8082                	ret
    return -1;
    80002948:	54fd                	li	s1,-1
    8000294a:	bfcd                	j	8000293c <sys_sbrk+0x26>

000000008000294c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000294c:	7139                	addi	sp,sp,-64
    8000294e:	fc06                	sd	ra,56(sp)
    80002950:	f822                	sd	s0,48(sp)
    80002952:	f04a                	sd	s2,32(sp)
    80002954:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002956:	fcc40593          	addi	a1,s0,-52
    8000295a:	4501                	li	a0,0
    8000295c:	e7fff0ef          	jal	800027da <argint>
  if(n < 0)
    80002960:	fcc42783          	lw	a5,-52(s0)
    80002964:	0607c763          	bltz	a5,800029d2 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002968:	00013517          	auipc	a0,0x13
    8000296c:	f3850513          	addi	a0,a0,-200 # 800158a0 <tickslock>
    80002970:	a84fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002974:	00005917          	auipc	s2,0x5
    80002978:	fcc92903          	lw	s2,-52(s2) # 80007940 <ticks>
  while(ticks - ticks0 < n){
    8000297c:	fcc42783          	lw	a5,-52(s0)
    80002980:	cf8d                	beqz	a5,800029ba <sys_sleep+0x6e>
    80002982:	f426                	sd	s1,40(sp)
    80002984:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002986:	00013997          	auipc	s3,0x13
    8000298a:	f1a98993          	addi	s3,s3,-230 # 800158a0 <tickslock>
    8000298e:	00005497          	auipc	s1,0x5
    80002992:	fb248493          	addi	s1,s1,-78 # 80007940 <ticks>
    if(killed(myproc())){
    80002996:	f4bfe0ef          	jal	800018e0 <myproc>
    8000299a:	f4cff0ef          	jal	800020e6 <killed>
    8000299e:	ed0d                	bnez	a0,800029d8 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800029a0:	85ce                	mv	a1,s3
    800029a2:	8526                	mv	a0,s1
    800029a4:	d0aff0ef          	jal	80001eae <sleep>
  while(ticks - ticks0 < n){
    800029a8:	409c                	lw	a5,0(s1)
    800029aa:	412787bb          	subw	a5,a5,s2
    800029ae:	fcc42703          	lw	a4,-52(s0)
    800029b2:	fee7e2e3          	bltu	a5,a4,80002996 <sys_sleep+0x4a>
    800029b6:	74a2                	ld	s1,40(sp)
    800029b8:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029ba:	00013517          	auipc	a0,0x13
    800029be:	ee650513          	addi	a0,a0,-282 # 800158a0 <tickslock>
    800029c2:	acafe0ef          	jal	80000c8c <release>
  return 0;
    800029c6:	4501                	li	a0,0
}
    800029c8:	70e2                	ld	ra,56(sp)
    800029ca:	7442                	ld	s0,48(sp)
    800029cc:	7902                	ld	s2,32(sp)
    800029ce:	6121                	addi	sp,sp,64
    800029d0:	8082                	ret
    n = 0;
    800029d2:	fc042623          	sw	zero,-52(s0)
    800029d6:	bf49                	j	80002968 <sys_sleep+0x1c>
      release(&tickslock);
    800029d8:	00013517          	auipc	a0,0x13
    800029dc:	ec850513          	addi	a0,a0,-312 # 800158a0 <tickslock>
    800029e0:	aacfe0ef          	jal	80000c8c <release>
      return -1;
    800029e4:	557d                	li	a0,-1
    800029e6:	74a2                	ld	s1,40(sp)
    800029e8:	69e2                	ld	s3,24(sp)
    800029ea:	bff9                	j	800029c8 <sys_sleep+0x7c>

00000000800029ec <sys_kill>:

uint64
sys_kill(void)
{
    800029ec:	1101                	addi	sp,sp,-32
    800029ee:	ec06                	sd	ra,24(sp)
    800029f0:	e822                	sd	s0,16(sp)
    800029f2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029f4:	fec40593          	addi	a1,s0,-20
    800029f8:	4501                	li	a0,0
    800029fa:	de1ff0ef          	jal	800027da <argint>
  return kill(pid);
    800029fe:	fec42503          	lw	a0,-20(s0)
    80002a02:	e5aff0ef          	jal	8000205c <kill>
}
    80002a06:	60e2                	ld	ra,24(sp)
    80002a08:	6442                	ld	s0,16(sp)
    80002a0a:	6105                	addi	sp,sp,32
    80002a0c:	8082                	ret

0000000080002a0e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a0e:	1101                	addi	sp,sp,-32
    80002a10:	ec06                	sd	ra,24(sp)
    80002a12:	e822                	sd	s0,16(sp)
    80002a14:	e426                	sd	s1,8(sp)
    80002a16:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a18:	00013517          	auipc	a0,0x13
    80002a1c:	e8850513          	addi	a0,a0,-376 # 800158a0 <tickslock>
    80002a20:	9d4fe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002a24:	00005497          	auipc	s1,0x5
    80002a28:	f1c4a483          	lw	s1,-228(s1) # 80007940 <ticks>
  release(&tickslock);
    80002a2c:	00013517          	auipc	a0,0x13
    80002a30:	e7450513          	addi	a0,a0,-396 # 800158a0 <tickslock>
    80002a34:	a58fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002a38:	02049513          	slli	a0,s1,0x20
    80002a3c:	9101                	srli	a0,a0,0x20
    80002a3e:	60e2                	ld	ra,24(sp)
    80002a40:	6442                	ld	s0,16(sp)
    80002a42:	64a2                	ld	s1,8(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret

0000000080002a48 <sys_mprotect>:

uint64 sys_mprotect(void) {
    80002a48:	7139                	addi	sp,sp,-64
    80002a4a:	fc06                	sd	ra,56(sp)
    80002a4c:	f822                	sd	s0,48(sp)
    80002a4e:	0080                	addi	s0,sp,64
    uint64 addr;
    int len;

    // Llamamos a las funciones para obtener los valores de los argumentos
    argaddr(0, &addr);
    80002a50:	fc840593          	addi	a1,s0,-56
    80002a54:	4501                	li	a0,0
    80002a56:	da1ff0ef          	jal	800027f6 <argaddr>
    argint(1, &len);
    80002a5a:	fc440593          	addi	a1,s0,-60
    80002a5e:	4505                	li	a0,1
    80002a60:	d7bff0ef          	jal	800027da <argint>

    struct proc *p = myproc();
    80002a64:	e7dfe0ef          	jal	800018e0 <myproc>
    for (int i = 0; i < len; i++) {
    80002a68:	fc442783          	lw	a5,-60(s0)
    80002a6c:	04f05663          	blez	a5,80002ab8 <sys_mprotect+0x70>
    80002a70:	f426                	sd	s1,40(sp)
    80002a72:	f04a                	sd	s2,32(sp)
    80002a74:	ec4e                	sd	s3,24(sp)
    80002a76:	892a                	mv	s2,a0
    80002a78:	4481                	li	s1,0
        uint64 va = addr + i * PGSIZE;
        pte_t *pte = walk(p->pagetable, va, 0);

        if (pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80002a7a:	49c5                	li	s3,17
        uint64 va = addr + i * PGSIZE;
    80002a7c:	00c49593          	slli	a1,s1,0xc
        pte_t *pte = walk(p->pagetable, va, 0);
    80002a80:	4601                	li	a2,0
    80002a82:	fc843783          	ld	a5,-56(s0)
    80002a86:	95be                	add	a1,a1,a5
    80002a88:	05093503          	ld	a0,80(s2)
    80002a8c:	cb0fe0ef          	jal	80000f3c <walk>
        if (pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80002a90:	c515                	beqz	a0,80002abc <sys_mprotect+0x74>
    80002a92:	611c                	ld	a5,0(a0)
    80002a94:	0117f713          	andi	a4,a5,17
    80002a98:	03371a63          	bne	a4,s3,80002acc <sys_mprotect+0x84>
            return -1;

        // Desactiva el bit PTE_W para hacer la página de solo lectura
        *pte &= ~PTE_W;
    80002a9c:	9bed                	andi	a5,a5,-5
    80002a9e:	e11c                	sd	a5,0(a0)
    for (int i = 0; i < len; i++) {
    80002aa0:	0485                	addi	s1,s1,1
    80002aa2:	fc442703          	lw	a4,-60(s0)
    80002aa6:	0004879b          	sext.w	a5,s1
    80002aaa:	fce7c9e3          	blt	a5,a4,80002a7c <sys_mprotect+0x34>
    }
    return 0;  // Retorna 0 si todo está correcto
    80002aae:	4501                	li	a0,0
    80002ab0:	74a2                	ld	s1,40(sp)
    80002ab2:	7902                	ld	s2,32(sp)
    80002ab4:	69e2                	ld	s3,24(sp)
    80002ab6:	a039                	j	80002ac4 <sys_mprotect+0x7c>
    80002ab8:	4501                	li	a0,0
    80002aba:	a029                	j	80002ac4 <sys_mprotect+0x7c>
            return -1;
    80002abc:	557d                	li	a0,-1
    80002abe:	74a2                	ld	s1,40(sp)
    80002ac0:	7902                	ld	s2,32(sp)
    80002ac2:	69e2                	ld	s3,24(sp)
}
    80002ac4:	70e2                	ld	ra,56(sp)
    80002ac6:	7442                	ld	s0,48(sp)
    80002ac8:	6121                	addi	sp,sp,64
    80002aca:	8082                	ret
            return -1;
    80002acc:	557d                	li	a0,-1
    80002ace:	74a2                	ld	s1,40(sp)
    80002ad0:	7902                	ld	s2,32(sp)
    80002ad2:	69e2                	ld	s3,24(sp)
    80002ad4:	bfc5                	j	80002ac4 <sys_mprotect+0x7c>

0000000080002ad6 <sys_munprotect>:

uint64 sys_munprotect(void) {
    80002ad6:	7139                	addi	sp,sp,-64
    80002ad8:	fc06                	sd	ra,56(sp)
    80002ada:	f822                	sd	s0,48(sp)
    80002adc:	0080                	addi	s0,sp,64
    uint64 addr;
    int len;

    // Llamamos a las funciones para obtener los valores de los argumentos
    argaddr(0, &addr);
    80002ade:	fc840593          	addi	a1,s0,-56
    80002ae2:	4501                	li	a0,0
    80002ae4:	d13ff0ef          	jal	800027f6 <argaddr>
    argint(1, &len);
    80002ae8:	fc440593          	addi	a1,s0,-60
    80002aec:	4505                	li	a0,1
    80002aee:	cedff0ef          	jal	800027da <argint>

    struct proc *p = myproc();
    80002af2:	deffe0ef          	jal	800018e0 <myproc>
    for (int i = 0; i < len; i++) {
    80002af6:	fc442783          	lw	a5,-60(s0)
    80002afa:	04f05763          	blez	a5,80002b48 <sys_munprotect+0x72>
    80002afe:	f426                	sd	s1,40(sp)
    80002b00:	f04a                	sd	s2,32(sp)
    80002b02:	ec4e                	sd	s3,24(sp)
    80002b04:	892a                	mv	s2,a0
    80002b06:	4481                	li	s1,0
        uint64 va = addr + i * PGSIZE;
        pte_t *pte = walk(p->pagetable, va, 0);

        if (pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80002b08:	49c5                	li	s3,17
        uint64 va = addr + i * PGSIZE;
    80002b0a:	00c49593          	slli	a1,s1,0xc
        pte_t *pte = walk(p->pagetable, va, 0);
    80002b0e:	4601                	li	a2,0
    80002b10:	fc843783          	ld	a5,-56(s0)
    80002b14:	95be                	add	a1,a1,a5
    80002b16:	05093503          	ld	a0,80(s2)
    80002b1a:	c22fe0ef          	jal	80000f3c <walk>
        if (pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    80002b1e:	c51d                	beqz	a0,80002b4c <sys_munprotect+0x76>
    80002b20:	611c                	ld	a5,0(a0)
    80002b22:	0117f713          	andi	a4,a5,17
    80002b26:	03371b63          	bne	a4,s3,80002b5c <sys_munprotect+0x86>
            return -1;

        // Activa el bit PTE_W para permitir escritura
        *pte |= PTE_W;
    80002b2a:	0047e793          	ori	a5,a5,4
    80002b2e:	e11c                	sd	a5,0(a0)
    for (int i = 0; i < len; i++) {
    80002b30:	0485                	addi	s1,s1,1
    80002b32:	fc442703          	lw	a4,-60(s0)
    80002b36:	0004879b          	sext.w	a5,s1
    80002b3a:	fce7c8e3          	blt	a5,a4,80002b0a <sys_munprotect+0x34>
    }
    return 0;  // Retorna 0 si todo está correcto
    80002b3e:	4501                	li	a0,0
    80002b40:	74a2                	ld	s1,40(sp)
    80002b42:	7902                	ld	s2,32(sp)
    80002b44:	69e2                	ld	s3,24(sp)
    80002b46:	a039                	j	80002b54 <sys_munprotect+0x7e>
    80002b48:	4501                	li	a0,0
    80002b4a:	a029                	j	80002b54 <sys_munprotect+0x7e>
            return -1;
    80002b4c:	557d                	li	a0,-1
    80002b4e:	74a2                	ld	s1,40(sp)
    80002b50:	7902                	ld	s2,32(sp)
    80002b52:	69e2                	ld	s3,24(sp)
}
    80002b54:	70e2                	ld	ra,56(sp)
    80002b56:	7442                	ld	s0,48(sp)
    80002b58:	6121                	addi	sp,sp,64
    80002b5a:	8082                	ret
            return -1;
    80002b5c:	557d                	li	a0,-1
    80002b5e:	74a2                	ld	s1,40(sp)
    80002b60:	7902                	ld	s2,32(sp)
    80002b62:	69e2                	ld	s3,24(sp)
    80002b64:	bfc5                	j	80002b54 <sys_munprotect+0x7e>

0000000080002b66 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b66:	7179                	addi	sp,sp,-48
    80002b68:	f406                	sd	ra,40(sp)
    80002b6a:	f022                	sd	s0,32(sp)
    80002b6c:	ec26                	sd	s1,24(sp)
    80002b6e:	e84a                	sd	s2,16(sp)
    80002b70:	e44e                	sd	s3,8(sp)
    80002b72:	e052                	sd	s4,0(sp)
    80002b74:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b76:	00005597          	auipc	a1,0x5
    80002b7a:	8ea58593          	addi	a1,a1,-1814 # 80007460 <etext+0x460>
    80002b7e:	00013517          	auipc	a0,0x13
    80002b82:	d3a50513          	addi	a0,a0,-710 # 800158b8 <bcache>
    80002b86:	feffd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b8a:	0001b797          	auipc	a5,0x1b
    80002b8e:	d2e78793          	addi	a5,a5,-722 # 8001d8b8 <bcache+0x8000>
    80002b92:	0001b717          	auipc	a4,0x1b
    80002b96:	f8e70713          	addi	a4,a4,-114 # 8001db20 <bcache+0x8268>
    80002b9a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b9e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ba2:	00013497          	auipc	s1,0x13
    80002ba6:	d2e48493          	addi	s1,s1,-722 # 800158d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002baa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bac:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bae:	00005a17          	auipc	s4,0x5
    80002bb2:	8baa0a13          	addi	s4,s4,-1862 # 80007468 <etext+0x468>
    b->next = bcache.head.next;
    80002bb6:	2b893783          	ld	a5,696(s2)
    80002bba:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bbc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bc0:	85d2                	mv	a1,s4
    80002bc2:	01048513          	addi	a0,s1,16
    80002bc6:	248010ef          	jal	80003e0e <initsleeplock>
    bcache.head.next->prev = b;
    80002bca:	2b893783          	ld	a5,696(s2)
    80002bce:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bd0:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bd4:	45848493          	addi	s1,s1,1112
    80002bd8:	fd349fe3          	bne	s1,s3,80002bb6 <binit+0x50>
  }
}
    80002bdc:	70a2                	ld	ra,40(sp)
    80002bde:	7402                	ld	s0,32(sp)
    80002be0:	64e2                	ld	s1,24(sp)
    80002be2:	6942                	ld	s2,16(sp)
    80002be4:	69a2                	ld	s3,8(sp)
    80002be6:	6a02                	ld	s4,0(sp)
    80002be8:	6145                	addi	sp,sp,48
    80002bea:	8082                	ret

0000000080002bec <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bec:	7179                	addi	sp,sp,-48
    80002bee:	f406                	sd	ra,40(sp)
    80002bf0:	f022                	sd	s0,32(sp)
    80002bf2:	ec26                	sd	s1,24(sp)
    80002bf4:	e84a                	sd	s2,16(sp)
    80002bf6:	e44e                	sd	s3,8(sp)
    80002bf8:	1800                	addi	s0,sp,48
    80002bfa:	892a                	mv	s2,a0
    80002bfc:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bfe:	00013517          	auipc	a0,0x13
    80002c02:	cba50513          	addi	a0,a0,-838 # 800158b8 <bcache>
    80002c06:	feffd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c0a:	0001b497          	auipc	s1,0x1b
    80002c0e:	f664b483          	ld	s1,-154(s1) # 8001db70 <bcache+0x82b8>
    80002c12:	0001b797          	auipc	a5,0x1b
    80002c16:	f0e78793          	addi	a5,a5,-242 # 8001db20 <bcache+0x8268>
    80002c1a:	02f48b63          	beq	s1,a5,80002c50 <bread+0x64>
    80002c1e:	873e                	mv	a4,a5
    80002c20:	a021                	j	80002c28 <bread+0x3c>
    80002c22:	68a4                	ld	s1,80(s1)
    80002c24:	02e48663          	beq	s1,a4,80002c50 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002c28:	449c                	lw	a5,8(s1)
    80002c2a:	ff279ce3          	bne	a5,s2,80002c22 <bread+0x36>
    80002c2e:	44dc                	lw	a5,12(s1)
    80002c30:	ff3799e3          	bne	a5,s3,80002c22 <bread+0x36>
      b->refcnt++;
    80002c34:	40bc                	lw	a5,64(s1)
    80002c36:	2785                	addiw	a5,a5,1
    80002c38:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c3a:	00013517          	auipc	a0,0x13
    80002c3e:	c7e50513          	addi	a0,a0,-898 # 800158b8 <bcache>
    80002c42:	84afe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c46:	01048513          	addi	a0,s1,16
    80002c4a:	1fa010ef          	jal	80003e44 <acquiresleep>
      return b;
    80002c4e:	a889                	j	80002ca0 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c50:	0001b497          	auipc	s1,0x1b
    80002c54:	f184b483          	ld	s1,-232(s1) # 8001db68 <bcache+0x82b0>
    80002c58:	0001b797          	auipc	a5,0x1b
    80002c5c:	ec878793          	addi	a5,a5,-312 # 8001db20 <bcache+0x8268>
    80002c60:	00f48863          	beq	s1,a5,80002c70 <bread+0x84>
    80002c64:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c66:	40bc                	lw	a5,64(s1)
    80002c68:	cb91                	beqz	a5,80002c7c <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c6a:	64a4                	ld	s1,72(s1)
    80002c6c:	fee49de3          	bne	s1,a4,80002c66 <bread+0x7a>
  panic("bget: no buffers");
    80002c70:	00005517          	auipc	a0,0x5
    80002c74:	80050513          	addi	a0,a0,-2048 # 80007470 <etext+0x470>
    80002c78:	b1dfd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002c7c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c80:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c84:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c88:	4785                	li	a5,1
    80002c8a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c8c:	00013517          	auipc	a0,0x13
    80002c90:	c2c50513          	addi	a0,a0,-980 # 800158b8 <bcache>
    80002c94:	ff9fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c98:	01048513          	addi	a0,s1,16
    80002c9c:	1a8010ef          	jal	80003e44 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ca0:	409c                	lw	a5,0(s1)
    80002ca2:	cb89                	beqz	a5,80002cb4 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ca4:	8526                	mv	a0,s1
    80002ca6:	70a2                	ld	ra,40(sp)
    80002ca8:	7402                	ld	s0,32(sp)
    80002caa:	64e2                	ld	s1,24(sp)
    80002cac:	6942                	ld	s2,16(sp)
    80002cae:	69a2                	ld	s3,8(sp)
    80002cb0:	6145                	addi	sp,sp,48
    80002cb2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002cb4:	4581                	li	a1,0
    80002cb6:	8526                	mv	a0,s1
    80002cb8:	1e9020ef          	jal	800056a0 <virtio_disk_rw>
    b->valid = 1;
    80002cbc:	4785                	li	a5,1
    80002cbe:	c09c                	sw	a5,0(s1)
  return b;
    80002cc0:	b7d5                	j	80002ca4 <bread+0xb8>

0000000080002cc2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cc2:	1101                	addi	sp,sp,-32
    80002cc4:	ec06                	sd	ra,24(sp)
    80002cc6:	e822                	sd	s0,16(sp)
    80002cc8:	e426                	sd	s1,8(sp)
    80002cca:	1000                	addi	s0,sp,32
    80002ccc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cce:	0541                	addi	a0,a0,16
    80002cd0:	1f2010ef          	jal	80003ec2 <holdingsleep>
    80002cd4:	c911                	beqz	a0,80002ce8 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cd6:	4585                	li	a1,1
    80002cd8:	8526                	mv	a0,s1
    80002cda:	1c7020ef          	jal	800056a0 <virtio_disk_rw>
}
    80002cde:	60e2                	ld	ra,24(sp)
    80002ce0:	6442                	ld	s0,16(sp)
    80002ce2:	64a2                	ld	s1,8(sp)
    80002ce4:	6105                	addi	sp,sp,32
    80002ce6:	8082                	ret
    panic("bwrite");
    80002ce8:	00004517          	auipc	a0,0x4
    80002cec:	7a050513          	addi	a0,a0,1952 # 80007488 <etext+0x488>
    80002cf0:	aa5fd0ef          	jal	80000794 <panic>

0000000080002cf4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	e04a                	sd	s2,0(sp)
    80002cfe:	1000                	addi	s0,sp,32
    80002d00:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d02:	01050913          	addi	s2,a0,16
    80002d06:	854a                	mv	a0,s2
    80002d08:	1ba010ef          	jal	80003ec2 <holdingsleep>
    80002d0c:	c135                	beqz	a0,80002d70 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002d0e:	854a                	mv	a0,s2
    80002d10:	17a010ef          	jal	80003e8a <releasesleep>

  acquire(&bcache.lock);
    80002d14:	00013517          	auipc	a0,0x13
    80002d18:	ba450513          	addi	a0,a0,-1116 # 800158b8 <bcache>
    80002d1c:	ed9fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002d20:	40bc                	lw	a5,64(s1)
    80002d22:	37fd                	addiw	a5,a5,-1
    80002d24:	0007871b          	sext.w	a4,a5
    80002d28:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d2a:	e71d                	bnez	a4,80002d58 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d2c:	68b8                	ld	a4,80(s1)
    80002d2e:	64bc                	ld	a5,72(s1)
    80002d30:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d32:	68b8                	ld	a4,80(s1)
    80002d34:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d36:	0001b797          	auipc	a5,0x1b
    80002d3a:	b8278793          	addi	a5,a5,-1150 # 8001d8b8 <bcache+0x8000>
    80002d3e:	2b87b703          	ld	a4,696(a5)
    80002d42:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d44:	0001b717          	auipc	a4,0x1b
    80002d48:	ddc70713          	addi	a4,a4,-548 # 8001db20 <bcache+0x8268>
    80002d4c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d4e:	2b87b703          	ld	a4,696(a5)
    80002d52:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d54:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d58:	00013517          	auipc	a0,0x13
    80002d5c:	b6050513          	addi	a0,a0,-1184 # 800158b8 <bcache>
    80002d60:	f2dfd0ef          	jal	80000c8c <release>
}
    80002d64:	60e2                	ld	ra,24(sp)
    80002d66:	6442                	ld	s0,16(sp)
    80002d68:	64a2                	ld	s1,8(sp)
    80002d6a:	6902                	ld	s2,0(sp)
    80002d6c:	6105                	addi	sp,sp,32
    80002d6e:	8082                	ret
    panic("brelse");
    80002d70:	00004517          	auipc	a0,0x4
    80002d74:	72050513          	addi	a0,a0,1824 # 80007490 <etext+0x490>
    80002d78:	a1dfd0ef          	jal	80000794 <panic>

0000000080002d7c <bpin>:

void
bpin(struct buf *b) {
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	1000                	addi	s0,sp,32
    80002d86:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d88:	00013517          	auipc	a0,0x13
    80002d8c:	b3050513          	addi	a0,a0,-1232 # 800158b8 <bcache>
    80002d90:	e65fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002d94:	40bc                	lw	a5,64(s1)
    80002d96:	2785                	addiw	a5,a5,1
    80002d98:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d9a:	00013517          	auipc	a0,0x13
    80002d9e:	b1e50513          	addi	a0,a0,-1250 # 800158b8 <bcache>
    80002da2:	eebfd0ef          	jal	80000c8c <release>
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <bunpin>:

void
bunpin(struct buf *b) {
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	1000                	addi	s0,sp,32
    80002dba:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dbc:	00013517          	auipc	a0,0x13
    80002dc0:	afc50513          	addi	a0,a0,-1284 # 800158b8 <bcache>
    80002dc4:	e31fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002dc8:	40bc                	lw	a5,64(s1)
    80002dca:	37fd                	addiw	a5,a5,-1
    80002dcc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dce:	00013517          	auipc	a0,0x13
    80002dd2:	aea50513          	addi	a0,a0,-1302 # 800158b8 <bcache>
    80002dd6:	eb7fd0ef          	jal	80000c8c <release>
}
    80002dda:	60e2                	ld	ra,24(sp)
    80002ddc:	6442                	ld	s0,16(sp)
    80002dde:	64a2                	ld	s1,8(sp)
    80002de0:	6105                	addi	sp,sp,32
    80002de2:	8082                	ret

0000000080002de4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	e04a                	sd	s2,0(sp)
    80002dee:	1000                	addi	s0,sp,32
    80002df0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002df2:	00d5d59b          	srliw	a1,a1,0xd
    80002df6:	0001b797          	auipc	a5,0x1b
    80002dfa:	19e7a783          	lw	a5,414(a5) # 8001df94 <sb+0x1c>
    80002dfe:	9dbd                	addw	a1,a1,a5
    80002e00:	dedff0ef          	jal	80002bec <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e04:	0074f713          	andi	a4,s1,7
    80002e08:	4785                	li	a5,1
    80002e0a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002e0e:	14ce                	slli	s1,s1,0x33
    80002e10:	90d9                	srli	s1,s1,0x36
    80002e12:	00950733          	add	a4,a0,s1
    80002e16:	05874703          	lbu	a4,88(a4)
    80002e1a:	00e7f6b3          	and	a3,a5,a4
    80002e1e:	c29d                	beqz	a3,80002e44 <bfree+0x60>
    80002e20:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e22:	94aa                	add	s1,s1,a0
    80002e24:	fff7c793          	not	a5,a5
    80002e28:	8f7d                	and	a4,a4,a5
    80002e2a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e2e:	711000ef          	jal	80003d3e <log_write>
  brelse(bp);
    80002e32:	854a                	mv	a0,s2
    80002e34:	ec1ff0ef          	jal	80002cf4 <brelse>
}
    80002e38:	60e2                	ld	ra,24(sp)
    80002e3a:	6442                	ld	s0,16(sp)
    80002e3c:	64a2                	ld	s1,8(sp)
    80002e3e:	6902                	ld	s2,0(sp)
    80002e40:	6105                	addi	sp,sp,32
    80002e42:	8082                	ret
    panic("freeing free block");
    80002e44:	00004517          	auipc	a0,0x4
    80002e48:	65450513          	addi	a0,a0,1620 # 80007498 <etext+0x498>
    80002e4c:	949fd0ef          	jal	80000794 <panic>

0000000080002e50 <balloc>:
{
    80002e50:	711d                	addi	sp,sp,-96
    80002e52:	ec86                	sd	ra,88(sp)
    80002e54:	e8a2                	sd	s0,80(sp)
    80002e56:	e4a6                	sd	s1,72(sp)
    80002e58:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e5a:	0001b797          	auipc	a5,0x1b
    80002e5e:	1227a783          	lw	a5,290(a5) # 8001df7c <sb+0x4>
    80002e62:	0e078f63          	beqz	a5,80002f60 <balloc+0x110>
    80002e66:	e0ca                	sd	s2,64(sp)
    80002e68:	fc4e                	sd	s3,56(sp)
    80002e6a:	f852                	sd	s4,48(sp)
    80002e6c:	f456                	sd	s5,40(sp)
    80002e6e:	f05a                	sd	s6,32(sp)
    80002e70:	ec5e                	sd	s7,24(sp)
    80002e72:	e862                	sd	s8,16(sp)
    80002e74:	e466                	sd	s9,8(sp)
    80002e76:	8baa                	mv	s7,a0
    80002e78:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e7a:	0001bb17          	auipc	s6,0x1b
    80002e7e:	0feb0b13          	addi	s6,s6,254 # 8001df78 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e82:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e84:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e86:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e88:	6c89                	lui	s9,0x2
    80002e8a:	a0b5                	j	80002ef6 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e8c:	97ca                	add	a5,a5,s2
    80002e8e:	8e55                	or	a2,a2,a3
    80002e90:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e94:	854a                	mv	a0,s2
    80002e96:	6a9000ef          	jal	80003d3e <log_write>
        brelse(bp);
    80002e9a:	854a                	mv	a0,s2
    80002e9c:	e59ff0ef          	jal	80002cf4 <brelse>
  bp = bread(dev, bno);
    80002ea0:	85a6                	mv	a1,s1
    80002ea2:	855e                	mv	a0,s7
    80002ea4:	d49ff0ef          	jal	80002bec <bread>
    80002ea8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002eaa:	40000613          	li	a2,1024
    80002eae:	4581                	li	a1,0
    80002eb0:	05850513          	addi	a0,a0,88
    80002eb4:	e15fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002eb8:	854a                	mv	a0,s2
    80002eba:	685000ef          	jal	80003d3e <log_write>
  brelse(bp);
    80002ebe:	854a                	mv	a0,s2
    80002ec0:	e35ff0ef          	jal	80002cf4 <brelse>
}
    80002ec4:	6906                	ld	s2,64(sp)
    80002ec6:	79e2                	ld	s3,56(sp)
    80002ec8:	7a42                	ld	s4,48(sp)
    80002eca:	7aa2                	ld	s5,40(sp)
    80002ecc:	7b02                	ld	s6,32(sp)
    80002ece:	6be2                	ld	s7,24(sp)
    80002ed0:	6c42                	ld	s8,16(sp)
    80002ed2:	6ca2                	ld	s9,8(sp)
}
    80002ed4:	8526                	mv	a0,s1
    80002ed6:	60e6                	ld	ra,88(sp)
    80002ed8:	6446                	ld	s0,80(sp)
    80002eda:	64a6                	ld	s1,72(sp)
    80002edc:	6125                	addi	sp,sp,96
    80002ede:	8082                	ret
    brelse(bp);
    80002ee0:	854a                	mv	a0,s2
    80002ee2:	e13ff0ef          	jal	80002cf4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ee6:	015c87bb          	addw	a5,s9,s5
    80002eea:	00078a9b          	sext.w	s5,a5
    80002eee:	004b2703          	lw	a4,4(s6)
    80002ef2:	04eaff63          	bgeu	s5,a4,80002f50 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002ef6:	41fad79b          	sraiw	a5,s5,0x1f
    80002efa:	0137d79b          	srliw	a5,a5,0x13
    80002efe:	015787bb          	addw	a5,a5,s5
    80002f02:	40d7d79b          	sraiw	a5,a5,0xd
    80002f06:	01cb2583          	lw	a1,28(s6)
    80002f0a:	9dbd                	addw	a1,a1,a5
    80002f0c:	855e                	mv	a0,s7
    80002f0e:	cdfff0ef          	jal	80002bec <bread>
    80002f12:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f14:	004b2503          	lw	a0,4(s6)
    80002f18:	000a849b          	sext.w	s1,s5
    80002f1c:	8762                	mv	a4,s8
    80002f1e:	fca4f1e3          	bgeu	s1,a0,80002ee0 <balloc+0x90>
      m = 1 << (bi % 8);
    80002f22:	00777693          	andi	a3,a4,7
    80002f26:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f2a:	41f7579b          	sraiw	a5,a4,0x1f
    80002f2e:	01d7d79b          	srliw	a5,a5,0x1d
    80002f32:	9fb9                	addw	a5,a5,a4
    80002f34:	4037d79b          	sraiw	a5,a5,0x3
    80002f38:	00f90633          	add	a2,s2,a5
    80002f3c:	05864603          	lbu	a2,88(a2)
    80002f40:	00c6f5b3          	and	a1,a3,a2
    80002f44:	d5a1                	beqz	a1,80002e8c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f46:	2705                	addiw	a4,a4,1
    80002f48:	2485                	addiw	s1,s1,1
    80002f4a:	fd471ae3          	bne	a4,s4,80002f1e <balloc+0xce>
    80002f4e:	bf49                	j	80002ee0 <balloc+0x90>
    80002f50:	6906                	ld	s2,64(sp)
    80002f52:	79e2                	ld	s3,56(sp)
    80002f54:	7a42                	ld	s4,48(sp)
    80002f56:	7aa2                	ld	s5,40(sp)
    80002f58:	7b02                	ld	s6,32(sp)
    80002f5a:	6be2                	ld	s7,24(sp)
    80002f5c:	6c42                	ld	s8,16(sp)
    80002f5e:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002f60:	00004517          	auipc	a0,0x4
    80002f64:	55050513          	addi	a0,a0,1360 # 800074b0 <etext+0x4b0>
    80002f68:	d5afd0ef          	jal	800004c2 <printf>
  return 0;
    80002f6c:	4481                	li	s1,0
    80002f6e:	b79d                	j	80002ed4 <balloc+0x84>

0000000080002f70 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f70:	7179                	addi	sp,sp,-48
    80002f72:	f406                	sd	ra,40(sp)
    80002f74:	f022                	sd	s0,32(sp)
    80002f76:	ec26                	sd	s1,24(sp)
    80002f78:	e84a                	sd	s2,16(sp)
    80002f7a:	e44e                	sd	s3,8(sp)
    80002f7c:	1800                	addi	s0,sp,48
    80002f7e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f80:	47ad                	li	a5,11
    80002f82:	02b7e663          	bltu	a5,a1,80002fae <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f86:	02059793          	slli	a5,a1,0x20
    80002f8a:	01e7d593          	srli	a1,a5,0x1e
    80002f8e:	00b504b3          	add	s1,a0,a1
    80002f92:	0504a903          	lw	s2,80(s1)
    80002f96:	06091a63          	bnez	s2,8000300a <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f9a:	4108                	lw	a0,0(a0)
    80002f9c:	eb5ff0ef          	jal	80002e50 <balloc>
    80002fa0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002fa4:	06090363          	beqz	s2,8000300a <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002fa8:	0524a823          	sw	s2,80(s1)
    80002fac:	a8b9                	j	8000300a <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002fae:	ff45849b          	addiw	s1,a1,-12
    80002fb2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002fb6:	0ff00793          	li	a5,255
    80002fba:	06e7ee63          	bltu	a5,a4,80003036 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002fbe:	08052903          	lw	s2,128(a0)
    80002fc2:	00091d63          	bnez	s2,80002fdc <bmap+0x6c>
      addr = balloc(ip->dev);
    80002fc6:	4108                	lw	a0,0(a0)
    80002fc8:	e89ff0ef          	jal	80002e50 <balloc>
    80002fcc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002fd0:	02090d63          	beqz	s2,8000300a <bmap+0x9a>
    80002fd4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fd6:	0929a023          	sw	s2,128(s3)
    80002fda:	a011                	j	80002fde <bmap+0x6e>
    80002fdc:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fde:	85ca                	mv	a1,s2
    80002fe0:	0009a503          	lw	a0,0(s3)
    80002fe4:	c09ff0ef          	jal	80002bec <bread>
    80002fe8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fea:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fee:	02049713          	slli	a4,s1,0x20
    80002ff2:	01e75593          	srli	a1,a4,0x1e
    80002ff6:	00b784b3          	add	s1,a5,a1
    80002ffa:	0004a903          	lw	s2,0(s1)
    80002ffe:	00090e63          	beqz	s2,8000301a <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003002:	8552                	mv	a0,s4
    80003004:	cf1ff0ef          	jal	80002cf4 <brelse>
    return addr;
    80003008:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000300a:	854a                	mv	a0,s2
    8000300c:	70a2                	ld	ra,40(sp)
    8000300e:	7402                	ld	s0,32(sp)
    80003010:	64e2                	ld	s1,24(sp)
    80003012:	6942                	ld	s2,16(sp)
    80003014:	69a2                	ld	s3,8(sp)
    80003016:	6145                	addi	sp,sp,48
    80003018:	8082                	ret
      addr = balloc(ip->dev);
    8000301a:	0009a503          	lw	a0,0(s3)
    8000301e:	e33ff0ef          	jal	80002e50 <balloc>
    80003022:	0005091b          	sext.w	s2,a0
      if(addr){
    80003026:	fc090ee3          	beqz	s2,80003002 <bmap+0x92>
        a[bn] = addr;
    8000302a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000302e:	8552                	mv	a0,s4
    80003030:	50f000ef          	jal	80003d3e <log_write>
    80003034:	b7f9                	j	80003002 <bmap+0x92>
    80003036:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003038:	00004517          	auipc	a0,0x4
    8000303c:	49050513          	addi	a0,a0,1168 # 800074c8 <etext+0x4c8>
    80003040:	f54fd0ef          	jal	80000794 <panic>

0000000080003044 <iget>:
{
    80003044:	7179                	addi	sp,sp,-48
    80003046:	f406                	sd	ra,40(sp)
    80003048:	f022                	sd	s0,32(sp)
    8000304a:	ec26                	sd	s1,24(sp)
    8000304c:	e84a                	sd	s2,16(sp)
    8000304e:	e44e                	sd	s3,8(sp)
    80003050:	e052                	sd	s4,0(sp)
    80003052:	1800                	addi	s0,sp,48
    80003054:	89aa                	mv	s3,a0
    80003056:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003058:	0001b517          	auipc	a0,0x1b
    8000305c:	f4050513          	addi	a0,a0,-192 # 8001df98 <itable>
    80003060:	b95fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003064:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003066:	0001b497          	auipc	s1,0x1b
    8000306a:	f4a48493          	addi	s1,s1,-182 # 8001dfb0 <itable+0x18>
    8000306e:	0001d697          	auipc	a3,0x1d
    80003072:	9d268693          	addi	a3,a3,-1582 # 8001fa40 <log>
    80003076:	a039                	j	80003084 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003078:	02090963          	beqz	s2,800030aa <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000307c:	08848493          	addi	s1,s1,136
    80003080:	02d48863          	beq	s1,a3,800030b0 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003084:	449c                	lw	a5,8(s1)
    80003086:	fef059e3          	blez	a5,80003078 <iget+0x34>
    8000308a:	4098                	lw	a4,0(s1)
    8000308c:	ff3716e3          	bne	a4,s3,80003078 <iget+0x34>
    80003090:	40d8                	lw	a4,4(s1)
    80003092:	ff4713e3          	bne	a4,s4,80003078 <iget+0x34>
      ip->ref++;
    80003096:	2785                	addiw	a5,a5,1
    80003098:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000309a:	0001b517          	auipc	a0,0x1b
    8000309e:	efe50513          	addi	a0,a0,-258 # 8001df98 <itable>
    800030a2:	bebfd0ef          	jal	80000c8c <release>
      return ip;
    800030a6:	8926                	mv	s2,s1
    800030a8:	a02d                	j	800030d2 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030aa:	fbe9                	bnez	a5,8000307c <iget+0x38>
      empty = ip;
    800030ac:	8926                	mv	s2,s1
    800030ae:	b7f9                	j	8000307c <iget+0x38>
  if(empty == 0)
    800030b0:	02090a63          	beqz	s2,800030e4 <iget+0xa0>
  ip->dev = dev;
    800030b4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800030b8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800030bc:	4785                	li	a5,1
    800030be:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800030c2:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800030c6:	0001b517          	auipc	a0,0x1b
    800030ca:	ed250513          	addi	a0,a0,-302 # 8001df98 <itable>
    800030ce:	bbffd0ef          	jal	80000c8c <release>
}
    800030d2:	854a                	mv	a0,s2
    800030d4:	70a2                	ld	ra,40(sp)
    800030d6:	7402                	ld	s0,32(sp)
    800030d8:	64e2                	ld	s1,24(sp)
    800030da:	6942                	ld	s2,16(sp)
    800030dc:	69a2                	ld	s3,8(sp)
    800030de:	6a02                	ld	s4,0(sp)
    800030e0:	6145                	addi	sp,sp,48
    800030e2:	8082                	ret
    panic("iget: no inodes");
    800030e4:	00004517          	auipc	a0,0x4
    800030e8:	3fc50513          	addi	a0,a0,1020 # 800074e0 <etext+0x4e0>
    800030ec:	ea8fd0ef          	jal	80000794 <panic>

00000000800030f0 <fsinit>:
fsinit(int dev) {
    800030f0:	7179                	addi	sp,sp,-48
    800030f2:	f406                	sd	ra,40(sp)
    800030f4:	f022                	sd	s0,32(sp)
    800030f6:	ec26                	sd	s1,24(sp)
    800030f8:	e84a                	sd	s2,16(sp)
    800030fa:	e44e                	sd	s3,8(sp)
    800030fc:	1800                	addi	s0,sp,48
    800030fe:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003100:	4585                	li	a1,1
    80003102:	aebff0ef          	jal	80002bec <bread>
    80003106:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003108:	0001b997          	auipc	s3,0x1b
    8000310c:	e7098993          	addi	s3,s3,-400 # 8001df78 <sb>
    80003110:	02000613          	li	a2,32
    80003114:	05850593          	addi	a1,a0,88
    80003118:	854e                	mv	a0,s3
    8000311a:	c0bfd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    8000311e:	8526                	mv	a0,s1
    80003120:	bd5ff0ef          	jal	80002cf4 <brelse>
  if(sb.magic != FSMAGIC)
    80003124:	0009a703          	lw	a4,0(s3)
    80003128:	102037b7          	lui	a5,0x10203
    8000312c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003130:	02f71063          	bne	a4,a5,80003150 <fsinit+0x60>
  initlog(dev, &sb);
    80003134:	0001b597          	auipc	a1,0x1b
    80003138:	e4458593          	addi	a1,a1,-444 # 8001df78 <sb>
    8000313c:	854a                	mv	a0,s2
    8000313e:	1f9000ef          	jal	80003b36 <initlog>
}
    80003142:	70a2                	ld	ra,40(sp)
    80003144:	7402                	ld	s0,32(sp)
    80003146:	64e2                	ld	s1,24(sp)
    80003148:	6942                	ld	s2,16(sp)
    8000314a:	69a2                	ld	s3,8(sp)
    8000314c:	6145                	addi	sp,sp,48
    8000314e:	8082                	ret
    panic("invalid file system");
    80003150:	00004517          	auipc	a0,0x4
    80003154:	3a050513          	addi	a0,a0,928 # 800074f0 <etext+0x4f0>
    80003158:	e3cfd0ef          	jal	80000794 <panic>

000000008000315c <iinit>:
{
    8000315c:	7179                	addi	sp,sp,-48
    8000315e:	f406                	sd	ra,40(sp)
    80003160:	f022                	sd	s0,32(sp)
    80003162:	ec26                	sd	s1,24(sp)
    80003164:	e84a                	sd	s2,16(sp)
    80003166:	e44e                	sd	s3,8(sp)
    80003168:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000316a:	00004597          	auipc	a1,0x4
    8000316e:	39e58593          	addi	a1,a1,926 # 80007508 <etext+0x508>
    80003172:	0001b517          	auipc	a0,0x1b
    80003176:	e2650513          	addi	a0,a0,-474 # 8001df98 <itable>
    8000317a:	9fbfd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000317e:	0001b497          	auipc	s1,0x1b
    80003182:	e4248493          	addi	s1,s1,-446 # 8001dfc0 <itable+0x28>
    80003186:	0001d997          	auipc	s3,0x1d
    8000318a:	8ca98993          	addi	s3,s3,-1846 # 8001fa50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000318e:	00004917          	auipc	s2,0x4
    80003192:	38290913          	addi	s2,s2,898 # 80007510 <etext+0x510>
    80003196:	85ca                	mv	a1,s2
    80003198:	8526                	mv	a0,s1
    8000319a:	475000ef          	jal	80003e0e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000319e:	08848493          	addi	s1,s1,136
    800031a2:	ff349ae3          	bne	s1,s3,80003196 <iinit+0x3a>
}
    800031a6:	70a2                	ld	ra,40(sp)
    800031a8:	7402                	ld	s0,32(sp)
    800031aa:	64e2                	ld	s1,24(sp)
    800031ac:	6942                	ld	s2,16(sp)
    800031ae:	69a2                	ld	s3,8(sp)
    800031b0:	6145                	addi	sp,sp,48
    800031b2:	8082                	ret

00000000800031b4 <ialloc>:
{
    800031b4:	7139                	addi	sp,sp,-64
    800031b6:	fc06                	sd	ra,56(sp)
    800031b8:	f822                	sd	s0,48(sp)
    800031ba:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800031bc:	0001b717          	auipc	a4,0x1b
    800031c0:	dc872703          	lw	a4,-568(a4) # 8001df84 <sb+0xc>
    800031c4:	4785                	li	a5,1
    800031c6:	06e7f063          	bgeu	a5,a4,80003226 <ialloc+0x72>
    800031ca:	f426                	sd	s1,40(sp)
    800031cc:	f04a                	sd	s2,32(sp)
    800031ce:	ec4e                	sd	s3,24(sp)
    800031d0:	e852                	sd	s4,16(sp)
    800031d2:	e456                	sd	s5,8(sp)
    800031d4:	e05a                	sd	s6,0(sp)
    800031d6:	8aaa                	mv	s5,a0
    800031d8:	8b2e                	mv	s6,a1
    800031da:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800031dc:	0001ba17          	auipc	s4,0x1b
    800031e0:	d9ca0a13          	addi	s4,s4,-612 # 8001df78 <sb>
    800031e4:	00495593          	srli	a1,s2,0x4
    800031e8:	018a2783          	lw	a5,24(s4)
    800031ec:	9dbd                	addw	a1,a1,a5
    800031ee:	8556                	mv	a0,s5
    800031f0:	9fdff0ef          	jal	80002bec <bread>
    800031f4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800031f6:	05850993          	addi	s3,a0,88
    800031fa:	00f97793          	andi	a5,s2,15
    800031fe:	079a                	slli	a5,a5,0x6
    80003200:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003202:	00099783          	lh	a5,0(s3)
    80003206:	cb9d                	beqz	a5,8000323c <ialloc+0x88>
    brelse(bp);
    80003208:	aedff0ef          	jal	80002cf4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000320c:	0905                	addi	s2,s2,1
    8000320e:	00ca2703          	lw	a4,12(s4)
    80003212:	0009079b          	sext.w	a5,s2
    80003216:	fce7e7e3          	bltu	a5,a4,800031e4 <ialloc+0x30>
    8000321a:	74a2                	ld	s1,40(sp)
    8000321c:	7902                	ld	s2,32(sp)
    8000321e:	69e2                	ld	s3,24(sp)
    80003220:	6a42                	ld	s4,16(sp)
    80003222:	6aa2                	ld	s5,8(sp)
    80003224:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003226:	00004517          	auipc	a0,0x4
    8000322a:	2f250513          	addi	a0,a0,754 # 80007518 <etext+0x518>
    8000322e:	a94fd0ef          	jal	800004c2 <printf>
  return 0;
    80003232:	4501                	li	a0,0
}
    80003234:	70e2                	ld	ra,56(sp)
    80003236:	7442                	ld	s0,48(sp)
    80003238:	6121                	addi	sp,sp,64
    8000323a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000323c:	04000613          	li	a2,64
    80003240:	4581                	li	a1,0
    80003242:	854e                	mv	a0,s3
    80003244:	a85fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    80003248:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000324c:	8526                	mv	a0,s1
    8000324e:	2f1000ef          	jal	80003d3e <log_write>
      brelse(bp);
    80003252:	8526                	mv	a0,s1
    80003254:	aa1ff0ef          	jal	80002cf4 <brelse>
      return iget(dev, inum);
    80003258:	0009059b          	sext.w	a1,s2
    8000325c:	8556                	mv	a0,s5
    8000325e:	de7ff0ef          	jal	80003044 <iget>
    80003262:	74a2                	ld	s1,40(sp)
    80003264:	7902                	ld	s2,32(sp)
    80003266:	69e2                	ld	s3,24(sp)
    80003268:	6a42                	ld	s4,16(sp)
    8000326a:	6aa2                	ld	s5,8(sp)
    8000326c:	6b02                	ld	s6,0(sp)
    8000326e:	b7d9                	j	80003234 <ialloc+0x80>

0000000080003270 <iupdate>:
{
    80003270:	1101                	addi	sp,sp,-32
    80003272:	ec06                	sd	ra,24(sp)
    80003274:	e822                	sd	s0,16(sp)
    80003276:	e426                	sd	s1,8(sp)
    80003278:	e04a                	sd	s2,0(sp)
    8000327a:	1000                	addi	s0,sp,32
    8000327c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000327e:	415c                	lw	a5,4(a0)
    80003280:	0047d79b          	srliw	a5,a5,0x4
    80003284:	0001b597          	auipc	a1,0x1b
    80003288:	d0c5a583          	lw	a1,-756(a1) # 8001df90 <sb+0x18>
    8000328c:	9dbd                	addw	a1,a1,a5
    8000328e:	4108                	lw	a0,0(a0)
    80003290:	95dff0ef          	jal	80002bec <bread>
    80003294:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003296:	05850793          	addi	a5,a0,88
    8000329a:	40d8                	lw	a4,4(s1)
    8000329c:	8b3d                	andi	a4,a4,15
    8000329e:	071a                	slli	a4,a4,0x6
    800032a0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800032a2:	04449703          	lh	a4,68(s1)
    800032a6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800032aa:	04649703          	lh	a4,70(s1)
    800032ae:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800032b2:	04849703          	lh	a4,72(s1)
    800032b6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800032ba:	04a49703          	lh	a4,74(s1)
    800032be:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800032c2:	44f8                	lw	a4,76(s1)
    800032c4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800032c6:	03400613          	li	a2,52
    800032ca:	05048593          	addi	a1,s1,80
    800032ce:	00c78513          	addi	a0,a5,12
    800032d2:	a53fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    800032d6:	854a                	mv	a0,s2
    800032d8:	267000ef          	jal	80003d3e <log_write>
  brelse(bp);
    800032dc:	854a                	mv	a0,s2
    800032de:	a17ff0ef          	jal	80002cf4 <brelse>
}
    800032e2:	60e2                	ld	ra,24(sp)
    800032e4:	6442                	ld	s0,16(sp)
    800032e6:	64a2                	ld	s1,8(sp)
    800032e8:	6902                	ld	s2,0(sp)
    800032ea:	6105                	addi	sp,sp,32
    800032ec:	8082                	ret

00000000800032ee <idup>:
{
    800032ee:	1101                	addi	sp,sp,-32
    800032f0:	ec06                	sd	ra,24(sp)
    800032f2:	e822                	sd	s0,16(sp)
    800032f4:	e426                	sd	s1,8(sp)
    800032f6:	1000                	addi	s0,sp,32
    800032f8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800032fa:	0001b517          	auipc	a0,0x1b
    800032fe:	c9e50513          	addi	a0,a0,-866 # 8001df98 <itable>
    80003302:	8f3fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    80003306:	449c                	lw	a5,8(s1)
    80003308:	2785                	addiw	a5,a5,1
    8000330a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000330c:	0001b517          	auipc	a0,0x1b
    80003310:	c8c50513          	addi	a0,a0,-884 # 8001df98 <itable>
    80003314:	979fd0ef          	jal	80000c8c <release>
}
    80003318:	8526                	mv	a0,s1
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	64a2                	ld	s1,8(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret

0000000080003324 <ilock>:
{
    80003324:	1101                	addi	sp,sp,-32
    80003326:	ec06                	sd	ra,24(sp)
    80003328:	e822                	sd	s0,16(sp)
    8000332a:	e426                	sd	s1,8(sp)
    8000332c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000332e:	cd19                	beqz	a0,8000334c <ilock+0x28>
    80003330:	84aa                	mv	s1,a0
    80003332:	451c                	lw	a5,8(a0)
    80003334:	00f05c63          	blez	a5,8000334c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003338:	0541                	addi	a0,a0,16
    8000333a:	30b000ef          	jal	80003e44 <acquiresleep>
  if(ip->valid == 0){
    8000333e:	40bc                	lw	a5,64(s1)
    80003340:	cf89                	beqz	a5,8000335a <ilock+0x36>
}
    80003342:	60e2                	ld	ra,24(sp)
    80003344:	6442                	ld	s0,16(sp)
    80003346:	64a2                	ld	s1,8(sp)
    80003348:	6105                	addi	sp,sp,32
    8000334a:	8082                	ret
    8000334c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000334e:	00004517          	auipc	a0,0x4
    80003352:	1e250513          	addi	a0,a0,482 # 80007530 <etext+0x530>
    80003356:	c3efd0ef          	jal	80000794 <panic>
    8000335a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000335c:	40dc                	lw	a5,4(s1)
    8000335e:	0047d79b          	srliw	a5,a5,0x4
    80003362:	0001b597          	auipc	a1,0x1b
    80003366:	c2e5a583          	lw	a1,-978(a1) # 8001df90 <sb+0x18>
    8000336a:	9dbd                	addw	a1,a1,a5
    8000336c:	4088                	lw	a0,0(s1)
    8000336e:	87fff0ef          	jal	80002bec <bread>
    80003372:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003374:	05850593          	addi	a1,a0,88
    80003378:	40dc                	lw	a5,4(s1)
    8000337a:	8bbd                	andi	a5,a5,15
    8000337c:	079a                	slli	a5,a5,0x6
    8000337e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003380:	00059783          	lh	a5,0(a1)
    80003384:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003388:	00259783          	lh	a5,2(a1)
    8000338c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003390:	00459783          	lh	a5,4(a1)
    80003394:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003398:	00659783          	lh	a5,6(a1)
    8000339c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800033a0:	459c                	lw	a5,8(a1)
    800033a2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800033a4:	03400613          	li	a2,52
    800033a8:	05b1                	addi	a1,a1,12
    800033aa:	05048513          	addi	a0,s1,80
    800033ae:	977fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    800033b2:	854a                	mv	a0,s2
    800033b4:	941ff0ef          	jal	80002cf4 <brelse>
    ip->valid = 1;
    800033b8:	4785                	li	a5,1
    800033ba:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800033bc:	04449783          	lh	a5,68(s1)
    800033c0:	c399                	beqz	a5,800033c6 <ilock+0xa2>
    800033c2:	6902                	ld	s2,0(sp)
    800033c4:	bfbd                	j	80003342 <ilock+0x1e>
      panic("ilock: no type");
    800033c6:	00004517          	auipc	a0,0x4
    800033ca:	17250513          	addi	a0,a0,370 # 80007538 <etext+0x538>
    800033ce:	bc6fd0ef          	jal	80000794 <panic>

00000000800033d2 <iunlock>:
{
    800033d2:	1101                	addi	sp,sp,-32
    800033d4:	ec06                	sd	ra,24(sp)
    800033d6:	e822                	sd	s0,16(sp)
    800033d8:	e426                	sd	s1,8(sp)
    800033da:	e04a                	sd	s2,0(sp)
    800033dc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800033de:	c505                	beqz	a0,80003406 <iunlock+0x34>
    800033e0:	84aa                	mv	s1,a0
    800033e2:	01050913          	addi	s2,a0,16
    800033e6:	854a                	mv	a0,s2
    800033e8:	2db000ef          	jal	80003ec2 <holdingsleep>
    800033ec:	cd09                	beqz	a0,80003406 <iunlock+0x34>
    800033ee:	449c                	lw	a5,8(s1)
    800033f0:	00f05b63          	blez	a5,80003406 <iunlock+0x34>
  releasesleep(&ip->lock);
    800033f4:	854a                	mv	a0,s2
    800033f6:	295000ef          	jal	80003e8a <releasesleep>
}
    800033fa:	60e2                	ld	ra,24(sp)
    800033fc:	6442                	ld	s0,16(sp)
    800033fe:	64a2                	ld	s1,8(sp)
    80003400:	6902                	ld	s2,0(sp)
    80003402:	6105                	addi	sp,sp,32
    80003404:	8082                	ret
    panic("iunlock");
    80003406:	00004517          	auipc	a0,0x4
    8000340a:	14250513          	addi	a0,a0,322 # 80007548 <etext+0x548>
    8000340e:	b86fd0ef          	jal	80000794 <panic>

0000000080003412 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003412:	7179                	addi	sp,sp,-48
    80003414:	f406                	sd	ra,40(sp)
    80003416:	f022                	sd	s0,32(sp)
    80003418:	ec26                	sd	s1,24(sp)
    8000341a:	e84a                	sd	s2,16(sp)
    8000341c:	e44e                	sd	s3,8(sp)
    8000341e:	1800                	addi	s0,sp,48
    80003420:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003422:	05050493          	addi	s1,a0,80
    80003426:	08050913          	addi	s2,a0,128
    8000342a:	a021                	j	80003432 <itrunc+0x20>
    8000342c:	0491                	addi	s1,s1,4
    8000342e:	01248b63          	beq	s1,s2,80003444 <itrunc+0x32>
    if(ip->addrs[i]){
    80003432:	408c                	lw	a1,0(s1)
    80003434:	dde5                	beqz	a1,8000342c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003436:	0009a503          	lw	a0,0(s3)
    8000343a:	9abff0ef          	jal	80002de4 <bfree>
      ip->addrs[i] = 0;
    8000343e:	0004a023          	sw	zero,0(s1)
    80003442:	b7ed                	j	8000342c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003444:	0809a583          	lw	a1,128(s3)
    80003448:	ed89                	bnez	a1,80003462 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000344a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000344e:	854e                	mv	a0,s3
    80003450:	e21ff0ef          	jal	80003270 <iupdate>
}
    80003454:	70a2                	ld	ra,40(sp)
    80003456:	7402                	ld	s0,32(sp)
    80003458:	64e2                	ld	s1,24(sp)
    8000345a:	6942                	ld	s2,16(sp)
    8000345c:	69a2                	ld	s3,8(sp)
    8000345e:	6145                	addi	sp,sp,48
    80003460:	8082                	ret
    80003462:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003464:	0009a503          	lw	a0,0(s3)
    80003468:	f84ff0ef          	jal	80002bec <bread>
    8000346c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000346e:	05850493          	addi	s1,a0,88
    80003472:	45850913          	addi	s2,a0,1112
    80003476:	a021                	j	8000347e <itrunc+0x6c>
    80003478:	0491                	addi	s1,s1,4
    8000347a:	01248963          	beq	s1,s2,8000348c <itrunc+0x7a>
      if(a[j])
    8000347e:	408c                	lw	a1,0(s1)
    80003480:	dde5                	beqz	a1,80003478 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003482:	0009a503          	lw	a0,0(s3)
    80003486:	95fff0ef          	jal	80002de4 <bfree>
    8000348a:	b7fd                	j	80003478 <itrunc+0x66>
    brelse(bp);
    8000348c:	8552                	mv	a0,s4
    8000348e:	867ff0ef          	jal	80002cf4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003492:	0809a583          	lw	a1,128(s3)
    80003496:	0009a503          	lw	a0,0(s3)
    8000349a:	94bff0ef          	jal	80002de4 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000349e:	0809a023          	sw	zero,128(s3)
    800034a2:	6a02                	ld	s4,0(sp)
    800034a4:	b75d                	j	8000344a <itrunc+0x38>

00000000800034a6 <iput>:
{
    800034a6:	1101                	addi	sp,sp,-32
    800034a8:	ec06                	sd	ra,24(sp)
    800034aa:	e822                	sd	s0,16(sp)
    800034ac:	e426                	sd	s1,8(sp)
    800034ae:	1000                	addi	s0,sp,32
    800034b0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034b2:	0001b517          	auipc	a0,0x1b
    800034b6:	ae650513          	addi	a0,a0,-1306 # 8001df98 <itable>
    800034ba:	f3afd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034be:	4498                	lw	a4,8(s1)
    800034c0:	4785                	li	a5,1
    800034c2:	02f70063          	beq	a4,a5,800034e2 <iput+0x3c>
  ip->ref--;
    800034c6:	449c                	lw	a5,8(s1)
    800034c8:	37fd                	addiw	a5,a5,-1
    800034ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034cc:	0001b517          	auipc	a0,0x1b
    800034d0:	acc50513          	addi	a0,a0,-1332 # 8001df98 <itable>
    800034d4:	fb8fd0ef          	jal	80000c8c <release>
}
    800034d8:	60e2                	ld	ra,24(sp)
    800034da:	6442                	ld	s0,16(sp)
    800034dc:	64a2                	ld	s1,8(sp)
    800034de:	6105                	addi	sp,sp,32
    800034e0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800034e2:	40bc                	lw	a5,64(s1)
    800034e4:	d3ed                	beqz	a5,800034c6 <iput+0x20>
    800034e6:	04a49783          	lh	a5,74(s1)
    800034ea:	fff1                	bnez	a5,800034c6 <iput+0x20>
    800034ec:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800034ee:	01048913          	addi	s2,s1,16
    800034f2:	854a                	mv	a0,s2
    800034f4:	151000ef          	jal	80003e44 <acquiresleep>
    release(&itable.lock);
    800034f8:	0001b517          	auipc	a0,0x1b
    800034fc:	aa050513          	addi	a0,a0,-1376 # 8001df98 <itable>
    80003500:	f8cfd0ef          	jal	80000c8c <release>
    itrunc(ip);
    80003504:	8526                	mv	a0,s1
    80003506:	f0dff0ef          	jal	80003412 <itrunc>
    ip->type = 0;
    8000350a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000350e:	8526                	mv	a0,s1
    80003510:	d61ff0ef          	jal	80003270 <iupdate>
    ip->valid = 0;
    80003514:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003518:	854a                	mv	a0,s2
    8000351a:	171000ef          	jal	80003e8a <releasesleep>
    acquire(&itable.lock);
    8000351e:	0001b517          	auipc	a0,0x1b
    80003522:	a7a50513          	addi	a0,a0,-1414 # 8001df98 <itable>
    80003526:	ecefd0ef          	jal	80000bf4 <acquire>
    8000352a:	6902                	ld	s2,0(sp)
    8000352c:	bf69                	j	800034c6 <iput+0x20>

000000008000352e <iunlockput>:
{
    8000352e:	1101                	addi	sp,sp,-32
    80003530:	ec06                	sd	ra,24(sp)
    80003532:	e822                	sd	s0,16(sp)
    80003534:	e426                	sd	s1,8(sp)
    80003536:	1000                	addi	s0,sp,32
    80003538:	84aa                	mv	s1,a0
  iunlock(ip);
    8000353a:	e99ff0ef          	jal	800033d2 <iunlock>
  iput(ip);
    8000353e:	8526                	mv	a0,s1
    80003540:	f67ff0ef          	jal	800034a6 <iput>
}
    80003544:	60e2                	ld	ra,24(sp)
    80003546:	6442                	ld	s0,16(sp)
    80003548:	64a2                	ld	s1,8(sp)
    8000354a:	6105                	addi	sp,sp,32
    8000354c:	8082                	ret

000000008000354e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000354e:	1141                	addi	sp,sp,-16
    80003550:	e422                	sd	s0,8(sp)
    80003552:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003554:	411c                	lw	a5,0(a0)
    80003556:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003558:	415c                	lw	a5,4(a0)
    8000355a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000355c:	04451783          	lh	a5,68(a0)
    80003560:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003564:	04a51783          	lh	a5,74(a0)
    80003568:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000356c:	04c56783          	lwu	a5,76(a0)
    80003570:	e99c                	sd	a5,16(a1)
}
    80003572:	6422                	ld	s0,8(sp)
    80003574:	0141                	addi	sp,sp,16
    80003576:	8082                	ret

0000000080003578 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003578:	457c                	lw	a5,76(a0)
    8000357a:	0ed7eb63          	bltu	a5,a3,80003670 <readi+0xf8>
{
    8000357e:	7159                	addi	sp,sp,-112
    80003580:	f486                	sd	ra,104(sp)
    80003582:	f0a2                	sd	s0,96(sp)
    80003584:	eca6                	sd	s1,88(sp)
    80003586:	e0d2                	sd	s4,64(sp)
    80003588:	fc56                	sd	s5,56(sp)
    8000358a:	f85a                	sd	s6,48(sp)
    8000358c:	f45e                	sd	s7,40(sp)
    8000358e:	1880                	addi	s0,sp,112
    80003590:	8b2a                	mv	s6,a0
    80003592:	8bae                	mv	s7,a1
    80003594:	8a32                	mv	s4,a2
    80003596:	84b6                	mv	s1,a3
    80003598:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000359a:	9f35                	addw	a4,a4,a3
    return 0;
    8000359c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000359e:	0cd76063          	bltu	a4,a3,8000365e <readi+0xe6>
    800035a2:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800035a4:	00e7f463          	bgeu	a5,a4,800035ac <readi+0x34>
    n = ip->size - off;
    800035a8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035ac:	080a8f63          	beqz	s5,8000364a <readi+0xd2>
    800035b0:	e8ca                	sd	s2,80(sp)
    800035b2:	f062                	sd	s8,32(sp)
    800035b4:	ec66                	sd	s9,24(sp)
    800035b6:	e86a                	sd	s10,16(sp)
    800035b8:	e46e                	sd	s11,8(sp)
    800035ba:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035bc:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800035c0:	5c7d                	li	s8,-1
    800035c2:	a80d                	j	800035f4 <readi+0x7c>
    800035c4:	020d1d93          	slli	s11,s10,0x20
    800035c8:	020ddd93          	srli	s11,s11,0x20
    800035cc:	05890613          	addi	a2,s2,88
    800035d0:	86ee                	mv	a3,s11
    800035d2:	963a                	add	a2,a2,a4
    800035d4:	85d2                	mv	a1,s4
    800035d6:	855e                	mv	a0,s7
    800035d8:	c33fe0ef          	jal	8000220a <either_copyout>
    800035dc:	05850763          	beq	a0,s8,8000362a <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800035e0:	854a                	mv	a0,s2
    800035e2:	f12ff0ef          	jal	80002cf4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035e6:	013d09bb          	addw	s3,s10,s3
    800035ea:	009d04bb          	addw	s1,s10,s1
    800035ee:	9a6e                	add	s4,s4,s11
    800035f0:	0559f763          	bgeu	s3,s5,8000363e <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800035f4:	00a4d59b          	srliw	a1,s1,0xa
    800035f8:	855a                	mv	a0,s6
    800035fa:	977ff0ef          	jal	80002f70 <bmap>
    800035fe:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003602:	c5b1                	beqz	a1,8000364e <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003604:	000b2503          	lw	a0,0(s6)
    80003608:	de4ff0ef          	jal	80002bec <bread>
    8000360c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000360e:	3ff4f713          	andi	a4,s1,1023
    80003612:	40ec87bb          	subw	a5,s9,a4
    80003616:	413a86bb          	subw	a3,s5,s3
    8000361a:	8d3e                	mv	s10,a5
    8000361c:	2781                	sext.w	a5,a5
    8000361e:	0006861b          	sext.w	a2,a3
    80003622:	faf671e3          	bgeu	a2,a5,800035c4 <readi+0x4c>
    80003626:	8d36                	mv	s10,a3
    80003628:	bf71                	j	800035c4 <readi+0x4c>
      brelse(bp);
    8000362a:	854a                	mv	a0,s2
    8000362c:	ec8ff0ef          	jal	80002cf4 <brelse>
      tot = -1;
    80003630:	59fd                	li	s3,-1
      break;
    80003632:	6946                	ld	s2,80(sp)
    80003634:	7c02                	ld	s8,32(sp)
    80003636:	6ce2                	ld	s9,24(sp)
    80003638:	6d42                	ld	s10,16(sp)
    8000363a:	6da2                	ld	s11,8(sp)
    8000363c:	a831                	j	80003658 <readi+0xe0>
    8000363e:	6946                	ld	s2,80(sp)
    80003640:	7c02                	ld	s8,32(sp)
    80003642:	6ce2                	ld	s9,24(sp)
    80003644:	6d42                	ld	s10,16(sp)
    80003646:	6da2                	ld	s11,8(sp)
    80003648:	a801                	j	80003658 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000364a:	89d6                	mv	s3,s5
    8000364c:	a031                	j	80003658 <readi+0xe0>
    8000364e:	6946                	ld	s2,80(sp)
    80003650:	7c02                	ld	s8,32(sp)
    80003652:	6ce2                	ld	s9,24(sp)
    80003654:	6d42                	ld	s10,16(sp)
    80003656:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003658:	0009851b          	sext.w	a0,s3
    8000365c:	69a6                	ld	s3,72(sp)
}
    8000365e:	70a6                	ld	ra,104(sp)
    80003660:	7406                	ld	s0,96(sp)
    80003662:	64e6                	ld	s1,88(sp)
    80003664:	6a06                	ld	s4,64(sp)
    80003666:	7ae2                	ld	s5,56(sp)
    80003668:	7b42                	ld	s6,48(sp)
    8000366a:	7ba2                	ld	s7,40(sp)
    8000366c:	6165                	addi	sp,sp,112
    8000366e:	8082                	ret
    return 0;
    80003670:	4501                	li	a0,0
}
    80003672:	8082                	ret

0000000080003674 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003674:	457c                	lw	a5,76(a0)
    80003676:	10d7e063          	bltu	a5,a3,80003776 <writei+0x102>
{
    8000367a:	7159                	addi	sp,sp,-112
    8000367c:	f486                	sd	ra,104(sp)
    8000367e:	f0a2                	sd	s0,96(sp)
    80003680:	e8ca                	sd	s2,80(sp)
    80003682:	e0d2                	sd	s4,64(sp)
    80003684:	fc56                	sd	s5,56(sp)
    80003686:	f85a                	sd	s6,48(sp)
    80003688:	f45e                	sd	s7,40(sp)
    8000368a:	1880                	addi	s0,sp,112
    8000368c:	8aaa                	mv	s5,a0
    8000368e:	8bae                	mv	s7,a1
    80003690:	8a32                	mv	s4,a2
    80003692:	8936                	mv	s2,a3
    80003694:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003696:	00e687bb          	addw	a5,a3,a4
    8000369a:	0ed7e063          	bltu	a5,a3,8000377a <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000369e:	00043737          	lui	a4,0x43
    800036a2:	0cf76e63          	bltu	a4,a5,8000377e <writei+0x10a>
    800036a6:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036a8:	0a0b0f63          	beqz	s6,80003766 <writei+0xf2>
    800036ac:	eca6                	sd	s1,88(sp)
    800036ae:	f062                	sd	s8,32(sp)
    800036b0:	ec66                	sd	s9,24(sp)
    800036b2:	e86a                	sd	s10,16(sp)
    800036b4:	e46e                	sd	s11,8(sp)
    800036b6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036b8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036bc:	5c7d                	li	s8,-1
    800036be:	a825                	j	800036f6 <writei+0x82>
    800036c0:	020d1d93          	slli	s11,s10,0x20
    800036c4:	020ddd93          	srli	s11,s11,0x20
    800036c8:	05848513          	addi	a0,s1,88
    800036cc:	86ee                	mv	a3,s11
    800036ce:	8652                	mv	a2,s4
    800036d0:	85de                	mv	a1,s7
    800036d2:	953a                	add	a0,a0,a4
    800036d4:	b81fe0ef          	jal	80002254 <either_copyin>
    800036d8:	05850a63          	beq	a0,s8,8000372c <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800036dc:	8526                	mv	a0,s1
    800036de:	660000ef          	jal	80003d3e <log_write>
    brelse(bp);
    800036e2:	8526                	mv	a0,s1
    800036e4:	e10ff0ef          	jal	80002cf4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036e8:	013d09bb          	addw	s3,s10,s3
    800036ec:	012d093b          	addw	s2,s10,s2
    800036f0:	9a6e                	add	s4,s4,s11
    800036f2:	0569f063          	bgeu	s3,s6,80003732 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800036f6:	00a9559b          	srliw	a1,s2,0xa
    800036fa:	8556                	mv	a0,s5
    800036fc:	875ff0ef          	jal	80002f70 <bmap>
    80003700:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003704:	c59d                	beqz	a1,80003732 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003706:	000aa503          	lw	a0,0(s5)
    8000370a:	ce2ff0ef          	jal	80002bec <bread>
    8000370e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003710:	3ff97713          	andi	a4,s2,1023
    80003714:	40ec87bb          	subw	a5,s9,a4
    80003718:	413b06bb          	subw	a3,s6,s3
    8000371c:	8d3e                	mv	s10,a5
    8000371e:	2781                	sext.w	a5,a5
    80003720:	0006861b          	sext.w	a2,a3
    80003724:	f8f67ee3          	bgeu	a2,a5,800036c0 <writei+0x4c>
    80003728:	8d36                	mv	s10,a3
    8000372a:	bf59                	j	800036c0 <writei+0x4c>
      brelse(bp);
    8000372c:	8526                	mv	a0,s1
    8000372e:	dc6ff0ef          	jal	80002cf4 <brelse>
  }

  if(off > ip->size)
    80003732:	04caa783          	lw	a5,76(s5)
    80003736:	0327fa63          	bgeu	a5,s2,8000376a <writei+0xf6>
    ip->size = off;
    8000373a:	052aa623          	sw	s2,76(s5)
    8000373e:	64e6                	ld	s1,88(sp)
    80003740:	7c02                	ld	s8,32(sp)
    80003742:	6ce2                	ld	s9,24(sp)
    80003744:	6d42                	ld	s10,16(sp)
    80003746:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003748:	8556                	mv	a0,s5
    8000374a:	b27ff0ef          	jal	80003270 <iupdate>

  return tot;
    8000374e:	0009851b          	sext.w	a0,s3
    80003752:	69a6                	ld	s3,72(sp)
}
    80003754:	70a6                	ld	ra,104(sp)
    80003756:	7406                	ld	s0,96(sp)
    80003758:	6946                	ld	s2,80(sp)
    8000375a:	6a06                	ld	s4,64(sp)
    8000375c:	7ae2                	ld	s5,56(sp)
    8000375e:	7b42                	ld	s6,48(sp)
    80003760:	7ba2                	ld	s7,40(sp)
    80003762:	6165                	addi	sp,sp,112
    80003764:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003766:	89da                	mv	s3,s6
    80003768:	b7c5                	j	80003748 <writei+0xd4>
    8000376a:	64e6                	ld	s1,88(sp)
    8000376c:	7c02                	ld	s8,32(sp)
    8000376e:	6ce2                	ld	s9,24(sp)
    80003770:	6d42                	ld	s10,16(sp)
    80003772:	6da2                	ld	s11,8(sp)
    80003774:	bfd1                	j	80003748 <writei+0xd4>
    return -1;
    80003776:	557d                	li	a0,-1
}
    80003778:	8082                	ret
    return -1;
    8000377a:	557d                	li	a0,-1
    8000377c:	bfe1                	j	80003754 <writei+0xe0>
    return -1;
    8000377e:	557d                	li	a0,-1
    80003780:	bfd1                	j	80003754 <writei+0xe0>

0000000080003782 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003782:	1141                	addi	sp,sp,-16
    80003784:	e406                	sd	ra,8(sp)
    80003786:	e022                	sd	s0,0(sp)
    80003788:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000378a:	4639                	li	a2,14
    8000378c:	e08fd0ef          	jal	80000d94 <strncmp>
}
    80003790:	60a2                	ld	ra,8(sp)
    80003792:	6402                	ld	s0,0(sp)
    80003794:	0141                	addi	sp,sp,16
    80003796:	8082                	ret

0000000080003798 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003798:	7139                	addi	sp,sp,-64
    8000379a:	fc06                	sd	ra,56(sp)
    8000379c:	f822                	sd	s0,48(sp)
    8000379e:	f426                	sd	s1,40(sp)
    800037a0:	f04a                	sd	s2,32(sp)
    800037a2:	ec4e                	sd	s3,24(sp)
    800037a4:	e852                	sd	s4,16(sp)
    800037a6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800037a8:	04451703          	lh	a4,68(a0)
    800037ac:	4785                	li	a5,1
    800037ae:	00f71a63          	bne	a4,a5,800037c2 <dirlookup+0x2a>
    800037b2:	892a                	mv	s2,a0
    800037b4:	89ae                	mv	s3,a1
    800037b6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800037b8:	457c                	lw	a5,76(a0)
    800037ba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800037bc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037be:	e39d                	bnez	a5,800037e4 <dirlookup+0x4c>
    800037c0:	a095                	j	80003824 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800037c2:	00004517          	auipc	a0,0x4
    800037c6:	d8e50513          	addi	a0,a0,-626 # 80007550 <etext+0x550>
    800037ca:	fcbfc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    800037ce:	00004517          	auipc	a0,0x4
    800037d2:	d9a50513          	addi	a0,a0,-614 # 80007568 <etext+0x568>
    800037d6:	fbffc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037da:	24c1                	addiw	s1,s1,16
    800037dc:	04c92783          	lw	a5,76(s2)
    800037e0:	04f4f163          	bgeu	s1,a5,80003822 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800037e4:	4741                	li	a4,16
    800037e6:	86a6                	mv	a3,s1
    800037e8:	fc040613          	addi	a2,s0,-64
    800037ec:	4581                	li	a1,0
    800037ee:	854a                	mv	a0,s2
    800037f0:	d89ff0ef          	jal	80003578 <readi>
    800037f4:	47c1                	li	a5,16
    800037f6:	fcf51ce3          	bne	a0,a5,800037ce <dirlookup+0x36>
    if(de.inum == 0)
    800037fa:	fc045783          	lhu	a5,-64(s0)
    800037fe:	dff1                	beqz	a5,800037da <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003800:	fc240593          	addi	a1,s0,-62
    80003804:	854e                	mv	a0,s3
    80003806:	f7dff0ef          	jal	80003782 <namecmp>
    8000380a:	f961                	bnez	a0,800037da <dirlookup+0x42>
      if(poff)
    8000380c:	000a0463          	beqz	s4,80003814 <dirlookup+0x7c>
        *poff = off;
    80003810:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003814:	fc045583          	lhu	a1,-64(s0)
    80003818:	00092503          	lw	a0,0(s2)
    8000381c:	829ff0ef          	jal	80003044 <iget>
    80003820:	a011                	j	80003824 <dirlookup+0x8c>
  return 0;
    80003822:	4501                	li	a0,0
}
    80003824:	70e2                	ld	ra,56(sp)
    80003826:	7442                	ld	s0,48(sp)
    80003828:	74a2                	ld	s1,40(sp)
    8000382a:	7902                	ld	s2,32(sp)
    8000382c:	69e2                	ld	s3,24(sp)
    8000382e:	6a42                	ld	s4,16(sp)
    80003830:	6121                	addi	sp,sp,64
    80003832:	8082                	ret

0000000080003834 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003834:	711d                	addi	sp,sp,-96
    80003836:	ec86                	sd	ra,88(sp)
    80003838:	e8a2                	sd	s0,80(sp)
    8000383a:	e4a6                	sd	s1,72(sp)
    8000383c:	e0ca                	sd	s2,64(sp)
    8000383e:	fc4e                	sd	s3,56(sp)
    80003840:	f852                	sd	s4,48(sp)
    80003842:	f456                	sd	s5,40(sp)
    80003844:	f05a                	sd	s6,32(sp)
    80003846:	ec5e                	sd	s7,24(sp)
    80003848:	e862                	sd	s8,16(sp)
    8000384a:	e466                	sd	s9,8(sp)
    8000384c:	1080                	addi	s0,sp,96
    8000384e:	84aa                	mv	s1,a0
    80003850:	8b2e                	mv	s6,a1
    80003852:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003854:	00054703          	lbu	a4,0(a0)
    80003858:	02f00793          	li	a5,47
    8000385c:	00f70e63          	beq	a4,a5,80003878 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003860:	880fe0ef          	jal	800018e0 <myproc>
    80003864:	15053503          	ld	a0,336(a0)
    80003868:	a87ff0ef          	jal	800032ee <idup>
    8000386c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000386e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003872:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003874:	4b85                	li	s7,1
    80003876:	a871                	j	80003912 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003878:	4585                	li	a1,1
    8000387a:	4505                	li	a0,1
    8000387c:	fc8ff0ef          	jal	80003044 <iget>
    80003880:	8a2a                	mv	s4,a0
    80003882:	b7f5                	j	8000386e <namex+0x3a>
      iunlockput(ip);
    80003884:	8552                	mv	a0,s4
    80003886:	ca9ff0ef          	jal	8000352e <iunlockput>
      return 0;
    8000388a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000388c:	8552                	mv	a0,s4
    8000388e:	60e6                	ld	ra,88(sp)
    80003890:	6446                	ld	s0,80(sp)
    80003892:	64a6                	ld	s1,72(sp)
    80003894:	6906                	ld	s2,64(sp)
    80003896:	79e2                	ld	s3,56(sp)
    80003898:	7a42                	ld	s4,48(sp)
    8000389a:	7aa2                	ld	s5,40(sp)
    8000389c:	7b02                	ld	s6,32(sp)
    8000389e:	6be2                	ld	s7,24(sp)
    800038a0:	6c42                	ld	s8,16(sp)
    800038a2:	6ca2                	ld	s9,8(sp)
    800038a4:	6125                	addi	sp,sp,96
    800038a6:	8082                	ret
      iunlock(ip);
    800038a8:	8552                	mv	a0,s4
    800038aa:	b29ff0ef          	jal	800033d2 <iunlock>
      return ip;
    800038ae:	bff9                	j	8000388c <namex+0x58>
      iunlockput(ip);
    800038b0:	8552                	mv	a0,s4
    800038b2:	c7dff0ef          	jal	8000352e <iunlockput>
      return 0;
    800038b6:	8a4e                	mv	s4,s3
    800038b8:	bfd1                	j	8000388c <namex+0x58>
  len = path - s;
    800038ba:	40998633          	sub	a2,s3,s1
    800038be:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800038c2:	099c5063          	bge	s8,s9,80003942 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800038c6:	4639                	li	a2,14
    800038c8:	85a6                	mv	a1,s1
    800038ca:	8556                	mv	a0,s5
    800038cc:	c58fd0ef          	jal	80000d24 <memmove>
    800038d0:	84ce                	mv	s1,s3
  while(*path == '/')
    800038d2:	0004c783          	lbu	a5,0(s1)
    800038d6:	01279763          	bne	a5,s2,800038e4 <namex+0xb0>
    path++;
    800038da:	0485                	addi	s1,s1,1
  while(*path == '/')
    800038dc:	0004c783          	lbu	a5,0(s1)
    800038e0:	ff278de3          	beq	a5,s2,800038da <namex+0xa6>
    ilock(ip);
    800038e4:	8552                	mv	a0,s4
    800038e6:	a3fff0ef          	jal	80003324 <ilock>
    if(ip->type != T_DIR){
    800038ea:	044a1783          	lh	a5,68(s4)
    800038ee:	f9779be3          	bne	a5,s7,80003884 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800038f2:	000b0563          	beqz	s6,800038fc <namex+0xc8>
    800038f6:	0004c783          	lbu	a5,0(s1)
    800038fa:	d7dd                	beqz	a5,800038a8 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800038fc:	4601                	li	a2,0
    800038fe:	85d6                	mv	a1,s5
    80003900:	8552                	mv	a0,s4
    80003902:	e97ff0ef          	jal	80003798 <dirlookup>
    80003906:	89aa                	mv	s3,a0
    80003908:	d545                	beqz	a0,800038b0 <namex+0x7c>
    iunlockput(ip);
    8000390a:	8552                	mv	a0,s4
    8000390c:	c23ff0ef          	jal	8000352e <iunlockput>
    ip = next;
    80003910:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003912:	0004c783          	lbu	a5,0(s1)
    80003916:	01279763          	bne	a5,s2,80003924 <namex+0xf0>
    path++;
    8000391a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000391c:	0004c783          	lbu	a5,0(s1)
    80003920:	ff278de3          	beq	a5,s2,8000391a <namex+0xe6>
  if(*path == 0)
    80003924:	cb8d                	beqz	a5,80003956 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003926:	0004c783          	lbu	a5,0(s1)
    8000392a:	89a6                	mv	s3,s1
  len = path - s;
    8000392c:	4c81                	li	s9,0
    8000392e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003930:	01278963          	beq	a5,s2,80003942 <namex+0x10e>
    80003934:	d3d9                	beqz	a5,800038ba <namex+0x86>
    path++;
    80003936:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003938:	0009c783          	lbu	a5,0(s3)
    8000393c:	ff279ce3          	bne	a5,s2,80003934 <namex+0x100>
    80003940:	bfad                	j	800038ba <namex+0x86>
    memmove(name, s, len);
    80003942:	2601                	sext.w	a2,a2
    80003944:	85a6                	mv	a1,s1
    80003946:	8556                	mv	a0,s5
    80003948:	bdcfd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    8000394c:	9cd6                	add	s9,s9,s5
    8000394e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003952:	84ce                	mv	s1,s3
    80003954:	bfbd                	j	800038d2 <namex+0x9e>
  if(nameiparent){
    80003956:	f20b0be3          	beqz	s6,8000388c <namex+0x58>
    iput(ip);
    8000395a:	8552                	mv	a0,s4
    8000395c:	b4bff0ef          	jal	800034a6 <iput>
    return 0;
    80003960:	4a01                	li	s4,0
    80003962:	b72d                	j	8000388c <namex+0x58>

0000000080003964 <dirlink>:
{
    80003964:	7139                	addi	sp,sp,-64
    80003966:	fc06                	sd	ra,56(sp)
    80003968:	f822                	sd	s0,48(sp)
    8000396a:	f04a                	sd	s2,32(sp)
    8000396c:	ec4e                	sd	s3,24(sp)
    8000396e:	e852                	sd	s4,16(sp)
    80003970:	0080                	addi	s0,sp,64
    80003972:	892a                	mv	s2,a0
    80003974:	8a2e                	mv	s4,a1
    80003976:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003978:	4601                	li	a2,0
    8000397a:	e1fff0ef          	jal	80003798 <dirlookup>
    8000397e:	e535                	bnez	a0,800039ea <dirlink+0x86>
    80003980:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003982:	04c92483          	lw	s1,76(s2)
    80003986:	c48d                	beqz	s1,800039b0 <dirlink+0x4c>
    80003988:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000398a:	4741                	li	a4,16
    8000398c:	86a6                	mv	a3,s1
    8000398e:	fc040613          	addi	a2,s0,-64
    80003992:	4581                	li	a1,0
    80003994:	854a                	mv	a0,s2
    80003996:	be3ff0ef          	jal	80003578 <readi>
    8000399a:	47c1                	li	a5,16
    8000399c:	04f51b63          	bne	a0,a5,800039f2 <dirlink+0x8e>
    if(de.inum == 0)
    800039a0:	fc045783          	lhu	a5,-64(s0)
    800039a4:	c791                	beqz	a5,800039b0 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039a6:	24c1                	addiw	s1,s1,16
    800039a8:	04c92783          	lw	a5,76(s2)
    800039ac:	fcf4efe3          	bltu	s1,a5,8000398a <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800039b0:	4639                	li	a2,14
    800039b2:	85d2                	mv	a1,s4
    800039b4:	fc240513          	addi	a0,s0,-62
    800039b8:	c12fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    800039bc:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039c0:	4741                	li	a4,16
    800039c2:	86a6                	mv	a3,s1
    800039c4:	fc040613          	addi	a2,s0,-64
    800039c8:	4581                	li	a1,0
    800039ca:	854a                	mv	a0,s2
    800039cc:	ca9ff0ef          	jal	80003674 <writei>
    800039d0:	1541                	addi	a0,a0,-16
    800039d2:	00a03533          	snez	a0,a0
    800039d6:	40a00533          	neg	a0,a0
    800039da:	74a2                	ld	s1,40(sp)
}
    800039dc:	70e2                	ld	ra,56(sp)
    800039de:	7442                	ld	s0,48(sp)
    800039e0:	7902                	ld	s2,32(sp)
    800039e2:	69e2                	ld	s3,24(sp)
    800039e4:	6a42                	ld	s4,16(sp)
    800039e6:	6121                	addi	sp,sp,64
    800039e8:	8082                	ret
    iput(ip);
    800039ea:	abdff0ef          	jal	800034a6 <iput>
    return -1;
    800039ee:	557d                	li	a0,-1
    800039f0:	b7f5                	j	800039dc <dirlink+0x78>
      panic("dirlink read");
    800039f2:	00004517          	auipc	a0,0x4
    800039f6:	b8650513          	addi	a0,a0,-1146 # 80007578 <etext+0x578>
    800039fa:	d9bfc0ef          	jal	80000794 <panic>

00000000800039fe <namei>:

struct inode*
namei(char *path)
{
    800039fe:	1101                	addi	sp,sp,-32
    80003a00:	ec06                	sd	ra,24(sp)
    80003a02:	e822                	sd	s0,16(sp)
    80003a04:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a06:	fe040613          	addi	a2,s0,-32
    80003a0a:	4581                	li	a1,0
    80003a0c:	e29ff0ef          	jal	80003834 <namex>
}
    80003a10:	60e2                	ld	ra,24(sp)
    80003a12:	6442                	ld	s0,16(sp)
    80003a14:	6105                	addi	sp,sp,32
    80003a16:	8082                	ret

0000000080003a18 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a18:	1141                	addi	sp,sp,-16
    80003a1a:	e406                	sd	ra,8(sp)
    80003a1c:	e022                	sd	s0,0(sp)
    80003a1e:	0800                	addi	s0,sp,16
    80003a20:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a22:	4585                	li	a1,1
    80003a24:	e11ff0ef          	jal	80003834 <namex>
}
    80003a28:	60a2                	ld	ra,8(sp)
    80003a2a:	6402                	ld	s0,0(sp)
    80003a2c:	0141                	addi	sp,sp,16
    80003a2e:	8082                	ret

0000000080003a30 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a30:	1101                	addi	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	e426                	sd	s1,8(sp)
    80003a38:	e04a                	sd	s2,0(sp)
    80003a3a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a3c:	0001c917          	auipc	s2,0x1c
    80003a40:	00490913          	addi	s2,s2,4 # 8001fa40 <log>
    80003a44:	01892583          	lw	a1,24(s2)
    80003a48:	02892503          	lw	a0,40(s2)
    80003a4c:	9a0ff0ef          	jal	80002bec <bread>
    80003a50:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a52:	02c92603          	lw	a2,44(s2)
    80003a56:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a58:	00c05f63          	blez	a2,80003a76 <write_head+0x46>
    80003a5c:	0001c717          	auipc	a4,0x1c
    80003a60:	01470713          	addi	a4,a4,20 # 8001fa70 <log+0x30>
    80003a64:	87aa                	mv	a5,a0
    80003a66:	060a                	slli	a2,a2,0x2
    80003a68:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a6a:	4314                	lw	a3,0(a4)
    80003a6c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a6e:	0711                	addi	a4,a4,4
    80003a70:	0791                	addi	a5,a5,4
    80003a72:	fec79ce3          	bne	a5,a2,80003a6a <write_head+0x3a>
  }
  bwrite(buf);
    80003a76:	8526                	mv	a0,s1
    80003a78:	a4aff0ef          	jal	80002cc2 <bwrite>
  brelse(buf);
    80003a7c:	8526                	mv	a0,s1
    80003a7e:	a76ff0ef          	jal	80002cf4 <brelse>
}
    80003a82:	60e2                	ld	ra,24(sp)
    80003a84:	6442                	ld	s0,16(sp)
    80003a86:	64a2                	ld	s1,8(sp)
    80003a88:	6902                	ld	s2,0(sp)
    80003a8a:	6105                	addi	sp,sp,32
    80003a8c:	8082                	ret

0000000080003a8e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a8e:	0001c797          	auipc	a5,0x1c
    80003a92:	fde7a783          	lw	a5,-34(a5) # 8001fa6c <log+0x2c>
    80003a96:	08f05f63          	blez	a5,80003b34 <install_trans+0xa6>
{
    80003a9a:	7139                	addi	sp,sp,-64
    80003a9c:	fc06                	sd	ra,56(sp)
    80003a9e:	f822                	sd	s0,48(sp)
    80003aa0:	f426                	sd	s1,40(sp)
    80003aa2:	f04a                	sd	s2,32(sp)
    80003aa4:	ec4e                	sd	s3,24(sp)
    80003aa6:	e852                	sd	s4,16(sp)
    80003aa8:	e456                	sd	s5,8(sp)
    80003aaa:	e05a                	sd	s6,0(sp)
    80003aac:	0080                	addi	s0,sp,64
    80003aae:	8b2a                	mv	s6,a0
    80003ab0:	0001ca97          	auipc	s5,0x1c
    80003ab4:	fc0a8a93          	addi	s5,s5,-64 # 8001fa70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ab8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003aba:	0001c997          	auipc	s3,0x1c
    80003abe:	f8698993          	addi	s3,s3,-122 # 8001fa40 <log>
    80003ac2:	a829                	j	80003adc <install_trans+0x4e>
    brelse(lbuf);
    80003ac4:	854a                	mv	a0,s2
    80003ac6:	a2eff0ef          	jal	80002cf4 <brelse>
    brelse(dbuf);
    80003aca:	8526                	mv	a0,s1
    80003acc:	a28ff0ef          	jal	80002cf4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ad0:	2a05                	addiw	s4,s4,1
    80003ad2:	0a91                	addi	s5,s5,4
    80003ad4:	02c9a783          	lw	a5,44(s3)
    80003ad8:	04fa5463          	bge	s4,a5,80003b20 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003adc:	0189a583          	lw	a1,24(s3)
    80003ae0:	014585bb          	addw	a1,a1,s4
    80003ae4:	2585                	addiw	a1,a1,1
    80003ae6:	0289a503          	lw	a0,40(s3)
    80003aea:	902ff0ef          	jal	80002bec <bread>
    80003aee:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003af0:	000aa583          	lw	a1,0(s5)
    80003af4:	0289a503          	lw	a0,40(s3)
    80003af8:	8f4ff0ef          	jal	80002bec <bread>
    80003afc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003afe:	40000613          	li	a2,1024
    80003b02:	05890593          	addi	a1,s2,88
    80003b06:	05850513          	addi	a0,a0,88
    80003b0a:	a1afd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003b0e:	8526                	mv	a0,s1
    80003b10:	9b2ff0ef          	jal	80002cc2 <bwrite>
    if(recovering == 0)
    80003b14:	fa0b18e3          	bnez	s6,80003ac4 <install_trans+0x36>
      bunpin(dbuf);
    80003b18:	8526                	mv	a0,s1
    80003b1a:	a96ff0ef          	jal	80002db0 <bunpin>
    80003b1e:	b75d                	j	80003ac4 <install_trans+0x36>
}
    80003b20:	70e2                	ld	ra,56(sp)
    80003b22:	7442                	ld	s0,48(sp)
    80003b24:	74a2                	ld	s1,40(sp)
    80003b26:	7902                	ld	s2,32(sp)
    80003b28:	69e2                	ld	s3,24(sp)
    80003b2a:	6a42                	ld	s4,16(sp)
    80003b2c:	6aa2                	ld	s5,8(sp)
    80003b2e:	6b02                	ld	s6,0(sp)
    80003b30:	6121                	addi	sp,sp,64
    80003b32:	8082                	ret
    80003b34:	8082                	ret

0000000080003b36 <initlog>:
{
    80003b36:	7179                	addi	sp,sp,-48
    80003b38:	f406                	sd	ra,40(sp)
    80003b3a:	f022                	sd	s0,32(sp)
    80003b3c:	ec26                	sd	s1,24(sp)
    80003b3e:	e84a                	sd	s2,16(sp)
    80003b40:	e44e                	sd	s3,8(sp)
    80003b42:	1800                	addi	s0,sp,48
    80003b44:	892a                	mv	s2,a0
    80003b46:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b48:	0001c497          	auipc	s1,0x1c
    80003b4c:	ef848493          	addi	s1,s1,-264 # 8001fa40 <log>
    80003b50:	00004597          	auipc	a1,0x4
    80003b54:	a3858593          	addi	a1,a1,-1480 # 80007588 <etext+0x588>
    80003b58:	8526                	mv	a0,s1
    80003b5a:	81afd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003b5e:	0149a583          	lw	a1,20(s3)
    80003b62:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003b64:	0109a783          	lw	a5,16(s3)
    80003b68:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003b6a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003b6e:	854a                	mv	a0,s2
    80003b70:	87cff0ef          	jal	80002bec <bread>
  log.lh.n = lh->n;
    80003b74:	4d30                	lw	a2,88(a0)
    80003b76:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003b78:	00c05f63          	blez	a2,80003b96 <initlog+0x60>
    80003b7c:	87aa                	mv	a5,a0
    80003b7e:	0001c717          	auipc	a4,0x1c
    80003b82:	ef270713          	addi	a4,a4,-270 # 8001fa70 <log+0x30>
    80003b86:	060a                	slli	a2,a2,0x2
    80003b88:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003b8a:	4ff4                	lw	a3,92(a5)
    80003b8c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003b8e:	0791                	addi	a5,a5,4
    80003b90:	0711                	addi	a4,a4,4
    80003b92:	fec79ce3          	bne	a5,a2,80003b8a <initlog+0x54>
  brelse(buf);
    80003b96:	95eff0ef          	jal	80002cf4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b9a:	4505                	li	a0,1
    80003b9c:	ef3ff0ef          	jal	80003a8e <install_trans>
  log.lh.n = 0;
    80003ba0:	0001c797          	auipc	a5,0x1c
    80003ba4:	ec07a623          	sw	zero,-308(a5) # 8001fa6c <log+0x2c>
  write_head(); // clear the log
    80003ba8:	e89ff0ef          	jal	80003a30 <write_head>
}
    80003bac:	70a2                	ld	ra,40(sp)
    80003bae:	7402                	ld	s0,32(sp)
    80003bb0:	64e2                	ld	s1,24(sp)
    80003bb2:	6942                	ld	s2,16(sp)
    80003bb4:	69a2                	ld	s3,8(sp)
    80003bb6:	6145                	addi	sp,sp,48
    80003bb8:	8082                	ret

0000000080003bba <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003bba:	1101                	addi	sp,sp,-32
    80003bbc:	ec06                	sd	ra,24(sp)
    80003bbe:	e822                	sd	s0,16(sp)
    80003bc0:	e426                	sd	s1,8(sp)
    80003bc2:	e04a                	sd	s2,0(sp)
    80003bc4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003bc6:	0001c517          	auipc	a0,0x1c
    80003bca:	e7a50513          	addi	a0,a0,-390 # 8001fa40 <log>
    80003bce:	826fd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003bd2:	0001c497          	auipc	s1,0x1c
    80003bd6:	e6e48493          	addi	s1,s1,-402 # 8001fa40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003bda:	4979                	li	s2,30
    80003bdc:	a029                	j	80003be6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003bde:	85a6                	mv	a1,s1
    80003be0:	8526                	mv	a0,s1
    80003be2:	accfe0ef          	jal	80001eae <sleep>
    if(log.committing){
    80003be6:	50dc                	lw	a5,36(s1)
    80003be8:	fbfd                	bnez	a5,80003bde <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003bea:	5098                	lw	a4,32(s1)
    80003bec:	2705                	addiw	a4,a4,1
    80003bee:	0027179b          	slliw	a5,a4,0x2
    80003bf2:	9fb9                	addw	a5,a5,a4
    80003bf4:	0017979b          	slliw	a5,a5,0x1
    80003bf8:	54d4                	lw	a3,44(s1)
    80003bfa:	9fb5                	addw	a5,a5,a3
    80003bfc:	00f95763          	bge	s2,a5,80003c0a <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c00:	85a6                	mv	a1,s1
    80003c02:	8526                	mv	a0,s1
    80003c04:	aaafe0ef          	jal	80001eae <sleep>
    80003c08:	bff9                	j	80003be6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c0a:	0001c517          	auipc	a0,0x1c
    80003c0e:	e3650513          	addi	a0,a0,-458 # 8001fa40 <log>
    80003c12:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003c14:	878fd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003c18:	60e2                	ld	ra,24(sp)
    80003c1a:	6442                	ld	s0,16(sp)
    80003c1c:	64a2                	ld	s1,8(sp)
    80003c1e:	6902                	ld	s2,0(sp)
    80003c20:	6105                	addi	sp,sp,32
    80003c22:	8082                	ret

0000000080003c24 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c24:	7139                	addi	sp,sp,-64
    80003c26:	fc06                	sd	ra,56(sp)
    80003c28:	f822                	sd	s0,48(sp)
    80003c2a:	f426                	sd	s1,40(sp)
    80003c2c:	f04a                	sd	s2,32(sp)
    80003c2e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c30:	0001c497          	auipc	s1,0x1c
    80003c34:	e1048493          	addi	s1,s1,-496 # 8001fa40 <log>
    80003c38:	8526                	mv	a0,s1
    80003c3a:	fbbfc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003c3e:	509c                	lw	a5,32(s1)
    80003c40:	37fd                	addiw	a5,a5,-1
    80003c42:	0007891b          	sext.w	s2,a5
    80003c46:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003c48:	50dc                	lw	a5,36(s1)
    80003c4a:	ef9d                	bnez	a5,80003c88 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c4c:	04091763          	bnez	s2,80003c9a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c50:	0001c497          	auipc	s1,0x1c
    80003c54:	df048493          	addi	s1,s1,-528 # 8001fa40 <log>
    80003c58:	4785                	li	a5,1
    80003c5a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003c5c:	8526                	mv	a0,s1
    80003c5e:	82efd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003c62:	54dc                	lw	a5,44(s1)
    80003c64:	04f04b63          	bgtz	a5,80003cba <end_op+0x96>
    acquire(&log.lock);
    80003c68:	0001c497          	auipc	s1,0x1c
    80003c6c:	dd848493          	addi	s1,s1,-552 # 8001fa40 <log>
    80003c70:	8526                	mv	a0,s1
    80003c72:	f83fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003c76:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c7a:	8526                	mv	a0,s1
    80003c7c:	a7efe0ef          	jal	80001efa <wakeup>
    release(&log.lock);
    80003c80:	8526                	mv	a0,s1
    80003c82:	80afd0ef          	jal	80000c8c <release>
}
    80003c86:	a025                	j	80003cae <end_op+0x8a>
    80003c88:	ec4e                	sd	s3,24(sp)
    80003c8a:	e852                	sd	s4,16(sp)
    80003c8c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003c8e:	00004517          	auipc	a0,0x4
    80003c92:	90250513          	addi	a0,a0,-1790 # 80007590 <etext+0x590>
    80003c96:	afffc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003c9a:	0001c497          	auipc	s1,0x1c
    80003c9e:	da648493          	addi	s1,s1,-602 # 8001fa40 <log>
    80003ca2:	8526                	mv	a0,s1
    80003ca4:	a56fe0ef          	jal	80001efa <wakeup>
  release(&log.lock);
    80003ca8:	8526                	mv	a0,s1
    80003caa:	fe3fc0ef          	jal	80000c8c <release>
}
    80003cae:	70e2                	ld	ra,56(sp)
    80003cb0:	7442                	ld	s0,48(sp)
    80003cb2:	74a2                	ld	s1,40(sp)
    80003cb4:	7902                	ld	s2,32(sp)
    80003cb6:	6121                	addi	sp,sp,64
    80003cb8:	8082                	ret
    80003cba:	ec4e                	sd	s3,24(sp)
    80003cbc:	e852                	sd	s4,16(sp)
    80003cbe:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cc0:	0001ca97          	auipc	s5,0x1c
    80003cc4:	db0a8a93          	addi	s5,s5,-592 # 8001fa70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003cc8:	0001ca17          	auipc	s4,0x1c
    80003ccc:	d78a0a13          	addi	s4,s4,-648 # 8001fa40 <log>
    80003cd0:	018a2583          	lw	a1,24(s4)
    80003cd4:	012585bb          	addw	a1,a1,s2
    80003cd8:	2585                	addiw	a1,a1,1
    80003cda:	028a2503          	lw	a0,40(s4)
    80003cde:	f0ffe0ef          	jal	80002bec <bread>
    80003ce2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003ce4:	000aa583          	lw	a1,0(s5)
    80003ce8:	028a2503          	lw	a0,40(s4)
    80003cec:	f01fe0ef          	jal	80002bec <bread>
    80003cf0:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003cf2:	40000613          	li	a2,1024
    80003cf6:	05850593          	addi	a1,a0,88
    80003cfa:	05848513          	addi	a0,s1,88
    80003cfe:	826fd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003d02:	8526                	mv	a0,s1
    80003d04:	fbffe0ef          	jal	80002cc2 <bwrite>
    brelse(from);
    80003d08:	854e                	mv	a0,s3
    80003d0a:	febfe0ef          	jal	80002cf4 <brelse>
    brelse(to);
    80003d0e:	8526                	mv	a0,s1
    80003d10:	fe5fe0ef          	jal	80002cf4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d14:	2905                	addiw	s2,s2,1
    80003d16:	0a91                	addi	s5,s5,4
    80003d18:	02ca2783          	lw	a5,44(s4)
    80003d1c:	faf94ae3          	blt	s2,a5,80003cd0 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d20:	d11ff0ef          	jal	80003a30 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d24:	4501                	li	a0,0
    80003d26:	d69ff0ef          	jal	80003a8e <install_trans>
    log.lh.n = 0;
    80003d2a:	0001c797          	auipc	a5,0x1c
    80003d2e:	d407a123          	sw	zero,-702(a5) # 8001fa6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003d32:	cffff0ef          	jal	80003a30 <write_head>
    80003d36:	69e2                	ld	s3,24(sp)
    80003d38:	6a42                	ld	s4,16(sp)
    80003d3a:	6aa2                	ld	s5,8(sp)
    80003d3c:	b735                	j	80003c68 <end_op+0x44>

0000000080003d3e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d3e:	1101                	addi	sp,sp,-32
    80003d40:	ec06                	sd	ra,24(sp)
    80003d42:	e822                	sd	s0,16(sp)
    80003d44:	e426                	sd	s1,8(sp)
    80003d46:	e04a                	sd	s2,0(sp)
    80003d48:	1000                	addi	s0,sp,32
    80003d4a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d4c:	0001c917          	auipc	s2,0x1c
    80003d50:	cf490913          	addi	s2,s2,-780 # 8001fa40 <log>
    80003d54:	854a                	mv	a0,s2
    80003d56:	e9ffc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003d5a:	02c92603          	lw	a2,44(s2)
    80003d5e:	47f5                	li	a5,29
    80003d60:	06c7c363          	blt	a5,a2,80003dc6 <log_write+0x88>
    80003d64:	0001c797          	auipc	a5,0x1c
    80003d68:	cf87a783          	lw	a5,-776(a5) # 8001fa5c <log+0x1c>
    80003d6c:	37fd                	addiw	a5,a5,-1
    80003d6e:	04f65c63          	bge	a2,a5,80003dc6 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003d72:	0001c797          	auipc	a5,0x1c
    80003d76:	cee7a783          	lw	a5,-786(a5) # 8001fa60 <log+0x20>
    80003d7a:	04f05c63          	blez	a5,80003dd2 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d7e:	4781                	li	a5,0
    80003d80:	04c05f63          	blez	a2,80003dde <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d84:	44cc                	lw	a1,12(s1)
    80003d86:	0001c717          	auipc	a4,0x1c
    80003d8a:	cea70713          	addi	a4,a4,-790 # 8001fa70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d8e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d90:	4314                	lw	a3,0(a4)
    80003d92:	04b68663          	beq	a3,a1,80003dde <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d96:	2785                	addiw	a5,a5,1
    80003d98:	0711                	addi	a4,a4,4
    80003d9a:	fef61be3          	bne	a2,a5,80003d90 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d9e:	0621                	addi	a2,a2,8
    80003da0:	060a                	slli	a2,a2,0x2
    80003da2:	0001c797          	auipc	a5,0x1c
    80003da6:	c9e78793          	addi	a5,a5,-866 # 8001fa40 <log>
    80003daa:	97b2                	add	a5,a5,a2
    80003dac:	44d8                	lw	a4,12(s1)
    80003dae:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003db0:	8526                	mv	a0,s1
    80003db2:	fcbfe0ef          	jal	80002d7c <bpin>
    log.lh.n++;
    80003db6:	0001c717          	auipc	a4,0x1c
    80003dba:	c8a70713          	addi	a4,a4,-886 # 8001fa40 <log>
    80003dbe:	575c                	lw	a5,44(a4)
    80003dc0:	2785                	addiw	a5,a5,1
    80003dc2:	d75c                	sw	a5,44(a4)
    80003dc4:	a80d                	j	80003df6 <log_write+0xb8>
    panic("too big a transaction");
    80003dc6:	00003517          	auipc	a0,0x3
    80003dca:	7da50513          	addi	a0,a0,2010 # 800075a0 <etext+0x5a0>
    80003dce:	9c7fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003dd2:	00003517          	auipc	a0,0x3
    80003dd6:	7e650513          	addi	a0,a0,2022 # 800075b8 <etext+0x5b8>
    80003dda:	9bbfc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003dde:	00878693          	addi	a3,a5,8
    80003de2:	068a                	slli	a3,a3,0x2
    80003de4:	0001c717          	auipc	a4,0x1c
    80003de8:	c5c70713          	addi	a4,a4,-932 # 8001fa40 <log>
    80003dec:	9736                	add	a4,a4,a3
    80003dee:	44d4                	lw	a3,12(s1)
    80003df0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003df2:	faf60fe3          	beq	a2,a5,80003db0 <log_write+0x72>
  }
  release(&log.lock);
    80003df6:	0001c517          	auipc	a0,0x1c
    80003dfa:	c4a50513          	addi	a0,a0,-950 # 8001fa40 <log>
    80003dfe:	e8ffc0ef          	jal	80000c8c <release>
}
    80003e02:	60e2                	ld	ra,24(sp)
    80003e04:	6442                	ld	s0,16(sp)
    80003e06:	64a2                	ld	s1,8(sp)
    80003e08:	6902                	ld	s2,0(sp)
    80003e0a:	6105                	addi	sp,sp,32
    80003e0c:	8082                	ret

0000000080003e0e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e0e:	1101                	addi	sp,sp,-32
    80003e10:	ec06                	sd	ra,24(sp)
    80003e12:	e822                	sd	s0,16(sp)
    80003e14:	e426                	sd	s1,8(sp)
    80003e16:	e04a                	sd	s2,0(sp)
    80003e18:	1000                	addi	s0,sp,32
    80003e1a:	84aa                	mv	s1,a0
    80003e1c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e1e:	00003597          	auipc	a1,0x3
    80003e22:	7ba58593          	addi	a1,a1,1978 # 800075d8 <etext+0x5d8>
    80003e26:	0521                	addi	a0,a0,8
    80003e28:	d4dfc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003e2c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e30:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e34:	0204a423          	sw	zero,40(s1)
}
    80003e38:	60e2                	ld	ra,24(sp)
    80003e3a:	6442                	ld	s0,16(sp)
    80003e3c:	64a2                	ld	s1,8(sp)
    80003e3e:	6902                	ld	s2,0(sp)
    80003e40:	6105                	addi	sp,sp,32
    80003e42:	8082                	ret

0000000080003e44 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e44:	1101                	addi	sp,sp,-32
    80003e46:	ec06                	sd	ra,24(sp)
    80003e48:	e822                	sd	s0,16(sp)
    80003e4a:	e426                	sd	s1,8(sp)
    80003e4c:	e04a                	sd	s2,0(sp)
    80003e4e:	1000                	addi	s0,sp,32
    80003e50:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e52:	00850913          	addi	s2,a0,8
    80003e56:	854a                	mv	a0,s2
    80003e58:	d9dfc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003e5c:	409c                	lw	a5,0(s1)
    80003e5e:	c799                	beqz	a5,80003e6c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e60:	85ca                	mv	a1,s2
    80003e62:	8526                	mv	a0,s1
    80003e64:	84afe0ef          	jal	80001eae <sleep>
  while (lk->locked) {
    80003e68:	409c                	lw	a5,0(s1)
    80003e6a:	fbfd                	bnez	a5,80003e60 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003e6c:	4785                	li	a5,1
    80003e6e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003e70:	a71fd0ef          	jal	800018e0 <myproc>
    80003e74:	591c                	lw	a5,48(a0)
    80003e76:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003e78:	854a                	mv	a0,s2
    80003e7a:	e13fc0ef          	jal	80000c8c <release>
}
    80003e7e:	60e2                	ld	ra,24(sp)
    80003e80:	6442                	ld	s0,16(sp)
    80003e82:	64a2                	ld	s1,8(sp)
    80003e84:	6902                	ld	s2,0(sp)
    80003e86:	6105                	addi	sp,sp,32
    80003e88:	8082                	ret

0000000080003e8a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e8a:	1101                	addi	sp,sp,-32
    80003e8c:	ec06                	sd	ra,24(sp)
    80003e8e:	e822                	sd	s0,16(sp)
    80003e90:	e426                	sd	s1,8(sp)
    80003e92:	e04a                	sd	s2,0(sp)
    80003e94:	1000                	addi	s0,sp,32
    80003e96:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e98:	00850913          	addi	s2,a0,8
    80003e9c:	854a                	mv	a0,s2
    80003e9e:	d57fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003ea2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ea6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003eaa:	8526                	mv	a0,s1
    80003eac:	84efe0ef          	jal	80001efa <wakeup>
  release(&lk->lk);
    80003eb0:	854a                	mv	a0,s2
    80003eb2:	ddbfc0ef          	jal	80000c8c <release>
}
    80003eb6:	60e2                	ld	ra,24(sp)
    80003eb8:	6442                	ld	s0,16(sp)
    80003eba:	64a2                	ld	s1,8(sp)
    80003ebc:	6902                	ld	s2,0(sp)
    80003ebe:	6105                	addi	sp,sp,32
    80003ec0:	8082                	ret

0000000080003ec2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003ec2:	7179                	addi	sp,sp,-48
    80003ec4:	f406                	sd	ra,40(sp)
    80003ec6:	f022                	sd	s0,32(sp)
    80003ec8:	ec26                	sd	s1,24(sp)
    80003eca:	e84a                	sd	s2,16(sp)
    80003ecc:	1800                	addi	s0,sp,48
    80003ece:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003ed0:	00850913          	addi	s2,a0,8
    80003ed4:	854a                	mv	a0,s2
    80003ed6:	d1ffc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003eda:	409c                	lw	a5,0(s1)
    80003edc:	ef81                	bnez	a5,80003ef4 <holdingsleep+0x32>
    80003ede:	4481                	li	s1,0
  release(&lk->lk);
    80003ee0:	854a                	mv	a0,s2
    80003ee2:	dabfc0ef          	jal	80000c8c <release>
  return r;
}
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	70a2                	ld	ra,40(sp)
    80003eea:	7402                	ld	s0,32(sp)
    80003eec:	64e2                	ld	s1,24(sp)
    80003eee:	6942                	ld	s2,16(sp)
    80003ef0:	6145                	addi	sp,sp,48
    80003ef2:	8082                	ret
    80003ef4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ef6:	0284a983          	lw	s3,40(s1)
    80003efa:	9e7fd0ef          	jal	800018e0 <myproc>
    80003efe:	5904                	lw	s1,48(a0)
    80003f00:	413484b3          	sub	s1,s1,s3
    80003f04:	0014b493          	seqz	s1,s1
    80003f08:	69a2                	ld	s3,8(sp)
    80003f0a:	bfd9                	j	80003ee0 <holdingsleep+0x1e>

0000000080003f0c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f0c:	1141                	addi	sp,sp,-16
    80003f0e:	e406                	sd	ra,8(sp)
    80003f10:	e022                	sd	s0,0(sp)
    80003f12:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f14:	00003597          	auipc	a1,0x3
    80003f18:	6d458593          	addi	a1,a1,1748 # 800075e8 <etext+0x5e8>
    80003f1c:	0001c517          	auipc	a0,0x1c
    80003f20:	c6c50513          	addi	a0,a0,-916 # 8001fb88 <ftable>
    80003f24:	c51fc0ef          	jal	80000b74 <initlock>
}
    80003f28:	60a2                	ld	ra,8(sp)
    80003f2a:	6402                	ld	s0,0(sp)
    80003f2c:	0141                	addi	sp,sp,16
    80003f2e:	8082                	ret

0000000080003f30 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f30:	1101                	addi	sp,sp,-32
    80003f32:	ec06                	sd	ra,24(sp)
    80003f34:	e822                	sd	s0,16(sp)
    80003f36:	e426                	sd	s1,8(sp)
    80003f38:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f3a:	0001c517          	auipc	a0,0x1c
    80003f3e:	c4e50513          	addi	a0,a0,-946 # 8001fb88 <ftable>
    80003f42:	cb3fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f46:	0001c497          	auipc	s1,0x1c
    80003f4a:	c5a48493          	addi	s1,s1,-934 # 8001fba0 <ftable+0x18>
    80003f4e:	0001d717          	auipc	a4,0x1d
    80003f52:	bf270713          	addi	a4,a4,-1038 # 80020b40 <disk>
    if(f->ref == 0){
    80003f56:	40dc                	lw	a5,4(s1)
    80003f58:	cf89                	beqz	a5,80003f72 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f5a:	02848493          	addi	s1,s1,40
    80003f5e:	fee49ce3          	bne	s1,a4,80003f56 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f62:	0001c517          	auipc	a0,0x1c
    80003f66:	c2650513          	addi	a0,a0,-986 # 8001fb88 <ftable>
    80003f6a:	d23fc0ef          	jal	80000c8c <release>
  return 0;
    80003f6e:	4481                	li	s1,0
    80003f70:	a809                	j	80003f82 <filealloc+0x52>
      f->ref = 1;
    80003f72:	4785                	li	a5,1
    80003f74:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003f76:	0001c517          	auipc	a0,0x1c
    80003f7a:	c1250513          	addi	a0,a0,-1006 # 8001fb88 <ftable>
    80003f7e:	d0ffc0ef          	jal	80000c8c <release>
}
    80003f82:	8526                	mv	a0,s1
    80003f84:	60e2                	ld	ra,24(sp)
    80003f86:	6442                	ld	s0,16(sp)
    80003f88:	64a2                	ld	s1,8(sp)
    80003f8a:	6105                	addi	sp,sp,32
    80003f8c:	8082                	ret

0000000080003f8e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f8e:	1101                	addi	sp,sp,-32
    80003f90:	ec06                	sd	ra,24(sp)
    80003f92:	e822                	sd	s0,16(sp)
    80003f94:	e426                	sd	s1,8(sp)
    80003f96:	1000                	addi	s0,sp,32
    80003f98:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f9a:	0001c517          	auipc	a0,0x1c
    80003f9e:	bee50513          	addi	a0,a0,-1042 # 8001fb88 <ftable>
    80003fa2:	c53fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003fa6:	40dc                	lw	a5,4(s1)
    80003fa8:	02f05063          	blez	a5,80003fc8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003fac:	2785                	addiw	a5,a5,1
    80003fae:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003fb0:	0001c517          	auipc	a0,0x1c
    80003fb4:	bd850513          	addi	a0,a0,-1064 # 8001fb88 <ftable>
    80003fb8:	cd5fc0ef          	jal	80000c8c <release>
  return f;
}
    80003fbc:	8526                	mv	a0,s1
    80003fbe:	60e2                	ld	ra,24(sp)
    80003fc0:	6442                	ld	s0,16(sp)
    80003fc2:	64a2                	ld	s1,8(sp)
    80003fc4:	6105                	addi	sp,sp,32
    80003fc6:	8082                	ret
    panic("filedup");
    80003fc8:	00003517          	auipc	a0,0x3
    80003fcc:	62850513          	addi	a0,a0,1576 # 800075f0 <etext+0x5f0>
    80003fd0:	fc4fc0ef          	jal	80000794 <panic>

0000000080003fd4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003fd4:	7139                	addi	sp,sp,-64
    80003fd6:	fc06                	sd	ra,56(sp)
    80003fd8:	f822                	sd	s0,48(sp)
    80003fda:	f426                	sd	s1,40(sp)
    80003fdc:	0080                	addi	s0,sp,64
    80003fde:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003fe0:	0001c517          	auipc	a0,0x1c
    80003fe4:	ba850513          	addi	a0,a0,-1112 # 8001fb88 <ftable>
    80003fe8:	c0dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003fec:	40dc                	lw	a5,4(s1)
    80003fee:	04f05a63          	blez	a5,80004042 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003ff2:	37fd                	addiw	a5,a5,-1
    80003ff4:	0007871b          	sext.w	a4,a5
    80003ff8:	c0dc                	sw	a5,4(s1)
    80003ffa:	04e04e63          	bgtz	a4,80004056 <fileclose+0x82>
    80003ffe:	f04a                	sd	s2,32(sp)
    80004000:	ec4e                	sd	s3,24(sp)
    80004002:	e852                	sd	s4,16(sp)
    80004004:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004006:	0004a903          	lw	s2,0(s1)
    8000400a:	0094ca83          	lbu	s5,9(s1)
    8000400e:	0104ba03          	ld	s4,16(s1)
    80004012:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004016:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000401a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000401e:	0001c517          	auipc	a0,0x1c
    80004022:	b6a50513          	addi	a0,a0,-1174 # 8001fb88 <ftable>
    80004026:	c67fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    8000402a:	4785                	li	a5,1
    8000402c:	04f90063          	beq	s2,a5,8000406c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004030:	3979                	addiw	s2,s2,-2
    80004032:	4785                	li	a5,1
    80004034:	0527f563          	bgeu	a5,s2,8000407e <fileclose+0xaa>
    80004038:	7902                	ld	s2,32(sp)
    8000403a:	69e2                	ld	s3,24(sp)
    8000403c:	6a42                	ld	s4,16(sp)
    8000403e:	6aa2                	ld	s5,8(sp)
    80004040:	a00d                	j	80004062 <fileclose+0x8e>
    80004042:	f04a                	sd	s2,32(sp)
    80004044:	ec4e                	sd	s3,24(sp)
    80004046:	e852                	sd	s4,16(sp)
    80004048:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000404a:	00003517          	auipc	a0,0x3
    8000404e:	5ae50513          	addi	a0,a0,1454 # 800075f8 <etext+0x5f8>
    80004052:	f42fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80004056:	0001c517          	auipc	a0,0x1c
    8000405a:	b3250513          	addi	a0,a0,-1230 # 8001fb88 <ftable>
    8000405e:	c2ffc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004062:	70e2                	ld	ra,56(sp)
    80004064:	7442                	ld	s0,48(sp)
    80004066:	74a2                	ld	s1,40(sp)
    80004068:	6121                	addi	sp,sp,64
    8000406a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000406c:	85d6                	mv	a1,s5
    8000406e:	8552                	mv	a0,s4
    80004070:	336000ef          	jal	800043a6 <pipeclose>
    80004074:	7902                	ld	s2,32(sp)
    80004076:	69e2                	ld	s3,24(sp)
    80004078:	6a42                	ld	s4,16(sp)
    8000407a:	6aa2                	ld	s5,8(sp)
    8000407c:	b7dd                	j	80004062 <fileclose+0x8e>
    begin_op();
    8000407e:	b3dff0ef          	jal	80003bba <begin_op>
    iput(ff.ip);
    80004082:	854e                	mv	a0,s3
    80004084:	c22ff0ef          	jal	800034a6 <iput>
    end_op();
    80004088:	b9dff0ef          	jal	80003c24 <end_op>
    8000408c:	7902                	ld	s2,32(sp)
    8000408e:	69e2                	ld	s3,24(sp)
    80004090:	6a42                	ld	s4,16(sp)
    80004092:	6aa2                	ld	s5,8(sp)
    80004094:	b7f9                	j	80004062 <fileclose+0x8e>

0000000080004096 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004096:	715d                	addi	sp,sp,-80
    80004098:	e486                	sd	ra,72(sp)
    8000409a:	e0a2                	sd	s0,64(sp)
    8000409c:	fc26                	sd	s1,56(sp)
    8000409e:	f44e                	sd	s3,40(sp)
    800040a0:	0880                	addi	s0,sp,80
    800040a2:	84aa                	mv	s1,a0
    800040a4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800040a6:	83bfd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800040aa:	409c                	lw	a5,0(s1)
    800040ac:	37f9                	addiw	a5,a5,-2
    800040ae:	4705                	li	a4,1
    800040b0:	04f76063          	bltu	a4,a5,800040f0 <filestat+0x5a>
    800040b4:	f84a                	sd	s2,48(sp)
    800040b6:	892a                	mv	s2,a0
    ilock(f->ip);
    800040b8:	6c88                	ld	a0,24(s1)
    800040ba:	a6aff0ef          	jal	80003324 <ilock>
    stati(f->ip, &st);
    800040be:	fb840593          	addi	a1,s0,-72
    800040c2:	6c88                	ld	a0,24(s1)
    800040c4:	c8aff0ef          	jal	8000354e <stati>
    iunlock(f->ip);
    800040c8:	6c88                	ld	a0,24(s1)
    800040ca:	b08ff0ef          	jal	800033d2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800040ce:	46e1                	li	a3,24
    800040d0:	fb840613          	addi	a2,s0,-72
    800040d4:	85ce                	mv	a1,s3
    800040d6:	05093503          	ld	a0,80(s2)
    800040da:	c78fd0ef          	jal	80001552 <copyout>
    800040de:	41f5551b          	sraiw	a0,a0,0x1f
    800040e2:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800040e4:	60a6                	ld	ra,72(sp)
    800040e6:	6406                	ld	s0,64(sp)
    800040e8:	74e2                	ld	s1,56(sp)
    800040ea:	79a2                	ld	s3,40(sp)
    800040ec:	6161                	addi	sp,sp,80
    800040ee:	8082                	ret
  return -1;
    800040f0:	557d                	li	a0,-1
    800040f2:	bfcd                	j	800040e4 <filestat+0x4e>

00000000800040f4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800040f4:	7179                	addi	sp,sp,-48
    800040f6:	f406                	sd	ra,40(sp)
    800040f8:	f022                	sd	s0,32(sp)
    800040fa:	e84a                	sd	s2,16(sp)
    800040fc:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800040fe:	00854783          	lbu	a5,8(a0)
    80004102:	cfd1                	beqz	a5,8000419e <fileread+0xaa>
    80004104:	ec26                	sd	s1,24(sp)
    80004106:	e44e                	sd	s3,8(sp)
    80004108:	84aa                	mv	s1,a0
    8000410a:	89ae                	mv	s3,a1
    8000410c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000410e:	411c                	lw	a5,0(a0)
    80004110:	4705                	li	a4,1
    80004112:	04e78363          	beq	a5,a4,80004158 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004116:	470d                	li	a4,3
    80004118:	04e78763          	beq	a5,a4,80004166 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000411c:	4709                	li	a4,2
    8000411e:	06e79a63          	bne	a5,a4,80004192 <fileread+0x9e>
    ilock(f->ip);
    80004122:	6d08                	ld	a0,24(a0)
    80004124:	a00ff0ef          	jal	80003324 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004128:	874a                	mv	a4,s2
    8000412a:	5094                	lw	a3,32(s1)
    8000412c:	864e                	mv	a2,s3
    8000412e:	4585                	li	a1,1
    80004130:	6c88                	ld	a0,24(s1)
    80004132:	c46ff0ef          	jal	80003578 <readi>
    80004136:	892a                	mv	s2,a0
    80004138:	00a05563          	blez	a0,80004142 <fileread+0x4e>
      f->off += r;
    8000413c:	509c                	lw	a5,32(s1)
    8000413e:	9fa9                	addw	a5,a5,a0
    80004140:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004142:	6c88                	ld	a0,24(s1)
    80004144:	a8eff0ef          	jal	800033d2 <iunlock>
    80004148:	64e2                	ld	s1,24(sp)
    8000414a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000414c:	854a                	mv	a0,s2
    8000414e:	70a2                	ld	ra,40(sp)
    80004150:	7402                	ld	s0,32(sp)
    80004152:	6942                	ld	s2,16(sp)
    80004154:	6145                	addi	sp,sp,48
    80004156:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004158:	6908                	ld	a0,16(a0)
    8000415a:	388000ef          	jal	800044e2 <piperead>
    8000415e:	892a                	mv	s2,a0
    80004160:	64e2                	ld	s1,24(sp)
    80004162:	69a2                	ld	s3,8(sp)
    80004164:	b7e5                	j	8000414c <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004166:	02451783          	lh	a5,36(a0)
    8000416a:	03079693          	slli	a3,a5,0x30
    8000416e:	92c1                	srli	a3,a3,0x30
    80004170:	4725                	li	a4,9
    80004172:	02d76863          	bltu	a4,a3,800041a2 <fileread+0xae>
    80004176:	0792                	slli	a5,a5,0x4
    80004178:	0001c717          	auipc	a4,0x1c
    8000417c:	97070713          	addi	a4,a4,-1680 # 8001fae8 <devsw>
    80004180:	97ba                	add	a5,a5,a4
    80004182:	639c                	ld	a5,0(a5)
    80004184:	c39d                	beqz	a5,800041aa <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004186:	4505                	li	a0,1
    80004188:	9782                	jalr	a5
    8000418a:	892a                	mv	s2,a0
    8000418c:	64e2                	ld	s1,24(sp)
    8000418e:	69a2                	ld	s3,8(sp)
    80004190:	bf75                	j	8000414c <fileread+0x58>
    panic("fileread");
    80004192:	00003517          	auipc	a0,0x3
    80004196:	47650513          	addi	a0,a0,1142 # 80007608 <etext+0x608>
    8000419a:	dfafc0ef          	jal	80000794 <panic>
    return -1;
    8000419e:	597d                	li	s2,-1
    800041a0:	b775                	j	8000414c <fileread+0x58>
      return -1;
    800041a2:	597d                	li	s2,-1
    800041a4:	64e2                	ld	s1,24(sp)
    800041a6:	69a2                	ld	s3,8(sp)
    800041a8:	b755                	j	8000414c <fileread+0x58>
    800041aa:	597d                	li	s2,-1
    800041ac:	64e2                	ld	s1,24(sp)
    800041ae:	69a2                	ld	s3,8(sp)
    800041b0:	bf71                	j	8000414c <fileread+0x58>

00000000800041b2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800041b2:	00954783          	lbu	a5,9(a0)
    800041b6:	10078b63          	beqz	a5,800042cc <filewrite+0x11a>
{
    800041ba:	715d                	addi	sp,sp,-80
    800041bc:	e486                	sd	ra,72(sp)
    800041be:	e0a2                	sd	s0,64(sp)
    800041c0:	f84a                	sd	s2,48(sp)
    800041c2:	f052                	sd	s4,32(sp)
    800041c4:	e85a                	sd	s6,16(sp)
    800041c6:	0880                	addi	s0,sp,80
    800041c8:	892a                	mv	s2,a0
    800041ca:	8b2e                	mv	s6,a1
    800041cc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800041ce:	411c                	lw	a5,0(a0)
    800041d0:	4705                	li	a4,1
    800041d2:	02e78763          	beq	a5,a4,80004200 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800041d6:	470d                	li	a4,3
    800041d8:	02e78863          	beq	a5,a4,80004208 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800041dc:	4709                	li	a4,2
    800041de:	0ce79c63          	bne	a5,a4,800042b6 <filewrite+0x104>
    800041e2:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800041e4:	0ac05863          	blez	a2,80004294 <filewrite+0xe2>
    800041e8:	fc26                	sd	s1,56(sp)
    800041ea:	ec56                	sd	s5,24(sp)
    800041ec:	e45e                	sd	s7,8(sp)
    800041ee:	e062                	sd	s8,0(sp)
    int i = 0;
    800041f0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800041f2:	6b85                	lui	s7,0x1
    800041f4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800041f8:	6c05                	lui	s8,0x1
    800041fa:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800041fe:	a8b5                	j	8000427a <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004200:	6908                	ld	a0,16(a0)
    80004202:	1fc000ef          	jal	800043fe <pipewrite>
    80004206:	a04d                	j	800042a8 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004208:	02451783          	lh	a5,36(a0)
    8000420c:	03079693          	slli	a3,a5,0x30
    80004210:	92c1                	srli	a3,a3,0x30
    80004212:	4725                	li	a4,9
    80004214:	0ad76e63          	bltu	a4,a3,800042d0 <filewrite+0x11e>
    80004218:	0792                	slli	a5,a5,0x4
    8000421a:	0001c717          	auipc	a4,0x1c
    8000421e:	8ce70713          	addi	a4,a4,-1842 # 8001fae8 <devsw>
    80004222:	97ba                	add	a5,a5,a4
    80004224:	679c                	ld	a5,8(a5)
    80004226:	c7dd                	beqz	a5,800042d4 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004228:	4505                	li	a0,1
    8000422a:	9782                	jalr	a5
    8000422c:	a8b5                	j	800042a8 <filewrite+0xf6>
      if(n1 > max)
    8000422e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004232:	989ff0ef          	jal	80003bba <begin_op>
      ilock(f->ip);
    80004236:	01893503          	ld	a0,24(s2)
    8000423a:	8eaff0ef          	jal	80003324 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000423e:	8756                	mv	a4,s5
    80004240:	02092683          	lw	a3,32(s2)
    80004244:	01698633          	add	a2,s3,s6
    80004248:	4585                	li	a1,1
    8000424a:	01893503          	ld	a0,24(s2)
    8000424e:	c26ff0ef          	jal	80003674 <writei>
    80004252:	84aa                	mv	s1,a0
    80004254:	00a05763          	blez	a0,80004262 <filewrite+0xb0>
        f->off += r;
    80004258:	02092783          	lw	a5,32(s2)
    8000425c:	9fa9                	addw	a5,a5,a0
    8000425e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004262:	01893503          	ld	a0,24(s2)
    80004266:	96cff0ef          	jal	800033d2 <iunlock>
      end_op();
    8000426a:	9bbff0ef          	jal	80003c24 <end_op>

      if(r != n1){
    8000426e:	029a9563          	bne	s5,s1,80004298 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004272:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004276:	0149da63          	bge	s3,s4,8000428a <filewrite+0xd8>
      int n1 = n - i;
    8000427a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000427e:	0004879b          	sext.w	a5,s1
    80004282:	fafbd6e3          	bge	s7,a5,8000422e <filewrite+0x7c>
    80004286:	84e2                	mv	s1,s8
    80004288:	b75d                	j	8000422e <filewrite+0x7c>
    8000428a:	74e2                	ld	s1,56(sp)
    8000428c:	6ae2                	ld	s5,24(sp)
    8000428e:	6ba2                	ld	s7,8(sp)
    80004290:	6c02                	ld	s8,0(sp)
    80004292:	a039                	j	800042a0 <filewrite+0xee>
    int i = 0;
    80004294:	4981                	li	s3,0
    80004296:	a029                	j	800042a0 <filewrite+0xee>
    80004298:	74e2                	ld	s1,56(sp)
    8000429a:	6ae2                	ld	s5,24(sp)
    8000429c:	6ba2                	ld	s7,8(sp)
    8000429e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800042a0:	033a1c63          	bne	s4,s3,800042d8 <filewrite+0x126>
    800042a4:	8552                	mv	a0,s4
    800042a6:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800042a8:	60a6                	ld	ra,72(sp)
    800042aa:	6406                	ld	s0,64(sp)
    800042ac:	7942                	ld	s2,48(sp)
    800042ae:	7a02                	ld	s4,32(sp)
    800042b0:	6b42                	ld	s6,16(sp)
    800042b2:	6161                	addi	sp,sp,80
    800042b4:	8082                	ret
    800042b6:	fc26                	sd	s1,56(sp)
    800042b8:	f44e                	sd	s3,40(sp)
    800042ba:	ec56                	sd	s5,24(sp)
    800042bc:	e45e                	sd	s7,8(sp)
    800042be:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800042c0:	00003517          	auipc	a0,0x3
    800042c4:	35850513          	addi	a0,a0,856 # 80007618 <etext+0x618>
    800042c8:	cccfc0ef          	jal	80000794 <panic>
    return -1;
    800042cc:	557d                	li	a0,-1
}
    800042ce:	8082                	ret
      return -1;
    800042d0:	557d                	li	a0,-1
    800042d2:	bfd9                	j	800042a8 <filewrite+0xf6>
    800042d4:	557d                	li	a0,-1
    800042d6:	bfc9                	j	800042a8 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800042d8:	557d                	li	a0,-1
    800042da:	79a2                	ld	s3,40(sp)
    800042dc:	b7f1                	j	800042a8 <filewrite+0xf6>

00000000800042de <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800042de:	7179                	addi	sp,sp,-48
    800042e0:	f406                	sd	ra,40(sp)
    800042e2:	f022                	sd	s0,32(sp)
    800042e4:	ec26                	sd	s1,24(sp)
    800042e6:	e052                	sd	s4,0(sp)
    800042e8:	1800                	addi	s0,sp,48
    800042ea:	84aa                	mv	s1,a0
    800042ec:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800042ee:	0005b023          	sd	zero,0(a1)
    800042f2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800042f6:	c3bff0ef          	jal	80003f30 <filealloc>
    800042fa:	e088                	sd	a0,0(s1)
    800042fc:	c549                	beqz	a0,80004386 <pipealloc+0xa8>
    800042fe:	c33ff0ef          	jal	80003f30 <filealloc>
    80004302:	00aa3023          	sd	a0,0(s4)
    80004306:	cd25                	beqz	a0,8000437e <pipealloc+0xa0>
    80004308:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000430a:	81bfc0ef          	jal	80000b24 <kalloc>
    8000430e:	892a                	mv	s2,a0
    80004310:	c12d                	beqz	a0,80004372 <pipealloc+0x94>
    80004312:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004314:	4985                	li	s3,1
    80004316:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000431a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000431e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004322:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004326:	00003597          	auipc	a1,0x3
    8000432a:	30258593          	addi	a1,a1,770 # 80007628 <etext+0x628>
    8000432e:	847fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004332:	609c                	ld	a5,0(s1)
    80004334:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004338:	609c                	ld	a5,0(s1)
    8000433a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000433e:	609c                	ld	a5,0(s1)
    80004340:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004344:	609c                	ld	a5,0(s1)
    80004346:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000434a:	000a3783          	ld	a5,0(s4)
    8000434e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004352:	000a3783          	ld	a5,0(s4)
    80004356:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000435a:	000a3783          	ld	a5,0(s4)
    8000435e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004362:	000a3783          	ld	a5,0(s4)
    80004366:	0127b823          	sd	s2,16(a5)
  return 0;
    8000436a:	4501                	li	a0,0
    8000436c:	6942                	ld	s2,16(sp)
    8000436e:	69a2                	ld	s3,8(sp)
    80004370:	a01d                	j	80004396 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004372:	6088                	ld	a0,0(s1)
    80004374:	c119                	beqz	a0,8000437a <pipealloc+0x9c>
    80004376:	6942                	ld	s2,16(sp)
    80004378:	a029                	j	80004382 <pipealloc+0xa4>
    8000437a:	6942                	ld	s2,16(sp)
    8000437c:	a029                	j	80004386 <pipealloc+0xa8>
    8000437e:	6088                	ld	a0,0(s1)
    80004380:	c10d                	beqz	a0,800043a2 <pipealloc+0xc4>
    fileclose(*f0);
    80004382:	c53ff0ef          	jal	80003fd4 <fileclose>
  if(*f1)
    80004386:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000438a:	557d                	li	a0,-1
  if(*f1)
    8000438c:	c789                	beqz	a5,80004396 <pipealloc+0xb8>
    fileclose(*f1);
    8000438e:	853e                	mv	a0,a5
    80004390:	c45ff0ef          	jal	80003fd4 <fileclose>
  return -1;
    80004394:	557d                	li	a0,-1
}
    80004396:	70a2                	ld	ra,40(sp)
    80004398:	7402                	ld	s0,32(sp)
    8000439a:	64e2                	ld	s1,24(sp)
    8000439c:	6a02                	ld	s4,0(sp)
    8000439e:	6145                	addi	sp,sp,48
    800043a0:	8082                	ret
  return -1;
    800043a2:	557d                	li	a0,-1
    800043a4:	bfcd                	j	80004396 <pipealloc+0xb8>

00000000800043a6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800043a6:	1101                	addi	sp,sp,-32
    800043a8:	ec06                	sd	ra,24(sp)
    800043aa:	e822                	sd	s0,16(sp)
    800043ac:	e426                	sd	s1,8(sp)
    800043ae:	e04a                	sd	s2,0(sp)
    800043b0:	1000                	addi	s0,sp,32
    800043b2:	84aa                	mv	s1,a0
    800043b4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043b6:	83ffc0ef          	jal	80000bf4 <acquire>
  if(writable){
    800043ba:	02090763          	beqz	s2,800043e8 <pipeclose+0x42>
    pi->writeopen = 0;
    800043be:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800043c2:	21848513          	addi	a0,s1,536
    800043c6:	b35fd0ef          	jal	80001efa <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800043ca:	2204b783          	ld	a5,544(s1)
    800043ce:	e785                	bnez	a5,800043f6 <pipeclose+0x50>
    release(&pi->lock);
    800043d0:	8526                	mv	a0,s1
    800043d2:	8bbfc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    800043d6:	8526                	mv	a0,s1
    800043d8:	e6afc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    800043dc:	60e2                	ld	ra,24(sp)
    800043de:	6442                	ld	s0,16(sp)
    800043e0:	64a2                	ld	s1,8(sp)
    800043e2:	6902                	ld	s2,0(sp)
    800043e4:	6105                	addi	sp,sp,32
    800043e6:	8082                	ret
    pi->readopen = 0;
    800043e8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800043ec:	21c48513          	addi	a0,s1,540
    800043f0:	b0bfd0ef          	jal	80001efa <wakeup>
    800043f4:	bfd9                	j	800043ca <pipeclose+0x24>
    release(&pi->lock);
    800043f6:	8526                	mv	a0,s1
    800043f8:	895fc0ef          	jal	80000c8c <release>
}
    800043fc:	b7c5                	j	800043dc <pipeclose+0x36>

00000000800043fe <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800043fe:	711d                	addi	sp,sp,-96
    80004400:	ec86                	sd	ra,88(sp)
    80004402:	e8a2                	sd	s0,80(sp)
    80004404:	e4a6                	sd	s1,72(sp)
    80004406:	e0ca                	sd	s2,64(sp)
    80004408:	fc4e                	sd	s3,56(sp)
    8000440a:	f852                	sd	s4,48(sp)
    8000440c:	f456                	sd	s5,40(sp)
    8000440e:	1080                	addi	s0,sp,96
    80004410:	84aa                	mv	s1,a0
    80004412:	8aae                	mv	s5,a1
    80004414:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004416:	ccafd0ef          	jal	800018e0 <myproc>
    8000441a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000441c:	8526                	mv	a0,s1
    8000441e:	fd6fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004422:	0b405a63          	blez	s4,800044d6 <pipewrite+0xd8>
    80004426:	f05a                	sd	s6,32(sp)
    80004428:	ec5e                	sd	s7,24(sp)
    8000442a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000442c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000442e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004430:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004434:	21c48b93          	addi	s7,s1,540
    80004438:	a81d                	j	8000446e <pipewrite+0x70>
      release(&pi->lock);
    8000443a:	8526                	mv	a0,s1
    8000443c:	851fc0ef          	jal	80000c8c <release>
      return -1;
    80004440:	597d                	li	s2,-1
    80004442:	7b02                	ld	s6,32(sp)
    80004444:	6be2                	ld	s7,24(sp)
    80004446:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004448:	854a                	mv	a0,s2
    8000444a:	60e6                	ld	ra,88(sp)
    8000444c:	6446                	ld	s0,80(sp)
    8000444e:	64a6                	ld	s1,72(sp)
    80004450:	6906                	ld	s2,64(sp)
    80004452:	79e2                	ld	s3,56(sp)
    80004454:	7a42                	ld	s4,48(sp)
    80004456:	7aa2                	ld	s5,40(sp)
    80004458:	6125                	addi	sp,sp,96
    8000445a:	8082                	ret
      wakeup(&pi->nread);
    8000445c:	8562                	mv	a0,s8
    8000445e:	a9dfd0ef          	jal	80001efa <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004462:	85a6                	mv	a1,s1
    80004464:	855e                	mv	a0,s7
    80004466:	a49fd0ef          	jal	80001eae <sleep>
  while(i < n){
    8000446a:	05495b63          	bge	s2,s4,800044c0 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000446e:	2204a783          	lw	a5,544(s1)
    80004472:	d7e1                	beqz	a5,8000443a <pipewrite+0x3c>
    80004474:	854e                	mv	a0,s3
    80004476:	c71fd0ef          	jal	800020e6 <killed>
    8000447a:	f161                	bnez	a0,8000443a <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000447c:	2184a783          	lw	a5,536(s1)
    80004480:	21c4a703          	lw	a4,540(s1)
    80004484:	2007879b          	addiw	a5,a5,512
    80004488:	fcf70ae3          	beq	a4,a5,8000445c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000448c:	4685                	li	a3,1
    8000448e:	01590633          	add	a2,s2,s5
    80004492:	faf40593          	addi	a1,s0,-81
    80004496:	0509b503          	ld	a0,80(s3)
    8000449a:	98efd0ef          	jal	80001628 <copyin>
    8000449e:	03650e63          	beq	a0,s6,800044da <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044a2:	21c4a783          	lw	a5,540(s1)
    800044a6:	0017871b          	addiw	a4,a5,1
    800044aa:	20e4ae23          	sw	a4,540(s1)
    800044ae:	1ff7f793          	andi	a5,a5,511
    800044b2:	97a6                	add	a5,a5,s1
    800044b4:	faf44703          	lbu	a4,-81(s0)
    800044b8:	00e78c23          	sb	a4,24(a5)
      i++;
    800044bc:	2905                	addiw	s2,s2,1
    800044be:	b775                	j	8000446a <pipewrite+0x6c>
    800044c0:	7b02                	ld	s6,32(sp)
    800044c2:	6be2                	ld	s7,24(sp)
    800044c4:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800044c6:	21848513          	addi	a0,s1,536
    800044ca:	a31fd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    800044ce:	8526                	mv	a0,s1
    800044d0:	fbcfc0ef          	jal	80000c8c <release>
  return i;
    800044d4:	bf95                	j	80004448 <pipewrite+0x4a>
  int i = 0;
    800044d6:	4901                	li	s2,0
    800044d8:	b7fd                	j	800044c6 <pipewrite+0xc8>
    800044da:	7b02                	ld	s6,32(sp)
    800044dc:	6be2                	ld	s7,24(sp)
    800044de:	6c42                	ld	s8,16(sp)
    800044e0:	b7dd                	j	800044c6 <pipewrite+0xc8>

00000000800044e2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800044e2:	715d                	addi	sp,sp,-80
    800044e4:	e486                	sd	ra,72(sp)
    800044e6:	e0a2                	sd	s0,64(sp)
    800044e8:	fc26                	sd	s1,56(sp)
    800044ea:	f84a                	sd	s2,48(sp)
    800044ec:	f44e                	sd	s3,40(sp)
    800044ee:	f052                	sd	s4,32(sp)
    800044f0:	ec56                	sd	s5,24(sp)
    800044f2:	0880                	addi	s0,sp,80
    800044f4:	84aa                	mv	s1,a0
    800044f6:	892e                	mv	s2,a1
    800044f8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800044fa:	be6fd0ef          	jal	800018e0 <myproc>
    800044fe:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004500:	8526                	mv	a0,s1
    80004502:	ef2fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004506:	2184a703          	lw	a4,536(s1)
    8000450a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000450e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004512:	02f71563          	bne	a4,a5,8000453c <piperead+0x5a>
    80004516:	2244a783          	lw	a5,548(s1)
    8000451a:	cb85                	beqz	a5,8000454a <piperead+0x68>
    if(killed(pr)){
    8000451c:	8552                	mv	a0,s4
    8000451e:	bc9fd0ef          	jal	800020e6 <killed>
    80004522:	ed19                	bnez	a0,80004540 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004524:	85a6                	mv	a1,s1
    80004526:	854e                	mv	a0,s3
    80004528:	987fd0ef          	jal	80001eae <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000452c:	2184a703          	lw	a4,536(s1)
    80004530:	21c4a783          	lw	a5,540(s1)
    80004534:	fef701e3          	beq	a4,a5,80004516 <piperead+0x34>
    80004538:	e85a                	sd	s6,16(sp)
    8000453a:	a809                	j	8000454c <piperead+0x6a>
    8000453c:	e85a                	sd	s6,16(sp)
    8000453e:	a039                	j	8000454c <piperead+0x6a>
      release(&pi->lock);
    80004540:	8526                	mv	a0,s1
    80004542:	f4afc0ef          	jal	80000c8c <release>
      return -1;
    80004546:	59fd                	li	s3,-1
    80004548:	a8b1                	j	800045a4 <piperead+0xc2>
    8000454a:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000454c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000454e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004550:	05505263          	blez	s5,80004594 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004554:	2184a783          	lw	a5,536(s1)
    80004558:	21c4a703          	lw	a4,540(s1)
    8000455c:	02f70c63          	beq	a4,a5,80004594 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004560:	0017871b          	addiw	a4,a5,1
    80004564:	20e4ac23          	sw	a4,536(s1)
    80004568:	1ff7f793          	andi	a5,a5,511
    8000456c:	97a6                	add	a5,a5,s1
    8000456e:	0187c783          	lbu	a5,24(a5)
    80004572:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004576:	4685                	li	a3,1
    80004578:	fbf40613          	addi	a2,s0,-65
    8000457c:	85ca                	mv	a1,s2
    8000457e:	050a3503          	ld	a0,80(s4)
    80004582:	fd1fc0ef          	jal	80001552 <copyout>
    80004586:	01650763          	beq	a0,s6,80004594 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000458a:	2985                	addiw	s3,s3,1
    8000458c:	0905                	addi	s2,s2,1
    8000458e:	fd3a93e3          	bne	s5,s3,80004554 <piperead+0x72>
    80004592:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004594:	21c48513          	addi	a0,s1,540
    80004598:	963fd0ef          	jal	80001efa <wakeup>
  release(&pi->lock);
    8000459c:	8526                	mv	a0,s1
    8000459e:	eeefc0ef          	jal	80000c8c <release>
    800045a2:	6b42                	ld	s6,16(sp)
  return i;
}
    800045a4:	854e                	mv	a0,s3
    800045a6:	60a6                	ld	ra,72(sp)
    800045a8:	6406                	ld	s0,64(sp)
    800045aa:	74e2                	ld	s1,56(sp)
    800045ac:	7942                	ld	s2,48(sp)
    800045ae:	79a2                	ld	s3,40(sp)
    800045b0:	7a02                	ld	s4,32(sp)
    800045b2:	6ae2                	ld	s5,24(sp)
    800045b4:	6161                	addi	sp,sp,80
    800045b6:	8082                	ret

00000000800045b8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800045b8:	1141                	addi	sp,sp,-16
    800045ba:	e422                	sd	s0,8(sp)
    800045bc:	0800                	addi	s0,sp,16
    800045be:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800045c0:	8905                	andi	a0,a0,1
    800045c2:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800045c4:	8b89                	andi	a5,a5,2
    800045c6:	c399                	beqz	a5,800045cc <flags2perm+0x14>
      perm |= PTE_W;
    800045c8:	00456513          	ori	a0,a0,4
    return perm;
}
    800045cc:	6422                	ld	s0,8(sp)
    800045ce:	0141                	addi	sp,sp,16
    800045d0:	8082                	ret

00000000800045d2 <exec>:

int
exec(char *path, char **argv)
{
    800045d2:	df010113          	addi	sp,sp,-528
    800045d6:	20113423          	sd	ra,520(sp)
    800045da:	20813023          	sd	s0,512(sp)
    800045de:	ffa6                	sd	s1,504(sp)
    800045e0:	fbca                	sd	s2,496(sp)
    800045e2:	0c00                	addi	s0,sp,528
    800045e4:	892a                	mv	s2,a0
    800045e6:	dea43c23          	sd	a0,-520(s0)
    800045ea:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800045ee:	af2fd0ef          	jal	800018e0 <myproc>
    800045f2:	84aa                	mv	s1,a0

  begin_op();
    800045f4:	dc6ff0ef          	jal	80003bba <begin_op>

  if((ip = namei(path)) == 0){
    800045f8:	854a                	mv	a0,s2
    800045fa:	c04ff0ef          	jal	800039fe <namei>
    800045fe:	c931                	beqz	a0,80004652 <exec+0x80>
    80004600:	f3d2                	sd	s4,480(sp)
    80004602:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004604:	d21fe0ef          	jal	80003324 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004608:	04000713          	li	a4,64
    8000460c:	4681                	li	a3,0
    8000460e:	e5040613          	addi	a2,s0,-432
    80004612:	4581                	li	a1,0
    80004614:	8552                	mv	a0,s4
    80004616:	f63fe0ef          	jal	80003578 <readi>
    8000461a:	04000793          	li	a5,64
    8000461e:	00f51a63          	bne	a0,a5,80004632 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004622:	e5042703          	lw	a4,-432(s0)
    80004626:	464c47b7          	lui	a5,0x464c4
    8000462a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000462e:	02f70663          	beq	a4,a5,8000465a <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004632:	8552                	mv	a0,s4
    80004634:	efbfe0ef          	jal	8000352e <iunlockput>
    end_op();
    80004638:	decff0ef          	jal	80003c24 <end_op>
  }
  return -1;
    8000463c:	557d                	li	a0,-1
    8000463e:	7a1e                	ld	s4,480(sp)
}
    80004640:	20813083          	ld	ra,520(sp)
    80004644:	20013403          	ld	s0,512(sp)
    80004648:	74fe                	ld	s1,504(sp)
    8000464a:	795e                	ld	s2,496(sp)
    8000464c:	21010113          	addi	sp,sp,528
    80004650:	8082                	ret
    end_op();
    80004652:	dd2ff0ef          	jal	80003c24 <end_op>
    return -1;
    80004656:	557d                	li	a0,-1
    80004658:	b7e5                	j	80004640 <exec+0x6e>
    8000465a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000465c:	8526                	mv	a0,s1
    8000465e:	b2afd0ef          	jal	80001988 <proc_pagetable>
    80004662:	8b2a                	mv	s6,a0
    80004664:	2c050b63          	beqz	a0,8000493a <exec+0x368>
    80004668:	f7ce                	sd	s3,488(sp)
    8000466a:	efd6                	sd	s5,472(sp)
    8000466c:	e7de                	sd	s7,456(sp)
    8000466e:	e3e2                	sd	s8,448(sp)
    80004670:	ff66                	sd	s9,440(sp)
    80004672:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004674:	e7042d03          	lw	s10,-400(s0)
    80004678:	e8845783          	lhu	a5,-376(s0)
    8000467c:	12078963          	beqz	a5,800047ae <exec+0x1dc>
    80004680:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004682:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004684:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004686:	6c85                	lui	s9,0x1
    80004688:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000468c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004690:	6a85                	lui	s5,0x1
    80004692:	a085                	j	800046f2 <exec+0x120>
      panic("loadseg: address should exist");
    80004694:	00003517          	auipc	a0,0x3
    80004698:	f9c50513          	addi	a0,a0,-100 # 80007630 <etext+0x630>
    8000469c:	8f8fc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    800046a0:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800046a2:	8726                	mv	a4,s1
    800046a4:	012c06bb          	addw	a3,s8,s2
    800046a8:	4581                	li	a1,0
    800046aa:	8552                	mv	a0,s4
    800046ac:	ecdfe0ef          	jal	80003578 <readi>
    800046b0:	2501                	sext.w	a0,a0
    800046b2:	24a49a63          	bne	s1,a0,80004906 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800046b6:	012a893b          	addw	s2,s5,s2
    800046ba:	03397363          	bgeu	s2,s3,800046e0 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800046be:	02091593          	slli	a1,s2,0x20
    800046c2:	9181                	srli	a1,a1,0x20
    800046c4:	95de                	add	a1,a1,s7
    800046c6:	855a                	mv	a0,s6
    800046c8:	90ffc0ef          	jal	80000fd6 <walkaddr>
    800046cc:	862a                	mv	a2,a0
    if(pa == 0)
    800046ce:	d179                	beqz	a0,80004694 <exec+0xc2>
    if(sz - i < PGSIZE)
    800046d0:	412984bb          	subw	s1,s3,s2
    800046d4:	0004879b          	sext.w	a5,s1
    800046d8:	fcfcf4e3          	bgeu	s9,a5,800046a0 <exec+0xce>
    800046dc:	84d6                	mv	s1,s5
    800046de:	b7c9                	j	800046a0 <exec+0xce>
    sz = sz1;
    800046e0:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046e4:	2d85                	addiw	s11,s11,1
    800046e6:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    800046ea:	e8845783          	lhu	a5,-376(s0)
    800046ee:	08fdd063          	bge	s11,a5,8000476e <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800046f2:	2d01                	sext.w	s10,s10
    800046f4:	03800713          	li	a4,56
    800046f8:	86ea                	mv	a3,s10
    800046fa:	e1840613          	addi	a2,s0,-488
    800046fe:	4581                	li	a1,0
    80004700:	8552                	mv	a0,s4
    80004702:	e77fe0ef          	jal	80003578 <readi>
    80004706:	03800793          	li	a5,56
    8000470a:	1cf51663          	bne	a0,a5,800048d6 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000470e:	e1842783          	lw	a5,-488(s0)
    80004712:	4705                	li	a4,1
    80004714:	fce798e3          	bne	a5,a4,800046e4 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004718:	e4043483          	ld	s1,-448(s0)
    8000471c:	e3843783          	ld	a5,-456(s0)
    80004720:	1af4ef63          	bltu	s1,a5,800048de <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004724:	e2843783          	ld	a5,-472(s0)
    80004728:	94be                	add	s1,s1,a5
    8000472a:	1af4ee63          	bltu	s1,a5,800048e6 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000472e:	df043703          	ld	a4,-528(s0)
    80004732:	8ff9                	and	a5,a5,a4
    80004734:	1a079d63          	bnez	a5,800048ee <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004738:	e1c42503          	lw	a0,-484(s0)
    8000473c:	e7dff0ef          	jal	800045b8 <flags2perm>
    80004740:	86aa                	mv	a3,a0
    80004742:	8626                	mv	a2,s1
    80004744:	85ca                	mv	a1,s2
    80004746:	855a                	mv	a0,s6
    80004748:	bf7fc0ef          	jal	8000133e <uvmalloc>
    8000474c:	e0a43423          	sd	a0,-504(s0)
    80004750:	1a050363          	beqz	a0,800048f6 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004754:	e2843b83          	ld	s7,-472(s0)
    80004758:	e2042c03          	lw	s8,-480(s0)
    8000475c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004760:	00098463          	beqz	s3,80004768 <exec+0x196>
    80004764:	4901                	li	s2,0
    80004766:	bfa1                	j	800046be <exec+0xec>
    sz = sz1;
    80004768:	e0843903          	ld	s2,-504(s0)
    8000476c:	bfa5                	j	800046e4 <exec+0x112>
    8000476e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004770:	8552                	mv	a0,s4
    80004772:	dbdfe0ef          	jal	8000352e <iunlockput>
  end_op();
    80004776:	caeff0ef          	jal	80003c24 <end_op>
  p = myproc();
    8000477a:	966fd0ef          	jal	800018e0 <myproc>
    8000477e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004780:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004784:	6985                	lui	s3,0x1
    80004786:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004788:	99ca                	add	s3,s3,s2
    8000478a:	77fd                	lui	a5,0xfffff
    8000478c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004790:	4691                	li	a3,4
    80004792:	6609                	lui	a2,0x2
    80004794:	964e                	add	a2,a2,s3
    80004796:	85ce                	mv	a1,s3
    80004798:	855a                	mv	a0,s6
    8000479a:	ba5fc0ef          	jal	8000133e <uvmalloc>
    8000479e:	892a                	mv	s2,a0
    800047a0:	e0a43423          	sd	a0,-504(s0)
    800047a4:	e519                	bnez	a0,800047b2 <exec+0x1e0>
  if(pagetable)
    800047a6:	e1343423          	sd	s3,-504(s0)
    800047aa:	4a01                	li	s4,0
    800047ac:	aab1                	j	80004908 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047ae:	4901                	li	s2,0
    800047b0:	b7c1                	j	80004770 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800047b2:	75f9                	lui	a1,0xffffe
    800047b4:	95aa                	add	a1,a1,a0
    800047b6:	855a                	mv	a0,s6
    800047b8:	d71fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800047bc:	7bfd                	lui	s7,0xfffff
    800047be:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800047c0:	e0043783          	ld	a5,-512(s0)
    800047c4:	6388                	ld	a0,0(a5)
    800047c6:	cd39                	beqz	a0,80004824 <exec+0x252>
    800047c8:	e9040993          	addi	s3,s0,-368
    800047cc:	f9040c13          	addi	s8,s0,-112
    800047d0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800047d2:	e66fc0ef          	jal	80000e38 <strlen>
    800047d6:	0015079b          	addiw	a5,a0,1
    800047da:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800047de:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800047e2:	11796e63          	bltu	s2,s7,800048fe <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800047e6:	e0043d03          	ld	s10,-512(s0)
    800047ea:	000d3a03          	ld	s4,0(s10)
    800047ee:	8552                	mv	a0,s4
    800047f0:	e48fc0ef          	jal	80000e38 <strlen>
    800047f4:	0015069b          	addiw	a3,a0,1
    800047f8:	8652                	mv	a2,s4
    800047fa:	85ca                	mv	a1,s2
    800047fc:	855a                	mv	a0,s6
    800047fe:	d55fc0ef          	jal	80001552 <copyout>
    80004802:	10054063          	bltz	a0,80004902 <exec+0x330>
    ustack[argc] = sp;
    80004806:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000480a:	0485                	addi	s1,s1,1
    8000480c:	008d0793          	addi	a5,s10,8
    80004810:	e0f43023          	sd	a5,-512(s0)
    80004814:	008d3503          	ld	a0,8(s10)
    80004818:	c909                	beqz	a0,8000482a <exec+0x258>
    if(argc >= MAXARG)
    8000481a:	09a1                	addi	s3,s3,8
    8000481c:	fb899be3          	bne	s3,s8,800047d2 <exec+0x200>
  ip = 0;
    80004820:	4a01                	li	s4,0
    80004822:	a0dd                	j	80004908 <exec+0x336>
  sp = sz;
    80004824:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004828:	4481                	li	s1,0
  ustack[argc] = 0;
    8000482a:	00349793          	slli	a5,s1,0x3
    8000482e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde310>
    80004832:	97a2                	add	a5,a5,s0
    80004834:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004838:	00148693          	addi	a3,s1,1
    8000483c:	068e                	slli	a3,a3,0x3
    8000483e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004842:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004846:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000484a:	f5796ee3          	bltu	s2,s7,800047a6 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000484e:	e9040613          	addi	a2,s0,-368
    80004852:	85ca                	mv	a1,s2
    80004854:	855a                	mv	a0,s6
    80004856:	cfdfc0ef          	jal	80001552 <copyout>
    8000485a:	0e054263          	bltz	a0,8000493e <exec+0x36c>
  p->trapframe->a1 = sp;
    8000485e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004862:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004866:	df843783          	ld	a5,-520(s0)
    8000486a:	0007c703          	lbu	a4,0(a5)
    8000486e:	cf11                	beqz	a4,8000488a <exec+0x2b8>
    80004870:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004872:	02f00693          	li	a3,47
    80004876:	a039                	j	80004884 <exec+0x2b2>
      last = s+1;
    80004878:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000487c:	0785                	addi	a5,a5,1
    8000487e:	fff7c703          	lbu	a4,-1(a5)
    80004882:	c701                	beqz	a4,8000488a <exec+0x2b8>
    if(*s == '/')
    80004884:	fed71ce3          	bne	a4,a3,8000487c <exec+0x2aa>
    80004888:	bfc5                	j	80004878 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    8000488a:	4641                	li	a2,16
    8000488c:	df843583          	ld	a1,-520(s0)
    80004890:	158a8513          	addi	a0,s5,344
    80004894:	d72fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004898:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000489c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048a0:	e0843783          	ld	a5,-504(s0)
    800048a4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800048a8:	058ab783          	ld	a5,88(s5)
    800048ac:	e6843703          	ld	a4,-408(s0)
    800048b0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800048b2:	058ab783          	ld	a5,88(s5)
    800048b6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800048ba:	85e6                	mv	a1,s9
    800048bc:	950fd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800048c0:	0004851b          	sext.w	a0,s1
    800048c4:	79be                	ld	s3,488(sp)
    800048c6:	7a1e                	ld	s4,480(sp)
    800048c8:	6afe                	ld	s5,472(sp)
    800048ca:	6b5e                	ld	s6,464(sp)
    800048cc:	6bbe                	ld	s7,456(sp)
    800048ce:	6c1e                	ld	s8,448(sp)
    800048d0:	7cfa                	ld	s9,440(sp)
    800048d2:	7d5a                	ld	s10,432(sp)
    800048d4:	b3b5                	j	80004640 <exec+0x6e>
    800048d6:	e1243423          	sd	s2,-504(s0)
    800048da:	7dba                	ld	s11,424(sp)
    800048dc:	a035                	j	80004908 <exec+0x336>
    800048de:	e1243423          	sd	s2,-504(s0)
    800048e2:	7dba                	ld	s11,424(sp)
    800048e4:	a015                	j	80004908 <exec+0x336>
    800048e6:	e1243423          	sd	s2,-504(s0)
    800048ea:	7dba                	ld	s11,424(sp)
    800048ec:	a831                	j	80004908 <exec+0x336>
    800048ee:	e1243423          	sd	s2,-504(s0)
    800048f2:	7dba                	ld	s11,424(sp)
    800048f4:	a811                	j	80004908 <exec+0x336>
    800048f6:	e1243423          	sd	s2,-504(s0)
    800048fa:	7dba                	ld	s11,424(sp)
    800048fc:	a031                	j	80004908 <exec+0x336>
  ip = 0;
    800048fe:	4a01                	li	s4,0
    80004900:	a021                	j	80004908 <exec+0x336>
    80004902:	4a01                	li	s4,0
  if(pagetable)
    80004904:	a011                	j	80004908 <exec+0x336>
    80004906:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004908:	e0843583          	ld	a1,-504(s0)
    8000490c:	855a                	mv	a0,s6
    8000490e:	8fefd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    80004912:	557d                	li	a0,-1
  if(ip){
    80004914:	000a1b63          	bnez	s4,8000492a <exec+0x358>
    80004918:	79be                	ld	s3,488(sp)
    8000491a:	7a1e                	ld	s4,480(sp)
    8000491c:	6afe                	ld	s5,472(sp)
    8000491e:	6b5e                	ld	s6,464(sp)
    80004920:	6bbe                	ld	s7,456(sp)
    80004922:	6c1e                	ld	s8,448(sp)
    80004924:	7cfa                	ld	s9,440(sp)
    80004926:	7d5a                	ld	s10,432(sp)
    80004928:	bb21                	j	80004640 <exec+0x6e>
    8000492a:	79be                	ld	s3,488(sp)
    8000492c:	6afe                	ld	s5,472(sp)
    8000492e:	6b5e                	ld	s6,464(sp)
    80004930:	6bbe                	ld	s7,456(sp)
    80004932:	6c1e                	ld	s8,448(sp)
    80004934:	7cfa                	ld	s9,440(sp)
    80004936:	7d5a                	ld	s10,432(sp)
    80004938:	b9ed                	j	80004632 <exec+0x60>
    8000493a:	6b5e                	ld	s6,464(sp)
    8000493c:	b9dd                	j	80004632 <exec+0x60>
  sz = sz1;
    8000493e:	e0843983          	ld	s3,-504(s0)
    80004942:	b595                	j	800047a6 <exec+0x1d4>

0000000080004944 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004944:	7179                	addi	sp,sp,-48
    80004946:	f406                	sd	ra,40(sp)
    80004948:	f022                	sd	s0,32(sp)
    8000494a:	ec26                	sd	s1,24(sp)
    8000494c:	e84a                	sd	s2,16(sp)
    8000494e:	1800                	addi	s0,sp,48
    80004950:	892e                	mv	s2,a1
    80004952:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004954:	fdc40593          	addi	a1,s0,-36
    80004958:	e83fd0ef          	jal	800027da <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000495c:	fdc42703          	lw	a4,-36(s0)
    80004960:	47bd                	li	a5,15
    80004962:	02e7e963          	bltu	a5,a4,80004994 <argfd+0x50>
    80004966:	f7bfc0ef          	jal	800018e0 <myproc>
    8000496a:	fdc42703          	lw	a4,-36(s0)
    8000496e:	01a70793          	addi	a5,a4,26
    80004972:	078e                	slli	a5,a5,0x3
    80004974:	953e                	add	a0,a0,a5
    80004976:	611c                	ld	a5,0(a0)
    80004978:	c385                	beqz	a5,80004998 <argfd+0x54>
    return -1;
  if(pfd)
    8000497a:	00090463          	beqz	s2,80004982 <argfd+0x3e>
    *pfd = fd;
    8000497e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004982:	4501                	li	a0,0
  if(pf)
    80004984:	c091                	beqz	s1,80004988 <argfd+0x44>
    *pf = f;
    80004986:	e09c                	sd	a5,0(s1)
}
    80004988:	70a2                	ld	ra,40(sp)
    8000498a:	7402                	ld	s0,32(sp)
    8000498c:	64e2                	ld	s1,24(sp)
    8000498e:	6942                	ld	s2,16(sp)
    80004990:	6145                	addi	sp,sp,48
    80004992:	8082                	ret
    return -1;
    80004994:	557d                	li	a0,-1
    80004996:	bfcd                	j	80004988 <argfd+0x44>
    80004998:	557d                	li	a0,-1
    8000499a:	b7fd                	j	80004988 <argfd+0x44>

000000008000499c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000499c:	1101                	addi	sp,sp,-32
    8000499e:	ec06                	sd	ra,24(sp)
    800049a0:	e822                	sd	s0,16(sp)
    800049a2:	e426                	sd	s1,8(sp)
    800049a4:	1000                	addi	s0,sp,32
    800049a6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049a8:	f39fc0ef          	jal	800018e0 <myproc>
    800049ac:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800049ae:	0d050793          	addi	a5,a0,208
    800049b2:	4501                	li	a0,0
    800049b4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800049b6:	6398                	ld	a4,0(a5)
    800049b8:	cb19                	beqz	a4,800049ce <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800049ba:	2505                	addiw	a0,a0,1
    800049bc:	07a1                	addi	a5,a5,8
    800049be:	fed51ce3          	bne	a0,a3,800049b6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049c2:	557d                	li	a0,-1
}
    800049c4:	60e2                	ld	ra,24(sp)
    800049c6:	6442                	ld	s0,16(sp)
    800049c8:	64a2                	ld	s1,8(sp)
    800049ca:	6105                	addi	sp,sp,32
    800049cc:	8082                	ret
      p->ofile[fd] = f;
    800049ce:	01a50793          	addi	a5,a0,26
    800049d2:	078e                	slli	a5,a5,0x3
    800049d4:	963e                	add	a2,a2,a5
    800049d6:	e204                	sd	s1,0(a2)
      return fd;
    800049d8:	b7f5                	j	800049c4 <fdalloc+0x28>

00000000800049da <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800049da:	715d                	addi	sp,sp,-80
    800049dc:	e486                	sd	ra,72(sp)
    800049de:	e0a2                	sd	s0,64(sp)
    800049e0:	fc26                	sd	s1,56(sp)
    800049e2:	f84a                	sd	s2,48(sp)
    800049e4:	f44e                	sd	s3,40(sp)
    800049e6:	ec56                	sd	s5,24(sp)
    800049e8:	e85a                	sd	s6,16(sp)
    800049ea:	0880                	addi	s0,sp,80
    800049ec:	8b2e                	mv	s6,a1
    800049ee:	89b2                	mv	s3,a2
    800049f0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800049f2:	fb040593          	addi	a1,s0,-80
    800049f6:	822ff0ef          	jal	80003a18 <nameiparent>
    800049fa:	84aa                	mv	s1,a0
    800049fc:	10050a63          	beqz	a0,80004b10 <create+0x136>
    return 0;

  ilock(dp);
    80004a00:	925fe0ef          	jal	80003324 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a04:	4601                	li	a2,0
    80004a06:	fb040593          	addi	a1,s0,-80
    80004a0a:	8526                	mv	a0,s1
    80004a0c:	d8dfe0ef          	jal	80003798 <dirlookup>
    80004a10:	8aaa                	mv	s5,a0
    80004a12:	c129                	beqz	a0,80004a54 <create+0x7a>
    iunlockput(dp);
    80004a14:	8526                	mv	a0,s1
    80004a16:	b19fe0ef          	jal	8000352e <iunlockput>
    ilock(ip);
    80004a1a:	8556                	mv	a0,s5
    80004a1c:	909fe0ef          	jal	80003324 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a20:	4789                	li	a5,2
    80004a22:	02fb1463          	bne	s6,a5,80004a4a <create+0x70>
    80004a26:	044ad783          	lhu	a5,68(s5)
    80004a2a:	37f9                	addiw	a5,a5,-2
    80004a2c:	17c2                	slli	a5,a5,0x30
    80004a2e:	93c1                	srli	a5,a5,0x30
    80004a30:	4705                	li	a4,1
    80004a32:	00f76c63          	bltu	a4,a5,80004a4a <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a36:	8556                	mv	a0,s5
    80004a38:	60a6                	ld	ra,72(sp)
    80004a3a:	6406                	ld	s0,64(sp)
    80004a3c:	74e2                	ld	s1,56(sp)
    80004a3e:	7942                	ld	s2,48(sp)
    80004a40:	79a2                	ld	s3,40(sp)
    80004a42:	6ae2                	ld	s5,24(sp)
    80004a44:	6b42                	ld	s6,16(sp)
    80004a46:	6161                	addi	sp,sp,80
    80004a48:	8082                	ret
    iunlockput(ip);
    80004a4a:	8556                	mv	a0,s5
    80004a4c:	ae3fe0ef          	jal	8000352e <iunlockput>
    return 0;
    80004a50:	4a81                	li	s5,0
    80004a52:	b7d5                	j	80004a36 <create+0x5c>
    80004a54:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a56:	85da                	mv	a1,s6
    80004a58:	4088                	lw	a0,0(s1)
    80004a5a:	f5afe0ef          	jal	800031b4 <ialloc>
    80004a5e:	8a2a                	mv	s4,a0
    80004a60:	cd15                	beqz	a0,80004a9c <create+0xc2>
  ilock(ip);
    80004a62:	8c3fe0ef          	jal	80003324 <ilock>
  ip->major = major;
    80004a66:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004a6a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004a6e:	4905                	li	s2,1
    80004a70:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004a74:	8552                	mv	a0,s4
    80004a76:	ffafe0ef          	jal	80003270 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004a7a:	032b0763          	beq	s6,s2,80004aa8 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a7e:	004a2603          	lw	a2,4(s4)
    80004a82:	fb040593          	addi	a1,s0,-80
    80004a86:	8526                	mv	a0,s1
    80004a88:	eddfe0ef          	jal	80003964 <dirlink>
    80004a8c:	06054563          	bltz	a0,80004af6 <create+0x11c>
  iunlockput(dp);
    80004a90:	8526                	mv	a0,s1
    80004a92:	a9dfe0ef          	jal	8000352e <iunlockput>
  return ip;
    80004a96:	8ad2                	mv	s5,s4
    80004a98:	7a02                	ld	s4,32(sp)
    80004a9a:	bf71                	j	80004a36 <create+0x5c>
    iunlockput(dp);
    80004a9c:	8526                	mv	a0,s1
    80004a9e:	a91fe0ef          	jal	8000352e <iunlockput>
    return 0;
    80004aa2:	8ad2                	mv	s5,s4
    80004aa4:	7a02                	ld	s4,32(sp)
    80004aa6:	bf41                	j	80004a36 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004aa8:	004a2603          	lw	a2,4(s4)
    80004aac:	00003597          	auipc	a1,0x3
    80004ab0:	ba458593          	addi	a1,a1,-1116 # 80007650 <etext+0x650>
    80004ab4:	8552                	mv	a0,s4
    80004ab6:	eaffe0ef          	jal	80003964 <dirlink>
    80004aba:	02054e63          	bltz	a0,80004af6 <create+0x11c>
    80004abe:	40d0                	lw	a2,4(s1)
    80004ac0:	00003597          	auipc	a1,0x3
    80004ac4:	b9858593          	addi	a1,a1,-1128 # 80007658 <etext+0x658>
    80004ac8:	8552                	mv	a0,s4
    80004aca:	e9bfe0ef          	jal	80003964 <dirlink>
    80004ace:	02054463          	bltz	a0,80004af6 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ad2:	004a2603          	lw	a2,4(s4)
    80004ad6:	fb040593          	addi	a1,s0,-80
    80004ada:	8526                	mv	a0,s1
    80004adc:	e89fe0ef          	jal	80003964 <dirlink>
    80004ae0:	00054b63          	bltz	a0,80004af6 <create+0x11c>
    dp->nlink++;  // for ".."
    80004ae4:	04a4d783          	lhu	a5,74(s1)
    80004ae8:	2785                	addiw	a5,a5,1
    80004aea:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004aee:	8526                	mv	a0,s1
    80004af0:	f80fe0ef          	jal	80003270 <iupdate>
    80004af4:	bf71                	j	80004a90 <create+0xb6>
  ip->nlink = 0;
    80004af6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004afa:	8552                	mv	a0,s4
    80004afc:	f74fe0ef          	jal	80003270 <iupdate>
  iunlockput(ip);
    80004b00:	8552                	mv	a0,s4
    80004b02:	a2dfe0ef          	jal	8000352e <iunlockput>
  iunlockput(dp);
    80004b06:	8526                	mv	a0,s1
    80004b08:	a27fe0ef          	jal	8000352e <iunlockput>
  return 0;
    80004b0c:	7a02                	ld	s4,32(sp)
    80004b0e:	b725                	j	80004a36 <create+0x5c>
    return 0;
    80004b10:	8aaa                	mv	s5,a0
    80004b12:	b715                	j	80004a36 <create+0x5c>

0000000080004b14 <sys_dup>:
{
    80004b14:	7179                	addi	sp,sp,-48
    80004b16:	f406                	sd	ra,40(sp)
    80004b18:	f022                	sd	s0,32(sp)
    80004b1a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b1c:	fd840613          	addi	a2,s0,-40
    80004b20:	4581                	li	a1,0
    80004b22:	4501                	li	a0,0
    80004b24:	e21ff0ef          	jal	80004944 <argfd>
    return -1;
    80004b28:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b2a:	02054363          	bltz	a0,80004b50 <sys_dup+0x3c>
    80004b2e:	ec26                	sd	s1,24(sp)
    80004b30:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b32:	fd843903          	ld	s2,-40(s0)
    80004b36:	854a                	mv	a0,s2
    80004b38:	e65ff0ef          	jal	8000499c <fdalloc>
    80004b3c:	84aa                	mv	s1,a0
    return -1;
    80004b3e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b40:	00054d63          	bltz	a0,80004b5a <sys_dup+0x46>
  filedup(f);
    80004b44:	854a                	mv	a0,s2
    80004b46:	c48ff0ef          	jal	80003f8e <filedup>
  return fd;
    80004b4a:	87a6                	mv	a5,s1
    80004b4c:	64e2                	ld	s1,24(sp)
    80004b4e:	6942                	ld	s2,16(sp)
}
    80004b50:	853e                	mv	a0,a5
    80004b52:	70a2                	ld	ra,40(sp)
    80004b54:	7402                	ld	s0,32(sp)
    80004b56:	6145                	addi	sp,sp,48
    80004b58:	8082                	ret
    80004b5a:	64e2                	ld	s1,24(sp)
    80004b5c:	6942                	ld	s2,16(sp)
    80004b5e:	bfcd                	j	80004b50 <sys_dup+0x3c>

0000000080004b60 <sys_read>:
{
    80004b60:	7179                	addi	sp,sp,-48
    80004b62:	f406                	sd	ra,40(sp)
    80004b64:	f022                	sd	s0,32(sp)
    80004b66:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b68:	fd840593          	addi	a1,s0,-40
    80004b6c:	4505                	li	a0,1
    80004b6e:	c89fd0ef          	jal	800027f6 <argaddr>
  argint(2, &n);
    80004b72:	fe440593          	addi	a1,s0,-28
    80004b76:	4509                	li	a0,2
    80004b78:	c63fd0ef          	jal	800027da <argint>
  if(argfd(0, 0, &f) < 0)
    80004b7c:	fe840613          	addi	a2,s0,-24
    80004b80:	4581                	li	a1,0
    80004b82:	4501                	li	a0,0
    80004b84:	dc1ff0ef          	jal	80004944 <argfd>
    80004b88:	87aa                	mv	a5,a0
    return -1;
    80004b8a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b8c:	0007ca63          	bltz	a5,80004ba0 <sys_read+0x40>
  return fileread(f, p, n);
    80004b90:	fe442603          	lw	a2,-28(s0)
    80004b94:	fd843583          	ld	a1,-40(s0)
    80004b98:	fe843503          	ld	a0,-24(s0)
    80004b9c:	d58ff0ef          	jal	800040f4 <fileread>
}
    80004ba0:	70a2                	ld	ra,40(sp)
    80004ba2:	7402                	ld	s0,32(sp)
    80004ba4:	6145                	addi	sp,sp,48
    80004ba6:	8082                	ret

0000000080004ba8 <sys_write>:
{
    80004ba8:	7179                	addi	sp,sp,-48
    80004baa:	f406                	sd	ra,40(sp)
    80004bac:	f022                	sd	s0,32(sp)
    80004bae:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bb0:	fd840593          	addi	a1,s0,-40
    80004bb4:	4505                	li	a0,1
    80004bb6:	c41fd0ef          	jal	800027f6 <argaddr>
  argint(2, &n);
    80004bba:	fe440593          	addi	a1,s0,-28
    80004bbe:	4509                	li	a0,2
    80004bc0:	c1bfd0ef          	jal	800027da <argint>
  if(argfd(0, 0, &f) < 0)
    80004bc4:	fe840613          	addi	a2,s0,-24
    80004bc8:	4581                	li	a1,0
    80004bca:	4501                	li	a0,0
    80004bcc:	d79ff0ef          	jal	80004944 <argfd>
    80004bd0:	87aa                	mv	a5,a0
    return -1;
    80004bd2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bd4:	0007ca63          	bltz	a5,80004be8 <sys_write+0x40>
  return filewrite(f, p, n);
    80004bd8:	fe442603          	lw	a2,-28(s0)
    80004bdc:	fd843583          	ld	a1,-40(s0)
    80004be0:	fe843503          	ld	a0,-24(s0)
    80004be4:	dceff0ef          	jal	800041b2 <filewrite>
}
    80004be8:	70a2                	ld	ra,40(sp)
    80004bea:	7402                	ld	s0,32(sp)
    80004bec:	6145                	addi	sp,sp,48
    80004bee:	8082                	ret

0000000080004bf0 <sys_close>:
{
    80004bf0:	1101                	addi	sp,sp,-32
    80004bf2:	ec06                	sd	ra,24(sp)
    80004bf4:	e822                	sd	s0,16(sp)
    80004bf6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004bf8:	fe040613          	addi	a2,s0,-32
    80004bfc:	fec40593          	addi	a1,s0,-20
    80004c00:	4501                	li	a0,0
    80004c02:	d43ff0ef          	jal	80004944 <argfd>
    return -1;
    80004c06:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c08:	02054063          	bltz	a0,80004c28 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c0c:	cd5fc0ef          	jal	800018e0 <myproc>
    80004c10:	fec42783          	lw	a5,-20(s0)
    80004c14:	07e9                	addi	a5,a5,26
    80004c16:	078e                	slli	a5,a5,0x3
    80004c18:	953e                	add	a0,a0,a5
    80004c1a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c1e:	fe043503          	ld	a0,-32(s0)
    80004c22:	bb2ff0ef          	jal	80003fd4 <fileclose>
  return 0;
    80004c26:	4781                	li	a5,0
}
    80004c28:	853e                	mv	a0,a5
    80004c2a:	60e2                	ld	ra,24(sp)
    80004c2c:	6442                	ld	s0,16(sp)
    80004c2e:	6105                	addi	sp,sp,32
    80004c30:	8082                	ret

0000000080004c32 <sys_fstat>:
{
    80004c32:	1101                	addi	sp,sp,-32
    80004c34:	ec06                	sd	ra,24(sp)
    80004c36:	e822                	sd	s0,16(sp)
    80004c38:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c3a:	fe040593          	addi	a1,s0,-32
    80004c3e:	4505                	li	a0,1
    80004c40:	bb7fd0ef          	jal	800027f6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c44:	fe840613          	addi	a2,s0,-24
    80004c48:	4581                	li	a1,0
    80004c4a:	4501                	li	a0,0
    80004c4c:	cf9ff0ef          	jal	80004944 <argfd>
    80004c50:	87aa                	mv	a5,a0
    return -1;
    80004c52:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c54:	0007c863          	bltz	a5,80004c64 <sys_fstat+0x32>
  return filestat(f, st);
    80004c58:	fe043583          	ld	a1,-32(s0)
    80004c5c:	fe843503          	ld	a0,-24(s0)
    80004c60:	c36ff0ef          	jal	80004096 <filestat>
}
    80004c64:	60e2                	ld	ra,24(sp)
    80004c66:	6442                	ld	s0,16(sp)
    80004c68:	6105                	addi	sp,sp,32
    80004c6a:	8082                	ret

0000000080004c6c <sys_link>:
{
    80004c6c:	7169                	addi	sp,sp,-304
    80004c6e:	f606                	sd	ra,296(sp)
    80004c70:	f222                	sd	s0,288(sp)
    80004c72:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c74:	08000613          	li	a2,128
    80004c78:	ed040593          	addi	a1,s0,-304
    80004c7c:	4501                	li	a0,0
    80004c7e:	b95fd0ef          	jal	80002812 <argstr>
    return -1;
    80004c82:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c84:	0c054e63          	bltz	a0,80004d60 <sys_link+0xf4>
    80004c88:	08000613          	li	a2,128
    80004c8c:	f5040593          	addi	a1,s0,-176
    80004c90:	4505                	li	a0,1
    80004c92:	b81fd0ef          	jal	80002812 <argstr>
    return -1;
    80004c96:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c98:	0c054463          	bltz	a0,80004d60 <sys_link+0xf4>
    80004c9c:	ee26                	sd	s1,280(sp)
  begin_op();
    80004c9e:	f1dfe0ef          	jal	80003bba <begin_op>
  if((ip = namei(old)) == 0){
    80004ca2:	ed040513          	addi	a0,s0,-304
    80004ca6:	d59fe0ef          	jal	800039fe <namei>
    80004caa:	84aa                	mv	s1,a0
    80004cac:	c53d                	beqz	a0,80004d1a <sys_link+0xae>
  ilock(ip);
    80004cae:	e76fe0ef          	jal	80003324 <ilock>
  if(ip->type == T_DIR){
    80004cb2:	04449703          	lh	a4,68(s1)
    80004cb6:	4785                	li	a5,1
    80004cb8:	06f70663          	beq	a4,a5,80004d24 <sys_link+0xb8>
    80004cbc:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004cbe:	04a4d783          	lhu	a5,74(s1)
    80004cc2:	2785                	addiw	a5,a5,1
    80004cc4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	da6fe0ef          	jal	80003270 <iupdate>
  iunlock(ip);
    80004cce:	8526                	mv	a0,s1
    80004cd0:	f02fe0ef          	jal	800033d2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004cd4:	fd040593          	addi	a1,s0,-48
    80004cd8:	f5040513          	addi	a0,s0,-176
    80004cdc:	d3dfe0ef          	jal	80003a18 <nameiparent>
    80004ce0:	892a                	mv	s2,a0
    80004ce2:	cd21                	beqz	a0,80004d3a <sys_link+0xce>
  ilock(dp);
    80004ce4:	e40fe0ef          	jal	80003324 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ce8:	00092703          	lw	a4,0(s2)
    80004cec:	409c                	lw	a5,0(s1)
    80004cee:	04f71363          	bne	a4,a5,80004d34 <sys_link+0xc8>
    80004cf2:	40d0                	lw	a2,4(s1)
    80004cf4:	fd040593          	addi	a1,s0,-48
    80004cf8:	854a                	mv	a0,s2
    80004cfa:	c6bfe0ef          	jal	80003964 <dirlink>
    80004cfe:	02054b63          	bltz	a0,80004d34 <sys_link+0xc8>
  iunlockput(dp);
    80004d02:	854a                	mv	a0,s2
    80004d04:	82bfe0ef          	jal	8000352e <iunlockput>
  iput(ip);
    80004d08:	8526                	mv	a0,s1
    80004d0a:	f9cfe0ef          	jal	800034a6 <iput>
  end_op();
    80004d0e:	f17fe0ef          	jal	80003c24 <end_op>
  return 0;
    80004d12:	4781                	li	a5,0
    80004d14:	64f2                	ld	s1,280(sp)
    80004d16:	6952                	ld	s2,272(sp)
    80004d18:	a0a1                	j	80004d60 <sys_link+0xf4>
    end_op();
    80004d1a:	f0bfe0ef          	jal	80003c24 <end_op>
    return -1;
    80004d1e:	57fd                	li	a5,-1
    80004d20:	64f2                	ld	s1,280(sp)
    80004d22:	a83d                	j	80004d60 <sys_link+0xf4>
    iunlockput(ip);
    80004d24:	8526                	mv	a0,s1
    80004d26:	809fe0ef          	jal	8000352e <iunlockput>
    end_op();
    80004d2a:	efbfe0ef          	jal	80003c24 <end_op>
    return -1;
    80004d2e:	57fd                	li	a5,-1
    80004d30:	64f2                	ld	s1,280(sp)
    80004d32:	a03d                	j	80004d60 <sys_link+0xf4>
    iunlockput(dp);
    80004d34:	854a                	mv	a0,s2
    80004d36:	ff8fe0ef          	jal	8000352e <iunlockput>
  ilock(ip);
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	de8fe0ef          	jal	80003324 <ilock>
  ip->nlink--;
    80004d40:	04a4d783          	lhu	a5,74(s1)
    80004d44:	37fd                	addiw	a5,a5,-1
    80004d46:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	d24fe0ef          	jal	80003270 <iupdate>
  iunlockput(ip);
    80004d50:	8526                	mv	a0,s1
    80004d52:	fdcfe0ef          	jal	8000352e <iunlockput>
  end_op();
    80004d56:	ecffe0ef          	jal	80003c24 <end_op>
  return -1;
    80004d5a:	57fd                	li	a5,-1
    80004d5c:	64f2                	ld	s1,280(sp)
    80004d5e:	6952                	ld	s2,272(sp)
}
    80004d60:	853e                	mv	a0,a5
    80004d62:	70b2                	ld	ra,296(sp)
    80004d64:	7412                	ld	s0,288(sp)
    80004d66:	6155                	addi	sp,sp,304
    80004d68:	8082                	ret

0000000080004d6a <sys_unlink>:
{
    80004d6a:	7151                	addi	sp,sp,-240
    80004d6c:	f586                	sd	ra,232(sp)
    80004d6e:	f1a2                	sd	s0,224(sp)
    80004d70:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004d72:	08000613          	li	a2,128
    80004d76:	f3040593          	addi	a1,s0,-208
    80004d7a:	4501                	li	a0,0
    80004d7c:	a97fd0ef          	jal	80002812 <argstr>
    80004d80:	16054063          	bltz	a0,80004ee0 <sys_unlink+0x176>
    80004d84:	eda6                	sd	s1,216(sp)
  begin_op();
    80004d86:	e35fe0ef          	jal	80003bba <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004d8a:	fb040593          	addi	a1,s0,-80
    80004d8e:	f3040513          	addi	a0,s0,-208
    80004d92:	c87fe0ef          	jal	80003a18 <nameiparent>
    80004d96:	84aa                	mv	s1,a0
    80004d98:	c945                	beqz	a0,80004e48 <sys_unlink+0xde>
  ilock(dp);
    80004d9a:	d8afe0ef          	jal	80003324 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004d9e:	00003597          	auipc	a1,0x3
    80004da2:	8b258593          	addi	a1,a1,-1870 # 80007650 <etext+0x650>
    80004da6:	fb040513          	addi	a0,s0,-80
    80004daa:	9d9fe0ef          	jal	80003782 <namecmp>
    80004dae:	10050e63          	beqz	a0,80004eca <sys_unlink+0x160>
    80004db2:	00003597          	auipc	a1,0x3
    80004db6:	8a658593          	addi	a1,a1,-1882 # 80007658 <etext+0x658>
    80004dba:	fb040513          	addi	a0,s0,-80
    80004dbe:	9c5fe0ef          	jal	80003782 <namecmp>
    80004dc2:	10050463          	beqz	a0,80004eca <sys_unlink+0x160>
    80004dc6:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004dc8:	f2c40613          	addi	a2,s0,-212
    80004dcc:	fb040593          	addi	a1,s0,-80
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	9c7fe0ef          	jal	80003798 <dirlookup>
    80004dd6:	892a                	mv	s2,a0
    80004dd8:	0e050863          	beqz	a0,80004ec8 <sys_unlink+0x15e>
  ilock(ip);
    80004ddc:	d48fe0ef          	jal	80003324 <ilock>
  if(ip->nlink < 1)
    80004de0:	04a91783          	lh	a5,74(s2)
    80004de4:	06f05763          	blez	a5,80004e52 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004de8:	04491703          	lh	a4,68(s2)
    80004dec:	4785                	li	a5,1
    80004dee:	06f70963          	beq	a4,a5,80004e60 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004df2:	4641                	li	a2,16
    80004df4:	4581                	li	a1,0
    80004df6:	fc040513          	addi	a0,s0,-64
    80004dfa:	ecffb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004dfe:	4741                	li	a4,16
    80004e00:	f2c42683          	lw	a3,-212(s0)
    80004e04:	fc040613          	addi	a2,s0,-64
    80004e08:	4581                	li	a1,0
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	869fe0ef          	jal	80003674 <writei>
    80004e10:	47c1                	li	a5,16
    80004e12:	08f51b63          	bne	a0,a5,80004ea8 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004e16:	04491703          	lh	a4,68(s2)
    80004e1a:	4785                	li	a5,1
    80004e1c:	08f70d63          	beq	a4,a5,80004eb6 <sys_unlink+0x14c>
  iunlockput(dp);
    80004e20:	8526                	mv	a0,s1
    80004e22:	f0cfe0ef          	jal	8000352e <iunlockput>
  ip->nlink--;
    80004e26:	04a95783          	lhu	a5,74(s2)
    80004e2a:	37fd                	addiw	a5,a5,-1
    80004e2c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e30:	854a                	mv	a0,s2
    80004e32:	c3efe0ef          	jal	80003270 <iupdate>
  iunlockput(ip);
    80004e36:	854a                	mv	a0,s2
    80004e38:	ef6fe0ef          	jal	8000352e <iunlockput>
  end_op();
    80004e3c:	de9fe0ef          	jal	80003c24 <end_op>
  return 0;
    80004e40:	4501                	li	a0,0
    80004e42:	64ee                	ld	s1,216(sp)
    80004e44:	694e                	ld	s2,208(sp)
    80004e46:	a849                	j	80004ed8 <sys_unlink+0x16e>
    end_op();
    80004e48:	dddfe0ef          	jal	80003c24 <end_op>
    return -1;
    80004e4c:	557d                	li	a0,-1
    80004e4e:	64ee                	ld	s1,216(sp)
    80004e50:	a061                	j	80004ed8 <sys_unlink+0x16e>
    80004e52:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004e54:	00003517          	auipc	a0,0x3
    80004e58:	80c50513          	addi	a0,a0,-2036 # 80007660 <etext+0x660>
    80004e5c:	939fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e60:	04c92703          	lw	a4,76(s2)
    80004e64:	02000793          	li	a5,32
    80004e68:	f8e7f5e3          	bgeu	a5,a4,80004df2 <sys_unlink+0x88>
    80004e6c:	e5ce                	sd	s3,200(sp)
    80004e6e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e72:	4741                	li	a4,16
    80004e74:	86ce                	mv	a3,s3
    80004e76:	f1840613          	addi	a2,s0,-232
    80004e7a:	4581                	li	a1,0
    80004e7c:	854a                	mv	a0,s2
    80004e7e:	efafe0ef          	jal	80003578 <readi>
    80004e82:	47c1                	li	a5,16
    80004e84:	00f51c63          	bne	a0,a5,80004e9c <sys_unlink+0x132>
    if(de.inum != 0)
    80004e88:	f1845783          	lhu	a5,-232(s0)
    80004e8c:	efa1                	bnez	a5,80004ee4 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e8e:	29c1                	addiw	s3,s3,16
    80004e90:	04c92783          	lw	a5,76(s2)
    80004e94:	fcf9efe3          	bltu	s3,a5,80004e72 <sys_unlink+0x108>
    80004e98:	69ae                	ld	s3,200(sp)
    80004e9a:	bfa1                	j	80004df2 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004e9c:	00002517          	auipc	a0,0x2
    80004ea0:	7dc50513          	addi	a0,a0,2012 # 80007678 <etext+0x678>
    80004ea4:	8f1fb0ef          	jal	80000794 <panic>
    80004ea8:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004eaa:	00002517          	auipc	a0,0x2
    80004eae:	7e650513          	addi	a0,a0,2022 # 80007690 <etext+0x690>
    80004eb2:	8e3fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004eb6:	04a4d783          	lhu	a5,74(s1)
    80004eba:	37fd                	addiw	a5,a5,-1
    80004ebc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ec0:	8526                	mv	a0,s1
    80004ec2:	baefe0ef          	jal	80003270 <iupdate>
    80004ec6:	bfa9                	j	80004e20 <sys_unlink+0xb6>
    80004ec8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004eca:	8526                	mv	a0,s1
    80004ecc:	e62fe0ef          	jal	8000352e <iunlockput>
  end_op();
    80004ed0:	d55fe0ef          	jal	80003c24 <end_op>
  return -1;
    80004ed4:	557d                	li	a0,-1
    80004ed6:	64ee                	ld	s1,216(sp)
}
    80004ed8:	70ae                	ld	ra,232(sp)
    80004eda:	740e                	ld	s0,224(sp)
    80004edc:	616d                	addi	sp,sp,240
    80004ede:	8082                	ret
    return -1;
    80004ee0:	557d                	li	a0,-1
    80004ee2:	bfdd                	j	80004ed8 <sys_unlink+0x16e>
    iunlockput(ip);
    80004ee4:	854a                	mv	a0,s2
    80004ee6:	e48fe0ef          	jal	8000352e <iunlockput>
    goto bad;
    80004eea:	694e                	ld	s2,208(sp)
    80004eec:	69ae                	ld	s3,200(sp)
    80004eee:	bff1                	j	80004eca <sys_unlink+0x160>

0000000080004ef0 <sys_open>:

uint64
sys_open(void)
{
    80004ef0:	7131                	addi	sp,sp,-192
    80004ef2:	fd06                	sd	ra,184(sp)
    80004ef4:	f922                	sd	s0,176(sp)
    80004ef6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004ef8:	f4c40593          	addi	a1,s0,-180
    80004efc:	4505                	li	a0,1
    80004efe:	8ddfd0ef          	jal	800027da <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f02:	08000613          	li	a2,128
    80004f06:	f5040593          	addi	a1,s0,-176
    80004f0a:	4501                	li	a0,0
    80004f0c:	907fd0ef          	jal	80002812 <argstr>
    80004f10:	87aa                	mv	a5,a0
    return -1;
    80004f12:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f14:	0a07c263          	bltz	a5,80004fb8 <sys_open+0xc8>
    80004f18:	f526                	sd	s1,168(sp)

  begin_op();
    80004f1a:	ca1fe0ef          	jal	80003bba <begin_op>

  if(omode & O_CREATE){
    80004f1e:	f4c42783          	lw	a5,-180(s0)
    80004f22:	2007f793          	andi	a5,a5,512
    80004f26:	c3d5                	beqz	a5,80004fca <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004f28:	4681                	li	a3,0
    80004f2a:	4601                	li	a2,0
    80004f2c:	4589                	li	a1,2
    80004f2e:	f5040513          	addi	a0,s0,-176
    80004f32:	aa9ff0ef          	jal	800049da <create>
    80004f36:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f38:	c541                	beqz	a0,80004fc0 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f3a:	04449703          	lh	a4,68(s1)
    80004f3e:	478d                	li	a5,3
    80004f40:	00f71763          	bne	a4,a5,80004f4e <sys_open+0x5e>
    80004f44:	0464d703          	lhu	a4,70(s1)
    80004f48:	47a5                	li	a5,9
    80004f4a:	0ae7ed63          	bltu	a5,a4,80005004 <sys_open+0x114>
    80004f4e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f50:	fe1fe0ef          	jal	80003f30 <filealloc>
    80004f54:	892a                	mv	s2,a0
    80004f56:	c179                	beqz	a0,8000501c <sys_open+0x12c>
    80004f58:	ed4e                	sd	s3,152(sp)
    80004f5a:	a43ff0ef          	jal	8000499c <fdalloc>
    80004f5e:	89aa                	mv	s3,a0
    80004f60:	0a054a63          	bltz	a0,80005014 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f64:	04449703          	lh	a4,68(s1)
    80004f68:	478d                	li	a5,3
    80004f6a:	0cf70263          	beq	a4,a5,8000502e <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004f6e:	4789                	li	a5,2
    80004f70:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004f74:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004f78:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004f7c:	f4c42783          	lw	a5,-180(s0)
    80004f80:	0017c713          	xori	a4,a5,1
    80004f84:	8b05                	andi	a4,a4,1
    80004f86:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004f8a:	0037f713          	andi	a4,a5,3
    80004f8e:	00e03733          	snez	a4,a4
    80004f92:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f96:	4007f793          	andi	a5,a5,1024
    80004f9a:	c791                	beqz	a5,80004fa6 <sys_open+0xb6>
    80004f9c:	04449703          	lh	a4,68(s1)
    80004fa0:	4789                	li	a5,2
    80004fa2:	08f70d63          	beq	a4,a5,8000503c <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004fa6:	8526                	mv	a0,s1
    80004fa8:	c2afe0ef          	jal	800033d2 <iunlock>
  end_op();
    80004fac:	c79fe0ef          	jal	80003c24 <end_op>

  return fd;
    80004fb0:	854e                	mv	a0,s3
    80004fb2:	74aa                	ld	s1,168(sp)
    80004fb4:	790a                	ld	s2,160(sp)
    80004fb6:	69ea                	ld	s3,152(sp)
}
    80004fb8:	70ea                	ld	ra,184(sp)
    80004fba:	744a                	ld	s0,176(sp)
    80004fbc:	6129                	addi	sp,sp,192
    80004fbe:	8082                	ret
      end_op();
    80004fc0:	c65fe0ef          	jal	80003c24 <end_op>
      return -1;
    80004fc4:	557d                	li	a0,-1
    80004fc6:	74aa                	ld	s1,168(sp)
    80004fc8:	bfc5                	j	80004fb8 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004fca:	f5040513          	addi	a0,s0,-176
    80004fce:	a31fe0ef          	jal	800039fe <namei>
    80004fd2:	84aa                	mv	s1,a0
    80004fd4:	c11d                	beqz	a0,80004ffa <sys_open+0x10a>
    ilock(ip);
    80004fd6:	b4efe0ef          	jal	80003324 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004fda:	04449703          	lh	a4,68(s1)
    80004fde:	4785                	li	a5,1
    80004fe0:	f4f71de3          	bne	a4,a5,80004f3a <sys_open+0x4a>
    80004fe4:	f4c42783          	lw	a5,-180(s0)
    80004fe8:	d3bd                	beqz	a5,80004f4e <sys_open+0x5e>
      iunlockput(ip);
    80004fea:	8526                	mv	a0,s1
    80004fec:	d42fe0ef          	jal	8000352e <iunlockput>
      end_op();
    80004ff0:	c35fe0ef          	jal	80003c24 <end_op>
      return -1;
    80004ff4:	557d                	li	a0,-1
    80004ff6:	74aa                	ld	s1,168(sp)
    80004ff8:	b7c1                	j	80004fb8 <sys_open+0xc8>
      end_op();
    80004ffa:	c2bfe0ef          	jal	80003c24 <end_op>
      return -1;
    80004ffe:	557d                	li	a0,-1
    80005000:	74aa                	ld	s1,168(sp)
    80005002:	bf5d                	j	80004fb8 <sys_open+0xc8>
    iunlockput(ip);
    80005004:	8526                	mv	a0,s1
    80005006:	d28fe0ef          	jal	8000352e <iunlockput>
    end_op();
    8000500a:	c1bfe0ef          	jal	80003c24 <end_op>
    return -1;
    8000500e:	557d                	li	a0,-1
    80005010:	74aa                	ld	s1,168(sp)
    80005012:	b75d                	j	80004fb8 <sys_open+0xc8>
      fileclose(f);
    80005014:	854a                	mv	a0,s2
    80005016:	fbffe0ef          	jal	80003fd4 <fileclose>
    8000501a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000501c:	8526                	mv	a0,s1
    8000501e:	d10fe0ef          	jal	8000352e <iunlockput>
    end_op();
    80005022:	c03fe0ef          	jal	80003c24 <end_op>
    return -1;
    80005026:	557d                	li	a0,-1
    80005028:	74aa                	ld	s1,168(sp)
    8000502a:	790a                	ld	s2,160(sp)
    8000502c:	b771                	j	80004fb8 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000502e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005032:	04649783          	lh	a5,70(s1)
    80005036:	02f91223          	sh	a5,36(s2)
    8000503a:	bf3d                	j	80004f78 <sys_open+0x88>
    itrunc(ip);
    8000503c:	8526                	mv	a0,s1
    8000503e:	bd4fe0ef          	jal	80003412 <itrunc>
    80005042:	b795                	j	80004fa6 <sys_open+0xb6>

0000000080005044 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005044:	7175                	addi	sp,sp,-144
    80005046:	e506                	sd	ra,136(sp)
    80005048:	e122                	sd	s0,128(sp)
    8000504a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000504c:	b6ffe0ef          	jal	80003bba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005050:	08000613          	li	a2,128
    80005054:	f7040593          	addi	a1,s0,-144
    80005058:	4501                	li	a0,0
    8000505a:	fb8fd0ef          	jal	80002812 <argstr>
    8000505e:	02054363          	bltz	a0,80005084 <sys_mkdir+0x40>
    80005062:	4681                	li	a3,0
    80005064:	4601                	li	a2,0
    80005066:	4585                	li	a1,1
    80005068:	f7040513          	addi	a0,s0,-144
    8000506c:	96fff0ef          	jal	800049da <create>
    80005070:	c911                	beqz	a0,80005084 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005072:	cbcfe0ef          	jal	8000352e <iunlockput>
  end_op();
    80005076:	baffe0ef          	jal	80003c24 <end_op>
  return 0;
    8000507a:	4501                	li	a0,0
}
    8000507c:	60aa                	ld	ra,136(sp)
    8000507e:	640a                	ld	s0,128(sp)
    80005080:	6149                	addi	sp,sp,144
    80005082:	8082                	ret
    end_op();
    80005084:	ba1fe0ef          	jal	80003c24 <end_op>
    return -1;
    80005088:	557d                	li	a0,-1
    8000508a:	bfcd                	j	8000507c <sys_mkdir+0x38>

000000008000508c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000508c:	7135                	addi	sp,sp,-160
    8000508e:	ed06                	sd	ra,152(sp)
    80005090:	e922                	sd	s0,144(sp)
    80005092:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005094:	b27fe0ef          	jal	80003bba <begin_op>
  argint(1, &major);
    80005098:	f6c40593          	addi	a1,s0,-148
    8000509c:	4505                	li	a0,1
    8000509e:	f3cfd0ef          	jal	800027da <argint>
  argint(2, &minor);
    800050a2:	f6840593          	addi	a1,s0,-152
    800050a6:	4509                	li	a0,2
    800050a8:	f32fd0ef          	jal	800027da <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050ac:	08000613          	li	a2,128
    800050b0:	f7040593          	addi	a1,s0,-144
    800050b4:	4501                	li	a0,0
    800050b6:	f5cfd0ef          	jal	80002812 <argstr>
    800050ba:	02054563          	bltz	a0,800050e4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050be:	f6841683          	lh	a3,-152(s0)
    800050c2:	f6c41603          	lh	a2,-148(s0)
    800050c6:	458d                	li	a1,3
    800050c8:	f7040513          	addi	a0,s0,-144
    800050cc:	90fff0ef          	jal	800049da <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050d0:	c911                	beqz	a0,800050e4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050d2:	c5cfe0ef          	jal	8000352e <iunlockput>
  end_op();
    800050d6:	b4ffe0ef          	jal	80003c24 <end_op>
  return 0;
    800050da:	4501                	li	a0,0
}
    800050dc:	60ea                	ld	ra,152(sp)
    800050de:	644a                	ld	s0,144(sp)
    800050e0:	610d                	addi	sp,sp,160
    800050e2:	8082                	ret
    end_op();
    800050e4:	b41fe0ef          	jal	80003c24 <end_op>
    return -1;
    800050e8:	557d                	li	a0,-1
    800050ea:	bfcd                	j	800050dc <sys_mknod+0x50>

00000000800050ec <sys_chdir>:

uint64
sys_chdir(void)
{
    800050ec:	7135                	addi	sp,sp,-160
    800050ee:	ed06                	sd	ra,152(sp)
    800050f0:	e922                	sd	s0,144(sp)
    800050f2:	e14a                	sd	s2,128(sp)
    800050f4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800050f6:	feafc0ef          	jal	800018e0 <myproc>
    800050fa:	892a                	mv	s2,a0
  
  begin_op();
    800050fc:	abffe0ef          	jal	80003bba <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005100:	08000613          	li	a2,128
    80005104:	f6040593          	addi	a1,s0,-160
    80005108:	4501                	li	a0,0
    8000510a:	f08fd0ef          	jal	80002812 <argstr>
    8000510e:	04054363          	bltz	a0,80005154 <sys_chdir+0x68>
    80005112:	e526                	sd	s1,136(sp)
    80005114:	f6040513          	addi	a0,s0,-160
    80005118:	8e7fe0ef          	jal	800039fe <namei>
    8000511c:	84aa                	mv	s1,a0
    8000511e:	c915                	beqz	a0,80005152 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005120:	a04fe0ef          	jal	80003324 <ilock>
  if(ip->type != T_DIR){
    80005124:	04449703          	lh	a4,68(s1)
    80005128:	4785                	li	a5,1
    8000512a:	02f71963          	bne	a4,a5,8000515c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000512e:	8526                	mv	a0,s1
    80005130:	aa2fe0ef          	jal	800033d2 <iunlock>
  iput(p->cwd);
    80005134:	15093503          	ld	a0,336(s2)
    80005138:	b6efe0ef          	jal	800034a6 <iput>
  end_op();
    8000513c:	ae9fe0ef          	jal	80003c24 <end_op>
  p->cwd = ip;
    80005140:	14993823          	sd	s1,336(s2)
  return 0;
    80005144:	4501                	li	a0,0
    80005146:	64aa                	ld	s1,136(sp)
}
    80005148:	60ea                	ld	ra,152(sp)
    8000514a:	644a                	ld	s0,144(sp)
    8000514c:	690a                	ld	s2,128(sp)
    8000514e:	610d                	addi	sp,sp,160
    80005150:	8082                	ret
    80005152:	64aa                	ld	s1,136(sp)
    end_op();
    80005154:	ad1fe0ef          	jal	80003c24 <end_op>
    return -1;
    80005158:	557d                	li	a0,-1
    8000515a:	b7fd                	j	80005148 <sys_chdir+0x5c>
    iunlockput(ip);
    8000515c:	8526                	mv	a0,s1
    8000515e:	bd0fe0ef          	jal	8000352e <iunlockput>
    end_op();
    80005162:	ac3fe0ef          	jal	80003c24 <end_op>
    return -1;
    80005166:	557d                	li	a0,-1
    80005168:	64aa                	ld	s1,136(sp)
    8000516a:	bff9                	j	80005148 <sys_chdir+0x5c>

000000008000516c <sys_exec>:

uint64
sys_exec(void)
{
    8000516c:	7121                	addi	sp,sp,-448
    8000516e:	ff06                	sd	ra,440(sp)
    80005170:	fb22                	sd	s0,432(sp)
    80005172:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005174:	e4840593          	addi	a1,s0,-440
    80005178:	4505                	li	a0,1
    8000517a:	e7cfd0ef          	jal	800027f6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000517e:	08000613          	li	a2,128
    80005182:	f5040593          	addi	a1,s0,-176
    80005186:	4501                	li	a0,0
    80005188:	e8afd0ef          	jal	80002812 <argstr>
    8000518c:	87aa                	mv	a5,a0
    return -1;
    8000518e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005190:	0c07c463          	bltz	a5,80005258 <sys_exec+0xec>
    80005194:	f726                	sd	s1,424(sp)
    80005196:	f34a                	sd	s2,416(sp)
    80005198:	ef4e                	sd	s3,408(sp)
    8000519a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000519c:	10000613          	li	a2,256
    800051a0:	4581                	li	a1,0
    800051a2:	e5040513          	addi	a0,s0,-432
    800051a6:	b23fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051aa:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800051ae:	89a6                	mv	s3,s1
    800051b0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800051b2:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051b6:	00391513          	slli	a0,s2,0x3
    800051ba:	e4040593          	addi	a1,s0,-448
    800051be:	e4843783          	ld	a5,-440(s0)
    800051c2:	953e                	add	a0,a0,a5
    800051c4:	d8cfd0ef          	jal	80002750 <fetchaddr>
    800051c8:	02054663          	bltz	a0,800051f4 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800051cc:	e4043783          	ld	a5,-448(s0)
    800051d0:	c3a9                	beqz	a5,80005212 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800051d2:	953fb0ef          	jal	80000b24 <kalloc>
    800051d6:	85aa                	mv	a1,a0
    800051d8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800051dc:	cd01                	beqz	a0,800051f4 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051de:	6605                	lui	a2,0x1
    800051e0:	e4043503          	ld	a0,-448(s0)
    800051e4:	db6fd0ef          	jal	8000279a <fetchstr>
    800051e8:	00054663          	bltz	a0,800051f4 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800051ec:	0905                	addi	s2,s2,1
    800051ee:	09a1                	addi	s3,s3,8
    800051f0:	fd4913e3          	bne	s2,s4,800051b6 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051f4:	f5040913          	addi	s2,s0,-176
    800051f8:	6088                	ld	a0,0(s1)
    800051fa:	c931                	beqz	a0,8000524e <sys_exec+0xe2>
    kfree(argv[i]);
    800051fc:	847fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005200:	04a1                	addi	s1,s1,8
    80005202:	ff249be3          	bne	s1,s2,800051f8 <sys_exec+0x8c>
  return -1;
    80005206:	557d                	li	a0,-1
    80005208:	74ba                	ld	s1,424(sp)
    8000520a:	791a                	ld	s2,416(sp)
    8000520c:	69fa                	ld	s3,408(sp)
    8000520e:	6a5a                	ld	s4,400(sp)
    80005210:	a0a1                	j	80005258 <sys_exec+0xec>
      argv[i] = 0;
    80005212:	0009079b          	sext.w	a5,s2
    80005216:	078e                	slli	a5,a5,0x3
    80005218:	fd078793          	addi	a5,a5,-48
    8000521c:	97a2                	add	a5,a5,s0
    8000521e:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005222:	e5040593          	addi	a1,s0,-432
    80005226:	f5040513          	addi	a0,s0,-176
    8000522a:	ba8ff0ef          	jal	800045d2 <exec>
    8000522e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005230:	f5040993          	addi	s3,s0,-176
    80005234:	6088                	ld	a0,0(s1)
    80005236:	c511                	beqz	a0,80005242 <sys_exec+0xd6>
    kfree(argv[i]);
    80005238:	80bfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000523c:	04a1                	addi	s1,s1,8
    8000523e:	ff349be3          	bne	s1,s3,80005234 <sys_exec+0xc8>
  return ret;
    80005242:	854a                	mv	a0,s2
    80005244:	74ba                	ld	s1,424(sp)
    80005246:	791a                	ld	s2,416(sp)
    80005248:	69fa                	ld	s3,408(sp)
    8000524a:	6a5a                	ld	s4,400(sp)
    8000524c:	a031                	j	80005258 <sys_exec+0xec>
  return -1;
    8000524e:	557d                	li	a0,-1
    80005250:	74ba                	ld	s1,424(sp)
    80005252:	791a                	ld	s2,416(sp)
    80005254:	69fa                	ld	s3,408(sp)
    80005256:	6a5a                	ld	s4,400(sp)
}
    80005258:	70fa                	ld	ra,440(sp)
    8000525a:	745a                	ld	s0,432(sp)
    8000525c:	6139                	addi	sp,sp,448
    8000525e:	8082                	ret

0000000080005260 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005260:	7139                	addi	sp,sp,-64
    80005262:	fc06                	sd	ra,56(sp)
    80005264:	f822                	sd	s0,48(sp)
    80005266:	f426                	sd	s1,40(sp)
    80005268:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000526a:	e76fc0ef          	jal	800018e0 <myproc>
    8000526e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005270:	fd840593          	addi	a1,s0,-40
    80005274:	4501                	li	a0,0
    80005276:	d80fd0ef          	jal	800027f6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000527a:	fc840593          	addi	a1,s0,-56
    8000527e:	fd040513          	addi	a0,s0,-48
    80005282:	85cff0ef          	jal	800042de <pipealloc>
    return -1;
    80005286:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005288:	0a054463          	bltz	a0,80005330 <sys_pipe+0xd0>
  fd0 = -1;
    8000528c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005290:	fd043503          	ld	a0,-48(s0)
    80005294:	f08ff0ef          	jal	8000499c <fdalloc>
    80005298:	fca42223          	sw	a0,-60(s0)
    8000529c:	08054163          	bltz	a0,8000531e <sys_pipe+0xbe>
    800052a0:	fc843503          	ld	a0,-56(s0)
    800052a4:	ef8ff0ef          	jal	8000499c <fdalloc>
    800052a8:	fca42023          	sw	a0,-64(s0)
    800052ac:	06054063          	bltz	a0,8000530c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052b0:	4691                	li	a3,4
    800052b2:	fc440613          	addi	a2,s0,-60
    800052b6:	fd843583          	ld	a1,-40(s0)
    800052ba:	68a8                	ld	a0,80(s1)
    800052bc:	a96fc0ef          	jal	80001552 <copyout>
    800052c0:	00054e63          	bltz	a0,800052dc <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052c4:	4691                	li	a3,4
    800052c6:	fc040613          	addi	a2,s0,-64
    800052ca:	fd843583          	ld	a1,-40(s0)
    800052ce:	0591                	addi	a1,a1,4
    800052d0:	68a8                	ld	a0,80(s1)
    800052d2:	a80fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800052d6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052d8:	04055c63          	bgez	a0,80005330 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800052dc:	fc442783          	lw	a5,-60(s0)
    800052e0:	07e9                	addi	a5,a5,26
    800052e2:	078e                	slli	a5,a5,0x3
    800052e4:	97a6                	add	a5,a5,s1
    800052e6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800052ea:	fc042783          	lw	a5,-64(s0)
    800052ee:	07e9                	addi	a5,a5,26
    800052f0:	078e                	slli	a5,a5,0x3
    800052f2:	94be                	add	s1,s1,a5
    800052f4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800052f8:	fd043503          	ld	a0,-48(s0)
    800052fc:	cd9fe0ef          	jal	80003fd4 <fileclose>
    fileclose(wf);
    80005300:	fc843503          	ld	a0,-56(s0)
    80005304:	cd1fe0ef          	jal	80003fd4 <fileclose>
    return -1;
    80005308:	57fd                	li	a5,-1
    8000530a:	a01d                	j	80005330 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000530c:	fc442783          	lw	a5,-60(s0)
    80005310:	0007c763          	bltz	a5,8000531e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005314:	07e9                	addi	a5,a5,26
    80005316:	078e                	slli	a5,a5,0x3
    80005318:	97a6                	add	a5,a5,s1
    8000531a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000531e:	fd043503          	ld	a0,-48(s0)
    80005322:	cb3fe0ef          	jal	80003fd4 <fileclose>
    fileclose(wf);
    80005326:	fc843503          	ld	a0,-56(s0)
    8000532a:	cabfe0ef          	jal	80003fd4 <fileclose>
    return -1;
    8000532e:	57fd                	li	a5,-1
}
    80005330:	853e                	mv	a0,a5
    80005332:	70e2                	ld	ra,56(sp)
    80005334:	7442                	ld	s0,48(sp)
    80005336:	74a2                	ld	s1,40(sp)
    80005338:	6121                	addi	sp,sp,64
    8000533a:	8082                	ret
    8000533c:	0000                	unimp
	...

0000000080005340 <kernelvec>:
    80005340:	7111                	addi	sp,sp,-256
    80005342:	e006                	sd	ra,0(sp)
    80005344:	e40a                	sd	sp,8(sp)
    80005346:	e80e                	sd	gp,16(sp)
    80005348:	ec12                	sd	tp,24(sp)
    8000534a:	f016                	sd	t0,32(sp)
    8000534c:	f41a                	sd	t1,40(sp)
    8000534e:	f81e                	sd	t2,48(sp)
    80005350:	e4aa                	sd	a0,72(sp)
    80005352:	e8ae                	sd	a1,80(sp)
    80005354:	ecb2                	sd	a2,88(sp)
    80005356:	f0b6                	sd	a3,96(sp)
    80005358:	f4ba                	sd	a4,104(sp)
    8000535a:	f8be                	sd	a5,112(sp)
    8000535c:	fcc2                	sd	a6,120(sp)
    8000535e:	e146                	sd	a7,128(sp)
    80005360:	edf2                	sd	t3,216(sp)
    80005362:	f1f6                	sd	t4,224(sp)
    80005364:	f5fa                	sd	t5,232(sp)
    80005366:	f9fe                	sd	t6,240(sp)
    80005368:	af8fd0ef          	jal	80002660 <kerneltrap>
    8000536c:	6082                	ld	ra,0(sp)
    8000536e:	6122                	ld	sp,8(sp)
    80005370:	61c2                	ld	gp,16(sp)
    80005372:	7282                	ld	t0,32(sp)
    80005374:	7322                	ld	t1,40(sp)
    80005376:	73c2                	ld	t2,48(sp)
    80005378:	6526                	ld	a0,72(sp)
    8000537a:	65c6                	ld	a1,80(sp)
    8000537c:	6666                	ld	a2,88(sp)
    8000537e:	7686                	ld	a3,96(sp)
    80005380:	7726                	ld	a4,104(sp)
    80005382:	77c6                	ld	a5,112(sp)
    80005384:	7866                	ld	a6,120(sp)
    80005386:	688a                	ld	a7,128(sp)
    80005388:	6e6e                	ld	t3,216(sp)
    8000538a:	7e8e                	ld	t4,224(sp)
    8000538c:	7f2e                	ld	t5,232(sp)
    8000538e:	7fce                	ld	t6,240(sp)
    80005390:	6111                	addi	sp,sp,256
    80005392:	10200073          	sret
	...

000000008000539e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000539e:	1141                	addi	sp,sp,-16
    800053a0:	e422                	sd	s0,8(sp)
    800053a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053a4:	0c0007b7          	lui	a5,0xc000
    800053a8:	4705                	li	a4,1
    800053aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053ac:	0c0007b7          	lui	a5,0xc000
    800053b0:	c3d8                	sw	a4,4(a5)
}
    800053b2:	6422                	ld	s0,8(sp)
    800053b4:	0141                	addi	sp,sp,16
    800053b6:	8082                	ret

00000000800053b8 <plicinithart>:

void
plicinithart(void)
{
    800053b8:	1141                	addi	sp,sp,-16
    800053ba:	e406                	sd	ra,8(sp)
    800053bc:	e022                	sd	s0,0(sp)
    800053be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053c0:	cf4fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800053c4:	0085171b          	slliw	a4,a0,0x8
    800053c8:	0c0027b7          	lui	a5,0xc002
    800053cc:	97ba                	add	a5,a5,a4
    800053ce:	40200713          	li	a4,1026
    800053d2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800053d6:	00d5151b          	slliw	a0,a0,0xd
    800053da:	0c2017b7          	lui	a5,0xc201
    800053de:	97aa                	add	a5,a5,a0
    800053e0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800053e4:	60a2                	ld	ra,8(sp)
    800053e6:	6402                	ld	s0,0(sp)
    800053e8:	0141                	addi	sp,sp,16
    800053ea:	8082                	ret

00000000800053ec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800053ec:	1141                	addi	sp,sp,-16
    800053ee:	e406                	sd	ra,8(sp)
    800053f0:	e022                	sd	s0,0(sp)
    800053f2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800053f4:	cc0fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800053f8:	00d5151b          	slliw	a0,a0,0xd
    800053fc:	0c2017b7          	lui	a5,0xc201
    80005400:	97aa                	add	a5,a5,a0
  return irq;
}
    80005402:	43c8                	lw	a0,4(a5)
    80005404:	60a2                	ld	ra,8(sp)
    80005406:	6402                	ld	s0,0(sp)
    80005408:	0141                	addi	sp,sp,16
    8000540a:	8082                	ret

000000008000540c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000540c:	1101                	addi	sp,sp,-32
    8000540e:	ec06                	sd	ra,24(sp)
    80005410:	e822                	sd	s0,16(sp)
    80005412:	e426                	sd	s1,8(sp)
    80005414:	1000                	addi	s0,sp,32
    80005416:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005418:	c9cfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000541c:	00d5151b          	slliw	a0,a0,0xd
    80005420:	0c2017b7          	lui	a5,0xc201
    80005424:	97aa                	add	a5,a5,a0
    80005426:	c3c4                	sw	s1,4(a5)
}
    80005428:	60e2                	ld	ra,24(sp)
    8000542a:	6442                	ld	s0,16(sp)
    8000542c:	64a2                	ld	s1,8(sp)
    8000542e:	6105                	addi	sp,sp,32
    80005430:	8082                	ret

0000000080005432 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005432:	1141                	addi	sp,sp,-16
    80005434:	e406                	sd	ra,8(sp)
    80005436:	e022                	sd	s0,0(sp)
    80005438:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000543a:	479d                	li	a5,7
    8000543c:	04a7ca63          	blt	a5,a0,80005490 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005440:	0001b797          	auipc	a5,0x1b
    80005444:	70078793          	addi	a5,a5,1792 # 80020b40 <disk>
    80005448:	97aa                	add	a5,a5,a0
    8000544a:	0187c783          	lbu	a5,24(a5)
    8000544e:	e7b9                	bnez	a5,8000549c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005450:	00451693          	slli	a3,a0,0x4
    80005454:	0001b797          	auipc	a5,0x1b
    80005458:	6ec78793          	addi	a5,a5,1772 # 80020b40 <disk>
    8000545c:	6398                	ld	a4,0(a5)
    8000545e:	9736                	add	a4,a4,a3
    80005460:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005464:	6398                	ld	a4,0(a5)
    80005466:	9736                	add	a4,a4,a3
    80005468:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000546c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005470:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005474:	97aa                	add	a5,a5,a0
    80005476:	4705                	li	a4,1
    80005478:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000547c:	0001b517          	auipc	a0,0x1b
    80005480:	6dc50513          	addi	a0,a0,1756 # 80020b58 <disk+0x18>
    80005484:	a77fc0ef          	jal	80001efa <wakeup>
}
    80005488:	60a2                	ld	ra,8(sp)
    8000548a:	6402                	ld	s0,0(sp)
    8000548c:	0141                	addi	sp,sp,16
    8000548e:	8082                	ret
    panic("free_desc 1");
    80005490:	00002517          	auipc	a0,0x2
    80005494:	21050513          	addi	a0,a0,528 # 800076a0 <etext+0x6a0>
    80005498:	afcfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000549c:	00002517          	auipc	a0,0x2
    800054a0:	21450513          	addi	a0,a0,532 # 800076b0 <etext+0x6b0>
    800054a4:	af0fb0ef          	jal	80000794 <panic>

00000000800054a8 <virtio_disk_init>:
{
    800054a8:	1101                	addi	sp,sp,-32
    800054aa:	ec06                	sd	ra,24(sp)
    800054ac:	e822                	sd	s0,16(sp)
    800054ae:	e426                	sd	s1,8(sp)
    800054b0:	e04a                	sd	s2,0(sp)
    800054b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054b4:	00002597          	auipc	a1,0x2
    800054b8:	20c58593          	addi	a1,a1,524 # 800076c0 <etext+0x6c0>
    800054bc:	0001b517          	auipc	a0,0x1b
    800054c0:	7ac50513          	addi	a0,a0,1964 # 80020c68 <disk+0x128>
    800054c4:	eb0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054c8:	100017b7          	lui	a5,0x10001
    800054cc:	4398                	lw	a4,0(a5)
    800054ce:	2701                	sext.w	a4,a4
    800054d0:	747277b7          	lui	a5,0x74727
    800054d4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800054d8:	18f71063          	bne	a4,a5,80005658 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054dc:	100017b7          	lui	a5,0x10001
    800054e0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800054e2:	439c                	lw	a5,0(a5)
    800054e4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800054e6:	4709                	li	a4,2
    800054e8:	16e79863          	bne	a5,a4,80005658 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054ec:	100017b7          	lui	a5,0x10001
    800054f0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800054f2:	439c                	lw	a5,0(a5)
    800054f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054f6:	16e79163          	bne	a5,a4,80005658 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800054fa:	100017b7          	lui	a5,0x10001
    800054fe:	47d8                	lw	a4,12(a5)
    80005500:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005502:	554d47b7          	lui	a5,0x554d4
    80005506:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000550a:	14f71763          	bne	a4,a5,80005658 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000550e:	100017b7          	lui	a5,0x10001
    80005512:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005516:	4705                	li	a4,1
    80005518:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000551a:	470d                	li	a4,3
    8000551c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000551e:	10001737          	lui	a4,0x10001
    80005522:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005524:	c7ffe737          	lui	a4,0xc7ffe
    80005528:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fddadf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000552c:	8ef9                	and	a3,a3,a4
    8000552e:	10001737          	lui	a4,0x10001
    80005532:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005534:	472d                	li	a4,11
    80005536:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005538:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000553c:	439c                	lw	a5,0(a5)
    8000553e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005542:	8ba1                	andi	a5,a5,8
    80005544:	12078063          	beqz	a5,80005664 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005548:	100017b7          	lui	a5,0x10001
    8000554c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005550:	100017b7          	lui	a5,0x10001
    80005554:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005558:	439c                	lw	a5,0(a5)
    8000555a:	2781                	sext.w	a5,a5
    8000555c:	10079a63          	bnez	a5,80005670 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005560:	100017b7          	lui	a5,0x10001
    80005564:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005568:	439c                	lw	a5,0(a5)
    8000556a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000556c:	10078863          	beqz	a5,8000567c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005570:	471d                	li	a4,7
    80005572:	10f77b63          	bgeu	a4,a5,80005688 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005576:	daefb0ef          	jal	80000b24 <kalloc>
    8000557a:	0001b497          	auipc	s1,0x1b
    8000557e:	5c648493          	addi	s1,s1,1478 # 80020b40 <disk>
    80005582:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005584:	da0fb0ef          	jal	80000b24 <kalloc>
    80005588:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000558a:	d9afb0ef          	jal	80000b24 <kalloc>
    8000558e:	87aa                	mv	a5,a0
    80005590:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005592:	6088                	ld	a0,0(s1)
    80005594:	10050063          	beqz	a0,80005694 <virtio_disk_init+0x1ec>
    80005598:	0001b717          	auipc	a4,0x1b
    8000559c:	5b073703          	ld	a4,1456(a4) # 80020b48 <disk+0x8>
    800055a0:	0e070a63          	beqz	a4,80005694 <virtio_disk_init+0x1ec>
    800055a4:	0e078863          	beqz	a5,80005694 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800055a8:	6605                	lui	a2,0x1
    800055aa:	4581                	li	a1,0
    800055ac:	f1cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800055b0:	0001b497          	auipc	s1,0x1b
    800055b4:	59048493          	addi	s1,s1,1424 # 80020b40 <disk>
    800055b8:	6605                	lui	a2,0x1
    800055ba:	4581                	li	a1,0
    800055bc:	6488                	ld	a0,8(s1)
    800055be:	f0afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    800055c2:	6605                	lui	a2,0x1
    800055c4:	4581                	li	a1,0
    800055c6:	6888                	ld	a0,16(s1)
    800055c8:	f00fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800055cc:	100017b7          	lui	a5,0x10001
    800055d0:	4721                	li	a4,8
    800055d2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800055d4:	4098                	lw	a4,0(s1)
    800055d6:	100017b7          	lui	a5,0x10001
    800055da:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800055de:	40d8                	lw	a4,4(s1)
    800055e0:	100017b7          	lui	a5,0x10001
    800055e4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800055e8:	649c                	ld	a5,8(s1)
    800055ea:	0007869b          	sext.w	a3,a5
    800055ee:	10001737          	lui	a4,0x10001
    800055f2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800055f6:	9781                	srai	a5,a5,0x20
    800055f8:	10001737          	lui	a4,0x10001
    800055fc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005600:	689c                	ld	a5,16(s1)
    80005602:	0007869b          	sext.w	a3,a5
    80005606:	10001737          	lui	a4,0x10001
    8000560a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000560e:	9781                	srai	a5,a5,0x20
    80005610:	10001737          	lui	a4,0x10001
    80005614:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005618:	10001737          	lui	a4,0x10001
    8000561c:	4785                	li	a5,1
    8000561e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005620:	00f48c23          	sb	a5,24(s1)
    80005624:	00f48ca3          	sb	a5,25(s1)
    80005628:	00f48d23          	sb	a5,26(s1)
    8000562c:	00f48da3          	sb	a5,27(s1)
    80005630:	00f48e23          	sb	a5,28(s1)
    80005634:	00f48ea3          	sb	a5,29(s1)
    80005638:	00f48f23          	sb	a5,30(s1)
    8000563c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005640:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005644:	100017b7          	lui	a5,0x10001
    80005648:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000564c:	60e2                	ld	ra,24(sp)
    8000564e:	6442                	ld	s0,16(sp)
    80005650:	64a2                	ld	s1,8(sp)
    80005652:	6902                	ld	s2,0(sp)
    80005654:	6105                	addi	sp,sp,32
    80005656:	8082                	ret
    panic("could not find virtio disk");
    80005658:	00002517          	auipc	a0,0x2
    8000565c:	07850513          	addi	a0,a0,120 # 800076d0 <etext+0x6d0>
    80005660:	934fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005664:	00002517          	auipc	a0,0x2
    80005668:	08c50513          	addi	a0,a0,140 # 800076f0 <etext+0x6f0>
    8000566c:	928fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005670:	00002517          	auipc	a0,0x2
    80005674:	0a050513          	addi	a0,a0,160 # 80007710 <etext+0x710>
    80005678:	91cfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    8000567c:	00002517          	auipc	a0,0x2
    80005680:	0b450513          	addi	a0,a0,180 # 80007730 <etext+0x730>
    80005684:	910fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005688:	00002517          	auipc	a0,0x2
    8000568c:	0c850513          	addi	a0,a0,200 # 80007750 <etext+0x750>
    80005690:	904fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005694:	00002517          	auipc	a0,0x2
    80005698:	0dc50513          	addi	a0,a0,220 # 80007770 <etext+0x770>
    8000569c:	8f8fb0ef          	jal	80000794 <panic>

00000000800056a0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056a0:	7159                	addi	sp,sp,-112
    800056a2:	f486                	sd	ra,104(sp)
    800056a4:	f0a2                	sd	s0,96(sp)
    800056a6:	eca6                	sd	s1,88(sp)
    800056a8:	e8ca                	sd	s2,80(sp)
    800056aa:	e4ce                	sd	s3,72(sp)
    800056ac:	e0d2                	sd	s4,64(sp)
    800056ae:	fc56                	sd	s5,56(sp)
    800056b0:	f85a                	sd	s6,48(sp)
    800056b2:	f45e                	sd	s7,40(sp)
    800056b4:	f062                	sd	s8,32(sp)
    800056b6:	ec66                	sd	s9,24(sp)
    800056b8:	1880                	addi	s0,sp,112
    800056ba:	8a2a                	mv	s4,a0
    800056bc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800056be:	00c52c83          	lw	s9,12(a0)
    800056c2:	001c9c9b          	slliw	s9,s9,0x1
    800056c6:	1c82                	slli	s9,s9,0x20
    800056c8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800056cc:	0001b517          	auipc	a0,0x1b
    800056d0:	59c50513          	addi	a0,a0,1436 # 80020c68 <disk+0x128>
    800056d4:	d20fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    800056d8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800056da:	44a1                	li	s1,8
      disk.free[i] = 0;
    800056dc:	0001bb17          	auipc	s6,0x1b
    800056e0:	464b0b13          	addi	s6,s6,1124 # 80020b40 <disk>
  for(int i = 0; i < 3; i++){
    800056e4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056e6:	0001bc17          	auipc	s8,0x1b
    800056ea:	582c0c13          	addi	s8,s8,1410 # 80020c68 <disk+0x128>
    800056ee:	a8b9                	j	8000574c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800056f0:	00fb0733          	add	a4,s6,a5
    800056f4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800056f8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056fa:	0207c563          	bltz	a5,80005724 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800056fe:	2905                	addiw	s2,s2,1
    80005700:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005702:	05590963          	beq	s2,s5,80005754 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005706:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005708:	0001b717          	auipc	a4,0x1b
    8000570c:	43870713          	addi	a4,a4,1080 # 80020b40 <disk>
    80005710:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005712:	01874683          	lbu	a3,24(a4)
    80005716:	fee9                	bnez	a3,800056f0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005718:	2785                	addiw	a5,a5,1
    8000571a:	0705                	addi	a4,a4,1
    8000571c:	fe979be3          	bne	a5,s1,80005712 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005720:	57fd                	li	a5,-1
    80005722:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005724:	01205d63          	blez	s2,8000573e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005728:	f9042503          	lw	a0,-112(s0)
    8000572c:	d07ff0ef          	jal	80005432 <free_desc>
      for(int j = 0; j < i; j++)
    80005730:	4785                	li	a5,1
    80005732:	0127d663          	bge	a5,s2,8000573e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005736:	f9442503          	lw	a0,-108(s0)
    8000573a:	cf9ff0ef          	jal	80005432 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000573e:	85e2                	mv	a1,s8
    80005740:	0001b517          	auipc	a0,0x1b
    80005744:	41850513          	addi	a0,a0,1048 # 80020b58 <disk+0x18>
    80005748:	f66fc0ef          	jal	80001eae <sleep>
  for(int i = 0; i < 3; i++){
    8000574c:	f9040613          	addi	a2,s0,-112
    80005750:	894e                	mv	s2,s3
    80005752:	bf55                	j	80005706 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005754:	f9042503          	lw	a0,-112(s0)
    80005758:	00451693          	slli	a3,a0,0x4

  if(write)
    8000575c:	0001b797          	auipc	a5,0x1b
    80005760:	3e478793          	addi	a5,a5,996 # 80020b40 <disk>
    80005764:	00a50713          	addi	a4,a0,10
    80005768:	0712                	slli	a4,a4,0x4
    8000576a:	973e                	add	a4,a4,a5
    8000576c:	01703633          	snez	a2,s7
    80005770:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005772:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005776:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000577a:	6398                	ld	a4,0(a5)
    8000577c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000577e:	0a868613          	addi	a2,a3,168
    80005782:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005784:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005786:	6390                	ld	a2,0(a5)
    80005788:	00d605b3          	add	a1,a2,a3
    8000578c:	4741                	li	a4,16
    8000578e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005790:	4805                	li	a6,1
    80005792:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005796:	f9442703          	lw	a4,-108(s0)
    8000579a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000579e:	0712                	slli	a4,a4,0x4
    800057a0:	963a                	add	a2,a2,a4
    800057a2:	058a0593          	addi	a1,s4,88
    800057a6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800057a8:	0007b883          	ld	a7,0(a5)
    800057ac:	9746                	add	a4,a4,a7
    800057ae:	40000613          	li	a2,1024
    800057b2:	c710                	sw	a2,8(a4)
  if(write)
    800057b4:	001bb613          	seqz	a2,s7
    800057b8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800057bc:	00166613          	ori	a2,a2,1
    800057c0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800057c4:	f9842583          	lw	a1,-104(s0)
    800057c8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800057cc:	00250613          	addi	a2,a0,2
    800057d0:	0612                	slli	a2,a2,0x4
    800057d2:	963e                	add	a2,a2,a5
    800057d4:	577d                	li	a4,-1
    800057d6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800057da:	0592                	slli	a1,a1,0x4
    800057dc:	98ae                	add	a7,a7,a1
    800057de:	03068713          	addi	a4,a3,48
    800057e2:	973e                	add	a4,a4,a5
    800057e4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800057e8:	6398                	ld	a4,0(a5)
    800057ea:	972e                	add	a4,a4,a1
    800057ec:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057f0:	4689                	li	a3,2
    800057f2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800057f6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057fa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800057fe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005802:	6794                	ld	a3,8(a5)
    80005804:	0026d703          	lhu	a4,2(a3)
    80005808:	8b1d                	andi	a4,a4,7
    8000580a:	0706                	slli	a4,a4,0x1
    8000580c:	96ba                	add	a3,a3,a4
    8000580e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005812:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005816:	6798                	ld	a4,8(a5)
    80005818:	00275783          	lhu	a5,2(a4)
    8000581c:	2785                	addiw	a5,a5,1
    8000581e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005822:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005826:	100017b7          	lui	a5,0x10001
    8000582a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000582e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005832:	0001b917          	auipc	s2,0x1b
    80005836:	43690913          	addi	s2,s2,1078 # 80020c68 <disk+0x128>
  while(b->disk == 1) {
    8000583a:	4485                	li	s1,1
    8000583c:	01079a63          	bne	a5,a6,80005850 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005840:	85ca                	mv	a1,s2
    80005842:	8552                	mv	a0,s4
    80005844:	e6afc0ef          	jal	80001eae <sleep>
  while(b->disk == 1) {
    80005848:	004a2783          	lw	a5,4(s4)
    8000584c:	fe978ae3          	beq	a5,s1,80005840 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005850:	f9042903          	lw	s2,-112(s0)
    80005854:	00290713          	addi	a4,s2,2
    80005858:	0712                	slli	a4,a4,0x4
    8000585a:	0001b797          	auipc	a5,0x1b
    8000585e:	2e678793          	addi	a5,a5,742 # 80020b40 <disk>
    80005862:	97ba                	add	a5,a5,a4
    80005864:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005868:	0001b997          	auipc	s3,0x1b
    8000586c:	2d898993          	addi	s3,s3,728 # 80020b40 <disk>
    80005870:	00491713          	slli	a4,s2,0x4
    80005874:	0009b783          	ld	a5,0(s3)
    80005878:	97ba                	add	a5,a5,a4
    8000587a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000587e:	854a                	mv	a0,s2
    80005880:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005884:	bafff0ef          	jal	80005432 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005888:	8885                	andi	s1,s1,1
    8000588a:	f0fd                	bnez	s1,80005870 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000588c:	0001b517          	auipc	a0,0x1b
    80005890:	3dc50513          	addi	a0,a0,988 # 80020c68 <disk+0x128>
    80005894:	bf8fb0ef          	jal	80000c8c <release>
}
    80005898:	70a6                	ld	ra,104(sp)
    8000589a:	7406                	ld	s0,96(sp)
    8000589c:	64e6                	ld	s1,88(sp)
    8000589e:	6946                	ld	s2,80(sp)
    800058a0:	69a6                	ld	s3,72(sp)
    800058a2:	6a06                	ld	s4,64(sp)
    800058a4:	7ae2                	ld	s5,56(sp)
    800058a6:	7b42                	ld	s6,48(sp)
    800058a8:	7ba2                	ld	s7,40(sp)
    800058aa:	7c02                	ld	s8,32(sp)
    800058ac:	6ce2                	ld	s9,24(sp)
    800058ae:	6165                	addi	sp,sp,112
    800058b0:	8082                	ret

00000000800058b2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058b2:	1101                	addi	sp,sp,-32
    800058b4:	ec06                	sd	ra,24(sp)
    800058b6:	e822                	sd	s0,16(sp)
    800058b8:	e426                	sd	s1,8(sp)
    800058ba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058bc:	0001b497          	auipc	s1,0x1b
    800058c0:	28448493          	addi	s1,s1,644 # 80020b40 <disk>
    800058c4:	0001b517          	auipc	a0,0x1b
    800058c8:	3a450513          	addi	a0,a0,932 # 80020c68 <disk+0x128>
    800058cc:	b28fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800058d0:	100017b7          	lui	a5,0x10001
    800058d4:	53b8                	lw	a4,96(a5)
    800058d6:	8b0d                	andi	a4,a4,3
    800058d8:	100017b7          	lui	a5,0x10001
    800058dc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800058de:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058e2:	689c                	ld	a5,16(s1)
    800058e4:	0204d703          	lhu	a4,32(s1)
    800058e8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    800058ec:	04f70663          	beq	a4,a5,80005938 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800058f0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058f4:	6898                	ld	a4,16(s1)
    800058f6:	0204d783          	lhu	a5,32(s1)
    800058fa:	8b9d                	andi	a5,a5,7
    800058fc:	078e                	slli	a5,a5,0x3
    800058fe:	97ba                	add	a5,a5,a4
    80005900:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005902:	00278713          	addi	a4,a5,2
    80005906:	0712                	slli	a4,a4,0x4
    80005908:	9726                	add	a4,a4,s1
    8000590a:	01074703          	lbu	a4,16(a4)
    8000590e:	e321                	bnez	a4,8000594e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005910:	0789                	addi	a5,a5,2
    80005912:	0792                	slli	a5,a5,0x4
    80005914:	97a6                	add	a5,a5,s1
    80005916:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005918:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000591c:	ddefc0ef          	jal	80001efa <wakeup>

    disk.used_idx += 1;
    80005920:	0204d783          	lhu	a5,32(s1)
    80005924:	2785                	addiw	a5,a5,1
    80005926:	17c2                	slli	a5,a5,0x30
    80005928:	93c1                	srli	a5,a5,0x30
    8000592a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000592e:	6898                	ld	a4,16(s1)
    80005930:	00275703          	lhu	a4,2(a4)
    80005934:	faf71ee3          	bne	a4,a5,800058f0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005938:	0001b517          	auipc	a0,0x1b
    8000593c:	33050513          	addi	a0,a0,816 # 80020c68 <disk+0x128>
    80005940:	b4cfb0ef          	jal	80000c8c <release>
}
    80005944:	60e2                	ld	ra,24(sp)
    80005946:	6442                	ld	s0,16(sp)
    80005948:	64a2                	ld	s1,8(sp)
    8000594a:	6105                	addi	sp,sp,32
    8000594c:	8082                	ret
      panic("virtio_disk_intr status");
    8000594e:	00002517          	auipc	a0,0x2
    80005952:	e3a50513          	addi	a0,a0,-454 # 80007788 <etext+0x788>
    80005956:	e3ffa0ef          	jal	80000794 <panic>
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
