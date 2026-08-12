with open(r'D:\exerciseapp\excise\lib\ui\screens\custom_plan_editor_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add weight input field after restSeconds row in _editExercise
old = """        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 60, child: Text('休息(秒)', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '休息', border: OutlineInputBorder()),
            onChanged: (v) => item.restSeconds = v,
            controller: TextEditingController(text: item.restSeconds),
          )),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('保存')),"""
new = """        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 60, child: Text('休息(秒)', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '休息', border: OutlineInputBorder()),
            onChanged: (v) => item.restSeconds = v,
            controller: TextEditingController(text: item.restSeconds),
          )),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const SizedBox(width: 60, child: Text('重量', style: TextStyle(color: Colors.white70))),
          Expanded(child: TextField(
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: '如 50kg', border: OutlineInputBorder()),
            onChanged: (v) => item.weight = v,
            controller: TextEditingController(text: item.weight),
          )),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('保存')),"""
c = c.replace(old, new, 1)

# Update display line to show weight
old2 = """Text('${item.sets}组 × ${item.reps}次 · 休息${item.restSeconds}s', style: theme.textTheme.bodySmall),"""
new2 = """Text('${item.sets}组 × ${item.reps}次${item.weight.isNotEmpty ? ' · ${item.weight}' : ''} · 休息${item.restSeconds}s', style: theme.textTheme.bodySmall),"""
c = c.replace(old2, new2, 1)

with open(r'D:\exerciseapp\excise\lib\ui\screens\custom_plan_editor_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('editor done')
