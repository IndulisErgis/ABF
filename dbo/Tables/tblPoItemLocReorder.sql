CREATE TABLE [dbo].[tblPoItemLocReorder] (
    [ItemId]           [dbo].[pItemID] NOT NULL,
    [LocId]            [dbo].[pLocID]  NOT NULL,
    [UomDflt]          [dbo].[pUom]    NULL,
    [QtyOnHand]        [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__QtyOn__293BEF9E] DEFAULT (0) NULL,
    [QtyOnOrder]       [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__QtyOn__2A3013D7] DEFAULT (0) NULL,
    [SafetyStock]      [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Safet__2B243810] DEFAULT (0) NULL,
    [UsageForecast]    [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Usage__2C185C49] DEFAULT (0) NULL,
    [UsageAnnual]      [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Usage__2D0C8082] DEFAULT (0) NULL,
    [OrderPointEoq]    [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Order__2E00A4BB] DEFAULT (0) NULL,
    [OrderPointFrcst]  [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Order__2EF4C8F4] DEFAULT (0) NULL,
    [OrderPointMinMax] [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Order__2FE8ED2D] DEFAULT (0) NULL,
    [OrderQtyEoq]      [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Order__30DD1166] DEFAULT (0) NULL,
    [OrderQtyFrcst]    [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Order__31D1359F] DEFAULT (0) NULL,
    [OrderQtyMinMax]   [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__Order__32C559D8] DEFAULT (0) NULL,
    [NotesEoq]         VARCHAR (2)     NULL,
    [NotesFrcst]       VARCHAR (2)     NULL,
    [NotesMinMax]      VARCHAR (2)     NULL,
    [FrozenEoq]        BIT             CONSTRAINT [DF__tblPoItem__Froze__33B97E11] DEFAULT (0) NULL,
    [FrozenFrcst]      BIT             CONSTRAINT [DF__tblPoItem__Froze__34ADA24A] DEFAULT (0) NULL,
    [FrozenQtyYN]      BIT             CONSTRAINT [DF__tblPoItem__Froze__35A1C683] DEFAULT (0) NULL,
    [AutoReorderYN]    BIT             CONSTRAINT [DF__tblPoItem__AutoR__3695EABC] DEFAULT (0) NULL,
    [GlInvAcct]        [dbo].[pGlAcct] NULL,
    [AboveEoqOrdPt]    BIT             CONSTRAINT [DF__tblPoItem__Above__378A0EF5] DEFAULT (0) NULL,
    [AboveFrcstOrdPt]  BIT             CONSTRAINT [DF__tblPoItem__Above__387E332E] DEFAULT (0) NULL,
    [AboveMinMaxOrdPt] BIT             CONSTRAINT [DF__tblPoItem__Above__39725767] DEFAULT (0) NULL,
    [AboveAllOrdPt]    BIT             CONSTRAINT [DF__tblPoItem__Above__3A667BA0] DEFAULT (0) NULL,
    [MinOrderQty]      [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__MinOr__3B5A9FD9] DEFAULT (0) NULL,
    [MaxOrderQty]      [dbo].[pDec]    CONSTRAINT [DF__tblPoItem__MaxOr__3C4EC412] DEFAULT (0) NULL,
    [ts]               ROWVERSION      NULL,
    [CF]               XML             NULL,
    CONSTRAINT [PK__tblPoItemLocReor__7E57BA87] PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPoItemLocReorder] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPoItemLocReorder] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPoItemLocReorder] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPoItemLocReorder] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoItemLocReorder';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoItemLocReorder';

