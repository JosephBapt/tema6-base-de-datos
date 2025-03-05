-- 1) 
-- Desplegar por número de factura, fecha de la factura, el nombre del canal
-- de venta, las fechas y montos de cada cobro realizados sobre la factura. Si
-- el cobro acumulado de la factura corresponde al cobro del monto total de la
-- factura escribir ‘La factura 99999 del cliente xxxx de monto 9999,99 fue
-- Cobrada en su totalidad’ y en el caso contrario escribir ‘La factura 99999
-- del cliente xxxx de monto 9999,99 fue cobrada parcialmente por un monto de
-- 9.9999,99 y tiene una de deuda pendiente de 9.999,99’. Debe ordenarse por
-- cliente, numero de factura y numero de cobranza. Dicha consulta deberá
-- realizarse con las siguientes indicaciones:
-- 
-- a) Realice un bloque PL/SQL que realice dicho requerimiento sin utilizar
-- funciones de grupo ni las cláusulas GROUP BY, HANING, UNION y CASE.
-- 
-- b) Utilizar mínimo dos (2) cursores.

DECLARE
    -- Varibles para almacenar
    id_factura facturas.id_factura%TYPE;
    fecha_factura facturas.fecha_factura%TYPE; 
    canal_venta canales.canal_venta%TYPE;
    nombre_cl clientes.nombre_cl%TYPE;
    fecha_cobro cobranzas.fecha_cobro%TYPE; 
    valor_cobrado cobranzas.valor_cobrado%TYPE;
    deuda_pendiente facturas.total_factura%TYPE;
    total_cobrado facturas.total_factura%TYPE;
    total_factura facturas.total_factura%TYPE;

    -- Cursor para conseguir las facturas
    CURSOR get_factura IS 
        SELECT fac.id_factura, fac.fecha_factura, fac.total_factura, can.canal_venta, cli.nombre_cl
        FROM facturas fac
            JOIN canales can ON fac.fk_canales = can.id_canal
            JOIN clientes cli ON fac.fk_clientes = cli.id_cliente
        ORDER BY cli.nombre_cl ASC, fac.id_factura ASC;

    -- Cursor para conseguir los cobros de una factura especifica
    CURSOR get_cobro_factura(id_factura facturas.id_factura%TYPE) IS 
        SELECT cob.fecha_cobro, cob.valor_cobrado
        FROM cobranzas cob
        WHERE cob.fk_facturas = id_factura
        ORDER BY cob.id_cobranza;
BEGIN
    OPEN get_factura;

    LOOP
        FETCH get_factura INTO id_factura, fecha_factura, total_factura, canal_venta, nombre_cl;
        EXIT WHEN get_factura%NOTFOUND;

        OPEN get_cobro_factura(id_factura);

        total_cobrado := 0;

        LOOP
            FETCH get_cobro_factura INTO fecha_cobro, valor_cobrado;
            EXIT WHEN get_cobro_factura%NOTFOUND;

            total_cobrado := total_cobrado + valor_cobrado;
        END LOOP;

        deuda_pendiente := total_factura - total_cobrado;

        IF deuda_pendiente = 0 THEN
            DBMS_OUTPUT.PUT_LINE('La factura ' || id_factura || ' del cliente ' || nombre_cl || ' de monto ' || total_factura || ' fue Cobrada en su totalidad');
        ELSE
            DBMS_OUTPUT.PUT_LINE('La factura ' || id_factura || ' del cliente ' || nombre_cl || ' de monto ' || total_factura || ' fue cobrada parcialmente por un monto de ' || total_cobrado || ' y tiene una deuda pendiente de ' || deuda_pendiente);
        END IF;

        CLOSE get_cobro_factura;

    END LOOP;

    CLOSE get_factura;
END;
/


-- 2)
-- Se requiere un procedimiento que se dispare el tercer dia de cada mes para
-- que cargue la tabla de comisiones de los vendedores. La tabla
-- RESUMEN_COMISIONES_VENDEDORES deberá crearse a través con las siguientes
-- estructuras: 
--
-- • Año 
-- • Mes 
-- • Vendedor 
-- • Cantidad de facturas asociadas 
-- • Monto total facturado de facturas asociadas 
-- • Monto total cobrado de facturas asociadas 
-- • Monto total por cobrar de facturas asociadas 
-- • Porcentaje de comisión 
-- • Monto de Comisión en función del monto total cobrado 
--
-- Escriba un procedimiento PL/SQL que cargue la tabla sin utilizar las
-- cláusulas GROUP BY y HANING con las siguientes condiciones:
--
-- a) Los parámetros del procedimiento deben ser el año, mes y porcentaje.
-- 
-- b) Realizar mediante funciones las siguientes validaciones: 
-- • Que el año a cargar posea transacciones en la tabla facturas. 
-- • Que el mes a procesar sea el siguiente al último mes procesado. 
-- • El cálculo de la comisión sea a través de una función. 
-- • El porcentaje de comisión es el 15%
-- 
-- c) Una vez cargada la tabla realizar una función PL/SQL que calcule y
-- devuelva el vendedor con mayor comisión y actualizar la comisión con 5%
-- adicional.


DROP TABLE resumen_comisiones_vendedores CASCADE CONSTRAINTS;
/
-- Crea la tabla RESUMEN_COMISIONES_VENDEDORES
CREATE TABLE resumen_comisiones_vendedores(
    anho NUMBER(4),
    mes NUMBER(2),
    fk_vendedores VARCHAR2(3 CHAR),
    cantidad_facturas NUMBER(5),
    monto_total_facturado NUMBER(10,2),
    monto_total_cobrado NUMBER(10,2),
    monto_total_por_cobrar NUMBER(10,2),
    porcentaje_comision NUMBER(4,3),
    monto_comision NUMBER(10,2),

    CONSTRAINT resumen_com_pk PRIMARY KEY (anho, mes, fk_vendedores),
    CONSTRAINT resumen_vendedores_fk FOREIGN KEY (fk_vendedores) REFERENCES vendedores(id_vendedor)
);
/

-- Función para validar si el año tiene transacciones
CREATE OR REPLACE FUNCTION existe_anho(anho NUMBER) RETURN BOOLEAN IS 
    cantidad NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO cantidad 
    FROM facturas 
    WHERE EXTRACT(YEAR FROM fecha_factura) = anho;

    RETURN cantidad > 0;
END;
/

-- Función para validar si el mes es el siguiente al último procesado
CREATE OR REPLACE FUNCTION validar_mes(anho NUMBER, mes NUMBER) RETURN BOOLEAN IS
    ultimo_mes NUMBER;
BEGIN
    SELECT nvl(max(res.mes), 0) INTO ultimo_mes
    FROM resumen_comisiones_vendedores res
    WHERE res.anho = anho;

    RETURN mes = ultimo_mes + 1;
END;
/


-- Función para calcular la comisión
CREATE OR REPLACE FUNCTION calcular_comision(monto_facturado NUMBER, porcentaje NUMBER) RETURN NUMBER IS
BEGIN
    RETURN monto_facturado * porcentaje;
END;
/

-- Función para verificar porcentaje de comision

CREATE OR REPLACE FUNCTION validar_porcentaje(porcentaje NUMBER) RETURN BOOLEAN IS 
BEGIN
    RETURN porcentaje = 0.15;
END;
/


-- Procedimiento para cargar las comisiones
CREATE OR REPLACE PROCEDURE cargar_comisiones(v_anho NUMBER, v_mes NUMBER, v_porcentaje NUMBER) 
IS
    v_fk_vendedores resumen_comisiones_vendedores.fk_vendedores%TYPE;
    v_cantidad_facturas resumen_comisiones_vendedores.cantidad_facturas%TYPE;
    v_monto_total_facturado resumen_comisiones_vendedores.monto_total_facturado%TYPE;
    v_monto_total_cobrado resumen_comisiones_vendedores.monto_total_cobrado%TYPE;
    v_monto_total_por_cobrar resumen_comisiones_vendedores.monto_total_por_cobrar%TYPE;
    v_porcentaje_comision resumen_comisiones_vendedores.porcentaje_comision%TYPE;
    v_monto_comision resumen_comisiones_vendedores.monto_comision%TYPE;
    v_id_factura facturas.id_factura%TYPE;
    v_total_factura facturas.total_factura%TYPE;
    v_valor_cobrado cobranzas.valor_cobrado%TYPE;
    
    CURSOR get_vendedorb IS SELECT id_vendedor FROM vendedores ORDER BY vendedor ASC;

    CURSOR get_facturab(anho_f NUMBER, mes_f NUMBER, vendedor_f vendedores.id_vendedor%TYPE) IS 
        SELECT fac.id_factura, fac.total_factura 
        FROM facturas fac
        WHERE 
            fac.fk_vendedores = vendedor_f 
            AND EXTRACT(YEAR FROM fac.fecha_factura) = anho_f
            AND EXTRACT(MONTH FROM fac.fecha_factura) = mes_f;
    
    CURSOR get_cobranzasb(id_factura_c facturas.id_factura%TYPE) IS 
        SELECT cob.valor_cobrado
        FROM cobranzas cob
        WHERE cob.fk_facturas = id_factura_c;
BEGIN
    -- Validar el año
    IF NOT existe_anho(v_anho) THEN
        RAISE_APPLICATION_ERROR(-20001, 'El año no tiene transacciones en la tabla facturas.');
    END IF;

    -- Validar el mes
    IF NOT validar_mes(v_anho, v_mes) THEN
        RAISE_APPLICATION_ERROR(-20002, 'El mes no es el siguiente al último procesado.');
    END IF;

    IF NOT validar_porcentaje(v_porcentaje) THEN
        RAISE_APPLICATION_ERROR(-20003, 'El porcentaje no es del 15%');
    END IF;

    OPEN get_vendedorb;
    LOOP
        FETCH get_vendedorb INTO v_fk_vendedores;
        EXIT WHEN get_vendedorb%NOTFOUND;

        v_cantidad_facturas := 0;
        v_monto_total_facturado := 0;
        v_monto_total_cobrado := 0;
        v_monto_total_por_cobrar := 0;
        v_monto_comision := 0;

        OPEN get_facturab(v_anho, v_mes, v_fk_vendedores);
        LOOP
            FETCH get_facturab INTO v_id_factura, v_total_factura;
            EXIT WHEN get_facturab%NOTFOUND;

            v_cantidad_facturas := v_cantidad_facturas + 1;
            v_monto_total_facturado := v_monto_total_facturado + v_total_factura;

            OPEN get_cobranzasb(v_id_factura);
            LOOP
                FETCH get_cobranzasb INTO v_valor_cobrado;
                EXIT WHEN get_cobranzasb%NOTFOUND;
                
                v_monto_total_cobrado := v_monto_total_cobrado + v_valor_cobrado;
            END LOOP;
            CLOSE get_cobranzasb;
        END LOOP;
        CLOSE get_facturab;

        v_monto_total_por_cobrar := v_monto_total_facturado - v_monto_total_cobrado;
        v_monto_comision := calcular_comision(v_monto_total_facturado, v_porcentaje);

        INSERT INTO RESUMEN_COMISIONES_VENDEDORES
            (anho,
            mes,
            fk_vendedores,
            cantidad_facturas,
            monto_total_facturado,
            monto_total_cobrado,
            monto_total_por_cobrar,
            porcentaje_comision,
            monto_comision)
        VALUES
            (v_anho,
            v_mes,
            v_fk_vendedores,
            v_cantidad_facturas,
            v_monto_total_facturado,
            v_monto_total_cobrado,
            v_monto_total_por_cobrar,
            v_porcentaje,
            v_monto_comision);
    END LOOP;
    CLOSE get_vendedorb;
END;
/
BEGIN

DBMS_SCHEDULER.CREATE_JOB (
   job_name             => 'cada 3er dia',
   job_type             => 'STORED_PROCEDURE',
   job_action           => 'BEGIN cargar_comisiones(EXTRACT(YEAR FROM sysdate), EXTRACT(MONTH FROM sysdate)); END;',
   start_date           => sysdate,
   repeat_interval      => 'FREQ=MONTHLY; BYDAY=3',
   end_date             => NULL, -- or any end date
   enabled              =>  TRUE,
   comments             => 'Carga las comisiones el tercer dia de cada mes');

END;
SELECT EXTRACT(MONTH FROM sysdate) FROM dual;

CREATE OR REPLACE FUNCTION mejor_vendedor(v_anho NUMBER, v_mes NUMBER) RETURN BOOLEAN IS 
BEGIN
    UPDATE resumen_comisiones_vendedores
    SET porcentaje_comision = porcentaje_comision + 0.05, monto_comision = monto_comision + monto_total_facturado * 0.05
    WHERE fk_vendedores = 
        (SELECT fk_vendedores 
        FROM (
            SELECT monto_comision 
            FROM resumen_comisiones_vendedores 
            WHERE 
                v_anho = anho
                AND v_mes = mes
            ORDER BY monto_comision DESC) 
        WHERE ROWNUM = 1);

    RETURN TRUE;
END;
/


-- 3)
-- Crear los trigger necesarios en la tabla Servicios para validar que los datos
-- sean validos al momento de la inserción o actualización o eliminar un
-- servicio.

-- CREATE TABLE servicios (
--     id_servicio             VARCHAR2(5 CHAR) NOT NULL,
--     fecha_inicio_serv       DATE NOT NULL,
--     fecha_fin_serv          DATE NOT NULL,
--     servicio                VARCHAR2(300 CHAR) NOT NULL,
--     costo_servicio          NUMBER(6, 2) NOT NULL,
--     fk_sucursales           VARCHAR2(3 CHAR) NOT NULL,
--     fk_clientes             VARCHAR2(5 CHAR) NOT NULL
-- );

CREATE OR REPLACE TRIGGER validacion_servicio
BEFORE INSERT OR UPDATE OR DELETE ON servicios
FOR EACH ROW
BEGIN
-- Valida la insercion a la tabla servicios
    IF INSERTING THEN
        IF :NEW.fecha_inicio_serv >= :NEW.fecha_fin_serv THEN
            RAISE_APPLICATION_ERROR(-20010, 'La fecha de inicio debe ser menor que la fecha de finalizacion');
        END IF:
        IF NOT :NEW.costo_servicio > 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'El costo del servicio debe ser mayor a 0');
        END IF:
        IF NOT EXIST (SELECT 1 FROM sucursales WHERE id_sucursal = :NEW.fk_sucursales) THEN
            RAISE_APPLICATION_ERROR(-20012, 'La columna fk_sucursales debe ser la id de una sucursal existente');
        END IF;
        IF NOT EXIST (SELECT 1 FROM clientes WHERE id_cliente = :NEW.fk_clientes) THEN
            RAISE_APPLICATION_ERROR(-20013, 'La columna fk_clientes debe ser la id de un cliente existente');
        END IF;
    END IF;
-- Valida la actualizacion a la tabla servicios
    IF UPDATING THEN
        IF :NEW.fecha_inicio_serv >= :NEW.fecha_fin_serv THEN
            RAISE_APPLICATION_ERROR(-20010, 'La fecha de inicio debe ser menor que la fecha de finalizacion');
        END IF:
        IF NOT :NEW.costo_servicio > 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'El costo del servicio debe ser mayor a 0');
        END IF:
        IF NOT EXIST (SELECT 1 FROM sucursales WHERE id_sucursal = :NEW.fk_sucursales) THEN
            RAISE_APPLICATION_ERROR(-20012, 'La columna fk_sucursales debe ser la id de una sucursal existente');
        END IF;
        IF NOT EXIST (SELECT 1 FROM clientes WHERE id_cliente = :NEW.fk_clientes) THEN
            RAISE_APPLICATION_ERROR(-20013, 'La columna fk_clientes debe ser la id de un cliente existente');
        END IF;
    END IF;
-- Valida la eliminacion a la tabla servicios
    IF DELETING THEN
    END IF;
END;
/
