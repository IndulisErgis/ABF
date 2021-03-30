
CREATE Procedure dbo.ALP_qryArAlpCentralStations
/* EFI# 1311 MAH 04-18-04: Created procedure, for SIMS integration*/
/* EFI# 1523 MAH 10-11-04: modified to ignore Central Stations that we do not interface to.  */
/* EFI# ???? MAH 03/04/05: select each central station record, so inactive accounts can be   */
/*                         identified within the app.                                        */
/* EFI# 1793 MAH 12/17/08: Added 'RequestTimeTolerance' field		*/
/* EFI# 1836 NP 7/17/09: Added 'EncryptYN' field			     */
As
set nocount on
SELECT  
	ALP_tblArAlpCentralStation.CentralId, ALP_tblArAlpCentralStation.Central, 
	ALP_tblArAlpCentralStation.InactiveYN, ALP_tblArAlpCentralStation.DealerNum, 
        ALP_tblArAlpCentralStation.MonSoftwareYN, ALP_tblArAlpMonSoftware.Name, 
	ALP_tblArAlpMonSoftware.ConnectMethod, ALP_tblArAlpMonSoftware.Path, ALP_tblArAlpMonSoftware.RequestTimeTolerance,
	ALP_tblArAlpMonSoftware.EncryptYN

FROM    ALP_tblArAlpCentralStation 
	INNER JOIN  ALP_tblArAlpMonSoftware 
	ON ALP_tblArAlpCentralStation.MonSoftwareId = ALP_tblArAlpMonSoftware.MonSoftwareId
return