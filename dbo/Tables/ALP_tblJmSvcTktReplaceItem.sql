CREATE TABLE [dbo].[ALP_tblJmSvcTktReplaceItem] (
    [TicketItemId]      INT          NOT NULL,
    [OriginalSysItemId] INT          NOT NULL,
    [OriginalItemQty]   FLOAT (53)   NOT NULL,
    [OriginalUom]       VARCHAR (5)  NOT NULL,
    [OriginalEquipLoc]  VARCHAR (30) NULL,
    [OriginalZone]      VARCHAR (5)  NULL,
    CONSTRAINT [PK_ALP_tblJmSvcTktReplaceItem] PRIMARY KEY CLUSTERED ([TicketItemId] ASC)
);

