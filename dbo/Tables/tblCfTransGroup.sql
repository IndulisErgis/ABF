CREATE TABLE [dbo].[tblCfTransGroup] (
    [GroupId]    BIGINT               NOT NULL,
    [TransId]    BIGINT               NOT NULL,
    [GroupCode]  NVARCHAR (5)         NOT NULL,
    [Descr]      [dbo].[pDescription] NULL,
    [GroupOrder] INT                  NOT NULL,
    [CF]         XML                  NULL,
    [ts]         ROWVERSION           NULL,
    CONSTRAINT [PK_tblCfTransGroup] PRIMARY KEY CLUSTERED ([GroupId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblCfTransGroup_TransId_GroupCode]
    ON [dbo].[tblCfTransGroup]([TransId] ASC, [GroupCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransGroup';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransGroup';

