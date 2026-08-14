import json, re
with open(r"D:\exerciseapp\excise\lib\data\exercises_export.json", encoding="utf-8") as f:
    data = json.load(f)
json_ids = {e["id"] for e in data}
print(f"JSON IDs sample: {list(json_ids)[:10]}")
print(f"JSON has 0001: {'0001' in json_ids}")
print(f"JSON has 1: {'1' in json_ids}")

with open(r"D:\exerciseapp\excise\lib\data\repositories\sample_repository.dart", encoding="utf-8") as f:
    content = f.read()
dart_ids = re.findall(r"id:\s+'(\d+)'", content)
print(f"Found {len(dart_ids)} IDs in dart file")
print(f"Dart IDs sample: {dart_ids[:5]}")
print(f"Dart has '1': {'1' in set(dart_ids)}")
print(f"Dart has '0001': {'0001' in set(dart_ids)}")
