CREATE TABLE [dbo].[tblWmHistMatReq] (
    [ID]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [PostRun]    [dbo].[pPostRun] NOT NULL,
    [TranKey]    INT              NOT NULL,
    [ReqType]    SMALLINT         NOT NULL,
    [ReqNum]     NVARCHAR (10)    NOT NULL,
    [DatePlaced] DATETIME         NULL,
    [DateNeeded] DATETIME         NULL,
    [LocID]      [dbo].[pLocID]   NULL,
    [ShipToID]   [dbo].[pCustID]  NULL,
    [ShipVia]    NVARCHAR (20)    NULL,
    [ReqstdBy]   NVARCHAR (25)    NULL,
    [Notes]      NVARCHAR (MAX)   NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK_tblWmHistMatReq] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWmHistMatReq_PostRunTransKey]
    ON [dbo].[tblWmHistMatReq]([PostRun] ASC, [TranKey] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistMatReq';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistMatReq';

