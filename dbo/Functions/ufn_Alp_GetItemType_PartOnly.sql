
CREATE FUNCTION   [dbo].[ufn_Alp_GetItemType_PartOnly] (@ItemType int) 
RETURNS bit 
AS  
BEGIN  
         If (@ItemType = 1) RETURN 1;
         If (@ItemType = 2) RETURN 1;
         If (@ItemType = 3) RETURN 0;
RETURN 0
END