import sys

with open("base.sql") as f:
    base = f.read()

name = sys.argv[1]

print(base.replace("^", name))
