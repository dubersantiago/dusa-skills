# Configuración del flujo de trabajo — AtlantisNEXUS MS-Frontend

## Documentos de referencia

| Archivo | Cuándo consultarlo |
|---|---|
| `CLAUDE.md` | Siempre: arquitectura, convenciones, deuda conocida, regla de resolución de conflictos |
| `docs/angular-standards.md` | Antes de definir estructura de carpetas, servicios de API, patrones o naming. Sección 4f (R1–R12) |
| `docs/Ui-Library.md` | Antes de usar cualquier componente de `@SyH-Soluciones-informaticas-integrales/uicomponents` |
| `docs/briefs/*.brief.md` | Brief funcional de un trabajo |

## Git

- **Rama base:** `origin/development`
- **Archivos sensibles del working tree:** `src/assets/config.json`, `src/environments/**` (suelen tener hosts locales)
- **Rutas de `docs/` ignoradas por git:** todo `docs/` salvo `docs/contexts/` y `docs/angular-standards.md`

## Planificación

- **Áreas siempre en modo normal:** autenticación, identidad y vinculación.
- **Fuente de los contratos e interfaces:** solo el brief o lo que indique el usuario. No se leen los repos backend ni se usa ningún MCP del backend. Convención de nombres: MS-Vinculacion y MS-Parametricas usan camelCase; MS-Libranzas y servicios externos usan snake_case y requieren mapper. URLs siempre vía el proxy `api.<micro>('/ruta')` de `src/app/core/utils/api.ts`.
- **Diseño:** si el brief trae link de Figma, consultar Figma MCP para el microcopy y los estados visuales.
- **Recetas de exploración** (feature existente):

```bash
find src/app/modules/vinculaciones/features/<feature> -type f | sort
grep -rl "signalStore" src/app/modules/vinculaciones/features/<feature> --include="*.ts"
grep -rl "createActionGroup\|createReducer\|createEffect" src/app/modules/vinculaciones/features/<feature> --include="*.ts"
find src/app/modules/vinculaciones/features/<feature> -name "*.spec.ts"
grep -rl "features/<feature>" src/app --include="*.ts"
```

- **Reglas de arquitectura que el plan debe respetar:**
  - Estado solo con `signalStore` + `rxMethod`, provisionado en la ruta del feature. NgRx clásico prohibido.
  - Servicios HTTP solo en `src/app/shared/services/ms<micro>/<recurso>/` (o `identity/<recurso>/`), nunca en el módulo. Buscar reutilizables en `@core/utils`, `src/app/shared/services/` y `common/` antes de crear.

## Implementación

- **Skills técnicas a cargar en `sdd-ejecucion`:** `angular-development`

## Verificación

- **Por tarea con cambios:**

```bash
npx tsc --noEmit -p tsconfig.app.json     # tipos de la app
npx tsc --noEmit -p tsconfig.spec.json    # tipos de los specs, si se tocaron specs
npx jest <rutas-afectadas> --no-coverage  # specs nuevos y afectados
```

- **Buscar tests afectados:** `find <carpeta-del-feature> -name "*.spec.ts"` y `grep -rl "<feature>/\|<Símbolo>" src/app --include="*.spec.ts"`
- **Verificación global de cierre:** `npx jest`, `npm run build`
- **Fallas preexistentes conocidas:** `npx tsc --noEmit -p tsconfig.spec.json` → TS5103 en `tsconfig.spec.json` (config preexistente): `NOT_RUN`. Cualquier otro error es `FAIL`.
- **Pruebas manuales:** `npm start` → http://localhost:4200

### Revisores (subagentes de solo lectura)

| Revisor | Cuándo se ejecuta | Datos que necesita |
|---|---|---|
| `standards-validator` | Toda tarea que crea o modifica `.ts`, `.html` o `.css` bajo `src/` | ruta del feature, archivos tocados, ruta del contexto, ID de la tarea (modo tarea) |
| `ui-reviewer` | Tareas que tocan pages, componentes, templates, estilos o el store/facade que los alimenta | igual |
