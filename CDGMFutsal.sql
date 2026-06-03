-- ============================================================
--  BASE DE DATOS: CDGMFutsal
--  Sistema de Gestión de Torneos
--  Ficha 3230984 – SENA – Bogotá 2026
--  Total: 49 tablas | 9 Módulos
-- ============================================================

CREATE DATABASE IF NOT EXISTS CDGMFutsal
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE CDGMFutsal;

-- ============================================================
-- MÓDULO 1 – USUARIOS Y AUTENTICACIÓN
-- ============================================================

CREATE TABLE ROLES (
    id_rol          INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol      VARCHAR(50)  NOT NULL UNIQUE,
    descripcion     VARCHAR(200),
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PERMISOS (
    id_permiso      INT AUTO_INCREMENT PRIMARY KEY,
    nombre_permiso  VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(200),
    modulo          VARCHAR(50),
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ROL_PERMISO (
    id_rol_permiso  INT AUTO_INCREMENT PRIMARY KEY,
    id_rol          INT NOT NULL,
    id_permiso      INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rp_rol     FOREIGN KEY (id_rol)     REFERENCES ROLES(id_rol),
    CONSTRAINT fk_rp_permiso FOREIGN KEY (id_permiso) REFERENCES PERMISOS(id_permiso),
    UNIQUE (id_rol, id_permiso)
);

CREATE TABLE USUARIOS (
    id_usuario      INT AUTO_INCREMENT PRIMARY KEY,
    id_rol          INT          NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    correo          VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usr_rol FOREIGN KEY (id_rol) REFERENCES ROLES(id_rol)
);

CREATE TABLE SESIONES (
    id_sesion       INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL,
    token           VARCHAR(255) NOT NULL UNIQUE,
    ip_origen       VARCHAR(45),
    fecha_inicio    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion DATETIME    NOT NULL,
    activa          TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_ses_usr FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE RECUPERACION_CONTRASENA (
    id_recuperacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL,
    token           VARCHAR(255) NOT NULL UNIQUE,
    fecha_solicitud DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion DATETIME    NOT NULL,
    usado           TINYINT(1)   NOT NULL DEFAULT 0,
    CONSTRAINT fk_rec_usr FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE PERFILES_USUARIO (
    id_perfil       INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL UNIQUE,
    foto_url        VARCHAR(300),
    telefono        VARCHAR(20),
    ciudad          VARCHAR(100),
    bio             TEXT,
    fecha_nacimiento DATE,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_prf_usr FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE CONFIG_NOTIFICACIONES (
    id_config       INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL UNIQUE,
    notif_email     TINYINT(1)   NOT NULL DEFAULT 1,
    notif_push      TINYINT(1)   NOT NULL DEFAULT 1,
    notif_sms       TINYINT(1)   NOT NULL DEFAULT 0,
    notif_resultados TINYINT(1)  NOT NULL DEFAULT 1,
    notif_pagos     TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_modificacion DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cfg_usr FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE IDIOMAS_USUARIO (
    id_idioma_usr   INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL UNIQUE,
    codigo_idioma   VARCHAR(10)  NOT NULL DEFAULT 'es',
    nombre_idioma   VARCHAR(50)  NOT NULL DEFAULT 'Español',
    fecha_seleccion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_idu_usr FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

-- ============================================================
-- MÓDULO 2 – EQUIPOS Y CATEGORÍAS
-- ============================================================

CREATE TABLE CATEGORIAS (
    id_categoria    INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    descripcion     TEXT,
    edad_minima     INT,
    edad_maxima     INT,
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
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
    id_jugador      INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo       INT          NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    documento       VARCHAR(30)  NOT NULL UNIQUE,
    fecha_nacimiento DATE         NOT NULL,
    posicion        VARCHAR(50),
    numero_camiseta INT,
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_jug_eqp FOREIGN KEY (id_equipo) REFERENCES EQUIPOS(id_equipo)
);

CREATE TABLE REQUISITOS_CATEGORIA (
    id_requisito    INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria    INT          NOT NULL,
    descripcion     VARCHAR(300) NOT NULL,
    obligatorio     TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_req_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria)
);

CREATE TABLE INSCRIPCION_EQUIPO_CAT (
    id_inscripcion_ec INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo       INT          NOT NULL,
    id_categoria    INT          NOT NULL,
    estado          ENUM('pendiente','aprobada','rechazada') NOT NULL DEFAULT 'pendiente',
    fecha_inscripcion DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_iec_eqp FOREIGN KEY (id_equipo)    REFERENCES EQUIPOS(id_equipo),
    CONSTRAINT fk_iec_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria),
    UNIQUE (id_equipo, id_categoria)
);

-- ============================================================
-- MÓDULO 3 – PAGOS E INSCRIPCIONES
-- ============================================================

CREATE TABLE TARIFAS (
    id_tarifa       INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria    INT          NOT NULL,
    descripcion     VARCHAR(200) NOT NULL,
    monto           DECIMAL(10,2) NOT NULL,
    moneda          VARCHAR(5)   NOT NULL DEFAULT 'COP',
    vigente         TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tar_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria)
);

CREATE TABLE REGLAMENTOS (
    id_reglamento   INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria    INT          NOT NULL,
    titulo          VARCHAR(200) NOT NULL,
    contenido       TEXT         NOT NULL,
    version         VARCHAR(10)  NOT NULL DEFAULT '1.0',
    fecha_publicacion DATE        NOT NULL,
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_reg_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria)
);

CREATE TABLE INSCRIPCIONES (
    id_inscripcion  INT AUTO_INCREMENT PRIMARY KEY,
    id_equipo       INT          NOT NULL,
    id_tarifa       INT          NOT NULL,
    estado          ENUM('pendiente','confirmada','cancelada') NOT NULL DEFAULT 'pendiente',
    fecha_inscripcion DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observaciones   TEXT,
    CONSTRAINT fk_ins_eqp FOREIGN KEY (id_equipo) REFERENCES EQUIPOS(id_equipo),
    CONSTRAINT fk_ins_tar FOREIGN KEY (id_tarifa) REFERENCES TARIFAS(id_tarifa)
);

CREATE TABLE PAGOS (
    id_pago         INT AUTO_INCREMENT PRIMARY KEY,
    id_inscripcion  INT          NOT NULL,
    monto_pagado    DECIMAL(10,2) NOT NULL,
    metodo_pago     VARCHAR(50)  NOT NULL,
    referencia      VARCHAR(100),
    estado          ENUM('pendiente','aprobado','rechazado') NOT NULL DEFAULT 'pendiente',
    fecha_pago      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pag_ins FOREIGN KEY (id_inscripcion) REFERENCES INSCRIPCIONES(id_inscripcion)
);

CREATE TABLE REPORTES_PAGO (
    id_reporte_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_pago         INT          NOT NULL,
    generado_por    INT          NOT NULL,   -- id_usuario
    descripcion     TEXT,
    fecha_generacion DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rpp_pago FOREIGN KEY (id_pago)        REFERENCES PAGOS(id_pago),
    CONSTRAINT fk_rpp_usr  FOREIGN KEY (generado_por)   REFERENCES USUARIOS(id_usuario)
);

-- ============================================================
-- MÓDULO 4 – PREMIOS Y DONACIONES
-- ============================================================

CREATE TABLE TIPOS_PREMIO (
    id_tipo_premio  INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(200),
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PREMIACIONES (
    id_premiacion   INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_premio  INT          NOT NULL,
    id_equipo       INT          NOT NULL,
    descripcion     VARCHAR(300),
    fecha_entrega   DATE         NOT NULL,
    CONSTRAINT fk_prm_tipo FOREIGN KEY (id_tipo_premio) REFERENCES TIPOS_PREMIO(id_tipo_premio),
    CONSTRAINT fk_prm_eqp  FOREIGN KEY (id_equipo)      REFERENCES EQUIPOS(id_equipo)
);

CREATE TABLE PREMIOS_CATEGORIA (
    id_premio_cat   INT AUTO_INCREMENT PRIMARY KEY,
    id_categoria    INT          NOT NULL,
    id_tipo_premio  INT          NOT NULL,
    descripcion     VARCHAR(300),
    valor_estimado  DECIMAL(10,2),
    fecha_asignacion DATE        NOT NULL,
    CONSTRAINT fk_pmc_cat  FOREIGN KEY (id_categoria)   REFERENCES CATEGORIAS(id_categoria),
    CONSTRAINT fk_pmc_tipo FOREIGN KEY (id_tipo_premio) REFERENCES TIPOS_PREMIO(id_tipo_premio)
);

CREATE TABLE TIPOS_DONACION (
    id_tipo_donacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(200),
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE DONANTES (
    id_donante      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    correo          VARCHAR(150),
    telefono        VARCHAR(20),
    empresa         VARCHAR(150),
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE DONACIONES (
    id_donacion     INT AUTO_INCREMENT PRIMARY KEY,
    id_donante      INT          NOT NULL,
    id_tipo_donacion INT         NOT NULL,
    monto           DECIMAL(10,2),
    descripcion     TEXT,
    fecha_donacion  DATE         NOT NULL,
    CONSTRAINT fk_don_donante FOREIGN KEY (id_donante)       REFERENCES DONANTES(id_donante),
    CONSTRAINT fk_don_tipo    FOREIGN KEY (id_tipo_donacion) REFERENCES TIPOS_DONACION(id_tipo_donacion)
);

CREATE TABLE ASIGNACION_DONACION (
    id_asignacion   INT AUTO_INCREMENT PRIMARY KEY,
    id_donacion     INT          NOT NULL,
    id_categoria    INT,
    id_equipo       INT,
    descripcion     VARCHAR(300),
    fecha_asignacion DATE        NOT NULL,
    CONSTRAINT fk_asd_don FOREIGN KEY (id_donacion)  REFERENCES DONACIONES(id_donacion),
    CONSTRAINT fk_asd_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria),
    CONSTRAINT fk_asd_eqp FOREIGN KEY (id_equipo)    REFERENCES EQUIPOS(id_equipo)
);

-- ============================================================
-- MÓDULO 5 – ORGANIZACIÓN DE TORNEOS
-- ============================================================

CREATE TABLE TORNEOS (
    id_torneo       INT AUTO_INCREMENT PRIMARY KEY,
    nombre_torneo   VARCHAR(200) NOT NULL,
    id_categoria    INT          NOT NULL,
    fecha_inicio    DATE         NOT NULL,
    fecha_fin       DATE         NOT NULL,
    descripcion     TEXT,
    estado          ENUM('planificado','en_curso','finalizado','cancelado') NOT NULL DEFAULT 'planificado',
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tor_cat FOREIGN KEY (id_categoria) REFERENCES CATEGORIAS(id_categoria)
);

CREATE TABLE UBICACIONES (
    id_ubicacion    INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL,
    direccion       VARCHAR(300) NOT NULL,
    ciudad          VARCHAR(100) NOT NULL,
    capacidad       INT,
    activa          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ARBITROS (
    id_arbitro      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    documento       VARCHAR(30)  NOT NULL UNIQUE,
    correo          VARCHAR(150),
    telefono        VARCHAR(20),
    licencia        VARCHAR(50),
    activo          TINYINT(1)   NOT NULL DEFAULT 1,
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PARTIDOS (
    id_partido      INT AUTO_INCREMENT PRIMARY KEY,
    id_torneo       INT          NOT NULL,
    id_equipo_local INT          NOT NULL,
    id_equipo_visitante INT      NOT NULL,
    id_ubicacion    INT          NOT NULL,
    fecha_partido   DATETIME     NOT NULL,
    goles_local     INT          DEFAULT 0,
    goles_visitante INT          DEFAULT 0,
    estado          ENUM('programado','en_curso','finalizado','aplazado','cancelado') NOT NULL DEFAULT 'programado',
    CONSTRAINT fk_par_tor  FOREIGN KEY (id_torneo)           REFERENCES TORNEOS(id_torneo),
    CONSTRAINT fk_par_loc  FOREIGN KEY (id_equipo_local)     REFERENCES EQUIPOS(id_equipo),
    CONSTRAINT fk_par_vis  FOREIGN KEY (id_equipo_visitante) REFERENCES EQUIPOS(id_equipo),
    CONSTRAINT fk_par_ubi  FOREIGN KEY (id_ubicacion)        REFERENCES UBICACIONES(id_ubicacion)
);

CREATE TABLE APLAZAMIENTOS (
    id_aplazamiento INT AUTO_INCREMENT PRIMARY KEY,
    id_partido      INT          NOT NULL,
    motivo          TEXT         NOT NULL,
    fecha_original  DATETIME     NOT NULL,
    nueva_fecha     DATETIME,
    solicitado_por  INT          NOT NULL,   -- id_usuario
    fecha_solicitud DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_apl_par FOREIGN KEY (id_partido)    REFERENCES PARTIDOS(id_partido),
    CONSTRAINT fk_apl_usr FOREIGN KEY (solicitado_por) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE ASIGNACION_ARBITROS (
    id_asignacion_arb INT AUTO_INCREMENT PRIMARY KEY,
    id_partido      INT          NOT NULL,
    id_arbitro      INT          NOT NULL,
    rol_arbitro     VARCHAR(50)  NOT NULL DEFAULT 'principal',
    fecha_asignacion DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_asarb_par FOREIGN KEY (id_partido) REFERENCES PARTIDOS(id_partido),
    CONSTRAINT fk_asarb_arb FOREIGN KEY (id_arbitro) REFERENCES ARBITROS(id_arbitro),
    UNIQUE (id_partido, id_arbitro)
);

CREATE TABLE DISPONIBILIDAD_ARBITROS (
    id_disponibilidad INT AUTO_INCREMENT PRIMARY KEY,
    id_arbitro      INT          NOT NULL,
    fecha_disponible DATE         NOT NULL,
    hora_inicio     TIME         NOT NULL,
    hora_fin        TIME         NOT NULL,
    disponible      TINYINT(1)   NOT NULL DEFAULT 1,
    CONSTRAINT fk_dis_arb FOREIGN KEY (id_arbitro) REFERENCES ARBITROS(id_arbitro)
);

CREATE TABLE ESTADISTICAS_PARTIDO (
    id_estadistica  INT AUTO_INCREMENT PRIMARY KEY,
    id_partido      INT          NOT NULL,
    id_equipo       INT          NOT NULL,
    posesion        DECIMAL(5,2),
    tiros_al_arco   INT          DEFAULT 0,
    faltas          INT          DEFAULT 0,
    tarjetas_amarillas INT       DEFAULT 0,
    tarjetas_rojas  INT          DEFAULT 0,
    CONSTRAINT fk_esp_par FOREIGN KEY (id_partido) REFERENCES PARTIDOS(id_partido),
    CONSTRAINT fk_esp_eqp FOREIGN KEY (id_equipo)  REFERENCES EQUIPOS(id_equipo),
    UNIQUE (id_partido, id_equipo)
);

-- ============================================================
-- MÓDULO 6 – TABLA DE POSICIONES
-- ============================================================

CREATE TABLE TABLA_POSICIONES (
    id_posicion     INT AUTO_INCREMENT PRIMARY KEY,
    id_torneo       INT          NOT NULL,
    id_equipo       INT          NOT NULL,
    puntos          INT          NOT NULL DEFAULT 0,
    partidos_jugados INT         NOT NULL DEFAULT 0,
    partidos_ganados INT         NOT NULL DEFAULT 0,
    partidos_empatados INT       NOT NULL DEFAULT 0,
    partidos_perdidos INT        NOT NULL DEFAULT 0,
    goles_favor     INT          NOT NULL DEFAULT 0,
    goles_contra    INT          NOT NULL DEFAULT 0,
    diferencia_goles INT GENERATED ALWAYS AS (goles_favor - goles_contra) STORED,
    CONSTRAINT fk_tpos_tor FOREIGN KEY (id_torneo) REFERENCES TORNEOS(id_torneo),
    CONSTRAINT fk_tpos_eqp FOREIGN KEY (id_equipo) REFERENCES EQUIPOS(id_equipo),
    UNIQUE (id_torneo, id_equipo)
);

CREATE TABLE ESTADISTICAS_INDIVIDUALES (
    id_estadistica_ind INT AUTO_INCREMENT PRIMARY KEY,
    id_jugador      INT          NOT NULL,
    id_partido      INT          NOT NULL,
    goles           INT          NOT NULL DEFAULT 0,
    asistencias     INT          NOT NULL DEFAULT 0,
    minutos_jugados INT          NOT NULL DEFAULT 0,
    tarjetas_amarillas INT       NOT NULL DEFAULT 0,
    tarjetas_rojas  INT          NOT NULL DEFAULT 0,
    CONSTRAINT fk_esi_jug FOREIGN KEY (id_jugador) REFERENCES JUGADORES(id_jugador),
    CONSTRAINT fk_esi_par FOREIGN KEY (id_partido)  REFERENCES PARTIDOS(id_partido),
    UNIQUE (id_jugador, id_partido)
);

-- ============================================================
-- MÓDULO 7 – REPORTES Y ESTADÍSTICAS
-- ============================================================

CREATE TABLE TIPOS_REPORTE (
    id_tipo_reporte INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(200),
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE REPORTES (
    id_reporte      INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_reporte INT          NOT NULL,
    generado_por    INT          NOT NULL,   -- id_usuario
    titulo          VARCHAR(200) NOT NULL,
    parametros      JSON,
    fecha_generacion DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rep_tipo FOREIGN KEY (id_tipo_reporte) REFERENCES TIPOS_REPORTE(id_tipo_reporte),
    CONSTRAINT fk_rep_usr  FOREIGN KEY (generado_por)    REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE FILTROS_REPORTE (
    id_filtro       INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte      INT          NOT NULL,
    nombre_filtro   VARCHAR(100) NOT NULL,
    valor_filtro    VARCHAR(200) NOT NULL,
    CONSTRAINT fk_fil_rep FOREIGN KEY (id_reporte) REFERENCES REPORTES(id_reporte)
);

CREATE TABLE EXPORTACIONES (
    id_exportacion  INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte      INT          NOT NULL,
    formato         ENUM('PDF','EXCEL','CSV','JSON') NOT NULL,
    url_archivo     VARCHAR(300),
    fecha_exportacion DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exp_rep FOREIGN KEY (id_reporte) REFERENCES REPORTES(id_reporte)
);

CREATE TABLE VISUALIZACIONES (
    id_visualizacion INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte      INT          NOT NULL,
    tipo_grafico    VARCHAR(50)  NOT NULL,
    configuracion   JSON,
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vis_rep FOREIGN KEY (id_reporte) REFERENCES REPORTES(id_reporte)
);

-- ============================================================
-- MÓDULO 8 – PARTIDOS EN VIVO
-- ============================================================

CREATE TABLE TIPOS_EVENTO_VIVO (
    id_tipo_evento  INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    descripcion     VARCHAR(200),
    fecha_creacion  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PARTIDOS_EN_VIVO (
    id_partido_vivo INT AUTO_INCREMENT PRIMARY KEY,
    id_partido      INT          NOT NULL UNIQUE,
    minuto_actual   INT          NOT NULL DEFAULT 0,
    estado_vivo     ENUM('por_iniciar','primer_tiempo','descanso','segundo_tiempo','finalizado') NOT NULL DEFAULT 'por_iniciar',
    espectadores    INT          NOT NULL DEFAULT 0,
    ultima_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_pvv_par FOREIGN KEY (id_partido) REFERENCES PARTIDOS(id_partido)
);

CREATE TABLE EVENTOS_EN_VIVO (
    id_evento_vivo  INT AUTO_INCREMENT PRIMARY KEY,
    id_partido_vivo INT          NOT NULL,
    id_tipo_evento  INT          NOT NULL,
    id_jugador      INT,
    minuto          INT          NOT NULL,
    descripcion     VARCHAR(300),
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_evv_pvv  FOREIGN KEY (id_partido_vivo) REFERENCES PARTIDOS_EN_VIVO(id_partido_vivo),
    CONSTRAINT fk_evv_tipo FOREIGN KEY (id_tipo_evento)  REFERENCES TIPOS_EVENTO_VIVO(id_tipo_evento),
    CONSTRAINT fk_evv_jug  FOREIGN KEY (id_jugador)      REFERENCES JUGADORES(id_jugador)
);

CREATE TABLE ESTADISTICAS_EN_VIVO (
    id_estadistica_vivo INT AUTO_INCREMENT PRIMARY KEY,
    id_partido_vivo INT          NOT NULL,
    id_equipo       INT          NOT NULL,
    goles_acumulados INT         NOT NULL DEFAULT 0,
    tiros_acumulados INT         NOT NULL DEFAULT 0,
    faltas_acumuladas INT        NOT NULL DEFAULT 0,
    ultima_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_esv_pvv FOREIGN KEY (id_partido_vivo) REFERENCES PARTIDOS_EN_VIVO(id_partido_vivo),
    CONSTRAINT fk_esv_eqp FOREIGN KEY (id_equipo)       REFERENCES EQUIPOS(id_equipo),
    UNIQUE (id_partido_vivo, id_equipo)
);

CREATE TABLE HISTORIAL_PARTIDO (
    id_historial    INT AUTO_INCREMENT PRIMARY KEY,
    id_partido      INT          NOT NULL,
    descripcion     TEXT         NOT NULL,
    tipo_cambio     VARCHAR(100),
    registrado_por  INT          NOT NULL,   -- id_usuario
    fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_his_par FOREIGN KEY (id_partido)    REFERENCES PARTIDOS(id_partido),
    CONSTRAINT fk_his_usr FOREIGN KEY (registrado_por) REFERENCES USUARIOS(id_usuario)
);

-- ============================================================
-- MÓDULO 9 – COMUNICACIÓN / NOTIFICACIONES / SOPORTE
-- ============================================================

CREATE TABLE NOTIFICACIONES (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario      INT          NOT NULL,
    titulo          VARCHAR(200) NOT NULL,
    mensaje         TEXT         NOT NULL,
    tipo            VARCHAR(50)  NOT NULL DEFAULT 'info',
    leida           TINYINT(1)   NOT NULL DEFAULT 0,
    fecha_envio     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_not_usr FOREIGN KEY (id_usuario) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE MENSAJES_INTERNOS (
    id_mensaje      INT AUTO_INCREMENT PRIMARY KEY,
    id_remitente    INT          NOT NULL,
    asunto          VARCHAR(200) NOT NULL,
    cuerpo          TEXT         NOT NULL,
    fecha_envio     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_msg_rem FOREIGN KEY (id_remitente) REFERENCES USUARIOS(id_usuario)
);

CREATE TABLE DESTINATARIOS_MENSAJE (
    id_destinatario INT AUTO_INCREMENT PRIMARY KEY,
    id_mensaje      INT          NOT NULL,
    id_usuario      INT          NOT NULL,
    leido           TINYINT(1)   NOT NULL DEFAULT 0,
    fecha_lectura   DATETIME,
    CONSTRAINT fk_des_msg FOREIGN KEY (id_mensaje)  REFERENCES MENSAJES_INTERNOS(id_mensaje),
    CONSTRAINT fk_des_usr FOREIGN KEY (id_usuario)  REFERENCES USUARIOS(id_usuario),
    UNIQUE (id_mensaje, id_usuario)
);

-- ============================================================
--  DATOS DE PRUEBA – AL MENOS 1 REGISTRO POR TABLA
--  Orden respetando dependencias (FK)
-- ============================================================

-- -----------------------------------------------
-- MÓDULO 1 – USUARIOS Y AUTENTICACIÓN
-- -----------------------------------------------

INSERT INTO ROLES (nombre_rol, descripcion, activo)
VALUES ('Administrador', 'Control total del sistema', 1);

INSERT INTO PERMISOS (nombre_permiso, descripcion, modulo)
VALUES ('gestionar_torneos', 'Crear, editar y eliminar torneos', 'Módulo 5');

INSERT INTO ROL_PERMISO (id_rol, id_permiso)
VALUES (1, 1);

INSERT INTO USUARIOS (id_rol, nombre, apellido, correo, contrasena_hash, activo)
VALUES (1, 'Carlos', 'Ramírez', 'admin@cdgmfutsal.com',
        '$2b$12$KIXabcdefghijklmnopqrstuvwxyz0123456789ABCDEF', 1);

INSERT INTO SESIONES (id_usuario, token, ip_origen, fecha_inicio, fecha_expiracion, activa)
VALUES (1, 'tok_abc123xyz789_sesion_inicial', '192.168.1.10',
        '2026-05-26 08:00:00', '2026-05-26 20:00:00', 1);

INSERT INTO RECUPERACION_CONTRASENA (id_usuario, token, fecha_solicitud, fecha_expiracion, usado)
VALUES (1, 'rec_token_abc_001', '2026-05-26 09:00:00', '2026-05-26 10:00:00', 0);

INSERT INTO PERFILES_USUARIO (id_usuario, telefono, ciudad, bio, fecha_nacimiento)
VALUES (1, '3001234567', 'Bogotá', 'Administrador principal del torneo CDGMFutsal.', '1990-03-15');

INSERT INTO CONFIG_NOTIFICACIONES (id_usuario, notif_email, notif_push, notif_sms, notif_resultados, notif_pagos)
VALUES (1, 1, 1, 0, 1, 1);

INSERT INTO IDIOMAS_USUARIO (id_usuario, codigo_idioma, nombre_idioma)
VALUES (1, 'es', 'Español');

-- -----------------------------------------------
-- MÓDULO 2 – EQUIPOS Y CATEGORÍAS
-- -----------------------------------------------

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

-- -----------------------------------------------
-- MÓDULO 3 – PAGOS E INSCRIPCIONES
-- -----------------------------------------------

INSERT INTO TARIFAS (id_categoria, descripcion, monto, moneda, vigente)
VALUES (1, 'Inscripción torneo apertura Sub-20 2026', 250000.00, 'COP', 1);

INSERT INTO REGLAMENTOS (id_categoria, titulo, contenido, version, fecha_publicacion, activo)
VALUES (1, 'Reglamento Sub-20 2026',
        'Cada equipo deberá presentarse 30 minutos antes del partido. Se permitirán 5 jugadores en cancha más el portero.',
        '1.0', '2026-01-10', 1);

INSERT INTO INSCRIPCIONES (id_equipo, id_tarifa, estado, observaciones)
VALUES (1, 1, 'confirmada', 'Inscripción completada sin novedad');

INSERT INTO PAGOS (id_inscripcion, monto_pagado, metodo_pago, referencia, estado)
VALUES (1, 250000.00, 'Transferencia bancaria', 'TXN-2026-00123', 'aprobado');

INSERT INTO REPORTES_PAGO (id_pago, generado_por, descripcion)
VALUES (1, 1, 'Comprobante de pago generado para inscripción de Tigres FC');

-- -----------------------------------------------
-- MÓDULO 4 – PREMIOS Y DONACIONES
-- -----------------------------------------------

INSERT INTO TIPOS_PREMIO (nombre, descripcion)
VALUES ('Trofeo Campeón', 'Trofeo entregado al equipo ganador del torneo');

INSERT INTO PREMIACIONES (id_tipo_premio, id_equipo, descripcion, fecha_entrega)
VALUES (1, 1, 'Campeón torneo apertura 2026', '2026-06-30');

INSERT INTO PREMIOS_CATEGORIA (id_categoria, id_tipo_premio, descripcion, valor_estimado, fecha_asignacion)
VALUES (1, 1, 'Trofeo y medallas para el equipo campeón Sub-20', 500000.00, '2026-01-15');

INSERT INTO TIPOS_DONACION (nombre, descripcion)
VALUES ('Patrocinio en efectivo', 'Aporte monetario de empresa o particular');

INSERT INTO DONANTES (nombre, correo, telefono, empresa, activo)
VALUES ('Juan Pérez', 'jperez@empresa.com', '3109876543', 'Deportes JPC S.A.S', 1);

INSERT INTO DONACIONES (id_donante, id_tipo_donacion, monto, descripcion, fecha_donacion)
VALUES (1, 1, 1000000.00, 'Donación para premios del torneo apertura 2026', '2026-02-01');

INSERT INTO ASIGNACION_DONACION (id_donacion, id_categoria, id_equipo, descripcion, fecha_asignacion)
VALUES (1, 1, NULL, 'Fondos asignados a premios de la categoría Sub-20', '2026-02-05');

-- -----------------------------------------------
-- MÓDULO 5 – ORGANIZACIÓN DE TORNEOS
-- -----------------------------------------------

INSERT INTO TORNEOS (nombre_torneo, id_categoria, fecha_inicio, fecha_fin, descripcion, estado)
VALUES ('Torneo Apertura CDGMFutsal 2026', 1, '2026-06-01', '2026-06-30',
        'Torneo inaugural de la liga CDGMFutsal Bogotá', 'planificado');

INSERT INTO UBICACIONES (nombre, direccion, ciudad, capacidad, activa)
VALUES ('Coliseo El Salitre', 'Cra 68 # 63-30, Bogotá', 'Bogotá', 500, 1);

INSERT INTO ARBITROS (nombre, apellido, documento, correo, telefono, licencia, activo)
VALUES ('Luis', 'Gómez', '79456123', 'lgomez@arbitros.com', '3156781234', 'COL-ARB-2025-041', 1);

INSERT INTO PARTIDOS (id_torneo, id_equipo_local, id_equipo_visitante, id_ubicacion,
                      fecha_partido, goles_local, goles_visitante, estado)
VALUES (1, 1, 1, 1, '2026-06-05 10:00:00', 0, 0, 'programado');
-- Nota: en un escenario real local ≠ visitante; se usa id=1 para mantener FK válida con un solo equipo de prueba.

INSERT INTO APLAZAMIENTOS (id_partido, motivo, fecha_original, nueva_fecha, solicitado_por)
VALUES (1, 'Lluvia intensa prevista según pronóstico meteorológico',
        '2026-06-05 10:00:00', '2026-06-07 10:00:00', 1);

INSERT INTO ASIGNACION_ARBITROS (id_partido, id_arbitro, rol_arbitro)
VALUES (1, 1, 'principal');

INSERT INTO DISPONIBILIDAD_ARBITROS (id_arbitro, fecha_disponible, hora_inicio, hora_fin, disponible)
VALUES (1, '2026-06-07', '08:00:00', '18:00:00', 1);

INSERT INTO ESTADISTICAS_PARTIDO (id_partido, id_equipo, posesion, tiros_al_arco, faltas,
                                   tarjetas_amarillas, tarjetas_rojas)
VALUES (1, 1, 55.00, 8, 4, 1, 0);

-- -----------------------------------------------
-- MÓDULO 6 – TABLA DE POSICIONES
-- -----------------------------------------------

INSERT INTO TABLA_POSICIONES (id_torneo, id_equipo, puntos, partidos_jugados,
                               partidos_ganados, partidos_empatados, partidos_perdidos,
                               goles_favor, goles_contra)
VALUES (1, 1, 3, 1, 1, 0, 0, 3, 1);

INSERT INTO ESTADISTICAS_INDIVIDUALES (id_jugador, id_partido, goles, asistencias,
                                        minutos_jugados, tarjetas_amarillas, tarjetas_rojas)
VALUES (1, 1, 2, 1, 40, 0, 0);

-- -----------------------------------------------
-- MÓDULO 7 – REPORTES Y ESTADÍSTICAS
-- -----------------------------------------------

INSERT INTO TIPOS_REPORTE (nombre, descripcion)
VALUES ('Reporte de resultados', 'Resumen de resultados de partidos por fecha');

INSERT INTO REPORTES (id_tipo_reporte, generado_por, titulo, parametros)
VALUES (1, 1, 'Resultados Jornada 1 – Torneo Apertura 2026',
        '{"torneo_id": 1, "jornada": 1}');

INSERT INTO FILTROS_REPORTE (id_reporte, nombre_filtro, valor_filtro)
VALUES (1, 'torneo', 'Torneo Apertura CDGMFutsal 2026');

INSERT INTO EXPORTACIONES (id_reporte, formato, url_archivo)
VALUES (1, 'PDF', 'https://cdn.cdgmfutsal.com/reportes/jornada1_2026.pdf');

INSERT INTO VISUALIZACIONES (id_reporte, tipo_grafico, configuracion)
VALUES (1, 'barras', '{"eje_x": "equipo", "eje_y": "goles", "color": "#1E90FF"}');

-- -----------------------------------------------
-- MÓDULO 8 – PARTIDOS EN VIVO
-- -----------------------------------------------

INSERT INTO TIPOS_EVENTO_VIVO (nombre, descripcion)
VALUES ('Gol', 'Anotación de un gol durante el partido');

INSERT INTO PARTIDOS_EN_VIVO (id_partido, minuto_actual, estado_vivo, espectadores)
VALUES (1, 20, 'primer_tiempo', 150);

INSERT INTO EVENTOS_EN_VIVO (id_partido_vivo, id_tipo_evento, id_jugador, minuto, descripcion)
VALUES (1, 1, 1, 18, 'Gol de Andrés Morales de tiro libre al ángulo superior derecho');

INSERT INTO ESTADISTICAS_EN_VIVO (id_partido_vivo, id_equipo, goles_acumulados,
                                   tiros_acumulados, faltas_acumuladas)
VALUES (1, 1, 1, 4, 2);

INSERT INTO HISTORIAL_PARTIDO (id_partido, descripcion, tipo_cambio, registrado_por)
VALUES (1, 'Partido iniciado puntualmente a las 10:00 AM', 'inicio_partido', 1);

-- -----------------------------------------------
-- MÓDULO 9 – COMUNICACIÓN / NOTIFICACIONES / SOPORTE
-- -----------------------------------------------

INSERT INTO NOTIFICACIONES (id_usuario, titulo, mensaje, tipo, leida)
VALUES (1, 'Bienvenido a CDGMFutsal',
        'Tu cuenta de administrador ha sido activada exitosamente. ¡Bienvenido al sistema!',
        'info', 0);

INSERT INTO MENSAJES_INTERNOS (id_remitente, asunto, cuerpo)
VALUES (1, 'Reunión de organización torneo apertura',
        'Hola equipo, recordamos que la reunión de organización del torneo apertura es el viernes 29 de mayo a las 3 PM.');

INSERT INTO DESTINATARIOS_MENSAJE (id_mensaje, id_usuario, leido)
VALUES (1, 1, 0);

-- ============================================================
--  FIN DEL SCRIPT – CDGMFutsal (49 tablas + datos de prueba)
-- ============================================================
