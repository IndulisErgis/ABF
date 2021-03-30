CREATE FUNCTION dbo.ufxCS_DiscontinuedAcct
	(
	@Transmitter nvarchar(36) = null,
	@RunDate nvarchar(30)  = '05/13/03'
	)
RETURNS varchar(30)
AS
	
begin
declare @x varchar(30)
set @x = 'test'
IF EXISTS (SELECT * 
		FROM PHX.phoenix.dbo.ABMTransmitter 
		WHERE transmitter_id = @Transmitter 
		        	AND discontinued_date IS NOT NULL 
		AND discontinued_date != '' 
		AND discontinued_date <= @RunDate)
		
	set @x = (SELECT discontinued_date FROM PHX.phoenix.dbo.ABMtransmitter WHERE transmitter_id = @Transmitter    ) 
	ELSE
    		IF EXISTS 
			(SELECT * 
			FROM PHX.phoenix.dbo.ABMSite 
			WHERE discontinued_date IS NOT NULL 
			AND discontinued_date != ''
		        AND discontinued_date <= @RunDate 
			AND Site_id in 
				(SELECT Site 
				FROM PHX.phoenix.dbo.ABMTransmitter 
				WHERE transmitter_id = @Transmitter) 
			AND subscriber in 
				(SELECT subscriber 
				FROM PHX.phoenix.dbo.ABMTransmitter
				WHERE transmitter_id = @Transmitter) 
			AND dealer in 
			(SELECT dealer 
			FROM PHX.phoenix.dbo.ABMTransmitter
			WHERE transmitter_id = @Transmitter)
			)
			set @x = (SELECT discontinued_date FROM PHX.phoenix.dbo.ABMSite WHERE 
											Site_id in 
											(SELECT site 
											FROM PHX.phoenix.dbo.ABMTransmitter
										        WHERE transmitter_id = @Transmitter) 
											AND 
											subscriber in 
											(SELECT subscriber 
											FROM PHX.phoenix.dbo.ABMTransmitter
               										WHERE transmitter_id = @Transmitter) 
											AND 
											dealer in 
												(SELECT dealer 
												FROM PHX.phoenix.dbo.ABMTransmitter 
                										 WHERE transmitter_id = @Transmitter) 	
									)                                     
  		ELSE
        		IF EXISTS 
				(SELECT * 
				FROM PHX.phoenix.dbo.ABMSubscriber 
				WHERE discontinued_date IS NOT NULL 
				AND discontinued_date != '' 
				AND discontinued_date <= @RunDate 
				AND Subscriber_id in 
					(SELECT subscriber 
					FROM PHX.phoenix.dbo.ABMTransmitter 
					WHERE transmitter_id = @Transmitter) 
				AND 
				dealer in 
				(SELECT dealer 
				FROM PHX.phoenix.dbo.ABMTransmitter 
				WHERE transmitter_id = @Transmitter)
				)
			set @x = (SELECT discontinued_date FROM PHX.phoenix.dbo.ABMSubscriber WHERE 
			Subscriber_id in 
				(SELECT subscriber 
				FROM PHX.phoenix.dbo.ABMTransmitter 
				WHERE transmitter_id = @Transmitter) 
				AND 
				dealer in 
					(SELECT dealer 
					FROM PHX.phoenix.dbo.ABMTransmitter 
					WHERE transmitter_id = @Transmitter)                  
				)             
		ELSE
		  	IF EXISTS 
				(SELECT * 
				FROM PHX.phoenix.dbo.ABMDealer 
				WHERE discontinued_date IS NOT NULL 
				AND discontinued_date != ''
                		AND discontinued_date <= @RunDate 
				AND Dealer_id in 
					(SELECT 
						dealer 
						FROM PHX.phoenix.dbo.ABMTransmitter
			                        WHERE transmitter_id = @Transmitter)
				)
				set @x = (
               			SELECT discontinued_date 
				FROM PHX.phoenix.dbo.ABMDealer 
				WHERE Dealer_id in 
					(SELECT dealer 
					FROM PHX.phoenix.dbo.ABMTransmitter
                    			WHERE transmitter_id = @Transmitter)       )                   
		--MAH added following lines, to temporarily avoid empty recordset problem
ELSE 
		set @x = (SELECT 'none' as  discontinued_date	)					
		--MAH ..end
return @x
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_DiscontinuedAcct] TO PUBLIC
    AS [dbo];

