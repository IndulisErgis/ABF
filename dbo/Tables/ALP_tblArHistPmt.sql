CREATE TABLE [dbo].[ALP_tblArHistPmt] (
    [AlpCounter] INT        NOT NULL,
    [AlpSiteID]  INT        NULL,
    [AlpComment] TEXT       NULL,
    [Alpts]      ROWVERSION NULL,
    CONSTRAINT [PK_ALP_tblArHistPmt] PRIMARY KEY CLUSTERED ([AlpCounter] ASC)
);

