*! _irw_meta 0.1.0  26oct2026  Item Response Warehouse
*! Make sure a cached copy of one irw_meta table exists and is fresh, and return
*! its path. Downloads only when the cache is missing or older than maxage() days.
*!
*! NOTE: when it does download, it replaces the data in memory. Callers that must
*! not disturb the user's data wrap the call in preserve/restore.
program define _irw_meta, rclass
	version 15.0
	syntax , Table(string) [ Force MAXAGE(integer 7) ]

	_irw_cachedir, subdir(meta)
	local dir `"`r(dir)'"'
	local sep "`r(sep)'"
	local dta   `"`dir'`sep'`table'.dta"'
	local stamp `"`dir'`sep'`table'.stamp"'

	local stale = 1
	capture confirm file `"`dta'"'
	if _rc == 0 & "`force'" == "" {
		capture confirm file `"`stamp'"'
		if _rc == 0 {
			tempname sh
			local fetched ""
			capture {
				file open `sh' using `"`stamp'"', read text
				file read `sh' fetched
				file close `sh'
			}
			capture file close `sh'
			if "`fetched'" != "" {
				local age = date("`c(current_date)'", "DMY") - date("`fetched'", "DMY")
				if `age' < . & `age' >= 0 & `age' <= `maxage' local stale = 0
			}
		}
	}

	if `stale' {
		tempfile csv
		capture _irw_get, dataset(irw_meta) table(`table') file(`"`csv'"')
		if _rc {
			capture confirm file `"`dta'"'
			if _rc == 0 {
				di as txt "note: could not refresh the `table' catalogue; using the" ///
					" cached copy from `fetched'"
				return scalar stale = 0
				return local path `"`dta'"'
				exit
			}
			di as err "could not download the `table' catalogue, and no cached copy exists"
			exit 601
		}
		* biblio carries BibTeX with embedded newlines inside quoted fields.
		quietly import delimited using `"`csv'"', clear varnames(1) ///
			bindquote(strict) maxquotedrows(200000) encoding(utf-8)
		char _dta[irw_table] "`table'"
		char _dta[irw_fetched] "`c(current_date)'"
		quietly save `"`dta'"', replace

		tempname wh
		file open `wh' using `"`stamp'"', write text replace
		file write `wh' "`c(current_date)'" _n
		file close `wh'
	}

	return scalar stale = `stale'
	return local path `"`dta'"'
end
