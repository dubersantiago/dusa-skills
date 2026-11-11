<!--
PLANTILLA DE CONTEXTO — MODO LIGERO
Ubicación del archivo generado: docs/contexts/<ID>-context.md.
Para tareas chicas (1-3 tareas chicas, sin cambios de contrato, de forma del estado ni de rutas).
Mismas reglas que el modo normal: plan aprobado antes de implementar, una tarea a la vez,
pausa al terminar, auditoría en la bitácora. Estados y tipos de evento: los de context-template.md.

Si durante el trabajo aparece una decisión, un riesgo relevante o más de 3 tareas, agregar la
sección correspondiente de context-template.md (registrar un SCOPE_CHANGE) o pasar a modo normal.
Borrar este comentario en el archivo generado.
-->

# [ID] — Context: [nombre del trabajo]

## 1. Estado general

- **ID:** [ID]
- **Modo:** ligero
- **Estado del contexto:** `PLANNING`
- **Origen:** [spec / brief / issue | descripción del usuario]
- **Área:** [ruta en el repo]
- **Creado / última actualización:** [AAAA-MM-DD] / [AAAA-MM-DD]
- **Plan aprobado por el usuario:** no
- **Tarea activa:** ninguna
- **Autorización de ejecución vigente:** ninguna

## 2. Objetivo y alcance

- **Objetivo:** [1-2 líneas]
- **Incluye:** [lista corta]
- **No incluye:** [lista corta]
- **Fuentes leídas:** [archivos y docs]

## 3. Tareas

### T-01 — [nombre]
- **Estado:** `PENDING`
- **Alcance:** [qué cambia]
- **Archivos previstos:** [rutas]
- **Criterios de aceptación:**
  - [ ] [criterio verificable]
- **Verificaciones requeridas:**
  - [ ] [comando o comprobación, incluidos los revisores que correspondan]
- **Resultado:**
  - **Hecho:** [resumen]
  - **Archivos:** [creados / modificados / eliminados]
  - **Verificaciones:** [comprobación → `PASS` | `FAIL` | `NOT_RUN` (motivo)]
  - **Limitaciones / desvíos:** [o "ninguno"]
  - **Commit:** [hash informado por el usuario | pendiente]

## 4. Bitácora

| # | Fecha | Tarea | Evento | Detalle | Verificación | Quién | Commit |
|---|---|---|---|---|---|---|---|
| 1 | [AAAA-MM-DD] | — | `PLANNING` | Contexto creado | [qué se leyó] | Agente | — |

## 5. Cierre

- [ ] Tareas `APPROVED` (o `DESCOPED` por decisión del usuario)
- [ ] Sin correcciones pendientes
- [ ] Excepciones registradas como `EXCEPTION_ACCEPTED`: [ninguna | filas]
