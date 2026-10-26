*! _irw_metatable 0.1.0  26oct2026  Item Response Warehouse
*! Map a source name to its catalogue table in irw_meta. Private helper.
program define _irw_metatable, rclass
	version 15.0
	syntax , Source(string)

	local source = lower("`source'")
	if inlist("`source'", "core", "main")                       local t "metadata"
	else if inlist("`source'", "conj", "conjoint")              local t "conj_metadata"
	else if inlist("`source'", "rank", "rankings")              local t "rank_metadata"
	else if inlist("`source'", "comp", "comps", "competitions") local t "comps_metadata"
	else if inlist("`source'", "nom", "nominal")                local t "nominal_metadata"
	else if inlist("`source'", "sim", "simsyn")                 local t "simsyn_metadata"
	else {
		di as err "unknown source `source'"
		di as err "{p 4 4 2}Known sources: core, conj, rank, comp, nom, sim.{p_end}"
		exit 198
	}
	return local table "`t'"
end
