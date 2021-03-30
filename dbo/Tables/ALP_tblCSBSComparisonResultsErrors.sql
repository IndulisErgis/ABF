CREATE TABLE [dbo].[ALP_tblCSBSComparisonResultsErrors] (
    [ID]             BIGINT       IDENTITY (1, 1) NOT NULL,
    [Transmitter]    VARCHAR (36) NOT NULL,
    [ErrorCode]      VARCHAR (4)  NULL,
    [BSCustId]       VARCHAR (50) NULL,
    [BSSiteID]       VARCHAR (50) NULL,
    [CSCustId]       VARCHAR (50) NULL,
    [CSSiteId]       VARCHAR (50) NULL,
    [BSMonStartDate] VARCHAR (50) NULL,
    [CSHasSignalsYn] CHAR (1)     NULL,
    CONSTRAINT [PK_tblCSBSComparisonResultsErrors] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_tblCSBSComparisonResultsErrors_tblCSBSComparisonResults] FOREIGN KEY ([Transmitter]) REFERENCES [dbo].[ALP_tblCSBSComparisonResults] ([Transmitter])
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCSBSComparisonResultsErrors_ErrorCode]
    ON [dbo].[ALP_tblCSBSComparisonResultsErrors]([ErrorCode] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_tblCSBSComparisonResultsErrors_Trans]
    ON [dbo].[ALP_tblCSBSComparisonResultsErrors]([Transmitter] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSBSComparisonResultsErrors] TO PUBLIC
    AS [dbo];

