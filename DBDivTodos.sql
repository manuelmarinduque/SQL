/*CREACIÓN DE TABLAS*/

CREATE TABLE Asignatura (
	codA CHAR(4) NOT NULL,
	nombreA VARCHAR(35) NOT NULL,
	precio INTEGER,
	PRIMARY KEY (codA)
);

CREATE TABLE  Alumnos (
	nAlum CHAR(4) NOT NULL,
	nombre VARCHAR(35) NOT NULL,
	Apellidos VARCHAR(35) NOT NULL,
	PRIMARY KEY (nAlum)
);

CREATE TABLE Notas (
	nAlum CHAR(4) NOT NULL,
	codA CHAR(4) NOT NULL,
	nota FLOAT,
	PRIMARY KEY (codA, nAlum),
	FOREIGN KEY (nAlum) REFERENCES Alumnos(nAlum) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (codA) REFERENCES Asignatura(codA) ON DELETE CASCADE ON UPDATE CASCADE
);

/*INSERCIÓN DE DATOS*/

INSERT INTO Asignatura VALUES (1, 'Programación', 94500);
INSERT INTO Asignatura VALUES (2, 'Dibujo', 28000);
INSERT INTO Asignatura VALUES (3, 'Inglés', 37500); 

INSERT INTO Alumnos VALUES (0338, 'Ana', 'Pérez Gómez');
INSERT INTO Alumnos VALUES (0254, 'Rosa', 'López López');
INSERT INTO Alumnos VALUES (0168, 'Juan', 'Aguilar Palomino');

INSERT INTO Notas VALUES (0338, 1, 3.6);
INSERT INTO Notas VALUES (0254, 1, 2.8);
INSERT INTO Notas VALUES (0168, 2, 4.9);
INSERT INTO Notas VALUES (0338, 2, 2.5);
INSERT INTO Notas VALUES (0338, 3, 5.0);
INSERT INTO Notas VALUES (0254, 2, 4.1);
INSERT INTO Notas VALUES (0168, 1, 3.3);
INSERT INTO Notas VALUES (0168, 3, 1.9);

SELECT * FROM Asignatura;
SELECT * FROM Alumnos;
SELECT * FROM Notas;

/*OBTENER LOS ALUMNOS QUE TENGAN NOTA EN TODAS LAS ASIGNATURAS (revisar página 97 del libro de 'Fundamentos de bases de datos'*/

SELECT nombre
FROM Alumnos AS N
WHERE NOT EXISTS 
	((SELECT codA
	FROM Asignatura)
	EXCEPT
	(SELECT codA
	FROM Notas AS R
	WHERE N.nAlum = R.nAlum));

/*MODIFICACIONES A LA BASE DE DATOS. RESTRICCIONES DE INTEGRIDAD REFERENCIAL EN CASACADA*/

/*ACTUALIZACIÓN DE UN DATO DE UNA TABLA, DATO EL CUAL ES LLAVE FORÁNEA DE UNA RELACIÓN EXTERNA (permitido por el ON UPDATE CASCADE definido previamente)*/
/*Los cambios serán aplicados tanto a la relación Alumno como a la relación Notas*/

UPDATE Alumnos
SET nAlum = '0147'
WHERE nombre = 'Juan';

/*SUBCONSULTAS CORELACIONADAS O SINCRONIZADAS*/
/*Obtener el nombre de los alumnos, la asignatura del mismo y la nota cuya nota supera la media de las notas de su asignatura*/

SELECT nombre, nombreA, nota
FROM Alumnos NATURAL JOIN Notas AS N NATURAL JOIN Asignatura AS A	/*MUY IMPORTANTE LOS ALIAS*/
WHERE N.nota > (SELECT AVG (nota)
		FROM Asignatura AS B NATURAL JOIN Notas
		WHERE B.nombreA = A.nombreA);

/*Obtener el nombre, apellido y la cantidad de asignaturas matriculadas de aquellos estudiantes que tienen más de 2 materias matriculadas*/

SELECT nombre, apellidos, COUNT(codA) AS materiasMatriculadas
FROM Alumnos NATURAL JOIN Notas NATURAL JOIN Asignatura
--ORDER BY nombre, apellidos (GROUP BY agrupa y deja implíctos los demás valores por fuera de la agrupación)
GROUP BY nombre, apellidos
HAVING COUNT(codA)>2;

/*Obtener la cantidad de alumnos matriculados a cada asignatura*/

SELECT nombreA, COUNT(nombre)
FROM Alumnos NATURAL JOIN Notas NATURAL JOIN Asignatura
GROUP BY nombreA