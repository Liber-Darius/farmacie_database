/*
a. Implement a stored procedure for the INSERT operation on 2 tables in 1-
n relationship; the procedure’s parameters should describe the entities /
relationships in the tables; the procedure should use at least 2 user-defined
functions to validate certain parameters.

b. Create a view that extract data from at least 4 tables and write a SELECT
on the view that returns useful information for a potential user.

c. Implement a trigger for a table, for INSERT, UPDATE or/and DELETE;
the trigger will introduce in a log table, the following data: the date and the
time of the triggering statement, the trigger type (INSERT / UPDATE /
DELETE), the name of the affected table and the number of added /
modified / removed records.

d. Write queries on 2 different tables such that their execution plans contain
the following operators in the execution plan (in WHERE, ORDER BY,
JOIN’s clauses):

 clustered index scan;
 clustered index seek;
 nonclustered index scan;
 nonclustered index seek;
 key lookup.
*/
use farmacie
-- check an int
go
create function checkPrice(@n int)
returns int as
begin
	declare @no int
	if @n>=0 and @n<=1500
		set @no=1
	else
		set @no=0
	return @no
end
go

go
create function checkVarchar(@v varchar(50))
returns bit as
begin
	declare @b bit
	if @v LIKE '[a-z]%[a-z]' --doar litere
		set @b=1
	else
		set @b=0
	return @b
end
go

create function checkNumericalID (@v bigint)
returns bit as
begin
	declare @b bit
	-- cnp 1 2 3 4 5 6 7 8 9 10 11 12 13
	set @b = 0;
	if @v > 999999999999 and @v < 99999999999999
		if(@v/100000000%100 <= 12) --luna
			if(@v/1000000%100 <=31) -- zile din luna
				if(@v/10000%100 < =52) -- judet + sectoare
					set @b = 1
	return @b
end
go

create function checkAge (@n int)
returns bit as
begin
	declare @b bit
	if @n < 0
		set @b = 0;
	else if @n > 130
		set @b = 0;
	else 
		set @b = 1;
	return @b
end
go

create function isNotExpired (@v date)
returns bit as 
begin
	declare @b bit
	if(@v > GETDATE())
	begin
		set @b = 1
	end
	else
		begin
			set @b = 0
		end
	return @b
end
go

/* a) Implement a stored procedure for the INSERT operation on 2 tables in 1- n relationship; the procedure’s parameters 
should describe theentities / relationships in the tables; the procedure should use at least 2 user-defined functions to
validate certain parameters.*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------
create procedure addMedicineToPharmacy  @name varchar(50), @availability bit, @needOfPrescription bit, @expiryDate date, @minimumAge int, @price int
as
begin
-- validate the parametres 
	if dbo.isNotExpired(@expiryDate) =  1 AND dbo.checkPrice(@price) = 1  AND dbo.checkVarchar(@name) = 1
		begin
			DECLARE @val int
			SELECT TOP 1 @val = IDpharmacy from pharmacy
			PRINT @val                     
			SET @val=(SELECT Top 1 IDpharmacy FROM pharmacy)
			PRINT @val -- asa zice in cerinta de la lab, ca nu trebuie extrase manual id-urile
			--
			insert into medicines  values (@val,  @name, @availability, @needOfPrescription, @expiryDate, @minimumAge, @price)
			print 'we added values into medicine'
			select* from medicines
		end
	else
		begin   
			print 'we had some errors'
			select* from medicines
		end
	end
go

exec addMedicinetoPharmacy 'logacalmin', 1, 1, '12.07.2022', 17, 34
exec addMedicinetoPharmacy 'nevrocalm', 1, 1, '12.07.2027', 14, 50


SELECT* FROM pharmacy
go

Select* from medicines
go

/*  b) Create a view that extract data from at least 4 tables and write a SELECT
on the view that returns useful information for a potential user*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------

create view viewMedicine
as
SELECT m.IDmedicine, m.name as medicineName, pro.name as providerName, p.name as pharmacyName, st.onStock
from medicines m inner join pharmacy p on m.IDpharmacy = p.IDpharmacy
inner join contracts d on d.IDpharmacy = p.IDpharmacy
inner join providers pro on pro.IDprovider = d.IDprovider
inner join stock st on st.IDprovider = pro.IDprovider and st.IDmedicine = m.IDmedicine
where st.onStock = 1
go

select*from viewMedicine


/* c) Implement a trigger for a table, for INSERT, UPDATE or/and DELETE;
the trigger will introduce in a log table, the following data: the date and the
time of the triggering statement, the trigger type (INSERT / UPDATE /
DELETE), the name of the affected table and the number of added /
modified / removed records.*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------
go
-- copy of the table - nu trebuie neaparat, nu inteleg de ce am nevoie
create table pharmacyTe([IDpharmacy] bigint primary key, [name] varchar(50))
go

--we create table Logs
create table Logs(TriggerDate date, TriggerType varchar(50),
NameAffectedTable varchar(50), NoAMDRows int)
go 

--for the table pharmacy
SET IDENTITY_INSERT [pharmacy] ON;
go
CREATE TRIGGER add_pharmacy ON pharmacy FOR
INSERT AS
BEGIN
INSERT INTO pharmacyTe(IDpharmacy, [name])
SELECT [IDpharmacy], [name]
FROM inserted
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'INSERT', 'pharmacy',
@@ROWCOUNT) 
END
GO
--

select * from pharmacy
select * from pharmacyTe
insert into pharmacy([IDpharmacy], [name]) Values(427423, 'Catedsna')
select * from pharmacy
select * from pharmacyTe
select * from Logs

--trigger for UPDATE
go
CREATE TRIGGER update_pharmacy ON pharmacy FOR
UPDATE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'UPDATE', 'pharmacy',
@@ROWCOUNT) 
END
GO

select * from pharmacy
update pharmacy
set [name] = 'gogu'
where IDpharmacy = 7
go
select * from pharmacy
select * from Logs
--

go
CREATE TRIGGER delete_pharmacy ON pharmacy FOR
DELETE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'DELETE', 'pharmacy',
@@ROWCOUNT) 
END
GO

select * from pharmacy
delete from pharmacy where IDpharmacy = 42423
select * from pharmacy
select * from Logs

------------------------------------------------------------------------------------------------
--for the table Medicines

go
CREATE TRIGGER add_medicines ON medicines FOR
INSERT AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'INSERT', 'medicines',
@@ROWCOUNT) 
END
GO

select * from medicines
insert into medicines([IDpharmacy], [IDmedicine], [name], [availability], [needOfPrescription], [expiryDate], [minimumAge], [price]) Values(12, 134, 'calcium', 1,1,'11.10.2023',18, 25)
select * from medicines
select * from Logs

--trigger for UPDATE
go
CREATE TRIGGER update_medicines ON medicines FOR
UPDATE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'UPDATE', 'medicines',
@@ROWCOUNT) 
END
GO

select * from medicines
update medicines
set [name] = 'metaloglobina'
where IDmedicine = 134
go
select * from medicines
select * from Logs
--

go
CREATE TRIGGER delete_medicines ON medicines FOR
DELETE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'DELETE', 'medicines',
@@ROWCOUNT) 
END
GO

select * from medicines
delete from medicines where IDmedicine = 134
select * from medicines
select * from Logs
go

----------------------------------------------------------------------------------------------------------
--for the table providers

go
CREATE TRIGGER add_providers ON providers FOR
INSERT AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'INSERT', 'providers',
@@ROWCOUNT) 
END
GO

select * from providers
insert into providers([IDprovider], [name], [shipsOnSunday]) Values(777, 'fanmedical', 1)
select * from providers
select * from Logs

--trigger for UPDATE
go
CREATE TRIGGER update_providers ON providers FOR
UPDATE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'UPDATE', 'providers',
@@ROWCOUNT) 
END
GO

select * from providers
update providers
set [name] = 'FAN'
where IDprovider = 777
go
select * from providers
select * from Logs
--

go
CREATE TRIGGER delete_providers ON providers FOR
DELETE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'DELETE', 'providers',
@@ROWCOUNT) 
END
GO

select * from providers
delete from providers where IDprovider = 777
select * from providers
select * from Logs
go

----------------------------------------------------------------------------------------------------------
--for the table fidelityCards

go
CREATE TRIGGER add_fidelityCards ON fidelityCards FOR
INSERT AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'INSERT', 'fidelityCards',
@@ROWCOUNT) 
END
GO

select * from fidelityCards
insert into fidelityCards([IDcard], [IDpharmacy], [points], [name], [surname], [email], [age]) Values(5020302243823, 11, 75, 'Rusu', 'Ciprian', 'cipriro@outlook.com', 45)
select * from fidelityCards
select * from Logs

--trigger for UPDATE
go
CREATE TRIGGER update_fidelityCards ON fidelityCards FOR
UPDATE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'UPDATE', 'fidelityCards',
@@ROWCOUNT) 
END
GO

select * from fidelityCards
update fidelityCards
set [points] = 125
where IDcard = 5020302243823
go
select * from fidelityCards
select * from Logs
--

go
CREATE TRIGGER delete_fidelityCards ON fidelityCards FOR
DELETE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'DELETE', 'fidelityCards',
@@ROWCOUNT) 
END
GO

select * from fidelityCards
delete from fidelityCards where IDcard = 5020302243823
select * from fidelityCards
select * from Logs
go

----------------------------------------------------------------------------------------------------------
--for the table location

go
CREATE TRIGGER add_location ON location FOR
INSERT AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'INSERT', 'location',
@@ROWCOUNT) 
END
GO

select * from location
insert into location([IDlocation], [country], [county], [town], [street], [nr]) values(47, 'Romania', 'Maramures', 'Baia Mare', 'Gheorghe Sincai',67)
select * from location
select * from Logs

--trigger for UPDATE
go
CREATE TRIGGER update_location ON location FOR
UPDATE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'UPDATE', 'location',
@@ROWCOUNT) 
END
GO

select * from location
update location
set [nr] = 71
where IDlocation = 47
go
select * from location
select * from Logs
--

go
CREATE TRIGGER delete_location ON location FOR
DELETE AS
BEGIN
insert into Logs(TriggerDate, TriggerType,
NameAffectedTable, NoAMDRows)
values (GETDATE(), 'DELETE', 'location',
@@ROWCOUNT) 
END
GO

select * from location
delete from location where IDlocation = 47
select * from location
select * from Logs
go

---------------------------------------------------------------------------------------------------------
/*d. Write queries on 2 different tables such that their execution plans contain
the following operators in the execution plan (in WHERE, ORDER BY,
JOIN’s clauses):

 clustered index scan;
 clustered index seek;
 nonclustered index scan;
 nonclustered index seek;
 key lookup.
*/
-----------------------------------------------------------------------------------------------------------

--for employees
use farmacie
go
SELECT* from employees order by [name]

go
SELECT* from employees order by [numericalCodeEmployee]

go
SELECT* from employees where [wage] > 2500

go
SELECT* from medicines where IDmedicine = 57528

go
SELECT* from medicines m inner join pharmacy p on m.IDpharmacy = P.IDpharmacy

go
SELECT* from medicines where [price] <25