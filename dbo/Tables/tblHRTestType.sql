CREATE TABLE [dbo].[tblHRTestType] (
    [ID]                    BIGINT        NOT NULL,
    [Description]           NVARCHAR (50) NOT NULL,
    [RecertificationMonths] INT           CONSTRAINT [DF_tblHRTestType_RecertificationMonths] DEFAULT ((0)) NOT NULL,
    [CF]                    XML           NULL,
    [ts]                    ROWVERSION    NULL,
    CONSTRAINT [PK_tblHRTestType] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHRTestTypet_Description]
    ON [dbo].[tblHRTestType]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHRTestType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHRTestType';

