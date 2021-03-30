
CREATE PROCEDURE dbo.trav_CmCampaignList_proc
@ViewNotes bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Campaign resultset
	SELECT c.ID AS CampaignID, c.Descr AS [Description], c.[Status], c.StartDate, c.EndDate, c.Cost, c.Pieces
		, CAST(p.ProjectName AS nvarchar) + ' / ' + ISNULL(d.TaskId, '') AS ProjectTask
		, d.PhaseId AS PhaseCode, p.CustId AS CustomerID
		, CASE WHEN @ViewNotes <> 0 THEN c.Notes ELSE NULL END AS Notes 
	FROM #tmpCampaignList t 
		INNER JOIN dbo.tblCmCampaign c ON t.CampaignID = c.ID 
		LEFT JOIN dbo.tblPcProjectDetail d ON d.ID = c.ProjectDetailID 
		LEFT JOIN dbo.tblPcProject p ON p.Id = d.ProjectId

	-- Detail resultset
	SELECT d.CampaignID, c.Descr AS [Description] 
	FROM #tmpCampaignList t 
		INNER JOIN dbo.tblCmCampaignDtl d ON t.CampaignID = d.CampaignID 
		LEFT JOIN dbo.tblCmCampType c ON c.ID = d.CampTypeID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmCampaignList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmCampaignList_proc';

