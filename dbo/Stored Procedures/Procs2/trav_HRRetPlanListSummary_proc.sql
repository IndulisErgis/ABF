CREATE PROCEDURE [dbo].[trav_HRRetPlanListSummary_proc]

AS
SET NOCOUNT ON

	--Header
	SELECT r.ID, r.[Description], r.AccountNumber, r.MinimumAge, r.WaitingPeriod, r.EmployerMatchPercent, r.EmployerMaxMatch, r.MaxContribution,
	r.LoansAllowed, f.Description [Frequency Description], t.Description [Trustee Name]
	FROM #tmpRetirementPlan p 
	INNER JOIN dbo.tblHRRetirementPlan r ON p.ID = r.ID
	LEFT JOIN dbo.tblHRTypeCode f ON f.ID = r.FrequencyTypeCodeID AND f.TableID = 15
	LEFT JOIN dbo.tblHRTypeCode t ON t.ID = r.TrusteeTypeCodeID AND t.TableID = 32

	--Detail
	SELECT f.RetPlanID, f.Description, Active 
	FROM #tmpRetirementPlan p INNER JOIN tblHRRetirementFund f ON p.ID = f.RetPlanID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRRetPlanListSummary_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRRetPlanListSummary_proc';

