CREATE function [dbo].[ufxABFRpt220Leases_ProjInfo]
	-- Purpose: Summarizes Price,Cost,Commissions data , by Project				
	-- Parameters: @BeginOrderDate and @EndOrderDate define the OrderDate filter.		
	--	To select all OrderDates, enter NULL for each date parameter.			
	-- History: created 01/28/04 mah							
(
@BeginOrderDate dateTime,
@EndOrderDate dateTime
)
Returns table
AS
Return
(
SELECT	TOP 100 PERCENT
	--J.SalesRepID, 
	J.CustID,
	J.CustName,
	J.ProjectID,
	ContrYYMM = J.OrderDate,
	ContrYY = CAST(DatePart(year,J.[OrderDate]) as char(4)),
	ContrMM = CAST(DatePart(month,J.[OrderDate]) as char(2)),
	J.OrderDate,
	J.SiteId,
	J.LseYn,
	EstCost = SUM(
		  isNull(J.EstCostParts,0)
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
	
FROM ufxABFRpt220Leases_SvcJobsInfo(@BeginOrderDate,@EndOrderDate) AS J
 
GROUP BY J.CustID,
 	J.CustName,
	J.ProjectID,
	CAST(DatePart(year,J.[OrderDate]) as char(4)),
	CAST(DatePart(month,J.[OrderDate]) as char(2)),
	J.OrderDate,
	J.SiteId,
	J.LseYn
ORDER BY J.CustName,
	J.ProjectID,
	CAST(DatePart(year,J.[OrderDate]) as char(4)),
	CAST(DatePart(month,J.[OrderDate]) as char(2))
)