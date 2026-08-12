
f = open(r'D:\\exerciseapp\\excise\\lib\\ui\\screens\\custom_plan_editor_screen.dart', 'rb')
d = f.read()
f.close()
lines = d.split(b'\\n')
old = lines[206]
dl = chr(36)
q = chr(39)
old_part = dl+chr(123)+'item.weight.isNotEmpty ? '+q+' \\xc2\\xb7 '+dl+chr(123)+'item.weight'+chr(125)+q+' : '+q+q
new_part = q+' + (item.weight.isNotEmpty ? '+q+' \\xc2\\xb7 '+q+' + item.weight : '+q+q+')
lines[206] = old.replace(old_part.encode(), new_part.encode())
f = open(r'D:\\exerciseapp\\excise\\lib\\ui\\screens\\custom_plan_editor_screen.dart', 'wb')
f.write(b'\\n'.join(lines))
f.close()
print('ok')
