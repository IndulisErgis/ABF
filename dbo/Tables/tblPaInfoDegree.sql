﻿CREATE TABLE [dbo].[tblPaInfoDegree] (
    [Id]                NVARCHAR (6)  NOT NULL,
    [DegreeDescription] NVARCHAR (25) NULL,
    [CF]                XML           NULL,
    [ts]                ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaInfoDegree] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaInfoDegree';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaInfoDegree';

