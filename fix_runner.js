const fs = require('fs');
let s = fs.readFileSync('D:\\exerciseapp\\excise\\lib\\ui\\screens\\custom_plan_runner_screen.dart', 'utf8');
let target = '                  Expanded(child: _StatBox(label: chr(27425)+chr(25968), value: chr(36)+'+chr(123)+'current.reps'+chr(125)+'组')),\\n';
console.log('target:', target);
