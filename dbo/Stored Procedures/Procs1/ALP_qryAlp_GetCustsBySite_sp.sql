CREATE Procedure [dbo].[ALP_qryAlp_GetCustsBySite_sp]
	(		
		@SiteID int = 0
	)
As
SET NOCOUNT ON
/*Builds a temporary table of all Customers related to a particular Site.*/
--modified 1/27/14 - MAH - modified to ignore expired or cancelled services, because these can often belon
--modifed 1/30/14 - MAH - modified to use Status from tblArCust ( new field ) rather than the alpine table.
CREATE Table #tblJmTempCustsBySite
	(
		CustId varchar(24)   NOT NULL,
		SiteID int NOT NULL
	)
INSERT INTO #tblJmTempCustsBySite ( CustId,SiteID )
		SELECT ALP_tblArAlpSiteSys.CustId,ALP_tblArAlpSiteSys.SiteId
		FROM ALP_tblArAlpSiteSys (NOLOCK)
		WHERE (ALP_tblArAlpSiteSys.SiteId=@SiteID) and (ALP_tblArAlpSiteSys.PulledDate IS NULL)
		GROUP BY ALP_tblArAlpSiteSys.CustId,ALP_tblArAlpSiteSys.SiteId;
--Add to Temporary table, Customers found in RecBill related to requested Site
INSERT INTO #tblJmTempCustsBySite ( CustId,SiteID )
	--MAH 1/27/14:  modified to ignore expired or cancelled services
		SELECT [ALP_tblArAlpSiteRecBill].[CustId],[ALP_tblArAlpSiteRecBill].[SiteId]
		FROM ALP_tblArAlpSiteRecBill (NOLOCK)
			INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [srbs] WITH (NOLOCK)
			ON ALP_tblArAlpSiteRecBill.RecBillID = [srbs].RecBillID   
		WHERE ([ALP_tblArAlpSiteRecBill].[SiteId])=	@SiteID
			AND ([srbs].[Status] <> 'Expired') 
			AND ([srbs].[Status] <> 'Cancelled')
			AND NOT EXISTS 
			(SELECT CustID from #tblJmTempCustsBySite);
		--SELECT [ALP_tblArAlpSiteRecBill].[CustId],[ALP_tblArAlpSiteRecBill].[SiteId]
		--FROM ALP_tblArAlpSiteRecBill (NOLOCK)
		--WHERE ([ALP_tblArAlpSiteRecBill].[SiteId])=@SiteID
		--AND NOT EXISTS 
		--	(SELECT CustID from #tblJmTempCustsBySite);


SELECT     #tblJmTempCustsBySite.CustID, CASE WHEN ALP_tblArCust_view.AlpFirstName IS NULL 
                      THEN ALP_tblArCust_view.CustName WHEN ALP_tblArCust_view.AlpFirstName = '' THEN ALP_tblArCust_view.CustName ELSE ALP_tblArCust_view.CustName + ', ' + ALP_tblArCust_view.AlpFirstName END AS
                       CustFullName,
                       --MAH 01/30/14: corrected which field Status should look at 
                       --CASE WHEN ALP_tblArCust_view.AlpInactive = 1 THEN 'Inactive' ELSE 'Active' END AS CustStatus,
                        CASE WHEN ALP_tblArCust_view.[Status] = 1 THEN 'Inactive' ELSE 'Active' END AS CustStatus,  
                      CASE WHEN ALP_tblArCust_view.Addr1 = ALP_tblArAlpSite.Addr1 THEN 1 ELSE 2 END AS Priority
FROM         #tblJmTempCustsBySite INNER JOIN
                      ALP_tblArCust_view ON #tblJmTempCustsBySite.CustID = ALP_tblArCust_view.CustId  INNER JOIN
                      ALP_tblArAlpSite ON #tblJmTempCustsBySite.SiteID = ALP_tblArAlpSite.SiteID
order by Priority,CustFullName
	--Delete the temporary table
	

DROP Table #tblJmTempCustsBySite