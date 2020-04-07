--Trigger Historial de precios
CREATE TABLE historial_precios(
idPrecios INT NOT NULL  auto_increment, 
id_producto INT,
precioPrevio float, 
precioActual float,
action varchar(50) default null,
changedate datetime default null,
CONSTRAINT pkPrecios PRIMARY KEY (idPrecios),
CONSTRAINT fkProducto FOREIGN KEY (id_Producto) REFERENCES producto(idProducto)
);

ALTER TABLE historial_precios() ADD action varchar(50);

DELIMITER $$
  CREATE TRIGGER before_update_precio
	AFTER UPDATE ON producto
  FOR EACH ROW
  BEGIN
    INSERT INTO historial_precios
    SET action = 'Update',
    id_producto = NEW.idProducto,
    precioPrevio = OLD.precio,
    precioActual = NEW.precio,
    changedate = NOW();
  END$$
DELIMITER ;

UPDATE producto SET precio=170 Where idProducto = 1;
UPDATE producto SET precio=1500 Where idProducto = 6;

-- Funcion tiempo de trabajo 
DELIMITER $$
  CREATE FUNCTION HorasTrabajadas(horaDeEntrada time, horaDesalida time) RETURNS time
  DETERMINISTIC
  BEGIN
    DECLARE tiempo time;
    DECLARE hora time DEFAULT now();
    IF hora<=horaDeEntrada THEN
    SET tiempo = null;
    ELSEIF horaDeSalida<=hora THEN
    SET tiempo = horaDeSalida-horaDeEntrada;
    ELSE
    SET tiempo = hora-horaDeEntrada;
    END IF;
    RETURN (tiempo);
  END$$
DELIMITER ;

select HorasTrabajadas(entrada, salida) from personal;

-- Stored procedure ventas
ALTER TABLE ventas ADD cantidad INT;
ALTER TABLE ventas ADD precioDeVenta FLOAT;


DELIMITER //
CREATE PROCEDURE procedimientoVentas(IN producto_idProducto int, cantidad1 int, idVentas int )
	BEGIN 
  	DECLARE productoCantidad INT;
    DECLARE precioVenta DOUBLE;
		 SET productoCantidad = (SELECT cantidad FROM producto WHERE idProducto = producto_idProducto);
		 SET precioVenta = (SELECT precio FROM producto WHERE idProducto = producto_idProducto) * cantidad1;
    IF productoCantidad >= cantidad1 THEN
     UPDATE producto SET cantidad = productoCantidad-cantidad1 WHERE idProducto = producto_idProducto;
     INSERT INTO ventas (idVentas, personal_idPersonal, fecha, producto_idProducto, cantidad, precioDeVenta) VALUES (idVentas, 1,NOW(),producto_idProducto, cantidad1, precioVenta);
     END IF;
  END //
DELIMITER ;

CALL procedimientoVentas(3,40,2);

-- Trigger orden de compra
CREATE TABLE orden_compra(
idCompra INT NOT NULL auto_increment,
id_producto INT,
cantidad float, 
fecha datetime,
PRIMARY KEY (idCompra),
FOREIGN KEY (id_Producto) REFERENCES producto(idProducto)
);

DELIMITER $$
  CREATE TRIGGER after_ordenCompra
	BEFORE UPDATE ON producto
  FOR EACH ROW 
  BEGIN
   IF NEW.cantidad = 0 THEN
  	SET NEW.cantidad = 10;
    INSERT INTO orden_compra(id_producto, cantidad, fecha) VALUES (OLD.idProducto, 10, now());
   END IF;
  END$$
DELIMITER ;

-- Proceso que cada 8 horas genera un resumen
CREATE EVENT ventas_8horas
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
DO
     SELECT idVentas, fecha, nombre, ventas.cantidad, precioDeVenta FROM ventas 
     INNER JOIN producto ON producto_idProducto = idProducto WHERE ADDDATE(now(),INTERVAL -3 minute) <= fecha; 

