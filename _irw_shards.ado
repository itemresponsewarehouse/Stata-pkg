*! _irw_shards 0.1.0  26oct2026  Item Response Warehouse
*! The core shard list, discovered rather than hard-coded: Redivis caps a dataset
*! at 1000 tables, so the warehouse grows a new shard every so often and a baked-in
*! list silently stops seeing the newest tables. Probe upwards until a shard 404s.
*! Newest first, which is the resolution order the R and Python clients use.
program define _irw_shards, rclass
	version 15.0
	syntax [, Force MAXShards(integer 30) ]

	if "$IRW_SHARDS" != "" & "`force'" == "" {
		return local shards "$IRW_SHARDS"
		exit
	}

	local list "item_response_warehouse"
	forvalues k = 2/`maxshards' {
		tempfile p
		capture quietly copy ///
			"https://redivis.com/api/v1/datasets/datapages.item_response_warehouse_`k'" ///
			`"`p'"', replace
		if _rc continue, break
		local list "item_response_warehouse_`k' `list'"
	}

	global IRW_SHARDS "`list'"
	return local shards "`list'"
end
