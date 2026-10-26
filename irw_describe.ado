*! irw_describe 0.1.0  26oct2026  Item Response Warehouse
*! Show a table's shape and columns without downloading it.
program define irw_describe, rclass
	version 15.0
	syntax anything(name=tbl id="table name") [, SOurce(string) ]

	if "`source'" == "" local source "core"

	_irw_dataset `tbl', source(`source')
	local ds "`r(dataset)'"

	_irw_tableinfo, dataset("`ds'") table("`tbl'")
	local nrows  = r(numrows)
	local nbytes = r(numbytes)
	local nvars  = r(numvars)
	local qref   "`r(qref)'"

	local cap = 100 * 1024 * 1024

	di as txt ""
	di as txt "{bf:`tbl'}"
	di as txt "{hline 60}"
	di as txt "dataset"   _col(20) as res "datapages.`ds'"
	di as txt "version"   _col(20) as res "`qref'"
	di as txt "responses" _col(20) as res %12.0fc `nrows'
	di as txt "columns"   _col(20) as res %12.0fc `nvars'
	di as txt "size"      _col(20) as res %12.0fc `nbytes' as txt " bytes"
	if `nbytes' > `cap' {
		di as txt "anonymous"  _col(20) as err "over the 100MB cap -- irw_fetch needs token()"
	}
	else {
		di as txt "anonymous"  _col(20) as res "yes"
	}

	* One row is enough to learn the column names, and costs nothing.
	preserve
		tempfile csv
		capture _irw_get, dataset("`ds'") table("`tbl'") file(`"`csv'"') ///
			maxresults(1) nosizecheck
		if _rc == 0 {
			quietly import delimited using `"`csv'"', clear varnames(1) encoding(utf-8)
			capture drop _unnamed_var
			local cols ""
			foreach v of varlist _all {
				local cols "`cols' `v'"
			}
			di as txt ""
			di as txt "columns:" as res "`cols'"
		}
	restore

	return local dataset "`ds'"
	return local qref "`qref'"
	return scalar numrows  = `nrows'
	return scalar numbytes = `nbytes'
	return scalar numvars  = `nvars'
end
