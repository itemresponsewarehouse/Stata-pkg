*! _irw_cachedir 0.1.0  26oct2026  Item Response Warehouse
*! Resolve (and create) the package cache directory. Private helper.
program define _irw_cachedir, rclass
	version 15.0
	syntax [, SUBdir(string) ]

	local sep "`c(dirsep)'"

	local d : environment IRW_CACHE_DIR
	if `"`d'"' == "" local d `"`c(sysdir_personal)'irw_cache"'
	if substr(`"`d'"', -1, 1) == "`sep'" {
		local d = substr(`"`d'"', 1, length(`"`d'"') - 1)
	}
	capture mkdir `"`d'"'
	capture local probe : dir `"`d'"' files "*"
	if _rc {
		* A nested IRW_CACHE_DIR needs its parents made one at a time.
		local built ""
		local rest `"`d'"'
		if substr(`"`d'"', 1, 1) == "`sep'" local built "`sep'"
		while `"`rest'"' != "" {
			gettoken piece rest : rest, parse("`sep'")
			if `"`piece'"' == "`sep'" continue
			local built `"`built'`piece'"'
			capture mkdir `"`built'"'
			local built `"`built'`sep'"'
		}
	}

	if `"`subdir'"' != "" {
		local d `"`d'`sep'`subdir'"'
		capture mkdir `"`d'"'
	}

	return local dir `"`d'"'
	return local sep "`sep'"
end
