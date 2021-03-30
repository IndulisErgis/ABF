

Create FUNCTION [dbo].[ufxALP_R_AR_Jm_R160_D_CompletedProjs] 
	(
	@Startdate Datetime = null,
	@Enddate Datetime = null
	)
RETURNS TABLE AS  
 
	RETURN (
		SELECT QR160B.ProjectId, QR160B.ProjCompleteDate, QR160B.SalesRepId
		FROM ufxALP_R_AR_Jm_R160_C_CompletedJobs_OpenProjects(@Enddate) as QR160C
		RIGHT JOIN  
				ufxALP_R_AR_Jm_R160_B_CompletedJobs(@Startdate) as QR160B
				ON QR160C.[ProjectId] = QR160B.[ProjectId]
		WHERE QR160C.ProjectId Is Null
		)