# Publishing

Open this when a report is published as an artifact, packaged for sharing, or checked
against its published version.

## Contents

- Source and published copy
- Manifest
- Package
- Links file
- Live equals disk

## Source and published copy

- The source document links to its supporting documents by relative file name, so the
  folder reads offline.
- The published copy is the source with every relative link rewritten to the target's
  published URL, from a `urls.json` map of file name to URL. It is built, never edited.
- The artifact is published from the published copy. Publishing the source ships links to
  file names that no reader can open.
- A supporting document is published before the document that links to it, so its URL
  exists when the links are rewritten.

Build the copy by taking the source's content from the charset meta to the end of the
body, dropping the head and body wrappers, and replacing each `href="FILE"` with the URL
from the map. Keep the build as a script in the document folder so a change rebuilds all
copies in one run.

## Manifest

A `submission-manifest.json` beside the documents lists the entry point and, for every
document, its file name, its SHA-256 hash, and its page count (the count of page labels).
The manifest is rebuilt after every change; a hash that does not match the file is a stale
package.

## Package

- The package is a ZIP of one folder holding the source documents, the manifest, the links
  file, a README that says what each document is, and a start page that links to the entry
  point.
- The package holds the source copies, with relative links, so it reads offline.
- Build it from the document folder with `zip -r -X`, excluding `.DS_Store`, and move the
  previous package aside before writing the new one.

## Links file

A links file beside the documents lists every published document in a table: the page, its
URL, and its version with the date. The version is bumped on every publish; a publish that
changes nothing is not made.

## Live equals disk

After every publish, read each artifact back, strip the viewer's wrapper, and compare it
with the published copy on disk. Every document reads "same" before the work is reported.
A difference means the artifact or the copy is stale, and the pass is run again.

The same check holds for the package: unpack it and compare each file with the source
documents, the manifest, and the links file.
