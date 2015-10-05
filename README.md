# [banias]

[banias] is a simple MIT-licensed [shellfire] script wrapping [pandoc] to make it easy to create PDF and Latex documents directly from markdown stored in Git. It's intended to be used as a git submodule. 

## Notes on Behaviour

* If there is a Pandoc extension [`pandoc_title_block`](http://pandoc.org/README.html#metadata-blocks) then the values of Author, Title and Date from this will take preference over those in a `REPORT.yaml` metadata section
* When concatentating markdown files, we insert a line feed between each file
* If there is a file called `REPORT.FORMAT.yaml`, then this will be concatenated before `REPORT.yaml`
  * This allows one to have format-specific settings and overrides
* Only files ending `.md` are included
* The metadata `.yaml` files are included before any markdown

## Hints

* [banias] is designed so that most of what you want can be achieved using symlinks.
  * Use symlinks to re-use template fragements that are common to only a subset of documents
  * Use folder symlinks to share common sets of templates
  * Use symlinks to re-use per-report YAML metadata
* Settings for PDF and Latex documents are frequently the same. Use a symlink from `REPORT.latex.yaml` to `REPORT.pdf.yaml` to keep these in-sync

## TODO

* Pandoc-as-a-service (solves a lot of deployment issues)
* Add in `---` before and after YAML documents in case it's missing
* Yaml Metadata
  * Explore a folder-based approach (like conf.d) to allow re-use of snippets
  * Do this at a reports level, too
* Templates
  * Re-use the pandoc data-dir approach (overriding the user data dir or merging the pandoc directories together)
* Bibliography
* Embed revision history, authors from git
* Explore default yaml for documents
  * Default the 'lang' to english (en)
  * Default the date from git revision
  * Likewise, default the author [this is first author, not last author]
  * ?default title to something obviously wrong?
  * Could have default-per-format, too
  * Consider generating 'lot: true' and 'lof: true' by detecting presence of tables with captions and figures
* More formats
  * latex-snippet
  * html-snippet
  * html
* Explore: Unlike [pandoc], [banias] has separate templates for PDFs and Latex; this is because they differ in needs

[shellfire]: "https://github.com/shellfire-dev/shellfire" "shellfire homepage"
[banias]: "https://github.com/raphaelcohn/banias" "banias homepage"
[pandoc]: "http://pandoc.org" "pandoc homepage"
