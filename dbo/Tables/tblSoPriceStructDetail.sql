CREATE TABLE [dbo].[tblSoPriceStructDetail] (
    [PriceId]      VARCHAR (10) NOT NULL,
    [CustLevel]    VARCHAR (10) NOT NULL,
    [Descr]        VARCHAR (35) NULL,
    [PriceAdjBase] TINYINT      CONSTRAINT [DF__tblSoPric__Price__7DB2731B] DEFAULT (0) NULL,
    [PriceAdjType] TINYINT      CONSTRAINT [DF__tblSoPric__Price__7EA69754] DEFAULT (0) NULL,
    [PriceAdjAmt]  [dbo].[pDec] CONSTRAINT [DF_tblSoPriceStructDetail_PriceAdjAmt] DEFAULT (0) NULL,
    [ts]           ROWVERSION   NULL,
    [CF]           XML          NULL,
    CONSTRAINT [PK__tblSoPriceStruct__7CBE4EE2] PRIMARY KEY CLUSTERED ([PriceId] ASC, [CustLevel] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoPriceStructDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoPriceStructDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoPriceStructDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoPriceStructDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPriceStructDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPriceStructDetail';

