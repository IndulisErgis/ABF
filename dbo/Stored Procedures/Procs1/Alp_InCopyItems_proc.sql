CREATE PROCEDURE [dbo].[Alp_InCopyItems_proc] (    
	@LocIDFrom pLocID, @LocIDTo pLocID, @GLAcctCode pGLAcctCode,@FilterCondition varchar(max)='')     
AS     
-- Below string concadination code modifie ravi on 07 Oct 2016,   
BEGIN TRY      
	DECLARE @Count int;    
    
BEGIN       
     
	CREATE TABLE #ItemLocExsists (AlpItemId varchar(24))    

	DECLARE @StrCheck Varchar(max) ='INSERT INTO #ItemLocExsists SELECT  AlpItemId   FROM Alp_tblInitemLoc     
          WHERE  AlpLocId=''' + @LocIDTo +'''';   
   
	IF @FilterCondition <>''   
   BEGIN   
		SET @StrCheck = @StrCheck+ ' and ' + @FilterCondition   
   END  
   
	print @StrCheck  
	Execute (@StrCheck);    
     
	SELECT @Count=Count(*)From #ItemLocExsists    
	print @Count;    
	
	IF(@Count>0)    
	BEGIN    
		Update a  SET a.AlpDfltHours=b.AlpDfltHours,    
				a.AlpDfltPts=b.AlpDfltPts,a.AlpInstalledPrice=b.AlpInstalledPrice,    
				a.AlpDfltCommercialHours=b.AlpDfltCommercialHours,    
				a.AlpDfltCommercialPts=b.AlpDfltCommercialPts      
      FROM alp_tblinitemloc a INNER JOIN alp_tblinitemloc b    
      ON a.alpitemid=b.alpItemid    
      WHERE a.alpItemid in(SELECT AlpItemId  FROM #ItemLocExsists)    
      and a.alplocid=@LocIdTo    
      and b.AlpLocId=@LocIDFrom    
        
      DECLARE @Str Varchar(max)='INSERT INTO ALP_tblInItemLoc 
											(AlpItemId, AlpLocId, AlpDfltHours,    
											AlpDfltPts,AlpInstalledPrice,AlpDfltCommercialHours,    
											AlpDfltCommercialPts)     
											
											SELECT AlpItemId,'''+ @LocIDTo +''', AlpDfltHours,    
													AlpDfltPts,AlpInstalledPrice,AlpDfltCommercialHours,    
													AlpDfltCommercialPts      
											FROM Alp_tblInitemLoc   WHERE AlpLocId=' +''''+ @LocIDFrom +''''    
											+ ' and AlpItemId NOT IN(SELECT AlpItemId  FROM #ItemLocExsists)'    
      
		IF @FilterCondition<>''  
		BEGIN  
			SET @Str =@Str + ' and ' +@FilterCondition    
		END  
		PRINT @str  
		EXECUTE (@Str)    
	END    
	ELSE    
	BEGIN    
		DECLARE @Str1 Varchar(max)='INSERT INTO ALP_tblInItemLoc 
											 (AlpItemId, AlpLocId, AlpDfltHours,    
											 AlpDfltPts,AlpInstalledPrice,AlpDfltCommercialHours,    
											 AlpDfltCommercialPts)     
       
											 SELECT AlpItemId,'''+ @LocIDTo+''', AlpDfltHours,    
													AlpDfltPts,AlpInstalledPrice,AlpDfltCommercialHours,    
													AlpDfltCommercialPts      
											 FROM Alp_tblInitemLoc   WHERE AlpLocId =' +''''+@LocIDFrom+''''    
       
		IF @FilterCondition<>''  
		BEGIN  
		--Below code commented by ravi on 13 Oct 2016, Earlier code wrongly used @Str variable instead of @Str1, those are correctted 
		  --SET @Str =@Str + ' and ' +@FilterCondition    
			SET @Str1 =@Str1 + ' and ' +@FilterCondition    
		END  
		PRINT @Str1  
		EXECUTE (@Str1)     
	 END    
 END      
END TRY      
BEGIN CATCH      
	EXEC dbo.trav_RaiseError_proc      
END CATCH