--zadanie 1
select b.polygon_id, b.geom
from buildings2019 b 
left join buildings2018 b2 
on b.geom=b2.geom 
where b2.polygon_id IS NULL;

--zadanie 2
select points.type,count(*)
from
(select b.polygon_id, b.geom from buildings2019 b left join buildings2018 b2 on b.geom=b2.geom where b2.polygon_id is null) as buildings
cross join
(select distinct p.geom,p.type from points2019 p left join points2018 p2 on p.geom =p2.geom where p2.poi_id is null) as points 
where st_distancesphere(points.geom,buildings.geom)<500
group by points.type;

--zadanie 3
create table streets_reprojected as 
select gid,link_id,st_name,ref_in_id,nref_in_id,func_class,speed_cat,fr_speed_l,to_speed_l,dir_travel,st_transform(geom,3068)
as geom from streets2019;

select * from streets_reprojected;

--zadanie 4
create table input_points (id integer, geometry geometry);
insert into input_points values (1,'POINT(8.36093 49.03174)');
insert into input_points values (2,'POINT(8.39876 49.00644)');
select * from input_points;

--zadanie 5
update input_points
set geometry=st_transform(st_setsrid(geometry,4326),3068);
select * from input_points;

--zadanie 6
update nodes2019
set geom=st_transform(st_setsrid(geom,4326),3068);

select * from nodes2019;

select *,st_distance(geom,line) 
from nodes2019 cross join 
(select st_makeline(array(select geometry from input_points)) as line) as line
where st_distance(geom,line)<200;

--zadanie 7
select count(*) from 
(select * from points2019 where type='Sporting Goods Store') as points,
(select * from lands2019 where type like '%Park%') as lands 
where st_distancesphere(points.geom, lands.geom)<300;

--zadanie 8
select rail2019.geom,water2019.geom,ST_Intersection(rail2019.geom, water2019.geom) as point
from rail2019
cross join water2019
where not ST_IsEmpty(ST_Intersection(rail2019.geom, water2019.geom));


-------KOMENDY-------
--shp2pgsql T2018_KAR_BUILDINGS.shp buildings2018 | psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql T2019_KAR_BUILDINGS.shp buildings2019 | psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql T2018_KAR_POI_TABLE.shp points2018 | psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql T2019_KAR_POI_TABLE.shp points2019 | psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql -s 4326 T2019_KAR_STREETS.shp streets2019 | psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql T2019_KAR_STREET_NODE.shp nodes2019| psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql T2019_KAR_LAND_USE_A.shp lands2019| psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql T2019_KAR_RAILWAYS.shp rail2019| psql -U postgres -h localhost -p 5432 -d cwiczenia3
--shp2pgsql T2019_KAR_WATER_LINES.shp water2019| psql -U postgres -h localhost -p 5432 -d cwiczenia3