CREATE TABLE [dbo].[tblBrClearedTrans] (
    [Counter]         INT                  IDENTITY (1, 1) NOT NULL,
    [BankId]          [dbo].[pBankID]      NULL,
    [Descr]           [dbo].[pDescription] NULL,
    [Reference]       VARCHAR (15)         NULL,
    [SourceId]        VARCHAR (10)         NULL,
    [TransDate]       DATETIME             NULL,
    [TransType]       SMALLINT             NULL,
    [Amount]          [dbo].[pDec]         CONSTRAINT [DF_tblBrClearedTrans_Amount] DEFAULT ((0)) NULL,
    [VoidStopYn]      BIT                  NULL,
    [ClearedEntryNum] INT                  NULL,
    [ts]              ROWVERSION           NULL,
    CONSTRAINT [PK_tblBrClearedTrans] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrClearedTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrClearedTrans';

