CREATE TABLE [dbo].[tblSmDocumentStore] (
    [ID]            BIGINT           NOT NULL,
    [ActivityID]    UNIQUEIDENTIFIER NOT NULL,
    [SourceID]      NVARCHAR (255)   NULL,
    [Reference]     NVARCHAR (255)   NOT NULL,
    [FormID]        NVARCHAR (20)    NULL,
    [DocumentNo]    NVARCHAR (255)   NOT NULL,
    [KeyFieldName]  NVARCHAR (255)   NOT NULL,
    [KeyFieldValue] NVARCHAR (255)   NOT NULL,
    [Store]         VARBINARY (MAX)  NOT NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblSmDocumentStore] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmDocumentStore_SourceID]
    ON [dbo].[tblSmDocumentStore]([SourceID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmDocumentStore_ActivityID]
    ON [dbo].[tblSmDocumentStore]([ActivityID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentStore';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentStore';

