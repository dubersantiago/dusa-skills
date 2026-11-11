# Pruebas y verificación en ODD

## Modo TDD

- Se resuelve de la configuración existente del proyecto (`odd/config.md`), de la sesión o de una elección explícita del usuario. **Que existan tests no activa TDD.**
- En trabajo grande, registrar en la cabecera del documento el modo, su fuente y el runner exacto, y pasarlos en cada delegación. Al reanudar, refrescarlos.
- Si el modo es desconocido o contradictorio, o falta el runner: hacer solo la pregunta que afecta a la siguiente acción. Nunca inventar precedencias ni comandos.

**TDD on:** cuando existe un test relevante, ejecutable y determinista, y el resultado esperado es claro: observar **RED** antes de implementar → **GREEN** → refactor con los tests en verde.
**TDD off:** igual se exigen checks funcionales ordinarios.
**Excepciones** (documentación pasiva, runner no disponible, ningún RED significativo posible): explicar la excepción y correr checks funcionales o estructurales proporcionales. Nunca inventar evidencia RED/GREEN.

## Qué testear

- **Un test RED por regla pedida.** Cada test afirma **todos** los efectos observables de la regla (código de salida, stdout y stderr exactos, y que una entrada rechazada deja los datos y contadores sin cambios), cubre los casos que la propia regla nombra (sus ejemplos, bordes y errores) y comprueba a través de la interfaz pública, nunca del almacenamiento interno.
- **Regresión de lo compartido:** por cada comando u opción existente que el cambio toca, un test que demuestre que su comportamiento anterior se mantiene; ningún otro caso extra. Un comportamiento existente se considera tocado cuando comparte el código que cambiaste (opciones, parsers, helpers, validación).
- **Comparación diferencial** antes de terminar: por cada comando existente que comparte el código cambiado, ejecutarlo con la entrada nueva o cambiada contra el código anterior (una copia del commit base en un directorio de `mktemp -d`, nunca commiteada como test) y contra el cambio, y comparar stdout, stderr y código de salida. Cualquier diferencia que nadie pidió es una regresión: arreglarla y fijarla con un test. Los tests commiteados nunca leen el historial de git ni un commit fijo.
- Cuando el usuario reporta una falla, **reproducirla** antes de decidir que ya funciona.
- Al agregar o cambiar un comando, opción o mensaje, actualizar el texto de ayuda y la documentación que lo describen.

## Cuándo correr qué

- Checks enfocados mientras se itera; la suite completa aplicable al cerrar la tarea. Un check rápido aplicable corre una vez.
- Un verificador o subagente no disponible se reporta como **no disponible**; no se reintenta ni se escala a más ceremonia.
- Prueba parcial, bloqueada, no disponible o agotada → un único **"Necesita tu decisión"** con los bloqueos o la prueba que falta, no más verificación.

## Scratch

- El estado temporal de los tests (directorios temporales, `HOME`, `TMPDIR`, cachés) va **fuera del worktree**, en un `mktemp -d`. Si tiene que vivir dentro, usar una ruta que git excluya y borrarla antes de terminar: ningún caché ni ruta de scratch queda en el cambio.
- Los subagentes nunca borran scratch: reportan sus rutas exactas, y el padre lo elimina después de usarlo.
