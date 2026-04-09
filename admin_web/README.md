## 关于

一款专注于用户体验和快速开发的开源后台管理解决方案。基于 ElementPlus 设计规范，进行了视觉上的精心优化，提供更美观、更实用的前端界面，帮助你轻松构建高质量的后台系统。

## 官方网站

[访问官方文档](https://www.lingchen.kim/art-design-pro/docs/)

## 特点

- 使用最新技术栈
- 内置常用业务组件模版
- 提供多种主题模式，可以自定义主题
- 漂亮的 UI设计、极致的用户体验和细节处理
- 系统全面支持自定义设置，满足您的个性化需求

## 技术栈

- 开发框架：Vue3、TypeScript、Vite、Element-Plus
- 代码规范：Eslint、Prettier、Stylelint、Husky、Lint-staged、cz-git

## 安装运行

```bash
# 安装依赖
pnpm install

# 如果 pnpm install 安装失败，尝试使用下面的命令安装依赖
pnpm install --ignore-scripts

# 本地开发环境启动
pnpm dev

# 生产环境打包
pnpm build


# 检查项目中的js语法
pnpm lint

# 修复项目中js语法错误
pnpm fix

# 使用 Prettier 格式化所有指定类型的文件。
pnpm lint:prettier

# 使用 Stylelint 检查和自动修复 CSS、SCSS 和 Vue 文件中的样式问题。
pnpm lint:stylelint

# 运行 lint-staged 仅检查暂存的文件，确保提交前代码质量。
pnpm lint:lint-staged

# 设置 Husky Git 钩子，用于在 Git 操作前运行脚本。
pnpm prepare

# 使用 Commitizen 规范化提交消息，确保提交格式一致。
pnpm commit

```

## dev

```
# 属性选择
<PropertySelectWithAdd
  v-model="form.category_id"
  sign="product_category"
  placeholder="请选择分类"
/>
```
