*! smoke.do -- end-to-end check of the irw Stata package
*!
*! Nothing in this repository's CI can run this: Stata needs a licence. So it is
*! written to be handed to someone who has one. It is self-contained, needs no
*! Redivis account, and downloads about 2 MB.
*!
*! To run from a checkout:   do tests/smoke.do
*! To run after installing:  do smoke.do
*!
*! Please send back the whole log, passes and failures both.

clear all
set more off
version 15.0

* Use the checkout if we are in one; otherwise rely on the installed package.
capture confirm file "irw_fetch.ado"
if _rc == 0 adopath ++ "`c(pwd)'"
capture confirm file "../irw_fetch.ado"
if _rc == 0 adopath ++ ".."

local failures = 0

capture log close smoke
log using irw_smoke, replace name(smoke) text

di as txt "{hline 70}"
di as txt "irw Stata package smoke test"
di as txt "Stata " c(stata_version) " " c(flavor) " on " c(os) ", " c(current_date) " " c(current_time)
di as txt "max variables: " c(maxvar) " (flavour ceiling " c(max_k_theory) ")"
di as txt "{hline 70}"

*-----------------------------------------------------------------------
* 1. The warehouse answers at all
*-----------------------------------------------------------------------
di as txt _n "== 1. irw_info"
capture noisily irw_info
if _rc local failures = `failures' + 1

*-----------------------------------------------------------------------
* 2. Describe a known table without downloading it
*-----------------------------------------------------------------------
di as txt _n "== 2. irw_describe 4thgrade_math_sirt"
capture noisily irw_describe 4thgrade_math_sirt
if _rc {
	local failures = `failures' + 1
}
else {
	if r(numrows) != 19920 {
		di as err "FAIL: expected 19920 responses, got " r(numrows)
		local failures = `failures' + 1
	}
	if "`r(dataset)'" != "item_response_warehouse" {
		di as err "FAIL: expected shard item_response_warehouse, got `r(dataset)'"
		local failures = `failures' + 1
	}
}

*-----------------------------------------------------------------------
* 3. Fetch it
*-----------------------------------------------------------------------
di as txt _n "== 3. irw_fetch 4thgrade_math_sirt"
capture noisily irw_fetch 4thgrade_math_sirt, clear
if _rc {
	local failures = `failures' + 1
}
else {
	if _N != 19920 {
		di as err "FAIL: expected 19920 rows in memory, got " _N
		local failures = `failures' + 1
	}
	foreach v in id item resp {
		capture confirm variable `v'
		if _rc {
			di as err "FAIL: no `v' column after fetch"
			local failures = `failures' + 1
		}
	}
	local t : char _dta[irw_table]
	if "`t'" != "4thgrade_math_sirt" {
		di as err "FAIL: provenance char not set, got `t'"
		local failures = `failures' + 1
	}
	describe
}

*-----------------------------------------------------------------------
* 4. The cache: a second fetch should come from disk
*-----------------------------------------------------------------------
di as txt _n "== 4. cached refetch"
capture noisily irw_fetch 4thgrade_math_sirt, clear
if _rc local failures = `failures' + 1

*-----------------------------------------------------------------------
* 5. Reshape to wide and fit something
*-----------------------------------------------------------------------
di as txt _n "== 5. irw_wide + irt 2pl"
capture noisily irw_wide, key(smoke_key.dta) replace
if _rc {
	local failures = `failures' + 1
}
else {
	capture unab rv : resp*
	local nrv : word count `rv'
	di as txt "wide: " _N " respondents, `nrv' item variables"
	if _N == 0 {
		di as err "FAIL: no rows after reshape"
		local failures = `failures' + 1
	}
	* The item name must have survived as a variable label.
	local lab : variable label resp1
	if "`lab'" == "" {
		di as err "FAIL: resp1 has no variable label, so the item name was lost"
		local failures = `failures' + 1
	}
	else di as txt "resp1 is item: `lab'"

	capture noisily irt 2pl resp*
	if _rc {
		di as err "FAIL: irt 2pl did not run (rc = " _rc ")"
		local failures = `failures' + 1
	}
	else capture noisily estat report, sort(b)
}

*-----------------------------------------------------------------------
* 6. Round-trip back to long
*-----------------------------------------------------------------------
di as txt _n "== 6. irw_long round trip"
capture noisily irw_long, key(smoke_key.dta)
if _rc {
	local failures = `failures' + 1
}
else {
	if _N != 19920 {
		di as err "NOTE: round trip gave " _N " rows, not 19920." ///
			" A difference here means the original had missing resp values."
	}
}

*-----------------------------------------------------------------------
* 7. Citation and tags
*-----------------------------------------------------------------------
di as txt _n "== 7. irw_cite / irw_tags"
capture noisily irw_cite 4thgrade_math_sirt
if _rc local failures = `failures' + 1
capture noisily irw_tags 4thgrade_math_sirt
if _rc local failures = `failures' + 1

*-----------------------------------------------------------------------
* 8. Search
*-----------------------------------------------------------------------
di as txt _n "== 8. irw_search"
capture noisily irw_search, name(4thgrade) max(10)
if _rc {
	local failures = `failures' + 1
}
else if r(N) == 0 {
	di as err "FAIL: search for 4thgrade matched nothing"
	local failures = `failures' + 1
}

*-----------------------------------------------------------------------
* 9. Error paths -- these are SUPPOSED to fail, cleanly
*-----------------------------------------------------------------------
di as txt _n "== 9a. over the 100MB cap (expect a clear refusal, not a crash)"
capture noisily irw_fetch pisa2018_read, clear
if _rc == 0 {
	di as err "FAIL: pisa2018_read should not fetch anonymously"
	local failures = `failures' + 1
}
else di as txt "  -> refused with rc = " _rc ", as intended"

di as txt _n "== 9b. a table that does not exist"
capture noisily irw_fetch not_a_real_table_zzz, clear
if _rc == 0 {
	di as err "FAIL: a nonexistent table should not fetch"
	local failures = `failures' + 1
}
else di as txt "  -> refused with rc = " _rc ", as intended"

di as txt _n "== 9c. a wider table, reshaped for real"
di as txt "  (a few hundred items; the variable-limit refusal itself is covered"
di as txt "   offline in unit.do, which lowers maxvar to reach it)"
capture noisily irw_fetch previc_bohn2023, clear columns(id item resp)
if _rc {
	local failures = `failures' + 1
}
else {
	capture noisily irw_wide
	if _rc {
		di as err "FAIL: a 379-item table should reshape under maxvar = " c(maxvar)
		local failures = `failures' + 1
	}
	else {
		capture unab rv : resp*
		di as txt "  -> " _N " respondents by `: word count `rv'' items"
	}
}

*-----------------------------------------------------------------------
di as txt _n "{hline 70}"
if `failures' == 0 di as result "SMOKE TEST PASSED"
else di as err "SMOKE TEST: `failures' failure(s) -- see above"
di as txt "{hline 70}"

capture erase smoke_key.dta
log close smoke
