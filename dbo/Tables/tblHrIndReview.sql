CREATE TABLE [dbo].[tblHrIndReview] (
    [ID]               BIGINT         NOT NULL,
    [IndId]            [dbo].[pEmpID] NOT NULL,
    [ReviewTypeID]     BIGINT         NOT NULL,
    [ReviewDate]       DATETIME       NOT NULL,
    [NextReviewDate]   DATETIME       NULL,
    [NextReviewTypeID] BIGINT         NULL,
    [Notes]            NVARCHAR (MAX) NULL,
    [CF]               XML            NULL,
    [ts]               ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndReview] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndReview_IndId]
    ON [dbo].[tblHrIndReview]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndReview';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndReview';

