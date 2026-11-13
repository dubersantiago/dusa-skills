# dusa-skills

Skills propias para agentes de código (Claude Code, Codex, Cursor, OpenCode…), instalables con el CLI [`skills`](https://github.com/vercel-labs/skills). Organizadas por metodología de trabajo.

| Metodología | En una línea | Entrada |
|---|---|---|
| [SDD](#sdd--spec-driven-development) | Control paso a paso: spec y plan aprobados, una tarea a la vez, pausa tras cada una | `/sdd` |
| [ODD](#odd--organic-driven-development) | Flujo proporcional: lo pequeño va directo, lo grande lleva un único documento de feature | `/odd` (o siempre activo vía `CLAUDE.md`) |

Usa `sdd` cuando quieras control paso a paso (zonas sensibles, equipos que revisan cada tarea) y `odd` para el trabajo diario. Puedes instalar una sola o las dos: cada grupo es autocontenido.

Utilidades sueltas, independientes de la metodología:

| Utilidad | En una línea | Entrada |
|---|---|---|
| [PR](#pr--mensajes-de-pull-request) | Título y cuerpo de un PR en Markdown a partir del diff entre dos ramas, según una plantilla | `/pr-mensaje` |

## Próximamente

- **SWARM (enjambres de agentes):** una ruta de ejecución para features **grandes y complejas** que se descomponen en unidades independientes. Un orquestador planifica, reparte el trabajo a workers en paralelo (cada uno con su superficie de edición disjunta), integra por olas y verifica con evidencia. Reutilizaría el documento de feature de ODD. No sería para el día a día: lo pequeño y lo secuencial seguirían en `odd`. Aún sin diseñar ni implementar.

---

## SDD — Spec-Driven Development

Spec-Driven Development con control humano, para cualquier tipo de proyecto (frontend, backend, infraestructura, datos, scripts, documentación). Cada trabajo queda en un único archivo `docs/contexts/<ID>-context.md` (spec + plan + tareas + bitácora).

```text
spec / brief ──► especificación + plan ──[apruebas]──► T-01 ──[autorizas]──► implementar ──► verificar ──► entrega ──[apruebas]──► … ──► cierre
```

- **Spec y plan antes que cambios**: el agente no toca nada hasta que apruebas el plan.
- **Una tarea a la vez**, con autorización explícita, y pausa al terminar cada una.
- **Verificación con evidencia**: cada comprobación queda como `PASS`, `FAIL` o `NOT_RUN`.
- **Los commits los haces tú**; el agente registra el hash.

**Skills (6):** `sdd` (orquestador) · `sdd-planificacion` · `sdd-mantenimiento` · `sdd-ejecucion` · `sdd-verificacion` · `sdd-auditoria`. Hay que instalarlas todas: el orquestador delega en las demás.

### Instalar SDD

```bash
# En el proyecto actual, para Claude Code
npx skills add dubersantiago/dusa-skills -a claude-code \
  -s sdd sdd-planificacion sdd-mantenimiento sdd-ejecucion sdd-verificacion sdd-auditoria

# Global (todos tus proyectos): agrega -g
npx skills add dubersantiago/dusa-skills -a claude-code -g \
  -s sdd sdd-planificacion sdd-mantenimiento sdd-ejecucion sdd-verificacion sdd-auditoria

# Otro agente: cambia -a (codex, cursor, opencode…)
npx skills add dubersantiago/dusa-skills -a codex \
  -s sdd sdd-planificacion sdd-mantenimiento sdd-ejecucion sdd-verificacion sdd-auditoria
```

### Usar SDD

```text
/sdd configurar                          # una vez por repo: crea docs/contexts/_config.md
/sdd docs/specs/FAJR-010.md              # trabajo nuevo desde una spec, brief o issue
/sdd necesito agregar X en el módulo Y   # trabajo nuevo sin spec
/sdd FAJR-010                            # retomar un trabajo
/sdd                                     # listar los trabajos abiertos
/sdd limpiar                             # borrar contextos COMPLETED ya mergeados
```

Guía completa (reglas del flujo, estados, configuración por proyecto): [skills/sdd/README.md](skills/sdd/README.md).

---

## ODD — Organic Driven Development

Adaptación portable de **Organic Driven Development**, el flujo de [Gentle Shell](https://github.com/Gentleman-Programming/gentle-shell) (Alan Buscaglia, licencia MIT). No es oficial ni está respaldada por ese proyecto.

Toda solicitud entra en el flujo sin pedirlo, y el trabajo crece de forma orgánica:

```text
Autorizar → Explorar → Resolver incertidumbre → Clasificar ─┬─ pequeño ─────────────────────┬─→ Implementar tarea a tarea → Cerrar con evidencia
                                                            └─ grande → Registrar (1 doc) ───┘
```

- **Lo pequeño va directo**, sin documentos: se retoma con el pedido y `git diff`.
- **Lo grande lleva un único documento** `docs/odd/tasks/<feature>.md`: specs citadas literalmente, tareas y log.
- **Una autorización inicial**; después pregunta solo ante decisiones reales.
- **Commits del agente por unidad de trabajo** (configurable a `Commits: usuario`, ver [Commits: agente o usuario](#commits-agente-o-usuario)).

**Skills (1):** `odd`, con referencias y plantillas que se cargan bajo demanda.

### Instalar ODD

```bash
# En el proyecto actual, para Claude Code
npx skills add dubersantiago/dusa-skills -a claude-code -s odd

# Global (todos tus proyectos)
npx skills add dubersantiago/dusa-skills -a claude-code -g -s odd

# Otro agente
npx skills add dubersantiago/dusa-skills -a codex -s odd
```

### Activar ODD en un proyecto

ODD debe correr en **cada** solicitud, así que agrega esto al `CLAUDE.md` / `AGENTS.md` del proyecto:

```markdown
## Flujo de trabajo
Usa la skill `odd` (Organic Driven Development) en toda solicitud. Configuración en `docs/odd/config.md`; documentos de feature en `docs/odd/tasks/`.
```

También puedes invocarla a mano con `/odd`.

### Configurar ODD (`docs/odd/config.md`)

La configuración es opcional y vive en `docs/odd/config.md`, en la raíz del proyecto (versiónalo). Lo que no declares usa el valor por defecto. Para crearla, copia la plantilla que viene con la skill instalada:

```bash
cd ~/Proyectos/mi-proyecto
mkdir -p docs/odd
cp .claude/skills/odd/templates/config-template.md docs/odd/config.md      # instalada en el proyecto
# cp ~/.claude/skills/odd/templates/config-template.md docs/odd/config.md  # instalada global (-g)
```

Después reemplaza cada `[opción | opción]` por el valor que quieras y borra el comentario del principio. La plantilla tiene secciones de pruebas (TDD, runner, checks), commits y entrega, áreas de alto riesgo y referencias.

### Commits: agente o usuario

Por defecto, en el trabajo grande **el agente hace los commits** por unidad de trabajo, en la rama de la feature (si está en la rama por defecto, primero crea la rama). Si prefieres hacerlos tú, como en SDD, pon `Commits: usuario`.

Ejemplo completo de `docs/odd/config.md` para un proyecto donde los commits los haces tú:

```markdown
# ODD — mi-proyecto

## Pruebas
- **TDD:** on
- **Runner enfocado:** `npx jest <ruta>`
- **Suite completa:** `npm test`
- **Otros checks:** tipos: `npx tsc --noEmit` · lint: `npm run lint`

## Commits y entrega
- **Commits:** usuario
- **Rama por defecto:** main
- **Estrategia de entrega por defecto:** ask-on-risk

## Riesgo
- **Áreas de alto riesgo propias del proyecto:** `src/auth/**`, migraciones en `db/`
```

Si solo quieres cambiar los commits, basta con esto (todo lo demás usa los valores por defecto):

```bash
mkdir -p docs/odd
cat > docs/odd/config.md <<'EOF'
# ODD — mi-proyecto

## Commits y entrega
- **Commits:** usuario
EOF
```

Cómo se ve en la práctica con `Commits: usuario`:

```text
Agente:  T2 lista para commit.
         Archivos: src/auth/token.ts, src/auth/token.test.ts
         Mensaje propuesto: feat(auth): validar expiración del token en el login
         Me detengo hasta que hagas el commit.

Tú:      git add src/auth/token.ts src/auth/token.test.ts
         git commit -m "feat(auth): validar expiración del token en el login"
         → "listo, hice el commit"

Agente:  Registra el hash en ## Tasks de docs/odd/tasks/<feature>.md y sigue con T3.
```

| | `agente` (por defecto) | `usuario` |
|---|---|---|
| Quién hace el commit | El agente, por unidad de trabajo | Tú |
| Qué hace el agente | Commitea y sigue con la siguiente tarea | Deja la unidad lista (lista exacta de archivos + mensaje Conventional Commit propuesto) y se detiene |
| Registro | Hash del commit en `## Tasks` del documento de feature | Cuando avisas que hiciste el commit, registra el hash en `## Tasks` |

En los dos modos, push, crear PR y merge **siempre** son decisión tuya, y el agente nunca reescribe historial (rebase, amend, force-push) sin autorización explícita. El trabajo pequeño no hace commits salvo que los pidas.

Guía completa (tamaños, diferencias con SDD, qué se adaptó del original): [skills/odd/README.md](skills/odd/README.md).

---

## Usar SDD y ODD en un mismo proyecto

Se pueden instalar las dos en el mismo proyecto. No chocan en archivos (SDD usa `docs/contexts/`, ODD usa `docs/odd/`), pero sí en el disparo: ODD se activa en **toda** solicitud desde el `CLAUDE.md`, y SDD solo con `/sdd`. Sin una regla de prioridad, el agente podría aplicar las dos a la vez. La solución es declarar en el `CLAUDE.md` / `AGENTS.md` cuál manda en cada caso.

**1. Instala las dos** (el orquestador de SDD necesita sus 5 skills hermanas):

```bash
cd ~/Proyectos/mi-proyecto
npx skills add dubersantiago/dusa-skills -a claude-code \
  -s sdd sdd-planificacion sdd-mantenimiento sdd-ejecucion sdd-verificacion sdd-auditoria odd
```

**2. Agrega esto al `CLAUDE.md` / `AGENTS.md`** en lugar del bloque de solo ODD:

```markdown
## Flujo de trabajo
Este proyecto usa dos metodologías. Elige una por solicitud, nunca las dos a la vez:

- **Por defecto, usa la skill `odd`** (Organic Driven Development) en toda solicitud. Configuración en `docs/odd/config.md`; documentos de feature en `docs/odd/tasks/`.
- **Usa la skill `sdd` solo si invoco `/sdd`** o si lo pido de forma explícita ("hazlo con SDD"). Mientras dure ese trabajo, `odd` no aplica: sigue el flujo de `sdd` (contexto en `docs/contexts/`, una tarea a la vez, commits míos).
- Si hay un contexto SDD abierto (`docs/contexts/*-context.md` sin cerrar) y retomo ese trabajo, continúa con `sdd`.
- Zonas sensibles (indica aquí las rutas, p. ej. `src/auth/**`, `db/migrations/`): usa siempre `sdd`.
```

**3. Configura cada una por separado**, son independientes: `/sdd configurar` crea `docs/contexts/_config.md` y `docs/odd/config.md` es opcional (ver [Configurar ODD](#configurar-odd-docsoddconfigmd)).

**Cómo se reparte el trabajo**

| Situación | Metodología | Cómo se entra |
|---|---|---|
| Arreglo pequeño, cambio de una línea, duda | `odd` (directo, sin documentos) | Solicitud normal |
| Feature mediana o grande del día a día | `odd` (un documento en `docs/odd/tasks/`) | Solicitud normal |
| Zona sensible, cambio que el equipo revisa tarea por tarea | `sdd` | `/sdd <spec o pedido>` |
| Retomar un trabajo de SDD | `sdd` | `/sdd <ID>` |

Un mismo trabajo usa una sola metodología de principio a fin. Si uno empezado en `odd` resulta ser sensible, ciérralo o descártalo y reábrelo con `/sdd`; no mezcles `docs/odd/tasks/<feature>.md` con `docs/contexts/<ID>-context.md` para la misma feature.

Si las dos usan commits, ojo con los modos: SDD siempre deja los commits al usuario; ODD por defecto los hace el agente. Si quieres el mismo comportamiento en todo el proyecto, pon `Commits: usuario` en `docs/odd/config.md`.

---

## PR — Mensajes de pull request

Redacta el título y el cuerpo de un PR leyendo `git log` y `git diff` desde el merge-base entre la rama origen y la destino, y rellena una plantilla. Es de solo lectura: no crea el PR salvo que se lo pidas (entonces usa `gh pr create`).

**Skills (1):** `pr-mensaje`.

```bash
npx skills add dubersantiago/dusa-skills -a claude-code -s pr-mensaje        # en el proyecto
npx skills add dubersantiago/dusa-skills -a claude-code -g -s pr-mensaje     # global
```

```text
/pr-mensaje de feature/login a develop    # ramas explícitas
/pr-mensaje de esta rama a main           # origen = rama actual
/pr-mensaje                               # rama actual → rama por defecto del remoto
```

**Plantilla**, la primera que exista:

1. La que indiques en el pedido (`/pr-mensaje de X a Y usando docs/mi-plantilla.md`).
2. La del repo: `.github/pull_request_template.md` (o sus variantes habituales, incluida la carpeta `.github/PULL_REQUEST_TEMPLATE/`).
3. La de la skill: [templates/pr-template.md](skills/pr/pr-mensaje/templates/pr-template.md) (resumen, tipo de cambio, cambios, cómo probar, riesgos, capturas, checklist).

No inventa pruebas, capturas ni motivaciones: lo que no sale del diff, los commits o tu pedido queda como `_Pendiente: …_` para que lo completes.

---

## Comandos de `npx skills`

Referencia rápida del CLI. `<fuente>` puede ser `dubersantiago/dusa-skills`, la URL completa (`https://github.com/dubersantiago/dusa-skills`), cualquier URL git o una ruta local.

| Para | Comando |
|---|---|
| Ver todas las skills del repo | `npx skills add <fuente> --list` |
| Instalar skills concretas | `npx skills add <fuente> -a claude-code -s <skill> [<skill>…]` |
| Instalar todo el repo (ambas metodologías) | `npx skills add <fuente> -a claude-code -s '*'` |
| Instalar global | agrega `-g` |
| Sin preguntas (CI, scripts) | agrega `-y` |
| Actualizar lo instalado | `npx skills update` |
| Crear una skill nueva | `npx skills init <nombre>` |

- `-s` (o `--skill`) acepta varios nombres, pero no comodines parciales: `'sdd*'` falla; solo nombres exactos o `'*'`.
- Sin `-a`, el CLI pregunta a qué agentes instalar.
- **Actualizar:** `npx skills update` solo actualiza lo instalado desde un repo remoto (GitHub o URL git). Lo instalado desde una ruta local se copia y no se actualiza solo: vuelve a instalarlo.
- Las skills se cargan al iniciar la sesión del agente: después de instalar o actualizar, abre una sesión nueva.

---

## Organización

```text
skills/
├── sdd/                       # un grupo por metodología
│   ├── README.md              # guía del grupo (no es una skill: no tiene SKILL.md)
│   ├── examples/              # configuraciones de ejemplo (tampoco son skills)
│   ├── sdd/                   # orquestador → /sdd
│   │   ├── SKILL.md
│   │   └── templates/
│   ├── sdd-planificacion/
│   ├── sdd-mantenimiento/
│   ├── sdd-ejecucion/
│   ├── sdd-verificacion/
│   └── sdd-auditoria/
├── odd/                       # otra metodología, mismo patrón
│   ├── README.md
│   └── odd/                   # una sola skill → /odd
│       ├── SKILL.md
│       ├── references/        # se cargan bajo demanda
│       └── templates/
└── pr/                        # utilidad suelta
    └── pr-mensaje/            # → /pr-mensaje
        ├── SKILL.md
        └── templates/
```

El CLI busca `SKILL.md` dentro de `skills/` hasta tres niveles (`skills/<grupo>/<skill>/SKILL.md`), así que los grupos funcionan sin configuración extra. Al instalar, el grupo **desaparece**: todas las skills quedan juntas en `.claude/skills/<nombre>/`. De ahí las reglas:

- **Nombres únicos en todo el repo, con el prefijo del grupo** (`sdd-…`, `odd-…`). Si dos skills se llaman igual, el CLI solo conserva la primera, y al instalarlas una pisaría a la otra.
- `name` del frontmatter = nombre de la carpeta, en minúsculas con guiones.
- **Cada grupo es autocontenido.** Si un grupo necesita reglas parecidas a las de otro (bitácora, verificación con evidencia), cópialas y adáptalas dentro del grupo; no hagas que una skill de `odd` dependa de una de `sdd`, porque alguien puede instalar solo uno de los grupos.

## Crear una skill nueva

```bash
mkdir -p skills/<grupo> && cd skills/<grupo> && npx skills init <grupo>-mi-skill   # o crea la carpeta a mano
```

```markdown
---
name: <grupo>-mi-skill
description: Qué hace y CUÁNDO usarla. El agente decide cargarla solo con esta línea.
---

# <grupo>-mi-skill

Instrucciones…
```

- La `description` es lo único que el agente ve antes de cargar la skill: di qué hace y cuándo usarla.
- Las rutas a archivos de la skill, relativas a su carpeta (`templates/x.md`, `references/y.md`). Para referirte a otra skill, usa su nombre, no una ruta como `.claude/skills/...`: según el agente se instala en `.claude/skills/`, `.agents/skills/` u otra carpeta.
- Nada específico de un proyecto (rutas, comandos, ramas, stack) dentro de la skill: léelo de un archivo de configuración del proyecto o de `CLAUDE.md`/`AGENTS.md` (así lo hace `sdd` con `docs/contexts/_config.md`).
- Los subagentes (`.claude/agents/*.md`) **no** se instalan con `npx skills`: quedan en cada proyecto.

Probar en local antes de publicar:

```bash
cd ~/algún-proyecto
npx skills add /ruta/a/dusa-skills --list
npx skills add /ruta/a/dusa-skills --skill <grupo>-mi-skill -a claude-code
```
