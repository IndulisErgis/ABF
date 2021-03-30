
CREATE VIEW dbo.ALP_stpJm0001SvcActionsAll
AS
SELECT dbo.ALP_tblJmSvcTktItem.TicketItemId, dbo.ALP_tblJmSvcTktItem.TicketId, dbo.ALP_tblJmSvcTktItem.ResDesc, dbo.ALp_tblJmCauseCode.CauseCode, 
             dbo.ALP_tblJmSvcTktItem.[Desc],
	CASE 
		WHEN dbo.ALP_tblJmSvcTktItem.KittedYn = 1 THEN 'K'	
		WHEN dbo.ALP_tblJmSvcTktItem.KittedYn = 0 AND ALP_tblJmSvcTktItem.KitRef Is Not Null THEN 'C'
		ELSE ''
		END AS KorC,
	CASE
		WHEN (ALP_tblJmResolution.[Action] = 'Add' OR ALP_tblJmResolution.[Action] = 'Replace') AND TreatAsPartYn = 1 THEN 'Part'
		WHEN (ALP_tblJmResolution.[Action] = 'Add' OR ALP_tblJmResolution.[Action] = 'Replace') AND TreatAsPartYn = 0 THEN 'Other'
		ELSE ''
	END AS Type,
	CASE	
		WHEN (ALP_tblJmResolution.[Action] = 'Add' OR ALP_tblJmResolution.[Action] = 'Replace') THEN QtyAdded
		WHEN ALP_tblJmResolution.[Action] = 'Remove' THEN QtyRemoved
		WHEN ALP_tblJmResolution.[Action] = 'Service' THEN QtyServiced
		ELSE 0
	END AS Qty,
	CASE
		WHEN UnitPrice is null THEN 0
		ELSE UnitPrice
	END AS Price,
	CASE
		WHEN UnitCost Is Null THEN 0
		ELSE UnitCost
	END AS Cost,	
	 ALP_tblJmSvcTktItem.UnitPts, ALP_tblJmSvcTktItem.UnitHrs
FROM         dbo.ALP_tblJmResolution INNER JOIN
                      dbo.ALP_tblJmCauseCode RIGHT OUTER JOIN
                      dbo.ALP_tblJmSvcTktItem ON dbo.ALP_tblJmCauseCode.CauseId = dbo.ALP_tblJmSvcTktItem.CauseId ON 
                      dbo.ALP_tblJmResolution.ResolutionId = dbo.ALP_tblJmSvcTktItem.ResolutionId