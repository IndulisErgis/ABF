CREATE Procedure dbo.Alp_qryJmIN_PhysicalCountPrepB_sp  
AS  
SET NOCOUNT ON  
--Create InUse Bins where needed  
create table #ItemLocBin  
( ItemId pItemId, LocId pLocId, InUseYN smallint  )  
INSERT INTO #ItemLocBin ( ItemId, LocId,InUseYN )  
 SELECT dbo.tblInItemLocBin.ItemId, dbo.tblInItemLocBin.LocId,   
  SUM(CASE WHEN BinNum = 'InUse' Then 1 else 0 end)  
 FROM dbo.tblInItemLocBin  
 GROUP BY dbo.tblInItemLocBin.ItemId, LocID   
 HAVING SUM(CASE WHEN BinNum = 'InUse' Then 1 else 0 end) = 0  
INSERT INTO #ItemLocBin ( ItemId, LocId,InUseYN )  
 SELECT dbo.tblInItemLoc.ItemId, dbo.tblInItemLoc.LocId, 0   
 FROM dbo.tblInItemLoc  
 WHERE not exists(SELECT dbo.tblInItemLocBin.ItemId  
  FROM dbo.tblInItemLocBin   
  WHERE dbo.tblInItemLocBin.ItemId = dbo.tblInItemLoc.ItemId)  
 GROUP BY dbo.tblInItemLoc.ItemId, LocID   
  
INSERT INTO dbo.tblInItemLocBin ( ItemId, LocId, BinNum)  
 SELECT #ItemLocBin.ItemId, #ItemLocBin.LocId, 'InUse'  
 FROM #ItemLocBin   
 --WHERE #ItemLocBin.InUseYN = 0  
drop table #ItemLocBin