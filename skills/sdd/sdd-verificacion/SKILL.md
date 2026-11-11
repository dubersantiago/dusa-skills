---
name: sdd-verificacion
description: Verifica con evidencia la tarea activa de un docs/contexts/<ID>-context.md. Convierte los criterios de aceptación en comprobaciones, corre primero los tests existentes afectados (regresión), ejecuta las verificaciones y los revisores que declare la configuración del proyecto (o un revisor genérico) y registra cada resultado como PASS, FAIL o NOT_RUN con su motivo. Parte del flujo /sdd; la usa sdd-ejecucion al terminar una implementación.
---

# sdd-verificacion

Compruebas lo que hizo la tarea y reportas **solo lo que verificaste**. No ocultas fallas ni afirmas resultados que no comprobaste.

Los comandos concretos salen de la sección "Verificación" de `docs/contexts/_config.md`. Si no existe, usar las verificaciones que el plan aprobado lista en la tarea.

## 1. Plan de verificación

Partir del bloque de la tarea: "Criterios de aceptación" y "Verificaciones requeridas". Armar la lista:

| Criterio / verificación | Cómo se comprueba | Quién |
|---|---|---|
| [criterio] | comando, test, revisión de código o prueba manual | Agente / revisor / usuario |

Si un criterio no se puede comprobar con nada disponible, se dice desde el principio: queda `NOT_RUN` con el motivo.

## 2. Regresión primero

Si la tarea modificó código que ya tiene tests, o código del que dependen otras áreas:

```bash
# buscar tests del área y tests que importan lo modificado (receta de la configuración, o equivalente)
find <carpeta-del-area> -name "*.spec.*" -o -name "*.test.*"
grep -rl "<área>/\|<SímboloModificado>" <src>
<comando de tests> <tests-encontrados>
```

Por cada test que falla:
- **Causa:** fixture desactualizada, tipo cambiado, método renombrado o comportamiento realmente roto.
- **Corrección mínima** propuesta.
- **Validez:** ¿el test sigue siendo válido con el cambio, o probaba algo que ya no existe?

**No modificar ni borrar un test existente que falla sin la aprobación del usuario.** Reportarlo como `FAIL`, con la causa y la propuesta, y dejar que el usuario decida. Un test roto **no** se asume inválido.

Para saber si una falla ya existía antes de la tarea, no usar `git stash` ni cambiar de rama sin autorización. Si no se puede determinar, decir "posiblemente previa, no verificado".

## 3. Comprobaciones automáticas

Ejecutar las "verificaciones por tarea con cambios" de la configuración que apliquen a la tarea (típicamente: compilación o tipos, lint, tests afectados; en infraestructura, validación y `plan`, nunca `apply` sin autorización).

- Si una falla coincide con una "falla preexistente conocida" de la configuración y el error es exactamente ese, registrar `NOT_RUN` con el motivo indicado. Si aparece otro error, es un `FAIL` real.
- La suite completa y el build se ejecutan en la verificación global de cierre, o si la tarea los pide.
- Registrar el comando exacto y el resultado real: exit code, suites y tests (p. ej. "3 suites, 30/30") y los errores relevantes, citados tal cual.
- Si un comando no se puede ejecutar (entorno, permisos, dependencias), queda `NOT_RUN` con el motivo. No se reemplaza por una suposición.

## 4. Revisores (en cada tarea con cambios)

Cuando la tarea crea o modifica código o artefactos (infraestructura, migraciones, configuración), ejecutar los revisores como subagentes de solo lectura, esperando el resultado:

- **Con revisores en la configuración:** invocar cada uno según su columna "Cuándo se ejecuta", pasándole los datos que pide (normalmente: ruta del área, lista exacta de archivos tocados, ruta del contexto e ID de la tarea).
- **Sin revisores configurados:** lanzar un subagente de propósito general con el prompt de `references/revisor-generico.md` (en la carpeta de esta skill), completando sus datos.
- **Si el agente no soporta subagentes:** hacer la revisión de `references/revisor-generico.md` en la sesión principal, sin modificar archivos, y anotarlo.

Cada subagente no recuerda esta conversación: el prompt debe llevar todo lo que necesita. Son de solo lectura y devuelven un reporte; no modifican nada.

Interpretar sus hallazgos:
- **Introducido por la tarea** (en líneas tocadas): si la corrección cabe en el alcance, corregir y volver a verificar; si no, `FAIL` con la propuesta.
- **Preexistente** (líneas no tocadas): no corregir; registrarlo en "Observaciones fuera de alcance".
- Si no aplican (la tarea solo toca documentación, por ejemplo), `NOT_RUN` con el motivo.

## 5. Pruebas manuales

Lo que solo se comprueba ejecutando la aplicación (ver "Pruebas manuales" en la configuración): listarlo con los pasos concretos para que lo haga el usuario. Queda `NOT_RUN` hasta que el usuario confirme el resultado, o `EXCEPTION_ACCEPTED` si decide no hacerlo.

## 6. Resultado

Devolver a `sdd-auditoria`:
- la tabla criterio → comprobación → `PASS` / `FAIL` / `NOT_RUN` (motivo);
- los comandos ejecutados y sus resultados;
- los hallazgos de los revisores, separados en introducidos y preexistentes;
- los tests rotos con su causa y propuesta, pendientes de aprobación.

Una tarea **no** se presenta como verificada si hay un `FAIL` o un `NOT_RUN` sin declarar. Un criterio de aceptación solo se marca `[x]` si una comprobación lo respalda.
