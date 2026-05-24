# Week 1 Proof-of-Work Pack

> AI × Web3 School — Week 1 (2026-05-18 ~ 2026-05-24)
> 仓库：https://github.com/chxii/ai-web3-school-cohort-0

---

## 一、AI 学习记录

### AI 基础概念卡片
📄 [tasks/AI-Basic-Concepts.md](https://github.com/chxii/ai-web3-school-cohort-0/blob/master/tasks/AI-Basic-Concepts.md)

涵盖：LLM / Prompt Engineering / RAG / Fine-tuning / AI Agent 核心概念。

### Learning Agent 实践记录
已安装配置 Hermes Agent，接入飞书 + 微信，实现自然语言操控 GitHub、读写文件、搜索网页等。

---

## 二、AI 工具实践产物

### Smart Contract Explainer
🔗 [github.com/chxii/smart-contract-explainer](https://github.com/chxii/smart-contract-explainer)
AI 辅助理解 Solidity 智能合约的最小实验项目。

---

## 三、Web3 概念卡片

### Web3 基础概念卡片
📄 [tasks/Web3 基础概念卡片.md](https://github.com/chxii/ai-web3-school-cohort-0/blob/master/tasks/Web3%20%E5%9F%BA%E7%A1%80%E6%A6%82%E5%BF%B5%E5%8D%A7.md)

涵盖：Wallet / EOA / Smart Contract / ENS / DApp / Token 标准。

---

## 四、测试网交易记录

### 一笔 ETH 转账（Sepolia）
| 字段 | 值 |
|------|-----|
| 测试网 | Sepolia |
| 钱包地址 | `0x76Aa2DB47B66556D353F0a7Fc95a49FD8Bf90f59` |
| 交易哈希 | `0xf3ec5e31582bebc2acca8b2d0d1802bd25b53746801851c578fdf35f2bb5c74a` |
| 区块浏览器 | [Etherscan Sepolia](https://sepolia.etherscan.io/tx/0xf3ec5e31582bebc2acca8b2d0d1802bd25b53746801851c578fdf35f2bb5c74a) |
| 区块高度 | #10883930 |
| 金额 | 0.001 ETH |
| Gas 消耗 | 21,000（Limit: 31,500） |
| 手续费 | 0.0000419 ETH |
| 状态 | ✅ Success（4 个区块确认） |
| 时间 | 2026-05-20 05:45:36 UTC |

### 智能合约部署
📁 [tasks/Task-SmartContract/](https://github.com/chxii/ai-web3-school-cohort-0/tree/master/tasks/Task-SmartContract)

最小 Solidity 合约：部署 + 调用全流程记录。

### 账户类型权限对比
📄 [tasks/Task-Account-Comparison.md](https://github.com/chxii/ai-web3-school-cohort-0/blob/master/tasks/Task-Account-Comparison.md)

对比 EOA、Smart Account、多签的权限差异。

---

## 五、AI × Web3 最小交叉实验

### 流程图
🌐 [tasks/AI-Web3-Basic-Workflow-Diagram.html](https://github.com/chxii/ai-web3-school-cohort-0/blob/master/tasks/AI-Web3-Basic-Workflow-Diagram.html)

展示：用户 → LLM → Agent → 链上合约调用的完整流程。

### DeFi Swap 助手设计
📄 [tasks/DeFi-Swap-Assistant.md](https://github.com/chxii/ai-web3-school-cohort-0/blob/master/tasks/DeFi-Swap-Assistant.md)

一个受限 Web3 助手的设计规范：只读查询、有限 Swap 操作、多重签名保护。

### AI × Web3 项目拆解
📄 [tasks/AIxWeb3-Project-Dissection.md](https://github.com/chxii/ai-web3-school-cohort-0/blob/master/tasks/AIxWeb3-Project-Dissection.md)

拆解了 2 个真实项目：
1. **x402** — HTTP 402 机器支付协议，AI Agent 自主付费调用 API
2. **ERC-8004** — 链上 AI Agent 身份与信誉注册表（Trustless Agents）

---

## 六、问题与修正记录

### 问题：GitHub Push 443 超时
- **现象**：`git push` 时 `github.com:443` 连接超时，但 `api.github.com` 正常。
- **根因**：腾讯云服务器对 `github.com` 域名 443 端口受限。
- **修正**：改用 `git@github.com:chxii/ai-web3-school-cohort-0.git` SSH 地址，配合 `master` 分支名手动指定。
- **验证**：✅ Push 成功，commit `6dbcac5` 已出现在仓库。

---

## 七、每日学习日志

| 日期 | 主题 |
|------|------|
| 2026-05-18 | AI × Web3 开营、环境配置、GitHub SSH |
| 2026-05-19 | Web3 基础概念：Wallet / EOA / Smart Contract |
| 2026-05-20 | Sepolia 测试网领取 ETH + 第一笔链上交易 |
| 2026-05-21 | Learning Agent 实践、智能合约部署 |
| 2026-05-22 | EVM / Gas / 账户类型对比 |
| 2026-05-23 | 项目拆解、DeFi Swap Assistant 设计 |
| 2026-05-24 | Web3 底层架构：共识 / 执行层 / 协议分层 |

详细日志：📁 [daily/](https://github.com/chxii/ai-web3-school-cohort-0/tree/master/daily)

---

*Last updated: 2026-05-24*