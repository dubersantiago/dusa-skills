# Delegación en ODD

Por defecto la sesión principal trabaja **directo**. Cada disparador se activa solo cuando su condición se cumple de verdad, y entonces es **obligatorio**: detenerse y delegar antes de seguir. Ejecutar directo después de que se disparó un disparador es un defecto de ruteo, aunque el trabajo salga bien. Ante la duda, directo.

Cada cambio autorizado toma exactamente una ruta de implementación: **directa** o **delegada**. La cantidad de archivos, las líneas cambiadas, el tamaño o el riesgo percibido nunca obligan por sí solos a una ruta más pesada. Tests, builds e instalaciones pueden correr en workers sin cambiar la ruta elegida.

Si el agente no soporta subagentes, hacer el trabajo del disparador en la sesión principal, anotar que no hubo aislamiento y, para el verificador, declararlo como "no disponible" en el cierre.

## Disparadores

| Disparador | Condición | Qué hacer |
|---|---|---|
| **Pregunta** | Decisión de producto o diseño abierta | Una pregunta enfocada; detenerse y esperar |
| **Mapeo** | Entender supera el lote directo (≈3 llamadas, ≈10k tokens) o necesita más de ≈5 búsquedas secuenciales | Un explorador de solo lectura antes de decidir o escribir. Devuelve ≤≈2k tokens con evidencia `ruta:línea`; una sola comprobación puntual del padre; no releer todo lo mapeado. Luego reevaluar el tamaño |
| **Verificación** | La línea de riesgo nombra un ítem de alto riesgo | Un verificador independiente **después** de los checks propios del cambio. Solo por un ítem nombrado, nunca por el modelo que escribió ni por "parece delicado" |
| **Seguimiento** | Tarea grande | Documento de feature + commits por unidad de trabajo |
| **Escritor** | (a) **Paralelismo:** dos o más unidades de comportamiento independientes, con superficies de edición disjuntas, cada una de varios minutos (varios archivos o ≈100+ líneas); se lanzan juntas. (b) **Contexto:** respaldo de sesión larga | Un escritor acotado por unidad. Nunca por tamaño, por ser grande, por cantidad de archivos o por precio. Unidades de ≈100 líneas o menos van siempre directo |
| **Preparación** | El disparador Escritor delega una escritura | La lectura que la prepara se delega junto con ella; las escrituras directas se leen directo |
| **Sesión larga** | ≈150k tokens en el contexto principal | Pausar y delegar la siguiente unidad acotada (orientativo) |

**Declaración de ruta:** en trabajo grande, registrar en `## Tasks` la ruta de cada tarea (inline / delegada) y el motivo del disparador, para que una delegación omitida sea visible.

## Reglas para escritores en paralelo

- Una **unidad** es una pieza de comportamiento independiente con su código, tests y docs juntos. Nunca separar un comportamiento en escritores de test, docs y código. Una entrega que depende de otra no es independiente.
- Mismo repo y mismo árbol: cada escritor con su superficie de edición declarada y disjunta. El padre es dueño de git. Los escritores no corren formateadores, generadores ni instalaciones de todo el repo. Un archivo compartido tiene un solo dueño o lo edita el padre al final. El padre revisa el diff de cada escritor contra su superficie antes de aceptarlo, y corre una única comprobación de costura al final (la suite completa, una vez).
- Unidades que necesitan el mismo archivo, o trabajo en otro repo: en un worktree aislado.
- **Invariantes:** el prompt de cada escritor nombra los helpers existentes que debe reutilizar para estado compartido y las invariantes que mantienen (orden, unicidad, validación, normalización). Las unidades en paralelo no se ven entre sí: el prompt es el único lugar donde las aprenden. Nunca reimplementar ese paso con otra forma.

## Prompts (los subagentes no conocen la conversación)

**Escritor:**
```text
Implementa la tarea <T#> de <docs/odd/tasks/feature.md>. Lee el documento completo hasta "## Log" antes de editar.
Superficie de edición permitida: <archivos/carpetas>. No toques nada fuera de ella. No hagas commits, no corras formateadores ni instalaciones globales.
Reutiliza: <helpers existentes> y mantén estas invariantes: <…>.
TDD: <on/off>, runner: <comando>. Si está on: observa RED antes de implementar, luego GREEN, luego refactor.
Las ~400 líneas por tarea son una heurística, no un límite: no borres comentarios ni tests, no minifiques, no inventes abstracciones para ahorrar líneas.
Devuelve: diff resumido (--stat), qué S# cubriste, comandos ejecutados con su resultado real (RED/GREEN), rutas de scratch que creaste y huecos o decisiones que no tomaste.
```

**Explorador (solo lectura):**
```text
Solo lectura. Necesito un mapa para decidir: <pregunta concreta>.
Devuelve como máximo ~2k tokens: hallazgos con ruta:línea, qué es hecho verificado y qué es suposición, y lo que no pudiste confirmar.
```

**Verificador independiente (solo lectura, salvo scratch):**
```text
Verifica el cambio <commit o rango> contra <docs/odd/tasks/feature.md> (o el pedido literal: "<…>"). Lee el documento completo.
Riesgo declarado: <Risk: item N (motivo)>.
1. Corre los ejemplos de las specs autorizados; si mutan datos, contra estado aislado (directorio de mktemp -d), nunca contra datos reales.
2. Revisa el diff buscando regresiones en lo compartido que toca y efectos no pedidos.
3. No modifiques archivos del repo. Reporta las rutas de scratch que crees.
Devuelve un veredicto por S#: pass / fail / no verificado (motivo), con la evidencia observada.
```

**Desafío de premisa** (como máximo uno, para una premisa de alta consecuencia no probada, incluso en un cambio pequeño de seguridad): nombrar la premisa, la evidencia y la consecuencia; pedir a un subagente de solo lectura que intente refutarla. Sin bucles de debate: las fallas deterministas se arreglan, no se discuten.

## Investigación

Solo para una incertidumbre con nombre. Establecer problema, resultado buscado, restricciones y evidencia actual. Usar documentación o web autorizadas, preferir fuentes primarias y atribuir cada afirmación a una URL o `ruta:línea`. Distinguir hechos, suposiciones, contradicciones, vigencia y huecos. Devolver recomendación, trade-offs, preguntas abiertas e implicaciones. Siempre solo lectura: sus hallazgos no autorizan implementar. Si falta evidencia, pausar solo las decisiones inseguras que dependen de ella.
