<!--
CONFIGURACIÓN DEL FLUJO DE TRABAJO — una por repositorio.
Ubicación: docs/contexts/_config.md (versionar junto con los contextos).
La leen todas las skills del flujo (sdd, sdd-planificacion, sdd-ejecucion,
sdd-verificacion, sdd-auditoria). Omitir las secciones que no apliquen.
Esta configuración dice CÓMO se verifica y QUÉ es sensible; nunca relaja las reglas del flujo.
Borrar este comentario en el archivo generado.
-->

# Configuración del flujo de trabajo — [nombre del proyecto]

## Documentos de referencia

| Archivo | Cuándo consultarlo |
|---|---|
| `CLAUDE.md` / `AGENTS.md` | Siempre: arquitectura, convenciones, deuda conocida |
| [docs/estandares.md] | [antes de definir estructura, naming o patrones] |

## Git

- **Rama base:** `origin/[main | development]` — la usa `/sdd limpiar`.
- **Archivos sensibles del working tree** (avisar que no entren en el commit de la tarea): [`src/environments/**`, `.env*`, …]
- **Rutas de `docs/` ignoradas por git** (se listan a mano al auditar): [ninguna | `docs/**` salvo `docs/contexts/`]

## Planificación

- **Áreas siempre en modo normal:** [autenticación, pagos, … | ninguna]
- **Fuente de los contratos e interfaces:** [solo la spec o lo que indique el usuario | OpenAPI / AsyncAPI en `<ruta>` | esquema en `<ruta>` | se puede leer el repo `<repo>`]
- **Material de referencia:** [cómo consultar diseños o diagramas, p. ej. un MCP de diseño | no aplica]
- **Recetas de exploración** (comandos para mapear el área afectada):

```bash
[find src/<area> -type f | sort]
[grep -rl "<símbolo>" src --include="*.ts"]
```

- **Reglas de arquitectura que el plan debe respetar:** [p. ej. "acceso a datos solo desde repositorios", "todo recurso de nube con tags obligatorios", "migraciones siempre reversibles"]

## Implementación

- **Skills técnicas a cargar en `sdd-ejecucion`:** [p. ej. `angular-development`, `terraform-conventions` | ninguna]

## Verificación

- **Por tarea con cambios** (los que apliquen al stack):

```bash
[npx tsc --noEmit]                 # tipos / compilación   (p. ej. dotnet build, mvn compile, go build ./...)
[npm run lint]                     # lint                  (p. ej. ruff check, golangci-lint run)
[npx jest <rutas-afectadas>]       # tests afectados       (p. ej. pytest <ruta>, dotnet test --filter, go test ./pkg/...)
[terraform validate && terraform plan]  # infraestructura (solo plan; nunca apply sin autorización)
```

- **Buscar tests afectados:** [`find <carpeta> -name "*.spec.ts"` | `find <carpeta> -name "test_*.py"` | …]
- **Verificación global de cierre:** [suite completa y build, p. ej. `npm test && npm run build`]
- **Fallas preexistentes conocidas** (registrar `NOT_RUN` con el motivo, no `FAIL`): [comando → error exacto → motivo | ninguna]
- **Pruebas manuales:** [cómo ejecutar o desplegar para probar: `npm start` → http://localhost:4200 | `docker compose up` + curl | entorno de staging]

### Revisores (subagentes de solo lectura)

| Revisor | Cuándo se ejecuta | Datos que necesita |
|---|---|---|
| [`standards-validator`] | [toda tarea que toca código] | ruta del área, archivos tocados, ruta del contexto, ID de la tarea |
| [`security-reviewer`] | [tareas que tocan autenticación, permisos o datos sensibles] | igual |

Si la tabla no existe o está vacía, `sdd-verificacion` usa su revisor genérico.
