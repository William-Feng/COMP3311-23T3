-- Q1

create assertion manager_works_in_department
-- Ensure no managers work in a different department
check  (not exists (
                    select  *
                    from    Employees e
                            join Departments d on e.id = d.manager
                    where   e.works_in != d.id
                    )
);



-- Q2

create assertion employee_manager_salary
-- Ensure that no employees earn more than the manager
check  ( not exists (
                    select  *
                    from    Employees e
                            join Departments d on e.works_in = d.id
                            join Employees m on d.manager = m.id
                    where   e.salary > m.salary
                    )
);



-- Q3

create trigger TriggerName
(before | after) EventName -- can be multiple events
on TableName
when Condition -- this line is optional
for each (row | statement)
execute procedure FunctionName(arguments...);


drop trigger TriggerName on TableName;



-- Order of operations
/*

1. BEFORE trigger
2. Constraint checking
3. Operation performed
4. AFTER trigger
5. Constraint checking
6. Commit changes (only if all the steps above did not fail, otherwise changes will be rolled back)

*/

-- Special keywords
/*

new
- Data type RECORD
- Variable holding the new database row for INSERT/UPDATE operations in row-level triggers
- This variable is null in statement-level triggers and for DELETE operations 

old
- Data type RECORD
- Variable holding the old database row for UPDATE/DELETE operations in row-level triggers
- This variable is null in statement-level triggers and for INSERT operations

found
- Data type BOOLEAN
- This variable starts out false within each PLpgSQL function call

TG_OP
- Data type TEXT
- This variable is a string containing one of 'INSERT', 'UPDATE', 'DELETE', or 'TRUNCATE' telling us for which operation the trigger was fired.

*/



-- Q6

create table R(a int, b int, c text, primary key(a,b));
create table S(x int primary key, y int);
create table T(j int primary key, k int references S(x));

-- (a)
-- Primary key constraint on relation R: non-null and unique

create function R_pk_check() returns trigger
as $$
begin
    -- If the primary key of the tuple that we're inserting is NULL, we reject
    if (new.a is null or new.b is null)
    then
        raise exception 'Primary key cannot be null';
    end if;
    
    -- If the primary key is not changed by an 'update', then that's all good
    if (TG_OP = 'update' and old.a = new.a and old.b = new.b)
    then
        return new;
    end if;
    
    -- We now need to ensure that the primary key is unique
    perform *
    from    R
    where   R.a = new.a and R.b = new.b;
    
    if (found)
    then
        raise exception 'Primary key must be unique (cannot already exist in table)';
    end if;
    
    -- Everything passed without exceptions
    return new;
end;
$$ language plpgsql;


create trigger R_pk_trigger
before insert or update
on R
for each row
execute procedure R_pk_check();



-- (b)
-- Foreign key constraint between T.k and S.x: all references are valid

-- When T is being inserted/updated, we need ensure S.x exists
create function T_fk_check() returns trigger
as $$
begin
    perform *
    from    S
    where   S.x = new.k;
    
    -- If that primary key is invalid (doesn't exist), we reject
    if (not found)
    then
        raise exception 'The primary key does not exist in table S';
    end if;
end;
$$ language plpgsql;

create trigger T_fk_trigger
before insert or update
on T
for each row
execute procedure T_fk_check();


-- When S is being deleted/updated, we need to make sure nothing in T refers to S
-- (Assuming that we do not want 'on delete cascade' functionality)
create function S_reference_check() returns trigger
as $$
begin
    -- If the primary key is not changed by an update, then that's all good
    if (TG_OP = 'update' and old.x = new.x)
    then
        return new;
    end if;
    
    -- Check that nothing is referencing the new primary key, otherwise reject
    perform *
    from    T
    where   k = old.x;
    
    if (found)
    then
        raise exception 'There are references to S.x from table T';
    end if;
end;
$$ language plpgsql;

create trigger S_reference_trigger
before delete or update
on S
for each row
execute procedure S_reference_check();



-- Q14 Solutions
create type StateType as ( sum numeric, count numeric );

create function mean_sfunc_iterator(s StateType, v numeric) returns StateType
as $$
begin
    if (v is not null) then
        s.sum := s.sum + v;
        s.count := s.count + 1;
    end if;
    return s;
end;
$$ language plpgsql;

create or replace function mean_final_computation(s StateType) returns numeric
as $$
begin
    if (s.count = 0) then
        return null;
    else
        return s.sum::numeric / s.count;
    end if;
end;
$$ language plpgsql;

create aggregate mean(numeric) (
    -- Examples of the state types are integer, text, tuple (needs to be defined)
    stype     = StateType,
    -- Examples of the initial condition are 0, '', (0, 0)
    initcond  = '(0,0)',
    -- The state function takes state type and a base type (type of data we're aggregating over) as parameters and returns a new stype
    -- You can treat this as a transitioning loop (how does the value change the state on each iteration?)
    sfunc     = mean_sfunc_iterator,
    -- The final function takes the final state as a parameter and returns the request aggregate
    finalfunc = mean_final_computation
);
