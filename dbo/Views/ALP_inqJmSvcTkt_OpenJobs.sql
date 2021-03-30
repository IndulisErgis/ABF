
CREATE VIEW dbo.ALP_inqJmSvcTkt_OpenJobs
AS 
SELECT CONVERT(datetime,ALP_tblJmSvcTkt.CreateDate,101) as CreateDate, 
	ALP_tblJmSvcTkt.ProjectId as [Proj ID],ALP_tblJmSvcTkt.SalesRepId as SalesRep, 
	ALP_tblJmSvcTkt.TicketId as[Job#], ALP_tblArAlpSite.SiteId, ALP_tblArAlpSite.SiteName, 
	ALP_tblJmWorkCode.WorkCode, ALP_tblJmSvcTkt.WorkDesc,  ALP_tblArAlpSysType.SysType, 
	ALP_tblJmTech.Tech, ALP_tblJmSvcTkt.EstHrs, 
	CONVERT(varchar,ALP_tblJmSvcTkt.PrefDate,101) as PrefDate, 
	ALP_tblJmSvcTkt.PrefTime, 
	ALP_tblArAlpSite.Addr1, ALP_tblArAlpSite.Addr2, ALP_tblArAlpSite.City, 
	ALP_tblJmSvcTkt.Status, ALP_tblArAlpSite.AlpFirstName, ALP_tblArAlpSiteSys.AlarmId,
	ALP_tblArAlpSite.PostalCode,  ALP_tblArAlpSite.MapId,
	CONVERT(varchar,ALP_tblJmSvcTkt.BoDate,101) as [B/O], 
	CONVERT(varchar,ALP_tblJmSvcTkt.StagedDate,101) as [Staged],
	CONVERT(varchar,ALP_tblJmSvcTkt.ToSchDate,101) as [ToSched],  
	CONVERT(varchar,ALP_tblJmSvcTkt.ReschDate,101) as ReSched,
	CASE WHEN ALP_tblJmSvcTkt.ReturnYn = 1 THEN 'Y' 
		ELSE '' END as NeedToReturn,
	ALP_tblJmSvcTkt.CustID, ALP_tblJmSvcTkt.ContactPhone, 
	ALP_tblJmSvcTkt.OtherComments,
	ALP_tblJmSvcTkt.ModifiedBy,  
	ALP_tblJmSvcTkt.ModifiedDate  
FROM ALP_tblJmTech 
	RIGHT JOIN 
		(ALP_tblJmWorkCode 
			INNER JOIN 
				(ALP_tblArAlpSysType 
					INNER JOIN  
					(((((ALP_tblArAlpSite 
						INNER JOIN ALP_tblJmSvcTkt 
						ON ALP_tblArAlpSite.SiteId = ALP_tblJmSvcTkt.SiteId) 
						INNER JOIN ALP_tblArAlpSiteSys 
						ON ALP_tblJmSvcTkt.SysId = ALP_tblArAlpSiteSys.SysId) 
						INNER JOIN ALP_tblArAlpDept 
						ON ALP_tblJmSvcTkt.DeptId = ALP_tblArAlpDept.DeptId) 
						INNER JOIN ALP_tblArAlpBranch 
						ON ALP_tblArAlpSite.BranchId = ALP_tblArAlpBranch.BranchId)) 
					ON ALP_tblArAlpSysType.SysTypeId = ALP_tblArAlpSiteSys.SysTypeId) 
					ON  ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId) 
					ON ALP_tblJmTech.TechID = ALP_tblJmSvcTkt.LeadTechId  
WHERE   --(((ALP_tblArAlpBranch.Branch) Like '%') 
		--AND ((ALP_tblArAlpDept.Dept) Like '%') 
		--AND 
		((ALP_tblJmSvcTkt.Status) = 'New' OR (ALP_tblJmSvcTkt.Status) = 'Targeted' OR (ALP_tblJmSvcTkt.Status) = 'Scheduled')