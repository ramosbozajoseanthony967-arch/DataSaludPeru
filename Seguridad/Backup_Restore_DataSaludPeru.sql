USE master;
GO

/* ============================================================
   PROYECTO: DataSalud Perú
   BLOQUE: SEGURIDAD
   ARCHIVO: Backup_Restore_DataSaludPeru.sql
   ============================================================ */


/* ============================================================
   1. BACKUP FULL
   ============================================================ */

BACKUP DATABASE DataSaludPeru
TO DISK = 'C:\Backup\DataSaludPeru_FULL.bak'
WITH INIT,
     FORMAT,
     NAME = 'Backup FULL DataSaludPeru',
     DESCRIPTION = 'Copia de seguridad completa de DataSaludPeru',
     STATS = 10;
GO


/* ============================================================
   2. BACKUP DIFERENCIAL
   ============================================================ */

BACKUP DATABASE DataSaludPeru
TO DISK = 'C:\Backup\DataSaludPeru_DIFF.bak'
WITH INIT,
     DIFFERENTIAL,
     NAME = 'Backup Diferencial DataSaludPeru',
     DESCRIPTION = 'Copia de seguridad diferencial de DataSaludPeru',
     STATS = 10;
GO


/* ============================================================
   3. VERIFICAR BACKUPS
   ============================================================ */

SELECT
    database_name,
    backup_start_date,
    backup_finish_date,
    type,
    physical_device_name
FROM msdb.dbo.backupset b
INNER JOIN msdb.dbo.backupmediafamily m
    ON b.media_set_id = m.media_set_id
WHERE database_name = 'DataSaludPeru'
ORDER BY backup_start_date DESC;
GO


/* ============================================================
   4. RESTAURACIÓN DE PRUEBA
   ============================================================ */

USE master;
GO

RESTORE DATABASE DataSaludPeru_Prueba
FROM DISK = 'C:\Backup\DataSaludPeru_FULL.bak'
WITH
    MOVE 'DataSaludPeru'
    TO 'C:\Backup\DataSaludPeru_Prueba.mdf',

    MOVE 'DataSaludPeru_log'
    TO 'C:\Backup\DataSaludPeru_Prueba_log.ldf',

    REPLACE,
    RECOVERY,
    STATS = 10;
GO


/* ============================================================
   5. VERIFICAR RESTAURACIÓN
   ============================================================ */

SELECT
    name,
    state_desc
FROM sys.databases
WHERE name = 'DataSaludPeru_Prueba';
GO