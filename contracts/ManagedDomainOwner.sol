pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./ENS.sol";

contract ManagedDomainOwner is Ownable {

    address registrar;
    address ens;
    ENS ensInstance;
    bool registrarActive = true;

    event ChangedENS(address ens);
    event DisabledRegistrar();
    event EnabledRegistrar();

    // will make sure that msg.sender is the registrar
    modifier onlyRegistrar() {
        require(msg.sender == registrar);
        _;
    }

    // will make sure the registrar is enabled access
    modifier activeRegistrar() {
        require(registrarActive);
        _;
    }

    // this will set the ens contract address
    // only callable by owner
    function setENS(address _ens) onlyOwner() {
        ens = _ens;
        ensInstance = ENS(_ens);
    }

    // will set the registrar that is allowed to call execOnENS
    // only callable by owner
    function setRegistrar(address _registrar) onlyOwner() {
        registrar = _registrar;
    }

    // disableRegistrar will disabled the registrar access to execOnENS
    // only callable by owner
    function disableRegistrar() onlyOwner {
        registrarActive = false;
    }

    // disableRegistrar will enable the registrar access to execOnENS
    // only callable by owner
    function enableRegistrar() onlyOwner {
        registrarActive = true;
    }


    // The four functions to interact with the public ENS registry
    function setSubnodeOwner(bytes32 _node, bytes32 _label, address _owner) onlyRegistrar() activeRegistrar() {
        ensInstance.setSubnodeOwner(_node, _label, _owner);
    }

    function setResolver(bytes32 _node, address _resolver) onlyRegistrar() activeRegistrar() {
        ensInstance.setResolver(_node, _resolver);
    }

    function setOwner(bytes32 _node, address _owner) onlyRegistrar() activeRegistrar() {
        ensInstance.setOwner(_node, _owner);
    }

    function setTTL(bytes32 _node, uint64 _ttl) onlyRegistrar() activeRegistrar() {
        ensInstance.setTTL(_node, _ttl);
    }


    // is supposed to get called by the owner only
    // if _ether is not 0, exec will be called with .value(_ether)
    // if _gas is not 0, exec will be called with .get(_gas)
    function exec(address _location, bytes _data, uint256 _ether, uint256 _gas) onlyOwner {

    }

}
