CREATE TABLE [dbo].[tblCMTask] (
    [TaskRef]           INT                  IDENTITY (1, 1) NOT NULL,
    [TaskTypeRef]       BIGINT               NULL,
    [RecType]           SMALLINT             DEFAULT ((0)) NOT NULL,
    [ShowWhen]          SMALLINT             DEFAULT ((-1)) NOT NULL,
    [SourceType]        SMALLINT             NULL,
    [SourceRef]         INT                  NULL,
    [EntryDate]         DATETIME             NULL,
    [ActionDate]        DATETIME             NULL,
    [CompletedDate]     DATETIME             NULL,
    [Descr]             [dbo].[pDescription] NULL,
    [UserID]            [dbo].[pUserID]      NOT NULL,
    [AssignedToUserID]  [dbo].[pUserID]      NOT NULL,
    [CompletedByUserId] [dbo].[pUserID]      NULL,
    [Notes]             NVARCHAR (MAX)       NULL,
    [ts]                ROWVERSION           NULL,
    [CF]                XML                  NULL,
    [StartDate]         DATETIME             NULL,
    [Status]            TINYINT              CONSTRAINT [DF_tblCmTask_Status] DEFAULT ((0)) NOT NULL,
    [Priority]          TINYINT              CONSTRAINT [DF_tblCmTask_Priority] DEFAULT ((0)) NOT NULL,
    [ContactID]         BIGINT               NULL,
    [CampaignID]        BIGINT               NULL,
    [OpportunityID]     BIGINT               NULL,
    [TaskTypeID]        BIGINT               NOT NULL,
    [ID]                BIGINT               NOT NULL,
    [LastUpdated]       DATETIME             NOT NULL,
    [LastUpdatedBy]     [dbo].[pUserID]      NOT NULL,
    CONSTRAINT [PK_tblCmTask] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMTask';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMTask';

