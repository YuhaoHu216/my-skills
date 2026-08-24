---
name: vue-build-skill
description: 构建 Vue3 + Vite + Element Plus 前端项目，包含路由、状态管理、持久化、axios
---

## Steps

### 1. 检查 Node.js 环境

```
node -v
```

要求 Node.js >= 18。版本匹配规则：

| Node.js 版本 | 创建方式 | Vite 版本 |
|---|---|---|
| >= 20.19.0 或 >= 22.12.0 | `npm create vue@latest` | Vite 8（Rolldown） |
| >= 18 但 < 20.19.0 | `npm create vite@5 -- --template vue` | Vite 5（esbuild） |

> **原因**：Vite 8 使用 Rolldown 打包引擎，其 native binding 要求 Node >= 20.19.0，低版本会报 `Cannot find native binding` 错误。

### 2. 创建项目

**Node >= 20.19.0 时：**
```
npm create vue@latest <project-name> -- --router --pinia
```
交互选项按需选择（推荐勾选 Router、Pinia），其余选 No。

**Node < 20.19.0 时（如 20.15.1）：**
```
npm create vite@5 <project-name> -- --template vue
```
> Vite 5 模板不含 Router/Pinia，需要在第 3 步安装依赖时手工加上。

### 3. 进入项目目录，一次性安装所有依赖

**Node >= 20.19.0（已用 create-vue 创建，自带 Router/Pinia）：**
```
cd <project-name>
npm install && npm install element-plus @element-plus/icons-vue axios pinia-plugin-persistedstate && npm install sass -D
```

**Node < 20.19.0（已用 create-vite@5 创建，需补装 Router/Pinia）：**
```
cd <project-name>
npm install && npm install vue-router@4 pinia pinia-plugin-persistedstate element-plus @element-plus/icons-vue axios && npm install sass -D
```

### 4. 配置 main.js

```js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import App from './App.vue'
import router from './router'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

const app = createApp(App)
app.use(pinia)
app.use(router)
app.use(ElementPlus)
app.mount('#app')
```

### 5. 调整目录结构

- 删除 `src/components/` 下的模板文件（HelloWorld.vue 等）
- 删除 `src/style.css`（Element Plus 替代）
- 新建 `src/router/`、`src/api/`、`src/utils/`、`src/views/`、`src/stores/`（Vite 5 模板无这些目录）
- 将静态资源放入 `src/assets/`

### 6. 编写路由配置 `src/router/index.js`

```js
import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/Home.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
```

### 7. 编写 Pinia store 示例 `src/stores/user.js`

```js
import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref('')

  function setToken(val) {
    token.value = val
  }

  function logout() {
    token.value = ''
  }

  return { token, setToken, logout }
}, {
  persist: true,  // 刷新不丢失
})
```

### 8. 清理 App.vue

```vue
<template>
  <router-view />
</template>
```

### 9. 启动开发服务器

```
npm run dev
```

---

## 注意事项

- Element Plus 组件默认英文，如需中文可在 `main.js` 中引入 `element-plus/dist/locale/zh-cn.mjs`
- `sass` 是 CSS 预处理器，仅在 `.vue` 文件中使用 `<style lang="scss">` 时才需要
- `pinia-plugin-persistedstate` 默认存 localStorage，可通过 `persist: { storage: sessionStorage }` 改为会话级
