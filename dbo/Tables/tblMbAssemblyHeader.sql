CREATE TABLE [dbo].[tblMbAssemblyHeader] (
    [AssemblyId]        [dbo].[pItemID]      NOT NULL,
    [RevisionNo]        VARCHAR (3)          NOT NULL,
    [Description]       [dbo].[pDescription] NULL,
    [EffectiveDateFrom] DATETIME             NULL,
    [EffectiveDateThru] DATETIME             NULL,
    [DrawingNumber]     VARCHAR (15)         NULL,
    [LotSize]           INT                  CONSTRAINT [DF__tblMbAsse__LotSi__7057ACA6] DEFAULT (1) NOT NULL,
    [Uom]               [dbo].[pUom]         NOT NULL,
    [MrpCode]           VARCHAR (10)         NULL,
    [Engineer]          VARCHAR (20)         NULL,
    [StockingLevel]     BIT                  CONSTRAINT [DF_tblMbAssemblyHeader_StockingLevel] DEFAULT (0) NOT NULL,
    [PlanningBill]      BIT                  CONSTRAINT [DF_tblMbAssemblyHeader_PlanningBill] DEFAULT (0) NOT NULL,
    [Backflushed]       BIT                  CONSTRAINT [DF_tblMbAssemblyHeader_Backflushed] DEFAULT (0) NOT NULL,
    [DfltRevYn]         BIT                  CONSTRAINT [DF__tblMbAsse__DfltR__723FF518] DEFAULT (0) NOT NULL,
    [LastUpdated]       DATETIME             NULL,
    [Instructions]      TEXT                 NULL,
    [MGID]              VARCHAR (10)         NULL,
    [UsrFldTxt1]        VARCHAR (12)         NULL,
    [UsrFldTxt2]        VARCHAR (12)         NULL,
    [UsrFldTxt3]        VARCHAR (12)         NULL,
    [UsrFldTxt4]        VARCHAR (12)         NULL,
    [UsrFldTxt5]        VARCHAR (12)         NULL,
    [UsrFldCst1]        VARCHAR (12)         NULL,
    [UsrFldCst2]        VARCHAR (12)         NULL,
    [UsrFldCst3]        VARCHAR (12)         NULL,
    [UsrFldCst4]        VARCHAR (12)         NULL,
    [UsrFldCst5]        VARCHAR (12)         NULL,
    [ts]                ROWVERSION           NULL,
    [CF]                XML                  NULL,
    [Id]                INT                  NOT NULL,
    CONSTRAINT [PK_tblMbAssemblyHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblMbAssemblyHeader_AssemblyIdRevisionNo]
    ON [dbo].[tblMbAssemblyHeader]([AssemblyId] ASC, [RevisionNo] ASC);


GO
CREATE NONCLUSTERED INDEX [sqltblMbAssemblyHeaderMGID]
    ON [dbo].[tblMbAssemblyHeader]([MGID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMbAssemblyHeader] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMbAssemblyHeader] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMbAssemblyHeader] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMbAssemblyHeader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbAssemblyHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbAssemblyHeader';

