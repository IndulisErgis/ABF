CREATE TABLE [dbo].[tblSvHistoryWorkOrderDispatchCoverage] (
    [ID]            BIGINT               NOT NULL,
    [DispatchID]    BIGINT               NOT NULL,
    [CoveredByType] TINYINT              NOT NULL,
    [CoveredById]   BIGINT               NOT NULL,
    [Description]   [dbo].[pDescription] NULL,
    [CoverageType]  TINYINT              CONSTRAINT [DF_tblSvHistoryWorkOrderDispatchCoverage_CoverageType] DEFAULT ((0)) NOT NULL,
    [BillingType]   NVARCHAR (10)        NULL,
    [StartDate]     DATETIME             NULL,
    [EndDate]       DATETIME             NULL,
    [ContractNo]    NVARCHAR (8)         NULL,
    [CF]            XML                  NULL,
    CONSTRAINT [PK_tblSvHistoryWorkOrderDispatchCoverage] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderDispatchCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderDispatchCoverage';

