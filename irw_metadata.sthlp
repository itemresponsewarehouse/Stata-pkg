{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}
{vieweralsosee "irw_search" "help irw_search"}{...}

{title:Title}

{phang}
{bf:irw_metadata} {hline 2} Load the IRW catalogue as your dataset


{title:Syntax}

{p 8 17 2}
{cmd:irw_metadata} [{cmd:,} {opt clear} {opt so:urce(name)} {opt force}]


{title:Description}

{pstd}
{cmd:irw_metadata} loads the warehouse catalogue into memory {c -} one row per table,
with its size, shape, columns and a few classical psychometric summaries. From there it
is ordinary Stata: {cmd:keep if}, {cmd:sort}, {cmd:browse}, {cmd:histogram}.

{pstd}
Use {helpb irw_search} instead when you only want the names and would rather keep the
data you have.

{pstd}
{opt source(name)} picks the family's catalogue: {cmd:core} (default), {cmd:conj},
{cmd:rank}, {cmd:comp}, {cmd:nom}, {cmd:sim}. They do not all carry the same columns.
{opt force} re-downloads rather than using the cached copy, which is refreshed weekly.


{title:Examples}

{phang2}{cmd:. irw_metadata, clear}{p_end}
{phang2}{cmd:. keep if n_items > 20 & n_participants > 1000}{p_end}
{phang2}{cmd:. list table n_items n_participants in 1/10}{p_end}

{phang2}{cmd:. irw_metadata, clear}{p_end}
{phang2}{cmd:. histogram n_responses if n_responses < 1e6}{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_search}, {helpb irw_describe}, {helpb irw_fetch}
{p_end}
