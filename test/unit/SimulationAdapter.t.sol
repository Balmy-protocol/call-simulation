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
    bytes memory _successfulCall = abi.encodeWithSelector(myContract.modifyStorage.selector, _value);
    bytes memory _failedCall = abi.encodeWithSelector(myContract.failWithError.selector, _value);
    bytes[] memory _calls = new bytes[](2);
    _calls[0] = _successfulCall;
    _calls[1] = _failedCall;

    ISimulationAdapter.SimulationResult[] memory _simulationResults = myContract.simulate(_calls);

    assertEq(_simulationResults.length, 2);

    // First one worked
    assertTrue(_simulationResults[0].success);
    assertEq(_simulationResults[0].result, abi.encode(_value));
    assertGt(_simulationResults[0].gasSpent, 0);

    // Second one failed
    assertFalse(_simulationResults[1].success);
    assertEq(_simulationResults[1].result, abi.encodeWithSelector(Failed.selector, _value));
    assertGt(_simulationResults[1].gasSpent, 0);

    // Storage was not modified any of the times
    assertEq(myContract.timesStorageModified(), 0);
  }
}

error Failed(uint256 value);

contract MyContract is SimulationAdapter {
  uint256 public timesStorageModified = 0;

  function modifyStorage(uint256 _value) external returns (uint256 _returnValue) {
    timesStorageModified++;
    _returnValue = _value;
  }

  function failWithError(uint256 _value) external {
    timesStorageModified++;
    revert Failed(_value);
  }
}
