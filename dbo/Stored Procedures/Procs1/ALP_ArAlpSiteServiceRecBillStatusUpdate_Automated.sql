
CREATE PROCEDURE [dbo].[ALP_ArAlpSiteServiceRecBillStatusUpdate_Automated] AS
BEGIN

SET ANSI_WARNINGS OFF
set nocount on


declare @todaysdate as date = Convert(DATE, GetDate());

select @todaysdate as 'Run Date'

begin transaction

--update all services that are New with svc start date of today to Active
update
	rsb
set
	Status = 'Active'
output
	inserted.RecBillServId,
	inserted.RecBillId,
	inserted.ServiceId,
	deleted.Status as 'Original Status',
	'Changed to' as Action,
	inserted.Status as 'New Status',
	@todaysdate as 'Svc Start'
from
	ALP_tblArAlpSiteRecBillServ rsb
inner join
	(
		select
			recbillservid, 
			max(startbilldate) as StartBillDate
		from
			ALP_tblArAlpSiteRecBillServPrice
		group by
			recbillservid
	) as rsbp
on
	rsbp.recbillservid = rsb.recbillservid
where
	StartBillDate = @todaysdate
and
	Status = 'New'

rollback transaction

begin transaction

--update all services that are Active with svc expires date of today to Expired
update
	rsb
set
	Status = 'Expired'
output
	inserted.RecBillServId,
	inserted.RecBillId,
	inserted.ServiceId,
	deleted.Status as 'Original Status',
	'Changed to' as Action,
	inserted.Status as 'New Status',
	@todaysdate as 'Svc Expires'
from
	ALP_tblArAlpSiteRecBillServ rsb
inner join
	(
		select
			recbillservid, 
			max(endbilldate) as EndBillDate
		from
			ALP_tblArAlpSiteRecBillServPrice
		group by
			recbillservid
	) as rsbp
on
	rsbp.recbillservid = rsb.recbillservid
where
	EndBillDate = @todaysdate
and Status = 'Active'


rollback transaction
END

--ALP_ArAlpSiteServiceRecBillStatusUpdate_Automated