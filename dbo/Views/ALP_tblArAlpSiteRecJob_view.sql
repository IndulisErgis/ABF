﻿
CREATE VIEW [dbo].[ALP_tblArAlpSiteRecJob_view]
AS
SELECT
	[RecJobEntryId],
	[CreateDate],
	[CustId],
	[SiteId],
	[RecBillEntryId],
	[RecSvcId],
	[SysId],
	[ContractId],
	[CustPoNum],
	[JobCycleId],
	[LastCycleStartDate],
	[NextCycleStartDate],
	[ExpirationDate],
	[LastDateCreated],
	[Contact],
	[ContactPhone],
	[WorkDesc],
	[WorkCodeId],
	[RepPlanId],
	[PriceId],
	[BranchId],
	[DeptId],
	[DivId],
	[SkillId],
	[PrefTechId],
	[EstHrs],
	[PrefTime],
	[OtherComments],
	[SalesRepId],
	[ts],
	[ModifiedBy],
	[ModifiedDate]
FROM [dbo].[ALP_tblArAlpSiteRecJob]