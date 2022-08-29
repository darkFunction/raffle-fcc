// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import "../src/Raffle.sol";
import "chainlink/mocks/VRFCoordinatorV2Mock.sol";

contract DeployLocal is Script {
    /* Constants */
    uint256 public immutable ENTRANCE_FEE = 0.1 ether;
    uint96 public immutable BASE_FEE = 0.25 ether;
    uint96 public immutable GAS_PRICE_LINK = 1000000000;
    bytes32 public immutable GOERLI_GAS_LANE =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint32 public immutable CALLBACK_GAS_LIMIT = 500000;
    uint256 public immutable INTERVAL = 30;

    /* State variables */
    VRFCoordinatorV2Mock public mockCoordinator;
    Raffle public raffle;

    function run() external {
        vm.startBroadcast();

        console.log("Deploying mock VRFCoordinatorV2");
        mockCoordinator = new VRFCoordinatorV2Mock(BASE_FEE, GAS_PRICE_LINK);
        console.log("Coordinator deployed:", address(mockCoordinator));

        console.log("Creating mock VRF subscription");
        uint64 subId = mockCoordinator.createSubscription();
        mockCoordinator.fundSubscription(subId, 10 ether);
        console.log("Mock subscription created: ", subId);

        console.log("Deploying Raffle");
        raffle = new Raffle(
            address(mockCoordinator),
            0.1 ether,
            GOERLI_GAS_LANE,
            subId,
            CALLBACK_GAS_LIMIT,
            INTERVAL
        );
        console.log("Deployed Raffle contract");

        console.log("Adding Raffle contract as coordinator consumer");
        mockCoordinator.addConsumer(subId, address(raffle));

        vm.stopBroadcast();
    }
}
