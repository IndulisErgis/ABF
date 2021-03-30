CREATE TABLE [dbo].[tblInItemAlt] (
    [AltItemId] [dbo].[pItemID] NOT NULL,
    [ItemId]    [dbo].[pItemID] NOT NULL,
    [DateStart] DATETIME        NULL,
    [DateEnd]   DATETIME        NULL,
    [ts]        ROWVERSION      NULL,
    [CF]        XML             NULL,
    CONSTRAINT [PK__tblInItemAlt__15702A09] PRIMARY KEY CLUSTERED ([AltItemId] ASC, [ItemId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemAlt] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemAlt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemAlt';

