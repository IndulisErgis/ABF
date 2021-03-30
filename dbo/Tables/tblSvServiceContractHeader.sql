CREATE TABLE [dbo].[tblSvServiceContractHeader] (
    [ID]                   BIGINT               NOT NULL,
    [ContractNo]           NVARCHAR (8)         NOT NULL,
    [CustID]               [dbo].[pCustID]      NULL,
    [Description]          [dbo].[pDescription] NULL,
    [StartDate]            DATETIME             NULL,
    [EndDate]              DATETIME             NULL,
    [OriginalContractDate] DATETIME             NULL,
    [Notes]                NVARCHAR (MAX)       NULL,
    [RecurID]              NVARCHAR (8)         NULL,
    [BillingType]          TINYINT              DEFAULT ((2)) NOT NULL,
    [NextBillingDate]      DATETIME             NULL,
    [BillingAmount]        [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [BillingInterval]      TINYINT              DEFAULT ((0)) NOT NULL,
    [LastBillingDate]      DATETIME             NULL,
    [CF]                   XML                  NULL,
    [ts]                   ROWVERSION           NULL,
    [BillingTypeDflt]      NVARCHAR (10)        NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvServiceContractHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvServiceContractHeader';

