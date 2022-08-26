// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Raffle.sol"

contract RaffleScript is Script {
    
    function run() external {
        vm.startBroadcast();
        
        Raffle raffle = new Raffle(
            
        )

        vm.stopBroadcast();
    }
}
