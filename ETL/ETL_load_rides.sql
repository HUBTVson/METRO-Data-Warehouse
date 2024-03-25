USE ETL_Trains;

CREATE TABLE aux_ride (
	RideId int primary key,
	TrainId int
);

INSERT INTO ETL_Trains.dbo.aux_ride
(
	RideId,
	TrainId
)
select
	RideId,
	TrainId

FROM Metro.dbo.Ride

--SET IDENTITY_INSERT DimRide ON;

MERGE INTO DimRide AS "Target"
USING (
	SELECT 
	RideId,
	TrainId

	FROM aux_ride
) AS "Source"
ON "Target".RideId = "Source".RideId
WHEN NOT MATCHED THEN
INSERT (
	RideId,
	TrainId
)
VALUES (
	"Source".RideId,
	"Source".TrainId
);	

--SET IDENTITY_INSERT DimRide OFF;
DROP TABLE aux_ride;
--select * from DimEvent;
--select COUNT(*) from DimEvent
