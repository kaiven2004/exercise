with open(r'D:\exerciseapp\excise\lib\data\models\models.dart', 'r', encoding='utf-8') as f:
    c = f.read()
old = "  final Exercise exercise;\n  int sets;\n  int reps;\n  String restSeconds;\n  final int order;"
new = "  final Exercise exercise;\n  int sets;\n  int reps;\n  String restSeconds;\n  String weight;\n  final int order;"
if old in c:
    c = c.replace(old, new, 1)
    c = c.replace("    this.restSeconds = '60',\n    this.order = 0,", "    this.restSeconds = '60',\n    this.weight = '',\n    this.order = 0,")
    c = c.replace("CustomExerciseItem copyWith({int? sets, int? reps, String? restSeconds, int? order})", "CustomExerciseItem copyWith({int? sets, int? reps, String? restSeconds, String? weight, int? order})")
    c = c.replace("      restSeconds: restSeconds ?? this.restSeconds,\n      order: order ?? this.order,", "      restSeconds: restSeconds ?? this.restSeconds,\n      weight: weight ?? this.weight,\n      order: order ?? this.order,")
    with open(r'D:\exerciseapp\excise\lib\data\models\models.dart', 'w', encoding='utf-8') as f:
        f.write(c)
    print('models.dart done')
else:
    print('not found')
