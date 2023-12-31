PANDOC_VERSION:must_be_at_least '2.12'

local function pagebreak()
    if FORMAT == 'docx' then
        local pagebreak = '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
        return pandoc.RawBlock('openxml', pagebreak)
    elseif FORMAT:match 'html.*' then
        return pandoc.RawBlock('html', '<div style=""></div>')
    elseif FORMAT:match 'tex$' then
        return pandoc.RawBlock('tex', '\\clearpage')
    elseif FORMAT:match 'epub' then
        local pagebreak = '<p style="page-break-after: always;"> </p>'
        return pandoc.RawBlock('html', pagebreak)
    else
        -- fall back to insert a form feed character
        return pandoc.Para {pandoc.Str '\f'}
    end
end

local function pagebreakleft()
    if FORMAT:match 'tex$' then
        return pandoc.RawBlock('tex', '\\cleartoleftpage')
    else
        -- fall back to normal page break
        return pagebreak()
    end
end

function Div(div)
    if div.classes:includes('pagebreak') then
        div.content:extend({pagebreak()})
    end
    if div.classes:includes('pagebreakleft') then
        div.content:extend({pagebreakleft()})
    end
    return div
end

