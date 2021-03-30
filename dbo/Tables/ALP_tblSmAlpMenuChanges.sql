CREATE TABLE [dbo].[ALP_tblSmAlpMenuChanges] (
    [MenuId]     INT          IDENTITY (1, 1) NOT NULL,
    [HideYn]     BIT          CONSTRAINT [DF_tblSmAlpMenuChanges_HideYn] DEFAULT (0) NULL,
    [Descr]      VARCHAR (50) NULL,
    [OrigDescr]  VARCHAR (50) NULL,
    [OrigHideYn] BIT          CONSTRAINT [DF_tblSmAlpMenuChanges_OrigHideYn] DEFAULT (0) NULL,
    [UpdatedYn]  BIT          CONSTRAINT [DF_tblSmAlpMenuChanges_UpdatedYn] DEFAULT (0) NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_tblSmAlpMenuChanges] PRIMARY KEY CLUSTERED ([MenuId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblSmAlpMenuChanges] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblSmAlpMenuChanges] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblSmAlpMenuChanges] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblSmAlpMenuChanges] TO PUBLIC
    AS [dbo];

