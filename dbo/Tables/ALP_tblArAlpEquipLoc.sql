CREATE TABLE [dbo].[ALP_tblArAlpEquipLoc] (
    [EquipLocID] INT          IDENTITY (1, 1) NOT NULL,
    [EquipLoc]   VARCHAR (30) NULL,
    [InactiveYN] BIT          CONSTRAINT [DF_tblArAlpEquipLoc_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_tblArAlpEquipLoc] PRIMARY KEY CLUSTERED ([EquipLocID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpEquipLoc] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpEquipLoc] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpEquipLoc] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpEquipLoc] TO PUBLIC
    AS [dbo];

