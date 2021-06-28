------------------------------------------------ 1920 NHS ENGLAND RE-PRICING----------------------------------------------------------------------------------------------------------------------------
--Create a CTE with some fields revised and cleaned so the tariff tables can join to appropriate fields

WITH CTE_1 AS (

SELECT [Reporting_Month]
      ,[Provider]
      ,[MDT]
      ,[Service Line]
      ,[Service Line Code]
      ,[Source]
      ,[Source Description]
      ,[Actual Cost]
      ,[Actual Activity]
      ,[POD]
      ,[POD_Detail]
      ,[National_POD_Code]
	  ,case when National_POD_Code ='NELNE' then 'NEL' 
	        when National_POD_Code = 'OPPROCFUP' then 'OPPROC'
			when National_POD_Code = 'OPPROCFA' then 'OPPROC'
			when National_POD_Code = 'DAOTHER' then 'OPPROC'	
	  else National_POD_Code 
	  end as 'revised_national_POD'
      ,[Contract_Type]
      ,[PBR FLAG]
      ,[HRG Code]
	  ,case when [HRG Code] = 'FA' then 'WF01B'
	        when [HRG Code] = 'FUP' then 'WF01A'
			else [HRG Code]
		end as 'Revised HRG Code'
      ,[HRG Desc]
      ,[Excess bed days]
      ,[Excess bed day Cost]
      ,[Drug/Device Name]
      ,[Highly Specialised]
      ,[Adhoc_Further_Detail]
      ,[Annual Plan excl CQUIN]
      ,[YTD Plan excl CQUIN]
      ,[YTD Variance]
      ,[Annual Plan inc CQUIN]
      ,[Activity Plan]
      ,[Activity YTD Plan]
      ,[Unit Price]
      ,[Marginal Rate]
      ,[Marginal Threshold]
      ,[CQUIN]
      ,[Main Specialty Code]
      ,[Treatment Function Code]
      ,[TFC Description]
      ,[Provider_Code]
      ,[Provider_Site]
      ,[Claims_Category]
      ,[Challenge Amount]
      ,[POD Level 1]
      ,[POD Level 2]
      ,[POD Level 3]
      ,[POD Level 4]
      ,[POD Order]
      ,[Measure]
      ,[Measure Description]
      ,[HRG Chapter]
      ,[HRG Subchapter]
      ,[NPoc]
      ,[NPoC_Service]
      ,[NPoC_Service_Code]
      ,[Reported_Flag]
      ,[Flex_Freeze]
      ,[Drug Category/Device Code]
      ,[Drug Device Indicator]
      ,[Order]
      ,[Type]
      ,[Provider Tier]
      ,[Reporting Quarter]
      ,[CCG_Code]
      ,[Activity_Type]
      ,[Challenged_Activity]
      ,[Source_ID]
      ,[Report_Flag_Category]
      ,[RAW_Commissioned_Service_Category_Code]
      ,[RAW_Organisation_Identifier_Code_Of_Commissioner]
      ,[Raw_Service_Line_Code]
      ,[Raw_National_POD_Code]
      ,[CCG Region Code]
      ,[CCG Region Name]
      ,[CCG STP Code]
      ,[CCG STP Name]
      ,[Provider Region Code]
      ,[Provider Region Name]
      ,[Provider STP Code]
      ,[Provider STP Name]
	   FROM [NHS ENGLAND].[dbo].[1920 M8]

	   where [PBR FLAG] in ('Y','Yes')

       and Source <> 'Plan'
	   and ([Actual Cost] <> 0 
	   and [Actual Activity] <> 0)
	 ),

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Using the the CTE, join onto all of the TARIFF tables to create an extra few columns that will cost the data as per the 20/21 tariffs.  Please note, this has only been done where the PBR Flag is "Y"

CTE_2 AS (

select  [Reporting_Month]
      ,[Provider]
      ,[MDT]
      ,[Service Line]
      ,[Service Line Code]
      ,[Source]
      ,[Source Description]
      ,[Actual Cost]
      ,[Actual Activity]
      ,A.[POD]
      ,[POD_Detail]
      ,[National_POD_Code]
	  ,revised_national_POD
      ,[Contract_Type]
      ,[PBR FLAG]
      ,A.[HRG Code]
	  ,[Revised HRG Code]
      ,[HRG Desc]
      ,[Excess bed days]
      ,[Excess bed day Cost]
      ,[Drug/Device Name]
      ,[Highly Specialised]
      ,[Adhoc_Further_Detail]
      ,[Annual Plan excl CQUIN]
      ,[YTD Plan excl CQUIN]
      ,[YTD Variance]
      ,[Annual Plan inc CQUIN]
      ,[Activity Plan]
      ,[Activity YTD Plan]
      ,[Unit Price]
      ,[Marginal Rate]
      ,[Marginal Threshold]
      ,[CQUIN]
      ,[Main Specialty Code]
      ,[Treatment Function Code]
      ,[TFC Description]
      ,[Provider_Code]
      ,[Provider_Site]
      ,[Claims_Category]
      ,[Challenge Amount]
      ,[POD Level 1]
      ,[POD Level 2]
      ,[POD Level 3]
      ,[POD Level 4]
      ,[POD Order]
      ,[Measure]
      ,[Measure Description]
      ,[HRG Chapter]
      ,[HRG Subchapter]
      ,[NPoc]
      ,[NPoC_Service]
      ,[NPoC_Service_Code]
      ,[Reported_Flag]
      ,[Flex_Freeze]
      ,[Drug Category/Device Code]
      ,[Drug Device Indicator]
      ,[Order]
      ,[Type]
      ,[Provider Tier]
      ,[Reporting Quarter]
      ,[CCG_Code]
      ,[Activity_Type]
      ,[Challenged_Activity]
      ,[Source_ID]
      ,[Report_Flag_Category]
      ,[RAW_Commissioned_Service_Category_Code]
      ,[RAW_Organisation_Identifier_Code_Of_Commissioner]
      ,[Raw_Service_Line_Code]
      ,[Raw_National_POD_Code]
      ,[CCG Region Code]
      ,[CCG Region Name]
      ,[CCG STP Code]
      ,[CCG STP Name]
      ,[Provider Region Code]
      ,[Provider Region Name]
      ,[Provider STP Code]
      ,[Provider STP Name]
	  ,J.[MFF payment index for _2019/20]
	  ,P.Tariff as '2020/21 XBD TARIFF'
	  ,N.[Top up rate]
	  ,K.[Non-elective spell_(£)]
	  ,M.[Combined day case / ordinary elective spell_(£)]
	  ,O.[Per day long stay payment (for days exceeding trim point) (£)]
	 ,B.[2020/21 MFF_]-1 as '2020/21 MFF'
	  ,isnull(C.[20/21 specialist top-up rates],0) as '2020/21 STU'
	  ,isnull(D.Tariff,0) + isnull(E.Tariff,0) + isnull(F.tariff,0) + isnull(G.[Best practice tariff (£)_(per session)],0) + isnull(H.Tariff,0) + isnull((I.Tariff/12),0) + isnull(L.[Best Practice Tariff Addition],0) + isnull(Q.[best practice tariff addition],0) as '2020/21 Base HRG'
	  --The Base HRG field merges the OP, IP, UNBUNDLED, XBD, ARD, CF and Spinal BPT prices, (it works on the assumption there will only ever be one non-zero value in all of the columns - except for the BPT elements)
	  --CF tariffs divided by 12 as they are YEARLY values within the Annex A Workbook.  Spinal BPT has been assumed achieved for all providers.  Stroke BPT has been assumed achieved for all providers.
  FROM CTE_1 A

    ----------------------------------------------------------- 2021 PRICES--------------------------------------------------------------------------------------------------------------

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_MFF] B
  on A.[Provider_Code] = B.[Provider Code]

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_STU] C
  on A.[Service Line Code] = C.[PSS Flag] and [POD Level 1] = 'Admitted Patient Care'

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_IP] D
  on A.[Revised HRG Code] = D.[HRG Code] and A.revised_national_POD = D.POD and revised_national_POD not in ('ELXBD', 'NELXBD', 'NELNEXBD')

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_OP] E
  on A.[Revised HRG Code] = E.HRG and A.[Treatment Function Code]=E.TFC and [POD Level 1] = 'Outpatient'

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_UNBNDLD] F
  on A.[Revised HRG Code] = F.[HRG Code]

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_ARD] G
  on A.[Revised HRG Code] = G.[HRG Code]

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_XBD] H
  on A.[Revised HRG Code] = H.[HRG Code] and revised_national_POD in ('ELXBD', 'NELXBD', 'NELNEXBD')

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_XBD] P
  on A.[Revised HRG Code] = P.[HRG Code]

  --The join below is specific to the CF national prices - have mapped against the local HRG codes within the dataset to bring back the correct prices

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_CF] I
  on A.[Revised HRG Code] = I.[HRG Code]

  --The join below is specific to the SPINAL BPT, it is only BPT-tariff DELTA, not the whole tariff value

   left join [NHS ENGLAND].[dbo].[TARIFF_2021_SPINALBPT] L
  on A.[Revised HRG Code] = L.[HRG Code] and A.revised_national_POD = L.[POD]

  --The join below is specific to the STROKE BPT, it is only BPT-tariff DELTA, not the whole tariff value

  left join [NHS ENGLAND].[dbo].[TARIFF_2021_STROKEBPT] Q
  on A.[Revised HRG Code] = Q.[HRG code] and A.revised_national_POD = Q.POD
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ----------------------------------------------------------- 1920 PRICES--------------------------------------------------------------------------------------------------------------

  -- The tables below are all 1920 prices, for the reason of working backwards to determine and correct some of the price variances seen

  left join [NHS ENGLAND].[dbo].[TARIFF_1920_MFF] J
  on A.Provider_Code = J.[ Provider code]

  left join [NHS ENGLAND].[dbo].[1920_NEL] K
  on A.[Revised HRG Code] = K.[HRG code]

  left join [NHS ENGLAND].[dbo].[TARIFF_1920_IP] M
  on A.[Revised HRG Code] = M.[HRG code] and A.revised_national_POD = M.[POD]

  left join [NHS ENGLAND].[dbo].[TARIFF_1920_STU] N
  on A.[Service Line Code] = N.[PSS Flag]

  left join [NHS ENGLAND].[dbo].[TARIFF_1920_XBD] O
  on A.[Revised HRG Code] = O.[HRG code]
  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  ), 

  -----------------------------------------------------------CALCULATED FIELDS--------------------------------------------------------------------------------------------------------------

CTE_3 AS (
select *
,((([Actual Cost]/[Actual Activity])/[MFF payment index for _2019/20])/isnull([Top up rate],1)) as 'PROVIDER TARIFF UNIT COST FOR XBD (Z)'
,isnull([Combined day case / ordinary elective spell_(£)],0) as 'ACTUAL TARIFF UNIT COST FOR XBD (Z)'
,isnull((((([Actual Cost]/[Actual Activity])/[MFF payment index for _2019/20])/isnull([Top up rate],1))-[Combined day case / ordinary elective spell_(£)])/nullif([Per day long stay payment (for days exceeding trim point) (£)],0),0) as 'ACTUAL TARIFF XBD DAYS (Z)'
,([Actual Cost]/[Actual Activity])/[MFF payment index for _2019/20] as 'TARIFF UNIT COST 19/20'
,[Non-elective spell_(£)] as 'OFFICAL TARIFF UNIT COST 19/20'
,[2020/21 Base HRG]*[2020/21 STU] as '2020/21 STU COST'
,([2020/21 Base HRG]*(1+[2020/21 STU]))*[2020/21 MFF] as '2020/21 MFF COST'
,((1+[2020/21 STU])*[2020/21 Base HRG])*(1+[2020/21 MFF]) as '2020/21 TOTAL UNIT COST'
,(case when [Provider_Code] = 'RJZ' and revised_national_POD = 'YOC' then (((([Actual Cost]/[Actual Activity])/1.202198)*1.0142)*1.19117)
       when [Provider_Code] = 'RJ2' and revised_national_POD = 'YOC' then (((([Actual Cost]/[Actual Activity])/1.194349)*1.0142)*1.184397) 
       when ([Provider_Code] = 'R1H' and revised_national_POD = 'UNBCHEMO' and [Revised HRG Code] is null) then (((([Actual Cost]/[Actual Activity])/1.202384)*1.124)*1.191966) 
	   when ([Provider_Code] = 'RJ7' and revised_national_POD = 'UNBCHEMO' and [Revised HRG Code] is null) then (((([Actual Cost]/[Actual Activity])/1.201694)*1.124)*1.190934)
       else (((1+[2020/21 STU])*[2020/21 Base HRG])*(1+[2020/21 MFF]))end)*(case when [Actual Activity]=0 then 1 else [Actual Activity] end) as '2020/21 TOTAL COST'
from CTE_2
--Fields above are calculated from the joined fields, the costs are split and aggregated to give the unit cost and total cost (where activity is 0, replaced with 1 to avoid ZERO charges)
--The case statements are FIXES for issues with YOC and UNBCHEMO within the data for certain providers wherein they have provided no HRG code to link to
--The 1920 fields also work backwards to determine the additional XBD cost so as to reapply them to 2020/21 costs
),

CTE_4 AS (

select [Reporting_Month]
      ,[Provider]
      ,[MDT]
      ,[Service Line]
      ,[Service Line Code]
      ,[Source]
      ,[Source Description]
      ,[Actual Cost]
      ,[Actual Activity]
      ,[POD]
      ,[POD_Detail]
      ,[National_POD_Code]
	  ,revised_national_POD
      ,[Contract_Type]
      ,[PBR FLAG]
      ,[HRG Code]
	  ,[Revised HRG Code]
      ,[HRG Desc]
      ,[Excess bed days]
      ,[Excess bed day Cost]
      ,[Drug/Device Name]
      ,[Highly Specialised]
      ,[Adhoc_Further_Detail]
      ,[Annual Plan excl CQUIN]
      ,[YTD Plan excl CQUIN]
      ,[YTD Variance]
      ,[Annual Plan inc CQUIN]
      ,[Activity Plan]
      ,[Activity YTD Plan]
      ,[Unit Price]
      ,[Marginal Rate]
      ,[Marginal Threshold]
      ,[CQUIN]
      ,[Main Specialty Code]
      ,[Treatment Function Code]
      ,[TFC Description]
      ,[Provider_Code]
      ,[Provider_Site]
      ,[Claims_Category]
      ,[Challenge Amount]
      ,[POD Level 1]
      ,[POD Level 2]
      ,[POD Level 3]
      ,[POD Level 4]
      ,[POD Order]
      ,[Measure]
      ,[Measure Description]
      ,[HRG Chapter]
      ,[HRG Subchapter]
      ,[NPoc]
      ,[NPoC_Service]
      ,[NPoC_Service_Code]
      ,[Reported_Flag]
      ,[Flex_Freeze]
      ,[Drug Category/Device Code]
      ,[Drug Device Indicator]
      ,[Order]
      ,[Type]
      ,[Provider Tier]
      ,[Reporting Quarter]
      ,[CCG_Code]
      ,[Activity_Type]
      ,[Challenged_Activity]
      ,[Source_ID]
      ,[Report_Flag_Category]
      ,[RAW_Commissioned_Service_Category_Code]
      ,[RAW_Organisation_Identifier_Code_Of_Commissioner]
      ,[Raw_Service_Line_Code]
      ,[Raw_National_POD_Code]
      ,[CCG Region Code]
      ,[CCG Region Name]
      ,[CCG STP Code]
      ,[CCG STP Name]
      ,[Provider Region Code]
      ,[Provider Region Name]
      ,[Provider STP Code]
      ,[Provider STP Name]
	  ,[MFF payment index for _2019/20]
	  ,[PROVIDER TARIFF UNIT COST FOR XBD (Z)]
	  ,[ACTUAL TARIFF UNIT COST FOR XBD (Z)]
	  ,isnull(cast([ACTUAL TARIFF XBD DAYS (Z)] as decimal (16,9)),0) as 'ACTUAL TARIFF XBD DAYS (Z)'
	  ,case when cast([ACTUAL TARIFF XBD DAYS (Z)]*[2020/21 XBD TARIFF] as decimal(16,9))<0 then 0 else isnull(cast((([ACTUAL TARIFF XBD DAYS (Z)]*[2020/21 XBD TARIFF])*(1+[2020/21 STU]))*(1+[2020/21 MFF]) as decimal(16,9)),0) end as 'ACTUAL TARIFF XBD DAYS 2021 COST (Z)'
	  ,[TARIFF UNIT COST 19/20]-[OFFICAL TARIFF UNIT COST 19/20] as 'Variance of 1920 cost'
	  ,[2020/21 MFF]
	  ,[2020/21 STU]
	  ,[2020/21 XBD TARIFF]
	  ,[2020/21 Base HRG]
	  ,[2020/21 STU COST]
	  ,[2020/21 MFF COST]
	  ,[2020/21 TOTAL UNIT COST]
	  ,[2020/21 TOTAL COST]
	  ,case 
	  when ([Actual Cost] <> 0 and [2020/21 TOTAL COST] = 0) then [Actual Cost]*1.014
	  else [2020/21 TOTAL COST]
	  end as '2020/21 TOTAL COST WITH 1.4% UPLFIT ON ZERO COSTED ITEMS'
	  -- the CASE statement above looks at all items that are uncosted in 2020/21 but costed in the 1920 base data; and then applies a 1.4% increase on the cost, as there is no standardised way to cost these items
 from CTE_3

 ),

  -----------------------------------------------------------FINAL TABLE AND OUTPUT 2020/21--------------------------------------------------------------------------------------------------------------

CTE_5 AS (

select *,
          case when Provider_Code = 'RYJ' and [Service Line Code] = 'NCBPS34T' then cast((((([2020/21 Base HRG]+([Variance of 1920 cost]*1.0143))*(1+[2020/21 STU]))*(1+[2020/21 MFF]))*[Actual Activity]) as decimal (16,9)) else cast([2020/21 TOTAL COST WITH 1.4% UPLFIT ON ZERO COSTED ITEMS] as decimal (16,9))  end as '2020/21 TOTAL COST V2'
		  -- The CASE statement above applies a 1.43% increase on the Major Trauma BPT and then adds it to the calculated TOTAL COST for IMPERIAL only - other providers have the BPT separate
from CTE_4
),
CTE_6 AS (
select [Reporting_Month]
      ,[Provider]
      ,[MDT]
      ,[Service Line]
      ,[Service Line Code]
      ,[Source]
      ,[Source Description]
      ,[Actual Cost]
      ,[Actual Activity]
      ,[POD]
      ,[POD_Detail]
      ,[National_POD_Code]
	  ,revised_national_POD
      ,[Contract_Type]
      ,[PBR FLAG]
      ,[HRG Code]
	  ,[Revised HRG Code]
      ,[HRG Desc]
      ,[Excess bed days]
      ,[Excess bed day Cost]
      ,[Drug/Device Name]
      ,[Highly Specialised]
      ,[Adhoc_Further_Detail]
      ,[Annual Plan excl CQUIN]
      ,[YTD Plan excl CQUIN]
      ,[YTD Variance]
      ,[Annual Plan inc CQUIN]
      ,[Activity Plan]
      ,[Activity YTD Plan]
      ,[Unit Price]
      ,[Marginal Rate]
      ,[Marginal Threshold]
      ,[CQUIN]
      ,[Main Specialty Code]
      ,[Treatment Function Code]
      ,[TFC Description]
      ,[Provider_Code]
      ,[Provider_Site]
      ,[Claims_Category]
      ,[Challenge Amount]
      ,[POD Level 1]
      ,[POD Level 2]
      ,[POD Level 3]
      ,[POD Level 4]
      ,[POD Order]
      ,[Measure]
      ,[Measure Description]
      ,[HRG Chapter]
      ,[HRG Subchapter]
      ,[NPoc]
      ,[NPoC_Service]
      ,[NPoC_Service_Code]
      ,[Reported_Flag]
      ,[Flex_Freeze]
      ,[Drug Category/Device Code]
      ,[Drug Device Indicator]
      ,[Order]
      ,[Type]
      ,[Provider Tier]
      ,[Reporting Quarter]
      ,[CCG_Code]
      ,[Activity_Type]
      ,[Challenged_Activity]
      ,[Source_ID]
      ,[Report_Flag_Category]
      ,[RAW_Commissioned_Service_Category_Code]
      ,[RAW_Organisation_Identifier_Code_Of_Commissioner]
      ,[Raw_Service_Line_Code]
      ,[Raw_National_POD_Code]
      ,[CCG Region Code]
      ,[CCG Region Name]
      ,[CCG STP Code]
      ,[CCG STP Name]
      ,[Provider Region Code]
      ,[Provider Region Name]
      ,[Provider STP Code]
      ,[Provider STP Name]
	  ,[MFF payment index for _2019/20]
	  ,[PROVIDER TARIFF UNIT COST FOR XBD (Z)]
	  ,[ACTUAL TARIFF UNIT COST FOR XBD (Z)]
	  ,[ACTUAL TARIFF XBD DAYS 2021 COST (Z)]
	  ,[Variance of 1920 cost]
	  ,[2020/21 MFF]
	  ,[2020/21 STU]
	  ,[2020/21 XBD TARIFF]
	  ,[2020/21 Base HRG]
	  ,[2020/21 STU COST]
	  ,[2020/21 MFF COST]
	  ,[2020/21 TOTAL UNIT COST]
	  ,[2020/21 TOTAL COST] as '2020/21 TOTAL COST INITIAL'
	  , 
         case when National_POD_Code in ('EL', 'NEL') and Provider_Code <> 'RYJ' then [2020/21 TOTAL COST V2]+[ACTUAL TARIFF XBD DAYS 2021 COST (Z)] 
		      when ([Service Line Code] ='NCBPS34T' and Provider_Code = 'RYJ') then [2020/21 TOTAL COST V2]
		      else [2020/21 TOTAL COST V2]+[ACTUAL TARIFF XBD DAYS 2021 COST (Z)] end as '2020/21 TOTAL COST FINAL'
		 --The case statement above ADDS the calculated excess bed days to the 2020/21 TARIFF calculation - with the exception of RYJ MAJOR TRAUMA, as that was dealt with separately
from CTE_5
)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select * from CTE_6
