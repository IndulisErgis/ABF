Create PROCEDURE [dbo].[ALP_qryCSsvcperbillingCode_Update_sp]	
@CSsvcperBillCodeID int,
@ItemId pItemID,
@CSSvcID int
AS
Update ALP_tblCSsvcperbillingCode set ItemId=@ItemId ,CSSvcID=@CSSvcID  where 
CSsvcperBillCodeID=@CSsvcperBillCodeID