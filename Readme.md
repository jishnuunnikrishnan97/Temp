```
def extract_info(data):
  card_numbers = []
  pin_entered_times = []
  response_received_times = []

  for transaction in data:
    for line in transaction:
      if "CARD:" in line:
        card_numbers.append(line.split(":")[1].strip())
      elif "PIN ENTERED" in line:
        pin_entered_times.append(line.split(" ")[1])
      elif "RESPONSE RECEIVED" in line:
        response_received_times.append(line.split(" ")[1])

  return {
    "CARD": card_numbers,
    "PIN ENTERED": pin_entered_times,
    "RESPONSE RECEIVED": response_received_times
  }
```