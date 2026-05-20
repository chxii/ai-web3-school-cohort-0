// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

contract SimpleStorage {
    uint256 public number;
    function set(uint256 _number) public {
        number = _number;
    }
}