*! irw_itemtext 0.1.1  28oct2026  Item Response Warehouse
*! Load the item wording that ships with one IRW table.
program define irw_itemtext
	version 15.0
	syntax anything(name=tbl id="table name") [, CLEAR Force ]

	if "`clear'" == "" & c(k) > 0 {
		di as err "no; data in memory would be lost"
		di as err "{p 4 4 2}Specify {bf:clear} to replace it.{p_end}"
		exit 4
	}

	local itbl "`tbl'__items"

	_irw_dataset `itbl', source(text) quietly
	if r(found) == 0 {
		di as err `"no item text published for "`tbl'""'
		di as err "{p 4 4 2}Item text is a separate, slower-moving collection than the" ///
			" response data; most tables do not have it yet.{p_end}"
		exit 601
	}
	local ds "`r(dataset)'"

	tempfile csv
	_irw_get, dataset("`ds'") table("`itbl'") file(`"`csv'"')
	* maxquotedrows() is Stata 16 and later; under 15 bindquote(strict) already
	* spans newlines, with no row cap to raise.
	local qrows ""
	if c(stata_version) >= 16 local qrows "maxquotedrows(200000)"
	quietly import delimited using `"`csv'"', clear varnames(1) ///
		bindquote(strict) `qrows' encoding(utf-8)
	capture drop _unnamed_var

	char _dta[irw_table] "`tbl'"
	char _dta[irw_dataset] "`ds'"

	di as txt ""
	di as txt "{bf:`tbl'} item text: " as res %9.0fc _N as txt " rows from datapages.`ds'"
	di as txt "{p}Item text is published so you can see what was asked. It carries no" ///
		" licence to reuse the instrument -- that is the originator's to give." ///
		" Check {bf:irw_cite `tbl'} and the warehouse's item-text licensing page" ///
		" before reproducing any of it.{p_end}"
end
