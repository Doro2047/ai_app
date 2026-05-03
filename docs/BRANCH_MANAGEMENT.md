# 分支管理说明

## 当前状态

本项目目前使用 **单分支策略**，仅保留 `main` 分支。

## 历史分支说明

本项目在初始化时曾使用过 Git Flow 分支策略，包含以下分支：

| 分支 | 用途 | 当前状态 |
|------|------|---------|
| `main` | 稳定版本分支 | **当前使用** |
| `develop` | 开发集成分支 | 已合并至 main 并删除 |

## 为什么选择单分支？

1. **简化开发流程** - 对于个人/小团队项目，单分支足够满足需求
2. **降低维护成本** - 无需频繁在多个分支间合并和同步
3. **清晰的提交历史** - 通过 Conventional Commits 规范即可区分功能开发、问题修复和文档更新

## 推荐的工作流程

- **日常开发**：直接在 `main` 分支上提交
- **提交规范**：遵循 [Conventional Commits](https://www.conventionalcommits.org/)
  - `feat:` - 新功能
  - `fix:` - 问题修复
  - `docs:` - 文档更新
  - `refactor:` - 重构
  - `chore:` - 杂务
- **版本发布**：使用 Git Tag 标记发布版本

## 如果需要多分支

未来如果项目规模扩大，可以考虑重新引入多分支策略：

```bash
# 创建 develop 分支
git checkout -b develop

# 创建功能分支
git checkout -b feature/新功能名

# 功能完成后合并回 develop
git checkout develop
git merge feature/新功能名
```

---

*本文档创建于 2025-05-03*
