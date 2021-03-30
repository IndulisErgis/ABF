
CREATE VIEW [dbo].[ALP_qryJmCostAllocRpt_view]        
AS        
SELECT    
T.BranchId,    
'0' as GLAcct,    
'<N/A>' as GLAcctDescr,        
T.TicketId,    
T.SiteId,    
S.SiteName,    
TypeDetail =  CASE WHEN (Reso.Action = 'ADD'  OR Reso.Action = 'REPLACE') THEN         
     CASE WHEN TreatAsPartYn = 0     
      THEN CASE WHEN ITEM.ItemType = 3 THEN 'Other Misc' ELSE 'Other Part' END    
     ELSE 'Part' END         
   ELSE '' END,     
PartCostExt = CASE WHEN (Reso.Action = 'ADD'  OR Reso.Action = 'REPLACE')    
    THEN isNUll(STI.UnitCost,0)* isNull(qtyAdded,0)  -- use name PartCost    
    ELSE 0 END,    
PartOHExt = CASE WHEN (Reso.Action = 'ADD'  OR Reso.Action = 'REPLACE')    
    THEN (isNUll(STI.UnitCost,0)* isNull(qtyAdded,0)) * T.PartsOhPct     
    ELSE 0 END,    
PartCostWithOHExt = CASE WHEN (Reso.Action = 'ADD'  OR Reso.Action = 'REPLACE')    
    THEN (isNUll(STI.UnitCost,0)* isNull(qtyAdded,0)) * (1 +  T.PartsOhPct)    
    ELSE 0 END,        
PartPriceExt = CASE WHEN (Reso.Action = 'ADD'  OR Reso.Action = 'REPLACE')    
    THEN isNull(STI.UnitPrice,0)*isNull(qtyAdded,0) -- use name 'PartPrice     
    ELSE 0 END,       
T.CompleteDate,    
T.CloseDate,    
T.OrderDate,    
STI.ItemId,    
STI.WhseId,    
STI.TicketItemId,    
STI.ResDesc,         
STI.[Desc],         
STI.PartPulledDate,    
KorC = CASE STI.KittedYN WHEN 1 THEN 'K' WHEN 0 THEN 'C' ELSE '' END,         
Type = CASE Reso.Action         
  WHEN 'ADD' THEN         
   CASE TreatAsPartYn WHEN 0 THEN 'Other' ELSE 'Part' END         
  WHEN 'REPLACE' THEN CASE TreatAsPartYn WHEN 0 THEN 'Other' ELSE 'Part' END         
  ELSE '' END,         
Qty = CASE Reso.Action         
  WHEN 'ADD' THEN qtyAdded        
  WHEN 'Replace' THEN qtyAdded         
  WHEN 'Service' THEN qtyServiced ELSE 0         
  END,         
UnitPrice = (CASE STI.UnitPrice WHEN NULL THEN 0 ELSE STI.UnitPrice END),         
UnitCost = (CASE STI.UnitCost         
  WHEN NULL THEN 0         
  ELSE STI.UnitCost         
  END),         
T.WorkCodeId,    
T.LseYn,    
T.DivId,    
T.DeptId,      
Reso.Action,
--Added by NSK on 27 Oct 2016
--start
Total=(CASE WHEN (Reso.Action = 'ADD'  OR Reso.Action = 'REPLACE')    
    THEN isNull(STI.UnitPrice,0)*isNull(qtyAdded,0) -- use name 'PartPrice     
    ELSE 0 END + 
    
    CASE WHEN (Reso.Action = 'ADD'  OR Reso.Action = 'REPLACE')    
    THEN (isNUll(STI.UnitCost,0)* isNull(qtyAdded,0)) * T.PartsOhPct     
    ELSE 0 END
    )
 ,ALP_tblArAlpBranch.Branch
--end
FROM   dbo.ALP_tblJmSvcTkt T INNER JOIN dbo.ALP_tblJMSvcTktItem STI ON T.TicketId = STI.TicketId     
  INNER JOIN dbo.ALP_tblArAlpSite S ON T.SiteId = S.SiteId 
  INNER JOIN ALP_tblArAlpBranch ON T.BranchId = ALP_tblArAlpBranch.BranchId -- Added by NSK on 27 Oct 2016
  LEFT OUTER JOIN dbo.tblInItem AS ITEM ON STI.ItemId = ITEM.ItemId     
  LEFT OUTER JOIN dbo.ALP_tblJmResolution AS Reso ON STI.ResolutionId =  Reso.ResolutionId     
WHERE  T.CompleteDate is not null AND ITEM.ItemType <> 3 AND STI.KittedYN = 0 AND STI.PartPulledDate is not null     
and (Reso.Action='Add' or Reso.Action='Replace')