CREATE PROCEDURE [dbo].[ALP_qryJm600LaborCostDistRpt_sp]   
(@StartDate Date = NULL, @EndDate Date = NULL) 
--created 12/19/16 MAH - for new Labor Distribution report        
AS   
BEGIN         

Select * from dbo.ALP_qryJm600_Labor_view where CompleteDate between @StartDate and @EndDate
UNION ALL  
select * from dbo.ALP_qryJm600_Other_view where CompleteDate between @StartDate and @EndDate  
ORDER BY ItemId  
END

--exec dbo.ALP_qryJm600LaborCostDistRpt_sp '12/16/2016', '12/19/2016'