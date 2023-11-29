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
            header.identifier = TransformPathToIdentifier(file_path .. ':' .. header.identifier)
            return header
        end,
        Link = function(link)
            if path.is_absolute(link.target) then
                link.target = '#' .. TransformPathToIdentifier(link.target)
            end
            return link
        end
    }

    return pandoc.walk_block(pandoc.Div(blocks), update_content_filter).content
end
