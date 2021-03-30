
CREATE Procedure [dbo].[ALP_qryJmSvcTktPendingProject]    
 (    
  @SiteID int = null,  
  @CustID pCustId    
 )    
As    
set nocount on   
 --MAH 04/06/15:  change to add CustID check, and more accurate Status field return   
--select ProjectId,InitialOrderDate as OrderDate,'Pending' as Status From ALP_tblJmSvcTktProject  
--WHERE ALP_tblJmSvcTktProject.SiteId = @SiteID   
SELECT p.ProjectId,p.InitialOrderDate as OrderDate,  
Status = CASE WHEN t.CustId IS NULL THEN 'Pending'   --No jobs yet under this project  
     WHEN t.CustId <> @CustId AND t.CustId IS NOT NULL THEN ' '  
     ELSE ' ' END         --Jobs exist, but for different CustId  
   --NOTE: This results in NO record being returned if Project already includes jobs for this site and cust  
FROM ALP_tblJmSvcTktProject p left outer join ALP_tblJmSvcTkt t on p.Projectid = t.ProjectId  
WHERE p.SiteId = @SiteID  AND  t.CustId is null
GROUP BY p.ProjectId, p.InitialOrderDate,   
  CASE WHEN t.CustId IS NULL THEN 'Pending'     
     WHEN t.CustId <> @CustId AND t.CustId IS NOT NULL THEN ' '  
     ELSE ' ' END   
return