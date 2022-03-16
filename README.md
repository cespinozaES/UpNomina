# UpNomina
UpNomina es un software de cargue de archivos planos encargado de la comunicacion entre un proveedor de nomina y uno de contabilidad, la funcion principal del programa es ser un puente de comunicacion, recibiendo los archivos generados por el proveedor de nomina, Encabezado.csv y Detalles.csv, estos archivos se validan y se procesan enviandose a un Web Service de Contabilidad, logrando de esta forma automatizar el proceso de cargue de archivos entre los dos servidores y permitiendo la comunicacion entre ellos.

## Instalación para Usuarios

Es necesario descargar el repositorio en la opción Code/Download ZIP, pero solo se usara la carpeta Win32/Release, en esta carpeta se encuentra el archivo ejecutable UpNomina.exe y también se encuentra la base de datos, es necesario aclarar que para poder ejecutar el software sin problema debemos tener la base de datos siempre en la misma carpeta donde se encuentra el ejecutable .exe


## Instalación para Pruebas y Mantenimiento

```bash
git clone https://github.com/cespinozaES/UpNomina.git
```
Luego de clonar el repositorio agregamos la ruta de la base de datos al modulo de conexión llamado fdConexion que se encuentra en la unidad udbModulo.pas de la siguiente manera:

Abrimos la conexión con doble clic al modulo fdConexion y en la propiedad Database agragamos la ruta donde se encuentra la base de datos UpNomina.exe, de esta forma tendremos la conexión a la base de datos sin necesidad de tenerla en la carpeta junto al ejecutable .exe.
![conexionbd](https://user-images.githubusercontent.com/100435479/158600570-c420c8fd-d0b2-4071-b973-e8d368604d3a.png)



## Manejo del Software
Para el uso correcto del aplicativo se debe tener en cuenta los archivos CSV y todas sus restricciones, cada archivo tiene una cantidad especifica de Columnas y Encabezados, se debe tener en cuenta que la cantidad de filas del archivo detalle es dependiente de la columna COMULTCOS del archivo encabezado, como se muestra en la imagen: 
### Encabezado.CSV
![encabezado](https://user-images.githubusercontent.com/100435479/158603995-0db4ece9-8f51-48ee-8f9b-0add1292da33.jpg)

### Detalles.CSV
![Detalle](https://user-images.githubusercontent.com/100435479/158604016-00284064-d764-42af-bf59-23648cae0b6b.jpg)


## Pruebas
