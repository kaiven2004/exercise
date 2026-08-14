import json
import re

# Read kept IDs from JSON export
with open(r"D:\exerciseapp\excise\lib\data\exercises_export.json", encoding="utf-8") as f:
    data = json.load(f)
kept_ids = {e["id"] for e in data}
print(f"Kept IDs count: {len(kept_ids)}")

# Read Dart file
with open(r"D:\exerciseapp\excise\lib\data\repositories\sample_repository.dart", encoding="utf-8") as f:
    content = f.read()

lines = content.split("\n")
print(f"Total lines: {len(lines)}")

# Find start and end markers
start_idx = None
end_idx = None
for i, l in enumerate(lines):
    if "static const List<Exercise> _exercises" in l:
        start_idx = i
    if l.strip() == "};" and start_idx is not None and i > start_idx:
        end_idx = i
        break

print(f"Start marker: line {start_idx}")
print(f"End marker: line {end_idx}")

prefix_lines = lines[:start_idx]
suffix_lines = lines[end_idx+1:]

exercise_lines = []
exercise_count = 0
kept_count = 0
removed_count = 0
in_entry = False

for l in lines[start_idx+1:end_idx]:
    stripped = l.strip()
    if stripped.startswith("Exercise("):
        exercise_count += 1
        m = re.search(r"id:\s*'(\d+)'", stripped)
        if m:
            eid = m.group(1)
            if eid in kept_ids:
                kept_count += 1
                in_entry = True
                exercise_lines.append(l)
            else:
                removed_count += 1
                in_entry = False
        else:
            in_entry = True
            exercise_lines.append(l)
    elif in_entry:
        exercise_lines.append(l)
        if stripped.endswith("),") or stripped.endswith("),\n"):
            in_entry = False

print(f"Exercises: {exercise_count}, Kept: {kept_count}, Removed: {removed_count}")

new_lines = prefix_lines + exercise_lines + suffix_lines
with open(r"D:\exerciseapp\excise\lib\data\repositories\sample_repository.dart", "w", encoding="utf-8") as f:
    f.write("\n".join(new_lines))

print(f"Written {len(new_lines)} lines")
