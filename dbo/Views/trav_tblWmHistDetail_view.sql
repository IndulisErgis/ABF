CREATE VIEW dbo.trav_tblWmHistDetail_view AS SELECT * FROM tblWmHistDetail
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.14311.1561', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblWmHistDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 14311', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_tblWmHistDetail_view';

