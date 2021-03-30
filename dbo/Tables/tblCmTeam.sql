CREATE TABLE [dbo].[tblCmTeam] (
    [ID]     BIGINT          NOT NULL,
    [TeamId] NVARCHAR (50)   NOT NULL,
    [UserId] [dbo].[pUserID] NOT NULL,
    [CF]     XML             NULL,
    [ts]     ROWVERSION      NULL,
    CONSTRAINT [PK_tblCmTeam] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblCmTeam_TeamIdUserId]
    ON [dbo].[tblCmTeam]([TeamId] ASC, [UserId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmTeam';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmTeam';

