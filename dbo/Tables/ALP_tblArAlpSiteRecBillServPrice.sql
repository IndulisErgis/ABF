CREATE TABLE [dbo].[ALP_tblArAlpSiteRecBillServPrice] (
    [RecBillServPriceId] INT          IDENTITY (1, 1) NOT NULL,
    [RecBillServId]      INT          NOT NULL,
    [StartBillDate]      DATETIME     NULL,
    [EndBillDate]        DATETIME     NULL,
    [Price]              [dbo].[pDec] CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServPrice_Price] DEFAULT ((0)) NOT NULL,
    [UnitCost]           [dbo].[pDec] CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServPrice_UnitCost] DEFAULT ((0)) NOT NULL,
    [RMR]                [dbo].[pDec] CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServPrice_RMR] DEFAULT ((0)) NOT NULL,
    [RMRChange]          [dbo].[pDec] CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServPrice_RMRChange] DEFAULT ((0)) NOT NULL,
    [Reason]             TINYINT      NULL,
    [JobOrdNum]          VARCHAR (12) NULL,
    [ActiveYn]           BIT          CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServPrice_ActiveYn] DEFAULT ((0)) NOT NULL,
    [ts]                 ROWVERSION   NULL,
    [PriceLockedYn]      BIT          CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServPrice_PriceLockedYn] DEFAULT ((0)) NOT NULL,
    [ModifiedBy]         VARCHAR (50) NULL,
    [ModifiedDate]       DATETIME     NULL,
    CONSTRAINT [PK_tblArAlpSiteRecBillServPrice] PRIMARY KEY CLUSTERED ([RecBillServPriceId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_tblArAlpSiteRecBillServPrice_tblArAlpSiteRecBillServ] FOREIGN KEY ([RecBillServId]) REFERENCES [dbo].[ALP_tblArAlpSiteRecBillServ] ([RecBillServId]) NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[ALP_tblArAlpSiteRecBillServPrice] NOCHECK CONSTRAINT [FK_tblArAlpSiteRecBillServPrice_tblArAlpSiteRecBillServ];


GO
CREATE NONCLUSTERED INDEX [ALP_tblArAlpSiteRecBillServPrice_ServId]
    ON [dbo].[ALP_tblArAlpSiteRecBillServPrice]([RecBillServId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBillServPrice] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBillServPrice] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBillServPrice] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBillServPrice] TO PUBLIC
    AS [dbo];

