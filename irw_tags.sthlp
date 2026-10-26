{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}

{title:Title}

{phang}
{bf:irw_tags} {hline 2} The hand-annotated tags for an IRW table


{title:Syntax}

{p 8 17 2}
{cmd:irw_tags} [{it:tablename}] [{cmd:,} {opt so:urce(name)} {opt force}]


{title:Description}

{pstd}
Shows what the warehouse's annotators recorded about a table: the construct and its
type, the sample, the measurement tool, the item format, the age range, the primary
language. With no table name it uses the one {helpb irw_fetch} last loaded.

{pstd}
{bf:Tagging is incomplete across the corpus.} A missing tag means nobody has got to it,
not that the table lacks the property. Do not read an absence as a denial, and do not
build a sampling frame out of tag filters without saying so.


{title:Examples}

{phang2}{cmd:. irw_fetch 4thgrade_math_sirt, clear}{p_end}
{phang2}{cmd:. irw_tags}{p_end}

{phang2}{cmd:. irw_tags burns_2018_bsi18_father}{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_search}, {helpb irw_cite}
{p_end}
