-- La cantidad de empleados que son cajeros cuyo CURP indica como 
-- estado de origen TK.
SELECT puesto, COUNT(puesto) num_trabajos
    FROM
        (SELECT curp
            FROM persona
            WHERE REGEXP_LIKE (curp, '^.{11}TK.{5}')
        ) NATURAL JOIN empleado
    GROUP BY puesto
    HAVING puesto LIKE  'CAJERO';
        
-- Información de todos los empleados que son hombre y que trabajan en el
-- departamento de abarrotes de la sucursal 1.
SELECT *
    FROM
        (SELECT curp, nombre, apellido_p, apellido_m
            FROM persona
            WHERE REGEXP_LIKE (curp, '^.{10}H.{7}')
        ) NATURAL JOIN (
        SELECT *
            FROM (empleado NATURAL JOIN trabajar)
            WHERE tipo_dep = 'A' AND id_suc = 1
        );

-- Cantidad de empleados por tipo de empleo, agrupados por sucursal.
SELECT id_suc, tipo_trabajo, COUNT(id_empleado) num_empleados 
    FROM (
    SELECT id_empleado,
    (
        CASE puesto
            WHEN 'GERENTE' THEN 'ADMINISTRATIVO'
            WHEN 'SUPERVISOR' THEN 'ADMINISTRATIVO'
            WHEN 'CAJERO' THEN 'SERVICIO AL CLIENTE'
            WHEN 'CONSERJE' THEN 'INTENDENCIA'
            ELSE 'ASALARIADO'
        END
    ) tipo_trabajo
    FROM empleado
    ) NATURAL JOIN trabajar
    GROUP BY id_suc, tipo_trabajo
    ORDER BY id_suc;

-- Clasificando los clientes registrados la cantidad de veces han comprado en 
-- promedio por mes en los últimos doce meses.
SELECT tipo_cliente, id_cliente, nombre, apellido_p, apellido_m
    FROM (
        SELECT id_cliente, (
            CASE 
                WHEN prom_compras_mes > 4 THEN 'FRECUENTE'
                WHEN prom_compras_mes > 2 THEN 'CASUAL'
                WHEN prom_compras_mes > 1 THEN 'POCO FRECUENTE' 
                ELSE 'NO SIGNIFICATIVO'
            END
        ) tipo_cliente
        FROM (
            SELECT id_cliente, COUNT(id_cliente)/12 prom_compras_mes
                FROM (
                    SELECT num_tarjeta
                        FROM venta
                        WHERE (CURRENT_DATE - fecha) <= 365.25
                ) NATURAL JOIN tarjeta
            GROUP BY id_cliente
        )
    ) NATURAL JOIN persona
    ORDER BY tipo_cliente, id_cliente;
