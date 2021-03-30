
CREATE VIEW dbo.ALP_lkpJmWorkCode AS SELECT WorkCode, [Desc], SvcYN,WorkCodeId From ALP_tblJmWorkCode WHERE InactiveYN = 0