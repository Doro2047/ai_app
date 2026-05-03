# ToolKit-Hub - 全能桌面工具集

## 项目简介

基于 Python + CustomTkinter 的桌面端工具集，包含多个实用工具程序。所有程序均使用 CustomTkinter 构建现代化 GUI 界面。

## 工具列表

### 文件管理工具
| 工具名称 | 说明 | 打包模式 |
|---------|------|---------|
| [APK批量安装工具](APK安装目录/) | 批量安装APK文件到Android设备 | 目录模式 |
| [批量扩展名修改器](批量扩展名修改器/) | 批量修改文件扩展名 | 单文件模式 |
| [批量文件查重清理工具](批量文件查重清理工具/) | 检测和清理重复文件 | 目录模式 |
| [批量重命名工具](批量重命名工具/) | 批量重命名文件 | 单文件模式 |
| [文件扫描器](文件扫描器/) | 扫描和筛选文件 | 单文件模式 |
| [文件移动工具](文件移动工具/) | 批量移动文件 | 单文件模式 |

### 系统工具
| 工具名称 | 说明 | 打包模式 |
|---------|------|---------|
| [FREE工具箱](FREE工具箱/) | 系统工具集，包含硬件信息、进程管理等 | 单文件模式 |
| [系统时间管理与设备控制工具](系统时间管理与设备控制工具/) | 时间同步、网络/蓝牙控制 | 目录模式 |

### 其他工具
| 工具名称 | 说明 | 打包模式 |
|---------|------|---------|
| [Edge书签管理器](edge书签管理器/) | 管理和整理Edge浏览器书签 | 单文件模式 |
| [ImageClassifier](ImageClassifier/) | AI图像分类器 | 目录模式 |

## 技术栈

- **GUI框架**: CustomTkinter（基于Tkinter的现代化UI框架）
- **图像处理**: PIL/Pillow
- **AI模型**: PyTorch, TorchVision（ImageClassifier）
- **网络工具**: scapy, pywifi（系统时间管理工具）
- **系统信息**: psutil
- **打包工具**: PyInstaller

## 国际化支持

本项目支持四种语言：

| 语言 | 代码 | 状态 |
|------|------|------|
| 简体中文 | zh_CN | ✅ 完整支持 |
| English | en_US | ✅ 完整支持 |
| 日本語 | ja_JP | ✅ 完整支持 |
| 한국어 | ko_KR | ✅ 完整支持 |

### 切换语言

程序启动后会自动检测系统语言，也可在设置中手动切换。

### 在代码中使用翻译

```python
from shared.i18n import t

# 简单翻译
label = t("ok")  # "确定" (中文) / "OK" (英文)

# 带参数的翻译
message = t("hello_name", name="用户")  # "你好，用户！"

# 复数形式
count_text = t("item_count", count=5)  # "5 个项目"
```

### 贡献翻译

欢迎提交 PR 完善翻译内容。翻译文件位于 `shared/locales/` 目录。

## 项目结构

```
ToolKit-Hub/
├── shared/                    # 共享模块
│   ├── ctk_imports.py         # CustomTkinter导入封装
│   ├── base_app_ctk.py        # 应用基类
│   ├── ui_components_ctk.py   # UI组件
│   ├── theme_manager_ctk.py   # 主题管理
│   ├── i18n.py                # 国际化模块
│   ├── locales/               # 翻译文件
│   │   ├── zh_CN.json         # 简体中文
│   │   ├── en_US.json         # English
│   │   ├── ja_JP.json         # 日本語
│   │   └── ko_KR.json         # 한국어
│   ├── icons/                 # 图标文件
│   └── ...
├── APK安装目录/               # APK批量安装工具
├── FREE工具箱/                # FREE工具箱
├── edge书签管理器/            # Edge书签管理器
├── 批量扩展名修改器/          # 批量扩展名修改器
├── 批量文件查重清理工具/      # 批量文件查重清理工具
├── 批量重命名工具/            # 批量重命名工具
├── 文件扫描器/                # 文件扫描器
├── 文件移动工具/              # 文件移动工具
├── 系统时间管理与设备控制工具/ # 系统时间管理与设备控制工具
├── ImageClassifier/           # AI图像分类器
├── AppCenter/                 # 应用中心
├── requirements_ctk.txt       # 依赖列表
├── pyproject.toml             # 项目配置
└── ruff.toml                  # 代码检查配置
```

## 快速开始

### 安装依赖

#### 使用 uv（推荐，速度更快）
```bash
# 首先安装 uv（如果尚未安装）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 使用 uv 安装依赖
uv pip install -r requirements_ctk.txt
```

#### 使用传统 pip
```bash
pip install -r requirements_ctk.txt
```

### 开发工具配置

#### 配置 pre-commit 钩子（推荐）
为确保代码质量，本项目使用 pre-commit 钩子：
```bash
# 安装 pre-commit
pip install pre-commit

# 安装 git 钩子
pre-commit install

# 运行所有检查（可选，在提交前自动触发）
pre-commit run --all-files
```

pre-commit 会在每次提交时自动运行：
- ruff check - 代码质量检查
- ruff format - 代码格式化
- mypy - 类型检查

### 运行工具
```bash
cd <工具目录>
python main.py
```

### 打包为可执行文件
```bash
cd <工具目录>
python -m PyInstaller <工具名称>.spec --clean --noconfirm
```

打包产物位于 `<工具目录>/dist/` 目录下。

## 打包模式说明

- **单文件模式**: 所有依赖打包进单个exe，双击即可运行
- **目录模式**: 生成包含exe和依赖的目录，适合有大型外部依赖的程序

## 许可证

本项目采用 MIT 许可证。使用、复制或修改本项目时，必须保留原始版权声明和许可声明。

详见 [LICENSE](LICENSE) 文件。
