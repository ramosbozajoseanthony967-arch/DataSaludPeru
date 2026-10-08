USE DataSaludPeru;
GO

/* ============================================================
   PROYECTO: DataSalud Perú
   BLOQUE: Seguridad
   ============================================================ */


/* ============================================================
   1. CREACIÓN DE ROLES
   ============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'Rol_Administrador'
)
BEGIN
    CREATE ROLE Rol_Administrador;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'Rol_Analista'
)
BEGIN
    CREATE ROLE Rol_Analista;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'Rol_Operador'
)
BEGIN
    CREATE ROLE Rol_Operador;
END;
GO


/* ============================================================
   2. PERMISOS DEL ADMINISTRADOR
   ============================================================ */

GRANT CONTROL ON DATABASE::DataSaludPeru
TO Rol_Administrador;
GO


/* ============================================================
   3. PERMISOS DEL ANALISTA
   ============================================================ */

GRANT SELECT
ON dbo.AtencionesSIS
TO Rol_Analista;
GO


/* ============================================================
   4. PERMISOS DEL OPERADOR
   ============================================================ */

GRANT EXECUTE
ON dbo.sp_InsertarAtencionSIS
TO Rol_Operador;
GO


/* ============================================================
   5. VERIFICACIÓN DE ROLES
   ============================================================ */

SELECT
    name AS Rol,
    type_desc AS Tipo
FROM sys.database_principals
WHERE name IN
(
    'Rol_Administrador',
    'Rol_Analista',
    'Rol_Operador'
);
GO


/* ============================================================
   6. VERIFICACIÓN DE PERMISOS
   ============================================================ */

SELECT
    dp.name AS Rol,
    dp.type_desc AS TipoRol,
    p.permission_name AS Permiso,
    p.state_desc AS EstadoPermiso
FROM sys.database_principals dp
LEFT JOIN sys.database_permissions p
    ON dp.principal_id = p.grantee_principal_id
WHERE dp.name IN
(
    'Rol_Administrador',
    'Rol_Analista',
    'Rol_Operador'
)
ORDER BY dp.name;
GO