CREATE TABLE [dbo].[tblHrReviewType] (
    [ID]                  BIGINT        NOT NULL,
    [Description]         NVARCHAR (50) NOT NULL,
    [FrequencyTypeCodeID] BIGINT        NULL,
    [CF]                  XML           NULL,
    [ts]                  ROWVERSION    NULL,
    CONSTRAINT [PK_tblHrReviewType] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrReviewType_Description]
    ON [dbo].[tblHrReviewType]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrReviewType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrReviewType';

