// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Raffle.sol";
import "chainlink/mocks/VRFCoordinatorV2Mock.sol";
import "../script/DeployLocal.s.sol";
import {console} from "forge-std/console.sol";
import "openzepplin/utils/Strings.sol";

contract RaffleTest is Test {
    /* State variables */
    DeployLocal private deployment;
    VRFCoordinatorV2Mock private vrfCoordinatorMock;
    Raffle private raffle;
    uint256 private entranceFee;

    function setUp() public {
        deployment = new DeployLocal();
        deployment.run();
        raffle = deployment.raffle();
        vrfCoordinatorMock = deployment.mockCoordinator();
        entranceFee = deployment.ENTRANCE_FEE();
    }

    function test_whenInitialised_thenStateIsCorrect() public {
        assertEq(
            uint256(Raffle.RaffleState.OPEN),
            uint256(raffle.getRaffleState())
        );
        assertEq(raffle.getEntranceFee(), deployment.ENTRANCE_FEE());
        assertEq(raffle.getInterval(), deployment.INTERVAL());
    }

    function test_whenRaffleEntered_andPaymentIsTooLow_thenReverts() public {
        vm.expectRevert(Raffle__NotEnoughETHEntered.selector);
        raffle.enterRaffle();
    }

    function test_whenRaffleEntered_thenRecordsPlayers() public {
        hoax(address(0x1));
        raffle.enterRaffle{value: entranceFee}();
        assertEq(raffle.getPlayer(0), address(0x1));
    }

    function test_whenRaffleEntered_thenEmitsEvent() public {
        vm.expectEmit(true, false, false, false);
        emit RaffleEnter(address(0x1));
        hoax(address(0x1));
        raffle.enterRaffle{value: entranceFee}();
    }

    function test_whenRaffleEntered_andStateIsCalculating_thenReverts() public {
        warpRaffleInterval();
        hoax(address(0x1));
        raffle.enterRaffle{value: entranceFee}();
        raffle.performUpkeep(bytes(""));
        hoax(address(0x2));
        vm.expectRevert(Raffle__NotOpen.selector);
        raffle.enterRaffle{value: entranceFee}();
    }

    function test_givenNoValueInRaffle_whenCheckUpkeep_thenReturnsFalse()
        public
    {
        warpRaffleInterval();
        (bool upkeepNeeded, ) = raffle.checkUpkeep(bytes(""));
        assertEq(false, upkeepNeeded);
    }

    function test_givenRaffleNotOpen_whenCheckUpkeep_thenReturnsFalse() public {
        hoax(address(0x1));
        raffle.enterRaffle{value: entranceFee}();
        warpRaffleInterval();
        raffle.performUpkeep(bytes(""));
        assertEq(
            uint256(raffle.getRaffleState()),
            uint256(Raffle.RaffleState.CALCULATING)
        );
        (bool upkeepNeeded, ) = raffle.checkUpkeep(bytes(""));
        assertFalse(upkeepNeeded);
    }

    /* Utility functions */
    function warpRaffleInterval() private {
        vm.warp(
            block.timestamp + raffle.getLatestTimestap() + raffle.getInterval()
        );
    }

    /* Raffle events */
    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);
}
