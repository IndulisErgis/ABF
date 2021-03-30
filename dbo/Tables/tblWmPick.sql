CREATE TABLE [dbo].[tblWmPick] (
    [PickKey]   INT                 IDENTITY (1, 1) NOT NULL,
    [SourceId]  TINYINT             NOT NULL,
    [TransId]   [dbo].[pTransID]    NOT NULL,
    [EntryNum]  BIGINT              NOT NULL,
    [SeqNum]    INT                 NOT NULL,
    [PickNum]   [dbo].[pInvoiceNum] NULL,
    [ItemId]    [dbo].[pItemID]     NOT NULL,
    [LocId]     [dbo].[pLocID]      NOT NULL,
    [SerNum]    [dbo].[pSerNum]     NULL,
    [LotNum]    [dbo].[pLotNum]     NULL,
    [ExtLocA]   INT                 NULL,
    [ExtLocAID] VARCHAR (10)        NULL,
    [ExtLocB]   INT                 NULL,
    [ExtLocBID] VARCHAR (10)        NULL,
    [UOM]       [dbo].[pUom]        NOT NULL,
    [QtyPicked] [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [EntryDate] DATETIME            NOT NULL,
    [TransDate] DATETIME            NOT NULL,
    [GrpId]     INT                 NULL,
    [UID]       [dbo].[pUserID]     NULL,
    [HostId]    [dbo].[pWrkStnID]   NULL,
    [ts]        ROWVERSION          NULL,
    [CF]        XML                 NULL,
    [Status]    TINYINT             NOT NULL,
    CONSTRAINT [PK__tblWmPick] PRIMARY KEY CLUSTERED ([PickKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmPick_UserIdWrkStnId]
    ON [dbo].[tblWmPick]([UID] ASC, [HostId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmPick_SourceIdTransIdEntryNumSeqNum]
    ON [dbo].[tblWmPick]([SourceId] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPick';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPick';

