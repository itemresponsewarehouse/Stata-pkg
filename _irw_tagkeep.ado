*! _irw_tagkeep 0.1.0  26oct2026  Item Response Warehouse
*! Case-insensitive substring keep on one tag column. Private helper.
program define _irw_tagkeep
	version 15.0
	args col pattern

	if `"`pattern'"' == "" exit
	capture confirm variable `col'
	if _rc {
		di as err "no tag column named `col' in this catalogue"
		exit 111
	}
	quietly keep if strpos(lower(`col'), lower(`"`pattern'"')) > 0
end
