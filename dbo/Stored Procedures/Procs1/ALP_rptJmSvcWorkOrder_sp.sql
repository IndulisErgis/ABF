
CREATE PROCEDURE dbo.ALP_rptJmSvcWorkOrder_sp 
	@ID int, 
	@SchedDate datetime, 
	@SchedTime varchar(50), 
	@CompName varchar(50), 
	@CompAddr varchar(255), 
	@Tech varchar(3), 
	@Comments text
As
SET NOCOUNT ON
SELECT ALP_tblJmSvcTkt.TicketId, ALP_tblJmSvcTkt.ProjectId, ALP_tblJmSvcTkt.CustId, 
	CASE 
		WHEN ALP_tblArCust_view.AlpFirstName Is Null or ALP_tblArCust_view.AlpFirstName = '' THEN CustName
		ELSE CustName + ', ' + ALP_tblArCust_view.AlpFirstName
	END AS Customer,
	ALP_tblJmSvcTkt.SiteId,
	CASE
		WHEN ALP_tblArAlpSite.AlpFirstName Is Null or ALP_tblArAlpSite.AlpFirstName = '' THEN SiteName
		ELSE SiteName + ', ' + ALP_tblArAlpSite.AlpFirstName
	END AS Site,
	CASE 
		WHEN ALP_tblArAlpSite.Addr2 Is Null or ALP_tblArAlpSite.Addr2 = '' THEN ALP_tblArAlpSite.Addr1
		ELSE ALP_tblArAlpSIte.Addr1 + ', ' + ALP_tblArAlpSite.Addr2
	END AS Address,
	ALP_tblArAlpSite.City +  ', ' + ALP_tblArAlpSite.Region + '  ' + ALP_tblArAlpSite.PostalCode AS CityState, 
	ALP_tblJmSvcTkt.Contact, ALP_tblJmSvcTkt.ContactPhone, ALP_tblJmSvcTkt.SysId, ALP_tblArAlpSiteSys.SysDesc, ALP_tblArAlpSiteSys.CentralId, ALP_tblArAlpSiteSys.AlarmId, 
	CASE WHEN LeaseYn = 1 Then 'Yes' ELSE 'No' END AS LseYn,
	ALP_tblJmWorkCode.WorkCode, ALP_tblJmTech.[Name] AS TechName, ALP_tblJmSvcTkt.WorkDesc, ALP_tblArAlpSite.Directions, ALP_tblArAlpSite.CrossStreet, 
	ALP_tblArAlpSite.MapId, ALP_tblArAlpSubdivision.Subdiv, ALP_tblArAlpSite.Block, ALP_tblJmSvcTkt.OtherComments, 
	@SchedDate AS SchedDate, @SchedTime AS SchedTime, 
	@CompName AS CompName, @CompAddr AS CompAddr, 
	ALP_tblJmSvcTkt.SalesRepId, @Tech AS Tech, @Comments AS Comments
FROM ALP_tblJmTech RIGHT JOIN (ALP_tblJmWorkCode INNER JOIN ((((ALP_tblJmSvcTkt INNER JOIN ALP_tblArAlpSite ON ALP_tblJmSvcTkt.SiteId = ALP_tblArAlpSite.SiteId) 
	INNER JOIN ALP_tblArCust_view ON ALP_tblJmSvcTkt.CustId = ALP_tblArCust_view.CustId) INNER JOIN ALP_tblArAlpSiteSys ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId) 
	LEFT JOIN ALP_tblArAlpSubdivision ON ALP_tblArAlpSite.SubDivID = ALP_tblArAlpSubdivision.SubdivId) ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId) 
	ON ALP_tblJmTech.TechID = ALP_tblJmSvcTkt.LeadTechId
WHERE ALP_tblJmSvcTkt.TicketId = @ID