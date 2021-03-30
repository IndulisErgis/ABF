CREATE TABLE [dbo].[tblInItemLocBin] (
    [ItemId]           [dbo].[pItemID]  NOT NULL,
    [LocId]            [dbo].[pLocID]   NOT NULL,
    [BinNum]           VARCHAR (10)     NOT NULL,
    [LastCountBatchId] [dbo].[pBatchID] NULL,
    [LastCountQty]     [dbo].[pDec]     CONSTRAINT [DF__tblInItem__LastC__69C08907] DEFAULT (0) NULL,
    [LastCountUom]     [dbo].[pUom]     NULL,
    [LastCountDate]    DATETIME         NULL,
    [LastCountTagNum]  VARCHAR (10)     NULL,
    [ts]               ROWVERSION       NULL,
    [CF]               XML              NULL,
    CONSTRAINT [PK__tblInItemLocBin__1758727B] PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC, [BinNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemLocBin] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocBin';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocBin';

