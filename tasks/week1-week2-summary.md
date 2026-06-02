# Week 1–2 任务汇总

> 整理时间：2026-06-02（Day 16）
> 用途：Hackathon 准备自查 + 方向确认

---

## 一、Week 1 基础搭建

### AI 基础

**AI 基础概念卡片**
`tasks/AI-Basic-Concepts.md`
涵盖 LLM 本质（概率预测而非知识存储）、Prompt Engineering（上下文决定输出质量）、RAG（检索增强生成）、Fine-tuning（微调 vs RAG 场景）、AI Agent（LLM + workflow 结合，harness 工程重要性）

**Learning Agent 实践**
Hermes Agent 已配置，接入飞书 + 微信，实现自然语言操控 GitHub、读写文件、搜索网页等

### Web3 基础

**Web3 概念卡片**
`tasks/Web3 基础概念卡片.md`
EVM 执行模型 / Gas 定价机制 / 智能合约（部署后不可改、信任机器）/ 测试网（Sepolia 真实体验）

**Week1 学习总结**
`tasks/Week1-Learning-Summary.md`
核心理解：LLM 是"预测"不是"知道" / Agent = LLM + 确定 workflow / Web3 = 去中心化状态机，可验证性是核心差异

**Proof-of-Work Pack**
`tasks/Week1-Proof-of-Work-Pack.md`
Week1 完整产出目录，含 AI 工具实践产物（Smart Contract Explainer）

### Learning Agent Demo

**Smart Contract Explainer**
`github.com/chxii/smart-contract-explainer`
AI 辅助理解 Solidity 智能合约的最小实验，输入合约地址或代码，输出人类可读的逻辑解释

---

## 二、Week 2 问题探索

### AI × Web3 问题地图

**问题地图 + 方向选择**
`tasks/Week2-Problem-Map-and-Direction.md`
6 个方向覆盖：Payment（机器支付/x402）、Identity（能力协作/ERC-8004/MCP）、Wallet（权限控制/EIP-7702）、Privacy（安全主权/ZK+TEE）、Dev Tooling（开发者工具/MCP）、Governance（治理协作/Snapshot）
每个方向分析了 AI 作用 + Web3 机制，选定 Payment 为主要方向

**Week 2 深挖包**
`tasks/Week2-Deep-Dive.md`
综合整理：6 方向地图 + 主方向 Payment 深挖 + Proposal 框架 + 参考资料清单

### 项目拆解（深度研究）

**x402 项目拆解**
`tasks/AIxWeb3-Project-Dissection.md`
x402 HTTP 402 机器支付协议：AI 自主支付 + USDC 稳定币结算 + 链上证明可验证。生产级（75M 笔/月，23 家成员），Stripe/Cloudflare/AWS 已集成

**ERC-8183 Commerce Flow**
`tasks/Agent-Payment-Commerce-Flow.md`
Job Escrow 标准：Open → Funded → Submitted → Completed 完整 commerce flow。角色：Client（委托方）/ Provider（执行方）/ Evaluator（验收方）/ Arbiter（仲裁方）

### 账户与权限

**EOA vs 智能账户 vs 多签**
`tasks/Task-Account-Comparison.md`
EOA：私钥 = 绝对控制权，无中间层；智能账户：控制权在合约逻辑，可编程权限；多签：M-of-N 签名，Gnosis Safe 实现

**Agent Wallet 权限策略**
`tasks/agent-wallet-permission-strategy.md`
预算：单次 ≤0.05 ETH / 每日 ≤0.2 ETH；白名单机制（仅允许 EAS/USDC 白名单地址）；人工确认阈值：单笔 >0.02 ETH / 未知合约 / 频率异常；自动化边界：读取数据自动，approve 修改永久禁止

### 安全分析

**Agent Workflow Threat Model**
`tasks/agent-workflow-threat-model.md`
8 大攻击入口：Prompt Injection / Tool Abuse / 伪造工具返回 / 越权指令 / 会话劫持 / 模型供应商故障 / Calldata 伪装 / 权限升级。分层防御：Policy Engine → Guard → 人工确认，三层拦截

**Agent Profile 设计**
`tasks/agent-profile-design.md`
以 Hermes Agent 为例，分析 Identity / Capability / Protocol / Integration 四个维度，建立 Agent 系统分析方法论

### 典型场景 Demo

**x402 + Cobo CAW Demo**
`tasks/x402-Cobo-CAW-Agent-Payment-Demo.md`
完整支付闭环 Demo：BudgetGuard 预算检查 → CAW 链上 USDC 转账 → tx_hash 作为 payment proof → Server 验证重试。repo: `github.com/chxii/agent-commerce-demo`

**DeFi Swap Assistant**
`tasks/DeFi-Swap-Assistant.md`
受限 Web3 助手设计：只负责规划 / 检查参数 / 解释风险 / 生成交易说明，不持有私钥、不自动签名、不自动转账。解决"用户不知道 Agent 在链上做了什么"的问题

### 治理方向

**LXDAO Governance AI Assistant**
`tasks/LXDAO-Governance-AI-Assistant-Draft.md`
LXDAO 治理结构拆解：Discourse 论坛 / Snapshot 投票 / Fairsharing 贡献记录 / Notion Dashboard。AI 辅助方向：提案总结 / 投票建议 / 行动追踪 / 预算检查

---

## 三、主方向选择路径

```
Week 1: 基础搭建（AI / Web3 / Agent / 工具链）
    ↓
Week 2: 问题探索（6 方向研究 → Payment 方向选定）
    ↓
    支付方向深挖 → x402 + CAW Demo 完成
    → 风险模型建立 → 安全边界清晰
    ↓
Week 3: Z.AI 赛道（Audit Agent）
```

---

## 四、Hackathon 准备状态

**已完成**
- Learning Agent 可用（Hermes Agent + 飞书/微信）
- GitHub repo 有基本结构（notes / prompts / tasks / daily）
- Week 2 问题地图（6 方向，覆盖完整）
- 主方向选定（Week 2 Payment → Week 3 Z.AI Audit Agent）
- Proposal 初稿框架（问题 / 用户 / 最小功能 / 验证方式 / 风险边界）

**待确认 / 待完成**
- Z.AI Audit Agent 方向：proposal 压缩成可执行 MVP
- 队伍信息（单人 / 组队？）
- GLM-5 API 接入方案
- Repo skeleton（Week 4 开发用）
- Week 4 sprint plan

**未完成（缺口）**
- Hackathon 赛道报名
- Demo 具体技术路径（GLM-5 + 静态分析工具选型）
- Sponsor workshop 笔记

---

## 五、关键链接

- 主 Repo：https://github.com/chxii/ai-web3-school-cohort-0
- x402 Demo Repo：https://github.com/chxii/agent-commerce-demo
- Smart Contract Explainer：https://github.com/chxii/smart-contract-explainer
- Z.AI 文档：https://docs.z.ai/devpack/overview
- Z.AI API：https://docs.z.ai/api-reference/introduction
- GLM-5 开源：https://huggingface.co/zai-org/GLM-5.1
- ERC-8183 Sepolia：`0xE7cdb812E2dF3E2898D50b392bF1B3D072eE5d68`