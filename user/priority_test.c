#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    for (int i = 0; i < 20; i++) {
        if (fork() == 0) {
            // Proceso hijo
            sleep(i);  // Dejar que cada hijo espere un poco antes de imprimir
            printf("Ejecutando proceso hijo %d, pid %d\n", i, getpid());
            sleep(10);  // El proceso duerme por 10 ticks
            exit(0);
        }
    }

    for (int i = 0; i < 20; i++) {
        wait(0);  // Esperar a que todos los procesos hijos terminen
    }

    exit(0);
}
