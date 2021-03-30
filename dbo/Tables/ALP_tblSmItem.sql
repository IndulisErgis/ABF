CREATE TABLE [dbo].[ALP_tblSmItem] (
    [AlpItemCode]               [dbo].[pItemID] NOT NULL,
    [AlpServiceType]            SMALLINT        NULL,
    [AlpKittedYN]               BIT             NULL,
    [AlpInstalledPrice]         FLOAT (53)      NULL,
    [AlpAcctCode]               VARCHAR (6)     NULL,
    [AlpDfltHours]              [dbo].[pDec]    NULL,
    [AlpDfltPts]                [dbo].[pDec]    NULL,
    [AlpPrintProposalYn]        BIT             NULL,
    [AlpCopyToListYn]           BIT             NULL,
    [AlpPhaseCodeID]            INT             NULL,
    [AlpPanelYN]                BIT             NULL,
    [AlpVendorKitYn]            BIT             NULL,
    [Alpts]                     ROWVERSION      NULL,
    [AlpItemStatus]             TINYINT         CONSTRAINT [Alp_AlpItemStatus] DEFAULT ((1)) NULL,
    [AlpKitUsageRestrictedToPO] BIT             CONSTRAINT [DF_ALP_tblSmItem_AlpKitUsageRestrictedToPO] DEFAULT ((0)) NULL
);

