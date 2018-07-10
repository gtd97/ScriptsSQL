-- Obtener el Nombre y Apellido de todos los clientes que hayan comprado algo entre 2013-01-01 y 2014-07-08 ordenados por nombre
SELECT c.FirstName, c.LastName FROM Customers c
INNER JOIN Orders o on o.CustomerId = c.Id
WHERE o.OrderDate >= '2013-01-01' AND o.OrderDate < '2014-07-08'
ORDER BY c.FirstName




-- Obtener todos los clientes de Argentina que tengan compras
SELECT DISTINCT c.* FROM Customers c
INNER JOIN Orders o ON o.CustomerId = c.Id
WHERE c.Country = 'Argentina' 




-- Obtener todos los proveedores que tengan productos discontinuados
SELECT s.* FROM Suppliers s
INNER JOIN Products p ON p.SupplierId = s.Id
WHERE p.IsDiscontinued = 1




-- Obtener todos los clientes que hayan comprado alguna vez mas de 30 "Teatime Chocolate Biscuits"
SELECT c.FirstName, c.LastName FROM Customers c
INNER JOIN Orders o ON o.CustomerId = c.Id
INNER JOIN OrderItems oi ON oi.OrderId = o.Id
WHERE oi.Quantity > 30 AND oi.ProductId = (
	SELECT Id FROM Products
	WHERE ProductName = 'Teatime Chocolate Biscuits'
)




-- Obtener todos los productos que nunca se vendieron
SELECT p.* FROM Products p
LEFT JOIN OrderItems oi ON oi.ProductId = p.Id
WHERE oi.ProductId IS NULL





-- Agregar una venta del producto anterior en el dia de ayer al cliente "Antonio Moreno" que vive en "México D.F." por 10 unidades con precio unitario 13 y 10 cajas
INSERT INTO Orders	(OrderDate, OrderNumber, CustomerId, TotalAmount)
			VALUES	(	
						('2018-07-03'),
						(SELECT MAX(OrderNumber+1) FROM Orders),
						(SELECT Id FROM Customers WHERE FirstName='Antonio' AND LastName='Moreno' AND City='México D.F.'),
						(SELECT (p.UnitPrice*10) FROM Products p LEFT OUTER JOIN OrderItems oi ON p.Id = oi.ProductId WHERE oi.ProductId IS NULL)					
					)

INSERT INTO OrderItems (OrderId, ProductId, UnitPrice, Quantity) 
			VALUES 	(
						(SELECT MAX(Id) FROM Orders),
						(SELECT p.Id FROM Products p LEFT OUTER JOIN OrderItems oi ON p.Id = oi.ProductId WHERE oi.ProductId IS NULL ),
						13,
						10
					) 

--Variables SQL
--DECLARE @order int;
--SET @order = 23;
--SELECT @order;


-- Calcular el nombre de todos los cliente que no compraron nada en 2013

	-- Opcion 1:
		SELECT c.FirstName, c.LastName FROM Customers c
		WHERE c.Id not in
		(
			SELECT CustomerId FROM Orders WHERE OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01' 
		)

	-- Opcion 2:
		SELECT c.FirstName, c.LastName FROM Customers c
		WHERE not exists
		(
			SELECT * FROM Orders WHERE OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01' 
		)



-- Obtener el promedio de ventas de todas las ordenes
SELECT AVG(TotalAmount) from Orders;




-- Promedio de gasto al anio por cliente en la tienda (cual quier cosa que este en el select y no sea un agregado.. sum, min, count,etc.. Ha de estar en el group by tambien)
SELECT year(o.OrderDate), o.CustomerId, avg(TotalAmount), sum(TotalAmount) from Orders o
GROUP BY o.CustomerId, year(o.OrderDate)
ORDER BY 2

	-- De esta forma, es como la anterior, pero al agrupar por año, no se mezclan los años 
	SELECT month(o.OrderDate), year(o.OrderDate), o.CustomerId, avg(TotalAmount), sum(TotalAmount) from Orders o
	GROUP BY o.CustomerId, year(o.OrderDate), month(o.OrderDate)
	ORDER BY 3




-- Promedio de gasto por cliente en la tienda, donde el promedio sea año a 500 (HAVING ES EL WHERE DENTRO DEL GROUP BY)
SELECT year(o.OrderDate), o.CustomerId, avg(TotalAmount), sum(TotalAmount) from Orders o
GROUP BY o.CustomerId, year(o.OrderDate)
HAVING avg(TotalAmount) > 500
ORDER BY 2




-- Promedio y total de gasto por cliente por año en la tienda donde el promedio sea mayor a 500, para todas las compras desde el 2014 en adelante
SELECT year(o.OrderDate), o.CustomerId, avg(TotalAmount), sum(TotalAmount) from Orders o 
WHERE OrderDate >= '2014-01-01'
GROUP BY o.CustomerId, year(o.OrderDate)
HAVING avg(TotalAmount) > 500
ORDER BY 2


-- OBTENER LA CANTIDAD TOTAL DE PRODUCTOS
	SELECT count(*) AS 'Cantidad Total de Productos' FROM Products


-- OBTENER LA CANTIDAD DE PRODUCTOS QUE NO SE VENDIERON EN 2014
	SELECT COUNT(p.Id) FROM Products p
	WHERE NOT EXISTS
	(
		SELECT oi.ProductId FROM OrderItems oi 
		INNER JOIN Orders o ON o.Id = oi.OrderId
		WHERE ProductId = p.Id AND year(o.OrderDate) = 2014
	)



-- OBTENER EL NOMBRE DE LOS CLIENTES QUE REALIZARON ORDENES CON SOLO 1 PRODUCTO
	SELECT Distinct c.FirstName, c.LastName FROM Orders o
	INNER JOIN Customers c ON c.Id = o.CustomerId
	INNER JOIN OrderItems oi ON oi.OrderId= o.Id
	WHERE o.id IN (
					SELECT OrderId FROM OrderItems
					WHERE Quantity = 1
				)


---------------------------------------------------------------------------------

-- OBTENER EL PRODUCTO QUE MAS UNIDADES VENDIO EN 2012
	SELECT TOP 1 oi.ProductId, SUM(oi.Quantity) AS 'SUMA Cantidad' FROM OrderItems oi
	INNER JOIN Products p ON p.Id = oi.ProductId
	INNER JOIN Orders o ON o.Id = oi.OrderId
	WHERE year(o.OrderDate) = 2012
	GROUP BY oi.ProductId
	ORDER BY [SUMA Cantidad] DESC


-- OBTENER EL PRODUCTO QUE MAS GANANCIAS GENERO ENTRE MARZO Y OCTUBRE EN 2013
	-- Todos los productos que fuero vendidos entre marzo y octubre de 2013
	SELECT DISTINCT TOP 1 o.*, (oi.Quantity*oi.UnitPrice) AS 'Total Ganancias' FROM Orders o
	INNER JOIN OrderItems oi ON oi.OrderId = o.Id
	INNER JOIN Products p ON p.Id = oi.ProductId
	WHERE YEAR(o.OrderDate) = 2013 AND MONTH(o.OrderDate) >= 3 AND MONTH(o.OrderDate) <= 10
	ORDER BY [Total Ganancias] DESC


---------------------------------------------------------------------------------
-- OBTENER LA CANTIDAD PROMEDIO DE ITEMS QUE COMPRA CADA CLIENTE
	SELECT (AVG(oi.Quantity)) AS total, c.Id AS 'ID Customer' FROM OrderItems oi 
	INNER JOIN Customers c ON c.Id = oi.OrderId 
	GROUP BY OrderId, c.Id




-- ELIMINAR TODAS LAS ORDENES DE LOS CLIENTES DE Argentina
	-- Elimina la orderitem si tiene una id de customer Argentino
	DELETE FROM OrderItems
	WHERE OrderItems.Id IN (
						-- Devuelve los ID's de las orders compradas por customers de Argentina
						SELECT DISTINCT o.Id FROM Customers c
						INNER JOIN Orders o ON o.CustomerId = c.Id
						WHERE c.Country = 'Argentina' AND c.Id = o.CustomerId
					 );
	
	-- Elimina las order si tiene una id de customer Argentino
	DELETE FROM Orders
	WHERE Orders.CustomerId IN (
						-- Devuelve los ID's de las orders compradas por customers de Argentina
						SELECT DISTINCT c.Id FROM Customers c
						INNER JOIN Orders o ON o.CustomerId = c.Id
						WHERE c.Country = 'Argentina' AND c.Id = o.CustomerId
					 );
