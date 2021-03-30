

CREATE FUNCTION dbo.ufxCS_OpensAndClosings 
(
@Transmitter varchar(36)
)
RETURNS TABLE
AS 
RETURN(
SELECT 
	'UAO' =monitor_early_effective , 
	'FTO' = monitor_failed_effective,
	'LO' = monitor_late_effective,	
    	'EC' = monitor_early_expiration,
	'FTC' = monitor_failed_expiration,
	'LC'= monitor_late_expiration,   
	'OCDate' = next_openclose_date, 
	'Status' = current_status
FROM PHX.phoenix.dbo.ABMSchedule S , PHX.phoenix.dbo.ABMTransmitter T
WHERE 
	type = 'openclose'  
	AND
		 (schedule_id in 
			(
			SELECT open_close_schedule 
			FROM PHX.phoenix.dbo.ABMTransmitter
        			WHERE transmitter_id = @Transmitter
			)
 		OR 
		schedule_id in 
			(
			SELECT open_close_schedule 
			FROM PHX.phoenix.dbo.ABMDealer
       			 WHERE Dealer_id in 
				(
				SELECT dealer 
				FROM PHX.phoenix.dbo.ABMTransmitter
            				WHERE transmitter_id = @Transmitter
				)	
			)
 
   OR 
		schedule_id in 
			(
			SELECT open_close_schedule 
			FROM PHX.phoenix.dbo.ABMSubscriber
        			WHERE Subscriber_id in 
					(
					SELECT subscriber 
					FROM PHX.phoenix.dbo.ABMTransmitter
           				WHERE transmitter_id = @Transmitter
)
				AND 
				Dealer in 
                				(
					SELECT dealer 	
					FROM PHX.phoenix.dbo.ABMTransmitter
					WHERE Transmitter_id = @Transmitter
)
			)
 			OR 
				schedule_id in 
					(
					SELECT open_close_schedule 
					FROM PHX.phoenix.dbo.ABMSite
        					WHERE site_id in 
					(
					SELECT site 
					FROM PHX.phoenix.dbo.ABMTransmitter
					WHERE transmitter_id = @Transmitter
) 
 			AND 
				subscriber in 
					(
					SELECT subscriber
			 		FROM PHX.phoenix.dbo.ABMTransmitter
					WHERE Transmitter_id = @Transmitter
) 
			AND 
				Dealer in 
					(
					SELECT dealer 
					FROM PHX.phoenix.dbo.ABMTransmitter
                 				WHERE transmitter_id = @Transmitter
)
				)	
				)
   			 AND 
				T.open_close_indicator = 'y'
			AND 
			Transmitter_id = @Transmitter
)
GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxCS_OpensAndClosings] TO PUBLIC
    AS [dbo];

