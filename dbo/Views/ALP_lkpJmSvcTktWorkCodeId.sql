
CREATE VIEW dbo.ALP_lkpJmSvcTktWorkCodeId AS
 SELECT TOP 100 PERCENT WorkCodeId, WorkCode, [Desc], InactiveYN, DfltSkillId, NewWorkYN, PullSystemYn 
 FROM dbo.ALP_tblJmWorkCode WHERE (InactiveYN = 0) ORDER BY WorkCode