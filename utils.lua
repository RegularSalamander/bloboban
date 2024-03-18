local util = {}



function util.map(item, min1, max1, min2, max2)
    return ((item-min1)/(max1-min1))*(max2-min2)+min2;
end

function util.approach(x, y, a)
    if math.abs(x-y) < a then return y end
    if x < y then
        return x + a
    end
    return x - a
end

function util.charAt(str, i)
    return string.sub(str, i, i)
end

return util