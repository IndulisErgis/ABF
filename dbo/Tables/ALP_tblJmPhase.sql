CREATE TABLE [dbo].[ALP_tblJmPhase] (
    [PhaseId]    INT           IDENTITY (1, 1) NOT NULL,
    [Phase]      VARCHAR (10)  NULL,
    [Desc]       VARCHAR (255) NOT NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblJmPhase_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmPhase] PRIMARY KEY CLUSTERED ([PhaseId] ASC) WITH (FILLFACTOR = 80),
    UNIQUE NONCLUSTERED ([Phase] ASC),
    UNIQUE NONCLUSTERED ([Phase] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmPhase] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmPhase] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmPhase] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmPhase] TO PUBLIC
    AS [dbo];

