CREATE TABLE [dbo].[tblPcRevenueAdjust] (
    [ID]                    BIGINT            NOT NULL,
    [AdjustBatchID]         BIGINT            NOT NULL,
    [ProjectID]             INT               NOT NULL,
    [ProjectName]           NVARCHAR (10)     NOT NULL,
    [CustID]                [dbo].[pCustID]   NOT NULL,
    [CustName]              NVARCHAR (30)     NULL,
    [ProjectDescription]    NVARCHAR (30)     NULL,
    [DistCode]              NVARCHAR (6)      NOT NULL,
    [Rep1Id]                [dbo].[pSalesRep] NULL,
    [Rep2Id]                [dbo].[pSalesRep] NULL,
    [ProjectManager]        [dbo].[pEmpID]    NULL,
    [FixedFeeAmount]        [dbo].[pDecimal]  NOT NULL,
    [BilledAmount]          [dbo].[pDecimal]  NOT NULL,
    [EstimatedCost]         [dbo].[pDecimal]  NOT NULL,
    [EstimatedHour]         [dbo].[pDecimal]  NOT NULL,
    [PostedCost]            [dbo].[pDecimal]  NOT NULL,
    [PostedHour]            [dbo].[pDecimal]  NOT NULL,
    [PercentCostCompletion] [dbo].[pDecimal]  NULL,
    [PercentHourCompletion] [dbo].[pDecimal]  NULL,
    [OverridePercent]       [dbo].[pDecimal]  NULL,
    [EarnedIncome]          [dbo].[pDecimal]  NULL,
    [PostedAdjustAmount]    [dbo].[pDecimal]  NOT NULL,
    [NetAdjustAmount]       [dbo].[pDecimal]  NOT NULL,
    [GLAcctIncome]          [dbo].[pGlAcct]   NULL,
    [GLAcctBillingExcess]   [dbo].[pGlAcct]   NULL,
    [GLAcctEarningExcess]   [dbo].[pGlAcct]   NULL,
    [CF]                    XML               NULL,
    [ts]                    ROWVERSION        NULL,
    CONSTRAINT [PK_tblPcRevenueAdjust] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPcRevenueAdjust_ProjectID]
    ON [dbo].[tblPcRevenueAdjust]([ProjectID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcRevenueAdjust';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcRevenueAdjust';

