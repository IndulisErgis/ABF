CREATE TABLE [dbo].[ALP_tmpCSBSComparisonResultsErrors] (
    [ID]             BIGINT       IDENTITY (1, 1) NOT NULL,
    [Transmitter]    VARCHAR (36) NOT NULL,
    [ErrorCode]      VARCHAR (4)  NULL,
    [BSCustId]       VARCHAR (50) NULL,
    [BSSiteID]       VARCHAR (50) NULL,
    [CSCustId]       VARCHAR (50) NULL,
    [CSSiteId]       VARCHAR (50) NULL,
    [BSMonStartDate] VARCHAR (50) NULL,
    [CSHasSignalsYn] CHAR (1)     NULL,
    CONSTRAINT [PK_tmpCSBSComparisonResultsErrors] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];

