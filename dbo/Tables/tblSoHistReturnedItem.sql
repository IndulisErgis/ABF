CREATE TABLE [dbo].[tblSoHistReturnedItem] (
    [Counter]      INT                 IDENTITY (1, 1) NOT NULL,
    [PostRun]      [dbo].[pPostRun]    NOT NULL,
    [PostDate]     DATETIME            NULL,
    [GlPeriod]     SMALLINT            CONSTRAINT [DF_tblSoHistReturnedItem_GlPeriod] DEFAULT ((0)) NOT NULL,
    [FiscalYear]   SMALLINT            CONSTRAINT [DF_tblSoHistReturnedItem_FiscalYear] DEFAULT ((0)) NOT NULL,
    [Status]       TINYINT             CONSTRAINT [DF_tblSoHistReturnedItem_Status] DEFAULT ((1)) NOT NULL,
    [ResCode]      VARCHAR (10)        NULL,
    [ResCodeDescr] VARCHAR (35)        NULL,
    [RMANumber]    [dbo].[pInvoiceNum] NULL,
    [CustId]       [dbo].[pCustID]     NULL,
    [TransId]      [dbo].[pTransID]    NULL,
    [EntryNum]     INT                 NULL,
    [ItemId]       [dbo].[pItemID]     NULL,
    [ItemDescr]    VARCHAR (35)        NULL,
    [LocId]        [dbo].[pLocID]      NULL,
    [ExtLocA]      INT                 NULL,
    [ExtLocAId]    VARCHAR (10)        NULL,
    [ExtLocB]      INT                 NULL,
    [ExtLocBId]    VARCHAR (10)        NULL,
    [EntryDate]    DATETIME            NULL,
    [TransDate]    DATETIME            NULL,
    [Units]        [dbo].[pUom]        NULL,
    [QtyReturn]    [dbo].[pDec]        CONSTRAINT [DF_tblSoHistReturnedItem_QtyReturn] DEFAULT ((0)) NOT NULL,
    [LotNum]       [dbo].[pLotNum]     NULL,
    [SerNum]       [dbo].[pSerNum]     NULL,
    [UnitCost]     [dbo].[pDec]        CONSTRAINT [DF_tblSoHistReturnedItem_UnitCost] DEFAULT ((0)) NOT NULL,
    [CostExt]      [dbo].[pDec]        CONSTRAINT [DF_tblSoHistReturnedItem_CostExt] DEFAULT ((0)) NOT NULL,
    [UnitPrice]    [dbo].[pDec]        CONSTRAINT [DF_tblSoHistReturnedItem_UnitPrice] DEFAULT ((0)) NOT NULL,
    [PriceExt]     [dbo].[pDec]        CONSTRAINT [DF_tblSoHistReturnedItem_PriceExt] DEFAULT ((0)) NOT NULL,
    [GLAcctCOGS]   [dbo].[pGlAcct]     NULL,
    [GLAcctInv]    [dbo].[pGlAcct]     NULL,
    [Notes]        TEXT                NULL,
    [CF]           XML                 NULL,
    [ReturnID]     INT                 NOT NULL,
    CONSTRAINT [PK_tblSoHistReturnedItem] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoHistReturnedItem';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoHistReturnedItem';

