CREATE TABLE [dbo].[ALP_tmpABF400_MailingListParameters] (
    [Id]                  INT      IDENTITY (1, 1) NOT NULL,
    [BillingDateExcluded] DATETIME NULL,
    CONSTRAINT [PK_tmpABF400_MailingListParameters] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpABF400_MailingListParameters] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpABF400_MailingListParameters] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpABF400_MailingListParameters] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpABF400_MailingListParameters] TO PUBLIC
    AS [dbo];

