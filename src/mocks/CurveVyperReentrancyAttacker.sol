// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CurveVyperReentrancyProtocolMock.sol";

contract CurveVyperReentrancyAttacker {
    CurveVyperReentrancyProtocolMock public immutable protocol;

    constructor(address target) {
        protocol = CurveVyperReentrancyProtocolMock(target);
    }

    function stageExploit() external {
        protocol.stageReentrantReserveMismatch();
    }

    function completeExploit() external {
        protocol.completeReentrantWithdrawal();
    }
}
