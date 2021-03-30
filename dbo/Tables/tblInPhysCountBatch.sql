CREATE TABLE [dbo].[tblInPhysCountBatch] (
    [BatchId]                [dbo].[pBatchID] NOT NULL,
    [Descr]                  VARCHAR (35)     NULL,
    [LocIdFrom]              [dbo].[pLocID]   NULL,
    [LocIdThru]              [dbo].[pLocID]   NULL,
    [BinNumFrom]             VARCHAR (10)     NULL,
    [BinNumThru]             VARCHAR (10)     NULL,
    [ItemIdFrom]             [dbo].[pItemID]  NULL,
    [ItemIdThru]             [dbo].[pItemID]  NULL,
    [ProductLineFrom]        VARCHAR (12)     NULL,
    [ProductLineThru]        VARCHAR (12)     NULL,
    [UsrFld1From]            VARCHAR (12)     NULL,
    [UsrFld1Thru]            VARCHAR (12)     NULL,
    [UsrFld2From]            VARCHAR (12)     NULL,
    [UsrFld2Thru]            VARCHAR (12)     NULL,
    [UseTagNumbersYN]        BIT              CONSTRAINT [DF__tblInPhys__UseTa__7AB60ADF] DEFAULT (0) NULL,
    [ZeroQtyTagsYN]          BIT              CONSTRAINT [DF__tblInPhys__ZeroQ__7BAA2F18] DEFAULT (0) NULL,
    [DisplayFrozenQtyYN]     BIT              CONSTRAINT [DF__tblInPhys__Displ__7C9E5351] DEFAULT (0) NULL,
    [DfltCountedQtyYN]       BIT              CONSTRAINT [DF__tblInPhys__DfltC__7D92778A] DEFAULT (0) NULL,
    [EnterExceptionOnlyYN]   BIT              CONSTRAINT [DF__tblInPhys__Enter__7E869BC3] DEFAULT (0) NULL,
    [EnteredCountYN]         BIT              CONSTRAINT [DF__tblInPhys__Enter__7F7ABFFC] DEFAULT (0) NULL,
    [PrintVarReportYN]       BIT              CONSTRAINT [DF__tblInPhys__Print__006EE435] DEFAULT (0) NULL,
    [PrintWorksheetYN]       BIT              CONSTRAINT [DF__tblInPhys__Print__0163086E] DEFAULT (0) NULL,
    [PrintTagsYN]            BIT              CONSTRAINT [DF__tblInPhys__Print__02572CA7] DEFAULT (0) NULL,
    [FreezeDateTime]         DATETIME         NULL,
    [CountDate]              DATETIME         NULL,
    [SumYear]                SMALLINT         CONSTRAINT [DF__tblInPhys__SumYe__034B50E0] DEFAULT (0) NULL,
    [SumPeriod]              SMALLINT         CONSTRAINT [DF__tblInPhys__SumPe__043F7519] DEFAULT (0) NULL,
    [GLPeriod]               SMALLINT         CONSTRAINT [DF__tblInPhys__GLPer__05339952] DEFAULT (0) NULL,
    [LockedYn]               INT              CONSTRAINT [DF__tblInPhys__Locke__0627BD8B] DEFAULT (0) NULL,
    [zzEndingSequenceNumber] [dbo].[pDec]     NULL,
    [PreparedYn]             BIT              CONSTRAINT [DF_tblInPhysCountBatch_PreparedYn] DEFAULT (0) NOT NULL,
    [ts]                     ROWVERSION       NULL,
    [ABCClassFrom]           VARCHAR (10)     NULL,
    [ABCClassThru]           VARCHAR (10)     NULL,
    [RptUom]                 TINYINT          NULL,
    [CF]                     XML              NULL,
    CONSTRAINT [PK__tblInPhysCountBa__2C538F61] PRIMARY KEY CLUSTERED ([BatchId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPhysCountBatch';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPhysCountBatch';

