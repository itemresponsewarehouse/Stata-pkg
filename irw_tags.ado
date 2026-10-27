*! irw_tags 0.1.0  26oct2026  Item Response Warehouse
*! The hand-annotated tags for one table.
*! Tagging is incomplete across the corpus, so an absent tag is not a denial.
program define irw_tags, rclass
	version 15.0
	syntax [anything(name=tbl id="table name")] [, SOurce(string) Force ]

	if "`source'" == "" local source "core"
	if `"`tbl'"' == "" {
		local tbl : char _dta[irw_table]
		if "`tbl'" == "" {
			di as err "give a table name, or run irw_fetch first"
			exit 198
		}
	}

	local tagtbl = cond(inlist(lower("`source'"), "nom", "nominal"), "nominal_tags", "tags")

	local found = 0
	preserve
		_irw_meta, table(`tagtbl') `force'
		quietly use if table == "`tbl'" using `"`r(path)'"', clear
		if _N > 0 {
			local found = 1
			di as txt ""
			di as txt "{bf:`tbl'}" as txt "  (tags)"
			di as txt "{hline 60}"
			foreach v of varlist _all {
				if "`v'" == "table" continue
				local val = `v'[1]
				if inlist(`"`val'"', "NA", ".", "") continue
				local lab = subinstr("`v'", "_", " ", .)
				di as txt "{p 0 26 2}`lab'" _col(26) as res `"`val'"' "{p_end}"
			}
		}
	restore

	if !`found' {
		di as txt "no tags on file for `tbl'"
		di as txt "{p}Tagging is incomplete across the warehouse, so this is an absence of" ///
			" information, not a statement that the table is untaggable.{p_end}"
	}
	return scalar found = `found'
end
