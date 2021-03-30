CREATE TABLE [dbo].[tblMpHistoryMatlSum] (
    [PostRun]        [dbo].[pPostRun] NOT NULL,
    [OrderNo]        [dbo].[pTransID] NULL,
    [ReleaseNo]      VARCHAR (3)      NULL,
    [ReqID]          VARCHAR (4)      NULL,
    [TransId]        INT              NOT NULL,
    [ComponentId]    [dbo].[pItemID]  NULL,
    [LocId]          [dbo].[pLocID]   NULL,
    [ComponentType]  TINYINT          DEFAULT ((0)) NOT NULL,
    [LeadTime]       INT              DEFAULT ((0)) NOT NULL,
    [RequiredDate]   DATETIME         NULL,
    [EstQtyRequired] [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [EstScrap]       [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [UOM]            [dbo].[pUom]     NULL,
    [ConvFactor]     [dbo].[pDec]     DEFAULT ((1)) NOT NULL,
    [CostGroupId]    VARCHAR (6)      NULL,
    [UnitCost]       [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [Status]         TINYINT          DEFAULT ((0)) NOT NULL,
    [QtySeqNum]      INT              DEFAULT ((0)) NULL,
    [Notes]          TEXT             NULL,
    [ts]             ROWVERSION       NULL,
    [CF]             XML              NULL,
    [UOMBase]        [dbo].[pUom]     NULL,
    CONSTRAINT [PK_tblMpHistoryMatlSum] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlSum';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlSum';

