// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { LibDiamond } from "./library/LibDiamond.sol";

error FunctionNotFound(bytes4 _functionSelector);

contract Diamond {    

    event DiamondCut(bytes4 _selector, address _facet, string _action);

    ///@notice inititalize owner eqaul to contract deployer
    constructor() payable {
        LibDiamond.diamondStorage().owner = msg.sender;
    }
    
    ///@notice add new function in facet
    ///@dev add new _selector in _implementation facet
    ///@param _selector signature of new function
    ///@param _implementation address of facet
    function addSelector(bytes4 _selector, address _implementation) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 selectorCount = ds.selector.length;
        require(ds.owner == msg.sender, "not owner");
        address facet = ds.facetAddressAndSelectorPosition[_selector].facetAddress;
        require(facet == address(0), "function selector already exist");
        ds.facetAddressAndSelectorPosition[_selector] = LibDiamond.FacetAddressAndSelectorPosition(_implementation, selectorCount);
        ds.selector.push(_selector);
        emit DiamondCut(_selector, _implementation, "Add");
    }

    ///@notice remove function from facet
    ///@dev remove selector from _implementation facet
    ///@param _selector signature of function
    function removeSelector(bytes4 _selector) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.owner == msg.sender, "not owner");
        LibDiamond.FacetAddressAndSelectorPosition memory facetAndPosition = ds.facetAddressAndSelectorPosition[_selector];
        if(facetAndPosition.facetAddress == address(0)) {
            revert FunctionNotFound(_selector);
        }
        uint256 selectorCount = ds.selector.length - 1;
        if(ds.facetAddressAndSelectorPosition[_selector].selectorPosition != selectorCount){
            bytes4 lastSelector = ds.selector[selectorCount];
            ds.selector[facetAndPosition.selectorPosition] = lastSelector;
            ds.facetAddressAndSelectorPosition[lastSelector].selectorPosition = facetAndPosition.selectorPosition;
        }
        ds.selector.pop();
        delete ds.facetAddressAndSelectorPosition[_selector];
        emit DiamondCut(_selector, facetAndPosition.facetAddress, "Remove");
    }

    ///@dev replace _selector from old facet to _implementation facet
    ///@param _selector signature of new function
    ///@param _implementation address of facet
    function replaceSelector(bytes4 _selector, address _implementation) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.owner == msg.sender, "not owner");
        address facet = ds.facetAddressAndSelectorPosition[_selector].facetAddress;
        if(facet == address(0)) {
            revert FunctionNotFound(_selector);
        }
        ds.facetAddressAndSelectorPosition[_selector].facetAddress = _implementation;
        emit DiamondCut(_selector, _implementation, "Replace");
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address facet = ds.facetAddressAndSelectorPosition[msg.sig].facetAddress;
        if(facet == address(0)) {
            revert FunctionNotFound(msg.sig);
        }
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}
