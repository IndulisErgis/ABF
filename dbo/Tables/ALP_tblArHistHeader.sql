CREATE TABLE [dbo].[ALP_tblArHistHeader] (
    [AlpPostRun]          [dbo].[pPostRun] NOT NULL,
    [AlpTransId]          [dbo].[pTransID] NOT NULL,
    [AlpSiteID]           INT              NULL,
    [AlpMailSiteYn]       BIT              NULL,
    [AlpJobNum]           INT              NULL,
    [AlpRep1AmtYn]        BIT              NULL,
    [AlpRep2AmtYn]        BIT              NULL,
    [AlpFromJobYn]        BIT              NULL,
    [AlpSvcYn]            BIT              NULL,
    [AlpRecBillRef]       VARCHAR (9)      NULL,
    [AlpSendToPrintYn]    BIT              NULL,
    [AlpUploadDate]       DATETIME         NULL,
    [AlpJobNumRmr]        INT              NULL,
    [AlpSubscriberInvcYn] BIT              NULL,
    [Alpts]               ROWVERSION       NULL,
    CONSTRAINT [PK_ALP_tblArHistHeader] PRIMARY KEY CLUSTERED ([AlpPostRun] ASC, [AlpTransId] ASC)
);

