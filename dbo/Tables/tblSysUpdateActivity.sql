CREATE TABLE [dbo].[tblSysUpdateActivity] (
    [ActivityId]  UNIQUEIDENTIFIER NOT NULL,
    [Description] NVARCHAR (MAX)   NULL,
    [UpdDate]     DATETIME         CONSTRAINT [DF_tblSysUpdateActivity_UpdDate] DEFAULT (getdate()) NOT NULL,
    [UName]       NVARCHAR (128)   CONSTRAINT [DF_tblSysUpdateActivity_UName] DEFAULT (suser_sname()) NOT NULL,
    [WrkStnID]    NVARCHAR (128)   CONSTRAINT [DF_tblSysUpdateActivity_WrkStnID] DEFAULT (host_name()) NOT NULL,
    CONSTRAINT [PK_tblSysUpdateActivity] PRIMARY KEY NONCLUSTERED ([ActivityId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysUpdateActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysUpdateActivity';

