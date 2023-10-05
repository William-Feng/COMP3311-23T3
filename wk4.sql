/*

insert into TableName(Attr1, Attr2, Attr3, ...)
values (ValForAttr1, ValForAttr2, ValForAttr3);

update TableName
set ListOfAssignments
where Condition;

delete from TableName
where Condition;

create view ViewName(AttributeNames)
as Query;

*/



-- Q2

update  employees
set     salary = salary * 0.8
where   age < 25;



/*

T1
id     | name
-------------------
1      | John
2      | Mary

T2
id     | food
-------------------
1      | sushi
2      | burger

-- The following 3 methods produce the same output (avoid the 3rd method in this course)

select  id, name, food
from    T1 natural join T2;


select  id, name, food
from    T1 (inner) join T2 on T1.id = T2.id;


select  id, name, food
from    T1, T2
where   T1.id = T2.id;


id     | name     | food
--------------------------
1      | John     | sushi
2      | Mary     | burger

--------------------------------------------------

-- Now, what if the database looked like this?

T1
id     | name
-------------------
1      | John
3      | Mary

T2
id     | food
-------------------
1      | sushi
2      | burger


select id, name, food
from T1
    join T2 on T1.id = T2.id;

id     | name     | food
--------------------------
1      | John     | sushi



-- Let's consider the other types of joins

select id, name, food
from T1
    left (outer) join T2 on T1.id = T2.id;

id     | name     | food
--------------------------
1      | John     | sushi
3      | Mary     | null


select id, name, food
from T1
    right (outer) join T2 on T1.id = T2.id;

id     | name     | food
--------------------------
1      | John     | sushi
2      | null     | burger


select id, name, food
from T1
    full (outer) join T2 on T1.id = T2.id;

id     | name     | food
--------------------------
1      | John     | sushi
2      | null     | burger
3      | Mary     | null


https://www.w3schools.com/sql/sql_join.asp

*/



-- Q3

update  employees e
set     salary = salary * 1.1
-- Find all employees who work in the sales department using a subquery
where   e.eid in (
                    select  w.eid
                    from    worksIn w
                            join departments d on w.did = d.did
                    where   d.dname = 'Sales';
                );



-- Q4, Q5, Q7

create table Employees (
    eid         integer,
    ename       text,
    age         integer,
    salary      real check (salary >= 15000),
    primary key (eid)
);

create table Departments (
    did         integer,
    dname       text,
    budget      real,
    manager     integer not null references Employees(eid),
    primary key (did),
    constraint  EnforceFullTimeManagement
                check   (1 = 
                            (select  w.percent
                            from    worksIn w
                                    join    departments d on w.did = d.did
                                    where   w.eid = manager
                            )
                        )
);

create table WorksIn (
    eid     integer references Employees(eid),
    did     integer references Departments(did),
    percent real,
    primary key (eid,did)
);



-- Q12

select  s.sname
from    suppliers s
        join catalog c on s.sid = c.sid
        join parts p on c.pid = p.pid
where   p.colour = 'red';


-- Natural Join Approach
select  s.sname
from    suppliers s
        natural join catalog c
        natural join parts p
where   p.colour = 'red';



-- Q14

select  s.sid
from    suppliers s
        join catalog c on s.sid = c.sid
        join parts p on c.pid = p.pid
where   p.colour = 'red'
        or s.address = '221 Packer Street';
        

-- Union Approach
(
    select  s.sid
    from    suppliers s
            join catalog c on s.sid = c.sid
            join parts p on c.pid = p.pid
    where   p.colour = 'red'
)
union
(
    select  sid
    from    suppliers
    where   address = '221 Packer Street'
);


-- Subquery Approach
select  s.sid
from    suppliers s
where   address = '221 Packer Street'
        or s.sid in (
                        select  c.sid
                        from    catalog c
                                join    parts p on c.pid = p.pid
                        where   p.colour = 'red'
        );



-- Q16

-- Solution's method using "where not exists"
select  S.sid
from    Suppliers S
where   not exists ((select P.pid from Parts P)
                    except
                    (select C.pid from Catalog C where C.sid = S.sid)
                   );


-- Parts: hammer, nail, screw, nut, bolt
-- Bunnings: hammer, nail, screw, nut
-- After the 'except': bolt
-- 'Where not exists' will return false (because the result is not empty)
-- Therefore, do not show Bunnings in the final output

-- Parts: hammer, nail, screw, nut, bolt
-- IKEA: hammer, nail, screw, nut, bolt
-- After the 'except': null
-- 'Where not exists' will return true (because the result is empty)
-- Therefore, show IKEA in the final output


-- Alternate approach
select  c.sid
from    catalog c
group   by c.sid
having  count(distinct(c.pid)) = select count(*) from parts;



-- Q22

-- Solution's method using "all"
select  C.pid
from    Catalog C, Suppliers S
where   S.sname = 'Yosemite Sham' and C.sid = S.sid and
        C.cost >= all(select C2.cost
                     from   Catalog C2, Suppliers S2
                     where  S2.sname = 'Yosemite Sham' and C2.sid = S2.sid
                     );


-- Alternate approach using helper views

-- Parts supplied by the supplier Yosemite Sham (include the cost for comparison)
create or replace view YosemiteShamSupplies(part_id, part_cost)
as
select  c.pid, c.cost
from    catalog c
        join    suppliers s on c.sid = s.sid
where   s.sname = 'Yosemite Sham';

-- Final query
select  y1.part_id
from    YosemiteShamSupplies y1
where   y1.part_cost = (select max(y2.part_cost) from YosemiteShamSupplies y2);
