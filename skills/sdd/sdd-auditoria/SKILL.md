---
name: sdd-auditoria
description: Mantiene la auditoría por tarea de un docs/contexts/<ID>-context.md. Llena el bloque Resultado de la tarea, agrega a la bitácora los eventos IMPLEMENTATION, VERIFICATION, READY_FOR_REVIEW, TASK_APPROVED y COMMIT, prepara la entrega para revisión del usuario, verifica las condiciones de cierre y ejecuta /sdd limpiar (borrado confirmado de contextos COMPLETED ya mergeados en la rama base). Nunca borra historial ni registra aprobaciones que el usuario no dio. Parte del flujo /sdd; la usan sdd-ejecucion y el orquestador.
---

# sdd-auditoria

Dejas registrado, de forma verificable, qué pasó en cada tarea. La bitácora del contexto es el único registro del trabajo: no hay CHANGELOG ni README por feature.

Límite con `sdd-mantenimiento`: tú registras el **resultado de las tareas**; los cambios de plan, de decisiones y de prioridades son de `sdd-mantenimiento`.

Configuración usada (de `docs/contexts/_config.md`, sección "Git"): rama base, archivos sensibles y rutas de `docs/` ignoradas por git.

## 1. Al terminar la implementación y la verificación

1. **Archivos.** Obtener los archivos tocados con `git status --short` y `git diff --stat`. Los archivos en rutas ignoradas por git (ver configuración) no aparecen en `git status`: listarlos a mano.
2. **Bloque "Resultado"** de la tarea:
   - **Hecho:** qué se implementó, en lenguaje claro.
   - **Archivos:** creados, modificados y eliminados.
   - **Verificaciones:** la tabla de `sdd-verificacion`, con los resultados reales.
   - **Limitaciones / desvíos:** ajustes menores, `NOT_RUN`, hallazgos preexistentes; o "ninguno".
   - **Commit:** pendiente.
3. **Criterios de aceptación:** marcar `[x]` solo los respaldados por una verificación. Los demás quedan `[ ]`, con su motivo.
4. **Bitácora:** filas `IMPLEMENTATION`, `VERIFICATION` (comando → resultado) y `READY_FOR_REVIEW`. Si hubo ajustes menores, también `SCOPE_CHANGE` (menor).
5. **Estados:** tarea → `READY_FOR_REVIEW`; "Última actualización" con la fecha del día.

## 2. Entrega para revisión

Presentar al usuario, de forma breve:

- **Qué se hizo** (2-4 líneas) y la lista exacta de archivos de la tarea, lista para el commit.
- **Otros cambios en el working tree** (`git status --short`) que no son de la tarea: listarlos y avisar que no deberían entrar en su commit. Destacar los que coincidan con los "archivos sensibles" de la configuración (suelen tener hosts o secretos locales).
- **Verificaciones:** `PASS` / `FAIL` / `NOT_RUN` con su motivo. Las fallas y lo no ejecutado van primero, sin suavizarlos.
- **Desvíos y limitaciones**, si los hay.
- **Pruebas manuales** que le tocan al usuario, con sus pasos.
- **Qué se espera:** aprobar la tarea o pedir cambios. Recordar que aprobar no autoriza la siguiente tarea.

Después, **detenerse**.

## 3. Decisión del usuario

| El usuario… | Registrar |
|---|---|
| Aprueba la tarea | `TASK_APPROVED` citando su mensaje; tarea → `APPROVED` (con fecha y fila); contexto → `PLAN_APPROVED`; tarea activa y autorización vigente: ninguna |
| Pide cambios | `CHANGES_REQUESTED` con cada observación; tarea → `CHANGES_REQUESTED`; sigue siendo la activa. Al volver a entregar se agregan filas nuevas y el Resultado se actualiza indicando qué cambió |
| Acepta algo sin hacer o sin verificar | `EXCEPTION_ACCEPTED` con lo aceptado. El resultado real no cambia (`NOT_RUN` sigue siendo `NOT_RUN`) |

Nunca registrar una aprobación, autorización o excepción que el usuario no haya dado de forma explícita.

## 4. Commits

Los commits los hace el usuario. Cuando avisa que hizo uno:

```bash
git log --oneline -3
git show --stat <hash>
```

- Registrar `COMMIT` con el hash, el mensaje y el resumen de archivos, y completar "Commit" en la tarea.
- Si el commit incluye varias tareas, o archivos que no son de la tarea, anotarlo tal cual; no pedir rehacerlo.
- Si `git status` muestra cambios que quedaron fuera del commit, avisarlo.

## 5. Cierre del contexto

Cuando el usuario pide cerrar, o todas las tareas están `APPROVED`/`DESCOPED`, verificar la sección "Cierre" de la plantilla:

- [ ] Todas las tareas `APPROVED` o `DESCOPED` por decisión del usuario.
- [ ] Sin `CHANGES_REQUESTED` ni decisiones `PENDING`.
- [ ] Verificación global ejecutada (la que defina el contexto o la configuración, p. ej. suite completa y build), con sus resultados reales.
- [ ] Excepciones registradas como `EXCEPTION_ACCEPTED`.
- [ ] Bitácora al día, con commits.

Si se cumplen todas: `CLOSURE`, contexto → `COMPLETED`, completar la tabla de commits y escribir un resumen final de 2-3 líneas. Si falta algo, listar qué falta y no cerrar.

## 6. Limpieza de contextos (`/sdd limpiar`)

Los contextos de trabajos que ya llegaron a la rama base se pueden borrar para que `docs/contexts/` no crezca; el historial de git los conserva. Solo se usa `git` (no `gh` ni consultas de PR). En lo que sigue, `<base>` es la rama base de la configuración (por defecto `origin/main`, o la rama por defecto del remoto).

1. **Actualizar la referencia remota:** `git fetch origin <rama>` (la parte de `<base>` sin `origin/`). Solo actualiza `<base>`; no toca ramas locales ni el working tree. Si falla (sin red o sin acceso), detenerse y avisar: sin la referencia actualizada no se limpia.
2. **Candidatos:** cada `docs/contexts/*-context.md` cuyo campo "Estado del contexto" sea exactamente `COMPLETED`. Los contextos con estado en texto libre o ilegible se excluyen con el motivo "estado no reconocible"; para limpiarlos hay que ajustar su estado a mano o borrarlos por pedido explícito.
3. **Commits del contexto:** los hashes de la tabla "Commits" del cierre y de los eventos `COMMIT` de la bitácora. Validar cada uno con `git cat-file -e <hash>^{commit}`.
4. **Elegible** solo si se cumple todo:
   - el archivo está versionado (`git ls-files --error-unmatch <archivo>`);
   - tiene al menos un commit, y ninguno figura como "pendiente";
   - cada commit cumple `git merge-base --is-ancestor <hash> <base>` (exit 0).
5. **Presentar** dos listas:
   - elegibles: archivo, ID y commits;
   - excluidos, con su motivo: no `COMPLETED`, no versionado, sin commits, commit pendiente, hash inexistente o commit que no está en `<base>`. En este último caso, aclarar que si el PR se mergeó con *squash* o *rebase* los hashes no coinciden y hay que revisarlo a mano.
6. **Confirmar:** pedir confirmación de la lista exacta (todos o una parte). Sin confirmación no se borra nada.
7. **Borrar:** `git rm <archivos confirmados>`. Mostrar `git status --short`. **No hacer commit**: el usuario lo incluye en su próximo commit y PR.

Restricciones: nunca borrar un contexto que no esté `COMPLETED` ni uno no versionado; nunca usar `rm` directo; no editar los contextos durante la limpieza; nunca tocar `_config.md`.

## Reglas

- La bitácora es de solo agregar: no se editan ni se borran filas anteriores. Las correcciones van en filas nuevas.
- Numeración correlativa; fecha `AAAA-MM-DD`; columna "Quién" con `Usuario`, `Agente` (o el nombre del agente, p. ej. `Claude`) o ambos.
- Las verificaciones se registran con el comando y el resultado real, nunca con un resultado esperado.
- No crear CHANGELOG, README ni otros documentos de seguimiento fuera del contexto.
