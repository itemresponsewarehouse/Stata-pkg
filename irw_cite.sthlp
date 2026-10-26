{smcl}
{* *! version 0.1.0  26oct2026}{...}
{vieweralsosee "irw" "help irw"}{...}

{title:Title}

{phang}
{bf:irw_cite} {hline 2} Citation, licence and provenance for an IRW table


{title:Syntax}

{p 8 17 2}
{cmd:irw_cite} [{it:tablename}] [{cmd:,} {opt bibf:ile(filename)} {opt replace} {opt so:urce(name)} {opt force}]


{title:Description}

{pstd}
{cmd:irw_cite} reports what the warehouse knows about where a table came from: the
reference, the DOIs for the paper and for the data, the original licence, the licence
the derived table carries, any custom terms, and the aggregator it came via.

{pstd}
With no table name it uses the one {helpb irw_fetch} last loaded, which it reads from
the dataset's characteristics.

{pstd}
{opt bibfile(filename)} writes the BibTeX entry to a file; {opt replace} overwrites an
existing one.

{pstd}
{bf:The original and derived licences can differ}, and the derived one is what governs
your use of the IRW table. Where there are custom terms, read them.


{title:Examples}

{phang2}{cmd:. irw_fetch 4thgrade_math_sirt, clear}{p_end}
{phang2}{cmd:. irw_cite}{p_end}

{phang2}{cmd:. irw_cite 5personalityfactors, bibfile(refs.bib) replace}{p_end}


{title:Stored results}

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2: Macros}{p_end}
{synopt:{cmd:r(reference)}}the formatted reference{p_end}
{synopt:{cmd:r(license)}}the licence the derived table carries{p_end}
{synopt:{cmd:r(doi)}}DOI for the paper{p_end}


{title:Also see}

{psee}
Help: {helpb irw}, {helpb irw_tags}, {helpb irw_itemtext}
{p_end}
