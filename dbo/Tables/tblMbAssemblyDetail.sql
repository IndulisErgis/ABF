CREATE TABLE [dbo].[tblMbAssemblyDetail] (
    [AssemblyId]     [dbo].[pItemID]      NULL,
    [RevisionNo]     VARCHAR (3)          NULL,
    [RtgType]        TINYINT              CONSTRAINT [DF__tblMbAsse__RtgTy__67C266A5] DEFAULT (1) NOT NULL,
    [CompSeq]        VARCHAR (3)          CONSTRAINT [DF__tblMbAsse__CompS__65DA1E33] DEFAULT ('010') NULL,
    [RtgStep]        VARCHAR (3)          NULL,
    [ComponentID]    [dbo].[pItemID]      NULL,
    [LocId]          [dbo].[pLocID]       NULL,
    [UOM]            [dbo].[pUom]         NULL,
    [ConvFactor]     [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__ConvF__68B68ADE] DEFAULT (1) NOT NULL,
    [UsageType]      TINYINT              NOT NULL,
    [Qty]            [dbo].[pDec]         CONSTRAINT [DF__tblMbAssemb__Qty__69AAAF17] DEFAULT (0) NOT NULL,
    [ScrapPct]       [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__Scrap__6A9ED350] DEFAULT (0) NOT NULL,
    [CostGroupID]    VARCHAR (6)          NULL,
    [DetailType]     TINYINT              CONSTRAINT [DF__tblMbAsse__Detai__6B92F789] DEFAULT (1) NOT NULL,
    [LottedYn]       BIT                  CONSTRAINT [DF__tblMbAsse__Lotte__6D7B3FFB] DEFAULT (0) NOT NULL,
    [Backflushed]    BIT                  NOT NULL,
    [Notes]          TEXT                 NULL,
    [MGID]           VARCHAR (10)         NULL,
    [ts]             ROWVERSION           NULL,
    [CF]             XML                  NULL,
    [CompRevisionNo] VARCHAR (3)          NULL,
    [UnitCost]       [dbo].[pDec]         CONSTRAINT [DF_tblMbAssemblyDetail_UnitCost] DEFAULT ((0)) NOT NULL,
    [Sequence]       INT                  NOT NULL,
    [RoutingId]      INT                  NOT NULL,
    [HeaderId]       INT                  NOT NULL,
    [Id]             INT                  NOT NULL,
    [Description]    [dbo].[pDescription] NULL,
    CONSTRAINT [PK_tblMbAssemblyDetail] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMbAssemblyDetail_RoutingIdSequence]
    ON [dbo].[tblMbAssemblyDetail]([RoutingId] ASC, [Sequence] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblMbAssemblyDetail_HeaderId]
    ON [dbo].[tblMbAssemblyDetail]([HeaderId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMbAssemblyDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMbAssemblyDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMbAssemblyDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMbAssemblyDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbAssemblyDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbAssemblyDetail';

