USE ETL_Trains;

CREATE TABLE aux_train (
	TrainId int primary key,
	SeatingCapacity int,
	StandingCapacity int
);

INSERT INTO ETL_Trains.dbo.aux_train
(
	TrainId,
	SeatingCapacity,
	StandingCapacity
)
select
	TrainId,
	SeatingCapacity,
	StandingCapacity
FROM Metro.dbo.Train

Declare @EntryDate datetime; 
SELECT @EntryDate = cast(getdate() as smalldatetime);

MERGE INTO DimTrain AS "Target"
USING (
	SELECT 
		TrainId, 
		SeatingCapacity, 
		StandingCapacity 
	FROM aux_train
) AS "Source"
ON "Target".TrainIdBk = "Source".TrainId
WHEN MATCHED AND
(
	"Target".SeatingCapacity <> "Source".SeatingCapacity OR
	"Target".StandingCapacity <> "Source".StandingCapacity
)
THEN
    UPDATE 
		SET 
			"Target".TrainDeactivationTime = @EntryDate, 
			"Target".TrainIsActive = 0
WHEN NOT MATCHED THEN
INSERT (
	TrainIdBk,
	TrainInsertionTime, 
	TrainDeactivationTime, 
	TrainIsActive, 
	SeatingCapacity, 
	StandingCapacity
)
VALUES (
	"Source".TrainId, 
	@EntryDate, 
	Null, 
	1, 
	"Source".SeatingCapacity, 
	"Source".StandingCapacity
);

INSERT INTO DimTrain (
	TrainIdBk,
	TrainInsertionTime, 
	TrainDeactivationTime,
	TrainIsActive, 
	SeatingCapacity, 
	StandingCapacity
)
SELECT 
	TrainId, 
	@EntryDate,
	Null,
	1,
	SeatingCapacity, 
	StandingCapacity
FROM aux_train
EXCEPT
SELECT
	TrainIdBk,
	@EntryDate, 
	TrainDeactivationTime, 
	1, 
	SeatingCapacity, 
	StandingCapacity
FROM DimTrain;

DROP TABLE aux_train;
--select * from DimTrain;
