path = r'D:\exerciseapp\excise\lib\data\repositories\sample_repository.dart' 
lines = open(path, encoding='utf-8').readlines() 
print('Fixed') 
open(path, 'w', encoding='utf-8').writelines(lines) 
lines.insert(694, '    };' + chr(10)) 
lines.insert(694, '    };' + chr(10)) 
open(path, 'w', encoding='utf-8').writelines(lines) 
