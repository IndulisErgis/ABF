CREATE TABLE [dbo].[tblCmContactMethodType] (
    [ID]    BIGINT               NOT NULL,
    [Type]  SMALLINT             NOT NULL,
    [Descr] [dbo].[pDescription] NOT NULL,
    [CF]    XML                  NULL,
    [ts]    ROWVERSION           NULL,
    CONSTRAINT [PK_tblCmContactMethodType] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblCmContactMethodType_Descr]
    ON [dbo].[tblCmContactMethodType]([Descr] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactMethodType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactMethodType';

