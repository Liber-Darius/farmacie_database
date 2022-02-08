USE MASTER
SELECT NAME FROM SYS.DATABASES WHERE NAME = 'farmacie'
IF EXISTS(SELECT NAME FROM SYS.DATABASES WHERE NAME = 'farmacie')
	DROP DATABASE farmacie
CREATE DATABase farmacie;
GO

USE farmacie;

Create table location(IDlocation INT PRIMARY KEY,
country VARCHAR(50),
county VARCHAR(50),
town VARCHAR(50),
street VARCHAR(50),
nr SMALLINT);
GO

Create table providers(IDprovider INT,
CONSTRAINT provider_pk PRIMARY KEY(IDprovider),
name VARCHAR(50),
shipsOnSunday BIT,
locationProvider INT FOREIGN KEY REFERENCES location(IDlocation))
GO

Create table medicines(IDmedicine INT PRIMARY KEY,
name VARCHAR(50),
availability BIT,
needOfPrescription BIT,
expiryDate DATE,
minimumAge INT,
price INT);
GO

Create table pharmacy(IDpharmacy INT PRIMARY KEY,
name VARCHAR(50),
nrOfemployees INT,
locationPharmacy INT FOREIGN KEY REFERENCES location(IDlocation));
GO

Create table employees(numericalCodeEmployee INT PRIMARY KEY,
name VARCHAR(50),
surname VARCHAR(50),
wage INT,
age INT,
job VARCHAR(50))
GO

Create table fidelityCards(IDcard INT PRIMARY KEY, 
points INT,
name VARCHAR(50),
surname VARCHAR(50),
email VARCHAR(50),
age INT)

Create table medicinePharmacyRelation(
IDpharmacy INT,
IDmedicine INT,
FOREIGN KEY (IDpharmacy) REFERENCES pharmacy(IDpharmacy) on delete cascade on update cascade,
FOREIGN KEY(IDmedicine) REFERENCES medicines(IDmedicine) on delete cascade on update cascade,
UNIQUE (IDpharmacy,IDmedicine))

/*insert data – for at least 4 tables;
update data – for at least 1 table;
delete date – for at least 1 table.*/

INSERT INTO employees VALUES (132, 'Filip', 'Alexandru', 3200, 27, 'chemist');
INSERT INTO employees VALUES (137, 'Kovacs', 'Elena', 5500, 25, 'manager');
INSERT INTO employees VALUES (138, 'Trif', 'Luca', 2200, 36, 'cashier');
INSERT INTO employees VALUES (142, 'Bota', 'Ovidiu', 2250, 29, 'cashier');

/*SELECT* FROM employees;*/

INSERT INTO location VALUES(4526, 'Romania', 'Maramures', 'Sighet', 'Gheorghe Doja', 47);
INSERT INTO location VALUES(7649, 'Romania', 'Maramures', 'Bistra', 'Ioan Slavici', 21);
INSERT INTO location VALUES(3244, 'Ukraine', 'Zakarpathia', 'Ujhorod', 'Leninsakaya', 67);
INSERT INTO location VALUES(8231, 'Germany', 'Baden-Wurttenberg', 'Karlsruhe', 'Kirchen', 55);
INSERT INTO location VALUES(7842, 'Romania', 'Alba', 'Bistra', 'Vasile Lucaciu', 35);
INSERT INTO location VALUES(6842, 'Romania', 'Cluj', 'Cluj-Napoca', 'Calea Turzii', 12);

/*SELECT* FROM location;*/

INSERT INTO MEDICINES VALUES(90215, 'paracetamol', 1, 1, '2022-10-27', 14, 25);
INSERT INTO MEDICINES VALUES(82341, 'ibuprofen', 1, 0, '2023-07-05', 16, 21);
INSERT INTO MEDICINES VALUES(85221, 'theraflu', 0, 0, '2023-02-09', 14, 27);
INSERT INTO MEDICINES VALUES(57528, 'faringosept', 1, 0, '2023-02-09', 12, 15);

/*SELECT* FROM medicines;*/

INSERT INTO pharmacy VALUES(12, 'Catena-1', 9, 8231);
INSERT INTO pharmacy VALUES(7, 'Sensiblu', 6, 7842);
INSERT INTO pharmacy VALUES(11, 'Catena-2', 15, 6842);

/*SELECT* FROM pharmacy;*/

INSERT INTO providers VALUES (577,'FARINGO SRL', 1, 7649);
INSERT INTO providers VALUES (213, 'CSTR SRL', 0, 4526);
INSERT INTO providers VALUES (217, 'BIOMEDA SA', 1, 3244);

/*SELECT* FROM providers;*/

-- 90215 paracetamol, 82341 ibuprofen, 85221 theraflu, 57528 - faringosept
INSERT INTO medicinePharmacyRelation VALUES(12, 90215);
INSERT INTO medicinePharmacyRelation VALUES(12, 82341);
INSERT INTO medicinePharmacyRelation VALUES(12, 57528);
INSERT INTO medicinePharmacyRelation VALUES(7, 90215);
INSERT INTO medicinePharmacyRelation VALUES(7, 82341);
INSERT INTO medicinePharmacyRelation VALUES(7, 85221);
INSERT INTO medicinePharmacyRelation VALUES(7, 57528);
INSERT INTO medicinePharmacyRelation VALUES(11, 82341);
INSERT INTO medicinePharmacyRelation VALUES(11, 85221);

INSERT INTO fidelityCards VALUES (892, 150, 'Draghis', 'Ioana', 'idraghis55@gmail.com', 67);
INSERT INTO fidelityCards VALUES (473, 275, 'Danci', 'Mihai', 'dancsmihai@gmail.com', 72);
INSERT INTO fidelityCards VALUES (132, 75, 'Filip', 'Alexandru', 'a_filip_19@gmail.com', 55);
INSERT INTO fidelityCards VALUES (912, 100, 'Radulescu', 'Raul', 'rraul@gmail.com', 37);
INSERT INTO fidelityCards VALUES (142, 500, 'Bota', 'Ovidiu','botaovi@yahoo.com' , 29);

SELECT* FROM fidelityCards;
PRINT 'we add 50 fidelity points to people who are over 65'
UPDATE fidelityCards
SET points = points + 50
WHERE age > 65;
SELECT* FROM fidelityCards;

SELECT* FROM employees;
PRINT 'we update the wages that are BETWEEN 2000-2300 to 2400'
UPDATE employees
SET wage = 2400 
WHERE wage BETWEEN 2000 AND 2300;
SELECT* FROM employees;

SELECT* FROM pharmacy;
DELETE FROM pharmacy WHERE name LIKE '%Catena%';
SELECT* FROM pharmacy;
INSERT INTO pharmacy VALUES(12, 'Catena-1', 9, 8231);
INSERT INTO pharmacy VALUES(11, 'Catena-2', 15, 6842);

DELETE FROM fidelityCards WHERE points IS NULL;

--3 queries with UNION, INTERSECT, EXCEPT
-- uniunea numelor (clienti, angajati)

SELECT name FROM fidelityCards
UNION
SELECT name FROM employees
ORDER BY name;

--prenume comune clienti(fidelityCards) cu angajati

SELECT surname FROM fidelityCards
INTERSECT
SELECT surname FROM employees
ORDER BY surname;

--prenumele din angajati exceptand prenumele care sunt deja in clienti
SELECT surname FROM employees
EXCEPT
SELECT surname FROM fidelityCards
ORDER BY surname;

--4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL JOIN (one
--query per operator); one query will join at least 3 tables;

--INNER JOIN

--angajatii care sunt si clienti
SELECT* FROM fidelityCards 
INNER JOIN employees
ON fidelityCards.IDcard = employees.numericalCodeEmployee;

SELECT* FROM fidelityCards 
LEFT JOIN employees
ON fidelityCards.IDcard = employees.numericalCodeEmployee;

SELECT wage, employees.name, employees.surname, numericalCodeEmployee, points FROM employees 
Right JOIN fidelityCards
ON fidelityCards.IDcard = employees.numericalCodeEmployee;

SELECT* FROM fidelityCards 
LEFT JOIN employees
ON fidelityCards.IDcard = employees.numericalCodeEmployee WHERE fidelityCards.age > 25 AND fidelityCards.points > 100;

--angajatii care au urmatoarele joburi: casier, manager
SELECT* FROM employees
WHERE job IN('cashier', 'manager');

-- furnizorii care livreaza si duminica
SELECT* FROM providers
WHERE EXISTS(SELECT* WHERE shipsOnSunday = 1);

--3 queries with the GROUP BY clause, from which 2 queries will also
--contain the HAVING clause; 1 query from the latter 2 will also have a
--subquery in the HAVING clause; use the aggregation operators: SUM,
--AVG, MIN, MAX, COUNT.

--medicamentele avand pret mai mare de 23 grupate descrecator si grupate dupa nume si disponibilitate
SELECT SUM(price), name, availability
FROM medicines
GROUP BY availability, name
HAVING SUM(price) > 23
ORDER BY SUM(price) DESC;

--judetele distincte
SELECT DISTINCT county
FROM location 
GROUP BY county;

--top 2 cei mai bine platiti angajati sub 30 de ani
SELECT TOP 2 * FROM employees
WHERE age < 30

--SELECT fidelityCards.email FROM
--(SELECT  FROM fidelityCards WHERE points > 200 AND age >30);







