CREATE TABLE [dbo].[tblCmTaskTemplateDetail] (
    [ID]               BIGINT               NOT NULL,
    [TemplateId]       NVARCHAR (20)        NOT NULL,
    [TaskTypeID]       BIGINT               NOT NULL,
    [Descr]            [dbo].[pDescription] NULL,
    [AssignedToUserID] [dbo].[pUserID]      NOT NULL,
    [Status]           TINYINT              CONSTRAINT [DF_tblCmTaskTemplateDetail_Status] DEFAULT ((0)) NOT NULL,
    [Priority]         TINYINT              CONSTRAINT [DF_tblCmTaskTemplateDetail_Priority] DEFAULT ((0)) NOT NULL,
    [Notes]            NVARCHAR (MAX)       NULL,
    [CF]               XML                  NULL,
    [ts]               ROWVERSION           NULL,
    CONSTRAINT [PK_tblCmTaskTemplateDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmTaskTemplateDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmTaskTemplateDetail';

