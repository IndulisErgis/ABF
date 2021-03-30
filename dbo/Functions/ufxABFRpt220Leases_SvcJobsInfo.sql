CREATE function [dbo].[ufxABFRpt220Leases_SvcJobsInfo]
	-- Purpose: Summarizes Price,Cost,Commisions data , by Job				
	-- Parameters: @BeginOrderDate and @EndOrderDate define the OrderDate filter.		
	--	To select all OrderDates, enter NULL for each date parameter.			
	-- History: created 09/05/03 mah, modified 09/15/03 mah - get est costs fro svc tkts; add siteid		
(
@BeginOrderDate DateTime,
@EndOrderDate DateTime
)
Returns table
AS
Return
(
SELECT ST.TicketId,
	ST.SalesRepID, 
	ST.CustID,
	CustName = (
		SELECT CustName 
		FROM ALP_tblArCust_view 
		WHERE CustID = ST.CustID
		),
	ST.ProjectID,
	ST.DivID,
	ST.OrderDate,
	ST.SiteId,
	ST.LseYn,
	RMRExpense = isNull(ST.RMRExpense,0),
	RMRAdded = isNUll(ST.RMRAdded,0),
	ST.DiscRatePct,
	ContractMths = (
		SELECT DfltBillTerm 
		FROM ALP_tblArAlpCustContract 
		WHERE ContractID = ST.ContractID
		),
	CommAmt = isNull(ST.CommAmt,0),
	PartsPrice = isnull(ST.PartsPrice,0),
	LaborPrice = isNull(ST.LabPriceTotal,0),
	OtherPrice = CASE 
		WHEN PCPO.OtherPrice Is Null 
		THEN 0 ELSE PCPO.OtherPrice 
		END,
	JobPrice =  isNull(ST.PartsPrice,0) + 
	isNull(ST.LabPriceTotal,0)	+ 
	(CASE 
		WHEN PCPO.OtherPrice Is Null 
		THEN 0 ELSE PCPO.OtherPrice 
		END),
	EstCostParts = isNUll(ST.EstCostParts,0),
	EstCostMisc = isNull(ST.EstCostMisc,0),
	EstCostLabor = isNull(ST.EstCostLabor,0)
	
FROM   ALP_tblJmSvcTkt ST
	LEFT OUTER JOIN ufxAlpSvcJobPriceCost_PartsOther(NULL,NULL,@BeginOrderDate,@EndOrderDate) 
	AS PCPO
		ON ST.TicketId = PCPO.TicketId 
		
	--select only jobs related to projects, and to commercial or eng divisions
WHERE (
	ST.OrderDate 
	BETWEEN isNull(@BeginOrderDate,'01/01/1900') 
	AND isNull(@EndOrderDate,'12/12/2100')
	)
)