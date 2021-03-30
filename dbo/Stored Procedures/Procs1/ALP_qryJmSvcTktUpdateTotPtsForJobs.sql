Create procedure dbo.ALP_qryJmSvcTktUpdateTotPtsForJobs  
--EFI 712 Ravi 08/28/2018 - update ticket totpoint
@IDs varchar (max)  
As  
Set nocount on  
Create table #Tmp  
(  
TicketId int,  
Qty pDec,  
UnitPts pDec  
)  
--Get current aged customer balances  
-- Test Target Table
DECLARE @Target_Table TABLE  (TicketId INT ) 

-- Insert statement
INSERT INTO @Target_Table
SELECT   CAST(item AS INT)   
FROM  dbo.ALP_ufxSplitString(@ids, ',')  

-- Test Select

Insert into #Tmp  
 SELECT ALP_tblJmSvcTktItem.TicketId,    
 CASE  
  WHEN ALP_tblJmResolution.[Action] = 'Add' THEN QtyAdded  
  WHEN ALP_tblJmResolution.[Action]='Replace' THEN QtyAdded  
  WHEN ALP_tblJmResolution.[Action]='Remove' THEN QtyRemoved  
  WHEN ALP_tblJmResolution.[Action]='Service' THEN QtyServiced  
  ELSE 1  
-- END AS Qty, UnitPts  
 END AS Qty, CASE WHEN UnitPts is null then 0   
  WHEN UnitPts = '' then 0 else UnitPts END  
 FROM ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId  
 WHERE ALP_tblJmSvcTktItem.TicketId in (Select TicketId From @Target_Table)  
--return the resultset   
SELECT TicketId, Sum([UnitPts]*[Qty]) AS SumOfUnitPts  into #t2
FROM #Tmp  
GROUP BY TicketId  
HAVING TicketId in( Select TicketId From @Target_Table  )

Update ticket SET TotalPts= temp.SumOfUnitPts
from ALP_tblJmSvcTkt  ticket Inner join #t2 temp on temp.TicketId= ticket.TicketId

Return 0