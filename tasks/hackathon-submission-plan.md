# Agent Rush — Hackathon 提交准备材料

> Track: Web3 x Long-Horizon Task (GLM-5.1)
> 形态: Roguelike 策略卡牌 / MEV 模拟器（纯前端，浏览器打开即玩）
> 文档日期: 2026-06-08
> 状态基准: 本文档基于当前 `main` 分支的**实际代码现状**生成，而非 commit message 标注的阶段。

---

## 0. 现状速览（事实核对）

合并到 `main` 的提交历史标注到「阶段3」，但工作区实际代码已包含大量阶段4内容。逐项核对：

| 能力 | 代码现状 | 文件 |
|------|---------|------|
| 状态机 / 回合循环（scan→play→execute→settle） | ✅ 已实现 | `RoundEngine.js` |
| 牌生成（Searcher/RiskAnalyzer/Strategist 规则） | ✅ 已实现 | `CardGenerator.js`（注：`src/core/CardGenerator.js` 由 config 驱动） |
| 刚体模式执行 + 敌方竞争 | ✅ 已实现 | `ExecutionEngine.runRigidMode`, `EnemyBotAI` |
| 自适应模式（Executor 4 调用点 + Thought Chain 流式） | ✅ 已实现 | `ExecutionEngine.runAdaptiveMode` |
| Schema 校验（ajv + 5 调用点 schema） | ✅ 已实现 | `SchemaValidator.js`, `data/executor-schema.json` |
| Mock AI（接口与真实层一致） | ✅ 已实现 | `ExecutorMock.js` |
| **真实 GLM 调用**（fetch + SSE 流式 + 5s 超时 + AbortController） | ✅ 已实现 | `ExecutorAI.js:115-187` |
| **超时/格式降级**（失败回退 Mock fallback，不卡死） | ✅ 已实现 | `ExecutorAI.requestWithFallback` |
| **AI 响应缓存**（key 去重 + 50 条上限 + 预热接口） | ✅ 已实现 | `ExecutorAI.js:92-113, 226-244` |
| **20 关配置 + 跳层** | ✅ 已实现 | `scenes.js: LAYER_CONFIG`, `RoundEngine` 跳层逻辑 |
| 关卡进度 / Agent 解锁 / Boss 奖励 | ✅ 已实现 | `ProgressionEngine.js` |
| Genesis 学习（规则引擎，连续 2 轮 +20% 胜率） | ✅ 已实现 | `EnemyBotAI.updateGenesisHistory` |
| `config/env.js` 已被 .gitignore | ✅ 已确认 | 不会泄漏 key |
| **Demo 缓存预热数据**（层10/层18 预设响应） | ❌ 缺失 | `src/ai/DemoCacheData.js` 不存在 |
| **部署配置**（vercel.json / netlify.toml） | ❌ 缺失 | 无 |
| **真实 GLM key 端到端验证** | ⚠️ 未验证 | 代码路径完整，但未确认真实 key 实跑通过 |
| **三幕 Demo 完整串排** | ⚠️ 未验证 | 跳层能力具备，但未做整段排练 |

结论：**核心可玩链路和 Long-Horizon 展示已具备**。距离「评审可用」的真实缺口集中在三点：①真实 GLM 端到端跑通验证 ②部署上线 ③Demo 路径预热与串排。

---

## 1. 最小可验证主流程（MVP Flow）

这是 Hackathon 必须能完整演示的一条主路径。任何一步断裂都视为 MVP 未达标。

```
[1] 浏览器打开部署 URL（零门槛：无需钱包/合约/后端）
      ↓
[2] 层 1-3 教程：看到手牌 → 选牌 → 出牌 → 看到结算损益
      （展示「零门槛上手」P4）
      ↓
[3] 跳到层 10（?debug 或自然推进）：带 Executor，进入自适应模式
      → Thought Chain 流式显示 Executor 推理（逐字符）
      → InitialPlanning：把多张牌拆解 + 排序（任务分解）
      → SingleCardPlan：每张牌拆成具体链上步骤（多步规划 + 工具调用）
      → Phantom 抢占目标 → IncidentResponse 触发（迭代修复）
      → SettlementReport：结算面板高亮 decisionHighlights（工作流闭环）
      （展示「Long-Horizon 可见」P5：评审能指认 ≥3 处特征）
      ↓
[4] 跳到层 18：Genesis 学习机制 → 预判 vs 玩家反预判
      ↓
[5] AI 超时/异常时自动降级到保底策略，游戏不卡死（鲁棒性兜底）
```

**MVP 通过判定**：上述 [1]→[5] 在部署 URL 上一气呵成，其中 [3] 的 4 个 Executor 调用点日志全部可见、流式可见、至少 3 处 Long-Horizon 特征评审可指认。

**降级保险**：若现场真实 GLM 不可用（网络/限流/超时），`window.GLM_API_KEY` 缺失即自动切 Mock，或单次调用超时自动 fallback——主流程 [1]→[5] 在纯 Mock 下依然完整可演。这是 Demo 的安全垫。

---

## 2. 任务看板拆分

### 🔴 Must-have（缺任一项则无法提交 / 无法 Demo）

| # | 任务 | Owner | Deadline | 验证方式 |
|---|------|-------|----------|---------|
| M1 | 真实 GLM key 端到端跑通：填入 `config/env.js`，层10 自适应模式实跑一轮，确认 4 个调用点返回合法 JSON 且通过 schema 校验 | Codex | Day 4 EOD | 浏览器实跑层10，控制台无 fallback 警告；ThoughtChain 显示真实 AI 文本（非 Mock 模板） |
| M2 | 部署上线：新增 `vercel.json`（SPA rewrite），推送后获得可访问公网 URL | Codex | Day 5 上午 | 用无痕窗口打开 URL，能完成层1-3主流程，无 404、无 CORS 报错 |
| M3 | Demo 路径预热缓存：创建 `src/ai/DemoCacheData.js`，写入层10/层18 关键调用的预设响应，`ExecutorAI.init` 调用 `preWarmCache` | Codex | Day 5 上午 | 断网后跳层10，Thought Chain 仍流式播放预热内容，无超时降级 |
| M4 | 三幕 Demo 串排：层1-3 → 层10（Executor + Phantom抢占 + 修复）→ 层18（Genesis），全程无卡顿、无 console error | 架构师 + Codex | Day 5 下午 | 完整录屏一遍 7 分钟流程；对照 GDD 13.3 检查清单逐项打勾（任务分解/多步规划/工具调用/迭代修复/工作流闭环 5 项全中） |
| M5 | 降级安全垫验证：删除 `config/env.js`（或模拟超时），主流程 [1]→[5] 在纯 Mock 下仍完整可演 | Codex | Day 5 下午 | 移除 key 后跑完整三幕，确认游戏不卡死、日志出现「[自动降级]」提示且流程继续 |
| M6 | 提交物打包：README（一句话价值主张 + 在线 URL + 本地运行说明 + Long-Horizon 亮点指引）+ Demo 录屏链接 | 架构师 | Day 5 EOD | README 里点 URL 能玩；评审照着「Long-Horizon 亮点指引」能在 60 秒内找到 3 处特征 |

> Owner 说明：项目当前由「架构师（审核+决策+文档+部署/提交把关）」与「Codex（编码执行）」两个角色推进。若实际有更多成员，按此模板补填具体人名即可。
> Deadline 说明：沿用 GDD 的 5 天开发窗口（Day 4 接真实 GLM，Day 5 Demo 排练+部署+降级）。如 Hackathon 有硬性提交时刻，请把 M2/M6 的 Deadline 对齐到「提交截止前 2 小时」。

### 🟡 Should-have（显著加分，但缺失不致命）

| # | 任务 | 说明 |
|---|------|------|
| S1 | UI 动画 P0：手牌弹出、计时器颜色切换、结算逐行出现 | 提升演示观感与「压力即乐趣」体感 |
| S2 | 层10 预设事件稳定性：Phantom 必抢 + 骗局牌注入可手动触发（`?debug=1` 面板） | 保证 Demo 第二幕每次都能触发修复路径 |
| S3 | 真实 GLM 的 reasoning 质量调优（prompt 微调，确保 50 字内、体现 Long-Horizon 特征） | 评审直接读到的文本，质量影响印象分 |
| S4 | Genesis 第三幕的「预判 vs 反预判」可视化对比 | 第三幕的记忆点 |

### 🟢 Nice-to-have（有余力再做）

| # | 任务 | 说明 |
|---|------|------|
| N1 | UI 动画 P1/P2：抢占红闪、Gas 数字高亮、风险翻转、Boss 粒子 | 锦上添花 |
| N2 | 通关画面 + 本局统计 | 完整度 |
| N3 | 每日挑战模式入口（固定种子） | GDD 列为通关后解锁，非 Demo 路径 |
| N4 | Flashbots / DAO 治理等额外场景（GDD 已标为 Day5 可选扩展） | 4 场景已覆盖全部 Demo 脚本 |

### ⚫ Cut / Mock（明确不做 或 用替代方案）

| 原设计 | 处理方式 | 理由 |
|--------|---------|------|
| 玩家暂停介入（NLP 自然语言指令，PlayerIntervention 调用点） | **Cut**：按钮显示「即将推出」，不实现 NLP | 不影响 Long-Horizon 5 要素展示；已在阶段3审核中决策移除自动触发 |
| Genesis ML 学习 | **Mock**：规则引擎记录最近 2 轮，触发 +20% 胜率 | ML 实现成本极高，规则引擎行为等效 |
| 8 个场景 | **Cut 到 4**：DEX套利/NFT市场/借贷清算/新币发射台 | Demo 脚本已被 4 场景完整覆盖 |
| 钱包 / 智能合约 / 后端 | **Cut**：纯前端静态部署 | 零门槛是核心卖点 P4；也规避了链上成本与复杂度 |
| 服务端存档 / 时间同步 | **Mock**：localStorage 本地持久化 | 无后端约束 |
| 真实链上 mempool 数据 | **Mock**：`MempoolSimulator` 本地模拟 | Demo 不依赖真实链 |

---

## 3. 风险与缓解（提交前重点盯）

| 风险 | 等级 | 缓解措施 | 对应任务 |
|------|------|---------|---------|
| 现场真实 GLM 超时 / 限流 → Demo 卡死 | 高 | 5s 超时自动降级 + 关键路径预热缓存 + Mock 安全垫 | M3, M5 |
| AI 返回非预期 JSON 结构 | 中 | ajv schema 校验，失败即 fallback（已实现） | M1 |
| 部署后路径 / CORS 问题 | 中 | 用无痕窗口预先验证，相对路径引用，不依赖构建工具 | M2 |
| `config/env.js` 误提交泄漏 key | 中 | 已确认在 .gitignore；提交前再 `git status` 核对一次 | M6 |
| Demo 第二幕 Phantom 没触发抢占 → 看不到「迭代修复」 | 中 | `?debug=1` 强制注入抢占事件 | S2 |

---

## 4. 一句话价值主张（README / 开场用）

> **Agent Rush** 是一款浏览器打开即玩的 MEV 模拟策略卡牌游戏——你指挥一支 AI Agent 战队在区块链 mempool 中抢套利、防夹击。其中 Executor Agent 由 GLM 驱动，把「执行多张机会牌」实时拆解为子任务、多步规划、遇到对手抢占时迭代修复，全过程在 Thought Chain 面板逐字可见。这是一个把 **Long-Horizon Agent 能力变成可玩、可见、可指认** 的 Web3 游戏。

---

*本文档为 Hackathon 提交准备材料，随现状滚动更新。Must-have 全绿即达到可提交状态。*
