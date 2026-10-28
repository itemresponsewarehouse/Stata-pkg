# irw for Stata

Stata access to the [Item Response Warehouse](https://itemresponsewarehouse.org) (IRW),
a corpus of several thousand item response datasets harmonised into one long format.

This is the third IRW client, alongside the
[R package](https://itemresponsewarehouse.github.io/Rpkg/) and the
[Python package](https://github.com/itemresponsewarehouse/Python-pkg).

**Status: new, and tested on two Stata versions by one outside tester.** The documented
example runs end to end on Stata 16.0 and StataNow 19.5 — fetch, reshape, a converged
2PL — and `tests/unit.do` passes all 29 of its checks on both. Four bugs were found and
fixed in the course of that. **Stata 15 is unconfirmed, and so is every platform other
than macOS**; see [Testing](#testing) and
[issue #2](https://github.com/itemresponsewarehouse/Stata-pkg/issues/2).

## Install

```stata
net install irw, from("https://raw.githubusercontent.com/itemresponsewarehouse/Stata-pkg/main/")
```

No other dependencies, and **no Redivis account**.

Every command declares `version 15.0`, so Stata 15 is the intended floor — but we are
not yet sure it holds. A Stata 15 user hit a Stata 16-only option in `irw_info`, which
is now guarded, and that fix has not been confirmed on 15. What has been run is 16.0 and
19.5. If you are on 15 and something fails, please say so in
[issue #2](https://github.com/itemresponsewarehouse/Stata-pkg/issues/2); we would rather
support 15 than declare 16 the floor.

## Use

```stata
irw_search, variable(rt) nitems(20 60)     // find something
irw_describe 4thgrade_math_sirt            // look before you download
irw_fetch 4thgrade_math_sirt, clear        // long format: id, item, resp
irw_wide, key(mathkey.dta) replace         // one row per respondent
irt 2pl resp*                              // fit
irw_cite 4thgrade_math_sirt                // credit the source
```

`help irw` is the overview; every command has its own help file.

| | |
|---|---|
| `irw_info` | the warehouse at a glance, or one table |
| `irw_search` | find tables by size, variables or tags |
| `irw_metadata` | load the whole catalogue as your dataset |
| `irw_describe` | one table's shape and columns, without downloading it |
| `irw_fetch` | download a table into memory, long format |
| `irw_itemtext` | the item wording published with a table |
| `irw_wide` / `irw_long` | the reshape bridge, both directions |
| `irw_cite` / `irw_tags` | citation, licence, provenance, annotations |
| `irw_cache` | inspect or empty the local cache |

## How it works, and what that costs

Redivis serves every public IRW table as CSV over plain HTTPS, so this package is
Stata's `copy` and `import delimited` and nothing else — no SDK, no OAuth, no login.
Two consequences follow, and both are visible to the user rather than hidden:

**The 100 MB cap.** Redivis refuses an unauthenticated result over 100 MB, which rules
out roughly 3% of the warehouse — the largest PISA, ENEM and five-factor tables.
`irw_fetch` checks the size first and says so. For those, use the R or Python packages,
which authenticate, or pass `token()` with a Redivis API token (that path shells out to
`curl`, because Stata's `copy` cannot set an HTTP header).

**Rows cannot be paged.** The endpoint is whole-table or nothing. `maxrows()` exists,
but row order in the warehouse is arbitrary, so a slice is a preview of a table and
never a sample of it. The help says so wherever the option appears.

Whole-table fetches are cached as `.dta` under your personal ado directory (or
`IRW_CACHE_DIR`), keyed on the Redivis content hash, so a refetch is free and a table
that changed upstream is noticed.

## The reshape is the point

The warehouse is long. Stata's `irt`, `gsem` and friends want wide. `irw_wide` is the
bridge, and it handles the things that make a naive `reshape` fail or mislead:

- item names become variable *labels*, because Stata allows 32 characters and a
  restricted character set and warehouse item names are often neither;
- `key()` writes the full crosswalk, which is the only way back to item names;
- duplicate `id`–`item` pairs stop it rather than being silently collapsed — in the IRW
  they can be real data (repeated administrations, trial-level tables);
- it checks the item count against `c(maxvar)` — the limit that actually binds, which
  is a setting and not the flavour's ceiling — and points at `set maxvar` instead of
  failing part-way through a reshape.

## Testing

Two halves, because Stata cannot be licensed in GitHub Actions.

`tests/test_endpoints.py` pins the endpoint contracts the ado code depends on — public
CSV access, the 100 MB refusal, the shard-naming column in the catalogue, the fact that
paging is ignored. Plain `unittest`, no dependencies, runs anywhere:

```bash
python3 -I tests/test_endpoints.py
```

`tests/unit.do` is the cheap middle, and the first thing to run after any edit: it
exercises the helpers and the reshape against fixtures on disk, with no network and no
account, in seconds. It exists because two review passes over this package each found a
bug that was fatal on every table, and both would have shown up here immediately:

```stata
do tests/unit.do
```

It reads one companion file, `tests/fixtures/backticks.json`, which has to be a file in
the repo: the JSON it holds quotes column names in backticks, and Stata expands those
while parsing a `file write` line, so writing the fixture from the do-file aborts before
any of the package code is reached.

`tests/smoke.do` runs the whole package against the live warehouse and asserts row and
column counts at each step, including the error paths. It is self-contained and
downloads about 2 MB:

```stata
do tests/smoke.do
```

Both need someone with a Stata licence. `unit.do` has been run at the current commit on
16.0 and 19.5; `smoke.do` was last run on both at `2493bac`, before the Stata 15 guard
landed. Neither has been run on Stata 15 or off macOS.

Note that `net install` ships only the `.ado` and `.sthlp` files, not the tests. To run
them, clone the repo or fetch the do-file and its fixture directly.

Please send back the whole log, passes and failures both.

## Citation

Cite the table's own source, which `irw_cite` gives you, and the warehouse:

> Domingue, B. W., et al. (2025). The Item Response Warehouse.
> *Behavior Research Methods*, 57(10), 276.
> <https://doi.org/10.3758/s13428-025-02796-y>

## Licence

MIT.
