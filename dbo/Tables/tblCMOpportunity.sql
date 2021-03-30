CREATE TABLE [dbo].[tblCMOpportunity] (
    [ID]            BIGINT               NOT NULL,
    [ContactID]     BIGINT               NOT NULL,
    [StatusID]      BIGINT               NOT NULL,
    [Descr]         [dbo].[pDescription] NULL,
    [OpenDate]      DATETIME             NULL,
    [CampaignID]    BIGINT               NULL,
    [ReferBy]       [dbo].[pDescription] NULL,
    [ReferDate]     DATETIME             NULL,
    [ReferID]       BIGINT               NULL,
    [Value]         [dbo].[pDec]         CONSTRAINT [DF_tblCmOpportunity_Value] DEFAULT ((0)) NOT NULL,
    [ProbCodeID]    BIGINT               NULL,
    [ResCodeID]     BIGINT               NULL,
    [TargetDate]    DATETIME             NULL,
    [CloseDate]     DATETIME             NULL,
    [UserID]        [dbo].[pUserID]      NOT NULL,
    [Notes]         NVARCHAR (MAX)       NULL,
    [Status]        TINYINT              CONSTRAINT [DF_tblCmOpportunity_Status] DEFAULT ((0)) NOT NULL,
    [LastUpdated]   DATETIME             NOT NULL,
    [LastUpdatedBy] [dbo].[pUserID]      NOT NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL,
    CONSTRAINT [PK_tblCmOpportunity] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCmOpportunity_ContactID]
    ON [dbo].[tblCMOpportunity]([ContactID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMOpportunity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMOpportunity';

