

Create FUNCTION [dbo].[ufxALP_R_AR_Jm_R160_B_CompletedJobs] 
	(
	@Startdate Datetime = null
	)
RETURNS TABLE AS  
 
	RETURN (
		SELECT ALP_tblJmSvcTkt.ProjectId, 
			Max(ALP_tblJmSvcTkt.CompleteDate) AS ProjCompleteDate,
			ALP_tblJmSvcTkt.SalesRepId
		FROM ALP_tblJmSvcTkt
		WHERE ALP_tblJmSvcTkt.CompleteDate>=@Startdate 
				AND (ALP_tblJmSvcTkt.Status='Closed' Or ALP_tblJmSvcTkt.Status='Completed')
		GROUP BY ALP_tblJmSvcTkt.ProjectId, ALP_tblJmSvcTkt.SalesRepId
		HAVING ALP_tblJmSvcTkt.ProjectId Is Not Null
		
		)