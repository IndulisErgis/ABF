CREATE TABLE [dbo].[tblSvHistoryWorkOrder] (
    [ID]                BIGINT            NOT NULL,
    [PostRun]           [dbo].[pPostRun]  NOT NULL,
    [WorkOrderNo]       [dbo].[pTransID]  NOT NULL,
    [OrderDate]         DATETIME          NOT NULL,
    [CustID]            [dbo].[pCustID]   NULL,
    [SiteID]            [dbo].[pLocID]    NULL,
    [Attention]         NVARCHAR (30)     NULL,
    [Address1]          NVARCHAR (30)     NULL,
    [Address2]          NVARCHAR (60)     NULL,
    [City]              NVARCHAR (30)     NULL,
    [Region]            NVARCHAR (10)     NULL,
    [Country]           [dbo].[pCountry]  NULL,
    [PostalCode]        NVARCHAR (10)     NULL,
    [TerrId]            NVARCHAR (10)     NULL,
    [Phone1]            NVARCHAR (15)     NULL,
    [Phone2]            NVARCHAR (15)     NULL,
    [Phone3]            NVARCHAR (15)     NULL,
    [Email]             NVARCHAR (255)    NULL,
    [Internet]          NVARCHAR (255)    NULL,
    [Rep1Id]            [dbo].[pSalesRep] NULL,
    [Rep1Pct]           [dbo].[pDec]      NOT NULL,
    [Rep2Id]            [dbo].[pSalesRep] NULL,
    [Rep2Pct]           [dbo].[pDec]      NOT NULL,
    [Rep1CommRate]      [dbo].[pDec]      NOT NULL,
    [Rep2CommRate]      [dbo].[pDec]      NOT NULL,
    [BillingType]       NVARCHAR (10)     NULL,
    [BillableYN]        BIT               NOT NULL,
    [CustomerPoNumber]  NVARCHAR (25)     NULL,
    [PODate]            DATETIME          NULL,
    [OriginalWorkOrder] [dbo].[pTransID]  NULL,
    [BillByWorkOrder]   BIT               NOT NULL,
    [FixedPrice]        BIT               NOT NULL,
    [BillingFormat]     NVARCHAR (255)    NULL,
    [ProjectID]         NVARCHAR (10)     NULL,
    [PhaseID]           NVARCHAR (10)     NULL,
    [TaskID]            NVARCHAR (10)     NULL,
    [CF]                XML               NULL,
    [BillVia]           TINYINT           CONSTRAINT [DF_tblSvHistoryWorkOrder_BillVia] DEFAULT ((0)) NOT NULL,
    [ProjectCustID]     NVARCHAR (10)     NULL,
    [ZoneCode]          NVARCHAR (10)     NULL,
    [CategoryCode]      NVARCHAR (10)     NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrder';

