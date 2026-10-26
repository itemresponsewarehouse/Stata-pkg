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

	capture unab wide : `prefix'*
	if _rc | "`wide'" == "" {
		di as err "no variables named `prefix'*; name them with prefix()"
		exit 111
	}

	quietly reshape long `prefix', i(`id') j(_itemnum)

	if "`prefix'" != "`resp'" rename `prefix' `resp'
	quietly drop if missing(`resp')

	if `"`key'"' != "" {
		quietly merge m:1 _itemnum using `"`key'"', keepusing(`item') nogenerate
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
