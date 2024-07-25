```

def seconds_to_hms(seconds):
  """Converts seconds to hours, minutes, and seconds."""

  hours = seconds // 3600
  seconds %= 3600
  minutes = seconds // 60
  seconds %= 60

  return f"{hours:02d}:{minutes:02d}:{seconds:02d}"

# Example usage:
total_seconds = 7187
result = seconds_to_hms(total_seconds)
print(result)  # Output: 01:59:47





```