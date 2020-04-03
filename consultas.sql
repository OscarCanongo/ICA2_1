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