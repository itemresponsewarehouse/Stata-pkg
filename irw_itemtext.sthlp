{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}

{title:Title}

{phang}
{bf:irw_itemtext} {hline 2} The item wording published with an IRW table


{title:Syntax}

{p 8 17 2}
{cmd:irw_itemtext} {it:tablename} [{cmd:,} {opt clear} {opt force}]


{title:Description}

{pstd}
Loads the item text that has been published for a table {c -} the wording of the items,
and often the response options {c -} into memory. Item text is a separate and
slower-moving collection than the response data, and most tables do not have it yet.

{pstd}
{bf:Item text carries no licence to reuse the instrument.} It is published so you can
see what was asked. Permission to administer or reproduce an instrument is the
originator's to give, and is not implied by the table's data licence. Check
{helpb irw_cite} and the warehouse's item-text licensing page before reproducing
anything.


{title:Examples}

{phang2}{cmd:. irw_itemtext phq9_xiong_2025, clear}{p_end}
{phang2}{cmd:. list in 1/5}{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_cite}
{p_end}
{psee}
Online: {browse "https://itemresponsewarehouse.org/itemtext.html"}
{p_end}
