local M = {}
-- An lze handler that enables a spec based on a nixCats category.
-- Register with: require('lze').register_handlers(require('nixCatsUtils.lzUtils').for_cat)
-- Usage in specs:
--   for_cat = "your.cat"
--   for_cat = { cat = "your.cat", default = bool }
M.for_cat = {
    spec_field = "for_cat",
    set_lazy = false,
    modify = function(plugin)
        if type(plugin.for_cat) == "table" and plugin.for_cat.cat ~= nil then
            plugin.enabled = nixCats(plugin.for_cat.cat) or false
        else
            plugin.enabled = nixCats(plugin.for_cat) or false
        end
        return plugin
    end,
}

return M
