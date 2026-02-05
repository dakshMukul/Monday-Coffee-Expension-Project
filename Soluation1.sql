-- Monday coffee Schemas

-- Import Rules
-- 1st import to city
-- 2nd import to products
-- 3rd import to customers
-- 4th import to sales
CREATE DATABASE MondayCoffeeDB;

USE MondayCoffeeDB;

CREATE TABLE city
(
	city_id INT primary KEY,
    city_name varchar(15),
    population bigint,
    estimated_rent FLOAT,
    city_rank INT
);

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,
    customer_name varchar(25),
    city_id INT,
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

CREATE TABLE Products 
(
	product_id INT primary key,
    product_name varchar(35),
    price float
);

create table sales
(
	sale_id int primary key,
    sale_date date,
    product_id int,
    customer_id int,
    total float,
    rating int,
    constraint fk_products foreign key (product_id) references products(product_id),
    constraint fk_customers foreign key (customer_id) references customers(customer_id)
);








