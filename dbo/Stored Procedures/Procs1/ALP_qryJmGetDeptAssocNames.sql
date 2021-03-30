
CREATE PROCEDURE [dbo].[ALP_qryJmGetDeptAssocNames] @InactiveYN int=null   AS

SELECT ALP_tblJmTech.TechID, ALP_tblArAlpBranch.Branch, ALP_tblArAlpDept.Dept,ALP_tblJmTech.Tech, ALP_tblJmTech.Name, 
ALP_tblJmTech.PayBasedOn, ALP_tblJmTech.DfltLaborCostPerHour, ALP_tblJmTech.DfltLaborCostPerPoint
 FROM ALP_tblArAlpDept INNER JOIN (ALP_tblArAlpBranch INNER JOIN ALP_tblJmTech ON ALP_tblArAlpBranch.BranchID = ALP_tblJmTech.BranchID)
 ON ALP_tblArAlpDept.DeptID = ALP_tblJmTech.DeptID
WHERE ALP_tblJmTech.InactiveYN<> @InactiveYN or @InactiveYN  IS NULL
ORDER BY ALP_tblArAlpDept.Dept, ALP_tblJmTech.Tech