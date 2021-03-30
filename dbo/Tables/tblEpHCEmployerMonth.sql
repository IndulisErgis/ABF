CREATE TABLE [dbo].[tblEpHCEmployerMonth] (
    [ID]                  BIGINT       NOT NULL,
    [HeaderId]            BIGINT       NOT NULL,
    [PaMonth]             TINYINT      NOT NULL,
    [MinCoverage]         NVARCHAR (1) NOT NULL,
    [FullTimeEmployees]   INT          NOT NULL,
    [TotalEmployees]      INT          NOT NULL,
    [GroupIndicator]      NVARCHAR (1) NOT NULL,
    [TransitionIndicator] NVARCHAR (1) NOT NULL,
    [CF]                  XML          NULL,
    [ts]                  ROWVERSION   NULL,
    CONSTRAINT [PK_tblEpHCEmployerMonth] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployerMonth';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployerMonth';

