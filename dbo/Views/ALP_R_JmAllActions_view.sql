
CREATE VIEW [dbo].[ALP_R_JmAllActions_view]  
AS  
SELECT  
STI.TicketItemId,   
STI.TicketId,   
STI.ResDesc,   
CC.CauseCode,   
STI.[Desc],   
CASE STI.KittedYN WHEN 1 THEN 'K' WHEN 0 THEN 'C' ELSE '' END AS KorC,   
CASE Reso.Action   
 WHEN 'ADD' THEN   
  CASE TreatAsPartYn WHEN 0 THEN 'Other' ELSE 'Part' END   
 WHEN 'REPLACE' THEN CASE TreatAsPartYn WHEN 0 THEN 'Other' ELSE 'Part' END   
 ELSE '' END AS Type,   
CASE Reso.Action   
 WHEN 'ADD' THEN qtyAdded  
 --changed 11/14/14 - mah and er - changed stmt below from qtyRemoved to qtyAdded 
 WHEN 'Replace' THEN qtyAdded   
 WHEN 'Service' THEN qtyServiced ELSE 0   
 END AS Qty,   
(CASE STI.UnitPrice WHEN NULL THEN 0 ELSE STI.UnitPrice END) AS Price,   
(CASE STI.UnitCost   
 WHEN NULL THEN 0   
 ELSE STI.UnitCost   
 END) AS COST,   
STI.UnitPts,   
STI.UnitHrs,   
STI.PartPulledDate,  
--added to allow seperation of parts and services for 'other' items - ERR - 9/4/15
ITEM.ItemType 
  
FROM  
dbo.ALP_tblJmResolution AS Reso   
INNER JOIN dbo.ALP_tblJmCauseCode AS CC  
RIGHT OUTER JOIN dbo.ALP_tblJmSvcTktItem AS STI   
 ON CC.CauseId = STI.CauseId   
 ON Reso.ResolutionId = STI.ResolutionId  
LEFT OUTER JOIN dbo.tblInItem AS ITEM
 ON STI.ItemId = ITEM.ItemId