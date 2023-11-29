PANDOC_VERSION:must_be_at_least '2.12'

-- This filter hides all content af divs with class .hide-on-print

function Div(div)
    -- Check if the div has a class named .hide-on-print
    if div.classes:includes('hide-on-print') then
        -- Return an empty table to remove the content
        return {}
    end
    return div
end
