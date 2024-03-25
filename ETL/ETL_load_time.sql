USE ETL_Trains;
GO

CREATE TABLE aux_time (
	TimeId int primary key,
	TimeHour int,
	TimeMinute int,
	TimeSecond int
);

BULK INSERT aux_time
FROM 'C:\Users\USER\Desktop\Politechnika Gdanska\Semester_4\Data_Warehouses\ETL\ETL_Trains\data\times.csv'
WITH (FIELDTERMINATOR = ',');

MERGE INTO DimTime AS "Target"
USING (
	SELECT 
		TimeId,
		TimeHour,
		TimeMinute,
		TimeSecond
	FROM aux_time
) AS "Source"
ON "Target".TimeId = "Source".TimeId
WHEN NOT MATCHED THEN
INSERT (
	TimeId,
	TimeHour,
	TimeMinute,
	TimeSecond
)
VALUES (
	"Source".TimeId, 
	"Source".TimeHour, 
	"Source".TimeMinute, 
	"Source".TimeSecond
);

DROP TABLE aux_time;
--select * from DimTime;
