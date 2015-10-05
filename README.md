# [banias]

[banias] is a simple MIT-licensed [shellfire] script to make it easy to create PDF and Word documents directly from markdown stored in Git. It's intended to be used as a git submodule. 

## Notes on Behaviour

* If there is a Pandoc extension [`pandoc_title_block`](http://pandoc.org/README.html#metadata-blocks) then the values of Author, Title and Date from this will take preference over those in a `.yaml` metadata section
* When concatentating markdown files, we insert a line feed between each file
* Only files ending `.md` are included
* The metadata `.yaml` file is included before any markdown

## TODO

* Explore figures
* Explore embedding images
* Templates
* Bibliography

[shellfire]: "https://github.com/shellfire-dev/shellfire" "shellfire homepage"
[banias-samples]: "https://github.com/raphaelcohn/banias-samples" "banias homepage"
