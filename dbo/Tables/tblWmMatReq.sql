CREATE TABLE [dbo].[tblWmMatReq] (
    [TranKey]    INT             IDENTITY (1, 1) NOT NULL,
    [ReqType]    SMALLINT        DEFAULT ((1)) NOT NULL,
    [ReqNum]     VARCHAR (10)    NULL,
    [DatePlaced] DATETIME        DEFAULT (getdate()) NULL,
    [DateNeeded] DATETIME        DEFAULT (getdate()) NULL,
    [LocID]      [dbo].[pLocID]  NULL,
    [ShipToId]   [dbo].[pCustID] NULL,
    [ShipVia]    VARCHAR (20)    NULL,
    [ReqstdBy]   VARCHAR (25)    NULL,
    [Notes]      TEXT            NULL,
    [ts]         ROWVERSION      NOT NULL,
    [CF]         XML             NULL,
    [Status]     TINYINT         CONSTRAINT [DF_tblWmMatReq_Status] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblWmMatReq] PRIMARY KEY CLUSTERED ([TranKey] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMatReq';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMatReq';

