
f = open(r'D:\\exerciseapp\\excise\\lib\\ui\\screens\\custom_plan_editor_screen.dart', 'rb')
d = f.read()
f.close()
lines = d.split(b'\\n')
old_line = lines[206]
q = chr(39)
dl = chr(36)
dot = bytes([194, 183])
old_pat = b'Text(' + q.encode() + dl.encode() + b'{item.weight.isNotEmpty ? ' + q.encode() + dot + b' ' + dl.encode() + b'{item.weight}' + q.encode() + b' : ' + q.encode() + q.encode()
new_pat = q.encode() + b' + (item.weight.isNotEmpty ? ' + q.encode() + dot + b' ' + q.encode() + b' + item.weight : ' + q.encode() + q.encode() + b')
old_line = old_line.replace(old_pat, new_pat)
lines[206] = old_line
f = open(r'D:\\exerciseapp\\excise\\lib\\ui\\screens\\custom_plan_editor_screen.dart', 'wb')
f.write(b'\\n'.join(lines))
f.close()
print('ok')
