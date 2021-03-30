CREATE TABLE [dbo].[tblSmPeriodConversion] (
    [GlYear]   SMALLINT      NOT NULL,
    [GlPeriod] SMALLINT      NOT NULL,
    [BegDate]  DATETIME      NULL,
    [EndDate]  DATETIME      NULL,
    [ClosedGL] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedGL] DEFAULT ((0)) NULL,
    [ClosedAP] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedAP] DEFAULT ((0)) NULL,
    [ClosedAR] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedAR] DEFAULT ((0)) NULL,
    [ClosedIN] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedIN] DEFAULT ((0)) NULL,
    [ClosedSO] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedSO] DEFAULT ((0)) NULL,
    [ClosedPO] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedPO] DEFAULT ((0)) NULL,
    [ClosedBR] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedBR] DEFAULT ((0)) NULL,
    [ClosedPA] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedPA] DEFAULT ((0)) NULL,
    [ClosedFA] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedFA] DEFAULT ((0)) NULL,
    [ClosedBM] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedBM] DEFAULT ((0)) NULL,
    [ClosedPC] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedPC] DEFAULT ((0)) NULL,
    [ClosedJC] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedJC] DEFAULT ((0)) NULL,
    [ClosedMR] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedMR] DEFAULT ((0)) NULL,
    [ClosedMP] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedMP] DEFAULT ((0)) NULL,
    [ClosedMB] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedMB] DEFAULT ((0)) NULL,
    [ClosedMF] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedMF] DEFAULT ((0)) NULL,
    [ClosedF4] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedF4] DEFAULT ((0)) NULL,
    [ClosedF5] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedF5] DEFAULT ((0)) NULL,
    [Notes]    VARCHAR (255) NULL,
    [ts]       ROWVERSION    NULL,
    [ClosedSD] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedSD] DEFAULT ((0)) NOT NULL,
    [ClosedPS] BIT           CONSTRAINT [DF_tblSmPeriodConversion_ClosedPS] DEFAULT ((0)) NOT NULL,
    [ID]       INT           NOT NULL,
    CONSTRAINT [PK_tblSmPeriodConversion] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmPeriodConversion]
    ON [dbo].[tblSmPeriodConversion]([GlYear] ASC, [GlPeriod] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmPeriodConversion';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmPeriodConversion';

