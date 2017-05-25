/*
A tener en cuenta:
	-No se permite actualizaciones o cambios de la llave primaria, esto es, no habrá ON UPDATE CASCADE.
	-Se permite que cuando una tupla sea eliminada también se eliminen las tuplas de las tablas relacionadas por FK, esto es, habrá ON DELETE CASCADE;
		pero no será para todas las tablas de la base de datos. Así, si se elimina un cliente no se elimirán sus facturas.
	-Una vez realizada la factura y asignada la fechaSalida (como el día en que se realizó la factura) en Reserva_Estancia, como lo anterior es una
		actualización a la tabla R_E, se procede a eliminar las reservas afectadas y a realizarse su respectivo respaldo.
	-Cómo llenar atributos derivados: Tablas Factura, Actividades.
	-Función para extraer el día de una fecha dada.
	-Para evitar el error [54001] ERROR: límite de profundidad de stack alcanzado se recomiendo especificar el campo afectado.
	-No olvidar que el retorno de las funciones puede ser o NEW o OLD (este para después de haber eliminado alguna tupla).
	- <>  = 'Diferente de, no igual a'. Funciona con strings.
	-Un trigger BEFORE y otro trigger AFTER pueden hacer referencia a la misma tabla. 
*/

--CREACIÓN DE LAS TABLAS

CREATE TABLE Hotel (
  codigoHotel VARCHAR(8) NOT NULL,
  nombreHotel VARCHAR(35) NOT NULL UNIQUE,
  categoria INTEGER NOT NULL CHECK (categoria IN (1,2,3,4,5)),
  direccionHotel VARCHAR(80) NOT NULL,
  telefonoHotel VARCHAR(15) NOT NULL,
  cantidadHabitaciones INTEGER NOT NULL CHECK (cantidadHabitaciones>=20),
  emailHotel VARCHAR(50) NULL UNIQUE,
  PRIMARY KEY(codigoHotel)
);

CREATE TABLE Cliente (
  DNI VARCHAR(15) NOT NULL,
  nombreCompleto VARCHAR(35) NOT NULL UNIQUE,
  telefonoCliente VARCHAR(15) NULL,
  direccionCliente VARCHAR(80) NULL,
  PRIMARY KEY(DNI)
);

CREATE TABLE Habitacion (
  nroHabitacion INTEGER NOT NULL,
  codigoHotel VARCHAR(8) NOT NULL,
  tipoHabitacion VARCHAR(15) NOT NULL CHECK (tipoHabitacion IN ('Individual','Doble','Triple','Suite')),
  precioHabitacion FLOAT NOT NULL DEFAULT 0 CHECK (precioHabitacion>=0),
  --Mediante un trigger con función que inicialice el estado en 'disponible' no necesita tener el default
  estado VARCHAR(15) NULL /*NOT NULL DEFAULT 'Disponible'*/ CHECK (estado IN ('Disponible','Reservada','Ocupada')),
  PRIMARY KEY(nroHabitacion, codigoHotel),
  FOREIGN KEY(codigoHotel)
  REFERENCES Hotel(codigoHotel)
  ON DELETE CASCADE
);

CREATE TABLE Empleado (
  codigoEmpleado INTEGER NOT NULL UNIQUE,
  DNI VARCHAR(15) NOT NULL UNIQUE ,
  codigoHotel VARCHAR(8) NOT NULL,
  nombreCompleto VARCHAR(35) NOT NULL UNIQUE,
  direccionEmpleado VARCHAR(80) NULL,
  telefonoEmpleado VARCHAR(15) NULL,
  tituloEstudio VARCHAR(35) NOT NULL,
  ocupacion VARCHAR(35) NOT NULL,
  PRIMARY KEY(codigoEmpleado, DNI),
  FOREIGN KEY(codigoHotel)
  REFERENCES Hotel(codigoHotel)
  ON DELETE CASCADE
);

--El nombre de usuario de cada usuario es su respectivo codigo de empleado
CREATE TABLE Usuarios (
  usuario INT NOT NULL,
  codigoHotel VARCHAR(8) NOT NULL,
  claveAcceso CHAR(8) NOT NULL,
  tipoCuenta VARCHAR(40) NOT NULL CHECK (tipoCuenta IN ('Usuario','Administrador')),
  PRIMARY KEY(usuario),
  FOREIGN KEY(codigoHotel)
  REFERENCES Hotel(codigoHotel)
  ON DELETE CASCADE,
  FOREIGN KEY(usuario)
  REFERENCES Empleado(codigoEmpleado)
  ON DELETE CASCADE
);

/*Respaldo de empleados. Esta tabla es con el fin de conservar los datos de los empleados que han salido de la empresa. Tener en cuenta que 
esta tabla tiene su propia PK, la cual es autoincrementada (esto mediante la función SERIAL) a medida que se le ingresen tuplas. Además, 
no tiene relación con otras tablas, por lo cual no tiene llaves foráneas.*/
CREATE TABLE Respaldo_Empleado (
  codigoRespaldo SERIAL,
  codigoEmpleado INTEGER NOT NULL,
  DNI VARCHAR(15) NOT NULL UNIQUE ,
  codigoHotel VARCHAR(8) NOT NULL,
  nombreCompleto VARCHAR(35) NOT NULL,
  direccionEmpleado VARCHAR(80) NULL,
  telefonoEmpleado VARCHAR(15) NULL,
  tituloEstudio VARCHAR(35) NOT NULL,
  ocupacion VARCHAR(35) NOT NULL,
  PRIMARY KEY(codigoRespaldo)
);

CREATE TABLE Servicios (
  codigoServicio VARCHAR(8) NOT NULL,
  codigoEmpleado INTEGER NOT NULL,
  codigoHotel VARCHAR(8) NOT NULL,
  tipoServicio VARCHAR(35) NOT NULL UNIQUE,
  precioPersona FLOAT NOT NULL DEFAULT 0 CHECK (precioPersona>=0),
  diasSemana VARCHAR(20) NULL,
  horario TIME NULL,
  descripcion VARCHAR(80) NULL DEFAULT 'Ninguna',
  PRIMARY KEY(codigoServicio),
  FOREIGN KEY(codigoHotel)
  REFERENCES Hotel(codigoHotel)
  ON DELETE CASCADE,
  FOREIGN KEY(codigoEmpleado)
  REFERENCES Empleado(codigoEmpleado)
  ON DELETE CASCADE
);

CREATE TABLE Reserva_Estancia (
  codigoReserva VARCHAR(8) NOT NULL,
  codigoHotel VARCHAR(8) NOT NULL,
  nroHabitacion INTEGER NOT NULL,
  DNI VARCHAR(15) NOT NULL,
  --Mediante un trigger con función now() el atributo fechaReserva no necesita ser 'NOT NULL'.
  fechaReserva DATE NULL /*También puede tener DEFAULT NOW()*/,
  fechaLimite DATE NOT NULL CHECK (fechaLimite>=fechaReserva),
  deposito FLOAT NOT NULL DEFAULT 0 CHECK (deposito>=0),
  fechaIngreso DATE NULL CHECK (fechaIngreso<=fechaLimite), --fechaIngreso>=fechaReserva
  --Por razones lógicas fechaSalida>=fechaIngreso, pero por cuestiones de demostración en la sustentación se omite
  fechaSalida DATE NULL /*CHECK (fechaSalida>=fechaIngreso)*/,
  PRIMARY KEY(codigoReserva),
  FOREIGN KEY(nroHabitacion, codigoHotel)
  REFERENCES Habitacion(nroHabitacion, codigoHotel),
  FOREIGN KEY(DNI)
  REFERENCES Cliente(DNI)
  ON DELETE CASCADE
);

/*Esta tabla de respaldo es con el objetivo de que cada vez que un cliente finalice su estancia en un hotel, esto es cuando se le realice su factura,
 sean borradas sus respectivas reservas de la tabla Reserva_Estancia y almacenadas en esta tabla. Tener en cuenta que esta tabla tiene su propia PK, la
 cual es autoincrementada (esto mediante la función SERIAL) a medida que se le ingresen tuplas. Además, no tiene relación con otras tablas, por lo cual
 no tiene llaves foráneas. */
CREATE TABLE Respaldo_Reserva_Estancia (
  codigoRespaldo SERIAL,
  codigoReserva VARCHAR(8) NOT NULL,
  codigoHotel VARCHAR(8) NOT NULL,
  nroHabitacion INTEGER NOT NULL,
  DNI VARCHAR(15) NOT NULL,
  fechaReserva DATE NULL,
  fechaLimite DATE NOT NULL CHECK (fechaLimite>=fechaReserva),
  deposito FLOAT NOT NULL DEFAULT 0 CHECK (deposito>=0),
  fechaIngreso DATE NULL CHECK (fechaIngreso<=fechaLimite),
  fechaSalida DATE NULL CHECK (fechaSalida>=fechaIngreso),
  PRIMARY KEY(codigoRespaldo)
);

CREATE TABLE Factura (
  nroFactura CHAR(8) NOT NULL,
  DNI VARCHAR(15) NOT NULL,
  fechaFactura DATE NOT NULL,
  --precioTemporada se determina con la fecha de la factura y con el uso del trigger Insercion_Factura.
  precioTemporada FLOAT NOT NULL DEFAULT 0 CHECK (precioTemporada>=0),
  diasEstancia INTEGER NOT NULL DEFAULT 0 CHECK (diasEstancia>=0),
  precioTotalHabitacion FLOAT NOT NULL DEFAULT 0 CHECK (precioTotalHabitacion>=0),
  precioTotalActividades FLOAT DEFAULT 0 CHECK (precioTotalActividades>=0),
  precioTotalEstancia FLOAT NOT NULL DEFAULT 0 CHECK (precioTotalEstancia>=0),
  PRIMARY KEY(nroFactura),
  FOREIGN KEY(DNI)
  REFERENCES Cliente(DNI)
);

CREATE TABLE Actividades (
  codigoServicio VARCHAR(8) NOT NULL,
  DNI VARCHAR(15) NOT NULL,
  cantidadPersonas INTEGER NOT NULL DEFAULT 0 CHECK (cantidadPersonas>=0),
  valorAPagar FLOAT NOT NULL DEFAULT 0 CHECK (valorAPagar>=0),
  PRIMARY KEY(codigoServicio, DNI),
  FOREIGN KEY(codigoServicio)
  REFERENCES Servicios(codigoServicio),
  FOREIGN KEY(DNI)
  REFERENCES Cliente(DNI)
);


CREATE TABLE Nomina (
  codigoNomina VARCHAR(8) NOT NULL,
  DNI VARCHAR(15) NOT NULL,
  codigoEmpleado INTEGER NOT NULL,
  salario FLOAT NOT NULL DEFAULT 0 CHECK (salario>=0),
  diasTrabajados INTEGER NOT NULL DEFAULT 0 CHECK (diasTrabajados BETWEEN 0 AND 30),
  devengo FLOAT NULL DEFAULT 0 CHECK (devengo>=0),
  auxilioTransporte VARCHAR(3) NOT NULL DEFAULT 'No' CHECK (auxilioTransporte IN ('Si','No')),
  PRIMARY KEY(codigoNomina),
  FOREIGN KEY(codigoEmpleado, DNI)
  REFERENCES Empleado(codigoEmpleado, DNI)
);

--CREACIÓN DE LOS TRIGGERS:

--Función que determina el precio de cada habitación dependiendo de la categoría del hotel y del tipo de habitación:
CREATE OR REPLACE FUNCTION Precio_Habitacion() RETURNS TRIGGER AS $$
DECLARE

--Variable donde se almacena la categoría del hotel según el hotel de cada tupla insertada:
 categoria_hotel INT;
 
BEGIN

 SELECT categoria INTO categoria_hotel
 FROM Hotel
 WHERE codigoHotel=NEW.codigoHotel;

 CASE
    WHEN categoria_hotel=1 AND NEW.tipoHabitacion='Individual' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=25000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=1 AND NEW.tipoHabitacion='Doble' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=45000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=1 AND NEW.tipoHabitacion='Triple' 
	THEN 
	RAISE EXCEPTION 'No se puede asignar un tipo de habitación triple';
    WHEN categoria_hotel=1 AND NEW.tipoHabitacion='Suite' 
	THEN 
	RAISE EXCEPTION 'No se puede asignar un tipo de habitación suite';
    WHEN categoria_hotel=2 AND NEW.tipoHabitacion='Individual' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=70000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=2 AND NEW.tipoHabitacion='Doble' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=95000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=2 AND NEW.tipoHabitacion='Triple' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=115000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=2 AND NEW.tipoHabitacion='Suite' 
	THEN 
	RAISE EXCEPTION 'No se puede asignar un tipo de habitación suite';
    WHEN categoria_hotel=3 AND NEW.tipoHabitacion='Individual' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=90000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=3 AND NEW.tipoHabitacion='Doble' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=125000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=3 AND NEW.tipoHabitacion='Triple' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=150000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=3 AND NEW.tipoHabitacion='Suite' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=230000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=4 AND NEW.tipoHabitacion='Individual' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=110000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=4 AND NEW.tipoHabitacion='Doble' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=170000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=4 AND NEW.tipoHabitacion='Triple' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=210000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=4 AND NEW.tipoHabitacion='Suite' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=300000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=5 AND NEW.tipoHabitacion='Individual' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=130000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=5 AND NEW.tipoHabitacion='Doble' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=190000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=5 AND NEW.tipoHabitacion='Triple' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=250000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
    WHEN categoria_hotel=5 AND NEW.tipoHabitacion='Suite' 
	THEN 
	UPDATE Habitacion SET precioHabitacion=420000 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
	UPDATE Habitacion SET estado='Disponible' WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
 END CASE;
 
 RETURN NEW;
 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Precio_Habitacion AFTER INSERT ON Habitacion FOR EACH ROW EXECUTE PROCEDURE Precio_Habitacion();

/*Trigger para cuando se actualiza el tipo de habitación; la actualización por tanto debe cumplir la condición de la función Precio_Habitacion().Para evitar 
el error [54001] ERROR: límite de profundidad de stack alcanzado se recomienda especificar el campo afectado, en este caso: AFTER UPDATE OF tipoHabitacion ON Habitacion*/
CREATE TRIGGER Precio_Habitacion2 AFTER UPDATE OF tipoHabitacion ON Habitacion FOR EACH ROW EXECUTE PROCEDURE Precio_Habitacion();

/*Función que determina que un cliente sólo pueda hacer reservas de habitaciones en un hotel durante el mismo límite de tiempo. Cabe destacar que el cliente puede realizar varias 
reservas en cada uno de los hoteles al mismo tiempo, por lo cual se debe garantizar que las reservas en cada uno sean por el mismo periodo de tiempo. Por ejempli, el cliente 001 solicita 
varias reservas en el hotel Central por un periodo de 3 días y a la vez solicita varias reservas en el hotel Costa del Sol por un periodo de 5 días; se debe garantizar que todas las reservas
solicitadas por este cliente en el hotel Central sean por el mismo periodo de tiempo y que a su vez también lo sean todas las reservas hechas en el hotel Costa del Sol.*/
CREATE OR REPLACE FUNCTION Insertar() RETURNS TRIGGER AS $$
DECLARE 

/*Variables donde se almacenan el hotel donde el cliente hizo la reserva, su DNI, y la fecha límite. Cabe destacar que estos valores se obtiene de la primer tupla insertada, es decir, 
la primer resrrva hecha. Si el cliente no tiene ninguna reserva, esto es, cuando los valores de las siguientes tres variables IS NULL, la inserción de la tupla se realiza y a partir de 
esta ya se obtienen los respectivos valores.*/
hotel VARCHAR(8);
cliente VARCHAR(8);
fecha_limite DATE;

BEGIN

--Tener en cuenta la condicón en el WHERE en cada una de las sgtes selecciones. Tal condición garantiza una tupla única.
SELECT codigoHotel INTO hotel
FROM Reserva_Estancia
WHERE DNI=NEW.DNI AND codigoHotel=NEW.codigoHotel
GROUP BY codigoHotel;

SELECT DNI INTO cliente
FROM Reserva_Estancia
WHERE DNI=NEW.DNI AND codigoHotel=NEW.codigoHotel
GROUP BY DNI;

SELECT fechaLimite INTO fecha_limite
FROM Reserva_Estancia
WHERE DNI=NEW.DNI AND codigoHotel=NEW.codigoHotel
GROUP BY fechaLimite;

/*Si el cliente previamente ya tiene hecha una reserva en un hotel, entonces se compara los valores codigoHotel, DNI y fechaLimite de la nueva tupla a insertar con 
los valores de la previa reserva hecha, esto con el fin de obtener y comparar la fecha límite de tal reserva con la fecha límite de la nueva tupla. Si ambos valores son
diferentes (NEW.fechaLimite<>fecha_limite), entonces la tupla o nueva reserva no será insertada */
IF (NEW.DNI=cliente AND NEW.codigoHotel=hotel) AND NEW.fechaLimite<>fecha_limite
THEN
 RAISE EXCEPTION 'No se puede realizar la reserva. La fecha límite es diferente. ';
END IF;

 RETURN NEW;
 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Insertar BEFORE INSERT ON Reserva_Estancia FOR EACH ROW EXECUTE PROCEDURE Insertar();

/*Función que determina que el depósito de una reserva sea el 10% del costo de la habitación, que la fecha de la reserva sea la actual y que cambie el estado de una 
habitación asignda a 'Reservada' sólo si está disponible. */
CREATE OR REPLACE FUNCTION Insercion_Reserva_Estancia() RETURNS TRIGGER AS $$
DECLARE

--Variables donde se almacena el precio y el estado de cada habitación según el nro de habitación y el hotel de la tupla insertada:
 precio_habitacion FLOAT;
 estado_habitacion VARCHAR(20);
 
BEGIN
 
 SELECT precioHabitacion INTO precio_habitacion
 FROM Habitacion
 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;

 SELECT estado INTO estado_habitacion
 FROM Habitacion
 WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;

--Actualizar el atributo deposito, su valor es el 10% del precio de la habitación.
 UPDATE Reserva_Estancia
 SET deposito=precio_habitacion*0.1
 WHERE codigoReserva=NEW.codigoReserva;

--Actualizar el atributo fechaReserva, su valor es la fecha actual.
 UPDATE Reserva_Estancia
 SET fechaReserva=now()
 WHERE codigoReserva=NEW.codigoReserva;

--Actualizar el atributo estado en Habitacion, suu valor sería 'Reservada' sólo si la habitación está disponible.
IF estado_habitacion='Disponible' 
 THEN
  UPDATE Habitacion
  SET estado='Reservada'
  WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
 ELSE
  RAISE EXCEPTION 'La habitación no está disponible';
END IF;

 RETURN NEW;
 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Insercion_Reserva_Estancia AFTER INSERT ON Reserva_Estancia FOR EACH ROW EXECUTE PROCEDURE Insercion_Reserva_Estancia();

/*Función para cuando se realice una actualización en R_E. Tal actualización puede ser cuando el cliente se hospeda en el hotel y cuando finaliza su estancia. Cabe
destacar que un cliente finaliza su estancia en el hotel cuando se le ha hecho su factura, para ello el atributo fechaSalida toma el valor en que se realiza la factura
(fechaFactura). El procedimiento anterior se realiza en el trigger Insercion_Factura. También, para destacar, cuando el atributo fechaSalida es llenado las tuplas afectadas
deben ser respaldadas, esto es el respaldo de las reservas del cliente, y también el estado de las habitaciones ocupadas deben cambiar a 'Disponible'. Para realizar el 
proceso de cambio de estado a 'Disponible' se emplea el trigger Eliminacion_Reserva_Estancia, el cual sigue a esta función.*/
CREATE OR REPLACE FUNCTION Actualizacion_Reserva() RETURNS TRIGGER AS $$
DECLARE
BEGIN

--Cuando un cliente llega dentro del plazo de la reserva al hotel el estado de la habitación asignada cambia a 'Ocupada'.
 IF NEW.fechaIngreso IS NOT NULL
 THEN
  UPDATE Habitacion
  SET estado='Ocupada'
  WHERE nroHabitacion=NEW.nroHabitacion AND codigoHotel=NEW.codigoHotel;
 END IF;

/*Cuando un cliente finaliza su estancia en el hotel el estado de la habitación asignada cambia a 'Disponible' nuevamente, además, se eliminan sus
reservas y se hace su respaldo en Respaldo_Reserva_Estancia. */
 IF NEW.fechaSalida IS NOT NULL
 THEN

--Cambiar el estado de la habitación a 'Disponible'
 UPDATE Habitacion
 SET estado='Disponible'
 WHERE nroHabitacion=OLD.nroHabitacion AND codigoHotel=OLD.codigoHotel;
 
--Tener en cuenta la PK en la tabla respaldo; la PK no se tiene en cuenta en la siguiente inserción ya que tal PK es autoincrementada.
 INSERT INTO Respaldo_Reserva_Estancia (codigoReserva, codigoHotel, nroHabitacion, DNI, fechaReserva, fechaLimite, deposito, fechaIngreso, fechaSalida)
 VALUES (NEW.codigoReserva, NEW.codigoHotel, NEW.nroHabitacion, NEW.DNI, NEW.fechaReserva, NEW.fechaLimite, NEW.deposito, NEW.fechaIngreso, NEW.fechaSalida);

--Por último cada reserva del cliente se borra de la tabla Reserva_Estancia.
 DELETE FROM Reserva_Estancia WHERE DNI=NEW.DNI;
 END IF;

 RETURN NEW;
 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Actualizacion_Reserva AFTER UPDATE ON Reserva_Estancia FOR EACH ROW EXECUTE PROCEDURE Actualizacion_Reserva();

/*Función para que cada vez que una tupla se elimine se active el trigger Eliminacion_Reserva_Estancia, el cual cambia el estado de la habitación ocupada a 'Disponible'.
Esta es función es útil para cuando el cliente reserva 3 habitaciones y sólo ocupa 2; las habitaciones que no ocupa deben cambiar su estado a 'Disponible' y además estas
no tendrán respaldo.*/
CREATE OR REPLACE FUNCTION Eliminacion_Reserva_Estancia() RETURNS TRIGGER AS $$
DECLARE 
BEGIN

 UPDATE Habitacion
 SET estado='Disponible'
 WHERE nroHabitacion=OLD.nroHabitacion AND codigoHotel=OLD.codigoHotel;

 RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Eliminacion_Reserva_Estancia AFTER DELETE ON Reserva_Estancia FOR EACH ROW EXECUTE PROCEDURE Eliminacion_Reserva_Estancia();

--Función que determina que un empleado sea del respectivo hotel de un servicio y que además este sea animador:
CREATE OR REPLACE FUNCTION Insercion_Servicios() RETURNS TRIGGER AS $$
DECLARE

--Variables donde se almacena la ocupacion del empleado y el código del hotel en el que ese empleado trabaja y se está prestando el servicio.
 ocupacion_empleado VARCHAR(35);
 hotel VARCHAR(8);
 
BEGIN

--Determinación de la ocupación del empleado.
 SELECT ocupacion INTO ocupacion_empleado
 FROM Empleado
 WHERE codigoEmpleado=NEW.codigoEmpleado;

--Determinación del hotel donde trabaja el empleado.
 SELECT codigoHotel INTO hotel
 FROM Empleado
 WHERE codigoEmpleado=NEW.codigoEmpleado;

--Condición para que el empleado asiganado a un servicio sea animador
 IF ocupacion_empleado<>'Animador'
 THEN
  RAISE EXCEPTION 'Este empleado no es animador';
 ELSIF
 NEW.codigoHotel<>hotel
 THEN
   RAISE EXCEPTION 'Este empleado no pertenece al hotel';
 END IF;

 RETURN NEW;
 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Insercion_Servicios AFTER INSERT ON Servicios FOR EACH ROW EXECUTE PROCEDURE Insercion_Servicios();
/*Trigger para cuando se actualiza el codigo de empleado; la actualización por tanto debe cumplir la condición de la función Insercion_Servicios() */
CREATE TRIGGER Insercion_Servicios2 AFTER UPDATE OF codigoEmpleado, codigoHotel ON Servicios FOR EACH ROW EXECUTE PROCEDURE Insercion_Servicios();

/*Función que determina los servicios o actividades prestadas a un cliente. Se debe tener en cuenta que una actividad puede ser asignada sólo si el cliente está hospedado
en el hotel, es decir, si ha cumplido con la reserva y tiene una fecha de ingreso. Además el precio a pagar por un actividad depende de la cantidad de acompañantes del 
cliente y del hotel donde este esté y se preste el servicio*/
CREATE OR REPLACE FUNCTION Insercion_Actividades() RETURNS TRIGGER AS $$
DECLARE

/*Variables donde se almacenan el precio por persona del servicio, la cantidad de personas o acompañantes del cliente quienes gozan del servicio, el hotel donde está 
hospedado el cliente y el hotel donde se realiza el servicio, y la fecha de ingreso del cliente al hotel, con lo cual la reserva se convierte en estancia. */
 precio_persona FLOAT;
 cantidad_Personas INT;
 hotel_cliente VARCHAR(8);
 hotel_servicio VARCHAR(8);
 fecha_ingreso DATE;
 
BEGIN

--Determinación del hotel donde se hospeda el cliente
 SELECT codigoHotel INTO hotel_cliente
 FROM Reserva_Estancia
 WHERE DNI=NEW.DNI
 GROUP BY codigoHotel;

--Determinación de la fecha de ingreso del cliente al hotel
 SELECT fechaIngreso INTO fecha_ingreso
 FROM Reserva_Estancia
 WHERE DNI=NEW.DNI
 GROUP BY fechaIngreso;

--Condición para cuando un cliente no tiene reserva y se le quiere asignar un servicio
 IF fecha_ingreso IS NULL
 THEN
  RAISE EXCEPTION 'El cliente no está hospedado en el hotel';
 END IF;

--Determinación del hotel donde se presta el servicio
 SELECT codigoHotel INTO hotel_servicio
 FROM Servicios 
 WHERE codigoServicio=NEW.codigoServicio
 GROUP BY codigoHotel;

--Determinación del precio por persona del servicio.
 SELECT precioPersona INTO precio_persona
 FROM Servicios
 WHERE codigoServicio=NEW.codigoServicio;
 
--Determinación de los acompañantes del cliente al servicio.
 SELECT cantidadPersonas INTO cantidad_Personas
 FROM Actividades
 WHERE codigoServicio=NEW.codigoServicio AND DNI=NEW.DNI;

 /*Condición que determina si el servicio a prestar es del mismo hotel donde se hospeda el cliente; si ambos hoteles coinciden entonces se procede a realizar
 la actividad y se asigna el precio total a pagar por esta. */
 IF hotel_cliente=hotel_servicio
 THEN
  UPDATE Actividades
  SET valorAPagar=precio_persona*cantidad_personas
  WHERE codigoServicio=NEW.codigoServicio AND DNI=NEW.DNI;
 ELSE
  RAISE EXCEPTION 'El servicio no es prestado en el hotel donde se hospeda el cliente';
 END IF;

 RETURN NEW;
 
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Insercion_Actividades AFTER INSERT ON Actividades FOR EACH ROW EXECUTE PROCEDURE Insercion_Actividades();

/*Función para cuando una tupla es actualizada en Actividades. El único campo que debe ser actualizado tiene que ser cantidadPersonas. Si este campo es cambiado, se 
debe modificar valorAPagar*/
CREATE OR REPLACE FUNCTION Actualizacion_Actividades() RETURNS TRIGGER AS $$
DECLARE 

precio_persona FLOAT;
cantidad_personas INT;

BEGIN

--Determinación del precio por persona del servicio.
 SELECT precioPersona INTO precio_persona
 FROM Servicios
 WHERE codigoServicio=NEW.codigoServicio;
 
--Determinación de los acompañantes del cliente al servicio.
 SELECT cantidadPersonas INTO cantidad_Personas
 FROM Actividades
 WHERE codigoServicio=NEW.codigoServicio AND DNI=NEW.DNI;

 UPDATE Actividades
 SET valorAPagar=precio_persona*cantidad_personas
 WHERE codigoServicio=NEW.codigoServicio AND DNI=NEW.DNI;

 RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Actualizacion_Actividades AFTER UPDATE OF cantidadPersonas ON Actividades FOR EACH ROW EXECUTE PROCEDURE Actualizacion_Actividades();

/*Función que determina el precio de la temporada, el precio de las habitaciones, el precio de los servicios consumidos y el depósito del cliente pagado 
por las reservas de las habitaciones. Además, cuando se genera la factura, las reservas del cliente y sus actividades deben eliminarse, aunque las reservas
deben tener un respaldo. Se debe tener en cuenta que una factura sólo puede ser hecha si el cliente está hospedado en el hotel, es decir, si ha cumplido 
con la reserva y tiene una fecha de ingreso*/
CREATE OR REPLACE FUNCTION Insercion_Factura() RETURNS TRIGGER AS $$
DECLARE

/*Variables donde se almacenan el precio total de las habitaciones ocupadas por el cliente, el precio de los servicios prestados, el depósito por las reservas de las 
habitaciones y una variable que se usa para determinar si un cliente está hospedado en el hotel. Además las dos últimas variables es con el fin de obtener los días 
de estancia del cliente el cual su valor es fecha_actual-fecha_ingreso*/
precio_habitaciones FLOAT;
precio_actividades FLOAT;
valor_deposito FLOAT;
fecha_ingreso DATE;
dia_actual INT;
dia_ingreso INT;

BEGIN --IMPORTANTE TENER EN CUENTA LA FUNCIÓN PARA EXTRAER EL DÍA DE UNA FECHA DADA.

--Determinación de la fecha de ingreso del cliente al hotel
SELECT fechaIngreso INTO fecha_ingreso
FROM Reserva_Estancia
WHERE DNI=NEW.DNI
GROUP BY fechaIngreso;

--Condición para cuando un cliente no tiene reserva y se le quiere asignar un servicio
 IF fecha_ingreso IS NULL
 THEN
  RAISE EXCEPTION 'El cliente no está hospedado en el hotel';
 END IF;

--Determinación de la fecha actual
SELECT EXTRACT(DAY FROM now()) INTO dia_actual;

--Determinación del día en que ingresa el cliente al hotel y su reserva se convierte en estancia
SELECT EXTRACT(DAY FROM fecha_ingreso) INTO dia_ingreso;

--La fecha de la factura queda automáticamente con la fecha actual del sistema
UPDATE Factura
SET fechaFactura=now()
WHERE nroFactura=NEW.nroFactura;

--Precio de todas las habitaciones ocupadas por el cliente
SELECT SUM(precioHabitacion) INTO precio_habitaciones
FROM Reserva_Estancia AS RE INNER JOIN Habitacion AS H ON (RE.nroHabitacion=H.nroHabitacion AND RE.codigoHotel=H.codigoHotel)
WHERE DNI=NEW.DNI
GROUP BY DNI;

--Precio de los servicios prestados al cliente
SELECT SUM(valorAPagar) INTO precio_actividades
FROM Actividades
WHERE DNI=NEW.DNI
GROUP BY DNI;

--Valor del depósito del cliente
SELECT SUM(deposito) INTO valor_deposito
FROM Reserva_Estancia
WHERE DNI=NEW.DNI;

--Determinación de la temporada según la fecha en que se realiza la factura
CASE
--Temporada baja=12000; media=20000; alta=36000
WHEN NEW.fechaFactura BETWEEN '2017-02-01' AND '2017-06-14' THEN UPDATE Factura SET precioTemporada=12000 WHERE nroFactura=NEW.nroFactura;
WHEN NEW.fechaFactura BETWEEN '2017-06-15' AND '2017-08-31' THEN UPDATE Factura SET precioTemporada=20000 WHERE nroFactura=NEW.nroFactura;
WHEN NEW.fechaFactura BETWEEN '2017-11-15' AND '2018-01-31' THEN UPDATE Factura SET precioTemporada=36000 WHERE nroFactura=NEW.nroFactura;
WHEN NEW.fechaFactura BETWEEN '2017-09-01' AND '2017-11-14' THEN UPDATE Factura SET precioTemporada=12000 WHERE nroFactura=NEW.nroFactura;
END CASE;

--Determinación de los días de estancia
IF (dia_actual-dia_ingreso=0)
THEN
 UPDATE Factura
 SET diasEstancia=1
 WHERE nroFactura=NEW.nroFactura;
ELSE
 UPDATE Factura
 SET diasEstancia=dia_actual-dia_ingreso
 WHERE nroFactura=NEW.nroFactura;
END IF;

--Asignación del valor al atributo precioTotalHabitacion
UPDATE Factura
SET precioTotalHabitacion=precio_habitaciones
WHERE nroFactura=NEW.nroFactura;

--Asignación del valor al atributo precioTotalActividades
IF precio_actividades IS NULL
THEN 
 UPDATE Factura
 SET precioTotalActividades=0
 WHERE nroFactura=NEW.nroFactura;
ELSE
 UPDATE Factura
 SET precioTotalActividades=precio_actividades
 WHERE nroFactura=NEW.nroFactura;
END IF;

--Determinación del valor total a pagar
UPDATE Factura
SET precioTotalEstancia=(diasEstancia*precio_habitaciones)+precioTotalActividades-valor_deposito+precioTemporada
WHERE nroFactura=NEW.nroFactura;

--La fecha de salida de un cliente del hotel es aquella fecha de realización de la factura, es decir, la fecha actual.
UPDATE Reserva_Estancia SET fechaSalida=now() WHERE DNI=NEW.DNI;

--Eliminación de las actividades prestadas al cliente. Se elimina aquellas actividades de ese cliente.
 DELETE FROM Actividades WHERE DNI=NEW.DNI;
 
RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Insercion_Factura AFTER INSERT ON Factura FOR EACH ROW EXECUTE PROCEDURE Insercion_Factura();

/*Función para cuando un empleado es eliminado; en tal caso se le hace un respaldo. Esta función funciona de forma similar a Respaldo_R_E en el sentido de la PK*/
CREATE OR REPLACE FUNCTION Eliminar_Empleado() RETURNS TRIGGER AS $$
DECLARE 
BEGIN

 INSERT INTO Respaldo_Empleado (codigoEmpleado, DNI, codigoHotel, nombreCompleto, direccionEmpleado, telefonoEmpleado, tituloEstudio, ocupacion)
 VALUES(OLD.codigoEmpleado, OLD.DNI, OLD.codigoHotel, OLD.nombreCompleto, OLD.direccionEmpleado, OLD.telefonoEmpleado, OLD.tituloEstudio, OLD.ocupacion);

 RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Eliminar_Empleado BEFORE DELETE ON Empleado FOR EACH ROW EXECUTE PROCEDURE Eliminar_Empleado();

/*Función que determina que un usuario de la base de datos sea un empleado del hotel y que además sea del área de sistemas*/
CREATE OR REPLACE FUNCTION Insertar_Usuario() RETURNS TRIGGER AS $$
DECLARE 

--Variables donde se almacena el hotel donde trabaja el empleado y su ocupación:
hotel_empleado VARCHAR(8);
ocupacion_empleado VARCHAR(35);

BEGIN

--Determinación del código del empleado:
 SELECT codigoHotel INTO hotel_empleado
 FROM Empleado
 WHERE codigoEmpleado=NEW.usuario;

--Determinación de la ocupación del empleado:
 SELECT ocupacion INTO ocupacion_empleado
 FROM Empleado
 WHERE codigoEmpleado=NEW.usuario;

 IF ocupacion_empleado<>'Sistemas'
 THEN 
  RAISE EXCEPTION 'El empleado no pertece al área de sistemas.';--;
 ELSIF hotel_empleado<>NEW.codigoHotel
  THEN
   RAISE EXCEPTION 'El empleado no pertenece al hotel.';
 END IF;
 
 RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Insertar_Usuario AFTER INSERT ON Usuarios FOR EACH ROW EXECUTE PROCEDURE Insertar_Usuario();










--Función que determina que ningún campo de la tabla Factura sea modificado.
CREATE OR REPLACE FUNCTION Sin_Modificar() RETURNS TRIGGER AS $$
DECLARE 
BEGIN

RAISE EXCEPTION 'No se puede hacer modificaciones en la factura.';

 RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Sin_Modificar_Factura BEFORE UPDATE ON Factura FOR EACH ROW EXECUTE PROCEDURE Sin_Modificar();

DROP TRIGGER Sin_Modificar_Factura ON Factura









CREATE OR REPLACE FUNCTION () RETURNS TRIGGER AS $$
DECLARE 
BEGIN

 RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER [] ON Empleado FOR EACH ROW EXECUTE PROCEDURE ();













