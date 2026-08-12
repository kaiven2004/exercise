import re
path = r"D:\exerciseapp\excise\lib\ui\screens\custom_plan_runner_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    c = f.read()
old = """SizedBox(height: 56, child: Row(children: [
                  Expanded(child: _StatBox(label: '"'"'目标'"'"', value: '"'"'${current.sets}组'"'"')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: '"'"'次数'"'"', value: '"'"'${current.reps}次'"'"')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: '"'"'休息'"'"', value: '"'"'${current.restSeconds}s'"'"')),
                ])),"""
new = """SizedBox(height: 56, child: Row(children: [
                  Expanded(child: _StatBox(label: '"'"'目标'"'"', value: '"'"'${current.sets}组'"'"')),
                  const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: '"'"'次数'"'"', value: '"'"'${current.reps}次'"'"')),
                  if (current.weight.isNotEmpty) const SizedBox(width: 8),
                  if (current.weight.isNotEmpty) Expanded(child: _StatBox(label: '"'"'重量'"'"', value: '"'"'${current.weight}'"'"')),
                  if (current.weight.isNotEmpty) const SizedBox(width: 8),
                  Expanded(child: _StatBox(label: '"'"'休息'"'"', value: '"'"'${current.restSeconds}s'"'"')),
                ])),"""
if old in c:
    c = c.replace(old, new, 1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(c)
    print("runner updated")
else:
    print("not found")
