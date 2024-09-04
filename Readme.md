```
def split_string(string):
    """Splits a string into a list of lists based on specified criteria.

    Args:
        string: The input string.

    Returns:
        A list of lists, where each inner list contains a portion of the input string
        that starts with '*Transaction start*' and ends with 'Transaction end'.
    """

    start_marker = "*Transaction start*"
    end_marker = "Transaction end"

    tsf = []
    current_list = []

    for line in string.splitlines():
        if start_marker in line:
            current_list.append(line)
        elif end_marker in line:
            current_list.append(line)
            tsf.append(current_list)
            current_list = []
        else:
            current_list.append(line)

    return tsf

# Example usage:
bare_string = """
*Transaction start*
Line 1 of transaction 1
Line 2 of transaction 1
Transaction end

*Transaction start*
Line 1 of transaction 2
Line 2 of transaction 2
Transaction end
"""

tsf_result = split_string(bare_string)
print(tsf_result)


```