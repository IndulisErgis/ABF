
/****** Object:  StoredProcedure [dbo].[ALP_R_AR_Site_R405_LocalAccountsBySubdivision]    Script Date: 01/04/2013 13:28:35 ******/
CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R405_LocalAccountsBySubdivision]
(
@SalesRepID varchar(5)
,@Subdivision varchar(10)
,@MoniYN varchar(10)
)
AS
BEGIN
SET NOCOUNT ON
SELECT 
ASite.SalesRepId1 
,SUB.Subdiv
,ASite.SiteId
,CASE WHEN AlpFirstName ='' or AlpFirstName IS null
	THEN SiteName
	ELSE SiteName + ', ' + AlpFirstName END AS SiteFullName
,CASE WHEN Addr2='' or Addr2 IS null
	THEN Addr1
	ELSE Addr1 + ', ' + Addr2 END AS Addr

,IsNull(ASite.Block,'---') AS Block
,ASite.City 
,ASite.Region 
,ASite.PostalCode 
--,ServiceID
,SUM(CASE
		WHEN ServiceID IS Null THEN 0 
		WHEN ServiceID='MONI' AND RBS.Status='Active' 
			OR RBS.Status='New' THEN 1 
		ELSE 0  
		END)
	AS MoniYN

FROM ALP_tblArAlpSite AS ASite 
	INNER JOIN ALP_tblArAlpSubdivision AS SUB 
	ON ASite.SubDivID = SUB.SubdivId
	left outer JOIN ALP_tblArAlpSiteRecBill_view AS RB 
	ON ASite.SiteId = RB.SiteId 
	left outer JOIN ALP_tblArAlpSiteRecBillServ_view AS RBS 
	ON RB.RecBillId = RBS.RecBillId

GROUP BY 
ASite.SalesRepId1 
,SUB.Subdiv 
,ASite.SiteId
,CASE WHEN ASite.AlpFirstName ='' or ASite.AlpFirstName IS null
	THEN ASite.SiteName
	ELSE ASite.SiteName + ', ' + ASite.AlpFirstName END
	
,CASE WHEN ASite.Addr2='' or ASite.Addr2 IS null 
	THEN ASite.Addr1
	ELSE ASite.Addr1 + ', ' + ASite.Addr2 END

,ASite.Block 
,ASite.City 
,ASite.Region 
,ASite.PostalCode 
 
HAVING SUB.Subdiv is not null 
	AND
		(ASite.SalesRepId1=@SalesRepID or @SalesRepID='<ALL>')
	AND 
		(SUB.Subdiv=@Subdivision or @Subdivision='<ALL>')
	AND 
	(
		(@MoniYN<>'2'
		AND
		(@MoniYN=SUM(CASE
		WHEN RBS.ServiceID IS Null THEN 0 
		WHEN RBS.ServiceID=' ' THEN 0 
		WHEN RBS.ServiceID='MONI' AND (RBS.Status='Active' 
			OR RBS.Status='New') THEN 1 

		ELSE 0  
		END)
		)
		OR 
		(@MoniYN='2')
		)
		)


END