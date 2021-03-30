CREATE TABLE [dbo].[ALP_tblArOpenInvoice] (
    [AlpCounter]          INT                 NOT NULL,
    [AlpCustId]           [dbo].[pCustID]     NULL,
    [AlpInvcNum]          [dbo].[pInvoiceNum] NULL,
    [AlpSiteID]           INT                 NULL,
    [AlpMailSiteYn]       BIT                 NULL,
    [AlpPostRun]          [dbo].[pPostRun]    NULL,
    [AlpTransID]          [dbo].[pTransID]    NULL,
    [AlpSubscriberInvcYn] BIT                 NULL,
    [Alpts]               ROWVERSION          NULL,
    CONSTRAINT [PK_ALP_tblArOpenInvoice] PRIMARY KEY CLUSTERED ([AlpCounter] ASC)
);

