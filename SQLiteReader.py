"""N1 Health Data Ops Challenge 2025 orchestration and result formatting."""

from __future__ import annotations

import argparse
import sqlite3
import sys
from pathlib import Path

from SQLiteQueryRunner import SQLiteQueryRunner


ANALYSIS_YEAR = 2025
FOOD_ACCESS_THRESHOLD = 2
PROJECT_DIRECTORY = Path(__file__).resolve().parent
DEFAULT_DATABASE_PATH = PROJECT_DIRECTORY / "n1_data_ops_challenge.db"
DEFAULT_QUERY_DIRECTORY = PROJECT_DIRECTORY / "queries"


def print_results(results: dict[str, list[sqlite3.Row]]) -> None:
    """Print result sets returned by SQLiteQueryRunner."""
    counts = results["02_member_counts"][0]

    print("\nN1 Data Ops Challenge - Part 1 Results")
    print("=" * 45)
    print(f"std_member_info rows: {counts['row_count']:,}")
    print(f"Distinct member IDs:  {counts['distinct_member_count']:,}")

    april_count = results["03_april_eligible_members"][0]["member_count"]
    print(
        f"\n1. Distinct members eligible in April {ANALYSIS_YEAR}: "
        f"{april_count:,}"
    )

    duplicate_count = results["04_duplicate_eligible_members"][0]["member_count"]
    print(f"2. Members included more than once: {duplicate_count:,}")

    print("3. Member breakdown by payer:")
    for row in results["05_members_by_payer"]:
        print(f"   {row['payer'] or 'Unknown'}: {row['member_count']:,}")

    food_count = results["06_low_food_access_members"][0]["member_count"]
    print(
        "4. Members in ZIP codes with Food access score "
        f"< {FOOD_ACCESS_THRESHOLD}: {food_count:,}"
    )

    isolation = results["07_average_social_isolation"][0]
    average = isolation["average_score"]
    if average is None:
        print("5. Average Social isolation score: unavailable")
    else:
        print(f"5. Average Social isolation score: {average:.4f}")

    unmatched = results["08_members_without_zip_score"][0]["member_count"]
    print(f"   Members without a matching ZIP score: {unmatched:,}")

    highest_rows = results["09_highest_composite_score_zip"]
    if not highest_rows:
        print("6. Highest Algorex SDOH composite score: unavailable")
        return

    highest_score = highest_rows[0]["composite_score"]
    highest_zips = [row["zip_code"] for row in highest_rows]
    members = results["10_members_in_highest_score_zip"]
    print(
        "6. Highest Algorex SDOH composite score: "
        f"{highest_score:.2f} (ZIP(s): {', '.join(highest_zips)})"
    )

    if members:
        for member in members:
            print(
                f"   {member['member_id']} - "
                f"{member['member_first_name']} "
                f"{member['member_last_name']} "
                f"({member['zip_code']})"
            )
    else:
        print("   No eligible members live in the highest-scoring ZIP code(s).")


def parse_args() -> argparse.Namespace:
    """Parse the database path and SQL directory."""
    parser = argparse.ArgumentParser(
        description="Run the ordered SQL workflow and print its results."
    )
    parser.add_argument(
        "db_path",
        nargs="?",
        type=Path,
        default=DEFAULT_DATABASE_PATH,
        help="Path to the SQLite database.",
    )
    parser.add_argument(
        "query_directory",
        nargs="?",
        type=Path,
        default=DEFAULT_QUERY_DIRECTORY,
        help="Directory containing ordered SQL files.",
    )
    return parser.parse_args()


def main() -> int:
    """Run all SQL files and display their returned results."""
    args = parse_args()
    parameters = {
        "year_start": f"{ANALYSIS_YEAR}-01-01",
        "year_end": f"{ANALYSIS_YEAR}-12-31",
        "april_start": f"{ANALYSIS_YEAR}-04-01",
        "april_end": f"{ANALYSIS_YEAR}-04-30",
        "food_access_threshold": FOOD_ACCESS_THRESHOLD,
    }

    try:
        runner = SQLiteQueryRunner(args.db_path, args.query_directory)
        print_results(runner.run_all(parameters))
        print("\nETL completed successfully.")
        print("Created table: std_member_info")
        return 0
    except (
        FileNotFoundError,
        NotADirectoryError,
        KeyError,
        IndexError,
        sqlite3.Error,
    ) as exc:
        print(f"\nError: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
