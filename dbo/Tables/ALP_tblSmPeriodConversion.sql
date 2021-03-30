CREATE TABLE [dbo].[ALP_tblSmPeriodConversion] (
    [AlpGlYear]   SMALLINT   NOT NULL,
    [AlpGlPeriod] SMALLINT   NOT NULL,
    [BegDate]     DATETIME   NULL,
    [EndDate]     DATETIME   NULL,
    [ClosedJM]    BIT        DEFAULT ((0)) NULL,
    [ts]          ROWVERSION NULL
);

