CREATE TABLE [dbo].[tblCmActivity] (
    [ID]                BIGINT               NOT NULL,
    [ActTypeID]         BIGINT               NULL,
    [Descr]             [dbo].[pDescription] NULL,
    [EntryDate]         DATETIME             NULL,
    [Duration]          [dbo].[pDec]         CONSTRAINT [DF_tblCmActivity_Duration] DEFAULT ((0)) NOT NULL,
    [Value]             [dbo].[pDec]         CONSTRAINT [DF_tblCmActivity_Value] DEFAULT ((0)) NOT NULL,
    [ContactID]         BIGINT               NULL,
    [CampaignID]        BIGINT               NULL,
    [OpportunityID]     BIGINT               NULL,
    [TaskID]            BIGINT               NULL,
    [UserID]            [dbo].[pUserID]      NOT NULL,
    [Source]            TINYINT              CONSTRAINT [DF_tblCmActivity_Source] DEFAULT ((0)) NOT NULL,
    [Status]            TINYINT              CONSTRAINT [DF_tblCmActivity_Status] DEFAULT ((0)) NOT NULL,
    [ExternalReference] NVARCHAR (255)       NULL,
    [ExternalFilter]    NVARCHAR (MAX)       NULL,
    [Notes]             NVARCHAR (MAX)       NULL,
    [CF]                XML                  NULL,
    [ts]                ROWVERSION           NULL,
    CONSTRAINT [PK_tblCmActivity] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCmActivity_EntryDate]
    ON [dbo].[tblCmActivity]([EntryDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCmActivity_ContactID]
    ON [dbo].[tblCmActivity]([ContactID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmActivity';

