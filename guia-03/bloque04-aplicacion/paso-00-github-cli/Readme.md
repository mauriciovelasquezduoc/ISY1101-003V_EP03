# PASO 00 — GitHub CLI: crear repositorios y Secrets desde terminal

## Objetivo

Aprender a usar GitHub CLI (`gh`) para crear repositorios y configurar Secrets desde la terminal, sin tocar la interfaz web de GitHub.

---

# ¿Qué es GitHub CLI?

GitHub CLI (`gh`) es la herramienta oficial de línea de comandos de GitHub. Permite hacer **todo lo que haces en github.com** pero desde la terminal: crear repos, issues, PRs, actions, secrets, etc.

```text
GitHub CLI (gh)
      ↓
   API de GitHub
      ↓
github.com
```

---

# ¿Por qué usar `gh` en vez de la web?

| Interfaz web           | GitHub CLI                |
| ---------------------- | ------------------------- |
| Click por click        | Un comando                |
| No automatizable       | Se puede poner en scripts |
| Manual, lento          | Rápido, repetible        |
| Difícil de documentar | Comandos copiables        |

---

# Requisitos previos

- `gh` instalado (incluido en el Dockerfile del paso 00)
- Cuenta de GitHub
- Autenticación inicial: `gh auth login`

---

# Autenticación

```bash
gh auth login
```

Opciones recomendadas:

```
? What account do you want to log into?
  > GitHub.com

? What is your preferred protocol for Git operations?
  > HTTPS

? Authenticate Git with your GitHub credentials? n
  > Paste an authentication token
```

Se abre el navegador, aceptas, y listo. Verificar:

```bash
gh auth status
```

---

# PARTE 1 — Crear repositorios (manual)

---

# Verificar si un repo existe

```bash
gh repo view NOMBRE_USUARIO/202601_ep03_frontend
```

Si existe, muestra los datos. Si no, da error — eso indica que hay que crearlo.

---

# Crear un repositorio público

```bash
gh repo create 202601_ep03_frontend --public --clone --description "Frontend — Gestor de Alumnos"
```

Parámetros:

| Flag              | Significado                                    |
| ----------------- | ---------------------------------------------- |
| `--public`      | Repositorio público (visible para todos)      |
| `--private`     | Repositorio privado (solo tú y colaboradores) |
| `--clone`       | Clonarlo localmente después de crearlo        |
| `--description` | Descripción del repo                          |

---

# Crear los 3 repositorios

```bash
gh repo create 202601_ep03_frontend --public --clone --description "Frontend — Gestor de Alumnos EKS"
gh repo create 202601_ep03_backend  --public --clone --description "Backend — API Gestor de Alumnos EKS"
gh repo create 202601_ep03_db       --public --clone --description "Base de datos — Gestor de Alumnos EKS"
```

> Si el repo ya existe, `gh` mostrará un error. Puedes ignorarlo o verificar antes con `gh repo view`.

---

# Agregar colaborador admin a cada repo

```bash
REPO="NOMBRE_USUARIO/202601_ep03_frontend"
COLLAB="mauriciovelasquezduoc"

gh api \
  -X PUT \
  "/repos/$REPO/collaborators/$COLLAB" \
  -f permission=admin
```

> Repetir para `202601_ep03_backend` y `202601_ep03_db`. El colaborador recibe una invitación que debe aceptar.

---

# PARTE 2 — Configurar Secrets (manual)

---

# Listar Secrets existentes en un repo

```bash
gh secret list --repo NOMBRE_USUARIO/202601_ep03_frontend
```

---

# Crear un Secret

```bash
echo "AKIAIOSFODNN7EXAMPLE" | gh secret set AWS_ACCESS_KEY_ID --repo NOMBRE_USUARIO/202601_ep03_frontend
```

> El pipe `echo "valor" | gh secret set` evita que el valor quede en el historial de comandos.

---

# Actualizar un Secret existente

Mismo comando. GitHub CLI sobrescribe automáticamente:

```bash
echo "NUEVO_VALOR" | gh secret set AWS_ACCESS_KEY_ID --repo NOMBRE_USUARIO/202601_ep03_frontend
```

---

# Crear los 6 Secrets en cada repo

Repetir para los 3 repositorios. Ejemplo para `202601_ep03_frontend`:

```bash
REPO="NOMBRE_USUARIO/202601_ep03_frontend"

echo "TU_ACCESS_KEY"        | gh secret set AWS_ACCESS_KEY_ID     --repo "$REPO"
echo "us-east-1"            | gh secret set AWS_REGION            --repo "$REPO"
echo "TU_SECRET_KEY"        | gh secret set AWS_SECRET_ACCESS_KEY --repo "$REPO"
echo "TU_SESSION_TOKEN"     | gh secret set AWS_SESSION_TOKEN     --repo "$REPO"
echo "TU_SNYK_TOKEN"        | gh secret set SNYK_TOKEN            --repo "$REPO"
echo "TU_SONAR_TOKEN"       | gh secret set SONAR_TOKEN           --repo "$REPO"
```

> Repetir para `202601_ep03_backend` y `202601_ep03_db`.

---

# PARTE 3 — Ver lo creado (manual)

---

# Listar todos los repositorios

```bash
gh repo list NOMBRE_USUARIO --limit 10
```

---

# Ver detalle de un repo

```bash
gh repo view NOMBRE_USUARIO/202601_ep03_frontend
```

Salida:

```
Name:   202601_ep03_frontend
Owner:  NOMBRE_USUARIO
Visibility: public
URL:    https://github.com/NOMBRE_USUARIO/202601_ep03_frontend
```

---

# Listar Secrets de un repo

```bash
gh secret list --repo NOMBRE_USUARIO/202601_ep03_frontend
```

Salida:

```
NAME                   UPDATED
AWS_ACCESS_KEY_ID      2026-06-02
AWS_REGION             2026-06-02
AWS_SECRET_ACCESS_KEY  2026-06-02
AWS_SESSION_TOKEN      2026-06-02
SNYK_TOKEN             2026-06-02
SONAR_TOKEN            2026-06-02
```

---

# Resumen de comandos manuales

Para crear los 3 repos, agregar un colaborador admin a cada uno y crear 18 Secrets (6 por repo), necesitarías ejecutar:

| Acción                   | Comandos                                      |
| ------------------------- | --------------------------------------------- |
| Crear 3 repos públicos   | 3 x `gh repo create`                        |
| Agregar colaborador admin | 3 x `gh api PUT /collaborators`             |
| Crear 18 Secrets          | 18 x `gh secret set`                        |
| Verificar                 | 3 x `gh repo view` + 3 x `gh secret list` |
| **Total mínimo**   | **30 comandos**                         |

---

# Automatización con script

En vez de 30 comandos manuales, usa el script que lo hace todo de una vez:

```bash
bash crear-repos-y-secrets.sh
```

El script tiene **4 partes**:

| Parte             | ¿Qué hace?                                                                                                                                                                                                                                                                                                      |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Parte 1** | Crea los 3 repos públicos (`202601_ep03_frontend`, `202601_ep03_backend`, `202601_ep03_db`). Si ya existen, continúa sin error. Agrega a `mauriciovelasquezduoc` como admin en cada uno.                                                                                                                |
| **Parte 2** | Pide interactivamente los 6 Secrets**una sola vez** (`AWS_ACCESS_KEY_ID`, `AWS_REGION`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`, `SNYK_TOKEN`, `SONAR_TOKEN`). Si dejas un valor vacío, ese secreto se omite. Muestra un resumen de lo ingresado y pide confirmación antes de continuar. |
| **Parte 3** | Aplica los 6 secretos a cada uno de los 3 repositorios automáticamente.                                                                                                                                                                                                                                          |
| **Parte 4** | Muestra un resumen con las URLs de los 3 repos, el estado de todos los Secrets, y los enlaces directos a la página de Secrets en GitHub.                                                                                                                                                                         |

---

# Resultado esperado

Al ejecutar el script:

```text
=========================================
 CREACIÓN DE REPOSITORIOS Y SECRETS EN GITHUB
=========================================

>>> Sesión activa: NOMBRE_USUARIO

=========================================
 PARTE 1 — REPOSITORIOS
=========================================

>>> Procesando: NOMBRE_USUARIO/202601_ep03_frontend
    Creando repositorio...
    Agregando colaborador admin: mauriciovelasquezduoc
    ✔ mauriciovelasquezduoc agregado como admin
>>> Procesando: NOMBRE_USUARIO/202601_ep03_backend
    Creando repositorio...
    Agregando colaborador admin: mauriciovelasquezduoc
    ✔ mauriciovelasquezduoc agregado como admin
>>> Procesando: NOMBRE_USUARIO/202601_ep03_db
    Creando repositorio...
    Agregando colaborador admin: mauriciovelasquezduoc
    ✔ mauriciovelasquezduoc agregado como admin

=========================================
 PARTE 2 — INGRESO DE SECRETOS (una vez para todos los repos)
=========================================

A continuación ingresa los 6 secretos.
Se aplicarán automáticamente a los 3 repositorios.
Si dejas un valor vacío, ese secreto no se configurará.

─────────────────────────────────────────
  Ingresa el valor para AWS_ACCESS_KEY_ID: ********
  ✔ Valor registrado (20 caracteres)

─────────────────────────────────────────
  Ingresa el valor para AWS_REGION: ********
  ✔ Valor registrado (9 caracteres)

  ... (los 6 Secrets)

=========================================
 RESUMEN DE SECRETOS A CONFIGURAR
=========================================

  AWS_ACCESS_KEY_ID             ✔ (20 caracteres)
  AWS_REGION                    ✔ (9 caracteres)
  ... (los 6 Secrets)

¿Aplicar estos secretos a los 3 repositorios? (s/n): s

=========================================
 PARTE 3 — APLICANDO SECRETOS A CADA REPOSITORIO
=========================================

>>> Repositorio: NOMBRE_USUARIO/202601_ep03_frontend
─────────────────────────────────────────
  [AWS_ACCESS_KEY_ID] configurando... ✔
  [AWS_REGION] configurando... ✔
  ... (los 6 Secrets)

  (se repite para los otros 2 repos)

=========================================
 PARTE 4 — RESUMEN DE LO CREADO
=========================================

Repositorios:
-------------
  202601_ep03_frontend   https://github.com/NOMBRE_USUARIO/202601_ep03_frontend
  202601_ep03_backend    https://github.com/NOMBRE_USUARIO/202601_ep03_backend
  202601_ep03_db         https://github.com/NOMBRE_USUARIO/202601_ep03_db

Secrets configurados en cada repositorio:
----------------------------------------

  [202601_ep03_frontend]
  https://github.com/NOMBRE_USUARIO/202601_ep03_frontend/settings/secrets/actions
    AWS_ACCESS_KEY_ID         actualizado: 2026-06-02
    AWS_REGION                actualizado: 2026-06-02
    AWS_SECRET_ACCESS_KEY     actualizado: 2026-06-02
    AWS_SESSION_TOKEN         actualizado: 2026-06-02
    SNYK_TOKEN                actualizado: 2026-06-02
    SONAR_TOKEN               actualizado: 2026-06-02
  ...
```

---

# Notas de seguridad

- Los Secrets **no se muestran** ni en logs ni en `gh secret list` — solo se ve su nombre y fecha de actualización.
- El script usa `read -s` para que el valor no aparezca en pantalla mientras se escribe.
- Los valores viajan cifrados a GitHub y se almacenan cifrados.
- Si necesitas actualizar credenciales de AWS Academy, vuelve a ejecutar el script y solo ingresa valor en los 3 que cambiaron (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`).

---

# Siguiente paso

```text
Paso 01 — Conectar los repositorios al pipeline CI/CD y desplegar en EKS.
```
