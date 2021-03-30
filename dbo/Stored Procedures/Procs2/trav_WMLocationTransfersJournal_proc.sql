
CREATE PROCEDURE [dbo].[trav_WMLocationTransfersJournal_proc]
@QuantityPrecision TINYINT,
@CurrencyPrecision TINYINT,
@UnitCostPrecision TINYINT,
@Include           tinyint
AS
BEGIN TRY
	SET NOCOUNT ON
	
DECLARE @IncludeNew bit
DECLARE @IncludePartial bit
DECLARE @IncludeCompleted bit

SELECT @IncludeNew = CASE WHEN @Include & 1 = 1 THEN 1 ELSE 0 END
SELECT @IncludePartial = CASE WHEN @Include & 2 = 2 THEN 1 ELSE 0 END
SELECT @IncludeCompleted = CASE WHEN @Include & 4 = 4 THEN 1 ELSE 0 END
	
--------------------------------------------------------------------------------------------------
    CREATE TABLE [dbo].[#Headers]
    (
		[TranKey]       [INT]  NOT NULL,
        [XferQty]       [pDecimal] NOT NULL,
        [PickQty]       [pDecimal] NOT NULL,
        [RcptQty]       [pDecimal] NOT NULL,
        [PickAmt]       [pDecimal] NOT NULL,
        [RcptAmt]       [pDecimal] NOT NULL,
        [AllocatedCost] [pDecimal] NOT NULL,
        [CompleteStatus] [BIT] NOT NULL,
        [CompleteQtys]   [BIT] NOT NULL
    )
--------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[#Headers]([TranKey],
                                 [XferQty],
                                 [PickQty],
                                 [RcptQty],
                                 [PickAmt],
                                 [RcptAmt],
                                 [AllocatedCost],
                                 [CompleteStatus],
                                 [CompleteQtys])
	     SELECT [xfer].[TranKey],
                ISNULL([xqty].[TtlQty], 0),
                ISNULL([pqty].[TtlQty], 0),
                ISNULL([rqty].[TtlQty], 0),
                ISNULL([pqty].[TtlAmt], 0),
                ISNULL([rqty].[TtlAmt], 0),
                CASE WHEN ([rqty].[TtlQty] = 0)
                     THEN 0
                     ELSE ISNULL(ROUND( ([xfer].[CostTransfer]/[rqty].[TtlQty]), @UnitCostPrecision), 0) END,
                CASE WHEN ([xfer].[Status] = 2)
                     THEN 1
                     ELSE 0 END,
                CASE WHEN ( ([pqty].[TtlQty] >= [xqty].[TtlQty] ) AND ([pqty].[TtlQty] = [rqty].[TtlQty] ) )
                     THEN 1
                     ELSE 0 END
	       FROM [dbo].[trav_tblWmTransfer_view] [xfer]
	 INNER JOIN [dbo].[#Filter] [fltr]
             ON ([fltr].[TranKey] = [xfer].[TranKey])
      LEFT JOIN (   SELECT [pick].[TranKey],
                           SUM(ROUND( ([pick].[Qty] * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision)) AS [TtlQty],
                           SUM (ROUND( ([pick].[Qty] * [pick].[UnitCost]), @CurrencyPrecision)) AS [TtlAmt]
                      FROM [dbo].[tblWmTransferPick] [pick]
                 LEFT JOIN [dbo].[tblInItemUom] [unit]
                        ON ([unit].[ItemId] =[pick].[ItemId])
			           AND ([unit].[Uom] = [pick].[UOM])
                  GROUP BY [pick].[TranKey]) pqty
             ON ([pqty].[TranKey] = [xfer].[TranKey])
      LEFT JOIN (   SELECT [pick].[TranKey],
                           SUM(ROUND( ([rcpt].[Qty] * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision)) AS [TtlQty],
                           SUM (ROUND( ([rcpt].[Qty] * [rcpt].[UnitCost]), @CurrencyPrecision)) AS [TtlAmt]
                      FROM [dbo].[tblWmTransferRcpt] [rcpt]
                 INNER JOIN [dbo].[tblWmTransferPick] [pick]
                         ON ([pick].[TranPickKey] = [rcpt].[TranPickKey])
                 LEFT JOIN [dbo].[tblInItemUom] [unit]
                        ON ([unit].[ItemId] =[rcpt].[ItemId])
			           AND ([unit].[Uom] = [rcpt].[UOM])
                  GROUP BY [pick].[TranKey]) rqty
             ON ([rqty].[TranKey] = [xfer].[TranKey])
      LEFT JOIN (   SELECT [xfer].[TranKey],
                           ROUND( ([xfer].[Qty] * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision) AS [TtlQty]
                      FROM [dbo].[trav_tblWmTransfer_view] [xfer]
                 LEFT JOIN [dbo].[tblInItemUom] [unit]
                        ON ([unit].[ItemId] =[xfer].[ItemId])
			           AND ([unit].[Uom] = [xfer].[UOM])) xqty
             ON ([xqty].[TranKey] = [xfer].[TranKey])
--------------------------------------------------------------------------------------------------
	CREATE TABLE [dbo].[#Transfers]
	(
		[TranKey]      [INT]      NOT NULL,
		[FiscalPeriod] [SMALLINT]     NULL,
		[FiscalYear]   [SMALLINT]     NULL,
		[SerNum]       [pSerNum]      NULL,
		[LotNum]       [pLotNum]      NULL,
		[ExtLocA]      [INT]          NULL,
		[ExtLocB]      [INT]          NULL,
		[TranPickKey]  [INT]          NULL,
		[TransType]    [TINYINT]  NOT NULL, -- 0 = Pick, 1 = Receipt, 2 = completed, 3 = New
		[TransDate]    [DATETIME]     NULL,
		[BaseQty]      [pDecimal]         NULL,
		[ExtCost]      [pDecimal]         NULL,
        [Completed]    [BIT]      NOT NULL,
        [New] bit NOT NULL, 
        [Partial] bit NOT NULL
	)
--------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[#Transfers]([TranKey],
								   [FiscalPeriod],
								   [FiscalYear],
								   [SerNum],
								   [LotNum],
								   [ExtLocA],
								   [ExtLocB],
								   [TranPickKey],
								   [TransType],
								   [TransDate],
								   [BaseQty],
								   [ExtCost],
                                   [Completed],
                                   [New],
                                   [Partial])
	     SELECT [xfer].[TranKey],
			    [pick].[GlPeriod],
			    [pick].[GlYear],
 			    [pick].[SerNum],
 			    [pick].[LotNum],
 			    [pick].[ExtLocA],
 			    [pick].[ExtLocB],
 			    [pick].[TranPickKey],
 			    0,
			    [pick].[TransDate],
                ROUND( ([pick].[Qty] * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision),
                ROUND( ([pick].[Qty] * [pick].[UnitCost]), @CurrencyPrecision),
                CASE WHEN ( ([hdrs].[CompleteStatus] = 1) OR ([hdrs].[CompleteQtys] = 1) )
                     THEN 1
                     ELSE 0 END, 
                0 AS New, 
                CASE WHEN (([hdrs].[CompleteStatus] = 1) OR ([hdrs].[CompleteQtys] = 1)) 
                     THEN 0 
                     ELSE 1 END AS [Partial] 
	       FROM [dbo].[trav_tblWmTransfer_view] [xfer]
	 INNER JOIN [dbo].[#Filter] [fltr]
             ON [fltr].[TranKey] = [xfer].[TranKey]
     INNER JOIN [dbo].[#Headers] hdrs
             ON ([hdrs].[TranKey] = [xfer].[TranKey])
     INNER JOIN [dbo].[tblWmTransferPick] [pick]
             ON [pick].[TranKey] = [xfer].[TranKey]
      LEFT JOIN [dbo].[tblInItemUom] [unit]
             ON [unit].[ItemId] =[pick].[ItemId]
			AND [unit].[Uom] = [pick].[UOM]
          WHERE ([pick].[Status] = 0)
--------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[#Transfers]([TranKey],
								   [FiscalPeriod],
								   [FiscalYear],
								   [SerNum],
								   [LotNum],
								   [ExtLocA],
								   [ExtLocB],
								   [TranPickKey],
								   [TransType],
								   [TransDate],
								   [BaseQty],
								   [ExtCost],
                                   [Completed],
                                   [New],
                                   [Partial])
                                   
	     SELECT [xfer].[TranKey],
			    [rcpt].[GlPeriod],
			    [rcpt].[GlYear],
 			    [rcpt].[SerNum],
 			    [rcpt].[LotNum],
 			    [rcpt].[ExtLocA],
 			    [rcpt].[ExtLocB],
 			    [pick].[TranPickKey],
 			    1,
			    [rcpt].[TransDate],
                ROUND( ([rcpt].[Qty] * ISNULL([unit].[ConvFactor], 1) ), @QuantityPrecision),
                CASE WHEN ( ([hdrs].[CompleteStatus] <> 1) AND ([hdrs].[CompleteQtys] = 1) )
                     THEN ROUND( ([rcpt].[Qty] * ([rcpt].[UnitCost]+ [hdrs].[AllocatedCost])), @CurrencyPrecision) 
                     ELSE ROUND( ([rcpt].[Qty] * [rcpt].[UnitCost]), @CurrencyPrecision) END,
                CASE WHEN ( ([hdrs].[CompleteStatus] = 1) OR ([hdrs].[CompleteQtys] = 1) )
                     THEN 1
                     ELSE 0 END, 
                0 AS New, 
                CASE WHEN (([hdrs].[CompleteStatus] = 1) OR ([hdrs].[CompleteQtys] = 1)) 
                     THEN 0 
                     ELSE 1 END AS [Partial] 
	       FROM [dbo].[trav_tblWmTransfer_view] [xfer]
	 INNER JOIN [dbo].[#Filter] [fltr]
             ON [fltr].[TranKey] = [xfer].[TranKey]
     INNER JOIN [dbo].[#Headers] hdrs
             ON ([hdrs].[TranKey] = [xfer].[TranKey])
     INNER JOIN [dbo].[tblWmTransferPick] [pick]
             ON [pick].[TranKey] = [xfer].[TranKey]
     INNER JOIN [dbo].[tblWmTransferRcpt] [rcpt]
             ON [rcpt].[TranPickKey] = [pick].[TranPickKey]
      LEFT JOIN [dbo].[tblInItemUom] [unit]
             ON [unit].[ItemId] =[rcpt].[ItemId]
			AND [unit].[Uom] = [rcpt].[UOM]
          WHERE ([rcpt].[Status] = 0)
--------------------------------------------------------------------------------------------------
	INSERT INTO [dbo].[#Transfers]([TranKey],
								   [FiscalPeriod],
								   [FiscalYear],
								   [SerNum],
								   [LotNum],
								   [ExtLocA],
								   [ExtLocB],
								   [TranPickKey],
								   [TransType],
								   [TransDate],
								   [BaseQty],
								   [ExtCost],
                                   [Completed],
                                   [New],
                                   [Partial])
	     SELECT [hdrs].[TranKey],
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                2,
                NULL,
                NULL,
                NULL,
                1, 
                0 AS New, 
                0 AS [Partial] 
           FROM [dbo].[#Headers] hdrs
          WHERE ([hdrs].[CompleteStatus] = 1)
             OR ([hdrs].[CompleteQtys] = 1)

	IF @IncludeNew = 1
	BEGIN
		INSERT INTO [dbo].[#Transfers]([TranKey], [TransType], [Completed], [New], [Partial]) 
		SELECT #Headers.TranKey, 3 AS TransType, 0 AS Completed, 1 AS New, 0 AS [Partial] 
		FROM #Headers LEFT JOIN #Transfers ON #Headers.TranKey = #Transfers.TranKey 
		WHERE #Transfers.TranKey IS NULL
	END
--------------------------------------------------------------------------------------------------
        SELECT [xfer].[TranKey],
			   [xfer].[Status],
               [xfer].[BatchID],
               [xfer].[TransDate] AS [EntryDate],
               [xfer].[ItemId],
               [xfer].[LocId],
               [xfer].[LocIdTo],
               [xfer].[Qty] AS [HdrQty],
               [xfer].[UOM],
               CASE WHEN ([temp].[Completed] = 1)
                    THEN [xfer].[CostTransfer]
                    ELSE 0 END AS [CostTransfer],
               CASE WHEN ([temp].[Completed] = 1)
                    THEN ([xfer].[CostTransfer] + [hdrs].[PickAmt] - [hdrs].[RcptAmt])
                    ELSE 0 END AS [Adjustment],
               [xfer].[Cmnt],
               [temp].[TransType],
               [temp].[TransDate],
               [temp].[FiscalPeriod],
               [temp].[FiscalYear],
               [temp].[ExtCost],
               [temp].[SerNum],
               [temp].[LotNum],
               [hdrs].[PickAmt] AS [TotalExtCostFrom],
               CASE WHEN ( ([hdrs].[CompleteStatus] <> 1) AND ([hdrs].[CompleteQtys] = 1) )
                    THEN ([hdrs].[RcptAmt] + [xfer].[CostTransfer])
                    ELSE [hdrs].[RcptAmt] END AS [TotalExtCostTo],
               [item].[Descr],
               [item].[ItemType],
               [item].[LottedYN],
               [locA].[ExtLocID] AS [ExtLocAID],
               [locB].[ExtLocID] AS [ExtLocBID],
               [temp].[BaseQty] AS [DtlQty]
          FROM [dbo].[trav_tblWmTransfer_view] [xfer] 
	INNER JOIN [dbo].[#Transfers] [temp] 
            ON [temp].[TranKey] = [xfer].[TranKey]
	INNER JOIN [dbo].[#Headers] [hdrs] 
            ON [hdrs].[TranKey] = [xfer].[TranKey]
     LEFT JOIN [dbo].[tblInItem] [item] 
            ON [item].[ItemId] = [xfer].[ItemId]
     LEFT JOIN [dbo].[tblWmExtLoc] [locA] 
            ON [locA].[Id] = [temp].[ExtLocA]
           AND [locA].[Type] = 0
     LEFT JOIN [dbo].[tblWmExtLoc] [locB] 
            ON [locB].[Id] = [temp].[ExtLocB]
           AND [locB].[Type] = 1 
	WHERE ([temp].Completed = 1 AND @IncludeCompleted = 1) 
		OR ([temp].[Partial] = 1 AND @IncludePartial = 1) 
		OR [temp].New = 1
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMLocationTransfersJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMLocationTransfersJournal_proc';

