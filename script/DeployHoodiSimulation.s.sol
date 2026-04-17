// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/mocks/MockToken.sol";
import "../src/mocks/CurveVyperReentrancyProtocolMock.sol";
import "../src/mocks/CurveVyperReentrancyAttacker.sol";
import "../src/CurveVyperReentrancyResponse.sol";

interface VmScript {
    function startBroadcast() external;
    function stopBroadcast() external;
}

contract DeployHoodiSimulation {
    VmScript internal constant vm = VmScript(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct Deployment {
        address token;
        address protocol;
        address attacker;
        address response;
    }

    Deployment public deployment;

    function run() external returns (Deployment memory out) {
        vm.startBroadcast();
        MockToken token = new MockToken();
        CurveVyperReentrancyProtocolMock protocol = new CurveVyperReentrancyProtocolMock();
        CurveVyperReentrancyAttacker attacker = new CurveVyperReentrancyAttacker(address(protocol));
        CurveVyperReentrancyResponse response = new CurveVyperReentrancyResponse();
        protocol.setToken(address(token));
        protocol.seedHealthy(address(attacker));
        out = Deployment(address(token), address(protocol), address(attacker), address(response));
        deployment = out;
        vm.stopBroadcast();
    }
}
