CREATE TABLE [dbo].[tblSoItemLocPrice] (
    [ItemId]          [dbo].[pItemID] NOT NULL,
    [LocId]           [dbo].[pLocID]  NOT NULL,
    [CustLevel]       VARCHAR (10)    NOT NULL,
    [Descr]           VARCHAR (35)    NULL,
    [PriceAdjBase]    TINYINT         CONSTRAINT [DF__tblSoItem__Price__3AF08B85] DEFAULT (0) NULL,
    [PriceAdjType]    TINYINT         CONSTRAINT [DF__tblSoItem__Price__3BE4AFBE] DEFAULT (0) NULL,
    [PriceAdjAmt]     [dbo].[pDec]    CONSTRAINT [DF_tblSoItemLocPrice_PriceAdjAmt] DEFAULT (0) NULL,
    [PriceAdjPromoYn] BIT             CONSTRAINT [DF__tblSoItem__Price__3DCCF830] DEFAULT (0) NULL,
    [ts]              ROWVERSION      NULL,
    [CF]              XML             NULL,
    [ID]              BIGINT          NOT NULL,
    CONSTRAINT [PK__tblSoItemLocPric__39FC674C] PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC, [CustLevel] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSoItemLocPrice_ID]
    ON [dbo].[tblSoItemLocPrice]([ID] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoItemLocPrice] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoItemLocPrice] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoItemLocPrice] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoItemLocPrice] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoItemLocPrice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoItemLocPrice';

