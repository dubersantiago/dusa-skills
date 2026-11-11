# Commits y entrega en ODD

Aplica al trabajo grande. El trabajo pequeño no hace commits salvo que el usuario los pida.

## Política de commits (`odd/config.md` → "Commits")

- **`agente` (por defecto, como en ODD original):** el agente hace commits por unidad de trabajo en la rama de la feature. Si está en la rama por defecto, primero crea la rama. Estos commits son parte de la implementación autorizada; **push, crear PR y merge siguen siendo decisión del usuario**.
- **`usuario`:** el agente deja cada unidad lista (lista exacta de archivos + mensaje Conventional Commit propuesto), se detiene y, cuando el usuario avisa que hizo el commit, registra el hash en `## Tasks` (`git log --oneline -3`).

Nunca reescribir historial (rebase, amend de commits ajenos, force-push) sin autorización explícita.

## Commits por unidad de trabajo

| Regla | Requisito |
|---|---|
| Por unidad de trabajo | Un commit = un comportamiento, arreglo, migración o unidad de docs entregable |
| No por tipo de archivo | Nada de "modelos", luego "servicios", luego "tests" si ninguno funciona solo |
| Tests con el código | Los tests van en el mismo commit que el comportamiento que verifican |
| Docs con el cambio visible | La documentación va con la feature que explica |
| Cuenta una historia | Del diff y el mensaje se entiende por qué existe el commit |
| Listo para PR | Cada commit podría ser un PR encadenado si el cambio crece |
| Alto riesgo aparte | Una unidad cuya línea de riesgo nombra un ítem de alto riesgo va en su propio commit, para revisarla sola |

Checklist antes de cada commit: un propósito claro · el repo tiene sentido aplicando solo este commit · incluye sus tests/docs · se puede revertir sin arrastrar trabajo ajeno · el mensaje explica el resultado, no la lista de archivos.

Mensajes en formato Conventional Commits: `feat(auth): validar expiración del token en el login`. Registrar en `## Tasks` el commit que contiene cada tarea.

## Presupuesto (~400 líneas)

- ≈400 líneas de autoría cambiadas (sumas + restas, sin archivos generados) por porción es una **heurística de planificación**: no es un límite, ni un criterio de aceptación, ni una parada automática, ni una división forzada.
- Si la solución correcta y clara lo excede naturalmente, explicar brevemente por qué y seguir.
- **No es code-golf:** nunca borrar espacios, líneas en blanco, comentarios o tests, minificar, inventar abstracciones ni partir artificialmente para encajar.
- Después de una pasada honesta de división, si ninguna partición coherente cabe, reportar el conteo honesto y el motivo; no iterar achicando código.

## Estrategia de entrega

Al crear el documento de feature, pronosticar las líneas de autoría a partir de las tareas y registrar el pronóstico en el Log; después llevar un conteo con cada commit. Una estrategia por feature:

| Estrategia | Comportamiento al superar ~400 líneas (pronóstico o conteo) |
|---|---|
| `ask-on-risk` (por defecto) | Preguntar una vez con el menú de abajo, antes del siguiente commit |
| `auto-chain` | Preguntar solo si falta la estrategia de cadena; luego partir en porciones automáticamente |
| `single-pr` | Un solo PR; reportar la carga de revisión y seguir la política de contribución del repo |
| `exception-ok` | Excepción aceptada explícitamente por el usuario (nunca elegirla automáticamente) |

Menú (en el idioma del usuario; los tokens no se traducen):

1. **Cadena sobre una rama de feature** — `chain_strategy=feature-branch-chain`: PRs hijos revisados que se integran en la rama de la feature, que luego se integra completa.
2. **Cadena apilada hacia la rama por defecto** — `chain_strategy=stacked-to-main`: las porciones aterrizan en orden sobre la rama por defecto verificada (no un nombre asumido).
3. **Un solo PR — el menos recomendado** — `delivery_strategy=single-pr`: se revisa todo el cambio junto (más carga para quien revisa, feedback más lento, rollback acoplado). Un PR enfocado de ≤400 líneas sigue siendo razonable.

Si no hay humano que pueda responder (sesión no interactiva), usar `feature-branch-chain`, registrarlo en el Log y seguir.

Guardar ambas elecciones en la cabecera del documento y registrar los límites de cada porción (qué commits contiene cada PR) en el Log. Elegir la forma de entrega **no** autoriza push, creación de PR ni merge.
