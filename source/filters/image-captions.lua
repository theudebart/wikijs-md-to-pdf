PANDOC_VERSION:must_be_at_least '2.17'

-- This filter searches for images which are directl followed by a cursive text and adds this cursive text as the image caption.

function Pandoc(doc)
    doc.blocks = doc.blocks:walk{
        traverse = 'topdown',
        Para = function(para)

            local image_count = 0
            local emph_count = 0
            local image_followed_by_emph = false
            local prev_element = nil
            local image = nil;
            local caption = nil;

            para.content = para.content:map(function(inline)
                if (inline.tag == 'Image') then
                    image_count = image_count + 1
                    image = inline
                elseif (inline.tag == 'Emph') then
                    emph_count = emph_count + 1
                    if (prev_element and prev_element.tag == 'Image') then
                        image_followed_by_emph = true
                        caption = inline
                    end
                end
                if (inline.tag ~= 'SoftBreak' and inline.tag ~= 'LineBreak' and inline.tag ~= 'Space') then
                    prev_element = inline
                end
                return inline
            end)

            if (image_count == 1 and emph_count == 1 and image_followed_by_emph) then
                image.caption = caption
                return pandoc.Figure(image, pandoc.List({image.caption}))
            else
                return para
            end
        end
    }

    return doc

end

