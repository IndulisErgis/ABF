
CREATE PROCEDURE [dbo].[trav_WMPackingList_proc]
@QuantityPrecision TINYINT
AS
BEGIN TRY
	SET NOCOUNT ON
--------------------------------------------------------------------------------------------------
	CREATE TABLE [dbo].[#PickQtySum]
	(
		[TranKey]      [INT]     NOT NULL,
		[TranPickKey]  [INT]         NULL,
		[ItemId]       [pItemID]     NULL,
		[LocId]        [pLocID]      NULL,
		[SerNum]       [pSerNum]     NULL,
		[LotNum]       [pLotNum]     NULL,
		[BaseQuantity] [pDecimal]    NOT NULL
	)
--------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[#PickQtySum]([TranKey],
		                            [TranPickKey],
		                            [ItemId],
		                            [LocId],
		                            [SerNum],
		                            [LotNum],
		                            [BaseQuantity])
	     SELECT [xfer].[TranKey],
		        [pick].[TranPickKey],
		        [pick].[ItemId],
		        [pick].[LocId],
		        [pick].[SerNum],
		        [pick].[LotNum],
			    SUM(ROUND( (ISNULL([pick].[Qty], 0) * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision) )
	       FROM [dbo].[trav_tblWmTransfer_view] [xfer]
	 INNER JOIN [dbo].[#Batch] [btch]
             ON [btch].[BatchID] = [xfer].[BatchID]
	  LEFT JOIN [dbo].[tblWmTransferPick] [pick]             
             ON [pick].[TranKey] = [xfer].[TranKey]
      LEFT JOIN [dbo].[tblInItemUom] [unit]
             ON [unit].[ItemId] =[pick].[ItemId]
			AND [unit].[Uom] = [pick].[UOM]
          WHERE [xfer].[Status] = 1
            AND ([pick].[TranKey] IS NULL
             OR [pick].[Status] = 0)
       GROUP BY [xfer].[TranKey], 
                [pick].[TranPickKey],
                [pick].[ItemId], 
                [pick].[LocId],
                [pick].[SerNum],
                [pick].[LotNum]
--------------------------------------------------------------------------------------------------
        SELECT [xfer].[TranKey],
               [xfer].[BatchID],
               [xfer].[PackNum],
               [xfer].[LocIdTo],
               [xfer].[UOM],
               [xfer].[Qty],
               [xfer].[ItemId],
               [xfer].[LocId],
               [temp].SerNum,
               [temp].LotNum,
               [tloc].[Descr] AS LocIdToDescr,
               [tloc].[Addr1] AS [ShipToAddr1],
               [tloc].[Addr2] AS [ShipToAddr2],
               [tloc].[City] AS [ShipToCity],
               [tloc].[Region] AS [ShipToRegion],
               [tloc].[PostalCode] AS [ShipToPostalCode],
               [tloc].[Country] AS [ShipToCountry],
               [floc].[Descr] AS LocIdFromDescr,
               [floc].[Addr1] AS [ShipFromAddr1],
               [floc].[Addr2] AS [ShipFromAddr2],
               [floc].[City] AS [ShipFromCity],
               [floc].[Region] AS [ShipFromRegion],
               [floc].[PostalCode] AS [ShipFromPostalCode],
               [floc].[Country] AS [ShipFromCountry],
               [item].[Descr],
               [item].[ItemType],
               [item].[LottedYN],
               (ROUND( ([temp].[BaseQuantity] / ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision) ) AS [QtyPicked],
               (ROUND( ([bqty].[QtyPickedBase] / ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision) ) AS [TotQtyPicked]
          FROM [dbo].[trav_tblWmTransfer_view] [xfer]
	INNER JOIN [dbo].[#PickQtySum] [temp]
            ON [temp].[TranKey] = [xfer].[TranKey]
     LEFT JOIN [dbo].[tblInLoc] [tloc]
            ON [tloc].[LocId] = [xfer].[LocIdTo]
     LEFT JOIN [dbo].[tblInLoc] [floc]
            ON [floc].[LocId] = [xfer].[LocId]
     LEFT JOIN [dbo].[tblInItem] [item]
            ON [item].[ItemId] = [xfer].[ItemId]
     LEFT JOIN [dbo].[tblInItemUom] [unit] 
            ON [unit].[ItemId] = [xfer].[ItemId]
           AND [unit].[Uom] = [xfer].[UOM]
     LEFT JOIN (  SELECT [TranKey],
                         SUM([BaseQuantity]) AS [QtyPickedBase]
                    FROM [dbo].[#PickQtySum]
                GROUP BY [TranKey]) [bqty]
            ON [bqty].[TranKey] = [xfer].[TranKey]
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPackingList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMPackingList_proc';

