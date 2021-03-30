CREATE TABLE [dbo].[tblApTen99FormCode] (
    [FormCode] VARCHAR (1)  NOT NULL,
    [Desc]     VARCHAR (15) NULL,
    [ts]       ROWVERSION   NULL,
    PRIMARY KEY CLUSTERED ([FormCode] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99FormCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99FormCode';

