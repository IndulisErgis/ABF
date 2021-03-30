CREATE TABLE [dbo].[tblSoItemLocPriceDetail] (
    [ID]       BIGINT        NOT NULL,
    [HeaderID] BIGINT        NOT NULL,
    [Uom]      [dbo].[pUom]  NOT NULL,
    [BrkId]    NVARCHAR (10) NOT NULL,
    [CF]       XML           NULL,
    [ts]       ROWVERSION    NULL,
    CONSTRAINT [PK_tblSoItemLocPriceDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSoItemLocPriceDetail_HeaderIDUom]
    ON [dbo].[tblSoItemLocPriceDetail]([HeaderID] ASC, [Uom] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoItemLocPriceDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoItemLocPriceDetail';

