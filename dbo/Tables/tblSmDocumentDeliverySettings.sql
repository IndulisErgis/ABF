CREATE TABLE [dbo].[tblSmDocumentDeliverySettings] (
    [FormID]          NVARCHAR (10)   NOT NULL,
    [SMTPID]          BIGINT          NULL,
    [Subject]         NVARCHAR (255)  NULL,
    [EmailBody]       NVARCHAR (MAX)  NULL,
    [EmailAttachment] VARBINARY (MAX) NULL,
    [SendAsHtml]      BIT             CONSTRAINT [DF_tblSmDocumentDeliverySettings_SendAsHtml] DEFAULT ((1)) NOT NULL,
    [FaxCoverPage]    VARBINARY (MAX) NULL,
    [AutoSend]        BIT             CONSTRAINT [DF_tblSmDocumentDeliverySettings_AutoSend] DEFAULT ((1)) NOT NULL,
    [CF]              XML             NULL,
    [ts]              ROWVERSION      NULL,
    [DocumentName]    NVARCHAR (255)  NULL,
    CONSTRAINT [PK_tblSmDocumentDeliverySettings] PRIMARY KEY CLUSTERED ([FormID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentDeliverySettings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentDeliverySettings';

