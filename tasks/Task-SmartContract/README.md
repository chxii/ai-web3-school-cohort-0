# Task: Smart Contract Deployment

## 1. 合约地址

```
0x85C6F429c85e0083c1AEfe0feb2151D302720307
```

Sepolia Etherscan: https://sepolia.etherscan.io/address/0x85C6F429c85e0083c1AEfe0feb2151D302720307

## 2. 部署交易哈希

```
0x0f0b2ae49defb052fd9b945ad09cd19f3b0a51ca8b0c382f0a791ad28c29b01d
```

https://sepolia.etherscan.io/tx/0x0f0b2ae49defb052fd9b945ad09cd19f3b0a51ca8b0c382f0a791ad28c29b01d

## 3. 读取 / 写入结果

| 操作 | 结果 |
|------|------|
| Read `number()` | 初始值 0 |
| Write `set(42)` | 交易 `0x51d172a08915482a3603a0384e2e8270eda97b66289736f81b29d218b051bf12`，链上确认后 `number()` 返回 42 |
| 写入交易链接 | https://sepolia.etherscan.io/tx/0x51d172a08915482a3603a0384e2e8270eda97b66289736f81b29d218b051bf12 |

## 4. 代码

- 文件: `tasks/Task-SmartContract/simpleStorage.sol`
- Remix IDE: https://remix.ethereum.org/

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

contract SimpleStorage {
    uint256 public number;
    function set(uint256 _number) public {
        number = _number;
    }
}
```

## 5. 说明

部署了最小存储合约 SimpleStorage，包含一个 `number` 状态变量，初始值为 0。调用 `set(42)` 将链上存储值修改为 42。Read 操作免费且无需钱包签名，Write 操作需要 MetaMask 签名并支付 Gas（人工确认点：点 Deploy 的 Confirm、点 set 的 Confirm）。合约永久保存在 Sepolia 网络，任何人都可以调用 Read 查询当前值。
