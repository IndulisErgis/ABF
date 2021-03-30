
CREATE PROCEDURE [dbo].[trav_MpWorkInProcessValuation_proc]

@GlAccountFrom    [pGlAcct] = NULL,
@GlAccountThru    [pGlAcct] = NULL,
@FiscalPeriodFrom SMALLINT,
@FiscalYearFrom   SMALLINT,
@FiscalPeriodThru SMALLINT,
@FiscalYearThru   SMALLINT,
@SortBy           TINYINT

AS

BEGIN TRY
    SET NOCOUNT ON
-------------------------------------------------------
    CREATE TABLE [#WorkInProcessValuation] (
        [Id]              INT,
	    [OrderNo]         [pTransID],
	    [ReleaseNo]       INT,
	    [ReqId]           INT,
	    [Type]            TINYINT,
	    [Description]     [pDescription],
	    [Source]          nvarchar(20),
	    [FiscalPeriod]    SMALLINT,
	    [GlAccount]       [pGlAcct],
	    [GlAccountDebit]  [pGlAcct],
	    [GlAccountCredit] [pGlAcct],
	    [UnpostedAmount]  [pDecimal]      DEFAULT(0),
	    [PostedAmount]    [pDecimal]      DEFAULT(0),
	    [TransDate]       DATETIME,
	    [CustId]          [pCustID]               NULL)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
    INSERT INTO [#WorkInProcessValuation]([Id],
                                          [OrderNo],
    	                                  [ReleaseNo],
                                          [ReqId], 
	                                      [Type],
	                                      [Description],
	                                      [Source], 
	                                      [FiscalPeriod], 
	                                      [GlAccount],
	                                      [GlAccountDebit], 
	                                      [GlAccountCredit], 
	                                      [UnpostedAmount],
    	                                  [PostedAmount],
	                                      [TransDate],
	                                      [CustId]) 
         SELECT [o].[Id],
                [o].[OrderNo],
                [o].[ReleaseNo],
                [r].[ReqId],
                [r].[Type],
                [r].[Description],
                [g].[Source], 
                [g].[GlPeriod] AS [FiscalPeriod],
                [g].[GlAccountCredit],
                '',
                [g].[GlAccountCredit],
                CASE WHEN ([g].[PostedYN] = 0) 
                     THEN [g].[Amount]
                     ELSE 0 END AS [UnpostedAmount],
                CASE WHEN ([g].[PostedYN] = 1)
                     THEN [g].[Amount]
                     ELSE 0 END AS [PostedAmount],
                ISNULL([m].[TransDate], [g].[EntryDate]) AS [Transdate],
                [o].[CustId] 
           FROM [dbo].[tblMpRequirements] [r] 
     INNER JOIN [dbo].[tblMpGlTrans] [g] 
             ON ([g].[TransId] = [r].[TransId]) 
     INNER JOIN [dbo].[trav_tblMpOrderReleases_view] [o]
             ON ([g].[OrderNo] = [o].[OrderNo])
            AND ([g].[ReleaseNo] = [o].[ReleaseNo])
      LEFT JOIN (      SELECT [TransId],
                              [SeqNo],
                              [TransDate]
                         FROM [dbo].[tblMpTimeDtl]
    			 UNION SELECT [TransId],
                              [SeqNo],
                              [TransDate]
                         FROM [dbo].[tblMpSubContractDtl]
    			 UNION SELECT [TransId],
                              [SeqNo],
                              [TransDate] 
                         FROM [dbo].[tblMpMatlDtl]) [m]
             ON ([m].[TransId] = [r].[TransId])
            AND ([m].[SeqNo] = [g].[SeqNo])
          WHERE ( (@GlAccountFrom IS NULL) OR ([g].[GlAccountCredit] >= @GlAccountFrom) )
            AND ( (@GlAccountThru IS NULL) OR ([g].[GlAccountCredit] <= @GlAccountThru) )
	        AND ( ([g].[FiscalYear] * 1000 + [g].[GlPeriod]) BETWEEN (@FiscalYearFrom * 1000 + @FiscalPeriodFrom) AND (@FiscalYearThru * 1000 + @FiscalPeriodThru) )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
    INSERT INTO [#WorkInProcessValuation]([Id],
                                          [OrderNo],
    	                                  [ReleaseNo],
                                          [ReqId], 
	                                      [Type],
	                                      [Description],
	                                      [Source], 
	                                      [FiscalPeriod], 
	                                      [GlAccount],
	                                      [GlAccountDebit], 
	                                      [GlAccountCredit], 
	                                      [UnpostedAmount],
    	                                  [PostedAmount],
	                                      [TransDate],
	                                      [CustId]) 
         SELECT [o].[Id],
                [o].[OrderNo],
                [o].[ReleaseNo],
                [r].[ReqId],
                [r].[Type],
                [r].[Description],
                [g].[Source], 
                [g].[GlPeriod] AS [FiscalPeriod],
                [g].[GlAccountDebit],
                [g].[GlAccountDebit],
                '',
                CASE WHEN ([g].[PostedYN] = 0) 
                     THEN [g].[Amount]
                     ELSE 0 END AS [UnpostedAmount],
                CASE WHEN ([g].[PostedYN] = 1)
                     THEN [g].[Amount]
                     ELSE 0 END AS [PostedAmount],
                ISNULL([m].[TransDate], [g].[EntryDate]) AS [Transdate],
                [o].[CustId] 
           FROM [dbo].[tblMpRequirements] [r] 
     INNER JOIN [dbo].[tblMpGlTrans] [g] 
             ON ([g].[TransId] = [r].[TransId]) 
     INNER JOIN [dbo].[trav_tblMpOrderReleases_view] [o]
             ON ([g].[OrderNo] = [o].[OrderNo])
            AND ([g].[ReleaseNo] = [o].[ReleaseNo])
      LEFT JOIN (      SELECT [TransId],
                              [SeqNo],
                              [TransDate]
                         FROM [dbo].[tblMpTimeDtl]
    			 UNION SELECT [TransId],
                              [SeqNo],
                              [TransDate]
                         FROM [dbo].[tblMpSubContractDtl]
    			 UNION SELECT [TransId],
                              [SeqNo],
                              [TransDate] 
                         FROM [dbo].[tblMpMatlDtl]) [m]
             ON ([m].[TransId] = [r].[TransId])
            AND ([m].[SeqNo] = [g].[SeqNo])
          WHERE ( (@GlAccountFrom IS NULL) OR ([g].[GlAccountDebit] >= @GlAccountFrom) )
            AND ( (@GlAccountThru IS NULL) OR ([g].[GlAccountDebit] <= @GlAccountThru) )
	        AND ( ([g].[FiscalYear] * 1000 + [g].[GlPeriod]) BETWEEN (@FiscalYearFrom * 1000 + @FiscalPeriodFrom) AND (@FiscalYearThru * 1000 + @FiscalPeriodThru) )
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
SELECT CASE @SortBy WHEN 0 
                    THEN CAST([GlAccount] AS nvarchar) 
		            ELSE CAST([OrderNo] AS nvarchar) END AS [GrpId1],
	   CASE @SortBy WHEN 0
                    THEN CAST([OrderNo] AS nvarchar) 
		            ELSE CAST(CASE [Source] WHEN  1 THEN 'Adjustment' 
		      	                            WHEN  2 THEN 'Machine' 
     			                            WHEN  3 THEN 'Labor' 
	     				                    WHEN  4 THEN 'Subcontracted' 
		     			                    WHEN  5 THEN 'Inventory' 
			     		                    WHEN  6 THEN 'Machine Overhead' 
				     	                    WHEN  7 THEN 'Labor Overhead' 
					                        WHEN  8 THEN 'Per Piece Overhead' 
					                        WHEN  9 THEN 'Order Overhead' 
					                        WHEN 10 THEN 'Labor Setup' 
					                                ELSE 'Finished Goods' END AS nvarchar) END AS [GrpId2],
	        [Type],
            [OrderNo],
            [ReleaseNo], 
            [ReqId],
	        CASE [Source] WHEN  1 THEN 'Adjustment'
                          WHEN  2 THEN 'Machine' 
  		                  WHEN  3 THEN 'Labor' 
                          WHEN  4 THEN 'Subcontracted'
                          WHEN  5 THEN 'Inventory' 
		                  WHEN  6 THEN 'Machine Overhead'
                          WHEN  7 THEN 'Labor Overhead' 
		                  WHEN  8 THEN 'Per Piece Overhead'
                          WHEN  9 THEN 'Order Overhead' 
		                  WHEN 10 THEN 'Labor Setup'
                                  ELSE 'Finished Goods' END AS [TransType],
	        [Description],
            [FiscalPeriod],
            [TransDate],
            CASE WHEN ([GlAccountDebit] <> '') 
                 THEN [UnpostedAmount] 
                 ELSE 0 END AS [UnpostedAmountDebit],
	        CASE WHEN ([GlAccountCredit] <> '')
                 THEN [UnpostedAmount]
                 ELSE 0 END AS [UnpostedAmountCredit],
	        CASE WHEN ([GlAccountDebit] <> '')
                 THEN [PostedAmount]
                 ELSE 0 END AS [PostedAmountDebit],
	        CASE WHEN ([GlAccountCredit] <> '')
                 THEN [PostedAmount]
                 ELSE 0 END AS [PostedAmountCredit],
	        [GlAccount]
       FROM [#WorkInProcessValuation] 
 INNER JOIN [#Filter]
         ON [#Filter].[ID] = [#WorkInProcessValuation].[Id]
   ORDER BY [GlAccount]
------------------------------------------------------------------------------------------------------------
DROP TABLE[#WorkInProcessValuation]

END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpWorkInProcessValuation_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpWorkInProcessValuation_proc';

