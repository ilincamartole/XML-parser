# XML Parser — Bash Shell Script

A lightweight, interactive XML parser implemented entirely in **Bash**, developed as a group project for the *Instrumente și Tehnici de Bază în Informatică* course at the University of Bucharest as part of a 3 people team.

---

## Overview

This project provides a portable, dependency-free solution for reading and manipulating XML files directly from the command line. It uses only standard UNIX/Linux utilities (`grep`, `awk`, `sed`, `mktemp`) and requires no external tools or libraries.

The script presents the user with an interactive menu and supports two modes of operation:
- **XML data structure processing** — reading tags and elements, creating new XML files, and adding elements to existing ones.
- **Application data processing** — extracting tag values and attributes from XML content (e.g. application metadata).

---

## Requirements

- Bash shell
- Standard UNIX/Linux utilities: `grep`, `awk`, `sed`, `mktemp`, `cat`
- No additional software or libraries required

Tested on **Ubuntu** and **Debian**. Compatible with most Linux/Unix distributions. Minor adjustments may be needed on macOS.

---

## Usage
```bash
# Make the script executable
chmod +x xml_parser.sh

# Run it
./xml_parser.sh
```

On launch, the script displays the main menu asking which type of data you want to parse. From there, you navigate through numbered submenus to perform operations.

---

## Menu Structure
```
Main Menu
├── 1. XML Data Structure Processing
│   ├── 1. Read a tag          → reads all values of a given tag
│   ├── 2. Read an element     → reads the full content of a specific element
│   ├── 3. Create a new XML file
│   ├── 4. Add an element to an existing XML file
│   └── 5. Exit
└── 2. Application Data Processing
    ├── Extract a tag value
    └── Extract an attribute value
```

After each operation, the user is asked whether they want to return to the menu or exit.

---

## Functions

### XML Data Structure Processing

#### `read_tag(file, tag)`
Reads and prints all values found between `<tag>` and `</tag>` in the given file.

Uses `grep` with a Perl-compatible regex (`-oP`) to match content between opening and closing tags.

#### `read_element(file, main_tag, attribute_tag, value)`
Reads the full content of a specific element, identified by a child tag and its value.

Uses `awk` to scan the file line by line, buffering content between `<main_tag>` and `</main_tag>` and printing only the matching element. Leading/trailing whitespace is stripped with `gsub`.

#### `add_file(file)`
Creates a new, valid XML file with a minimal `<root>` structure and a UTF-8 declaration.

Uses `cat <<EOF` to write a valid XML template. Outputs a confirmation message on success.

#### `add_element(file, element_tag, attribute_tag, content)`
Adds a new element to an existing XML file, inserted just before the closing root tag.

Detects the root tag automatically using `grep`, then uses `awk` to insert the new element before `</root_tag>`. A temporary file (`mktemp`) is used to avoid overwriting the original during processing.

### Application Data Processing

#### `extract_tag(xml_content, tag)`
Extracts the value of a given tag from an XML string. Uses `grep -oP` to match the tag and `sed` to strip the delimiters.

#### `extract_attribute(xml_content, tag, attribute)`
Extracts the value of a specific attribute from a given tag. Uses `grep` to locate the tag and `sed` to isolate the attribute value from the surrounding markup.

---

## Known Limitations

- **No XML validation** — the script assumes input files are well-formed XML.
- **Single-line tags only** — `read_tag` works best when tag content is on a single line.
- **Performance on large files** — sequential processing with `grep`/`awk`/`sed` may be slow for files larger than a few MB.
- **No delete functionality** — removing tags or attributes is not currently supported.
- **No namespace support** — XML namespaces and complex schemas are not handled.

---

## Performance

| Operation | Small file | Medium (~2 MB) |
|---|---|---|
| Read a tag | < 10 ms | Increases linearly |
| Create a new file | Instant | Instant |
| Add an element | ~50 ms | ~50 ms |
| Extract attribute | < 10 ms | Increases linearly |

---

## Possible Future Improvements

- **Delete functionality** — remove specific tags or attributes from XML files.
- **XSD/DTD validation** — validate XML structure before processing.
- **Performance optimization** — integrate `xmlstarlet` or `libxml2` for large files.
- **Application data menu** — complete the implementation of menu option 2.

---

| Academic year | 2024–2025 |
| Team name | Spice Girls |
| Members | Marțole Ilinca-Maria, Pleșca Erika-Maria, Vîrghileanu Maria-Roberta |
