/*CREACIÓN DE TABLAS*/

CREATE TABLE Aeropuerto (
	codAeropto CHAR(4) NOT NULL,
	nombrAeropto VARCHAR(25) NOT NULL,
	ciudadNro CHAR(4) NOT NULL,
	longitudPista FLOAT,
	PRIMARY KEY (codAeropto),
	FOREIGN KEY (ciudadNro) REFERENCES Ciudad(ciudadNro)
);

CREATE TABLE Ciudad (
	ciudadNro CHAR(4) NOT NULL,
	nombreCiu VARCHAR(25) NOT NULL, 
	dptoCiud VARCHAR(25),
	paisCiu VARCHAR(25) NOT NULL,
	PRIMARY KEY (ciudadNro)
);

CREATE TABLE Vuelo (
	nroVuelo CHAR(4) NOT NULL,
	codAeroptoSale CHAR(4) NOT NULL,
	duracionVuelo TIME NOT NULL,
	codAeroptoLlega CHAR(4) NOT NULL,
	PRIMARY KEY (nroVuelo),
	FOREIGN KEY (codAeroptoSale) REFERENCES Aeropuerto(codAeropto),
	FOREIGN KEY (codAeroptoLlega) REFERENCES Aeropuerto(codAeropto)
);

CREATE TABLE ProgramaVuelo (
	nroVuelo CHAR(4) NOT NULL,
	fecha DATE NOT NULL,
	idAvion CHAR(4) NOT NULL,
	horaSalida TIME NOT NULL,
	duracion TIME NOT NULL,
	PRIMARY KEY (nroVuelo, fecha, horaSalida),
	FOREIGN KEY (nroVuelo) REFERENCES Vuelo(nroVuelo),
	FOREIGN KEY (idAvion) REFERENCES Avion(idAvion)
);

CREATE TABLE Avion (
	idAvion CHAR(4) NOT NULL,
	totalAsientos INTEGER,
	tipoAvi VARCHAR(25) NOT NULL,
	PRIMARY KEY (idAvion),
	FOREIGN KEY (tipoAvi) REFERENCES TipoAvion(tipoAvi)
);

CREATE TABLE TipoAvion (
	tipoAvi VARCHAR(25) NOT NULL,
	cupoMax INTEGER,
	fabricante VARCHAR(25) NOT NULL,
	longPista FLOAT,
	PRIMARY KEY (tipoAvi)
);

/*INSERCIÓN DE DATOS*/

INSERT INTO Aeropuerto VALUES (5184, 'A.I Teniente L.Candelaria', 4871, 1200);
INSERT INTO Aeropuerto VALUES (1840, 'Aeroclub Río de la Plata', 2315, 800);
INSERT INTO Aeropuerto VALUES (8215, 'Aeropuerto de Bolívar', 6510, 1200);
INSERT INTO Aeropuerto VALUES (0256, 'Rodríguez Ballón', 8412, 1000);
INSERT INTO Aeropuerto VALUES (2401, 'El Dorado', 5148, 1200);
INSERT INTO Aeropuerto VALUES (8720, 'A. Alfredo Mendívil', 5464, 800);

INSERT INTO Ciudad VALUES (4871, 'Bahía Blanca', 'Rio Negro', 'Argentina');
INSERT INTO Ciudad VALUES (2315, 'Berazategui', 'Buenos Aires', 'Argentina');
INSERT INTO Ciudad VALUES (6510, 'Bolivar', 'Quito', 'Ecuador');
INSERT INTO Ciudad VALUES (8412, 'Arequipa', 'AQP', 'Perú');
INSERT INTO Ciudad VALUES (5148, 'Bogotá', 'Cundinamarca', 'Colombia');
INSERT INTO Ciudad VALUES (5464, 'El Vergel', 'Sincasur', 'Venezuela');

INSERT INTO Vuelo VALUES (9865, 5184, '1:15:23', 0256);
INSERT INTO Vuelo VALUES (4802, 1840, '1:21:52', 0256);
INSERT INTO Vuelo VALUES (6584, 2401, '2:20:20', 8215);
INSERT INTO Vuelo VALUES (5010, 8720, '1:42:45', 0256);
INSERT INTO Vuelo VALUES (8420, 8215, '2:39:53', 2401);

INSERT INTO ProgramaVuelo VALUES (9865, '2014-11-15', 5168, '12:15:32', '1:15:21');
INSERT INTO ProgramaVuelo VALUES (4802, '2014-11-21', 1540, '10:40:54', '1:19:20');
INSERT INTO ProgramaVuelo VALUES (6584, '2013-02-24', 5610, '09:24:30', '2:17:47');
INSERT INTO ProgramaVuelo VALUES (5010, '2015-10-02', 8721, '07:35:36', '1:38:21');
INSERT INTO ProgramaVuelo VALUES (8420, '2014-08-17', 0254, '03:27:47', '0:45:23');

INSERT INTO Avion VALUES (5168, 350, 'Pasajeros1');
INSERT INTO Avion VALUES (1540, 310, 'Pasajeros2');
INSERT INTO Avion VALUES (5610, 270, 'Pasajeros3');
INSERT INTO Avion VALUES (8721, 150, 'Pasajeros4');
INSERT INTO Avion VALUES (0254, 170, 'Pasajeros5');

INSERT INTO TipoAvion VALUES ('Pasajeros1', 350, 'Aircraft Industries', 1000);
INSERT INTO TipoAvion VALUES ('Pasajeros2', 310, 'Industria aeroespacial', 800);
INSERT INTO TipoAvion VALUES ('Pasajeros3', 270, 'GEN Corporation', 700);
INSERT INTO TipoAvion VALUES ('Pasajeros4', 150, 'Gyrodyne', 600);
INSERT INTO TipoAvion VALUES ('Pasajeros5', 170, 'Indonesian Aerospace', 550);

/*Prepare una lista con numero de vuelo, nombre del aeropuerto de salida, ciudad de salida, nombre del aeropuerto de llegada, ciudad de arribo,
la hora de salida y la fecha de todos los vuelos programados para el mes de noviembre de 2014, que salen del aeropuerto de Argentina 
hacia algún aeropuerto ubicado en Perú.*/

WITH CiudadLlegada(aeropuertoLlegada, ciudadArribo) AS
	(SELECT codAeroptoLlega, nombreCiu
	FROM Aeropuerto INNER JOIN Vuelo ON codAeropto=codAeroptoLlega NATURAL JOIN Ciudad)
SELECT *
FROM Aeropuerto INNER JOIN Vuelo ON codAeropto=codAeroptoSale INNER JOIN CiudadLlegada ON codAeropto=aeropuertoLlegada
WHERE 

WITH CiudadSalida(numeroVuelo, aeropuertoSalida, ciudadSalida, horaSalida, fechaSalida) AS
	(SELECT nroVuelo, codAeroptoSale, nombreCiu, horaSalida, fecha
	FROM Aeropuerto INNER JOIN Vuelo ON codAeropto=codAeroptoSale NATURAL JOIN ProgramaVuelo NATURAL JOIN Ciudad)
WITH CiudadLlegada(numeroVuelo, aeropuertoLlegada, ciudadArribo) AS
	(SELECT nroVuelo, codAeroptoLlega, nombreCiu
	FROM Aeropuerto INNER JOIN Vuelo ON codAeropto=codAeroptoLlega NATURAL JOIN Ciudad)
SELECT *
FROM CiudadSalida, CiudadLlegada







DROP  TABLE AVION

delete from vuelo
select * from tipoavion