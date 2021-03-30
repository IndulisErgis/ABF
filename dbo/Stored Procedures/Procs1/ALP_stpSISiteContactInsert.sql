CREATE PROCEDURE [dbo].[ALP_stpSISiteContactInsert]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/30/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@ContactID INT output,
	@SiteId INT = NULL,
	@Name VARCHAR(255) = NULL,
	@PrimaryYN BIT = NULL,
	@Title VARCHAR(255) = NULL,
	@IntlPrefix VARCHAR(6) = NULL,
	@PrimaryPhone VARCHAR(15) = NULL,
	@PrimaryExt VARCHAR(15) = NULL,
	@PrimaryType TINYINT = NULL,
	@OtherPhone VARCHAR(15) = NULL,
	@OtherExt VARCHAR(15) = NULL,
	@OtherType TINYINT = NULL,
	@Fax VARCHAR(15) = NULL,
	@Email TEXT = NULL,
	@Comments TEXT = NULL,
	@FirstName VARCHAR(50) = NULL,
	@CreateDate DATETIME = NULL,
	@LastUpdateDate DATETIME = NULL,
	@UploadDate DATETIME = NULL,
	@ModifiedBy VARCHAR(50) = NULL,
	@ModifiedDate DATETIME = NULL
)
AS
BEGIN
	INSERT INTO [dbo].[ALP_tblArAlpSiteContact]
	([SiteId], [Name], [PrimaryYN], [Title], [IntlPrefix], [PrimaryPhone], [PrimaryExt], [PrimaryType], [OtherPhone], [OtherExt], [OtherType], [Fax], [Email], [Comments], [FirstName], [CreateDate], [LastUpdateDate], [UploadDate], [ModifiedBy], [ModifiedDate])
	VALUES
	(	@SiteId,
		@Name,
		@PrimaryYN,
		@Title,
		@IntlPrefix,
		@PrimaryPhone,
		@PrimaryExt,
		@PrimaryType,
		@OtherPhone,
		@OtherExt,
		@OtherType,
		@Fax,
		@Email,
		@Comments,
		@FirstName,
		@CreateDate,
		@LastUpdateDate,
		@UploadDate,
		@ModifiedBy,
		@ModifiedDate)
	
	SET @ContactID = @@IDENTITY
END