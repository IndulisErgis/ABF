
CREATE VIEW dbo.ALP_lkpDfltCauseId AS
SELECT CauseId, [Desc] FROM  dbo.ALP_tblJmCauseCode WHERE CauseCode = 'Add' AND InactiveYn = 0