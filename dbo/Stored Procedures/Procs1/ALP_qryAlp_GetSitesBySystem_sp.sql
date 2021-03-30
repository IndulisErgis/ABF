

CREATE Procedure [dbo].[ALP_qryAlp_GetSitesBySystem_sp]
	(		
		@AlarmID varchar(50) 
	)
As
SET NOCOUNT ON
/*Builds a temporary table of all Customers related to a particular Site.*/
CREATE Table #tblJmTempSitesBySystem
	(
		SiteID int  NOT NULL,
		CustID varchar(24) NOT NULL
	)
INSERT INTO #tblJmTempSitesBySystem ( SiteID,CustID )
		SELECT  ALP_tblArAlpSiteSys.SiteID, ALP_tblArAlpSiteSys.CustID
		FROM ALP_tblArAlpSiteSys (NOLOCK)
		WHERE (ALP_tblArAlpSiteSys.AlarmID=@AlarmID) and (ALP_tblArAlpSiteSys.PulledDate IS NULL)
		GROUP BY ALP_tblArAlpSiteSys.SiteID, ALP_tblArAlpSiteSys.CustID;
SELECT     #tblJmTempSitesBySystem.SiteID, CASE WHEN ALP_tblArAlpSite.AlpFirstName IS NULL 
                      THEN ALP_tblArAlpSite.SiteName WHEN ALP_tblArAlpSite.AlpFirstName = '' THEN ALP_tblArAlpSite.SiteName ELSE ALP_tblArAlpSite.SiteName + ', ' + ALP_tblArAlpSite.AlpFirstName
                       END AS SiteFullName, ALP_tblArAlpSite.Addr1 AS SiteAddress, ALP_tblArAlpSubdivision.[Desc] AS Subdivision, ALP_tblArAlpSite.Block AS LotNo, 
                      ALP_tblArAlpSite.Status AS SiteStatus, CASE WHEN ALP_tblArAlpSite.Addr1 = ALP_tblArCust_view.Addr1 THEN 1 ELSE 2 END AS Priority
FROM         #tblJmTempSitesBySystem INNER JOIN
                      ALP_tblArAlpSite ON #tblJmTempSitesBySystem.SiteID = ALP_tblArAlpSite.SiteId INNER JOIN
                      ALP_tblArCust_view ON #tblJmTempSitesBySystem.CustID = ALP_tblArCust_view.CustId  LEFT OUTER JOIN
                      ALP_tblArAlpSubdivision ON ALP_tblArAlpSite.SubDivID = ALP_tblArAlpSubdivision.SubdivId
	--Delete the temporary table
	

DROP Table #tblJmTempSitesBySystem