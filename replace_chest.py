import re 
print(len(chest)) 
lines = content.split(chr(10)) 
path = r'D:\\exerciseapp\\excise\\lib\\data\\repositories\\sample_repository.dart' 
content = open(path, encoding='utf-8').read() 
chest = [i for i, l in enumerate(lines) if 'categoryPath:' in l and '胸部训练' in l] 
