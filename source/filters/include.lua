PANDOC_VERSION:must_be_at_least '2.12'

local path = require 'pandoc.path'

function Header(header)
    if header.attributes.path then
        header.identifier = TransformPathToIdentifier(header.attributes.path)
    elseif header.attributes.include then
        header.identifier = TransformPathToIdentifier(header.attributes.include)
    end

    if not header.attributes.include then
        return header
    else

        local file = './content/pages' .. header.attributes.include .. '.md'
        local fh = io.open(file, 'r')
        if not fh then
            print('File not found: ' .. file)
            return
        end
        local blocks = pandoc.read(fh:read('*a')).blocks
        fh:close()
        blocks = ApplyTransformations(blocks, header.level, path.directory(file), header.attributes.include)
        table.insert(blocks, 1, header)
        return pandoc.Div(blocks)
    end
end

function TransformHeaderToIdentifier(header)
    -- Use the pandoc default header identifier
    -- In Wikijs if the header starts with a digit, the identifier is prefixed with 'h' following the digits
    -- This is not implemented in pandoc, so we need add this behavior
    if pandoc.utils.stringify(header.content):sub(1, 1):match('%d+') then
        -- Workaround to use the default pandoc header content to identifier method
        -- as this is not available in Lua
        local temp_header = pandoc.Header(1, 'h' .. pandoc.utils.stringify(header.content))
        local temp_doc = pandoc.Pandoc {temp_header}
        local roundtripped_doc = pandoc.read(pandoc.write(temp_doc, FORMAT), FORMAT)
        header.identifier = roundtripped_doc.blocks[1].identifier
    end
    return header
end

function TransformPathToIdentifier(path)
    -- Remove trailing '/'
    if path:sub(-1) == '/' then
        path = path:sub(1, -2)
    end
    -- Convert to CamelCase and replace '/' with ':
    local parts = {}
    for part in path:gmatch("[^/]+") do
        table.insert(parts, part:sub(1, 1):upper() .. part:sub(2))
    end
    path = table.concat(parts, ':')
    -- Remove special characters except ':'
    path = path:gsub('[^a-zA-Z0-9:]', '')
    return path
end

function ApplyTransformations(blocks, header_demote_level, include_path, file_path)
    local update_content_filter = {
        Image = function(image)
            if path.is_relative(image.src) then
                image.src = path.normalize(path.join({'.', include_path, image.src}))
            end
            return image
        end,
        Header = function(header)
            if header_demote_level then
                header.level = header.level + header_demote_level
            end
            header = TransformHeaderToIdentifier(header) -- Used to create identifier like Wikijs
            header.identifier = TransformPathToIdentifier(file_path .. ':' .. header.identifier)
            return header
        end,
        Link = function(link)
            if path.is_absolute(link.target) then
                link.target = '#' .. TransformPathToIdentifier(link.target)
            elseif path.is_relative(link.target) and link.target:sub(1, 1) == '#' then
                link.target = '#' .. TransformPathToIdentifier(file_path .. ':' .. link.target)
            end
            return link
        end
    }

    return pandoc.walk_block(pandoc.Div(blocks), update_content_filter).content
end
