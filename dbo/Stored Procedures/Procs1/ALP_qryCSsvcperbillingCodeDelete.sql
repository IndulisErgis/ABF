CREATE PROCEDURE [dbo].[ALP_qryCSsvcperbillingCodeDelete]	
@CSsvcperBillCodeID int,
@ItemId pItemID,
@CSSvcID int
AS
Delete ALP_tblCSsvcperbillingCode  where 
CSsvcperBillCodeID=@CSsvcperBillCodeID
--ItemId=@ItemId and CSSvcID=@CSSvcID