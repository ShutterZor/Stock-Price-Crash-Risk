********************** Author Information **************************************
/*
Author: 		Shutter Zor（左祥太）
Affiliation:		School of Management, Xiamen University
Date:			2023/5/4
Email:			Shutter_Z@outlook.com
Version:		1.0
*/
********************************************************************************



******************* 股价崩盘风险（Stock Price Crash Risk）**********************
/*
说明：本次样本选取所有A股，所以在后续仅保留A股相关数据
*/

*- 数据的清洗与合并
	*- 整理个股周收益率数据
	import excel using "周个股回报率文件/TRD_Week.xlsx", first clear
	labone, nrow(1 2) concat("_")
	drop in 1/2
	keep if Markettype == "1" | Markettype == "4"		// 保留上证A股与深证A股
	compress
	save ShareReturn.dta, replace


	*- 整理市场周收益率数据
	import excel using "周市场回报率文件/TRD_Weekm.xlsx", first clear
	labone, nrow(1 2) concat("_")
	drop in 1/2
	keep if Markettype == "1" | Markettype == "4"		// 保留上证A股与深证A股
	compress
	save MarketReturn.dta, replace


	*- 合并个股与市场的收益率数据
	use ShareReturn.dta, clear
	merge m:1 Markettype Trdwnt using MarketReturn.dta
	drop _merge Markettype
	save MergeData.dta, replace


	
*- 计算股价崩盘风险
use MergeData.dta, clear

	*- 计算前准备
	destring Wre*, replace
	replace Wretwd = Wretwd * 100
	replace Wretwdos = Wretwdos * 100
	
	*- 计算NCSKEW
		*- 定义面板，方便滞后处理
		egen stkid = group(Stkcd)
		egen week = group(Trdwnt)
		xtset stkid week
		
		*- 生成年交易周数
		gen year = substr(Trdwnt,1,4)
		bys Stkcd year: gen tradeWeek = _N
		
		*- 计算残差
		sort stkid week
		reghdfe Wretwd L2.Wretwdos L1.Wretwdos Wretwdos 	///
				F1.Wretwdos F2.Wretwdos, noa res(e)
		
		*- 计算特定收益率
		gen W = ln(1 + e)
		
		*- 计算NCSKEW
		gen W2 = W ^ 2
		gen W3 = W ^ 3
		bys Stkcd year: egen sumW2 = sum(W2)
		bys Stkcd year: egen sumW3 = sum(W3)
		gen NCSKEW1 = -1 * tradeWeek * (tradeWeek-1)^(3/2) * sumW3
		gen NCSKEW2 = (tradeWeek-1) * (tradeWeek-2) * sumW2^(3/2)
		gen NCSKEW = NCSKEW1 / NCSKEW2
		
		*- 计算DUVOL
		bys Stkcd year: egen meanW = mean(W)
		gen temp1 = 1 if W > meanW 
		gen temp2 = 1 if W < meanW
		bys Stkcd year: egen nu = sum(temp1)
		bys Stkcd year: egen nd = sum(temp2)
		gen W2U = W^2 if temp1 == 1
		gen W2D = W^2 if temp2 == 1
		bys Stkcd year: egen sumW2U = sum(W2U)
		bys Stkcd year: egen sumW2D = sum(W2D)
		gen DUVOL1 = (nu-1) * sumW2D
		gen DUVOL2 = (nd-1) * sumW2U
		gen DUVOL = ln(DUVOL1/DUVOL2)

		*- 去除重复值
		duplicates drop Stkcd year, force
		keep Stkcd year NCSKEW DUVOL
		
		*- 描述性统计
		sum NCSKEW DUVOL

		*- 前后缩尾1%
		winsor NCSKEW, p(0.01) g(NCSKEW_W)
		winsor DUVOL, p(0.01) g(DUVOL_W)

		sum NCSKEW_W DUVOL_W
		
		keep Stkcd year *_W
		save FinalData.dta, replace

********************************************************************************
