USE ETL_Trains;

insert into DimRide
values
	(-1,-1);
SET IDENTITY_INSERT DimTrain ON;
insert into DimTrain (TrainIdSk,TrainIdBk,TrainInsertionTime,TrainDeactivationTime,TrainIsActive,SeatingCapacity,StandingCapacity)
values
	(-1,-1,cast(getdate() as smalldatetime),NULL,1,NULL,NULL);
SET IDENTITY_INSERT DimTrain OFF;

insert into "DimEvent"
values
	(-1,'Unknown');

insert into DimStation
values
	(-1,'Unknown');

insert into DimTime
values
	(-1,null,null,null);

insert into DimDate
values
	(-1,null,null,null,null,null,'Unknown');