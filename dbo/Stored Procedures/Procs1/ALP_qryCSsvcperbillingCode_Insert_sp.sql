 CREATE  Procedure [dbo].[ALP_qryCSsvcperbillingCode_Insert_sp]  
 @ItemId pItemID,  
 @CSSvcId int  
 
AS  
/*  
 Created by NP for EFI#1869 on 05/17/2010  
*/  
SET NOCOUNT ON  
INSERT INTO ALP_tblCSsvcperbillingCode ( ItemId, CSSvcId )  
VALUES(@ItemId,@CSSvcId)