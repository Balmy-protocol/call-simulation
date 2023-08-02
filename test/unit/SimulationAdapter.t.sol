// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { StdUtils } from "forge-std/StdUtils.sol";
// solhint-disable-next-line no-unused-import
import { IERC165 } from "../../src/interfaces/external/IERC165.sol";
import { SimulationAdapter, ISimulationAdapter } from "../../src/SimulationAdapter.sol";

contract SimulationAdapterTest is PRBTest, StdUtils {
  MyContract internal myContract;

  function setUp() public virtual {
    myContract = new MyContract();
  }

  function test_supportsInterface() public {
    assertTrue(myContract.supportsInterface(type(ISimulationAdapter).interfaceId));
    assertTrue(myContract.supportsInterface(type(IERC165).interfaceId));
    assertFalse(myContract.supportsInterface(0xffffffff));
  }

  function testFuzz_simulate(uint256 _value) public {
    vm.deal(address(this), _value);

    bytes memory _successfulCall = abi.encodeWithSelector(myContract.modifyStorage.selector, _value);
    bytes memory _failedCall = abi.encodeWithSelector(myContract.failWithError.selector, _value);
    bytes memory _callWithValue = abi.encodeWithSelector(myContract.modifyStorageWithValue.selector);
    bytes[] memory _calls = new bytes[](3);
    _calls[0] = _successfulCall;
    _calls[1] = _failedCall;
    _calls[2] = _callWithValue;

    ISimulationAdapter.SimulationResult[] memory _simulationResults = myContract.simulate{value: _value}(_calls);

    assertEq(_simulationResults.length, 3);

    // First one worked
    assertTrue(_simulationResults[0].success);
    assertEq(_simulationResults[0].result, abi.encode(_value), 'Call 1 is different');
    assertGt(_simulationResults[0].gasSpent, 0);

    // Second one failed
    assertFalse(_simulationResults[1].success);
    assertEq(_simulationResults[1].result, abi.encodeWithSelector(Failed.selector, _value), 'Call 2 is different');
    assertGt(_simulationResults[1].gasSpent, 0);

    // Third one worked
    assertTrue(_simulationResults[2].success);
    assertEq(_simulationResults[2].result, abi.encode(_value), 'Call 3 is different');
    assertGt(_simulationResults[2].gasSpent, 0);

    // Storage was not modified any of the times
    assertEq(myContract.timesStorageModified(), 0);
  }
}

error Failed(uint256 value);

contract MyContract is SimulationAdapter {
  uint256 public timesStorageModified = 0;

  function modifyStorage(uint256 _value) external payable returns (uint256 _returnValue) {
    timesStorageModified++;
    _returnValue = _value;
  }

  function failWithError(uint256 _value) external payable {
    timesStorageModified++;
    revert Failed(_value);
  }

  function modifyStorageWithValue() external payable returns (uint256 _returnValue) {
    timesStorageModified++;
    _returnValue = msg.value;
  }
}
