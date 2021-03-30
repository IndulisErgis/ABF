CREATE TABLE [dbo].[ALP_tblJmSvcTktUDF] (
    [TktUDFId] INT           IDENTITY (1, 1) NOT NULL,
    [TicketId] INT           NULL,
    [UDFId]    INT           NULL,
    [Value]    VARCHAR (255) NULL,
    [ts]       ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmSvcTktUDF] PRIMARY KEY CLUSTERED ([TktUDFId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktUDF] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktUDF] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktUDF] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktUDF] TO PUBLIC
    AS [dbo];

