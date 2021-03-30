CREATE TABLE [dbo].[ALP_tblIMPProject] (
    [ImportProjectId] INT           IDENTITY (1, 1) NOT NULL,
    [Source]          VARCHAR (30)  NULL,
    [Source_Id]       VARCHAR (20)  NULL,
    [Source_Desc]     VARCHAR (200) NULL,
    [Source_Rep]      VARCHAR (50)  NULL,
    [ImportDate]      DATETIME      NULL,
    [Status]          INT           NULL,
    [IsValidate]      BIT           NULL,
    [ValidatedBy]     VARCHAR (50)  NULL,
    [ValidatedDate]   DATETIME      NULL,
    [CreatedBy]       VARCHAR (50)  NOT NULL,
    [CreatedDate]     DATETIME      NOT NULL,
    [ts]              ROWVERSION    NULL,
    [BillingNotes]    TEXT          NULL,
    [ProjectNotes]    TEXT          NULL,
    [PartsOnly]       BIT           CONSTRAINT [DF_ALP_tblIMPProject_PartsOnly] DEFAULT ((0)) NULL,
    [PONum]           VARCHAR (15)  NULL,
    CONSTRAINT [PK_Alp_tblIMPProject] PRIMARY KEY CLUSTERED ([ImportProjectId] ASC)
);

