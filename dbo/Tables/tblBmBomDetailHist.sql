CREATE TABLE [dbo].[tblBmBomDetailHist] (
    [Counter]      INT             IDENTITY (1, 1) NOT NULL,
    [HistSeqNum]   INT             NULL,
    [BmBomId]      INT             NULL,
    [ItemId]       [dbo].[pItemID] NULL,
    [BmDetailType] TINYINT         NULL,
    [LocId]        [dbo].[pLocID]  NULL,
    [Quantity]     [dbo].[pDec]    NULL,
    [Uom]          [dbo].[pUom]    NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK__tblBmBomDetailHi__4A18FC72] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmBomDetailHist] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmBomDetailHist] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmBomDetailHist] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmBomDetailHist] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBomDetailHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBomDetailHist';

