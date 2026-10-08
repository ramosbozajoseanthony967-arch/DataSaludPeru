USE DataSaludPeru;
GO

/* ============================================================
   PROYECTO: DataSalud Perú
   BLOQUE: Automatización mediante objetos de base de datos
   ============================================================ */


/* ============================================================
   1. TABLA DE LOG DE OPERACIONES
   ============================================================ */

IF OBJECT_ID('dbo.LogOperaciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LogOperaciones
    (
        IdLog INT IDENTITY(1,1) PRIMARY KEY,
        FechaOperacion DATETIME DEFAULT GETDATE(),
        UsuarioSQL NVARCHAR(100),
        Operacion NVARCHAR(100),
        TablaAfectada NVARCHAR(100),
        Descripcion NVARCHAR(500),
        TipoResultado NVARCHAR(50)
    );
END;
GO


/* ============================================================
   2. PROCEDIMIENTO: INSERTAR ATENCIÓN SIS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.sp_InsertarAtencionSIS
    @Anio INT,
    @Mes NVARCHAR(20),
    @Region NVARCHAR(100),
    @Provincia NVARCHAR(100),
    @UbigeoDistrito NVARCHAR(20),
    @Distrito NVARCHAR(100),
    @CodUnidadEjecutora NVARCHAR(50),
    @DescUnidadEjecutora NVARCHAR(200),
    @CodIPRESS NVARCHAR(50),
    @IPRESS NVARCHAR(200),
    @NivelEESS NVARCHAR(100),
    @PlanSeguro NVARCHAR(150),
    @CodServicio NVARCHAR(50),
    @DescServicio NVARCHAR(200),
    @Sexo NVARCHAR(20),
    @GrupoEdad NVARCHAR(100),
    @Atenciones INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        /* Validación de duplicados */
        IF EXISTS
        (
            SELECT 1
            FROM dbo.AtencionesSIS
            WHERE Anio = @Anio
              AND Mes = @Mes
              AND CodIPRESS = @CodIPRESS
              AND CodServicio = @CodServicio
              AND Sexo = @Sexo
              AND GrupoEdad = @GrupoEdad
              AND PlanSeguro = @PlanSeguro
        )
        BEGIN

            INSERT INTO dbo.LogOperaciones
            (
                UsuarioSQL,
                Operacion,
                TablaAfectada,
                Descripcion,
                TipoResultado
            )
            VALUES
            (
                SUSER_SNAME(),
                'INSERT',
                'AtencionesSIS',
                'Registro duplicado. No se insertó.',
                'RECHAZADO'
            );

            ROLLBACK TRANSACTION;

            SELECT 'Registro duplicado. No se insertó.' AS Resultado;
            RETURN;
        END;

        /* Inserción */
        INSERT INTO dbo.AtencionesSIS
        (
            Anio,
            Mes,
            Region,
            Provincia,
            UbigeoDistrito,
            Distrito,
            CodUnidadEjecutora,
            DescUnidadEjecutora,
            CodIPRESS,
            IPRESS,
            NivelEESS,
            PlanSeguro,
            CodServicio,
            DescServicio,
            Sexo,
            GrupoEdad,
            Atenciones
        )
        VALUES
        (
            @Anio,
            @Mes,
            @Region,
            @Provincia,
            @UbigeoDistrito,
            @Distrito,
            @CodUnidadEjecutora,
            @DescUnidadEjecutora,
            @CodIPRESS,
            @IPRESS,
            @NivelEESS,
            @PlanSeguro,
            @CodServicio,
            @DescServicio,
            @Sexo,
            @GrupoEdad,
            @Atenciones
        );

        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'INSERT',
            'AtencionesSIS',
            'Registro insertado correctamente.',
            'EXITOSO'
        );

        COMMIT TRANSACTION;

        SELECT 'Registro insertado correctamente.' AS Resultado;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'INSERT',
            'AtencionesSIS',
            ERROR_MESSAGE(),
            'ERROR'
        );

        THROW;

    END CATCH;
END;
GO


/* ============================================================
   3. PROCEDIMIENTO: ACTUALIZAR ATENCIÓN SIS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.sp_ActualizarAtencionSIS
    @IdRegistro INT,
    @NuevasAtenciones INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        SAVE TRANSACTION PuntoActualizacion;

        /* Verificar existencia */
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.AtencionesSIS
            WHERE IdRegistro = @IdRegistro
        )
        BEGIN
            ROLLBACK TRANSACTION PuntoActualizacion;
            RAISERROR('El registro indicado no existe.', 16, 1);
            RETURN;
        END;

        /* Validar valor */
        IF @NuevasAtenciones < 0
        BEGIN
            ROLLBACK TRANSACTION PuntoActualizacion;
            RAISERROR('La cantidad de atenciones no puede ser negativa.', 16, 1);
            RETURN;
        END;

        /* Actualización */
        UPDATE dbo.AtencionesSIS
        SET Atenciones = @NuevasAtenciones
        WHERE IdRegistro = @IdRegistro;

        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'UPDATE',
            'AtencionesSIS',
            'Registro actualizado correctamente.',
            'EXITOSO'
        );

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'UPDATE',
            'AtencionesSIS',
            ERROR_MESSAGE(),
            'ERROR'
        );

        THROW;

    END CATCH;
END;
GO


/* ============================================================
   4. PROCEDIMIENTO: CONSULTAR ATENCIONES
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.sp_ConsultarAtenciones
    @Region NVARCHAR(100),
    @Provincia NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Region,
        Provincia,
        Distrito,
        IPRESS,
        DescServicio,
        Sexo,
        GrupoEdad,
        Atenciones
    FROM dbo.AtencionesSIS
    WHERE Region = @Region
      AND Provincia = @Provincia;
END;
GO


/* ============================================================
   5. TRIGGER: AUDITORÍA
   ============================================================ */

CREATE OR ALTER TRIGGER dbo.trg_AuditoriaAtenciones
ON dbo.AtencionesSIS
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* INSERT */
    IF EXISTS (SELECT 1 FROM inserted)
       AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'INSERT',
            'AtencionesSIS',
            'Auditoría: se insertó un registro.',
            'EXITOSO'
        );
    END;

    /* UPDATE */
    IF EXISTS (SELECT 1 FROM inserted)
       AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'UPDATE',
            'AtencionesSIS',
            'Auditoría: se actualizó un registro.',
            'EXITOSO'
        );
    END;

    /* DELETE */
    IF EXISTS (SELECT 1 FROM deleted)
       AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'DELETE',
            'AtencionesSIS',
            'Auditoría: se eliminó un registro.',
            'EXITOSO'
        );
    END;
END;
GO


/* ============================================================
   6. TRIGGER: INTEGRIDAD DE ATENCIONES
   ============================================================ */

CREATE OR ALTER TRIGGER dbo.trg_IntegridadAtenciones
ON dbo.AtencionesSIS
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE Atenciones < 0
    )
    BEGIN

        INSERT INTO dbo.LogOperaciones
        (
            UsuarioSQL,
            Operacion,
            TablaAfectada,
            Descripcion,
            TipoResultado
        )
        VALUES
        (
            SUSER_SNAME(),
            'VALIDACION',
            'AtencionesSIS',
            'Se intentó registrar una cantidad de atenciones negativa.',
            'RECHAZADO'
        );

        RAISERROR(
            'La cantidad de atenciones no puede ser negativa.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


/* ============================================================
   7. FUNCIÓN: TOTAL DE ATENCIONES POR IPRESS
   ============================================================ */

CREATE OR ALTER FUNCTION dbo.fn_TotalAtencionesIPRESS
(
    @CodIPRESS NVARCHAR(50)
)
RETURNS INT
AS
BEGIN

    DECLARE @Total INT;

    SELECT
        @Total = ISNULL(SUM(Atenciones), 0)
    FROM dbo.AtencionesSIS
    WHERE CodIPRESS = @CodIPRESS;

    RETURN @Total;

END;
GO


/* ============================================================
   8. PRUEBA DE PROCEDIMIENTO DE CONSULTA
   ============================================================ */

EXEC dbo.sp_ConsultarAtenciones
    @Region = 'LA LIBERTAD',
    @Provincia = 'TRUJILLO';
GO


/* ============================================================
   9. PRUEBA DE FUNCIÓN
   ============================================================ */

SELECT dbo.fn_TotalAtencionesIPRESS('IPRESS001')
AS TotalAtenciones;
GO


/* ============================================================
   10. CONSULTA DEL LOG DE AUDITORÍA
   ============================================================ */

SELECT *
FROM dbo.LogOperaciones
ORDER BY IdLog DESC;
GO