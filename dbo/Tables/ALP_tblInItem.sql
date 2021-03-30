CREATE TABLE [dbo].[ALP_tblInItem] (
    [AlpItemId]                 [dbo].[pItemID]     NOT NULL,
    [AlpServiceType]            SMALLINT            NULL,
    [AlpDfltHours]              [dbo].[pDec]        NULL,
    [AlpDfltPts]                [dbo].[pDec]        NULL,
    [AlpPrintProposalYn]        BIT                 NULL,
    [AlpCopyToListYn]           BIT                 NULL,
    [AlpPhaseCodeID]            INT                 NULL,
    [AlpAcctCode]               [dbo].[pGLAcctCode] NULL,
    [AlpPanelYN]                BIT                 NULL,
    [AlpVendorKitYN]            BIT                 NULL,
    [AlpDfltCommercialHours]    [dbo].[pDec]        NULL,
    [AlpDfltCommercialPts]      [dbo].[pDec]        NULL,
    [AlpLocationYn]             BIT                 NULL,
    [AlpPrintOnInvoice]         BIT                 NULL,
    [AlpMFG]                    NVARCHAR (12)       NULL,
    [AlpCATG]                   NVARCHAR (12)       NULL,
    [Alpts]                     ROWVERSION          NULL,
    [AlpQMDescription]          NVARCHAR (200)      NULL,
    [AlpKitUsageRestrictedToPO] BIT                 CONSTRAINT [DF_ALP_tblInItem_AlpKitUsageRestrictedToPO] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_ALP_tblInItem] PRIMARY KEY CLUSTERED ([AlpItemId] ASC)
);

