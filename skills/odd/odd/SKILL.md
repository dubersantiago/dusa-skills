---
name: odd
description: Organic Driven Development (ODD), flujo de desarrollo proporcional basado en el de Gentle Shell. Usar en TODA solicitud de un repo que adopte ODD (o cuando el usuario invoque /odd), sin que el usuario pida un plan ni seguimiento — preguntas, revisiones, bugs, features, refactors, infraestructura. Las consultas quedan en solo lectura hasta que se pida un cambio; se explora antes de tocar nada; el trabajo pequeño y entendido se hace directo, sin documentos; el trabajo grande (no reanudable desde git diff) lleva un único documento de feature en docs/odd/tasks/<feature>.md con specs citadas literalmente, tareas y bitácora; TDD cuando aplica, línea de riesgo y cierre con evidencia.
---

# /odd — Organic Driven Development

ODD es el flujo de trabajo **por defecto**: toda solicitud entra en él, sin que el usuario pida un flujo, un plan o seguimiento de tareas. No lo describas: ejecútalo. El trabajo crece de forma orgánica: lo pequeño se queda pequeño y solo lo que no se puede retomar desde el diff gana estructura.

Configuración del proyecto (opcional): `docs/odd/config.md` (plantilla en `templates/config-template.md`). Si no existe, se aplican los valores por defecto de cada sección.

## Protocolo (obligatorio, en este orden, en cada solicitud)

1. **Autorizar.** Investigar, explicar, revisar, comparar y proponer es **solo lectura**: sin escrituras, sin documentos de tareas. Si no está claro si se autoriza un cambio, haz **una** pregunta y espera. Que el usuario diga que quizá te detenga o retome después pide notas y commits separados, no detenerse.
2. **Explorar.** Lee el código y los requisitos existentes antes de proponer o escribir, en proporción al pedido. No delegues la exploración de archivos que de todos modos vas a leer para trabajar directo.
3. **Resolver la incertidumbre.** Recomienda investigación solo para una incertidumbre con nombre. Haz **una** pregunta enfocada solo ante una decisión de producto realmente abierta, y espera. Como máximo un desafío independiente de solo lectura para una premisa de alta consecuencia no probada (ver `references/delegacion.md`).
4. **Clasificar.** Pequeño o grande, **solo** por la sección "Tamaño de la tarea". El trabajo pequeño sigue el camino pequeño.
5. **Registrar antes de la primera escritura.** Para trabajo grande autorizado: crear `docs/odd/tasks/<feature>.md` desde `templates/feature-template.md` (y su espejo en memoria, si hay herramienta de memoria) **antes** de escribir código, sin pedir permiso para ello. Reconstruir la lista visible de TODOs a partir de sus tareas. Avisar en una línea qué documento se creó y cuántas tareas tiene.
6. **Implementar tarea por tarea.** Pasar el trabajo **por referencia, nunca parafraseado** (`Spec: docs/odd/tasks/<feature>.md, T2, S3-S4`). Pruebas primero cuando aplique (`references/pruebas.md`). Marcar una tarea como hecha solo con su resultado y sus checks **observados**. Actualizar el documento tras cada transición. Commits por unidad de trabajo según la política de commits (`references/entrega.md`).
7. **Cerrar.** Reportar el resultado verificado, **cada** check fallido, omitido o pendiente, la línea de riesgo y el siguiente paso. Nunca terminar con una tarea registrada pendiente salvo que cites la orden explícita del usuario de parar. Una prueba parcial, bloqueada o no disponible se convierte en un único resultado **"Necesita tu decisión"** que nombra lo que falta; eso es un cierre válido, una redacción ambigua no.

**Reanudar** un trabajo interrumpido: leer el documento completo de `docs/odd/tasks/<feature>.md` (y el espejo en memoria si existe), reconciliar requisitos, código y evidencia (`git log`, `git diff`), conservar versiones en conflicto y continuar con la siguiente tarea sin terminar. No inferir el trabajo activo del recuerdo más reciente.

## Tamaño de la tarea

Una tarea es **pequeña** cuando se cumplen las tres:

1. **Entendida:** el resultado está especificado, se sabe qué y dónde cambiar, y no hay decisiones de producto o diseño abiertas. Se demuestra con un lote acotado de lectura (≈3 llamadas, ≈10k tokens).
2. **Riesgo contenido:** no toca ningún elemento de alto riesgo.
3. **Reanudable desde el diff:** si la sesión se cortara ahora, alguien podría terminar el trabajo solo con el pedido original y `git diff`.

La cantidad de archivos, comandos, tests, arreglos o una lista de TODOs pedida **nunca** decide el tamaño. Es **grande** solo cuando falla la prueba de reanudación: varias sesiones, espera de algo externo, entregables que el usuario quiere separados, o requisitos demasiado largos para sobrevivir a una compactación del contexto.

**Camino pequeño:** trabajar directo. Leer y editar (varios archivos de un mismo cambio entendido incluidos), observar RED antes del arreglo cuando aplique, correr el test enfocado y la suite una vez cada uno. Sin explorador, sin workers, sin verificador, sin documento de feature, sin commits salvo que el usuario los pida.

**Camino grande:** documento de feature + commits por unidad de trabajo. Se sigue trabajando directo salvo que un disparador de delegación se cumpla de verdad (`references/delegacion.md`).

## Alto riesgo

Un error sería difícil de detectar, difícil de deshacer o va más allá del cambio. Toca:

1. **Datos o efectos irreversibles:** migraciones, modificar o borrar datos almacenados, cambiar formatos persistidos (no: guardar registros nuevos).
2. **Seguridad:** autenticación, permisos, credenciales, secretos, guards, sandbox.
3. **Contratos que otros consumen:** cambiar o quitar API pública, flags de CLI, formatos de configuración, exports publicados (no: agregar un flag, comando o campo opcional; lo pedido no es alto riesgo por sí mismo; romper sin pedirlo código compartido sí).
4. **Concurrencia:** locks, carreras, orden asíncrono.
5. **Entrega o entorno:** instaladores, release, CI, despliegue, dependencias.
6. **Ningún test detectaría** una regresión en lo que cambia.

"No está claro" cuenta como alto solo si una mirada acotada no puede decir si aplican 1-5. La configuración puede agregar áreas de alto riesgo propias del proyecto.

**Línea de riesgo:** todo cambio de código cierra con `Risk: item N (motivo)` o `Risk: none`. Antes de escribir `Risk: none`, comprobar si el diff cambia código que también usa un comportamiento existente que el pedido no mencionó (opciones, parsers, helpers compartidos); si es así, es el ítem 3. Cualquier ítem dispara el **verificador independiente** (`references/delegacion.md`).

## Documento de feature (`docs/odd/tasks/<feature>.md`)

Un único documento por feature: es la especificación que leen los workers. Orden fijo, lo estable primero y la bitácora al final:

- **Cabecera** de 2-3 líneas: objetivo, rama, estrategia de entrega, runner de tests y modo TDD.
- **`## Specs`**: requisitos numerados `S1..Sn` con alcance autorizado, criterios de aceptación y checks aplicables. Citan **literalmente** los textos, mensajes de error, comandos y ejemplos del usuario, en su idioma: numerarlos sí, resumirlos o reescribirlos nunca. No agregar requisitos que el usuario no pidió; las suposiciones se marcan como suposiciones.
- **`## Tasks`**: una línea por tarea: `T# | S# | ruta (inline/delegada + motivo) | estado | commit o evidencia RED/GREEN`.
- **`## Log`**: `L1` es el pedido original **literal**; después se agregan, con fecha, las correcciones del usuario (literales), análisis, decisiones con su motivo, evidencia de verificación, progreso y siguiente paso. Breve: no es un diario exhaustivo.

Reglas:
- Un cambio de requisito agrega su entrada literal al Log, reescribe **solo** el `S#` afectado y reabre **solo** su tarea. Se conserva el trabajo completado válido.
- Los hallazgos (de una revisión, de un test) no autorizan por sí solos ampliar el alcance ni aceptar nada. Los cambios de alcance de negocio requieren autorización del usuario.
- Una casilla marcada no es una aprobación: solo dice que se observó el resultado.
- Escribir el archivo primero y releerlo. Si hay memoria persistente (p. ej. Engram), espejar el documento completo con su ruta; si no está disponible, dejar el espejo como pendiente de forma explícita, sin inventar éxito ni bloquear el trabajo.
- No crear planes, changelogs ni documentos de seguimiento aparte.

## Reglas transversales

- **Pruebas:** `references/pruebas.md` — TDD según configuración, un test RED por regla, tests de regresión para lo compartido que se toca, comparación diferencial, scratch fuera del repo.
- **Delegación:** `references/delegacion.md` — por defecto se trabaja directo; solo se delega cuando un disparador se cumple de verdad, y entonces es obligatorio.
- **Entrega:** `references/entrega.md` — commits por unidad de trabajo, ~400 líneas por porción como heurística, estrategias de PR. Push, crear PR y merge **siempre** son decisión del usuario.
- **Salida acotada:** en la sesión principal, mostrar de los comandos solo conteos, `--stat`, `tail` o resúmenes.
- **Idioma:** preguntas, opciones y reportes en el idioma del usuario; los tokens técnicos (`S#`, `T#`, estados, estrategias) no se traducen.
- **Acciones destructivas** (borrar, sobrescribir lo ajeno, reescribir historial, servicios externos): confirmar con la lista exacta, aunque el trabajo esté autorizado.
