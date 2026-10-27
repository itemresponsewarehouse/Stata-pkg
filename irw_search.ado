*! irw_search 0.1.0  26oct2026  Item Response Warehouse
*! Find tables by metadata, without disturbing the data in memory.
program define irw_search, rclass
	version 15.0
	syntax [, Name(string) VARiable(string) SOurce(string) ///
		NResponses(numlist min=1 max=2) NParticipants(numlist min=1 max=2) ///
		NItems(numlist min=1 max=2) NCategories(numlist min=1 max=2) ///
		Density(numlist min=1 max=2) LONGitudinal ///
		CONstruct(string) SAmple(string) TOol(string) FORMat(string) LANGuage(string) ///
		Max(integer 50) LIst Force ]

	if "`source'" == "" local source "core"
	local source = lower("`source'")
	_irw_metatable, source(`source')
	local mt "`r(table)'"

	local tables ""
	local n = 0

	preserve
		_irw_meta, table(`mt') `force'
		quietly use `"`r(path)'"', clear

		if `"`name'"' != "" quietly keep if strpos(lower(table), lower(`"`name'"')) > 0
		if `"`variable'"' != "" {
			capture confirm variable variables
			if _rc {
				di as err "the `source' catalogue has no variables column, so variable() cannot be used"
				exit 111
			}
			foreach v of local variable {
				quietly keep if strpos(lower(variables), lower("`v'")) > 0
			}
		}

		foreach f in nresponses nparticipants nitems ncategories density {
			if "``f''" != "" {
				local col = subinstr("`f'", "n", "n_", 1)
				if "`f'" == "density" local col "density"
				capture confirm numeric variable `col'
				if _rc {
					di as err "the `source' catalogue has no numeric `col' column"
					exit 111
				}
				local lo : word 1 of ``f''
				local hi : word 2 of ``f''
				quietly keep if `col' >= `lo' & !missing(`col')
				if "`hi'" != "" quietly keep if `col' <= `hi'
			}
		}

		if "`longitudinal'" != "" {
			capture confirm variable longitudinal
			if _rc == 0 {
				capture confirm string variable longitudinal
				if _rc == 0 quietly keep if inlist(lower(longitudinal), "true", "yes", "1")
				else quietly keep if longitudinal == 1
			}
		}

		* Tag filters live in a different irw_meta table, joined on table name.
		local tagfilters "`construct'`sample'`tool'`format'`language'"
		if `"`tagfilters'"' != "" {
			if !inlist("`source'", "core", "main", "nom", "nominal") {
				di as err "tag filters are only available for the core and nominal sources"
				exit 198
			}
			tempfile shortlist
			quietly keep table
			quietly save `"`shortlist'"'

			local tagtbl = cond(inlist("`source'", "nom", "nominal"), "nominal_tags", "tags")
			_irw_meta, table(`tagtbl') `force'
			quietly use `"`r(path)'"', clear
			quietly merge 1:1 table using `"`shortlist'"', keep(match) nogenerate

			_irw_tagkeep construct_name        `"`construct'"'
			_irw_tagkeep sample                `"`sample'"'
			_irw_tagkeep measurement_tool      `"`tool'"'
			_irw_tagkeep item_format           `"`format'"'
			_irw_tagkeep primary_language_s_   `"`language'"'
		}

		local n = _N
		if `n' > 0 {
			quietly keep table
			sort table
			local shown = min(`n', `max')
			forvalues i = 1/`shown' {
				local tables "`tables' `=table[`i']'"
			}
		}
	restore

	local tables = trim("`tables'")
	di as txt ""
	di as txt as res `n' as txt " table" cond(`n' == 1, "", "s") " match"

	if `n' > 0 {
		local shown : word count `tables'
		di as txt "{hline 60}"
		foreach t of local tables {
			di as res "  `t'"
		}
		if `n' > `shown' {
			di as txt "  ... and " as res `n' - `shown' as txt " more (raise {bf:max()} to see them)"
		}
		di as txt ""
		di as txt "{p}The names are in {bf:r(tables)}; fetch one with {bf:irw_fetch} {it:name}{bf:, clear}.{p_end}"
	}

	return local tables "`tables'"
	return scalar N = `n'
end
