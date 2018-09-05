pragma solidity ^0.4.18;

import "./Registrar.sol";

/**
 * A simple resolver anyone can use; only allows the owner of a node to set its
 * address.
 */
contract Resolver {

    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant MULTIHASH_INTERFACE_ID = 0xe89401a1;

    event AddrChanged(bytes32 indexed node, address a);
    event MultihashChanged(bytes32 indexed node, bytes hash);

    struct Record {
        address addr;
        bytes multihash;
    }

    Registrar registrar;

    mapping (bytes32 => Record) records;

    // Make sure that the owner
    modifier only_owner(bytes32 node) {
        require(registrar.owner(node) == msg.sender);
        _;
    }

    /**
     * Constructor.
     * @param registrarAddr The ENS registrar contract.
     */
    function PublicResolver(Registrar registrarAddr) public {
        registrar = registrarAddr;
    }

    /**
     * Sets the address associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param addr The address to set.
     */
    function setAddr(bytes32 node, address addr) public only_owner(node) {
        records[node].addr = addr;
        AddrChanged(node, addr);
    }

    /**
     * Sets the multihash associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param hash The multihash to set
     */
    function setMultihash(bytes32 node, bytes hash) public only_owner(node) {
        records[node].multihash = hash;
        MultihashChanged(node, hash);
    }

    /**
     * Returns the multihash associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated multihash.
     */
    function multihash(bytes32 node) public view returns (bytes) {
        return records[node].multihash;
    }

    /**
     * Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) public view returns (address) {
        return records[node].addr;
    }

    /**
     * Returns true if the resolver implements the interface specified by the provided hash.
     * @param interfaceID The ID of the interface to check for.
     * @return True if the contract implements the requested interface.
     */
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == ADDR_INTERFACE_ID ||
        interfaceID == MULTIHASH_INTERFACE_ID;
    }
}