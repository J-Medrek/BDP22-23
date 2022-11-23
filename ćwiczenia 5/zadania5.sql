create database cwiczenia5;

create extension postgis;

--zad 1

create table obiekty (id integer, geometry geometry,name varchar);

insert into obiekty select 1,ST_Collect(array['LINESTRING(0 1,1 1)',
'CIRCULARSTRING(1 1,2 0,3 1)',
'CIRCULARSTRING(3 1,4 2,5 1)',
'LINESTRING(5 1,6 1)']),'obiekt1';

insert into obiekty select 2,ST_Collect(array['LINESTRING(10 6,14 6)',
'CIRCULARSTRING(14 6,16 4,14 2)',
'CIRCULARSTRING(14 2,12 0,10 2)',
'LINESTRING(10 2,10 6)',
'CIRCULARSTRING(11 2,12 3,13 2,12 1,11 2)']),'obiekt2';

insert into obiekty select 3,ST_Collect(array['LINESTRING(10 17,12 3)',
'LINESTRING(12 3,7 15)',
'LINESTRING(7 15,10 17)']),'obiekt3';

insert into obiekty select 4,ST_Collect(array['LINESTRING(20 20,25 25)',
'LINESTRING(25 25,27 24)',
'LINESTRING(27 24,25 22)',
'LINESTRING(25 22,26 21)',
'LINESTRING(26 21,22 19)',
'LINESTRING(22 19,20.5 19.5)']),'obiekt4';

insert into obiekty select 5,ST_Collect(array['POINT Z (30 30 59)',
'POINT Z (38 32 234)']),'obiekt5';

insert into obiekty select 6,ST_Collect(array['LINESTRING(1 1,3 2)',
'POINT(4 2)']),'obiekt6';

select * from obiekty;

--zad 2

select st_area(st_buffer(st_shortestline( o1.geometry,o2.geometry),5))
from obiekty o1 cross join obiekty o2
where o1.id=3 and o2.id=4;

--zad 3
--Geometria musi byc zamknieta linia
select geometry,
ST_LineMerge(ST_CollectionExtract(st_collect(geometry,'LINESTRING(20.5 19.5,20 20)')),true),
st_makepolygon(ST_LineMerge(ST_CollectionExtract(st_collect(geometry,'LINESTRING(20.5 19.5,20 20)')),true))
from obiekty where name='obiekt4';

--zad 4
insert into obiekty select 7,
st_collect(o1.geometry,o2.geometry),'obiekt7'
from obiekty o1 cross join obiekty o2
where o1.name='obiekt3' and o2.name='obiekt4';

select * from obiekty;

--zad 5
select sum(st_area(st_buffer(geometry,5))) from obiekty where ST_HasArc(geometry) is false;

