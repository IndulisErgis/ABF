

Create FUNCTION [dbo].[ufxALP_R_AR_Jm_R160_C_CompletedJobs_OpenProjects] 
	(
	@Enddate Datetime = null
	)
RETURNS TABLE AS  
 
	RETURN (
		SELECT [ProjectId]
		FROM ALP_tblJmSvcTkt 
		WHERE 
			([ALP_tblJmSvcTkt].[Status]='New' Or [ALP_tblJmSvcTkt].[Status]='Scheduled' 
			Or [ALP_tblJmSvcTkt].[Status]='Targeted' Or [ALP_tblJmSvcTkt].[Status]='Completed' Or [ALP_tblJmSvcTkt].[Status]='Closed')
			And [ALP_tblJmSvcTkt].[CompleteDate]>@Enddate 
		)