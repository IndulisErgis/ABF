CREATE TABLE [dbo].[tblBmAcctCode] (
    [GLAcctCode]               [dbo].[pGLAcctCode] NOT NULL,
    [GLInventoryLabour]        [dbo].[pGlAcct]     NOT NULL,
    [GLInventoryAppliedLabour] [dbo].[pGlAcct]     NULL,
    [ts]                       ROWVERSION          NULL,
    [CF]                       XML                 NULL,
    CONSTRAINT [PK__tblBmAcctCode__0B287117] PRIMARY KEY CLUSTERED ([GLAcctCode] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmAcctCode] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmAcctCode] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmAcctCode] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmAcctCode] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmAcctCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmAcctCode';

