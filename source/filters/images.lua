PANDOC_VERSION:must_be_at_least '2.17'

local path = require 'pandoc.path'

-- This filter adjusts images paths to search in the assets folder
-- This filter allows the support of image sizes

function Image(image)
    if path.is_absolute(image.src) then
        image.src = '.' .. image.src
    end
    if image.src:match('=%d*x$') then
        local width = tonumber(image.src:match('%d*x$'):match('%d*')) or 1204
        local ratio = width / 10.24
        if ratio > 100 then
            ratio = 100
        end
        image.attributes.width = tostring(math.floor(ratio)) .. '%'
        image.src = image.src:gsub('(%%(%x%x))=%d*x$', '')
    elseif image.src:match('=%d*%%x$') then
        local width = tonumber(image.src:match('%d*%%x$'):match('%d*')) or 1204
        image.attributes.width = tostring(width) .. '%'
        image.src = image.src:gsub('(%%(%x%x))=%d*%%x$', '')
    end
    return image
end
