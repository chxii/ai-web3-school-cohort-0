# LXDAO Governance AI Assistant — Proposal Draft

> 基于实际采集的 LXDAO 治理数据草拟。标注 `[AI]` 为 AI 辅助总结，`[HUMAN]` 为必须人工或治理流程确认的步骤。

---

## 一、核心治理架构（已确认）

| 组件 | 工具 | 链接 |
|------|------|------|
| 治理论坛 | Discourse | https://forum.lxdao.io/c/governance/10 |
| Snapshot 投票 | Snapshot (offchain) | https://snapshot.box/#/s:lxdao.eth |
| 社区周会 | Zoom，每週六 11:00 UTC+8 | https://s.lxdao.io/CC |
| 月度 AMA | Forum category | https://forum.lxdao.io/c/governance/monthly-ama/12 |
| 贡献记录 | Fairsharing | app.fairsharing.xyz/project/0xBeB6a348dBd5362312daafc60C1A66D29Be56Ced/contribution |
| Dashboard | Notion | https://www.notion.so/lxdao/LXDAO-Dashboard-253dceffe40b80efadf0dab89a1e33a9 |
| 预算追踪 | Forum tag: account | https://forum.lxdao.io/tag/account |
| Gitbook Docs | Gitbook | https://docs.lxdao.io/ |

### Season 周期（来源：LIP13）
- **每季时长**：3 个月（2022/06/01 起）
- **Pre-season**：每季最后一个月 = 提案讨论期
- **预算申请截止**：季开始前 2 周须在 Snapshot 提交
- **Strategy Meeting**：每季最后一个月，由 Governance Team 主持，总结上季、规划下季

### 组织结构（来源：LIP13）
- **Working Groups**：运营 / 治理 / DAO Tools / 技术专家组 / SteadyForce / Financing
- **Project Teams**：独立于 Season 运作，季末须提交里程碑总结
- **Buidler Card**：发起项目必须持有（身份体系）

---

## 二、提案生命周期（来源：LIP13 + Budget Framework）

```
Step 0: Pre-Season Discussion（每季最后1个月）
  [HUMAN] Governance Team 发起下季提案讨论
  [HUMAN] 社区成员提出 Working Group 增减、Leader 轮换、项目提案

Step 1: Ideation → Soft Vote（Forum）
  [AI] 总结相关帖子、主要争论点
  [AI] 检查是否已有类似提案、建议合并
  [HUMAN] 提案者 Forum 发帖
  [HUMAN] Forum 软投票（民间投票，非正式）

Step 2: Proposal Draft（提案撰写）
  [AI] 生成提案草案摘要（背景/目标/预算/里程碑/SMART目标）
  [AI] 格式化预算数字 → 符合 Season Budget 模板
  [AI] 检查提案必含要素：Background、Why、What、How、Personnel、Funding、Income/Expenditure rules、Key goals
  [HUMAN] 提案者用 template 正式撰写（LIP template: https://forum.lxdao.io/t/lxdao-proposal-templates/620）

Step 3: Governance WG Review
  [AI] 整理 Forum 所有意见 → 提炼支持/反对理由
  [AI] 对齐预算请求 vs Season 可用预算 → 给出建议
  [HUMAN] 提案提交给 Governance WG
  [HUMAN] Governance WG 审核格式 + 逻辑
  [HUMAN] 如需调整 → 退回提案者修改

Step 4: Snapshot Vote（季开始前 2 周）
  [AI] 生成投票摘要卡片（提案目标/预算/里程碑/KPI/来源链接）
  [AI] 标注不确定项
  [HUMAN] Governance WG 创建 Snapshot 提案
  [HUMAN] 须在 Snapshot 附带：上季总结、目标达成、收支、剩余资产
  [HUMAN] DAO 成员投票（token holder 或成员资格）
  [HUMAN] 通过阈值 → 进入执行阶段

Step 5: Execution（Season 执行中）
  [AI] 月度自动检查：里程碑进度 vs KPI
  [AI] 异常提醒：某项目 2 周无更新 → 自动通知
  [AI] 生成月度财务报表
  [HUMAN] PM 每周参加周会汇报 + 输出周报
  [HUMAN] PM 每月提交支出报告（cost statement）给 Governance WG
  [HUMAN] Governance WG 审核 + 公示（Forum tag: account）
  [HUMAN] 如有偏差 → 需重新提案批准
  [HUMAN] 外部专家评审：项目未达里程碑 → 专家工作组评审

Step 6: Season End → 循环回 Step 0
  [AI] 汇总本季所有项目进展 → 生成 Strategy Meeting 材料
  [HUMAN] Strategy Meeting 总结上季、规划下季
```

---

## 三、周会 → Action Items 工作流（Meeting-to-Action）

来源：LXDAO Community Call #203 实际议程结构

```
会前（24h 内）
  [AI] 抓取上周 Forum 新帖 + 热门讨论 → 生成议题摘要
  [AI] 检查 Notion Dashboard 更新 → 提取有进展的项目列表
  [AI] 汇总本周投票结果（Snapshot）→ 列出需跟进项

会中（约 1 小时）
  环节 1：周度数据复盘
    [AI] 自动拉取 Notion Dashboard 数据 → 格式化展示（成员数/活跃/成果）
    [HUMAN] 治理组确认数据准确性

  环节 2：Dashboard 项目进展同步
    [AI] 汇总各项目最新状态，标注有更新的
    [AI] 标注"卡点"项目（2 周无更新）
    [HUMAN] 项目发言人确认进展、提出卡点
    [HUMAN] 需要帮助的当场号召人跟进

  环节 3：重点话题讨论（来自 Forum 回复/群内/Snapshot 结果）
    [AI] 抓取 Forum 本周热门帖 → 提炼争论焦点 + 链接
    [HUMAN] 社区成员举手发言
    [HUMAN] 需决策事项 → 当场宣布后续 Forum 发帖计划

  环节 4：新成员自我介绍
    [HUMAN] 成员自行介绍（无法自动化）
    [HUMAN] 引导新成员完成 onboarding：官网注册 + 联系运营加群

  环节 5：Random Talk

会后（24h 内）
  [AI] 生成会议纪要（讨论了什么/决定了什么）
  [AI] 识别 Action Items：任务 + Owner + Deadline + 是否含预算影响
  [AI] 发布到 Forum（Category: Community Call）

人工确认（会后 48h 内）
  [HUMAN] 主持人 review 会议纪要 + 确认发布
  [HUMAN] Owner 确认认领 Action Items
  [HUMAN] 需决策事项 → 在 Forum 对应 category 发帖
```

---

## 四、贡献记录 & 激励执行（Contribution Tracker）

来源：LXDAO 2026 April Incentive Announcement（Fairsharing 数据结构）

```
每月激励发放流程：
  [AI] 从 Fairsharing 导出本期贡献数据
       Fields: Name | POC on FS (贡献分) | USD | Address | Note

  [AI] 交叉检查：
       - Address 格式校验
       - POC on FS vs USD 汇率检查
       - 检测超过岗位最大预算（如：Lynn 岗位最大 1000U）
       - 检测缺失字段

  [AI] 生成汇总表 + 异常报告

  [HUMAN] Governance Team (wodeche 等) review 数据
  [HUMAN] 如有异常 → 联系相关人确认
  [HUMAN] Forum 发布 Incentive Announcement（含完整表格）
  [HUMAN] Multi-sig 签名执行链上转账

Budget Checklist（每月末）：
  □ Governance Team 计算：expense + revenue + 剩余资产
  □ 每个项目组 KPI 完成度检查
  □ 超预算项目标记 → 要求 PM 解释
  □ 外部专家评审：未达里程碑的项目
  □ 财务报表公示（Forum tag: account）
  □ 下一季预算提案准备（Pre-season 第一周）
```

---

## 五、关键治理边界

| 场景 | AI 能做什么 | 不能交给 AI |
|------|------------|------------|
| 预算批准 | 计算可用预算、检测超支 | **批准预算** — 必须 Snapshot 投票 |
| 提案通过 | 总结利弊、格式化卡片 | **决定提案命运** — 必须 DAO 投票 |
| 激励发放 | 汇总数据、检查异常 | **确认发放金额** — 必须人工 review |
| 项目评估 | 追踪 KPI、标记异常 | **外部专家评审结论** — 须人工判断 |
| 惩罚/激励 | 提醒某项目未达 KPI | **做出惩罚决定** — 须治理组提出 + 投票 |
| 成员加入 | 检查 Buidler Card 状态 | **批准加入** — 须人工 + Forum 流程 |
| 不可逆动作 | 提示即将执行的操作 | **执行链上转账** — 须 multi-sig |
| PM 替换 | 提醒需要替换 | **替换 PM** — 须 Forum 公示 + 讨论 |

---



## 数据来源

| 来源 | 采集内容 |
|------|----------|
| LXDAO Introduction Page | 治理组件工具列表 |
| Community Call #203 帖 | 周会议程结构 |
| LIP13（Season + Org Structure）| Season 定义/组织结构/提案流程/Working Group formation |
| Budget Framework（Marcus, Mar 2023）| 预算框架/月度报表/KPI 追踪 |
| 2026 April Incentive Announcement | Fairsharing 贡献数据结构/激励发放流程 |
| Governance Forum | 工作组列表/投票/Snapshot 提案 |
| docs.lxdao.io | 页面结构（部分 404） |

