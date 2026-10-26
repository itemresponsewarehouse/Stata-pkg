*! _irw_tableinfo 0.1.0  26oct2026  Item Response Warehouse
*! Read a Redivis table's properties without downloading any rows.
*! Anonymous: the table metadata endpoint needs no credentials.
program define _irw_tableinfo, rclass
	version 15.0
	syntax , Dataset(string) Table(string)

	tempfile j
	local url "https://redivis.com/api/v1/tables/datapages.`dataset'.`table'"

	capture quietly copy `"`url'"' `"`j'"', replace
	if _rc {
		return scalar found = 0
		exit
	}

	_irw_json using `"`j'"', key(numRows)
	local nr `"`r(value)'"'
	_irw_json using `"`j'"', key(numBytes)
	local nb `"`r(value)'"'
	_irw_json using `"`j'"', key(variableCount)
	local nv `"`r(value)'"'
	_irw_json using `"`j'"', key(hash) string
	local hash `"`r(value)'"'
	_irw_json using `"`j'"', key(qualifiedReference) string
	local qref `"`r(value)'"'

	* A 404 body parses fine but carries none of these.
	if "`nr'" == "" {
		return scalar found = 0
		exit
	}

	return local url "`url'"
	return local qref "`qref'"
	return local hash "`hash'"
	return scalar numvars  = real("`nv'")
	return scalar numbytes = real("`nb'")
	return scalar numrows  = real("`nr'")
	return scalar found    = 1
end
