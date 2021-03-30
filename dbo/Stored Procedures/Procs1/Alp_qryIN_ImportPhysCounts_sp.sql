CREATE Procedure [dbo].[Alp_qryIN_ImportPhysCounts_sp]      
 AS      
SET NOCOUNT ON      
--Update physical counts   
--MAH 03/17/15: created      
create table #Import      
 ( ItemId pItemId, LocId pLocId, Bin varchar(10), [Count] pDec, UOM varchar(10) )      
     
INSERT INTO #Import ( ItemId, LocId, Bin,[Count], UOM)      
 SELECT t.ItemId,'ABF', t.[Bin], 
		CASE WHEN t.[Count] IS NULL THEN 0 ELSE t.[Count] END, t.Uom      
  FROM dbo.ALP_INPhysCounts t      
  --INNER JOIN dbo.tblInItem  i ON t.ItemId = i.ItemId      
  WHERE ItemId IS NOT NULL  --  AND  t.[Count] > 0   
  ORDER BY t.ItemId      
--select * from #Import  
UPDATE dbo.tblInPhysCountDetail    
 SET dbo.tblInPhysCountDetail.QtyCounted = [Count] ,  
  dbo.tblInPhysCountDetail.CountedUom = [Uom] 
  --,  dbo.tblInPhysCountDetail.VerifyYn = 1
 FROM #Import    
 INNER JOIN  dbo.tblInPhysCount  pc  
  ON (#Import.LocId = pc.LocId) AND (#Import.ItemId = pc.ItemId)    
 INNER JOIN  dbo.tblInPhysCountDetail    
  ON (pc.SeqNum = dbo.tblInPhysCountDetail.SeqNum ) AND (dbo.tblInPhysCountDetail.ExtLocAId = #Import.Bin)   

UPDATE dbo.tblInPhysCount    
 SET dbo.tblInPhysCount.VerifyYn = 1
 FROM #Import    
 INNER JOIN  dbo.tblInPhysCount  pc  
  ON (#Import.LocId = pc.LocId) AND (#Import.ItemId = pc.ItemId)    
      
drop table #Import