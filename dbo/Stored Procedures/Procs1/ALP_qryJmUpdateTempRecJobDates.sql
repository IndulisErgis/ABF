CREATE PROCEDURE [dbo].[ALP_qryJmUpdateTempRecJobDates]   
@UserId varchar(50) 
-- Procedure created by NSK on 22 sep 2015. This is the copy of ALP_qryJmUpdateRecJobDates.    
-- Created for preview purpose in recurring job form.  
--modified to increase Alpine userID length of 50 from 16, mah 05/05/17      
As        
SET NOCOUNT ON        
--UPDATE rptJmRecurJob        
--SET LastCycleStartDate = NextCycleStartDate, NextCycleStartDate = DateAdd(month, Units, NextCycleStartDate), LastDateCreated = Getdate()        
UPDATE ALP_tmpArAlpSiteRecJob        
SET LastCycleStartDate = tmp.NextCycleStartDate,
 NextCycleStartDate = CASE WHEN Cycle = 'WK' THEN  DateAdd(day,7,tmp.NextCycleStartDate)       
 ELSE DateAdd(month,tmp.Units,tmp.NextCycleStartDate)      
 END,         
 LastDateCreated = Getdate()        
FROM ALP_tmpJmRecurJob tmp        
WHERE tmp.RecJobEntryId = ALP_tmpArAlpSiteRecJob.RecJobEntryId 
and ALP_tmpArAlpSiteRecJob.UserId=@UserId