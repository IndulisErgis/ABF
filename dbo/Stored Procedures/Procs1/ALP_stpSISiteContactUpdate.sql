CREATE PROCEDURE [dbo].[ALP_stpSISiteContactUpdate]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/30/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@ContactID INT,
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
	UPDATE [sc]
	SET	[SiteId] = @SiteId,
		[Name] = @Name,
		[PrimaryYN] = @PrimaryYN,
		[Title] = @Title,
		[IntlPrefix] = @IntlPrefix,
		[PrimaryPhone] = @PrimaryPhone,
		[PrimaryExt] = @PrimaryExt,
		[PrimaryType] = @PrimaryType,
		[OtherPhone] = @OtherPhone,
		[OtherExt] = @OtherExt,
		[OtherType] = @OtherType,
		[Fax] = @Fax,
		[Email] = @Email,
		[Comments] = @Comments,
		[FirstName] = @FirstName,
		[CreateDate] = @CreateDate,
		[LastUpdateDate] = @LastUpdateDate,
		[UploadDate] = @UploadDate,
		[ModifiedBy] = @ModifiedBy,
		[ModifiedDate] = @ModifiedDate
	FROM [dbo].[ALP_tblArAlpSiteContact] AS [sc]
	WHERE	[sc].[ContactID] = @ContactID
END