PANDOC_VERSION:must_be_at_least '2.17'

local selected_tabs_variable = tostring(PANDOC_WRITER_OPTIONS.variables['selected-tabs']):gsub('"?([^"]+)"?', "%1")
local show_tab_headings_variable = tostring(PANDOC_WRITER_OPTIONS.variables['show-tab-headings']):gsub('"?([^"]+)"?',
    "%1")

local selected_tabs = pandoc.List:new({})
local show_tab_headings = false

if selected_tabs_variable and selected_tabs_variable ~= 'nil' and selected_tabs_variable ~= '""' and
    selected_tabs_variable ~= '' then
    for tab in string.gmatch(selected_tabs_variable, '[^:]+') do
        selected_tabs:insert(tab)
    end
end

if show_tab_headings_variable and show_tab_headings_variable ~= 'nil' then
    if (show_tab_headings_variable == 'true') then
        show_tab_headings = true
    end
else
    show_tab_headings = true
end

local last_headers = {}
local number_of_headers_in_div = 0

function Pandoc(doc)
    doc.blocks = pandoc.utils.make_sections(true, nil, doc.blocks)
    doc.blocks = doc.blocks:walk{
        traverse = 'topdown',
        Div = function(div)
            local remove_section = false
            number_of_headers_in_div = 0
            div.content = div.content:walk{
                traverse = 'topdown',
                Header = function(header)
                    if (number_of_headers_in_div > 0) then
                        remove_section = false
                        return header
                    end
                    number_of_headers_in_div = number_of_headers_in_div + 1
                    -- Search for Tabsets
                    -- Condition: Heading has class tabset
                    if (header.classes:includes('tabset')) then
                        last_headers[header.level] = header
                        -- Remove tabset heading
                        return {}
                        -- Search for Tabs
                        -- Condition: Heading is one level below a heading with class tabset
                    elseif (header.level > 0 and last_headers[header.level - 1] and
                        last_headers[header.level - 1].classes:includes('tabset')) then
                        -- Check if tab is in list of selected-tabs if not remove tab (section)
                        if (#selected_tabs > 0 and selected_tabs:includes(pandoc.utils.stringify(header.content)) ==
                            false) then
                            remove_section = true
                        end
                        -- If option show-tab-headings is set remove heading
                        if (not show_tab_headings) then
                            return {}
                        else
                            --  else show heading but increse level because we removed the tabset heading
                            header.level = header.level - 1
                            return header
                        end
                    end

                    last_headers[header.level] = header
                    return header
                end
            }

            if (remove_section) then
                return {}
            else
                return div
            end
        end
    }
    return doc

end

