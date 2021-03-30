CREATE TABLE [dbo].[ALP_tblInItem_temp] (
    [ItemId]                 VARCHAR (24)     NOT NULL,
    [UsrFld1]                VARCHAR (12)     NULL,
    [UsrFld2]                VARCHAR (12)     NULL,
    [UsrFld3]                VARCHAR (12)     NULL,
    [UsrFld4]                VARCHAR (12)     NULL,
    [AlpServiceType]         SMALLINT         NULL,
    [AlpDfltHours]           DECIMAL (20, 10) NULL,
    [AlpDfltPts]             DECIMAL (20, 10) NULL,
    [AlpPrintProposalYn]     BIT              NULL,
    [AlpCopyToListYn]        BIT              NULL,
    [AlpPhaseCodeID]         INT              NULL,
    [AlpAcctCode]            VARCHAR (2)      NULL,
    [AlpPanelYN]             BIT              NULL,
    [AlpVendorKitYn]         BIT              NULL,
    [AlpDfltCommercialHours] DECIMAL (20, 10) NULL,
    [AlpDfltCommercialPts]   DECIMAL (20, 10) NULL,
    [AlpLocationYn]          BIT              NULL,
    [AlpPrintOnInvoice]      BIT              NULL
);

