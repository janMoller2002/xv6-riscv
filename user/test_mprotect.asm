
user/_test_mprotect:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"

int main() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
    char *addr = sbrk(0);  // Obtener la dirección actual del heap
   a:	4501                	li	a0,0
   c:	388000ef          	jal	394 <sbrk>
  10:	84aa                	mv	s1,a0
    sbrk(4096);  // Reservar una página (4096 bytes)
  12:	6505                	lui	a0,0x1
  14:	380000ef          	jal	394 <sbrk>

    // Intentar proteger la nueva página
    if (mprotect(addr, 1) == -1) {
  18:	4585                	li	a1,1
  1a:	8526                	mv	a0,s1
  1c:	390000ef          	jal	3ac <mprotect>
  20:	57fd                	li	a5,-1
  22:	04f50e63          	beq	a0,a5,7e <main+0x7e>
        exit(1);
    }

    // Intentar escribir en la página protegida
    char *ptr = addr;
    printf("Intentando escribir en la página protegida...\n");
  26:	00001517          	auipc	a0,0x1
  2a:	8d250513          	addi	a0,a0,-1838 # 8f8 <malloc+0x110>
  2e:	706000ef          	jal	734 <printf>
    *ptr = 'A';  // Esto debería fallar si la protección es exitosa
  32:	04100793          	li	a5,65
  36:	00f48023          	sb	a5,0(s1)

    // Si el sistema de protección funciona, no debería llegar aquí sin un error
    printf("Error: Escritura en página protegida no falló como se esperaba.\n");
  3a:	00001517          	auipc	a0,0x1
  3e:	8ee50513          	addi	a0,a0,-1810 # 928 <malloc+0x140>
  42:	6f2000ef          	jal	734 <printf>

    // Ahora desprotegemos la página
    if (munprotect(addr, 1) == -1) {
  46:	4585                	li	a1,1
  48:	8526                	mv	a0,s1
  4a:	36a000ef          	jal	3b4 <munprotect>
  4e:	57fd                	li	a5,-1
  50:	04f50063          	beq	a0,a5,90 <main+0x90>
        printf("munprotect falló\n");
        exit(1);
    }

    // Intentar escribir nuevamente en la página después de desprotegerla
    printf("Intentando escribir en la página desprotegida...\n");
  54:	00001517          	auipc	a0,0x1
  58:	93450513          	addi	a0,a0,-1740 # 988 <malloc+0x1a0>
  5c:	6d8000ef          	jal	734 <printf>
    *ptr = 'B';  // Esto debería tener éxito
  60:	04200793          	li	a5,66
  64:	00f48023          	sb	a5,0(s1)
    printf("Escritura exitosa en la página desprotegida, valor: %c\n", *ptr);
  68:	04200593          	li	a1,66
  6c:	00001517          	auipc	a0,0x1
  70:	95450513          	addi	a0,a0,-1708 # 9c0 <malloc+0x1d8>
  74:	6c0000ef          	jal	734 <printf>

    exit(0);
  78:	4501                	li	a0,0
  7a:	292000ef          	jal	30c <exit>
        printf("mprotect falló\n");
  7e:	00001517          	auipc	a0,0x1
  82:	86250513          	addi	a0,a0,-1950 # 8e0 <malloc+0xf8>
  86:	6ae000ef          	jal	734 <printf>
        exit(1);
  8a:	4505                	li	a0,1
  8c:	280000ef          	jal	30c <exit>
        printf("munprotect falló\n");
  90:	00001517          	auipc	a0,0x1
  94:	8e050513          	addi	a0,a0,-1824 # 970 <malloc+0x188>
  98:	69c000ef          	jal	734 <printf>
        exit(1);
  9c:	4505                	li	a0,1
  9e:	26e000ef          	jal	30c <exit>

00000000000000a2 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e406                	sd	ra,8(sp)
  a6:	e022                	sd	s0,0(sp)
  a8:	0800                	addi	s0,sp,16
  extern int main();
  main();
  aa:	f57ff0ef          	jal	0 <main>
  exit(0);
  ae:	4501                	li	a0,0
  b0:	25c000ef          	jal	30c <exit>

00000000000000b4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ba:	87aa                	mv	a5,a0
  bc:	0585                	addi	a1,a1,1
  be:	0785                	addi	a5,a5,1
  c0:	fff5c703          	lbu	a4,-1(a1)
  c4:	fee78fa3          	sb	a4,-1(a5)
  c8:	fb75                	bnez	a4,bc <strcpy+0x8>
    ;
  return os;
}
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	addi	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cb91                	beqz	a5,ee <strcmp+0x1e>
  dc:	0005c703          	lbu	a4,0(a1)
  e0:	00f71763          	bne	a4,a5,ee <strcmp+0x1e>
    p++, q++;
  e4:	0505                	addi	a0,a0,1
  e6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	fbe5                	bnez	a5,dc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ee:	0005c503          	lbu	a0,0(a1)
}
  f2:	40a7853b          	subw	a0,a5,a0
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strlen>:

uint
strlen(const char *s)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cf91                	beqz	a5,122 <strlen+0x26>
 108:	0505                	addi	a0,a0,1
 10a:	87aa                	mv	a5,a0
 10c:	86be                	mv	a3,a5
 10e:	0785                	addi	a5,a5,1
 110:	fff7c703          	lbu	a4,-1(a5)
 114:	ff65                	bnez	a4,10c <strlen+0x10>
 116:	40a6853b          	subw	a0,a3,a0
 11a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	addi	sp,sp,16
 120:	8082                	ret
  for(n = 0; s[n]; n++)
 122:	4501                	li	a0,0
 124:	bfe5                	j	11c <strlen+0x20>

0000000000000126 <memset>:

void*
memset(void *dst, int c, uint n)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12c:	ca19                	beqz	a2,142 <memset+0x1c>
 12e:	87aa                	mv	a5,a0
 130:	1602                	slli	a2,a2,0x20
 132:	9201                	srli	a2,a2,0x20
 134:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 138:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13c:	0785                	addi	a5,a5,1
 13e:	fee79de3          	bne	a5,a4,138 <memset+0x12>
  }
  return dst;
}
 142:	6422                	ld	s0,8(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret

0000000000000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cb99                	beqz	a5,168 <strchr+0x20>
    if(*s == c)
 154:	00f58763          	beq	a1,a5,162 <strchr+0x1a>
  for(; *s; s++)
 158:	0505                	addi	a0,a0,1
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbfd                	bnez	a5,154 <strchr+0xc>
      return (char*)s;
  return 0;
 160:	4501                	li	a0,0
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret
  return 0;
 168:	4501                	li	a0,0
 16a:	bfe5                	j	162 <strchr+0x1a>

000000000000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	711d                	addi	sp,sp,-96
 16e:	ec86                	sd	ra,88(sp)
 170:	e8a2                	sd	s0,80(sp)
 172:	e4a6                	sd	s1,72(sp)
 174:	e0ca                	sd	s2,64(sp)
 176:	fc4e                	sd	s3,56(sp)
 178:	f852                	sd	s4,48(sp)
 17a:	f456                	sd	s5,40(sp)
 17c:	f05a                	sd	s6,32(sp)
 17e:	ec5e                	sd	s7,24(sp)
 180:	1080                	addi	s0,sp,96
 182:	8baa                	mv	s7,a0
 184:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	892a                	mv	s2,a0
 188:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18a:	4aa9                	li	s5,10
 18c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 18e:	89a6                	mv	s3,s1
 190:	2485                	addiw	s1,s1,1
 192:	0344d663          	bge	s1,s4,1be <gets+0x52>
    cc = read(0, &c, 1);
 196:	4605                	li	a2,1
 198:	faf40593          	addi	a1,s0,-81
 19c:	4501                	li	a0,0
 19e:	186000ef          	jal	324 <read>
    if(cc < 1)
 1a2:	00a05e63          	blez	a0,1be <gets+0x52>
    buf[i++] = c;
 1a6:	faf44783          	lbu	a5,-81(s0)
 1aa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ae:	01578763          	beq	a5,s5,1bc <gets+0x50>
 1b2:	0905                	addi	s2,s2,1
 1b4:	fd679de3          	bne	a5,s6,18e <gets+0x22>
    buf[i++] = c;
 1b8:	89a6                	mv	s3,s1
 1ba:	a011                	j	1be <gets+0x52>
 1bc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1be:	99de                	add	s3,s3,s7
 1c0:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c4:	855e                	mv	a0,s7
 1c6:	60e6                	ld	ra,88(sp)
 1c8:	6446                	ld	s0,80(sp)
 1ca:	64a6                	ld	s1,72(sp)
 1cc:	6906                	ld	s2,64(sp)
 1ce:	79e2                	ld	s3,56(sp)
 1d0:	7a42                	ld	s4,48(sp)
 1d2:	7aa2                	ld	s5,40(sp)
 1d4:	7b02                	ld	s6,32(sp)
 1d6:	6be2                	ld	s7,24(sp)
 1d8:	6125                	addi	sp,sp,96
 1da:	8082                	ret

00000000000001dc <stat>:

int
stat(const char *n, struct stat *st)
{
 1dc:	1101                	addi	sp,sp,-32
 1de:	ec06                	sd	ra,24(sp)
 1e0:	e822                	sd	s0,16(sp)
 1e2:	e04a                	sd	s2,0(sp)
 1e4:	1000                	addi	s0,sp,32
 1e6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e8:	4581                	li	a1,0
 1ea:	162000ef          	jal	34c <open>
  if(fd < 0)
 1ee:	02054263          	bltz	a0,212 <stat+0x36>
 1f2:	e426                	sd	s1,8(sp)
 1f4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f6:	85ca                	mv	a1,s2
 1f8:	16c000ef          	jal	364 <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	134000ef          	jal	334 <close>
  return r;
 204:	64a2                	ld	s1,8(sp)
}
 206:	854a                	mv	a0,s2
 208:	60e2                	ld	ra,24(sp)
 20a:	6442                	ld	s0,16(sp)
 20c:	6902                	ld	s2,0(sp)
 20e:	6105                	addi	sp,sp,32
 210:	8082                	ret
    return -1;
 212:	597d                	li	s2,-1
 214:	bfcd                	j	206 <stat+0x2a>

0000000000000216 <atoi>:

int
atoi(const char *s)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21c:	00054683          	lbu	a3,0(a0)
 220:	fd06879b          	addiw	a5,a3,-48
 224:	0ff7f793          	zext.b	a5,a5
 228:	4625                	li	a2,9
 22a:	02f66863          	bltu	a2,a5,25a <atoi+0x44>
 22e:	872a                	mv	a4,a0
  n = 0;
 230:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 232:	0705                	addi	a4,a4,1
 234:	0025179b          	slliw	a5,a0,0x2
 238:	9fa9                	addw	a5,a5,a0
 23a:	0017979b          	slliw	a5,a5,0x1
 23e:	9fb5                	addw	a5,a5,a3
 240:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 244:	00074683          	lbu	a3,0(a4)
 248:	fd06879b          	addiw	a5,a3,-48
 24c:	0ff7f793          	zext.b	a5,a5
 250:	fef671e3          	bgeu	a2,a5,232 <atoi+0x1c>
  return n;
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
  n = 0;
 25a:	4501                	li	a0,0
 25c:	bfe5                	j	254 <atoi+0x3e>

000000000000025e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 264:	02b57463          	bgeu	a0,a1,28c <memmove+0x2e>
    while(n-- > 0)
 268:	00c05f63          	blez	a2,286 <memmove+0x28>
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 274:	872a                	mv	a4,a0
      *dst++ = *src++;
 276:	0585                	addi	a1,a1,1
 278:	0705                	addi	a4,a4,1
 27a:	fff5c683          	lbu	a3,-1(a1)
 27e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 282:	fef71ae3          	bne	a4,a5,276 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret
    dst += n;
 28c:	00c50733          	add	a4,a0,a2
    src += n;
 290:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 292:	fec05ae3          	blez	a2,286 <memmove+0x28>
 296:	fff6079b          	addiw	a5,a2,-1
 29a:	1782                	slli	a5,a5,0x20
 29c:	9381                	srli	a5,a5,0x20
 29e:	fff7c793          	not	a5,a5
 2a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a4:	15fd                	addi	a1,a1,-1
 2a6:	177d                	addi	a4,a4,-1
 2a8:	0005c683          	lbu	a3,0(a1)
 2ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b0:	fee79ae3          	bne	a5,a4,2a4 <memmove+0x46>
 2b4:	bfc9                	j	286 <memmove+0x28>

00000000000002b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2b6:	1141                	addi	sp,sp,-16
 2b8:	e422                	sd	s0,8(sp)
 2ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2bc:	ca05                	beqz	a2,2ec <memcmp+0x36>
 2be:	fff6069b          	addiw	a3,a2,-1
 2c2:	1682                	slli	a3,a3,0x20
 2c4:	9281                	srli	a3,a3,0x20
 2c6:	0685                	addi	a3,a3,1
 2c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	0005c703          	lbu	a4,0(a1)
 2d2:	00e79863          	bne	a5,a4,2e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2d6:	0505                	addi	a0,a0,1
    p2++;
 2d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2da:	fed518e3          	bne	a0,a3,2ca <memcmp+0x14>
  }
  return 0;
 2de:	4501                	li	a0,0
 2e0:	a019                	j	2e6 <memcmp+0x30>
      return *p1 - *p2;
 2e2:	40e7853b          	subw	a0,a5,a4
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret
  return 0;
 2ec:	4501                	li	a0,0
 2ee:	bfe5                	j	2e6 <memcmp+0x30>

00000000000002f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f0:	1141                	addi	sp,sp,-16
 2f2:	e406                	sd	ra,8(sp)
 2f4:	e022                	sd	s0,0(sp)
 2f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2f8:	f67ff0ef          	jal	25e <memmove>
}
 2fc:	60a2                	ld	ra,8(sp)
 2fe:	6402                	ld	s0,0(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret

0000000000000304 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 304:	4885                	li	a7,1
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <exit>:
.global exit
exit:
 li a7, SYS_exit
 30c:	4889                	li	a7,2
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <wait>:
.global wait
wait:
 li a7, SYS_wait
 314:	488d                	li	a7,3
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 31c:	4891                	li	a7,4
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <read>:
.global read
read:
 li a7, SYS_read
 324:	4895                	li	a7,5
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <write>:
.global write
write:
 li a7, SYS_write
 32c:	48c1                	li	a7,16
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <close>:
.global close
close:
 li a7, SYS_close
 334:	48d5                	li	a7,21
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <kill>:
.global kill
kill:
 li a7, SYS_kill
 33c:	4899                	li	a7,6
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <exec>:
.global exec
exec:
 li a7, SYS_exec
 344:	489d                	li	a7,7
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <open>:
.global open
open:
 li a7, SYS_open
 34c:	48bd                	li	a7,15
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 354:	48c5                	li	a7,17
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 35c:	48c9                	li	a7,18
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 364:	48a1                	li	a7,8
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <link>:
.global link
link:
 li a7, SYS_link
 36c:	48cd                	li	a7,19
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 374:	48d1                	li	a7,20
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 37c:	48a5                	li	a7,9
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <dup>:
.global dup
dup:
 li a7, SYS_dup
 384:	48a9                	li	a7,10
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 38c:	48ad                	li	a7,11
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 394:	48b1                	li	a7,12
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 39c:	48b5                	li	a7,13
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a4:	48b9                	li	a7,14
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mprotect>:
.global mprotect
mprotect:
    li a7, SYS_mprotect  
 3ac:	48d9                	li	a7,22
    ecall
 3ae:	00000073          	ecall
    ret
 3b2:	8082                	ret

00000000000003b4 <munprotect>:
.global munprotect
munprotect:
    li a7, SYS_munprotect
 3b4:	48dd                	li	a7,23
    ecall
 3b6:	00000073          	ecall
    ret
 3ba:	8082                	ret

00000000000003bc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3bc:	1101                	addi	sp,sp,-32
 3be:	ec06                	sd	ra,24(sp)
 3c0:	e822                	sd	s0,16(sp)
 3c2:	1000                	addi	s0,sp,32
 3c4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c8:	4605                	li	a2,1
 3ca:	fef40593          	addi	a1,s0,-17
 3ce:	f5fff0ef          	jal	32c <write>
}
 3d2:	60e2                	ld	ra,24(sp)
 3d4:	6442                	ld	s0,16(sp)
 3d6:	6105                	addi	sp,sp,32
 3d8:	8082                	ret

00000000000003da <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3da:	7139                	addi	sp,sp,-64
 3dc:	fc06                	sd	ra,56(sp)
 3de:	f822                	sd	s0,48(sp)
 3e0:	f426                	sd	s1,40(sp)
 3e2:	0080                	addi	s0,sp,64
 3e4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3e6:	c299                	beqz	a3,3ec <printint+0x12>
 3e8:	0805c963          	bltz	a1,47a <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ec:	2581                	sext.w	a1,a1
  neg = 0;
 3ee:	4881                	li	a7,0
 3f0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3f4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3f6:	2601                	sext.w	a2,a2
 3f8:	00000517          	auipc	a0,0x0
 3fc:	61050513          	addi	a0,a0,1552 # a08 <digits>
 400:	883a                	mv	a6,a4
 402:	2705                	addiw	a4,a4,1
 404:	02c5f7bb          	remuw	a5,a1,a2
 408:	1782                	slli	a5,a5,0x20
 40a:	9381                	srli	a5,a5,0x20
 40c:	97aa                	add	a5,a5,a0
 40e:	0007c783          	lbu	a5,0(a5)
 412:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 416:	0005879b          	sext.w	a5,a1
 41a:	02c5d5bb          	divuw	a1,a1,a2
 41e:	0685                	addi	a3,a3,1
 420:	fec7f0e3          	bgeu	a5,a2,400 <printint+0x26>
  if(neg)
 424:	00088c63          	beqz	a7,43c <printint+0x62>
    buf[i++] = '-';
 428:	fd070793          	addi	a5,a4,-48
 42c:	00878733          	add	a4,a5,s0
 430:	02d00793          	li	a5,45
 434:	fef70823          	sb	a5,-16(a4)
 438:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 43c:	02e05a63          	blez	a4,470 <printint+0x96>
 440:	f04a                	sd	s2,32(sp)
 442:	ec4e                	sd	s3,24(sp)
 444:	fc040793          	addi	a5,s0,-64
 448:	00e78933          	add	s2,a5,a4
 44c:	fff78993          	addi	s3,a5,-1
 450:	99ba                	add	s3,s3,a4
 452:	377d                	addiw	a4,a4,-1
 454:	1702                	slli	a4,a4,0x20
 456:	9301                	srli	a4,a4,0x20
 458:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45c:	fff94583          	lbu	a1,-1(s2)
 460:	8526                	mv	a0,s1
 462:	f5bff0ef          	jal	3bc <putc>
  while(--i >= 0)
 466:	197d                	addi	s2,s2,-1
 468:	ff391ae3          	bne	s2,s3,45c <printint+0x82>
 46c:	7902                	ld	s2,32(sp)
 46e:	69e2                	ld	s3,24(sp)
}
 470:	70e2                	ld	ra,56(sp)
 472:	7442                	ld	s0,48(sp)
 474:	74a2                	ld	s1,40(sp)
 476:	6121                	addi	sp,sp,64
 478:	8082                	ret
    x = -xx;
 47a:	40b005bb          	negw	a1,a1
    neg = 1;
 47e:	4885                	li	a7,1
    x = -xx;
 480:	bf85                	j	3f0 <printint+0x16>

0000000000000482 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 482:	711d                	addi	sp,sp,-96
 484:	ec86                	sd	ra,88(sp)
 486:	e8a2                	sd	s0,80(sp)
 488:	e0ca                	sd	s2,64(sp)
 48a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48c:	0005c903          	lbu	s2,0(a1)
 490:	26090863          	beqz	s2,700 <vprintf+0x27e>
 494:	e4a6                	sd	s1,72(sp)
 496:	fc4e                	sd	s3,56(sp)
 498:	f852                	sd	s4,48(sp)
 49a:	f456                	sd	s5,40(sp)
 49c:	f05a                	sd	s6,32(sp)
 49e:	ec5e                	sd	s7,24(sp)
 4a0:	e862                	sd	s8,16(sp)
 4a2:	e466                	sd	s9,8(sp)
 4a4:	8b2a                	mv	s6,a0
 4a6:	8a2e                	mv	s4,a1
 4a8:	8bb2                	mv	s7,a2
  state = 0;
 4aa:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4ac:	4481                	li	s1,0
 4ae:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4b0:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4b4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4b8:	06c00c93          	li	s9,108
 4bc:	a005                	j	4dc <vprintf+0x5a>
        putc(fd, c0);
 4be:	85ca                	mv	a1,s2
 4c0:	855a                	mv	a0,s6
 4c2:	efbff0ef          	jal	3bc <putc>
 4c6:	a019                	j	4cc <vprintf+0x4a>
    } else if(state == '%'){
 4c8:	03598263          	beq	s3,s5,4ec <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4cc:	2485                	addiw	s1,s1,1
 4ce:	8726                	mv	a4,s1
 4d0:	009a07b3          	add	a5,s4,s1
 4d4:	0007c903          	lbu	s2,0(a5)
 4d8:	20090c63          	beqz	s2,6f0 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 4dc:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4e0:	fe0994e3          	bnez	s3,4c8 <vprintf+0x46>
      if(c0 == '%'){
 4e4:	fd579de3          	bne	a5,s5,4be <vprintf+0x3c>
        state = '%';
 4e8:	89be                	mv	s3,a5
 4ea:	b7cd                	j	4cc <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4ec:	00ea06b3          	add	a3,s4,a4
 4f0:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4f4:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4f6:	c681                	beqz	a3,4fe <vprintf+0x7c>
 4f8:	9752                	add	a4,a4,s4
 4fa:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4fe:	03878f63          	beq	a5,s8,53c <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 502:	05978963          	beq	a5,s9,554 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 506:	07500713          	li	a4,117
 50a:	0ee78363          	beq	a5,a4,5f0 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 50e:	07800713          	li	a4,120
 512:	12e78563          	beq	a5,a4,63c <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 516:	07000713          	li	a4,112
 51a:	14e78a63          	beq	a5,a4,66e <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 51e:	07300713          	li	a4,115
 522:	18e78a63          	beq	a5,a4,6b6 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 526:	02500713          	li	a4,37
 52a:	04e79563          	bne	a5,a4,574 <vprintf+0xf2>
        putc(fd, '%');
 52e:	02500593          	li	a1,37
 532:	855a                	mv	a0,s6
 534:	e89ff0ef          	jal	3bc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 538:	4981                	li	s3,0
 53a:	bf49                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 53c:	008b8913          	addi	s2,s7,8
 540:	4685                	li	a3,1
 542:	4629                	li	a2,10
 544:	000ba583          	lw	a1,0(s7)
 548:	855a                	mv	a0,s6
 54a:	e91ff0ef          	jal	3da <printint>
 54e:	8bca                	mv	s7,s2
      state = 0;
 550:	4981                	li	s3,0
 552:	bfad                	j	4cc <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 554:	06400793          	li	a5,100
 558:	02f68963          	beq	a3,a5,58a <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 55c:	06c00793          	li	a5,108
 560:	04f68263          	beq	a3,a5,5a4 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 564:	07500793          	li	a5,117
 568:	0af68063          	beq	a3,a5,608 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 56c:	07800793          	li	a5,120
 570:	0ef68263          	beq	a3,a5,654 <vprintf+0x1d2>
        putc(fd, '%');
 574:	02500593          	li	a1,37
 578:	855a                	mv	a0,s6
 57a:	e43ff0ef          	jal	3bc <putc>
        putc(fd, c0);
 57e:	85ca                	mv	a1,s2
 580:	855a                	mv	a0,s6
 582:	e3bff0ef          	jal	3bc <putc>
      state = 0;
 586:	4981                	li	s3,0
 588:	b791                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 58a:	008b8913          	addi	s2,s7,8
 58e:	4685                	li	a3,1
 590:	4629                	li	a2,10
 592:	000ba583          	lw	a1,0(s7)
 596:	855a                	mv	a0,s6
 598:	e43ff0ef          	jal	3da <printint>
        i += 1;
 59c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 59e:	8bca                	mv	s7,s2
      state = 0;
 5a0:	4981                	li	s3,0
        i += 1;
 5a2:	b72d                	j	4cc <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a4:	06400793          	li	a5,100
 5a8:	02f60763          	beq	a2,a5,5d6 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5ac:	07500793          	li	a5,117
 5b0:	06f60963          	beq	a2,a5,622 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5b4:	07800793          	li	a5,120
 5b8:	faf61ee3          	bne	a2,a5,574 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4681                	li	a3,0
 5c2:	4641                	li	a2,16
 5c4:	000ba583          	lw	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	e11ff0ef          	jal	3da <printint>
        i += 2;
 5ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
        i += 2;
 5d4:	bde5                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4685                	li	a3,1
 5dc:	4629                	li	a2,10
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	df7ff0ef          	jal	3da <printint>
        i += 2;
 5e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
        i += 2;
 5ee:	bdf9                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5f0:	008b8913          	addi	s2,s7,8
 5f4:	4681                	li	a3,0
 5f6:	4629                	li	a2,10
 5f8:	000ba583          	lw	a1,0(s7)
 5fc:	855a                	mv	a0,s6
 5fe:	dddff0ef          	jal	3da <printint>
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	b5d9                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 608:	008b8913          	addi	s2,s7,8
 60c:	4681                	li	a3,0
 60e:	4629                	li	a2,10
 610:	000ba583          	lw	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	dc5ff0ef          	jal	3da <printint>
        i += 1;
 61a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 1;
 620:	b575                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000ba583          	lw	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	dabff0ef          	jal	3da <printint>
        i += 2;
 634:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 636:	8bca                	mv	s7,s2
      state = 0;
 638:	4981                	li	s3,0
        i += 2;
 63a:	bd49                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 63c:	008b8913          	addi	s2,s7,8
 640:	4681                	li	a3,0
 642:	4641                	li	a2,16
 644:	000ba583          	lw	a1,0(s7)
 648:	855a                	mv	a0,s6
 64a:	d91ff0ef          	jal	3da <printint>
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	bdad                	j	4cc <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 654:	008b8913          	addi	s2,s7,8
 658:	4681                	li	a3,0
 65a:	4641                	li	a2,16
 65c:	000ba583          	lw	a1,0(s7)
 660:	855a                	mv	a0,s6
 662:	d79ff0ef          	jal	3da <printint>
        i += 1;
 666:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 668:	8bca                	mv	s7,s2
      state = 0;
 66a:	4981                	li	s3,0
        i += 1;
 66c:	b585                	j	4cc <vprintf+0x4a>
 66e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 670:	008b8d13          	addi	s10,s7,8
 674:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 678:	03000593          	li	a1,48
 67c:	855a                	mv	a0,s6
 67e:	d3fff0ef          	jal	3bc <putc>
  putc(fd, 'x');
 682:	07800593          	li	a1,120
 686:	855a                	mv	a0,s6
 688:	d35ff0ef          	jal	3bc <putc>
 68c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68e:	00000b97          	auipc	s7,0x0
 692:	37ab8b93          	addi	s7,s7,890 # a08 <digits>
 696:	03c9d793          	srli	a5,s3,0x3c
 69a:	97de                	add	a5,a5,s7
 69c:	0007c583          	lbu	a1,0(a5)
 6a0:	855a                	mv	a0,s6
 6a2:	d1bff0ef          	jal	3bc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a6:	0992                	slli	s3,s3,0x4
 6a8:	397d                	addiw	s2,s2,-1
 6aa:	fe0916e3          	bnez	s2,696 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6ae:	8bea                	mv	s7,s10
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	6d02                	ld	s10,0(sp)
 6b4:	bd21                	j	4cc <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6b6:	008b8993          	addi	s3,s7,8
 6ba:	000bb903          	ld	s2,0(s7)
 6be:	00090f63          	beqz	s2,6dc <vprintf+0x25a>
        for(; *s; s++)
 6c2:	00094583          	lbu	a1,0(s2)
 6c6:	c195                	beqz	a1,6ea <vprintf+0x268>
          putc(fd, *s);
 6c8:	855a                	mv	a0,s6
 6ca:	cf3ff0ef          	jal	3bc <putc>
        for(; *s; s++)
 6ce:	0905                	addi	s2,s2,1
 6d0:	00094583          	lbu	a1,0(s2)
 6d4:	f9f5                	bnez	a1,6c8 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6d6:	8bce                	mv	s7,s3
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bbcd                	j	4cc <vprintf+0x4a>
          s = "(null)";
 6dc:	00000917          	auipc	s2,0x0
 6e0:	32490913          	addi	s2,s2,804 # a00 <malloc+0x218>
        for(; *s; s++)
 6e4:	02800593          	li	a1,40
 6e8:	b7c5                	j	6c8 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6ea:	8bce                	mv	s7,s3
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bbf9                	j	4cc <vprintf+0x4a>
 6f0:	64a6                	ld	s1,72(sp)
 6f2:	79e2                	ld	s3,56(sp)
 6f4:	7a42                	ld	s4,48(sp)
 6f6:	7aa2                	ld	s5,40(sp)
 6f8:	7b02                	ld	s6,32(sp)
 6fa:	6be2                	ld	s7,24(sp)
 6fc:	6c42                	ld	s8,16(sp)
 6fe:	6ca2                	ld	s9,8(sp)
    }
  }
}
 700:	60e6                	ld	ra,88(sp)
 702:	6446                	ld	s0,80(sp)
 704:	6906                	ld	s2,64(sp)
 706:	6125                	addi	sp,sp,96
 708:	8082                	ret

000000000000070a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70a:	715d                	addi	sp,sp,-80
 70c:	ec06                	sd	ra,24(sp)
 70e:	e822                	sd	s0,16(sp)
 710:	1000                	addi	s0,sp,32
 712:	e010                	sd	a2,0(s0)
 714:	e414                	sd	a3,8(s0)
 716:	e818                	sd	a4,16(s0)
 718:	ec1c                	sd	a5,24(s0)
 71a:	03043023          	sd	a6,32(s0)
 71e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 722:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 726:	8622                	mv	a2,s0
 728:	d5bff0ef          	jal	482 <vprintf>
}
 72c:	60e2                	ld	ra,24(sp)
 72e:	6442                	ld	s0,16(sp)
 730:	6161                	addi	sp,sp,80
 732:	8082                	ret

0000000000000734 <printf>:

void
printf(const char *fmt, ...)
{
 734:	711d                	addi	sp,sp,-96
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	e40c                	sd	a1,8(s0)
 73e:	e810                	sd	a2,16(s0)
 740:	ec14                	sd	a3,24(s0)
 742:	f018                	sd	a4,32(s0)
 744:	f41c                	sd	a5,40(s0)
 746:	03043823          	sd	a6,48(s0)
 74a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74e:	00840613          	addi	a2,s0,8
 752:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 756:	85aa                	mv	a1,a0
 758:	4505                	li	a0,1
 75a:	d29ff0ef          	jal	482 <vprintf>
}
 75e:	60e2                	ld	ra,24(sp)
 760:	6442                	ld	s0,16(sp)
 762:	6125                	addi	sp,sp,96
 764:	8082                	ret

0000000000000766 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 766:	1141                	addi	sp,sp,-16
 768:	e422                	sd	s0,8(sp)
 76a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 770:	00001797          	auipc	a5,0x1
 774:	8907b783          	ld	a5,-1904(a5) # 1000 <freep>
 778:	a02d                	j	7a2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77a:	4618                	lw	a4,8(a2)
 77c:	9f2d                	addw	a4,a4,a1
 77e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 782:	6398                	ld	a4,0(a5)
 784:	6310                	ld	a2,0(a4)
 786:	a83d                	j	7c4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 788:	ff852703          	lw	a4,-8(a0)
 78c:	9f31                	addw	a4,a4,a2
 78e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 790:	ff053683          	ld	a3,-16(a0)
 794:	a091                	j	7d8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 796:	6398                	ld	a4,0(a5)
 798:	00e7e463          	bltu	a5,a4,7a0 <free+0x3a>
 79c:	00e6ea63          	bltu	a3,a4,7b0 <free+0x4a>
{
 7a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a2:	fed7fae3          	bgeu	a5,a3,796 <free+0x30>
 7a6:	6398                	ld	a4,0(a5)
 7a8:	00e6e463          	bltu	a3,a4,7b0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ac:	fee7eae3          	bltu	a5,a4,7a0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7b0:	ff852583          	lw	a1,-8(a0)
 7b4:	6390                	ld	a2,0(a5)
 7b6:	02059813          	slli	a6,a1,0x20
 7ba:	01c85713          	srli	a4,a6,0x1c
 7be:	9736                	add	a4,a4,a3
 7c0:	fae60de3          	beq	a2,a4,77a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7c4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c8:	4790                	lw	a2,8(a5)
 7ca:	02061593          	slli	a1,a2,0x20
 7ce:	01c5d713          	srli	a4,a1,0x1c
 7d2:	973e                	add	a4,a4,a5
 7d4:	fae68ae3          	beq	a3,a4,788 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7d8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7da:	00001717          	auipc	a4,0x1
 7de:	82f73323          	sd	a5,-2010(a4) # 1000 <freep>
}
 7e2:	6422                	ld	s0,8(sp)
 7e4:	0141                	addi	sp,sp,16
 7e6:	8082                	ret

00000000000007e8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e8:	7139                	addi	sp,sp,-64
 7ea:	fc06                	sd	ra,56(sp)
 7ec:	f822                	sd	s0,48(sp)
 7ee:	f426                	sd	s1,40(sp)
 7f0:	ec4e                	sd	s3,24(sp)
 7f2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f4:	02051493          	slli	s1,a0,0x20
 7f8:	9081                	srli	s1,s1,0x20
 7fa:	04bd                	addi	s1,s1,15
 7fc:	8091                	srli	s1,s1,0x4
 7fe:	0014899b          	addiw	s3,s1,1
 802:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 804:	00000517          	auipc	a0,0x0
 808:	7fc53503          	ld	a0,2044(a0) # 1000 <freep>
 80c:	c915                	beqz	a0,840 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 810:	4798                	lw	a4,8(a5)
 812:	08977a63          	bgeu	a4,s1,8a6 <malloc+0xbe>
 816:	f04a                	sd	s2,32(sp)
 818:	e852                	sd	s4,16(sp)
 81a:	e456                	sd	s5,8(sp)
 81c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 81e:	8a4e                	mv	s4,s3
 820:	0009871b          	sext.w	a4,s3
 824:	6685                	lui	a3,0x1
 826:	00d77363          	bgeu	a4,a3,82c <malloc+0x44>
 82a:	6a05                	lui	s4,0x1
 82c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 830:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 834:	00000917          	auipc	s2,0x0
 838:	7cc90913          	addi	s2,s2,1996 # 1000 <freep>
  if(p == (char*)-1)
 83c:	5afd                	li	s5,-1
 83e:	a081                	j	87e <malloc+0x96>
 840:	f04a                	sd	s2,32(sp)
 842:	e852                	sd	s4,16(sp)
 844:	e456                	sd	s5,8(sp)
 846:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 848:	00000797          	auipc	a5,0x0
 84c:	7c878793          	addi	a5,a5,1992 # 1010 <base>
 850:	00000717          	auipc	a4,0x0
 854:	7af73823          	sd	a5,1968(a4) # 1000 <freep>
 858:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 85e:	b7c1                	j	81e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 860:	6398                	ld	a4,0(a5)
 862:	e118                	sd	a4,0(a0)
 864:	a8a9                	j	8be <malloc+0xd6>
  hp->s.size = nu;
 866:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86a:	0541                	addi	a0,a0,16
 86c:	efbff0ef          	jal	766 <free>
  return freep;
 870:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 874:	c12d                	beqz	a0,8d6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 876:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 878:	4798                	lw	a4,8(a5)
 87a:	02977263          	bgeu	a4,s1,89e <malloc+0xb6>
    if(p == freep)
 87e:	00093703          	ld	a4,0(s2)
 882:	853e                	mv	a0,a5
 884:	fef719e3          	bne	a4,a5,876 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 888:	8552                	mv	a0,s4
 88a:	b0bff0ef          	jal	394 <sbrk>
  if(p == (char*)-1)
 88e:	fd551ce3          	bne	a0,s5,866 <malloc+0x7e>
        return 0;
 892:	4501                	li	a0,0
 894:	7902                	ld	s2,32(sp)
 896:	6a42                	ld	s4,16(sp)
 898:	6aa2                	ld	s5,8(sp)
 89a:	6b02                	ld	s6,0(sp)
 89c:	a03d                	j	8ca <malloc+0xe2>
 89e:	7902                	ld	s2,32(sp)
 8a0:	6a42                	ld	s4,16(sp)
 8a2:	6aa2                	ld	s5,8(sp)
 8a4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8a6:	fae48de3          	beq	s1,a4,860 <malloc+0x78>
        p->s.size -= nunits;
 8aa:	4137073b          	subw	a4,a4,s3
 8ae:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8b0:	02071693          	slli	a3,a4,0x20
 8b4:	01c6d713          	srli	a4,a3,0x1c
 8b8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8ba:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8be:	00000717          	auipc	a4,0x0
 8c2:	74a73123          	sd	a0,1858(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c6:	01078513          	addi	a0,a5,16
  }
}
 8ca:	70e2                	ld	ra,56(sp)
 8cc:	7442                	ld	s0,48(sp)
 8ce:	74a2                	ld	s1,40(sp)
 8d0:	69e2                	ld	s3,24(sp)
 8d2:	6121                	addi	sp,sp,64
 8d4:	8082                	ret
 8d6:	7902                	ld	s2,32(sp)
 8d8:	6a42                	ld	s4,16(sp)
 8da:	6aa2                	ld	s5,8(sp)
 8dc:	6b02                	ld	s6,0(sp)
 8de:	b7f5                	j	8ca <malloc+0xe2>
