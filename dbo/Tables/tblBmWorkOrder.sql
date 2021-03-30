CREATE TABLE [dbo].[tblBmWorkOrder] (
    [TransId]       [dbo].[pTransID] NOT NULL,
    [EntryNum]      INT              CONSTRAINT [DF_tblBmWorkOrder_EntryNum] DEFAULT ((-1)) NOT NULL,
    [TransDate]     DATETIME         CONSTRAINT [DF__tblBmWork__Trans__4262CC11] DEFAULT (getdate()) NULL,
    [WorkType]      TINYINT          CONSTRAINT [DF__tblBmWork__WorkT__4356F04A] DEFAULT (1) NULL,
    [Status]        TINYINT          CONSTRAINT [DF__tblBmWork__Statu__444B1483] DEFAULT (0) NOT NULL,
    [PrintedYn]     BIT              CONSTRAINT [DF__tblBmWork__Print__453F38BC] DEFAULT (0) NOT NULL,
    [BmBomId]       INT              NULL,
    [ItemId]        [dbo].[pItemID]  NULL,
    [LocId]         [dbo].[pLocID]   NULL,
    [ItemType]      TINYINT          NULL,
    [BuildUOM]      [dbo].[pUom]     NULL,
    [BuildQty]      [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__Build__46335CF5] DEFAULT (0) NULL,
    [ActualQty]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__Actua__4727812E] DEFAULT (0) NULL,
    [LaborCost]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__Labor__481BA567] DEFAULT (0) NULL,
    [UnitCost]      [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__UnitC__490FC9A0] DEFAULT (0) NULL,
    [ConvFactor]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__ConvF__4A03EDD9] DEFAULT (1) NULL,
    [GLPeriod]      SMALLINT         CONSTRAINT [DF__tblBmWork__GLPer__4AF81212] DEFAULT (0) NULL,
    [GlYear]        SMALLINT         CONSTRAINT [DF__tblBmWork__GlYea__4BEC364B] DEFAULT (0) NULL,
    [SumHistPeriod] SMALLINT         CONSTRAINT [DF__tblBmWork__SumHi__4CE05A84] DEFAULT (0) NULL,
    [QtySeqNum]     INT              CONSTRAINT [DF__tblBmWork__QtySe__4DD47EBD] DEFAULT (0) NULL,
    [HistSeqNum]    INT              CONSTRAINT [DF__tblBmWork__HistS__4EC8A2F6] DEFAULT (0) NULL,
    [WorkUser]      [dbo].[pUserID]  NULL,
    [ts]            ROWVERSION       NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK__tblBmWorkOrder__56F49FFA] PRIMARY KEY CLUSTERED ([TransId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransIdEntryNum]
    ON [dbo].[tblBmWorkOrder]([TransId] ASC, [EntryNum] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmWorkOrder] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmWorkOrder] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmWorkOrder] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmWorkOrder] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrder';

