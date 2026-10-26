*! _irw_get 0.1.0  26oct2026  Item Response Warehouse
*! Download one Redivis table as CSV to a local file.
*!
*! Anonymous by default. Redivis refuses an unauthenticated result over 100MB, so
*! the size is checked first and refused here with a message the user can act on,
*! rather than left to come back as an opaque copy() failure.
program define _irw_get, rclass
	version 15.0
	syntax , Dataset(string) Table(string) File(string) ///
		[ Vars(string) MAXResults(integer 0) TOKen(string) NOSIZEcheck KNOWNBytes(real -1) ]

	local cap = 100 * 1024 * 1024

	if "`nosizecheck'" == "" {
		if `knownbytes' >= 0 & !missing(`knownbytes') {
			local nbytes = `knownbytes'
		}
		else {
			_irw_tableinfo, dataset("`dataset'") table("`table'")
			if r(found) == 0 {
				di as err `"table "`table'" not found in datapages.`dataset'"'
				exit 601
			}
			local nbytes = r(numbytes)
			local nrows  = r(numrows)
			local hash   "`r(hash)'"
		}

		if `nbytes' > `cap' & !missing(`nbytes') & "`token'" == "" & `maxresults' == 0 {
			di as err "{p}`table' is " %9.0fc `nbytes' " bytes. Redivis will not serve a result" ///
				" larger than 100MB to an unauthenticated request, which is how this package reads" ///
				" the warehouse.{p_end}"
			di as err "{p 4 4 2}Options: use the R or Python irw package, which authenticate" ///
				" and have no such cap; or pass token() with a Redivis API token (needs curl);" ///
				" or restrict rows with maxrows(), remembering that a slice comes back in" ///
				" arbitrary order and is a preview, never a sample.{p_end}"
			exit 672
		}
	}

	local url "https://redivis.com/api/v1/tables/datapages.`dataset'.`table'/rows?format=csv"
	if `"`vars'"' != "" {
		local vars = trim(itrim(`"`vars'"'))
		local vars : subinstr local vars " " ",", all
		local url "`url'&selectedVariables=`vars'"
	}
	if `maxresults' > 0 local url "`url'&maxResults=`maxresults'"

	if `"`token'"' != "" {
		* copy cannot set an Authorization header, so curl is the only way in.
		local q = char(34)
		capture erase `"`file'"'
		shell curl -sS -f -H `q'Authorization: Bearer `token'`q' `q'`url'`q' -o `q'`file'`q'

		* shell does not reliably return the child's exit status, and curl
		* creates the output file before it makes the request, so judge the
		* result by what landed rather than by _rc.
		local head ""
		capture {
			tempname ch
			file open `ch' using `"`file'"', read text
			file read `ch' head
			file close `ch'
		}
		capture file close `ch'
		if `"`head'"' == "" {
			di as err "the authenticated download of `table' produced nothing"
			di as err "{p 4 4 2}Check that {bf:curl} is installed and that the token is a" ///
				" valid Redivis API token with read access.{p_end}"
			exit 672
		}
		if strpos(`"`head'"', `""error""') > 0 {
			di as err "Redivis refused the authenticated request for `table':"
			di as err `"{p 4 4 2}`head'{p_end}"'
			exit 672
		}
	}
	else {
		capture quietly copy `"`url'"' `"`file'"', replace
		if _rc {
			di as err "could not download `table' from datapages.`dataset'"
			di as err `"{p 4 4 2}URL: `url'{p_end}"'
			exit _rc
		}
	}

	capture confirm file `"`file'"'
	if _rc {
		di as err "download of `table' produced no file"
		exit 601
	}

	return local url "`url'"
	return local hash "`hash'"
	return scalar numrows = cond("`nrows'" == "", ., real("`nrows'"))
end
