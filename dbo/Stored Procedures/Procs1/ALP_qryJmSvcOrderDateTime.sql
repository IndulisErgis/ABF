
  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcOrderDateTime]   
 @ID int  
As  
SET NOCOUNT ON  
SELECT DISTINCT ALP_tblJmTimeCard.TicketId, ALP_tblJmTimeCard.StartDate,  
 convert(datetime,cast(StartTime/60 as varchar) + ':' + cast(StartTime % 60 as varchar),8)  AS[Time],   
 ALP_tblJmTech.Tech,
 ALP_tblJmTimeCard.TimeCardComment,ALP_tblJmTimeCode.TimeCode --Last 2 columns added by NSK on 27 Jan 2016  
FROM ALP_tblJmTimeCard INNER JOIN ALP_tblJmTech ON 
ALP_tblJmTimeCard.TechID = ALP_tblJmTech.TechID  
INNER JOIN ALP_tblJmTimeCode ON  ALP_tblJmTimeCard.TimeCodeID=  ALP_tblJmTimeCode.TimeCodeID
WHERE ALP_tblJmTimeCard.TicketId=@ID  
ORDER BY StartDate,[Time]  -- order by modified by NSK on 27 Jan 2016