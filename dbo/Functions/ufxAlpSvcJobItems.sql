CREATE Function [dbo].[ufxAlpSvcJobItems]
/* Purpose: Select Price and Cost data for Service Ticket Items.				*/
/* Parameters: @StartTicketID and @EndTicketID define the range of ticketID's to select. 	*/
/*		To select one TicketID, enter the same number for both parameters.	 */
/*		To select all TicketIDs, enter NULL for each TicketID parameter.	 	*/
/* 	     @BeginOrderDate and @EndOrderDate define the OrderDate filter.		 */
/*		To select all OrderDates, enter NULL for each date parameter.		*/	
/* History: created 09/05/03 mah								*/
	(
	@StartTicketID int,
	@EndTicketID int,
	@BeginOrderDate dateTime,
	@EndOrderDate dateTime
	)
RETURNS table
As
RETURN (
SELECT TOP 100 percent STI.ResDesc, CC.CauseCode, STI.[Desc], 
	STI.EquipLoc, UnitPts AS Pts, UnitHrs AS Hrs, 
	CASE
		WHEN KittedYn = 1 THEN 'K'
		WHEN KitRef IS Not Null OR KitRef <> '' THEN 'C'
		ELSE ''
	END AS KorC, 
	CASE 
		WHEN TreatAsPartYN = 1 THEN 'Yes'
		ELSE 'No'
	END AS TreatAsPartYn,
	CASE
		WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 1 THEN 'Part'
		WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 0 THEN 'Other'
		ELSE ''
	END AS Type,
	CASE
		WHEN [Action] = 'Add' THEN QtyAdded
		WHEN [Action] = 'Replace' THEN QtyAdded
		WHEN [Action] = 'Remove' THEN QtyAdded
		WHEN [Action] = 'Service' THEN QtyServiced
		ELSE 1 
	END AS Qty,
	Price = CASE WHEN STI.UnitPrice is null 
		THEN 0 ELSE STI.UnitPrice END, 
	TotPrice = (CASE WHEN STI.UnitPrice is null 
		THEN 0 ELSE STI.UnitPrice END) * 
		(CASE
		WHEN [Action] = 'Add' THEN QtyAdded
		WHEN [Action] = 'Replace' THEN QtyAdded
		WHEN [Action] = 'Remove' THEN QtyAdded
		WHEN [Action] = 'Service' THEN QtyServiced
		ELSE 1 
		END),
	 Cost = CASE 
	 WHEN STI.UnitCost is null THEN 0 
	 ELSE STI.UnitCost END, 
	 STK.PriceMethod, 
	 STI.TicketItemId, 
	 STI.TicketId
	 
FROM ALP_tblJmResolution AS JR 
INNER JOIN (ALP_tblJmCauseCode AS CC 
INNER JOIN (ALP_tblJmSvcTktItem AS STI
INNER JOIN ALP_tblJmSvcTkt AS STK 
ON STI.TicketId = STK.TicketId) 
ON CC.CauseId = STI.CauseId) 
ON JR.ResolutionId = STI.ResolutionId

WHERE (STK.TicketId BETWEEN isNull(@StartTicketID,'0') 
	AND isNull(@EndTicketID,'999999'))
	AND (STK.OrderDate BETWEEN isNull(@BeginOrderDate,'01/01/1900') 
	AND isNull(@EndOrderDate,'12/12/2100')) 
ORDER BY STK.TicketId,
	STI.TreatAsPartYn
)