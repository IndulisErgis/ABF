﻿
CREATE PROCEDURE [dbo].[trav_tblSmCustomField_Delete] 
	@id int
AS
	SET NOCOUNT ON
	
	delete from dbo.tblSmCustomField
	where Id=@id
	
	RETURN
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_tblSmCustomField_Delete';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_tblSmCustomField_Delete';

