use ETL_Trains

Declare @StartDate date;
Declare @EndDate date;

SELECT @StartDate = '2018-01-01', @EndDate = '2022-12-31';

Declare @DateInProcess date= '2018-01-01';
Declare @Key int= 0;

While @DateInProcess <= @EndDate
	Begin
		Insert into [dbo].[DimDate]
	(
		[DateId],
		[DateYear],
		[DateMonth],
		[DateDay],
		[DateDayOfWeek],
		[DateIsBusinessDay],
		[DateSeason]
	)
	Values (
	 @Key
	,Cast( Year(@DateInProcess) as int )
	, Cast( Month(@DateInProcess) as int )
	, Cast( Day(@DateInProcess) as int )
	, Cast( DATEPART(dw,@DateInProcess) as int)
	,CASE 
		WHEN DATEPART(dw,@DateInProcess)>5 then 0
		ELSE 1
	END
	, CASE 
		WHEN Month(@DateInProcess) = 12 THEN 0
		WHEN Month(@DateInProcess) = 1 THEN 0
		WHEN Month(@DateInProcess) = 2 THEN 0
		WHEN Month(@DateInProcess) = 3 THEN 1
		WHEN Month(@DateInProcess) = 4 THEN 1
		WHEN Month(@DateInProcess) = 5 THEN 1
		WHEN Month(@DateInProcess) = 6 THEN 2
		WHEN Month(@DateInProcess) = 7 THEN 2
		WHEN Month(@DateInProcess) = 8 THEN 2
		WHEN Month(@DateInProcess) = 9 THEN 3
		WHEN Month(@DateInProcess) = 10 THEN 3
		WHEN Month(@DateInProcess) = 11 THEN 3
	  END
	);
	Set @DateInProcess = DateAdd(d, 1, @DateInProcess);
	Set @Key = @Key + 1;
End

If (object_id('vETLDimDatesData') is not null) Drop View vETLDimDatesData;
go

CREATE VIEW vETLDimDatesData
AS
SELECT
    DimDate.DateId,
    DimDate.DateDay,
    MonthLookup.MonthName AS [Month],
    DimDate.DateYear,
    CASE
        WHEN DimDate.DateIsBusinessDay = 0 THEN 'day off'
        ELSE 'working day'
    END AS [TypeOfDay],
    CASE
        WHEN DimDate.DateSeason = '0' THEN 'winter'
        WHEN DimDate.DateSeason = '1' THEN 'spring'
        WHEN DimDate.DateSeason = '2' THEN 'summer'
        WHEN DimDate.DateSeason = '3' THEN 'autumn'
    END AS [Season]
FROM ETL_Trains.dbo.DimDate
JOIN (
    VALUES
        (1, 'January'),
        (2, 'February'),
        (3, 'March'),
        (4, 'April'),
        (5, 'May'),
        (6, 'June'),
        (7, 'July'),
        (8, 'August'),
        (9, 'September'),
        (10, 'October'),
        (11, 'November'),
        (12, 'December')
) AS MonthLookup (MonthNumber, MonthName)
ON DimDate.DateMonth = MonthLookup.MonthNumber;

--select * from DimDate;
