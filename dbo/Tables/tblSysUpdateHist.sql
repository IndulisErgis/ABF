CREATE TABLE [dbo].[tblSysUpdateHist] (
    [HistID]   INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [VerInfo1] NVARCHAR (50)   NULL,
    [VerInfo2] NVARCHAR (50)   NULL,
    [UpdFile]  NVARCHAR (255)  NULL,
    [UpdDate]  DATETIME        CONSTRAINT [DF_tblSysUpdateHist_UpdDate] DEFAULT (getdate()) NOT NULL,
    [UName]    NVARCHAR (255)  CONSTRAINT [DF_tblSysUpdateHist_UName] DEFAULT (suser_sname()) NOT NULL,
    [WrkStnID] [dbo].[pUserID] CONSTRAINT [DF_tblSysUpdateHist_WrkStnID] DEFAULT (host_name()) NOT NULL,
    CONSTRAINT [PK_tblSysUpdateHist] PRIMARY KEY CLUSTERED ([HistID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysUpdateHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysUpdateHist';

