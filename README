# Informe sobre la Implementación del Sistema de Prioridades en xv6

## Funcionamiento y Lógica del Sistema de Prioridades

La implementación del sistema de prioridades en el kernel de xv6 permite gestionar de manera más efectiva la ejecución de procesos en el sistema operativo. A continuación, se describen las características clave de este sistema:

1. **Prioridad de Procesos**: Cada proceso tiene un campo de `prioridad`, que se inicializa en 0, donde un número menor indica una mayor prioridad. Esto significa que los procesos con menor valor de prioridad son seleccionados para la ejecución antes que aquellos con valores más altos.

2. **Campo de Boost**: Se ha agregado un campo de `boost` a la estructura del proceso, que se utiliza para modificar la prioridad de manera dinámica durante la ejecución. El `boost` se inicializa en 1.

3. **Lógica de Aumento de Prioridad**: Cada vez que un proceso se ejecuta, la prioridad del mismo se incrementa en función del valor de `boost`. Esto se realiza en el bucle del planificador (`scheduler`), donde se ajusta la prioridad de cada proceso que está en estado `RUNNABLE`.

4. **Condiciones de Ajuste de Boost**: 
   - Si la prioridad de un proceso alcanza 9, el `boost` se cambia a -1, lo que previene que la prioridad aumente más allá de este valor.
   - Si la prioridad llega a 0, el `boost` se ajusta a 1, lo que permite que la prioridad de otros procesos pueda aumentar nuevamente.

5. **Selección del Proceso a Ejecutar**: El planificador busca el proceso con la mayor prioridad (el valor numérico más bajo) y lo ejecuta. Si no hay procesos `RUNNABLE`, el sistema entra en un estado de espera hasta que ocurra una interrupción.

Este enfoque permite una gestión más justa y eficiente de los procesos, mejorando el rendimiento general del sistema operativo.

## Explicación de las Modificaciones Realizadas

Se realizaron las siguientes modificaciones en el kernel de xv6 para implementar el sistema de prioridades:

1. **Estructura del Proceso**: Se añadió un campo de `boost` a la estructura de datos del proceso en `proc.h` y se modificó la inicialización de `priority` y `boost` en la función de creación de procesos.

2. **Planificador (`scheduler`)**:
   - Se modificó el código para buscar el proceso con la mayor prioridad (menor valor) en lugar de simplemente seleccionar el primer proceso `RUNNABLE`.
   - Se implementó la lógica para incrementar la prioridad de cada proceso utilizando su `boost`.
   - Se incluyó la lógica para ajustar el `boost` basado en los límites de prioridad establecidos.

3. **Programa de Prueba (`priority_test`)**:
   - Se creó un programa de usuario para probar el nuevo sistema de prioridades, que genera múltiples procesos y verifica que se ejecuten de acuerdo con la lógica de prioridad.

## Dificultades Encontradas y Soluciones Implementadas

Durante la implementación del sistema de prioridades, se encontraron varias dificultades, así como las soluciones aplicadas para superarlas:

1. **Sincronización de Acceso a Procesos**:
   - **Dificultad**: Se presentaron problemas de acceso concurrente a la estructura de procesos, lo que resultaba en condiciones de carrera y bloqueos.
   - **Solución**: Se implementaron adecuadamente bloqueos (`acquire` y `release`) alrededor de las secciones críticas donde se accede o se modifica la estructura de procesos.

2. **Manejo de Prioridades y Boost**:
   - **Dificultad**: La lógica para incrementar la prioridad y ajustar el `boost` no estaba funcionando correctamente en las primeras pruebas, resultando en comportamientos inesperados en la ejecución de procesos.
   - **Solución**: Se revisó y ajustó la lógica para asegurarse de que el `boost` y la prioridad se modificaran en el momento adecuado y se incluyeron mensajes de depuración para rastrear los valores de `priority` y `boost` durante la ejecución.

3. **Ejecución del Programa de Prueba**:
   - **Dificultad**: Al ejecutar el programa de prueba `priority_test`, se encontraban errores al intentar ejecutar los procesos.
   - **Solución**: Se revisó la integración del programa en el `Makefile` y se aseguraron las dependencias necesarias para su correcta compilación y ejecución.
