# N1 Health Data Ops Challenge 2025

## Project structure

```text
N1_Data_Ops_Submission/
|-- SQLiteReader.py
|-- SQLiteQueryRunner.py
|-- read_results.txt
`-- queries/
    |-- 01_build_std_member_info.sql
    |-- 02_member_counts.sql
    |-- 03_april_eligible_members.sql
    |-- ...
    `-- 10_members_in_highest_score_zip.sql
```

## Why SQL is separated

The Python file handles orchestration, database connections, and output
formatting. All SQL—including source validation, date normalization, roster
unions, table creation, and analysis—is stored in plain `.sql` files.

Plain SQL files are easy to read, test, and run directly in a database client.

## SQLiteQueryRunner

`SQLiteQueryRunner` accepts a database path and a query directory. It:

- discovers `*.sql` files;
- sorts them case-insensitively by filename;
- reads every file and supports multiple statements per file;
- runs every query in filename order with shared named parameters; and
- returns a dictionary containing the result rows for every file.

`SQLiteReader.py` gives the database path and query-directory path to the
runner, then passes the returned results to `print_results`.

## Run instructions

Place `n1_data_ops_challenge.db` beside `SQLiteReader.py`, then run:

```powershell
python .\SQLiteReader.py
```

To save the console output:

```powershell
python .\SQLiteReader.py | Tee-Object -FilePath read_results.txt
```

An alternate database path and query directory can also be supplied:

```powershell
python .\SQLiteReader.py "C:\path\to\n1_data_ops_challenge.db"
python .\SQLiteReader.py "C:\path\to\database.db" "C:\path\to\queries"
```

## Assumptions

- "This year" refers to calendar year 2025.
- Eligibility dates are inclusive.
- Eligibility is determined by date-range overlap.
- Duplicate members are resolved by the latest eligibility end date, then the
  latest start date, then the highest-numbered source roster.
- ZIP codes are stored as five-character text values.
- ZIP-level metrics are member-weighted.
