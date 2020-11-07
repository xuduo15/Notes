# SQL is a standard language for accessing and manipulating databases.

USE SQL_Diego;
select * from emp;

########################## Chapter 1: Retrieving Records ##########################
### 1) SELECT / DISTINCT /  AS / LIMIT
SELECT DISTINCT ename, job, sal*7 AS RMB FROM emp LIMIT 3;

# OFFSET
select sal from emp order by sal;
select sal from emp order by sal limit 5 offset 0; # Top 5
select sal from emp order by sal limit 5 offset 3; # Top 4 - Top 8 (remove top 1-3)

### 3) CASE / IF()
select ename, sal, 
CASE WHEN sal <= 2000 THEN 'UNDERPAID'
		 WHEN sal >= 4000 THEN 'OVERPAID'
         ELSE 'OK'
END AS status from emp;

# IF()
select ename, sal, IF(sal > 2000, "Yes", "No") as rich from emp; 

### 5a) WHERE / IS (NOT) NULL
select * from emp WHERE comm IS NULL;
### 5b) COALESCE -> Return a specific value if null -> same as IFNULL(Col, #)
select ename, coalesce(comm, "no record") from emp;

### 6a) IN / LIKE -> Remeber to add ""
select job, deptno from emp where deptno IN (10, 20);
select ename, job from emp where job LIKE '%ER';  # ---> "%" for many letters; "_" for one letter
select ID, Ticket from titanic WHERE Ticket LIKE '_@/%' ESCAPE "@";  # ---> ESCAPE "@" -> use "@" to notice special character as a regular character

### 6b) (NOT) REGEXP
select * from emp where ename REGEXP "^[A].*[NS]$"; 
# "[abc]" -> Include a, b or c
# "[^abc]" -> not include a, b or c
# "^" -> Start with
# "$" -> End with
# "." -> One character
# "*" -> Repetitive
# "|" -> Or
# ".*" -> And

### 7) GROUP BY / HAVING -> COUNT / SUM / AVG / MAX / MIN
# --->  "WHERE" will use before GROUP BY because "WHERE" doesn't work with SQL aggregate
#  ---> "HAVING" will use after GROUP BY or after JOIN function
select job, AVG(distinct sal) as avg from emp WHERE sal>1000 GROUP BY job HAVING avg>2000;
select job, COUNT(*) as count from emp GROUP BY job;


########################## Chapter 2: Sorting Query Results ##########################
### 1) ORDER BY
select ename, deptno, sal from emp ORDER BY deptno, sal DESC; # also can write as "order by 2,3 desc"

### 2) Sort NULL to the bottom
# ---> NULL will always be ordered at the top for asceding order
select ename, sal, comm from emp order by comm; 

# Solve:
select ename, sal, comm, 
	case when comm is null then 0 else 1 end as is_null 
from emp order by is_null desc, comm; 

### 5) Sorting on a dependent key
# Sort on comm if the job is "SALESMAN"; Otherwise, sort by sal
# 0 - 300 - 500 - 800 - ... - 1300 - 1400 - 2450
# Regular sort
select ename, sal, job, comm, case when job = 'SALESMAN' then comm else sal end as ordered from emp order by 5;
# Sort with "case statement"
select ename, sal, job, comm from emp order by case when job = 'SALESMAN' then comm else sal end;


########################## Chapter 3: Working with Multiple Tables ##########################
### 1) INNER JOIN / LEFT JOIN / RIGHT JOIN
# ---> We can't use join() directly for outer join
# ---> A left join B -> B may has NULL

select e.ename, e.sal, d.loc, e.deptno from emp as e LEFT JOIN dept as d ON e.deptno = d.deptno;

# We can add OR / AND Logic to combine the join condition
select e.ename, d.deptno, d.loc from dept d left join emp e on (d.deptno = e.deptno and (e.deptno=10 or e.deptno=30)); # Only want to join the data for dept 10 and 30

### 2) UNION -> FULL JOIN
# ---> UNION only save DISTINCT value; "UNION ALL" will select all the values
# ---> UNION will directly connect two datasets (no matter what's the real value)

select e.ename, e.sal, d.loc from emp as e LEFT JOIN dept as d ON e.deptno = d.deptno
UNION
select e.ename, e.sal, d.loc from emp as e RIGHT JOIN dept as d ON e.deptno = d.deptno;

### 3) Self Join
select a.ename as emp, b.ename as manager from emp as a left join emp as b on a.mgr_id=b.emp_id having manager IS NOT NULL;

# Expressing a Child-Parent-Grandparent Relationship
select concat(a.ename, ' --> ', b.ename, ' --> ',c.ename, ' --> ', d.ename, ' (',d.job,')') as emps_and_mgrs
from emp a, emp b, emp c, emp d 
where a.mgr_id=b.emp_id and b.mgr_id = c.emp_id and c.mgr_id = d.emp_id;

### 4) (NOT) IN/EXISTS & BETWEEN / EXISTS
select * from emp where deptno IN (10,30);
select ename, sal from emp where emp_id IN (select salary from employee2); # IN -> If sub-query results is very small
select e.* from emp as e where EXISTS (select deptno from dept as t where  e.deptno = t.deptno and t.dname = "SALES"); # EXISTS -> If sub-query results is very large

### 5) BETWEEN / ANY / ALL
select comm*3 from emp where comm between 1 and 500; 
# The salary between 1 and 500 comm: 900 & 1500 ---> Can also use for characters or date
select ename, sal from emp where sal < ANY (select comm*3 from emp where comm between 1 and 500); 
# ANY - Returns true if any of the subquery values meet the condition (<1500)
select ename, sal from emp where sal < ALL (select comm*3 from emp where comm between 1 and 500); 
#  ALL - Returns true if all of the subquery values meet the condition (<900)


########################## Chapter 4: MySQL String Functions ##########################
# 1. LENGTH()
select ename, LENGTH(ename) from emp;

# 2. CONCAT / CONCAT_WS -> Combine strings
select concat(ename, ' is a ', job), concat_ws('---', ename, 'is a', job) from emp;

# 3. REPLACE()
select ename, replace(replace(replace(ename, 'A', ''),'B',''),'C','') as ename_edit, sal, replace(sal,0,'') as sal_edit from emp; 

# 4. LCASE() / UCASE()
select ename, LCASE(ename) from emp;

# 5. LEFT() / RIGHT()
select ename, LEFT(ename, 2) from emp; 

# 6. SUBSTR(column, start_point, number_string) / INSTR() / SUBSTRING_INDEX()
select job, SUBSTR(job, 6, 3), SUBSTR(job, -3, 2) from emp; 
select job, INSTR(job, 'S') as S, INSTR(job, 'MAN') as MAN from emp;
select hiredate, substring_index(hiredate, "-", 1) as year, substring_index(substring_index(hiredate, "-", 2),"-",-1) as "month", substring_index(hiredate, "-", -1) as "day" from emp;

# Example for substr --> Separate string to characters: "KING" -> "K","I","N","G"
select ename, iter.pos, 
substr(e.ename, iter.pos, 1) a # Step 3: Substr the ename by pos
 from (select ename from emp where ename = "KING") e, (select pos from t10) iter # Step 1: ename = "KING" & pos = "1,2,3,4,5..."
where iter.pos <= length(e.ename); # Step2: pos = 4

# 7. TRIM() / LTRIM() / RTRIM() - removes spaces from a string
select TRIM(ename) from emp;

# 8. GROUP_CONCAT()
select deptno, GROUP_CONCAT(ename order by sal separator ' <-- ') as salary from emp group by deptno;

# Reverse way for GROUP_CONCAT()
select indexs.pos, list.vals,
substring_index(list.vals, ' <-- ', indexs.pos) as first_step,
substring_index(substring_index(list.vals, ' <-- ',indexs.pos), " <-- ",-1) as second_step # Select the last string
from (select pos from t10) as indexs, (select "MILLER <-- CLARK <-- KING" as vals from t1) as list # --> See Note1
where indexs.pos <= (length(list.vals) - length(replace(list.vals, ' <-- ','')))/length(" --> ") +1; # calculate how many values total = 3 --> See Note2

# Note 1 --> We can create a string value by using quotes
select "MILLER <-- CLARK <-- KING" as vals from t1; 

# Note 2 --> How many times does "LL" in a string ("HELLO, HELLO, HELLO")?
select length ('HELLO, HELLO, HELLO') as "original length",  # 19 total
length ( replace ('HELLO, HELLO, HELLO', 'LL', '')) as "length after removing the LL", # 19 - 6 = 13
length ('LL') as "length of LL", # 2
(length ('HELLO, HELLO, HELLO') - length ( replace ('HELLO, HELLO, HELLO', 'LL', ''))) / length ('LL') as LL_count # (19 - 13) / 2
from t1;

# 9. REPEAT()
select REPEAT(ename, 2) from emp;  # Repeats a string


########################## Chapter 5: MySQL Numeric Functions ##########################
# 1. COUNT() / AVG() / SUM() / MAX/MIX()
select COUNT(distinct job) as job, sum(sal) as employee_cost from emp; 
# Aggregate Functions
select job, count(*), max(sal) as max_sal, sum(sal) as sum_sal, round(avg(sal),2) as avg_sal from emp group by job;

# 2.  ROUND() / FLOOR() / CEIL()
select sal, ROUND(sal*0.001, 2) as thousand, floor(sal*0.001) as floor, ceil(sal*0.001) as ceil from emp;

# 3. SIGN() / ABS()
select a.job, a.S, SIGN(a.S), ABS(a.S) from 
(select job, sal, if(job="SALESMAN", -sal, sal) as S from emp order by 3) as a ;

# 4. RAND()
# Method 1: Order value randomly
select ename, job,sal from emp ORDER BY RAND();
# Method 2: Returns a random number [0,1) (include 0 but not 1) 
select rand() from t10;
# Method 3: Returns a random integer number (a-b) (inclusive) ---> a + floor(rand() * (b-a+1))
select 6 + floor(rand() * (10-6+1)) from t10; # from [6, 10]

# 5. POWER() / LOG() / LN() / EXP()
select pos, POWER(pos,2) from t10; 

### 1) Generating a Cumulate Running Total
# Method 1:
select a.emp_id, a.ename, a.sal, (select sum(b.sal) from emp as b where b.emp_id <= a.emp_id) as sum from emp as a;
# Method 2:
select a.emp_id, a.ename, a.sal, sum(b.sal) from emp as a inner join emp as b on a.emp_id>=b.emp_id group by a.emp_id, a.ename, a.sal;

### 2) RANK -> window function for row_number() or dense_rank() 'if there are duplicated"
# Method 1: (rank by sal)
select a.ename, a.sal, (select count(distinct b.sal) from emp b where a.sal <= b.sal) as rn from emp a order by rn limit 5;
# 5000-3000-3000-2975 -> 1-2-2-3
select a.ename, a.sal, (select count(b.sal) from emp b where a.sal <= b.sal) as rn from emp a order by rn limit 5;
# 5000-3000-3000-2975 -> 1-3-3-4
select a.ename, a.sal, (select count(b.sal) +1 from emp b where a.sal < b.sal) as rn from emp a order by rn limit 5;
# 5000-3000-3000-2975 -> 1-2-2-4

# Method 2: (rank by distinct id)
select a.ename,  a.emp_id, count(*) as rn from emp a, emp b where a.emp_id >= b.emp_id group by a.emp_id, a.ename;
# --> For other ranking methods: please see the function on the bottom

# Method 3 -> Regular rank -> 5000, 3000, 3000, 2975 -> only for rank: 1, 2, 3, 4
SET @RANK :=0;
select ename, sal, @RANK := @RANK + 1 AS rank
from emp order by sal desc;

# OR
select ename, sal, @RANK := @RANK + 1 AS rank
from emp, (select @RANK := 0) as a order by sal desc;

### 2) Calculating a Mode (most frequently)
select sal, count(*) from emp group by sal order by 2 desc; # 1250 & 3000 -> We can't use limit directly because we have two most frequent values
# Method 1:
select sal, count(sal) as num from emp group by sal 
having num in (select max(a.count) from (select sal, count(*) as count from emp group by sal) as a);

# Method 2: (better)
select sal, count(*) from emp group by sal having count(*) >= all (select count(*) from emp group by sal);

### 3) Calculating a Median
select e.*, d.* from emp e, emp d;

# Step 1:
select e.sal as sal, abs(sum(sign(e.sal - d.sal))) as cnt2 from emp e, emp d group by e.sal;
# abs(sum(sign(e.sal - d.sal))) -> the median will either equal to 0 (odd) or 1 (even)

# Step 2:
select avg(a.sal), a.cnt2 from  
(select e.sal as sal, abs(sum(sign(e.sal - d.sal))) as cnt2 from emp e, emp d group by e.sal having cnt2=1 or cnt2=0) a # use abs because cnt also may equal to -1
group by a.cnt2;
    
############# WARNING!!!
select * from median; # 1, 2, 2, 3, 4, 5 -> not work in this case -> think a better solution
select avg(a.num), a.cnt2 from  
(select e.num as num, abs(sum(sign(e.num - d.num))) as cnt2 from median e, median d group by e.num having cnt2=1 or cnt2=0) a 
group by a.cnt2; # should be 2.5

# Solve
# Step One:
select num, @rnk := @rnk + 1 as rnk from median, (select @rnk := 0) as a;
# Step Two:
select b.*, c.*, sign(b.rnk-c.rnk2) 
from (select num, @rnk := @rnk + 1 as rnk from median, (select @rnk := 0) as a) as b, (select num, @rnk2 := @rnk2 + 1 as rnk2 from median, (select @rnk2 := 0) as a) as c;
# Step Three
select b.num, b.rnk, abs(sum(sign((b.rnk-c.rnk2)))) as med from 
(select num, @rnk := @rnk + 1 as rnk from median, (select @rnk := 0) as a) as b, (select num, @rnk2 := @rnk2 + 1 as rnk2 from median, (select @rnk2 := 0) as a) as c
group by b.num, b.rnk;
# Step Four
select avg(d.num) from # new
(select b.num, b.rnk, abs(sum(sign((b.rnk-c.rnk2)))) as med from 
(select num, @rnk := @rnk + 1 as rnk from median, (select @rnk := 0) as a) as b, (select num, @rnk2 := @rnk2 + 1 as rnk2 from median, (select @rnk2 := 0) as a) as c
group by b.num, b.rnk) d
where d.med = 1 or d.med = 0; # new

# Method 2: Works perfect
select avg(a.num) from (select num, @rowindex:=@rowindex + 1 as rowindex from median order by num) AS a, (select @rowindex := -1) as b
where a.rowindex in (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2)); 
# @rowindex is the last index value
# when count = 3, rowindex = 0, 1, 2 --> 2/2 = 1 --> floor(1) = ceil(1) = 1
# when count = 4, rowindex = 0, 1, 2, 3 --> 3/2 = 1.5 --> floor(1.5) = 1 and ceil(1.5) = 2

# The other way to use "@rowindex"
SET @rowindex := -1;
select avg(b.num) from (select @rowindex:=@rowindex + 1 as rowindex, num from median order by num) AS b
where b.rowindex in (FLOOR(@rowindex / 2) , CEIL(@rowindex / 2));

# Method 3:
# Please check Leetcode -> Q 571
# Add the data --> only works if there is an index

### 4) Determining the Percentage of a Total salary in deptno 10
# Method one:
select round(a.aa/b.bb*100,2) as pct from
(select sum(a.sal) as aa from emp as a where deptno =10) a, (select sum(sal) as bb from emp) b;
# Method two:
select deptno, sal, case when deptno =10 then sal end from emp; # step one
select (sum( case when deptno = 10 then sal end) / sum(sal) )*100 as pct from emp; # step two

### 5) Computing Averages without high and low values
select avg(sal) from emp where sal not in ((select min(sal) from emp), (select max(sal) from emp));
    
### 6) Shifting Row Values: FORWARD AND REWIND
select e.ename, e.sal, 
(select min(sal) from emp d where d.sal > e.sal) as forward,
(select max(sal) from emp d where d.sal < e.sal) as rewind
from emp e order by 2;

### 7) WITH ROLLUP -> Calculating Simple Subtotals
select job, sum(sal) as sal from emp group by job with rollup;
select ifnull(job,'TOTAL') as Job, sum(sal) as Sal from emp group by job with rollup; 

### 8) Determining which rows are reciprocals
select * from Reciprocal;
# Method 1:
select distinct a.* from Reciprocal as a, Reciprocal as b where a.TEST1 = b.TEST2 and a.TEST2 = b.TEST1 and a.TEST1 <= b.TEST1;

# Method 2:
select distinct a.* from Reciprocal as a left join Reciprocal as b on a.TEST2 =  b.TEST1 and a.TEST1 = b.TEST2
where b.TEST1 is not null 
and a.TEST1 <= a.TEST2; # 70-90 & 90-70 -> keep one value
    
    

########################## Chapter 6: Date Arithmetic ##########################
##### 10. DATES #####
# 1. NOW() / CURDATE() / CURTIME()
select NOW(), CURDATE(), CURTIME(); 

# 2. DATE() -> use DATE(hiredate) to create the date format if it didn't define as "DATE" type yet
select date(hiredate) from emp; 

# 3. DATE_FORMAT()
select current_timestamp,
DATE_FORMAT(current_timestamp, "%Y / %y") as year, 
DATE_FORMAT(current_timestamp, "%M / %b / %m") as month,
DATE_FORMAT(current_timestamp,"%d / %D") as day,
DATE_FORMAT(current_timestamp,"%W / %a") as weekday,
DATE_FORMAT(current_timestamp,"%k:%i:%s") as h_m_s,
DATE_FORMAT(current_timestamp,"%p") as am_pm,
DATE_FORMAT(current_timestamp,"%j") as day_of_the_year
from t1;

# 4. Extract Date
# Method One:
select current_timestamp, 
year(current_timestamp) as Year, # year() / month() / day() --> 2020 / 10 / 08
# monthname() --> October; week() --> Thursday
hour(current_timestamp) as Hour # hour() / minute() / second()
from t1;

# Method Two:
select EXTRACT(YEAR FROM current_timestamp) as Year, # YEAR / MONTH / DAY / QUARTER
EXTRACT(HOUR FROM current_timestamp) as Hour # HOUR / MINUTE / SECOND
from t1; 

# 4. Add or Subtract day / month / year
select hiredate, hiredate + interval 5 day as add1 from emp limit 5; 
select hiredate, DATE_ADD(hiredate, INTERVAL 5 DAY) as add2 from emp limit 5; # date_sub()

# 5. DATEDIFF(date1, date2) / TIMESTAMPDIFF(period, date2, date1)
select hiredate, "1980-12-12", DATEDIFF(hiredate, DATE("1980-12-12")) as Diff from emp limit 5; # Left - Right
select hiredate, "1980-12-12", TIMESTAMPDIFF(MONTH, DATE("1980-12-12"), hiredate) as Diff from emp limit 5; # Right - Left

### 1) Determining the number of business days between two dates (remove weekend)
# ALLEN -> 1981/02/20
# WARD -> 1981/02/22

# step 1 -> choose two different date for ALLEN and WARD separately
select case when ename = "ALLEN" then hiredate end as allen, 
case when ename = "WARD"  then hiredate end as ward 
from emp;

# step 2 -> use "max" to remove NULL
select max(case when ename = "ALLEN" then hiredate end) as allen, 
max(case when ename = "WARD"  then hiredate end) as ward from emp;

# step 3 -> Add the pos, Add all the dates betwen ALLEN and WARD
select x.*, t10.* , allen+ interval t10.pos day as dates
from (
	select max(case when ename = "ALLEN" then hiredate end) as allen, 
	max(case when ename = "WARD"  then hiredate end) as ward from emp) x, t10
where t10.pos <= datediff(ward,allen)+1;

# step 4 -> filter & select the right date and calculate how many business days between
select sum(case when date_format(allen+ interval t10.pos day, '%a') in ('Sat','Sun') then 0 else 1 end) as dates2 
from (
	select max(case when ename = "ALLEN" then hiredate end) as allen, 
	max(case when ename = "WARD"  then hiredate end) as ward from emp) x, t10
		where t10.pos <= datediff(ward,allen)+1; # datediff is "left - right"

### 2) Determining the Date Difference Between the Current Record and the Next Record
# step 1 -> choose the min hiredate
select e.deptno, e.ename, e.hiredate, (select min(d.hiredate) from emp d) as next_hd from emp as e;
# step 2 -> choose the next hiredate for each record
select e.deptno, e.ename, e.hiredate, (select min(d.hiredate) from emp d where d.hiredate>e.hiredate) as next_hd,
datediff((select min(d.hiredate) from emp d where d.hiredate>e.hiredate), e.hiredate) as diff from emp as e;



########################## Chapter 8: Reporting and Warehousing ##########################
### 1) Pivoting a result set into one row
# Step one:
select (case when deptno=10 then 1 else 0 end) as deptno_10,
(case when deptno=20 then 1 else 0 end) as deptno_20,
(case when deptno=30 then 1 else 0 end) as deptno_30 from emp;

# Step two:
select sum(case when deptno=10 then 1 else 0 end) as deptno_10,
sum(case when deptno=20 then 1 else 0 end) as deptno_20,
sum(case when deptno=30 then 1 else 0 end) as deptno_30 from emp;

### 2) Reverse pivoting a result set
# Step One:
select dept.deptno, emp_cnts.*
from (select sum(case when deptno = 10 then 1 else 0 end) as deptno_10,
	sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
	sum(case when deptno = 30 then 1 else 0 end) as deptno_30 from emp) emp_cnts, dept;

# Step Two:
select dept.deptno, 
(case dept.deptno
	when 10 then emp_cnts.deptno_10
	when 20 then emp_cnts.deptno_20
	when 30 then emp_cnts.deptno_30 end) as counts_by_dept 
from (select sum(case when deptno = 10 then 1 else 0 end) as deptno_10,
	sum(case when deptno = 20 then 1 else 0 end) as deptno_20,
	sum(case when deptno = 30 then 1 else 0 end) as deptno_30 from emp) emp_cnts, dept;
    
### 3) Pivoting a result set into multiple rows
# step 1: 
select e.job, e.emp_id, e.ename, (select count(*) from emp d where e.job = d.job and e.emp_id < d.emp_id) as rnk from emp e order by 1,2 desc;

# step 2:
select x.rnk, (case when job='CLERK' then ename else null end) as clerks,
(case when job='ANALYST' then ename end) as analysts
from (select e.job, e.ename, (select count(*) from emp d where e.job = d.job and e.emp_id < d.emp_id) as rnk from emp e) x;

# step 3:
select x.rnk, max(case when job='CLERK' then ename else null end) as clerks, 
max(case when job='ANALYST' then ename else null end) as analysts, 
max(case when job='MANAGER' then ename else null end) as mgrs, 
max(case when job='PRESIDENT' then ename else null end) as prez, 
max(case when job='SALESMAN' then ename else null end) as sales 
from (select e.job, e.ename, (select count(*) from emp d where e.job = d.job and e.emp_id < d.emp_id) as rnk from emp e) x
group by rnk;
# use 'max' to because we want to use "group by" and remove the extra NULL

### 4) Creating Buckets of Data with a fixed Size (each bucket has size 5)
select rnk, rnk/5, ceil(rnk/5) as grp, emp_id, ename from (
	select e.emp_id, e.ename, (select count(*) from emp d where e.emp_id <= d.emp_id) as rnk from emp e) x 
    order by 1;
# Remember add 1 to the rank

### 5) Create a predefined number of buckets (four buckets but don't know how many data for each bucket)
select emp_id, ename, rnk, mod(rnk,4) as remainder, mod(rnk,4)+1 as grp from
(select e.emp_id, e.ename, (select count(*) from emp d where e.emp_id >= d.emp_id) as rnk from emp e) x
order by 3;

### 6) Creating Horizontal Histograms
SELECT LPAD('ABCDE', 3, "*") as L1, LPAD('XYZ', 5, "*") as L2, RPAD('XYZ', 5, "*") as R1, LPAD('*', 5, "*") as L3 from t1;
# LPAD(string, length, replace_string to the left)
# L1 -> If the string longer than length -> remove "DE"
# L2-> if the string shorter than length -> add "*" on the left -> add "**" before "XYZ"

select deptno, LPAD('*', count(*), '*') as cnt from emp group by deptno;
# deptno: 10 -> 3, 20 -> 5, 30 -> 6

### 7) Creating Vertical Histograms
# Step 1: 
select case when e.deptno = 10 then '*' else null end deptno_10,
case when e.deptno = 20 then '*' else null end deptno_20,
case when e.deptno = 30 then '*' else null end deptno_30,
(select count(*) from emp d where e.deptno=d.deptno and e.emp_id<d.emp_id) as rnk from emp e order by 1,2,3;

# Step 2:
select max(deptno_10) as d10, max(deptno_20) as d20,max(deptno_30) as d30, rnk 
from(
select case when e.deptno = 10 then '*' else null end deptno_10,
case when e.deptno = 20 then '*' else null end deptno_20,
case when e.deptno = 30 then '*' else null end deptno_30,
(select count(*) from emp d where e.deptno=d.deptno and e.emp_id<d.emp_id) as rnk from emp e) x
group by rnk 
order by 1,2,3;

### 9) Calculating Subtotals for All Possible Expression Combinations
select deptno, job, 'Total by dept and job' as category, sum(sal) as sal from emp group by deptno, job;
select null, job, 'Total by job' as category, sum(sal) as sal from emp group by  job;
select deptno, null, 'Total by dept' as category, sum(sal) as sal from emp group by deptno;
select null, null, 'Grand total for table', sum(sal) from emp;

select deptno, job, 'Total by dept and job' as category, sum(sal) as sal from emp group by deptno, job
union all
select null, job, 'Total by job' as category, sum(sal) as sal from emp group by  job
union all
select deptno, null, 'Total by  dept' as category, sum(sal) as sal from emp group by deptno
union all
select null, null, 'Grand total for table', sum(sal) from emp;

### 10) Using Case Expressions to Flag Rows / Creating a spare matrix
select ename, 
	case when job = 'CLERK' then 1 else 0 end as is_clerk,
	case when job = 'SALESMAN' then 1 else 0 end as is_sales,
	case when job = 'ANALYST' then 1 else 0 end as is_analyst,
	case when job = 'MANAGER' then ename else 0 end as is_manager,
	case when job = 'PRESIDENT' then ename else 0 end as is_president
from emp
order by 2,3,4,5,6;

### 11) Performing Aggregations over a Moving Range of Values
select e.hiredate, e.sal, (select sum(sal) from emp as d ) as spend 
from emp e order by 1;

 select e.hiredate, e.sal, 
 (select sum(sal) from emp as d 
where d.hiredate between date_sub(e.hiredate, interval 30 day) and e.hiredate) as spending_pattern  # where datediff(e.hiredate, d.hiredate) between 0 and 30) as spending_pattern
from emp e order by 1;

###  Windows function
select e.ename, avg(sal) over (partition by job) as job_avg from emp e;