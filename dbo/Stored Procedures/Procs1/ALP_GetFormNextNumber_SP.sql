CREATE Procedure [dbo].[ALP_GetFormNextNumber_SP]  
(  
 @FormId varchar(15)   
)  
  
AS   
BEGIN  
    
 Update tblSmFormNum set NextNum =NextNum +1 Where FormId =@FormId;  
   
 SELECT NextNum FROM tblSmFormNum WHERE FormId =@FormId;  
  
END