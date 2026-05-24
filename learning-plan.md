# 学习规划 / Learning Plan

> 目标：系统掌握 AI × Web3 开发能力，准备 Hackathon 项目
> 学习者：chxii | 每日投入：约 5 小时

---

## 阶段一：Web3 基础（2-3 周）

目标是建立链上系统的基本直觉，与你已有的编程经验结合。

| 顺序 | 主题 | 重点内容 | 预计时间 |
|------|------|---------|---------|
| 1 | Network | 区块、共识、L2、RPC、链上状态 | 3-4 天 |
| 2 | Cryptography | 哈希、公私钥、签名、Merkle Tree | 2-3 天 |
| 3 | Wallet | EOAs vs Smart Accounts、签名入口、Session Key | 2-3 天 |
| 4 | Smart Contract | 部署、调用、状态、Gas、简单合约入门 | 3-4 天 |
| 5 | Account Abstraction | Smart Account、ERC-4337、权限表达 | 2-3 天 |
| 6 | DeFi & Oracle | AMM、借贷、预言机、数据源风险 | 2-3 天 |

**本阶段产出：**
- 每个主题至少 1 篇笔记
- 尝试部署一个简单合约（可以用 Remix 或 Hardhat）
- 理解钱包签名流程

---

## 阶段二：AI 基础（1-2 周）

你已有一定基础，重点补齐与 Agent 开发相关的概念。

| 顺序 | 主题 | 重点内容 | 预计时间 |
|------|------|---------|---------|
| 1 | LLM | Token、Context Window、能力边界、模型选择 | 1-2 天 |
| 2 | Prompt | 结构化提示词、Few-shot、CoT | 1-2 天 |
| 3 | Context | RAG、向量数据库、上下文管理 | 2 天 |
| 4 | Agent | Tool Use、ReAct、Multi-step Execution | 2-3 天 |
| 5 | MCP | 模型上下文协议、工具注册与调用 | 1-2 天 |
| 6 | Frameworks | LangChain / LangGraph / Agents SDK 对比 | 1-2 天 |

**本阶段产出：**
- 理解 Agent 的核心工作流
- 用 LangChain 或类似框架搭建一个简单的 Agent 原型
- 结合 Web3 工具（如读取链上数据）

---

## 阶段三：AI × Web3 Bridge（2-3 周）

这是核心交叉地带，从概念进入实践。

| 顺序 | 主题 | 重点内容 | 预计时间 |
|------|------|---------|---------|
| 1 | Chain-aware Context | 链上状态如何进入 Agent 上下文 | 2 天 |
| 2 | Web3 Tool Use | RPC 调用、合约读取、钱包签名工具 | 3 天 |
| 3 | Agent Workflow | 自动化边界、Human-in-the-loop 设计 | 2 天 |
| 4 | Agent Wallet | 权限授予、Session Key、Policy Guard | 2-3 天 |
| 5 | Machine Payment | 自动化结算、Escrow、支付通道 | 2 天 |
| 6 | Agent Identity | DID、链上身份、声誉记录 | 1-2 天 |
| 7 | AI Security | Prompt Injection、权限隔离、审计 | 2 天 |
| 8 | Verifiable AI | 证明模型执行、ZK 与 AI 结合方向 | 1-2 天 |

**本阶段产出：**
- 一个能读取链上数据 + 执行交易的 Agent 原型
- 理解 Agent 与钱包权限的结合方式
- 建立 AI Security 的基本意识

---

## 阶段四：前沿探索 & Hackathon 准备（持续）

根据个人兴趣选择方向。

| 方向 | 简介 | 适合场景 |
|------|------|---------|
| Agentic Commerce | Agent 发现服务、协商任务、支付结算 | 电商 / 支付类 Hackathon |
| Wallet / Permission | Session Key、Policy、Guard 设计 | 钱包 / 权限类项目 |
| AI Security | 攻击面、隔离、审计日志 | 安全类项目 |
| Governance | DAO 提案、AI 辅助决策 | 治理类项目 |

**Hackathon 准备：**
- 至少完成 1 个可演示的原型
- 准备好 1 分钟和 5 分钟的展示版本
- 积累 3 个以上的项目素材（截图、代码、架构图）

---

## 每日节奏建议（5 小时 / 天）

| 时段 | 时长 | 内容 |
|------|------|------|
| 早上 (1h) | 60 min | 读 Handbook 章节 + 整理笔记 |
| 上午 (1.5h) | 90 min | 概念理解 + 画架构图 / 思维导图 |
| 下午 (2h) | 120 min | 实践：写代码、做实验、跑 Demo |
| 晚上 (1.5h) | 90 min | 打卡 + 整理笔记 + 明日计划 |

---

## 当前进度

- [x] 初始化完成 (2026-05-18)
- [x] 阶段一：Web3 基础 — 完成（3天，2026-05-18 ~ 2026-05-20）
  - [x] Network — Day 2
  - [x] Cryptography — Day 1
  - [x] Wallet — Day 1
  - [x] Smart Contract — Day 2/3
  - [x] Account Abstraction — Day 2
  - [x] DeFi & Oracle — Day 2
  - [x] Indexing — Day 3
  - [x] Security — Day 3
  - [x] Dev Stack — Day 3
- [x] 阶段二：AI 基础 — 完成（Day 4-5）
  - [x] EVM / Gas / Blocks / PoS 深化 — Day 7
- [ ] 阶段三：AI × Web3 Bridge
- [ ] 阶段四：前沿探索 & Hackathon 准备
