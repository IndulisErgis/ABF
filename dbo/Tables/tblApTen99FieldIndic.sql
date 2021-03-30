CREATE TABLE [dbo].[tblApTen99FieldIndic] (
    [IndicatorId] VARCHAR (1)  NOT NULL,
    [Desc]        VARCHAR (30) NULL,
    [Limit]       [dbo].[pDec] CONSTRAINT [DF__tblApTen9__Limit__0DBDF25B] DEFAULT (0) NULL,
    [ts]          ROWVERSION   NULL,
    [CF]          XML          NULL,
    CONSTRAINT [PK__tblApTen99FieldI__0FEC5ADD] PRIMARY KEY CLUSTERED ([IndicatorId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99FieldIndic';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99FieldIndic';

