CREATE TABLE [dbo].[tblPcDistCode] (
    [DistCode]              [dbo].[pDistCode] NOT NULL,
    [Description]           NVARCHAR (25)     NULL,
    [GLAcctWIP]             [dbo].[pGlAcct]   NOT NULL,
    [GLAcctPayrollClearing] [dbo].[pGlAcct]   NOT NULL,
    [GLAcctIncome]          [dbo].[pGlAcct]   NOT NULL,
    [GLAcctCost]            [dbo].[pGlAcct]   NOT NULL,
    [GLAcctAdjustments]     [dbo].[pGlAcct]   NOT NULL,
    [GLAcctFixedFeeBilling] [dbo].[pGlAcct]   NOT NULL,
    [GLAcctOverheadContra]  [dbo].[pGlAcct]   NOT NULL,
    [GLAcctAccruedIncome]   [dbo].[pGlAcct]   NOT NULL,
    [GLAcctAccrual]         [dbo].[pGlAcct]   NULL,
    [CF]                    XML               NULL,
    [ts]                    ROWVERSION        NULL,
    [GLAcctBillingExcess]   [dbo].[pGlAcct]   NULL,
    [GLAcctEarningExcess]   [dbo].[pGlAcct]   NULL,
    CONSTRAINT [PK_tblPcDistCode] PRIMARY KEY CLUSTERED ([DistCode] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcDistCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcDistCode';

