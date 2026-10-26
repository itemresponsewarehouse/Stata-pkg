*! irw_metadata 0.1.0  26oct2026  Item Response Warehouse
*! Load the IRW catalogue into memory, one row per table.
program define irw_metadata
	version 15.0
	syntax [, CLEAR SOurce(string) Force ]

	if "`clear'" == "" & c(k) > 0 {
		di as err "no; data in memory would be lost"
		di as err "{p 4 4 2}Specify {bf:clear} to replace it.{p_end}"
		exit 4
	}
	if "`source'" == "" local source "core"

	_irw_metatable, source(`source')
	local mt "`r(table)'"

	_irw_meta, table(`mt') `force'
	quietly use `"`r(path)'"', clear

	di as txt ""
	di as txt "IRW catalogue: " as res "`mt'" as txt " (`source')"
	di as res %9.0fc _N as txt " tables, " as res c(k) as txt " columns"
	di as txt "{p}Filter it with ordinary Stata ({bf:keep if n_items > 20}), or use" ///
		" {bf:irw_search} to do that without disturbing your data.{p_end}"
end
