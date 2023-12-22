*PhD Ch3

*DJ de Villiers
*2023/05/29
*use Forbes and Warnock (2021) dataset; merge in Alam et al (2019) dataset (MaPPs)

*setup project directory
clear
global project_directory "C:/Users/de Villiers/Downloads" // main folder
cd "$project_directory"

* Forbes and Warnock have 3 seperate datasets, which we need to merge to estimate the episodes

use "ForbesWarnock_flows_dataset.dta"
merge 1:1  yr qtr id country time using "ForbesWarnock_control_variables.dta"

*each merge generates a merge variable, which we create a copy, and delete the original (otherwise you cannot merge more than one dataset)

gen merge1 = _merge
drop _merge

merge 1:1 yr qtr id country time using "ForbesWarnock_episodes.dta"

gen merge2 = _merge
drop _merge

gen IFSCODE = id

*yr qtr id_time do not uniquely identify the data becuase there are extra unlabeled observations
*so I sort the data, tag them, and then drop the duplicates
sort yr qtr id_time 
quietly by yr qtr id_time: gen dup2 = cond(_N==1,0,_n)
drop if dup2>1

*I save the dataset before adding the MaPPs
save PhD_Ch3_panel_without_CFMs, replace

*the MaPPs dataset is just the Alam/ iMaPP dataset, imported and saved in the .dta format. 
merge 1:1 yr qtr id_time using "PhD_panel_2_mapps.dta", force

save PhD_Ch3_panel, replace


*drop any observations with missing data for the MaPPs
drop if missing(code_1)

*declare panel variables
xtset id milkyway 



teffects psmatch (surge_epiTO) (code_1 vxo_ch money_global_growth lt_rate_us_jp_ea_uk growth_global cont_surge realgdpyoy, noconstant), nn(2)  

teffects psmatch (stop_epiTO) (code_1 vxo_ch money_global_growth lt_rate_us_jp_ea_uk growth_global cont_stop realgdpyoy, noconstant), nn(2) 

