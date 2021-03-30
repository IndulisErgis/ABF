CREATE TABLE [dbo].[tblCMCampaignDtl] (
    [CampRef]     INT        NULL,
    [CampTypeRef] INT        NULL,
    [ts]          ROWVERSION NULL,
    [CF]          XML        NULL,
    [CampaignID]  BIGINT     NOT NULL,
    [CampTypeID]  BIGINT     NOT NULL,
    [ID]          BIGINT     NOT NULL,
    CONSTRAINT [PK_tblCmCampaignDtl] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblCMCampaignDtl_CampaignIDCampTypeID]
    ON [dbo].[tblCMCampaignDtl]([CampaignID] ASC, [CampTypeID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMCampaignDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMCampaignDtl';

