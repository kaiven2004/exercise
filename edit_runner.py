lines = open(r'D:\exerciseapp\excise\t.py',encoding='utf-8').readlines()
result = []
i = 0
while i < len(lines):
    line = lines[i]
    if 'SizedBox(height: 56, child: Row(children: [' in line:
        i += 1
        while i < len(lines) and '                ])),\n' not in lines[i]:
            i += 1
        i += 1
        result.append('                SizedBox(height: 56, child: Row(children: [\n')
        result.append("                  Expanded(child: _StatBox(label: '目标', value: '组')),\n")
        result.append('                  const SizedBox(width: 8),\n')
        result.append("                  Expanded(child: _StatBox(label: '次数', value: '次')),\n")
        result.append('                  if (current.weight.isNotEmpty) const SizedBox(width: 8),\n')
        result.append("                  if (current.weight.isNotEmpty) Expanded(child: _StatBox(label: '重量', value: '')),\n")
        result.append('                  if (current.weight.isNotEmpty) const SizedBox(width: 8),\n')
        result.append("                  Expanded(child: _StatBox(label: '休息', value: 's')),\n")
        result.append('                ])),\n')
    else:
        result.append(line)
        i += 1
open(r'D:\exerciseapp\excise\lib\ui\screens\custom_plan_runner_screen.dart','w',encoding='utf-8').writelines(result)
print('done')