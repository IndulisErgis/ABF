﻿CREATE TABLE [dbo].[ALP_tblArAlpSite] (
    [SiteId]                           INT               IDENTITY (1, 1) NOT NULL,
    [SiteName]                         VARCHAR (80)      NULL,
    [AlpFirstName]                     VARCHAR (30)      NULL,
    [AlpDear]                          VARCHAR (50)      NULL,
    [Status]                           VARCHAR (10)      NULL,
    [Attn]                             VARCHAR (30)      NULL,
    [Addr1]                            VARCHAR (40)      NULL,
    [Addr2]                            VARCHAR (60)      NULL,
    [City]                             VARCHAR (30)      NULL,
    [Region]                           VARCHAR (50)      NULL,
    [Country]                          VARCHAR (6)       NULL,
    [PostalCode]                       VARCHAR (10)      NULL,
    [IntlPrefix]                       VARCHAR (6)       NULL,
    [Phone]                            VARCHAR (15)      NULL,
    [Fax]                              VARCHAR (15)      NULL,
    [Email]                            TEXT              NULL,
    [CrossStreet]                      VARCHAR (255)     NULL,
    [MapId]                            VARCHAR (10)      NULL,
    [Directions]                       TEXT              NULL,
    [SubDivID]                         INT               NULL,
    [Block]                            VARCHAR (255)     NULL,
    [SiteMemo]                         TEXT              NULL,
    [SalesRepId1]                      [dbo].[pSalesRep] NULL,
    [Rep1PctInvc]                      NUMERIC (20, 10)  NULL,
    [SalesRepId2]                      [dbo].[pSalesRep] NULL,
    [Rep2PctInvc]                      NUMERIC (20, 10)  NULL,
    [TermsCode]                        VARCHAR (6)       NOT NULL,
    [DistCode]                         VARCHAR (6)       NOT NULL,
    [TaxLocId]                         VARCHAR (10)      NOT NULL,
    [Taxable]                          BIT               CONSTRAINT [DF_ALP_tblArAlpSite_Taxable] DEFAULT ((1)) NOT NULL,
    [CreditHoldYn]                     BIT               CONSTRAINT [DF_ALP_tblArAlpSite_CreditHoldYn] DEFAULT ((0)) NOT NULL,
    [BranchId]                         INT               NULL,
    [MarketId]                         INT               NULL,
    [LeadSourceId]                     INT               NULL,
    [ReferBy]                          VARCHAR (255)     NULL,
    [Referral Fee]                     NUMERIC (20, 10)  NULL,
    [PromoId]                          INT               NULL,
    [Structure]                        TINYINT           NULL,
    [Basement]                         TINYINT           NULL,
    [Attic]                            TINYINT           NULL,
    [SqFt]                             VARCHAR (50)      NULL,
    [InitialContactDate]               SMALLDATETIME     NULL,
    [PrefApptDate]                     SMALLDATETIME     NULL,
    [PrefApptTime]                     SMALLDATETIME     NULL,
    [DeadProspectYN]                   BIT               CONSTRAINT [DF_ALP_tblArAlpSite_DeadProspectYN] DEFAULT ((0)) NOT NULL,
    [FinSourceID]                      INT               NULL,
    [FinanceDate]                      SMALLDATETIME     NULL,
    [FinanceEnds]                      SMALLDATETIME     NULL,
    [Contact]                          VARCHAR (255)     NULL,
    [County]                           VARCHAR (50)      NULL,
    [OldSiteId]                        VARCHAR (50)      NULL,
    [OldBillId]                        VARCHAR (50)      NULL,
    [CreateDate]                       SMALLDATETIME     NULL,
    [LastUpdateDate]                   SMALLDATETIME     NULL,
    [UploadDate]                       SMALLDATETIME     NULL,
    [BundledYn]                        BIT               CONSTRAINT [DF_ALP_tblArAlpSite_BundledYn] DEFAULT ((0)) NOT NULL,
    [RecurTaxLocId]                    VARCHAR (10)      NULL,
    [DealerSiteYn]                     BIT               CONSTRAINT [DF_ALP_tblArAlpSite_DealerSiteYn] DEFAULT ((0)) NOT NULL,
    [WDBTemplateYN]                    BIT               CONSTRAINT [DF_ALP_tblArAlpSite_WDBTemplateYN] DEFAULT ((0)) NOT NULL,
    [ts]                               ROWVERSION        NULL,
    [TaxExemptID]                      VARCHAR (20)      NULL,
    [ModifiedBy]                       VARCHAR (50)      NULL,
    [ModifiedDate]                     DATETIME          NULL,
    [DisplayRmrInvoiceLineItemByMonth] BIT               CONSTRAINT [DF_ALP_tblArAlpSite_DisplayRmrInvoiceLineItemByMonth] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblArAlpSite] PRIMARY KEY CLUSTERED ([SiteId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSite] TO PUBLIC
    AS [dbo];
