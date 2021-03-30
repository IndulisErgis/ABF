CREATE Procedure [dbo].[ALP_qryAlp_GetSitesByCust_sp]  
 (    
  @CustID  varchar(24)  
 )  
As  
SET NOCOUNT ON  

SELECT    f.SiteID, 
		  CASE 
				WHEN ALP_tblArAlpSite.AlpFirstName IS NULL   
                        THEN ALP_tblArAlpSite.SiteName 
                WHEN ALP_tblArAlpSite.AlpFirstName = '' 
						THEN ALP_tblArAlpSite.SiteName 
                ELSE ALP_tblArAlpSite.SiteName + ', ' + ALP_tblArAlpSite.AlpFirstName  
           END AS SiteFullName, 
          ALP_tblArAlpSite.Addr1 AS SiteAddress,
          ALP_tblArAlpSite.Addr2 AS SiteAddress2, 
          ALP_tblArAlpSubdivision.[Desc] AS Subdivision, 
          ALP_tblArAlpSite.Block AS LotNo,   
          ALP_tblArAlpSite.Status AS SiteStatus, 
          CASE WHEN ALP_tblArAlpSite.Addr1 = ALP_tblArCust_view.Addr1 THEN 1 ELSE 2 END AS Priority ,
          ALP_tblArAlpSite.City,
          ALP_tblArAlpSite.Region,
          ALP_tblArAlpSite.PostalCode,
          ALP_tblArAlpSite.Phone,
          CASE 
				WHEN ALP_tblArAlpSite.Addr1 IS NULL   
                        THEN ALP_tblArAlpSite.Addr2 
                WHEN ALP_tblArAlpSite.Addr1 = '' 
						THEN ALP_tblArAlpSite.Addr2 
				WHEN ALP_tblArAlpSite.Addr2 IS NULL   
                        THEN ALP_tblArAlpSite.Addr1
                WHEN ALP_tblArAlpSite.Addr2 = '' 
						THEN ALP_tblArAlpSite.Addr1 
                ELSE ALP_tblArAlpSite.Addr1 + ', ' + ALP_tblArAlpSite.Addr2  
            END AS SiteAddressFull 
FROM         [dbo].[ALP_ufxSISite_FindByCustId](@CustId) AS f INNER JOIN  
                      ALP_tblArAlpSite ON f.SiteID = ALP_tblArAlpSite.SiteId INNER JOIN  
                      ALP_tblArCust_view ON @CustId = ALP_tblArCust_view.CustId  LEFT OUTER JOIN  
                      ALP_tblArAlpSubdivision ON ALP_tblArAlpSite.SubDivID = ALP_tblArAlpSubdivision.SubdivId