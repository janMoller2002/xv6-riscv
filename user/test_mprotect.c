#include "user.h"

int main() {
    char *addr = sbrk(0);  // Obtener la dirección actual del heap
    sbrk(4096);  // Reservar una página (4096 bytes)

    // Intentar proteger la nueva página
    if (mprotect(addr, 1) == -1) {
        printf("mprotect falló\n");
        exit(1);
    }

    // Intentar escribir en la página protegida
    char *ptr = addr;
    printf("Intentando escribir en la página protegida...\n");
    *ptr = 'A';  // Esto debería fallar si la protección es exitosa

    // Si el sistema de protección funciona, no debería llegar aquí sin un error
    printf("Error: Escritura en página protegida no falló como se esperaba.\n");

    // Ahora desprotegemos la página
    if (munprotect(addr, 1) == -1) {
        printf("munprotect falló\n");
        exit(1);
    }

    // Intentar escribir nuevamente en la página después de desprotegerla
    printf("Intentando escribir en la página desprotegida...\n");
    *ptr = 'B';  // Esto debería tener éxito
    printf("Escritura exitosa en la página desprotegida, valor: %c\n", *ptr);

    exit(0);
}
