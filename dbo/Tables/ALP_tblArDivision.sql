CREATE TABLE [dbo].[ALP_tblArDivision] (
    [DivisionId] INT           IDENTITY (1, 1) NOT NULL,
    [Division]   VARCHAR (10)  NULL,
    [Name]       VARCHAR (255) NULL,
    [GlSegId]    VARCHAR (12)  NULL,
    [InactiveYN] BIT           DEFAULT ((0)) NULL,
    [ts]         ROWVERSION    NULL
);

