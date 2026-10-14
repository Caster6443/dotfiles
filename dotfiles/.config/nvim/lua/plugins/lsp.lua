return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { exclude = { "vue", "go" } },
      servers = {
        gopls = { settings = { gopls = { usePlaceholders = false } } },
        -- 启用 QML 语言服务器
        qmlls = {
          mason = false,
          -- 注意：如果在 Arch Linux 上，这里通常是 "qmlls6"，如果是其他系统可能是 "qmlls"
          cmd = { "qmlls6" },
          filetypes = { "qml", "qmljs" },
        },
        yamlls = {
          settings = {
            yaml = {
              completion = true,
              hover = true,
              validate = true,
              schemas = {
                kubernetes = {
                  -- Kubernetes 学习项目；不影响普通 YAML/Compose 配置
                  "/home/caster/Projects/k8s-in-action2/**/*.yaml",
                  "/home/caster/Projects/k8s-in-action2/**/*.yml",
                  "**/k8s/**/*.yaml",
                  "**/k8s/**/*.yml",
                  "k8s/*.yaml",
                  "k8s/*.yml",
                  "*.k8s.yaml",
                  "*.k8s.yml",
                },
              },
            },
          },
        },
      },
    },
  },
}
