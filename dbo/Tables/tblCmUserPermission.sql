CREATE TABLE [dbo].[tblCmUserPermission] (
    [ID]             BIGINT          NOT NULL,
    [TeamId]         NVARCHAR (50)   NOT NULL,
    [UserId]         [dbo].[pUserID] NOT NULL,
    [TaskPermission] TINYINT         NOT NULL,
    [CF]             XML             NULL,
    [ts]             ROWVERSION      NULL,
    CONSTRAINT [PK_tblCmUserPermission] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblCmUserPermission_TeamIdUserId]
    ON [dbo].[tblCmUserPermission]([TeamId] ASC, [UserId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmUserPermission';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmUserPermission';

