CREATE Procedure [dbo].[ALP_lkpJmCustLookUp]
/* Rowsource for cboCustID2 in frmJm110 ( ControlCenter ) */
	(
		@ComboCTL varchar(1) = '',
		@SiteID int = 0
	)
As
SET NOCOUNT ON
--IF @ComboCTL <> 'C' AND @SiteID IS NOT NULL 
IF @ComboCTL <> 'C' AND @SiteID > 0 
   BEGIN
	/*Builds a temporary table of all Customers related to a particular Site.*/
	CREATE Table #ALP_tblJm110SiteCusts
	(
		CustId pCustID NOT NULL
	)
	INSERT INTO #ALP_tblJm110SiteCusts ( CustId )
		SELECT ALP_tblArAlpSiteSys.CustId
		FROM ALP_tblArAlpSiteSys (NOLOCK)
		WHERE (ALP_tblArAlpSiteSys.SiteId=@SiteID) 
		--mah 12/16/13 added check that CustID is not null
		AND ALP_tblArAlpSiteSys.CustId is not null
		GROUP BY ALP_tblArAlpSiteSys.CustId;
	--Add to Temporary table, Customers found in RecBill related to requested Site
	INSERT INTO #ALP_tblJm110SiteCusts ( CustId )
		SELECT [ALP_tblArAlpSiteRecBill].[CustId]
		FROM ALP_tblArAlpSiteRecBill (NOLOCK)
		WHERE ([ALP_tblArAlpSiteRecBill].[SiteId])=@SiteID
		--mah 12/16/13 added check that CustID is not null
		AND [ALP_tblArAlpSiteRecBill].[CustId] is not null
		AND NOT EXISTS 
			(SELECT CustID from #ALP_tblJm110SiteCusts);
	--Create recordset of Customers name, id for the selected customers.  Sort by CustID
	SELECT ALP_tblArCust_view.CustId, 
		[Customer Name]=(ALP_tblArCust_view.CustName) + 
		CASE WHEN ALP_tblArCust_view.AlpFirstName IS NULL THEN ''
		     	ELSE CONVERT(varchar,', ')
			+ ALP_tblArCust_view.AlpFirstName
		END,AlpFirstName,AlpLastName,Addr1,
		--MAH 01/30/14 - added Addr2, City, Region, PostalCode to output 
		Phone,Addr2, City, Region, PostalCode,
		--MAH 01/30/14- changes field used to display cust status
		Status = CASE WHEN[Status] = 1 THEN '  *INACTIVE*' ELSE '' END 	
		--Status = CASE WHEN[AlpInactive] = 1 THEN '  *INACTIVE*' ELSE '' END 		
	FROM ALP_tblArCust_view,#ALP_tblJm110SiteCusts (NOLOCK)
	WHERE ALP_tblArCust_view.CustId = #ALP_tblJm110SiteCusts.CustId 
	ORDER BY ALP_tblArCust_view.CustId 
	--Delete the temporary table
	DROP Table #ALP_tblJm110SiteCusts
   END
ELSE
   --If the SiteID input parameter is 0 (or not entered), or ComboCTL = 'C', 
   --then select ALL customers for display in the combo box
   BEGIN
	SELECT ALP_tblArCust_view.CustId, 
		[Customer Name]=(ALP_tblArCust_view.CustName) + 
		CASE WHEN ALP_tblArCust_view.AlpFirstName IS NULL THEN ''
		    	 ELSE CONVERT(varchar,', ')
			+ ALP_tblArCust_view.AlpFirstName
		END,AlpFirstName,AlpLastName,Addr1,
		--MAH 01/30/14 - added Addr2, City, Region, PostalCode to output 
		Phone,Addr2, City, Region, PostalCode,
		--MAH 01/30/14- changes field used to display cust status
		Status = CASE WHEN[Status] = 1 THEN '  *INACTIVE*' ELSE '' END 	
		--Status = CASE WHEN[AlpInactive] = 1 THEN '  *INACTIVE*' ELSE '' END 		
	FROM ALP_tblArCust_view (NOLOCK)
	ORDER BY ALP_tblArCust_view.CustId 
   END