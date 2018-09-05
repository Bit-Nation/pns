pragma solidity ^0.4.24;

import "./ENS.sol";
import "./ManagedDomainOwner.sol";
import "./Ownable.sol";

contract Registrar is Ownable {

    struct Record {
        address owner;
        uint ttl;
    }

    mapping (bytes32 => Record) owners;

    uint pricePerMonth;
    bytes32 rootNode;
    address domainOwnerAddress;
    ManagedDomainOwner domainOwner;
    address ens;

    /**
     * Constructor.
     * @param _ownerAddr The address of the Domain Owner contract.
     * @param _rootNode The node that bitnation is being registered under
     * @param _ensAddr The address of the ENS registry
     */
    constructor(address _ownerAddr, bytes32 _rootNode, address _ensAddr, uint _pricePerMonth) public {
        domainOwner = ManagedDomainOwner(_ownerAddr);
        domainOwnerAddress = _ownerAddr;
        rootNode = _rootNode;
        ens = _ensAddr;
        pricePerMonth = _pricePerMonth;
    }

    /**
     * Set a new price per week. Only callable by owner
     * @param _newPrice The new price per week in WEI
     */
    function setPricePerWeek(uint _newPrice) public onlyOwner() {
        pricePerMonth = _newPrice;
    }


    /**
    * Register a sub domain under another domain. The msg.sender must own the node the subdomain
    * is being registered under.
    * @param _node The main node that is being registered under
    * @param _subnodeLabel The label of the subnode that is being registered
    * @param _setTTL The timeout for the domain
    */
    function registerSubDomain(bytes32 _node, string _subnodeLabel, uint64 _setTTL) public {

        require(testStr(_subnodeLabel));

        // Get the bytes32 hash of the label for the subnode
        bytes memory label = bytes(_subnodeLabel);
        bytes32 hashedLabel = keccak256(label);

        // If the subnode being registered is under the main bitnation node
        // Charge monthly fee here
        if (_node == rootNode) {

            // Check if the subnode already exists
            if (owners[hashedLabel].owner != 0x0) {
                // Then it needs to be expired for this domain to be remapped
                require(owners[hashedLabel].ttl <= now);
            }

            // Establish pricing by weeks, and make sure it is between 1 month and 24 months (96 weeks)
            require(_setTTL >= 4 weeks && _setTTL <= 96 weeks && _setTTL % 4 weeks == 0);
            // Check that the correct amount of ether has been sent (number of weeks * PRICE_PER_WEEK);
            require(msg.value == _setTTL % 4 weeks * pricePerMonth);
            // Set the expire time
            uint64 ttl = now + _setTTL;

            // Set the first subdomain
            domainOwner.setSubnodeOwner(rootNode, hashedLabel, domainOwnerAddress);
            // Set the owner for this subdomain
            owners[hashedLabel].owner = msg.sender;
            owners[hashedLabel].ttl = ttl;
            // Set the timeout for the first subnode.
            domainOwner.setTTL(hashedLabel, ttl);

        } else {

            // Check if the sender owns the node they are trying to register and that it isn't expired
            require(owners[_node].owner == msg.sender && owners[_node].ttl <= now);

            // Otherwise they are trying to set a sub-sub domain or higher so just set it
            domainOwner.setSubnodeOwner(_node, hashedLabel, domainOwnerAddress);

            // Set the owner and the ttl for the sub sub domain
            owners[hashedLabel].owner = msg.sender;
            owners[hashedLabel].ttl = owners[_node].ttl;

        }
    }

    function setSubdomainResolver(bytes32 _node, address _resolver) public {
        domainOwner.setResolver(_node, _resolver);
    }

    function owner(bytes32 _node) public view returns (address) {
        return owners[_node].owner;
    }

    function ttl(bytes32 _node) public view returns (uint) {
        return owners[_node].ttl;
    }

    function testStr(string str) public pure returns (bool){
        bytes memory b = bytes(str);
        if(b.length < 4) return false;

        for(uint i; i<b.length; i++){
            bytes1 char = b[i];

            if(
                !(char >= 0x30 && char <= 0x39) && // 9-0
            !(char >= 0x41 && char <= 0x5A) && // A-Z
            !(char >= 0x61 && char <= 0x7A) && // a-z
            !(char == 0x2D) // -
            )
                return false;
        }

        return true;
    }

}