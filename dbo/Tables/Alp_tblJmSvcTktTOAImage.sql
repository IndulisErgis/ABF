CREATE TABLE [dbo].[Alp_tblJmSvcTktTOAImage] (
    [ImageId]     INT           IDENTITY (1, 1) NOT NULL,
    [TicketId]    INT           NOT NULL,
    [SystemId]    INT           NULL,
    [Filename]    VARCHAR (255) NOT NULL,
    [Filepath]    VARCHAR (255) NOT NULL,
    [Title]       VARCHAR (255) NOT NULL,
    [Description] VARCHAR (255) NULL,
    [Taken]       DATETIME      NOT NULL,
    [Uploaded]    DATETIME      NOT NULL,
    [Visible]     BIT           CONSTRAINT [DF_Alp_tblJmSvcTktImage_Visible] DEFAULT ((1)) NOT NULL,
    [Thumbnail]   VARCHAR (255) NOT NULL,
    [isSignature] BIT           CONSTRAINT [DF_Alp_tblJmSvcTktTOAImage_isSignature] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Alp_tblJmSvcTktImage] PRIMARY KEY CLUSTERED ([ImageId] ASC)
);

