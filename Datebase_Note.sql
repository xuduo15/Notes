############################## MySQL Database ##############################
CREATE DATABASE SQL_Diego;

USE SQL_Diego;

############# TABLE: emp #############
DROP TABLE IF EXISTS emp;
CREATE TABLE emp
(
    emp_id  	 	    DECIMAL(4,0) NOT NULL,
    ename   	    VARCHAR(10) default NULL,
    job                 VARCHAR(10)  default NULL,
    mgr_id                DECIMAL(4,0)  default NULL,
    hiredate      DATE  default NULL,
    sal                 DECIMAL(7,2)  default NULL,
    comm             DECIMAL(7,2) default NULL,
    deptno         DECIMAL(2,0) default NULL
);

# default 0 -> replace the empty values as "0"

INSERT INTO emp 
(emp_id, ename, job, mgr_id, hiredate, sal, comm, deptno)
VALUES 
('7369','SM ITH','CLERK','7902','1980-12-17','800.00',NULL,'20'), 
('7499','ALLEN','SALESMAN','7698','1981-02-20','1600.00','300.00','30'),
('7521','WARD','SALESMAN','7698','1981-02-22','1250.00','500.00','30'),
('7566','JONES','MANAGER','7839','1981-04-02','2975.00',NULL,'20'),
('7654','MARTIN','SALESMAN','7698','1981-09-28','1250.00','1400.00','30'),
('7698','BLAKE','MANAGER','7839','1981-05-01','2850.00',NULL,'30'),
('7782','CLARK','MANAGER','7839','1981-06-09','2450.00',NULL,'10'),
('7788','SCOTT','ANALYST','7566','1982-12-09','3000.00',NULL,'20'),
('7839','KING','PRESIDENT',NULL,'1981-11-17','5000.00',NULL,'10'),
('7844','TURNER','SALESMAN','7698','1981-09-08','1500.00','0.00','30'),
('7876','ADAMS','CLERK','7788','1983-01-12','1100.00',NULL,'20'),
('7900','JAMES','CLERK','7698','1981-12-03','950.00',NULL,'30'),
('7902','FORD','ANALYST','7566','1981-12-03','3000.00',NULL,'20'),
('7934','MILLER','CLERK','7782','1982-01-23','1300.00',NULL,'10');



############# TABLE: dept #############
DROP TABLE IF EXISTS dept;
CREATE TABLE dept
(
    deptno  	 	    INT,
    dname   	    VARCHAR(30),
    loc                 VARCHAR(30)
);

INSERT INTO dept 
(deptno,dname, loc)
VALUES 
('10','ACCOUNTING','NEW YORK'),
('20','RESEARCH','DALLAS'),
('30','SALES','CHICAGO'),
('40','OPERATIONS','BOSTON');



############# TABLE: emp_bonus #############
DROP TABLE IF EXISTS emp_bonus;
CREATE TABLE emp_bonus
(
    emp_id  	 	    DECIMAL(4,0) NOT NULL,
    received   	    DATE default NULL,
    type                 INT
);

INSERT INTO emp_bonus 
(emp_id,received, type)
VALUES 
('7934','2005-03-17','1'),
('7934','2005-02-15','2'),
('7839','2005-02-15','3'),
('7782','2005-02-15','1');



############# TABLE: t1 #############
DROP TABLE IF EXISTS t1;
CREATE TABLE t1
(pos  	 	    INT);

INSERT INTO t1
(pos)
VALUES 
('1');



############# TABLE: t10 #############
DROP TABLE IF EXISTS t10;
CREATE TABLE t10
(pos  	 	    INT);

INSERT INTO t10 
(pos)
VALUES 
('1'),
('2'),
('3'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9'),
('10');



############# TABLE: Reciprocal #############
DROP TABLE IF EXISTS Reciprocal;
CREATE TABLE Reciprocal
(TEST1 INT, TEST2 INT);

INSERT INTO Reciprocal 
(TEST1,TEST2)
VALUES 
('20','20'),('50','25'),('20','20'),('60','30'),('70','90'),('80','130'),('90','70'),('100','50');



############# TABLE: titanic #############
CREATE TABLE IF NOT EXISTS titanic
(
    ID    CHAR(10),
    Survived  		INT,
    Pclass   			CHAR(1),
    Name               VARCHAR(100),
    Sex                  VARCHAR(10),
    Age                  DOUBLE(10,0) DEFAULT NULL,
    SibSp               INT,
    Parch               INT,
    Ticket               VARCHAR(30),
    Fare            		 INT,
    Cabin               VARCHAR(20),
    Embarked        CHAR(1)
);

### 1) Data Types
# VACHAR, INT, DOUBLE, DATE/DATETIME/TIMESTAMP/TIME/YEAR

### 2) Constraints -> Used to define the "rules" for each variable
# PRIMARY KEY - unique and not NULL.
# FOREIGN KEY - refers to a primary key in another table
# NUT NULL
# DEFAULT -> Age int DEFAULT 28 -> Will show 28 if the value is missing
# UNIQUE
# AUTO_INCREMENT -> Allows a unique number to be generated automatically when a new record is inserted into a table.
# CHECK -> filter the data -> Example: "CONSTRAINT person CHECK (PersonID>25 AND FirstName='Diego')"

ALTER TABLE titanic ADD PRIMARY KEY (ID); # Alter table with new constraints
ALTER TABLE titanic MODIFY parch varchar(255);  # Update current constraints

### 3) Load the local data set into the table 
LOAD DATA LOCAL INFILE '/Users/xuduo/Desktop/Notes/SQL Note/Titanic.csv' INTO TABLE titanic
# Check the dataset in text format
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'  # Name format ->  "A,B" -> ' "" '
LINES TERMINATED BY '\n' 
IGNORE 1 LINES # Ignore the row name
(ID,Survived,Pclass,Name,Sex,@Age,SibSp,Parch,Ticket,Fare,Cabin,Embarked)
SET Age = IF(@Age = '', NULL, @Age); # we want to include the NULL in Age (DOUBLE)

select * from titanic; 



############# TABLE: emp2 #############
CREATE TABLE IF NOT EXISTS emp2
(
    emp_id    INT,
    ename 		VARCHAR(255),
    ename2 		VARCHAR(255),
    email 				VARCHAR(255),
    phoneno VARCHAR(255),
    hire_date 		DATE,
    job_id 				VARCHAR(255),
    salary 				INT(10),
    comm 		INT(10),
    mgr_id  	INT,
    dept   	INT(10),
    age             	    INT(10)
);

show tables;

LOAD DATA LOCAL INFILE '/Users/xuduo/Desktop/Notes/SQL/emps.csv' INTO TABLE emp2
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(emp_id,ename,ename2,email,phoneno,@hire_date,job_id,salary,comm,mgr_id,dept,age)
set hire_date = STR_TO_DATE(@hire_date,'%m/%d/%y'); # STR_TO_DATE() -> Set the date format





########################## Chapter 4: Inserting, Updating, Deleting ##########################
DROP TABLE test;
CREATE TABLE IF NOT EXISTS test (select deptno as id, dname as name, loc as loc from dept);
# (select * from dept where 1=0) => will only copy the column structure instead of the rows

### 1) Inserting a new record
insert into test (id, name, loc) values (1, 'A', 'B'), (2, 'B', ''), (3, null, 'C');

### 2) Copying rows from one table into another
insert into test (id, name, loc) select deptno, dname, loc from dept  where loc in ('NEW YORK', 'BOSTON');

### 4) CREATE VIEW -> Users can create new records but can't provide any value for new columns
create view new_emps as select empno, ename, job from emp;
# improve to security
# create a layer of abstraction between the underlying tables and applications
# -> Use to implement row & column level; 
# -> Simplify queries / the database by join; 
# -> Present aggregated and summarized data

### 5) UPDATE 
SET SQL_SAFE_UPDATES = 0; 
update test set id = id+10 where name = 'OPERATIONS';

### 7) Deleting Records
delete from test where id = 1;
delete from test where id not in (select deptno from dept);
# Deleting duplicate records -> MySQL can't reference the same table twice
insert into test (id, name, loc) values (50, 'SALES', 'NEW YORK'), (60, 'TEACHER', 'NEW YORK');
delete from test where id not in (select min(id) from (select id, loc from test) tmp group by loc);

### 8) Drop 
DROP TABLE IF EXISTS dropdrop;# Drop table
create table dropdrop (select * from titanic);

ALTER TABLE dropdrop DROP COLUMN Cabin, DROP COLUMN Embarked; # Drop columns
ALTER TABLE dropdrop DROP PRIMARY KEY; # Drop constraints

TRUNCATE TABLE dropdrop; # ONLY clean all the dataset instead of drop the entire table.
# * DELETE is similar with truncate but can use with "where"
DROP DATABASE database_name; # Drop a whole database

### 9) INDEX
CREATE INDEX age ON emp2 (ename, age);
CREATE UNIQUE INDEX dept2 ON emp2 (ename, dept);
SHOW INDEX from emp2;
ALTER TABLE emps DROP INDEX NAME; # Drop index
# Why use index?
# -> Speed up the queries
# -> Tthe database search engine can find out the records faster.


########################## Chapter 5: Metadata Queries ##########################
### 1) Listing tables in a schema
select emp from information_schema.tables where table_schema='SMEAGOL';

### 2) Listing a table's columns
select column_name, data_type, ordinal_position from information_schema.columns
where table_schema='SMEAGOL' and table_name = 'EMP';



CREATE TABLE median
(
    num  	 	    INT
);

INSERT INTO median 
(num)
VALUES
("1"),
("2"),
("2"),
("3"),
("4"),
("5");

