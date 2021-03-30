CREATE TABLE [dbo].[ALP_tblArTransHeader] (
    [AlpTransId]          [dbo].[pTransID] NOT NULL,
    [AlpSiteID]           INT              NULL,
    [AlpMailSiteYn]       BIT              NULL,
    [AlpJobNum]           INT              NULL,
    [AlpRep1AmtYn]        BIT              NULL,
    [AlpRep2AmtYn]        BIT              NULL,
    [AlpFromJobYN]        BIT              NULL,
    [AlpSvcYN]            BIT              NULL,
    [AlpRecBillRef]       VARCHAR (9)      NULL,
    [AlpSendToPrintYn]    BIT              NULL,
    [AlpUploadDate]       DATETIME         NULL,
    [AlpJobNumRmr]        INT              NULL,
    [AlpSubscriberInvcYN] BIT              NULL,
    [Alpts]               ROWVERSION       NULL,
    CONSTRAINT [PK_ALP_tblArTransHeader] PRIMARY KEY CLUSTERED ([AlpTransId] ASC)
);

