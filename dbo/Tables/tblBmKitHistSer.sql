CREATE TABLE [dbo].[tblBmKitHistSer] (
    [Counter]     INT             IDENTITY (1, 1) NOT NULL,
    [HistSeqNum]  INT             CONSTRAINT [DF__tblBmKitH__HistS__6CF8EFB2] DEFAULT (0) NOT NULL,
    [EntryNumber] INT             CONSTRAINT [DF__tblBmKitH__Entry__6DED13EB] DEFAULT (0) NULL,
    [ItemId]      [dbo].[pItemID] NOT NULL,
    [LocId]       [dbo].[pLocID]  NOT NULL,
    [LotNum]      [dbo].[pLotNum] NULL,
    [SerNum]      [dbo].[pSerNum] NOT NULL,
    [CostUnit]    [dbo].[pDec]    CONSTRAINT [DF_tblBmKitHistSer_CostUnit] DEFAULT (0) NOT NULL,
    [PriceUnit]   [dbo].[pDec]    CONSTRAINT [DF_tblBmKitHistSer_PriceUnit] DEFAULT (0) NOT NULL,
    [ts]          ROWVERSION      NULL,
    [CF]          XML             NULL,
    [ExtLocAID]   VARCHAR (10)    NULL,
    [ExtLocBID]   VARCHAR (10)    NULL,
    CONSTRAINT [PK__tblBmKitHistSer__51BA1E3A] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmKitHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmKitHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmKitHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmKitHistSer] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistSer';

