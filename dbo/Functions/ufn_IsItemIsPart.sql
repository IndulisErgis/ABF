
CREATE function [dbo].[ufn_IsItemIsPart]( @pitemId varchar(200))
		 returns bit
		 begin
			return isnull( (select case ItemType when 1 then  1 else case itemtype when 2 then 1 else 0 end end  
		 from abf.dbo.tblInItem  
		 where  ItemID =@pitemId  ) ,0)
		 end