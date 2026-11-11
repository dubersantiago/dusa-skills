<!--
PLANTILLA DE CONTEXTO — MODO NORMAL
Ubicación del archivo generado: docs/contexts/<ID>-context.md (un archivo por trabajo).
Usar modo normal para features nuevos, cambios en varias capas o cambios disruptivos.
Para tareas chicas usar context-template-ligero.md.

Reglas de llenado:
- Secciones marcadas [OBLIGATORIA] siempre van. Las [OPCIONAL] se omiten si no aplican (no dejarlas vacías).
- Reemplazar todo lo que esté entre [corchetes]. Borrar este comentario en el archivo generado.
- Nada se borra del historial: si algo cambia, se registra en la bitácora (§8) y se actualiza el bloque afectado.
- Ningún estado de aprobación o autorización se escribe sin una orden explícita del usuario.
-->

# [ID] — Context: [nombre del trabajo]

## 1. Estado general [OBLIGATORIA]

- **ID:** [ID — p. ej. FAJR-003]
- **Modo:** normal
- **Estado del contexto:** `PLANNING`
- **Spec / brief:** [ruta o referencia; "sin spec — descripción del usuario" si no hay]
- **Área:** [ruta en el repo]
- **Rama de trabajo:** [rama, si se conoce]
- **Creado:** [AAAA-MM-DD]
- **Última actualización:** [AAAA-MM-DD]
- **Plan aprobado por el usuario:** no
- **Tarea activa:** ninguna
- **Autorización de ejecución vigente:** ninguna
- **Método de trabajo:** una tarea a la vez. Al terminar cada tarea se actualiza este contexto, se presenta el resultado y se detiene el trabajo. Aprobar una tarea no autoriza la siguiente. Los commits los hace el usuario.

### Estados

**Contexto**

| Estado | Significado |
|---|---|
| `PLANNING` | Se está preparando el contexto. No se implementa código. |
| `AWAITING_PLAN_APPROVAL` | Contexto y plan presentados; esperan aprobación del usuario. |
| `PLAN_APPROVED` | Plan aprobado; ninguna tarea autorizada o en curso. También aplica entre tareas. |
| `IN_PROGRESS` | Hay una tarea autorizada, en curso o en revisión. |
| `BLOCKED` | Una decisión, dependencia o impedimento evita avanzar. |
| `COMPLETED` | Se cumplen todas las condiciones de cierre (§9). |

**Tarea**

| Estado | Significado |
|---|---|
| `PENDING` | Planificada; sin autorización. |
| `AUTHORIZED` | El usuario autorizó ejecutarla; aún no empieza. |
| `IN_PROGRESS` | En implementación. |
| `READY_FOR_REVIEW` | Implementada, verificada (o con verificaciones declaradas como no ejecutadas) y presentada. |
| `CHANGES_REQUESTED` | El usuario pidió correcciones; sigue siendo la tarea activa. |
| `APPROVED` | El usuario la aprobó. **No autoriza la siguiente.** |
| `BLOCKED` | No puede avanzar; el motivo está en la bitácora. |
| `DESCOPED` | Sacada del alcance por decisión del usuario; el motivo está en la bitácora. |

## 2. Objetivo y alcance [OBLIGATORIA]

### Objetivo
[Resultado que se quiere conseguir, en 1-3 líneas]

### Incluye
- [elemento]

### No incluye
- [elemento]

### Restricciones
- [restricción técnica, funcional o de proceso]

## 3. Fuentes consultadas [OBLIGATORIA]

- **Brief:** [ruta]
- **Documentos indicados con @:** [lista]
- **Archivos del proyecto leídos:** [lista]
- **Contratos e interfaces:** [interfaz → fuente (spec §x | indicado por el usuario) | "no verificado: motivo"]
- **Material de referencia:** [diseños, diagramas, ADRs que trae la spec | "no aplica"]

### Evidencia capturada [OPCIONAL — respuestas reales, logs, salidas de comandos, capturas]

| Fecha | Origen (llamada, comando, pantalla, consulta) | Resultado | Observaciones |
|---|---|---|---|
| [AAAA-MM-DD] | [..] | [..] | [quién la aportó] |

## 4. Estado actual verificado [OPCIONAL — cuando se modifica código existente]

> Fuente: lectura de código. [Indicar si algo se reprodujo en ejecución o no.]

- [hallazgo con `archivo:línea`]

## 5. Decisiones [OPCIONAL — obligatoria si alguna tarea depende de una decisión]

| ID | Decisión | Opciones | Recomendación | Decisión final | Bloquea | Estado | Fecha | Quién |
|---|---|---|---|---|---|---|---|---|
| D-01 | [pregunta] | a) … · b) … | [opción + motivo] | — | [T-xx] | `PENDING` | — | — |

Estados de decisión: `PENDING` · `APPROVED` · `REJECTED` · `SUPERSEDED` (reemplazada por otra; indicar cuál).
Una tarea no se autoriza mientras tenga decisiones `PENDING` que la bloqueen.

## 6. Plan de tareas [OBLIGATORIA]

<!-- Un bloque por tarea. El bloque guarda el estado ACTUAL; la historia va en la bitácora (§8). -->

### T-01 — [nombre]
- **Estado:** `PENDING`
- **Objetivo:** [qué resuelve]
- **Alcance:** [qué cambia]
- **Archivos previstos:** [rutas]
- **Dependencias:** [T-xx | ninguna]
- **Decisiones requeridas:** [D-xx | ninguna]
- **Criterios de aceptación:**
  - [ ] [criterio verificable]
- **Verificaciones requeridas:**
  - [ ] [comando o comprobación — las de `docs/contexts/_config.md` (tipos, tests afectados, revisores) o una prueba manual]
- **Resultado** (se llena al pasar a `READY_FOR_REVIEW`; se actualiza si hay correcciones):
  - **Hecho:** [resumen]
  - **Archivos:** creados [..] · modificados [..] · eliminados [..]
  - **Verificaciones:** [comprobación → `PASS` | `FAIL` | `NOT_RUN` (motivo)]
  - **Limitaciones / desvíos:** [o "ninguno"]
  - **Commit:** [hash informado por el usuario | pendiente]

## 7. Impacto y riesgos [OPCIONAL — obligatoria en cambios disruptivos]

- **Tipo de cambio:** [aditivo | disruptivo | mixto]
- **Archivos que NO cambian:** [para acotar el alcance]
- **Tests que pueden fallar:** [test → motivo]
- **Dependencias externas afectadas:** [otras áreas que importan de esta | ninguna]
- **Riesgos:**
  - [riesgo → mitigación]
- **Observaciones fuera de alcance (no tocar sin pedirlo):**
  - [deuda o hallazgo detectado]

## 8. Bitácora [OBLIGATORIA]

Una fila por evento significativo. No se borran ni se editan filas anteriores: si algo se revierte o se corrige, se agrega una fila nueva.

| # | Fecha | Tarea | Evento | Detalle | Archivos / comandos | Verificación | Quién | Commit |
|---|---|---|---|---|---|---|---|---|
| 1 | [AAAA-MM-DD] | — | `PLANNING` | Contexto creado a partir de [brief / descripción] | `docs/contexts/[ID]-context.md` | [qué se leyó] | Agente | — |

Tipos de evento:

| Evento | Cuándo |
|---|---|
| `PLANNING` | Se crea o reestructura el plan. |
| `DECISION` | Se toma, cambia o reemplaza una decisión. |
| `PLAN_APPROVED` | El usuario aprueba el plan (o un plan modificado). |
| `TASK_AUTHORIZED` | El usuario autoriza ejecutar una tarea concreta. |
| `IMPLEMENTATION` | Se crean, modifican o eliminan archivos. |
| `VERIFICATION` | Se ejecuta una comprobación (registrar comando y resultado real). |
| `READY_FOR_REVIEW` | La tarea se presenta al usuario. |
| `CHANGES_REQUESTED` | El usuario pide correcciones. |
| `TASK_APPROVED` | El usuario aprueba la tarea. |
| `SCOPE_CHANGE` | Cambia el alcance o el plan (indicar si es menor o si requirió autorización). |
| `BLOCKED` | Aparece un impedimento. |
| `EXCEPTION_ACCEPTED` | El usuario acepta que algo quede sin hacer o sin verificar. |
| `COMMIT` | El usuario informa un commit. |
| `CLOSURE` | Se cierra el contexto. |

## 9. Cierre [OBLIGATORIA]

El contexto pasa a `COMPLETED` solo si se cumplen todas las condiciones:

- [ ] Todas las tareas están `APPROVED` o `DESCOPED` por decisión del usuario.
- [ ] No hay `CHANGES_REQUESTED` ni decisiones `PENDING`.
- [ ] Verificación global ejecutada: [lista — la "verificación global de cierre" de la configuración, p. ej. suite completa y build]
- [ ] Las excepciones aceptadas están registradas como `EXCEPTION_ACCEPTED` en la bitácora.
- [ ] La bitácora está al día.

**Excepciones aceptadas:** [ninguna | lista con referencia a la fila de la bitácora]

**Commits:**

| Commit | Tareas |
|---|---|
| [hash] | [T-xx] |
