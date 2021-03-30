CREATE TABLE [dbo].[ALP_tblCSsvcperbillingCode] (
    [CSsvcperBillCodeID] INT             IDENTITY (15, 1) NOT NULL,
    [ItemId]             [dbo].[pItemID] NULL,
    [CSSvcID]            INT             NULL,
    CONSTRAINT [PK_tblCSsvcperbillingCode] PRIMARY KEY NONCLUSTERED ([CSsvcperBillCodeID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_tblCSsvcperbillingCode_tblCSServices] FOREIGN KEY ([CSSvcID]) REFERENCES [dbo].[ALP_tblCSServices] ([CSSvcID])
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCSsvcperbillingCode]
    ON [dbo].[ALP_tblCSsvcperbillingCode]([ItemId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSsvcperbillingCode] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSsvcperbillingCode] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSsvcperbillingCode] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSsvcperbillingCode] TO PUBLIC
    AS [dbo];

