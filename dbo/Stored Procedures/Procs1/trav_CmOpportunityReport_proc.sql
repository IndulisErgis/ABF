
CREATE PROCEDURE dbo.trav_CmOpportunityReport_proc
@SortBy tinyint = 0

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Opportunity resultset
	SELECT o.ID AS OpportunityID
		, CASE @SortBy 
			WHEN 0 THEN s.Descr 
			WHEN 1 THEN p.Descr 
			WHEN 2 THEN b.Descr 
			WHEN 3 THEN r.Descr 
			END AS GrpId1
	, o.Descr AS [Description], o.OpenDate, o.CloseDate, c.ContactName AS Contact
	, b.Descr AS Probability, s.Descr AS [Status], r.Descr AS Resolution, p.Descr AS Campaign, o.Value 
	FROM #OpportunityList t 
		INNER JOIN dbo.tblCmOpportunity o ON t.OpportunityID = o.ID 
		LEFT JOIN dbo.tblCmOppStatus s ON o.StatusID = s.ID 
		LEFT JOIN dbo.tblCmContact c ON o.ContactID = c.ID 
		LEFT JOIN dbo.tblCmCampaign p ON o.CampaignID = p.ID 
		LEFT JOIN dbo.tblCmOppProbCode b ON o.ProbCodeID = b.ID 
		LEFT JOIN dbo.tblCmOppResCode r ON o.ResCodeID = r.ID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmOpportunityReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmOpportunityReport_proc';

