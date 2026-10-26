*! _irw_json 0.1.0  26oct2026  Item Response Warehouse
*! Pull one key out of a small JSON file. Private helper, not for direct use.
program define _irw_json, rclass
	version 15.0
	syntax using/, Key(string) [ String MAXChars(integer 40000) ]

	local q = char(34)

	tempname fh
	file open `fh' using `"`using'"', read text
	local buf ""
	local n = 0
	local chunk ""
	file read `fh' %500s chunk
	while r(eof) == 0 & `n' < `maxchars' {
		local buf `"`buf'`chunk'"'
		local n = `n' + 500
		file read `fh' %500s chunk
	}
	local buf `"`buf'`chunk'"'
	file close `fh'

	if "`string'" != "" {
		local pat `"`q'`key'`q':`q'([^`q']*)`q'"'
	}
	else {
		local pat `"`q'`key'`q':(-?[0-9][0-9.eE+-]*)"'
	}

	if ustrregexm(`"`buf'"', `"`pat'"') {
		return local value `"`=ustrregexs(1)'"'
		return scalar found = 1
	}
	else {
		return local value ""
		return scalar found = 0
	}
end
