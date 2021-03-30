CREATE TABLE [dbo].[tblArSalesRepComm] (
    [Id]         INT               IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SalesRepID] [dbo].[pSalesRep] NOT NULL,
    [CommType]   TINYINT           DEFAULT ((0)) NOT NULL,
    [RefID]      VARCHAR (24)      NULL,
    [CommRate]   [dbo].[pDec]      DEFAULT ((0)) NULL,
    [ts]         ROWVERSION        NULL,
    [CF]         XML               NULL,
    CONSTRAINT [PK_tblArSalesRepComm] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblArSalesRepComm_CommTypeRefID]
    ON [dbo].[tblArSalesRepComm]([CommType] ASC, [RefID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblArSalesRepComm_SalesRepId]
    ON [dbo].[tblArSalesRepComm]([SalesRepID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesRepComm';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesRepComm';

