PANDOC_VERSION:must_be_at_least '2.12'

function Para(para)
    local function convert_para_with_list(para)
        local has_list = false
        local prev_element_type = nil
        local list_start_index = 0
        local list_stop_index = 0
        local list_element = {}
        local list_content = {}

        for index, element in ipairs(para.content) do
            if (prev_element_type == 'SoftBreak' or prev_element_type == 'LineBreak' or prev_element_type == nil) then
                local first_character = string.sub(pandoc.utils.stringify(element), 1, 1)
                if (first_character == '-' or first_character == '*') then
                    if (has_list) then
                        table.insert(list_content, list_element)
                    else
                        has_list = true
                        list_start_index = index
                    end
                    list_element = {}
                else
                    if (has_list) then
                        break
                    end
                end
            end
            if (has_list) then
                if not (element.text and string.sub(pandoc.utils.stringify(element.text), 1, 1) == '-') then
                    table.insert(list_element, element)
                end
                list_stop_index = index;
            end
            prev_element_type = element.tag
        end

        if has_list then
            table.insert(list_content, list_element) -- insert last element
            local bullet_list = pandoc.BulletList(list_content)
            local content_before = para.content:filter(function(element, index)
                return index < list_start_index
            end)
            local content_after = para.content:filter(function(element, index)
                return index > list_stop_index
            end)
            content_before = pandoc.Para(content_before)
            content_after = pandoc.Para(content_after)
            content_after = convert_para_with_list(content_after)

            local new_para = pandoc.List:new({content_before, bullet_list})
            if (type(content_after) == 'table') then
                new_para:extend(content_after)
            else
                new_para:extend({content_after})
            end
            return new_para
        end

        return para
    end

    return convert_para_with_list(para)
end
