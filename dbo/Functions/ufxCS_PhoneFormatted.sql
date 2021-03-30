

CREATE FUNCTION dbo.ufxCS_PhoneFormatted
-- This function returns the complete phone number as a string
(
	@Type varchar(3) = '',
	@AreaCode varchar(4) = '',
	@Phone varchar(80) = '',
	@Ext varchar(6) = ''
)
RETURNS varchar(90)
AS  
BEGIN
DECLARE @PhoneFormatted as varchar(90)
DECLARE @AreaFormatted varchar(7)
DECLARE @ExtFormatted varchar(9)
SET @AreaFormatted = ''
IF @AreaCode <> '' AND @AreaCode is not null 
   BEGIN
	SET @AreaFormatted = '(' + @AreaCode + ') '
   END
SET @ExtFormatted = ''
IF @Ext <> '' AND @Ext is not null 
   BEGIN
	SET @ExtFormatted = ' [' + @Ext + ']'
   END
SET @PhoneFormatted = 
   CASE @Type
--	Internal Extension
	WHEN '0' 
		THEN @Phone + @ExtFormatted
--	Long Distance
	WHEN '1'
 		THEN @AreaFormatted + @Phone + @ExtFormatted
--	Normal Seven-digit
	WHEN '2'
  		THEN @Phone
--	Special local, 10-digit
	WHEN '3'
 		THEN @AreaFormatted + @Phone + @ExtFormatted
--	Free-form, international numbers
	WHEN '4'
 		THEN @Phone
	ELSE @Phone
    END
return @PhoneFormatted
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_PhoneFormatted] TO PUBLIC
    AS [dbo];

