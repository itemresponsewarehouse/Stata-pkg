{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}
{vieweralsosee "irw_wide" "help irw_wide"}{...}

{title:Title}

{phang}
{bf:irw_long} {hline 2} Reshape a wide person-by-item matrix back to IRW long format


{title:Syntax}

{p 8 17 2}
{cmd:irw_long} [{cmd:,} {opt key(filename)} {opt pre:fix(name)} {opt id(varname)} {opt it:em(varname)} {opt r:esp(varname)}]


{title:Description}

{pstd}
The inverse of {helpb irw_wide}: one row per respondent becomes one row per response,
with {cmd:id}, {cmd:item} and {cmd:resp}. Missing cells are dropped, since an
unanswered item is not a response.

{pstd}
Pass the {opt key()} file {cmd:irw_wide} wrote and the original warehouse item names
come back. Without it the items are numbered.

{pstd}
Useful for getting your own wide data into the format the warehouse's tooling and the
IRW data standard expect.


{title:Examples}

{phang2}{cmd:. irw_fetch 4thgrade_math_sirt, clear}{p_end}
{phang2}{cmd:. irw_wide, key(mathkey.dta) replace}{p_end}
{phang2}{cmd:. irw_long, key(mathkey.dta)}{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_wide}, {helpb reshape}
{p_end}
