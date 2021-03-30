CREATE TABLE [dbo].[tblSmPrintDetail] (
    [SeqNum]     INT               IDENTITY (1, 1) NOT NULL,
    [FormId]     NVARCHAR (50)     NOT NULL,
    [HostId]     [dbo].[pWrkStnID] CONSTRAINT [DF_tblSmPrintDetail_HostId] DEFAULT ('{ALL}') NOT NULL,
    [CopyText]   NVARCHAR (50)     NULL,
    [PrintOrder] TINYINT           CONSTRAINT [DF_tblSmPrintDetail_PrintOrder] DEFAULT ((1)) NOT NULL,
    [DeviceName] NVARCHAR (255)    CONSTRAINT [DF_tblSmPrintDetail_DeviceName] DEFAULT (N'{Default}') NOT NULL,
    [Disabled]   BIT               CONSTRAINT [DF_tblSmPrintDetail_Disabled] DEFAULT ((0)) NOT NULL,
    [ts]         ROWVERSION        NULL,
    [Tray]       NVARCHAR (255)    NULL,
    [CF]         XML               NULL,
    CONSTRAINT [PK_tblSmPrintDetail] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmPrintDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmPrintDetail';

