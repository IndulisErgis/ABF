
CREATE Procedure lkpWDB_CustomerSites_sp
/* Rowsource for ABPro cboSiteNameID in frmJm110 ( ControlCenter ) */
	(
	@CustID varchar(10) = '--NONE--'
	)
As
SET NOCOUNT ON

	/*Builds a temporary table of all Sites related to a particular Customer.*/
	CREATE Table #tblJm110CustSites
	(
		SiteId int NOT NULL
	)
	INSERT INTO #tblJm110CustSites ( SiteID )
		SELECT [tblArAlpSiteSys].[SiteId]
		FROM tblArAlpSiteSys (NOLOCK)
		WHERE (tblArAlpSiteSys.[CustId]=@CustID)
			 AND
			(tblArAlpSiteSys.PulledDate Is Null)
		GROUP BY [tblArAlpSiteSys].[SiteId]
	--Create recordset of Site data for the selected customers.  Sort by SiteID
	SELECT tblArAlpSite.SiteId,
		Name =  [SiteName] + 
		CASE WHEN  tblArAlpSite.AlpFirstName IS NULL THEN ''
		     	ELSE CONVERT(varchar,', ')
			+ tblArAlpSite.AlpFirstName
		END,
 		Address1 = tblArAlpSite.Addr1
	FROM #tblJm110CustSites, tblArAlpSite (NOLOCK)  
	WHERE  ( #tblJm110CustSites.SiteID = tblArAlpSite.SiteId) 
		AND 
		(tblArAlpSite.Status = 'Active')
	ORDER BY tblArAlpSite.SiteId,
		[SiteName] + 
		CASE WHEN  tblArAlpSite.AlpFirstName IS NULL THEN ''
		     	ELSE CONVERT(varchar,', ')
			+ tblArAlpSite.AlpFirstName
		END,
		tblArAlpSite.Addr1
	--Delete the temporary table
	DROP Table #tblJm110CustSites