CREATE TABLE [dbo].[tblQMUserLog] (
    [Counter]   INT           IDENTITY (1, 1) NOT NULL,
    [UserID]    NVARCHAR (20) NOT NULL,
    [WrkStnID]  NVARCHAR (20) CONSTRAINT [DF_tblQMUserLog_WrkStnID] DEFAULT (host_name()) NOT NULL,
    [EntryDate] DATETIME      CONSTRAINT [DF_tblQMUserLog_EntryDate] DEFAULT (getdate()) NOT NULL,
    [LogType]   SMALLINT      CONSTRAINT [DF_tblQMUserLog_LogType] DEFAULT (1) NOT NULL,
    [Descr]     VARCHAR (50)  NULL,
    [Notes]     VARCHAR (200) NULL,
    CONSTRAINT [PK_tblQMUserLog] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);

