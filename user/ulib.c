#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"
#include "kernel/syscall.h"
#include <stdarg.h>  // Para manejar argumentos variables

//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  extern int main();
  main();
  exit(0);
}

char*
strcpy(char *s, const char *t)
{
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    ;
  return os;
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    p++, q++;
  return (uchar)*p - (uchar)*q;
}

uint
strlen(const char *s)
{
  int n;

  for(n = 0; s[n]; n++)
    ;
  return n;
}

void*
memset(void *dst, int c, uint n)
{
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    cdst[i] = c;
  }
  return dst;
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    if(*s == c)
      return (char*)s;
  return 0;
}

char*
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
  return buf;
}

int
stat(const char *n, struct stat *st)
{
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  if(fd < 0)
    return -1;
  r = fstat(fd, st);
  close(fd);
  return r;
}

int
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    n = n*10 + *s++ - '0';
  return n;
}

void*
memmove(void *vdst, const void *vsrc, int n)
{
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    while(n-- > 0)
      *dst++ = *src++;
  } else {
    dst += n;
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}

int
memcmp(const void *s1, const void *s2, uint n)
{
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    if (*p1 != *p2) {
      return *p1 - *p2;
    }
    p1++;
    p2++;
  }
  return 0;
}

void *
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
}

int
getppid(void)
{
  return syscall(SYS_getppid);
}

// Implementación de la función syscall
long
syscall(int num, ...)
{
  // Manejar argumentos variables
  va_list ap;
  va_start(ap, num);

  // Cargar los argumentos en los registros
  register uint64 a0 asm("a0") = va_arg(ap, uint64);
  register uint64 a1 asm("a1") = va_arg(ap, uint64);
  register uint64 a2 asm("a2") = va_arg(ap, uint64);
  register uint64 a3 asm("a3") = va_arg(ap, uint64);
  register uint64 a4 asm("a4") = va_arg(ap, uint64);
  register uint64 a5 asm("a5") = va_arg(ap, uint64);
  
  va_end(ap);

  // Hacer la llamada al sistema
  register uint64 syscall_num asm("a7") = num;
  asm volatile("ecall"
               : "+r" (a0)
               : "r" (syscall_num), "r" (a1), "r" (a2), "r" (a3), "r" (a4), "r" (a5)
               : "memory");

  // Retornar el resultado
  return a0;
}
