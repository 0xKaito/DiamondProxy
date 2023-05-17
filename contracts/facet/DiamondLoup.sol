// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.18;


import { LibDiamond } from  "../library/LibDiamond.sol";

interface IDiamondLoupe {

    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    function facets() external view returns (Facet[] memory facets_);

    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);

    function facetAddresses() external view returns (address[] memory facetAddresses_);

    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);
}

contract DiamondLoupeFacet is IDiamondLoupe {
 
    /// @notice Gets all facets and their selectors.
    /// @return facets_ Facet
    function facets() external view returns (Facet[] memory facets_){
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 totalselector = ds.selector.length;

    }
    
    /// @notice Gets all the function selectors supported by a specific facet.
    /// @param _facet The facet address.
    /// @return facetFunctionSelectors The selectors associated with a facet address.
    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors){
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 totalselector = ds.selector.length;
        uint256 num;
        facetFunctionSelectors = new bytes4[](totalselector);
        for (uint256 index; index < totalselector; index++) {
            bytes4 selector = ds.selector[index];
            address facet = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            if (_facet == facet) {
                facetFunctionSelectors[num] = selector;
                num++;
            }
        }
    }

    /// @notice Get all the facet addresses used by a diamond.
    /// @return facetAddresses_
    function facetAddresses() external view returns (address[] memory facetAddresses_){
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 totalselector = ds.selector.length;
        uint256 num;
        facetAddresses_ = new address[](totalselector);
        for (uint256 index; index < totalselector; index++) {
            bytes4 selector = ds.selector[index];
            address facet = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            bool exist = false;
            for (uint256 indexfacetAddresses_; indexfacetAddresses_ < num; ++indexfacetAddresses_){
                if(facet == facetAddresses_[indexfacetAddresses_]){
                    exist = true;
                    break;
                }
            }
            if(!exist){
                facetAddresses_[num] = facet;
                num++;
                continue;
            }
            exist = false;
        }
    }

    /// @notice Gets the facet address that supports the given selector.
    /// @dev If facet is not found return address(0).
    /// @param _functionSelector The function selector.
    /// @return facetAddress_ The facet address.
    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_){
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddress_ = ds.facetAddressAndSelectorPosition[_functionSelector].facetAddress;
    }
}