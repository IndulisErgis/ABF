CREATE TABLE [dbo].[tblPsRewardAccount] (
    [ID]             BIGINT           NOT NULL,
    [RewardNumber]   NVARCHAR (255)   NOT NULL,
    [Status]         TINYINT          NOT NULL,
    [Type]           TINYINT          NOT NULL,
    [Level]          TINYINT          NOT NULL,
    [EnrollmentDate] DATETIME         NOT NULL,
    [Name]           NVARCHAR (30)    NULL,
    [Address1]       NVARCHAR (30)    NULL,
    [Address2]       NVARCHAR (60)    NULL,
    [City]           NVARCHAR (30)    NULL,
    [Region]         NVARCHAR (10)    NULL,
    [Country]        [dbo].[pCountry] NULL,
    [PostalCode]     NVARCHAR (10)    NULL,
    [Phone]          NVARCHAR (15)    NULL,
    [Fax]            NVARCHAR (15)    NULL,
    [Email]          [dbo].[pEmail]   NULL,
    [Internet]       [dbo].[pWeb]     NULL,
    [Synched]        BIT              NOT NULL,
    [CF]             XML              NULL,
    [ts]             ROWVERSION       NULL,
    CONSTRAINT [PK_tblPsRewardAccount] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsRewardAccount_RewardNumber]
    ON [dbo].[tblPsRewardAccount]([RewardNumber] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsRewardAccount';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsRewardAccount';

