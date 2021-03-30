CREATE function [dbo].[ufxABFRpt200ProjInfo]
/* Purpose: Summarizes Price,Cost,Commissions data , by Project				*/
/*		Used in Alpine Reports by ABF custom report ABF200			*/
/* Parameters: 										*/
/* 	     @BeginOrderDate and @EndOrderDate define the OrderDate filter.		*/
/*		To select all OrderDates, enter NULL for each date parameter.		*/	
/* History: created 09/05/03 mah							*/
/*		updated 09/15/03 mah - get estimated costs from new SvcTkt fields,	*/
/*					- added siteid to output			*/
	(
	@BeginOrderDate dateTime,
	@EndOrderDate dateTime
	)
Returns table
AS
Return
(
SELECT	TOP 100 PERCENT
	J.SalesRepID, 
	J.CustID,
	J.CustName,
	J.ProjectID,
	ContrYYMM = J.OrderDate,
	ContrYY = CAST(DatePart(year,J.[OrderDate]) as char(4)),
	ContrMM = CAST(DatePart(month,J.[OrderDate]) as char(2)),
	J.OrderDate,
	J.SiteId,
	J.LseYn,
--	EstMatCost = CASE
--			WHEN J.ProjectID IS NULL THEN 0
--			ELSE (SELECT IsNull(EstMatCost,0) FROM tblJmSvcTktProject WHERE ProjectID = J.ProjectID)
--		     END,
--	EstLabCost = CASE
--			WHEN J.ProjectID IS NULL THEN 0
--			ELSE (SELECT IsNull(EstLabCost,0) FROM tblJmSvcTktProject WHERE ProjectID = J.ProjectID)
--		     END,
	EstCost = SUM(isNull(J.EstCostParts,0)
		+ isNull(J.EstCostLabor,0)
		+ isNull(J.EstCostMisc,0)),
	EstMatCost = ROUND(SUM(isNull(J.EstCostParts,0)),2),
	EstLabCost = ROUND(SUM(isNull(J.EstCostLabor,0)),2),
	EstMiscCost = ROUND(SUM(isNull(J.EstCostMisc,0)),2),
	RMRExpense = ROUND(SUM(IsNull(J.RMRExpense,0)),2),
	RMRAdded = ROUND(SUM(IsNull(J.RMRAdded,0)),2),
	DiscRatePct = Max(isNull(J.DiscRatePct,0)),
	ContractMths = Max(isNull(J.ContractMths,0)),
	CommAmt = ROUND(SUM(IsNull(J.CommAmt,0)),2),
	PartsPrice =ROUND(SUM(IsNull(J.PartsPrice,0)),2),
	LaborPrice = ROUND(SUM(IsNull(J.LaborPrice,0)),2),
	OtherPrice = ROUND(SUM(IsNull(J.OtherPrice,0)),2),
	JobPrice = ROUND(SUM(IsNull(J.JobPrice,0)),2)
FROM   dbo.ufxABFRpt200SvcJobsInfo(@BeginOrderDate,@EndOrderDate) AS J
--select only commercial projects
WHERE  J.DivID IN (1,2) 
GROUP BY J.SalesRepID, 
	J.CustID,
 	J.CustName,
	J.ProjectID,
	CAST(DatePart(year,J.[OrderDate]) as char(4)),
	CAST(DatePart(month,J.[OrderDate]) as char(2)),
	J.OrderDate,
	J.SiteId,
	J.LseYn
ORDER BY J.SalesRepID,
 	J.CustName,
	J.ProjectID,
	CAST(DatePart(year,J.[OrderDate]) as char(4)),
	CAST(DatePart(month,J.[OrderDate]) as char(2))
)