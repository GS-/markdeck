local change = {x=0, y=0, z=0, scale=0, rotate=0}
local last = {x=0, y=0, z=0, scale=1, rotate=0}
local history = {}


function calc_pos(elem, dim)
    local attr_name = "data-" .. dim
    if elem.attributes[dim .. "-of"] then
        elem.attributes[attr_name] = history[elem.attributes[dim .. "-of"]][attr_name]
        change[dim] = 0
    end
    if elem.attributes[dim] then
        elem.attributes[attr_name] = elem.attributes[dim]
        change[dim] = 0
    end
    if elem.attributes["rel-" .. dim] then
        if elem.attributes[attr_name] then
            elem.attributes[attr_name] = elem.attributes[attr_name] + elem.attributes["rel-" .. dim]
        else
            elem.attributes[attr_name] = last[dim] + elem.attributes["rel-" .. dim]
        end
        change[dim] = elem.attributes[attr_name] - last[dim]
    end
    if elem.attributes[attr_name] == nil then
        elem.attributes[attr_name] = last[dim] + change[dim]
        change[dim] = elem.attributes[attr_name] - last[dim]
    end
    last[dim] = elem.attributes[attr_name]
end


function calc_position(elem)
    for _, dim in pairs({"x", "y", "z", "scale", "rotate"}) do
        calc_pos(elem, dim)
    end
end

function remember_position(elem)
    local entry = {}
    for _, dim in pairs({"x", "y", "z", "scale", "rotate"}) do
        local attr_name = "data-" .. dim
        entry[attr_name] = elem.attributes[attr_name]
    end
    history[elem.identifier] = entry
end

function dump_position(elem)
    local attrs = {elem.identifier}
    for _, dim in pairs({"x", "y", "z", "scale", "rotate"}) do
        local attr_name = "data-" .. dim
        table.insert(attrs, elem.attributes[attr_name])
    end
    print(table.concat(attrs, "\t"))
end

function calc_positions(elem)
    table.insert(elem.classes, "step")

    calc_position(elem)
    remember_position(elem)
    dump_position(elem)

    return elem
end


function add_backgrounds(header)
    if header.attributes.bg then
        return {header, pandoc.Div(pandoc.Null(), pandoc.Attr(header.identifier .. "__bg"))}
    else
        return header
    end
end

return {{Header=calc_positions}, {Header=add_backgrounds}}
