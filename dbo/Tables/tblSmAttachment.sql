CREATE TABLE [dbo].[tblSmAttachment] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [LinkType]     VARCHAR (10)    NOT NULL,
    [LinkKey]      NVARCHAR (255)  NOT NULL,
    [Status]       TINYINT         CONSTRAINT [DF_tblSmAttachment_Status] DEFAULT ((0)) NOT NULL,
    [Priority]     TINYINT         CONSTRAINT [DF_tblSmAttachment_Priority] DEFAULT ((0)) NOT NULL,
    [Description]  NVARCHAR (50)   NULL,
    [ExpireDate]   DATETIME        NULL,
    [EntryDate]    DATETIME        NOT NULL,
    [EnteredBy]    [dbo].[pUserID] NOT NULL,
    [Keywords]     NVARCHAR (255)  NULL,
    [Comment]      NTEXT           NULL,
    [FileName]     NTEXT           NULL,
    [CF]           XML             NULL,
    [ts]           ROWVERSION      NULL,
    [DocumentName] NVARCHAR (255)  NULL,
    [Document]     VARBINARY (MAX) NULL,
    CONSTRAINT [PK_tblSmAttachment] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmAttachment_EnteredBy]
    ON [dbo].[tblSmAttachment]([EnteredBy] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmAttachment_LinkTypeLinkId]
    ON [dbo].[tblSmAttachment]([LinkType] ASC, [LinkKey] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmAttachment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmAttachment';

