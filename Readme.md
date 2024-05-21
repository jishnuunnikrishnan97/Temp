
```
def transform_ref(value):
    part1 = value[2:5]    # MID(C2, 3, 3)
    part2 = value[5:7]    # MID(C2, 6, 2)
    part3 = value[7:14]   # MID(C2, 8, 7)
    return f"{part1}-{part2}-{part3}"
```