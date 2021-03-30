CREATE TABLE [dbo].[ALP_tblArCashRcptDetail] (
    [AlpRcptDetailID] INT        NOT NULL,
    [AlpSiteID]       INT        NULL,
    [AlpComment]      TEXT       NULL,
    [Alpts]           ROWVERSION NULL,
    CONSTRAINT [PK_ALP_tblArCashRcptDetail] PRIMARY KEY CLUSTERED ([AlpRcptDetailID] ASC)
);

