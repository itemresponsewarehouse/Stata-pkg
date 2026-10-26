*! _irw_dataset 0.1.0  26oct2026  Item Response Warehouse
*! Resolve a table name to the Redivis dataset that holds it.
*!
*! For core tables this is a lookup, not a guess: irw_meta.metadata carries a
*! "dataset" column naming the exact shard. Probing is the fallback, for a table
*! published since the cached catalogue was built.
program define _irw_dataset, rclass
	version 15.0
	syntax anything(name=tbl id="table name") [, SOurce(string) QUIETly ]

	if "`source'" == "" local source "core"
	local source = lower("`source'")

	local found ""
	local cands ""

	if inlist("`source'", "conj", "conjoint")           local cands "irw_conjoint_2 irw_conjoint"
	else if inlist("`source'", "rank", "rankings")      local cands "irw_rank"
	else if inlist("`source'", "comp", "comps", "competitions") local cands "irw_competitions"
	else if inlist("`source'", "nom", "nominal")        local cands "irw_nominal"
	else if inlist("`source'", "sim", "simsyn")         local cands "irw_simsyn"
	else if inlist("`source'", "meta")                  local cands "irw_meta"
	else if inlist("`source'", "text", "itemtext")      local cands "irw_text_3 irw_text_2 irw_text"
	else if inlist("`source'", "core", "main") {
		preserve
			capture _irw_meta, table(metadata)
			if _rc == 0 {
				local dta `"`r(path)'"'
				capture quietly use table dataset if table == "`tbl'" using `"`dta'"', clear
				if _rc == 0 & _N > 0 local found = dataset[1]
			}
		restore
		if "`found'" == "" {
			_irw_shards
			local cands "`r(shards)'"
		}
	}
	else {
		di as err "unknown source `source'; see {help irw_fetch##source:sources}"
		exit 198
	}

	if "`found'" == "" {
		foreach d of local cands {
			_irw_tableinfo, dataset("`d'") table("`tbl'")
			if r(found) == 1 {
				local found "`d'"
				continue, break
			}
		}
	}

	if "`found'" == "" {
		return local dataset ""
		return scalar found = 0
		if "`quietly'" != "" exit
		di as err `"no table named "`tbl'" in the `source' source"'
		di as err `"{p 4 4 2}Check the spelling against {bf:irw_search, name(`tbl')}.{p_end}"'
		exit 601
	}

	return local dataset "`found'"
	return scalar found = 1
end
