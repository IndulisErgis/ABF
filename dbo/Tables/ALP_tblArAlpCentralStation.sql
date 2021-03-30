CREATE TABLE [dbo].[ALP_tblArAlpCentralStation] (
    [CentralId]     INT           IDENTITY (1, 1) NOT NULL,
    [Central]       VARCHAR (255) NULL,
    [InactiveYN]    BIT           CONSTRAINT [DF_tblArAlpCentralStation_InactiveYN] DEFAULT ((0)) NULL,
    [Name]          VARCHAR (255) NULL,
    [Addr1]         VARCHAR (255) NULL,
    [Addr2]         VARCHAR (255) NULL,
    [City]          VARCHAR (255) NULL,
    [Region]        VARCHAR (50)  NULL,
    [Country]       VARCHAR (255) NULL,
    [PostalCode]    VARCHAR (10)  NULL,
    [IntlPrefix]    VARCHAR (6)   NULL,
    [Phone]         VARCHAR (15)  NULL,
    [Fax]           VARCHAR (15)  NULL,
    [Email]         TEXT          NULL,
    [Internet]      TEXT          NULL,
    [DealerNum]     VARCHAR (255) NULL,
    [CompOwnedYN]   BIT           CONSTRAINT [DF_tblArAlpCentralStation_CompOwnedYN] DEFAULT ((0)) NULL,
    [MonSoftwareYN] BIT           CONSTRAINT [DF_tblArAlpCentralStation_MonSoftwareYN] DEFAULT ((0)) NULL,
    [MonSoftwareId] INT           NULL,
    [ts]            ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpCentralStation] PRIMARY KEY CLUSTERED ([CentralId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpCentralStationU] ON [dbo].[ALP_tblArAlpCentralStation] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(CentralID))
BEGIN
	/* BEGIN tblArAlpSiteSys */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.CentralID = ALP_tblArAlpSiteSys.CentralId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.CentralID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpCentralStationU', @FldVal, 'ALP_tblArAlpSiteSys.CentralId')
		Set @Undo = 1
	END
	/* END tblArAlpSiteSys */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpCentralStationD] ON [dbo].[ALP_tblArAlpCentralStation] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSiteSys */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.CentralId = ALP_tblArAlpSiteSys.CentralId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.CentralId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpCentralStationD', @FldVal, 'ALP_tblArAlpSiteSys.CentralId')
    Set @Undo = 1
END
/* END tblArAlpSiteSys */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpCentralStation] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpCentralStation] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpCentralStation] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpCentralStation] TO PUBLIC
    AS [dbo];

