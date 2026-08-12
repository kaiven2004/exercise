with open(r'D:\exerciseapp\excise\lib\data\repositories\sample_repository.dart', 'rb') as f:
    data = f.read()
old = b"      'chest_upper': '\xe4\xb8\x8a\xe8\x83\xb8',\r\n      'chest_middle': '\xe4\xb8\xad\xe8\x83\xb8',\r\n      'chest_lower': '\xe4\xb8\x8b\xe8\x83\xb8',\r\n      'shoulder_front': '\xe5\x89\x8d\xe6\x9d\x9f',\r\n      'shoulder_mid': '\xe4\xb8\xad\xe6\x9d\x9f',\r\n      'shoulder_rear': '\xe5\x90\x8e\xe6\x9d\x9f',\r\n      'back_lats': '\xe8\x83\x8c\xe9\x98\x94\xe8\x82\x8c',\r\n      'back_traps': '\xe6\x96\x9c\xe6\x96\xb9\xe8\x82\x8c',\r\n      'leg_quads': '\xe8\x82\xa1\xe5\x9b\x9b\xe5\xa4\xb4\xe8\x82\x8c',\r\n      'leg_hamstrings': '\xe8\x98\x98\xe7\xbb\xb3\xe8\x82\x8c',\r\n      'leg_glutes': '\xe8\x87\x80\xe9\x83\xa8',\r\n      'core_abs': '\xe8\x85\xb9\xe7\x9b\xb4\xe8\x82\x8c',\r\n      'core_obliques': '\xe8\x85\xb9\xe6\x96\x9c\xe8\x82\x8c',"
# Check what the actual bytes are for leg_hamstrings
idx = data.find(b'leg_hamstrings')
print('leg_hamstrings raw:', repr(data[idx:idx+60]))
