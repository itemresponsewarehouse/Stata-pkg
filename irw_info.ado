*! irw_info 0.1.0  26oct2026  Item Response Warehouse
*! An overview of the warehouse, or of one table.
program define irw_info
	version 15.0
	syntax [anything(name=tbl id="table name")] [, SOurce(string) Force ]

	if "`source'" == "" local source "core"

	if `"`tbl'"' != "" {
		irw_describe `tbl', source(`source')
		capture noisily irw_tags `tbl', source(`source')
		capture noisily irw_cite `tbl', source(`source')
		exit
	}

	_irw_metatable, source(`source')
	local mt "`r(table)'"

	preserve
		_irw_meta, table(`mt') `force'
		quietly use `"`r(path)'"', clear
		local ntab = _N
		local nresp = .
		capture confirm variable n_responses
		if _rc == 0 {
			quietly summarize n_responses, meanonly
			local nresp = r(sum)
		}
	restore

	di as txt ""
	di as txt "{bf:Item Response Warehouse} -- `source'"
	di as txt "{hline 60}"
	di as txt "tables"    _col(16) as res %14.0fc `ntab'
	if `nresp' < . di as txt "responses" _col(16) as res %14.0fc `nresp'
	di as txt ""
	di as txt `"{p}Browse: {browse "https://itemresponsewarehouse.org"}{p_end}"'
	di as txt "{p}Find a table with {bf:irw_search}, then {bf:irw_fetch} {it:name}{bf:, clear}.{p_end}"
	di as txt "{p}This package reads the warehouse's public CSV endpoint, so no Redivis" ///
		" account is needed for tables under 100MB. The R and Python {bf:irw} packages" ///
		" authenticate and have no such limit.{p_end}"
end
