#include "user/user.h"
#include "kernel/param.h"

int
main(int argc, char *argv[])
{
  int ppid;

  ppid = getppid();
  printf("Parent process ID: %d\n", ppid);

  exit(0);
}
