# Exit on error
set -euo pipefail

OUTPUT_FILE="${1:-datasets.json}"
DATASETS_DIR="$PWD/frontend/datasets"

if [ ! -d "$DATASETS_DIR" ]; then
  echo "Error: Directory '$DATASETS_DIR' does not exist." >&2
  exit 1
fi

echo "[" > "$OUTPUT_FILE"

first=true
for file in "$DATASETS_DIR"/*.json; do
  [ -e "$file" ] || continue

  filename=$(basename "$file")
  rel_path="datasets/$filename"

  # POSIX pattern matching
  case "$filename" in
    [A-Z][A-Z]_cities.json)
      code=$(printf '%s' "$filename" | cut -c1-2)
      title="$code Cities"
      ;;
    cities500.json)
      title="World cities 500+ residents"
      ;;
    *)
      title="$filename"
      ;;
  esac

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

  printf '    {\n        "name": "%s",\n        "path": "%s",\n        "items": %s\n    }' "$title" "$rel_path" "$count" >> "$OUTPUT_FILE"
done

echo "" >> "$OUTPUT_FILE"
echo "]" >> "$OUTPUT_FILE"