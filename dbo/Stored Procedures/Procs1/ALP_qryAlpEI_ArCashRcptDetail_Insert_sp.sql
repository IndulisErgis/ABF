  -- select * from tblArCashRcptDetail order by 1 desc  
   
CREATE     procedure [dbo].[ALP_qryAlpEI_ArCashRcptDetail_Insert_sp]     
 @RcptHeaderID int,  
 @RcptDetailID  int,    
 @AmtToApply    decimal(20,10),  
 @AmtToApplyFgn decimal(20,10),  
 @InvcNum  varchar(15),  
 @SiteID int  
As    
 
Begin    
  
 Insert into   
  tblArCashRcptDetail  
   (   
     InvcNum, PmtAmt,  [Difference], PmtAmtFgn, DifferenceFgn,  
     RcptHeaderID, DistCode 
  
   )  
 Select   
     @InvcNum, @AmtToApply, [Difference], @AmtToApplyFgn, DifferenceFgn,  
     @RcptHeaderID, DistCode  
 from    
  tblArCashRcptDetail  
 Where    
  RcptDetailID = @RcptDetailID  
   
   --Below insert code add by Ravi
   Insert into     ALP_tblArCashRcptDetail     (   AlpRcptDetailID ,      AlpSiteId  ,AlpComment    )  
													Select     @RcptHeaderID,    @SiteID  ,AlpComment  from      ALP_tblArCashRcptDetail  
													 Where     AlpRcptDetailID = @RcptDetailID  
  --- end

 Insert into     tblArCashRcptDetail     (        InvcNum, PmtAmt,  [Difference], PmtAmtFgn, DifferenceFgn, 
       RcptHeaderID, DistCode     )  
 Select   
     InvcNum, @AmtToApply*-1, [Difference], @AmtToApplyFgn*-1, DifferenceFgn,  
     @RcptHeaderID+1,DistCode   
 from      tblArCashRcptDetail   Where      RcptDetailID = @RcptDetailID  
 
  --Below insert code add by Ravi
   Insert into     ALP_tblArCashRcptDetail     (   AlpRcptDetailID ,      AlpSiteId  ,AlpComment    )  
													Select      @RcptHeaderID+1,    AlpSiteId  ,AlpComment  from      ALP_tblArCashRcptDetail  
													 Where     AlpRcptDetailID = @RcptDetailID 
													 --- end 
end