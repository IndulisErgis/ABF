CREATE TABLE [dbo].[tblSoPendingOrder] (
    [ID]          BIGINT               NOT NULL,
    [CustId]      [dbo].[pCustID]      NOT NULL,
    [ItemId]      [dbo].[pItemID]      NULL,
    [Description] [dbo].[pDescription] NULL,
    [LocId]       [dbo].[pLocID]       NULL,
    [Quantity]    [dbo].[pDecimal]     NOT NULL,
    [Uom]         [dbo].[pUom]         NULL,
    [UnitPrice]   [dbo].[pDecimal]     NOT NULL,
    [AddnlDescr]  NVARCHAR (MAX)       NULL,
    [UserName]    NVARCHAR (25)        NOT NULL,
    [EntryDate]   DATETIME             NULL,
    [CF]          XML                  NULL,
    [ts]          ROWVERSION           NULL,
    CONSTRAINT [PK_tblSoPendingOrder] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [UX_tblSoPendingOrder_CustIdUserName]
    ON [dbo].[tblSoPendingOrder]([CustId] ASC, [UserName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPendingOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPendingOrder';

