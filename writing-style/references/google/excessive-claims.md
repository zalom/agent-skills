# Avoid Excessive Claims

Source: https://developers.google.com/style/excessive-claims

An *excessive claim* is any statement that:
- Asserts performance or cost that isn't easily verifiable with data available to the reader.
- Asserts security that would be invalidated by a future security incident.
- Could be read as subjective or disparaging, especially about third-party products.

Assess claims against not just what's true today but what could become false in the future.

## Guidelines
- Avoid superlatives: *best*, *simplest*, *fastest*, *never*, *always*. Use *ensure*/*guarantee* only when something can truly be ensured/guaranteed.
- Specific performance claims (speed, storage, etc.) must cite their data source.
- Never claim a product "is secure" outright — a single breach invalidates and discredits the doc. Prefer "helps with security" or "is designed for security," which remain true even after an incident.
- Competitive claims can become false if you misunderstand the competitor's product, or if the competitor later updates their product.

**Safest approach**: write factually and objectively — only verifiable statements that will remain true for the life of the document.

| Recommended | Not recommended |
|---|---|
| "Our product distributes datasets and computation in memory across a cluster, and therefore it can be faster for this scenario than ExampleCorporation's product. For more information, see Performance comparison." | "Our product is faster than ExampleCorp's product." |
| "Using our security product is part of an overall strategy that helps prevent account takeovers from phishing attacks." | "Our security product prevents account takeovers from phishing attacks." |
