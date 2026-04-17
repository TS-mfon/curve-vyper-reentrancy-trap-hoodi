// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/mocks/MockToken.sol";
import "../src/mocks/CurveVyperReentrancyProtocolMock.sol";
import "../src/mocks/CurveVyperReentrancyAttacker.sol";
import "../src/CurveVyperReentrancyResponse.sol";
import "../src/CurveVyperReentrancyEnvironmentRegistry.sol";

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
        address registry;
    }

    function run() external returns (Deployment memory out) {
        vm.startBroadcast();
        MockToken token = new MockToken();
        CurveVyperReentrancyProtocolMock protocol = new CurveVyperReentrancyProtocolMock(address(token));
        CurveVyperReentrancyAttacker attacker = new CurveVyperReentrancyAttacker(address(protocol));
        CurveVyperReentrancyResponse response = new CurveVyperReentrancyResponse();
        protocol.setEmergencyModule(address(response));
        protocol.seedHealthy(address(attacker));
        CurveVyperReentrancyEnvironmentRegistry registry = new CurveVyperReentrancyEnvironmentRegistry(keccak256("curve-vyper-reentrancy-trap-hoodi"), address(protocol), address(response), address(response), true);
        out = Deployment(address(token), address(protocol), address(attacker), address(response), address(registry));
        vm.stopBroadcast();
    }
}
