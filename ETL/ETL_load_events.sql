USE ETL_Trains;

CREATE TABLE aux_event (
	EventId int primary key,
	EventType char(256)
);

INSERT INTO ETL_Trains.dbo.aux_event
(
	EventId,
	EventType
)
select
	EventId,
	EventType
FROM Metro.dbo."Event"

MERGE INTO DimEvent AS "Target"
USING (
	SELECT 
	EventId,
	EventType
	FROM aux_event
) AS "Source"
ON "Target".EventId = "Source".EventId
WHEN NOT MATCHED THEN
INSERT (
	EventId,
	EventType
)
VALUES (
	"Source".EventId, 
	"Source".EventType
);	

DROP TABLE aux_event;
--select * from DimEvent;
--select COUNT(*) from DimEvent
