---
name: pr-mensaje
description: Genera el mensaje de un pull request (título + cuerpo en Markdown) a partir del git diff entre dos ramas, siguiendo una plantilla. Usar cuando el usuario pida crear, redactar o escribir un PR, la descripción de un PR o un mensaje de PR ("quiero un PR de esta rama a main", "descripción del PR de feature/x a develop") o invoque /pr-mensaje. Solo lectura del repo; no crea el PR en GitHub salvo que se pida.
---

# /pr-mensaje — Mensaje de PR desde el diff

Redacta el título y el cuerpo de un pull request leyendo los cambios reales entre una rama **origen** (la que se mergea) y una rama **destino** (contra la que se abre el PR), y rellena una plantilla Markdown.

Es una tarea de **solo lectura**: no edites archivos, no hagas commits, no hagas push y no crees el PR salvo que el usuario lo pida explícitamente.

## 1. Identificar las ramas

Del pedido del usuario ("de `feature/login` a `develop`", "de esta rama a main"):

- **Origen:** la rama que nombre; "esta rama" o nada = la rama actual (`git branch --show-current`).
- **Destino:** la rama que nombre. Si no la nombra, usa la rama por defecto del remoto (`git symbolic-ref --short refs/remotes/origin/HEAD`, sin el prefijo `origin/`); si no se puede obtener, `main` o `master`, la que exista. Di en una línea qué destino asumiste.
- Si alguna rama no existe (ni local ni en `origin/`), dilo y pregunta; no adivines nombres parecidos.

Refs a comparar:

1. Si hay remoto, intenta `git fetch origin <destino> <origen> --quiet` (solo actualiza las refs remotas, no toca ramas locales). Si falla (sin red, sin credenciales), sigue con lo local y avísalo.
2. Para el **destino** usa `origin/<destino>` si existe (es contra lo que GitHub compara); si no, la rama local.
3. Para el **origen** usa la rama local si existe; si solo existe en el remoto, `origin/<origen>`. Si la local va por detrás o por delante de `origin/<origen>`, avísalo: el PR mostrará lo que esté pusheado.

Si el origen es la rama actual y hay cambios sin commitear (`git status --porcelain`), avisa de que **no** entran en el PR y no los describas.

## 2. Leer los cambios

Usa siempre la comparación desde el **merge-base** (tres puntos en `diff`, dos en `log`), que es lo que muestra un PR:

```bash
git log --no-merges --format='%h %s%n%b' <destino>..<origen>   # commits del PR
git diff --stat <destino>...<origen>                           # archivos y tamaño
git diff <destino>...<origen> -- <ruta>                        # diff, por archivo o por grupos
```

- Si no hay commits entre las ramas, dilo y para: no hay PR que describir.
- Empieza por `--stat` y el log para entender el alcance; después lee el diff. En diffs grandes léelo por archivos o carpetas, priorizando código fuente, migraciones, configuración y tests.
- No leas línea a línea archivos generados o ruidosos (lockfiles, `dist/`, snapshots, código autogenerado, binarios): menciónalos en una línea ("se actualizó `package-lock.json`").
- Si algo del diff no se entiende sin contexto, lee el archivo completo en la rama origen (`git show <origen>:<ruta>`).
- Busca un ID de ticket en el nombre de la rama o en los commits (`ABC-123`, `#45`) para referenciarlo.

## 3. Elegir la plantilla

En este orden, la primera que exista:

1. Una ruta o plantilla que el usuario indique en el pedido.
2. La plantilla del repo: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `docs/pull_request_template.md` o `pull_request_template.md` en la raíz (sin distinguir mayúsculas). Si hay varias en `.github/PULL_REQUEST_TEMPLATE/`, elige la que encaje con el tipo de cambio y di cuál usaste.
3. La plantilla por defecto de esta skill: `templates/pr-template.md`.

Respeta la estructura de la plantilla elegida: mismos encabezados, mismo orden, mismo idioma. Elimina los comentarios HTML de instrucciones (`<!-- ... -->`) una vez rellenada la sección.

## 4. Redactar

**Título:** una línea, en imperativo, ≤ 72 caracteres. Si el repo usa Conventional Commits (mira el log), sigue ese formato (`feat(auth): agregar login con Google`). Incluye el ID de ticket si el proyecto lo hace en los commits o ramas.

**Cuerpo:** rellena cada sección de la plantilla con lo que dice el diff:

- **Explica el porqué y el efecto**, no repitas el diff. "Los tokens expirados ahora se renuevan antes de reintentar la petición", no "se modificó `api.ts`".
- Agrupa los cambios por tema o módulo, no por commit ni por archivo. Menciona archivos o funciones solo cuando ayuden al revisor a orientarse.
- Señala lo que el revisor debe mirar con cuidado: migraciones, cambios de API o contratos, configuración, variables de entorno nuevas, dependencias añadidas o actualizadas, borrados, cambios de permisos o seguridad, breaking changes.
- **No inventes.** Nada de pruebas ejecutadas, métricas, capturas, motivaciones de negocio ni issues que no salgan del diff, los commits o el pedido. Si una sección necesita información que no tienes (motivación de producto, capturas, pasos de QA manual), deja un marcador visible: `_Pendiente: <qué falta>_`.
- "Cómo probar": deriva los pasos de lo que cambió (endpoints, pantallas, comandos, tests añadidos). Si hay tests nuevos o modificados, nómbralos.
- Checkboxes: márcalos `[x]` solo si el diff lo demuestra (p. ej. "se agregaron tests" cuando hay archivos de test nuevos). El resto, sin marcar.
- Secciones que no aplican: escribe `No aplica.` en vez de borrarlas, salvo que la plantilla diga que son opcionales.
- Proporción: un PR de 2 líneas lleva un cuerpo corto; no rellenes por rellenar.

## 5. Entregar

Responde con:

1. Una línea con el resumen de la comparación: `origen → destino`, número de commits y archivos, y la plantilla usada.
2. Los avisos que hagan falta (cambios sin commitear, rama sin pushear, fetch fallido, destino asumido).
3. El **título** y el **cuerpo**, cada uno en su bloque de código (el cuerpo en un bloque ` ```markdown `) para copiarlos tal cual. Si el cuerpo contiene bloques de código, usa cuatro backticks para el bloque exterior.
4. La lista de marcadores `_Pendiente_` que el usuario debe completar, si hay.

Si el usuario lo pide:

- **Guardar en archivo:** escribe el cuerpo en la ruta que indique (o en un temporal fuera del repo) para usarlo con `--body-file`.
- **Crear el PR:** confirma antes ramas y título, y usa `gh pr create --base <destino> --head <origen> --title "<título>" --body-file <archivo>`. Si la rama origen no está en el remoto, avisa en lugar de hacer push por tu cuenta.
