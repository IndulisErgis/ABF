CREATE TABLE [dbo].[ALP_tblSmAlpCmntCat] (
    [CatId]      INT           NOT NULL,
    [Cat]        NVARCHAR (15) NULL,
    [Desc]       NVARCHAR (50) NULL,
    [InactiveYn] BIT           NOT NULL
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntCat] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntCat] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntCat] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblSmAlpCmntCat] TO PUBLIC
    AS [dbo];

