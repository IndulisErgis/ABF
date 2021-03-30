CREATE TABLE [dbo].[tblPaCheckHistWithhold] (
    [PostRun]             [dbo].[pPostRun] NOT NULL,
    [SequenceNumber]      INT              NULL,
    [InternalNumber]      INT              NULL,
    [TaxAuthority]        VARCHAR (4)      NULL,
    [WithholdingCode]     VARCHAR (3)      NULL,
    [Description]         VARCHAR (30)     NULL,
    [WithholdingAmount]   [dbo].[pDec]     NOT NULL,
    [WithholdingEarnings] [dbo].[pDec]     NOT NULL,
    [GrossEarnings]       [dbo].[pDec]     NOT NULL,
    [ts]                  ROWVERSION       NULL,
    [CF]                  XML              NULL,
    [Id]                  INT              NOT NULL,
    [CheckId]             INT              NOT NULL,
    [TaxAuthorityType]    TINYINT          NOT NULL,
    [State]               VARCHAR (2)      NULL,
    [Local]               VARCHAR (2)      NULL,
    [GLAcctLiability]     [dbo].[pGlAcct]  NULL,
    CONSTRAINT [PK_tblPaCheckHistWithhold] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckHistWithhold_PostRunCheckid]
    ON [dbo].[tblPaCheckHistWithhold]([PostRun] ASC, [CheckId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlWithholdingCode]
    ON [dbo].[tblPaCheckHistWithhold]([WithholdingCode] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaCheckHistWithhold] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaCheckHistWithhold] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaCheckHistWithhold] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaCheckHistWithhold] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistWithhold';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistWithhold';

