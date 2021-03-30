CREATE TABLE [dbo].[tblPsDistCode] (
    [ID]             BIGINT            NOT NULL,
    [DistCode]       [dbo].[pDistCode] NOT NULL,
    [GLAcctSales]    [dbo].[pGlAcct]   NOT NULL,
    [GLAcctCOGS]     [dbo].[pGlAcct]   NOT NULL,
    [GLAcctInv]      [dbo].[pGlAcct]   NOT NULL,
    [GLAcctDiscount] [dbo].[pGlAcct]   NOT NULL,
    [GLAcctCoupon]   [dbo].[pGlAcct]   NOT NULL,
    [GLAcctLayaway]  [dbo].[pGlAcct]   NOT NULL,
    [GLAcctRounding] [dbo].[pGlAcct]   NOT NULL,
    [CF]             XML               NULL,
    [ts]             ROWVERSION        NULL,
    CONSTRAINT [PK_tblPsDistCode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsDistCode_DistCode]
    ON [dbo].[tblPsDistCode]([DistCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsDistCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsDistCode';

