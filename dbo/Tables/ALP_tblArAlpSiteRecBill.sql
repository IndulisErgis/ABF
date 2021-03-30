CREATE TABLE [dbo].[ALP_tblArAlpSiteRecBill] (
    [RecBillId]                  INT                 IDENTITY (1, 1) NOT NULL,
    [CustId]                     VARCHAR (10)        NULL,
    [SiteId]                     INT                 NULL,
    [ContractID]                 INT                 NULL,
    [RecBillNum]                 VARCHAR (255)       NULL,
    [ItemId]                     VARCHAR (24)        NULL,
    [Desc]                       VARCHAR (35)        NULL,
    [LocID]                      VARCHAR (10)        NULL,
    [AddnlDesc]                  TEXT                NULL,
    [AcctCode]                   [dbo].[pGLAcctCode] NULL,
    [GLAcctSales]                VARCHAR (40)        NULL,
    [GLAcctCOGS]                 VARCHAR (40)        NULL,
    [GLAcctInv]                  VARCHAR (40)        NULL,
    [TaxClass]                   TINYINT             NULL,
    [CatId]                      VARCHAR (2)         NULL,
    [CustPONum]                  VARCHAR (50)        NULL,
    [CustPODate]                 DATETIME            NULL,
    [NextBillDate]               DATETIME            NULL,
    [BillCycleId]                INT                 NULL,
    [MailSiteYN]                 BIT                 CONSTRAINT [DF_ALP_tblArAlpSiteRecBill_MailSiteYN] DEFAULT ((0)) NULL,
    [TaxTotal]                   [dbo].[pDec]        NULL,
    [NonTaxTotal]                [dbo].[pDec]        NULL,
    [SalesTaxTotal]              [dbo].[pDec]        NULL,
    [TaxTotalFgn]                [dbo].[pDec]        NULL,
    [NonTaxTotalFgn]             [dbo].[pDec]        NULL,
    [SalesTaxTotalFgn]           [dbo].[pDec]        NULL,
    [CostTotal]                  [dbo].[pDec]        NULL,
    [TaxAmtAdj]                  FLOAT (53)          NULL,
    [TaxAdj]                     TINYINT             NULL,
    [TaxLocAdj]                  VARCHAR (10)        NULL,
    [TaxClassAdj]                TINYINT             NULL,
    [ActivePrice]                [dbo].[pDec]        NULL,
    [ActiveCost]                 [dbo].[pDec]        NULL,
    [ActiveRMR]                  [dbo].[pDec]        NULL,
    [CreateDate]                 DATETIME            NULL,
    [LastUpdateDate]             DATETIME            NULL,
    [UploadDate]                 DATETIME            NULL,
    [ts]                         ROWVERSION          NULL,
    [ModifiedBy]                 VARCHAR (50)        NULL,
    [ModifiedDate]               DATETIME            NULL,
    [UseInvcConsolidationSiteYn] BIT                 CONSTRAINT [DF_ALP_tblArAlpSiteRecBill_UseInvcConsolidationSiteYn] DEFAULT ((0)) NULL,
    [InvcConsolidationSiteId]    INT                 NULL,
    CONSTRAINT [PK_tblArAlpSiteRecBill] PRIMARY KEY CLUSTERED ([RecBillId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_tblArAlpSiteRecBill_tblArAlpSite] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[ALP_tblArAlpSite] ([SiteId]) NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[ALP_tblArAlpSiteRecBill] NOCHECK CONSTRAINT [FK_tblArAlpSiteRecBill_tblArAlpSite];


GO
CREATE NONCLUSTERED INDEX [ALP_tblArAlpSiteRecBill_CustId]
    ON [dbo].[ALP_tblArAlpSiteRecBill]([CustId] ASC);


GO
CREATE NONCLUSTERED INDEX [ALP_tblArAlpSiteRecBill_SiteId]
    ON [dbo].[ALP_tblArAlpSiteRecBill]([SiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [ALP_tblArAlpSiteRecBill_CustIdAndSiteId]
    ON [dbo].[ALP_tblArAlpSiteRecBill]([CustId] ASC, [SiteId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBill] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBill] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBill] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecBill] TO PUBLIC
    AS [dbo];

