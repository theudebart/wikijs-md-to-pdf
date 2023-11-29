PANDOC_VERSION:must_be_at_least '2.12'

local path = require 'pandoc.path'

local add_pageref_variable = tostring(PANDOC_WRITER_OPTIONS.variables['add-pageref']):gsub('"?([^"]+)"?', "%1")

local add_pageref = false
if add_pageref_variable and add_pageref_variable ~= 'nil' then
    if (add_pageref_variable == 'true') then
        add_pageref = true
    end
end

function LinkWithPageref(link)
    if (FORMAT:match 'tex$') then
        link.content:extend({pandoc.RawInline("latex", "\\iflabelexists{" .. link.target:gsub('#', '') ..
            "}{\\ (\\cpageref{" .. link.target:gsub('#', '') .. "})}")})
    end
    return link
end

function Link(link)
    -- If add pageref option is set continue
    if add_pageref_variable then
        if link.target then
            -- Only add links to pages not to files
            _, extenstion = path.split_extension(link.target)
            -- if the target has no file extension we add the pageref
            if (extenstion == '') then
                return LinkWithPageref(link)
            else
                link.target = nil
            end
        end
    end
    return link
end

-- Please do not ask why this is necessary....
-- In order for \labels to reference to the correct position labels should follow an \phantomsection
-- In Version 3.1.8 this change was made to pandoc and should be included by default.
-- However for some reasons this is not the case in my environment (v.3.1.9)
-- I wanted to add this as a filter but then noticed, that \phantomsection appeard twice.
-- After a little bit of debuging I found out that as soon as a RawInline is added, the \phantomsection gets added by pandoc.
-- So here we are adding en empty RawInline so that pandoc adds a \phantomsection
function Header(header)
    if (FORMAT:match 'tex$') then
        return {pandoc.RawInline("latex", ""), header}
    end
    return header
end

