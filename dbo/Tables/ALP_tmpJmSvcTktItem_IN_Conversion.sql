CREATE TABLE [dbo].[ALP_tmpJmSvcTktItem_IN_Conversion] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [TicketId]     INT          NOT NULL,
    [TicketItemId] INT          NOT NULL,
    [ItemId]       VARCHAR (50) NOT NULL,
    [Action]       VARCHAR (50) NOT NULL,
    [Qty]          [dbo].[pDec] NOT NULL,
    [UOM]          VARCHAR (10) NOT NULL,
    [BaseQty]      [dbo].[pDec] NOT NULL,
    [Category]     VARCHAR (10) NOT NULL,
    [PullDate]     DATETIME     NULL,
    [QtySeqNum]    INT          NULL,
    [WhseId]       VARCHAR (10) NULL,
    [ts]           ROWVERSION   NULL,
    CONSTRAINT [PK_tmpJmSvcTktItem_IN_Conversion] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);

