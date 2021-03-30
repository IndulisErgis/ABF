CREATE TABLE [dbo].[ALP_tblCSBSComparisonResults] (
    [Transmitter] VARCHAR (36) NOT NULL,
    CONSTRAINT [PK_tblCSBSComparisonResults] PRIMARY KEY CLUSTERED ([Transmitter] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResults] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResults] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResults] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResults] TO PUBLIC
    AS [dbo];

