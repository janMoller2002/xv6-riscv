# Informe de Implementación de la Llamada al Sistema `getppid` en xv6

## Funcionamiento de las Llamadas al Sistema

En xv6, las llamadas al sistema proporcionan una interfaz para que los programas de usuario interactúen con el núcleo del sistema operativo. Estas llamadas permiten a los programas realizar operaciones que requieren permisos especiales, como la creación de procesos, la lectura y escritura de archivos, y la comunicación entre procesos.

## Funcionamiento de `getppid`

La llamada al sistema `getppid` permite a un proceso obtener el ID del proceso padre. Este ID es útil para que un proceso pueda saber qué proceso lo creó o está gestionando. La función `getppid` se implementa de manera que devuelve el ID del proceso padre del proceso que la invoca.

## Explicación de las Modificaciones Realizadas

1. **Definición de la Llamada al Sistema `getppid`:**

   Se añadió la llamada al sistema `getppid` en los siguientes archivos:

   - `kernel/syscall.h`: Se definió un nuevo identificador de llamada al sistema `SYS_getppid`.
   - `kernel/syscall.c`: Se implementó el manejo de la llamada al sistema `getppid` en la función `syscall`.

2. **Implementación de la Función `syscall` en `ulib.c`:**

   Se añadió una función `syscall` para invocar las llamadas al sistema desde el espacio de usuario. Esta función permite a los programas de usuario ejecutar llamadas al sistema usando el número de llamada al sistema y los parámetros necesarios.

   ```c
   long syscall(int num, ...) {
       va_list args;
       long ret;
       va_start(args, num);
       asm volatile (
           "mov a7, %1\n"
           "mv a0, %2\n"
           "mv a1, %3\n"
           "mv a2, %4\n"
           "mv a3, %5\n"
           "mv a4, %6\n"
           "mv a5, %7\n"
           "ecall\n"
           "mv %0, a0"
           : "=r"(ret)
           : "r"(num), "r"(va_arg(args, int)), "r"(va_arg(args, int)), "r"(va_arg(args, int)), "r"(va_arg(args, int)), "r"(va_arg(args, int)), "r"(va_arg(args, int))
           : "a0", "a1", "a2", "a3", "a4", "a5", "a7"
       );
       va_end(args);
       return ret;
   }

3. **Actualización del Archivo `user.h`:**

   Se incluyó la declaración de la función `syscall` y las demás funciones necesarias en el archivo `user.h`.

    ```c
    long syscall(int, ...);

4. **Prueba de la Nueva Llamada al Sistema:**
    
    Se creó un nuevo programa de prueba test_getppid.c para verificar la correcta implementación de la llamada al sistema getppid. Este programa imprime el ID del proceso padre del proceso que lo ejecuta.

    ```c
    #include "user/user.h"
    #include "user/ulib.h"

    int main() {
        int ppid = getppid();
        printf("Parent process ID: %d\n", ppid);
        exit(0);
    }

    El programa se incluyó en el Makefile para que se compile y ejecute con el resto de los programas de usuario en xv6.

## Dificultades Encontradas y Cómo se Resolvían

1. **Problemas con `syscall` en `ulib.c`:**

   - **Problema:** La función `syscall` no estaba definida correctamente, lo que causaba errores de compilación.
   - **Solución:** Se reescribió la función `syscall` con la firma adecuada y el código correcto para realizar llamadas al sistema.

2. **Errores de Declaración en `user.h`:**

   - **Problema:** Se encontraron errores relacionados con tipos desconocidos como `uint`.
   - **Solución:** Se reemplazaron `uint` con `unsigned int` en las declaraciones de funciones en `user.h` para asegurar la compatibilidad con el compilador.

3. **Errores de Referencia No Definida:**

   - **Problema:** Se produjo un error de referencia no definida para la función `syscall`.
   - **Solución:** Se aseguró que la función `syscall` estuviera correctamente implementada en `ulib.c` y se actualizaron las referencias en otros archivos de código.

4. **Errores de Configuración del `Makefile`:**

   - **Problema:** El `Makefile` no incluía la nueva llamada al sistema en la lista de programas a compilar.
   - **Solución:** Se actualizó el `Makefile` para incluir el nuevo programa de prueba `test_getppid` en la lista de `UPROGS`.








