// This was based a AragonOS' proxy system modified by William
// Distributed under the GPL 3.0 license

pragma solidity ^0.4.18;

import "./RegistrarStorage.sol";
import "./DelegateProxy.sol";

/**
 * @title RegistrarProxy
 * @dev The proxy contract that forwards all function calls to the registrar
 * Implementation that is currently being used
 */
contract RegistrarProxy is RegistrarStorage, DelegateProxy {

    // This is a proxy contract to a registrar implementation. The implementation can
    // Update the reference, which upgrades the contract

    function RegistrarProxy(address _registrarImpl) public {
        registrarImpl = _registrarImpl;
    }

    // All calls made to the proxy are forwarded to the registrar implementation via a delegatecall
    function () payable public {
        delegatedFwd(registrarImpl, msg.data);
    }

}
