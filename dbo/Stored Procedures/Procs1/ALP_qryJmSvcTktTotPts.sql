


CREATE procedure dbo.ALP_qryJmSvcTktTotPts
--EFI 1515 MAH 09/28/04 - set default for null points
@ID int
As
Set nocount on
Create table #Tmp
(
TicketId int,
Qty pDec,
UnitPts pDec
)
--Get current aged customer balances
Insert into #Tmp
	SELECT ALP_tblJmSvcTktItem.TicketId,  
	CASE
		WHEN ALP_tblJmResolution.[Action] = 'Add' THEN QtyAdded
		WHEN ALP_tblJmResolution.[Action]='Replace' THEN QtyAdded
		WHEN ALP_tblJmResolution.[Action]='Remove' THEN QtyRemoved
		WHEN ALP_tblJmResolution.[Action]='Service' THEN QtyServiced
		ELSE 1
--	END AS Qty, UnitPts
	END AS Qty, CASE WHEN UnitPts is null then 0 
		WHEN UnitPts = '' then 0 else UnitPts END
	FROM ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId
	WHERE ALP_tblJmSvcTktItem.TicketId = @ID
--return the resultset
SELECT TicketId, Sum([UnitPts]*[Qty]) AS SumOfUnitPts
FROM #Tmp
GROUP BY TicketId
HAVING TicketId = @ID
Return 0