-- Q1

create or replace function sqr(input numeric) returns numeric
as $$
begin
    return input * input;
end;
$$ language plpgsql;



-- Q2

-- For loop with argument name
create or replace function spread(word text) returns text
as $$
declare
    result  text := '';
    i       integer := 1;
begin
    for i in 1..length(word)
    loop
        result := result || substr(word, i, 1) || ' ';
    end loop;
    -- Optionally, we could also remove the trailing space
    return trim(result);
end;
$$ language plpgsql;


-- While loop without argument name
create or replace function spread_variation(text) returns text
as $$
declare
    result  text := '';
    i       integer := 1;
begin
    while (i <= length($1))
    loop
        result := result || substr($1, i, 1) || ' ';
        i := i + 1;
    end loop;
    return result;
end;
$$ language plpgsql;



-- Q7 (returns a string)

create function hotelsIn(_addr text) returns text
as $$
declare
    result  text := '';
    hotel   record;
begin
    -- Loop through all the hotels that exist in a suburb
    for hotel in (
        select *
        from    bars
        where   address = _addr)
    loop
        result := result || hotel.name || e'\n';
    end loop;
    return result;
end;
$$ language plpgsql;




-- Q8 (returns a string)

-- Naive way using 2 queries (with the 'into' keyword to store the output into a variable)
create function hotelsIn(_addr text) returns text
as $$
declare
    result  text := '';
    hotel   record;
    _number integer := 0;
begin
    -- Check if the suburb exists in the database
    select  count(*) into _number
    from    bars
    where   address = _addr;
    
    if (_number = 0)
    then
        return 'There are no hotels in ' || _addr || e'\n';
    end if;
    
    -- Since suburb exists, loop through all the hotels and build up the 'result' string
    for hotel in 
        (select *
        from    bars
        where   address = _addr)
    loop
        result := result || hotel.name || '  ';
    end loop;
    
    result := 'Hotels in ' || _addr || ':  ' || result;
    return result;
end;
$$ language plpgsql;


-- Naive way using 2 queries (with 'not found')
create function hotelsIn(_addr text) returns text
as $$
declare
    result  text := '';
    hotel   record;
begin
    -- If we are not using the output of a query, use the 'perform' keyword
    perform *
    from    bars
    where   address = _addr;
    
    -- If there was no output, then that means the suburb does not exist
    if (not found)
    then
        return 'There are no hotels in ' || _addr || e'\n';
    end if;
    
    for hotel in 
        (select *
        from    bars
        where   address = _addr)
    loop
        result := result || hotel.name || '  ';
    end loop;
    
    result := 'Hotels in ' || _addr || ':  ' || result;
    return result;
end;
$$ language plpgsql;


-- Naive way using 2 queries (with the 'exists' keyword)
create function hotelsIn(_addr text) returns text
as $$
declare
    result  text := '';
    hotel   record;
begin
    
    if exists 
        (select *
        from    bars
        where   address = _addr)
    then
        for hotel in 
            (select *
            from    bars
            where   address = _addr)
        loop
            result := result || hotel.name || '  ';
        end loop;
        
        result := 'Hotels in ' || _addr || ':  ' || result;
        return result;
    end if;
    return 'There are no hotels in ' || _addr || e'\n';
end;
$$ language plpgsql;


-- Optimal approach that uses 1 query
create function hotelsIn(_addr text) returns text
as $$
declare
    result  text := '';
    hotel   record;
begin   
    for hotel in 
        (select *
        from    bars
        where   address = _addr)
    loop
        result := result || hotel.name || '  ';
    end loop;
    
    -- If 'result' is still the initial empty string, then the suburb does not exist
    if (result = '')
    then
        return 'There are no hotels in ' || _addr || e'\n';
    end if;
    
    result := 'Hotels in ' || _addr || ':  ' || result;
    return result;
end;
$$ language plpgsql;



-- Q10 (returns a table with SQL function)

create or replace hotelsIn(suburb text) returns setof Bars
as $$
    select  *
    from    bars
    where   address = suburb;
$$ language sql;



-- Q11 (returns a table with PL/pgSQL function)

create function hotelsIn(_addr text) returns text
as $$
declare
    hotel   record;
begin
    -- Loop through all the hotels that exist in a suburb
    for hotel in 
        (select *
        from    bars
        where   address = _addr)
    loop
        return next hotel;
    end loop;
    return;
end;
$$ language plpgsql;
