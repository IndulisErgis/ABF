
CREATE VIEW dbo.ALP_lkpJmCauseId AS SELECT TOP 100 PERCENT CauseId, CauseCode, [Desc], InactiveYN FROM dbo.ALP_tblJmCauseCode WHERE (InactiveYN = 0) ORDER BY CauseCode