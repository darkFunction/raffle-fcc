// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Raffle.sol";
import "chainlink/mocks/VRFCoordinatorV2Mock.sol";
import "../script/DeployLocal.s.sol";
import {console} from "forge-std/console.sol";

contract RaffleTest is Test {
    /* State variables */
    DeployLocal private deployment;
    VRFCoordinatorV2Interface private vrfCoordinatorMock;
    Raffle private raffle;

    function setUp() public {
        deployment = new DeployLocal();
        deployment.run();
        raffle = deployment.raffle();
        vrfCoordinatorMock = deployment.coordinator();
    }

    function test_whenInitialised_thenStateIsCorrect() public {
        console.log(""); //raffle.getRaffleState());
        assertEq(raffle.getRaffleState(), uint256(0));
        assertEq(raffle.getEntranceFee(), deployment.ENTRANCE_FEE());
    }
}
