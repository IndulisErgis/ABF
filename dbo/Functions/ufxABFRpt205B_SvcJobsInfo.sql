



CREATE function [dbo].[ufxABFRpt205B_SvcJobsInfo]
	/* Purpose: Summarizes Price,Cost,Commisions data , by Job				*/
	/*		Used in Alpine Reports by ABF custom report ABF205B			*/
	/* Parameters: 										*/
	/* 	     @BeginOrderDate and @EndOrderDate define the OrderDate filter.		*/
	/*		To select all OrderDates, enter NULL for each date parameter.		*/	
	/* History: created 09/05/03 mah								*/
	/*		modified 09/15/03 mah - get est costs fro svc tkts; add siteid		*/
	/*		modified 02/13/12 mah - added ContractID to output		*/
	/*      modified 02/03/14 mah/jvh - correct blank ProjectIDs in rpt R205B */
	/*		mod 02/08/2014 JVH sort error in R205B */
(
@BeginOrderDate Datetime,
@EndOrderDate Datetime
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
		WHERE CustID = ST.CustID),
	ST.ProjectID,
	ST.DivID,
	ST.OrderDate,
	ST.SiteId,
	ST.LseYn,
	CO = CASE WHEN ST.CsConnectYn = 0 THEN 0 ELSE 1 END,
	RMRExpense = isNull(ST.RMRExpense,0),
	RMRAdded = isNull(ST.RMRAdded,0),
	ST.DiscRatePct,
	ST.ContractID,
	ContractMths = (
		SELECT DfltBillTerm 
		FROM ALP_tblArAlpCustContract 
		WHERE ContractID = ST.ContractID),
	ContractValue = (
		SELECT ContractValue 
		FROM ALP_tblArAlpCustContract 
		WHERE (ContractID = ST.ContractID)
		--AND (ContractValue IS NOT NULL) -- undo this change 2-10-2014, ContractValue contains no nulls  
		--AND (ContractValue<>0) -- mod 02/03/14 JVH - correct sort issue in rpt R205B? - undo this change 2-10-2014
		),
	CommAmt = isNull(ST.CommAmt,0),
	PartsPrice = isnull(ST.PartsPrice,0),
	LaborPrice = isNull(ST.LabPriceTotal,0),
	OtherPrice = CASE 
		WHEN OPC.OtherPrice Is Null 
		THEN 0 ELSE OPC.OtherPrice 
		END,
	JobPrice =  isNull(ST.PartsPrice,0) + isNull(ST.LabPriceTotal,0)
		+ (CASE 
			WHEN OPC.OtherPrice Is Null 
			THEN 0 ELSE OPC.OtherPrice 
			END),
	EstCostParts = isNUll(ST.EstCostParts,0),
	EstCostMisc = isNull(ST.EstCostMisc,0), -- JVH 2-10-14 added
	EstCostLabor = isNull(ST.EstCostLabor,0)-- JVH 2-10-14 added
	
FROM ALP_tblJmSvcTkt ST
	LEFT OUTER JOIN dbo.ufxAlpSvcJobPriceCost_PartsOther(NULL,NULL,@BeginOrderDate,@EndOrderDate) AS OPC
		ON ST.TicketId = OPC.TicketId 
		
--select only jobs related to projects
WHERE (ST.ProjectID IS NOT NULL) 
	AND (RTRIM(ProjectID) <> '') -- update 2-3-14 MAH/JVH correct blanks in rpt R205B
--	AND (ST.Status <> 'canceled') -- 11/28/17 ER - ABF wants to capture canceled 
	AND (Convert(Datetime, convert(Date, ST.OrderDate)) BETWEEN isNull(@BeginOrderDate,'01/01/1900') AND isNull(@EndOrderDate,'12/12/2100') )
)