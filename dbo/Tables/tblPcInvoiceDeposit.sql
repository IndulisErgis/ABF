CREATE TABLE [dbo].[tblPcInvoiceDeposit] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [TransId]         [dbo].[pTransID] NOT NULL,
    [ProjectDetailId] INT              NOT NULL,
    [DepositAmtAvail] [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceDeposit_DepositAmtAvail] DEFAULT ((0)) NOT NULL,
    [DepositAmtApply] [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceDeposit_DepositAmtApply] DEFAULT ((0)) NOT NULL,
    [ActivityId]      INT              NOT NULL,
    [CF]              XML              NULL,
    [ts]              ROWVERSION       NULL,
    CONSTRAINT [PK_tblPcInvoiceDeposit] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransId]
    ON [dbo].[tblPcInvoiceDeposit]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceDeposit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceDeposit';

