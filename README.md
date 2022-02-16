# jdf/bakery

Create self-contained html files which:

- provide interactive data visualisation through the use of built-in data, js, css and svg
- require only a modern browser to view; no network, server, or other infrastructure
- are able to deliver contained data as csv "download"
- also contain a static visualisation suitable for use in noscript environments such as SharePoint

Subject to browser API deprecation, these files may be more distributable and archivable, and less susceptible to breakage (dependencies, build systems, server maintenance etc) than other methods of interactive data visualisation.

## Method

### Ingest data from CSV
Encode as inline json vs compressed blob. Deserialise on execution incl possibly converting types e.g. string to Date.

### Define visualisation
Map data to DOM elements directly in the first instance. Consider using data attributes.

Use modern web APIs from nim.

### Provide export
Reconstruct CSV and present as download.

## Maturity

Pre-alpha. Will eventually separate functionality into dedicated libraries/tools.
