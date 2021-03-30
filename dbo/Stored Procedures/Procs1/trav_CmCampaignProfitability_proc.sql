
CREATE PROCEDURE dbo.trav_CmCampaignProfitability_proc
@ViewActivityDetail bit = 1, 
@CmJcYn bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Campaign resultset
	SELECT c.ID AS CampaignID, c.Descr AS [Description], c.StartDate, c.EndDate
		, COALESCE(p.Cost, c.Cost) AS Cost, ISNULL(a.Value, 0) AS Value
		, ISNULL(a.Value, 0) - COALESCE(p.Cost, c.Cost) AS Profit 
	FROM #tmpCampaignList t 
		INNER JOIN dbo.tblCmCampaign c ON t.CampaignID = c.ID 
		LEFT JOIN 
			(
				SELECT CampaignID, CAST(SUM(Value) AS float) AS Value 
				FROM dbo.tblCmActivity 
				GROUP BY CampaignID
			) a ON c.ID = a.CampaignID 
		LEFT JOIN 
			(
				SELECT ProjectDetailID, CAST(SUM(ExtCost) AS float) AS Cost 
				FROM dbo.tblPcActivity 
				WHERE ([Type] BETWEEN 0 AND 3) AND ([Status] <> 6) AND (@CmJcYn = 1) 
				GROUP BY ProjectDetailID
			) p ON c.ProjectDetailID = p.ProjectDetailID

	-- Activity Detail resultset
	SELECT a.CampaignID, c.ContactName AS Contact, a.EntryDate
		, CONVERT(nvarchar(8), a.EntryDate, 112) AS EntryDateSort
		, d.Descr AS ActivityType, a.Descr AS [Description], a.Value 
	FROM #tmpCampaignList t 
		INNER JOIN dbo.tblCmActivity a ON t.CampaignID = a.CampaignID 
		INNER JOIN dbo.tblCmActivityType d ON a.ActTypeID = d.ID 
		LEFT JOIN dbo.tblCmContact c ON a.ContactID = c.ID 
		LEFT JOIN dbo.tblCmCampaign p ON a.CampaignID = p.ID 
	WHERE @ViewActivityDetail <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmCampaignProfitability_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmCampaignProfitability_proc';

