        
        
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktLabor]         
 @ID int        
As        
SET NOCOUNT ON        
SELECT ALP_tblJmTimeCard.TimeCardID, ALP_tblJmTimeCard.TechID, ALP_tblJmTech.Tech, ALP_tblJmTimeCard.StartDate,         
 convert(datetime,cast(StartTime/60 as varchar) + ':' + cast(StartTime % 60 as varchar),8) AS[Time],        
 ALP_tblJmTimeCode.TimeCode,        
 ([EndTime]-[StartTime])/60.00 AS Hours, [BillableHrs] AS BillHrs, Points AS Pts,         
 CASE        
  WHEN ALP_tblJmTimeCard.PayBasedOn = 0 Then ([EndTime]-[StartTime])/60.00 *[laborcostrate]        
  WHEN ALP_tblJmTimeCard.PayBasedOn = 1 Then ([Points]*[PworkRate])+([Points]*[PworkRate]*[PworkLabMarkupPct])        
  ELSE([EndTime]-[StartTime])/60.00*[LaborCostRate]        
 END AS LaborCost,        
 CASE        
  WHEN ALP_tblJmTimeCard.PayBasedOn = 0 THEN [BillableHrs]*[laborcostrate]        
  WHEN ALP_tblJmTimeCard.PayBasedOn = 1 THEN [Points]*[PworkRate]        
  ELSE [BillableHrs]*[LaborCostRate]        
 END AS LaborPrice  ,      
 --Below end date added by NSK on Feb 24 2015      
 ALP_tblJmTimeCard.EndDate     
-- IIf([ALP_tblJmTimeCard].[PayBasedOn]=0,[Hours]*[laborcostrate], IIf([ALP_tblJmTimeCard].[PayBasedOn]=1,([Points]*[PworkRate])+[Points]*[PworkRate]*[PworkLabMarkupPct],[Hours]*[LaborCostRate])) AS LaborCost,        
-- IIf([ALP_tblJmTimeCard].[PayBasedOn]=0,[BillableHrs]*[laborcostrate],IIf([ALP_tblJmTimeCard].[PayBasedOn]=1,[Points]*[PworkRate],[BillableHrs]*[LaborCostRate])) AS LaborPrice        

,ALP_tblJmTimeCard.LockedYN  --Uncommented by NSK on 20 jun 2018 for bug id 742
FROM ALP_tblJmTimeCode RIGHT JOIN ((ALP_tblJmTimeCard INNER JOIN ALP_tblJmTech ON ALP_tblJmTimeCard.TechID = ALP_tblJmTech.TechID)         
 INNER JOIN ALP_tblJmSvcTkt ON ALP_tblJmTimeCard.TicketId = ALP_tblJmSvcTkt.TicketId) ON ALP_tblJmTimeCode.TimeCodeID = ALP_tblJmTimeCard.TimeCodeID        
WHERE ALP_tblJmTimeCard.TicketId =@ID