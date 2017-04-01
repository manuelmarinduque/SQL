/*PARA CREAR UNA TABLA EN SQL:

CREATE TABLE [nombre de la tabla](
[nombre del atributo] [tipo] [opciones], 
[nombre del atributo] [tipo] [opciones], 
[nombre del atributo] [tipo] [opciones], 
[otras columnas. . . . . . . . ]
); */

/*Donde [opciones] puede ser: NOT NULL, UNIQUE, DEFAULT o PRIMARY KEY*/

CREATE TABLE Asignatura ( 
codA CHAR(4) NOT NULL,
nombreA VARCHAR (50) NOT NULL,
precio FLOAT NOT NULL,
depto VARCHAR(12),
PRIMARY KEY (codA)
);

CREATE TABLE Alumno (
nAlum VARCHAR(4) NOT NULL,
nombre VARCHAR(20) NOT NULL,
apellido VARCHAR(20) NOT NULL,
direccion VARCHAR(30),
telefono VARCHAR(12),
PRIMARY KEY (nAlum)
);

/*DECLARACIÓN DE LAS LLAVES:

LLAVEPRIMARIA:
PRIMARY KEY (ATRIBUTO1, ATRIBUTO2,..., ATRIBUTON)

LLAVE FORÁNEA:
FOREIGN KEY (ATRIBUTO_A_RELACIONAR) REFERENCES NOMBRE_TABLA_A_RELACIONAR (ATRIBUTO_A_RELACIONAR)
*/

CREATE TABLE Notas (
nAlum VARCHAR(4) NOT NULL,
codA CHAR(4) NOT NULL,
fecha DATE,
nota DECIMAL(4,1),
PRIMARY KEY (nAlum, codA),
FOREIGN KEY (nAlum) REFERENCES Alumno (nAlum),
FOREIGN KEY (codA) REFERENCES Asignatura (codA)
);

/*PARA VER LA COMPOSICIÓN DE UNA TABLA:

SELECT table_name, column_name, udt_name
FROM information_schema.columns
WHERE table_name = 'NOMBRE_TABLA';
*/

SELECT table_name, column_name, udt_name
FROM information_schema.columns
WHERE table_name = 'Asignatura';

/*INSERCIÓN DE DATOS:

INSERT INTO nombre_de_la_tabla ( atributos_a_insertar ) VALUES ( valores_a_insertar );

La cláusula (atributos_a_insertar) es opcional, solo se usa cuando los atributos a los que se le va a insertar 
valores no son todos los atributos de la tabla o no se recuerda el orden.
*/

INSERT INTO Asignatura (codA, nombreA, precio) VALUES (1, 'Programacion', 91500);
INSERT INTO Asignatura VALUES (2, 'Dibujo', 28000, 'Diseño');
INSERT INTO Asignatura VALUES (3, 'Inglés', 30000, 'Lenguas');
INSERT INTO Asignatura (codA, nombreA, precio) VALUES (4, 'Bases de datos', 90300);
INSERT INTO Asignatura VALUES (5, 'Sistemas Operativos', 87500, 'Informática');
INSERT INTO Asignatura VALUES (6, 'Cálculo III', 86000, 'Matemáticas');
INSERT INTO Asignatura (codA, nombreA, precio) VALUES (7, 'Matemáticas discretas', 84700);
INSERT INTO Asignatura VALUES (8, 'Arquitectura de computadores', 95100, 'Informática');
INSERT INTO Asignatura VALUES (9, 'Desarrollo de software', 94500, 'Informática');
INSERT INTO Asignatura VALUES (10, 'Historia del arte', 28000, 'Diseño');
INSERT INTO Asignatura VALUES (11, 'Español', 26000, 'Lenguas');
INSERT INTO Asignatura (codA, nombreA, precio) VALUES (12, 'Redes informáticas', 115300);
INSERT INTO Asignatura (codA, nombreA, precio) VALUES (13, 'Matemáticas discretas II', 114700);
INSERT INTO Asignatura VALUES (14, 'Análisis de algoritmos', 91200, 'Sistemas');

INSERT INTO Alumno VALUES (0338, 'Ana', 'Pérez Gómez', 'CL23 #9-60', '92478596');
INSERT INTO Alumno VALUES (0254, 'Rosa', 'López López', 'C5 #45-10', '92458796');
INSERT INTO Alumno (nAlum, nombre, apellido, direccion) VALUES (0168, 'Juan', 'García García', 'T22 #7-98');
INSERT INTO Alumno VALUES (1111, 'Victor', 'Marín Duque', 'CL24 #45-97', '92547897');
INSERT INTO Alumno (nAlum, nombre, apellido, telefono) VALUES (1569, 'Juan', 'Caicedo Duque', '92654132');
INSERT INTO Alumno VALUES (7895, 'Camilo', 'Pérez Pupiales', 'CL23 #36-78', '92478630');
INSERT INTO Alumno VALUES (2546, 'Manuel', 'Díaz Gómez', 'CL17 #14-63', '93647810');
INSERT INTO Alumno (nAlum, nombre, apellido) VALUES (4520, 'Alejandro', 'Díaz Marín');
INSERT INTO Alumno VALUES (0230, 'Cristian', 'Salcedo Gutierrez', 'CL14 #47-69', '94587123');
INSERT INTO Alumno VALUES (1547, 'Andres', 'Loiaza Henao', 'CL27 #16-27', '94782013');
INSERT INTO Alumno VALUES (2000, 'Felipe', 'González López', 'CL12 #87-61', '91654723');

INSERT INTO Notas VALUES (0338, 1, '2013-02-02', 3.6);
INSERT INTO Notas VALUES (0254, 2, '2013-02-02', 2.8);
INSERT INTO Notas VALUES (0168, 2, '2013-02-02', 1.3);
INSERT INTO Notas VALUES (0338, 2, '2013-02-02', 3.5);
INSERT INTO Notas VALUES (0338, 3, '2013-06-02', 5.0);
INSERT INTO Notas VALUES (0254, 1, '2013-06-02', 4.6);
INSERT INTO Notas VALUES (0168, 1, '2013-06-02', 3.8);
INSERT INTO Notas VALUES (0168, 3, '2013-06-02', 2.9);
INSERT INTO Notas VALUES (7895, 5, '2013-07-03', 4.3);
INSERT INTO Notas VALUES (1111, 6, '2013-07-03', 5.0);
INSERT INTO Notas VALUES (1547, 4, '2012-03-15', 4.0);
INSERT INTO Notas VALUES (2546, 14, '2012-01-15', 2.0);
INSERT INTO Notas VALUES (1547, 14, '2012-03-15', 4.1);


/*ESTRUCTURA DE UNA CONSULTA:

SELECT [Lista de atributos a seleccionar]
FROM [nombre de las tablas que contienen los datos]
WHERE [restricciones aplicadas a la consulta];
*/

/*Obtener el nombre y su departamento de la asignatura que tiene el código igual a 2. */

SELECT nombreA, depto
FROM Asignatura
WHERE codA='2'; /*COMO ES codA ES CHAR VA ENTRE COMILLAS SIMPLES*/

/*Obtener nombre, apellido y dirección de los alumnos con número de alumno igual a 0254.*/

SELECT nombre, apellido, direccion
FROM Alumno
WHERE nAlum='254';

/*Obtener el nombre del alumno y nombre de la asignatura en la que obtuvo nota aprobatoria de la materia (mayor a 3.0).*/

SELECT nombre, nombreA
FROM Alumno NATURAL JOIN Notas NATURAL JOIN Asignatura
WHERE nota>=3.0;

/*Obtener el nombre del alumno matriculado en Junio 2 de 2013.*/

SELECT nombre
FROM Alumno NATURAL JOIN Notas
WHERE fecha='2013-06-02';

/*Obtener el nombre de las asignaturas del departamento de Lenguas.*/

SELECT nombreA
FROM Asignatura
WHERE depto='Lenguas';

/*Permite la eliminación de una o más filas de una tabla, y su sintaxis es la siguiente:
DELETE FROM [nombre de la tabla]
WHERE [condiciones para el borrado];
*/

/*Permite modificar los valores de las columnas en una o más filas de una tabla, su sintaxis de uso es:
UPDATE [nombre de la tabla]
SET [atributo a cambiar = nuevo valor, atributo a cambiar = nuevo valor,...]
WHERE [condición para ejecutar la actualización];
*/

/*Modificar el departamento de la Asignatura codA = 5 a ‘Sistemas’*/

UPDATE Asignatura
SET depto = 'Sistemas'
WHERE codA='5';

/*Modificar la dirección del alumno con nAlum 2000 a ‘Dg32 #12-87’*/

UPDATE Alumno
SET direccion = 'Dg32 #12-87'
WHERE nAlum='2000';

/*Eliminar las notas que se hayan obtenido antes del año 2013*/

DELETE FROM Notas
WHERE fecha<'2013-01-01';

/*Borrar las asignaturas que tengan un precio superior a $100.000*/

DELETE FROM Asignatura
WHERE precio>100000;

/*En algunos de los atributos aparece el modificador NOT NULL, investigue qué significa y de un ejemplo de una 
tupla que no puede ser insertada en la tabla Alumno por la existencia del NOT NULL.

NOT NULL es una restricción que sirve para especificar que una columna no acepta el valor NULL, es decir, que 
esa columna siempre tiene que tener algún valor, no puede estar vacía.

Un ejemplo de tupla que no puede ser insertada sería la siguiente:
INSERT INTO Asignatura (nombreA, precio, depto) VALUES ('Matemáticas discretas', 84700, 'Informática');
No puede ser insertada porque no se está especificando el valor del atributo codA, el cual tiene restricción NOT NULL.
*/

/*Trate de insertar la siguiente tupla en la tabla Asignatura:
INSERT INTO Asignatura VALUES (1, 'Programación Avanzada', 99000, 'Sistemas')
A qué se debe el mensaje de error que aparece?

El mensaje de error que aparece hace referencia a la integridad de identidad, el cual establece que una llave primaria no puede ser duplicada o ser NULL.
*/

/*Realice una consulta con cada una de las funciones agregadas del SQL.*/

/*SUM - Obtener el precio total que paga cada estudiante por cada departamento */

SELECT depto, SUM (precio)
FROM Asignatura
GROUP BY depto;

/*CONT - Contar la cantidad de alumnos que se llamen 'Juan' */

SELECT nombre, COUNT (nombre)
FROM Alumno
GROUP BY nombre
HAVING nombre='Juan';

/*MAX - Obtener el nombre y el precio de la materia con el mayor precio */

SELECT nombreA, PrecioMayor
FROM 	(SELECT MAX(Precio) AS PrecioMayor
	FROM Asignatura) AS P
	INNER JOIN Asignatura ON (Asignatura.precio=P.PrecioMayor);

/*MIN - Obtener el nombre de la materia y el nombre del alumno con la menor (peor) nota */

SELECT nombre, nombreA, NotaMenor
FROM 	Notas NATURAL JOIN Asignatura NATURAL JOIN Alumno INNER JOIN 
	(SELECT MIN(nota) AS NotaMenor
	FROM Notas) AS P
	ON (Notas.nota=P.NotaMenor);

/*AVG - Hallar el promedio de notas de los alumnos en el año 2013*/

SELECT AVG(nota)
FROM Notas
WHERE fecha between '2013-01-01' and '2013-12-31';

/*AVG - Hallar el nombre de los alumnos con promedio de notas mayores a 3 en el año 2013*/

SELECT nAlum, AVG(nota)
FROM Alumno NATURAL JOIN Notas
WHERE fecha between '2013-01-01' and '2013-12-31'	/*Condición general*/
GROUP BY nAlum
HAVING AVG (nota)>3.0; 					/*Condición específica para cada grupo*/

/*Por medio de una subconsulta, obtenga el nombre y departamento de las asignaturas que han sido aprobadas durante el año 2013.*/

SELECT nombreA, depto 
FROM Asignatura NATURAL JOIN Notas
WHERE nota IN 	(SELECT nota
		FROM Notas
		WHERE nota>3.0 and fecha between '2013-01-01' and '2013-12-31');

/*Usando subconsultas, obtenga la información de los alumnos que han aprobado asignaturas pertenecientes al departamento de ‘Sistemas’.*/

SELECT *
FROM Alumno NATURAL JOIN Notas NATURAL JOIN Asignatura
WHERE nota IN	(SELECT nota
		FROM Notas
		WHERE nota>3) 
		and depto='Sistemas';

/*Usando subconsultas, obtenga la información de los alumnos que han obtenido una nota superior al promedio de notas del año 2013.*/

SELECT *
FROM Alumno NATURAL JOIN Notas
WHERE nota>	(SELECT AVG(nota)
		FROM Notas
		WHERE fecha between '2013-01-01' and '2013-12-31');

/*Cree una vista de las asignaturas, con el nombreA y depto, del departamento de Sistemas, llámela ViewAsignaturasSmas.*/

CREATE VIEW ViewAsignaturasSmas AS 
	SELECT nombreA, depto
	FROM Asignatura
	WHERE depto='Sistemas';

SELECT * FROM ViewAsignaturasSmas

/*Cree una vista de los alumnos que contenga el nAlum, el nombre, el apellido y el teléfono. Asígnele VistaAlumno como nombre a la vista.*/

CREATE VIEW VistaAlumno AS
	SELECT nAlum, nombre, apellido, telefono
	FROM Alumno;

SELECT * FROM VistaAlumno

SELECT * FROM ASIGNATURA
SELECT * FROM NOTAS
SELECT * FROM ALUMNO