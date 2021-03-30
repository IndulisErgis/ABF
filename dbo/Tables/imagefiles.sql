CREATE TABLE [dbo].[imagefiles] (
    [File Name]              NVARCHAR (255) NULL,
    [File Path]              NVARCHAR (255) NULL,
    [File Size ( in KBs )]   FLOAT (53)     NULL,
    [File Type]              NVARCHAR (255) NULL,
    [Last Modified]          NVARCHAR (255) NULL,
    [Click to Open the File] NVARCHAR (255) NULL,
    [TicketId]               INT            NULL,
    [Filename]               VARCHAR (255)  NULL,
    [Filepath]               VARCHAR (255)  NULL,
    [Title]                  VARCHAR (255)  NULL,
    [Description]            VARCHAR (255)  NULL,
    [Taken]                  DATETIME       NULL,
    [Uploaded]               DATETIME       NULL,
    [Thumbnail]              VARCHAR (255)  NULL,
    [isSignature]            BIT            NULL
);

