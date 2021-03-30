CREATE TABLE [dbo].[tblHrIndReviewByCategory] (
    [ReviewId]        BIGINT          NOT NULL,
    [ReviewTypeCatID] BIGINT          NOT NULL,
    [Weight]          INT             CONSTRAINT [DF_tblHrIndReviewByCategory_Weight] DEFAULT ((0)) NOT NULL,
    [Rating]          DECIMAL (10, 2) CONSTRAINT [DF_tblHrIndReviewByCategory_Rating] DEFAULT ((0)) NOT NULL,
    [Score]           INT             CONSTRAINT [DF_tblHrIndReviewByCategory_Score] DEFAULT ((0)) NOT NULL,
    [Notes]           NVARCHAR (MAX)  NULL,
    [CF]              XML             NULL,
    [ts]              ROWVERSION      NULL,
    CONSTRAINT [PK_tblHrIndReviewByCategory] PRIMARY KEY CLUSTERED ([ReviewId] ASC, [ReviewTypeCatID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndReviewByCategory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndReviewByCategory';

