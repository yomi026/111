# Little Paws

一个宠物主题的静态网站：猫咪、狗狗、兔子的介绍，以及日常养护指南。

## 页面

| 文件 | 内容 |
| --- | --- |
| `index.html` | 首页，站点介绍与导航入口 |
| `animals.html` | 动物图鉴 |
| `care.html` | 养护指南 |
| `gallery.html` | 图片墙 |

## 结构

```
little-paws/
├── index.html
├── animals.html
├── care.html
├── gallery.html
├── css/
│   └── style.css
└── js/
    └── script.js
```

## 本地预览

纯静态页面，无需构建。直接双击 `index.html` 用浏览器打开即可；
若要让 `js/script.js` 的行为和线上完全一致，建议起一个本地服务器：

```powershell
# 有 Python 时
python -m http.server 8000
# 有 Node.js 时
npx serve .
```

然后访问 <http://localhost:8000>。

## 部署

推送到 GitHub 后，可在仓库 **Settings → Pages** 中把 Source 设为 `main` 分支根目录，
几分钟后即可通过 `https://<用户名>.github.io/little-paws/` 访问。
