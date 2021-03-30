CREATE TABLE [dbo].[tblPcPrepareOverhead] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [ActivityId]   INT          NOT NULL,
    [OhAllCode]    NVARCHAR (6) NOT NULL,
    [FiscalPeriod] SMALLINT     NOT NULL,
    [FiscalYear]   SMALLINT     NOT NULL,
    [TransDate]    DATETIME     NOT NULL,
    [CurrOH]       [dbo].[pDec] NOT NULL,
    [CF]           XML          NULL,
    [ts]           ROWVERSION   NULL,
    CONSTRAINT [PK_tblPcPrepareOverhead] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcPrepareOverhead';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcPrepareOverhead';

