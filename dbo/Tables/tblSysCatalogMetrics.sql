CREATE TABLE [dbo].[tblSysCatalogMetrics] (
    [CatalogDefId]  BIGINT         NOT NULL,
    [LastRefreshed] DATETIME       NULL,
    [LastValue]     NVARCHAR (MAX) NULL,
    [ts]            ROWVERSION     NULL,
    [ScheduleYN]    BIT            CONSTRAINT [DF_tblSysCatalogMetrics_ScheduleYN] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSysCatalogMetrics] PRIMARY KEY CLUSTERED ([CatalogDefId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCatalogMetrics';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCatalogMetrics';

