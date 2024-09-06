```
def remove_after_response_received(transactions):
  """Removes everything after "RESPONSE RECEIVED" from each transaction list.

  Args:
    transactions: A list of transaction lists.

  Returns:
    A list of modified transaction lists.
  """

  modified_transactions = []
  for transaction in transactions:
    index = transaction.index("RESPONSE RECEIVED")
    modified_transaction = transaction[:index + 1]
    modified_transactions.append(modified_transaction)

  return modified_transactions

# Example usage:
transactions = [
    ['\x1b[020t*488*04/16/2024*06:44:16*', *PRIMARY CARD READER ACTIVATED*', '\x1b[020t*489*04/16/2024*06:44:23*', *TRANSACTION START*', '\x1b[020t CARD INSERTED', '06:44:24 ATR RECEIVED T=1', '\x1b[020tCARD: 652183******2734', 'DATE 16-04-24 TIME 06:44:31', '\x1b[020t 06:44:41 PIN ENTERED', '06:44:48 AMOUNT 1500 ENTERED', '\x1b[020t 06:44:54 OPCODE = CC B BF', '06:44:55 REQUEST SENT [AMOUNT=00001500]', ' 06:44:56 GENAC 1: ARQC', '06:44:59 RESPONSE RECEIVED [FUNCTION ID=2, TXN SN NO=9997]', '06:45:00 GENAC 2: TC', '\x1b[020t 06:45:04 NOTES STACKED', '---16/04/24 06:45:53 01080949 CARD NO:652183******2734 ', '\x1b[020t 06:45:23 TRANSACTION END'],
    ['\x1b[020t*490*04/16/2024*06:45:23*', '*PRIMARY CARD READER ACTIVATED*', '\x1b[020t*491*04/16/2024*06:53:22*', '*TRANSACTION START*', '\x1b[020t CARD INSERTED', '06:53:22 ATR RECEIVED T=0', '\x1b[020tCARD: 608072******7301', 'DATE 16-04-24 TIME 06:53:31', '\x1b[020t 06:53:42 PIN ENTERED', '06:53:51 AMOUNT 2000 ENTERED', '\x1b[020t 06:54:02 OPCODE = CC B BD', '06:54:03 REQUEST SENT [AMOUNT=00002000]','06:54:05 GENAC 1: ARQC', '06:54:08 RESPONSE RECEIVED [FUNCTION ID=2, TXN SN NO=9998]', '06:54:09 GENAC 2: TC', '\x1b[020t 06:54:13 NOTES STACKED', '---16/04/24 06:55:01 01080949 CARD NO:608072******7301' ,'\x1b[020t 06:54:19 NOTES TAKEN', '\x1b[020t 06:54:29 TRANSACTION END']
]

modified_transactions = remove_after_response_received(transactions)
print(modified_transactions)


```