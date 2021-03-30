CREATE TABLE [dbo].[ALP_tblSmAlpReportParams] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [ReportName]    VARCHAR (100) NOT NULL,
    [FieldName]     VARCHAR (100) NOT NULL,
    [Property]      VARCHAR (100) NOT NULL,
    [PropValue]     VARCHAR (500) NOT NULL,
    [PropValueType] INT           NULL,
    [ConditionalYn] BIT           CONSTRAINT [DF_tblSmAlpReportParams_ConditionalYn] DEFAULT (0) NULL,
    [TestField]     VARCHAR (100) NULL,
    [TestProperty]  VARCHAR (100) NULL,
    [TestCompare]   VARCHAR (2)   NULL,
    [TestPropValue] VARCHAR (100) NULL,
    [ts]            ROWVERSION    NULL,
    CONSTRAINT [PK_tblSmAlpReportParams] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmAlpReportParams_RptName]
    ON [dbo].[ALP_tblSmAlpReportParams]([ReportName] ASC) WITH (FILLFACTOR = 80);


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblSmAlpReportParams] TO PUBLIC
    AS [dbo];

