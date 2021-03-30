
CREATE VIEW dbo.trav_WmRecordPickedDocument_view
AS
	SELECT Ref1, PickNum, SourceId 
	FROM dbo.tblWmPick_Gen 
	GROUP BY Ref1, PickNum, SourceId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmRecordPickedDocument_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmRecordPickedDocument_view';

