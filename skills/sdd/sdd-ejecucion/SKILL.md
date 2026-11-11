---
name: sdd-ejecucion
description: Implementa una sola tarea autorizada de un docs/contexts/<ID>-context.md, solo dentro de su alcance aprobado. Comprueba autorización, dependencias y decisiones antes de empezar, registra los ajustes menores y se detiene ante un cambio significativo. Al terminar pasa por verificación y auditoría, entrega para revisión y no inicia la siguiente tarea. Parte del flujo /sdd, que es quien la invoca.
---

# sdd-ejecucion

Implementas **una** tarea: la activa y autorizada. Nada más.

## 1. Antes de tocar un archivo

1. Leer el contexto desde disco: el bloque de la tarea, las decisiones que la afectan, "Impacto y riesgos" y las últimas filas de la bitácora.
2. Confirmar las comprobaciones de `sdd` §4. Si alguna falla, no empezar: informar cuál falla.
3. Actualizar el contexto: tarea → `IN_PROGRESS`; "Tarea activa" y "Autorización vigente" con el ID de la tarea; contexto → `IN_PROGRESS`.
4. Leer el contenido actual de cada archivo que se va a modificar. No asumir su estado a partir de la conversación.
5. Cargar las "skills técnicas" que declare `docs/contexts/_config.md` y seguir las instrucciones del proyecto (`CLAUDE.md`, `AGENTS.md`).

## 2. Implementar

- Solo lo que dicen el alcance y los criterios de aceptación de la tarea.
- No adelantar trabajo de otras tareas, aunque sea "de paso".
- No mejorar código adyacente. Si aparece algo que merece atención, mencionarlo en una línea y registrarlo en "Observaciones fuera de alcance"; no tocarlo.
- Reutilizar lo que ya existe (utilidades, servicios, patrones de otras áreas) antes de crear algo nuevo.
- La implementación ocurre en la sesión principal; no delegarla en subagentes.

### Cambios durante la tarea
- **Ajuste menor** (criterios de `sdd-mantenimiento` §2): aplicarlo y anotarlo en "Limitaciones / desvíos" de la tarea y como `SCOPE_CHANGE` menor en la bitácora.
- **Cambio significativo:** detenerse **antes** de implementarlo y pasar a `sdd-mantenimiento`. No seguir con la parte afectada hasta tener autorización.
- **Acción destructiva** (borrar archivos, sobrescribir lo que no es del trabajo): mostrar la lista exacta y esperar confirmación, aunque la tarea esté autorizada.

## 3. Al terminar la implementación

1. Cargar `sdd-verificacion` y ejecutar las verificaciones requeridas por la tarea.
2. Si algo falla y la corrección está dentro del alcance, corregir y volver a verificar. Si no lo está, registrarlo como `FAIL` y explicarlo.
3. Cargar `sdd-auditoria` para llenar el "Resultado" de la tarea, registrar `IMPLEMENTATION`, `VERIFICATION` y `READY_FOR_REVIEW` en la bitácora, y entregar para revisión.
4. **Detenerse.** No seleccionar ni iniciar la siguiente tarea. No hacer commit.

## 4. Cuando el usuario pide cambios (`CHANGES_REQUESTED`)

- La tarea sigue siendo la activa y conserva su ID.
- Registrar cada observación del usuario en la bitácora antes de corregir.
- Corregir solo lo pedido (si lo pedido es significativo, aplicar §2).
- Repetir las verificaciones afectadas y volver a entregar: `READY_FOR_REVIEW` en una fila nueva; las anteriores no se editan.

## Restricciones

- Una tarea por autorización. Sin orden explícita no hay tarea nueva.
- Nunca commit, push ni comandos destructivos de git.
- No afirmar que algo funciona sin una verificación ejecutada que lo respalde.
