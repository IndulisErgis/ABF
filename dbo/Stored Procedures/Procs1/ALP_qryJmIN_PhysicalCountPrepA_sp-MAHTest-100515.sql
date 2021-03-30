
CREATE Procedure [dbo].[ALP_qryJmIN_PhysicalCountPrepA_sp-MAHTest-100515] 
AS 
SET NOCOUNT ON 
--Update Dflt Bins 
UPDATE dbo.tblInItemLoc 
SET dbo.tblInItemLoc.DfltBinNum = (SELECT COALESCE(Min(dbo.tblInItemLocBin.BinNum),' ') 
                                FROM dbo.tblInItemLocBin 
                                WHERE (dbo.tblInItemLoc.LocId = dbo.tblInItemLocBin.LocId) 
                                AND (dbo.tblInItemLoc.ItemId = dbo.tblInItemLocBin.ItemId) 
                                AND (dbo.tblInItemLocBin.BinNum <> 'InUse') 
                                GROUP BY dbo.tblInItemLocBin.ItemId, dbo.tblInItemLocBin.LocId) 
                                
WHERE ((dbo.tblInItemLoc.DfltBinNum) Is Null) 

--MAH 10/05/15 - INSERT Inventory Cleanup here.  
--Must be done before Batches are frozen, and before Physical Inventory process begins

exec ALP_qryJmIN_InventoryIntegrityCheck_sp