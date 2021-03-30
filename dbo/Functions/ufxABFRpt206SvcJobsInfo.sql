CREATE function [dbo].[ufxABFRpt206SvcJobsInfo]
	-- Purpose: Summarizes Price,Cost,Commisions data , by Job			
	--		Used in Alpine Reports by ABF custom report ABF206			
	-- Parameters: @BeginOrderDate and @EndOrderDate define the OrderDate filter.		
	--	To select all OrderDates, enter NULL for each date parameter.			
	-- History: created 08/05/11 mah							
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
	JobPrice =  ST.PartsPrice + ST.LabPriceTotal
		+ (CASE 
			WHEN OPC.OtherPrice Is Null 
			THEN 0 ELSE OPC.OtherPrice 
			END),
	ST.EstCostParts,
	ST.EstCostMisc,
	ST.EstCostLabor
	
FROM ALP_tblJmSvcTkt ST
	LEFT OUTER JOIN ufxAlpSvcJobPriceCost_PartsOther(NULL,NULL,@BeginOrderDate,@EndOrderDate) AS OPC
		ON ST.TicketId = OPC.TicketId 
	-- selects only 'project' jobs ( excludes service jobs )
WHERE (ST.ProjectID IS NOT NULL)
	AND
	(ST.Status <> 'canceled')
	AND
	(ST.OrderDate BETWEEN isNull(@BeginOrderDate,'01/01/1900') AND isNull(@EndOrderDate,'12/12/2100'))
)