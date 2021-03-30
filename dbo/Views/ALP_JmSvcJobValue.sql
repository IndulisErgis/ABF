




CREATE VIEW [dbo].[ALP_JmSvcJobValue]
AS
SELECT 
ST.OrderDate,
TECH.Name,
ST.SiteId,
ST.TicketId,
--SS.SysDesc,
WC.WorkCode,
ST.WorkDesc,
STI.ResDesc,
STI.CauseDesc,
RP.RepPlan,
ST.SalesRepID,
--qry31.JobCost,
JobPrice =  isNull(ST.PartsPrice,0) + isNull(ST.LabPriceTotal,0)
		+ (CASE 
			WHEN OPC.OtherPrice Is Null 
			THEN 0 ELSE OPC.OtherPrice 
			END),
--NetPV = (isNull(ST.PartsPrice,0) + isNull(ST.LabPriceTotal,0)
--		+ (CASE 
--			WHEN OPC.OtherPrice Is Null 
--			THEN 0 ELSE OPC.OtherPrice 
--			END))- qry31.JobCost,
STI.Comments
FROM ALP_tblJmSvcTkt ST
	LEFT OUTER JOIN dbo.ufxAlpSvcJobPriceCost_PartsOther(NULL,NULL,NULL,NULL) AS OPC
		ON ST.TicketId = OPC.TicketId
	--INNER JOIN ufxALP_R_AR_Jm_Q031_SvcJobCostDetail() AS qry31
	--	ON ST.TicketId =  qry31.TicketId
	INNER JOIN ALP_tblJmTech AS TECH
		ON ST.LeadTechId = TECH.TechId
	--INNER JOIN ALP_tblArAlpSiteSys AS SS
	--	ON ST.SiteId = SS.SiteId
	INNER JOIN ALP_tblArAlpRepairPlan AS RP
		ON ST.RepPlanId = RP.RepPlanId
	INNER JOIN ALP_tblJmWorkCode AS WC
		ON ST.WorkCodeId = WC.WorkCodeId
	INNER JOIN ALP_tblJmSvcTktItem AS STI
		ON ST.TicketId = STI.TicketId