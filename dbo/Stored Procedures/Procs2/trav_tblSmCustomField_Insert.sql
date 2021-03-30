
CREATE PROCEDURE [dbo].[trav_tblSmCustomField_Insert] 
	@name nvarchar(50),
	@def xml,
	@id int out
AS
	SET NOCOUNT ON
	
	insert into dbo.tblSmcustomField(FieldName, Definition)
	values (@name, @def)
	
	set @id = SCOPE_IDENTITY()
	
	RETURN
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_tblSmCustomField_Insert';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_tblSmCustomField_Insert';

