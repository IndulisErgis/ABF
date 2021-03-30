CREATE TABLE [dbo].[tblBmBomHist] (
    [HistSeqNum] INT             NOT NULL,
    [BmBomId]    INT             NOT NULL,
    [BmItemId]   [dbo].[pItemID] NOT NULL,
    [BmLocId]    [dbo].[pLocID]  NULL,
    [Descr]      VARCHAR (35)    NULL,
    [Status]     TINYINT         NULL,
    [LaborCost]  [dbo].[pDec]    NULL,
    [UsrFldTxt1] VARCHAR (12)    NULL,
    [UsrFldTxt2] VARCHAR (12)    NULL,
    [UsrFldTxt3] VARCHAR (12)    NULL,
    [UsrFldTxt4] VARCHAR (12)    NULL,
    [UsrFldTxt5] VARCHAR (12)    NULL,
    [UsrFldCst1] VARCHAR (12)    NULL,
    [UsrFldCst2] VARCHAR (12)    NULL,
    [UsrFldCst3] VARCHAR (12)    NULL,
    [UsrFldCst4] VARCHAR (12)    NULL,
    [UsrFldCst5] VARCHAR (12)    NULL,
    [Update]     VARCHAR (9)     NULL,
    [UserId]     [dbo].[pUserID] NULL,
    [Uom]        [dbo].[pUom]    NOT NULL,
    [Period]     SMALLINT        NULL,
    [Year]       SMALLINT        NULL,
    [UpdateDate] DATETIME        NULL,
    [ts]         ROWVERSION      NULL,
    [CF]         XML             NULL,
    CONSTRAINT [PK__tblBmBomHist__4B0D20AB] PRIMARY KEY CLUSTERED ([HistSeqNum] ASC, [BmBomId] ASC, [BmItemId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [sqlIndex1]
    ON [dbo].[tblBmBomHist]([HistSeqNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlBmLocId]
    ON [dbo].[tblBmBomHist]([BmLocId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmBomHist] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmBomHist] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmBomHist] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmBomHist] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBomHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBomHist';

