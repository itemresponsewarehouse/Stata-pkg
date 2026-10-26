{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}

{title:Title}

{phang}
{bf:irw_describe} {hline 2} A table's shape and columns, without downloading it


{title:Syntax}

{p 8 17 2}
{cmd:irw_describe} {it:tablename} [{cmd:,} {opt so:urce(name)}]


{title:Description}

{pstd}
{cmd:irw_describe} reports which Redivis dataset holds the table, which version you
would get, how many responses and columns it has, how large it is, and whether it is
under the 100MB anonymous cap. It then fetches a single row to show the column names.
Your data in memory is untouched.

{pstd}
This is the cheap thing to run before {helpb irw_fetch} on anything you have not seen.


{title:Examples}

{phang2}{cmd:. irw_describe 4thgrade_math_sirt}{p_end}
{phang2}{cmd:. irw_describe pisa2018_read}{p_end}


{title:Stored results}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(numrows)}}responses in the table{p_end}
{synopt:{cmd:r(numbytes)}}size in bytes{p_end}
{synopt:{cmd:r(numvars)}}number of columns{p_end}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(dataset)}}the Redivis dataset holding it{p_end}
{synopt:{cmd:r(qref)}}the version-pinned Redivis reference{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_fetch}, {helpb irw_search}
{p_end}
