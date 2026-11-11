---
name: sdd-mantenimiento
description: Mantiene un docs/contexts/<ID>-context.md a nivel de plan cuando cambian requisitos, la spec, decisiones, prioridades o el estado del trabajo (aprobación del plan, pausa, bloqueo). Clasifica el cambio como menor o significativo, conserva el historial y mantiene sincronizados el estado general y el de cada tarea. Parte del flujo /sdd, que es quien la invoca.
---

# sdd-mantenimiento

Actualizas el **mismo** contexto cuando cambia algo del plan. Nunca creas un contexto nuevo para el mismo trabajo y nunca borras historial.

Límite con `sdd-auditoria`: tú manejas el **plan** (alcance, decisiones, tareas, estados globales); `sdd-auditoria` maneja el **resultado de cada tarea** (implementación, verificaciones, entrega, commits, cierre). Los dos escriben en la misma bitácora.

## 1. Registrar primero

Toda solicitud de cambio se registra en la bitácora **antes** de modificar el plan: qué se pidió, quién lo pidió y en qué tarea estaba el trabajo.

## 2. Clasificar el cambio

**Menor** (se aplica y se registra como `SCOPE_CHANGE` menor), si cumple todo:
- no cambia el objetivo;
- no contradice una decisión aprobada;
- no modifica un contrato (API, tipos que consumen otros, forma del estado o de los datos, rutas);
- no afecta a otras tareas ni a sus criterios;
- es necesario para cumplir la tarea activa.

**Significativo** (cualquier otro caso): amplía el alcance, altera una decisión, modifica un contrato, afecta otras tareas o cambia requisitos importantes. Entonces:
1. Detener el trabajo en curso.
2. Explicar el impacto: tareas, criterios, dependencias y decisiones afectadas.
3. Proponer la modificación concreta del plan.
4. Esperar autorización. Mientras tanto, la tarea afectada queda `BLOCKED` si no puede avanzar.
5. Con la autorización: aplicar los cambios y registrar `SCOPE_CHANGE` y `PLAN_APPROVED` (plan modificado).

Ante la duda: significativo.

## 3. Aplicar cambios sin perder historial

- **Decisiones:** una decisión aprobada no se reescribe. Se marca `SUPERSEDED`, indicando la nueva `D-xx` que la reemplaza, y se registra un evento `DECISION`.
- **Tareas eliminadas:** no se borran; pasan a `DESCOPED` con su motivo.
- **Tareas nuevas:** se agregan al final con un ID nuevo (no se renumeran las existentes), con criterios, verificaciones y dependencias.
- **Tareas modificadas:** se actualiza el bloque y en la bitácora se resume qué cambió (antes → después).
- Las tareas no afectadas no se tocan.

## 4. Eventos de estado que te tocan

| Evento | Qué actualizar |
|---|---|
| El usuario aprueba el plan | Bitácora `PLAN_APPROVED`; "Plan aprobado: sí (fecha, fila)"; contexto → `PLAN_APPROVED`. No autorizar ninguna tarea. |
| Se resuelve una decisión | Tabla de decisiones (decisión final, estado, fecha, quién) + `DECISION`. |
| El usuario pide una pausa o cambia prioridades | Bitácora; "Autorización vigente: ninguna". La tarea en curso conserva su estado con la nota "pausada"; para retomarla hace falta un nuevo `TASK_AUTHORIZED`. |
| Impedimento | `BLOCKED` en la tarea (y en el contexto si nada puede avanzar), con el motivo y las opciones. |
| Se levanta un bloqueo | Bitácora; la tarea vuelve a su estado anterior, sin autorización automática. |

## 5. Reglas de sincronización

1. En cada transición, actualizar a la vez el estado general (§1 del contexto), el bloque de la tarea y la bitácora.
2. "Última actualización" con la fecha del día.
3. No marcar `APPROVED`, `PLAN_APPROVED` ni `TASK_AUTHORIZED` sin una orden explícita del usuario, citada en la bitácora.
4. Si cambia el plan, revisar las dependencias y los criterios de las tareas afectadas.
5. No pasar a `COMPLETED` mientras queden tareas sin aprobar, correcciones pendientes o decisiones `PENDING`.
6. Las excepciones que acepta el usuario se registran como `EXCEPTION_ACCEPTED` sin cambiar el resultado real de las verificaciones (un `NOT_RUN` sigue siendo `NOT_RUN`).
7. Si el estado del archivo y lo que dice el usuario no coinciden, decirlo y preguntar; no corregir en silencio.

## 6. Al terminar

Mostrar al usuario qué cambió en el plan, qué tareas quedaron afectadas y qué autorización o decisión falta. Detenerse.

Toda decisión nueva o pendiente que se le presente (cambio significativo, `BLOCKED`, decisión surgida durante una tarea) usa el formato explicado del paso 7 de `sdd-planificacion`: problema, qué pasa hoy en el código, lo que no sé, opciones, recomendación y lo que necesito de ti, más un resumen final. No presentar solo la tabla.
