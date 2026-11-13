<!--
DOCUMENTO DE FEATURE — ODD
Ubicación: docs/odd/tasks/<feature>.md (nombre descriptivo, apto para archivo; uno por feature).
Solo para trabajo GRANDE (falla la prueba de reanudación). El trabajo pequeño no crea documento.
Orden fijo: cabecera → ## Specs → ## Tasks → ## Log (siempre al final, solo se agrega).
Borrar este comentario en el archivo generado.
-->

# [Nombre de la feature]
Objetivo: [una línea con el resultado que se busca].
Rama: [feature/…]; entrega: [ask-on-risk | auto-chain | single-pr | exception-ok]; runner: [comando exacto | ninguno]; TDD: [on | off] ([fuente: docs/odd/config.md | sesión | elección del usuario]).

## Specs
S1. [Requisito. Citar literal lo del usuario: "texto exacto", mensajes de error, comandos, ejemplos.] Aceptación: [criterio observable]. Checks: [test / comando].
S2. [Suposición: … — marcada como suposición si no la dijo el usuario.]

## Tasks
T1 | S1 | inline | pending | commit pending | [evidencia RED/GREEN o checks al cerrar]
T2 | S2 | delegada (paralelismo: superficie disjunta con T3) | pending | commit pending |

<!-- Estados: pending · in_progress · done · blocked · reopened (con motivo en el Log). -->

## Log
L1. [AAAA-MM-DD] Pedido original del usuario (literal): "[…]"
L2. [AAAA-MM-DD] Pronóstico: ≈[N] líneas de autoría cambiadas (sumas + restas, sin generados); estrategia de entrega: [..].
