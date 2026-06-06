> 创建于：2026 - 06 - 06

## Hackathon Direction Card

参赛赛道：Z.AI
项目名：Verifiable Web3 Research Agent
目标用户：散户投资者、DAO 参与者、独立 Web3 研究者
要解决的问题：现有 AI 工具做 Web3 研究只给结论、不给来源，无法验证；人工调研要横跨 Etherscan / Dune / CoinGecko /治理论坛手动拼数据，一次调研动辄数小时
最小功能（MVP）：用户输入自然语言问题 → GLM-5.1 自主拆解研究计划 → 多工具并发取数（Dune 链上 / Tally 治理 / Etherscan 地址核验 / CoinGecko 市值）→ SQL 报错自动触发 Self-Heal 重试 → 输出结构化研究报告，每条结论绑定可独立复跑的 Dune Query ID + 区块/时间锚，前端 Research Graph 实时展示 Agent 推理过程
技术路径：
- Backend: Python 3.11 + FastAPI + WebSocket + 自研 ReAct loop（无 LangChain）
- LLM: GLM-5.1（Z.AI API，OpenAI-compatible function calling）
- 数据: Dune REST / Tally GraphQL / Etherscan / CoinGecko / Firecrawl / Tavily
- Frontend: React 18 + TypeScript + React Flow（Research Graph）+ Zustand + shadcn-ui
主要风险：
1. placeholder_resolver 在非 Demo 输入上的稳定性，任意用户输入能否正确解析占位符、触发 self-heal 还未大范围测试。
2. Dune API 超时，Demo 现场超时兜底逻辑（缓存 + 30s fallback）有没有覆盖所有 Demo 路径需要显式测试一遍。

## 项目一句话说明

Web3 研究者面对"AI 幻觉"和"信息碎片化"的双重困境——现有 AI 工具只输出结论文本，无法证明数字的真实来源；而人工验证链上数据又需要横跨 Etherscan、Dune、治理论坛多个平台，成本极高。
面向散户投资者和 DAO 参与者，让他们能在 10 分钟内完成过去需要 2–3 小时才能做完的链上事实核查，并获得每一条结论都绑定链上铁证的可验证研究报告。
输入任何 Web3 问题、消息或新闻 → GLM-5.1 自主拆解研究计划、调用 Dune MCP 执行链上查询、完成自愈重试 → 前端 Research Graph 实时生长，每个结论节点可点击展开原始 SQL 与区块数据，全程链路可观测、可追溯、可独立验证。


## 赛道选择说明

我选择 Z.AI 赛道:Web3 × Long-Horizon Task。

一次链上研究天然就是长程任务:它不是一次 API 调用能解决的,而是要走完"实体提取 → 地址关联 → SQL 生成 → 链上执行 → 跨源比对 → 结论推演"六个以上有序步骤,且每一步的输入都依赖上一步的产出。GLM-5.1 在我的项目里不只是生成结论文本,它承担了四个核心智能环节——自主拆解研究计划、动态生成工具调用参数、读懂 Dune SQL报错并迭代修复、跨数据源交叉推理——这些恰好是长程自主执行最吃模型能力的地方。尤其是 SQL 报错后的自愈 Loop(注入 Schema上下文、最多重试 3 次再降级)和目标一致性Checkpoint(每步自检是否偏离初始目标、必要时回退重规划),直接体现了赛道要求的"持续调用工具、迭代修复"而非一次性生成。整个流程从"用户一句自然语言研究问题"到"带可验证证据引脚的研究报告",是一条有明确起点和终点的完整 Web3工作流闭环,且全程在前端 Research Graph 上可观测、可追溯。

## 组队 / 单人参赛状态确认

参赛形式: 单人参赛。
角色: 我同时担任产品设计、系统架构、全栈开发与 Demo 演示。借助 AI 编码工具 (Claude Code 负责架构设计与代码审查、Codex负责具体实现)作为开发工具链来提升单人产能,所有方案决策、架构定型、代码审查与最终交付由我本人负责。
负责模块(全栈):
- 后端 / Agent 核心: Python + FastAPI;自研 ReAct Agent Loop(研究计划拆解、工具调度、证据收集)、自愈 Loop(SQL 报错注入Schema 上下文重试)、目标一致性 Checkpoint。
- 工具与数据层: Dune REST(链上数据)、Tally GraphQL(治理)、Firecrawl(网页),证据存储与 WebSocket 事件广播。
- 前端 / 可视化: React + TypeScript + React Flow;Research Graph 渐进渲染、Agent 执行日志面板、Evidence证据面板、研究报告卡片。
- 集成与 Demo: 前后端联调、三个 Demo 场景跑通、Fallback 降级路径、演示脚本与录制。

## Z.AI 赛道对齐任务

拆解复杂任务。 用户只输入一句自然语言研究问题，GLM-5.1 先进入 Plan 阶段，把问题自主拆解为 3–5步结构化研究计划(如：解析协议关联地址 → 查询目标地址链上转账 → 交叉比对 → 生成结论)，计划实时渲染到前端 Research Graph，评委能直接看到 Agent 在"规划"而非"直接答题"。
持续调用工具。 Agent 按计划在 ReAct Loop 中连续调度多个工具——实体解析、Dune SQL 生成与执行、Tally 治理数据、Firecrawl 网页抓取——每一步的输出都作为下一步的输入，单次研究通常触发 6步以上有序工具调用，且每步产出都被记录为可追溯的 Evidence Pin(含 Dune Query ID 与区块范围)。
迭代修复。Dune 的 Spellbook schema 极其庞杂，自然语言转 SQL 首次很容易选错表或字段类型报错；此时 Agent 进入自愈 Loop，把报错信息 + 对应表的 schema 上下文重新喂给 GLM-5.1 让它修复SQL，最多重试 3 次，仍失败则降级到预验证查询库。同时有目标一致性 Checkpoint：每步执行后让模型自检是否偏离初始研究目标，偏离则回退重规划。整个"出错—诊断—修复—成功"过程在前端日志面板完整可见。
从需求到交付的完整闭环。 整条链路从"用户一句研究问题"出发，到"一份带可验证证据引脚的研究报告"结束——报告每条结论都钉死一条可独立复跑的链上证据,末尾附硬编码免责声明。输出物是可观测、可追溯、可独立验证的真实 Web3研究资产，构成有明确起点和终点的交付闭环。

## Sponsor SDK / API Integration Plan
接入 Z.AI GLM-5.1 API，以 Function Calling 模式驱动 Agent 的全部推理与工具决策。

## Sponsor / Mentor 问题清单

假如 Agent 连续触发 6 步以上工具调用，请问 GLM-5.1 在这种多轮 tool_calls 累积的场景下，有没有推荐的上下文管理策略（比如历史 tool结果该全量保留还是摘要压缩）？以及单次会话累积多少轮工具调用后，Function Calling 的可靠性会开始下降？


## Risk / Assumption Memo

风险 1：Dune MCP 的链上 SQL 准确率不稳定
Dune 的 Spellbook Schema 极其复杂，自然语言转 SQL 在模糊查询时容易找错表、字段类型报错，或返回空数据。自愈 Loop 反复触发但仍无法拿到有效数据，Demo 卡死。
Fallback：准备 3 组"预验证 Query ID"——在 Dune 官网提前手写并保存正确的 SQL 查询（覆盖"地址过去 48h 转账"、"大额转账筛选"、"地址净流出"三种模式）。当 GLM-5.1 自动生成的 SQL 连续 3 次失败后，Agent 自动切换到"从预存 Query 库中检索最相近查询并执行"的降级路径，前端黄色节点提示"已启用预验证查询"。

风险 2：GLM-5.1 在长程工具调用中发生"目标漂移"
6 步以上的 ReAct Loop 中，模型可能在某一步突然改变研究方向、忽视前面的上下文、或在错误的分支上死循环。Research Graph 生长路径出现明显逻辑断裂。
Fallback：在 GLM-5.1 的 System Prompt 中为每个阶段设置硬性检查点：每步执行完成后，GLM-5.1 必须先输出"当前已完成：X，下一步计划：Y，是否与初始研究目标一致：是/否"，再继续执行。若自评为"否"，强制回退到 Plan 节点重新规划，最多回退 2 次。前端日志中这个自我校验过程完整可见。

## Repo Skeleton

```
verifiable-web3-research-agent/
├── docs/
│   └── plans/                 # 设计文档
├── backend/
│   ├── main.py               # FastAPI 入口
│   ├── agent/
│   │   ├── orchestrator.py   # Agent 核心编排
│   │   ├── planner.py        # 研究计划生成
│   │   ├── self_heal.py      # 自愈 Loop
│   │   └── checkpoint.py     # 目标一致性检查
│   ├── tools/
│   │   ├── dune_client.py    # Dune MCP Client
│   │   ├── tally_client.py   # Tally GraphQL Client
│   │   ├── firecrawl_client.py # Firecrawl Client
│   │   └── entity_resolver.py # 实体→地址解析
│   ├── models/
│   │   ├── evidence.py       # Evidence Store 数据模型
│   │   ├── graph.py          # Research Graph 数据模型
│   │   └── report.py         # 报告数据模型
│   ├── ws/
│   │   └── manager.py        # WebSocket 会话管理
│   ├── llm/
│   │   └── glm_client.py     # GLM-5.1 API Client
│   ├── config.py             # 配置管理
│   ├── requirements.txt
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   │   ├── ResearchGraph/   # React Flow 画布
│   │   │   ├── AgentLog/        # 终端日志
│   │   │   ├── EvidencePanel/   # 证据面板
│   │   │   ├── InputPanel/      # 输入框
│   │   │   └── ReportCard/      # 报告输出
│   │   ├── hooks/
│   │   │   └── useWebSocket.ts  # WS 连接管理
│   │   ├── stores/
│   │   │   └── researchStore.ts # 状态管理 (Zustand)
│   │   ├── types/
│   │   │   └── index.ts        # TypeScript 类型定义
│   │   └── styles/
│   │       └── globals.css     # Tailwind + 自定义样式
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   └── tsconfig.json
└── README.md
```

## Scope Review
Research Memory 知识图谱持久化
多用户 / 多 Session 并发
移动端适配
账号系统 / 登录
Twitter/X 实时抓取

## 技术验证计划

1. Placeholder Resolver — 非 Demo 输入
backend/agent/placeholder_resolver.py 已有两套测（test_placeholder_resolver.py +
test_step_runner_placeholders.py），但这是单元测试。需要验证的是：端到端场景里，GLM-5.1 生成的 plan 里占位符格式是否与resolver 期望的格式一致——模型可能写出 {{step1.output.address}} 而 resolver 期望 {{step1.addresses.0.address}}，对不上就触发 self-heal 但不一定能恢复。

2. Demo Cache 覆盖率
backend/demo_cache/ 已存在 fixture（如 demo-b-uniswap/），但需要确认三个 Demo 路径（A/B/C）的每个工具调用都有缓存命中，避免 live demo 时穿透到真实 API 超时。

3. Self-Heal 流程
self_heal.py 存在，但 Demo C（Lido + SQL 自愈）是卖点之一，需要实际跑一次让 SQL 报错触发自愈，验证整条链路在前端Research Graph 上的可视化是否正常显示 retry 节点。

4. Etherscan verify_address 集成
entity_resolver.py + etherscan_client.py 已实现，但没有看到 Sepolia/on-chain 合约交互（C-1 弹性项尚未做）。需要验证verify_address 的结果是否真的被后续 step 的 placeholder 引用。


## Week 4 Sprint Plan

Day 1：
跑 pytest backend/tests/ 全套，确认全绿
端到端跑 Demo：启动 backend + frontend，输入 Demo 问题，验证 Research Graph节点逐步出现 
确认 demo_cache/ 三个目录命中率 100%（无 cache miss 穿透到真实 API）
placeholder_resolver 压测：构造非 Demo 输入，验证 {{step1.address}} 被正确解析或触发 self-heal

Day2：
跑一次完整 Demo A，点击导出 Markdown，验证输出含 Dune 链接和证据清单
证据面板 Dune 外链（dune.com/queries/{id}）点击跳转验证
研究深度选择器（轻/中/重）前端 UI 验证三档切换
Research Graph 节点状态颜色（pending/running/success/failed/degraded）截图确认
修复发现的任何 UI bug
README 内容审查：安装步骤、.env 模板、运行命令是否完整可执行

Day3：
写 Demo A/B/C 的口头讲解脚本（问题背景 → agent 拆解 → 工具调用 → 报告展示，各 3 分钟）
Demo C 着重准备 SQL 自愈的叙事："Dune Spellbook schema 庞杂，Agent 读报错补 schema 重试"
彩排一次完整 Demo（计时），找出操作卡顿点
C-1 上链决策：今天做还是砍。若无法在 2 小时内出一个 Sepolia 存 hash 的MVP，直接砍，改为口头路线图

Day4：
录制 Demo A 完整流程视频（Research Graph 实时生长 + 报告输出）
录制 Demo C SQL 自愈片段（核心技术差异化）
剪辑拼接，加字幕（关键节点：plan → tool calls → self-heal → report）
verify_address 的 Etherscan 核验截图（证明"每条结论绑定可验证链上证据"）

Day5：
git status 确认 README.md 在根目录且已 commit
.env 未入库确认（git log --all -- .env 无输出）
打 tag v1.0-hackathon-submit