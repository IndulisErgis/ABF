CREATE TABLE [dbo].[tblFaAssetService] (
    [Counter]          INT                  IDENTITY (1, 1) NOT NULL,
    [AssetID]          [dbo].[pAssetID]     NOT NULL,
    [ServiceDateSched] DATETIME             NULL,
    [ServiceDateAct]   DATETIME             NULL,
    [ServDescr]        [dbo].[pDescription] NULL,
    [ts]               ROWVERSION           NULL,
    [CF]               XML                  NULL,
    [ID]               INT                  NOT NULL,
    [WorkOrderID]      BIGINT               NULL,
    [WorkOrderNo]      [dbo].[pTransID]     NULL,
    [ServiceCost]      [dbo].[pDec]         NULL,
    CONSTRAINT [PK_tblFaAssetService] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblFaAssetService_AssetID]
    ON [dbo].[tblFaAssetService]([AssetID] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblFaAssetService] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblFaAssetService] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblFaAssetService] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblFaAssetService] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAssetService';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAssetService';

