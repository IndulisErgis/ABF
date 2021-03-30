CREATE TABLE [dbo].[ALP_tblArAlpRecurTax] (
    [RecBillId]     INT          NOT NULL,
    [TaxLocID]      VARCHAR (10) NOT NULL,
    [TaxClass]      TINYINT      NULL,
    [Level]         TINYINT      NULL,
    [TaxAmt]        FLOAT (53)   NULL,
    [TaxAmtFgn]     FLOAT (53)   NULL,
    [Taxable]       FLOAT (53)   NULL,
    [TaxableFgn]    FLOAT (53)   NULL,
    [NonTaxable]    FLOAT (53)   NULL,
    [NonTaxableFgn] FLOAT (53)   NULL,
    [LiabilityAcct] VARCHAR (24) NULL,
    [ts]            ROWVERSION   NULL,
    CONSTRAINT [PK_tblArAlpRecurTax] PRIMARY KEY CLUSTERED ([RecBillId] ASC, [TaxLocID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpRecurTax] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpRecurTax] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpRecurTax] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpRecurTax] TO PUBLIC
    AS [dbo];

