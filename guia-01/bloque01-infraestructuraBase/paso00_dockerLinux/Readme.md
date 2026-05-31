# Docker & Aws Cli

## Ingresar a AWS Academy

Pasos:

1. ingresar a  https://www.awsacademy.com/login
2. Seleccionar LMS
3. Seleccionar un curso que sea de tipo **AWS Academy Learner Lab**
4. Ir a modulos
5. Luego Iniciar el Laboratorio de aprendizaje de AWS Academy
6. Hacer click en "Student View"
7. Luego "Start Lab"
8. Cuando el icono que esta al costado de AWS queda verde ya se puede seguir al paso 9
9. Hacer click en "AWS Details"
10. Hacer click en "Show" de AWS CLI
11. Ahora se debe guardar para los proximos pasos las siguientes variables:

    1. aws_access_key_id
    2. aws_secret_access_key
    3. aws_session_token
    4. AWSAccountId
    5. Region
12. Iniciar Docker Desktop

## Crear imagen:

Se usara una imagen personalizada para ejecutar comandos que windows no nos permite, por tanto operaremos en un contenedor con linux

```
docker build -t devops-eks-lab .
```

## Ejecutar la imagen personalizada

Para iniciar un contenedor a partir de la imagen preparada, y quedar adentro se realiza con el siguiente comando, donde: se deber reemplazar c:... por el path donde estamos operando:

```
docker run -it -v "..":/root/work -v ~/.aws:/root/.aws  -v /var/run/docker.sock:/var/run/docker.sock devops-eks-lab
```

## Ingresar a AWS:

```
aws configure
```

## Ver los stack creados:

```bash
# NOTA: Si los scripts fallan con errores como "^M" o "syntax error",
# es porque los archivos tienen terminaciones CRLF de Windows.
# Ejecuta dentro del contenedor:
fix-crlf
# o el alias:
fixwin
# Esto convierte automaticamente todos los .sh y .yaml a formato Unix.
```

```
aws cloudformation list-stacks --region us-east-1 --query "StackSummaries[?StackStatus!='DELETE_COMPLETE' && contains(StackName, 'laboratorio')].[StackName, StackStatus]"  --output table
```

## Borrar stack completo

```
aws cloudformation delete-stack --stack-name NOMBRE_STACK
```
