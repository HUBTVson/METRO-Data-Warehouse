USE ETL_Trains;
GO

CREATE TABLE aux_station (
	StationId int primary key,
	StationName char(256)
);

INSERT INTO ETL_Trains.dbo.aux_station
(
	StationId,
	StationName
)
select
	StationId,
	StationName
FROM Metro.dbo.Station

MERGE INTO DimStation AS "Target"
USING (
	SELECT 
		StationId, 
		StationName
	FROM aux_station
) AS "Source"
ON "Target".StationId = "Source".StationId
WHEN NOT MATCHED THEN
INSERT (
	StationId, 
	StationName
)
VALUES (
	"Source".StationId, 
	"Source".StationName
);	

DROP TABLE aux_station;
select count(*) from DimStation;
select * from DimStation;
