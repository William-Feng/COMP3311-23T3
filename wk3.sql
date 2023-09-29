-- Q5

-- (a)

create table R (
    id          integer primary key,
    name        text,
    address     text,
    d_o_b       date
);

create table R (
    id          integer,
    name        text,
    address     text,
    d_o_b       date,
    primary key (id)
);


-- (b)

create domain age as integer check (value > 0 and value < 200);

create table S (
    name        text,
    address     text,
    d_o_b       date,
    -- age         integer check (age > 0 and age < 200),
    age         age,
    primary key (name, address)
);



-- Q9

insert into R(name, d_o_b) values ('Bob', '2000-05-18') returning id;

foreign key integer references R(id)



-- Q13

create table supplier (
    name        text primary key,
    city        text,
);

create table parts (
    number      integer,
    colour      text,
    primary key (number)
);

create table supplies (
    supplier_name   text references supplier(name),
    part_number     integer,
    quantity        integer,
    primary key (supplier_name, part_number),
    foreign key part_number references parts(number)
);
