```

import time

start_time = time.perf_counter()  # Get the start time

# Your code block to be timed
for i in range(10000):
    pass

end_time = time.perf_counter()  # Get the end time

execution_time = end_time - start_time
print(f"Execution time: {execution_time:.6f} seconds")


from win10toast import ToastNotifier

# Create a ToastNotifier object
toaster = ToastNotifier()

# Notification title and message
title = "Python Script Notification"
message = "Your script has finished running!"

# Show the notification
toaster.show_toast(title, message)





```