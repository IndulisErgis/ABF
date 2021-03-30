CREATE TABLE [dbo].[tblSmSMTPSettings] (
    [ID]          BIGINT         NOT NULL,
    [Description] NVARCHAR (255) NOT NULL,
    [Server]      NVARCHAR (255) NOT NULL,
    [Port]        INT            NOT NULL,
    [EnableSSL]   BIT            CONSTRAINT [DF_tblSmSMTPSettings_EnableSSL] DEFAULT ((0)) NOT NULL,
    [UserName]    NVARCHAR (255) NULL,
    [Password]    NVARCHAR (MAX) NULL,
    [Certificate] NVARCHAR (255) NULL,
    [SenderName]  NVARCHAR (255) NULL,
    [SenderEmail] [dbo].[pEmail] NOT NULL,
    [ReplyTo]     [dbo].[pEmail] NULL,
    [CF]          XML            NULL,
    [ts]          ROWVERSION     NULL,
    CONSTRAINT [PK_tblSmSMTPSettings] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Description]
    ON [dbo].[tblSmSMTPSettings]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmSMTPSettings';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmSMTPSettings';

