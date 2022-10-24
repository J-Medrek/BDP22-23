CREATE DATABASE ćwiczenia2;

CREATE EXTENSION postgis;

CREATE TABLE buildings (id integer, geometry geometry,name varchar);
CREATE TABLE roads (id integer, geometry geometry,name varchar);
CREATE TABLE poi (id integer, geometry geometry,name varchar);

insert into buildings values (1,'POLYGON((8 1.5,10.5 1.5,10.5 4,8 4,8 1.5))','BuildingA');
insert into buildings values (2,'POLYGON((4 5,6 5,6 7,4 7,4 5))','BuildingB');
insert into buildings values (3,'POLYGON((3 6,5 6,5 8,3 8,3 6))','BuildingC');
insert into buildings values (4,'POLYGON((9 8,10 8,10 9,9 9,9 8))','BuildingD');
insert into buildings values (5,'POLYGON((1 1,2 1,2 2,1 2,1 1))','BuildingF');

insert into roads values (1,'LINESTRING(0 4.5,12 4.5)','RoadX');
insert into roads values (2,'LINESTRING(7.5 0,7.5 10.5)','RoadY');

insert into poi values (1,'POINT(1 3.5)','G');
insert into poi values (2,'POINT(5.5 1.5)','H');
insert into poi values (3,'POINT(9.5 6)','I');
insert into poi values (4,'POINT(6.5 6)','J');
insert into poi values (5,'POINT(6 9.5)','K');


--a
select sum(ST_Length(geometry)) from roads;

--b
select ST_AsText(geometry),ST_Area(geometry),ST_Perimeter(geometry) from buildings where "name" ='BuildingA';

--c
select name,ST_Area(geometry) from buildings order by name;

--d
select name,ST_Perimeter(geometry) from buildings order by ST_Area(geometry) desc limit 2;

--e
select ST_Distance(b.geometry,p.geometry) from buildings b, poi p where p.name='K' and b.name='BuildingC';

--f
select ST_Area(ST_Difference(a.geometry,ST_Buffer(b.geometry, 0.5))) from buildings a, buildings b where a.name='BuildingC' and b.name='BuildingB';

--g
select b.name from buildings b,roads r where r.name='RoadX' and ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_Centroid(r.geometry));

--8
select ST_Area(ST_SymDifference(geometry,ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))) from buildings where name='BuildingC';