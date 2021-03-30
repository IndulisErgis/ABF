

CREATE PROCEDURE [dbo].[ALP_R_JM_R134]
(@StartDate datetime = NULL,
 @EndDate datetime = NULL,
 @Branch varchar(255))
AS

SELECT P.Site, P.ProjectId, P.ProjDesc, CP.ProjCompleteDate, 
	P.MarketCode, P.FirstOfBranch, P.ResComm, 
	P.FirstOfSalesRepID, P.Connects, 
	P.ProjPrice, P.ProjPartCost,P.ProjOtherCost, P.ProjLaborCost,
	P.ProjCommCost, P.ProjCost,  P.ProjRmr,
    CASE WHEN [SumOfLseYn]=0 THEN 'Outright Sale' ELSE 'Company Owned' END AS LseOrSale,
     [ProjPrice]-[ProjCost] AS Margin

FROM [ufxALP_R_AR_Jm_Q011_ProjInfo_Q009]() P
INNER JOIN  [dbo].[ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c](@EndDate) CP 
ON P.ProjectId = CP.ProjectId

WHERE
@Branch = '<ALL>' OR P.FirstOfBranch = @Branch

GROUP BY P.Site, P.ProjectId, P.ProjDesc, CP.ProjCompleteDate, P.MarketCode, 
P.FirstOfBranch, P.ResComm, P.FirstOfSalesRepID, P.Connects, P.ProjPrice, 
P.ProjPartCost, P.ProjOtherCost, P.ProjLaborCost, P.ProjCommCost, P.ProjCost, 
P.ProjRmr, CASE WHEN [SumOfLseYn]=0 THEN 'Outright Sale' ELSE 'Company Owned' END, [ProjPrice]-[ProjCost]
HAVING ((CP.ProjCompleteDate >= @StartDate)  And (CP.ProjCompleteDate <= @EndDate))