extends RefCounted
# JSON numbers may arrive as floats, but counters/ranks must be exact integers.
static func integer(value,minimum: int,maximum: int) -> bool:
    return (value is int or value is float) and is_finite(float(value)) and float(value)==floor(float(value)) and value>=minimum and value<=maximum
static func header(value) -> bool:
    return value is Dictionary and integer(value.get("schema"),1,1)
