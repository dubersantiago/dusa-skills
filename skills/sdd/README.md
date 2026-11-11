# SDD — Spec-Driven Development con control humano

Una pauta para trabajar con agentes de código guiados por especificación, en cualquier tipo de proyecto: frontend, backend, infraestructura, datos, scripts o documentación. Un orquestador (`/sdd`), una skill por fase y revisores de solo lectura. Cada trabajo queda en un único archivo de contexto (spec + plan + tareas + bitácora), y tú controlas cada paso.

```text
spec / brief ──► especificación + plan ──[apruebas]──► T-01 ──[autorizas]──► implementar ──► verificar ──► entrega ──[apruebas]──► … ──► cierre
```

---

## Reglas del flujo

1. **Spec y plan antes que cambios.** El agente analiza, arma el contexto con la especificación y el plan, y espera tu aprobación. Hasta entonces no toca código, infraestructura, datos ni configuración.
2. **Una tarea a la vez.** Solo se trabaja la tarea que autorizaste de forma explícita ("autorizo T-02", "sigue con T-02").
3. **Pausa al terminar cada tarea.** El agente verifica, registra y te presenta el resultado. Después se detiene.
4. **Aprobar no es continuar.** "Apruebo T-02" cierra T-02, pero no inicia T-03. Las dos órdenes pueden ir en un mismo mensaje ("apruebo T-02, sigue con T-03").
5. **Nada implícito.** Que pasen los tests o que no respondas no cuenta como aprobación. Los mensajes ambiguos ("ok", "dale") generan una pregunta.
6. **Cambios significativos con tu autorización.** El agente puede hacer ajustes menores dentro de la tarea y los registra. Si algo amplía el alcance, cambia una decisión o un contrato, o afecta otras tareas, se detiene y te consulta.
7. **Verificación honesta.** Cada comprobación queda como `PASS`, `FAIL` o `NOT_RUN` (con motivo).
8. **Los commits los haces tú.** Avísale al agente cuando hagas uno; él registra el hash.

Ninguna herramienta bloquea técnicamente estos pasos: el flujo depende de que el agente siga las skills y lea el estado del contexto antes de actuar. Si ves que se salta un paso, díselo.

---

## Cómo se usa

```text
/sdd configurar                          # una vez por repo: crea docs/contexts/_config.md
/sdd docs/specs/FAJR-010.md             # trabajo nuevo desde una spec, brief o issue
/sdd necesito agregar X en el módulo Y   # trabajo nuevo sin spec
/sdd FAJR-010                            # retomar un trabajo
/sdd                                     # listar los trabajos abiertos
/sdd limpiar                             # borrar contextos COMPLETED ya mergeados en la rama base
```

Recorrido típico:

| Paso | Tú | Agente |
|---|---|---|
| 1 | Entregas la spec o describes el cambio (y los documentos con `@`) | Lee el proyecto y los contratos, y crea `docs/contexts/<ID>-context.md` con tareas, decisiones e impacto. Estado `AWAITING_PLAN_APPROVAL` |
| 2 | Respondes las decisiones y apruebas el plan | Registra `PLAN_APPROVED`. No inicia nada |
| 3 | Autorizas T-01 | Implementa solo T-01, verifica (comandos y revisores de la configuración), registra y se detiene en `READY_FOR_REVIEW` |
| 4 | Apruebas o pides cambios | Si apruebas: `TASK_APPROVED` y espera. Si pides cambios: corrige la misma tarea y vuelve a entregar |
| 5 | Haces el commit y avisas | Registra `COMMIT` con el hash |
| … | Repites 3 a 5 por tarea | |
| Fin | Pides cerrar | Verifica las condiciones de cierre y pasa el contexto a `COMPLETED` |

**Modo ligero:** para trabajos chicos (de 1 a 3 tareas, sin cambios de contratos ni interfaces públicas) el contexto es más corto, pero las reglas son las mismas. Las áreas que la configuración marque como sensibles van siempre en modo normal.

**Limpieza:** `/sdd limpiar` hace `git fetch` de la rama base y lista los contextos `COMPLETED` cuyos commits ya están **todos** en ella, junto con los excluidos y su motivo. Con tu confirmación los borra con `git rm`: quedan recuperables desde el historial y el borrado entra en tu próximo commit. Si un PR se mergea con *squash*, los hashes no coinciden y ese contexto queda excluido.

---

## Piezas

### Skills

| Skill | Qué hace |
|---|---|
| `sdd` | Orquestador: lee el estado del contexto, controla autorizaciones y pausas, decide qué skill toca. Plantilla de configuración en `templates/` |
| `sdd-planificacion` | Convierte una spec, brief o pedido en el contexto con la especificación y el plan, sin tocar el proyecto. Plantillas normal y ligera en `templates/` |
| `sdd-mantenimiento` | Cambios de alcance, decisiones, pausas, bloqueos y sincronización de estados, sin perder historial |
| `sdd-ejecucion` | Implementa solo la tarea activa autorizada |
| `sdd-verificacion` | Regresión, comprobaciones automáticas, revisores; resultados reales. Revisor genérico en `references/` |
| `sdd-auditoria` | Resultado de la tarea, entrega para revisión, commits, cierre y limpieza |

### Lo que pone cada proyecto

| Pieza | Dónde | Para qué |
|---|---|---|
| Configuración | `docs/contexts/_config.md` | Comandos de verificación, rama base, revisores, skills técnicas, archivos sensibles, fuente de contratos. Plantilla: `sdd/templates/config-template.md`. Ejemplo real: [examples/atlantis-frontend/_config.md](examples/atlantis-frontend/_config.md) |
| Skills técnicas (opcional) | `.claude/skills/<nombre>/` del repo | Convenciones del stack (p. ej. `angular-development`, convenciones de Terraform) |
| Revisores (opcional) | `.claude/agents/<nombre>.md` del repo | Subagentes de solo lectura con las reglas del proyecto. Sin ellos se usa el revisor genérico |

### El archivo de contexto (`docs/contexts/<ID>-context.md`)

Es el único registro del trabajo: estado, alcance, fuentes, decisiones, tareas con su resultado, impacto y riesgos, una bitácora de eventos y el cierre.

Estados del contexto: `PLANNING` → `AWAITING_PLAN_APPROVAL` → `PLAN_APPROVED` ⇄ `IN_PROGRESS` → `COMPLETED` (y `BLOCKED`).
Estados de una tarea: `PENDING` → `AUTHORIZED` → `IN_PROGRESS` → `READY_FOR_REVIEW` → `APPROVED` (o `CHANGES_REQUESTED`, `BLOCKED`, `DESCOPED`).

---

## Notas

- Versiona `docs/contexts/`: los contextos viajan en el commit y en el PR del trabajo, así que conviene revisarlos antes (pueden traer evidencia de entornos reales: respuestas, logs).
- Las skills se cargan al iniciar la sesión del agente: después de actualizarlas (`npx skills update`), abre una sesión nueva.
- Los contratos e interfaces salen de la fuente que diga la configuración (por defecto, solo la spec o lo que tú indiques). Lo que falte queda "no verificado" en el contexto y te lo pregunta; nunca inventa campos.
