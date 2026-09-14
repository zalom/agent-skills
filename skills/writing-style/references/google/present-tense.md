# Present Tense

Source: https://developers.google.com/style/tense

Use present tense for general, time-independent behavior.
- Recommended: "Send a query to the service. The server sends an acknowledgment."
- Not recommended: "Send a query to the service. The server will send an acknowledgment."

## Future tense is OK to distinguish a genuinely future action
- Recommended: "Add the filename to the backup list. The file will be archived the next time the backup process runs."
- Recommended (async messaging): "A message is sent that will notify any Pub/Sub subscribers." (correct because Pub/Sub delivery isn't immediate)
- Not recommended: "A message is sent that notifies any Pub/Sub subscribers."

## Don't use future tense for unreleased functionality
Never describe how a product/feature will work after the next release/update — see Document future features.

## Avoid the hypothetical future "would"
- Recommended: "If you send an unsubscribe message, the server removes you from the mailing list."
- Not recommended: "You can send an unsubscribe message. The server would then remove you from the mailing list."
