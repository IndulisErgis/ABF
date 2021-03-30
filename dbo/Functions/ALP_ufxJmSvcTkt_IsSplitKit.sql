CREATE FUNCTION [dbo].[ALP_ufxJmSvcTkt_IsSplitKit]
--created 09/08/16 MAH
( 
 @TicketID int = NULL,   
 @TicketItemId INT = NULL    
)    
RETURNS BIT    
AS    
BEGIN    
   DECLARE @IsPartOfSplitKit BIT
   DECLARE @LineNumber varchar (100)
   DECLARE @pos int
   DECLARE @Search varchar(100)    
   SET @IsPartOfSplitKit = 0  
   SET @LineNumber = (SELECT LineNumber FROM ALP_tblJmSvcTktItem WHERE TicketItemID =@TicketItemId)
   SET @pos = CHARINDEX('.',@LineNumber)
   SET @Search = CASE WHEN @pos > 1 THEN LEFT(@LineNumber,@pos - 1) ELSE @LineNumber END + '%'
 IF EXISTS( SELECT 1 from ALP_tblJmSvcTktItem 
   where LineNumber LIKE @Search and TicketID <> @TicketID)    
	BEGIN    
		SET @IsPartOfSplitKit = 1    
	END    
 RETURN @IsPartOfSplitKit    
END