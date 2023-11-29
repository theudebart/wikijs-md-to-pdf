PANDOC_VERSION:must_be_at_least '2.12'

function BlockQuote(quote)
    local class = nil

    -- For some reson pandoc converts LineBreaks in quotes to SoftBreaks
    -- Fix by replacing SoftBreaks with LineBreaks
    quote.content = quote.content:walk{
        SoftBreak = function(softBreak)
            return pandoc.LineBreak()
        end
    }

    -- BlockQuotes can not have attributes so we need to identfiy them, turn the BlockQuote into a Div and apply the attributes

    -- Extract the attributes and remove them from the content
    attributes_string = pandoc.utils.stringify(quote):match('{([^{}]+)}%s*$')
    attributes = nil
    if (attributes_string) then
        attributes = pandoc.Attr(nil, pandoc.List:new({}), nil)
        for class in attributes_string:gmatch('%s*%.([^%.%s]*)') do
            attributes.classes:insert(class)
        end
        for identifier in attributes_string:gmatch('%s*#([^#%s]*)') do
            attributes.identifier = identifier
        end

        traverse_to_paragraph_or_plain = function(content, callback)
            if (content.tag == 'Para' or content.tag == 'Plain') then
                callback(content)
            else
                for index, element in ipairs(content.content) do
                    if (pandoc.utils.stringify(element):match('{([^{}]+)}%s*$')) then
                        traverse_to_paragraph_or_plain(element, callback)
                    end
                end
            end
        end
        remove_attributes = function(elements)
            -- Search for position of last occurance of opening curly bracket
            local last_opening_bracket = pandoc.utils.stringify(elements):find('%s*{[^{]*$')
            local cursor = 0
            local remove_indices = pandoc.List:new({})
            for index, element in ipairs(elements.content) do
                string = pandoc.utils.stringify(element)
                if cursor >= last_opening_bracket then
                    remove_indices:insert(index)
                elseif cursor <= last_opening_bracket and (cursor + string:len()) >= last_opening_bracket then
                    if (element.tag and element.tag == 'Str') then
                        element.text = string:sub(1, last_opening_bracket - cursor - 1)
                    elseif (element.tag and
                        (element.tag == 'Space' or element.tag == 'LineBreak' or element.tag == 'SoftBreak')) then
                        remove_indices:insert(index)
                    end
                end
                cursor = cursor + string:len()
            end
            remove_indices:sort(function(a, b)
                return a > b
            end)
            remove_indices:map(function(index)
                table.remove(elements.content, index)
            end)

        end
        traverse_to_paragraph_or_plain(quote, remove_attributes)
    end

    -- If the BlockQuote has attributes, convert the BlockQuote into a Div with the attributes
    if (attributes) then
        -- Turn the BlockQuote into a Div
        quote = pandoc.Div(quote.content, attributes)
        -- Add the BlockQuote environment to the LaTeX Output
        if FORMAT:match 'tex$' then
            if (attributes.classes:includes('is-info')) then
                table.insert(quote.content, 1, pandoc.RawBlock("latex", "\\begin{blockquote-info}"))
                table.insert(quote.content, pandoc.RawBlock("latex", "\\end{blockquote-info}"))
            elseif (attributes.classes:includes('is-success')) then
                table.insert(quote.content, 1, pandoc.RawBlock("latex", "\\begin{blockquote-success}"))
                table.insert(quote.content, pandoc.RawBlock("latex", "\\end{blockquote-success}"))
            elseif (attributes.classes:includes('is-warning')) then
                table.insert(quote.content, 1, pandoc.RawBlock("latex", "\\begin{blockquote-warning}"))
                table.insert(quote.content, pandoc.RawBlock("latex", "\\end{blockquote-warning}"))
            elseif (attributes.classes:includes('is-danger')) then
                table.insert(quote.content, 1, pandoc.RawBlock("latex", "\\begin{blockquote-danger}"))
                table.insert(quote.content, pandoc.RawBlock("latex", "\\end{blockquote-danger}"))
            else
                table.insert(quote.content, 1, pandoc.RawBlock("latex", "\\begin{blockquote-default}"))
                table.insert(quote.content, pandoc.RawBlock("latex", "\\end{blockquote-default}"))
            end
        end
    end

    return quote
end
