--zadanie 3

CREATE INDEX idx_intersects_rast_gist ON uk_250k
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('public'::name, 'uk_250k'::name,'rast'::name);

CREATE INDEX idx_intersects_rast_gist2 ON uk_250k_2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('public'::name, 'uk_250k_2'::name,'rast'::name);

CREATE TABLE mosaic AS
SELECT lo_from_bytea(0,
 ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
 ) AS loid
FROM uk_250k_2;

SELECT lo_export(loid, 'E:\zadanie3.tiff')
 FROM mosaic;

SELECT lo_unlink(loid)
 FROM mosaic;


--zadanie 6

SELECT UpdateGeometrySRID('national_parks','geom',4277);

CREATE TABLE uk_lake_district AS
select ST_Clip(a.rast, b.geom, true)
FROM uk_250k AS a, national_parks AS b
where ST_Intersects(a.rast,b.geom) and  b.gid=1;

CREATE TABLE uk_lake_district_file AS
SELECT lo_from_bytea(0,
 ST_AsGDALRaster(ST_Union(a.st_clip), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
 ) AS loid
FROM uk_lake_district  AS a;

SELECT lo_export(loid, 'E:\zadanie6.tiff')
 FROM uk_lake_district_file;

SELECT lo_unlink(loid)
 FROM uk_lake_district_file;

--zadanie 10

CREATE INDEX idx_intersects_rast_gist3 ON sentinel
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('public'::name, 'sentinel'::name,'rast'::name);

CREATE TABLE converted AS
select a.rid,ST_Transform(a.rast, 27700)
FROM sentinel a;

CREATE INDEX idx_intersects_rast_gist5 ON converted
USING gist (ST_ConvexHull(st_transform));

SELECT AddRasterConstraints('public'::name, 'converted'::name,'st_transform'::name);

create or replace function ndvi(
value double precision [] [] [],
pos integer [][],
VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value
[1][1][1]);
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE sentinel_ndvi AS
SELECT
converted.rid,ST_MapAlgebra(
converted.st_transform, ARRAY[1,4],
'ndvi(double precision[],
integer[],text[])'::regprocedure,
'32BF'::text
) AS rast
FROM converted;

SELECT UpdateGeometrySRID('national_parks','geom',27700);

CREATE TABLE sentinel_clip AS
select ST_Clip(a.st_transform , b.geom, true)
FROM converted  AS a, national_parks AS b
where ST_Intersects(a.st_transform,b.geom) and  b.gid=1;
 
CREATE INDEX idx_intersects_rast_gist6 ON sentinel_clip
USING gist (ST_ConvexHull(st_clip));

SELECT AddRasterConstraints('public'::name, 'sentinel_clip'::name,'st_clip'::name);

------------------------------------------------------------

CREATE TABLE sentinel_clip_file AS
SELECT lo_from_bytea(0,
 ST_AsGDALRaster(ST_Union(a.st_clip), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
 ) AS loid
FROM resized  AS a;
--SQL Error [XX000]: ERROR: rt_raster_from_two_rasters: The two rasters provided do not have the same alignment


SELECT lo_export(loid, 'E:\zadanie11.tiff')
 FROM sentinel_clip_file;

SELECT lo_unlink(loid)
 FROM sentinel_clip_file;