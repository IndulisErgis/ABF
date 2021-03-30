
CREATE PROCEDURE [dbo].[ALP_R_AR_R587_DealerStatement_Summary]
(
@CustID varchar(10),
@EndDate datetime
)
AS
BEGIN
SET NOCOUNT ON;
/****** Object:  StoredProcedure [dbo].[ALP_R_AR_R587_DealerStmt_Summary]   
 Script Date: 02/01/2013 13:55:18  ******/  /* formerly qryAr-R587-Q002 */
  
SELECT 
-- Dealer Name block
AC.CustId,

-- Address block
AC.Attn,
--tblArCust.CustName,
--tblArCust.AlpFirstName,
AC.CustName +
	CASE
	WHEN AC.AlpFirstName IS NULL THEN ''
	WHEN AC.AlpFirstName='' THEN ''
	ELSE ', ' + AC.AlpFirstName
	END AS CName,

AC.Addr1 +
	CASE	
	WHEN AC.Addr2 IS NULL THEN ''
	WHEN AC.Addr2 = '' THEN ''
	ELSE ', ' + AC.Addr2
	END AS CAddr,

AC.City + ', ' + AC.Region + '  ' + AC.PostalCode AS CityRegionPostal, 

-- Data listing
HH.AlpSiteID,
SiteName + 
	CASE
	WHEN ASite.AlpFirstName is Null THEN ''  
	WHEN ASite.AlpFirstName = ''    THEN '' 
	ELSE (', ' + ASite.AlpFirstName)  
	END AS Site,

OI.InvcNum,
OI.FirstOfTransDate AS Date, 
OI.InvcAmt,
(OI.CreditAmt * -1) AS CreditORPmt,
(OI.InvcAmt - OI.CreditAmt) as Balance

FROM ALP_tblArCust_view AS AC 
	INNER JOIN ufxALP_R_AR_R587_Q002_OpenItems_Q001() AS OI 
	ON AC.CustId = OI.CustId
	LEFT JOIN ALP_tblArHistHeader_view AS HH
	ON OI.InvcNum = HH.InvcNum
	LEFT JOIN ALP_tblArAlpSite_view AS ASite 
	ON HH.AlpSiteID = ASite.SiteId 

WHERE 
AC.CustId = @CustID AND 
AC.AlpDealerYn=1 AND 
OI.FirstOfTransDate <= @EndDate

ORDER BY 
SiteName + 
	CASE
	WHEN ASite.AlpFirstName is Null THEN ''  
	WHEN ASite.AlpFirstName = ''    THEN '' 
	ELSE (', ' + ASite.AlpFirstName)  
	END,
InvcDate DESC


END