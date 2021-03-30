CREATE TABLE [dbo].[tblHrReviewTypeCat] (
    [ID]           BIGINT        NOT NULL,
    [ReviewTypeID] BIGINT        NOT NULL,
    [Description]  NVARCHAR (50) NOT NULL,
    [Weight]       INT           CONSTRAINT [DF_tblHrReviewTypeCat_Weight] DEFAULT ((0)) NOT NULL,
    [CF]           XML           NULL,
    [ts]           ROWVERSION    NULL,
    CONSTRAINT [PK_tblHrReviewTypeCat] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrReviewTypeCat_ReviewTypeIDDescription]
    ON [dbo].[tblHrReviewTypeCat]([ReviewTypeID] ASC, [Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrReviewTypeCat';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrReviewTypeCat';

