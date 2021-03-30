CREATE VIEW dbo.ALP_lkpArBatch AS
--Where Conditon added by ravi on 10.27.2014, to avoid the duplicate batchid 
 SELECT BatchId FROM dbo.tblSMBatch  WHERE FunctionId in ('ARTRANS','ARCASHRCPT')