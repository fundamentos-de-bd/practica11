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


-- Gastos mensuales en sueldos de los departamentos de Farmacia y Abarrotes
-- con el número de empleados en estos.
--NOTA: Los registros de sueldo se hacen por epleado, no puesto.
SELECT SUM(sueldo) gastos, COUNT(sueldo) empleados
    FROM (
        SELECT sueldo, DECODE (id_tipo_dep, 'A', 'Considerado',
                                            'F', 'Considerado',
                              'noConsiderado') criterio
            FROM SUELDO
        )
    WHERE criterio = 'Considerado';


--Obtiene la lista de teléfonos de los departamentos de todas las sucursales con
-- un departamento de farmacia ó vinos y licores.
SELECT *
    FROM (SELECT DISTINCT id_suc id_sucursal
        FROM (
            SELECT id_suc, DECODE (id_tipo, 'A', 'Considerado',
                                            'VYL', 'Considerado',
                                  'noConsiderado') criterio
                FROM tener_departamento
            )
        WHERE criterio = 'Considerado'
    ) NATURAL JOIN telefono_sucursal;



--Del registro de productos, toma aquellos que son agua embotellada y agrupando por marcas
-- reporta los precios máximos.
SELECT presentacion, cantidad, max(PRECIO) precio_máximo, agua as marca_agua
FROM (producto NATURAL JOIN (SELECT codigo_barras, descripcion FROM instancia_producto))
    PIVOT (max(marca)  -- Rellena nuestra columna con estos valores
    FOR descripcion -- Usa este campo como base para las columnas
    IN ('Agua embotellada' as agua) 
        -- Crea una única columna que rellena con marca
        --  unicamente si coincide el campo de la tupla con 'Agua embotellada'.
        --  si no coincide, pone un (null).
    )
HAVING agua IS NOT NULL
GROUP BY agua, presentacion, cantidad;


--Recupera los datos de todos los productos cuya fecha de caducidad coincide
--con (07/06/19) que no han sido vendidos.
--i.e. mustra productos en stock que cauducan el (07/06/19) con su lote.
--NOTA: si cuando insertas la tupla usas CURRENT_DATE o pones una fecha con una
--  hora, la consulta no va a considerarla como lo mismo :/.
--  Esto sirve 
--       INSERT INTO lote VALUES (3404510077, 001, TO_DATE ('07/06/19', 'dd/mm/yy'));
SELECT *
    FROM producto NATURAL JOIN
    (SELECT id_produccion, COUNT(id_venta) numero_en_inventario
        FROM (instancia_producto NATURAL JOIN (
            SELECT *
            FROM lote
                PIVOT (max(codigo_barras)  -- Rellena nuestra columna con estos valores
                FOR fecha_cad -- Usa este campo como base para las columnas
                IN ( (TO_DATE ('07/06/19', 'dd/mm/yy')) as codigo_barras)
                )
            )
        )WHERE id_venta IS NULL
        GROUP BY id_produccion
    );


--Usando todos los registros de personas lista las 'palabras' que hay junto con
--su clasificación como parte de un nombe(apellidoP,apellidoM o nombre) depurando
--los NULL y manteniendo a las personas registradas anónimas.
--NOTA: Supongo que algo así sería útil para entrenar un sistema que verifica 
--      si un nombre es correcto o algo así :S
SELECT parte_nombre, palabra
FROM persona
    UNPIVOT (palabra -- Nuevo campo donde se reflejará el conteo de registros con 
    FOR parte_nombre -- Campo en el que se fusionan los campos VALOR1 y VALOR2
    IN (nombre, apellido_p, apellido_m)
    )
WHERE palabra IS NOT NULL
ORDER BY parte_nombre;

--Del registro de productos, toma aquellos que son agua embotellada y agrupando por marcas
-- reporta los precios máximos. PERO esta vez reconstruye la columna marca :p
SELECT presentacion, cantidad, precio_máximo, marca, 'Agua embotellada' as descripcion
    FROM(
        SELECT presentacion, cantidad, max(PRECIO) precio_máximo, agua as marca_agua
        FROM (producto NATURAL JOIN (SELECT codigo_barras, descripcion FROM instancia_producto))
            PIVOT (max(marca)
            FOR descripcion
            IN ('Agua embotellada' as agua) 
            )
        HAVING agua IS NOT NULL
        GROUP BY agua, presentacion, cantidad
    )
    UNPIVOT (marca --Nuevo campo donde se reflejará el contenido de los registros 
    FOR decripcion
    IN (marca_agua)
    );

--Datos de los clientes con total de dinero gastado mayor a X, registrados en 
--CDMX o Chihuahua o  Morelos y que son mayores de 20 años
SELECT id_cliente,nombre,apellido_p,apellido_m,curp,dinero_gastado
    FROM Persona 
         NATURAL JOIN
         (
            (SELECT id_cliente, dinero_gastado
                FROM ((SELECT num_tarjeta, SUM(importe) dinero_gastado
                        FROM metodo_pago
                        GROUP BY num_tarjeta)
                        NATURAL JOIN
                        tarjeta
                     )
            ) NATURAL JOIN
            (SELECT curp, id_cliente, fecha_nac
                FROM (
                    (SELECT curp, id_cliente, (
                            CASE 
                                WHEN REGEXP_LIKE (curp, '^.{11}CX.{5}') THEN 'ok'
                                WHEN REGEXP_LIKE (curp, '^.{11}CH.{5}') THEN 'ok'
                                WHEN REGEXP_LIKE (curp, '^.{11}MO.{5}') THEN 'ok' 
                                ELSE 'no'
                            END
                        ) tipo_cliente
                        FROM cliente
                    ) 
                    NATURAL JOIN 
                    (SELECT curp, fecha_nac
                        FROM persona
                        WHERE (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM fecha_nac)) > 20
                    )
                )
                WHERE fecha_nac IS NOT NULL AND tipo_cliente = 'ok'
            )
        );


--Sueldo promedio de todos los CAJEROS por SEXO y sucursal
SELECT id_suc, sexo, AVG(sueldo) promedio
    FROM(SELECT id_suc, sueldo,(
                                CASE 
                                    WHEN REGEXP_LIKE (curp, '^.{10}H.{7}') THEN 'ok'
                                    WHEN REGEXP_LIKE (curp, '^.{10}M.{7}') THEN 'ok' 
                                    ELSE 'no'
                                END
                            ) as sexo
        FROM (sueldo NATURAL JOIN (empleado NATURAL JOIN trabajar))
    )
    GROUP BY id_suc, sexo;

