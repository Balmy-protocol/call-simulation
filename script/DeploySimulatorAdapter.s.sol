// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { console2 } from "forge-std/console2.sol";
import { Simulator } from "../src/Simulator.sol";
import { BaseScript } from "./Base.s.sol";

bytes32 constant SALT = bytes32(
  uint256(56_695_679_612_138_000_431_577_699_311_877_947_994_212_843_972_045_166_829_844_248_425_940_608_660_468)
);

contract DeploySimulatorAdapter is BaseScript {
  function run() public broadcaster returns (Simulator _simulator) {
    _simulator = new Simulator{salt: SALT}();
    console2.log("Simulator Deployed:", address(_simulator));
  }
}
