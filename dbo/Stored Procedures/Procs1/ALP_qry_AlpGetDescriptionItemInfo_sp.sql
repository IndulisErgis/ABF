
CREATE PROCEDURE [dbo].[ALP_qry_AlpGetDescriptionItemInfo_sp]
	@PartID VARCHAR(24) = NULL
AS
	/*
		Created by JM for EFI#1893 on 06/08/2010
	*/
SELECT * FROM dbo.ALP_lkpArAlpDescriptionItem WHERE ItemCode = @PartID