CREATE TABLE [dbo].[tblSvActivityStatus] (
    [ID]                     TINYINT              NOT NULL,
    [Description]            [dbo].[pDescription] NOT NULL,
    [ActivityDispatchStatus] TINYINT              NOT NULL,
    [Action]                 TINYINT              NOT NULL,
    [Sequence]               TINYINT              NOT NULL,
    [CF]                     XML                  NULL,
    [ts]                     ROWVERSION           NULL,
    [StatusColor]            INT                  NULL,
    CONSTRAINT [PK_tblSvActivityStatus] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSvActivityStatus]
    ON [dbo].[tblSvActivityStatus]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvActivityStatus';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvActivityStatus';

