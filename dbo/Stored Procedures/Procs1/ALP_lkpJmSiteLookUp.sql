CREATE Procedure [dbo].[ALP_lkpJmSiteLookUp]
/* Rowsource for cboSiteNameID in frmJm110 ( ControlCenter ) */
-- EFI# 1521 MAH 100104 - adjust site status display
-- MAH 091813 - added custs associated with the site's recurring billing
-- MAH 012714 - do not pull in recurBill data if not active  
--		(when included, it causes misleading display for sites that were 'turned over' to another customer.)
	(
	@ComboCTL varchar(1) = '',		
	@CustID pCustID = '--NONE--'
	)
As
SET NOCOUNT ON
IF (@ComboCTL <> 'S') AND (@CustID <> '--NONE--')        --(@CustID <> '') AND (@CustID IS NOT NULL)
   BEGIN 
	/*Builds a temporary table of all Sites related to a particular Customer.*/
	CREATE Table #ALP_tblJm110CustSites
	(
		SiteId int NOT NULL
	)
	INSERT INTO #ALP_tblJm110CustSites ( SiteID )
		SELECT [ALP_tblArAlpSiteSys].[SiteId] AS SiteID
		FROM ALP_tblArAlpSiteSys (NOLOCK)
		WHERE (ALP_tblArAlpSiteSys.[CustId]=@CustID)
			 AND
			(ALP_tblArAlpSiteSys.PulledDate Is Null)
			--mah 12/16/13 added check that CustID is not null
			AND ALP_tblArAlpSiteSys.[CustId] is not null
		UNION
		SELECT [ALP_tblArAlpSiteRecBill].[SiteId] AS SiteID
		FROM ALP_tblArAlpSiteRecBill (NOLOCK)
			INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [srbs] WITH (NOLOCK)
			ON ALP_tblArAlpSiteRecBill.RecBillID = [srbs].RecBillID 
		WHERE (ALP_tblArAlpSiteRecBill.[CustId]=@CustID)
			--mah 12/16/13 added check that CustID is not null
			AND ALP_tblArAlpSiteRecBill.[CustId] is not null
			AND ([srbs].[Status] <> 'Expired') 
			AND ([srbs].[Status] <> 'Cancelled')
		GROUP BY SiteID
		
	--Create recordset of Site data for the selected customers.  Sort by SiteID
	SELECT ALP_tblArAlpSite.SiteId,
		SubDivision = ALP_tblArAlpSubdivision.[Desc],
 		Lot = ALP_tblArAlpSite.Block, 
		Name =  [SiteName] + 
		CASE WHEN  ALP_tblArAlpSite.AlpFirstName IS NULL THEN ''
		     	ELSE CONVERT(varchar,', ')
			+ ALP_tblArAlpSite.AlpFirstName
		END,
		-- MAH 091813 - added Addr1 and Addr2 to the Address output:
 		--Address1 = ALP_tblArAlpSite.Addr1,
 		Address1 = CASE WHEN ALP_tblArAlpSite.Addr1 IS NULL THEN
 						CASE WHEN ALP_tblArAlpSite.Addr2 IS NULL THEN ''
 							ELSE ALP_tblArAlpSite.Addr2
 							END
 						ELSE CASE WHEN ALP_tblArAlpSite.Addr2 IS NULL THEN ALP_tblArAlpSite.Addr1
 						 	ELSE ALP_tblArAlpSite.Addr1 + ', ' + ALP_tblArAlpSite.Addr2
 							END
 						END,
		-- EFI# 1521 MAH 100104
		SiteStatus = 
			CASE Status 
				WHEN 'Inactive'   THEN ''
				ELSE Status
			END,ALP_tblArAlpSite.AlpFirstName,ALP_tblArAlpSite.Phone
	FROM  (ALP_tblArAlpSite 
		INNER JOIN #ALP_tblJm110CustSites
			ON #ALP_tblJm110CustSites.SiteID = ALP_tblArAlpSite.SiteId) 
   		 LEFT OUTER  JOIN ALP_tblArAlpSubdivision 
			ON ALP_tblArAlpSite.SubDivID = ALP_tblArAlpSubdivision.SubdivId
			
	WHERE 	( #ALP_tblJm110CustSites.SiteID = ALP_tblArAlpSite.SiteId) 
	ORDER BY ALP_tblArAlpSite.SiteId,
		[SiteName] + 
		CASE WHEN  ALP_tblArAlpSite.AlpFirstName IS NULL THEN ''
		     	ELSE CONVERT(varchar,', ')
			+ ALP_tblArAlpSite.AlpFirstName
		END,
		ALP_tblArAlpSite.Addr1
	--Delete the temporary table
	DROP Table #ALP_tblJm110CustSites
   END
ELSE
   --If the CombocTL = 'S',or if there is no CustID provided,
   --then select ALL sites for display in the combo box
   BEGIN
	SELECT ALP_tblArAlpSite.SiteId,
		SubDivision = ALP_tblArAlpSubdivision.[Desc],
 		Lot = ALP_tblArAlpSite.Block, 
		Name =  [SiteName] + 
		CASE WHEN  ALP_tblArAlpSite.AlpFirstName IS NULL THEN ''
		     	ELSE CONVERT(varchar,', ')
			+ ALP_tblArAlpSite.AlpFirstName
		END,
 		Address1 = ALP_tblArAlpSite.Addr1,
		-- EFI# 1521 MAH 100104
		SiteStatus = 
			CASE Status 
				WHEN 'Inactive'   THEN ''
				ELSE Status
			END,ALP_tblArAlpSite.AlpFirstName,ALP_tblArAlpSite.Phone
	FROM  ALP_tblArAlpSite 
   		  LEFT OUTER  JOIN ALP_tblArAlpSubdivision 
			ON ALP_tblArAlpSite.SubDivID = ALP_tblArAlpSubdivision.SubdivId
			
	ORDER BY ALP_tblArAlpSite.SiteId,
		[SiteName] + 
		CASE WHEN  ALP_tblArAlpSite.AlpFirstName IS NULL THEN ''
		     	ELSE CONVERT(varchar,', ')
			+ ALP_tblArAlpSite.AlpFirstName
		END,
		ALP_tblArAlpSite.Addr1
   END