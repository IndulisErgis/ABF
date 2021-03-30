CREATE TABLE [dbo].[tblPsHistHeader] (
    [ID]                BIGINT            NOT NULL,
    [PostRun]           [dbo].[pPostRun]  NOT NULL,
    [TransIDPrefix]     NVARCHAR (7)      NOT NULL,
    [TransID]           INT               NOT NULL,
    [TransType]         SMALLINT          NOT NULL,
    [TransDate]         DATETIME          NOT NULL,
    [RewardNumber]      NVARCHAR (255)    NULL,
    [SoldToID]          [dbo].[pCustID]   NULL,
    [BillToID]          [dbo].[pCustID]   NULL,
    [ShipToID]          [dbo].[pCustID]   NULL,
    [ShipVia]           NVARCHAR (20)     NULL,
    [ShipNum]           NVARCHAR (30)     NULL,
    [TaxableYN]         BIT               NOT NULL,
    [TaxExemptID]       NVARCHAR (255)    NULL,
    [TaxGroupID]        [dbo].[pTaxLoc]   NOT NULL,
    [CurrencyID]        [dbo].[pCurrency] NOT NULL,
    [SalesRepID]        [dbo].[pSalesRep] NULL,
    [DueDate]           DATETIME          NULL,
    [VoidDate]          DATETIME          NULL,
    [CompletedDate]     DATETIME          NULL,
    [UserID]            BIGINT            NOT NULL,
    [HostID]            [dbo].[pWrkStnID] NOT NULL,
    [EntryDate]         DATETIME          NOT NULL,
    [SourceID]          UNIQUEIDENTIFIER  NOT NULL,
    [LocID]             [dbo].[pLocID]    NULL,
    [DistCode]          [dbo].[pDistCode] NULL,
    [GLAcctReceivables] [dbo].[pGlAcct]   NULL,
    [Notes]             NVARCHAR (MAX)    NULL,
    [CF]                XML               NULL,
    [PONumber]          NVARCHAR (25)     NULL,
    [PODate]            DATETIME          NULL,
    [ReqShipDate]       DATETIME          NULL,
    [iCap]              VARBINARY (MAX)   NULL,
    CONSTRAINT [PK_tblPsHistHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsHistHeader_RewardNumber]
    ON [dbo].[tblPsHistHeader]([RewardNumber] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsHistHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsHistHeader';

