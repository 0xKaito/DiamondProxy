// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.storage");

    struct DiamondStorage {
        address owner;
        mapping(bytes4 => address) facetAddress;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
