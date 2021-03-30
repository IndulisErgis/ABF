CREATE TABLE [dbo].[tblPsTransHeader] (
    [ID]            BIGINT            NOT NULL,
    [TransIDPrefix] NVARCHAR (7)      NOT NULL,
    [TransID]       INT               NOT NULL,
    [TransType]     SMALLINT          NOT NULL,
    [TransDate]     DATETIME          NOT NULL,
    [RewardNumber]  NVARCHAR (255)    NULL,
    [SoldToID]      [dbo].[pCustID]   NULL,
    [BillToID]      [dbo].[pCustID]   NULL,
    [ShipToID]      [dbo].[pCustID]   NULL,
    [ShipVia]       NVARCHAR (20)     NULL,
    [ShipNum]       NVARCHAR (30)     NULL,
    [TaxableYN]     BIT               CONSTRAINT [DF_tblPsTransHeader_TaxableYN] DEFAULT ((1)) NOT NULL,
    [TaxExemptID]   NVARCHAR (255)    NULL,
    [TaxGroupID]    [dbo].[pTaxLoc]   NOT NULL,
    [CurrencyID]    [dbo].[pCurrency] NOT NULL,
    [SalesRepID]    [dbo].[pSalesRep] NULL,
    [DueDate]       DATETIME          NULL,
    [VoidDate]      DATETIME          NULL,
    [SuspendDate]   DATETIME          NULL,
    [CompletedDate] DATETIME          NULL,
    [UserID]        BIGINT            NOT NULL,
    [HostID]        [dbo].[pWrkStnID] NOT NULL,
    [EntryDate]     DATETIME          NOT NULL,
    [Synched]       BIT               NOT NULL,
    [SourceID]      UNIQUEIDENTIFIER  NOT NULL,
    [Notes]         NVARCHAR (MAX)    NULL,
    [CF]            XML               NULL,
    [ts]            ROWVERSION        NULL,
    [SynchID]       BIGINT            NULL,
    [ConfigID]      BIGINT            NOT NULL,
    [PONumber]      NVARCHAR (25)     NULL,
    [PODate]        DATETIME          NULL,
    [ReqShipDate]   DATETIME          NULL,
    [iCap]          VARBINARY (MAX)   NULL,
    CONSTRAINT [PK_tblPsTransHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsTransHeader_ConfigID]
    ON [dbo].[tblPsTransHeader]([ConfigID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsTransHeader_SynchID]
    ON [dbo].[tblPsTransHeader]([SynchID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsTransHeader_RewardNumber]
    ON [dbo].[tblPsTransHeader]([RewardNumber] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsTransHeader_TransIDPrefixTransID]
    ON [dbo].[tblPsTransHeader]([TransIDPrefix] ASC, [TransID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsTransHeader_HostID]
    ON [dbo].[tblPsTransHeader]([HostID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransHeader';

