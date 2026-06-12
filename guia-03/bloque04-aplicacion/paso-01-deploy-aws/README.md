# Deploy de aplicaciones a GitHub

## Qué hace este script

`github-action.sh` automatiza la publicación inicial de los 3 microservicios
en GitHub usando SSH, de forma completamente **no-interactiva** y **dinámica**.

## Flujo

1. Obtiene dinámicamente el usuario GitHub autenticado (`gh api user --jq '.login'`)
2. Agrega `github.com` a `known_hosts` para evitar prompts SSH
3. Para cada repositorio (`202601_ep03_db`, `202601_ep03_backend`, `202601_ep03_frontend`):
   - Inicializa git (si no existe `.git`)
   - Configura/actualiza el remote SSH: `git@github.com:$USER/$repo.git`
   - `git add .` + `git commit -m "Deploy inicial"`
   - Detecta si el repo remoto ya existe (`git ls-remote`):
     - Si existe → `git push --force` (reset, pisa el remoto)
     - Si no existe → `git push -u origin main` (primer push)

## Requisitos

- GitHub CLI (`gh`) autenticado con token
- SSH key ed25519 registrada en GitHub (`gh ssh-key add`)
- Código fuente en los directorios correspondientes

## Uso

```bash
cd bloque04-aplicacion/paso-01-deploy-aws
bash github-action.sh
```
