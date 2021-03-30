CREATE TABLE [dbo].[tblWmPick_Gen] (
    [PickGenKey] INT                 IDENTITY (1, 1) NOT NULL,
    [SourceId]   TINYINT             NOT NULL,
    [TransId]    [dbo].[pTransID]    NOT NULL,
    [EntryNum]   BIGINT              NOT NULL,
    [SeqNum]     INT                 NOT NULL,
    [PickNum]    [dbo].[pInvoiceNum] NULL,
    [ItemId]     [dbo].[pItemID]     NOT NULL,
    [LocId]      [dbo].[pLocID]      NOT NULL,
    [LotNum]     [dbo].[pLotNum]     NULL,
    [ExtLocA]    INT                 NULL,
    [ExtLocB]    INT                 NULL,
    [UOM]        [dbo].[pUom]        NOT NULL,
    [QtyReq]     [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [ReqDate]    DATETIME            NOT NULL,
    [Ref1]       [dbo].[pTransID]    NULL,
    [Ref2]       [dbo].[pTransID]    NULL,
    [Ref3]       [dbo].[pTransID]    NULL,
    [GrpId]      INT                 NULL,
    [OriCompQty] [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [UID]        [dbo].[pUserID]     NULL,
    [HostId]     [dbo].[pWrkStnID]   NULL,
    [ts]         ROWVERSION          NULL,
    [PickID]     VARCHAR (20)        NULL,
    [CF]         XML                 NULL,
    CONSTRAINT [PK__tblWmPick_Gen] PRIMARY KEY CLUSTERED ([PickGenKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmPick_Gen_UserIdWrkStnId]
    ON [dbo].[tblWmPick_Gen]([UID] ASC, [HostId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWmPick_Gen_SourceIdTransIdEntryNumSeqNum]
    ON [dbo].[tblWmPick_Gen]([SourceId] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPick_Gen';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPick_Gen';

