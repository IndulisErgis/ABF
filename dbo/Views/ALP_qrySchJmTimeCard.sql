
CREATE VIEW dbo.ALP_qrySchJmTimeCard
AS
SELECT case when Convert(varchar(2),StartTime / 60)>=24  then
	 	CONVERT(DATETIME,CONVERT(varchar(15), StartDate, 101) + ' ' +  Convert(varchar(2),(StartTime / 60)-24) + ':' + Convert(varchar(2),StartTime % 60)  ,101)
	else
		CONVERT(DATETIME,CONVERT(varchar(15), StartDate, 101) + ' ' +  Convert(varchar(2),StartTime / 60) + ':' + Convert(varchar(2),StartTime % 60)  ,101)
	end AS StartDateTime,
		
	case when Convert(varchar(2),EndTime / 60)>=24  then
	 	CONVERT(DATETIME,CONVERT(varchar(15), EndDate, 101) + ' ' + Convert(varchar(2),(EndTime / 60) -24) + ':' + Convert(varchar(2),EndTime % 60) ,101)
	else
		CONVERT(DATETIME,CONVERT(varchar(15), EndDate, 101) + ' ' + Convert(varchar(2),EndTime / 60) + ':' + Convert(varchar(2),EndTime % 60),101)
	end   EndDateTime, TechID,TimeCardID
FROM         dbo.ALP_tblJmTimeCard