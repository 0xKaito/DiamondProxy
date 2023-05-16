// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

library FacetALib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.FacetA.storage");

    struct TestState {
        uint256 myNum;
    }

    function diamondStorage() internal pure returns (TestState storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}

contract FacetA {
    ///@dev update myNum to _var1 integer
    ///@param _var1 unsigned integer
    function setNum(uint256 _var1) external {
        FacetALib.diamondStorage().myNum = _var1;
    }
}
