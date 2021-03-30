CREATE TABLE [dbo].[tblMpGLTrans] (
    [EntryNum]        INT              IDENTITY (1, 1) NOT NULL,
    [EntryDate]       DATETIME         DEFAULT (getdate()) NULL,
    [OrderNo]         [dbo].[pTransID] NOT NULL,
    [ReleaseNo]       INT              NOT NULL,
    [ReqID]           INT              NOT NULL,
    [SeqNo]           INT              NOT NULL,
    [TransId]         INT              NOT NULL,
    [Source]          VARCHAR (2)      NOT NULL,
    [GLAccountDebit]  [dbo].[pGlAcct]  NULL,
    [GLAccountCredit] [dbo].[pGlAcct]  NULL,
    [Amount]          [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PostedYN]        BIT              DEFAULT ((0)) NOT NULL,
    [GlPeriod]        SMALLINT         DEFAULT ((0)) NOT NULL,
    [FiscalYear]      SMALLINT         DEFAULT ((0)) NOT NULL,
    [ts]              ROWVERSION       NULL,
    [CF]              XML              NULL,
    [TransDate]       DATETIME         CONSTRAINT [DF_tblMpGLTrans_TransDate] DEFAULT (getdate()) NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMpGLTrans_TransIdSeqNo]
    ON [dbo].[tblMpGLTrans]([TransId] ASC, [SeqNo] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblMpGLTrans_OrderReleaseReqIdSeqNo]
    ON [dbo].[tblMpGLTrans]([OrderNo] ASC, [ReleaseNo] ASC, [ReqID] ASC, [SeqNo] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpGLTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpGLTrans';

