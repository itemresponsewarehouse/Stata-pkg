*! _irw_clean 0.1.0  26oct2026  Item Response Warehouse
*! Tidy a freshly imported IRW table: drop Redivis's index column, repair resp,
*! and label the standard columns. Private helper.
program define _irw_clean
	version 15.0

	capture drop _unnamed_var
	capture drop unnamed_var

	* resp arrives as a string whenever the table carries literal NA.
	capture confirm string variable resp
	if _rc == 0 {
		quietly count if trim(resp) == "NA" | trim(resp) == ""
		local nna = r(N)
		quietly replace resp = "" if trim(resp) == "NA"
		capture quietly destring resp, replace
		capture confirm string variable resp
		if _rc == 0 {
			di as txt "note: resp is not numeric in this table and was left as a string"
		}
		else if `nna' > 0 {
			di as txt "note: " %9.0fc `nna' " resp values were NA and are now missing"
		}
	}

	capture label variable id   "respondent identifier"
	capture label variable item "item identifier"
	capture label variable resp "response"
	capture label variable rt   "response time"
	capture label variable date "date of response"
	capture label variable wave "wave"

	foreach v of varlist _all {
		if strpos("`v'", "itemcov_") == 1 {
			local nm = substr("`v'", 9, .)
			capture label variable `v' "item covariate: `nm'"
		}
		else if strpos("`v'", "cov_") == 1 {
			local nm = substr("`v'", 5, .)
			capture label variable `v' "covariate: `nm'"
		}
		else if strpos("`v'", "trial_") == 1 {
			local nm = substr("`v'", 7, .)
			capture label variable `v' "trial detail: `nm'"
		}
	}
end
