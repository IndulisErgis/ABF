CREATE Function [dbo].[ufxAlpSvcJobPriceCost_PartsOther]
/* Purpose: Determine Price and Cost data for Service Ticket(s), for Parts and Other items.	*/
/* Parameters: @StartTicketID and @EndTicketID define the range of ticketID's to select. 	*/
/*		To select one TicketID, enter the same number for both parameters.		*/
/*		To select all TicketIDs, enter NULL for each TicketID parameter.	 	*/
/* 	     @BeginOrderDate and @EndOrderDate define the OrderDate filter.		 	*/
/*		To select all OrderDates, enter NULL for each date parameter.			*/	
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
SELECT TOP 100 PERCENT
	TicketID,
	PartsPrice = ROUND(SUM(
			CASE
			WHEN TreatAsPartYn = 'Yes' THEN TotPrice
			ELSE 0
			END
			),2),
	OtherPrice = ROUND(SUM(
			CASE
			WHEN TreatAsPartYn = 'Yes' THEN 0
			ELSE TotPrice
			END
			),2),
	PartsCost = ROUND(SUM(
			CASE
			WHEN TreatAsPartYn = 'Yes' THEN Cost
			ELSE 0
			END
			),2),
	OtherCost = ROUND(SUM(
			CASE
			WHEN TreatAsPartYn = 'Yes' THEN 0
			ELSE Cost
			END
			),2)
FROM ufxAlpSvcJobItems(@StartTicketID,@EndTicketID,@BeginOrderDate,@EndOrderDate)

GROUP BY ufxAlpSvcJobItems.TicketID
)