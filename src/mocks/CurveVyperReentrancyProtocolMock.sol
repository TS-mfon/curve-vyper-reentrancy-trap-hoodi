// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMockToken {
    function mint(address to, uint256 amount) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract CurveVyperReentrancyProtocolMock {
    address public constant DEFAULT_TOKEN = address(0x0000000000000000000000000000000000002002);
    address public token = DEFAULT_TOKEN;
    address public attacker;
    bool public paused;
    bool public staged;
    uint256 public accountedBalance0;
    uint256 public accountedBalance1;
    uint256 public actualBalance0;
    uint256 public actualBalance1;
    uint256 public virtualPrice;
    uint256 public totalSupply;

    function seedHealthy(address attacker_) external {
        attacker = attacker_;
        if (token == address(0)) token = DEFAULT_TOKEN;
        paused = false;
        staged = false;
        accountedBalance0 = 1_000_000e18;
        accountedBalance1 = 1_000_000e18;
        actualBalance0 = 1_000_000e18;
        actualBalance1 = 1_000_000e18;
        virtualPrice = 1e18;
        totalSupply = 2_000_000e18;
    }

    function setToken(address token_) external {
        token = token_;
    }

    function stageReentrantReserveMismatch() external {
        accountedBalance0 = 1_000_000e18;
        accountedBalance1 = 1_000_000e18;
        actualBalance0 = 650_000e18;
        actualBalance1 = 1_000_000e18;
        virtualPrice = 7e17;
        totalSupply = 2_000_000e18;
        staged = true;
    }

    function completeReentrantWithdrawal() external {
        require(!paused, "PROTOCOL_PAUSED");
        require(staged, "EXPLOIT_NOT_STAGED");
        IMockToken(token).mint(attacker, 100e18);
    }

    function pauseAll() external {
        paused = true;
    }

    function attackerBalance() external view returns (uint256) {
        return IMockToken(token).balanceOf(attacker);
    }

    function getMetrics() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool) {
        return (accountedBalance0, accountedBalance1, actualBalance0, actualBalance1, virtualPrice, totalSupply, block.number, paused);
    }
}
