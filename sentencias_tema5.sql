-- FALTAN:
-- * 10 y 17 de la parte 2

-- Parte 1:

-- 1) Consultar el identificador, la fecha y total de las facturas sin el iva
-- de las facturas que fueron atendidas por el vendedor Pablo Marmol, cuyas
-- facturas fueron generadas para clientes de la ciudad de Medellín.

SELECT
    fac.id_factura AS "Identificador factura",
    fac.fecha_factura AS "Fecha factura",
    fac.vr_antes_iva AS "Precio sin iva"
FROM 
    facturas fac
    JOIN vendedores ven ON fac.fk_vendedores = ven.id_vendedor
    JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
WHERE ven.vendedor = 'PABLO MARMOL' AND cli.ciudad_cl = 'MEDELLIN';


-- 2) Consultar los clientes con el siguiente formato de salida: ‘El Cliente
-- Pérez Pedro (apellido y Nombre) es un Hombre (o Mujer) que reside en la
-- ciudad Caracas del País Venezuela’

SELECT 'El Cliente ' || cli.nombre_cl || ' es un ' || cli.segmento_cl ||
    ' que reside en la ciudad ' || cli.ciudad_cl || ' del País ' ||
    cli.pais_cl AS "Descripcion cliente"
FROM clientes cli;


-- 3) Visualizar los vendedores con la fecha y el total de la factura
-- procesada, los canales de venta a través de las cuales fueron realizadas,
-- ordenado por vendedor en forma ascendente y canales de ventas en forma
-- descendente.

SELECT
    ven.vendedor AS "Nombre vendedor",
    fac.fecha_factura AS "Fecha de factura",
    fac.total_factura AS "Total Factura",
    can.canal_venta AS "Canal de venta"
FROM 
    facturas fac
    JOIN vendedores ven ON fac.fk_vendedores = ven.id_vendedor
    JOIN canales can ON fac.fk_canales = can.id_canal
ORDER BY ven.vendedor ASC, can.canal_venta DESC;


-- 4) Consultar la sucursal, numero del servicio, costo del servicio y nombre
-- del cliente para los clientes cuyo segmento sea ‘HOMBRE’ y el servicio haya
-- durado más de 10 días.

SELECT
    suc.sucursal AS "Sucursal",
    ser.id_servicio AS "Num. servicio",
    ser.costo_servicio AS "Costo",
    cli.nombre_cl AS "Cliente"
FROM 
    servicios ser
    JOIN clientes cli ON ser.fk_clientes = cli.id_cliente
    JOIN sucursales suc ON ser.fk_sucursales = suc.id_sucursal
WHERE cli.segmento_cl = 'HOMBRE'
    AND (ser.fecha_fin_serv - ser.fecha_inicio_serv) > 10;


-- 5) Visualizar un listado de las facturas procesadas en Perú con su número de
-- factura y total facturado con un mensaje que indique el segmento del
-- cliente. Cuando el segmento sea ‘MUJER’ hay que escribir el mensaje
-- ‘SEGMENTO MUJER RESIDE EN EL PAIS XXXXXX’ y es ‘HOMBRE’ escribir el mensaje
-- ‘SEGMENTO HOMBRE Y RESIDE EN LA CIUDAD XXXXXXX’.

SELECT
    fac.id_factura AS "Num. factura",
    fac.total_factura AS "Total factura",
    CASE
        WHEN cli.segmento_cl = 'MUJER'
            THEN 'SEGMENTO MUJER RESIDE EN EL PAIS ' || cli.pais_cl
        WHEN cli.segmento_cl = 'HOMBRE'
            THEN 'SEGMENTO HOMBRE Y RESIDE EN LA CIUDAD ' || cli.ciudad_cl
    END AS mensaje_segmento
FROM 
    facturas fac
    JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
WHERE cli.pais_cl = 'PERÚ';


-- 6) Consultar el nombre del cliente, fecha de la factura, total factura,
-- fecha del cobro y monto del cobro para los clientes cuyo país es ‘España’,
-- que el canal de venta haya sido Punto de Venta y que el monto cobrado fue
-- igual al monto facturado.

SELECT
    cli.nombre_cl AS "Cliente",
    fac.fecha_factura AS "Fecha factura",
    fac.total_factura AS "Total factura",
    cob.fecha_cobro AS "Fecha de cobro",
    cob.valor_cobrado AS "Valor cobrado"
FROM 
    facturas fac
    JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
    JOIN cobranzas cob ON fac.id_factura = cob.fk_facturas
    JOIN canales can ON fac.fk_canales = can.id_canal
WHERE cli.pais_cl = 'ESPAÑA' AND can.canal_venta = 'PUNTOS DE VENTAS'
    AND cob.valor_cobrado = fac.total_factura;


-- 7) Consultar el nombre de vendedor, canal, números de factura, el cobro
-- realizado para la factura y el porcentaje cobrado de la factura en cada
-- cobro, si el porcentaje no corresponde al cobro total de la factura (100%
-- cobrado) escribir ‘Cobro Total’ de lo contrario escribir ‘Cobro Parcial’.
-- Debe ordenar por cliente y numero de factura.

SELECT
    ven.vendedor AS "Vendedor",
    can.canal_venta AS "Canal de venta",
    fac.id_factura AS "Num. factura",
    cob.valor_cobrado AS "Valor cobrado",
    CASE
        WHEN (cob.valor_cobrado / fac.total_factura) = 1
            THEN 'Cobro Total'
        ELSE 'Cobro Parcial'
    END AS "Estado cobro"
FROM 
    facturas fac
    JOIN vendedores ven ON fac.fk_vendedores = ven.id_vendedor
    JOIN canales can ON fac.fk_canales = can.id_canal
    JOIN cobranzas cob ON fac.id_factura = cob.fk_facturas
ORDER BY fac.fk_clientes ASC, fac.id_factura ASC;


-- 8) Consultar los nombres de las sucursales, fechas de inicio y fin del
-- servicio, los nombres de los clientes, las fechas cobros y valores cobrados
-- para los clientes cuyas ciudades contengan más de 6 letras y las fechas de
-- cobro sea del primer trimestre del año 2019. (Lo mas parecido que logre)

SELECT
    suc.sucursal AS "Sucursal",
    ser.fecha_inicio_serv AS "Inicio servicio",
    ser.fecha_fin_serv AS "Final Servicio",
    cli.nombre_cl AS "Cliente",
    cob.fecha_cobro AS "Fecha cobro",
    cob.valor_cobrado AS "Valor cobrado"
FROM 
    servicios ser
    JOIN sucursales suc ON ser.fk_sucursales = suc.id_sucursal
    JOIN clientes cli ON ser.fk_clientes = cli.id_cliente
    JOIN cobranzas cob ON ser.fk_clientes = cob.fk_clientes
WHERE LENGTH(cli.ciudad_cl) > 6
    AND cob.fecha_cobro BETWEEN TO_DATE('2019-01-01', 'YYYY-MM-DD') AND TO_DATE('2019-03-31', 'YYYY-MM-DD')
ORDER BY cli.nombre_cl;

SELECT
    suc.sucursal,
    ser.fecha_inicio_serv,
    ser.fecha_fin_serv,
    cli.nombre_cl,
    cob.fecha_cobro,
    cob.valor_cobrado
FROM sucursales suc
JOIN servicios ser ON suc.id_sucursal = ser.fk_sucursales
JOIN clientes cli ON ser.fk_clientes = cli.id_cliente
JOIN cobranzas cob ON cli.id_cliente = cob.fk_clientes
WHERE fecha_cobro BETWEEN TO_DATE('2019-01-01', 'YYYY-MM-DD') AND TO_DATE('2019-03-31', 'YYYY-MM-DD')
    AND length(ciudad_cl) > 6;

-- 9) Consultar el nombre de las diferentes sucursales que han generado
-- servicios

SELECT DISTINCT suc.sucursal AS "Sucursal"
FROM servicios ser
JOIN sucursales suc ON ser.fk_sucursales = suc.id_sucursal;


-- Parte 2:

-- 1) Motivado que el vendedor es el responsable de las cobranzas se desea
-- consultar el nombre de vendedor y del cliente, el monto total de sus
-- facturas que aparezca como "Facturado", el monto total cobrado que parezca
-- como "Cobrado" y la diferencia por cobrar que aparezca como "Deuda
-- Pendiente", en caso de que no posea diferencia por cobrar colocar 'Deuda
-- Saldada'.

SELECT
    ven.vendedor AS "Vendedor",
    cli.nombre_cl AS "Cliente",
    SUM(fac.total_factura) AS "Facturado",
    CASE
        WHEN SUM(cob.valor_cobrado) IS NULL
            THEN 0
        ELSE SUM(cob.valor_cobrado)
    END AS "Valor cobrado",
    CASE
        WHEN SUM(cob.valor_cobrado) IS NULL
            THEN TO_CHAR(SUM(fac.total_factura))
        WHEN SUM(fac.total_factura) - SUM(cob.valor_cobrado) = 0
            THEN 'Deuda Saldada'
        ELSE TO_CHAR(SUM(fac.total_factura) - SUM(cob.valor_cobrado))
    END AS "Deuda pendiente"
FROM facturas fac
JOIN vendedores ven ON fac.fk_vendedores = ven.id_vendedor
JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
LEFT JOIN cobranzas cob ON fac.id_factura = cob.fk_facturas
GROUP BY ven.vendedor, cli.nombre_cl;


-- 2) Consultar por año la cantidad de facturas realizadas, la cantidad de
-- facturas realizadas debe ser mayor al promedio de facturas para el año. Debe
-- aparecer el año y la cantidad de facturas del respectivo año.

SELECT
    EXTRACT(YEAR FROM fecha_factura) AS "Año",
    COUNT(*) AS "Cantidad de facturas"
FROM facturas
GROUP BY EXTRACT(YEAR FROM fecha_factura)
HAVING
    COUNT(*) >
    (SELECT
        AVG(COUNT(*))
    FROM facturas
GROUP BY EXTRACT(YEAR FROM fecha_factura));


-- 10) Mostrar la cantidad de servicios prestados realizados por canal de venta
-- y el monto total cobrado por dichos servicios en el segundo trimestre del año
-- 2017 para los clientes de España, mostrar para el canal de venta junto con la
-- cantidad de factura y monto total cobrado.  (Lo mas parecido que logre)

SELECT 
    can.canal_venta, 
    COUNT(DISTINCT ser.id_servicio) AS cantidad_servicios, 
    SUM(cob.valor_cobrado) AS monto_total_cobrado
FROM 
    servicios ser
    JOIN clientes cli ON ser.fk_clientes = cli.id_cliente
    JOIN facturas fac ON cli.id_cliente = fac.fk_clientes
    JOIN canales can ON fac.fk_canales = can.id_canal
    JOIN cobranzas cob ON fac.id_factura = cob.fk_facturas
WHERE cli.pais_cl = 'ESPAÑA'
AND ser.fecha_inicio_serv BETWEEN TO_DATE('2017-04-01', 'YYYY-MM-DD') AND TO_DATE('2017-06-30', 'YYYY-MM-DD')
GROUP BY can.canal_venta;


SELECT cli.nombre_cl, ser.servicio, COUNT(fac.id_factura) AS cantidad_facturas
FROM clientes cli
JOIN servicios ser ON cli.id_cliente = ser.fk_clientes
JOIN facturas fac ON cli.id_cliente = fac.fk_clientes
GROUP BY cli.nombre_cl, ser.servicio
ORDER BY cli.nombre_cl, ser.servicio;



-- 11) Consultar para los canales de venta, la cantidad de facturas y monto
-- total promedio facturado solo para facturas de los clientes de 'ARGENTINA'
-- cuya fecha de servicio estén entre el último trimestre del año 2018 y el
-- primer trimestre del año 2019.

SELECT
    can.canal_venta AS "Canal de venta",
    COUNT(*) AS "Cantidad de facturas",
    AVG(fac.total_factura) AS "Monto promedio facturado"
FROM facturas fac
JOIN canales can ON fac.fk_canales = can.id_canal
JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
WHERE cli.pais_cl = 'ARGENTINA'
AND fac.fecha_factura BETWEEN TO_DATE('2018-10-01', 'YYYY-MM-DD') AND TO_DATE('2019-03-31', 'YYYY-MM-DD')
GROUP BY can.canal_venta;


-- 12) Crear una tabla denominada histórico_servicios por año y trimestre con los siguientes datos:
-- • Año
-- • Trimestres
-- • Cantidad de servicios registrados
-- • Monto total del servicio
-- • Cantidad de facturas realizadas
-- • Monto total facturado
-- • Monto total cobrado
-- • Monto total por cobrar
-- • Porcentaje del monto cobrado sobre lo facturado

DROP TABLE historico_servicios CASCADE CONSTRAINTS;

CREATE TABLE historico_servicios (
    año NUMBER(4),
    trimestre NUMBER(1),
    cantidad_servicios NUMBER(10),
    monto_total_servicio NUMBER(10, 2),
    cantidad_facturas NUMBER(10),
    monto_total_facturado NUMBER(10, 2),
    monto_total_cobrado NUMBER(10, 2),
    monto_total_por_cobrar NUMBER(10, 2),
    porcentaje_cobrado NUMBER(5, 2)
);


-- 13) Añadir un constraint de clave primaria a la tabla histórico_servicios
-- compuesta por las columnas año y trimestre.

ALTER TABLE historico_servicios
ADD CONSTRAINT pk_historico_servicios PRIMARY KEY (año, trimestre);


-- 14) Crear una vista denominada costos_servicios, en la cual se debe
-- considerar la el año, la sucursal, el servicio, la fecha de inicio y fin del
-- servicio, el costo o valor del servicio, el costo por hora del servicio,
-- nombre del cliente al cual se realizo el servicio y el nombre de la
-- sucursal. La vista deber ser de solo lectura.

DROP VIEW costos_servicios CASCADE CONSTRAINTS;

CREATE VIEW costos_servicios AS
SELECT
    EXTRACT(YEAR FROM ser.fecha_inicio_serv) AS año,
    suc.sucursal,
    ser.servicio,
    ser.fecha_inicio_serv,
    ser.fecha_fin_serv,
    ser.costo_servicio,
    (ser.costo_servicio / (24 * (ser.fecha_fin_serv - ser.fecha_inicio_serv))) AS costo_por_hora,
    cli.nombre_cl
FROM servicios ser
JOIN sucursales suc ON ser.fk_sucursales = suc.id_sucursal
JOIN clientes cli ON ser.fk_clientes = cli.id_cliente;


-- 15) Utilizando la tabla histórico_servicios y la vista costos_servicios
-- visualizar por año y sucursal el costo por hora del servicio a partir de la
-- tabla histórico_servicios, el costo por hora del servicio a partir de la
-- vista costos_servicios y la diferencia en las mismas. La creación de vistas
-- se encuentra en la documentación de SQL de Oracle.

SELECT
    hs.año AS "Año",
    hs.sucursal AS "Sucursal",
    hs.costo_por_hora AS "Costo por hora historico",
    cs.costo_por_hora AS "Costo por hora vista",
    (hs.costo_por_hora - cs.costo_por_hora) AS "Diferencia"
FROM historico_servicios hs
JOIN costos_servicios cs ON hs.año = cs.año AND hs.sucursal = cs.sucursal;


-- 16) Basado en la vista costos_servicios determinar el costo promedio por
-- hora servicio por susursal

SELECT
    sucursal AS "Sucursal",
    AVG(costo_por_hora) AS "Costo promedio por hora"
FROM costos_servicios
GROUP BY sucursal;



-- 17) Visualizar cantidad de sucursales que tienen alguna cobranza registrada.
-- Aplique subconsulta utilizando la referencia IN o EXIST. (Lo mas parecido
-- que logre)

SELECT COUNT(DISTINCT suc.id_sucursal) AS "Sucursales con cobranza"
FROM sucursales suc
WHERE EXISTS (
    SELECT 1
    FROM servicios ser
    JOIN facturas fac ON ser.fk_clientes = fac.fk_clientes
    JOIN cobranzas cob ON fac.id_factura = cob.fk_facturas
    WHERE ser.fk_sucursales = suc.id_sucursal
);


-- 18) Visualizar para los vendedores el monto total facturado con su
-- respectiva comisión por venta (10% sobre el monto facturado). Mostrar solo
-- aquellos vendedores cuyo monto de facturación total facturado es mayor al
-- promedio de venta de la ciudad de Caracas.

SELECT
    ven.vendedor AS "Vendedor",
    SUM(fac.total_factura) AS "Monto total facturado",
    SUM(fac.total_factura) * 0.1 AS "Comision"
FROM facturas fac
JOIN vendedores ven ON fac.fk_vendedores = ven.id_vendedor
GROUP BY ven.vendedor
HAVING
    SUM(fac.total_factura) >
    (SELECT AVG(total_factura)
    FROM facturas fc
    JOIN clientes cli on fc.fk_clientes = cli.id_cliente
    WHERE cli.ciudad_cl = 'CARACAS');


-- 19) Mostrar cantidad de vendedores que no tienen ninguna factura asociada.

SELECT
    COUNT(DISTINCT ven.id_vendedor) AS "Vendedores sin facturas"
FROM vendedores ven
LEFT JOIN facturas fac on ven.id_vendedor = fac.fk_vendedores
WHERE fac.fk_vendedores IS NULL;


-- 20) Mostrar el nombre de los canales, país y el monto total de iva para
-- aquellas facturas cuyo monto total cobrado es menor al monto total de iva
-- facturado en el año 2019. Utilizar una subconsulta en la cláusula FROM.

SELECT
    can.canal_venta AS "Canal de venta",
    cli.pais_cl AS "Pais cliente",
    SUM(fac.iva) AS "Monto total iva"
FROM
    (SELECT
        f.id_factura,
        f.iva,
        f.fk_clientes,
        f.fk_canales
    FROM
        facturas f
        JOIN cobranzas c ON f.id_factura = c.fk_facturas
    GROUP BY
        f.id_factura,
        f.iva,
        f.fk_clientes,
        f.fk_canales
    HAVING
        SUM(c.valor_cobrado) <
        (SELECT SUM(iva) FROM facturas WHERE EXTRACT(YEAR FROM fecha_factura) = 2019)) fac
    JOIN canales can ON fac.fk_canales = can.id_canal
    JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
    JOIN cobranzas cob ON fac.id_factura = cob.fk_facturas
GROUP BY can.canal_venta, cli.pais_cl;


-- 21) Crear una tabla venta_sucursal con el resultado de una subconsulta por
-- sucursal con el monto total sin iva facturado para los clientes de la
-- sucursal y el monto de la comisión por venta (15% sobre el monto total
-- facturado) cuya duración del servicio no exceda el promedio de las duraciones
-- de la sucursal.

DROP TABLE venta_sucursal CASCADE CONSTRAINTS;

CREATE TABLE venta_sucursal AS
SELECT
    suc.sucursal,
    SUM(fac.vr_antes_iva) AS monto_total_sin_iva,
    SUM(fac.total_factura) * 0.15 AS comision
FROM
    facturas fac
    JOIN servicios ser ON fac.id_factura = ser.id_servicio
    JOIN sucursales suc ON ser.fk_sucursales = suc.id_sucursal
WHERE
    (ser.fecha_fin_serv - ser.fecha_inicio_serv)
    <=
    (SELECT AVG(fecha_fin_serv - fecha_inicio_serv)
    FROM servicios
    WHERE fk_sucursales = suc.id_sucursal)
GROUP BY suc.sucursal;


-- 22) Mostrar el nombre de cliente, el numero de la factura y numero de
-- cobranza de las facturas que tienen cobranzas asociadas, y en la misma
-- consulta mostrar las facturas que no tienen cobranzas asociadas.

SELECT
    cli.nombre_cl AS "Cliente",
    fac.id_factura AS "Num. factura",
    cob.id_cobranza AS "Num. cobranza"
FROM facturas fac
JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
LEFT JOIN cobranzas cob ON fac.id_factura = cob.fk_facturas;


-- Parte 3

-- 1) Se necesita conocer en una sola consulta la suma de los costos de
-- servicios desagregados por nombre de sucursal y nombre del cliente con los
-- subtotales respectivos, y los subtotales por cliente y el total general cuyo
-- país sea ARGENTINA

SELECT
    suc.sucursal AS "Sucursal",
    cli.nombre_cl AS "Cliente",
    SUM(ser.costo_servicio) AS "Suma costos"
FROM servicios ser
JOIN sucursales suc ON ser.fk_sucursales = suc.id_sucursal
JOIN clientes cli ON ser.fk_clientes = cli.id_cliente
WHERE cli.pais_cl = 'CHILE'
GROUP BY ROLLUP (suc.sucursal, cli.nombre_cl);


-- 2) Se necesita conocer en una sola consulta el promedio de los valores
-- cobrados desagregados por nombre de cliente y nombre del canal de venta con
-- los subtotales respectivos y total general para las facturas generadas en el
-- segundo trimestre del año 2019.

SELECT
    cli.nombre_cl AS "Cliente",
    can.canal_venta AS "Canal de venta",
    AVG(cob.valor_cobrado) AS "Promedio cobrado"
FROM
    facturas f
    JOIN clientes cli ON f.fk_clientes = cli.id_cliente
    JOIN canales can ON f.fk_canales = can.id_canal
    JOIN cobranzas cob ON f.id_factura = cob.fk_facturas
WHERE f.fecha_factura BETWEEN TO_DATE('2019-04-01', 'YYYY-MM-DD') AND TO_DATE('2019-06-30', 'YYYY-MM-DD')
GROUP BY CUBE (cli.nombre_cl, can.canal_venta)
ORDER BY cli.nombre_cl, can.canal_venta;


-- 3) Se necesita conocer en una sola consulta el promedio de los montos
-- facturados desagregados por dos grupos (agrupamientos): 1) nombre de cliente
-- y nombre del canal de venta, 2) nombre de cliente y nombre de vendedor con
-- los subtotales respectivos para el año que más se facturo.

SELECT
    cli.nombre_cl AS "Cliente",
    ven.vendedor AS "Vendedor",
    can.canal_venta AS "Canal de venta",
    AVG(fac.total_factura) AS "Promedio facturado"
FROM
    facturas fac
    JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
    JOIN vendedores ven ON fac.fk_vendedores = ven.id_vendedor
    JOIN canales can ON fac.fk_canales = can.id_canal
WHERE 
    EXTRACT(YEAR FROM fac.fecha_factura) = (
        SELECT a.anho
        FROM
            (SELECT EXTRACT(YEAR FROM f.fecha_factura) AS anho
            FROM facturas f
            GROUP BY EXTRACT(YEAR FROM f.fecha_factura)
            ORDER BY AVG(f.total_factura) DESC) a
        WHERE ROWNUM = 1)
GROUP BY GROUPING SETS ((cli.nombre_cl, can.canal_venta), (cli.nombre_cl, ven.vendedor))
ORDER BY cli.nombre_cl, can.canal_venta, ven.vendedor;


-- 4) Realice la consulta de los agrupamientos solicitada en el item 3 mediante
-- los operadores UNION ALL.

SELECT
    cli.nombre_cl AS "Cliente",
    NULL AS "Vendedor",
    can.canal_venta AS "Canal de venta",
    AVG(fac.total_factura) AS "Promedio facturado"
FROM
    facturas fac
    JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
    JOIN canales can ON fac.fk_canales = can.id_canal
WHERE 
    EXTRACT(YEAR FROM fac.fecha_factura) = (
        SELECT a.anho
        FROM
            (SELECT EXTRACT(YEAR FROM f.fecha_factura) AS anho
            FROM facturas f
            GROUP BY EXTRACT(YEAR FROM f.fecha_factura)
            ORDER BY AVG(f.total_factura) DESC) a
        WHERE ROWNUM = 1
    )
GROUP BY 
    cli.nombre_cl, can.canal_venta
UNION ALL
SELECT
    cli.nombre_cl AS "Cliente",
    ven.vendedor AS "Vendedor",
    NULL AS "Canal de venta",  -- No hay canal de venta en esta agrupación
    AVG(fac.total_factura) AS "Promedio facturado"
FROM
    facturas fac
    JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
    JOIN vendedores ven ON fac.fk_vendedores = ven.id_vendedor
WHERE 
    EXTRACT(YEAR FROM fac.fecha_factura) = (
        SELECT a.anho
        FROM
            (SELECT EXTRACT(YEAR FROM f.fecha_factura) AS anho
            FROM facturas f
            GROUP BY EXTRACT(YEAR FROM f.fecha_factura)
            ORDER BY AVG(f.total_factura) DESC) a
        WHERE ROWNUM = 1
    )
GROUP BY 
    cli.nombre_cl, ven.vendedor
ORDER BY cli.nombre_cl, can.canal_venta, ven.vendedor;
