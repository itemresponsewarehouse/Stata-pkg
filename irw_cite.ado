*! irw_cite 0.1.0  26oct2026  Item Response Warehouse
*! Citation, licence and source for one IRW table.
program define irw_cite, rclass
	version 15.0
	syntax [anything(name=tbl id="table name")] [, BIBfile(string) SOurce(string) replace Force ]

	if "`source'" == "" local source "core"

	* With no argument, cite whatever irw_fetch last put in memory.
	if `"`tbl'"' == "" {
		local tbl : char _dta[irw_table]
		if "`tbl'" == "" {
			di as err "give a table name, or run irw_fetch first"
			exit 198
		}
		local src : char _dta[irw_source]
		if "`src'" != "" local source "`src'"
	}

	local bibtbl = "biblio"
	if inlist(lower("`source'"), "conj", "conjoint")              local bibtbl "conj_biblio"
	else if inlist(lower("`source'"), "rank", "rankings")         local bibtbl "rank_biblio"
	else if inlist(lower("`source'"), "comp", "comps", "competitions") local bibtbl "comps_biblio"
	else if inlist(lower("`source'"), "nom", "nominal")           local bibtbl "nominal_biblio"
	else if inlist(lower("`source'"), "sim", "simsyn")            local bibtbl "simsyn_biblio"

	local found = 0
	preserve
		_irw_meta, table(`bibtbl') `force'
		quietly use if table == "`tbl'" using `"`r(path)'"', clear
		if _N > 0 {
			local found = 1
			foreach f in reference_x doi__for_paper_ doi__for_data_ url__for_data_ ///
				original_license derived_license custom_license_terms description ///
				source_via {
				capture confirm variable `f'
				if _rc == 0 local `f' = `f'[1]
				if `"``f''"' == "NA" local `f' ""
			}

			if `"`bibfile'"' != "" {
				capture confirm file `"`bibfile'"'
				if _rc == 0 & "`replace'" == "" {
					di as err `"file `bibfile' already exists; specify replace"'
					exit 602
				}
				capture confirm variable bibtex
				if _rc == 0 {
					quietly keep bibtex
					quietly drop if missing(bibtex) | bibtex == "NA"
				}
				if _N > 0 {
					quietly export delimited using `"`bibfile'"', ///
						novarnames noquote delimiter(tab) replace
					local wrotebib = 1
				}
			}
		}
	restore

	if !`found' {
		di as err `"no citation on file for "`tbl'" in `bibtbl'"'
		exit 601
	}

	di as txt ""
	di as txt "{bf:`tbl'}"
	di as txt "{hline 60}"
	if `"`description'"'         != "" di as txt "{p 0 12 2}about" _col(12) as res `"`description'"' "{p_end}"
	if `"`reference_x'"'         != "" di as txt "{p 0 12 2}cite" _col(12) as res `"`reference_x'"' "{p_end}"
	if `"`doi__for_paper_'"'     != "" di as txt "paper DOI"  _col(12) as res `"`doi__for_paper_'"'
	if `"`doi__for_data_'"'      != "" di as txt "data DOI"   _col(12) as res `"`doi__for_data_'"'
	if `"`url__for_data_'"'      != "" di as txt "data URL"   _col(12) as res `"`url__for_data_'"'
	if `"`original_license'"'    != "" di as txt "original"   _col(12) as res `"`original_license'"'
	if `"`derived_license'"'     != "" di as txt "as derived" _col(12) as res `"`derived_license'"'
	if `"`custom_license_terms'"' != "" di as txt "{p 0 12 2}terms" _col(12) as res `"`custom_license_terms'"' "{p_end}"
	if `"`source_via'"'          != "" di as txt "via"        _col(12) as res `"`source_via'"'
	di as txt ""
	di as txt "{p}Cite the warehouse too: Domingue et al. (2025), {it:Behavior Research Methods} 57(10):276," ///
		" doi:10.3758/s13428-025-02796-y.{p_end}"

	if `"`bibfile'"' != "" {
		if "`wrotebib'" == "1" di as txt "BibTeX written to " as res `"`bibfile'"'
		else di as err "no BibTeX entry on file for `tbl'"
	}

	return local reference `"`reference_x'"'
	return local license   `"`derived_license'"'
	return local doi       `"`doi__for_paper_'"'
end
