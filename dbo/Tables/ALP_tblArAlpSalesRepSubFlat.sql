CREATE TABLE [dbo].[ALP_tblArAlpSalesRepSubFlat] (
    [SalesRepId] [dbo].[pSalesRep] NOT NULL,
    [FlatCommId] INT               NOT NULL,
    [Desc]       VARCHAR (20)      NULL,
    [Amount]     [dbo].[pDec]      NULL,
    CONSTRAINT [PK_tblArSalesRepSubFlat] PRIMARY KEY CLUSTERED ([SalesRepId] ASC, [FlatCommId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSalesRepSubFlat] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSalesRepSubFlat] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSalesRepSubFlat] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSalesRepSubFlat] TO PUBLIC
    AS [dbo];

