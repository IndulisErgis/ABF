CREATE TABLE [dbo].[tblCmContactGroup] (
    [ID]     BIGINT               NOT NULL,
    [Descr]  [dbo].[pDescription] NOT NULL,
    [Status] TINYINT              CONSTRAINT [DF_tblCmContactGroup_Status] DEFAULT ((0)) NOT NULL,
    [Filter] NVARCHAR (MAX)       NULL,
    [UserID] [dbo].[pUserID]      NOT NULL,
    [Type]   TINYINT              NOT NULL,
    [CF]     XML                  NULL,
    [ts]     ROWVERSION           NULL,
    CONSTRAINT [PK_tblCmContactGroup] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblCmContactGroup_DescrUserID]
    ON [dbo].[tblCmContactGroup]([Descr] ASC, [UserID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactGroup';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactGroup';

