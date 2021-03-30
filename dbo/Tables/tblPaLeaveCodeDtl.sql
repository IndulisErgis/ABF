CREATE TABLE [dbo].[tblPaLeaveCodeDtl] (
    [LeaveCodeId] [dbo].[pCode] NOT NULL,
    [UpToYear]    SMALLINT      NOT NULL,
    [HrsWkd]      [dbo].[pDec]  CONSTRAINT [DF_tblPaLeaveCodeDtl_HrsWkd] DEFAULT ((0)) NOT NULL,
    [MaxHrs]      [dbo].[pDec]  CONSTRAINT [DF_tblPaLeaveCodeDtl_MaxHrs] DEFAULT ((0)) NOT NULL,
    [MinAccrual]  [dbo].[pDec]  CONSTRAINT [DF_tblPaLeaveCodeDtl_MinAccrual] DEFAULT ((0)) NOT NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaLeaveCodeDtl] PRIMARY KEY CLUSTERED ([LeaveCodeId] ASC, [UpToYear] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaLeaveCodeDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaLeaveCodeDtl';

