


CREATE PROCEDURE [dbo].[ALP_R_JM_R110_ProjectsByBranch] 
( 
 @StartDate Datetime,
 @EndDate Datetime,
 @Branch VARCHAR(255)='<ALL>',
 @Department VARCHAR(255)='<ALL>'
)
AS

--Converted from Access query qryJm-R110-Q011 - 3/10/15 - ER
Select ProjectId,ProjDesc,
Promo,LeadSource,
MarketCode,SiteId,
Site,Address,
ResComm,Subdiv
Block,ProjOrderDate,
ProjCmpltdDate,ProjCloseDate,
FirstOfSysType,SumOfLseYn,
FirstOfSalesRepID,FirstOfBranch,
FirstOfDivision,FirstOfDept,
Connects,ProjPrice,
ProjCost,ProjPv,
ProjComm,ProjRmr,
ProjRmrExp,SumOfEstCostParts,
SumOfEstCostLabor,SumOfEstCostMisc,
EstHours,ProjPartCost,
ProjOtherCost,ProjLaborCost,
ProjCommCost,ProjBaseInst
FROM ufxALP_R_AR_Jm_Q011_ProjInfo_Q009() as Q1109
WHERE Q1109.ProjOrderDate  >= @StartDate  And Q1109.ProjOrderDate<=@EndDate
and (Q1109.FirstOfBranch =@Branch or @Branch='<ALL>')
and (Q1109.FirstOfDept =@Department or @Department='<ALL>')