CREATE TABLE [dbo].[tblSoCustLevel] (
    [CustLevel] VARCHAR (10) NOT NULL,
    [Descr]     VARCHAR (35) NULL,
    [ts]        ROWVERSION   NULL,
    [CF]        XML          NULL,
    PRIMARY KEY CLUSTERED ([CustLevel] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoCustLevel] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoCustLevel] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoCustLevel] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoCustLevel] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoCustLevel';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoCustLevel';

