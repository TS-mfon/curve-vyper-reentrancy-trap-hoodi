// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMockToken {
    function mint(address to, uint256 amount) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract CurveVyperReentrancyProtocolMock {
    address public owner;
    address public emergencyModule;
    address public token;
    address public attacker;
    bool public paused;
    bool public staged;
    uint256 public accountedBalance0;
    uint256 public accountedBalance1;
    uint256 public actualBalance0;
    uint256 public actualBalance1;
    uint256 public virtualPrice;
    uint256 public totalSupply;

    error NotOwner();
    error NotEmergencyModule();
    error ProtocolPaused();

    constructor(address token_) {
        owner = msg.sender;
        token = token_;
    }

    function setEmergencyModule(address emergencyModule_) external {
        _claimOwnerIfNeeded();
        if (msg.sender != owner) revert NotOwner();
        emergencyModule = emergencyModule_;
    }

    function setToken(address token_) external {
        _claimOwnerIfNeeded();
        if (msg.sender != owner) revert NotOwner();
        token = token_;
    }

    function seedHealthy(address attacker_) external {
        _claimOwnerIfNeeded();
        if (msg.sender != owner) revert NotOwner();
        attacker = attacker_;
        paused = false;
        staged = false;
        accountedBalance0 = 1_000_000e18;
        accountedBalance1 = 1_000_000e18;
        actualBalance0 = 1_000_000e18;
        actualBalance1 = 1_000_000e18;
        virtualPrice = 1e18;
        totalSupply = 2_000_000e18;
    }

    function stageReentrantReserveMismatch() external {
        if (paused) revert ProtocolPaused();
        accountedBalance0 = 1_000_000e18;
        accountedBalance1 = 1_000_000e18;
        actualBalance0 = 650_000e18;
        actualBalance1 = 1_000_000e18;
        virtualPrice = 7e17;
        totalSupply = 2_000_000e18;
        staged = true;
    }

    function completeReentrantWithdrawal() external {
        if (paused) revert ProtocolPaused();
        require(staged, "EXPLOIT_NOT_STAGED");
        IMockToken(token).mint(attacker, 100e18);
    }

    function emergencyPause() external {
        if (msg.sender != emergencyModule) revert NotEmergencyModule();
        paused = true;
    }

    function attackerBalance() external view returns (uint256) {
        return IMockToken(token).balanceOf(attacker);
    }

    function getMetrics() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool) {
        return (accountedBalance0, accountedBalance1, actualBalance0, actualBalance1, virtualPrice, totalSupply, block.number, paused);
    }

    function _claimOwnerIfNeeded() internal {
        if (owner == address(0)) owner = msg.sender;
    }
}
