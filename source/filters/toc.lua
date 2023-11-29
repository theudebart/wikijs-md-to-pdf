PANDOC_VERSION:must_be_at_least '2.12'
traverse = 'topdown'

local path = require 'pandoc.path'

-- This filter hides headers with the class .unlisted and all children headers from the table of contents (TOC)
-- Additonally .unlisted-children will hide all children headers but not the parent header

function UnlistedHeader(header)
    if FORMAT:match 'tex$' then
        -- If the output format is 'tex', add raw blocks to disable the addcontentsline command around the header
        return {pandoc.RawInline('tex', '\\bgroup\\let\\addcontentsline=\\nocontentsline'), header,
                pandoc.RawInline('tex', '\\egroup')}

    else
        -- For other output formats, simply return the header
        -- Other formats yet to implement
        return header
    end
end

local hide_header_below_level = nil
function Header(header)
    -- Check if there is a previously specified level to hide headers below
    if (hide_header_below_level ~= nil) then
        -- If the current header level is greater than the specified level, return an UnlistedHeader
        if (header.level > hide_header_below_level) then
            return UnlistedHeader(header)
            -- If the current header level is less than or equal to the specified level, reset the level to nil to stop unlisting headers
        elseif (header.level <= hide_header_below_level) then
            hide_header_below_level = nil
        end
    end
    -- If the header has the 'unlisted' class, set the hide_header_below_level to the current header level and return an UnlistedHeader
    -- This will unlist the current header as well as all headers below that level
    if header.classes:includes('unlisted') then
        hide_header_below_level = header.level
        return UnlistedHeader(header)
    end
    -- If the header has the 'unlisted-children' class, set the hide_header_below_level to the current header level
    -- This will unlist all headers below that level
    if header.classes:includes('unlisted-children') then
        hide_header_below_level = header.level
    end

    return header
end
