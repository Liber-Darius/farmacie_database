GO
USE farmacie
GO

if exists (select * from farmacie.sys.tables where name='our_version')
drop table our_version

if not exists (select * from farmacie.sys.tables where name='our_version')
BEGIN
	CREATE TABLE our_version(
		id_version int PRIMARY KEY default 0)
	INSERT INTO our_version VALUES(0)
END
GO


if exists (select * from farmacie.sys.objects where name='add_column_1')
	drop procedure add_column_1
go

CREATE PROCEDURE add_column_1
AS
IF EXISTS(	SELECT * FROM farmacie.sys.tables
		WHERE name = 'employees')
	IF EXISTS(	SELECT * FROM farmacie.sys.columns
					WHERE name = 'years_since_employed' AND OBJECT_ID = OBJECT_ID('employees'))
		PRINT('column years_since_employed already exists')
	else	
	BEGIN
		ALTER TABLE employees
		ADD years_since_employed int
		--UPDATE our_version SET id_version = 1
		PRINT 'years_since_employed column added to table employees'
		PRINT 'Database is now at version 1'
	END
ELSE
PRINT('table employees does not exist')
GO

if exists (select * from farmacie.sys.objects where name='remove_column_1')
	drop procedure remove_column_1
go

CREATE PROCEDURE remove_column_1
AS
	IF EXISTS(	SELECT * FROM sys.tables
			WHERE name = 'employees')
		IF NOT EXISTS(	SELECT * FROM sys.columns
						WHERE name = 'years_since_employed' AND OBJECT_ID = OBJECT_ID('employees'))
		PRINT('column years_since_employed does not exist')
		ELSE
		BEGIN
			ALTER TABLE employees
			DROP COLUMN years_since_employed 
			PRINT 'years_since_employed column deleted from table employees'
			PRINT 'Database is now at version 0'
		END
GO

if exists (select * from farmacie.sys.objects where name='add_constraint_2')
	drop procedure add_constraint_2
go

CREATE PROCEDURE add_constraint_2
AS
IF EXISTS(	SELECT * FROM farmacie.sys.tables
			WHERE name = 'employees')
	IF EXISTS(	SELECT * FROM sys.objects
					WHERE name = 'pk_minimum_wage')
	PRINT('default constraint minimum_wage already exists')
	ELSE
	BEGIN
		ALTER TABLE employees
		ADD CONSTRAINT pk_minimum_wage DEFAULT 1800 FOR wage
		--UPDATE our_version SET id_version = 2
		PRINT 'minimum _wage DEFAULT CONSTRAINT added on employees'
		PRINT 'Database is now at version 2'
	END

GO

if exists (select * from farmacie.sys.objects where name='remove_constraint_2')
	drop procedure remove_constraint_2
go

CREATE PROCEDURE remove_constraint_2
AS
IF EXISTS(	SELECT * FROM farmacie.sys.tables
			WHERE name = 'employees')
	IF NOT EXISTS(	SELECT * FROM sys.objects
					WHERE name = 'pk_minimum_wage' )
	PRINT('default constraint minimum_wage does not exist')
	ELSE
	BEGIN
		ALTER TABLE employees
		DROP CONSTRAINT pk_minimum_wage
		PRINT 'minimum _wage DEFAULT CONSTRAINT removed from employees'
		PRINT 'Database is now at version 1'
	END

GO

if exists (select * from farmacie.sys.objects where name='add_foreign_key_3')
	drop procedure add_foreign_key_3
go

CREATE PROCEDURE add_foreign_key_3
AS
IF EXISTS(	SELECT * FROM sys.objects
			WHERE name = 'fk_works_at' )
PRINT('foreign key work_at already exists')
ELSE
BEGIN
	ALTER TABLE employees
	ADD CONSTRAINT fk_works_at FOREIGN KEY (IDprovider) REFERENCES providers(IDprovider) ON DELETE CASCADE ON UPDATE CASCADE
	--UPDATE our_version SET id_version = 3
	PRINT 'work_at foreign key added on employees'
	PRINT 'Database is now at version 3'
END
GO

if exists (select * from farmacie.sys.objects where name='remove_foreign_key_3')
	drop procedure remove_foreign_key_3
go

CREATE PROCEDURE remove_foreign_key_3
AS
IF NOT EXISTS(	SELECT * FROM sys.objects
				WHERE name = 'fk_works_at' )
PRINT('foreign key work_at does not exist')
ELSE
BEGIN
	ALTER TABLE employees
	DROP CONSTRAINT fk_works_at
	PRINT 'work_at foreign key droped from employees'
	PRINT 'Database is now at version 2'
END
GO

if exists (select * from farmacie.sys.objects where name='create_table_4')
	drop procedure create_table_4
go

CREATE PROCEDURE create_table_4
AS
IF EXISTS(	SELECT * FROM sys.tables
			WHERE name = 'car')
PRINT('table car already exists')
ELSE
BEGIN
	CREATE TABLE car(
	car_id INT PRIMARY KEY,
	brand VARCHAR(50) NOT NULL,
	model VARCHAR(50) NOT NULL,
	horsePower INT,
	engineSize INT)

	--UPDATE our_version SET id_version = 4
	PRINT 'car table now created'
	PRINT 'Database is now at version 4'
END
GO

if exists (select * from farmacie.sys.objects where name='remove_table_4')
	drop procedure remove_table_4
go

CREATE PROCEDURE remove_table_4
AS
IF NOT EXISTS(	SELECT * FROM sys.tables
			WHERE name = 'car')
PRINT('table car does not exist')
ELSE
BEGIN
	IF EXISTS(	SELECT * FROM sys.tables
			WHERE name = 'car') DROP TABLE car
	PRINT 'car table droped'
	PRINT 'Database is now at version 3'
END

GO

if exists (select * from farmacie.sys.objects where name='update_version')
	drop procedure update_version
go

create procedure update_version(@new_version INT)
as
	delete from our_version
	insert into our_version(id_version) values
	(@new_version)
	PRINT 'update_version executed'
go

if exists (select * from farmacie.sys.objects where name='main')
	drop procedure main
go

create PROCEDURE main
@new_version INT
AS
	DECLARE @old_version INT
	SET @old_version = (SELECT id_version FROM our_version)

	IF @new_version < 0 or @new_version > 4
	BEGIN
		PRINT 'NOT A VALID NUMBER'
	END
	ELSE
	BEGIN
	
		IF @old_version < @new_version
			BEGIN
				PRINT 'Going forward from version ' + CAST(@old_version AS nvarchar(2)) + ' to version ' + CAST(@new_version AS nvarchar(2))
				WHILE @old_version <> @new_version
				BEGIN
					IF @old_version = 0
						EXEC add_column_1
					ELSE IF @old_version = 1
						EXEC add_constraint_2
					ELSE IF @old_version = 2
						EXEC add_foreign_key_3
					ELSE IF @old_version = 3
						EXEC create_table_4
					SET @old_version = @old_version + 1
				END
			END
			ELSE IF @old_version > @new_version
			BEGIN
				PRINT 'Going backwards from version ' + CAST(@old_version AS nvarchar(2)) + ' to version ' + CAST(@new_version AS nvarchar(2))
				WHILE @old_version <> @new_version
				BEGIN
					IF @old_version = 1
						EXEC remove_column_1
					ELSE IF @old_version = 2
						EXEC remove_constraint_2
					ELSE IF @old_version = 3
						EXEC remove_foreign_key_3
					ELSE IF @old_version = 4
						EXEC remove_table_4
					SET @old_version = @old_version - 1
				END
			END
			ELSE
				PRINT 'The database is already at version ' + CAST(@new_version AS nvarchar(2))

			execute update_version @new_version
	END
	
go

UPDATE our_version SET id_version = 4

exec main 4




	


