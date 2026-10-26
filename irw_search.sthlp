{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}
{vieweralsosee "irw_metadata" "help irw_metadata"}{...}

{title:Title}

{phang}
{bf:irw_search} {hline 2} Find IRW tables by metadata, without disturbing your data


{title:Syntax}

{p 8 17 2}
{cmd:irw_search} [{cmd:,} {it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt n:ame(string)}}table name contains this{p_end}
{synopt:{opt var:iable(namelist)}}table has all of these columns (e.g. {cmd:rt}){p_end}
{synopt:{opt nr:esponses(# [#])}}responses, at least # (and at most #){p_end}
{synopt:{opt np:articipants(# [#])}}respondents, likewise{p_end}
{synopt:{opt ni:tems(# [#])}}items, likewise{p_end}
{synopt:{opt nc:ategories(# [#])}}response categories, likewise{p_end}
{synopt:{opt d:ensity(# [#])}}density, likewise{p_end}
{synopt:{opt long:itudinal}}longitudinal tables only{p_end}
{synopt:{opt con:struct(string)}}construct name contains this{p_end}
{synopt:{opt sa:mple(string)}}sample description contains this{p_end}
{synopt:{opt to:ol(string)}}measurement tool contains this{p_end}
{synopt:{opt format(string)}}item format contains this{p_end}
{synopt:{opt lang:uage(string)}}primary language contains this{p_end}
{synopt:{opt so:urce(name)}}family; default {cmd:core}{p_end}
{synopt:{opt max(#)}}list at most # names; default 50{p_end}
{synopt:{opt force}}refresh the cached catalogue first{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:irw_search} filters the IRW catalogue and lists the matching table names. It uses
{helpb preserve}, so your own data is untouched.

{pstd}
All string filters are case-insensitive substring matches. Numeric filters take one
number (a floor) or two (a range). Filters combine with AND.

{pstd}
The tag filters {c -} {opt construct()}, {opt sample()}, {opt tool()}, {opt format()},
{opt language()} {c -} come from a separate hand-annotated table and are available for
the {cmd:core} and {cmd:nom} sources only. {bf:Tagging is incomplete across the corpus},
so a tag filter excludes untagged tables; an untagged table is not a non-match.


{title:Examples}

{pstd}Response-time data of a workable size:{p_end}
{phang2}{cmd:. irw_search, variable(rt) nitems(20 60)}{p_end}

{pstd}Big longitudinal tables:{p_end}
{phang2}{cmd:. irw_search, longitudinal nresponses(100000)}{p_end}

{pstd}Anything measuring depression:{p_end}
{phang2}{cmd:. irw_search, construct(depress)}{p_end}

{pstd}Feed the results to a loop:{p_end}
{phang2}{cmd:. irw_search, nitems(10 20) ncategories(2 2) max(5)}{p_end}
{phang2}{cmd:. local hits "`r(tables)'"}{p_end}
{phang2}{cmd:. foreach t of local hits {c -(}}{p_end}
{phang2}{cmd:.         irw_fetch `t', clear}{p_end}
{phang2}{cmd:. {c )-}}{p_end}


{title:Stored results}

{synoptset 16 tabbed}{...}
{p2col 5 16 20 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of matching tables{p_end}
{p2col 5 16 20 2: Macros}{p_end}
{synopt:{cmd:r(tables)}}the matching table names, up to {opt max()}{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_metadata}, {helpb irw_fetch}, {helpb irw_tags}
{p_end}
