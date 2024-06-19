

使用 Yarn 创建一个 Vite + Vue 3 项目非常简单。以下是详细的步骤：

### 1. 安装 Yarn 

首先，确保你已经安装了 Yarn。如果没有安装，可以使用以下命令进行安装：

```bash
npm install -g yarn
```

### 2. 创建项目目录
在命令行中，进入你想要创建项目的目录，然后运行以下命令来创建项目：

```bash
yarn create vite my-vue-app --template vue

# 在当前目录创建项目
yarn create vite . --template vue
```

这里的 `my-vue-app` 是你的项目名称，你可以根据需要进行修改。

### 3. 安装依赖
进入项目目录并安装依赖：

```bash
cd my-vue-app
yarn
```

### 4. 运行开发服务器
使用以下命令启动开发服务器：

```bash
yarn dev
```

默认情况下，Vite 会在 `http://localhost:5173` 启动开发服务器。你可以在浏览器中打开这个地址来查看你的 Vue 3 项目。

### 5. 项目结构
创建的 Vite + Vue 3 项目会有一个类似以下的结构：

```
my-vue-app/
├── index.html
├── package.json
├── public/
├── src/
│   ├── assets/
│   ├── components/
│   │   └── HelloWorld.vue
│   ├── App.vue
│   └── main.js
├── vite.config.js
└── yarn.lock
```

### 6. 编写代码
你可以在 `src/` 目录下编写 Vue 组件和逻辑。例如，打开 `src/components/HelloWorld.vue` 文件，你可以看到一个基本的 Vue 组件模板：

```vue
<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
  </div>
</template>

<script>
export default {
  name: 'HelloWorld',
  props: {
    msg: String
  }
}
</script>

<style scoped>
h1 {
  color: #42b983;
}
</style>
```

你可以根据自己的需要修改和扩展这个组件。

### 7. 构建项目
当你完成开发并准备部署时，可以使用以下命令构建项目：

```bash
yarn build
```

构建完成后，项目的静态文件会生成在 `dist` 目录下，你可以将这些文件部署到你的 Web 服务器上。

### 资源
- [Vite 官方文档](https://vitejs.dev/)
- [Vue 3 官方文档](https://v3.vuejs.org/)
- [Yarn 官方文档](https://yarnpkg.com/)

通过以上步骤，你应该能够快速地使用 Yarn 创建一个 Vite + Vue 3 项目，并开始你的开发工作。