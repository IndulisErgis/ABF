
CREATE VIEW dbo.ALP_lkpJmSvcTktBranchId AS 
SELECT BranchId, Branch, Name, InactiveYN, DfltLocID, GlSegId
 FROM dbo.ALP_tblArAlpBranch WHERE (InactiveYN = 0)