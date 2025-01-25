-- define your colorscheme here
local colorscheme = 'onedark'

require("onedarkpro").setup({
    options = {
        transparency = true
    }
})

local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
    vim.notify('colorscheme `' .. colorscheme .. ' not found!')
    return
end
