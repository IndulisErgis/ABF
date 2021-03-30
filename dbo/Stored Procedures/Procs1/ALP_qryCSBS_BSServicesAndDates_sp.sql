CREATE Procedure dbo.ALP_qryCSBS_BSServicesAndDates_sp
/* This sproc is used by clsCSBS, to determine all of the active, monitored
   services that a particular System is being billed for.  It also determines the earliest StartBill date,
   and latest EndBill date for each service.
   The function ufxGetBSServicesForSystem is called, and creates a table of the active,
   monitored services for the system.   This table is then joined to the Pricing table (tblRecBillServPrice)
   to find the start and end bill dates.
*/
	(
		@SystemID int = null,
		@RunDate datetime
	)
As
set nocount on
-- Group all Pricing records for the service to find the earliest (min) StartDate and 
-- the latest (max) End Date. Also finds the first StartDate entered, and the last End Date entered.
-- (Note:  If the service is still active, the End Date will be null.)
-- Put the results in a temp table - #ALP_tblServicesAndDates.
CREATE Table #ALP_tblServicesAndDates
	(
		RecBillServId int,
		ServiceID varchar(24),
		SvcCode varchar(15),
		StartDateMin dateTime, 
		EndDateMax dateTime,
		EndDateLast datetime,
		ActiveRMR pDec
	)
INSERT INTO #ALP_tblServicesAndDates ( 
		RecBillServId,
		ServiceID,
		SvcCode,
		StartDateMin,
		EndDateMax,
		EndDateLast,
		ActiveRMR)
		(SELECT SP.RecBillServId,
			A.ServiceID,
			A.SvcCode,
			ServiceStartDate = Min(A.ServiceStartDate), 
			EndDateMax = Max(SP.EndBillDate),
			EndDateLast = 
					--Find the last Pricing record entered for that service
					(SELECT EndBillDate 
					FROM ALP_tblArAlpSiteRecBillServPrice SP2
					WHERE SP2.RecBillServPriceId =  
						-- Find the KEY of the last Pricing record
						(SELECT MAX(RecBillServPriceId) 
						FROM ALP_tblArAlpSiteRecBillServPrice SP2
						WHERE SP2.RecBillServId  = SP.RecBillServID)),
			SUM(A.ActivePrice)
		FROM ALP_tblArAlpSiteRecBillServPrice SP
			INNER JOIN dbo.ufxGetBSServicesForSystem(@SystemID) AS A
				ON  SP.RecBillServId = A.RecSvcId
		GROUP BY SP.RecBillServId,A.ServiceID,A.SvcCode)
-- Group records by SvcCode, retain the earliest Start Date and the latest End Date. 
SELECT SvcCode,
	StartDate = Min(StartDateMin),
	EndDate = CASE
			WHEN Max(EndDateLast)IS NULL
				THEN NULL
			WHEN Max(EndDateLast) IS NOT NULL
				THEN Max(EndDateMax)
		END,
	RMR = SUM(ActiveRMR)
FROM #ALP_tblServicesAndDates
GROUP BY SvcCode
ORDER BY SvcCode
--Delete the temporary table
DROP Table #ALP_tblServicesAndDates
return