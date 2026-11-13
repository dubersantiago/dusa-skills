<!--
CONFIGURACIÓN ODD — una por repositorio. Ubicación: docs/odd/config.md (versionar).
Todo es opcional: lo que falte usa el valor por defecto indicado.
La configuración dice CÓMO se trabaja en este repo; no relaja el protocolo.
Borrar este comentario en el archivo generado.
-->

# ODD — [nombre del proyecto]

## Pruebas
- **TDD:** [on | off] — por defecto: preguntar una vez al primer cambio de comportamiento que tenga un test ejecutable, y registrarlo aquí si el usuario quiere.
- **Runner enfocado:** [`npx jest <ruta>` | `pytest <ruta>` | `go test ./pkg/...`]
- **Suite completa:** [`npm test` | `pytest` | …]
- **Otros checks:** [tipos: `npx tsc --noEmit` · lint: `npm run lint` · build: `npm run build` · infra: `terraform plan`]
- **Fallas preexistentes conocidas:** [comando → error exacto → motivo | ninguna]

## Commits y entrega
- **Commits:** [agente | usuario] — por defecto `agente`: el agente hace commits por unidad de trabajo en la rama de la feature en trabajo grande. Con `usuario`, el agente deja cada unidad lista (archivos + mensaje Conventional Commit propuesto), se detiene y registra el hash cuando el usuario avisa.
- **Rama por defecto:** [main | development] — por defecto la del remoto (`git symbolic-ref refs/remotes/origin/HEAD`).
- **Estrategia de entrega por defecto:** [ask-on-risk | auto-chain | single-pr | exception-ok] — por defecto `ask-on-risk`.
- **Presupuesto por porción:** [400] líneas de autoría cambiadas (heurística).
- **Política de contribución del repo:** [ruta a CONTRIBUTING.md o reglas de tamaño de PR | ninguna]

## Riesgo
- **Áreas de alto riesgo propias del proyecto** (se suman a la lista de ODD): [p. ej. `src/auth/**`, migraciones en `db/`, pipelines en `.github/`]

## Referencias
- **Instrucciones del proyecto:** `CLAUDE.md` / `AGENTS.md`
- **Skills técnicas a cargar al implementar:** [p. ej. `angular-development` | ninguna]
- **Memoria persistente:** [Engram MCP | ninguna] — si existe, se espeja cada documento de feature.
