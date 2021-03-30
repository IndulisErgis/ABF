CREATE TABLE [dbo].[tblInItemUomDflt] (
    [ItemId]   [dbo].[pItemID] NOT NULL,
    [DfltType] SMALLINT        NOT NULL,
    [Uom]      [dbo].[pUom]    NOT NULL,
    [ts]       ROWVERSION      NULL,
    [CF]       XML             NULL,
    CONSTRAINT [PK__tblInItemUomDflt] PRIMARY KEY CLUSTERED ([ItemId] ASC, [DfltType] ASC)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemUomDflt] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemUomDflt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemUomDflt';

