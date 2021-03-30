CREATE PROCEDURE [dbo].[ALP_qryJmGetRecJobDates]    
as
SELECT      ALP_tblArAlpSiteRecJob.NextCycleStartDate, ALP_tblArAlpSiteRecJob.LastDateCreated, ALP_tblArAlpSiteRecJob.LastCycleStartDate, 
                      ALP_tmpJmRecurJob.Cycle, ALP_tmpJmRecurJob.Units, ALP_tmpJmRecurJob.NextCycleStartDate AS TempNextCycleStartDate
FROM         ALP_tblArAlpSiteRecJob INNER JOIN
                      ALP_tmpJmRecurJob ON ALP_tblArAlpSiteRecJob.RecJobEntryId = ALP_tmpJmRecurJob.RecJobEntryId