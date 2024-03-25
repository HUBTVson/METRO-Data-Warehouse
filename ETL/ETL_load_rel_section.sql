use ETL_Trains

-- Create the target table (assuming the table name is "AnotherTable")
if (OBJECT_ID('aux_amount') is not null) drop table aux_amount;
CREATE TABLE aux_amount (
    RealSectionId int,
    Amount int,
);

-- Insert the result of the query into the target table
INSERT INTO aux_amount (RealSectionId, Amount)
SELECT RealSectionId, Amount
FROM (
    SELECT COUNT(RealSectionId) AS Amount, RealSectionId
    FROM (
        SELECT rs.RealSectionId, rs.RideId, pr.PassengerRideId, ss.StartStationId, ss.EndStationId, pr.EntryStationId, pr.ExitStationId
        FROM Metro.dbo.RealSection rs
        JOIN Metro.dbo.PassengerRide pr ON rs.RideId = pr.RideId
        JOIN Metro.dbo.ScheduledSection ss ON rs.ScheduledSectionId = ss.ScheduledSectionId
        WHERE (ss.StartStationId >= pr.EntryStationId AND ss.EndStationId <= pr.ExitStationId)
            OR (ss.StartStationId <= pr.EntryStationId AND ss.EndStationId >= pr.ExitStationId)
    ) AS query1
    GROUP BY RealSectionId
) AS query2;


If (object_id('vETLFRealSection') is not null) Drop View vETLFRealSection;
go
CREATE VIEW vETLFRealSection
AS
SELECT
	TrainId,
	TimeId,
	DateId,
	EventId,
	RideId,
	StartStationId,
	EndStationId,
	Amount as AmountOfPassengers,
	DelayAmount,
	CongestionLevel
FROM
	(
	SELECT
		CASE
			WHEN rs.TrainId is NULL THEN -1
			WHEN rs.TrainId is not NULL THEN dt.TrainIdsk
		END AS TrainId,
		TimeId = target_time.Timeid,
		DateId = target_date.DateId,
		CASE
			WHEN rs.EventId is NULL THEN -1
			WHEN rs.EventId is not NULL THEN de.EventId
		END AS EventId,	
		RideId = dr.RideId,
		StartStationId = ss.StartStationId,
		EndStationId = ss.EndStationId,
		CASE
			WHEN Amount is NULL THEN 0
			WHEN Amount is not NULL THEN Amount
		END AS Amount,
		DelayAmount = DATEDIFF(MINUTE,CONVERT(TIME,rs.RealArrivalTime), CONVERT(TIME,ss.ArrivalTime)),
		CASE
			WHEN Amount - (SeatingCapacity + StandingCapacity) < 130 THEN 1
			WHEN Amount - (SeatingCapacity + StandingCapacity) >= 131 AND Amount - (SeatingCapacity + StandingCapacity) <= 210 THEN 2
			ELSE 3
		END AS CongestionLevel
FROM Metro.dbo.RealSection rs
Left JOIN Metro.dbo.ScheduledSection ss ON rs.ScheduledSectionId = ss.ScheduledSectionId
Left JOIN DimRide dr ON rs.RideId = dr.RideId
Left JOIN DimTrain dt ON rs.TrainId = dt.TrainIdBk
AND dt.TrainIsActive = 1
Left JOIN DimEvent de ON rs.EventId = de.EventId
Left JOIN DimStation ds ON ss.StartStationId = ds.StationId
Left JOIN DimStation dn ON ss.EndStationId = dn.StationId
Left JOIN DimDate AS target_date ON target_date.DateYear = DATEPART(YEAR, RealArrivalTime)
			AND target_date.DateMonth = DATEPART(MONTH, RealArrivalTime)
			AND target_date.DateDay = DATEPART(DAY, RealArrivalTime)
Left JOIN DimTime AS target_time ON target_time.TimeHour = DATEPART(HOUR, RealArrivalTime)
			AND target_time.TimeMinute = DATEPART(MINUTE, RealArrivalTime)
			AND target_time.TimeSecond = DATEPART(SECOND, RealArrivalTime)
left JOIN aux_amount a ON rs.RealSectionId = a.RealSectionId
	) as x
go

select * from vETLFRealSection;

MERGE INTO FactRealSection as TT
	USING vETLFRealSection as ST
		ON 	
			TT.TrainId = ST.TrainId
		AND TT.TimeId = ST.TimeId
		AND TT.DateId = ST.DateId
		AND TT.EventId = ST.EventId
		AND TT.RideId = ST.RideId
		AND TT.StartStationId = ST.StartStationId
		AND TT.EndStationId = ST.EndStationId
			WHEN Not Matched
				THEN
					INSERT
					Values (
						  ST.TrainId
						, ST.TimeId
						, ST.DateId
						, ST.EventId
						, ST.RideId
						, ST.StartStationId
						, ST.EndStationId
						, ST.AmountOfPassengers
						, ST.DelayAmount
						, ST.CongestionLevel
					);





