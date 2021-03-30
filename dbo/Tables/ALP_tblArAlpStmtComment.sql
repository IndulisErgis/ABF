CREATE TABLE [dbo].[ALP_tblArAlpStmtComment] (
    [GroupCode]        VARCHAR (1)   NOT NULL,
    [GCStmtComment]    TEXT          NULL,
    [CloseDateComment] VARCHAR (150) NULL,
    CONSTRAINT [PK_ALP_tblArAlpStmtComment] PRIMARY KEY CLUSTERED ([GroupCode] ASC)
);

