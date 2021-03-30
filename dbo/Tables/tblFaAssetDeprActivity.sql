CREATE TABLE [dbo].[tblFaAssetDeprActivity] (
    [ID]           INT              NOT NULL,
    [DeprID]       INT              NOT NULL,
    [TransType]    SMALLINT         NOT NULL,
    [EntryDate]    DATETIME         CONSTRAINT [DF_tblFaAssetDeprActivity_EntryDate] DEFAULT (getdate()) NULL,
    [TransDate]    DATETIME         CONSTRAINT [DF_tblFaAssetDeprActivity_TransDate] DEFAULT (getdate()) NOT NULL,
    [GLAccumDepr]  [dbo].[pGlAcct]  NULL,
    [GLExpense]    [dbo].[pGlAcct]  NULL,
    [Amount]       [dbo].[pDec]     CONSTRAINT [DF_tblFaAssetDeprActivity_Amount] DEFAULT ((0)) NOT NULL,
    [FiscalPeriod] SMALLINT         NOT NULL,
    [FiscalYear]   SMALLINT         NOT NULL,
    [PostRun]      [dbo].[pPostRun] NULL,
    [CF]           XML              NULL,
    [ts]           ROWVERSION       NULL,
    CONSTRAINT [PK_tblFaAssetDeprActivity] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblFaAssetDeprActivity_DeprID]
    ON [dbo].[tblFaAssetDeprActivity]([DeprID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAssetDeprActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAssetDeprActivity';

