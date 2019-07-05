import subprocess
import sys

args = sys.argv
s0 = '\'Insertion.run(xxx)\''
s = s0.replace('xxx', args[1])

res = subprocess.run(['elixir', '-r', 'insertion.ex', '-e', s, '>', 'out'])
# print(res)
# print('-------'+args[1]+'-------')



