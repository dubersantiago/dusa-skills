---
name: sdd-planificacion
description: Fase de especificación y planificación del flujo SDD. Convierte una spec, brief, issue o descripción de cambio (de cualquier tipo de proyecto) en un archivo docs/contexts/<ID>-context.md con objetivo, alcance, estado actual verificado, decisiones, tareas pequeñas con criterios de aceptación e impacto, sin escribir código. Parte del flujo /sdd; la invoca al iniciar un trabajo nuevo o al replanificarlo por completo.
---

# sdd-planificacion

Produces la especificación y el plan de un trabajo en su contexto, y los presentas para aprobación. **No escribes ni modificas código ni artefactos del proyecto** (infraestructura, migraciones, configuración, pipelines).

## Entradas

- Spec, brief, issue o descripción del usuario, y los documentos que indique con `@`.
- Plantillas: `templates/context-template.md` (normal) y `templates/context-template-ligero.md` (ligero), en la carpeta de esta skill.
- Configuración del proyecto: `docs/contexts/_config.md` (si existe; ver `sdd` §7).
- Instrucciones del proyecto (`CLAUDE.md`, `AGENTS.md`) y los documentos de referencia que liste la configuración y que existan.

## Pasos

### 1. Entender el pedido
Extraer en una línea qué se quiere, dónde vive (área existente o nueva), qué interfaces o contratos involucra (APIs, eventos o mensajes, esquemas de datos, parámetros de CLI, variables de infraestructura, configuración compartida) y qué partes del sistema toca.
Si falta un dato, hay ambigüedad o caben dos lecturas razonables: **preguntar antes de seguir**. No suponer.

### 2. Elegir ID y modo
- **ID:** el de la spec, brief o issue (p. ej. `FAJR-003`). Si no hay, proponer uno corto en mayúsculas y confirmarlo con el usuario.
- Comprobar que no exista ya `docs/contexts/<ID>-context.md`. Si existe, es el mismo trabajo: pasar a `sdd-mantenimiento`, no crear otro.
- **Modo:** según los criterios de `sdd` §5 y las "áreas siempre en modo normal" de la configuración. Ante la duda, normal.

### 3. Leer el código del área afectada
- Mapear el área: archivos, tests existentes y quién la importa. Usar las "recetas de exploración" de la configuración si las hay; si no, algo equivalente a:

```bash
find <carpeta-del-area> -type f | sort
find <carpeta-del-area> -name "*.spec.*" -o -name "*.test.*" -o -name "test_*"
grep -rl "<carpeta-o-símbolo-del-area>" <src> 
```

- Leer completos los archivos que toca el pedido (módulos, modelos, servicios, configuración, infraestructura, scripts, migraciones…).
- Respetar las "reglas de arquitectura" de la configuración y las convenciones de `CLAUDE.md`/`AGENTS.md`. No proponer patrones que el proyecto declare prohibidos o en deuda.
- Registrar lo verificado en "Estado actual verificado", con `archivo:línea`. Indicar si algo se reprodujo en ejecución o solo se leyó.
- Buscar código reutilizable (utilidades, servicios, patrones en otras áreas) antes de proponer código nuevo.

### 4. Confirmar contratos e interfaces
Para cada interfaz que se toca (API, evento, esquema, CLI, variables de infraestructura…):
- El contrato (forma de entrada y salida, nombres y su convención, errores, compatibilidad hacia atrás) sale de la **fuente que indique la configuración**. Si no la indica: solo de la spec o de lo que diga el usuario.
- Anotar la fuente de cada contrato en "Fuentes consultadas" (spec, sección, o "indicado por el usuario").
- Lo que falte se marca **"no verificado"** con el motivo y se le pregunta al usuario, o se convierte en decisión. **Nunca inventar campos.**
- Si en el código ya hay algo que consume el contrato, se puede citar como referencia del uso actual, pero no reemplaza la confirmación de la fuente.

### 5. Material de referencia (opcional)
Solo si la spec trae diseños, diagramas, ADRs u otro material (y la configuración dice cómo consultarlo, p. ej. un MCP de diseño). Los textos visibles, mensajes y nombres que el usuario verá salen de la spec o se le preguntan al usuario. No inventarlos.

### 6. Descomponer en tareas
- Tareas **pequeñas y revisables**: idealmente una tarea = un commit.
- Cada tarea lleva objetivo, alcance, archivos previstos, dependencias, decisiones requeridas, **criterios de aceptación verificables** y **verificaciones requeridas**.
- Las tareas que hacen cambios incluyen siempre las verificaciones "por tarea con cambios" de la configuración y los revisores que correspondan. Sin configuración: proponer los comandos deducidos de los scripts del proyecto y confirmarlos con el usuario al presentar el plan.
- Si el área tiene tests que el cambio puede romper, incluir la verificación de regresión (correr esos tests antes de modificarlos).
- Antes de prever un test, leer el setup del test existente del archivo: si sobrescribe o mockea lo que se quiere probar, no prometer ese test. Planificar lo que sí se puede probar y dejar el resto como prueba manual.
- Las pruebas manuales (navegador, llamada a una API, ejecución de un comando, despliegue en un entorno) se listan como verificación del usuario.

### 7. Decisiones
Todo lo que el usuario debe decidir antes de una tarea va como `D-xx`, con opciones, una recomendación con su motivo y las tareas que bloquea. No decidir por el usuario lo que cambie alcance, comportamiento visible o contratos.

**Formato al presentar decisiones al usuario (obligatorio, en chat).** La tabla del contexto es el registro; al usuario se le presenta cada decisión explicada, en lenguaje llano y sin asumir que conoce el código. Una sección por decisión, con este orden:

1. `## D-xx — <título corto> (<ref de la spec o tarea>)`
2. **Problema:** qué se ve o qué falla, en una o dos frases.
3. **Qué pasa hoy en el código:** causa o comportamiento actual, con `archivo:línea` si aporta. Indicar si es lectura de código o se reprodujo en ejecución.
4. **Lo que no sé:** lo no verificado, dicho explícitamente. No rellenar con suposiciones.
5. **Opciones:** `a)`, `b)`… con una línea de consecuencia cada una.
6. **Mi recomendación:** opción y motivo; si no hay base para recomendar, decirlo.
7. **Lo que necesito de ti:** la acción o dato concreto que el usuario debe aportar (p. ej. "ejecuta X en el entorno y pégame la salida", "dame el texto final", "confirma si aplica Y"). Si es decisión puramente técnica, decir que puede asumirla el agente si el usuario lo prefiere.

Cerrar con un **resumen** de una línea por decisión (qué hacer para cada una) y preguntar si aprueba el plan con decisiones pendientes o prefiere resolverlas antes; indicar por qué tarea se podría empezar según qué decisiones queden abiertas. Nunca presentar solo la tabla ni una lista de decisiones sin esta explicación.

### 8. Impacto y riesgos
Obligatorio si el cambio es disruptivo: cambia un contrato o la forma de los datos, requiere migración, toca varias partes del sistema a la vez, puede romper tests, afecta a otras áreas o a otros sistemas, o tiene efectos difíciles de revertir (datos, infraestructura). Listar los archivos que **no** cambian para acotar el alcance, los tests que pueden fallar, las dependencias externas y los riesgos (regresión, contrato, datos persistidos). Registrar la deuda detectada fuera de alcance en "Observaciones", sin proponer corregirla.

### 9. Escribir el contexto
- Crear `docs/contexts/<ID>-context.md` desde la plantilla del modo elegido. Omitir las secciones opcionales que no apliquen; no dejar secciones vacías.
- Estado del contexto: `AWAITING_PLAN_APPROVAL`. Todas las tareas en `PENDING`. Plan aprobado: no.
- Bitácora: fila `PLANNING` con las fuentes leídas.

### 10. Presentar y detenerse
Mostrar al usuario:
- objetivo y alcance en 2-3 líneas, y el modo propuesto;
- tabla de tareas (ID, nombre, dependencias);
- decisiones pendientes, explicadas con el formato del paso 7 (no solo la tabla);
- riesgos principales y lo que no se pudo verificar;
- si no hay configuración, las verificaciones que se proponen usar.

Pedir de forma explícita la aprobación del plan y las decisiones. **No iniciar ninguna tarea.**

## Restricciones

- No escribir código ni artefactos del proyecto, ni crear archivos fuera de `docs/contexts/`.
- No inventar interfaces, campos, rutas, nombres, textos ni versiones.
- No citar documentos que no existan: comprobar la ruta antes de citarla.
- No proponer patrones que el proyecto declare prohibidos o en deuda.
- No generar un contexto más largo de lo necesario.
