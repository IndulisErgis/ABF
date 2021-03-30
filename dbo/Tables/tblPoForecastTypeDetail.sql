CREATE TABLE [dbo].[tblPoForecastTypeDetail] (
    [ForecastType] VARCHAR (10) NOT NULL,
    [Period]       SMALLINT     CONSTRAINT [DF__tblPoFore__Perio__7898B843] DEFAULT (0) NOT NULL,
    [WeightFactor] [dbo].[pDec] CONSTRAINT [DF__tblPoFore__Weigh__798CDC7C] DEFAULT (0) NULL,
    [ts]           ROWVERSION   NULL,
    [CF]           XML          NULL,
    CONSTRAINT [PK__tblPoForecastTyp__7993056A] PRIMARY KEY CLUSTERED ([ForecastType] ASC, [Period] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoForecastTypeDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoForecastTypeDetail';

