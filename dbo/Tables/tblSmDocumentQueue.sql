CREATE TABLE [dbo].[tblSmDocumentQueue] (
    [ID]                  BIGINT            NOT NULL,
    [FormID]              NVARCHAR (10)     NOT NULL,
    [FunctionID]          UNIQUEIDENTIFIER  NOT NULL,
    [Subject]             NVARCHAR (255)    NULL,
    [DeliveryDestination] [dbo].[pEmail]    NULL,
    [DeliveryType]        TINYINT           NOT NULL,
    [DeliveryName]        NVARCHAR (30)     NULL,
    [EmailBody]           NVARCHAR (MAX)    NULL,
    [EmailAttachment]     VARBINARY (MAX)   NULL,
    [RunTime]             DATETIME          NOT NULL,
    [SentTime]            DATETIME          NULL,
    [ActivityID]          UNIQUEIDENTIFIER  NULL,
    [ContactID]           NVARCHAR (20)     NOT NULL,
    [UserID]              [dbo].[pUserID]   NOT NULL,
    [HostID]              [dbo].[pWrkStnID] NOT NULL,
    [DocumentNo]          NVARCHAR (255)    NULL,
    [KeyFieldName]        NVARCHAR (255)    NULL,
    [KeyFieldValue]       NVARCHAR (255)    NULL,
    [SourceID]            NVARCHAR (255)    NULL,
    [ModifiedBy]          [dbo].[pUserID]   NULL,
    [ModifiedTime]        DATETIME          NULL,
    [CF]                  XML               NULL,
    [ts]                  ROWVERSION        NULL,
    CONSTRAINT [PK_tblSmDocumentQueue] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentQueue';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentQueue';

