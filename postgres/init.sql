-- Runs once, when the pgdata volume is created. One database and user per service,
-- like in staging. Each service's Flyway creates its own tables.
create user orders with password 'orders';
create database orders owner orders;

create user catalog with password 'catalog';
create database catalog owner catalog;
