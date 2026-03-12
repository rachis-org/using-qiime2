(metadata-formatting-reference)=
# Metadata file format

QIIME 2 metadata is most commonly[^metadata-tsv-exception] stored in a [TSV (i.e. tab-separated values)](https://en.wikipedia.org/wiki/Tab-separated_values) file.
These files typically have a `.tsv` or `.txt` file extension, though it doesn't matter to QIIME 2 what file extension is used.
TSV files are simple text files used to store tabular data, and the format is supported by many types of software.
TSV files can be imported to, edited in, and exported from most spreadsheet programs and databases.
Thus it's usually straightforward to manipulate QIIME 2 metadata using the software of your choosing.
If in doubt, we recommend using a spreadsheet program such as Google Sheets to edit and export your metadata files.

Because metadata files contain tabular data, we describe their formatting in terms of **rows** and **columns**.
The commonality across QIIME 2 metadata files is that the first [non-comment, non-empty](#comments-and-empty-rows) row of the file defines the column headers, and the first column contains a unique identifier for each metadata entry.
The following sections describe the formatting requirements for QIIME 2 metadata files.

There is no universal standard for TSV files.
It is important to adhere to the requirements described in this document to understand how QIIME 2 will interpret your metadata file's contents.

```{admonition} Warning: Do not include confidential information in your metadata.
:class: warning
QIIME 2 goes to great lengths to ensure that your bioinformatics workflow will be reproducible.
This includes recording information about your analysis inside of your Results' data provenance, and the recorded information includes metadata that you provided to run specific commands.
For this and other reasons, we strongly recommend that you **never include confidential information, such as Personally Identifying Information (PII), in your QIIME 2 metadata**.
**Because QIIME 2 stores metadata in your data provenance, confidential information that you use in a QIIME 2 analysis will persist in downstream Results.**

Instead of including confidential information in your metadata, you should encode it with variables that only authorized individuals have access to.
For example, subject names should be replaced with anonymized subject identifiers before use with QIIME 2.
```

```{warning}
Spreadsheet editors often have auto-correct or auto-format features that will modify your data without alerting you that changes will be made (e.g., see [Ziemann et al. (2016)](https://doi.org/10.1186/s13059-016-1044-7)).
This is something that you need to watch out for when working with your metadata files in spreadsheet editors.
```

(comments-and-empty-rows)=
## Comments, comment directives, and empty rows

Rows whose first cell begins with the pound sign (`#`) are interpreted as comments and may appear anywhere in the file.
Comment rows are ignored by QIIME 2 and are for informational purposes only.
Inline comments (i.e., comments that begin part-way through a row or at the end of a row) are not supported.

Rows beginning with `#q2:` are interpreted as **comment directives** and should not be used unless they are used in a comment directive (e.g., `q2:types` or `q2:missing`).
We discuss use cases for these below.
We reserve the right to add new comment directives, beyond those that are already defined, in the future.

Empty rows (e.g. blank lines or rows consisting solely of empty cells) may appear anywhere in the file and are ignored.

(identifier-column)=
## Identifier column

The first column in the metadata file is the **identifier (ID) column**.
This column defines the sample or feature IDs described by your metadata.
It is not recommended to mix sample and feature IDs in a single metadata file; keep sample and feature metadata stored in separate files.

The **ID column name** (also referred to as the ID column header) must be one of the following values.
The values listed below are reserved for use as ID column names and may not be used as IDs or names of other columns in the metadata file.

Case-insensitive (i.e., uppercase or lowercase, or a mixing of the two, is allowed):

- `id`
- `sampleid`
- `sample id`
- `sample-id`
- `featureid`
- `feature id`
- `feature-id`

````{margin}
```{note}
The case-sensitive ID headers are available for backwards-compatibility with QIIME 1, biom-format, and Qiita files.
```
````

Case-sensitive (i.e., these must appear exactly as presented here):

- `#SampleID`
- `#Sample ID`
- `#OTUID`
- `#OTU ID`
- `sample_name`

The following rules apply to IDs:

- IDs may consist of any Unicode characters, with the exception that IDs must not start with the pound sign (`#`), as those rows would be interpreted as comments and ignored.
  See the section {ref}`identifier-recommendations` for recommendations on choosing identifiers in your study.
- IDs cannot be empty (i.e. they must consist of at least one character).
- IDs must be unique (exact string matching is performed to detect duplicates).
- At least one ID must be present in the file.
- IDs cannot be any of the reserved ID headers listed above.

## Metadata columns

The ID column is the first column in the metadata file, and can optionally be followed by additional columns defining metadata associated with each sample or feature ID.
Metadata files are not required to have additional metadata columns, so a file containing only an ID column is a valid QIIME 2 metadata file.

The following rules apply to column names:

- May consist of any Unicode characters.
- Cannot be empty (i.e., column names must consist of at least one character).
- Must be unique without regard to case (e.g., columns `foo` and `Foo` in the same file are not allowed).
- Column names cannot use any of the reserved ID headers described in the section {ref}`identifier-column`.

The metadata file line containing the ID column name and any other column names is referred to as the **header row**.

```{admonition} Jargon: metadata columns or metadata categories?
In previous versions of QIIME 2 and in QIIME 1, *metadata columns* were often referred to as *metadata categories*.
Now that we support metadata column typing, which allows you to say whether a column contains *numeric* or *categorical* data, we would end up using terms like *categorical metadata category* or *numeric metadata category*, which can be confusing.
We now avoid using the term *category* unless it is used in the context of *categorical* metadata.
We've done our best to update our software and documentation to use the term *metadata column* instead of *metadata category*, but there may still be lingering usage of the previous terms out there.
```

## Metadata values

The contents of a metadata file following the ID column and header row (excluding comments and empty lines) are referred to as the **metadata values**.
A single metadata value, defined by an (ID, column) pair, is referred to as a **cell**.

The following rules apply to metadata values and cells:

- May consist of any Unicode characters.
- Empty cells represent *missing data*.
  Other values such as `NA` are not interpreted as missing data; only the empty cell is recognized as "missing".
  Note that cells consisting solely of whitespace characters are also interpreted as *missing data* because [leading and trailing whitespace characters are always ignored](#metadata-whitespace), effectively making the cell empty.
  For more advanced ways to handle missing data, see [](#advanced-missing-metadata).

(metadata-whitespace)=
## Leading and trailing whitespace characters

If **any** cell in the metadata contains leading or trailing whitespace characters (e.g. spaces, tabs), those characters will be ignored when the file is loaded.
Thus, leading and trailing whitespace characters are not significant, so cells containing the values `'gut'` and `'  gut  '` are equivalent.
This rule is applied before any other rules described in this section.

(identifier-recommendations)=
## Recommendations for identifiers

Our goal with QIIME 2 is to support arbitrary Unicode characters in all cells of metadata files.
However, given that QIIME 2 plugins and interfaces can be developed by anyone, we can't make a guarantee that arbitrary Unicode characters will work with all plugins and interfaces.
We can therefore make recommendations to users about characters that should be safe to use in identifiers, and [we are preparing resources for plugin and interface developers](https://github.com/caporaso-lab/developing-with-qiime2/issues/127) to help them make their software as robust as possible.

Sample and feature identifiers with problematic characters tend to cause the most issues for our users.
Based on our experiences we recommend the following attributes for identifiers:

- Identifiers should be 36 characters[^36-characters] long or less.
- Identifiers should contain only ASCII alphanumeric characters (i.e. in the range of `[a-z]`, `[A-Z]`, or `[0-9]`), the period (`.`) character, or the dash (`-`) character.

An important point to remember is that sometimes values in your sample metadata can become identifiers.
For example, taxonomy annotations can become feature identifiers following `qiime taxa collapse`, and sample or feature metadata values can become identifiers after applying `qiime feature-table group`.
If you plan to apply these or similar methods where metadata values can become identifiers, you will be less likely to encounter problems if the values adhere to these identifier recommendations as well.

```{tip}
We recommend the [cual-id](https://github.com/johnchase/cual-id) software for assistance with creating sample identifiers.
The [cual-id paper](https://doi.org/10.1128/mSystems.00010-15) also provides some discussion on how to design identifiers.
```

```{note}
Some bioinformatics tools may have more restrictive requirements on identifiers than the recommendations that are outlined here.
For example, Illumina sample sheet identifiers cannot have `.` characters, while we do include those in our set of recommended characters.
Similarly, [Phylip](http://evolution.genetics.washington.edu/phylip.html) requires that identifiers are a maximum of 10 characters, while we recommend length 36 or less.
If you plan to export your data for use with other tools that may have more restrictive requirements on identifiers, we recommend that you adhere to those requirements in your QIIME 2 metadata as well, to simplify subsequent processing steps.
```

## Column types

QIIME 2 currently supports *categorical* and *numeric* metadata columns.
By default, QIIME 2 will attempt to infer the type of each metadata column: if the column consists only of numbers or missing data, the column is inferred to be *numeric*.
Otherwise, if the column contains any non-numeric values, the column is inferred to be *categorical*.
Missing data (i.e. empty cells) are supported in categorical columns as well as numeric columns.

QIIME 2 supports an optional **comment directive** to allow users to explicitly state a column's type.
This bypasses the column type inference described above.
This can be useful if there is a column that appears to be numeric, but should actually be treated as categorical metadata (e.g. a `Subject` column where subjects are labeled `1`, `2`, `3`, etc.).
Explicitly declaring a column's type also makes your metadata file more descriptive because the intended column type is included with the metadata, instead of relying on software to infer the type (which isn't always transparent).

You can add a *comment directive* to declare column types in your metadata file manually or through the {term}`q2cli` command line utilities (call `qiime tools`).

For manual specifications within your metadata file(s), comment directive line(s) must appear **directly** below the header.
The row's first cell must be `#q2:types` to indicate the row is a *comment directive*.
Subsequent cells may contain the values `categorical` or `numeric` (both case-insensitive).
The empty cell is also supported if you do not wish to assign a type to a column (the type will be inferred in that case).
Thus, it is easy to include this comment directive without having to declare types for every column in your metadata.

This functionality is now also supported directly through {term}`q2cli` by calling `qiime tools cast-metadata`.
This utility allows for bulk specifications to your metadata file(s) column types, set to either **categorical** or **numeric**.
This tool utilizes the aforementioned comment directive, but allows for inline data manipulation (or the ability to automate column type assignment through a custom script), which can be a more robust method than manual file manipulation.

````{margin}
```{tip}
The command `qiime metadata tabulate` can be used to review the column types of your QIIME 2 Metadata.
This works whether you're using the comment directive, type inference, or a combination of the two approaches.
```
````

## Number formatting

If a column is to be interpreted as a *numeric* metadata column (either through column type inference or by using the `#q2:types` comment directive), numbers in the column must be formatted following these rules:

- Use the decimal number system: ASCII characters `[0-9]`, `.` for an optional decimal point, and `+` and `-` for positive and negative signs, respectively.

  - Examples: `123`, `123.45`, `0123.40`, `-0.000123`, `+1.23`

- Scientific notation may be used with *E-notation*; both `e` and `E` are supported.

  - Examples: `1e9`, `1.23E-4`, `-1.2e-08`, `+4.5E+6`

- Only up to 15 digits **total** (including before and after the decimal point) are supported to stay within the 64-bit floating point specification.
  Numbers exceeding 15 total digits are unsupported and will result in undefined behavior.

- Common representations of *not a number* (e.g. `NaN`, `nan`) or infinity (e.g. `inf`, `-Infinity`) are **not supported**.
  Use an empty cell for missing data (e.g. instead of `NaN`). Infinity is not supported at this time in QIIME 2 metadata files.

(advanced-missing-metadata)=
## Advanced missing metadata value encoding

Missing metadata values may be encoded in one of the following schemes:

 1. `blank`: The default, which treats empty cells as the only valid missing values.
 2. `no-missing`: Indicates there are no missing values, and that any empty cells should be considered an error.
 If a scheme other than ‘blank’ is used by default, this scheme can be provided to preserve strings as categorical terms.
 3. `INSDC:missing`: [The INSDC vocabulary for missing values](https://www.insdc.org/technical-specifications/missing-value-reporting/).
  The current implementation supports only lower-case terms which match exactly: ‘not applicable’, ‘missing’, ‘not provided’, ‘not collected’, and ‘restricted access’.

The encoding used for each column can be specified on a per-column basis using the `#q2:missing` *comment directive*.
For manual specifications within your metadata file(s), comment directive line(s) must appear directly below the header.
The row’s first cell must be `#q2:missing` to indicate the row is a comment directive.
Subsequent cells may contain the values `blank`, `no-missing`, or `INSDC:missing` (all case-sensitive).
The empty cell is also supported if you do not wish to assign a missing value encoding to a column, in which case it will default to `blank`.

## Advanced metadata formatting

If you're creating TSV files manually (e.g. in a text editor) or writing your own software to consume or produce QIIME 2 metadata files this section provides additional formatting details.
If you're creating and exporting QIIME 2 metadata files using a spreadsheet program (e.g. Microsoft Excel, Google Sheets) you can skip this content.

### TSV dialect and parser

QIIME 2 attempts to interoperate with TSV files exported from Microsoft Excel, as this is the most common TSV "dialect" we have seen in use.
The QIIME 2 metadata parser (i.e. reader) uses the [Python csv module](https://docs.python.org/3/library/csv.html) `excel-tab` dialect for parsing TSV metadata files.
This dialect supports wrapping fields in double quote characters (`"`) to allow for tab, newline, and carriage return characters within a field. To include a literal double quote character in a field, the double quote character must be immediately preceded by another double quote character.
See the [Python csv module](https://docs.python.org/3/library/csv.html) for complete documentation on the `excel-tab` dialect.

### Encoding and line endings

Metadata files must be encoded as UTF-8, which is backwards-compatible with ASCII encoding.

Unix line endings (`\n`), Windows/DOS line endings (`\r\n`), and "classic Mac OS" line endings (`\r`) are all supported by the metadata parser for interoperability.
When metadata files are written to disk in QIIME 2, the line endings will always be `\r\n` (Windows/DOS line endings).

### Trailing empty cells and jagged data

The metadata parser ignores any trailing empty cells that occur past the fields declared by the header.
This is mainly for interoperability with files exported from some spreadsheet programs.
These trailing cells/columns may be jagged (or not); they will be ignored either way when the file is read.

If a row doesn't contain as many fields as declared by the header, empty cells will be padded to match the header length (again, this is mainly for interoperability with exported spreadsheets).


[^metadata-tsv-exception]: In addition to TSV files, some QIIME 2 Artifacts (i.e. `.qza` files) can also be used as metadata.
 See [](#view-artifacts-as-metadata) for details.
[^36-characters]: The length recommended here (36 characters or less) is designed to be as short as possible while still supporting version 4 UUIDs formatted with dashes.