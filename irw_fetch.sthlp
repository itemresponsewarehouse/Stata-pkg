{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}
{vieweralsosee "irw_wide" "help irw_wide"}{...}
{viewerjumpto "Syntax" "irw_fetch##syntax"}{...}
{viewerjumpto "Description" "irw_fetch##description"}{...}
{viewerjumpto "Options" "irw_fetch##options"}{...}
{viewerjumpto "Remarks" "irw_fetch##remarks"}{...}
{viewerjumpto "Examples" "irw_fetch##examples"}{...}

{title:Title}

{phang}
{bf:irw_fetch} {hline 2} Download one IRW table into memory


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:irw_fetch} {it:tablename} [{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt clear}}replace the data in memory; required if any is loaded{p_end}
{synopt:{opt col:umns(varlist)}}fetch only these columns (done server side){p_end}
{synopt:{opt max:rows(#)}}fetch at most # rows {c -} a preview, not a sample{p_end}
{synopt:{opt so:urce(name)}}which family: {cmd:core} (default), {cmd:conj}, {cmd:rank}, {cmd:comp}, {cmd:nom}, {cmd:sim}{p_end}
{synopt:{opt tok:en(string)}}Redivis API token, for tables over the 100MB cap{p_end}
{synopt:{opt noca:che}}do not read or write the local cache{p_end}
{synopt:{opt force}}ignore the cache and download again{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:irw_fetch} downloads one table from the Item Response Warehouse and leaves it in
memory in the warehouse's long format: one row per response, with {cmd:id},
{cmd:item} and {cmd:resp}, plus the table's covariates.

{pstd}
It resolves which Redivis dataset holds the table (the warehouse is sharded, because
Redivis caps a dataset at 1000 tables), checks the table's size before downloading
anything, fetches the CSV, repairs the types and labels the standard columns.


{marker options}{...}
{title:Options}

{phang}
{opt clear} replaces the data in memory. Like most Stata commands that load data,
{cmd:irw_fetch} refuses to run without it when anything is loaded.

{phang}
{opt columns(varlist)} restricts the download to these columns. The restriction is
applied by Redivis, so it genuinely reduces what crosses the network. It does {it:not}
help with the 100MB cap, which Redivis computes on the whole table.

{phang}
Redivis returns the table's own column order regardless of the order you ask for, so
{opt columns()} selects columns but does not reorder them.

{phang}
{opt maxrows(#)} caps the number of rows. Read {help irw_fetch##remarks:Remarks} before
using it.

{phang}
{opt source(name)} picks the family. {cmd:core} is the main corpus of item responses.
The others are {cmd:conj} (conjoint), {cmd:rank} (rankings), {cmd:comp} (competitions),
{cmd:nom} (nominal) and {cmd:sim} (simulated/synthetic).

{phang}
{opt token(string)} supplies a Redivis API token so tables over the 100MB anonymous cap
can be read. This path shells out to {cmd:curl}, because Stata's {helpb copy} cannot set
an HTTP header; if {cmd:curl} is not on your PATH it will not work.

{phang}
{opt nocache} skips the local cache entirely. {opt force} uses the cache directory but
downloads a fresh copy first.


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:maxrows() is a preview, not a sample.} Row order in the warehouse is arbitrary, and
Redivis's endpoint cannot be paged. A 200,000-row slice of a large table in one test
gave 146,840 respondents across 32 items {c -} about 1.4 responses per person. That is
fine for looking at the columns and useless for fitting anything. Use it to inspect,
never to estimate.

{pstd}
{bf:The 100MB cap.} Redivis refuses an unauthenticated result over 100MB, which rules
out roughly 3% of the warehouse. {cmd:irw_fetch} checks first and tells you the size
rather than letting the download fail. Your options are the R or Python {cmd:irw}
packages, which authenticate, or {opt token()}.

{pstd}
{bf:Caching.} A whole-table fetch is cached as a {cmd:.dta} keyed on the table's Redivis
content hash, so refetching is free and a table that changed upstream is downloaded
again. A bounded fetch ({opt columns()} or {opt maxrows()}) is never cached, since it is
not the table. See {helpb irw_cache}.

{pstd}
{bf:What the cleanup does.} Redivis's unnamed index column is dropped. {cmd:resp}
arrives as a string in tables that carry a literal {cmd:NA}; those become missing and
the count is reported. {cmd:cov_}, {cmd:itemcov_} and {cmd:trial_} columns are labelled
by their role.

{pstd}
{bf:Duplicate id-item rows can be real.} Repeated administrations and trial-level data
both produce them legitimately. {cmd:irw_fetch} does not deduplicate.


{marker examples}{...}
{title:Examples}

{pstd}A small table, end to end:{p_end}
{phang2}{cmd:. irw_fetch 4thgrade_math_sirt, clear}{p_end}
{phang2}{cmd:. irw_wide, key(mathkey.dta) replace}{p_end}
{phang2}{cmd:. irt 2pl resp*}{p_end}

{pstd}Only the three columns an IRT model needs:{p_end}
{phang2}{cmd:. irw_fetch previc_bohn2023, clear columns(id item resp)}{p_end}

{pstd}A look at the columns of something large, without committing to the download:{p_end}
{phang2}{cmd:. irw_describe pisa2018_read}{p_end}


{title:Stored results}

{pstd}{cmd:irw_fetch} leaves provenance in the dataset's characteristics:
{cmd:_dta[irw_table]}, {cmd:_dta[irw_dataset]}, {cmd:_dta[irw_hash]},
{cmd:_dta[irw_qref]} (the version-pinned Redivis reference), {cmd:_dta[irw_url]} and
{cmd:_dta[irw_fetched]}. {helpb irw_cite} and {helpb irw_tags} read them, so they work
with no argument after a fetch.


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_search}, {helpb irw_describe}, {helpb irw_wide},
{helpb irw_cite}, {helpb irw_cache}
{p_end}
