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
	file read `fh' chunk
	while r(eof) == 0 & `n' < `maxchars' {
		local buf `"`macval(buf)'`macval(chunk)'"'
		local n = length(`"`macval(buf)'"')
		file read `fh' chunk
	}
	local buf `"`macval(buf)'`macval(chunk)'"'
	file close `fh'

	* \s* because JSON may be pretty-printed: "status": 404.
	if "`string'" != "" {
		local pat `"`q'`key'`q':\s*`q'([^`q']*)`q'"'
	}
	else {
		local pat `"`q'`key'`q':\s*(-?[0-9][0-9.eE+-]*)"'
	}

	if ustrregexm(`"`macval(buf)'"', `"`pat'"') {
		return local value `"`=ustrregexs(1)'"'
		return scalar found = 1
	}
	else {
		return local value ""
		return scalar found = 0
	}
end
