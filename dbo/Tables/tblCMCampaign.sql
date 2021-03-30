CREATE TABLE [dbo].[tblCMCampaign] (
    [CampRef]         INT                  IDENTITY (1, 1) NOT NULL,
    [Descr]           [dbo].[pDescription] NOT NULL,
    [Status]          TINYINT              DEFAULT ((0)) NOT NULL,
    [StartDate]       DATETIME             NULL,
    [EndDate]         DATETIME             NULL,
    [Cost]            [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Pieces]          [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [ProjId]          [dbo].[pProjID]      NULL,
    [PhaseId]         [dbo].[pPhaseID]     NULL,
    [TaskId]          [dbo].[pTaskID]      NULL,
    [Notes]           NVARCHAR (MAX)       NULL,
    [ts]              ROWVERSION           NULL,
    [CF]              XML                  NULL,
    [ProjectDetailId] INT                  NULL,
    [ID]              BIGINT               NOT NULL,
    CONSTRAINT [PK_tblCmCampaign] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_CampaignDescr]
    ON [dbo].[tblCMCampaign]([Descr] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMCampaign';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMCampaign';

