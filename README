## Informe de Implementación de Protección de Memoria en xv6

### 1. Funcionamiento y Lógica de la Protección de Memoria

El sistema de protección de memoria en xv6 asegura que cada proceso tenga un espacio de direcciones seguro e independiente. La protección de memoria es vital para evitar que un proceso pueda leer o escribir en el espacio de otro proceso, lo cual protege la integridad de los datos y el sistema en general. En esta implementación, se utilizaron dos nuevas llamadas al sistema: `mprotect` y `munprotect`.

- **mprotect**: Permite proteger una región de memoria dentro de un proceso contra escrituras. Al recibir una dirección base (`addr`) y una longitud (`len`), `mprotect` calcula el número de páginas que cubren esta región y desactiva el bit de escritura (`W`) en la tabla de páginas de cada una de esas páginas. De esta forma, cualquier intento de escritura en esta área protegida resultará en una excepción de protección de memoria.
  
- **munprotect**: Esta función restaura el permiso de escritura en una región de memoria previamente protegida por `mprotect`. Al recibir `addr` y `len`, `munprotect` calcula las páginas afectadas y reactiva el bit de escritura (`W`) en cada página, permitiendo que el proceso pueda escribir nuevamente en esta región de memoria.

Estas funciones proporcionan una capa de control adicional sobre el uso de la memoria dentro de cada proceso, lo que permite simular y probar diferentes niveles de protección.

### 2. Explicación de las Modificaciones Realizadas

Para implementar `mprotect` y `munprotect` en xv6, se realizaron los siguientes cambios:

1. **Modificaciones en la Tabla de Páginas**: 
   - Se agregaron funciones para recorrer las entradas de tabla de páginas (PTEs) de cada página afectada. En `mprotect`, cada PTE es modificado para desactivar el bit `W`, mientras que en `munprotect`, el bit `W` se restaura.

2. **Manejo de Excepciones en `usertrap`**:
   - Se ajustó la función `usertrap` para interceptar errores de protección de memoria. Si un proceso intenta escribir en una región protegida, `usertrap` maneja esta interrupción y marca el proceso para ser terminado, lo que evita que acceda a la memoria sin autorización.

3. **Manejo de Errores en `mprotect` y `munprotect`**:
   - Se implementaron validaciones en ambas llamadas para verificar que `addr` esté alineado con el tamaño de página y que `len` sea mayor que cero.
   - Las funciones devuelven un error si se detecta que `addr` o `len` caen fuera del espacio de direcciones del proceso.

4. **Test_mprotect**:
   - Se desarrollo una serie de pruebas para `mprotect` y `munprotect`, asegurándonos de que cualquier intento de escritura en una página protegida generara un error de violación de memoria correctamente.

### 3. Dificultades Encontradas y Soluciones Implementadas

Durante la implementación de `mprotect` y `munprotect`, encontramos varios desafíos. Estos son los más importantes y cómo los resolvimos:

- **Identificación de Causas de Excepción (scause)**:
   - Al principio, los errores de protección de memoria no se detectaban como esperábamos debido a la falta de manejo específico para excepciones como `Store Protection Exception`. Al ajustar `usertrap` para verificar códigos específicos de scause (`0x13`, `0x15` y `0x0f`), logramos manejar las interrupciones correctamente.

- **Control de Acceso en la Tabla de Páginas**:
   - Modificar el bit `W` en los PTEs presentó complicaciones porque la lógica de permisos es fundamental en xv6. Asegurarse de que solo se modificaran los PTEs correctos y que las protecciones se activaran y desactivaran como se espera fue clave para la implementación.
   - La solución consistió en revisar cuidadosamente cada cambio en la tabla de páginas, confirmando que el bit de escritura se desactivara y activara sin modificar otros bits de protección accidentalmente.

- **Problemas con Direcciones Inválidas**:
   - Al inicio, `mprotect` y `munprotect` no verificaban si `addr` y `len` eran válidos para el proceso, lo que causaba errores de segmentación. Para resolver esto, agregamos verificaciones que confirmaban que la dirección base y la longitud cayeran dentro del rango permitido del proceso. Esto evitó accesos indebidos y aumentó la robustez de nuestras funciones.
