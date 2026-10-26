*! irw_wide 0.1.0  26oct2026  Item Response Warehouse
*! Reshape an IRW long table to one row per respondent, ready for -irt- and -gsem-.
program define irw_wide
	version 15.0
	syntax [, Id(name) ITem(name) Resp(name) KEY(string) PREfix(name) replace ]

	if "`id'"     == "" local id   id
	if "`item'"   == "" local item item
	if "`resp'"   == "" local resp resp
	if "`prefix'" == "" local prefix resp

	foreach v in id item resp {
		capture confirm variable ``v''
		if _rc {
			di as err "variable ``v'' not found; name it with `v'()"
			exit 111
		}
	}

	* Nothing below this point touches the user's data until the reshape is
	* certain to run: every refusal here restores what they had.
	preserve

	* Covariates cannot come along: a person-by-item covariate is not constant
	* within respondent, which is exactly what reshape refuses.
	local extra ""
	foreach v of varlist _all {
		if !inlist("`v'", "`id'", "`item'", "`resp'") local extra "`extra' `v'"
	}

	quietly duplicates report `id' `item'
	if r(unique_value) < r(N) {
		local ndup = r(N) - r(unique_value)
		di as err "{p}`ndup' duplicate `id'-`item' pairs. These can be real data in the" ///
			" warehouse -- repeated administrations, trials -- so irw_wide will not guess" ///
			" at them.{p_end}"
		di as err "{p 4 4 2}Collapse them yourself first, or keep one per pair, e.g." ///
			" {bf:bysort `id' `item': keep if _n == 1}.{p_end}"
		exit 459
	}

	if "`extra'" != "" {
		di as txt "{p}note: dropping" as res "`extra'" as txt ///
			" -- only `id', `item' and `resp' survive the reshape." ///
			" Collapse them to the respondent level and {bf:merge} them back" ///
			" if you need them.{p_end}"
		quietly keep `id' `item' `resp'
	}

	capture drop _itemnum
	capture label drop _itemnum
	quietly egen _itemnum = group(`item'), label
	quietly summarize _itemnum, meanonly
	local K = r(max)

	local maxk = c(maxvar)
	if (`K' + 2) > `maxk' {
		di as err "{p}this table has `K' items, and this Stata is set to allow `maxk'" ///
			" variables, so the wide form will not fit.{p_end}"
		di as err "{p 4 4 2}Raise it with {bf:set maxvar} (this flavour's ceiling is" ///
			" " c(max_k_theory) "), or subset the items first.{p_end}"
		exit 1000
	}

	local vl : value label _itemnum
	if "`vl'" != "" {
		forvalues k = 1/`K' {
			local lab`k' : label `vl' `k'
		}
	}

	if `"`key'"' != "" {
		tempfile beforekey
		quietly save `"`beforekey'"'
		quietly keep `item' _itemnum
		quietly duplicates drop
		quietly gen str32 variable = "`prefix'" + string(_itemnum)
		quietly order variable _itemnum `item'
		label variable variable "variable name in the wide data"
		label variable _itemnum "item number"
		label variable `item' "item identifier in the warehouse"
		capture quietly save `"`key'"', `replace'
		if _rc {
			quietly use `"`beforekey'"', clear
			di as err `"could not write the key to `key'"'
			di as err "{p 4 4 2}If it already exists, specify {bf:replace}.{p_end}"
			exit _rc
		}
		quietly use `"`beforekey'"', clear
		di as txt "item key written to " as res `"`key'"'
	}

	* reshape requires every non-i(), non-j(), non-stub variable to be constant
	* within i(). item is not, by construction, so it cannot survive the call.
	quietly drop `item'
	quietly reshape wide `resp', i(`id') j(_itemnum)
	restore, not

	forvalues k = 1/`K' {
		capture confirm variable `resp'`k'
		if _rc continue
		if "`prefix'" != "`resp'" {
			capture confirm variable `prefix'`k'
			if _rc rename `resp'`k' `prefix'`k'
			else di as txt "note: `prefix'`k' already exists; left `resp'`k' as it was"
		}
		capture label variable `prefix'`k' `"`lab`k''"'
	}

	di as txt ""
	di as txt "wide: " as res %9.0fc _N as txt " respondents by " as res `K' as txt " items"
	local alsokey ""
	if `"`key'"' != "" local alsokey `" and in `key'"'
	di as txt "{p}Item names are kept as variable labels`alsokey'; Stata's" ///
		" 32-character variable names cannot carry them.{p_end}"
	di as txt "{p}Now e.g. {bf:irt 2pl `prefix'*}.{p_end}"
end
