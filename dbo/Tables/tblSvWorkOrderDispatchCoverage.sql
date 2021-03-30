CREATE TABLE [dbo].[tblSvWorkOrderDispatchCoverage] (
    [ID]            BIGINT     NOT NULL,
    [DispatchID]    BIGINT     NOT NULL,
    [CoveredByType] TINYINT    NOT NULL,
    [CoveredById]   BIGINT     NOT NULL,
    [CF]            XML        NULL,
    [ts]            ROWVERSION NULL,
    CONSTRAINT [PK_tblSvWorkOrderDispatchCoverage] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderDispatchCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderDispatchCoverage';

