CREATE TABLE [dbo].[tblPaTaxAuthorityHeader] (
    [Id]           INT           NOT NULL,
    [Type]         TINYINT       NOT NULL,
    [State]        NVARCHAR (2)  NULL,
    [Local]        NVARCHAR (2)  NULL,
    [TaxAuthority] AS            (case [Type] when (0) then 'FED' when (1) then [State] else [State]+[Local] end),
    [Description]  NVARCHAR (30) NULL,
    [CF]           XML           NULL,
    [ts]           ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaTaxAuthorityHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaTaxAuthorityHeader_TypeStateLocal]
    ON [dbo].[tblPaTaxAuthorityHeader]([Type] ASC, [State] ASC, [Local] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityHeader';

