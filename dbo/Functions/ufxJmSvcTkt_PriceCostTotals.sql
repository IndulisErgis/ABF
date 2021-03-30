

CREATE Function dbo.ufxJmSvcTkt_PriceCostTotals
/* Purpose: Determine Price and Cost data for Service Ticket(s), for Parts and Other items.	*/
/* Parameters: @ProjectID - used to select all data within a Project. 				*/
/*                  To select only by TicketID, enter NULL for the ProjectID parameter		*/
/* 	       @TicketID - used to select data for a specific job ( TicketID ).		 	*/
/*		    To select all TicketIDs, enter NULL for the TicketID parameter. 		*/
/* History: created 12/16/05 M.Hueser								*/
	(
	@ProjectID varchar(10) = null,
	@TicketID int = null
	)
RETURNS table
As
RETURN (
SELECT TOP 100 PERCENT
	ProjectID = @ProjectID,
	TicketID,
	--NOTE: Parts Price  is taken from the SvcTkt table, rather than from summing the price of the parts
	--PartsPrice = ROUND(SUM(
	--		CASE
	--		WHEN TreatAsPartYn = 'Yes' THEN TotPrice
	--		ELSE 0
	--		END
	--		),2),
	OtherPrice = ROUND(SUM(
			CASE
			WHEN TreatAsPartYn = 'Yes' THEN 0
			ELSE TotPrice
			END
			),2),
	PartsCost = ROUND(SUM(
			CASE
			WHEN TreatAsPartYn = 'Yes' THEN TotCost
			ELSE 0
			END
			),2),
	OtherCost = ROUND(SUM(
			CASE
			--WHEN TreatAsPartYn = 'Yes' THEN 0
			WHEN Type = 'OTHER' THEN TotCost
			ELSE 0
			END
			),2),
	OtherCostLabor  = ROUND(SUM(
			CASE
			WHEN Type = 'OTHERLABOR' THEN TotCost
			ELSE 0
			END
			),2),
	EstHrs = SUM(TotHrs),
	EstPts = SUM(TotPts)
FROM dbo.ufxJmSvcTktItems(@ProjectID,@TicketID)
GROUP BY dbo.ufxJmSvcTktItems.TicketID
)
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ufxJmSvcTkt_PriceCostTotals] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxJmSvcTkt_PriceCostTotals] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ufxJmSvcTkt_PriceCostTotals] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ufxJmSvcTkt_PriceCostTotals] TO PUBLIC
    AS [dbo];

