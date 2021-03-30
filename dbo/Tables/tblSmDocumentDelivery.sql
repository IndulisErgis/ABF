CREATE TABLE [dbo].[tblSmDocumentDelivery] (
    [ContactId]             VARCHAR (20)   NOT NULL,
    [FormId]                VARCHAR (10)   NOT NULL,
    [ContactType]           TINYINT        NOT NULL,
    [DeliveryType]          TINYINT        CONSTRAINT [DF_tblSmDocumentDelivery_DeliveryType] DEFAULT ((0)) NOT NULL,
    [DeliveryName]          VARCHAR (30)   NULL,
    [DeliveryDestination]   [dbo].[pEmail] NULL,
    [DeliveryNote]          VARCHAR (255)  NULL,
    [EmailAttachmentFormat] TINYINT        NULL,
    [IncludePaperCopy]      BIT            CONSTRAINT [DF_tblSmDocumentDelivery_IncludePaperCopy] DEFAULT ((0)) NOT NULL,
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [CF]                    XML            NULL,
    CONSTRAINT [PK_tblSmDocumentDelivery] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmDocumentDelivery';

