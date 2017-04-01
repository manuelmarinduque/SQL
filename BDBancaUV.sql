/*DEFINICIÓN DE LAS TABLAS EN SQL*/

CREATE TABLE Empleado(
	dniEmp CHAR(4) NOT NULL,
	nomEmp VARCHAR(35) NOT NULL,
	sexEmp CHAR(1) NOT NULL,
	fecNac DATE NOT NULL,
	fecAlt DATE,
	salEmp FLOAT,
	codSuc CHAR(4),
	dirEmp VARCHAR(35),
	PRIMARY KEY (dniEmp),
	FOREIGN KEY (codSuc) REFERENCES Sucursal(codSuc)
);

CREATE TABLE Sucursal (
	codSuc CHAR(4) NOT NULL,
	dirSuc VARCHAR(35),
	telSuc CHAR(7),
	PRIMARY KEY (codSuc)
);

CREATE TABLE Cuenta (
	nroCta CHAR(4) NOT NULL,
	fecAper DATE NOT NULL,
	codSuc CHAR(4),
	PRIMARY KEY (nroCta),
	FOREIGN KEY (codSuc) REFERENCES Sucursal(codSuc)
);

CREATE TABLE Cliente (
	nDICli CHAR(4) NOT NULL,
	nomCli VARCHAR(35) NOT NULL,
	dirCli VARCHAR(35) NOT NULL,
	telCli CHAR(7),
	PRIMARY KEY (nDICli)
);

CREATE TABLE Titular (
	nroCta CHAR(4) NOT NULL,
	nDICli CHAR(4) NOT NULL,
	numOrdTit CHAR(4) NOT NULL,
	PRIMARY KEY (nroCta, nDICli, numOrdTit),
	FOREIGN KEY (nroCta) REFERENCES Cuenta(nroCta),
	FOREIGN KEY (nDICli) REFERENCES Cliente(nDICli)
);

CREATE TABLE Cajero (
	codCaj CHAR(4) NOT NULL,
	tipCaj VARCHAR(15) NOT NULL,
	codSuc CHAR(4),
	PRIMARY KEY (codCaj),
	FOREIGN KEY (codSuc) REFERENCES Sucursal(codSuc)
);

CREATE TABLE Operacion (
	codCaj CHAR(4) NOT NULL,
	fechaOpe DATE NOT NULL,
	horaOpe TIME NOT NULL,
	tipoOpe VARCHAR(15),
	descripcOpe VARCHAR(35),
	vlrOpe FLOAT,
	nroCta CHAR(4) NOT NULL,
	PRIMARY KEY (codCaj, nroCta, fechaOpe, horaOpe),
	FOREIGN KEY (codCaj) REFERENCES Cajero(codCaj),
	FOREIGN KEY (nroCta) REFERENCES Cuenta(nroCta)
);

/*INSERCIÓN DE DATOS*/

INSERT INTO Empleado VALUES (1524, 'Juan David López', 'M', '1994-01-21', '2002-06-14', 724800, 2, 'CL14 #24-30');
INSERT INTO Empleado VALUES (1245, 'Pablo Ramirez', 'M', '1993-06-14', '2001-11-02', 512360, 1, 'CL12 #5-37');
INSERT INTO Empleado VALUES (5415, 'Sara Gutiérrez', 'F', '1963-02-28', '1999-09-06', 896300, 2, 'CL4 #10-24');
INSERT INTO Empleado VALUES (7561, 'Alejandro Pérez', 'M', '1976-04-25', '2003-06-10', 1230560, 3, 'CL8 #12-21');
INSERT INTO Empleado VALUES (0154, 'María Juana', 'F', '1992-11-21', '1997-03-16', 412600, 4, 'CL15 #16-18');
INSERT INTO Empleado VALUES (5420, 'Steven Rodríguez', 'M', '1986-12-01', '1999-05-20', 584200, 4, 'CL20 #20-17');
INSERT INTO Empleado VALUES (8703, 'Camila Caicedo', 'F', '1972-04-30', '2004-11-24', 724800, 4, 'CL26 #24-11');

INSERT INTO Sucursal VALUES (1, 'CL13 #54-21', 2325410);
INSERT INTO Sucursal VALUES (2, 'CL20 #75-63', 2356978);
INSERT INTO Sucursal VALUES (3, 'CL23 #47-56', 2245879);
INSERT INTO Sucursal VALUES (4, 'CL36 #7-12', 2365471);

INSERT INTO Cuenta VALUES (4125, '2006-11-11', 2);
INSERT INTO Cuenta VALUES (7854, '2013-04-17', 2);
INSERT INTO Cuenta VALUES (6547, '2004-06-15', 3);
INSERT INTO Cuenta VALUES (5140, '2009-02-05', 1);
INSERT INTO Cuenta VALUES (4720, '2011-12-21', 4);
INSERT INTO Cuenta VALUES (8514, '2007-10-14', 4);
INSERT INTO Cuenta VALUES (0006, '2012-12-21', 1, 9635000);

INSERT INTO Cliente VALUES (4444, 'Manuel Marín Duque', 'CL17 #1-45', 2301218);
INSERT INTO Cliente VALUES (5415, 'Jorge Alfredo Muñóz', 'CL45 #54-62', 2147859);
INSERT INTO Cliente VALUES (6584, 'Juan del Risco', 'CL12 #63-15', 2154789);
INSERT INTO Cliente VALUES (4120, 'Alejandro Córdoba', 'CL02 #01-20', 2164379);
INSERT INTO Cliente VALUES (7852, 'Alejandra Casanova', 'CL42 #68-24', 2315487);

INSERT INTO Titular VALUES (4125, 4444, 5696);
INSERT INTO Titular VALUES (4125, 5415, 5696);
INSERT INTO Titular VALUES (5140, 4444, 1356);
INSERT INTO Titular VALUES (6547, 6584, 0147);
INSERT INTO Titular VALUES (7854, 6584, 4896);
INSERT INTO Titular VALUES (4720, 4120, 8756);
INSERT INTO Titular VALUES (8514, 7852, 5174);

/*Número de todas las cuentas corrientes (nroCta) de la sucursal número 2 ordenadas por fecha de apertura (fecAbre).*/

SELECT nroCta
FROM Cuenta NATURAL JOIN Sucursal
WHERE codSuc='2';

/*El número de todas las cuentas corrientes del cliente con # documento de identidad 44444444 y el orden de titularidad.*/

SELECT nroCta, numOrdTit
FROM Cuenta NATURAL JOIN Titular NATURAL JOIN Cliente
WHERE nDICli='4444';

/*El número de todas las cuentas corrientes del cliente que se llama Juan del Risco y el orden de titularidad.*/

SELECT nroCta, numOrdTit
FROM Cuenta NATURAL JOIN Titular NATURAL JOIN Cliente
WHERE nomCli='Juan del Risco';

/*El # documento de identidad y nombre de todos los clientes que tienen cuenta en la sucursal número 4, ordenado por nombre.*/

SELECT nDICli, nomCli
FROM Cuenta NATURAL JOIN Sucursal NATURAL JOIN Titular NATURAL JOIN Cliente
WHERE codSuc='4'
ORDER BY nomCli;

/*El saldo de la cuenta número 6.
Como no existe el campo 'saldo' en la relación 'Cuenta', este se agrega: */

ALTER TABLE Cuenta ADD saldo FLOAT;

/*Se actualiza las demás filas debido al nuevo campo agregado: */

UPDATE Cuenta SET saldo=4522100 WHERE nroCta='4125';
UPDATE Cuenta SET saldo=5820300 WHERE nroCta='7854';
UPDATE Cuenta SET saldo=1254000 WHERE nroCta='6547';
UPDATE Cuenta SET saldo=8963000 WHERE nroCta='5140';
UPDATE Cuenta SET saldo=10690200 WHERE nroCta='4720';
UPDATE Cuenta SET saldo=3604000 WHERE nroCta='8514';

/*Saldo de la cuenta número 6*/

SELECT saldo
FROM Cuenta
WHERE nroCta='6';

/*El número y saldo de todas las cuentas de la sucursal número 4.*/

SELECT nroCta, saldo
FROM Cuenta
WHERE codSuc='4';

/*Todas las sucursales (codSuc) y su saldo total (suma de los saldos de todas sus cuentas) ordenado descendentemente por el saldo.*/

SELECT codSuc, SUM (saldo) AS SaldoTotal
FROM Cuenta NATURAL JOIN Sucursal
GROUP BY codSuc
ORDER BY SaldoTotal desc;

/*Todos los clientes (# documento de identidad) junto con el número de cuentas corrientes que tienen; 
pero sólo aquellos clientes que tienen más de una cuenta corriente.*/

SELECT nDICli AS Cliente, COUNT (nroCta) AS CantidadCuentas
FROM Cliente NATURAL JOIN Titular NATURAL JOIN Cuenta
GROUP BY nDICli
HAVING COUNT (nroCta)>1;

/*Todas las cuentas corrientes (nroCta) cuyo saldo sea superior a la media de saldos de la misma sucursal.*/

/*CLAÚSULA WITH
	WITH nombreVista(atributo1, atributo2,..., atributon) AS (SELECT FROM [WHERE])
	(SELECT FROM [WHERE]);*/

WITH MediaSaldos(media) AS (SELECT AVG(saldo) FROM Cuenta)
SELECT nroCta, saldo
FROM Cuenta, MediaSaldos
WHERE saldo>media;

/*Listado de clientes (# documento de identidad y nombre) con el saldo total (suma de saldos) de todas sus cuentas corrientes, ordenado por nombre.*/

SELECT nDICli, nomCli, SUM(saldo) AS SaldoCuenta
FROM Cuenta NATURAL JOIN Titular NATURAL JOIN Cliente
GROUP BY nDICli, nomCli
ORDER BY nomCli;			

/*Extraer un listado de todas las sucursales (codSuc) junto con el número de empleados de dicha sucursal; ordenado por el número de empleados*/

SELECT codSuc, COUNT (dniEmp) AS CantidadEmpleados
FROM Sucursal NATURAL JOIN Empleado
GROUP BY codSuc
ORDER BY CantidadEmpleados;

/*Extraer un listado de todas las sucursales (codSuc) junto con el número de empleados masculinos y el número de empleados femeninos.*/

(SELECT codSuc, COUNT (dniEmp) AS CantidadEmpleados, sexEmp
FROM Sucursal NATURAL JOIN Empleado
GROUP BY codSuc, sexEmp
HAVING sexEmp='M')
UNION
(SELECT codSuc, COUNT (dniEmp) AS CantidadEmpleados, sexEmp
FROM Sucursal NATURAL JOIN Empleado
GROUP BY codSuc, sexEmp
HAVING sexEmp='F')



SELECT * FROM Sucursal
SELECT * FROM Titular
SELECT * FROM Cliente
SELECT * FROM Cuenta