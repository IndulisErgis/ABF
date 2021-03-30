CREATE TABLE [dbo].[tblWmHistMatReqRequest] (
    [ID]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [HeaderID]      BIGINT           NOT NULL,
    [LineNum]       INT              NOT NULL,
    [ItemID]        [dbo].[pItemID]  NOT NULL,
    [LocID]         [dbo].[pLocID]   NOT NULL,
    [LotNum]        [dbo].[pLotNum]  NULL,
    [ExtLocA]       INT              NULL,
    [ExtLocB]       INT              NULL,
    [ExtLocAID]     NVARCHAR (10)    NULL,
    [ExtLocBID]     NVARCHAR (10)    NULL,
    [Qty]           [dbo].[pDecimal] NOT NULL,
    [QtyBase]       [dbo].[pDecimal] NOT NULL,
    [UOM]           [dbo].[pUom]     NOT NULL,
    [UOMBase]       [dbo].[pUom]     NOT NULL,
    [GLAcct]        [dbo].[pGlAcct]  NOT NULL,
    [GLAcctInv]     [dbo].[pGlAcct]  NOT NULL,
    [GLDescr]       [dbo].[pGLDesc]  NULL,
    [QtySeqNum]     INT              NOT NULL,
    [QtySeqNum_Ext] INT              NOT NULL,
    [LineSeq]       INT              NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK_tblWmHistMatReqRequest] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWmHistMatReqRequest_HeaderIDLineNum]
    ON [dbo].[tblWmHistMatReqRequest]([HeaderID] ASC, [LineNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistMatReqRequest';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistMatReqRequest';

