
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	fe2d8d93          	addi	s11,s11,-30 # 1010 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	9a8a0a13          	addi	s4,s4,-1624 # 9e0 <malloc+0xfc>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a035                	j	6e <wc+0x6e>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	1bc000ef          	jal	202 <strchr>
  4a:	c919                	beqz	a0,60 <wc+0x60>
        inword = 0;
  4c:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  4e:	0485                	addi	s1,s1,1
  50:	01348d63          	beq	s1,s3,6a <wc+0x6a>
      if(buf[i] == '\n')
  54:	0004c583          	lbu	a1,0(s1)
  58:	ff5596e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  5c:	2c05                	addiw	s8,s8,1
  5e:	b7dd                	j	44 <wc+0x44>
      else if(!inword){
  60:	fe0917e3          	bnez	s2,4e <wc+0x4e>
        w++;
  64:	2c85                	addiw	s9,s9,1
        inword = 1;
  66:	4905                	li	s2,1
  68:	b7dd                	j	4e <wc+0x4e>
  6a:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  6e:	20000613          	li	a2,512
  72:	85ee                	mv	a1,s11
  74:	f8843503          	ld	a0,-120(s0)
  78:	3b8000ef          	jal	430 <read>
  7c:	8b2a                	mv	s6,a0
  7e:	00a05963          	blez	a0,90 <wc+0x90>
    for(i=0; i<n; i++){
  82:	00001497          	auipc	s1,0x1
  86:	f8e48493          	addi	s1,s1,-114 # 1010 <buf>
  8a:	009509b3          	add	s3,a0,s1
  8e:	b7d9                	j	54 <wc+0x54>
      }
    }
  }
  if(n < 0){
  90:	02054c63          	bltz	a0,c8 <wc+0xc8>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  94:	f8043703          	ld	a4,-128(s0)
  98:	86ea                	mv	a3,s10
  9a:	8666                	mv	a2,s9
  9c:	85e2                	mv	a1,s8
  9e:	00001517          	auipc	a0,0x1
  a2:	96250513          	addi	a0,a0,-1694 # a00 <malloc+0x11c>
  a6:	78a000ef          	jal	830 <printf>
}
  aa:	70e6                	ld	ra,120(sp)
  ac:	7446                	ld	s0,112(sp)
  ae:	74a6                	ld	s1,104(sp)
  b0:	7906                	ld	s2,96(sp)
  b2:	69e6                	ld	s3,88(sp)
  b4:	6a46                	ld	s4,80(sp)
  b6:	6aa6                	ld	s5,72(sp)
  b8:	6b06                	ld	s6,64(sp)
  ba:	7be2                	ld	s7,56(sp)
  bc:	7c42                	ld	s8,48(sp)
  be:	7ca2                	ld	s9,40(sp)
  c0:	7d02                	ld	s10,32(sp)
  c2:	6de2                	ld	s11,24(sp)
  c4:	6109                	addi	sp,sp,128
  c6:	8082                	ret
    printf("wc: read error\n");
  c8:	00001517          	auipc	a0,0x1
  cc:	92850513          	addi	a0,a0,-1752 # 9f0 <malloc+0x10c>
  d0:	760000ef          	jal	830 <printf>
    exit(1);
  d4:	4505                	li	a0,1
  d6:	342000ef          	jal	418 <exit>

00000000000000da <main>:

int
main(int argc, char *argv[])
{
  da:	7179                	addi	sp,sp,-48
  dc:	f406                	sd	ra,40(sp)
  de:	f022                	sd	s0,32(sp)
  e0:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  e2:	4785                	li	a5,1
  e4:	04a7d463          	bge	a5,a0,12c <main+0x52>
  e8:	ec26                	sd	s1,24(sp)
  ea:	e84a                	sd	s2,16(sp)
  ec:	e44e                	sd	s3,8(sp)
  ee:	00858913          	addi	s2,a1,8
  f2:	ffe5099b          	addiw	s3,a0,-2
  f6:	02099793          	slli	a5,s3,0x20
  fa:	01d7d993          	srli	s3,a5,0x1d
  fe:	05c1                	addi	a1,a1,16
 100:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
 102:	4581                	li	a1,0
 104:	00093503          	ld	a0,0(s2)
 108:	350000ef          	jal	458 <open>
 10c:	84aa                	mv	s1,a0
 10e:	02054c63          	bltz	a0,146 <main+0x6c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 112:	00093583          	ld	a1,0(s2)
 116:	eebff0ef          	jal	0 <wc>
    close(fd);
 11a:	8526                	mv	a0,s1
 11c:	324000ef          	jal	440 <close>
  for(i = 1; i < argc; i++){
 120:	0921                	addi	s2,s2,8
 122:	ff3910e3          	bne	s2,s3,102 <main+0x28>
  }
  exit(0);
 126:	4501                	li	a0,0
 128:	2f0000ef          	jal	418 <exit>
 12c:	ec26                	sd	s1,24(sp)
 12e:	e84a                	sd	s2,16(sp)
 130:	e44e                	sd	s3,8(sp)
    wc(0, "");
 132:	00001597          	auipc	a1,0x1
 136:	8b658593          	addi	a1,a1,-1866 # 9e8 <malloc+0x104>
 13a:	4501                	li	a0,0
 13c:	ec5ff0ef          	jal	0 <wc>
    exit(0);
 140:	4501                	li	a0,0
 142:	2d6000ef          	jal	418 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 146:	00093583          	ld	a1,0(s2)
 14a:	00001517          	auipc	a0,0x1
 14e:	8c650513          	addi	a0,a0,-1850 # a10 <malloc+0x12c>
 152:	6de000ef          	jal	830 <printf>
      exit(1);
 156:	4505                	li	a0,1
 158:	2c0000ef          	jal	418 <exit>

000000000000015c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  extern int main();
  main();
 164:	f77ff0ef          	jal	da <main>
  exit(0);
 168:	4501                	li	a0,0
 16a:	2ae000ef          	jal	418 <exit>

000000000000016e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 174:	87aa                	mv	a5,a0
 176:	0585                	addi	a1,a1,1
 178:	0785                	addi	a5,a5,1
 17a:	fff5c703          	lbu	a4,-1(a1)
 17e:	fee78fa3          	sb	a4,-1(a5)
 182:	fb75                	bnez	a4,176 <strcpy+0x8>
    ;
  return os;
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret

000000000000018a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 190:	00054783          	lbu	a5,0(a0)
 194:	cb91                	beqz	a5,1a8 <strcmp+0x1e>
 196:	0005c703          	lbu	a4,0(a1)
 19a:	00f71763          	bne	a4,a5,1a8 <strcmp+0x1e>
    p++, q++;
 19e:	0505                	addi	a0,a0,1
 1a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbe5                	bnez	a5,196 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a8:	0005c503          	lbu	a0,0(a1)
}
 1ac:	40a7853b          	subw	a0,a5,a0
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strlen>:

uint
strlen(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cf91                	beqz	a5,1dc <strlen+0x26>
 1c2:	0505                	addi	a0,a0,1
 1c4:	87aa                	mv	a5,a0
 1c6:	86be                	mv	a3,a5
 1c8:	0785                	addi	a5,a5,1
 1ca:	fff7c703          	lbu	a4,-1(a5)
 1ce:	ff65                	bnez	a4,1c6 <strlen+0x10>
 1d0:	40a6853b          	subw	a0,a3,a0
 1d4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret
  for(n = 0; s[n]; n++)
 1dc:	4501                	li	a0,0
 1de:	bfe5                	j	1d6 <strlen+0x20>

00000000000001e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e6:	ca19                	beqz	a2,1fc <memset+0x1c>
 1e8:	87aa                	mv	a5,a0
 1ea:	1602                	slli	a2,a2,0x20
 1ec:	9201                	srli	a2,a2,0x20
 1ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f6:	0785                	addi	a5,a5,1
 1f8:	fee79de3          	bne	a5,a4,1f2 <memset+0x12>
  }
  return dst;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strchr>:

char*
strchr(const char *s, char c)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  for(; *s; s++)
 208:	00054783          	lbu	a5,0(a0)
 20c:	cb99                	beqz	a5,222 <strchr+0x20>
    if(*s == c)
 20e:	00f58763          	beq	a1,a5,21c <strchr+0x1a>
  for(; *s; s++)
 212:	0505                	addi	a0,a0,1
 214:	00054783          	lbu	a5,0(a0)
 218:	fbfd                	bnez	a5,20e <strchr+0xc>
      return (char*)s;
  return 0;
 21a:	4501                	li	a0,0
}
 21c:	6422                	ld	s0,8(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret
  return 0;
 222:	4501                	li	a0,0
 224:	bfe5                	j	21c <strchr+0x1a>

0000000000000226 <gets>:

char*
gets(char *buf, int max)
{
 226:	711d                	addi	sp,sp,-96
 228:	ec86                	sd	ra,88(sp)
 22a:	e8a2                	sd	s0,80(sp)
 22c:	e4a6                	sd	s1,72(sp)
 22e:	e0ca                	sd	s2,64(sp)
 230:	fc4e                	sd	s3,56(sp)
 232:	f852                	sd	s4,48(sp)
 234:	f456                	sd	s5,40(sp)
 236:	f05a                	sd	s6,32(sp)
 238:	ec5e                	sd	s7,24(sp)
 23a:	1080                	addi	s0,sp,96
 23c:	8baa                	mv	s7,a0
 23e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 240:	892a                	mv	s2,a0
 242:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 244:	4aa9                	li	s5,10
 246:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 248:	89a6                	mv	s3,s1
 24a:	2485                	addiw	s1,s1,1
 24c:	0344d663          	bge	s1,s4,278 <gets+0x52>
    cc = read(0, &c, 1);
 250:	4605                	li	a2,1
 252:	faf40593          	addi	a1,s0,-81
 256:	4501                	li	a0,0
 258:	1d8000ef          	jal	430 <read>
    if(cc < 1)
 25c:	00a05e63          	blez	a0,278 <gets+0x52>
    buf[i++] = c;
 260:	faf44783          	lbu	a5,-81(s0)
 264:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 268:	01578763          	beq	a5,s5,276 <gets+0x50>
 26c:	0905                	addi	s2,s2,1
 26e:	fd679de3          	bne	a5,s6,248 <gets+0x22>
    buf[i++] = c;
 272:	89a6                	mv	s3,s1
 274:	a011                	j	278 <gets+0x52>
 276:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 278:	99de                	add	s3,s3,s7
 27a:	00098023          	sb	zero,0(s3)
  return buf;
}
 27e:	855e                	mv	a0,s7
 280:	60e6                	ld	ra,88(sp)
 282:	6446                	ld	s0,80(sp)
 284:	64a6                	ld	s1,72(sp)
 286:	6906                	ld	s2,64(sp)
 288:	79e2                	ld	s3,56(sp)
 28a:	7a42                	ld	s4,48(sp)
 28c:	7aa2                	ld	s5,40(sp)
 28e:	7b02                	ld	s6,32(sp)
 290:	6be2                	ld	s7,24(sp)
 292:	6125                	addi	sp,sp,96
 294:	8082                	ret

0000000000000296 <stat>:

int
stat(const char *n, struct stat *st)
{
 296:	1101                	addi	sp,sp,-32
 298:	ec06                	sd	ra,24(sp)
 29a:	e822                	sd	s0,16(sp)
 29c:	e04a                	sd	s2,0(sp)
 29e:	1000                	addi	s0,sp,32
 2a0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a2:	4581                	li	a1,0
 2a4:	1b4000ef          	jal	458 <open>
  if(fd < 0)
 2a8:	02054263          	bltz	a0,2cc <stat+0x36>
 2ac:	e426                	sd	s1,8(sp)
 2ae:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b0:	85ca                	mv	a1,s2
 2b2:	1be000ef          	jal	470 <fstat>
 2b6:	892a                	mv	s2,a0
  close(fd);
 2b8:	8526                	mv	a0,s1
 2ba:	186000ef          	jal	440 <close>
  return r;
 2be:	64a2                	ld	s1,8(sp)
}
 2c0:	854a                	mv	a0,s2
 2c2:	60e2                	ld	ra,24(sp)
 2c4:	6442                	ld	s0,16(sp)
 2c6:	6902                	ld	s2,0(sp)
 2c8:	6105                	addi	sp,sp,32
 2ca:	8082                	ret
    return -1;
 2cc:	597d                	li	s2,-1
 2ce:	bfcd                	j	2c0 <stat+0x2a>

00000000000002d0 <atoi>:

int
atoi(const char *s)
{
 2d0:	1141                	addi	sp,sp,-16
 2d2:	e422                	sd	s0,8(sp)
 2d4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d6:	00054683          	lbu	a3,0(a0)
 2da:	fd06879b          	addiw	a5,a3,-48
 2de:	0ff7f793          	zext.b	a5,a5
 2e2:	4625                	li	a2,9
 2e4:	02f66863          	bltu	a2,a5,314 <atoi+0x44>
 2e8:	872a                	mv	a4,a0
  n = 0;
 2ea:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ec:	0705                	addi	a4,a4,1
 2ee:	0025179b          	slliw	a5,a0,0x2
 2f2:	9fa9                	addw	a5,a5,a0
 2f4:	0017979b          	slliw	a5,a5,0x1
 2f8:	9fb5                	addw	a5,a5,a3
 2fa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fe:	00074683          	lbu	a3,0(a4)
 302:	fd06879b          	addiw	a5,a3,-48
 306:	0ff7f793          	zext.b	a5,a5
 30a:	fef671e3          	bgeu	a2,a5,2ec <atoi+0x1c>
  return n;
}
 30e:	6422                	ld	s0,8(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret
  n = 0;
 314:	4501                	li	a0,0
 316:	bfe5                	j	30e <atoi+0x3e>

0000000000000318 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e422                	sd	s0,8(sp)
 31c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31e:	02b57463          	bgeu	a0,a1,346 <memmove+0x2e>
    while(n-- > 0)
 322:	00c05f63          	blez	a2,340 <memmove+0x28>
 326:	1602                	slli	a2,a2,0x20
 328:	9201                	srli	a2,a2,0x20
 32a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32e:	872a                	mv	a4,a0
      *dst++ = *src++;
 330:	0585                	addi	a1,a1,1
 332:	0705                	addi	a4,a4,1
 334:	fff5c683          	lbu	a3,-1(a1)
 338:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33c:	fef71ae3          	bne	a4,a5,330 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
    dst += n;
 346:	00c50733          	add	a4,a0,a2
    src += n;
 34a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34c:	fec05ae3          	blez	a2,340 <memmove+0x28>
 350:	fff6079b          	addiw	a5,a2,-1
 354:	1782                	slli	a5,a5,0x20
 356:	9381                	srli	a5,a5,0x20
 358:	fff7c793          	not	a5,a5
 35c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35e:	15fd                	addi	a1,a1,-1
 360:	177d                	addi	a4,a4,-1
 362:	0005c683          	lbu	a3,0(a1)
 366:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36a:	fee79ae3          	bne	a5,a4,35e <memmove+0x46>
 36e:	bfc9                	j	340 <memmove+0x28>

0000000000000370 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e422                	sd	s0,8(sp)
 374:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 376:	ca05                	beqz	a2,3a6 <memcmp+0x36>
 378:	fff6069b          	addiw	a3,a2,-1
 37c:	1682                	slli	a3,a3,0x20
 37e:	9281                	srli	a3,a3,0x20
 380:	0685                	addi	a3,a3,1
 382:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 384:	00054783          	lbu	a5,0(a0)
 388:	0005c703          	lbu	a4,0(a1)
 38c:	00e79863          	bne	a5,a4,39c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 390:	0505                	addi	a0,a0,1
    p2++;
 392:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 394:	fed518e3          	bne	a0,a3,384 <memcmp+0x14>
  }
  return 0;
 398:	4501                	li	a0,0
 39a:	a019                	j	3a0 <memcmp+0x30>
      return *p1 - *p2;
 39c:	40e7853b          	subw	a0,a5,a4
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret
  return 0;
 3a6:	4501                	li	a0,0
 3a8:	bfe5                	j	3a0 <memcmp+0x30>

00000000000003aa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e406                	sd	ra,8(sp)
 3ae:	e022                	sd	s0,0(sp)
 3b0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b2:	f67ff0ef          	jal	318 <memmove>
}
 3b6:	60a2                	ld	ra,8(sp)
 3b8:	6402                	ld	s0,0(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret

00000000000003be <syscall>:
}

// Implementación de la función syscall
long
syscall(int num, ...)
{
 3be:	711d                	addi	sp,sp,-96
 3c0:	ec22                	sd	s0,24(sp)
 3c2:	1000                	addi	s0,sp,32
 3c4:	832a                	mv	t1,a0
 3c6:	852e                	mv	a0,a1
 3c8:	e40c                	sd	a1,8(s0)
 3ca:	85b2                	mv	a1,a2
 3cc:	e810                	sd	a2,16(s0)
 3ce:	8636                	mv	a2,a3
 3d0:	ec14                	sd	a3,24(s0)
 3d2:	86ba                	mv	a3,a4
 3d4:	f018                	sd	a4,32(s0)
 3d6:	873e                	mv	a4,a5
 3d8:	f41c                	sd	a5,40(s0)
 3da:	87c2                	mv	a5,a6
 3dc:	03043823          	sd	a6,48(s0)
 3e0:	03143c23          	sd	a7,56(s0)
  // Manejar argumentos variables
  va_list ap;
  va_start(ap, num);

  // Cargar los argumentos en los registros
  register uint64 a0 asm("a0") = va_arg(ap, uint64);
 3e4:	01040813          	addi	a6,s0,16
 3e8:	ff043423          	sd	a6,-24(s0)
  register uint64 a5 asm("a5") = va_arg(ap, uint64);
  
  va_end(ap);

  // Hacer la llamada al sistema
  register uint64 syscall_num asm("a7") = num;
 3ec:	889a                	mv	a7,t1
  asm volatile("ecall"
 3ee:	00000073          	ecall
               : "r" (syscall_num), "r" (a1), "r" (a2), "r" (a3), "r" (a4), "r" (a5)
               : "memory");

  // Retornar el resultado
  return a0;
}
 3f2:	6462                	ld	s0,24(sp)
 3f4:	6125                	addi	sp,sp,96
 3f6:	8082                	ret

00000000000003f8 <getppid>:
{
 3f8:	1141                	addi	sp,sp,-16
 3fa:	e406                	sd	ra,8(sp)
 3fc:	e022                	sd	s0,0(sp)
 3fe:	0800                	addi	s0,sp,16
  return syscall(SYS_getppid);
 400:	4559                	li	a0,22
 402:	fbdff0ef          	jal	3be <syscall>
}
 406:	2501                	sext.w	a0,a0
 408:	60a2                	ld	ra,8(sp)
 40a:	6402                	ld	s0,0(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret

0000000000000410 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 410:	4885                	li	a7,1
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <exit>:
.global exit
exit:
 li a7, SYS_exit
 418:	4889                	li	a7,2
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <wait>:
.global wait
wait:
 li a7, SYS_wait
 420:	488d                	li	a7,3
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 428:	4891                	li	a7,4
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <read>:
.global read
read:
 li a7, SYS_read
 430:	4895                	li	a7,5
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <write>:
.global write
write:
 li a7, SYS_write
 438:	48c1                	li	a7,16
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <close>:
.global close
close:
 li a7, SYS_close
 440:	48d5                	li	a7,21
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <kill>:
.global kill
kill:
 li a7, SYS_kill
 448:	4899                	li	a7,6
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <exec>:
.global exec
exec:
 li a7, SYS_exec
 450:	489d                	li	a7,7
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <open>:
.global open
open:
 li a7, SYS_open
 458:	48bd                	li	a7,15
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 460:	48c5                	li	a7,17
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 468:	48c9                	li	a7,18
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 470:	48a1                	li	a7,8
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <link>:
.global link
link:
 li a7, SYS_link
 478:	48cd                	li	a7,19
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 480:	48d1                	li	a7,20
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 488:	48a5                	li	a7,9
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <dup>:
.global dup
dup:
 li a7, SYS_dup
 490:	48a9                	li	a7,10
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 498:	48ad                	li	a7,11
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4a0:	48b1                	li	a7,12
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a8:	48b5                	li	a7,13
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4b0:	48b9                	li	a7,14
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b8:	1101                	addi	sp,sp,-32
 4ba:	ec06                	sd	ra,24(sp)
 4bc:	e822                	sd	s0,16(sp)
 4be:	1000                	addi	s0,sp,32
 4c0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c4:	4605                	li	a2,1
 4c6:	fef40593          	addi	a1,s0,-17
 4ca:	f6fff0ef          	jal	438 <write>
}
 4ce:	60e2                	ld	ra,24(sp)
 4d0:	6442                	ld	s0,16(sp)
 4d2:	6105                	addi	sp,sp,32
 4d4:	8082                	ret

00000000000004d6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d6:	7139                	addi	sp,sp,-64
 4d8:	fc06                	sd	ra,56(sp)
 4da:	f822                	sd	s0,48(sp)
 4dc:	f426                	sd	s1,40(sp)
 4de:	0080                	addi	s0,sp,64
 4e0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e2:	c299                	beqz	a3,4e8 <printint+0x12>
 4e4:	0805c963          	bltz	a1,576 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e8:	2581                	sext.w	a1,a1
  neg = 0;
 4ea:	4881                	li	a7,0
 4ec:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4f0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f2:	2601                	sext.w	a2,a2
 4f4:	00000517          	auipc	a0,0x0
 4f8:	53c50513          	addi	a0,a0,1340 # a30 <digits>
 4fc:	883a                	mv	a6,a4
 4fe:	2705                	addiw	a4,a4,1
 500:	02c5f7bb          	remuw	a5,a1,a2
 504:	1782                	slli	a5,a5,0x20
 506:	9381                	srli	a5,a5,0x20
 508:	97aa                	add	a5,a5,a0
 50a:	0007c783          	lbu	a5,0(a5)
 50e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 512:	0005879b          	sext.w	a5,a1
 516:	02c5d5bb          	divuw	a1,a1,a2
 51a:	0685                	addi	a3,a3,1
 51c:	fec7f0e3          	bgeu	a5,a2,4fc <printint+0x26>
  if(neg)
 520:	00088c63          	beqz	a7,538 <printint+0x62>
    buf[i++] = '-';
 524:	fd070793          	addi	a5,a4,-48
 528:	00878733          	add	a4,a5,s0
 52c:	02d00793          	li	a5,45
 530:	fef70823          	sb	a5,-16(a4)
 534:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 538:	02e05a63          	blez	a4,56c <printint+0x96>
 53c:	f04a                	sd	s2,32(sp)
 53e:	ec4e                	sd	s3,24(sp)
 540:	fc040793          	addi	a5,s0,-64
 544:	00e78933          	add	s2,a5,a4
 548:	fff78993          	addi	s3,a5,-1
 54c:	99ba                	add	s3,s3,a4
 54e:	377d                	addiw	a4,a4,-1
 550:	1702                	slli	a4,a4,0x20
 552:	9301                	srli	a4,a4,0x20
 554:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 558:	fff94583          	lbu	a1,-1(s2)
 55c:	8526                	mv	a0,s1
 55e:	f5bff0ef          	jal	4b8 <putc>
  while(--i >= 0)
 562:	197d                	addi	s2,s2,-1
 564:	ff391ae3          	bne	s2,s3,558 <printint+0x82>
 568:	7902                	ld	s2,32(sp)
 56a:	69e2                	ld	s3,24(sp)
}
 56c:	70e2                	ld	ra,56(sp)
 56e:	7442                	ld	s0,48(sp)
 570:	74a2                	ld	s1,40(sp)
 572:	6121                	addi	sp,sp,64
 574:	8082                	ret
    x = -xx;
 576:	40b005bb          	negw	a1,a1
    neg = 1;
 57a:	4885                	li	a7,1
    x = -xx;
 57c:	bf85                	j	4ec <printint+0x16>

000000000000057e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57e:	711d                	addi	sp,sp,-96
 580:	ec86                	sd	ra,88(sp)
 582:	e8a2                	sd	s0,80(sp)
 584:	e0ca                	sd	s2,64(sp)
 586:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 588:	0005c903          	lbu	s2,0(a1)
 58c:	26090863          	beqz	s2,7fc <vprintf+0x27e>
 590:	e4a6                	sd	s1,72(sp)
 592:	fc4e                	sd	s3,56(sp)
 594:	f852                	sd	s4,48(sp)
 596:	f456                	sd	s5,40(sp)
 598:	f05a                	sd	s6,32(sp)
 59a:	ec5e                	sd	s7,24(sp)
 59c:	e862                	sd	s8,16(sp)
 59e:	e466                	sd	s9,8(sp)
 5a0:	8b2a                	mv	s6,a0
 5a2:	8a2e                	mv	s4,a1
 5a4:	8bb2                	mv	s7,a2
  state = 0;
 5a6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5a8:	4481                	li	s1,0
 5aa:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ac:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5b0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5b4:	06c00c93          	li	s9,108
 5b8:	a005                	j	5d8 <vprintf+0x5a>
        putc(fd, c0);
 5ba:	85ca                	mv	a1,s2
 5bc:	855a                	mv	a0,s6
 5be:	efbff0ef          	jal	4b8 <putc>
 5c2:	a019                	j	5c8 <vprintf+0x4a>
    } else if(state == '%'){
 5c4:	03598263          	beq	s3,s5,5e8 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5c8:	2485                	addiw	s1,s1,1
 5ca:	8726                	mv	a4,s1
 5cc:	009a07b3          	add	a5,s4,s1
 5d0:	0007c903          	lbu	s2,0(a5)
 5d4:	20090c63          	beqz	s2,7ec <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 5d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5dc:	fe0994e3          	bnez	s3,5c4 <vprintf+0x46>
      if(c0 == '%'){
 5e0:	fd579de3          	bne	a5,s5,5ba <vprintf+0x3c>
        state = '%';
 5e4:	89be                	mv	s3,a5
 5e6:	b7cd                	j	5c8 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5e8:	00ea06b3          	add	a3,s4,a4
 5ec:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5f0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5f2:	c681                	beqz	a3,5fa <vprintf+0x7c>
 5f4:	9752                	add	a4,a4,s4
 5f6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5fa:	03878f63          	beq	a5,s8,638 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 5fe:	05978963          	beq	a5,s9,650 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 602:	07500713          	li	a4,117
 606:	0ee78363          	beq	a5,a4,6ec <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 60a:	07800713          	li	a4,120
 60e:	12e78563          	beq	a5,a4,738 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 612:	07000713          	li	a4,112
 616:	14e78a63          	beq	a5,a4,76a <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 61a:	07300713          	li	a4,115
 61e:	18e78a63          	beq	a5,a4,7b2 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 622:	02500713          	li	a4,37
 626:	04e79563          	bne	a5,a4,670 <vprintf+0xf2>
        putc(fd, '%');
 62a:	02500593          	li	a1,37
 62e:	855a                	mv	a0,s6
 630:	e89ff0ef          	jal	4b8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 634:	4981                	li	s3,0
 636:	bf49                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 638:	008b8913          	addi	s2,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000ba583          	lw	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e91ff0ef          	jal	4d6 <printint>
 64a:	8bca                	mv	s7,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bfad                	j	5c8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 650:	06400793          	li	a5,100
 654:	02f68963          	beq	a3,a5,686 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 658:	06c00793          	li	a5,108
 65c:	04f68263          	beq	a3,a5,6a0 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 660:	07500793          	li	a5,117
 664:	0af68063          	beq	a3,a5,704 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 668:	07800793          	li	a5,120
 66c:	0ef68263          	beq	a3,a5,750 <vprintf+0x1d2>
        putc(fd, '%');
 670:	02500593          	li	a1,37
 674:	855a                	mv	a0,s6
 676:	e43ff0ef          	jal	4b8 <putc>
        putc(fd, c0);
 67a:	85ca                	mv	a1,s2
 67c:	855a                	mv	a0,s6
 67e:	e3bff0ef          	jal	4b8 <putc>
      state = 0;
 682:	4981                	li	s3,0
 684:	b791                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 686:	008b8913          	addi	s2,s7,8
 68a:	4685                	li	a3,1
 68c:	4629                	li	a2,10
 68e:	000ba583          	lw	a1,0(s7)
 692:	855a                	mv	a0,s6
 694:	e43ff0ef          	jal	4d6 <printint>
        i += 1;
 698:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 69a:	8bca                	mv	s7,s2
      state = 0;
 69c:	4981                	li	s3,0
        i += 1;
 69e:	b72d                	j	5c8 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6a0:	06400793          	li	a5,100
 6a4:	02f60763          	beq	a2,a5,6d2 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6a8:	07500793          	li	a5,117
 6ac:	06f60963          	beq	a2,a5,71e <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6b0:	07800793          	li	a5,120
 6b4:	faf61ee3          	bne	a2,a5,670 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b8:	008b8913          	addi	s2,s7,8
 6bc:	4681                	li	a3,0
 6be:	4641                	li	a2,16
 6c0:	000ba583          	lw	a1,0(s7)
 6c4:	855a                	mv	a0,s6
 6c6:	e11ff0ef          	jal	4d6 <printint>
        i += 2;
 6ca:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6cc:	8bca                	mv	s7,s2
      state = 0;
 6ce:	4981                	li	s3,0
        i += 2;
 6d0:	bde5                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	4685                	li	a3,1
 6d8:	4629                	li	a2,10
 6da:	000ba583          	lw	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	df7ff0ef          	jal	4d6 <printint>
        i += 2;
 6e4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
        i += 2;
 6ea:	bdf9                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 6ec:	008b8913          	addi	s2,s7,8
 6f0:	4681                	li	a3,0
 6f2:	4629                	li	a2,10
 6f4:	000ba583          	lw	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	dddff0ef          	jal	4d6 <printint>
 6fe:	8bca                	mv	s7,s2
      state = 0;
 700:	4981                	li	s3,0
 702:	b5d9                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 704:	008b8913          	addi	s2,s7,8
 708:	4681                	li	a3,0
 70a:	4629                	li	a2,10
 70c:	000ba583          	lw	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	dc5ff0ef          	jal	4d6 <printint>
        i += 1;
 716:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
        i += 1;
 71c:	b575                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	008b8913          	addi	s2,s7,8
 722:	4681                	li	a3,0
 724:	4629                	li	a2,10
 726:	000ba583          	lw	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	dabff0ef          	jal	4d6 <printint>
        i += 2;
 730:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	8bca                	mv	s7,s2
      state = 0;
 734:	4981                	li	s3,0
        i += 2;
 736:	bd49                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 738:	008b8913          	addi	s2,s7,8
 73c:	4681                	li	a3,0
 73e:	4641                	li	a2,16
 740:	000ba583          	lw	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	d91ff0ef          	jal	4d6 <printint>
 74a:	8bca                	mv	s7,s2
      state = 0;
 74c:	4981                	li	s3,0
 74e:	bdad                	j	5c8 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 750:	008b8913          	addi	s2,s7,8
 754:	4681                	li	a3,0
 756:	4641                	li	a2,16
 758:	000ba583          	lw	a1,0(s7)
 75c:	855a                	mv	a0,s6
 75e:	d79ff0ef          	jal	4d6 <printint>
        i += 1;
 762:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
        i += 1;
 768:	b585                	j	5c8 <vprintf+0x4a>
 76a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 76c:	008b8d13          	addi	s10,s7,8
 770:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 774:	03000593          	li	a1,48
 778:	855a                	mv	a0,s6
 77a:	d3fff0ef          	jal	4b8 <putc>
  putc(fd, 'x');
 77e:	07800593          	li	a1,120
 782:	855a                	mv	a0,s6
 784:	d35ff0ef          	jal	4b8 <putc>
 788:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 78a:	00000b97          	auipc	s7,0x0
 78e:	2a6b8b93          	addi	s7,s7,678 # a30 <digits>
 792:	03c9d793          	srli	a5,s3,0x3c
 796:	97de                	add	a5,a5,s7
 798:	0007c583          	lbu	a1,0(a5)
 79c:	855a                	mv	a0,s6
 79e:	d1bff0ef          	jal	4b8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7a2:	0992                	slli	s3,s3,0x4
 7a4:	397d                	addiw	s2,s2,-1
 7a6:	fe0916e3          	bnez	s2,792 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 7aa:	8bea                	mv	s7,s10
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	6d02                	ld	s10,0(sp)
 7b0:	bd21                	j	5c8 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7b2:	008b8993          	addi	s3,s7,8
 7b6:	000bb903          	ld	s2,0(s7)
 7ba:	00090f63          	beqz	s2,7d8 <vprintf+0x25a>
        for(; *s; s++)
 7be:	00094583          	lbu	a1,0(s2)
 7c2:	c195                	beqz	a1,7e6 <vprintf+0x268>
          putc(fd, *s);
 7c4:	855a                	mv	a0,s6
 7c6:	cf3ff0ef          	jal	4b8 <putc>
        for(; *s; s++)
 7ca:	0905                	addi	s2,s2,1
 7cc:	00094583          	lbu	a1,0(s2)
 7d0:	f9f5                	bnez	a1,7c4 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7d2:	8bce                	mv	s7,s3
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	bbcd                	j	5c8 <vprintf+0x4a>
          s = "(null)";
 7d8:	00000917          	auipc	s2,0x0
 7dc:	25090913          	addi	s2,s2,592 # a28 <malloc+0x144>
        for(; *s; s++)
 7e0:	02800593          	li	a1,40
 7e4:	b7c5                	j	7c4 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7e6:	8bce                	mv	s7,s3
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	bbf9                	j	5c8 <vprintf+0x4a>
 7ec:	64a6                	ld	s1,72(sp)
 7ee:	79e2                	ld	s3,56(sp)
 7f0:	7a42                	ld	s4,48(sp)
 7f2:	7aa2                	ld	s5,40(sp)
 7f4:	7b02                	ld	s6,32(sp)
 7f6:	6be2                	ld	s7,24(sp)
 7f8:	6c42                	ld	s8,16(sp)
 7fa:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7fc:	60e6                	ld	ra,88(sp)
 7fe:	6446                	ld	s0,80(sp)
 800:	6906                	ld	s2,64(sp)
 802:	6125                	addi	sp,sp,96
 804:	8082                	ret

0000000000000806 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 806:	715d                	addi	sp,sp,-80
 808:	ec06                	sd	ra,24(sp)
 80a:	e822                	sd	s0,16(sp)
 80c:	1000                	addi	s0,sp,32
 80e:	e010                	sd	a2,0(s0)
 810:	e414                	sd	a3,8(s0)
 812:	e818                	sd	a4,16(s0)
 814:	ec1c                	sd	a5,24(s0)
 816:	03043023          	sd	a6,32(s0)
 81a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 822:	8622                	mv	a2,s0
 824:	d5bff0ef          	jal	57e <vprintf>
}
 828:	60e2                	ld	ra,24(sp)
 82a:	6442                	ld	s0,16(sp)
 82c:	6161                	addi	sp,sp,80
 82e:	8082                	ret

0000000000000830 <printf>:

void
printf(const char *fmt, ...)
{
 830:	711d                	addi	sp,sp,-96
 832:	ec06                	sd	ra,24(sp)
 834:	e822                	sd	s0,16(sp)
 836:	1000                	addi	s0,sp,32
 838:	e40c                	sd	a1,8(s0)
 83a:	e810                	sd	a2,16(s0)
 83c:	ec14                	sd	a3,24(s0)
 83e:	f018                	sd	a4,32(s0)
 840:	f41c                	sd	a5,40(s0)
 842:	03043823          	sd	a6,48(s0)
 846:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 84a:	00840613          	addi	a2,s0,8
 84e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 852:	85aa                	mv	a1,a0
 854:	4505                	li	a0,1
 856:	d29ff0ef          	jal	57e <vprintf>
}
 85a:	60e2                	ld	ra,24(sp)
 85c:	6442                	ld	s0,16(sp)
 85e:	6125                	addi	sp,sp,96
 860:	8082                	ret

0000000000000862 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 862:	1141                	addi	sp,sp,-16
 864:	e422                	sd	s0,8(sp)
 866:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 868:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86c:	00000797          	auipc	a5,0x0
 870:	7947b783          	ld	a5,1940(a5) # 1000 <freep>
 874:	a02d                	j	89e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 876:	4618                	lw	a4,8(a2)
 878:	9f2d                	addw	a4,a4,a1
 87a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 87e:	6398                	ld	a4,0(a5)
 880:	6310                	ld	a2,0(a4)
 882:	a83d                	j	8c0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 884:	ff852703          	lw	a4,-8(a0)
 888:	9f31                	addw	a4,a4,a2
 88a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 88c:	ff053683          	ld	a3,-16(a0)
 890:	a091                	j	8d4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 892:	6398                	ld	a4,0(a5)
 894:	00e7e463          	bltu	a5,a4,89c <free+0x3a>
 898:	00e6ea63          	bltu	a3,a4,8ac <free+0x4a>
{
 89c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89e:	fed7fae3          	bgeu	a5,a3,892 <free+0x30>
 8a2:	6398                	ld	a4,0(a5)
 8a4:	00e6e463          	bltu	a3,a4,8ac <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a8:	fee7eae3          	bltu	a5,a4,89c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ac:	ff852583          	lw	a1,-8(a0)
 8b0:	6390                	ld	a2,0(a5)
 8b2:	02059813          	slli	a6,a1,0x20
 8b6:	01c85713          	srli	a4,a6,0x1c
 8ba:	9736                	add	a4,a4,a3
 8bc:	fae60de3          	beq	a2,a4,876 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8c0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8c4:	4790                	lw	a2,8(a5)
 8c6:	02061593          	slli	a1,a2,0x20
 8ca:	01c5d713          	srli	a4,a1,0x1c
 8ce:	973e                	add	a4,a4,a5
 8d0:	fae68ae3          	beq	a3,a4,884 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8d4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8d6:	00000717          	auipc	a4,0x0
 8da:	72f73523          	sd	a5,1834(a4) # 1000 <freep>
}
 8de:	6422                	ld	s0,8(sp)
 8e0:	0141                	addi	sp,sp,16
 8e2:	8082                	ret

00000000000008e4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e4:	7139                	addi	sp,sp,-64
 8e6:	fc06                	sd	ra,56(sp)
 8e8:	f822                	sd	s0,48(sp)
 8ea:	f426                	sd	s1,40(sp)
 8ec:	ec4e                	sd	s3,24(sp)
 8ee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8f0:	02051493          	slli	s1,a0,0x20
 8f4:	9081                	srli	s1,s1,0x20
 8f6:	04bd                	addi	s1,s1,15
 8f8:	8091                	srli	s1,s1,0x4
 8fa:	0014899b          	addiw	s3,s1,1
 8fe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 900:	00000517          	auipc	a0,0x0
 904:	70053503          	ld	a0,1792(a0) # 1000 <freep>
 908:	c915                	beqz	a0,93c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90c:	4798                	lw	a4,8(a5)
 90e:	08977a63          	bgeu	a4,s1,9a2 <malloc+0xbe>
 912:	f04a                	sd	s2,32(sp)
 914:	e852                	sd	s4,16(sp)
 916:	e456                	sd	s5,8(sp)
 918:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 91a:	8a4e                	mv	s4,s3
 91c:	0009871b          	sext.w	a4,s3
 920:	6685                	lui	a3,0x1
 922:	00d77363          	bgeu	a4,a3,928 <malloc+0x44>
 926:	6a05                	lui	s4,0x1
 928:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 92c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 930:	00000917          	auipc	s2,0x0
 934:	6d090913          	addi	s2,s2,1744 # 1000 <freep>
  if(p == (char*)-1)
 938:	5afd                	li	s5,-1
 93a:	a081                	j	97a <malloc+0x96>
 93c:	f04a                	sd	s2,32(sp)
 93e:	e852                	sd	s4,16(sp)
 940:	e456                	sd	s5,8(sp)
 942:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 944:	00001797          	auipc	a5,0x1
 948:	8cc78793          	addi	a5,a5,-1844 # 1210 <base>
 94c:	00000717          	auipc	a4,0x0
 950:	6af73a23          	sd	a5,1716(a4) # 1000 <freep>
 954:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 956:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 95a:	b7c1                	j	91a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 95c:	6398                	ld	a4,0(a5)
 95e:	e118                	sd	a4,0(a0)
 960:	a8a9                	j	9ba <malloc+0xd6>
  hp->s.size = nu;
 962:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 966:	0541                	addi	a0,a0,16
 968:	efbff0ef          	jal	862 <free>
  return freep;
 96c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 970:	c12d                	beqz	a0,9d2 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 972:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 974:	4798                	lw	a4,8(a5)
 976:	02977263          	bgeu	a4,s1,99a <malloc+0xb6>
    if(p == freep)
 97a:	00093703          	ld	a4,0(s2)
 97e:	853e                	mv	a0,a5
 980:	fef719e3          	bne	a4,a5,972 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 984:	8552                	mv	a0,s4
 986:	b1bff0ef          	jal	4a0 <sbrk>
  if(p == (char*)-1)
 98a:	fd551ce3          	bne	a0,s5,962 <malloc+0x7e>
        return 0;
 98e:	4501                	li	a0,0
 990:	7902                	ld	s2,32(sp)
 992:	6a42                	ld	s4,16(sp)
 994:	6aa2                	ld	s5,8(sp)
 996:	6b02                	ld	s6,0(sp)
 998:	a03d                	j	9c6 <malloc+0xe2>
 99a:	7902                	ld	s2,32(sp)
 99c:	6a42                	ld	s4,16(sp)
 99e:	6aa2                	ld	s5,8(sp)
 9a0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9a2:	fae48de3          	beq	s1,a4,95c <malloc+0x78>
        p->s.size -= nunits;
 9a6:	4137073b          	subw	a4,a4,s3
 9aa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ac:	02071693          	slli	a3,a4,0x20
 9b0:	01c6d713          	srli	a4,a3,0x1c
 9b4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9b6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9ba:	00000717          	auipc	a4,0x0
 9be:	64a73323          	sd	a0,1606(a4) # 1000 <freep>
      return (void*)(p + 1);
 9c2:	01078513          	addi	a0,a5,16
  }
}
 9c6:	70e2                	ld	ra,56(sp)
 9c8:	7442                	ld	s0,48(sp)
 9ca:	74a2                	ld	s1,40(sp)
 9cc:	69e2                	ld	s3,24(sp)
 9ce:	6121                	addi	sp,sp,64
 9d0:	8082                	ret
 9d2:	7902                	ld	s2,32(sp)
 9d4:	6a42                	ld	s4,16(sp)
 9d6:	6aa2                	ld	s5,8(sp)
 9d8:	6b02                	ld	s6,0(sp)
 9da:	b7f5                	j	9c6 <malloc+0xe2>
