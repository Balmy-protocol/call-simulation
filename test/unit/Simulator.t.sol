// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
// solhint-disable-next-line no-unused-import
import { Simulator, ISimulator } from "../../src/Simulator.sol";

contract SimulatorTest is PRBTest, StdUtils {
  Simulator internal simulator;
  MyContract internal myContract;

  function setUp() public virtual {
    simulator = new Simulator();
    myContract = new MyContract();
  }

  function testFuzz_simulate(uint256 _value) public {
    vm.deal(address(this), _value);

    bytes memory _successfulCall = abi.encodeWithSelector(myContract.modifyStorage.selector, _value);
    bytes memory _failedCall = abi.encodeWithSelector(myContract.failWithError.selector, _value);
    bytes memory _callWithValue = abi.encodeWithSelector(myContract.modifyStorageWithValue.selector);
    bytes memory _checkSenderCall = abi.encodeWithSelector(myContract.checkSender.selector);
    ISimulator.Call[] memory _calls = new ISimulator.Call[](4);
    _calls[0] = ISimulator.Call({ target: address(myContract), callData: _successfulCall, value: 0 });
    _calls[1] = ISimulator.Call({ target: address(myContract), callData: _failedCall, value: 0 });
    _calls[2] = ISimulator.Call({ target: address(myContract), callData: _callWithValue, value: _value });
    _calls[3] = ISimulator.Call({ target: address(myContract), callData: _checkSenderCall, value: 0 });

    ISimulator.SimulationResult[] memory _simulationResults = simulator.simulate{ value: _value }(_calls);

    assertEq(_simulationResults.length, 4);

    // First one worked
    assertTrue(_simulationResults[0].success);
    assertEq(_simulationResults[0].result, abi.encode(_value), "Call 1 is different");
    assertGt(_simulationResults[0].gasSpent, 0);

    // Second one failed
    assertFalse(_simulationResults[1].success);
    assertEq(_simulationResults[1].result, abi.encodeWithSelector(Failed.selector, _value), "Call 2 is different");
    assertGt(_simulationResults[1].gasSpent, 0);

    // Third one worked
    assertTrue(_simulationResults[2].success);
    assertEq(_simulationResults[2].result, abi.encode(_value), "Call 3 is different");
    assertGt(_simulationResults[2].gasSpent, 0);

    // Forth one worked
    assertTrue(_simulationResults[3].success);
    assertEq(_simulationResults[3].result, abi.encode(address(simulator)), "Call 4 is different");
    assertGt(_simulationResults[3].gasSpent, 0);

    // Storage was not modified any of the times
    assertEq(myContract.timesStorageModified(), 0);
  }
}

error Failed(uint256 value);

contract MyContract {
  uint256 public timesStorageModified = 0;

  function modifyStorage(uint256 _value) external returns (uint256 _returnValue) {
    timesStorageModified++;
    _returnValue = _value;
  }

  function failWithError(uint256 _value) external {
    timesStorageModified++;
    revert Failed(_value);
  }

  function modifyStorageWithValue() external payable returns (uint256 _returnValue) {
    timesStorageModified++;
    _returnValue = msg.value;
  }

  function checkSender() external returns (address _returnValue) {
    timesStorageModified++;
    _returnValue = msg.sender;
  }
}
