CREATE TABLE [dbo].[tblSmTransLink] (
    [SeqNum]        INT           IDENTITY (1, 1) NOT NULL,
    [SourceType]    SMALLINT      NOT NULL,
    [DestType]      SMALLINT      NOT NULL,
    [DropShipYn]    BIT           NOT NULL,
    [ts]            ROWVERSION    NULL,
    [SourceId]      VARCHAR (255) NOT NULL,
    [DestId]        VARCHAR (255) NOT NULL,
    [SourceStatus]  TINYINT       CONSTRAINT [DF_tblSmTransLink_SourceStatus] DEFAULT ((0)) NOT NULL,
    [DestStatus]    TINYINT       CONSTRAINT [DF_tblSmTransLink_DestStatus] DEFAULT ((0)) NOT NULL,
    [TransLinkType] TINYINT       CONSTRAINT [DF_tblSmTransLink_TransLinkType] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblSmTransLink] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTransLink';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTransLink';

