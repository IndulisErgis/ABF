

CREATE PROCEDURE [dbo].[ALP_R_JM_R135]
(@StartDate datetime = NULL,
 @EndDate datetime = NULL)
AS

SELECT P.FirstOfBranch, CASE WHEN [SumOfLseYn]=0 THEN 'Outright Sale' ELSE 'Company Owned' END AS LseOrSale, 
P.ResComm, 
Sum(P.Connects)*-1 AS SumOfConnects, 
Sum(P.ProjPrice) AS SumOfProjPrice, 
Sum(P.ProjPartCost) AS SumOfProjPartCost, 
Sum(P.ProjOtherCost) AS SumOfProjOtherCost, 
Sum(P.ProjLaborCost) AS SumOfProjLaborCost, 
Sum(P.ProjCommCost) AS SumOfProjCommCost,
 Sum(P.ProjCost) AS SumOfProjCost, 
 Sum(P.ProjRmr) AS SumOfProjRmr, Sum([ProjPrice]-[ProjCost]) AS Margin

FROM [ufxALP_R_AR_Jm_Q011_ProjInfo_Q009]() P 
INNER JOIN [dbo].[ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c](@EndDate) CP 
ON P.ProjectId = CP.ProjectId

WHERE ((CP.ProjCompleteDate >= @StartDate) And (CP.ProjCompleteDate <= @EndDate))

GROUP BY P.FirstOfBranch, 
CASE WHEN [SumOfLseYn]=0 THEN 'Outright Sale' ELSE 'Company Owned' END, 
P.ResComm