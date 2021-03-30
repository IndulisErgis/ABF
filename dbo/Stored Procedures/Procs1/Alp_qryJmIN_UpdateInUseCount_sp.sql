  
  
CREATE Procedure dbo.Alp_qryJmIN_UpdateInUseCount_sp      
 AS      
SET NOCOUNT ON      
--Update physical counts   
--MAH 12/3/2014: updated the table entries to be changed. Required by Trav11 updates      
create table #JmInUse      
 ( ItemId pItemId, LocId pLocId, InUseCount pDec, UOMBase varchar(10) )      
     
INSERT INTO #JmInUse ( ItemId, LocId, InUseCount, UOMBase)      
 SELECT t.ItemId,t.WhseId, Sum(t.BaseQty) AS InUseCount, i.UomBase      
  FROM dbo.Alp_tmpJmSvcTktItem_IN_Conversion t      
  INNER JOIN dbo.tblInItem  i ON t.ItemId = i.ItemId      
  --WHERE (t.Category Like 'InUse')      
  WHERE (t.Category =1)      
  GROUP BY t.ItemId,t.WhseId, i.UomBase      
  ORDER BY t.ItemId      
  
--MAH UPDATE 12/3/2014:  
UPDATE dbo.tblInPhysCountDetail    
 SET dbo.tblInPhysCountDetail.QtyCounted = [InUseCount] ,  
  dbo.tblInPhysCountDetail.CountedUom = [UomBase]  
 FROM #JmInUse    
 INNER JOIN  dbo.tblInPhysCount  pc  
  ON (#JmInUse.LocId = pc.LocId) AND (#JmInUse.ItemId = pc.ItemId)    
 INNER JOIN  dbo.tblInPhysCountDetail    
  ON (pc.SeqNum = dbo.tblInPhysCountDetail.SeqNum ) AND (dbo.tblInPhysCountDetail.ExtLocAId = 'InUse')   
    
--UPDATE dbo.tblInPhysCount      
-- SET dbo.tblInPhysCount.QtyCounted = [InUseCount],dbo.tblInPhysCount.CountedUom = [UomBase],       
--  dbo.tblInPhysCount.VerifyYn = 1      
-- FROM #JmInUse      
-- INNER JOIN  dbo.tblInPhysCount      
--  ON (#JmInUse.LocId = dbo.tblInPhysCount.LocId) AND (#JmInUse.ItemId = dbo.tblInPhysCount.ItemId)       
--  and  (dbo.tblInPhysCount.BinNum='InUse')      
      
drop table #JmInUse