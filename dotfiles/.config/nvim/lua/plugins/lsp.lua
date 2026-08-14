return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- 启用 QML 语言服务器
        qmlls = {
	  mason = false,
          -- 注意：如果在 Arch Linux 上，这里通常是 "qmlls6"，如果是其他系统可能是 "qmlls"
          cmd = { "qmlls6" }, 
          filetypes = { "qml", "qmljs" },
        },
      },
    },
  },
}
