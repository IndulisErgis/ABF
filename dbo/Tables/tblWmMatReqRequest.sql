CREATE TABLE [dbo].[tblWmMatReqRequest] (
    [TranKey]       INT             NOT NULL,
    [LineNum]       INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]        [dbo].[pItemID] NULL,
    [LocId]         [dbo].[pLocID]  NULL,
    [LotNum]        [dbo].[pLotNum] NULL,
    [ExtLocA]       INT             NULL,
    [ExtLocAID]     VARCHAR (10)    NULL,
    [ExtLocB]       INT             NULL,
    [ExtLocBID]     VARCHAR (10)    NULL,
    [Qty]           [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [QtyFilled]     [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UOM]           [dbo].[pUom]    NOT NULL,
    [UnitCost]      [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [GLAcctNum]     [dbo].[pGlAcct] NULL,
    [GLDescr]       [dbo].[pGLDesc] NULL,
    [CustId]        [dbo].[pCustID] NULL,
    [ProjId]        VARCHAR (10)    NULL,
    [PhaseId]       VARCHAR (10)    NULL,
    [TaskId]        VARCHAR (10)    NULL,
    [QtySeqNum]     INT             DEFAULT ((0)) NOT NULL,
    [QtySeqNum_Ext] INT             DEFAULT ((0)) NOT NULL,
    [ts]            ROWVERSION      NULL,
    [CF]            XML             NULL,
    [LineSeq]       INT             NULL,
    CONSTRAINT [PK__tblWmMatReqRequest] PRIMARY KEY CLUSTERED ([LineNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmMatReqRequest_TranKeyLineNum]
    ON [dbo].[tblWmMatReqRequest]([TranKey] ASC, [LineNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMatReqRequest';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMatReqRequest';

