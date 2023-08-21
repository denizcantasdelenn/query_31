--find median salary for each company.

create table employee 
(
emp_id int,
company varchar(10),
salary int
);

insert into employee values (1,'A',2341)
insert into employee values (2,'A',341)
insert into employee values (3,'A',15)
insert into employee values (4,'A',15314)
insert into employee values (5,'A',451)
insert into employee values (6,'A',513)
insert into employee values (7,'B',15)
insert into employee values (8,'B',13)
insert into employee values (9,'B',1154)
insert into employee values (10,'B',1345)
insert into employee values (11,'B',1221)
insert into employee values (12,'B',234)
insert into employee values (13,'C',2345)
insert into employee values (14,'C',2645)
insert into employee values (15,'C',2645)
insert into employee values (16,'C',2652)
insert into employee values (17,'C',65);


--select * from employee


--First solution
select company, avg(salary) as median_salary
from (
select *
from (
select *, 
rank() over(partition by company order by salary) as salary_rank, 
count(*) over(partition by company) as total_cnt
from employee) A
where salary_rank between total_cnt * 1.0/2 and total_cnt * 1.0/2 + 1) B
group by company




--OR
with companies_even_cnt as (
select *, 
rank() over(partition by company order by salary) as salary_rank, 
(count(*) over(partition by company)) / 2 as first, 
(count(*) over(partition by company)) / 2 + 1 as second
from employee
where company in (
select company
from employee
group by company
having count(*) % 2 = 0))
, result_evens as (
select company, avg(salary) as median_salary
from companies_even_cnt
where salary_rank = first or salary_rank = second
group by company)
, companies_odd_cnt as (
select *, 
count(*) over() / 2 + 1 as salary_cnt, 
rank() over(order by salary) as salary_order
from employee
where company in(
select company
from employee
group by company
having count(*) % 2 != 0))
, result_odds as (
select distinct company, salary as median_salary
from companies_odd_cnt
where salary_cnt = salary_order)

select *
from result_evens
union all
select *
from result_odds