CREATE Function [dbo].[ufxJmSvcTktItems]
/* Purpose: Select Price and Cost data for Service Ticket Items.				*/
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
SELECT TOP 100 percent ALP_tblJmSvcTktItem.ResDesc, ALP_tblJmCauseCode.CauseCode, ALP_tblJmSvcTktItem.[Desc], 
	ALP_tblJmSvcTktItem.EquipLoc, UnitPts AS Pts, UnitHrs AS Hrs, 
	CASE
		WHEN ALP_tblJmSvcTktItem.KittedYn = 1 THEN 'K'
		WHEN KitRef IS Not Null OR KitRef <> '' THEN 'C'
		ELSE ''
	END AS KorC, 
	CASE 
		WHEN TreatAsPartYN = 1 THEN 'Yes'
		ELSE 'No'
	END AS TreatAsPartYn,
	CASE
		WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 1 THEN 'Part'
		--WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 0  THEN 'Other'
		WHEN ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 0 
			AND tblInItem.ItemType = 3 AND ALP_tblInItem.AlpServiceType = 1  THEN 'OtherLabor'
		ELSE 'Other'
	END AS Type,
	CASE
		WHEN [Action] = 'Add' THEN QtyAdded
		WHEN [Action] = 'Replace' THEN QtyAdded
		WHEN [Action] = 'Remove' THEN QtyAdded
		WHEN [Action] = 'Service' THEN QtyServiced
		ELSE 1 
	END AS Qty,
	ALP_tblJmSvcTktItem.UnitPrice AS Price, 
	TotPrice = ROUND( ALP_tblJmSvcTktItem.UnitPrice * 
		CASE
		WHEN [Action] = 'Add' THEN QtyAdded
		WHEN [Action] = 'Replace' THEN QtyAdded
		WHEN [Action] = 'Remove' THEN QtyAdded
		WHEN [Action] = 'Service' THEN QtyServiced
		ELSE 1 
		END,2),
	ALP_tblJmSvcTktItem.UnitCost AS Cost, 
	TotCost =ROUND( ALP_tblJmSvcTktItem.UnitCost * 
		CASE
		WHEN [Action] = 'Add' THEN QtyAdded
		WHEN [Action] = 'Replace' THEN QtyAdded
		WHEN [Action] = 'Remove' THEN QtyAdded
		WHEN [Action] = 'Service' THEN QtyServiced
		ELSE 1 
		END,2),
	TotHrs = ROUND(UnitHrs *
		CASE
		WHEN [Action] = 'Add' THEN QtyAdded
		WHEN [Action] = 'Replace' THEN QtyAdded
		WHEN [Action] = 'Remove' THEN QtyAdded
		WHEN [Action] = 'Service' THEN QtyServiced
		ELSE 1 
		END,2), 
	TotPts = ROUND(UnitPts *
		CASE
		WHEN [Action] = 'Add' THEN QtyAdded
		WHEN [Action] = 'Replace' THEN QtyAdded
		WHEN [Action] = 'Remove' THEN QtyAdded
		WHEN [Action] = 'Service' THEN QtyServiced
		ELSE 1 
		END,2), 
	 ALP_tblJmSvcTkt.PriceMethod, ALP_tblJmSvcTktItem.TicketItemId, ALP_tblJmSvcTktItem.TicketId
FROM ALP_tblJmResolution INNER JOIN (ALP_tblJmCauseCode INNER JOIN (ALP_tblJmSvcTktItem 
	INNER JOIN ALP_tblJmSvcTkt ON ALP_tblJmSvcTktItem.TicketId = ALP_tblJmSvcTkt.TicketId) ON ALP_tblJmCauseCode.CauseId = ALP_tblJmSvcTktItem.CauseId) 
	ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId
	LEFT JOIN tblInItem ON ALP_tblJmSvcTktItem.ItemID = tblInItem.ItemId
	LEFT JOIN ALP_tblInItem ON tblInItem.ItemId = ALP_tblInItem.AlpItemId
WHERE 	
((@TicketID is not null) and (ALP_tblJmSvcTkt.TicketId = @TicketID))
OR
((@TicketID is null) and (ALP_tblJmSvcTkt.ProjectId = @ProjectID))
ORDER BY ALP_tblJmSvcTkt.TicketId,
	ALP_tblJmSvcTktItem.TreatAsPartYn
)
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ufxJmSvcTktItems] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxJmSvcTktItems] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ufxJmSvcTktItems] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ufxJmSvcTktItems] TO PUBLIC
    AS [dbo];

