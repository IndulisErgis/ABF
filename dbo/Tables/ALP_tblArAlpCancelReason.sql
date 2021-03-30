CREATE TABLE [dbo].[ALP_tblArAlpCancelReason] (
    [ReasonId]   INT           IDENTITY (1, 1) NOT NULL,
    [Reason]     VARCHAR (255) NULL,
    [Desc]       VARCHAR (255) NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblArAlpCancelReason_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpCancelReason] PRIMARY KEY CLUSTERED ([ReasonId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpCancelReason] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpCancelReason] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpCancelReason] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpCancelReason] TO PUBLIC
    AS [dbo];

