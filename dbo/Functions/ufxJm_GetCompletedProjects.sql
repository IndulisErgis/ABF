CREATE FUNCTION [dbo].[ufxJm_GetCompletedProjects]
--Created 04/11/06 MAH - for use in JM ProjectSummary Report
	(
	@CompletionDateFrom datetime = null,
	@CompletionDateThru datetime = null,
	@SalesRepIDFrom varchar(3) = null,
	@SalesRepIDThru varchar(3) = null,
	@BranchIDFrom integer = null,
	@BranchIDThru integer = null,
	@DivIDFrom integer = null,
	@DivIDThru integer = null,
	@DeptIDFrom integer = null,
	@DeptIDThru integer = null
	)
RETURNS table
AS
RETURN
	SELECT [ALP_tblJmSvcTkt].[ProjectId],dbo.ufxJm_GetProjStatus([ALP_tblJmSvcTkt].[ProjectId]) as Status,
			dbo.ufxJm_GetProjCompletionDate([ALP_tblJmSvcTkt].[ProjectId]) as CompletionDate
	FROM ALP_tblJmSvcTkt

	WHERE   ((ALP_tblJmSvcTkt.ProjectId Is Not Null)
			AND 
			(
			@SalesRepIDFrom is null
			OR
			ALP_tblJmSvcTkt.SalesRepID between @SalesRepIDFrom AND @SalesRepIDThru
			)
			AND
			(
			@BranchIDFrom is null
			OR
			ALP_tblJmSvcTkt.BranchID between @BranchIDFrom AND @BranchIDThru
			)
			AND
			(
			@DivIDFrom is null
			OR
			ALP_tblJmSvcTkt.DivID between @DivIDFrom AND @DivIDThru
			)
			AND
			(
			@DeptIDFrom is null
			OR
			ALP_tblJmSvcTkt.DeptID between @DeptIDFrom AND @DeptIDThru
			)
		)
		AND
		dbo.ufxJm_GetProjStatus([ALP_tblJmSvcTkt].[ProjectId]) = 'Complete'
		AND
		(
			(@CompletionDateFrom is null)
			OR
			(dbo.ufxJm_GetProjCompletionDate([ALP_tblJmSvcTkt].[ProjectId]) BETWEEN @CompletionDateFrom AND @CompletionDateThru)
		)
	GROUP BY [ALP_tblJmSvcTkt].[ProjectId]