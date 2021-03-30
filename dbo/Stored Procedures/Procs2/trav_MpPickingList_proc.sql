
CREATE PROCEDURE [dbo].[trav_MpPickingList_proc]
AS
BEGIN TRY

   SET NOCOUNT ON
   ----------------------------------------
   CREATE TABLE [#PickingList] (
      [ListSeq]   INT        IDENTITY(1,1),
      [ReleaseId] INT,
      [ParentId]  INT) 
   ----------------------------------------------
   INSERT INTO [#PickingList]([ReleaseId],
                              [ParentId])
        SELECT [req].[ReleaseId],
               [req].[ParentId]
          FROM [dbo].[tblMpRequirements] [req]
    INNER JOIN [#Filter]
            ON ([#Filter].[Id] = [req].[ReleaseId])
 	     WHERE ([req].[Type] <> 0)
           AND ([req].[Type] <> 2)
           AND ([req].[Type] <> 5) 
      GROUP BY [req].[ReleaseId],
               [req].[ParentId]
      ORDER BY [req].[ReleaseId],
               MAX([req].[BLT]) DESC 
   -------------------------------------------------------
       SELECT [rel].[OrderNo],
              [rel].[ReleaseNo],
              [tmp].[Id] AS [ReleaseId],
              [rel].[CustId],
              [rel].[EstCompletionDate] AS [RequiredDate],
              [rel].[EstStartDate] AS [StartDate],
              [rel].[UOM] AS [BuildUom],
              [rel].[Qty] AS [BuildQty],
              [rel].[Notes], 
              [ord].[AssemblyId],
              [asm].[Description] AS [AssemblyDescr],
              [rel].[SalesOrder],
              [rel].[PurchaseOrder],
              [rel].[Priority],
              [rel].[OrderSource],
              [rel].[OrderCode] 
         FROM [#Filter] [tmp]
   INNER JOIN [dbo].[tblMpOrderReleases] [rel]
           ON ([rel].[Id] = [tmp].[Id]) 
   INNER JOIN [dbo].[tblMpOrder] [ord]
           ON ([ord].[OrderNo] = [rel].[OrderNo])	
   LEFT JOIN [dbo].[tblMbAssemblyHeader] [asm]
           ON ([asm].[AssemblyID] = [ord].[AssemblyID])
          AND ([asm].[RevisionNo] = [ord].[RevisionNo]) 
	    WHERE [tmp].[Id] IN (SELECT DISTINCT [ReleaseId] AS [Id]
                               FROM [dbo].[tblMpRequirements] 
                              WHERE ([Type] <> 0)
                                AND ([Type] <> 2)
                                AND ([Type] <> 5) ) 
   -------------------------------------------------------
       SELECT [tmp].[ListSeq],
              [tmp].[ReleaseId],
              [req].[ReqID],
              [req].[description] AS [ComponentDescr],
              [req].[TransId],
              [mtl].[ComponentID],
	          [mtl].[LocID],
              [mtl].[EstQtyRequired] AS [Qty],
              [mtl].[UOM], 
              [mtl].[Notes] AS [MaterialNotes], 
	          [tym].[WorkCenterID],
              [itm].[LottedYN],
              [itm].[ItemType],
              [loc].[DfltBinNum], 
              [req].[ReqSeq] 
         FROM [#PickingList] [tmp]
   INNER JOIN [dbo].[tblMpRequirements] [req] 
           ON ([req].[ReleaseId] = [tmp].[ReleaseId])
          AND ([req].[ParentId] = [tmp].[ParentId]) 
   INNER JOIN [dbo].[tblMpMatlSum] [mtl]
           ON ([mtl].[TransId] = [req].[TransId])
    LEFT JOIN [dbo].[tblInItem] [itm]
           ON ([itm].[ItemId] = [mtl].[ComponentID])
    LEFT JOIN [dbo].[tblInItemLoc] [loc]
           ON ([loc].[ItemId] = [mtl].[ComponentID])
          AND ([loc].[LocId] = [mtl].[LocID])
    LEFT JOIN [dbo].[tblMpTimeSum] [tym]
           ON ([tym].[TransId] = [req].[ParentId])
        WHERE ([req].[Type] <> 0)
          AND ([req].[Type] <> 2)
          AND ([req].[Type] <> 5)
     ORDER BY [tmp].[ListSeq],
              [tmp].[ReleaseId]
------------------------------------------------------
       SELECT [SumX].[LotNum],
              [SumX].[QtyRequired],
              [reqs].[TransId],
              [locA].[ExtLocID] AS [ExtLocAID],
              [locB].[ExtLocID] AS [ExtLocBID]
         FROM [dbo].[tblMpMatlSumExt] [SumX]
   INNER JOIN [dbo].[tblMpRequirements] [reqs] 
           ON ([reqs].[TransId] = [SumX].[TransId])
   INNER JOIN [#PickingList] [temp]
           ON ([temp].[ReleaseId] = [reqs].[ReleaseId])
          AND ([temp].[ParentId] = [reqs].[ParentId])
    LEFT JOIN [dbo].[tblWmExtLoc] [locA]
           ON ([locA].[Id] = [SumX].[ExtLocA])
          AND ([locA].[Type] = 0)
    LEFT JOIN [dbo].[tblWmExtLoc] [locB]
           ON ([locB].[Id] = [SumX].[ExtLocB])
          AND ([locB].[Type] = 1)
   --------------------------------------------------
END TRY
BEGIN CATCH
   EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpPickingList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpPickingList_proc';

