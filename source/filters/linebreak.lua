PANDOC_VERSION:must_be_at_least '2.12'

function RawInline(raw)
    if raw.format == 'html' and raw.text:match '(<br/?>)' then
        return pandoc.LineBreak()
    end
    return raw
end
