


CREATE Procedure [dbo].[ALP_rptJmSvcOrder_sp]
(
	@ID int, 
	@SchedDate datetime, 
	@SchedTime varchar(50), 
	@CompName varchar(50), 
	@CompAddr varchar(255), 
	@Tech varchar(3), 
	@Comments text
)
AS
SET NOCOUNT ON
SELECT 
ALP_tblJmSvcTkt.TicketId,
ALP_tblJmSvcTkt.ProjectId, 
--MAH 12/9/03 - change date format
--ALP_tblJmSvcTkt.CreateDate, 
CONVERT(varchar,ALP_tblJmSvcTkt.CreateDate,1) AS CreateDate, 
ALP_tblJmSvcTkt.CreateBy, 
ALP_tblJmSvcTkt.CustId, 
ALP_tblJmSvcTkt.SiteId, 
ALP_tblJmSvcTkt.Contact, 
ALP_tblJmSvcTkt.ContactPhone, 
ALP_tblJmSvcTkt.SysId, 
--JAL 12/30/03 - Added PrefTime
ALP_tblJmSvcTkt.PrefTime,
Customer = 
 	ALP_tblArCust_view.CustName +
	(CASE 
		WHEN ALP_tblArCust_view.alpfirstname IS NULL 
		THEN ' ' 
		ELSE ', ' + ALP_tblArCust_view.alpfirstname 
	END),
Site = 
	ALP_tblArAlpSite.SiteName + 
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
ALP_tblArAlpSiteSys.SysDesc, 
ALP_tblArAlpSiteSys.CentralId,
ALP_tblArAlpSiteSys.AlarmId,
ALP_tblArAlpSiteSys.WarrExpires,
LseYn = 
	(CASE 
		WHEN ALP_tblArAlpSiteSys.LeaseYN=1 
		THEN 'Yes' 
		ELSE 'No' 
	END), 
ALP_tblArAlpRepairPlan.RepPlan, 
ALP_tblJmSvcTkt.PriceId, 
ALP_tblArCust_view.AlpJmCustLevel, 
ALP_tblJmWorkCode.WorkCode, 
ALP_tblArAlpSite.Directions,
ALP_tblJmSvcTkt.WorkDesc,
SchedDate = @SchedDate, 
SchedTime = @SchedTime, 
CompName = @CompName, 
CompAddr = @CompAddr, 
LaborRate =
	CASE
		WHEN ALP_tblJmSvcTkt.OutOfRegYN=1 THEN 'Out Of Regular'
		ELSE
			CASE 
				WHEN ALP_tblJmSvcTkt.HolidayYN=1 THEN 'Holiday'
				ELSE 'Regular'
			END
		END, 
Tech =@Tech, 
ALP_tblArAlpSite.County,
ALP_tblArAlpSite.CrossStreet, 
ALP_tblArAlpSite.MapId, 
Struct = 
	CASE ALP_tblArAlpSite.Structure
		WHEN 1 THEN 'Ranch'
		WHEN 2 THEN 'Two-Level'
		WHEN 3 THEN '`Split-Level'
		WHEN 4 THEN 'Office'
		WHEN 5 THEN 'Warehouse' 
		ELSE ' '
	END, 
Bsmt = 
	CASE ALP_tblArAlpSite.Basement
		WHEN 1 THEN 'Full'
		WHEN 2 THEN 'Part'
		WHEN 3 THEN 'Drop Ceiling'
		WHEN 4 THEN 'All Finished'
		WHEN 5 THEN 'None'
		ELSE ' '
END, 
Att =
	CASE ALP_tblArAlpSite.Attic
		WHEN 0 THEN 'None'
		WHEN 1 THEN 'Full'
		WHEN 2 THEN 'Part'
		WHEN 3 THEN 'Small'
		ELSE ' '
	END, 
SqFoot = ALP_tblArAlpSite.SqFt*1000, 
--CreditStatus =
Comments = @Comments,
ALP_tblArAlpSite.Status,'' as CreditStatus
FROM ALP_tblJmTech 
	RIGHT JOIN ALP_tblJmWorkCode 
	INNER JOIN ALP_tblJmSvcTkt 
	INNER JOIN ALP_tblArAlpSite ON ALP_tblJmSvcTkt.SiteId = ALP_tblArAlpSite.SiteId
	INNER JOIN ALP_tblArCust_view ON ALP_tblJmSvcTkt.CustId = ALP_tblArCust_view.CustId
	LEFT JOIN ALP_tblArAlpRepairPlan ON ALP_tblJmSvcTkt.RepPlanId = ALP_tblArAlpRepairPlan.RepPlanId
	INNER JOIN ALP_tblArAlpSiteSys ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId
	ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId
	ON ALP_tblJmTech.TechID = ALP_tblJmSvcTkt.LeadTechId
WHERE ALP_tblJmSvcTkt.TicketId=@ID