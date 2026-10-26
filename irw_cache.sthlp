{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}

{title:Title}

{phang}
{bf:irw_cache} {hline 2} Inspect or empty the local IRW cache


{title:Syntax}

{p 8 17 2}
{cmd:irw_cache} [{cmd:,} {opt l:ist} {opt clear}]


{title:Description}

{pstd}
Downloaded tables and catalogues are kept locally so a repeat fetch costs nothing.
{cmd:irw_cache} says where that is, {opt list} shows what is in it, and {opt clear}
empties it.

{pstd}
Tables are keyed on the Redivis content hash, so a table that changed upstream is
downloaded again rather than served stale. Catalogues are refreshed after a week.
A bounded fetch {c -} {helpb irw_fetch} with {opt columns()} or {opt maxrows()} {c -}
is never cached, because it is not the table.

{pstd}
The location defaults to {cmd:irw_cache} inside your personal ado directory. Set the
{cmd:IRW_CACHE_DIR} environment variable to put it somewhere else; point it at the same
directory the R and Python packages use if you want one cache across languages, though
the formats differ ({cmd:.dta} here, Parquet there).


{title:Examples}

{phang2}{cmd:. irw_cache}{p_end}
{phang2}{cmd:. irw_cache, list}{p_end}
{phang2}{cmd:. irw_cache, clear}{p_end}


{title:Stored results}

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: Macros}{p_end}
{synopt:{cmd:r(dir)}}the cache directory{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_fetch}
{p_end}
