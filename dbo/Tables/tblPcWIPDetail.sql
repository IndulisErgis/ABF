CREATE TABLE [dbo].[tblPcWIPDetail] (
    [Id]            INT                  IDENTITY (1, 1) NOT NULL,
    [HeaderId]      INT                  NOT NULL,
    [ActivityId]    INT                  NOT NULL,
    [Description]   [dbo].[pDescription] NULL,
    [AddnlDesc]     NVARCHAR (MAX)       NULL,
    [QtyBill]       [dbo].[pDec]         CONSTRAINT [DF_tblPcWIPDetail_QtyBill] DEFAULT ((0)) NOT NULL,
    [ExtIncomeBill] [dbo].[pDec]         CONSTRAINT [DF_tblPcWIPDetail_ExtIncomeBill] DEFAULT ((0)) NOT NULL,
    [SelectYn]      BIT                  CONSTRAINT [DF_tblPcWIPDetail_SelectYn] DEFAULT ((1)) NOT NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL,
    [BatchId]       [dbo].[pBatchID]     NULL,
    [ExtCost]       [dbo].[pDec]         CONSTRAINT [DF_tblPcWIPDetail_ExtCost] DEFAULT ((0)) NOT NULL,
    [ResourceId]    NVARCHAR (24)        NULL,
    [LocId]         [dbo].[pLocID]       NULL,
    [Uom]           [dbo].[pUom]         NULL,
    [ExtIncome]     [dbo].[pDec]         CONSTRAINT [DF_tblPcWIPDetail_ExtIncome] DEFAULT ((0)) NOT NULL,
    [Qty]           [dbo].[pDec]         CONSTRAINT [DF_tblPcWIPDetail_Qty] DEFAULT ((0)) NOT NULL,
    [ActivityDate]  DATETIME             NULL,
    [Type]          TINYINT              NULL,
    [TaxClass]      TINYINT              CONSTRAINT [DF_tblPcWIPDetail_TaxClass] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblPcWIPDetail] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPcWIPDetail_BatchId]
    ON [dbo].[tblPcWIPDetail]([BatchId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlHeaderId]
    ON [dbo].[tblPcWIPDetail]([HeaderId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPDetail';

