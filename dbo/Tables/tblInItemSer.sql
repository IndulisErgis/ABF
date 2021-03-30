CREATE TABLE [dbo].[tblInItemSer] (
    [ItemId]        [dbo].[pItemID] NOT NULL,
    [SerNum]        [dbo].[pSerNum] NOT NULL,
    [LocId]         [dbo].[pLocID]  NULL,
    [LotNum]        [dbo].[pLotNum] NULL,
    [SerNumStatus]  TINYINT         CONSTRAINT [DF__tblInItem__SerNu__201C99B8] DEFAULT (1) NULL,
    [CostUnit]      [dbo].[pDec]    CONSTRAINT [DF__tblInItem__CostU__2110BDF1] DEFAULT (0) NULL,
    [PriceUnit]     [dbo].[pDec]    CONSTRAINT [DF__tblInItem__Price__2204E22A] DEFAULT (0) NULL,
    [InitialDate]   DATETIME        NULL,
    [Cmnt]          VARCHAR (35)    NULL,
    [Source]        TINYINT         CONSTRAINT [DF_tblInItemSer_Source] DEFAULT (0) NOT NULL,
    [ts]            ROWVERSION      NULL,
    [ExtLocA]       INT             NULL,
    [ExtLocB]       INT             NULL,
    [CostAdjPosted] [dbo].[pDec]    CONSTRAINT [DF_tblInItemSer_CostAdjPosted] DEFAULT ((0)) NOT NULL,
    [CostSell]      [dbo].[pDec]    CONSTRAINT [DF_tblInItemSer_CostSell] DEFAULT ((0)) NOT NULL,
    [CF]            XML             NULL,
    CONSTRAINT [PK__tblInItemSer__20E1DCB5] PRIMARY KEY CLUSTERED ([ItemId] ASC, [SerNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemSer] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemSer';

