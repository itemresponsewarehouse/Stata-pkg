"""Contract tests for the Redivis endpoints the Stata package depends on.

The .ado code cannot be exercised here -- Stata is not installable in CI -- so
this harness pins the half-dozen facts the ado relies on. If one of these
changes, the package breaks silently and tests/smoke.do is the only other
warning, and that one needs a human with a licence.

Everything here runs anonymously, on purpose: that is the whole premise.
"""

import csv
import io
import re
import json
import unittest
import urllib.error
import urllib.request

API = "https://redivis.com/api/v1"
ORG = "datapages"

# A small core table, stable since 2025. 19,920 responses, 6 columns.
SMALL = "4thgrade_math_sirt"
SMALL_SHARD = "item_response_warehouse"
SMALL_ROWS = 19920

# Comfortably over the 100MB anonymous cap.
BIG = "pisa2018_read"
BIG_SHARD = "item_response_warehouse"

TIMEOUT = 120


def get(url):
    """Fetch a URL anonymously. Returns (status, body bytes)."""
    req = urllib.request.Request(url, headers={"User-Agent": "irw-stata-tests"})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
            return r.status, r.read()
    except urllib.error.HTTPError as e:
        return e.code, e.read()


def table_url(shard, table, suffix=""):
    return f"{API}/tables/{ORG}.{shard}.{table}{suffix}"


class TestAnonymousAccess(unittest.TestCase):
    """The premise: no token, no SDK, real data."""

    def test_table_properties_are_public(self):
        status, body = get(table_url(SMALL_SHARD, SMALL))
        self.assertEqual(status, 200)
        info = json.loads(body)
        self.assertEqual(info["numRows"], SMALL_ROWS)
        # _irw_tableinfo parses these four keys out of this JSON by regex.
        for key in ("numRows", "numBytes", "variableCount", "hash"):
            self.assertIn(key, info, f"_irw_tableinfo reads {key} from this response")
        self.assertTrue(info["qualifiedReference"].startswith(f"{ORG}.{SMALL_SHARD}"))

    def test_properties_json_is_small_enough_to_parse_in_stata(self):
        # _irw_json reads in 500-char chunks up to maxchars(40000).
        _, body = get(table_url(SMALL_SHARD, SMALL))
        self.assertLess(len(body), 40000)

    def test_rows_as_csv_is_public(self):
        status, body = get(table_url(SMALL_SHARD, SMALL, "/rows?format=csv"))
        self.assertEqual(status, 200)
        rows = list(csv.DictReader(io.StringIO(body.decode("utf-8"))))
        self.assertEqual(len(rows), SMALL_ROWS)
        for col in ("id", "item", "resp"):
            self.assertIn(col, rows[0], "the IRW long format's three required columns")

    def test_column_projection(self):
        url = table_url(SMALL_SHARD, SMALL, "/rows?format=csv&selectedVariables=id,item,resp&maxResults=3")
        status, body = get(url)
        self.assertEqual(status, 200)
        header = next(csv.reader(io.StringIO(body.decode("utf-8"))))
        # Redivis returns the table's own column order, not the requested one,
        # so columns() in irw_fetch selects columns and never reorders them.
        self.assertEqual(set(header), {"id", "item", "resp"})


class TestLimits(unittest.TestCase):
    """The two boundaries the ado has to explain to the user."""

    def test_over_100mb_is_refused_anonymously(self):
        status, body = get(table_url(BIG_SHARD, BIG, "/rows?format=csv"))
        self.assertEqual(status, 401)
        msg = json.loads(body)["error_description"]
        self.assertIn("100MB", msg)

    def test_projection_does_not_dodge_the_cap(self):
        # Redivis sizes the whole table, not the selection. _irw_get says so.
        url = table_url(BIG_SHARD, BIG, "/rows?format=csv&selectedVariables=id,item,resp")
        status, _ = get(url)
        self.assertEqual(status, 401)

    def test_rows_cannot_be_paged(self):
        # Whole table or nothing: paging parameters are accepted and ignored.
        # If this ever starts working, irw_fetch could stream large tables.
        base = table_url(SMALL_SHARD, SMALL, "/rows?format=csv&maxResults=10")
        _, first = get(base)
        _, offset = get(base + "&startIndex=5000")
        self.assertEqual(first, offset, "startIndex is silently ignored")


class TestResolution(unittest.TestCase):
    """How _irw_dataset finds which shard holds a table."""

    def test_catalogue_names_the_shard(self):
        url = f"{API}/tables/{ORG}.irw_meta.metadata/rows?format=csv"
        status, body = get(url)
        self.assertEqual(status, 200)
        rows = list(csv.DictReader(io.StringIO(body.decode("utf-8"))))
        self.assertGreater(len(rows), 6000)
        self.assertIn("dataset", rows[0], "_irw_dataset reads the shard from this column")
        by_name = {r["table"]: r["dataset"] for r in rows}
        self.assertEqual(by_name[SMALL], SMALL_SHARD)

    def test_missing_table_404s(self):
        status, _ = get(table_url(SMALL_SHARD, "not_a_real_table_zzz"))
        self.assertEqual(status, 404)

    def test_shard_probing_terminates(self):
        # _irw_shards walks upward until a shard 404s. Check that the walk both
        # finds the shards that exist and stops: a shard list that never ends
        # would hang the client.
        found = []
        for k in range(2, 31):
            status, _ = get(f"{API}/datasets/{ORG}.item_response_warehouse_{k}")
            if status != 200:
                break
            found.append(k)
        self.assertGreaterEqual(len(found), 7, "at least shards _2.._8 exist")
        self.assertLess(len(found), 29, "the probe must terminate")
        self.assertEqual(found, list(range(2, 2 + len(found))), "no gaps in the run")

    def test_family_datasets_are_public(self):
        for ds in ("irw_conjoint", "irw_conjoint_2", "irw_rank", "irw_competitions",
                   "irw_nominal", "irw_simsyn", "irw_meta",
                   "irw_text", "irw_text_2", "irw_text_3"):
            with self.subTest(dataset=ds):
                status, _ = get(f"{API}/datasets/{ORG}.{ds}")
                self.assertEqual(status, 200)


class TestMetaTables(unittest.TestCase):
    """The irw_meta tables the commands read, and the columns they read."""

    EXPECTED = {
        "metadata": ["table", "dataset", "n_responses", "n_items", "n_participants",
                     "n_categories", "density", "variables", "longitudinal"],
        "tags": ["table", "construct_name", "sample", "measurement_tool",
                 "item_format", "primary_language_s_"],
        "biblio": ["table", "Reference_x", "DOI__for_paper_", "Original_License",
                   "Derived_License", "Custom_License_Terms", "BibTex", "Source_via"],
        "conj_metadata": ["table"],
        "rank_metadata": ["table"],
        "comps_metadata": ["table"],
        "nominal_metadata": ["table"],
        "simsyn_metadata": ["table"],
        "nominal_tags": ["table"],
    }

    def test_columns_the_ado_reads(self):
        for tbl, cols in self.EXPECTED.items():
            with self.subTest(table=tbl):
                url = f"{API}/tables/{ORG}.irw_meta.{tbl}/rows?format=csv&maxResults=1"
                status, body = get(url)
                self.assertEqual(status, 200)
                header = next(csv.reader(io.StringIO(body.decode("utf-8"))))
                for c in cols:
                    self.assertIn(c, header)

    def test_properties_json_survives_stata_macro_expansion(self):
        """irw_meta.tags broke _irw_json, and this is why.

        Redivis returns each table's own description inside the properties
        JSON, and tags's description quotes column names in backticks --
        `age range`, `measurement tool`. _irw_json builds its buffer in a
        Stata local, and a bare `local buf "`buf'`chunk'"' expands those as
        macro references, which aborted with r(198) and took irw_tags down
        with it. The fix is macval(); this test fails loudly if anyone
        removes it, by asserting the hazard is still present upstream.
        """
        _, body = get(f"{API}/tables/{ORG}.irw_meta.tags")
        text = body.decode("utf-8")
        self.assertIn("`", text, "the hazard macval() guards against")

        # And the patterns _irw_json uses must still find every key it reads
        # in a body that contains them.
        num = r'"%s":\s*(-?[0-9][0-9.eE+-]*)'
        string = r'"%s":\s*"([^"]*)"'
        for key in ("numRows", "numBytes", "variableCount"):
            self.assertIsNotNone(re.search(num % key, text), key)
        for key in ("hash", "qualifiedReference"):
            self.assertIsNotNone(re.search(string % key, text), key)

    def test_patterns_tolerate_pretty_printed_json(self):
        # A 404 body is pretty-printed, with a space after the colon. The
        # patterns demanded the value immediately after it and so returned
        # nothing; \s* is what fixed that.
        status, body = get(table_url(SMALL_SHARD, "not_a_real_table_zzz"))
        self.assertEqual(status, 404)
        text = body.decode("utf-8")
        self.assertRegex(text, r'"status":\s*(-?[0-9][0-9.eE+-]*)')
        self.assertRegex(text, r'"error":\s*"([^"]*)"')

    def test_itemtext_table_naming(self):
        # irw_itemtext appends __items to the table name.
        status, _ = get(table_url("irw_text_3", "phq9_xiong_2025__items"))
        self.assertEqual(status, 200)


if __name__ == "__main__":
    unittest.main(verbosity=2)
