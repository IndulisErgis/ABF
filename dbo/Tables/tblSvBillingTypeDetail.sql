CREATE TABLE [dbo].[tblSvBillingTypeDetail] (
    [ID]          BIGINT        NOT NULL,
    [BillingType] NVARCHAR (10) NOT NULL,
    [TransType]   TINYINT       NOT NULL,
    [BillableYN]  BIT           NOT NULL,
    [PriceID]     NVARCHAR (10) NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblSvBillingTypeDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSvBillingTypeDetail_BillingType_TransType]
    ON [dbo].[tblSvBillingTypeDetail]([BillingType] ASC, [TransType] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvBillingTypeDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvBillingTypeDetail';

