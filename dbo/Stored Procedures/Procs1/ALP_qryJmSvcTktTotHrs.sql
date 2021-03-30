

CREATE procedure dbo.ALP_qryJmSvcTktTotHrs
@ID int
As
Set nocount on
Create table #Tmp
(
TicketId int,
Qty pDec,
UnitHrs pDec
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
	END AS Qty, UnitHrs
	FROM ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId
	WHERE ALP_tblJmSvcTktItem.TicketId = @ID
--return the resultset
SELECT TicketId, Sum([UnitHrs]*[Qty]) AS SumOfUnitHrs
FROM #Tmp
GROUP BY TicketId
HAVING TicketId = @ID
Return 0