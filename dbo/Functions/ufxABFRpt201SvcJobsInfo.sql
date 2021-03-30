CREATE function [dbo].[ufxABFRpt201SvcJobsInfo]
	/* Purpose: Summarizes Price,Cost,Commisions data , by Job				*/
	/*		Used in Alpine Reports by ABF custom report ABF201			*/
	/* Parameters: 										*/
	/* 	     @BeginOrderDate and @EndOrderDate define the OrderDate filter.		*/
	/*		To select all OrderDates, enter NULL for each date parameter.		*/	
	/* History: created 09/09/03 mah							*/
	/*		modified 09/15/03 mah - get costs from new SvcTkt fields: add siteid	*/
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
	ST.ProjectID,
	ST.DivID,
	ST.DeptID,
	ST.OrderDate,
	ST.SiteId,
	ST.RMRExpense,
	ST.RMRAdded,
	ST.DiscRatePct,
	ContractMths = (
		SELECT DfltBillTerm 
		FROM ALP_tblArAlpCustContract 
		WHERE ContractID = ST.ContractID),
	ST.CommAmt,
	ST.PartsPrice,
	LaborPrice = ST.LabPriceTotal,
	OtherPrice = CASE WHEN OPC.OtherPrice Is Null THEN 0 ELSE OPC.OtherPrice END,
	JobPrice =  ST.PartsPrice + ST.LabPriceTotal + 
		(CASE WHEN OPC.OtherPrice Is Null 
			THEN 0 ELSE OPC.OtherPrice 
			END),
	ST.EstCostParts,
	ST.EstCostMisc,
	ST.EstCostLabor
	
FROM ALP_tblJmSvcTkt ST
	LEFT OUTER JOIN dbo.ufxAlpSvcJobPriceCost_PartsOther(NULL,NULL,@BeginOrderDate,@EndOrderDate) AS OPC
		ON ST.TicketId = OPC.TicketId 
	--select only jobs related to projects, and to commercial or eng divisions
WHERE 
	(ST.ProjectID IS NOT NULL)
	AND
	(ST.DivID IN (1,2))	
	AND
	(ST.Status <> 'canceled')

	AND
	(ST.OrderDate 
		BETWEEN isNull(@BeginOrderDate,'01/01/1900') 
		AND isNull(@EndOrderDate,'12/12/2100'))
)