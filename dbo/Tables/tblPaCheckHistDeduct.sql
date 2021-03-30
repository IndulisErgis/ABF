CREATE TABLE [dbo].[tblPaCheckHistDeduct] (
    [PostRun]         [dbo].[pPostRun] NOT NULL,
    [SequenceNumber]  INT              NULL,
    [InternalNumber]  INT              NULL,
    [DeductionCode]   VARCHAR (3)      NULL,
    [Hours]           [dbo].[pDec]     NOT NULL,
    [Amount]          [dbo].[pDec]     NOT NULL,
    [ts]              ROWVERSION       NULL,
    [CF]              XML              NULL,
    [Id]              INT              NOT NULL,
    [CheckId]         INT              NOT NULL,
    [GLAcctLiability] [dbo].[pGlAcct]  NULL,
    CONSTRAINT [PK_tblPaCheckHistDeduct] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckHistDeduct_PostRunCheckid]
    ON [dbo].[tblPaCheckHistDeduct]([PostRun] ASC, [CheckId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlDeductionCode]
    ON [dbo].[tblPaCheckHistDeduct]([DeductionCode] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaCheckHistDeduct] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaCheckHistDeduct] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaCheckHistDeduct] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaCheckHistDeduct] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistDeduct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistDeduct';

