with open(r'"'"'D:\exerciseapp\excise\lib\ui\screens\custom_plan_runner_screen.dart'"'"', '"'"'r'"'"', encoding='"'"'utf-8'"'"') as f:
    c = f.read()
old = '"'"'SizedBox(height: 56, child: Row(children: [\n                  Expanded(child: _StatBox(label: '"'"'目标'"'"', value: '"'"'${current.sets}组'"'"')),\n                  const SizedBox(width: 8),\n                  Expanded(child: _StatBox(label: '"'"'次数'"'"', value: '"'"'${current.reps}次'"'"')),\n                  const SizedBox(width: 8),\n                  Expanded(child: _StatBox(label: '"'"'休息'"'"', value: '"'"'${current.restSeconds}s'"'"')),\n                ])),'"'"'
new = '"'"'SizedBox(height: 56, child: Row(children: [\n                  Expanded(child: _StatBox(label: '"'"'目标'"'"', value: '"'"'${current.sets}组'"'"')),\n                  const SizedBox(width: 4),\n                  Expanded(child: _StatBox(label: '"'"'次数'"'"', value: '"'"'${current.reps}次'"'"')),\n                  if (current.weight.isNotEmpty) const SizedBox(width: 4),\n                  if (current.weight.isNotEmpty) Expanded(child: _StatBox(label: '"'"'重量'"'"', value: '"'"'${current.weight}'"'"')),\n                  if (current.weight.isNotEmpty) const SizedBox(width: 4),\n                  Expanded(child: _StatBox(label: '"'"'休息'"'"', value: '"'"'${current.restSeconds}s'"'"')),\n                ])),'"'"'
if old in c:
    c = c.replace(old, new, 1)
    with open(r'"'"'D:\exerciseapp\excise\lib\ui\screens\custom_plan_runner_screen.dart'"'"', '"'"'w'"'"', encoding='"'"'utf-8'"'"') as f:
        f.write(c)
    print('"'"'done'"'"')
else:
    print('"'"'not found'"'"')
