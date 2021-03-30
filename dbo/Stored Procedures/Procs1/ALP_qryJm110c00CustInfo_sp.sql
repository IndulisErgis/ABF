CREATE Procedure [dbo].[ALP_qryJm110c00CustInfo_sp]        
/* Used as RecordSource for Customer Info subform ( frmJm110cCustomerInfo) in Control Center*/        
-- EFI 1423 MAH 08/13/04: added region code to output        
-- MAH 01/30/14: modified to use the Status from traverse tblArCust table ( new field ) rather than Alp table.        
 (        
 @CustID pCustID = null        
 )        
As        
 set nocount on        
 SELECT ALP_tblArCust_view.CustId,        
  [Customer Name] = [CustName] +        
    CASE         
       WHEN([AlpFirstName] + '' <> '') Then CONVERT(varchar,', ') +[AlpFirstName]        
        ELSE ''        
   END,        
  Address = [Addr1]        
   + CASE        
       WHEN ( [addr2] + '' <> '') Then Char(13) + Char(10) + [addr2]        
       ELSE  ''        
    END        
    + Char(13) + Char(10)        
    + CASE WHEN([city] + '' <> '') Then  [city]+ CONVERT(varchar,', ')        
        ELSE ''        
    END        
    + isnull([region],'') + CONVERT(varchar,' ')        
    -- + isnull([postalcode],''), --Commented and added the line below by NSK on 16 Oct 2020 for bug id 1097        
    + CASE
    WHEN Len(postalcode) >5 THEN isnull(Substring([postalcode], 1, 5) + '-' + Substring([postalcode], 6, 9) ,'')
    ELSE isnull([postalcode],'')
END, 
  Contact = isnull(ALP_tblArCust_view.Contact,''),         
  Phone = isnull(ALP_tblArCust_view.Phone,''),        
  --AlpStatus = CASE        
  --  WHEN [AlpInactive]='1' Then ' Inactive'        
  --  ELSE ''        
  --      END,        
  AlpStatus = CASE        
    WHEN [Status]='1' Then 'Inactive'        
    ELSE ''        
        END,        
  Rep = isnull(ALP_tblArCust_view.SalesRepId1,''),        
  region        
  ,Email --added by NSK on 19 Nov 2015    
  ,GroupCode --added by NSK on 24 Nov 2015    
 FROM ALP_tblArCust_view  (NOLOCK)        
 WHERE  ALP_tblArCust_view.CustId = @Custid         
 return