CREATE TABLE [dbo].[tblWMBOLDetail] (
    [BOLDtlRef] INT                  IDENTITY (1, 1) NOT NULL,
    [BOLRef]    INT                  NOT NULL,
    [Source]    TINYINT              DEFAULT ((0)) NOT NULL,
    [TransId]   [dbo].[pTransID]     NULL,
    [EntryNum]  INT                  NULL,
    [Descr]     [dbo].[pDescription] NULL,
    [Qty]       [dbo].[pDec]         NOT NULL,
    [QtyUOM]    [dbo].[pUom]         NULL,
    [HandleQty] [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [HandleUOM] [dbo].[pUom]         NULL,
    [ExtWeight] [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [RateClass] VARCHAR (7)          NULL,
    [HazMatYn]  BIT                  DEFAULT ((0)) NOT NULL,
    [NMFCNo]    VARCHAR (10)         NULL,
    [CF]        XML                  NULL,
    CONSTRAINT [PK_tblWMBOLDetail] PRIMARY KEY CLUSTERED ([BOLDtlRef] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWMBOLDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWMBOLDetail';

