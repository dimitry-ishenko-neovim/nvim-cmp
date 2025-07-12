local cmp = require("cmp")
local snippy = require("snippy")

local function has_words_before()
    unpack = unpack or table.unpack
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    return col ~= 0 and line:sub(col, col):match("%s") == nil
end

local function tab_next(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    elseif snippy.can_expand_or_advance() then
        snippy.expand_or_advance()
    elseif has_words_before() then
        cmp.complete()
    else
        fallback()
    end
end

local function tab_prev(fallback)
    if cmp.visible() then
        cmp.select_prev_item()
    elseif snippy.can_jump(-1) then
        snippy.previous()
    else
        fallback()
    end
end

cmp.setup({
    snippet = {expand = function(args)
        snippy.expand_snippet(args.body)
    end},

    mapping = cmp.mapping.preset.insert({
        ["<c-space>"] = cmp.mapping.complete(),

        ["<c-b>"] = cmp.mapping.scroll_docs(-4),
        ["<c-f>"] = cmp.mapping.scroll_docs(4),
        ["<c-e>"] = cmp.mapping.abort(),
        ["<cr>" ] = cmp.mapping.confirm({select = true}),

        ["<tab>"] = cmp.mapping(tab_next, {"i", "s"}),
        ["<s-tab>"] = cmp.mapping(tab_prev, {"i", "s"}),
    }),

    sources = cmp.config.sources(
        {{name = "copilot"}, {name = "nvim_lsp"}, {name = "snippy"}},
        {{name = "nvim_lsp_signature_help"}},
        {{name = "buffer"}}
    )
})

cmp.setup.cmdline({"/", "?"}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {{name = "buffer"}}
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources(
        {{name = "path"}},
        {{name = "cmdline"}}
    ),
    matching = {disallow_symbol_nonprefix_matching = false}
})
