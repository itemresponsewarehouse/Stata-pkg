*! unit.do -- offline checks of the irw Stata package
*!
*! No network, no Redivis, no downloads, no account. Runs in seconds.
*!
*! This exists because the first two review passes over this package each found
*! a bug that was fatal on every table, and both would have been caught here in
*! one second. The endpoint tests in tests/test_endpoints.py check Redivis, not
*! this code; tests/smoke.do checks this code but needs the network. This file
*! is the cheap middle: run it first, and run it after any edit.
*!
*! To run:  do tests/unit.do        (from a checkout)
*!          do unit.do              (from inside tests/)
*!
*! Note on the ck calls: the condition is wrapped in `=(...)' so that Stata
*! evaluates it to 0 or 1 BEFORE ck is called. Passing the bare expression does
*! not work -- args splits on spaces and parentheses do not protect it, which
*! aborts with r(132).

clear all
set more off
version 15.0

capture confirm file "_irw_json.ado"
if _rc == 0 adopath ++ "`c(pwd)'"
capture confirm file "../_irw_json.ado"
if _rc == 0 adopath ++ ".."

program define ck
	args ok label got
	if `ok' {
		di as txt "  ok    " "`label'"
	}
	else {
		di as err "  FAIL  " "`label'" cond("`got'" == "", "", "  (got: `got')")
		global UNIT_FAILS = ${UNIT_FAILS} + 1
	}
end
global UNIT_FAILS = 0

di as txt "{hline 66}"
di as txt "irw unit checks (offline) -- Stata " c(stata_version) " " c(flavor)
di as txt "maxvar = " c(maxvar) ", flavour ceiling " c(max_k_theory)
di as txt "{hline 66}"

*----------------------------------------------------------------------
* 1. _irw_json, against files shaped like Redivis's actual replies.
*    The live properties reply is one compact line with NO trailing
*    newline, so that is the first case.
*----------------------------------------------------------------------
di as txt _n "1. _irw_json"

tempfile j1 j2 j3 j4
tempname fh

file open `fh' using "`j1'", write text replace
file write `fh' `"{"kind":"table","name":"demo","numRows":19920,"numBytes":1111536,"variableCount":6,"hash":"0e417df0","qualifiedReference":"datapages.irw:v1_0.demo"}"'
file close `fh'

_irw_json using "`j1'", key(numRows)
ck `=(`"`r(value)'"' == "19920")' "numRows from an unterminated line" `"`r(value)'"'

_irw_json using "`j1'", key(numBytes)
ck `=(`"`r(value)'"' == "1111536")' "numBytes" `"`r(value)'"'

_irw_json using "`j1'", key(variableCount)
ck `=(`"`r(value)'"' == "6")' "variableCount" `"`r(value)'"'

_irw_json using "`j1'", key(hash) string
ck `=(`"`r(value)'"' == "0e417df0")' "hash, as a string" `"`r(value)'"'

_irw_json using "`j1'", key(qualifiedReference) string
ck `=(`"`r(value)'"' == "datapages.irw:v1_0.demo")' "qualifiedReference" `"`r(value)'"'

_irw_json using "`j1'", key(notAKeyAtAll)
ck `=(r(found) == 0)' "a missing key reports found = 0" "`r(found)'"

* with a trailing newline
file open `fh' using "`j2'", write text replace
file write `fh' `"{"numRows":42,"hash":"zz"}"' _n
file close `fh'
_irw_json using "`j2'", key(numRows)
ck `=(`"`r(value)'"' == "42")' "numRows with a trailing newline" `"`r(value)'"'

* pretty-printed, with a space after the colon, as a 404 body is
file open `fh' using "`j3'", write text replace
file write `fh' "{" _n `"  "status": 404,"' _n `"  "error": "not_found""' _n "}" _n
file close `fh'
_irw_json using "`j3'", key(status)
ck `=(`"`r(value)'"' == "404")' "a numeric key with a space after the colon" `"`r(value)'"'
_irw_json using "`j3'", key(error) string
ck `=(`"`r(value)'"' == "not_found")' "a string key with a space after the colon" `"`r(value)'"'

* Backticks and quotes in the file must not be expanded as macro references.
* irw_meta.tags really does carry a description that quotes column names in
* backticks, and it aborted every command that read that table with r(198).
file open `fh' using "`j4'", write text replace
file write `fh' `"{"numRows":6497,"description":"tags for `age range` and `measurement tool`, see $PATH and 100% of tables","hash":"ab12"}"'
file close `fh'
_irw_json using "`j4'", key(numRows)
ck `=(`"`r(value)'"' == "6497")' "a description full of backticks does not abort the read" `"`r(value)'"'
_irw_json using "`j4'", key(hash) string
ck `=(`"`r(value)'"' == "ab12")' "and a key after it still parses" `"`r(value)'"'

*----------------------------------------------------------------------
* 2. _irw_cachedir
*----------------------------------------------------------------------
di as txt _n "2. _irw_cachedir"

_irw_cachedir, subdir(unittest)
local ud `"`r(dir)'"'
local sep "`r(sep)'"
ck `=(`"`ud'"' != "")' "returns a directory" `"`ud'"'

tempname probe
capture file open `probe' using `"`ud'`sep'write_probe.txt"', write text replace
local openrc = _rc
capture file close `probe'
capture erase `"`ud'`sep'write_probe.txt"'
ck `=(`openrc' == 0)' "the directory exists and is writable" "rc `openrc'"

*----------------------------------------------------------------------
* 3. irw_wide, on synthetic long data with item names Stata cannot use
*    as variable names
*----------------------------------------------------------------------
di as txt _n "3. irw_wide"

tempfile keyf
clear
quietly set obs 4
quietly gen str4 id = "p" + string(_n)
quietly expand 3
bysort id: gen byte k = _n
quietly gen str44 item = "an_item_name_far_longer_than_32_chars_" + string(k)
quietly gen byte resp = mod(_n, 2)
quietly gen byte cov_age = 30 + _n
quietly drop k

irw_wide, key("`keyf'") replace
ck `=(_N == 4)' "one row per respondent" "`=_N'"

* NOT describe + r(k): r(k) counts every variable in the dataset, id included.
capture unab rv : resp*
local nrv : word count `rv'
ck `=(`nrv' == 3)' "one variable per item" "`nrv'"

local l1 : variable label resp1
ck `=(`"`l1'"' != "")' "the item name survives as a variable label" `"`l1'"'
ck `=(strpos(`"`l1'"', "an_item_name_far_longer") == 1)' "and it is the full name" `"`l1'"'

capture confirm variable item
ck `=(_rc != 0)' "item is gone (reshape cannot carry it)" ""

capture confirm variable cov_age
ck `=(_rc != 0)' "the covariate was dropped, with a note" ""

preserve
	quietly use "`keyf'", clear
	ck `=(_N == 3)' "the key has one row per item" "`=_N'"
	capture confirm variable variable
	local a = _rc
	capture confirm variable item
	local b = _rc
	ck `=(`a' == 0 & `b' == 0)' "the key maps variable <-> item" ""
restore

*----------------------------------------------------------------------
* 4. irw_long round trip
*----------------------------------------------------------------------
di as txt _n "4. irw_long"

irw_long, key("`keyf'")
ck `=(_N == 12)' "every response comes back" "`=_N'"
capture confirm variable item
ck `=(_rc == 0)' "item names are restored from the key" ""
quietly levelsof item, local(its)
local nits : word count `its'
ck `=(`nits' == 3)' "three distinct items" "`nits'"

*----------------------------------------------------------------------
* 5. The refusals. These are supposed to fail, with a specific code.
*----------------------------------------------------------------------
di as txt _n "5. refusals"

clear
quietly set obs 4
quietly gen str4 id = "p1"
quietly gen str6 item = "i1"
quietly gen byte resp = 1
capture irw_wide
ck `=(_rc == 459)' "duplicate id-item pairs are refused, not collapsed" "rc `=_rc'"

clear
quietly set obs 3
quietly gen str4 id = "p" + string(_n)
quietly gen byte resp1 = 1
quietly gen byte resp2 = 0
quietly gen byte resp_total = 1
capture irw_long
ck `=(_rc == 198)' "a stray resp* variable stops irw_long" "rc `=_rc'"

clear
quietly set obs 2
quietly gen byte notid = 1
capture irw_wide
ck `=(_rc == 111)' "a missing id column is reported" "rc `=_rc'"

*----------------------------------------------------------------------
* 6. The variable-limit guard. This cannot be exercised against a real
*    warehouse table without one holding more items than maxvar, so it
*    is done here by lowering maxvar instead.
*----------------------------------------------------------------------
di as txt _n "6. the variable-limit guard"

local oldmax = c(maxvar)
clear
capture set maxvar 2048
if _rc {
	di as txt "  skip  maxvar is fixed on this flavour of Stata"
}
else {
	quietly set obs 2100
	quietly gen str4 id = "p1"
	quietly gen str12 item = "i" + string(_n)
	quietly gen byte resp = mod(_n, 2)
	capture irw_wide
	ck `=(_rc == 1000)' "more items than maxvar allows is refused before reshaping" "rc `=_rc'"
	clear
	capture set maxvar `oldmax'
}

*----------------------------------------------------------------------
di as txt _n "{hline 66}"
if ${UNIT_FAILS} == 0 di as result "UNIT CHECKS PASSED"
else di as err "UNIT CHECKS: ${UNIT_FAILS} failure(s)"
di as txt "{hline 66}"
