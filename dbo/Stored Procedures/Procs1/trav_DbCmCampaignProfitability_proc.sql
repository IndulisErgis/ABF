
CREATE PROCEDURE dbo.trav_DbCmCampaignProfitability_proc
@CmJcYn bit = 1

AS
BEGIN TRY
	SET NOCOUNT ON

	SELECT c.Descr AS [Description], c.StartDate, c.EndDate
		, COALESCE(p.Cost, c.Cost) AS Cost 
		, ISNULL(a.Value, 0) AS Value 
		, ISNULL(a.Value, 0) - COALESCE(p.Cost, c.Cost) AS Profit 
	FROM dbo.tblCmCampaign c 
		LEFT JOIN 
			(
				SELECT CampaignID, CAST(SUM(Value) AS float) AS Value 
				FROM dbo.tblCmActivity 
				WHERE [Status] <> 1 
				GROUP BY CampaignID
			) a ON c.ID = a.CampaignID 
		LEFT JOIN 
			(
				SELECT ProjectDetailID, CAST(SUM(ExtCost) AS float) AS Cost 
				FROM dbo.tblPcActivity 
				WHERE ([Type] BETWEEN 0 AND 3) AND ([Status] <> 6) AND (@CmJcYn = 1) 
				GROUP BY ProjectDetailID
			) p ON c.ProjectDetailID = p.ProjectDetailID
	WHERE c.[Status] = 0 
	ORDER BY c.Descr

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmCampaignProfitability_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmCampaignProfitability_proc';

