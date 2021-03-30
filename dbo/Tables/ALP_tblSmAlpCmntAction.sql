CREATE TABLE [dbo].[ALP_tblSmAlpCmntAction] (
    [ActionId]   INT           NOT NULL,
    [Action]     NVARCHAR (15) NULL,
    [Desc]       NVARCHAR (50) NULL,
    [InactiveYn] BIT           NOT NULL
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntAction] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntAction] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntAction] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntAction] TO PUBLIC
    AS [dbo];

