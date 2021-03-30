CREATE TABLE [dbo].[tblPaCheckHistEmplrTax] (
    [PostRun]             [dbo].[pPostRun] NOT NULL,
    [SequenceNumber]      INT              NULL,
    [InternalNumber]      INT              NULL,
    [DepartmentID]        [dbo].[pDeptID]  NULL,
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
    [GLAcctDept]          [dbo].[pGlAcct]  NULL,
    CONSTRAINT [PK_tblPaCheckHistEmplrTax] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckHistEmplrTax_PostRunCheckid]
    ON [dbo].[tblPaCheckHistEmplrTax]([PostRun] ASC, [CheckId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlWithholdingCode]
    ON [dbo].[tblPaCheckHistEmplrTax]([WithholdingCode] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaCheckHistEmplrTax] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaCheckHistEmplrTax] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaCheckHistEmplrTax] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaCheckHistEmplrTax] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistEmplrTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistEmplrTax';

