-- Creando la tabla para la relacion de Producto
CREATE TABLE producto (
    codigo_barras NUMBER(20),
    precio NUMBER(10) DEFAULT 0,
    presentacion VARCHAR(100),
    cantidad VARCHAR(10) DEFAULT 0,
    es_refrigerado NUMBER(1) DEFAULT 0,
    marca VARCHAR(100) NOT NULL
);

ALTER TABLE producto 
    ADD CONSTRAINT pk_producto
    PRIMARY KEY (codigo_barras);
    
ALTER TABLE producto
    ADD CONSTRAINT ck_es_refrigerado
    CHECK (es_refrigerado IN (0, 1));
    
-- Creando tabla para la relac�n de Medicamento
CREATE TABLE medicamento (
    id_prod NUMBER(10) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    laboratorio VARCHAR(100) NOT NULL,
    dosis NUMBER(10),
    es_controlado NUMBER(1) DEFAULT 0
);
    
ALTER TABLE medicamento
    ADD CONSTRAINT pk_medicamento
    PRIMARY KEY (nombre, laboratorio);
    
ALTER TABLE medicamento
    ADD CONSTRAINT fk_producto
    FOREIGN KEY (id_prod)
    REFERENCES producto(codigo_barras)
    ON DELETE CASCADE;
    
ALTER TABLE medicamento
    ADD CONSTRAINT ck_es_controlado
    CHECK (es_controlado IN (0, 1));
    
-- Creando tabla para la relaci�n Compuestos
CREATE TABLE compuestos (
    sustancia VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    laboratorio VARCHAR(100) NOT NULL
);

ALTER TABLE compuestos 
    ADD CONSTRAINT fk_medicamento
    FOREIGN KEY (nombre, laboratorio)
    REFERENCES medicamento(nombre, laboratorio)
    ON DELETE CASCADE;
    
-- Creando la tabla para la relaci�n de Lote
CREATE TABLE lote (
    codigo_barras NUMBER(20) NOT NULL,
    id_produccion NUMBER(10) NOT NULL,
    fecha_cad DATE NOT NULL
);

ALTER TABLE lote
    ADD CONSTRAINT fk_cod_barr
    FOREIGN KEY (codigo_barras)
    REFERENCES producto(codigo_barras)
    ON DELETE CASCADE;
    
ALTER TABLE lote
    ADD CONSTRAINT pk_lote
    PRIMARY KEY (id_produccion);
    
-- Creando tabla para la relaci�n de Tipo Departamento
CREATE TABLE tipo_departamento (
    tipo VARCHAR(100),
    descripcion VARCHAR(500)
);

ALTER TABLE tipo_departamento
    ADD CONSTRAINT pk_tipo_dep
    PRIMARY KEY (tipo);
    
ALTER TABLE tipo_departamento
    ADD CONSTRAINT  ch_tipo_dep_tipo
    CHECK (tipo IN ('VYL', 'F', 'A'));
    
-- Creando la tabla para la relaci�n de Sucursal
CREATE TABLE sucursal (
    id_sucursal NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    fecha_func DATE DEFAULT CURRENT_DATE,
    calle VARCHAR(100) NOT NULL,
    numero NUMBER(10),
    cp NUMBER(5) NOT NULL,
    estado VARCHAR(15) NOT NULL
);

ALTER TABLE sucursal  
    ADD CONSTRAINT pk_sucursal
    PRIMARY KEY (id_sucursal);
    
-- Creando tabla para tel�fono de sucursales
CREATE TABLE telefono_sucursal (
    num_tel NUMBER(10) NOT NULL,
    id_sucursal NUMBER(10) NOT NULL
);

ALTER TABLE telefono_sucursal
    ADD CONSTRAINT fk_sucursal
    FOREIGN KEY (id_sucursal)
    REFERENCES sucursal(id_sucursal)
    ON DELETE CASCADE;
    
-- Creando tabla para la relaci�n de Tener Departamento
CREATE TABLE tener_departamento (
    id_suc NUMBER(10) NOT NULL,
    id_tipo VARCHAR(100) NOT NULL
);

ALTER TABLE tener_departamento 
    ADD CONSTRAINT ck_tener_departamento
    UNIQUE (id_suc, id_tipo);

ALTER TABLE tener_departamento
    ADD CONSTRAINT fk_suc
    FOREIGN KEY (id_suc)
    REFERENCES sucursal(id_sucursal)
    ON DELETE CASCADE;
    
ALTER TABLE tener_departamento
    ADD CONSTRAINT fk_tipo_dep
    FOREIGN KEY (id_tipo)
    REFERENCES tipo_departamento(tipo)
    ON DELETE CASCADE;
    
-- Creando la tabla para la relacion de Persona
CREATE TABLE persona (
    curp VARCHAR(18),
    nombre VARCHAR(100) NOT NULL,
    apellido_p VARCHAR(100) NOT NULL,
    apellido_m VARCHAR(100),
    fecha_nac DATE
);

ALTER TABLE persona
    ADD CONSTRAINT pk_persona
    PRIMARY KEY (curp);

-- Creando tabla para tel�fono de personas
CREATE TABLE telefono_persona (
    num_tel NUMBER(10) NOT NULL,
    curp VARCHAR(12) NOT NULL
);

ALTER TABLE telefono_persona 
    ADD CONSTRAINT fk_persona
    FOREIGN KEY (curp)
    REFERENCES persona(curp)
    ON DELETE CASCADE;
    
-- Creando table para la relacion Cliente
CREATE TABLE cliente (
    id_cliente NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    calle VARCHAR(100) NOT NULL,
    numero_ext VARCHAR(10),
    numero_int VARCHAR(10),
    cp NUMBER(5) NOT NULL,
    curp VARCHAR(18) NOT NULL,
    fecha_reg DATE DEFAULT CURRENT_DATE
);

ALTER TABLE cliente
    ADD CONSTRAINT pk_cliente
    PRIMARY KEY (id_cliente);
    
ALTER TABLE cliente
    ADD CONSTRAINT fk_persona_cl
    FOREIGN KEY (curp)
    REFERENCES persona(curp)
    ON DELETE CASCADE;

-- Creando tabla para Tarjeta
CREATE TABLE tarjeta (
    num_tarjeta NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_cliente NUMBER(10) NOT NULL
);

ALTER TABLE tarjeta 
    ADD CONSTRAINT pk_tarjeta
    PRIMARY KEY (num_tarjeta);
    
ALTER TABLE tarjeta
    ADD CONSTRAINT fk_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_cliente)
    ON DELETE CASCADE;
    
    
-- Creando tabla para E-mail de los clientes
CREATE TABLE email (
    id_cliente NUMBER(10) NOT NULL,
    email VARCHAR(20) NOT NULL
);

ALTER TABLE email
    ADD CONSTRAINT fk_cliente_mail
    FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_cliente);

ALTER TABLE email
    ADD CONSTRAINT ch_email
    CHECK (email LIKE '.%[@].%[.].%');

-- Tabla para la relaci�n Horario
CREATE TABLE horario (
    id_tipo_dep VARCHAR(100) NOT NULL,
    puesto VARCHAR(80),
    hora_entrada NUMBER(10),
    hora_salida NUMBER(10)
);

ALTER TABLE horario
    ADD CONSTRAINT pk_horario
    PRIMARY KEY (id_tipo_dep, puesto);

ALTER TABLE horario
    ADD CONSTRAINT fk_id_tipo_dep_hor
    FOREIGN KEY (id_tipo_dep)
    REFERENCES tipo_departamento(tipo)
    ON DELETE CASCADE;


-- Creando tabla para la relaci�n Sueldo
CREATE TABLE sueldo (
    id_tipo_dep VARCHAR(100),
    puesto VARCHAR(80),
    registro DATE DEFAULT CURRENT_DATE,
    sueldo NUMBER(10) NOT NULL
);

ALTER TABLE sueldo
    ADD CONSTRAINT fk_tipo_dep_sueldo
    FOREIGN KEY (id_tipo_dep)
    REFERENCES tipo_departamento(tipo)
    ON DELETE CASCADE;

ALTER TABLE sueldo
    ADD CONSTRAINT fk_tipo_puesto
    FOREIGN KEY (id_tipo_dep, puesto)
    REFERENCES horario(id_tipo_dep, puesto)
    ON DELETE CASCADE;
    
ALTER TABLE sueldo
    ADD CONSTRAINT pk_sueldo
    PRIMARY KEY (id_tipo_dep, puesto, registro);

    
-- Creando la tabla para la relacion de Empleado
CREATE TABLE empleado (
    id_empleado NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    curp VARCHAR(18) NOT NULL,
    tipo_dep VARCHAR(100) NOT NULL,
    puesto VARCHAR(80),
    registro DATE DEFAULT CURRENT_DATE
);

ALTER TABLE empleado
    ADD CONSTRAINT pk_empleado
    PRIMARY KEY (id_empleado);

ALTER TABLE empleado
    ADD CONSTRAINT fk_persona_empl
    FOREIGN KEY (curp)
    REFERENCES persona(curp)
    ON DELETE CASCADE;

ALTER TABLE empleado
    ADD CONSTRAINT fk_tipo_dep_empl
    FOREIGN KEY (tipo_dep)
    REFERENCES tipo_departamento(tipo)
    ON DELETE SET NULL;

ALTER TABLE empleado
    ADD CONSTRAINT fk_puesto_reg_empl
    FOREIGN KEY (tipo_dep, puesto, registro)
    REFERENCES sueldo(id_tipo_dep, puesto, registro)
    ON DELETE SET NULL;

-- Creando la tabla para la relaci�n de Trabajar
CREATE TABLE trabajar (
    id_suc NUMBER(10) NOT NULL,
    id_empleado NUMBER(10) NOT NULL
);

ALTER TABLE trabajar
    ADD CONSTRAINT fk_suc_trabajar
    FOREIGN KEY (id_suc)
    REFERENCES sucursal(id_sucursal)
    ON DELETE CASCADE;
    
ALTER TABLE trabajar
    ADD CONSTRAINT fk_empleado_trabajar
    FOREIGN KEY (id_empleado)
    REFERENCES empleado(id_empleado)
    ON DELETE CASCADE;
   
-- Creando la tabla para la relaci�n de Dirigir sucursal
CREATE TABLE dirigir (
    id_suc NUMBER(10) NOT NULL,
    id_empleado NUMBER(10) NOT NULL
);

ALTER TABLE dirigir
    ADD CONSTRAINT fk_suc_dirigir
    FOREIGN KEY (id_suc)
    REFERENCES sucursal(id_sucursal)
    ON DELETE CASCADE;
    
ALTER TABLE dirigir
    ADD CONSTRAINT fk_empleado_dirigir
    FOREIGN KEY (id_empleado)
    REFERENCES empleado(id_empleado)
    ON DELETE CASCADE;
    
-- Creando la tabla para la relaci�n de Supervisar
CREATE TABLE supervisar (
    id_empleado NUMBER(10) NOT NULL,
    id_suc NUMBER(10) NOT NULL,
    id_tipo_dep VARCHAR(100) NOT NULL
);

ALTER TABLE supervisar 
    ADD CONSTRAINT fk_empleado_supervisar
    FOREIGN KEY (id_empleado)
    REFERENCES empleado (id_empleado);
    
ALTER TABLE supervisar
    ADD CONSTRAINT fk_dep_supervisar
    FOREIGN KEY (id_suc, id_tipo_dep)
    REFERENCES tener_departamento(id_suc, id_tipo)
    ON DELETE CASCADE;
    
-- Creando tabla para Venta
CREATE TABLE venta (
    id_venta NUMBER(10),
    fecha DATE DEFAULT CURRENT_DATE,
    num_tarjeta NUMBER(10) NOT NULL,
    id_empleado NUMBER(10) NOT NULL
);

ALTER TABLE venta
    ADD CONSTRAINT pk_venta
    PRIMARY KEY (id_venta);
    
ALTER TABLE venta
    ADD CONSTRAINT fk_empleado_venta
    FOREIGN KEY (id_empleado)
    REFERENCES empleado(id_empleado)
    ON DELETE SET NULL;
    
ALTER TABLE venta
    ADD CONSTRAINT fk_tarj_venta
    FOREIGN KEY (num_tarjeta)
    REFERENCES tarjeta(num_tarjeta)
    ON DELETE SET NULL;

-- Creando la tabla para la relaci�n de Tipo de Pago
CREATE TABLE tipo_pago (
    num_transac NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    id_venta NUMBER(10) NOT NULL
);

ALTER TABLE tipo_pago
    ADD CONSTRAINT fk_venta_pago
    FOREIGN KEY (id_venta)
    REFERENCES venta(id_venta)
    ON DELETE CASCADE;

ALTER TABLE tipo_pago
    ADD CONSTRAINT pk_tipo_pago
    PRIMARY KEY (num_transac);

-- Creando la tabla para la relaci�n de M�todo de Pago
CREATE TABLE metodo_pago (
    importe NUMBER(10) DEFAULT 0,
    medio NUMBER(10) NOT NULL,
    num_transac NUMBER(10) NOT NULL,
    num_tarjeta NUMBER(10) NOT NULL
);

ALTER TABLE metodo_pago
    ADD CONSTRAINT fk_trans
    FOREIGN KEY (num_transac)
    REFERENCES tipo_pago(num_transac)
    ON DELETE CASCADE;
    
ALTER TABLE metodo_pago
    ADD CONSTRAINT fk_tarj_met_pago
    FOREIGN KEY (num_tarjeta)
    REFERENCES tarjeta(num_tarjeta)
    ON DELETE SET NULL;
    
-- Creando la tabla para Ticket
CREATE TABLE ticket (
    id_ticket NUMBER(10),
    id_venta NUMBER(10) NOT NULL
);

ALTER TABLE ticket
    ADD CONSTRAINT pk_ticket
    PRIMARY KEY (id_ticket);
    
ALTER TABLE ticket
    ADD CONSTRAINT fk_venta_ticket
    FOREIGN  KEY (id_venta)
    REFERENCES venta(id_venta)
    ON DELETE CASCADE;

-- Creando tabla para la relaci�n de canjear ticket
CREATE TABLE canjear_ticket (
    fecha DATE DEFAULT CURRENT_DATE,
    id_ticket NUMBER(10) NOT NULL,
    id_cliente NUMBER(10) NOT NULL
);

ALTER TABLE canjear_ticket
    ADD CONSTRAINT fk_ticket
    FOREIGN KEY (id_ticket)
    REFERENCES ticket(id_ticket)
    ON DELETE CASCADE;
    
ALTER TABLE canjear_ticket
    ADD CONSTRAINT fk_cliente_canjear
    FOREIGN KEY (id_cliente)
    REFERENCES cliente(id_cliente)
    ON DELETE CASCADE;
   
-- Creando tabla para la relacion de Instancia Producto
CREATE TABLE instancia_producto (
    id_producto NUMBER(10) GENERATED ALWAYS AS IDENTITY,
    codigo_barras NUMBER(20) NOT NULL,
    id_produccion NUMBER(10),
    id_departamento VARCHAR(100),
    id_sucursal NUMBER(10),
    id_venta NUMBER(10),
    descripcion VARCHAR(100)
);

ALTER TABLE instancia_producto
    ADD CONSTRAINT pk_inst_prod
    PRIMARY KEY (id_producto);
    
ALTER TABLE instancia_producto
    ADD CONSTRAINT fk_cod_barr_inst_prod
    FOREIGN KEY (codigo_barras)
    REFERENCES producto(codigo_barras)
    ON DELETE CASCADE;
    
ALTER TABLE instancia_producto
    ADD CONSTRAINT fk_suc_inst_prod
    FOREIGN KEY (id_sucursal)
    REFERENCES sucursal(id_sucursal)
    ON DELETE SET NULL;
    
ALTER TABLE instancia_producto
    ADD CONSTRAINT fk_id_produc_inst_prod
    FOREIGN KEY (id_produccion)
    REFERENCES lote(id_produccion)
    ON DELETE SET NULL;
    
ALTER TABLE instancia_producto
    ADD CONSTRAINT fk_id_dep_inst_prod
    FOREIGN KEY (id_departamento)
    REFERENCES tipo_departamento(tipo)
    ON DELETE SET NULL;
    
ALTER TABLE instancia_producto
    ADD CONSTRAINT fk_venta
    FOREIGN KEY (id_venta)
    REFERENCES venta(id_venta)
    ON DELETE CASCADE;