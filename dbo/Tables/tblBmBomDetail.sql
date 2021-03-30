CREATE TABLE [dbo].[tblBmBomDetail] (
    [BmBomId]      INT             NOT NULL,
    [BmDetailType] TINYINT         NULL,
    [ItemId]       [dbo].[pItemID] NOT NULL,
    [LocId]        [dbo].[pLocID]  NOT NULL,
    [Quantity]     [dbo].[pDec]    NULL,
    [Uom]          [dbo].[pUom]    NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK__tblBmBomDetail__0D10B989] PRIMARY KEY CLUSTERED ([BmBomId] ASC, [ItemId] ASC, [LocId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmBomDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmBomDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmBomDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmBomDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBomDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBomDetail';

