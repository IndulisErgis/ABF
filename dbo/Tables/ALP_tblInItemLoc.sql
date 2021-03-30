CREATE TABLE [dbo].[ALP_tblInItemLoc] (
    [AlpItemId]              [dbo].[pItemID] NOT NULL,
    [AlpLocId]               [dbo].[pLocID]  NOT NULL,
    [AlpDfltHours]           [dbo].[pDec]    NULL,
    [AlpDfltPts]             [dbo].[pDec]    NULL,
    [AlpInstalledPrice]      [dbo].[pDec]    NULL,
    [AlpDfltCommercialHours] [dbo].[pDec]    NULL,
    [AlpDfltCommercialPts]   [dbo].[pDec]    NULL,
    [Alpts]                  ROWVERSION      NULL,
    CONSTRAINT [PK_ALP_tblInItemLoc] PRIMARY KEY CLUSTERED ([AlpItemId] ASC, [AlpLocId] ASC)
);

