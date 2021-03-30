CREATE Procedure [dbo].[lkpWDB_GetAssociatedCSService_sp]

/* Get the CS Service associated with an ABPro Billing Code  */

/* created 04/16/08 - MAH  */

        (

        @ItemID varchar(24) = '--NONE--'

        )

As

SET NOCOUNT ON

SELECT ALP_tblCSServices.SvcCode AS CSServiceCode, 

        ALP_tblCSServices.Descr AS CSServiceCodeDescr

FROM dbo.ALP_tblCSServices 

        INNER JOIN dbo.ALP_tblCSsvcperbillingCode 

        ON ALP_tblCSServices.CSSvcID = ALP_tblCSsvcperbillingCode.CSSvcID 

WHERE ALP_tblCSsvcperbillingCode.ItemId = @ItemID