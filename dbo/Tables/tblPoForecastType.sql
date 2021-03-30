CREATE TABLE [dbo].[tblPoForecastType] (
    [ForecastType] VARCHAR (10) NOT NULL,
    [Descr]        VARCHAR (35) NULL,
    [AdjFactor]    [dbo].[pDec] CONSTRAINT [DF__tblPoFore__AdjFa__75BC4B98] DEFAULT (0) NULL,
    [ts]           ROWVERSION   NULL,
    [CF]           XML          NULL,
    CONSTRAINT [PK__tblPoForecastTyp__789EE131] PRIMARY KEY CLUSTERED ([ForecastType] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoForecastType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoForecastType';

