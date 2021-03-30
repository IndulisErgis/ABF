CREATE TABLE [dbo].[tblDRRunData] (
    [RunId]         [dbo].[pPostRun]  NOT NULL,
    [SeqNum]        INT               IDENTITY (1, 1) NOT NULL,
    [ItemId]        [dbo].[pItemID]   NOT NULL,
    [LocId]         [dbo].[pLocID]    NOT NULL,
    [TransDate]     DATETIME          NOT NULL,
    [TransType]     TINYINT           NOT NULL,
    [Source]        SMALLINT          NOT NULL,
    [VirtualYn]     BIT               CONSTRAINT [DF_tblDrRunData_VirtualYn] DEFAULT ((0)) NOT NULL,
    [Qty]           [dbo].[pDec]      CONSTRAINT [DF_tblDrRunData_Qty] DEFAULT ((0)) NOT NULL,
    [LinkID]        NCHAR (2)         NULL,
    [LinkIDSub]     NVARCHAR (8)      NULL,
    [LinkIDSubLine] INT               NULL,
    [CustId]        [dbo].[pCustID]   NULL,
    [VendorId]      [dbo].[pVendorID] NULL,
    [AssemblyId]    [dbo].[pItemID]   NULL,
    [AssemblyLocId] [dbo].[pLocID]    NULL,
    [CF]            XML               NULL,
    [ts]            ROWVERSION        NULL,
    CONSTRAINT [PK_tblDrRunData] PRIMARY KEY CLUSTERED ([RunId] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 90)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDRRunData';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDRRunData';

