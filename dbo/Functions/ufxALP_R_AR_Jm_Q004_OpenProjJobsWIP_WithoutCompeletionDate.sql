CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q004_OpenProjJobsWIP_WithoutCompeletionDate]     
(     
-- created by ravi on 7th Jan 2019, to fix the bugid 876 -- In the JM point edit screen's  Project drop down should also show Projects that are Completed.  
 @EndDate dateTime    
)    
RETURNS TABLE     
AS    
RETURN     
(    
SELECT     
SvcTkt.ProjectId    
FROM ALP_tblJmSvcTkt AS SvcTkt    
WHERE (  SvcTkt.CancelDate Is Null OR   SvcTkt.CancelDate>@EndDate )
 --Or (SvcTkt.CancelDate)>@EndDate))     
 --OR (((SvcTkt.CompleteDate)>@EndDate)     
 --AND SvcTkt.CancelDate Is Null 
GROUP BY SvcTkt.ProjectId    
HAVING SvcTkt.ProjectId Is Not Null    
)