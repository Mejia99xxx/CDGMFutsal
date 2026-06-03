-- ============================================================
--  BASE DE DATOS: CDGMFutsal
--  Sistema de Gestión de Torneos
--  Ficha 3230984 – SENA – Bogotá 2026
-- ============================================================
--  MÓDULO 2 – EQUIPOS Y CATEGORÍAS
--  Tablas: CATEGORIAS, EQUIPOS, JUGADORES,
--          REQUISITOS_CATEGORIA, INSCRIPCION_EQUIPO_CAT
-- ============================================================

USE CDGMFutsal;

-- ============================================================
-- DDL – ESTRUCTURA DE TABLAS
-- ============================================================

CREATE TABLE CATEGORIAS (
    id_categoria     INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    descripcion      TEXT,
    edad_minima      INT,
    edad_maxima      INT,
    activo           TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE EQUIPOS (
    id_equipo       INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL,   -- representante / delegado
    nombre_equipo   VARCHAR(150) NOT NULL,
    logo_url        VARCHAR(300),
    ciudad          VARCHAR(100),
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_eqp_usr FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE JUGADORES (
    id_jugador       INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo        INT          NOT NULL,
    nombre           VARCHAR(100) NOT NULL,
    apellido         VARCHAR(100) NOT NULL,
    documento        VARCHAR(30)  NOT NULL UNIQUE,
    fecha_nacimiento DATE         NOT NULL,
    posicion         VARCHAR(50),
    numero_camiseta  INT,
    activo           TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_jug_eqp FOREIGN KEY (id_equipo) REFERENCES EQUIPOS(id_equipo)
);

CREATE TABLE REQUISITOS_CATEGORIA (
    id_requisito   INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria   INT          NOT NULL,
    descripcion    VARCHAR(300) NOT NULL,
    obligatorio    TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_req_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria)
);

CREATE TABLE INSCRIPCION_EQUIPO_CAT (
    id_inscripcion_ec INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo         INT          NOT NULL,
    id_categoria      INT          NOT NULL,
    estado            ENUM('pendiente','aprobada','rechazada') NOT NULL DEFAULT 'pendiente',
    fecha_inscripcion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_iec_eqp FOREIGN KEY (id_equipo)    REFERENCES EQUIPOS(id_equipo),
    CONSTRAINT fk_iec_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria),
    UNIQUE (id_equipo, id_categoria)
);

-- ============================================================
-- DML – DATOS DE PRUEBA
-- ============================================================

INSERT INTO CATEGORIAS (nombre_categoria, descripcion, edad_minima, edad_maxima, activo)
VALUES ('Sub-20', 'Categoría para jugadores menores de 20 años', 15, 19, 1);

INSERT INTO EQUIPOS (id_usuario, nombre_equipo, logo_url, ciudad, activo)
VALUES (1, 'Tigres FC', 'https://cdn.cdgmfutsal.com/logos/tigres.png', 'Bogotá', 1);

INSERT INTO JUGADORES (id_equipo, nombre, apellido, documento, fecha_nacimiento, posicion, numero_camiseta, activo)
VALUES (1, 'Andrés', 'Morales', '1005678901', '2007-06-22', 'Pivote', 10, 1);

INSERT INTO REQUISITOS_CATEGORIA (id_categoria, descripcion, obligatorio)
VALUES (1, 'Presentar documento de identidad vigente', 1);

INSERT INTO INSCRIPCION_EQUIPO_CAT (id_equipo, id_categoria, estado)
VALUES (1, 1, 'aprobada');

-- ============================================================
--  FIN DEL MÓDULO 2
-- ============================================================
