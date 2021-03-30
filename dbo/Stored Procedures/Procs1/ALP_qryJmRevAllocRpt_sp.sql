CREATE PROCEDURE [dbo].[ALP_qryJmRevAllocRpt_sp] 
(@StartDate Date = NULL, @EndDate Date = NULL)       
AS 
BEGIN       
select * from dbo.ALP_qryJmRevAllocRpt_Parts_view where CompleteDate between @StartDate and @EndDate
UNION ALL
Select * from dbo.ALP_qryJmRevAllocRpt_Labor_view where CompleteDate between @StartDate and @EndDate
UNION ALL
select * from dbo.ALP_qryJmRevAllocRpt_Other_view where CompleteDate between @StartDate and @EndDate
ORDER BY ItemId
END