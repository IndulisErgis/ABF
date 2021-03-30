
CREATE PROCEDURE [dbo].[ALP_qryJmUpdateRecJobDates]  
--EFI#1454 MAH 08/25/04 - Menu Security changes: uses tmp table populated  
--   during Recur Job Process (tmpJmRecurJob) to determine  
--   which RecurJObs to update, rather than updating the  
--   view (rptJmRecurJob) that had been created  
--   within the app.   
As  
SET NOCOUNT ON  
--UPDATE rptJmRecurJob  
--SET LastCycleStartDate = NextCycleStartDate, NextCycleStartDate = DateAdd(month, Units, NextCycleStartDate), LastDateCreated = Getdate()  
UPDATE ALP_tblArAlpSiteRecJob  
SET LastCycleStartDate = tmp.NextCycleStartDate,
--MAH 09/07/2015: Units is not coming through correctly when less than 1 ('WK' cycle), 
--    causing error in assignment of NextCycleStartDate.  Handled this is the added CASE statement 
-- NextCycleStartDate = DateAdd(month,tmp.Units,tmp.NextCycleStartDate),
 NextCycleStartDate = CASE WHEN Cycle = 'WK' THEN  DateAdd(day,7,tmp.NextCycleStartDate) 
	ELSE DateAdd(month,tmp.Units,tmp.NextCycleStartDate)
	END,   
 LastDateCreated = Getdate()  
FROM ALP_tmpJmRecurJob tmp  
WHERE tmp.RecJobEntryId = ALP_tblArAlpSiteRecJob.RecJobEntryId