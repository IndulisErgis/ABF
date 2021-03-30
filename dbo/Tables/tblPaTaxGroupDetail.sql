CREATE TABLE [dbo].[tblPaTaxGroupDetail] (
    [ID]             BIGINT     NOT NULL,
    [HeaderID]       BIGINT     NOT NULL,
    [TaxAuthorityId] INT        NOT NULL,
    [CF]             XML        NULL,
    [ts]             ROWVERSION NULL,
    CONSTRAINT [PK_tblPaTaxGroupDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaTaxGroupDetail_HeaderIDTaxAuthorityId]
    ON [dbo].[tblPaTaxGroupDetail]([HeaderID] ASC, [TaxAuthorityId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxGroupDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxGroupDetail';

