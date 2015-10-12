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
  * <http://www.docverter.com/api#Conversions>
* Add in `---` before and after YAML documents in case it's missing
  * Could use the `file` command to detect YAML
* Yaml Metadata
  * Explore a folder-based approach (like conf.d) to allow re-use of snippets
  * Do this at a reports level, too
  * Explore using `pandoc-options: -VstandardWaiver=$(cat include/standardWaiver.md)` (see https://groups.google.com/forum/#!topic/pandoc-discuss/pe63zLmNwtk) 
* Templates
  * Re-use the pandoc data-dir approach (overriding the user data dir or merging the pandoc directories together)
* Pre-Processing
  * Generation of images (eg stormmq logo from vector graphics)
* Images
  * What about when using HTML? Can we differentiate between embedded and re-used?
* Formatting
  * Nice borders for figures in PDFs (but not inline images, perhaps)
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
* Review:-
  * Filter support: <https://github.com/jgm/pandoc/wiki/Pandoc-Filters>
  * `curl -LH "Accept: text/bibliography; style=bibtex" "http://dx.doi.org/10.1017/S0022112061000019"` citations!
  * <https://github.com/jgm/pandoc/issues/813>

[shellfire]: "https://github.com/shellfire-dev/shellfire" "shellfire homepage"
[banias]: "https://github.com/raphaelcohn/banias" "banias homepage"
[pandoc]: "http://pandoc.org" "pandoc homepage"
