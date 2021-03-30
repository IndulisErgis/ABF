CREATE FUNCTION [dbo].[ALP_ufxGetAuditFieldOldValue_MAH]   
(   
   @xml as XML,   
   @FieldName as nvarchar(max)   
)   
RETURNS nvarchar(max)   
AS   
BEGIN   
  
--parse the list of values into a table for processing   
Declare @nodes Table ([Name] varchar(max), [Value] varchar(max))   
  
INSERT INTO @nodes ([Name], [Value])   
SELECT e.props.value('./FieldName[1]', 'VARCHAR(max)') as [Name]   
   , e.props.value('./OldValue[1]', 'VARCHAR(max)') as [Value]   
FROM @xml.nodes('/ArrayOfEntityAuditEventData/EntityAuditEventData') as e(props)   
--WHERE (e.props.exist('FieldName') = 1) AND (e.props.exist('OldValue') = 1)   
WHERE (e.props.value('./FieldName[1]', 'varchar(max)') = @FieldName) --AND (e.props.Value('OldValue') = 1)   
        
--modify the data   
--   the custom field values are stored in a string representation therefore any values   
--   must be formatted based upon the datatype assigned to the given custom field   
declare @FieldValue nvarchar(max)   
  
if (select COUNT(*) from @nodes where [Name]=@FieldName)=0   
   select @FieldValue = ''   
else   
   select top 1 @FieldValue=[Value] from @nodes where [Name]=@FieldName   
  
select @FieldValue=replace(@FieldValue, '&amp;', '&')   
  
return @FieldValue   
END