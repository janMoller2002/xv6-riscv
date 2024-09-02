
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7119                	addi	sp,sp,-128
      76:	fc86                	sd	ra,120(sp)
      78:	f8a2                	sd	s0,112(sp)
      7a:	f4a6                	sd	s1,104(sp)
      7c:	e4d6                	sd	s5,72(sp)
      7e:	0100                	addi	s0,sp,128
      80:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      82:	4501                	li	a0,0
      84:	3a5000ef          	jal	c28 <sbrk>
      88:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      8a:	00001517          	auipc	a0,0x1
      8e:	0e650513          	addi	a0,a0,230 # 1170 <malloc+0x104>
      92:	377000ef          	jal	c08 <mkdir>
  if(chdir("grindir") != 0){
      96:	00001517          	auipc	a0,0x1
      9a:	0da50513          	addi	a0,a0,218 # 1170 <malloc+0x104>
      9e:	373000ef          	jal	c10 <chdir>
      a2:	cd19                	beqz	a0,c0 <go+0x4c>
      a4:	f0ca                	sd	s2,96(sp)
      a6:	ecce                	sd	s3,88(sp)
      a8:	e8d2                	sd	s4,80(sp)
      aa:	e0da                	sd	s6,64(sp)
      ac:	fc5e                	sd	s7,56(sp)
    printf("grind: chdir grindir failed\n");
      ae:	00001517          	auipc	a0,0x1
      b2:	0ca50513          	addi	a0,a0,202 # 1178 <malloc+0x10c>
      b6:	703000ef          	jal	fb8 <printf>
    exit(1);
      ba:	4505                	li	a0,1
      bc:	2e5000ef          	jal	ba0 <exit>
      c0:	f0ca                	sd	s2,96(sp)
      c2:	ecce                	sd	s3,88(sp)
      c4:	e8d2                	sd	s4,80(sp)
      c6:	e0da                	sd	s6,64(sp)
      c8:	fc5e                	sd	s7,56(sp)
  }
  chdir("/");
      ca:	00001517          	auipc	a0,0x1
      ce:	0d650513          	addi	a0,a0,214 # 11a0 <malloc+0x134>
      d2:	33f000ef          	jal	c10 <chdir>
      d6:	00001997          	auipc	s3,0x1
      da:	0da98993          	addi	s3,s3,218 # 11b0 <malloc+0x144>
      de:	c489                	beqz	s1,e8 <go+0x74>
      e0:	00001997          	auipc	s3,0x1
      e4:	0c898993          	addi	s3,s3,200 # 11a8 <malloc+0x13c>
  uint64 iters = 0;
      e8:	4481                	li	s1,0
  int fd = -1;
      ea:	5a7d                	li	s4,-1
      ec:	00001917          	auipc	s2,0x1
      f0:	39490913          	addi	s2,s2,916 # 1480 <malloc+0x414>
      f4:	a819                	j	10a <go+0x96>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
      f6:	20200593          	li	a1,514
      fa:	00001517          	auipc	a0,0x1
      fe:	0be50513          	addi	a0,a0,190 # 11b8 <malloc+0x14c>
     102:	2df000ef          	jal	be0 <open>
     106:	2c3000ef          	jal	bc8 <close>
    iters++;
     10a:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     10c:	1f400793          	li	a5,500
     110:	02f4f7b3          	remu	a5,s1,a5
     114:	e791                	bnez	a5,120 <go+0xac>
      write(1, which_child?"B":"A", 1);
     116:	4605                	li	a2,1
     118:	85ce                	mv	a1,s3
     11a:	4505                	li	a0,1
     11c:	2a5000ef          	jal	bc0 <write>
    int what = rand() % 23;
     120:	f39ff0ef          	jal	58 <rand>
     124:	47dd                	li	a5,23
     126:	02f5653b          	remw	a0,a0,a5
     12a:	0005071b          	sext.w	a4,a0
     12e:	47d9                	li	a5,22
     130:	fce7ede3          	bltu	a5,a4,10a <go+0x96>
     134:	02051793          	slli	a5,a0,0x20
     138:	01e7d513          	srli	a0,a5,0x1e
     13c:	954a                	add	a0,a0,s2
     13e:	411c                	lw	a5,0(a0)
     140:	97ca                	add	a5,a5,s2
     142:	8782                	jr	a5
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     144:	20200593          	li	a1,514
     148:	00001517          	auipc	a0,0x1
     14c:	08050513          	addi	a0,a0,128 # 11c8 <malloc+0x15c>
     150:	291000ef          	jal	be0 <open>
     154:	275000ef          	jal	bc8 <close>
     158:	bf4d                	j	10a <go+0x96>
    } else if(what == 3){
      unlink("grindir/../a");
     15a:	00001517          	auipc	a0,0x1
     15e:	05e50513          	addi	a0,a0,94 # 11b8 <malloc+0x14c>
     162:	28f000ef          	jal	bf0 <unlink>
     166:	b755                	j	10a <go+0x96>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     168:	00001517          	auipc	a0,0x1
     16c:	00850513          	addi	a0,a0,8 # 1170 <malloc+0x104>
     170:	2a1000ef          	jal	c10 <chdir>
     174:	ed11                	bnez	a0,190 <go+0x11c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     176:	00001517          	auipc	a0,0x1
     17a:	06a50513          	addi	a0,a0,106 # 11e0 <malloc+0x174>
     17e:	273000ef          	jal	bf0 <unlink>
      chdir("/");
     182:	00001517          	auipc	a0,0x1
     186:	01e50513          	addi	a0,a0,30 # 11a0 <malloc+0x134>
     18a:	287000ef          	jal	c10 <chdir>
     18e:	bfb5                	j	10a <go+0x96>
        printf("grind: chdir grindir failed\n");
     190:	00001517          	auipc	a0,0x1
     194:	fe850513          	addi	a0,a0,-24 # 1178 <malloc+0x10c>
     198:	621000ef          	jal	fb8 <printf>
        exit(1);
     19c:	4505                	li	a0,1
     19e:	203000ef          	jal	ba0 <exit>
    } else if(what == 5){
      close(fd);
     1a2:	8552                	mv	a0,s4
     1a4:	225000ef          	jal	bc8 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1a8:	20200593          	li	a1,514
     1ac:	00001517          	auipc	a0,0x1
     1b0:	03c50513          	addi	a0,a0,60 # 11e8 <malloc+0x17c>
     1b4:	22d000ef          	jal	be0 <open>
     1b8:	8a2a                	mv	s4,a0
     1ba:	bf81                	j	10a <go+0x96>
    } else if(what == 6){
      close(fd);
     1bc:	8552                	mv	a0,s4
     1be:	20b000ef          	jal	bc8 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     1c2:	20200593          	li	a1,514
     1c6:	00001517          	auipc	a0,0x1
     1ca:	03250513          	addi	a0,a0,50 # 11f8 <malloc+0x18c>
     1ce:	213000ef          	jal	be0 <open>
     1d2:	8a2a                	mv	s4,a0
     1d4:	bf1d                	j	10a <go+0x96>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     1d6:	3e700613          	li	a2,999
     1da:	00002597          	auipc	a1,0x2
     1de:	e4658593          	addi	a1,a1,-442 # 2020 <buf.0>
     1e2:	8552                	mv	a0,s4
     1e4:	1dd000ef          	jal	bc0 <write>
     1e8:	b70d                	j	10a <go+0x96>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     1ea:	3e700613          	li	a2,999
     1ee:	00002597          	auipc	a1,0x2
     1f2:	e3258593          	addi	a1,a1,-462 # 2020 <buf.0>
     1f6:	8552                	mv	a0,s4
     1f8:	1c1000ef          	jal	bb8 <read>
     1fc:	b739                	j	10a <go+0x96>
    } else if(what == 9){
      mkdir("grindir/../a");
     1fe:	00001517          	auipc	a0,0x1
     202:	fba50513          	addi	a0,a0,-70 # 11b8 <malloc+0x14c>
     206:	203000ef          	jal	c08 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     20a:	20200593          	li	a1,514
     20e:	00001517          	auipc	a0,0x1
     212:	00250513          	addi	a0,a0,2 # 1210 <malloc+0x1a4>
     216:	1cb000ef          	jal	be0 <open>
     21a:	1af000ef          	jal	bc8 <close>
      unlink("a/a");
     21e:	00001517          	auipc	a0,0x1
     222:	00250513          	addi	a0,a0,2 # 1220 <malloc+0x1b4>
     226:	1cb000ef          	jal	bf0 <unlink>
     22a:	b5c5                	j	10a <go+0x96>
    } else if(what == 10){
      mkdir("/../b");
     22c:	00001517          	auipc	a0,0x1
     230:	ffc50513          	addi	a0,a0,-4 # 1228 <malloc+0x1bc>
     234:	1d5000ef          	jal	c08 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     238:	20200593          	li	a1,514
     23c:	00001517          	auipc	a0,0x1
     240:	ff450513          	addi	a0,a0,-12 # 1230 <malloc+0x1c4>
     244:	19d000ef          	jal	be0 <open>
     248:	181000ef          	jal	bc8 <close>
      unlink("b/b");
     24c:	00001517          	auipc	a0,0x1
     250:	ff450513          	addi	a0,a0,-12 # 1240 <malloc+0x1d4>
     254:	19d000ef          	jal	bf0 <unlink>
     258:	bd4d                	j	10a <go+0x96>
    } else if(what == 11){
      unlink("b");
     25a:	00001517          	auipc	a0,0x1
     25e:	fee50513          	addi	a0,a0,-18 # 1248 <malloc+0x1dc>
     262:	18f000ef          	jal	bf0 <unlink>
      link("../grindir/./../a", "../b");
     266:	00001597          	auipc	a1,0x1
     26a:	f7a58593          	addi	a1,a1,-134 # 11e0 <malloc+0x174>
     26e:	00001517          	auipc	a0,0x1
     272:	fe250513          	addi	a0,a0,-30 # 1250 <malloc+0x1e4>
     276:	18b000ef          	jal	c00 <link>
     27a:	bd41                	j	10a <go+0x96>
    } else if(what == 12){
      unlink("../grindir/../a");
     27c:	00001517          	auipc	a0,0x1
     280:	fec50513          	addi	a0,a0,-20 # 1268 <malloc+0x1fc>
     284:	16d000ef          	jal	bf0 <unlink>
      link(".././b", "/grindir/../a");
     288:	00001597          	auipc	a1,0x1
     28c:	f6058593          	addi	a1,a1,-160 # 11e8 <malloc+0x17c>
     290:	00001517          	auipc	a0,0x1
     294:	fe850513          	addi	a0,a0,-24 # 1278 <malloc+0x20c>
     298:	169000ef          	jal	c00 <link>
     29c:	b5bd                	j	10a <go+0x96>
    } else if(what == 13){
      int pid = fork();
     29e:	0fb000ef          	jal	b98 <fork>
      if(pid == 0){
     2a2:	c519                	beqz	a0,2b0 <go+0x23c>
        exit(0);
      } else if(pid < 0){
     2a4:	00054863          	bltz	a0,2b4 <go+0x240>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2a8:	4501                	li	a0,0
     2aa:	0ff000ef          	jal	ba8 <wait>
     2ae:	bdb1                	j	10a <go+0x96>
        exit(0);
     2b0:	0f1000ef          	jal	ba0 <exit>
        printf("grind: fork failed\n");
     2b4:	00001517          	auipc	a0,0x1
     2b8:	fcc50513          	addi	a0,a0,-52 # 1280 <malloc+0x214>
     2bc:	4fd000ef          	jal	fb8 <printf>
        exit(1);
     2c0:	4505                	li	a0,1
     2c2:	0df000ef          	jal	ba0 <exit>
    } else if(what == 14){
      int pid = fork();
     2c6:	0d3000ef          	jal	b98 <fork>
      if(pid == 0){
     2ca:	c519                	beqz	a0,2d8 <go+0x264>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     2cc:	00054d63          	bltz	a0,2e6 <go+0x272>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2d0:	4501                	li	a0,0
     2d2:	0d7000ef          	jal	ba8 <wait>
     2d6:	bd15                	j	10a <go+0x96>
        fork();
     2d8:	0c1000ef          	jal	b98 <fork>
        fork();
     2dc:	0bd000ef          	jal	b98 <fork>
        exit(0);
     2e0:	4501                	li	a0,0
     2e2:	0bf000ef          	jal	ba0 <exit>
        printf("grind: fork failed\n");
     2e6:	00001517          	auipc	a0,0x1
     2ea:	f9a50513          	addi	a0,a0,-102 # 1280 <malloc+0x214>
     2ee:	4cb000ef          	jal	fb8 <printf>
        exit(1);
     2f2:	4505                	li	a0,1
     2f4:	0ad000ef          	jal	ba0 <exit>
    } else if(what == 15){
      sbrk(6011);
     2f8:	6505                	lui	a0,0x1
     2fa:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x29b>
     2fe:	12b000ef          	jal	c28 <sbrk>
     302:	b521                	j	10a <go+0x96>
    } else if(what == 16){
      if(sbrk(0) > break0)
     304:	4501                	li	a0,0
     306:	123000ef          	jal	c28 <sbrk>
     30a:	e0aaf0e3          	bgeu	s5,a0,10a <go+0x96>
        sbrk(-(sbrk(0) - break0));
     30e:	4501                	li	a0,0
     310:	119000ef          	jal	c28 <sbrk>
     314:	40aa853b          	subw	a0,s5,a0
     318:	111000ef          	jal	c28 <sbrk>
     31c:	b3fd                	j	10a <go+0x96>
    } else if(what == 17){
      int pid = fork();
     31e:	07b000ef          	jal	b98 <fork>
     322:	8b2a                	mv	s6,a0
      if(pid == 0){
     324:	c10d                	beqz	a0,346 <go+0x2d2>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     326:	02054d63          	bltz	a0,360 <go+0x2ec>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     32a:	00001517          	auipc	a0,0x1
     32e:	f7650513          	addi	a0,a0,-138 # 12a0 <malloc+0x234>
     332:	0df000ef          	jal	c10 <chdir>
     336:	ed15                	bnez	a0,372 <go+0x2fe>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     338:	855a                	mv	a0,s6
     33a:	097000ef          	jal	bd0 <kill>
      wait(0);
     33e:	4501                	li	a0,0
     340:	069000ef          	jal	ba8 <wait>
     344:	b3d9                	j	10a <go+0x96>
        close(open("a", O_CREATE|O_RDWR));
     346:	20200593          	li	a1,514
     34a:	00001517          	auipc	a0,0x1
     34e:	f4e50513          	addi	a0,a0,-178 # 1298 <malloc+0x22c>
     352:	08f000ef          	jal	be0 <open>
     356:	073000ef          	jal	bc8 <close>
        exit(0);
     35a:	4501                	li	a0,0
     35c:	045000ef          	jal	ba0 <exit>
        printf("grind: fork failed\n");
     360:	00001517          	auipc	a0,0x1
     364:	f2050513          	addi	a0,a0,-224 # 1280 <malloc+0x214>
     368:	451000ef          	jal	fb8 <printf>
        exit(1);
     36c:	4505                	li	a0,1
     36e:	033000ef          	jal	ba0 <exit>
        printf("grind: chdir failed\n");
     372:	00001517          	auipc	a0,0x1
     376:	f3e50513          	addi	a0,a0,-194 # 12b0 <malloc+0x244>
     37a:	43f000ef          	jal	fb8 <printf>
        exit(1);
     37e:	4505                	li	a0,1
     380:	021000ef          	jal	ba0 <exit>
    } else if(what == 18){
      int pid = fork();
     384:	015000ef          	jal	b98 <fork>
      if(pid == 0){
     388:	c519                	beqz	a0,396 <go+0x322>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     38a:	00054d63          	bltz	a0,3a4 <go+0x330>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     38e:	4501                	li	a0,0
     390:	019000ef          	jal	ba8 <wait>
     394:	bb9d                	j	10a <go+0x96>
        kill(getpid());
     396:	08b000ef          	jal	c20 <getpid>
     39a:	037000ef          	jal	bd0 <kill>
        exit(0);
     39e:	4501                	li	a0,0
     3a0:	001000ef          	jal	ba0 <exit>
        printf("grind: fork failed\n");
     3a4:	00001517          	auipc	a0,0x1
     3a8:	edc50513          	addi	a0,a0,-292 # 1280 <malloc+0x214>
     3ac:	40d000ef          	jal	fb8 <printf>
        exit(1);
     3b0:	4505                	li	a0,1
     3b2:	7ee000ef          	jal	ba0 <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     3b6:	f9840513          	addi	a0,s0,-104
     3ba:	7f6000ef          	jal	bb0 <pipe>
     3be:	02054363          	bltz	a0,3e4 <go+0x370>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     3c2:	7d6000ef          	jal	b98 <fork>
      if(pid == 0){
     3c6:	c905                	beqz	a0,3f6 <go+0x382>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     3c8:	08054263          	bltz	a0,44c <go+0x3d8>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     3cc:	f9842503          	lw	a0,-104(s0)
     3d0:	7f8000ef          	jal	bc8 <close>
      close(fds[1]);
     3d4:	f9c42503          	lw	a0,-100(s0)
     3d8:	7f0000ef          	jal	bc8 <close>
      wait(0);
     3dc:	4501                	li	a0,0
     3de:	7ca000ef          	jal	ba8 <wait>
     3e2:	b325                	j	10a <go+0x96>
        printf("grind: pipe failed\n");
     3e4:	00001517          	auipc	a0,0x1
     3e8:	ee450513          	addi	a0,a0,-284 # 12c8 <malloc+0x25c>
     3ec:	3cd000ef          	jal	fb8 <printf>
        exit(1);
     3f0:	4505                	li	a0,1
     3f2:	7ae000ef          	jal	ba0 <exit>
        fork();
     3f6:	7a2000ef          	jal	b98 <fork>
        fork();
     3fa:	79e000ef          	jal	b98 <fork>
        if(write(fds[1], "x", 1) != 1)
     3fe:	4605                	li	a2,1
     400:	00001597          	auipc	a1,0x1
     404:	ee058593          	addi	a1,a1,-288 # 12e0 <malloc+0x274>
     408:	f9c42503          	lw	a0,-100(s0)
     40c:	7b4000ef          	jal	bc0 <write>
     410:	4785                	li	a5,1
     412:	00f51f63          	bne	a0,a5,430 <go+0x3bc>
        if(read(fds[0], &c, 1) != 1)
     416:	4605                	li	a2,1
     418:	f9040593          	addi	a1,s0,-112
     41c:	f9842503          	lw	a0,-104(s0)
     420:	798000ef          	jal	bb8 <read>
     424:	4785                	li	a5,1
     426:	00f51c63          	bne	a0,a5,43e <go+0x3ca>
        exit(0);
     42a:	4501                	li	a0,0
     42c:	774000ef          	jal	ba0 <exit>
          printf("grind: pipe write failed\n");
     430:	00001517          	auipc	a0,0x1
     434:	eb850513          	addi	a0,a0,-328 # 12e8 <malloc+0x27c>
     438:	381000ef          	jal	fb8 <printf>
     43c:	bfe9                	j	416 <go+0x3a2>
          printf("grind: pipe read failed\n");
     43e:	00001517          	auipc	a0,0x1
     442:	eca50513          	addi	a0,a0,-310 # 1308 <malloc+0x29c>
     446:	373000ef          	jal	fb8 <printf>
     44a:	b7c5                	j	42a <go+0x3b6>
        printf("grind: fork failed\n");
     44c:	00001517          	auipc	a0,0x1
     450:	e3450513          	addi	a0,a0,-460 # 1280 <malloc+0x214>
     454:	365000ef          	jal	fb8 <printf>
        exit(1);
     458:	4505                	li	a0,1
     45a:	746000ef          	jal	ba0 <exit>
    } else if(what == 20){
      int pid = fork();
     45e:	73a000ef          	jal	b98 <fork>
      if(pid == 0){
     462:	c519                	beqz	a0,470 <go+0x3fc>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     464:	04054f63          	bltz	a0,4c2 <go+0x44e>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     468:	4501                	li	a0,0
     46a:	73e000ef          	jal	ba8 <wait>
     46e:	b971                	j	10a <go+0x96>
        unlink("a");
     470:	00001517          	auipc	a0,0x1
     474:	e2850513          	addi	a0,a0,-472 # 1298 <malloc+0x22c>
     478:	778000ef          	jal	bf0 <unlink>
        mkdir("a");
     47c:	00001517          	auipc	a0,0x1
     480:	e1c50513          	addi	a0,a0,-484 # 1298 <malloc+0x22c>
     484:	784000ef          	jal	c08 <mkdir>
        chdir("a");
     488:	00001517          	auipc	a0,0x1
     48c:	e1050513          	addi	a0,a0,-496 # 1298 <malloc+0x22c>
     490:	780000ef          	jal	c10 <chdir>
        unlink("../a");
     494:	00001517          	auipc	a0,0x1
     498:	e9450513          	addi	a0,a0,-364 # 1328 <malloc+0x2bc>
     49c:	754000ef          	jal	bf0 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     4a0:	20200593          	li	a1,514
     4a4:	00001517          	auipc	a0,0x1
     4a8:	e3c50513          	addi	a0,a0,-452 # 12e0 <malloc+0x274>
     4ac:	734000ef          	jal	be0 <open>
        unlink("x");
     4b0:	00001517          	auipc	a0,0x1
     4b4:	e3050513          	addi	a0,a0,-464 # 12e0 <malloc+0x274>
     4b8:	738000ef          	jal	bf0 <unlink>
        exit(0);
     4bc:	4501                	li	a0,0
     4be:	6e2000ef          	jal	ba0 <exit>
        printf("grind: fork failed\n");
     4c2:	00001517          	auipc	a0,0x1
     4c6:	dbe50513          	addi	a0,a0,-578 # 1280 <malloc+0x214>
     4ca:	2ef000ef          	jal	fb8 <printf>
        exit(1);
     4ce:	4505                	li	a0,1
     4d0:	6d0000ef          	jal	ba0 <exit>
    } else if(what == 21){
      unlink("c");
     4d4:	00001517          	auipc	a0,0x1
     4d8:	e5c50513          	addi	a0,a0,-420 # 1330 <malloc+0x2c4>
     4dc:	714000ef          	jal	bf0 <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     4e0:	20200593          	li	a1,514
     4e4:	00001517          	auipc	a0,0x1
     4e8:	e4c50513          	addi	a0,a0,-436 # 1330 <malloc+0x2c4>
     4ec:	6f4000ef          	jal	be0 <open>
     4f0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     4f2:	04054763          	bltz	a0,540 <go+0x4cc>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     4f6:	4605                	li	a2,1
     4f8:	00001597          	auipc	a1,0x1
     4fc:	de858593          	addi	a1,a1,-536 # 12e0 <malloc+0x274>
     500:	6c0000ef          	jal	bc0 <write>
     504:	4785                	li	a5,1
     506:	04f51663          	bne	a0,a5,552 <go+0x4de>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     50a:	f9840593          	addi	a1,s0,-104
     50e:	855a                	mv	a0,s6
     510:	6e8000ef          	jal	bf8 <fstat>
     514:	e921                	bnez	a0,564 <go+0x4f0>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     516:	fa843583          	ld	a1,-88(s0)
     51a:	4785                	li	a5,1
     51c:	04f59d63          	bne	a1,a5,576 <go+0x502>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     520:	f9c42583          	lw	a1,-100(s0)
     524:	0c800793          	li	a5,200
     528:	06b7e163          	bltu	a5,a1,58a <go+0x516>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     52c:	855a                	mv	a0,s6
     52e:	69a000ef          	jal	bc8 <close>
      unlink("c");
     532:	00001517          	auipc	a0,0x1
     536:	dfe50513          	addi	a0,a0,-514 # 1330 <malloc+0x2c4>
     53a:	6b6000ef          	jal	bf0 <unlink>
     53e:	b6f1                	j	10a <go+0x96>
        printf("grind: create c failed\n");
     540:	00001517          	auipc	a0,0x1
     544:	df850513          	addi	a0,a0,-520 # 1338 <malloc+0x2cc>
     548:	271000ef          	jal	fb8 <printf>
        exit(1);
     54c:	4505                	li	a0,1
     54e:	652000ef          	jal	ba0 <exit>
        printf("grind: write c failed\n");
     552:	00001517          	auipc	a0,0x1
     556:	dfe50513          	addi	a0,a0,-514 # 1350 <malloc+0x2e4>
     55a:	25f000ef          	jal	fb8 <printf>
        exit(1);
     55e:	4505                	li	a0,1
     560:	640000ef          	jal	ba0 <exit>
        printf("grind: fstat failed\n");
     564:	00001517          	auipc	a0,0x1
     568:	e0450513          	addi	a0,a0,-508 # 1368 <malloc+0x2fc>
     56c:	24d000ef          	jal	fb8 <printf>
        exit(1);
     570:	4505                	li	a0,1
     572:	62e000ef          	jal	ba0 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     576:	2581                	sext.w	a1,a1
     578:	00001517          	auipc	a0,0x1
     57c:	e0850513          	addi	a0,a0,-504 # 1380 <malloc+0x314>
     580:	239000ef          	jal	fb8 <printf>
        exit(1);
     584:	4505                	li	a0,1
     586:	61a000ef          	jal	ba0 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     58a:	00001517          	auipc	a0,0x1
     58e:	e1e50513          	addi	a0,a0,-482 # 13a8 <malloc+0x33c>
     592:	227000ef          	jal	fb8 <printf>
        exit(1);
     596:	4505                	li	a0,1
     598:	608000ef          	jal	ba0 <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     59c:	f8840513          	addi	a0,s0,-120
     5a0:	610000ef          	jal	bb0 <pipe>
     5a4:	0a054563          	bltz	a0,64e <go+0x5da>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     5a8:	f9040513          	addi	a0,s0,-112
     5ac:	604000ef          	jal	bb0 <pipe>
     5b0:	0a054963          	bltz	a0,662 <go+0x5ee>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     5b4:	5e4000ef          	jal	b98 <fork>
      if(pid1 == 0){
     5b8:	cd5d                	beqz	a0,676 <go+0x602>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     5ba:	14054263          	bltz	a0,6fe <go+0x68a>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     5be:	5da000ef          	jal	b98 <fork>
      if(pid2 == 0){
     5c2:	14050863          	beqz	a0,712 <go+0x69e>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     5c6:	1e054663          	bltz	a0,7b2 <go+0x73e>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     5ca:	f8842503          	lw	a0,-120(s0)
     5ce:	5fa000ef          	jal	bc8 <close>
      close(aa[1]);
     5d2:	f8c42503          	lw	a0,-116(s0)
     5d6:	5f2000ef          	jal	bc8 <close>
      close(bb[1]);
     5da:	f9442503          	lw	a0,-108(s0)
     5de:	5ea000ef          	jal	bc8 <close>
      char buf[4] = { 0, 0, 0, 0 };
     5e2:	f8042023          	sw	zero,-128(s0)
      read(bb[0], buf+0, 1);
     5e6:	4605                	li	a2,1
     5e8:	f8040593          	addi	a1,s0,-128
     5ec:	f9042503          	lw	a0,-112(s0)
     5f0:	5c8000ef          	jal	bb8 <read>
      read(bb[0], buf+1, 1);
     5f4:	4605                	li	a2,1
     5f6:	f8140593          	addi	a1,s0,-127
     5fa:	f9042503          	lw	a0,-112(s0)
     5fe:	5ba000ef          	jal	bb8 <read>
      read(bb[0], buf+2, 1);
     602:	4605                	li	a2,1
     604:	f8240593          	addi	a1,s0,-126
     608:	f9042503          	lw	a0,-112(s0)
     60c:	5ac000ef          	jal	bb8 <read>
      close(bb[0]);
     610:	f9042503          	lw	a0,-112(s0)
     614:	5b4000ef          	jal	bc8 <close>
      int st1, st2;
      wait(&st1);
     618:	f8440513          	addi	a0,s0,-124
     61c:	58c000ef          	jal	ba8 <wait>
      wait(&st2);
     620:	f9840513          	addi	a0,s0,-104
     624:	584000ef          	jal	ba8 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     628:	f8442783          	lw	a5,-124(s0)
     62c:	f9842b83          	lw	s7,-104(s0)
     630:	0177eb33          	or	s6,a5,s7
     634:	180b1963          	bnez	s6,7c6 <go+0x752>
     638:	00001597          	auipc	a1,0x1
     63c:	e1058593          	addi	a1,a1,-496 # 1448 <malloc+0x3dc>
     640:	f8040513          	addi	a0,s0,-128
     644:	2ce000ef          	jal	912 <strcmp>
     648:	ac0501e3          	beqz	a0,10a <go+0x96>
     64c:	aab5                	j	7c8 <go+0x754>
        fprintf(2, "grind: pipe failed\n");
     64e:	00001597          	auipc	a1,0x1
     652:	c7a58593          	addi	a1,a1,-902 # 12c8 <malloc+0x25c>
     656:	4509                	li	a0,2
     658:	137000ef          	jal	f8e <fprintf>
        exit(1);
     65c:	4505                	li	a0,1
     65e:	542000ef          	jal	ba0 <exit>
        fprintf(2, "grind: pipe failed\n");
     662:	00001597          	auipc	a1,0x1
     666:	c6658593          	addi	a1,a1,-922 # 12c8 <malloc+0x25c>
     66a:	4509                	li	a0,2
     66c:	123000ef          	jal	f8e <fprintf>
        exit(1);
     670:	4505                	li	a0,1
     672:	52e000ef          	jal	ba0 <exit>
        close(bb[0]);
     676:	f9042503          	lw	a0,-112(s0)
     67a:	54e000ef          	jal	bc8 <close>
        close(bb[1]);
     67e:	f9442503          	lw	a0,-108(s0)
     682:	546000ef          	jal	bc8 <close>
        close(aa[0]);
     686:	f8842503          	lw	a0,-120(s0)
     68a:	53e000ef          	jal	bc8 <close>
        close(1);
     68e:	4505                	li	a0,1
     690:	538000ef          	jal	bc8 <close>
        if(dup(aa[1]) != 1){
     694:	f8c42503          	lw	a0,-116(s0)
     698:	580000ef          	jal	c18 <dup>
     69c:	4785                	li	a5,1
     69e:	00f50c63          	beq	a0,a5,6b6 <go+0x642>
          fprintf(2, "grind: dup failed\n");
     6a2:	00001597          	auipc	a1,0x1
     6a6:	d2e58593          	addi	a1,a1,-722 # 13d0 <malloc+0x364>
     6aa:	4509                	li	a0,2
     6ac:	0e3000ef          	jal	f8e <fprintf>
          exit(1);
     6b0:	4505                	li	a0,1
     6b2:	4ee000ef          	jal	ba0 <exit>
        close(aa[1]);
     6b6:	f8c42503          	lw	a0,-116(s0)
     6ba:	50e000ef          	jal	bc8 <close>
        char *args[3] = { "echo", "hi", 0 };
     6be:	00001797          	auipc	a5,0x1
     6c2:	d2a78793          	addi	a5,a5,-726 # 13e8 <malloc+0x37c>
     6c6:	f8f43c23          	sd	a5,-104(s0)
     6ca:	00001797          	auipc	a5,0x1
     6ce:	d2678793          	addi	a5,a5,-730 # 13f0 <malloc+0x384>
     6d2:	faf43023          	sd	a5,-96(s0)
     6d6:	fa043423          	sd	zero,-88(s0)
        exec("grindir/../echo", args);
     6da:	f9840593          	addi	a1,s0,-104
     6de:	00001517          	auipc	a0,0x1
     6e2:	d1a50513          	addi	a0,a0,-742 # 13f8 <malloc+0x38c>
     6e6:	4f2000ef          	jal	bd8 <exec>
        fprintf(2, "grind: echo: not found\n");
     6ea:	00001597          	auipc	a1,0x1
     6ee:	d1e58593          	addi	a1,a1,-738 # 1408 <malloc+0x39c>
     6f2:	4509                	li	a0,2
     6f4:	09b000ef          	jal	f8e <fprintf>
        exit(2);
     6f8:	4509                	li	a0,2
     6fa:	4a6000ef          	jal	ba0 <exit>
        fprintf(2, "grind: fork failed\n");
     6fe:	00001597          	auipc	a1,0x1
     702:	b8258593          	addi	a1,a1,-1150 # 1280 <malloc+0x214>
     706:	4509                	li	a0,2
     708:	087000ef          	jal	f8e <fprintf>
        exit(3);
     70c:	450d                	li	a0,3
     70e:	492000ef          	jal	ba0 <exit>
        close(aa[1]);
     712:	f8c42503          	lw	a0,-116(s0)
     716:	4b2000ef          	jal	bc8 <close>
        close(bb[0]);
     71a:	f9042503          	lw	a0,-112(s0)
     71e:	4aa000ef          	jal	bc8 <close>
        close(0);
     722:	4501                	li	a0,0
     724:	4a4000ef          	jal	bc8 <close>
        if(dup(aa[0]) != 0){
     728:	f8842503          	lw	a0,-120(s0)
     72c:	4ec000ef          	jal	c18 <dup>
     730:	c919                	beqz	a0,746 <go+0x6d2>
          fprintf(2, "grind: dup failed\n");
     732:	00001597          	auipc	a1,0x1
     736:	c9e58593          	addi	a1,a1,-866 # 13d0 <malloc+0x364>
     73a:	4509                	li	a0,2
     73c:	053000ef          	jal	f8e <fprintf>
          exit(4);
     740:	4511                	li	a0,4
     742:	45e000ef          	jal	ba0 <exit>
        close(aa[0]);
     746:	f8842503          	lw	a0,-120(s0)
     74a:	47e000ef          	jal	bc8 <close>
        close(1);
     74e:	4505                	li	a0,1
     750:	478000ef          	jal	bc8 <close>
        if(dup(bb[1]) != 1){
     754:	f9442503          	lw	a0,-108(s0)
     758:	4c0000ef          	jal	c18 <dup>
     75c:	4785                	li	a5,1
     75e:	00f50c63          	beq	a0,a5,776 <go+0x702>
          fprintf(2, "grind: dup failed\n");
     762:	00001597          	auipc	a1,0x1
     766:	c6e58593          	addi	a1,a1,-914 # 13d0 <malloc+0x364>
     76a:	4509                	li	a0,2
     76c:	023000ef          	jal	f8e <fprintf>
          exit(5);
     770:	4515                	li	a0,5
     772:	42e000ef          	jal	ba0 <exit>
        close(bb[1]);
     776:	f9442503          	lw	a0,-108(s0)
     77a:	44e000ef          	jal	bc8 <close>
        char *args[2] = { "cat", 0 };
     77e:	00001797          	auipc	a5,0x1
     782:	ca278793          	addi	a5,a5,-862 # 1420 <malloc+0x3b4>
     786:	f8f43c23          	sd	a5,-104(s0)
     78a:	fa043023          	sd	zero,-96(s0)
        exec("/cat", args);
     78e:	f9840593          	addi	a1,s0,-104
     792:	00001517          	auipc	a0,0x1
     796:	c9650513          	addi	a0,a0,-874 # 1428 <malloc+0x3bc>
     79a:	43e000ef          	jal	bd8 <exec>
        fprintf(2, "grind: cat: not found\n");
     79e:	00001597          	auipc	a1,0x1
     7a2:	c9258593          	addi	a1,a1,-878 # 1430 <malloc+0x3c4>
     7a6:	4509                	li	a0,2
     7a8:	7e6000ef          	jal	f8e <fprintf>
        exit(6);
     7ac:	4519                	li	a0,6
     7ae:	3f2000ef          	jal	ba0 <exit>
        fprintf(2, "grind: fork failed\n");
     7b2:	00001597          	auipc	a1,0x1
     7b6:	ace58593          	addi	a1,a1,-1330 # 1280 <malloc+0x214>
     7ba:	4509                	li	a0,2
     7bc:	7d2000ef          	jal	f8e <fprintf>
        exit(7);
     7c0:	451d                	li	a0,7
     7c2:	3de000ef          	jal	ba0 <exit>
     7c6:	8b3e                	mv	s6,a5
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     7c8:	f8040693          	addi	a3,s0,-128
     7cc:	865e                	mv	a2,s7
     7ce:	85da                	mv	a1,s6
     7d0:	00001517          	auipc	a0,0x1
     7d4:	c8050513          	addi	a0,a0,-896 # 1450 <malloc+0x3e4>
     7d8:	7e0000ef          	jal	fb8 <printf>
        exit(1);
     7dc:	4505                	li	a0,1
     7de:	3c2000ef          	jal	ba0 <exit>

00000000000007e2 <iter>:
  }
}

void
iter()
{
     7e2:	7179                	addi	sp,sp,-48
     7e4:	f406                	sd	ra,40(sp)
     7e6:	f022                	sd	s0,32(sp)
     7e8:	1800                	addi	s0,sp,48
  unlink("a");
     7ea:	00001517          	auipc	a0,0x1
     7ee:	aae50513          	addi	a0,a0,-1362 # 1298 <malloc+0x22c>
     7f2:	3fe000ef          	jal	bf0 <unlink>
  unlink("b");
     7f6:	00001517          	auipc	a0,0x1
     7fa:	a5250513          	addi	a0,a0,-1454 # 1248 <malloc+0x1dc>
     7fe:	3f2000ef          	jal	bf0 <unlink>
  
  int pid1 = fork();
     802:	396000ef          	jal	b98 <fork>
  if(pid1 < 0){
     806:	02054163          	bltz	a0,828 <iter+0x46>
     80a:	ec26                	sd	s1,24(sp)
     80c:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     80e:	e905                	bnez	a0,83e <iter+0x5c>
     810:	e84a                	sd	s2,16(sp)
    rand_next ^= 31;
     812:	00001717          	auipc	a4,0x1
     816:	7ee70713          	addi	a4,a4,2030 # 2000 <rand_next>
     81a:	631c                	ld	a5,0(a4)
     81c:	01f7c793          	xori	a5,a5,31
     820:	e31c                	sd	a5,0(a4)
    go(0);
     822:	4501                	li	a0,0
     824:	851ff0ef          	jal	74 <go>
     828:	ec26                	sd	s1,24(sp)
     82a:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     82c:	00001517          	auipc	a0,0x1
     830:	a5450513          	addi	a0,a0,-1452 # 1280 <malloc+0x214>
     834:	784000ef          	jal	fb8 <printf>
    exit(1);
     838:	4505                	li	a0,1
     83a:	366000ef          	jal	ba0 <exit>
     83e:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     840:	358000ef          	jal	b98 <fork>
     844:	892a                	mv	s2,a0
  if(pid2 < 0){
     846:	02054063          	bltz	a0,866 <iter+0x84>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     84a:	e51d                	bnez	a0,878 <iter+0x96>
    rand_next ^= 7177;
     84c:	00001697          	auipc	a3,0x1
     850:	7b468693          	addi	a3,a3,1972 # 2000 <rand_next>
     854:	629c                	ld	a5,0(a3)
     856:	6709                	lui	a4,0x2
     858:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x729>
     85c:	8fb9                	xor	a5,a5,a4
     85e:	e29c                	sd	a5,0(a3)
    go(1);
     860:	4505                	li	a0,1
     862:	813ff0ef          	jal	74 <go>
    printf("grind: fork failed\n");
     866:	00001517          	auipc	a0,0x1
     86a:	a1a50513          	addi	a0,a0,-1510 # 1280 <malloc+0x214>
     86e:	74a000ef          	jal	fb8 <printf>
    exit(1);
     872:	4505                	li	a0,1
     874:	32c000ef          	jal	ba0 <exit>
    exit(0);
  }

  int st1 = -1;
     878:	57fd                	li	a5,-1
     87a:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     87e:	fdc40513          	addi	a0,s0,-36
     882:	326000ef          	jal	ba8 <wait>
  if(st1 != 0){
     886:	fdc42783          	lw	a5,-36(s0)
     88a:	eb99                	bnez	a5,8a0 <iter+0xbe>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     88c:	57fd                	li	a5,-1
     88e:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     892:	fd840513          	addi	a0,s0,-40
     896:	312000ef          	jal	ba8 <wait>

  exit(0);
     89a:	4501                	li	a0,0
     89c:	304000ef          	jal	ba0 <exit>
    kill(pid1);
     8a0:	8526                	mv	a0,s1
     8a2:	32e000ef          	jal	bd0 <kill>
    kill(pid2);
     8a6:	854a                	mv	a0,s2
     8a8:	328000ef          	jal	bd0 <kill>
     8ac:	b7c5                	j	88c <iter+0xaa>

00000000000008ae <main>:
}

int
main()
{
     8ae:	1101                	addi	sp,sp,-32
     8b0:	ec06                	sd	ra,24(sp)
     8b2:	e822                	sd	s0,16(sp)
     8b4:	e426                	sd	s1,8(sp)
     8b6:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     8b8:	00001497          	auipc	s1,0x1
     8bc:	74848493          	addi	s1,s1,1864 # 2000 <rand_next>
     8c0:	a809                	j	8d2 <main+0x24>
      iter();
     8c2:	f21ff0ef          	jal	7e2 <iter>
    sleep(20);
     8c6:	4551                	li	a0,20
     8c8:	368000ef          	jal	c30 <sleep>
    rand_next += 1;
     8cc:	609c                	ld	a5,0(s1)
     8ce:	0785                	addi	a5,a5,1
     8d0:	e09c                	sd	a5,0(s1)
    int pid = fork();
     8d2:	2c6000ef          	jal	b98 <fork>
    if(pid == 0){
     8d6:	d575                	beqz	a0,8c2 <main+0x14>
    if(pid > 0){
     8d8:	fea057e3          	blez	a0,8c6 <main+0x18>
      wait(0);
     8dc:	4501                	li	a0,0
     8de:	2ca000ef          	jal	ba8 <wait>
     8e2:	b7d5                	j	8c6 <main+0x18>

00000000000008e4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     8e4:	1141                	addi	sp,sp,-16
     8e6:	e406                	sd	ra,8(sp)
     8e8:	e022                	sd	s0,0(sp)
     8ea:	0800                	addi	s0,sp,16
  extern int main();
  main();
     8ec:	fc3ff0ef          	jal	8ae <main>
  exit(0);
     8f0:	4501                	li	a0,0
     8f2:	2ae000ef          	jal	ba0 <exit>

00000000000008f6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     8f6:	1141                	addi	sp,sp,-16
     8f8:	e422                	sd	s0,8(sp)
     8fa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     8fc:	87aa                	mv	a5,a0
     8fe:	0585                	addi	a1,a1,1
     900:	0785                	addi	a5,a5,1
     902:	fff5c703          	lbu	a4,-1(a1)
     906:	fee78fa3          	sb	a4,-1(a5)
     90a:	fb75                	bnez	a4,8fe <strcpy+0x8>
    ;
  return os;
}
     90c:	6422                	ld	s0,8(sp)
     90e:	0141                	addi	sp,sp,16
     910:	8082                	ret

0000000000000912 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     912:	1141                	addi	sp,sp,-16
     914:	e422                	sd	s0,8(sp)
     916:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     918:	00054783          	lbu	a5,0(a0)
     91c:	cb91                	beqz	a5,930 <strcmp+0x1e>
     91e:	0005c703          	lbu	a4,0(a1)
     922:	00f71763          	bne	a4,a5,930 <strcmp+0x1e>
    p++, q++;
     926:	0505                	addi	a0,a0,1
     928:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     92a:	00054783          	lbu	a5,0(a0)
     92e:	fbe5                	bnez	a5,91e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     930:	0005c503          	lbu	a0,0(a1)
}
     934:	40a7853b          	subw	a0,a5,a0
     938:	6422                	ld	s0,8(sp)
     93a:	0141                	addi	sp,sp,16
     93c:	8082                	ret

000000000000093e <strlen>:

uint
strlen(const char *s)
{
     93e:	1141                	addi	sp,sp,-16
     940:	e422                	sd	s0,8(sp)
     942:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     944:	00054783          	lbu	a5,0(a0)
     948:	cf91                	beqz	a5,964 <strlen+0x26>
     94a:	0505                	addi	a0,a0,1
     94c:	87aa                	mv	a5,a0
     94e:	86be                	mv	a3,a5
     950:	0785                	addi	a5,a5,1
     952:	fff7c703          	lbu	a4,-1(a5)
     956:	ff65                	bnez	a4,94e <strlen+0x10>
     958:	40a6853b          	subw	a0,a3,a0
     95c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     95e:	6422                	ld	s0,8(sp)
     960:	0141                	addi	sp,sp,16
     962:	8082                	ret
  for(n = 0; s[n]; n++)
     964:	4501                	li	a0,0
     966:	bfe5                	j	95e <strlen+0x20>

0000000000000968 <memset>:

void*
memset(void *dst, int c, uint n)
{
     968:	1141                	addi	sp,sp,-16
     96a:	e422                	sd	s0,8(sp)
     96c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     96e:	ca19                	beqz	a2,984 <memset+0x1c>
     970:	87aa                	mv	a5,a0
     972:	1602                	slli	a2,a2,0x20
     974:	9201                	srli	a2,a2,0x20
     976:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     97a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     97e:	0785                	addi	a5,a5,1
     980:	fee79de3          	bne	a5,a4,97a <memset+0x12>
  }
  return dst;
}
     984:	6422                	ld	s0,8(sp)
     986:	0141                	addi	sp,sp,16
     988:	8082                	ret

000000000000098a <strchr>:

char*
strchr(const char *s, char c)
{
     98a:	1141                	addi	sp,sp,-16
     98c:	e422                	sd	s0,8(sp)
     98e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     990:	00054783          	lbu	a5,0(a0)
     994:	cb99                	beqz	a5,9aa <strchr+0x20>
    if(*s == c)
     996:	00f58763          	beq	a1,a5,9a4 <strchr+0x1a>
  for(; *s; s++)
     99a:	0505                	addi	a0,a0,1
     99c:	00054783          	lbu	a5,0(a0)
     9a0:	fbfd                	bnez	a5,996 <strchr+0xc>
      return (char*)s;
  return 0;
     9a2:	4501                	li	a0,0
}
     9a4:	6422                	ld	s0,8(sp)
     9a6:	0141                	addi	sp,sp,16
     9a8:	8082                	ret
  return 0;
     9aa:	4501                	li	a0,0
     9ac:	bfe5                	j	9a4 <strchr+0x1a>

00000000000009ae <gets>:

char*
gets(char *buf, int max)
{
     9ae:	711d                	addi	sp,sp,-96
     9b0:	ec86                	sd	ra,88(sp)
     9b2:	e8a2                	sd	s0,80(sp)
     9b4:	e4a6                	sd	s1,72(sp)
     9b6:	e0ca                	sd	s2,64(sp)
     9b8:	fc4e                	sd	s3,56(sp)
     9ba:	f852                	sd	s4,48(sp)
     9bc:	f456                	sd	s5,40(sp)
     9be:	f05a                	sd	s6,32(sp)
     9c0:	ec5e                	sd	s7,24(sp)
     9c2:	1080                	addi	s0,sp,96
     9c4:	8baa                	mv	s7,a0
     9c6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9c8:	892a                	mv	s2,a0
     9ca:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     9cc:	4aa9                	li	s5,10
     9ce:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     9d0:	89a6                	mv	s3,s1
     9d2:	2485                	addiw	s1,s1,1
     9d4:	0344d663          	bge	s1,s4,a00 <gets+0x52>
    cc = read(0, &c, 1);
     9d8:	4605                	li	a2,1
     9da:	faf40593          	addi	a1,s0,-81
     9de:	4501                	li	a0,0
     9e0:	1d8000ef          	jal	bb8 <read>
    if(cc < 1)
     9e4:	00a05e63          	blez	a0,a00 <gets+0x52>
    buf[i++] = c;
     9e8:	faf44783          	lbu	a5,-81(s0)
     9ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     9f0:	01578763          	beq	a5,s5,9fe <gets+0x50>
     9f4:	0905                	addi	s2,s2,1
     9f6:	fd679de3          	bne	a5,s6,9d0 <gets+0x22>
    buf[i++] = c;
     9fa:	89a6                	mv	s3,s1
     9fc:	a011                	j	a00 <gets+0x52>
     9fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     a00:	99de                	add	s3,s3,s7
     a02:	00098023          	sb	zero,0(s3)
  return buf;
}
     a06:	855e                	mv	a0,s7
     a08:	60e6                	ld	ra,88(sp)
     a0a:	6446                	ld	s0,80(sp)
     a0c:	64a6                	ld	s1,72(sp)
     a0e:	6906                	ld	s2,64(sp)
     a10:	79e2                	ld	s3,56(sp)
     a12:	7a42                	ld	s4,48(sp)
     a14:	7aa2                	ld	s5,40(sp)
     a16:	7b02                	ld	s6,32(sp)
     a18:	6be2                	ld	s7,24(sp)
     a1a:	6125                	addi	sp,sp,96
     a1c:	8082                	ret

0000000000000a1e <stat>:

int
stat(const char *n, struct stat *st)
{
     a1e:	1101                	addi	sp,sp,-32
     a20:	ec06                	sd	ra,24(sp)
     a22:	e822                	sd	s0,16(sp)
     a24:	e04a                	sd	s2,0(sp)
     a26:	1000                	addi	s0,sp,32
     a28:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a2a:	4581                	li	a1,0
     a2c:	1b4000ef          	jal	be0 <open>
  if(fd < 0)
     a30:	02054263          	bltz	a0,a54 <stat+0x36>
     a34:	e426                	sd	s1,8(sp)
     a36:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a38:	85ca                	mv	a1,s2
     a3a:	1be000ef          	jal	bf8 <fstat>
     a3e:	892a                	mv	s2,a0
  close(fd);
     a40:	8526                	mv	a0,s1
     a42:	186000ef          	jal	bc8 <close>
  return r;
     a46:	64a2                	ld	s1,8(sp)
}
     a48:	854a                	mv	a0,s2
     a4a:	60e2                	ld	ra,24(sp)
     a4c:	6442                	ld	s0,16(sp)
     a4e:	6902                	ld	s2,0(sp)
     a50:	6105                	addi	sp,sp,32
     a52:	8082                	ret
    return -1;
     a54:	597d                	li	s2,-1
     a56:	bfcd                	j	a48 <stat+0x2a>

0000000000000a58 <atoi>:

int
atoi(const char *s)
{
     a58:	1141                	addi	sp,sp,-16
     a5a:	e422                	sd	s0,8(sp)
     a5c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a5e:	00054683          	lbu	a3,0(a0)
     a62:	fd06879b          	addiw	a5,a3,-48
     a66:	0ff7f793          	zext.b	a5,a5
     a6a:	4625                	li	a2,9
     a6c:	02f66863          	bltu	a2,a5,a9c <atoi+0x44>
     a70:	872a                	mv	a4,a0
  n = 0;
     a72:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     a74:	0705                	addi	a4,a4,1
     a76:	0025179b          	slliw	a5,a0,0x2
     a7a:	9fa9                	addw	a5,a5,a0
     a7c:	0017979b          	slliw	a5,a5,0x1
     a80:	9fb5                	addw	a5,a5,a3
     a82:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a86:	00074683          	lbu	a3,0(a4)
     a8a:	fd06879b          	addiw	a5,a3,-48
     a8e:	0ff7f793          	zext.b	a5,a5
     a92:	fef671e3          	bgeu	a2,a5,a74 <atoi+0x1c>
  return n;
}
     a96:	6422                	ld	s0,8(sp)
     a98:	0141                	addi	sp,sp,16
     a9a:	8082                	ret
  n = 0;
     a9c:	4501                	li	a0,0
     a9e:	bfe5                	j	a96 <atoi+0x3e>

0000000000000aa0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     aa0:	1141                	addi	sp,sp,-16
     aa2:	e422                	sd	s0,8(sp)
     aa4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     aa6:	02b57463          	bgeu	a0,a1,ace <memmove+0x2e>
    while(n-- > 0)
     aaa:	00c05f63          	blez	a2,ac8 <memmove+0x28>
     aae:	1602                	slli	a2,a2,0x20
     ab0:	9201                	srli	a2,a2,0x20
     ab2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     ab6:	872a                	mv	a4,a0
      *dst++ = *src++;
     ab8:	0585                	addi	a1,a1,1
     aba:	0705                	addi	a4,a4,1
     abc:	fff5c683          	lbu	a3,-1(a1)
     ac0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ac4:	fef71ae3          	bne	a4,a5,ab8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ac8:	6422                	ld	s0,8(sp)
     aca:	0141                	addi	sp,sp,16
     acc:	8082                	ret
    dst += n;
     ace:	00c50733          	add	a4,a0,a2
    src += n;
     ad2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     ad4:	fec05ae3          	blez	a2,ac8 <memmove+0x28>
     ad8:	fff6079b          	addiw	a5,a2,-1
     adc:	1782                	slli	a5,a5,0x20
     ade:	9381                	srli	a5,a5,0x20
     ae0:	fff7c793          	not	a5,a5
     ae4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ae6:	15fd                	addi	a1,a1,-1
     ae8:	177d                	addi	a4,a4,-1
     aea:	0005c683          	lbu	a3,0(a1)
     aee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     af2:	fee79ae3          	bne	a5,a4,ae6 <memmove+0x46>
     af6:	bfc9                	j	ac8 <memmove+0x28>

0000000000000af8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     af8:	1141                	addi	sp,sp,-16
     afa:	e422                	sd	s0,8(sp)
     afc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     afe:	ca05                	beqz	a2,b2e <memcmp+0x36>
     b00:	fff6069b          	addiw	a3,a2,-1
     b04:	1682                	slli	a3,a3,0x20
     b06:	9281                	srli	a3,a3,0x20
     b08:	0685                	addi	a3,a3,1
     b0a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b0c:	00054783          	lbu	a5,0(a0)
     b10:	0005c703          	lbu	a4,0(a1)
     b14:	00e79863          	bne	a5,a4,b24 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b18:	0505                	addi	a0,a0,1
    p2++;
     b1a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b1c:	fed518e3          	bne	a0,a3,b0c <memcmp+0x14>
  }
  return 0;
     b20:	4501                	li	a0,0
     b22:	a019                	j	b28 <memcmp+0x30>
      return *p1 - *p2;
     b24:	40e7853b          	subw	a0,a5,a4
}
     b28:	6422                	ld	s0,8(sp)
     b2a:	0141                	addi	sp,sp,16
     b2c:	8082                	ret
  return 0;
     b2e:	4501                	li	a0,0
     b30:	bfe5                	j	b28 <memcmp+0x30>

0000000000000b32 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b32:	1141                	addi	sp,sp,-16
     b34:	e406                	sd	ra,8(sp)
     b36:	e022                	sd	s0,0(sp)
     b38:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b3a:	f67ff0ef          	jal	aa0 <memmove>
}
     b3e:	60a2                	ld	ra,8(sp)
     b40:	6402                	ld	s0,0(sp)
     b42:	0141                	addi	sp,sp,16
     b44:	8082                	ret

0000000000000b46 <syscall>:
}

// Implementación de la función syscall
long
syscall(int num, ...)
{
     b46:	711d                	addi	sp,sp,-96
     b48:	ec22                	sd	s0,24(sp)
     b4a:	1000                	addi	s0,sp,32
     b4c:	832a                	mv	t1,a0
     b4e:	852e                	mv	a0,a1
     b50:	e40c                	sd	a1,8(s0)
     b52:	85b2                	mv	a1,a2
     b54:	e810                	sd	a2,16(s0)
     b56:	8636                	mv	a2,a3
     b58:	ec14                	sd	a3,24(s0)
     b5a:	86ba                	mv	a3,a4
     b5c:	f018                	sd	a4,32(s0)
     b5e:	873e                	mv	a4,a5
     b60:	f41c                	sd	a5,40(s0)
     b62:	87c2                	mv	a5,a6
     b64:	03043823          	sd	a6,48(s0)
     b68:	03143c23          	sd	a7,56(s0)
  // Manejar argumentos variables
  va_list ap;
  va_start(ap, num);

  // Cargar los argumentos en los registros
  register uint64 a0 asm("a0") = va_arg(ap, uint64);
     b6c:	01040813          	addi	a6,s0,16
     b70:	ff043423          	sd	a6,-24(s0)
  register uint64 a5 asm("a5") = va_arg(ap, uint64);
  
  va_end(ap);

  // Hacer la llamada al sistema
  register uint64 syscall_num asm("a7") = num;
     b74:	889a                	mv	a7,t1
  asm volatile("ecall"
     b76:	00000073          	ecall
               : "r" (syscall_num), "r" (a1), "r" (a2), "r" (a3), "r" (a4), "r" (a5)
               : "memory");

  // Retornar el resultado
  return a0;
}
     b7a:	6462                	ld	s0,24(sp)
     b7c:	6125                	addi	sp,sp,96
     b7e:	8082                	ret

0000000000000b80 <getppid>:
{
     b80:	1141                	addi	sp,sp,-16
     b82:	e406                	sd	ra,8(sp)
     b84:	e022                	sd	s0,0(sp)
     b86:	0800                	addi	s0,sp,16
  return syscall(SYS_getppid);
     b88:	4559                	li	a0,22
     b8a:	fbdff0ef          	jal	b46 <syscall>
}
     b8e:	2501                	sext.w	a0,a0
     b90:	60a2                	ld	ra,8(sp)
     b92:	6402                	ld	s0,0(sp)
     b94:	0141                	addi	sp,sp,16
     b96:	8082                	ret

0000000000000b98 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     b98:	4885                	li	a7,1
 ecall
     b9a:	00000073          	ecall
 ret
     b9e:	8082                	ret

0000000000000ba0 <exit>:
.global exit
exit:
 li a7, SYS_exit
     ba0:	4889                	li	a7,2
 ecall
     ba2:	00000073          	ecall
 ret
     ba6:	8082                	ret

0000000000000ba8 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ba8:	488d                	li	a7,3
 ecall
     baa:	00000073          	ecall
 ret
     bae:	8082                	ret

0000000000000bb0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     bb0:	4891                	li	a7,4
 ecall
     bb2:	00000073          	ecall
 ret
     bb6:	8082                	ret

0000000000000bb8 <read>:
.global read
read:
 li a7, SYS_read
     bb8:	4895                	li	a7,5
 ecall
     bba:	00000073          	ecall
 ret
     bbe:	8082                	ret

0000000000000bc0 <write>:
.global write
write:
 li a7, SYS_write
     bc0:	48c1                	li	a7,16
 ecall
     bc2:	00000073          	ecall
 ret
     bc6:	8082                	ret

0000000000000bc8 <close>:
.global close
close:
 li a7, SYS_close
     bc8:	48d5                	li	a7,21
 ecall
     bca:	00000073          	ecall
 ret
     bce:	8082                	ret

0000000000000bd0 <kill>:
.global kill
kill:
 li a7, SYS_kill
     bd0:	4899                	li	a7,6
 ecall
     bd2:	00000073          	ecall
 ret
     bd6:	8082                	ret

0000000000000bd8 <exec>:
.global exec
exec:
 li a7, SYS_exec
     bd8:	489d                	li	a7,7
 ecall
     bda:	00000073          	ecall
 ret
     bde:	8082                	ret

0000000000000be0 <open>:
.global open
open:
 li a7, SYS_open
     be0:	48bd                	li	a7,15
 ecall
     be2:	00000073          	ecall
 ret
     be6:	8082                	ret

0000000000000be8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     be8:	48c5                	li	a7,17
 ecall
     bea:	00000073          	ecall
 ret
     bee:	8082                	ret

0000000000000bf0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     bf0:	48c9                	li	a7,18
 ecall
     bf2:	00000073          	ecall
 ret
     bf6:	8082                	ret

0000000000000bf8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     bf8:	48a1                	li	a7,8
 ecall
     bfa:	00000073          	ecall
 ret
     bfe:	8082                	ret

0000000000000c00 <link>:
.global link
link:
 li a7, SYS_link
     c00:	48cd                	li	a7,19
 ecall
     c02:	00000073          	ecall
 ret
     c06:	8082                	ret

0000000000000c08 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c08:	48d1                	li	a7,20
 ecall
     c0a:	00000073          	ecall
 ret
     c0e:	8082                	ret

0000000000000c10 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c10:	48a5                	li	a7,9
 ecall
     c12:	00000073          	ecall
 ret
     c16:	8082                	ret

0000000000000c18 <dup>:
.global dup
dup:
 li a7, SYS_dup
     c18:	48a9                	li	a7,10
 ecall
     c1a:	00000073          	ecall
 ret
     c1e:	8082                	ret

0000000000000c20 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     c20:	48ad                	li	a7,11
 ecall
     c22:	00000073          	ecall
 ret
     c26:	8082                	ret

0000000000000c28 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     c28:	48b1                	li	a7,12
 ecall
     c2a:	00000073          	ecall
 ret
     c2e:	8082                	ret

0000000000000c30 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     c30:	48b5                	li	a7,13
 ecall
     c32:	00000073          	ecall
 ret
     c36:	8082                	ret

0000000000000c38 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c38:	48b9                	li	a7,14
 ecall
     c3a:	00000073          	ecall
 ret
     c3e:	8082                	ret

0000000000000c40 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c40:	1101                	addi	sp,sp,-32
     c42:	ec06                	sd	ra,24(sp)
     c44:	e822                	sd	s0,16(sp)
     c46:	1000                	addi	s0,sp,32
     c48:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c4c:	4605                	li	a2,1
     c4e:	fef40593          	addi	a1,s0,-17
     c52:	f6fff0ef          	jal	bc0 <write>
}
     c56:	60e2                	ld	ra,24(sp)
     c58:	6442                	ld	s0,16(sp)
     c5a:	6105                	addi	sp,sp,32
     c5c:	8082                	ret

0000000000000c5e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     c5e:	7139                	addi	sp,sp,-64
     c60:	fc06                	sd	ra,56(sp)
     c62:	f822                	sd	s0,48(sp)
     c64:	f426                	sd	s1,40(sp)
     c66:	0080                	addi	s0,sp,64
     c68:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     c6a:	c299                	beqz	a3,c70 <printint+0x12>
     c6c:	0805c963          	bltz	a1,cfe <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     c70:	2581                	sext.w	a1,a1
  neg = 0;
     c72:	4881                	li	a7,0
     c74:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     c78:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     c7a:	2601                	sext.w	a2,a2
     c7c:	00001517          	auipc	a0,0x1
     c80:	86450513          	addi	a0,a0,-1948 # 14e0 <digits>
     c84:	883a                	mv	a6,a4
     c86:	2705                	addiw	a4,a4,1
     c88:	02c5f7bb          	remuw	a5,a1,a2
     c8c:	1782                	slli	a5,a5,0x20
     c8e:	9381                	srli	a5,a5,0x20
     c90:	97aa                	add	a5,a5,a0
     c92:	0007c783          	lbu	a5,0(a5)
     c96:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     c9a:	0005879b          	sext.w	a5,a1
     c9e:	02c5d5bb          	divuw	a1,a1,a2
     ca2:	0685                	addi	a3,a3,1
     ca4:	fec7f0e3          	bgeu	a5,a2,c84 <printint+0x26>
  if(neg)
     ca8:	00088c63          	beqz	a7,cc0 <printint+0x62>
    buf[i++] = '-';
     cac:	fd070793          	addi	a5,a4,-48
     cb0:	00878733          	add	a4,a5,s0
     cb4:	02d00793          	li	a5,45
     cb8:	fef70823          	sb	a5,-16(a4)
     cbc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     cc0:	02e05a63          	blez	a4,cf4 <printint+0x96>
     cc4:	f04a                	sd	s2,32(sp)
     cc6:	ec4e                	sd	s3,24(sp)
     cc8:	fc040793          	addi	a5,s0,-64
     ccc:	00e78933          	add	s2,a5,a4
     cd0:	fff78993          	addi	s3,a5,-1
     cd4:	99ba                	add	s3,s3,a4
     cd6:	377d                	addiw	a4,a4,-1
     cd8:	1702                	slli	a4,a4,0x20
     cda:	9301                	srli	a4,a4,0x20
     cdc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     ce0:	fff94583          	lbu	a1,-1(s2)
     ce4:	8526                	mv	a0,s1
     ce6:	f5bff0ef          	jal	c40 <putc>
  while(--i >= 0)
     cea:	197d                	addi	s2,s2,-1
     cec:	ff391ae3          	bne	s2,s3,ce0 <printint+0x82>
     cf0:	7902                	ld	s2,32(sp)
     cf2:	69e2                	ld	s3,24(sp)
}
     cf4:	70e2                	ld	ra,56(sp)
     cf6:	7442                	ld	s0,48(sp)
     cf8:	74a2                	ld	s1,40(sp)
     cfa:	6121                	addi	sp,sp,64
     cfc:	8082                	ret
    x = -xx;
     cfe:	40b005bb          	negw	a1,a1
    neg = 1;
     d02:	4885                	li	a7,1
    x = -xx;
     d04:	bf85                	j	c74 <printint+0x16>

0000000000000d06 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d06:	711d                	addi	sp,sp,-96
     d08:	ec86                	sd	ra,88(sp)
     d0a:	e8a2                	sd	s0,80(sp)
     d0c:	e0ca                	sd	s2,64(sp)
     d0e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d10:	0005c903          	lbu	s2,0(a1)
     d14:	26090863          	beqz	s2,f84 <vprintf+0x27e>
     d18:	e4a6                	sd	s1,72(sp)
     d1a:	fc4e                	sd	s3,56(sp)
     d1c:	f852                	sd	s4,48(sp)
     d1e:	f456                	sd	s5,40(sp)
     d20:	f05a                	sd	s6,32(sp)
     d22:	ec5e                	sd	s7,24(sp)
     d24:	e862                	sd	s8,16(sp)
     d26:	e466                	sd	s9,8(sp)
     d28:	8b2a                	mv	s6,a0
     d2a:	8a2e                	mv	s4,a1
     d2c:	8bb2                	mv	s7,a2
  state = 0;
     d2e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d30:	4481                	li	s1,0
     d32:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d34:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d38:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d3c:	06c00c93          	li	s9,108
     d40:	a005                	j	d60 <vprintf+0x5a>
        putc(fd, c0);
     d42:	85ca                	mv	a1,s2
     d44:	855a                	mv	a0,s6
     d46:	efbff0ef          	jal	c40 <putc>
     d4a:	a019                	j	d50 <vprintf+0x4a>
    } else if(state == '%'){
     d4c:	03598263          	beq	s3,s5,d70 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     d50:	2485                	addiw	s1,s1,1
     d52:	8726                	mv	a4,s1
     d54:	009a07b3          	add	a5,s4,s1
     d58:	0007c903          	lbu	s2,0(a5)
     d5c:	20090c63          	beqz	s2,f74 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
     d60:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d64:	fe0994e3          	bnez	s3,d4c <vprintf+0x46>
      if(c0 == '%'){
     d68:	fd579de3          	bne	a5,s5,d42 <vprintf+0x3c>
        state = '%';
     d6c:	89be                	mv	s3,a5
     d6e:	b7cd                	j	d50 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d70:	00ea06b3          	add	a3,s4,a4
     d74:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d78:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d7a:	c681                	beqz	a3,d82 <vprintf+0x7c>
     d7c:	9752                	add	a4,a4,s4
     d7e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     d82:	03878f63          	beq	a5,s8,dc0 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
     d86:	05978963          	beq	a5,s9,dd8 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d8a:	07500713          	li	a4,117
     d8e:	0ee78363          	beq	a5,a4,e74 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     d92:	07800713          	li	a4,120
     d96:	12e78563          	beq	a5,a4,ec0 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     d9a:	07000713          	li	a4,112
     d9e:	14e78a63          	beq	a5,a4,ef2 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
     da2:	07300713          	li	a4,115
     da6:	18e78a63          	beq	a5,a4,f3a <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     daa:	02500713          	li	a4,37
     dae:	04e79563          	bne	a5,a4,df8 <vprintf+0xf2>
        putc(fd, '%');
     db2:	02500593          	li	a1,37
     db6:	855a                	mv	a0,s6
     db8:	e89ff0ef          	jal	c40 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
     dbc:	4981                	li	s3,0
     dbe:	bf49                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     dc0:	008b8913          	addi	s2,s7,8
     dc4:	4685                	li	a3,1
     dc6:	4629                	li	a2,10
     dc8:	000ba583          	lw	a1,0(s7)
     dcc:	855a                	mv	a0,s6
     dce:	e91ff0ef          	jal	c5e <printint>
     dd2:	8bca                	mv	s7,s2
      state = 0;
     dd4:	4981                	li	s3,0
     dd6:	bfad                	j	d50 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     dd8:	06400793          	li	a5,100
     ddc:	02f68963          	beq	a3,a5,e0e <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     de0:	06c00793          	li	a5,108
     de4:	04f68263          	beq	a3,a5,e28 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
     de8:	07500793          	li	a5,117
     dec:	0af68063          	beq	a3,a5,e8c <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
     df0:	07800793          	li	a5,120
     df4:	0ef68263          	beq	a3,a5,ed8 <vprintf+0x1d2>
        putc(fd, '%');
     df8:	02500593          	li	a1,37
     dfc:	855a                	mv	a0,s6
     dfe:	e43ff0ef          	jal	c40 <putc>
        putc(fd, c0);
     e02:	85ca                	mv	a1,s2
     e04:	855a                	mv	a0,s6
     e06:	e3bff0ef          	jal	c40 <putc>
      state = 0;
     e0a:	4981                	li	s3,0
     e0c:	b791                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e0e:	008b8913          	addi	s2,s7,8
     e12:	4685                	li	a3,1
     e14:	4629                	li	a2,10
     e16:	000ba583          	lw	a1,0(s7)
     e1a:	855a                	mv	a0,s6
     e1c:	e43ff0ef          	jal	c5e <printint>
        i += 1;
     e20:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     e22:	8bca                	mv	s7,s2
      state = 0;
     e24:	4981                	li	s3,0
        i += 1;
     e26:	b72d                	j	d50 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e28:	06400793          	li	a5,100
     e2c:	02f60763          	beq	a2,a5,e5a <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e30:	07500793          	li	a5,117
     e34:	06f60963          	beq	a2,a5,ea6 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e38:	07800793          	li	a5,120
     e3c:	faf61ee3          	bne	a2,a5,df8 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e40:	008b8913          	addi	s2,s7,8
     e44:	4681                	li	a3,0
     e46:	4641                	li	a2,16
     e48:	000ba583          	lw	a1,0(s7)
     e4c:	855a                	mv	a0,s6
     e4e:	e11ff0ef          	jal	c5e <printint>
        i += 2;
     e52:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e54:	8bca                	mv	s7,s2
      state = 0;
     e56:	4981                	li	s3,0
        i += 2;
     e58:	bde5                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e5a:	008b8913          	addi	s2,s7,8
     e5e:	4685                	li	a3,1
     e60:	4629                	li	a2,10
     e62:	000ba583          	lw	a1,0(s7)
     e66:	855a                	mv	a0,s6
     e68:	df7ff0ef          	jal	c5e <printint>
        i += 2;
     e6c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e6e:	8bca                	mv	s7,s2
      state = 0;
     e70:	4981                	li	s3,0
        i += 2;
     e72:	bdf9                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
     e74:	008b8913          	addi	s2,s7,8
     e78:	4681                	li	a3,0
     e7a:	4629                	li	a2,10
     e7c:	000ba583          	lw	a1,0(s7)
     e80:	855a                	mv	a0,s6
     e82:	dddff0ef          	jal	c5e <printint>
     e86:	8bca                	mv	s7,s2
      state = 0;
     e88:	4981                	li	s3,0
     e8a:	b5d9                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e8c:	008b8913          	addi	s2,s7,8
     e90:	4681                	li	a3,0
     e92:	4629                	li	a2,10
     e94:	000ba583          	lw	a1,0(s7)
     e98:	855a                	mv	a0,s6
     e9a:	dc5ff0ef          	jal	c5e <printint>
        i += 1;
     e9e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     ea0:	8bca                	mv	s7,s2
      state = 0;
     ea2:	4981                	li	s3,0
        i += 1;
     ea4:	b575                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     ea6:	008b8913          	addi	s2,s7,8
     eaa:	4681                	li	a3,0
     eac:	4629                	li	a2,10
     eae:	000ba583          	lw	a1,0(s7)
     eb2:	855a                	mv	a0,s6
     eb4:	dabff0ef          	jal	c5e <printint>
        i += 2;
     eb8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     eba:	8bca                	mv	s7,s2
      state = 0;
     ebc:	4981                	li	s3,0
        i += 2;
     ebe:	bd49                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
     ec0:	008b8913          	addi	s2,s7,8
     ec4:	4681                	li	a3,0
     ec6:	4641                	li	a2,16
     ec8:	000ba583          	lw	a1,0(s7)
     ecc:	855a                	mv	a0,s6
     ece:	d91ff0ef          	jal	c5e <printint>
     ed2:	8bca                	mv	s7,s2
      state = 0;
     ed4:	4981                	li	s3,0
     ed6:	bdad                	j	d50 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ed8:	008b8913          	addi	s2,s7,8
     edc:	4681                	li	a3,0
     ede:	4641                	li	a2,16
     ee0:	000ba583          	lw	a1,0(s7)
     ee4:	855a                	mv	a0,s6
     ee6:	d79ff0ef          	jal	c5e <printint>
        i += 1;
     eea:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     eec:	8bca                	mv	s7,s2
      state = 0;
     eee:	4981                	li	s3,0
        i += 1;
     ef0:	b585                	j	d50 <vprintf+0x4a>
     ef2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     ef4:	008b8d13          	addi	s10,s7,8
     ef8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     efc:	03000593          	li	a1,48
     f00:	855a                	mv	a0,s6
     f02:	d3fff0ef          	jal	c40 <putc>
  putc(fd, 'x');
     f06:	07800593          	li	a1,120
     f0a:	855a                	mv	a0,s6
     f0c:	d35ff0ef          	jal	c40 <putc>
     f10:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f12:	00000b97          	auipc	s7,0x0
     f16:	5ceb8b93          	addi	s7,s7,1486 # 14e0 <digits>
     f1a:	03c9d793          	srli	a5,s3,0x3c
     f1e:	97de                	add	a5,a5,s7
     f20:	0007c583          	lbu	a1,0(a5)
     f24:	855a                	mv	a0,s6
     f26:	d1bff0ef          	jal	c40 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f2a:	0992                	slli	s3,s3,0x4
     f2c:	397d                	addiw	s2,s2,-1
     f2e:	fe0916e3          	bnez	s2,f1a <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
     f32:	8bea                	mv	s7,s10
      state = 0;
     f34:	4981                	li	s3,0
     f36:	6d02                	ld	s10,0(sp)
     f38:	bd21                	j	d50 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     f3a:	008b8993          	addi	s3,s7,8
     f3e:	000bb903          	ld	s2,0(s7)
     f42:	00090f63          	beqz	s2,f60 <vprintf+0x25a>
        for(; *s; s++)
     f46:	00094583          	lbu	a1,0(s2)
     f4a:	c195                	beqz	a1,f6e <vprintf+0x268>
          putc(fd, *s);
     f4c:	855a                	mv	a0,s6
     f4e:	cf3ff0ef          	jal	c40 <putc>
        for(; *s; s++)
     f52:	0905                	addi	s2,s2,1
     f54:	00094583          	lbu	a1,0(s2)
     f58:	f9f5                	bnez	a1,f4c <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
     f5a:	8bce                	mv	s7,s3
      state = 0;
     f5c:	4981                	li	s3,0
     f5e:	bbcd                	j	d50 <vprintf+0x4a>
          s = "(null)";
     f60:	00000917          	auipc	s2,0x0
     f64:	51890913          	addi	s2,s2,1304 # 1478 <malloc+0x40c>
        for(; *s; s++)
     f68:	02800593          	li	a1,40
     f6c:	b7c5                	j	f4c <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
     f6e:	8bce                	mv	s7,s3
      state = 0;
     f70:	4981                	li	s3,0
     f72:	bbf9                	j	d50 <vprintf+0x4a>
     f74:	64a6                	ld	s1,72(sp)
     f76:	79e2                	ld	s3,56(sp)
     f78:	7a42                	ld	s4,48(sp)
     f7a:	7aa2                	ld	s5,40(sp)
     f7c:	7b02                	ld	s6,32(sp)
     f7e:	6be2                	ld	s7,24(sp)
     f80:	6c42                	ld	s8,16(sp)
     f82:	6ca2                	ld	s9,8(sp)
    }
  }
}
     f84:	60e6                	ld	ra,88(sp)
     f86:	6446                	ld	s0,80(sp)
     f88:	6906                	ld	s2,64(sp)
     f8a:	6125                	addi	sp,sp,96
     f8c:	8082                	ret

0000000000000f8e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f8e:	715d                	addi	sp,sp,-80
     f90:	ec06                	sd	ra,24(sp)
     f92:	e822                	sd	s0,16(sp)
     f94:	1000                	addi	s0,sp,32
     f96:	e010                	sd	a2,0(s0)
     f98:	e414                	sd	a3,8(s0)
     f9a:	e818                	sd	a4,16(s0)
     f9c:	ec1c                	sd	a5,24(s0)
     f9e:	03043023          	sd	a6,32(s0)
     fa2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     fa6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     faa:	8622                	mv	a2,s0
     fac:	d5bff0ef          	jal	d06 <vprintf>
}
     fb0:	60e2                	ld	ra,24(sp)
     fb2:	6442                	ld	s0,16(sp)
     fb4:	6161                	addi	sp,sp,80
     fb6:	8082                	ret

0000000000000fb8 <printf>:

void
printf(const char *fmt, ...)
{
     fb8:	711d                	addi	sp,sp,-96
     fba:	ec06                	sd	ra,24(sp)
     fbc:	e822                	sd	s0,16(sp)
     fbe:	1000                	addi	s0,sp,32
     fc0:	e40c                	sd	a1,8(s0)
     fc2:	e810                	sd	a2,16(s0)
     fc4:	ec14                	sd	a3,24(s0)
     fc6:	f018                	sd	a4,32(s0)
     fc8:	f41c                	sd	a5,40(s0)
     fca:	03043823          	sd	a6,48(s0)
     fce:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     fd2:	00840613          	addi	a2,s0,8
     fd6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     fda:	85aa                	mv	a1,a0
     fdc:	4505                	li	a0,1
     fde:	d29ff0ef          	jal	d06 <vprintf>
}
     fe2:	60e2                	ld	ra,24(sp)
     fe4:	6442                	ld	s0,16(sp)
     fe6:	6125                	addi	sp,sp,96
     fe8:	8082                	ret

0000000000000fea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fea:	1141                	addi	sp,sp,-16
     fec:	e422                	sd	s0,8(sp)
     fee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     ff0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ff4:	00001797          	auipc	a5,0x1
     ff8:	01c7b783          	ld	a5,28(a5) # 2010 <freep>
     ffc:	a02d                	j	1026 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     ffe:	4618                	lw	a4,8(a2)
    1000:	9f2d                	addw	a4,a4,a1
    1002:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1006:	6398                	ld	a4,0(a5)
    1008:	6310                	ld	a2,0(a4)
    100a:	a83d                	j	1048 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    100c:	ff852703          	lw	a4,-8(a0)
    1010:	9f31                	addw	a4,a4,a2
    1012:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1014:	ff053683          	ld	a3,-16(a0)
    1018:	a091                	j	105c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    101a:	6398                	ld	a4,0(a5)
    101c:	00e7e463          	bltu	a5,a4,1024 <free+0x3a>
    1020:	00e6ea63          	bltu	a3,a4,1034 <free+0x4a>
{
    1024:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1026:	fed7fae3          	bgeu	a5,a3,101a <free+0x30>
    102a:	6398                	ld	a4,0(a5)
    102c:	00e6e463          	bltu	a3,a4,1034 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1030:	fee7eae3          	bltu	a5,a4,1024 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1034:	ff852583          	lw	a1,-8(a0)
    1038:	6390                	ld	a2,0(a5)
    103a:	02059813          	slli	a6,a1,0x20
    103e:	01c85713          	srli	a4,a6,0x1c
    1042:	9736                	add	a4,a4,a3
    1044:	fae60de3          	beq	a2,a4,ffe <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1048:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    104c:	4790                	lw	a2,8(a5)
    104e:	02061593          	slli	a1,a2,0x20
    1052:	01c5d713          	srli	a4,a1,0x1c
    1056:	973e                	add	a4,a4,a5
    1058:	fae68ae3          	beq	a3,a4,100c <free+0x22>
    p->s.ptr = bp->s.ptr;
    105c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    105e:	00001717          	auipc	a4,0x1
    1062:	faf73923          	sd	a5,-78(a4) # 2010 <freep>
}
    1066:	6422                	ld	s0,8(sp)
    1068:	0141                	addi	sp,sp,16
    106a:	8082                	ret

000000000000106c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    106c:	7139                	addi	sp,sp,-64
    106e:	fc06                	sd	ra,56(sp)
    1070:	f822                	sd	s0,48(sp)
    1072:	f426                	sd	s1,40(sp)
    1074:	ec4e                	sd	s3,24(sp)
    1076:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1078:	02051493          	slli	s1,a0,0x20
    107c:	9081                	srli	s1,s1,0x20
    107e:	04bd                	addi	s1,s1,15
    1080:	8091                	srli	s1,s1,0x4
    1082:	0014899b          	addiw	s3,s1,1
    1086:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1088:	00001517          	auipc	a0,0x1
    108c:	f8853503          	ld	a0,-120(a0) # 2010 <freep>
    1090:	c915                	beqz	a0,10c4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1092:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1094:	4798                	lw	a4,8(a5)
    1096:	08977a63          	bgeu	a4,s1,112a <malloc+0xbe>
    109a:	f04a                	sd	s2,32(sp)
    109c:	e852                	sd	s4,16(sp)
    109e:	e456                	sd	s5,8(sp)
    10a0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    10a2:	8a4e                	mv	s4,s3
    10a4:	0009871b          	sext.w	a4,s3
    10a8:	6685                	lui	a3,0x1
    10aa:	00d77363          	bgeu	a4,a3,10b0 <malloc+0x44>
    10ae:	6a05                	lui	s4,0x1
    10b0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10b4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10b8:	00001917          	auipc	s2,0x1
    10bc:	f5890913          	addi	s2,s2,-168 # 2010 <freep>
  if(p == (char*)-1)
    10c0:	5afd                	li	s5,-1
    10c2:	a081                	j	1102 <malloc+0x96>
    10c4:	f04a                	sd	s2,32(sp)
    10c6:	e852                	sd	s4,16(sp)
    10c8:	e456                	sd	s5,8(sp)
    10ca:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    10cc:	00001797          	auipc	a5,0x1
    10d0:	33c78793          	addi	a5,a5,828 # 2408 <base>
    10d4:	00001717          	auipc	a4,0x1
    10d8:	f2f73e23          	sd	a5,-196(a4) # 2010 <freep>
    10dc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    10de:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    10e2:	b7c1                	j	10a2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    10e4:	6398                	ld	a4,0(a5)
    10e6:	e118                	sd	a4,0(a0)
    10e8:	a8a9                	j	1142 <malloc+0xd6>
  hp->s.size = nu;
    10ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    10ee:	0541                	addi	a0,a0,16
    10f0:	efbff0ef          	jal	fea <free>
  return freep;
    10f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    10f8:	c12d                	beqz	a0,115a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10fc:	4798                	lw	a4,8(a5)
    10fe:	02977263          	bgeu	a4,s1,1122 <malloc+0xb6>
    if(p == freep)
    1102:	00093703          	ld	a4,0(s2)
    1106:	853e                	mv	a0,a5
    1108:	fef719e3          	bne	a4,a5,10fa <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    110c:	8552                	mv	a0,s4
    110e:	b1bff0ef          	jal	c28 <sbrk>
  if(p == (char*)-1)
    1112:	fd551ce3          	bne	a0,s5,10ea <malloc+0x7e>
        return 0;
    1116:	4501                	li	a0,0
    1118:	7902                	ld	s2,32(sp)
    111a:	6a42                	ld	s4,16(sp)
    111c:	6aa2                	ld	s5,8(sp)
    111e:	6b02                	ld	s6,0(sp)
    1120:	a03d                	j	114e <malloc+0xe2>
    1122:	7902                	ld	s2,32(sp)
    1124:	6a42                	ld	s4,16(sp)
    1126:	6aa2                	ld	s5,8(sp)
    1128:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    112a:	fae48de3          	beq	s1,a4,10e4 <malloc+0x78>
        p->s.size -= nunits;
    112e:	4137073b          	subw	a4,a4,s3
    1132:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1134:	02071693          	slli	a3,a4,0x20
    1138:	01c6d713          	srli	a4,a3,0x1c
    113c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    113e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1142:	00001717          	auipc	a4,0x1
    1146:	eca73723          	sd	a0,-306(a4) # 2010 <freep>
      return (void*)(p + 1);
    114a:	01078513          	addi	a0,a5,16
  }
}
    114e:	70e2                	ld	ra,56(sp)
    1150:	7442                	ld	s0,48(sp)
    1152:	74a2                	ld	s1,40(sp)
    1154:	69e2                	ld	s3,24(sp)
    1156:	6121                	addi	sp,sp,64
    1158:	8082                	ret
    115a:	7902                	ld	s2,32(sp)
    115c:	6a42                	ld	s4,16(sp)
    115e:	6aa2                	ld	s5,8(sp)
    1160:	6b02                	ld	s6,0(sp)
    1162:	b7f5                	j	114e <malloc+0xe2>
