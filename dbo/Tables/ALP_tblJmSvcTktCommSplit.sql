CREATE TABLE [dbo].[ALP_tblJmSvcTktCommSplit] (
    [CommSplitID]  INT          IDENTITY (1, 1) NOT NULL,
    [TicketID]     INT          NOT NULL,
    [SalesRep]     VARCHAR (3)  NOT NULL,
    [CommSplitPct] FLOAT (53)   CONSTRAINT [DF_tblJmSvcTktCommSplit_CommSplitPct] DEFAULT (100) NOT NULL,
    [CommAmt]      [dbo].[pDec] CONSTRAINT [DF_tblJmSvcTktCommSplit_CommAmt] DEFAULT (0) NOT NULL,
    [JobShare]     FLOAT (53)   CONSTRAINT [DF_tblJmSvcTktCommSplit_JobShare] DEFAULT (100) NOT NULL,
    [Comments]     TEXT         NULL,
    [ts]           ROWVERSION   NOT NULL,
    [ModifiedBy]   VARCHAR (50) NULL,
    [ModifiedDate] DATETIME     NULL,
    CONSTRAINT [PK_tblJmSvcTktCommSplit] PRIMARY KEY CLUSTERED ([CommSplitID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktCommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktCommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ALP_tblJmSvcTktCommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktCommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktCommSplit] TO PUBLIC
    AS [dbo];

