with open(r'D:\exerciseapp\excise\lib\data\repositories\custom_plan_repository.dart', 'r', encoding='utf-8') as f:
    c = f.read()
c = c.replace("        'sets': e.sets,\n        'reps': e.reps,\n        'restSeconds': e.restSeconds,\n        'order': e.order,", "        'sets': e.sets,\n        'reps': e.reps,\n        'restSeconds': e.restSeconds,\n        'weight': e.weight,\n        'order': e.order,")
c = c.replace("        sets: exJson['sets'] as int,\n        reps: exJson['reps'] as int,\n        restSeconds: exJson['restSeconds'] as String,\n        order: exJson['order'] as int,", "        sets: exJson['sets'] as int,\n        reps: exJson['reps'] as int,\n        restSeconds: exJson['restSeconds'] as String,\n        weight: exJson['weight'] as String? ?? '',\n        order: exJson['order'] as int,")
with open(r'D:\exerciseapp\excise\lib\data\repositories\custom_plan_repository.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('repository.dart done')
