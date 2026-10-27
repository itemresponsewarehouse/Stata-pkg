*! irw_long 0.1.0  26oct2026  Item Response Warehouse
*! Reshape a wide person-by-item matrix back to IRW long format.
program define irw_long
	version 15.0
	syntax [, Id(name) PREfix(name) KEY(string) ITem(name) Resp(name) ]

	if "`id'"     == "" local id   id
	if "`prefix'" == "" local prefix resp
	if "`item'"   == "" local item item
	if "`resp'"   == "" local resp resp

	capture confirm variable `id'
	if _rc {
		di as err "variable `id' not found; name it with id()"
		exit 111
	}

	capture unab candidates : `prefix'*
	local wide ""
	local stray ""
	foreach v of local candidates {
		if ustrregexm("`v'", "^`prefix'[0-9]+$") local wide "`wide' `v'"
		else local stray "`stray' `v'"
	}
	if `"`wide'"' == "" {
		di as err "no variables named `prefix' followed by a number; name them with prefix()"
		exit 111
	}
	* reshape long claims every variable starting with the stub, not just the
	* numbered ones, and dies on a non-numeric j. Say so rather than let it.
	if `"`stray'"' != "" {
		di as err "{p}these start with {bf:`prefix'} but do not end in a number, and" ///
			" {bf:reshape long} would take them too:" as res "`stray'" as err "{p_end}"
		di as err "{p 4 4 2}Drop or rename them, or choose a {bf:prefix()} that does not" ///
			" match them.{p_end}"
		exit 198
	}

	quietly reshape long `prefix', i(`id') j(_itemnum)

	if "`prefix'" != "`resp'" rename `prefix' `resp'
	quietly drop if missing(`resp')

	if `"`key'"' != "" {
		quietly merge m:1 _itemnum using `"`key'"', keepusing(`item') ///
			keep(master match) nogenerate
		quietly drop if missing(`item')
	}
	else {
		quietly gen str32 `item' = "item" + string(_itemnum)
		di as txt "{p}note: no key() given, so items are numbered rather than named." ///
			" irw_wide writes that key when you ask it to.{p_end}"
	}

	quietly drop _itemnum
	quietly order `id' `item' `resp'
	_irw_clean

	di as txt "long: " as res %9.0fc _N as txt " responses"
end
