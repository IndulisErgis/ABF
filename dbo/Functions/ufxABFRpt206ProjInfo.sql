CREATE function [dbo].[ufxABFRpt206ProjInfo]
/* Purpose: Summarizes Price,Cost,Commissions data for commercial sales			*/
/*		Used in Alpine Reports by ABF custom report ABF206			*/
/* Parameters: 										*/
/* 	     @BeginOrderDate and @EndOrderDate define the OrderDate filter.		*/
/*		To select all OrderDates, enter NULL for each date parameter.		*/	
/* History: created 08/05/11 mah							*/
	(
	@BeginOrderDate dateTime,
	@EndOrderDate dateTime
	)
Returns table
AS
Return
(
SELECT	TOP 100 PERCENT
	J.DivID,
	J.DeptID,
	J.SalesRepID, 
	J.ProjectID,
	ContrYYMM = J.OrderDate,
	ContrYY = CAST(DatePart(year,J.[OrderDate]) as char(4)),
	ContrMM = CAST(DatePart(month,J.[OrderDate]) as char(2)),
	J.OrderDate,
	J.SiteId,
	EstCost = ROUND(SUM(isnull(J.EstCostParts,0) + isnull(J.EstCostLabor,0) + isnull(J.EstCostMisc,0)),2),
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
FROM   dbo.ufxABFRpt206SvcJobsInfo(@BeginOrderDate,@EndOrderDate) AS J
GROUP BY J.DivID,
	J.DeptId,
	J.SalesRepID, 
	J.ProjectID,
	CAST(DatePart(year,J.[OrderDate]) as char(4)),
	CAST(DatePart(month,J.[OrderDate]) as char(2)),
	J.OrderDate,
	J.SiteId
ORDER BY  CAST(DatePart(year,J.[OrderDate]) as char(4)),
	CAST(DatePart(month,J.[OrderDate]) as char(2)),
	J.OrderDate,
	J.DivID,
	J.DeptId,
	J.SalesRepID,
	J.ProjectID


)