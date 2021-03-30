CREATE TABLE [dbo].[tblSoPriceStructHeader] (
    [PriceId]     VARCHAR (10) NOT NULL,
    [Descr]       VARCHAR (35) NULL,
    [DfltAdjBase] TINYINT      CONSTRAINT [DF__tblSoPric__DfltA__02772838] DEFAULT (0) NULL,
    [DfltAdjType] TINYINT      CONSTRAINT [DF__tblSoPric__DfltA__036B4C71] DEFAULT (0) NULL,
    [DfltAdjAmt]  [dbo].[pDec] CONSTRAINT [DF_tblSoPriceStructHeader_DfltAdjAmt] DEFAULT (0) NULL,
    [ts]          ROWVERSION   NULL,
    [CF]          XML          NULL,
    CONSTRAINT [PK__tblSoPriceStruct__018303FF] PRIMARY KEY CLUSTERED ([PriceId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [sqlPriceId]
    ON [dbo].[tblSoPriceStructHeader]([PriceId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoPriceStructHeader] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoPriceStructHeader] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoPriceStructHeader] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoPriceStructHeader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPriceStructHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPriceStructHeader';

