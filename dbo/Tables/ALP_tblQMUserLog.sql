CREATE TABLE [dbo].[ALP_tblQMUserLog] (
    [Counter]   INT           IDENTITY (1, 1) NOT NULL,
    [UserID]    VARCHAR (50)  NULL,
    [WrkStnID]  NVARCHAR (20) DEFAULT (host_name()) NOT NULL,
    [EntryDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    [LogType]   SMALLINT      DEFAULT ((1)) NOT NULL,
    [Descr]     VARCHAR (50)  NULL,
    [Notes]     VARCHAR (200) NULL,
    CONSTRAINT [PK_ALP_tblQMUserLog] PRIMARY KEY CLUSTERED ([Counter] ASC)
);

