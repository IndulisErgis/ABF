CREATE TABLE [dbo].[tblInItemAddlDescr] (
    [ItemId]    [dbo].[pItemID] NOT NULL,
    [AddlDescr] TEXT            NULL,
    [ts]        ROWVERSION      NULL,
    [CF]        XML             NULL,
    CONSTRAINT [PK__tblInItemAddlDes__1387E197] PRIMARY KEY CLUSTERED ([ItemId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemAddlDescr] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemAddlDescr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemAddlDescr';

