*! irw_cache 0.1.0  26oct2026  Item Response Warehouse
*! Inspect or empty the local cache of downloaded tables and catalogues.
program define irw_cache, rclass
	version 15.0
	syntax [, CLEAR List ]

	_irw_cachedir, subdir(meta)
	_irw_cachedir, subdir(tables)
	_irw_cachedir
	local dir `"`r(dir)'"'
	local sep "`r(sep)'"

	if "`clear'" != "" {
		local n = 0
		foreach sub in meta tables {
			foreach pat in "*.dta" "*.stamp" {
				local these ""
				capture local these : dir `"`dir'`sep'`sub'"' files `"`pat'"'
				foreach f of local these {
					capture erase `"`dir'`sep'`sub'`sep'`f'"'
					if _rc == 0 local n = `n' + 1
				}
			}
		}
		global IRW_SHARDS ""
		di as txt as res `n' as txt " file" cond(`n' == 1, "", "s") " erased from " as res `"`dir'"'
		return local dir `"`dir'"'
		exit
	}

	di as txt ""
	di as txt "IRW cache" _col(14) as res `"`dir'"'
	di as txt "{p 0 14 2}set" _col(14) as txt "with the {bf:IRW_CACHE_DIR} environment variable{p_end}"

	if "`list'" != "" {
		di as txt ""
		capture noisily dir `"`dir'`sep'tables`sep'*.dta"'
		di as txt ""
		capture noisily dir `"`dir'`sep'meta`sep'*.dta"'
	}
	else {
		di as txt "{p 0 14 2}see" _col(14) as txt "what is in it with {bf:irw_cache, list};" ///
			" empty it with {bf:irw_cache, clear}{p_end}"
	}

	return local dir `"`dir'"'
end
