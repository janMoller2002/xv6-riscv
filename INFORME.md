# Informe de Instalación de xv6

## 1. Pasos seguidos para instalar xv6

1. **Instalación de WSL (Windows Subsystem for Linux)**: 
   - Se instaló WSL y Ubuntu desde la tienda de Windows para poder trabajar en un entorno de desarrollo Linux desde Windows.

2. **Instalación de dependencias necesarias**:
   - Se instalaron las dependencias requeridas para la compilación de xv6, como `build-essential`, `qemu`, y otros paquetes adicionales.

3. **Instalación de riscv-gnu-toolchain**:
   - Se clonó y compiló la herramienta `riscv-gnu-toolchain`, necesaria para compilar xv6 para la arquitectura RISC-V.
   - Se ejecutaron los siguientes comandos:
     ```bash
     git clone https://github.com/riscv/riscv-gnu-toolchain
     cd riscv-gnu-toolchain
     ./configure --prefix=/opt/riscv
     sudo make -j$(nproc)
     sudo make install
     ```

4. **Clonación de xv6**:
   - Se clonó el repositorio de xv6 del MIT y se configuró el entorno de trabajo.
   - Se ejecutaron los siguientes comandos:
     ```bash
     git clone https://github.com/mit-pdos/xv6-riscv
     cd xv6-riscv
     ```

5. **Compilación y ejecución de xv6**:
   - Se compiló y ejecutó el sistema operativo xv6 usando QEMU con el comando:
     ```bash
     make qemu
     ```

## 2. Problemas encontrados y soluciones

### Problema 1: Archivos faltantes y solucion de errores
   - **Solución**: En el proceso de instlacion de Xv6 se precetaron diversos problemas que requerian instalacion, reinstalacion, actualizaciones e investigacion de archivos faltantes los cuales se fueron solucionando poco a poco con ayuda de ChatGPT.

### Problema 2: Error al inciar make qemu
   - **Solución**: Despues de instalar el proceso en mi otro dispositivo, aunque cumplia todos los requisitos para iniciar make qemu, este se detenia a mitad del proceso y se quedaba pegado sin mostrar ningun error. Tuve que cambiar de ordenador he instalar todo nuevamente hasta que resulto.

### Problema 3: Instalación de riscv-gnu-toolchain
   - **Solución**: Se enfrentaron problemas durante la instalación debido a dependencias faltantes. Se instalaron librerías adicionales como `libgmp-dev`, `libmpfr-dev` y `libmpc-dev`, y se ejecutó nuevamente el proceso de instalación.

### Problema 4: Autenticación fallida en GitHub
   - **Solución**: Se generó un token de acceso personal para poder realizar `git push` hacia GitHub, ya que GitHub había deshabilitado la autenticación con contraseña para comandos de Git.

## 3. Confirmación de que xv6 está funcionando correctamente

Después de completar la instalación y resolución de problemas, se verificó que xv6 estaba funcionando correctamente. Se logró compilar y ejecutar xv6 usando QEMU, lo cual fue confirmado con éxito al ver el sistema operativo en ejecución.

- Comando ejecutado: `make qemu`
- Salida esperada: La pantalla de QEMU mostrando el sistema operativo xv6 en funcionamiento.

El sistema operativo xv6 está ahora configurado y listo para futuras tareas y desarrollo.