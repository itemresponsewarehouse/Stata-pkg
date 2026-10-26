{smcl}
{* *! version 0.1.0  26oct2026}{...}
{viewerjumpto "Description" "irw##description"}{...}
{viewerjumpto "Commands" "irw##commands"}{...}
{viewerjumpto "Getting started" "irw##started"}{...}
{viewerjumpto "What needs no account" "irw##anon"}{...}
{viewerjumpto "Citation" "irw##citation"}{...}

{title:Title}

{phang}
{bf:irw} {hline 2} Stata access to the Item Response Warehouse


{marker description}{...}
{title:Description}

{pstd}
The {help http://itemresponsewarehouse.org:Item Response Warehouse} (IRW) is a corpus
of several thousand item response datasets, harmonised into one long format: a row per
response, with {cmd:id}, {cmd:item} and {cmd:resp}, plus whatever covariates the source
carried. It is hosted on Redivis and maintained at Stanford.

{pstd}
This package reads it from Stata. It needs no Redivis account and no SDK: the warehouse
is served as CSV over plain HTTPS, and {helpb copy} and {helpb import delimited} are all
it takes. The one limit is Redivis's refusal to serve an unauthenticated result over
100MB; see {help irw##anon:what needs no account} below.


{marker commands}{...}
{title:Commands}

{synoptset 18 tabbed}{...}
{synopthdr:finding a table}
{synoptline}
{synopt:{helpb irw_info}}the warehouse at a glance, or one table{p_end}
{synopt:{helpb irw_search}}find tables by size, variables or tags{p_end}
{synopt:{helpb irw_metadata}}load the whole catalogue as your dataset{p_end}
{synopt:{helpb irw_describe}}one table's shape and columns, without downloading it{p_end}
{synoptline}

{synopthdr:reading data}
{synoptline}
{synopt:{helpb irw_fetch}}download a table into memory, long format{p_end}
{synopt:{helpb irw_itemtext}}the item wording published with a table{p_end}
{synopt:{helpb irw_cache}}inspect or empty the local cache{p_end}
{synoptline}

{synopthdr:getting it into shape}
{synoptline}
{synopt:{helpb irw_wide}}long {c -}> one row per respondent, ready for {helpb irt}{p_end}
{synopt:{helpb irw_long}}wide {c -}> back to IRW long format{p_end}
{synoptline}

{synopthdr:credit}
{synoptline}
{synopt:{helpb irw_cite}}citation, licence and provenance for a table{p_end}
{synopt:{helpb irw_tags}}the hand-annotated tags for a table{p_end}
{synoptline}


{marker started}{...}
{title:Getting started}

{pstd}A whole session, start to finish:{p_end}

{phang2}{cmd:. irw_search, variable(rt) nitems(20 60)}{p_end}
{phang2}{cmd:. irw_describe 4thgrade_math_sirt}{p_end}
{phang2}{cmd:. irw_fetch 4thgrade_math_sirt, clear}{p_end}
{phang2}{cmd:. irw_wide, key(mathkey.dta) replace}{p_end}
{phang2}{cmd:. irt 2pl resp*}{p_end}
{phang2}{cmd:. irw_cite 4thgrade_math_sirt}{p_end}

{pstd}
{cmd:irw_wide} is the step that matters. The warehouse is long and every Stata IRT
command wants wide, so this is the bridge. It keeps item names as variable labels,
because Stata's 32-character variable names cannot hold them, and writes the full
crosswalk to the file you name in {opt key()}.


{marker anon}{...}
{title:What needs no account}

{pstd}
Everything here reads Redivis's public {cmd:rows} endpoint, which answers without
credentials. Two consequences are worth knowing before you plan around them.

{pstd}
{bf:The 100MB cap.} Redivis will not serve an unauthenticated result larger than 100MB.
That is roughly 3% of the warehouse {c -} the biggest PISA, ENEM and five-factor tables.
{cmd:irw_fetch} checks the size first and says so rather than failing obscurely. For
those tables, use the R or Python {cmd:irw} packages, which authenticate, or pass
{opt token()} with a Redivis API token (that route shells out to {cmd:curl}).

{pstd}
{bf:Rows cannot be paged.} The endpoint is whole-table or nothing. {opt maxrows()}
exists, but Redivis returns rows in arbitrary order, so a slice is a preview of the
table and never a sample of it {c -} it will not hold whole respondents, and fitting a
model to one is a mistake.

{pstd}
Downloaded tables are cached locally, keyed on the Redivis content hash, so a repeat
fetch costs nothing and a changed table is noticed. See {helpb irw_cache}.


{marker citation}{...}
{title:Citation}

{pstd}
Cite both the table's own source, which {helpb irw_cite} gives you, and the warehouse:

{pstd}
Domingue, B. W., et al. (2025). The Item Response Warehouse.
{it:Behavior Research Methods}, 57(10), 276. {browse "https://doi.org/10.3758/s13428-025-02796-y"}


{title:Also see}

{psee}
Online: {browse "https://itemresponsewarehouse.org"},
{browse "https://itemresponsewarehouse.github.io/Rpkg/":R package},
{browse "https://github.com/itemresponsewarehouse/Python-pkg":Python package}
{p_end}
{psee}
Help: {helpb irt}, {helpb gsem}, {helpb reshape}
{p_end}
