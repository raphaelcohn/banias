--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local tabelize = require('halimede.tabelize').tabelize

local Html5Writer = require('markuplanguagewriter.Html5Writer')
local writeText = Html5Writer.writeText
local writeElementNameWithAttributes = Html5Writer.writeElementNameWithAttributes
local writeElementOpenTag = Html5Writer.writeElementOpenTag
local writeElementEmptyTag = Html5Writer.writeElementEmptyTag
local writeElementCloseTag = Html5Writer.writeElementCloseTag
local writeElement = Html5Writer.writeElement

local assert = require('halimede.assert')

--[[TODO:
* Header Numbering (class header-section-number)
* Ordered List Delimiters
* MathML et al (https://github.com/jgm/pandoc/blob/34d53aff6e0237c4934024a413a5b722666cc487/src/Text/Pandoc/Writers/HTML.hs) line 720
* Quoting works, but we ignore HTML <q> tags as the alternative
]]

--[[
Required styles:-
	span.smallcaps
	{
		font-variant:small-caps;
	}
	
	tr.header
	{
		...
	}
	
	tr.even
	{
		...
	}

	tr.odd
	{
		...
	}
	
	th.align.left, td.align.left
	{
		...
	}
	
	th.align.right, td.align.right
	{
		...
	}
	
	th.align.center, td.align.center
	{
		...
	}
]]--

--[[

	pngcrush:
	optipng: Crush the life out of PNGs
	
	png2ico: Create ICOs from pngs
	svg2png: Create PNGs from SVG (so could go SVG -> ICO)
	git2png: Convert GIF to PNG
	tiff2png: Convert TIFF to PNG

	pngquant:
	pngnq:    Quantise PNGs (ie go from 24-bit colour to 8-bit colour)

	pngcheck: Check CRCs, etc but also get dimensions, extract text annotations, etc

	jpeginfo:
	
	jpegoptim: Optimisers
	mozjpeg:

	jpegrescan:

]]--

-- Table to store footnotes, so they can be included at the end.
local footnotes = tabelize()
--TODO: Add meta author, dcterms.date to ?metadata?
--TODO: Missing <title></title>!
function Doc(body, metadata, variables)
	assert.parameterTypeIsString(body)
	assert.parameterTypeIsTable(metadata)
	assert.parameterTypeIsTable(variables)
	
	local buffer = tabelize()
	
	local function add(content)
		buffer:insert(content)
	end
	
	add(body)
	
	-- TODO: Don't we always want to output this, as it may occupy space on the page (eg styled as a block)?
	if #footnotes > 0 then
		add(writeElementOpenTag(writeElementNameWithAttributes('ol', {class = 'footnotes'})))
		for _, footnote in pairs(footnotes) do
			add(footnote)
		end
		add(writeElementCloseTag('ol'))
	end
	
	return buffer:concat()
end

function Plain(phrasingContent)
	return phrasingContent
end

-- CaptionedImage() supplied by Image()
requireChild('Image')

function Para(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return writeElement('p', phrasingContent)
end

function RawBlock(format, content)
	assert.parameterTypeIsString(format)
	assert.parameterTypeIsString(content)
	
	if format == 'html' then
		return content
	else
		-- Just drop the output; Pandoc only supports MathJax in RawBlock
		return ''
		--return writeElement('pre', writeText(content))
	end
end

function HorizontalRule()
	return writeElementEmptyTag('hr')
end

function Header(oneBasedLevelInteger, phrasingContent, attributesTable)
	assert.parameterTypeIsNumber(oneBasedLevelInteger)
	assert.parameterTypeIsString(phrasingContent)
	assert.parameterTypeIsTable(attributesTable)
	
	return writeElement('h' .. oneBasedLevelInteger, phrasingContent, attributesTable)
end

local codeblocks = requireChild('codeblocks')
local functions = codeblocks.functions

function CodeBlock(rawCodeString, attributesTable)
	assert.parameterTypeIsString(rawCodeString)
	assert.parameterTypeIsTable(attributesTable)
	
	local class = attributesTable.class
	if class then
		return functions[class](rawCodeString, attributesTable)
	else
		return codeblocks.default(rawCodeString, attributesTable)
	end
end

function BlockQuote(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return writeElement('blockquote', phrasingContent)
end

requireChild('Table')

requireChild('BulletListAndOrderedList')

-- TODO: Use <defn> tag to define a term in the <dt>, eg <dt><defn>hello</defn></dt><dd>A way to greet someone</dd></dt>
-- TODO: Tag ommission rules for dd / dt  http://www.w3.org/html/wg/drafts/html/master/semantics.html#the-dl-element
function DefinitionList(items)
	assert.parameterTypeIsTable(items)
	
	local buffer = tabelize()
	
	local function add(content)
		buffer:insert(content)
	end
	
	for _, item in pairs(items) do
		assert.parameterTypeIsTable(item)
	
		for definitionTerm, definitions in pairs(item) do
			assert.parameterTypeIsString(definitionTerm)
			assert.parameterTypeIsTable(definitions)
			
			add(writeElement('dt', definitionTerm))
			
			for _, definition in ipairs(definitions) do
				add(writeElement('dd', definition))
			end
		end
	end
	return writeElement('dl', buffer:concat(), {})
end

-- TODO: No use of <section>? Why?
function Div(content, attributesTable)
	assert.parameterTypeIsString(content)
	assert.parameterTypeIsTable(attributesTable)
	
	return writeElement('div', content, attributesTable)
end

function Blocksep()
	return ''
end

function Str(rawText)
	assert.parameterTypeIsString(rawText)
	
	return writeText(rawText)
end

function Space()
	return ' '
end

function Emph(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return writeElement('em', phrasingContent)
end

function Strong(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return writeElement('strong', phrasingContent)
end

function Strikeout(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return writeElement('del', phrasingContent)
end

function Subscript(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return writeElement('sub', phrasingContent)
end

function Superscript(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return writeElement('sup', phrasingContent)
end

function SmallCaps(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	-- was style = 'font-variant: small-caps;'  but this is longer than class="smallcaps"
	return writeElement('span', phrasingContent, {class = 'smallcaps'})
end

local singleOpeningQuoteUtf8 = '\226\128\152' -- LEFT SINGLE QUOTATION MARK, Unicode: U+2018, UTF-8: E2 80 98
local singleClosingQuoteUtf8 = '\226\128\153' -- RIGHT SINGLE QUOTATION MARK, Unicode: U+2019, UTF-8: E2 80 99
function SingleQuoted(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return singleOpeningQuoteUtf8 .. phrasingContent .. singleClosingQuote
end

local doubleOpeningQuoteUtf8 = '\226\128\156' -- LEFT DOUBLE QUOTATION MARK, Unicode: U+201C, UTF-8: E2 80 9C
local doubleClosingQuoteUtf8 = '\226\128\157' -- RIGHT DOUBLE QUOTATION MARK, Unicode: U+201D, UTF-8: E2 80 9D
function DoubleQuoted(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	return doubleOpeningQuoteUtf8 .. phrasingContent .. doubleClosingQuote
end

function Cite(phrasingContent, citations)
	assert.parameterTypeIsString(phrasingContent)
	assert.parameterTypeIsTable(citations)
	
	local identifiers = tablelize()
	
	-- Also .citationPrefix, .citationSuffix, .citationMode, .citationNoteNum, .citationHash
	for _, citation in ipairs(citations) do
		assert.parameterTypeIsTable(citation)
		identifiers:insert(citation.citationId)
	end
	
	local attributesTable = {
		class = 'cite'
	}
	attributesTable['data-citation-identifiers'] = identifiers:concat(',')
	
	return writeElement('span', phrasingContent, attributesTable)
end

function Code(rawCodeString, attributesTable)
	assert.parameterTypeIsString(rawCodeString)
	assert.parameterTypeIsTable(attributesTable)
	
	return writeElement('code', writeText(rawCodeString), attributesTable)
end

function DisplayMath(rawText)
	assert.parameterTypeIsString(rawText)
	
	return '\\[' .. writeText(rawText) .. '\\]'
end

function InlineMath(rawText)
	assert.parameterTypeIsString(rawText)
	
	return '\\(' .. writeText(rawText) .. '\\)'
end

function RawInline(format, content)
	assert.parameterTypeIsString(format)
	assert.parameterTypeIsString(content)
	
	if format == 'html' then
		return content
	else
		-- Could be latex, Pandoc here only supports LaTeXMathML and MathJax
		-- Commenting is dangerous; -- needs removing, as does ]]> and they still exist as nodes, so we simply silently drop them from output
		return ''
		--return writeElement('code', writeText(content))
	end
end

function LineBreak()
	return writeElementEmptyTag('br')
end

function Link(phrasingContent, url, title)
	assert.parameterTypeIsString(phrasingContent)
	assert.parameterTypeIsString(url)
	assert.parameterTypeIsString(title)
	
	return writeElement('a', phrasingContent, {url = url, title = title})
end

requireChild('Image')

-- HTML Entity '&#8617;' replaced with UTF-8 encoding for efficiency
local unicodeLeftwardArrowWithHookInUtf8 = '\226\134\169'
local footnoteIdentifierPrefix = 'fn'
local footnoteReferenceIdentifierPrefix = footnoteIdentifierPrefix .. 'ref'
function Note(phrasingContent)
	assert.parameterTypeIsString(phrasingContent)
	
	local oneBasedFootnoteIndex = #footnotes + 1
	
	local footnoteIdentifier = footnoteIdentifierPrefix .. oneBasedFootnoteIndex
	local footnoteIdentifierHref = '#' .. footnoteIdentifier
	local footnoteReferenceIdentifier = footnoteReferenceIdentifierPrefix .. oneBasedFootnoteIndex
	local footnoteReferenceIdentifierHref = '#' .. footnoteReferenceIdentifierPrefix .. oneBasedFootnoteIndex
	
	local xxx = writeElement('a', unicodeLeftwardArrowWithHookInUtf8, {href = footnoteReferenceIdentifierHref})
	phrasingContentWithBackReferenceRightBeforeTheFinalClosingTag = phrasingContent:gsub('(.*)</', '%1 ' .. xxx .. '</')
	
	footnotes:insert(writeElement('li', phrasingContentWithBackReferenceRightBeforeTheFinalClosingTag, {id = footnoteIdentifier}))
	
	local sup = writeElement('sup', '' .. oneBasedFootnoteIndex)
	return writeElement('a', sup, {id = footnoteReferenceIdentifier, href = footnoteIdentifierHref})
end

function Span(phrasingContent, attributesTable)
	assert.parameterTypeIsString(phrasingContent)
	assert.parameterTypeIsTable(attributesTable)
	
	return writeElement('span', phrasingContent, attributesTable)
end
