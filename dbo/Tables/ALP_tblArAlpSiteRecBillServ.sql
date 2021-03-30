CREATE TABLE [dbo].[ALP_tblArAlpSiteRecBillServ] (
    [RecBillServId]            INT                 IDENTITY (1, 1) NOT NULL,
    [RecBillId]                INT                 NULL,
    [Status]                   VARCHAR (10)        CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServ_Status] DEFAULT ('New') NULL,
    [ServiceID]                VARCHAR (24)        NULL,
    [Desc]                     VARCHAR (35)        NULL,
    [LocID]                    VARCHAR (10)        NULL,
    [ActivePrice]              [dbo].[pDec]        NULL,
    [ActiveCycleId]            INT                 NULL,
    [ActiveCost]               [dbo].[pDec]        NULL,
    [ActiveRMR]                [dbo].[pDec]        NULL,
    [AcctCode]                 [dbo].[pGLAcctCode] NULL,
    [GLAcctSales]              VARCHAR (40)        NULL,
    [GLAcctCOGS]               VARCHAR (40)        NULL,
    [GLAcctInv]                VARCHAR (40)        NULL,
    [DfltPrice]                [dbo].[pDec]        NULL,
    [DfltCost]                 [dbo].[pDec]        NULL,
    [ServiceType]              SMALLINT            NULL,
    [SysId]                    INT                 NULL,
    [ExtRepPlanId]             INT                 NULL,
    [ContractId]               INT                 NULL,
    [InitialTerm]              SMALLINT            NULL,
    [RenTerm]                  SMALLINT            NULL,
    [ServiceStartDate]         DATETIME            NULL,
    [BilledThruDate]           DATETIME            NULL,
    [FinalBillDate]            DATETIME            NULL,
    [AllowGlobalPriceChangeYN] BIT                 CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServ_AllowGlobalPriceChangeYN] DEFAULT ((0)) NOT NULL,
    [MinMths]                  SMALLINT            NULL,
    [NoChangePriorTo]          DATETIME            NULL,
    [AutoRenYN]                BIT                 CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServ_AutoRenYN] DEFAULT ((0)) NOT NULL,
    [NotifyYN]                 BIT                 CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServ_NotifyYN] DEFAULT ((0)) NOT NULL,
    [CanReasonId]              INT                 NULL,
    [CanComments]              TEXT                NULL,
    [CanReportDate]            DATETIME            NULL,
    [CanServEndDate]           DATETIME            NULL,
    [CanCustId]                VARCHAR (10)        NULL,
    [CanCustName]              VARCHAR (30)        NULL,
    [CanSiteName]              VARCHAR (80)        NULL,
    [CanCustFirstName]         VARCHAR (30)        NULL,
    [CanSiteFirstName]         VARCHAR (30)        NULL,
    [Processed]                BIT                 CONSTRAINT [DF_ALP_tblArAlpSiteRecBillServ_Processed] DEFAULT ((0)) NOT NULL,
    [ts]                       ROWVERSION          NULL,
    [ModifiedBy]               VARCHAR (50)        NULL,
    [ModifiedDate]             DATETIME            NULL,
    CONSTRAINT [PK_tblArAlpSiteRecBillServ] PRIMARY KEY CLUSTERED ([RecBillServId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_tblArAlpSiteRecBillServ_tblArAlpSiteRecBill] FOREIGN KEY ([RecBillId]) REFERENCES [dbo].[ALP_tblArAlpSiteRecBill] ([RecBillId]) NOT FOR REPLICATION,
    CONSTRAINT [FK_tblArAlpSiteRecBillServ_tblArAlpSiteSys] FOREIGN KEY ([SysId]) REFERENCES [dbo].[ALP_tblArAlpSiteSys] ([SysId]) NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[ALP_tblArAlpSiteRecBillServ] NOCHECK CONSTRAINT [FK_tblArAlpSiteRecBillServ_tblArAlpSiteRecBill];


GO
ALTER TABLE [dbo].[ALP_tblArAlpSiteRecBillServ] NOCHECK CONSTRAINT [FK_tblArAlpSiteRecBillServ_tblArAlpSiteSys];


GO
CREATE NONCLUSTERED INDEX [FK_RecBillID]
    ON [dbo].[ALP_tblArAlpSiteRecBillServ]([RecBillId] ASC);

