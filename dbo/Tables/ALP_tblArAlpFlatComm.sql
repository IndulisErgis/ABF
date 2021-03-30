CREATE TABLE [dbo].[ALP_tblArAlpFlatComm] (
    [FlatCommId] INT              IDENTITY (1, 1) NOT NULL,
    [FlatComm]   VARCHAR (10)     NULL,
    [Desc]       VARCHAR (255)    NULL,
    [Amount]     NUMERIC (20, 10) NULL,
    [InactiveYN] BIT              CONSTRAINT [DF_tblArAlpFlatComm_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblArAlpFlatComm] PRIMARY KEY CLUSTERED ([FlatCommId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpFlatComm] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpFlatComm] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpFlatComm] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpFlatComm] TO PUBLIC
    AS [dbo];

