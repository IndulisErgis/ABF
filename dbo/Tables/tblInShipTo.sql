CREATE TABLE [dbo].[tblInShipTo] (
    [ShipToId]    [dbo].[pCustID] NOT NULL,
    [ShipToName]  VARCHAR (30)    NULL,
    [ShipToAddr1] VARCHAR (30)    NULL,
    [ShipToAddr2] VARCHAR (60)    NULL,
    [Email]       [dbo].[pEmail]  NULL,
    [Internet]    [dbo].[pWeb]    NULL,
    [ts]          ROWVERSION      NULL,
    [CF]          XML             NULL,
    CONSTRAINT [PK__tblInShipTo__33F4B129] PRIMARY KEY CLUSTERED ([ShipToId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInShipTo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInShipTo';

