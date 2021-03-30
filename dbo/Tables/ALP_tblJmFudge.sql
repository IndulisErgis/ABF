CREATE TABLE [dbo].[ALP_tblJmFudge] (
    [FudgeId]     INT           IDENTITY (1, 1) NOT NULL,
    [FudgeFactor] [dbo].[pDec]  NULL,
    [Desc]        VARCHAR (255) NULL,
    [InactiveYN]  BIT           CONSTRAINT [DF_tblJmFudge_InactiveYN] DEFAULT (0) NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmFudge] PRIMARY KEY CLUSTERED ([FudgeId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmFudge] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmFudge] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmFudge] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmFudge] TO PUBLIC
    AS [dbo];

