USE BazaGeo_DB;
GO

--BACKUP LA DATABASE

-- Backup full
BACKUP DATABASE BazaGeo_DB
TO DISK = 'studiu_individual_backup.bak'
WITH FORMAT,
NAME = 'Backup complet la studiu invididual';
GO

SELECT SERVERPROPERTY('InstanceDefaultBackupPath') AS BackupFolder;

-- Recovery full
RESTORE DATABASE BazaGeo_DB
FROM DISK = 'studiu_individual_backup.bak'
WITH 
    NORECOVERY,            -- baza ramane in RESTORING
    REPLACE,               -- suprascrie baza existenta
    STATS = 10;

-- Backup differential
BACKUP DATABASE BazaGeo_DB
TO DISK = 'studiu_individual_backup1.bak'
WITH DIFFERENTIAL,
     INIT,
     COMPRESSION,
     STATS = 10;

SELECT SERVERPROPERTY('InstanceDefaultBackupPath') AS BackupFolder;

-- Restore differential
RESTORE DATABASE BazaGeo_DB
FROM DISK = 'studiu_individual_backup1.bak'
WITH 
    NORECOVERY, 
    STATS = 10;

-- Backup log
BACKUP LOG BazaGeo_DB
TO DISK = 'studiu_individual_backup2.bak'
WITH INIT,
     COMPRESSION,
     STATS = 10;

SELECT SERVERPROPERTY('InstanceDefaultBackupPath') AS BackupFolder;

-- Restore log
RESTORE LOG BazaGeo_DB
FROM DISK = 'studiu_individual_backup2.bak'
WITH 
    NORECOVERY,
    STATS = 10;