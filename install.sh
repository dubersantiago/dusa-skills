#!/usr/bin/env bash
# Instala todas las skills de un grupo (metodología) con el CLI `skills`.
#
# Uso (desde la raíz del proyecto donde quieres instalarlas):
#   /ruta/a/dusa-skills/install.sh <grupo> [opciones de `npx skills add`]
#
# Ejemplos:
#   ~/Proyectos/dusa-skills/install.sh sdd            # en el proyecto actual, para Claude Code
#   ~/Proyectos/dusa-skills/install.sh sdd -g         # global (todos tus proyectos)
#   ~/Proyectos/dusa-skills/install.sh odd -a codex   # para otro agente
#   SOURCE=<usuario>/dusa-skills ~/Proyectos/dusa-skills/install.sh sdd   # desde GitHub
#
# Volver a ejecutarlo reinstala (actualiza) el grupo.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${SOURCE:-$REPO_DIR}"

listar_grupos() {
  for d in "$REPO_DIR"/skills/*/; do
    [ -d "$d" ] && printf '  %s\n' "$(basename "$d")"
  done
}

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Uso: $(basename "$0") <grupo> [opciones de npx skills add]"
  echo "Grupos disponibles:"
  listar_grupos
  exit 1
fi

GRUPO="$1"; shift

if [ ! -d "$REPO_DIR/skills/$GRUPO" ]; then
  echo "No existe el grupo '$GRUPO'. Grupos disponibles:" >&2
  listar_grupos >&2
  exit 1
fi

# Cada carpeta con SKILL.md dentro del grupo es una skill.
SKILLS=()
for f in "$REPO_DIR/skills/$GRUPO"/*/SKILL.md; do
  [ -f "$f" ] && SKILLS+=("$(basename "$(dirname "$f")")")
done

if [ ${#SKILLS[@]} -eq 0 ]; then
  echo "El grupo '$GRUPO' no tiene skills (ninguna carpeta con SKILL.md)." >&2
  exit 1
fi

# Agente por defecto: Claude Code, salvo que se pase -a/--agent.
AGENTE=(-a claude-code)
for arg in "$@"; do
  case "$arg" in -a|--agent|--agent=*|--all) AGENTE=() ;; esac
done

echo "Instalando grupo '$GRUPO' desde $SOURCE: ${SKILLS[*]}"
exec npx -y skills add "$SOURCE" ${AGENTE[@]+"${AGENTE[@]}"} -y "$@" -s "${SKILLS[@]}"
