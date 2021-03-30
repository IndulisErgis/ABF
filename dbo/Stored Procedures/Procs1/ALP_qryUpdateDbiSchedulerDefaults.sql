﻿
CREATE PROCEDURE dbo.ALP_qryUpdateDbiSchedulerDefaults
@intStartWork int, @intEndWork int, @intLoadData smallint, @bytIncrement tinyint, @intTimeBarLength smallint,
@lngTimeType int, @lngTimeTypeColor int,
@lngTimeTypeForeColor int, @blnAdjustOnMove bit,
@lngBackColor int, @bytBarTextAlign tinyint,
@lngListBackColor int, @blnDisplayOnly bit,
@blnRuler3D bit, @blnRulerSplit bit,
@blnTextIntoView bit, @blnTimeLines bit,
@blnSnapToGrid bit, @blnVertReposition bit,
@lngWeekendColor int, @lngNonWorkColor int,
@bytScale tinyint,  @blnShowWeekends bit,
@bytBarTextInfo tinyint,  @lngSelectedTabColor int,
@lngTabColor int, @strPrintTitle varchar(255),
@blnPrintColorBars bit,  @blnPrintWeekendColor bit,
@blnTab3D bit, @blnPrintListColumns bit,
@bShowTimecardsYn bit,
@bShowTimeBarDialog bit,
@intRulerDivision int,
@intHeaderHeight int,
@intTimeDistance int,
@intLoadDataAfter smallint
As
SET NOCOUNT ON
UPDATE ALP_tblJmSchedulerDefaults 
SET ALP_tblJmSchedulerDefaults.StartWork = @intStartWork, ALP_tblJmSchedulerDefaults.EndWork = @intEndWork, ALP_tblJmSchedulerDefaults.LoadData = @intLoadData, 
	ALP_tblJmSchedulerDefaults.Increment = @bytIncrement, ALP_tblJmSchedulerDefaults.TimeBarLength = @intTimeBarLength, 
	ALP_tblJmSchedulerDefaults.TimeType = @lngTimeType, ALP_tblJmSchedulerDefaults.TimeTypeColor = @lngTimeTypeColor, 
	ALP_tblJmSchedulerDefaults.TimeTypeForeColor = @lngTimeTypeForeColor, ALP_tblJmSchedulerDefaults.AdjustOnMove = @blnAdjustOnMove, 
	ALP_tblJmSchedulerDefaults.BackColor = @lngBackColor, ALP_tblJmSchedulerDefaults.BarTextAlign = @bytBarTextAlign, 
	ALP_tblJmSchedulerDefaults.ListBackColor = @lngListBackColor, ALP_tblJmSchedulerDefaults.DisplayOnly = @blnDisplayOnly, 
	ALP_tblJmSchedulerDefaults.Ruler3D = @blnRuler3D, ALP_tblJmSchedulerDefaults.RulerSplit = @blnRulerSplit, 
	ALP_tblJmSchedulerDefaults.TextIntoView = @blnTextIntoView, ALP_tblJmSchedulerDefaults.TimeLines = @blnTimeLines, 
	ALP_tblJmSchedulerDefaults.SnapToGrid = @blnSnapToGrid, ALP_tblJmSchedulerDefaults.VertReposition = @blnVertReposition, 
	ALP_tblJmSchedulerDefaults.WeekendColor = @lngWeekendColor, ALP_tblJmSchedulerDefaults.NonWorkColor = @lngNonWorkColor, 
	ALP_tblJmSchedulerDefaults.Scale = @bytScale, ALP_tblJmSchedulerDefaults.ShowWeekends = @blnShowWeekends, 
	ALP_tblJmSchedulerDefaults.BarTextInfo = @bytBarTextInfo, ALP_tblJmSchedulerDefaults.SelectedTabColor = @lngSelectedTabColor, 
	ALP_tblJmSchedulerDefaults.TabColor = @lngTabColor, ALP_tblJmSchedulerDefaults.PrintTitle = @strPrintTitle, 
	ALP_tblJmSchedulerDefaults.PrintColorBars = @blnPrintColorBars, ALP_tblJmSchedulerDefaults.PrintWeekendColor = @blnPrintWeekendColor, 
	ALP_tblJmSchedulerDefaults.Tab3D = @blnTab3D, ALP_tblJmSchedulerDefaults.PrintListColumns = @blnPrintListColumns, 
	ALP_tblJmSchedulerDefaults.ShowTimecardsYn = @bShowTimecardsYn,ALP_tblJmSchedulerDefaults.TimeBarDialog = @bShowTimeBarDialog,
	ALP_tblJmSchedulerDefaults.RulerDivision = @intRulerDivision,ALP_tblJmSchedulerDefaults.HeaderHeight = @intHeaderHeight,
	ALP_tblJmSchedulerDefaults.TimeDistance = @intTimeDistance,ALP_tblJmSchedulerDefaults.LoadDaysAfter = @intLoadDataAfter