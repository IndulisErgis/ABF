
CREATE PROCEDURE [dbo].[trav_WMLocationTransfersReport_proc]
@QuantityPrecision TINYINT,
@Include           TINYINT
AS
BEGIN TRY
	SET NOCOUNT ON
    ----------------------------------------------------------------------------------------------------------------------------
	CREATE TABLE [dbo].[#Transfers]
	(
		[TranKey]     [INT]      NOT NULL,
		[SerNum]      [pSerNum]      NULL,
		[LotNum]      [pLotNum]      NULL,
		[ExtLocA]     [INT]          NULL,
		[ExtLocB]     [INT]          NULL,
		[TranPickKey] [INT]      NOT NULL, 
		[TransType]   [TINYINT]  NOT NULL, -- 0 = Pick, 1 = Receipt
		[TransDate]   [DATETIME] NOT NULL,
		[BaseQty]     [pDecimal]     NOT NULL,
	)
    ----------------------------------------------------------------------------------------------------------------------------
	IF (@Include = 1)
		BEGIN
			DELETE [dbo].[#Filter]
              FROM [dbo].[tblWmTransferPick] [pick]
			 WHERE [pick].[TranKey] = [dbo].[#Filter].[TranKey]
		END
	ELSE
		BEGIN
            --------------------------------------------------------------------------------------------------------------------
			INSERT INTO [dbo].[#Transfers]([TranKey],
										   [SerNum],
										   [LotNum],
										   [ExtLocA],
										   [ExtLocB],
										   [TranPickKey],
										   [TransType],
										   [TransDate],
										   [BaseQty])
			     SELECT [xfer].[TranKey],
 					    [pick].[SerNum],
 						[pick].[LotNum],
		 			    [pick].[ExtLocA],
 					    [pick].[ExtLocB],
 						[pick].[TranPickKey],
		 			    0,
					    [pick].[TransDate],
						ROUND( ([pick].[Qty] * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision)
			       FROM [dbo].[trav_tblWmTransfer_view] [xfer]
			 INNER JOIN [dbo].[#Filter] [fltr]
					 ON [fltr].[TranKey] = [xfer].[TranKey]
		     INNER JOIN [dbo].[tblWmTransferPick] [pick]
				     ON [pick].[TranKey] = [xfer].[TranKey]
		      LEFT JOIN [dbo].[tblInItemUom] [unit]
				     ON [unit].[ItemId] =[pick].[ItemId]
					AND [unit].[Uom] = [pick].[UOM]
            --------------------------------------------------------------------------------------------------------------------
			INSERT INTO [dbo].[#Transfers]([TranKey],
										   [SerNum],
										   [LotNum],
										   [ExtLocA],
										   [ExtLocB],
										   [TranPickKey],
										   [TransType],
										   [TransDate],
										   [BaseQty])
			     SELECT [xfer].[TranKey],
 					    [rcpt].[SerNum],
 						[rcpt].[LotNum],
		 			    [rcpt].[ExtLocA],
 					    [rcpt].[ExtLocB],
 						[pick].[TranPickKey],
		 			    1,
					    [rcpt].[TransDate],
						ROUND( ([rcpt].[Qty] * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision)
			       FROM [dbo].[trav_tblWmTransfer_view] [xfer]
			 INNER JOIN [dbo].[#Filter] [fltr]
		             ON [fltr].[TranKey] = [xfer].[TranKey]
			 INNER JOIN [dbo].[tblWmTransferPick] [pick]
					 ON [pick].[TranKey] = [xfer].[TranKey]
		     INNER JOIN [dbo].[tblWmTransferRcpt] [rcpt]
				     ON [rcpt].[TranPickKey] = [pick].[TranPickKey]
		      LEFT JOIN [dbo].[tblInItemUom] [unit]
				     ON [unit].[ItemId] =[rcpt].[ItemId]
					AND [unit].[Uom] = [rcpt].[UOM]
            --------------------------------------------------------------------------------------------------------------------
			UPDATE [dbo].[#Filter]
               SET [PFStatus] = 2
              FROM (  SELECT [temp].[TranKey]
                        FROM [dbo].[#Transfers] [temp]
                    GROUP BY [temp].[TranKey]) [otmp]
             WHERE [otmp].[TranKey] = [dbo].[#Filter].[TranKey]
		END
    ----------------------------------------------------------------------------------------------------------------------------
	UPDATE [dbo].[#Filter]
       SET [PFStatus] = 4
      FROM [dbo].[trav_tblWmTransfer_view] [xfer]
     WHERE [xfer].[TranKey] = [dbo].[#Filter].[TranKey]
       AND [xfer].[Status] = 2
    ----------------------------------------------------------------------------------------------------------------------------
	UPDATE [dbo].[#Filter]
       SET [PFStatus] = 4
      FROM (  SELECT [otmp].[TranKey]
                FROM (  SELECT [temp].[TranKey],
                               CASE WHEN ROUND(SUM(CASE WHEN [temp].[TransType] = 0 
                                                        THEN [temp].[BaseQty] 
                                                        ELSE -[temp].[BaseQty] END), @QuantityPrecision) = 0.0 
                                    THEN 1 
                                    ELSE 0 END AS [MatchCount]
                          FROM [dbo].[#Transfers] [temp]
                      GROUP BY [temp].[TranKey],
                               [temp].[TranPickKey]) [otmp]
            GROUP BY [otmp].[TranKey]
              HAVING COUNT(1) = SUM([otmp].[MatchCount]) ) [ptmp]
     WHERE [ptmp].[TranKey] = [dbo].[#Filter].[TranKey]
    ----------------------------------------------------------------------------------------------------------------------------
    	SELECT [xfer].[TranKey],
               [xfer].[Status],
               [xfer].[BatchID],
               [xfer].[TransDate] AS [EntryDate],
               [xfer].[ItemId],
               [xfer].[LocId],
               [xfer].[LocIdTo],
               [xfer].[Qty],
               [xfer].[UOM],
               [xfer].[CostTransfer],
               [xfer].[Cmnt],
               [temp].[TransType],
               [temp].[TransDate],
               [temp].[SerNum],
               [temp].[LotNum],
               [item].[Descr],
               [item].[ItemType],
               [item].[LottedYN],
               [locA].[ExtLocID] AS [ExtLocAID],
               [locB].[ExtLocID] AS [ExtLocBID],
               CASE WHEN [temp].[TranKey] IS NULL
                    THEN NULL
                    ELSE CASE WHEN [temp].[TransType] = 0
                              THEN ROUND([temp].[BaseQty] / ISNULL([unit].[ConvFactor], 1), @QuantityPrecision)
                              ELSE NULL END END AS [QtyPicked],
               CASE WHEN [temp].[TranKey] IS NULL
                    THEN NULL
                    ELSE CASE WHEN [temp].[TransType] = 1
                              THEN ROUND([temp].[BaseQty] / ISNULL([unit].[ConvFactor], 1), @QuantityPrecision)
                              ELSE NULL END END AS [QtyReceived],
               (ROUND( ([bqty].[QtyPickedBase] / ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision) ) AS [TotalQtyPicked],
               (ROUND( ([bqty].[QtyReceivedBase] / ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision) ) AS [TotalQtyReceived]
          FROM [dbo].[trav_tblWmTransfer_view] [xfer]
	INNER JOIN [dbo].[#Filter] [fltr]
            ON [fltr].[TranKey] = [xfer].[TranKey]
	 LEFT JOIN [dbo].[#Transfers] [temp]
            ON [temp].[TranKey] = [xfer].[TranKey]
     LEFT JOIN [dbo].[tblInItem] [item]
            ON [item].[ItemId] = [xfer].[ItemId]
     LEFT JOIN [dbo].[tblWmExtLoc] [locA] 
            ON [locA].[Id] = [temp].[ExtLocA]
           AND [locA].[Type] = 0
     LEFT JOIN [dbo].[tblWmExtLoc] [locB] 
            ON [locB].[Id] = [temp].[ExtLocB]
           AND [locB].[Type] = 1
     LEFT JOIN [dbo].[tblInItemUom] [unit]
            ON [unit].[ItemId] = [xfer].[ItemId]
           AND [unit].[Uom] = [xfer].[UOM] 
     LEFT JOIN (  SELECT [temp].[TranKey],
                         SUM(CASE WHEN [temp].[TransType] = 0
                                  THEN [temp].[BaseQty]
                                  ELSE 0 END) AS [QtyPickedBase],
                         SUM(CASE WHEN [temp].[TransType] = 1
                                  THEN [temp].[BaseQty]
                                  ELSE 0 END) AS [QtyReceivedBase]
                    FROM [dbo].[#Transfers] [temp]
                GROUP BY [temp].[TranKey]) [bqty]
            ON [bqty].[TranKey] = [xfer].[TranKey]
         WHERE ([fltr].[PFStatus] & @Include) = [fltr].[PFStatus]
    ----------------------------------------------------------------------------------------------------------------------------
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMLocationTransfersReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMLocationTransfersReport_proc';

