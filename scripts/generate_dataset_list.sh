
# Exit on error
set -euo pipefail

# Output file path from $1, defaulting to datasets.json if not provided
OUTPUT_FILE="${1:-datasets.json}"
DATASETS_DIR="$PWD/frontend/datasets"


if [[ ! -d "$DATASETS_DIR" ]]; then
  echo "Error: Directory '$DATASETS_DIR' does not exist." >&2
  exit 1
fi

echo "[" > "$OUTPUT_FILE"

first=true
for file in "$DATASETS_DIR"/*.json; do
  [[ -e "$file" ]] || continue

  # Get just the filename (e.g. HR_cities.json)
  filename=$(basename "$file")
  rel_path="datasets/$filename"

  if command -v jq >/dev/null 2>&1 && jq -e '. | (if type=="array" then length elif type=="object" then keys|length else 0 end)' "$file" >/dev/null 2>&1; then
    count=$(jq '. | if type=="array" then length elif type=="object" then keys|length else 0 end' "$file")
  else
    count=$(wc -l < "$file" | tr -d ' ')
  fi

  if [ "$first" = true ]; then
    first=false
  else
    echo "," >> "$OUTPUT_FILE"
  fi

  printf '    {\n        "path": "%s",\n        "items": %s\n    }' "$rel_path" "$count" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "]" >> "$OUTPUT_FILE"