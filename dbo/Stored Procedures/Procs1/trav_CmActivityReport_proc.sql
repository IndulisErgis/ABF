
CREATE PROCEDURE dbo.trav_CmActivityReport_proc
@ViewNotes bit = 1, 
@SortBy tinyint = 0 -- 0 = Activity Type, 1 = User ID

AS
BEGIN TRY
	SET NOCOUNT ON

	-- Activity resultset
	SELECT a.ID AS ActivityID
		, CASE @SortBy 
			WHEN 0 THEN CASE WHEN a.[Source] <> 0 THEN 'System Defined' ELSE t.Descr END 
			WHEN 1 THEN a.UserID 
			END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN a.UserID 
			WHEN 1 THEN CASE WHEN a.[Source] <> 0 THEN 'System Defined' ELSE t.Descr END 
			END AS GrpId2
		, CASE WHEN a.[Source] <> 0 THEN 'System Defined' ELSE t.Descr END AS ActivityType
		, a.UserID, a.EntryDate, c.ContactName AS Contact, a.Descr AS [Description]
		, a.Value, a.Duration, p.Descr AS CampaignDescription
		, CASE WHEN @ViewNotes <> 0 THEN a.Notes ELSE NULL END AS Notes 
	FROM #ActivityList l 
		INNER JOIN dbo.tblCmActivity a ON l.ActivityID = a.ID 
		LEFT JOIN dbo.tblCmActivityType t ON a.ActTypeID = t.ID 
		LEFT JOIN dbo.tblCmContact c ON a.ContactID = c.ID 
		LEFT JOIN dbo.tblCmCampaign p ON a.CampaignID = p.ID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmActivityReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmActivityReport_proc';

