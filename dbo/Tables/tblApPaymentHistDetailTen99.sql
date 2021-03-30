CREATE TABLE [dbo].[tblApPaymentHistDetailTen99] (
    [ID]       BIGINT       NOT NULL,
    [Ten99Amt] [dbo].[pDec] NOT NULL,
    [CF]       XML          NULL,
    CONSTRAINT [PK_tblApPaymentHistDetailTen99] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPaymentHistDetailTen99';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPaymentHistDetailTen99';

