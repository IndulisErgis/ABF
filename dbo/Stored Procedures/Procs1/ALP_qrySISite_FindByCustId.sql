CREATE PROCEDURE [dbo].[ALP_qrySISite_FindByCustId]  
(  
 @CustId VARCHAR(10)  
)  
AS  
BEGIN  
 SELECT  
  [s].* , dbo.ALP_tblArAlpBranch.Branch ,  dbo.ALP_tblArAlpSubdivision.Subdiv AS Subdivision
FROM [dbo].[ALP_tblArAlpSite] AS [s]  
 INNER JOIN [dbo].[ALP_ufxSISite_FindByCustId](@CustId) AS [f]  
  ON [f].[SiteId] = [s].[SiteId]  
  --Below condition added by Ravi on 27.11.2013 to fix invalid  column name 'Branch' while loading site from Alpine customer form
  LEFT OUTER JOIN  dbo.ALP_tblArAlpBranch ON [s].BranchId = dbo.ALP_tblArAlpBranch.BranchId  
  LEFT OUTER JOIN  dbo.ALP_tblArAlpSubdivision ON [s].SubDivID = dbo.ALP_tblArAlpSubdivision.SubdivId
END