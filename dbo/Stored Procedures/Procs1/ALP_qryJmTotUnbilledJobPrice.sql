CREATE PROCEDURE dbo.ALP_qryJmTotUnbilledJobPrice
@CustID varchar(10) as     
SELECT   
  ALP_tblJmSvcTkt.TicketId,     
  SUM(CASE      
  	WHEN [Action] = 'Add' THEN QtyAdded * coalesce(ALP_tblJmSvcTktItem.UnitPrice, 0)     
  	WHEN [Action] = 'Replace' THEN QtyAdded * coalesce(ALP_tblJmSvcTktItem.UnitPrice, 0)      
  	WHEN [Action] = 'Remove' THEN QtyAdded * coalesce(ALP_tblJmSvcTktItem.UnitPrice, 0)      
  	WHEN [Action] = 'Service' THEN QtyServiced * coalesce(ALP_tblJmSvcTktItem.UnitPrice, 0)      
    	ELSE 1       
  END) AS ExtPriceOtherEst    
INTO #TicketOtherItems
FROM ALP_tblJmResolution INNER JOIN (ALP_tblJmCauseCode INNER JOIN (ALP_tblJmSvcTktItem       
 	INNER JOIN ALP_tblJmSvcTkt ON ALP_tblJmSvcTktItem.TicketId = ALP_tblJmSvcTkt.TicketId) ON
  	ALP_tblJmCauseCode.CauseId = ALP_tblJmSvcTktItem.CauseId)       
 	ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId      
 	Left JOIN ALP_tblInItem_view ON ALP_tblJmSvcTktItem.ItemID = ALP_tblInItem_view.ItemId      
WHERE ([Action] = 'Add' or [Action] = 'Replace') AND TreatAsPartYn = 0  AND
	ALP_tblJmSvcTkt.CustId = '000000'and ALP_tblJmSvcTkt.BilledYN=0 and  
	ALP_tblJmSvcTkt.status <> 'Cancelled' and ALP_tblJmSvcTkt.status <> 'Closed'   
group by ALP_tblJmSvcTkt.TicketId

Select 
	(SUM(ISNULL(#TicketOtherItems.ExtPriceOtherEst,0))+ SUM(ISNULL(ALP_tblJmSvcTkt.PartsPrice,0)) + 
	SUM(ISNULL(ALP_tblJmSvcTkt.LabPriceTotal,0))) as TotUnbilledJobPrice
from #TicketOtherItems  
	Right outer join ALP_tblJmSvcTkt on #TicketOtherItems.TicketId=ALP_tblJmSvcTkt.TicketId
WHERE ALP_tblJmSvcTkt.CustId = @CustID and ALP_tblJmSvcTkt.BilledYN=0 and  
	ALP_tblJmSvcTkt.status <> 'Cancelled' and ALP_tblJmSvcTkt.status <> 'Closed'  
group by ALP_tblJmSvcTkt.CustId

drop table #TicketOtherItems