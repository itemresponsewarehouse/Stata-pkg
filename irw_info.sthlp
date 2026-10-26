{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}

{title:Title}

{phang}
{bf:irw_info} {hline 2} The warehouse at a glance, or one table


{title:Syntax}

{p 8 17 2}
{cmd:irw_info} [{it:tablename}] [{cmd:,} {opt so:urce(name)} {opt force}]


{title:Description}

{pstd}
With no argument, {cmd:irw_info} reports how many tables and responses the chosen
family holds and points at the commands for going further. With a table name it is
{helpb irw_describe}, {helpb irw_tags} and {helpb irw_cite} run together.

{pstd}
Your data in memory is untouched.


{title:Examples}

{phang2}{cmd:. irw_info}{p_end}
{phang2}{cmd:. irw_info, source(rank)}{p_end}
{phang2}{cmd:. irw_info 4thgrade_math_sirt}{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_describe}, {helpb irw_search}
{p_end}
