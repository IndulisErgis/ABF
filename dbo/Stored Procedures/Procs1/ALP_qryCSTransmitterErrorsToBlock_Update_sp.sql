CREATE      Procedure [dbo].[ALP_qryCSTransmitterErrorsToBlock_Update_sp]  
 @ID int,
 @Transmitter varchar(36),  
 @ErrorCode varchar(4),
 @DisabledDate datetime,
 @DisabledBy varchar(255)
 
AS  

SET NOCOUNT ON  
Update ALP_tblCSTransmitterErrorsToBlock set  Transmitter= @Transmitter,ErrorCode= @ErrorCode, DisabledDate= @DisabledDate,DisabledBy=DisabledBy
where ID=@ID