--[[
This file is part of banias. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT. No part of banias, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of banias. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/raphaelcohn/banias/master/COPYRIGHT.
]]--

-- Compatibility must be XHTML5

-- http://www.w3.org/html/wg/drafts/html/master/dom.html#phrasing-content-2

-- Causes any missing function in the future to cause a warning; should be made into generic code (ie pre-pended)
setmetatable(_G, {
	__index = function(tableLookedUp, missingFunctionInModule)
		io.stderr:write(string.format("WARN: Missing required function '%s'\n", missingFunctionInModule))
		return function()
			return ''
		end
	end
})

-- Adds the table.concat, table.insert, etc methods to tableLiteral
local function tabelize(tableLiteral)
	setmetatable(tableLiteral, {__index = table})
	return tableLiteral
end


local alwaysEscapedCharacters = {}
alwaysEscapedCharacters['<'] = '&lt;'
alwaysEscapedCharacters['>'] = '&gt;'
alwaysEscapedCharacters['&'] = '&amp;'
alwaysEscapedCharacters = setmetatable(alwaysEscapedCharacters, {
		__index = function(_, matchedCharacter)
			return matchedCharacter
		end
	}
)

local function escapeRawText(rawText)
	return rawText:gsub('[<>&]', function(matchedCharacter)
		return alwaysEscapedCharacters[matchedCharacter]
	end)
end

local function attributes(attributesTable)
	
	local attributesArray = tabelize({})

	for attributeName, attributeValue in pairs(attributesTable) do
		
		-- There is no continue in Lua, a serious omission that makes fail-fast harder than it needs to be: https://stackoverflow.com/questions/3524970/why-does-lua-have-no-continue-statement
		-- Hence the double-negation test here, which I despise
		if attributeValue ~= nil and attributeValue ~= '' then
			
			local quotationMark = '"'
			local doubleQuotesPresent = false
			local singleQuotePresent = false
			
			local escapedAttributeValue = attributeValue:gsub('[<>&"\']', function(matchedCharacter)
				local result = alwaysEscapedCharacters[matchedCharacter]
				if result ~= matchedCharacter then
					return result
				end
				
				if matchedCharacter == '"' then
					quotationMark = "'"
					doubleQuotesPresent = true
				elseif matchedCharacter == '\'' then
					singleQuotePresent = true
				end
				
				return matchedCharacter
			end)

			local reEscapeBecauseBothDoubleAndSingleQuotesArePresent = doubleQuotesPresent and singleQuotePresent
			if reEscapeBecauseBothDoubleAndSingleQuotesArePresent then
				quotationMark = '"'
				
				escapedAttributeValue = attributeValue:gsub('[<>&"]', function(matchedCharacter)
					local result = alwaysEscapedCharacters[matchedCharacter]
					if result ~= matchedCharacter then
						return result
					end
					
					if matchedCharacter == '"' then
						-- We do not return '&quot;' as it is more verbose; we save a byte
						return '&#38;'
					else
						return matchedCharacter
					end
				end)
			
			end
			
			attributesArray:insert(' ' .. attributeName .. '=' .. quotationMark .. escapedAttributeValue .. quotationMark)
		end
	end
	
	return attributesArray:concat()
end

local function htmlElementNameWithAttributes(elementName, attributesTable)
	return elementName .. attributes(attributesTable)
end

local function htmlElementOpenTag(elementNameOrElementNameWithAttributes)
	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end

local function htmlElementCloseTag(elementNameOrElementNameWithAttributes)
	return '</' .. elementNameOrElementNameWithAttributes .. '>'
end

local function htmlElementEmptyTag(elementNameOrElementNameWithAttributes)
	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end

local function optionallyEmptyHtml(elementName, phrasingContent)
	if phrasingContent == '' then
		return htmlElementEmptyTag(elementName)
	end
	return htmlElementOpenTag(elementName) .. phrasingContent .. htmlElementCloseTag(elementName)
end

local function optionallyEmptyHtmlWithAttributes(elementName, phrasingContent, attributesTable)
	element = htmlElementNameWithAttributes(elementName, attributesTable)
	if phrasingContent == '' then
		return htmlElementEmptyTag(element)
	end
	return htmlElementOpenTag(element) .. phrasingContent .. htmlElementCloseTag(elementName)
end


-- This function is called once for the whole document. Parameters:
-- body is a string, metadata is a table, variables is a table.
-- This gives you a fragment.  You could use the metadata table to
-- fill variables in a custom lua template.  Or, pass `--template=...`
-- to pandoc, and pandoc will add do the template processing as
-- usual.

-- Table to store footnotes, so they can be included at the end.
local footnotes = tabelize({})
function Doc(body, metadata, variables)
	local buffer = tabelize({})
	
	local function add(content)
		buffer:insert(content)
	end
	
	add(body)
	
	-- TODO: Don't we always want to output this, as it may occupy space on the page (eg styled as a block)?
	if #footnotes > 0 then
		add(htmlElementOpenTag(htmlElementNameWithAttributes('ol', {class = 'footnotes'})))
		for _, footnote in pairs(footnotes) do
			add(footnote)
		end
		add(htmlElementCloseTag('ol'))
	end
	
	return buffer:concat()
end






function Blocksep()
	return ''
end

function Space()
	return ' '
end

function Plain(phrasingContent)
	return phrasingContent
end

function InlineMath(rawText)
	return '\\(' .. escapeRawText(rawText) .. '\\)'
end

function DisplayMath(rawText)
	return '\\[' .. escapeRawText(rawText) .. '\\]'
end

function Str(rawText)
	return escapeRawText(rawText)
end

function LineBreak()
	return htmlElementEmptyTag('br')
end

function Emph(phrasingContent)
	return optionallyEmptyHtml('em', phrasingContent)
end

function Strong(phrasingContent)
	return optionallyEmptyHtml('strong', phrasingContent)
end

function Subscript(phrasingContent)
	return optionallyEmptyHtml('sub', phrasingContent)
end

function Superscript(phrasingContent)
	return optionallyEmptyHtml('sup', phrasingContent)
end

function SmallCaps(phrasingContent)
	-- was style = 'font-variant:small-caps;'  but this is longer than class="smallcaps"
	return optionallyEmptyHtmlWithAttributes('span', phrasingContent, {class = 'smallcaps'})
end

function Strikeout(phrasingContent)
	return optionallyEmptyHtml('del', phrasingContent)
end

-- TODO: Check if title is smart-quoted
function Link(phrasingContent, url, title)
	return optionallyEmptyHtmlWithAttributes('a', phrasingContent, {url = url, title = title})
end

function Image(altText, url, titleWithoutSmartQuotes)
	-- TODO: this is where we can embed our size logic, eg using ImageMagick
	return optionallyEmptyHtmlWithAttributes('img', '', {url = url, title = titleWithoutSmartQuotes, alt = altText})
end

-- TODO: Check if attributesTable contains 'class=language-pascal', say - the correct way according to the W3C
function Code(rawCodeString, attributesTable)
	return optionallyEmptyHtmlWithAttributes('code', escapeRawText(rawCodeString), attributesTable)
end

function Span(phrasingContent, attributesTable)
	return optionallyEmptyHtmlWithAttributes('span', phrasingContent, attributesTable)
end

-- TODO: Optimise for empty p, h, blockquote, etc...
function Para(phrasingContent)
	return optionallyEmptyHtml('p', phrasingContent)
end

function Header(oneBasedLevelInteger, phrasingContent, attributesTable)
	return optionallyEmptyHtmlWithAttributes('h' .. oneBasedLevelInteger, phrasingContent, attributesTable)
end

function BlockQuote(phrasingContent)
	return optionallyEmptyHtml('blockquote', phrasingContent)
end

function HorizontalRule()
	return htmlElementEmptyTag('hr')
end

-- TODO: No use of <section>? Why?

function Div(content, attributesTable)
	return optionallyEmptyHtmlWithAttributes('div', content, attributesTable)
end

-- HTML Entity '&#8617;' replaced with UTF-8 encoding for efficiency
local unicodeLeftwardArrowWithHookInUtf8 = '\226\134\169'
local footnoteIdentifierPrefix = 'fn'
local footnoteReferenceIdentifierPrefix = footnoteIdentifierPrefix .. 'ref'
function Note(phrasingContent)
	local oneBasedFootnoteIndex = #footnotes + 1
	
	local footnoteIdentifier = footnoteIdentifierPrefix .. oneBasedFootnoteIndex
	local footnoteIdentifierHref = '#' .. footnoteIdentifier
	local footnoteReferenceIdentifier = footnoteReferenceIdentifierPrefix .. oneBasedFootnoteIndex
	local footnoteReferenceIdentifierHref = '#' .. footnoteReferenceIdentifierPrefix .. oneBasedFootnoteIndex
	
	local xxx = optionallyEmptyHtmlWithAttributes('a', unicodeLeftwardArrowWithHookInUtf8, {href = footnoteReferenceIdentifierHref})
	phrasingContentWithBackReferenceRightBeforeTheFinalClosingTag = phrasingContent:gsub('(.*)</', '%1 ' .. xxx .. '</')
	
	footnotes:insert(optionallyEmptyHtmlWithAttributes('li', phrasingContentWithBackReferenceRightBeforeTheFinalClosingTag, {id = footnoteIdentifier}))
	
	return optionallyEmptyHtmlWithAttributes('a', optionallyEmptyHtml('sup', oneBasedFootnoteIndex), {id = footnoteReferenceIdentifier, href = footnoteIdentifierHref})
end

function Cite(phrasingContent, citations)
	local identifiers = tablelize({})
  
	for _, citation in ipairs(citations) do
		identifiers:insert(citation.citationId)
	end
	
	local attributesTable = {
		class = 'cite'
	}
	attributesTable['data-citation-identifiers'] = identifiers:concat(',')
	
	return optionallyEmptyHtmlWithAttributes('span', phrasingContent, attributesTable)
end

local function htmlSimpleList(elementName, items)
	local buffer = tabelize({})
	for _, phrasingContent in pairs(items) do
		buffer:insert(optionallyEmptyHtml('li', phrasingContent))
	end
	return optionallyEmptyHtml(elementName, buffer:concat())
end

function BulletList(items)
	return htmlSimpleList('ul', items)
end

function OrderedList(items)
	return htmlSimpleList('ol', items)
end

-- TODO: Use <defn> tag to define a term in the <dt>, eg <dt><defn>hello</defn></dt><dd>A way to greet someone</dd></dt>
-- TODO: Tag ommission rules for dd / dt  http://www.w3.org/html/wg/drafts/html/master/semantics.html#the-dl-element
-- TODO: Multiple definition terms (<dt>) are not supported by pandoc
function DefinitionList(items)
	local buffer = tabelize({})
	
	local function add(content)
		buffer:insert(content)
	end
	
	for _, item in pairs(items) do
		for definitionTerm, definitions in pairs(item) do
			
			add(optionallyEmptyHtml('dt', definitionTerm))
			
			for _, definition in ipairs(definitions) do
				add(optionallyEmptyHtml('dd', definition))
			end
		end
	end
	return optionallyEmptyHtml('dl', buffer:concat(), {})
end

local function CodeBlock_default(rawCodeString, attributesTable)
	return optionallyEmptyHtml('pre', optionallyEmptyHtmlWithAttributes('code', escapeRawText(rawCodeString), attributesTable))
end



-- TODO: Sort out extensions / requires() syntax
-- TODO: Check in (sort out licensing)


-- Runs dot then base64 on 'rawCodeString' to produce a base64-encoded png in a data: URL
-- Added to retain compatibility with JGM
local function CodeBlock_extension_dot(rawCodeString, attributesTable)
	
	-- TODO: replace os.tmpname with io.tmpfile - http://www.lua.org/manual/5.2/manual.html#6.8 - but no way to get file name...
	local function pipe(programCommandStringWithEscapedData, inputBytes)
		local temporaryFileToWrite = os.tmpname()
		local tmph = io.open(temporaryFileToWrite, 'w')
		tmph:write(inputBytes)
		tmph:close()

		local outh = io.popen(programCommandStringWithEscapedData .. ' ' .. temporaryFileToWrite, 'r')
		local result = outh:read('*all')
		outh:close()

		os.remove(temporaryFileToWrite)
		return result
	end
	
    local base64EncondedPortalNetworkGraphicsImage = pipe('base64', pipe('dot -Tpng', rawCodeString))
	
	return optionallyEmptyHtmlWithAttributes('img', '', {src = 'data:image/png;base64,' .. base64EncondedPortalNetworkGraphicsImage})
end

function CodeBlock(rawCodeString, attributesTable)
	-- TODO: Change this logic to a look-up table or plug in pattern
	if attributesTable.class and string.match(' ' .. attributesTable.class .. ' ', ' dot ') then
		return CodeBlock_extension_dot(rawCodeString, attributesTable)
	else
		-- TODO: Support syntax highlighters (ideally, I feel these should run client-side, as they interfere with cut-and-paste code)
		return CodeBlock_default(rawCodeString, attributesTable)
	end
end











local defaultHtmlAlignment = 'left'
local pandocToHtmlAlignmentLookUp = setmetatable({
		AlignLeft = 'left',
		AlignRight = 'right',
		AlignCenter = 'center',
		AlignDefault = defaultHtmlAlignment
	}, {
		__index = function(tableLookedUp, missingKey)
			return defaultHtmlAlignment
		end
	}
)

function Table(caption, pandocAlignments, widths, headers, rows)
	
	local buffer = tabelize({})
	
	local function add(content)
		buffer:insert(content)
	end
	
	add(htmlElementOpenTag('table'))
  
	if caption ~= '' then
		add(optionallyEmptyHtml('caption', caption))
	end
	
	if widths and widths[1] ~= 0 then
    	for _, width in pairs(widths) do
			local percentageWidth = string.format('%d%%', width * 100)
			add(optionallyEmptyHtmlWithAttributes('col', '', {width = percentageWidth}))
		end
	end
	
	local headerRow = tabelize({})
	local isHeaderEmpty = true
	for columnIndex, headerCellPhrasedContent in pairs(headers) do
		local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
		headerRow:insert(optionallyEmptyHtmlWithAttributes('th', headerCellPhrasedContent, {align = align}))
		isHeaderEmpty = isHeaderEmpty and headerCellPhrasedContent == ''
	end
	if not isHeaderEmpty then
		add(htmlElementOpenTag(htmlElementNameWithAttributes('tr', {class = 'header'})))
		for _, thCell in pairs(headerRow) do
			add(thCell)
		end
		add(htmlElementCloseTag('tr'))
	end
	
	local class = 'even'
	for _, row in pairs(rows) do
		class = (class == 'even' and 'odd') or 'even'
		add(htmlElementOpenTag(htmlElementNameWithAttributes('tr', {class = 'class'})))
		for columnIndex, rowCellPhrasedContent in pairs(row) do
			local align = pandocToHtmlAlignmentLookUp[pandocAlignments[columnIndex]]
			add(optionallyEmptyHtmlWithAttributes('td', rowCellPhrasedContent, {align = align}))
		end
		add(htmlElementCloseTag('tr'))
	end
	
	add(htmlElementCloseTag('table'))
	
	return buffer:concat()
end
