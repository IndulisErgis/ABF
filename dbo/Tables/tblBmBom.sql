CREATE TABLE [dbo].[tblBmBom] (
    [BmBomId]    INT             NOT NULL,
    [BmItemId]   [dbo].[pItemID] NULL,
    [BmLocId]    [dbo].[pLocID]  NULL,
    [Descr]      VARCHAR (35)    NULL,
    [LaborCost]  [dbo].[pDec]    CONSTRAINT [DF__tblBmBom__LaborC__5244F976] DEFAULT (0) NULL,
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
    [Uom]        [dbo].[pUom]    NOT NULL,
    [ts]         ROWVERSION      NULL,
    [CF]         XML             NULL,
    CONSTRAINT [PK__tblBmBom__4830B400] PRIMARY KEY CLUSTERED ([BmBomId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [sqlItemLoc]
    ON [dbo].[tblBmBom]([BmItemId] ASC, [BmLocId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmBom] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmBom] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmBom] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmBom] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBom';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmBom';

