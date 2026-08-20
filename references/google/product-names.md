# Product Names

Source: https://developers.google.com/style/product-names

## Capitalize product names

Google product names are generally written in *title case* (also called *init-capped*): every word is capitalized except prepositions (*of*, *on*) and articles (*a*, *the*). Use title case when referring to a Google product, except when matching a UI label exactly (see UI elements and interaction for how to refer to UI labels).

Follow the official capitalization for names of brands, companies, software, products, services, features, and terms defined by companies and open source communities.

- For Kubernetes-related terms, follow the capitalization shown in the Kubernetes Concepts documentation.
  - Recommended (Kubernetes context): "A Job creates one or more Pods."
  - Recommended: "The Cloud Scheduler job publishes a message to a Pub/Sub topic at one-minute intervals."
- If an official name begins with a lowercase letter, keep it lowercase even at the start of a sentence — but it's better to revise the sentence to avoid a lowercase word at the start, if possible.
  - Recommended: "You can use macOS to run the app."
  - Not recommended: "macOS can run the app."

### Feature names

A *feature* is a distinctive attribute or capability of a product, usually described in terms of what it can do as part of a product. In general, feature names are lowercase, with exceptions.

- Don't capitalize a feature name unless it's officially capitalized.
- If unsure, follow the precedent set by other documents describing the feature.
- As with products, match the capitalization of a UI label when referring to one.
- See also the general Capitalization page for broader capitalization rules.

## Shorten Google product names

You might want to abbreviate a long product name (e.g., referring to "Google Spreadsheets" as "Spreadsheets" after first mention).

- Use the full trademarked product name. Don't abbreviate product names, except when matching a UI label — and in that case, make clear you're referring to the Google product and not something else with a similar name.
- Consider whether you need to repeat the specific product name throughout a document, or whether you can use a more general term instead. For example, once you've established you're discussing *Anthos Service Mesh*, you can often frame the rest of the discussion around the general concept of "a service mesh."

## Possessives of product names

For guidance on forming possessives with product names, see Product, feature, and company names (a related page in the guide).

## Articles before product names

- Don't use *the* before a product name unless the name is modifying something else.
- DO use *the* before tool names and API names.

Recommended:
- "Using Cloud Datastore with Cloud Dataproc"
- "The Cloud Datastore options page"
- "The Google Cloud console"
- "The Transcoder API"
- "The `gcloud` CLI"

Not recommended:
- "Using the Cloud Datastore with Cloud Dataproc"

When a product name modifies something else with an indefinite article (*a*/*an*), pay close attention to which article precedes it.

Recommended:
- "An Anthos Service Mesh environment"
- "A Service Mesh environment"

See also the general Articles page for more on *a*, *an*, *the*.

## Use "service" to refer to multiple products

It's OK to refer to Google products as "services" — e.g., "the Google Kubernetes Engine service" or "the Compute Engine service." However, if the term "services" creates ambiguity, use the specific product names instead.

## Don't use product names as verbs

Never use product names or feature names as verbs.
