
CREATE PROCEDURE [dbo].[ALP_qryJmUpdateProjectFudgeFactor]	
@FudgeFactor pDec ,@FudgeFactorHrs pDec,@AdjPoints float,@AdjHrs float,
@SvcTktProjectId int
AS
Update ALP_tblJmSvcTktProject set FudgeFactor=@FudgeFactor,FudgeFactorHrs=@FudgeFactorHrs,AdjPoints=@AdjPoints,AdjHrs=@AdjHrs
where SvcTktProjectId=@SvcTktProjectId