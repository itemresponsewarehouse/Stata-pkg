{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}
{vieweralsosee "irw_long" "help irw_long"}{...}
{viewerjumpto "Syntax" "irw_wide##syntax"}{...}
{viewerjumpto "Description" "irw_wide##description"}{...}
{viewerjumpto "Options" "irw_wide##options"}{...}
{viewerjumpto "Remarks" "irw_wide##remarks"}{...}
{viewerjumpto "Examples" "irw_wide##examples"}{...}

{title:Title}

{phang}
{bf:irw_wide} {hline 2} Reshape an IRW table to one row per respondent


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:irw_wide} [{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt key(filename)}}write the item crosswalk here{p_end}
{synopt:{opt replace}}overwrite the {opt key()} file{p_end}
{synopt:{opt pre:fix(name)}}stub for the new variables; default {cmd:resp}{p_end}
{synopt:{opt id(varname)}}respondent column; default {cmd:id}{p_end}
{synopt:{opt it:em(varname)}}item column; default {cmd:item}{p_end}
{synopt:{opt r:esp(varname)}}response column; default {cmd:resp}{p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
The warehouse is long: one row per response. Every Stata IRT command {c -} {helpb irt},
{helpb gsem} {c -} wants wide: one row per respondent, one variable per item.
{cmd:irw_wide} is that bridge.

{pstd}
It numbers the items, reshapes, and puts each item's warehouse name in the
corresponding variable's label. With {opt key()} it also writes the full crosswalk
to a dataset, which is what you need to get back to item names later and what
{helpb irw_long} reads.


{marker options}{...}
{title:Options}

{phang}
{opt key(filename)} saves a three-column dataset {c -} {cmd:variable},
{cmd:_itemnum}, {cmd:item} {c -} mapping the wide variables back to warehouse item
names. Strongly recommended: without it the wide data is readable only through the
variable labels.

{phang}
{opt prefix(name)} names the new variables {it:name}{cmd:1}, {it:name}{cmd:2}, and so
on. Default {cmd:resp}, so an IRT call reads {cmd:irt 2pl resp*}.

{phang}
{opt id()}, {opt item()} and {opt resp()} name the three columns if they are not
called {cmd:id}, {cmd:item} and {cmd:resp}.


{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:Covariates do not survive.} A person-by-item covariate is not constant within
respondent, which is precisely what {helpb reshape} refuses. {cmd:irw_wide} drops
everything but the three columns and tells you what went. If you need covariates
alongside the wide data, collapse them to the respondent level yourself and
{helpb merge} them back.

{pstd}
{bf:Duplicate id-item pairs stop it.} They can be real data in the warehouse {c -}
repeated administrations, trial-level tables {c -} so {cmd:irw_wide} will not guess
which to keep. It reports the count and leaves the choice to you.

{pstd}
{bf:Item names cannot be variable names.} Stata allows 32 characters and a restricted
character set; warehouse item names are often neither. Hence the numbering, the labels
and {opt key()}.

{pstd}
{bf:There is a ceiling.} The binding limit is {cmd:c(maxvar)}, which is a setting, not
the flavour's ceiling {c -} Stata/SE starts at 5,000 whatever {cmd:c(max_k_theory)}
says. Plenty of IRW tables have more items than that. {cmd:irw_wide} checks against
{cmd:c(maxvar)} first, reports both numbers, and points at {helpb set maxvar} rather
than failing part-way through a reshape.

{pstd}
{bf:Speed.} {helpb reshape} is slow on large tables. If you have {cmd:gtools}
installed, {cmd:greshape} does the same job much faster; this package does not require
it.


{marker examples}{...}
{title:Examples}

{phang2}{cmd:. irw_fetch 4thgrade_math_sirt, clear}{p_end}
{phang2}{cmd:. irw_wide, key(mathkey.dta) replace}{p_end}
{phang2}{cmd:. irt 2pl resp*}{p_end}
{phang2}{cmd:. estat report, sort(b)}{p_end}

{pstd}Reading the item behind a parameter:{p_end}
{phang2}{cmd:. use mathkey, clear}{p_end}
{phang2}{cmd:. list item if variable == "resp7"}{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_fetch}, {helpb irw_long}, {helpb irt}, {helpb reshape}
{p_end}
