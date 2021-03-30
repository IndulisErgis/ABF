
CREATE PROCEDURE dbo.ALP_rptJmSvcTktRpt_sp
(
@TicketID int,
@CompName varchar(30),
@CompAddr varchar(255),
@Comments varchar(255)
)
AS
SET NOCOUNT ON
SELECT 
ALP_tblJmSvcTkt.TicketId, 
ALP_tblJmSvcTkt.CustId, 
Customer =
 	[CustName] + 
	(CASE 
		WHEN ALP_tblArCust_view.alpfirstname IS NULL 
		THEN ' ' 
		ELSE ', ' + ALP_tblArCust_view.alpfirstname 
	END) , 
ALP_tblJmSvcTkt.SiteId, 
Site = 
	[SiteName] + 
	(CASE 
		WHEN ALP_tblArAlpSite.alpfirstname IS NULL 
		THEN ' ' 
		ELSE ', '  + ALP_tblArAlpSite.alpfirstname
	END), 
Address = 
	ALP_tblArAlpSite.Addr1 + 
	(CASE 
		WHEN  ALP_tblArAlpSite.Addr2 IS NULL
		THEN '  ' 
		ELSE ', ' + ALP_tblArAlpSite.Addr2 
	END) ,
CityState = 
	ALP_tblArAlpSite.City + ', ' + ALP_tblArAlpSite.Region + '  ' + ALP_tblArAlpSite.PostalCode, 
ALP_tblJmSvcTkt.Contact, 
ALP_tblJmSvcTkt.ContactPhone, 
ALP_tblJmSvcTkt.SysId, 
ALP_tblArAlpSiteSys.SysDesc, 
ALP_tblArAlpSiteSys.CentralId, 
ALP_tblArAlpSiteSys.AlarmId, 
LseYn = 
	(CASE 
		WHEN LeaseYN=1 
		THEN 'Yes' 
		ELSE 'No' 
	END), 
ALP_tblJmSvcTkt.WorkDesc, 
ALP_tblArAlpSubdivision.Subdiv, 
ALP_tblArAlpSite.Block, 
CompName = @CompName,
CompAddr = @CompAddr, 
ALP_tblJmSvcTkt.SalesRepId, 
Comments = @Comments, 
ALP_tblJmSvcTkt.PartsPrice, 
ALP_tblJmSvcTkt.LabPriceTotal
FROM ALP_tblJmTech 
RIGHT JOIN ALP_tblJmWorkCode 
INNER JOIN ALP_tblJmSvcTkt 
INNER JOIN ALP_tblArAlpSite 
ON ALP_tblJmSvcTkt.SiteId = ALP_tblArAlpSite.SiteId 
INNER JOIN ALP_tblArCust_view 
ON ALP_tblJmSvcTkt.CustId = ALP_tblArCust_view.CustId 
INNER JOIN ALP_tblArAlpSiteSys 
ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId 
LEFT JOIN ALP_tblArAlpSubdivision 
ON ALP_tblArAlpSite.SubDivID = ALP_tblArAlpSubdivision.SubdivId 
ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId 
ON ALP_tblJmTech.TechID = ALP_tblJmSvcTkt.LeadTechId
WHERE ALP_tblJmSvcTkt.TicketId=@TicketID