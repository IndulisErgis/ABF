

CREATE Procedure dbo.ALP_qryArAlpAppendEquipLoc
@Loc varchar (30)
AS
SET NOCOUNT ON
INSERT INTO ALP_tblArAlpEquipLoc ( EquipLoc )
VALUES(@Loc)