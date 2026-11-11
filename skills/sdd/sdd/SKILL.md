---
name: sdd
description: Orquestador de un flujo de trabajo Spec-Driven Development (SDD) con control humano, para cualquier tipo de proyecto (frontend, backend, infraestructura, datos, scripts, documentación). Especificación y plan aprobados antes de tocar nada, una tarea a la vez con autorización explícita, verificación con evidencia, pausa y bitácora. Usar cuando el usuario invoca /sdd, entrega una spec, brief o issue, pide un cambio para planificar, o cuando aprueba, autoriza, pide cambios, pausa o cierra un trabajo registrado en docs/contexts/<ID>-context.md. Delega cada fase en sdd-planificacion, sdd-mantenimiento, sdd-ejecucion, sdd-verificacion y sdd-auditoria.
---

# /sdd — Orquestador

Controlas el ciclo de vida de un trabajo guiado por especificación, de punta a punta. No implementas por tu cuenta: decides **qué fase toca ahora**, verificas que esté autorizada y cargas la skill correspondiente.

| Fase SDD | Artefacto | Skill | Puerta humana |
|---|---|---|---|
| Especificar | Objetivo, alcance, criterios de aceptación, contratos, decisiones | `sdd-planificacion` | Aprobación del plan |
| Planificar | Tareas pequeñas con criterios y verificaciones | `sdd-planificacion` | Aprobación del plan |
| Implementar | Cambios de una sola tarea | `sdd-ejecucion` | Autorización por tarea |
| Verificar | Evidencia `PASS` / `FAIL` / `NOT_RUN` | `sdd-verificacion` | Aprobación de la tarea |
| Registrar y cerrar | Bitácora, commits, cierre | `sdd-auditoria` | Pedido de cierre |
| Cambiar la spec | Plan modificado sin perder historial | `sdd-mantenimiento` | Autorización si es significativo |

La especificación, el plan, las tareas y su historial viven en **un solo archivo** por trabajo: `docs/contexts/<ID>-context.md`. "Implementar" significa cualquier cambio en el proyecto: código, infraestructura, migraciones, configuración, pipelines o documentación.

**Uso:** `/sdd <ID | ruta de la spec o brief | descripción del cambio>`
- Si el argumento es un ID o un archivo en `docs/contexts/`, retomar ese contexto.
- Si es una spec, brief, issue o una descripción nueva, iniciar planificación (`sdd-planificacion`).
- Sin argumento: listar los contextos de `docs/contexts/*-context.md` que no estén `COMPLETED` (ID + estado + tarea activa) y preguntar cuál retomar o si se inicia uno nuevo.
- `configurar`: crear o actualizar la configuración del proyecto (§7). No crea ni modifica contextos.
- `limpiar`: borrar, previa confirmación, los contextos `COMPLETED` cuyos commits ya están todos en la rama base (`sdd-auditoria` §6). No crea ni modifica contextos.

## 1. Fuente de verdad

El archivo `docs/contexts/<ID>-context.md` es el único registro del trabajo. Antes de **cualquier** acción:

1. Leer el contexto completo desde disco. No usar el estado recordado de la conversación.
2. Leer la configuración del proyecto, `docs/contexts/_config.md` (§7), si existe.
3. Identificar: estado del contexto, tarea activa, autorización vigente, decisiones `PENDING`, tareas en `CHANGES_REQUESTED`.
4. Actuar solo si el estado lo permite (§3). Si el estado del archivo contradice lo que el usuario cree, decirlo y preguntar.

Plantillas: carpeta `templates/` de la skill `sdd-planificacion` — `context-template.md` (normal) y `context-template-ligero.md` (ligero). Ahí están los estados de contexto, de tarea y de decisión, y los tipos de evento de la bitácora.

## 2. Reglas no negociables

1. **Sin cambios antes del plan aprobado.** Hasta que el contexto registre `PLAN_APPROVED`, solo se lee y se planifica: no se toca código, infraestructura, datos ni configuración.
2. **Decisiones antes que tareas.** Una tarea no se inicia si tiene decisiones `PENDING` que la bloqueen.
3. **Una tarea a la vez.** Solo se trabaja la tarea activa autorizada. No se adelanta trabajo de otras tareas.
4. **Pausa obligatoria.** Al terminar una tarea: actualizar el contexto, presentar el resultado y **detenerse**.
5. **Aprobar ≠ continuar.** `TASK_APPROVED` no autoriza la siguiente tarea. Hace falta una orden explícita para ella.
6. **Sin aprobación implícita.** Entregar una spec, generar el plan, terminar una implementación, que pasen los tests o que el usuario guarde silencio **no** son aprobaciones ni autorizaciones.
7. **Ajustes menores sí, cambios significativos no.** Se puede hacer un ajuste pequeño y necesario que no cambie el objetivo ni contradiga decisiones, siempre que se registre. Si el cambio amplía el alcance, altera una decisión o un contrato, afecta otras tareas o cambia requisitos: detenerse, explicar el impacto y esperar autorización (`sdd-mantenimiento`).
8. **Verificación transparente.** Toda comprobación queda como `PASS`, `FAIL` o `NOT_RUN` con motivo. Nunca se presenta como verificado algo que no lo está.
9. **Historial acumulativo.** La bitácora no se borra ni se reescribe; las correcciones se agregan como filas nuevas.
10. **Cierre controlado.** `COMPLETED` solo si se cumplen todas las condiciones de la sección "Cierre" de la plantilla.
11. **Commits del usuario.** Nunca hacer commit ni preguntar si hacerlo. Cuando el usuario informa un commit, obtener el hash con `git log` y registrar un evento `COMMIT`.
12. **Acciones destructivas** (borrar archivos, sobrescribir lo que no es tuyo, cambios en servicios externos): confirmar con la lista exacta antes de ejecutar, aunque la tarea esté autorizada.

### Límite técnico (declararlo, no ocultarlo)

Ninguna herramienta bloquea técnicamente el avance: las pausas dependen de que sigas estas reglas y de que leas el estado del contexto antes de actuar. Por eso:
- La orquestación y la implementación ocurren en la **sesión principal**. No delegar implementación ni orquestación en subagentes: un subagente corre hasta terminar y no puede detenerse a esperar al usuario.
- Los únicos subagentes del flujo son los **revisores** (los que declare la configuración, o el revisor genérico de `sdd-verificacion`): solo lectura y con reporte. Los invoca `sdd-verificacion`.

## 3. Qué hacer según la situación

| Situación (mensaje del usuario + estado del contexto) | Acción | Skill |
|---|---|---|
| Spec, brief o pedido nuevo, sin contexto | Planificar; crear el contexto en `AWAITING_PLAN_APPROVAL`; presentar y detenerse | `sdd-planificacion` |
| Contexto en `AWAITING_PLAN_APPROVAL` + el usuario aprueba el plan | Evento `PLAN_APPROVED`; contexto → `PLAN_APPROVED`; **no** iniciar ninguna tarea | `sdd-mantenimiento` |
| El usuario autoriza la tarea T-xx | Comprobaciones previas (§4); evento `TASK_AUTHORIZED`; ejecutar | `sdd-ejecucion` |
| Tarea en `READY_FOR_REVIEW` + el usuario la aprueba | Evento `TASK_APPROVED`; tarea → `APPROVED`; contexto → `PLAN_APPROVED`; tarea activa: ninguna; **detenerse** | `sdd-auditoria` |
| Tarea en `READY_FOR_REVIEW` + el usuario pide cambios | Evento `CHANGES_REQUESTED` con las observaciones; corregir la misma tarea | `sdd-ejecucion` |
| El usuario informa un commit | Hash con `git log`; evento `COMMIT`; completar "Commit" en la tarea | `sdd-auditoria` |
| Cambia la spec o los requisitos, se pide algo nuevo o se cambian prioridades | Registrar, analizar el impacto y pedir autorización si es significativo | `sdd-mantenimiento` |
| El usuario pide una pausa | Registrar; autorización vigente: ninguna; no iniciar nada | `sdd-mantenimiento` |
| Aparece un impedimento | Evento `BLOCKED`; explicar el impedimento y las opciones; esperar | `sdd-mantenimiento` |
| El usuario pide cerrar, o todas las tareas están aprobadas | Verificar las condiciones de cierre; si se cumplen, evento `CLOSURE` → `COMPLETED`; si no, listar lo que falta | `sdd-auditoria` |
| `/sdd limpiar` | Listar los contextos elegibles y los excluidos con su motivo; con confirmación, `git rm` de los elegibles; no hacer commit | `sdd-auditoria` §6 |
| `/sdd configurar` | Crear o actualizar `docs/contexts/_config.md` | este archivo, §7 |

**Mensajes combinados.** "Aprobado T-01, sigue con T-02" son dos órdenes: registrar `TASK_APPROVED` (T-01) y luego `TASK_AUTHORIZED` (T-02), en ese orden.

**Mensajes ambiguos** ("ok", "dale", "listo", "bien"): no interpretarlos como aprobación ni como autorización. Preguntar qué se aprueba o autoriza, nombrando la tarea.

**Si el usuario autoriza una tarea sin haber aprobado la anterior** que está en `READY_FOR_REVIEW`: preguntar si aprueba la anterior, si la deja abierta o si pide cambios. No asumir.

## 4. Comprobaciones antes de iniciar una tarea

Todas deben cumplirse. Si una falla, no iniciar: explicar cuál falla y qué se necesita.

- [ ] El contexto registra `PLAN_APPROVED` (evento en la bitácora).
- [ ] La tarea existe en el plan y está en `PENDING`, `AUTHORIZED` o `CHANGES_REQUESTED`.
- [ ] Sus dependencias están `APPROVED`.
- [ ] Sus decisiones requeridas no están `PENDING`.
- [ ] No hay un `SCOPE_CHANGE` significativo esperando autorización.
- [ ] No hay otra tarea en `IN_PROGRESS`, `READY_FOR_REVIEW` o `CHANGES_REQUESTED`, salvo que el usuario la haya dejado abierta de forma explícita.
- [ ] Existe una orden explícita del usuario para **esta** tarea.

## 5. Modo normal o ligero

Lo decide `sdd-planificacion` y se lo propone al usuario al presentar el plan.
- **Ligero:** de 1 a 3 tareas chicas, sin cambios de contrato o interfaz pública (APIs, eventos, esquemas de datos, tipos que consumen otros, rutas, parámetros de CLI o de infraestructura) y sin decisiones abiertas relevantes.
- **Normal:** todo lo demás. Ante la duda, normal. Las áreas que la configuración marque como "siempre modo normal" van siempre en normal.

El modo ligero reduce secciones, **no** reglas: también exige plan aprobado, autorización por tarea, pausa y bitácora.

## 6. Mapa de skills

| Skill | Para qué |
|---|---|
| `sdd-planificacion` | Convertir una spec, brief o pedido en un contexto con especificación y plan, sin tocar el proyecto |
| `sdd-mantenimiento` | Cambios de alcance, decisiones, pausas, bloqueos, aprobación del plan y sincronización de estados |
| `sdd-ejecucion` | Implementar solo la tarea activa autorizada |
| `sdd-verificacion` | Ejecutar comprobaciones y revisores; registrar resultados reales |
| `sdd-auditoria` | Resultado de la tarea, bitácora, entrega para revisión, commits, cierre y limpieza |
| Skills técnicas del proyecto | Las que declare la configuración (convenciones del stack: un framework, Terraform, dbt…); las carga `sdd-ejecucion` |

Para cargar una skill, usar la herramienta de skills del agente con su nombre. Si alguna no está instalada, avisarlo al usuario y seguir con estas reglas y con las instrucciones del proyecto (`CLAUDE.md`, `AGENTS.md`).

## 7. Configuración del proyecto (`docs/contexts/_config.md`)

Las skills del flujo son genéricas. Lo propio de cada repo vive en `docs/contexts/_config.md`: comandos de verificación, rama base, revisores, skills técnicas, archivos sensibles, áreas siempre en modo normal, fuente de los contratos de API y documentos de referencia. La plantilla está en `templates/config-template.md` de esta skill.

- **Si no existe:** el flujo funciona igual, con estos valores por defecto: rama base `origin/main` (o la rama por defecto del remoto), verificaciones deducidas de los scripts del proyecto (`package.json`, `Makefile`, `pyproject.toml`…) y confirmadas con el usuario al planificar, revisor genérico de `sdd-verificacion`, sin archivos sensibles ni áreas forzadas. Al iniciar el primer trabajo, sugerir una vez `/sdd configurar`.
- **`/sdd configurar`:**
  1. Leer `CLAUDE.md`/`AGENTS.md`, los manifiestos y scripts del proyecto, `.claude/agents/` (o equivalente) y las skills instaladas.
  2. Proponer cada campo de la plantilla con lo detectado, marcando lo que es suposición.
  3. Preguntar lo que no se pueda deducir (rama base, áreas sensibles, fuente de contratos).
  4. Mostrar el archivo propuesto y escribirlo solo con la confirmación del usuario. Si ya existe, mostrar el diff.
- La configuración nunca relaja las reglas de §2: solo dice **cómo** verificar y **qué** es sensible en este repo.
