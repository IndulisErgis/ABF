CREATE TABLE [dbo].[tblHrIndActivity] (
    [ID]                 BIGINT         NOT NULL,
    [IndId]              [dbo].[pEmpID] NOT NULL,
    [ActivityTypeCodeId] BIGINT         NOT NULL,
    [ActivityDate]       DATETIME       NOT NULL,
    [Description]        NVARCHAR (50)  NULL,
    [Notes]              NVARCHAR (MAX) NULL,
    [CF]                 XML            NULL,
    [ts]                 ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndActivity] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndActivity_IndId]
    ON [dbo].[tblHrIndActivity]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndActivity';

