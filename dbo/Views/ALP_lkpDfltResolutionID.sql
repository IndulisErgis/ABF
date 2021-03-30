
CREATE VIEW dbo.ALP_lkpDfltResolutionID AS
SELECT ResolutionID, [Desc] FROM dbo.ALP_tblJmResolution WHERE Action = 'Add' AND InactiveYn = 0