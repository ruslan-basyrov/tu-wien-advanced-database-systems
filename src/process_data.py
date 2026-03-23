"""Data processing script.

Reads raw data and produces a cleaned/processed dataset.
Called by Snakemake: python src/process_data.py --input <raw> --output <processed>
"""

import argparse
from pathlib import Path


def process(input_path: Path, output_path: Path) -> None:
    """Read raw data, clean it, and write processed output.

    TODO: Replace with your actual data processing logic.
    """
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Placeholder: copy input to output
    output_path.write_text(input_path.read_text())


def main() -> None:
    parser = argparse.ArgumentParser(description="Process raw data")
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    process(args.input, args.output)


if __name__ == "__main__":
    main()
