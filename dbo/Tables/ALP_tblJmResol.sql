CREATE TABLE [dbo].[ALP_tblJmResol] (
    [ResolID]    INT          IDENTITY (1, 1) NOT NULL,
    [ResolCode]  VARCHAR (15) NULL,
    [Descr]      VARCHAR (50) NULL,
    [InactiveYN] BIT          CONSTRAINT [DF_tblJmResol_Inactive] DEFAULT (0) NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_tblJmResol] PRIMARY KEY CLUSTERED ([ResolID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmResol] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmResol] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmResol] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmResol] TO PUBLIC
    AS [dbo];

