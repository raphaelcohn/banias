--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--


local tabelize = require('halimede.tabelize').tabelize

local xml = require('xml')
local escapeRawText = xml.escapeRawText
local attributes = xml.attributes
local xmlElementNameWithAttributes = xml.xmlElementNameWithAttributes
local xmlElementOpenTag = xml.xmlElementOpenTag
local xmlElementCloseTag = xml.xmlElementCloseTag
local xmlElementEmptyTag = xml.xmlElementEmptyTag
local potentiallyEmptyXml = xml.potentiallyEmptyXml
local potentiallyEmptyXmlWithAttributes = xml.potentiallyEmptyXmlWithAttributes

local assert = require('halimede.assert')

-- Inline LuaRocks  http://lua-users.org/wiki/InlineCee
-- Pandoc uses Lua, not LuaJIT, and uses Lua 5.1 (irritatingly)
-- Compatibility must be XHTML5
-- http://www.w3.org/html/wg/drafts/html/master/dom.html#phrasing-content-2

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

-- TODO: Omit quotes if no spaces at all in attributes?

-- Table to store footnotes, so they can be included at the end.
local footnotes = tabelize()
--TODO: Add meta author, dcterms.date to ?metadata?
--TODO: Missing <title></title>!
function Doc(body, metadata, variables)

	assert.parameterIsString(body)
	assert.parameterIsTable(metadata)
	assert.parameterIsTable(variables)
	
	local buffer = tabelize()
	
	local function add(content)
		buffer:insert(content)
	end
	
	add(body)
	
	-- TODO: Don't we always want to output this, as it may occupy space on the page (eg styled as a block)?
	if #footnotes > 0 then
		add(xmlElementOpenTag(xmlElementNameWithAttributes('ol', {class = 'footnotes'})))
		for _, footnote in pairs(footnotes) do
			add(footnote)
		end
		add(xmlElementCloseTag('ol'))
	end
	
	return buffer:concat()
end

function Plain(phrasingContent)
	return phrasingContent
end

-- CaptionedImage() supplied by Image()
requireChild('Image')

function Para(phrasingContent)
	assert.parameterIsString(phrasingContent)
	
	return potentiallyEmptyXml('p', phrasingContent)
end

function RawBlock(format, content)
	assert.parameterIsString(format)
	assert.parameterIsString(content)
	
	if format == 'html' then
		return content
	else
		return potentiallyEmptyXml('pre', escapeRawText(content))
	end
end

function HorizontalRule()
	return xmlElementEmptyTag('hr')
end

function Header(oneBasedLevelInteger, phrasingContent, attributesTable)
	assert.parameterIsNumber(oneBasedLevelInteger)
	assert.parameterIsString(phrasingContent)
	assert.parameterIsTable(attributesTable)
	
	return potentiallyEmptyXmlWithAttributes('h' .. oneBasedLevelInteger, phrasingContent, attributesTable)
end

local codeblocks = requireChild('codeblocks')
local functions = codeblocks.functions

function CodeBlock(rawCodeString, attributesTable)
	assert.parameterIsString(rawCodeString)
	assert.parameterIsTable(attributesTable)
	
	local class = attributesTable.class
	if class then
		return functions[class](rawCodeString, attributesTable)
	else
		return codeblocks.default(rawCodeString, attributesTable)
	end
end

function BlockQuote(phrasingContent)
	assert.parameterIsString(phrasingContent)
	
	return potentiallyEmptyXml('blockquote', phrasingContent)
end

requireChild('Table')

requireChild('BulletListAndOrderedList')

-- TODO: Use <defn> tag to define a term in the <dt>, eg <dt><defn>hello</defn></dt><dd>A way to greet someone</dd></dt>
-- TODO: Tag ommission rules for dd / dt  http://www.w3.org/html/wg/drafts/html/master/semantics.html#the-dl-element
function DefinitionList(items)
	assert.parameterIsTable(items)
	
	local buffer = tabelize()
	
	local function add(content)
		buffer:insert(content)
	end
	
	for _, item in pairs(items) do
		assert.parameterIsTable(item)
	
		for definitionTerm, definitions in pairs(item) do
			assert.parameterIsString(definitionTerm)
			assert.parameterIsTable(definitions)
			
			add(potentiallyEmptyXml('dt', definitionTerm))
			
			for _, definition in ipairs(definitions) do
				add(potentiallyEmptyXml('dd', definition))
			end
		end
	end
	return potentiallyEmptyXml('dl', buffer:concat(), {})
end

-- TODO: No use of <section>? Why?
function Div(content, attributesTable)
	assert.parameterIsString(content)
	assert.parameterIsTable(attributesTable)
	
	return potentiallyEmptyXmlWithAttributes('div', content, attributesTable)
end

function Blocksep()
	return ''
end

function Str(rawText)
	assert.parameterIsString(rawText)
	return escapeRawText(rawText)
end

function Space()
	return ' '
end

function Emph(phrasingContent)
	assert.parameterIsString(phrasingContent)
	return potentiallyEmptyXml('em', phrasingContent)
end

function Strong(phrasingContent)
	assert.parameterIsString(phrasingContent)
	return potentiallyEmptyXml('strong', phrasingContent)
end

function Strikeout(phrasingContent)
	assert.parameterIsString(phrasingContent)
	return potentiallyEmptyXml('del', phrasingContent)
end

function Subscript(phrasingContent)
	assert.parameterIsString(phrasingContent)
	return potentiallyEmptyXml('sub', phrasingContent)
end

function Superscript(phrasingContent)
	assert.parameterIsString(phrasingContent)
	return potentiallyEmptyXml('sup', phrasingContent)
end

function SmallCaps(phrasingContent)
	assert.parameterIsString(phrasingContent)
	-- was style = 'font-variant: small-caps;'  but this is longer than class="smallcaps"
	return potentiallyEmptyXmlWithAttributes('span', phrasingContent, {class = 'smallcaps'})
end

local singleOpeningQuoteUtf8 = '\226\128\152' -- LEFT SINGLE QUOTATION MARK, Unicode: U+2018, UTF-8: E2 80 98
local singleClosingQuoteUtf8 = '\226\128\153' -- RIGHT SINGLE QUOTATION MARK, Unicode: U+2019, UTF-8: E2 80 99
function SingleQuoted(phrasingContent)
	assert.parameterIsString(phrasingContent)
	return singleOpeningQuoteUtf8 .. phrasingContent .. singleClosingQuote
end

local doubleOpeningQuoteUtf8 = '\226\128\156' -- LEFT DOUBLE QUOTATION MARK, Unicode: U+201C, UTF-8: E2 80 9C
local doubleClosingQuoteUtf8 = '\226\128\157' -- RIGHT DOUBLE QUOTATION MARK, Unicode: U+201D, UTF-8: E2 80 9D
function DoubleQuoted(phrasingContent)
	assert.parameterIsString(phrasingContent)
	return doubleOpeningQuoteUtf8 .. phrasingContent .. doubleClosingQuote
end

function Cite(phrasingContent, citations)
	assert.parameterIsString(phrasingContent)
	assert.parameterIsTable(citations)
	
	local identifiers = tablelize()
	
	-- Also .citationPrefix, .citationSuffix, .citationMode, .citationNoteNum, .citationHash
	for _, citation in ipairs(citations) do
		assert.parameterIsTable(citation)
		identifiers:insert(citation.citationId)
	end
	
	local attributesTable = {
		class = 'cite'
	}
	attributesTable['data-citation-identifiers'] = identifiers:concat(',')
	
	return potentiallyEmptyXmlWithAttributes('span', phrasingContent, attributesTable)
end

function Code(rawCodeString, attributesTable)
	assert.parameterIsString(rawCodeString)
	assert.parameterIsTable(attributesTable)
	return potentiallyEmptyXmlWithAttributes('code', escapeRawText(rawCodeString), attributesTable)
end

function DisplayMath(rawText)
	assert.parameterIsString(rawText)
	return '\\[' .. escapeRawText(rawText) .. '\\]'
end

function InlineMath(rawText)
	assert.parameterIsString(rawText)
	return '\\(' .. escapeRawText(rawText) .. '\\)'
end

function RawInline(format, content)
	assert.parameterIsString(format)
	assert.parameterIsString(content)
	
	if format == 'html' then
		return content
	else
		return potentiallyEmptyXml('code', escapeRawText(content))
	end
end

function LineBreak()
	return xmlElementEmptyTag('br')
end

function Link(phrasingContent, url, title)
	assert.parameterIsString(phrasingContent)
	assert.parameterIsString(url)
	assert.parameterIsString(title)
	
	return potentiallyEmptyXmlWithAttributes('a', phrasingContent, {url = url, title = title})
end

requireChild('Image')

-- HTML Entity '&#8617;' replaced with UTF-8 encoding for efficiency
local unicodeLeftwardArrowWithHookInUtf8 = '\226\134\169'
local footnoteIdentifierPrefix = 'fn'
local footnoteReferenceIdentifierPrefix = footnoteIdentifierPrefix .. 'ref'
function Note(phrasingContent)
	assert.parameterIsString(phrasingContent)
	
	local oneBasedFootnoteIndex = #footnotes + 1
	
	local footnoteIdentifier = footnoteIdentifierPrefix .. oneBasedFootnoteIndex
	local footnoteIdentifierHref = '#' .. footnoteIdentifier
	local footnoteReferenceIdentifier = footnoteReferenceIdentifierPrefix .. oneBasedFootnoteIndex
	local footnoteReferenceIdentifierHref = '#' .. footnoteReferenceIdentifierPrefix .. oneBasedFootnoteIndex
	
	local xxx = potentiallyEmptyXmlWithAttributes('a', unicodeLeftwardArrowWithHookInUtf8, {href = footnoteReferenceIdentifierHref})
	phrasingContentWithBackReferenceRightBeforeTheFinalClosingTag = phrasingContent:gsub('(.*)</', '%1 ' .. xxx .. '</')
	
	footnotes:insert(potentiallyEmptyXmlWithAttributes('li', phrasingContentWithBackReferenceRightBeforeTheFinalClosingTag, {id = footnoteIdentifier}))
	
	return potentiallyEmptyXmlWithAttributes('a', potentiallyEmptyXml('sup', oneBasedFootnoteIndex), {id = footnoteReferenceIdentifier, href = footnoteIdentifierHref})
end

function Span(phrasingContent, attributesTable)
	assert.parameterIsString(phrasingContent)
	assert.parameterIsTable(attributesTable)
	
	return potentiallyEmptyXmlWithAttributes('span', phrasingContent, attributesTable)
end

return module