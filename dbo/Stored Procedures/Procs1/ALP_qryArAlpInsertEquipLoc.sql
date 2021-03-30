
Create Procedure [dbo].[ALP_qryArAlpInsertEquipLoc]
	(
		@EquipLoc varchar(30),
		@InactiveYN bit
	)
AS
INSERT INTO dbo.ALP_tblArAlpEquipLoc
	(EquipLoc,
	InactiveYN)
	VALUES
	(@EquipLoc,
	@InactiveYN)