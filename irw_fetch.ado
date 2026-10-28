*! irw_fetch 0.1.1  28oct2026  Item Response Warehouse
*! Download one IRW table into memory, in the warehouse's long format.
program define irw_fetch
	version 15.0
	syntax anything(name=tbl id="table name") [, CLEAR COLumns(string) ///
		MAXrows(integer 0) SOurce(string) TOKen(string) NOCAche Force ]

	if "`clear'" == "" & c(k) > 0 {
		di as err "no; data in memory would be lost"
		di as err "{p 4 4 2}Specify {bf:clear} to replace it.{p_end}"
		exit 4
	}
	if "`source'" == "" local source "core"

	local bounded = ("`columns'" != "" | `maxrows' > 0)
	if `maxrows' > 0 {
		di as txt "{p}note: maxrows() takes the rows Redivis happens to return first." ///
			" Row order in the warehouse is arbitrary, so this is a preview of the" ///
			" table, not a sample of it, and it will not hold whole respondents.{p_end}"
	}

	_irw_dataset `tbl', source(`source')
	local ds "`r(dataset)'"

	_irw_tableinfo, dataset("`ds'") table("`tbl'")
	if r(found) == 0 {
		di as err `"the catalogue puts "`tbl'" in datapages.`ds', but Redivis does not have it there"'
		di as err "{p 4 4 2}The cached catalogue may be stale; try {bf:irw_cache, clear}.{p_end}"
		exit 601
	}
	local hash   "`r(hash)'"
	local qref   "`r(qref)'"
	local nrows  = r(numrows)
	local nbytes = r(numbytes)

	_irw_cachedir, subdir(tables)
	local cdir `"`r(dir)'"'
	local sep  "`r(sep)'"
	local cfile `"`cdir'`sep'`ds'__`tbl'__`hash'.dta"'

	local fromcache = 0
	if "`nocache'" == "" & "`force'" == "" & !`bounded' {
		capture confirm file `"`cfile'"'
		if _rc == 0 {
			quietly use `"`cfile'"', clear
			local fromcache = 1
		}
	}

	if !`fromcache' {
		tempfile csv
		_irw_get, dataset("`ds'") table("`tbl'") file(`"`csv'"') ///
			vars(`"`columns'"') maxresults(`maxrows') token(`"`token'"') ///
			knownbytes(`nbytes')
		local url `"`r(url)'"'

		* maxquotedrows() is Stata 16 and later; under 15 bindquote(strict) already
		* spans newlines, with no row cap to raise.
		local qrows ""
		if c(stata_version) >= 16 local qrows "maxquotedrows(200000)"
		quietly import delimited using `"`csv'"', clear varnames(1) ///
			bindquote(strict) `qrows' encoding(utf-8)

		_irw_clean

		char _dta[irw_table]   "`tbl'"
		char _dta[irw_dataset] "`ds'"
		char _dta[irw_source]  "`source'"
		char _dta[irw_hash]    "`hash'"
		char _dta[irw_qref]    "`qref'"
		char _dta[irw_url]     `"`url'"'
		char _dta[irw_fetched] "`c(current_date)'"

		if "`nocache'" == "" & !`bounded' {
			capture quietly save `"`cfile'"', replace
		}
	}

	di as txt ""
	di as txt "{bf:`tbl'}" _col(32) as txt "datapages.`ds'"
	di as txt "{hline 60}"
	di as txt "responses in memory" _col(32) as res %12.0fc _N
	if !`bounded' {
		di as txt "responses in warehouse" _col(32) as res %12.0fc `nrows'
	}
	foreach v in id item {
		capture confirm variable `v'
		if _rc == 0 {
			tempvar t
			quietly egen `t' = tag(`v')
			quietly count if `t' == 1
			local lab = cond("`v'" == "id", "respondents", "items")
			di as txt "`lab'" _col(32) as res %12.0fc r(N)
			drop `t'
		}
	}
	di as txt "source" _col(32) as res cond(`fromcache', "local cache", "redivis.com")
	di as txt ""
	di as txt "{p}Next: {bf:irw_wide} reshapes this to one row per respondent," ///
		" which is what {bf:irt} and {bf:gsem} expect. {bf:irw_cite `tbl'} gives the citation.{p_end}"
end
