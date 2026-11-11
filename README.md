# dusa-skills

Skills propias para agentes de código (Claude Code, Codex, Cursor, OpenCode…), instalables con el CLI [`skills`](https://github.com/vercel-labs/skills). Organizadas por metodología de trabajo.

## Metodologías

| Grupo | Qué es | Entrada | Guía |
|---|---|---|---|
| `sdd` | Spec-Driven Development con control humano: spec y plan aprobados, una tarea a la vez, verificación con evidencia, bitácora | `/sdd` | [skills/sdd/README.md](skills/sdd/README.md) |
| `odd` | Organic Driven Development, adaptado de [Gentle Shell](https://github.com/Gentleman-Programming/gentle-shell): flujo proporcional, lo pequeño va directo y lo grande lleva un único documento de feature | `/odd` (o siempre activo vía `CLAUDE.md`) | [skills/odd/README.md](skills/odd/README.md) |

## Instalar

La forma corta es `install.sh`, que instala todas las skills de un grupo. Ejecútalo desde la raíz del proyecto donde las quieres:

```bash
cd ~/Proyectos/mi-proyecto
~/Proyectos/dusa-skills/install.sh sdd            # el grupo sdd, para Claude Code
~/Proyectos/dusa-skills/install.sh sdd -g         # global (todos tus proyectos)
~/Proyectos/dusa-skills/install.sh odd -a codex   # otro grupo, otro agente
~/Proyectos/dusa-skills/install.sh                # lista los grupos disponibles
```

- Detecta las skills del grupo a partir de `skills/<grupo>/*/SKILL.md`, así que no hay que tocarlo al agregar skills.
- Las opciones extra se pasan tal cual a `npx skills add`. Si no indicas `-a`, usa `-a claude-code`.
- Por defecto instala desde la copia local del repo. Para instalar desde GitHub: `SOURCE=<usuario>/dusa-skills ~/Proyectos/dusa-skills/install.sh sdd`.

**Actualizar:** `npx skills update` solo actualiza lo que se instaló desde un repo remoto (GitHub o una URL git). Lo instalado desde una ruta local se copia y no se actualiza solo: vuelve a ejecutar `install.sh <grupo>`.

Sin el script, con el CLI directo:

```bash
npx skills add <usuario>/dusa-skills --list                          # ver todas las skills
npx skills add <usuario>/dusa-skills -a claude-code \
  -s sdd sdd-{planificacion,mantenimiento,ejecucion,verificacion,auditoria}   # un grupo (-s acepta varios nombres)
npx skills add <usuario>/dusa-skills -a claude-code -s '*'           # todo el repo
```

`-s` no acepta comodines parciales (`'sdd*'` falla), solo nombres exactos o `'*'`. También acepta la URL completa (`https://github.com/<usuario>/dusa-skills`), cualquier URL git o una ruta local.

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
└── odd/                       # otra metodología, mismo patrón
    ├── README.md
    └── odd/                   # una sola skill → /odd
        ├── SKILL.md
        ├── references/        # se cargan bajo demanda
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
