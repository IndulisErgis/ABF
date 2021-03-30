CREATE TABLE [dbo].[tblSysUserSettings] (
    [ID]         INT              IDENTITY (1, 1) NOT NULL,
    [UserID]     [dbo].[pUserID]  NOT NULL,
    [FunctionID] UNIQUEIDENTIFIER NOT NULL,
    [Store]      VARBINARY (MAX)  NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblSysUserSettings] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UI_tblSysUserSettings_UserIDFunctionID]
    ON [dbo].[tblSysUserSettings]([UserID] ASC, [FunctionID] ASC)
    INCLUDE([Store], [ts]);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysUserSettings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysUserSettings';

