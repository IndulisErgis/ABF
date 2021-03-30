
 CREATE procedure alp_selectsite_proc (@pShowAll bit,@pShowSiteOnly bit,@pShowCustOnly bit,@pName varchar(100),@pAddress varchar(200),@pPhone varchar(15)
 ,@pCell varchar(15)
 ) as
 begin

 declare @strSite varchar(max);
		declare @strCust varchar(max);
		declare @sql1 varchar(max);
		
		if @pName <>'' 
		begin
			set @strSite='siteName like '''+@pName   +''''
			set @strCust='CustName like '''+@pName   +''''
		end
		if @pAddress <>'' 
		begin
			if @strSite<>''
			set @strSite= @strSite + 'and addr1 like'''+@pAddress   +''''
			else
			set @strSite=  ' addr1 like '''+@pAddress   +''''
			if @strCust<>''
			set @strCust= @strCust + 'and addr1 like'''+@pAddress   +''''
			 else
			 set @strCust= ' addr1 like '''+@pAddress   +''''
		End

		if @pPhone <>'' 
		begin
			if @strSite<>''
			set @strSite= @strSite + 'and phone like '''+@pPhone   +''''
			else
			set @strSite= ' phone like '''+@pPhone   +''''

			if @strCust<>''
			set @strCust= @strCust + 'and Phone like'''+@pPhone   +''''
			else
			set @strCust=   ' Phone like '''+@pPhone   +''''
		End
		if @pCell <>'' 
		begin
			if @strSite<>''   
			set @strSite= @strSite + 'and PrimaryType=3 and primaryphone like '''+ @pCell   +''''
			else
			set @strSite= ' PrimaryType=3 and primaryphone like '''+ @pCell   +''''
			
			if @strCust<>''
			set @strCust= @strCust + 'or Phone like'''+@pCell    +''''
			else
			set @strCust=   ' Phone like '''+@pCell +''''
		End
		 
		if @strSite<>''
		begin
		set @strSite= ' Where ' + @strSite  
		end
		if @strCust<>''
		begin
		set @strCust= ' Where ' + @strCust  
		end

	 if(@pShowAll=1)
	 begin
			set @sql1='	select ''Site'' as source,cast (a.SiteId as varchar(10))  as Id,sitename as Name,alpfirstname as FirstName, 
				case when (alpfirstname is null or alpfirstname ='''')then ''false'' else ''true'' end as IsResidential ,
				case when (alpfirstname is null or alpfirstname ='''') then sitename else alpfirstname +'' ''+sitename end as FullName ,
				case when (alpfirstname is null or alpfirstname ='''') then b.PrimaryPhone else a.Phone end as Phone ,
				case when (alpfirstname is null or alpfirstname ='''') then a.SiteName else a.alpfirstname +'' ''+ a.sitename   end as contact ,
				b.Email, addr1 +'', ''+ City+'', ''+ Region+'', ''+ PostalCode as Address ,b. title,
				 b.PrimaryYN, Addr1,Addr2,City,Region,PostalCode , case when isnull( b.primarytype,0) =''3'' then  PrimaryPhone else  '''' end as cell
				 ,Attn
				from alp_tblaralpsite a left outer join ALP_tblArAlpSiteContact b on a .SiteId=b.SiteId  
				 ' + @strSite  
				 + 'union all
				select ''Cust'' as source, CustId as Id ,CustName as Name,AlpFirstName as FirstName, 
				case when (AlpFirstName is null or AlpFirstName ='''')then ''false'' else ''true'' end as IsResidential ,
				case when (AlpFirstName is null or AlpFirstName ='''') then CustName else AlpFirstName +'' ''+CustName end as FullName ,
				Phone  ,
				case when (alpfirstname is null or alpfirstname ='''') then CustName else AlpFirstName +'' ''+ CustName   end as contact ,
				Email, addr1 +'', ''+ City+'', ''+ Region+'', ''+ PostalCode as Address ,'' ''as  title,
				 ''''as PrimaryYN, Addr1,Addr2,City,Region,PostalCode ,   ''''   as cell,Attn
				from alp_tblarcust_view  
				' + @strCust + '		order by id'
			-- exec(  @sql);
	end
	else if( @pShowSiteOnly=1)
	begin
		set @sql1=' select ''Site'' as source,cast (a.SiteId as varchar(10))  as Id,sitename as Name,alpfirstname as FirstName, 
			case when (alpfirstname is null or alpfirstname ='''')then ''false'' else ''true'' end as IsResidential ,
			case when (alpfirstname is null or alpfirstname ='''') then sitename else alpfirstname +'' ''+sitename end as FullName ,
			case when (alpfirstname is null or alpfirstname ='''') then b.PrimaryPhone else a.Phone end as Phone ,
			case when (alpfirstname is null or alpfirstname ='''') then a.SiteName else a.alpfirstname +'' ''+ a.sitename   end as contact ,
			b.Email, addr1 +'', ''+ City+'', ''+ Region+'', ''+ PostalCode as Address ,b. title,
			 b.PrimaryYN, Addr1,Addr2,City,Region,PostalCode, case when isnull( b.primarytype,0) =''3'' then  PrimaryPhone else  '''' end as cell
			  ,Attn
			from alp_tblaralpsite a left outer join ALP_tblArAlpSiteContact b on a .SiteId=b.SiteId '
			+ @strSite + '
			order by id '
	end
	else if( @pShowCustOnly=1)
	begin
		set @sql1='select''Cust'' as source, CustId as Id ,CustName as Name,AlpFirstName as FirstName, 
			case when (AlpFirstName is null or AlpFirstName ='''')then ''false'' else ''true'' end as IsResidential ,
			case when (AlpFirstName is null or AlpFirstName ='''') then CustName else AlpFirstName +'' ''+CustName end as FullName ,
			Phone  ,
			case when (alpfirstname is null or alpfirstname ='''') then CustName else AlpFirstName +'' ''+ CustName   end as contact ,
			Email, addr1 +'', ''+ City+'', ''+ Region+'', ''+ PostalCode as Address ,''''as  title,
			 ''''as PrimaryYN, Addr1,Addr2,City,Region,PostalCode,   ''''   as cell,Attn
			from alp_tblarcust_view  '
			+ @strCust + '
			order by id'
	end
	-- print @sql1;
	exec(@sql1)
end