CREATE TABLE [dbo].[tblMrRoutingHeader] (
    [RoutingId] VARCHAR (10)         NOT NULL,
    [Descr]     [dbo].[pDescription] NULL,
    [ts]        ROWVERSION           NULL,
    [CF]        XML                  NULL,
    CONSTRAINT [PK__tblMrRoutingHead__0F59C005] PRIMARY KEY CLUSTERED ([RoutingId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrRoutingHeader] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrRoutingHeader] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrRoutingHeader] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrRoutingHeader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrRoutingHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrRoutingHeader';

