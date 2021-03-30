CREATE TABLE [dbo].[tblPsConfig] (
    [ID]                BIGINT               NOT NULL,
    [HostID]            [dbo].[pWrkStnID]    NULL,
    [Description]       [dbo].[pDescription] NULL,
    [LocID]             [dbo].[pLocID]       NULL,
    [CustID]            [dbo].[pCustID]      NULL,
    [SalesRepID]        [dbo].[pSalesRep]    NULL,
    [SalesRepRequired]  BIT                  NOT NULL,
    [MaxDiscount]       [dbo].[pDecimal]     NOT NULL,
    [PmtMethodID]       NVARCHAR (10)        NULL,
    [TaxGroupID]        [dbo].[pTaxLoc]      NOT NULL,
    [TransIDPrefix]     NVARCHAR (7)         NOT NULL,
    [DistCode]          [dbo].[pDistCode]    NOT NULL,
    [LayawayDays]       SMALLINT             NOT NULL,
    [InvoicePrinter]    NVARCHAR (255)       NULL,
    [ReceiptPrinter]    NVARCHAR (255)       NULL,
    [ReceiptHeader]     NVARCHAR (MAX)       NULL,
    [ReceiptFooter]     NVARCHAR (MAX)       NULL,
    [MenuMessage]       NVARCHAR (MAX)       NULL,
    [CF]                XML                  NULL,
    [ts]                ROWVERSION           NULL,
    [PrintOption]       TINYINT              CONSTRAINT [DF_tblPsConfig_PrintOption] DEFAULT ((0)) NOT NULL,
    [DrawerDeviceType]  TINYINT              CONSTRAINT [DF_tblPsConfig_DrawerDeviceType] DEFAULT ((0)) NOT NULL,
    [DrawerDeviceName]  NVARCHAR (255)       NULL,
    [DrawerOpenCommand] NVARCHAR (255)       NULL,
    CONSTRAINT [PK_tblPsConfig] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsConfig_TransIDPrefix]
    ON [dbo].[tblPsConfig]([TransIDPrefix] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsConfig_HostID]
    ON [dbo].[tblPsConfig]([HostID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsConfig';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsConfig';

