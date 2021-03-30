CREATE TABLE [dbo].[ALP_tblArAlpServRevDist] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [ForYear]     SMALLINT        NOT NULL,
    [ForPeriod]   SMALLINT        NOT NULL,
    [GLAccount]   [dbo].[pGlAcct] NOT NULL,
    [Amount]      [dbo].[pDec]    NOT NULL,
    [FromYear]    SMALLINT        NOT NULL,
    [FromPeriod]  SMALLINT        NOT NULL,
    [InvoiceDate] DATE            NOT NULL,
    [RunId]       INT             NOT NULL,
    [ts]          ROWVERSION      NOT NULL
);

