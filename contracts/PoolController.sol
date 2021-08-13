// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;

import {
  ISuperfluid,
  ISuperToken,
  SuperAppBase,
  SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";
import { IConstantFlowAgreementV1 } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

contract PoolController is SuperAppBase { // streaming - inflow
  ISuperToken private _acceptedToken; // fDAI or fDAIx (testing)
  ISuperfluid private _host;
  IConstantFlowAgreementV1 private _cfa;
  address private _receiver; // ADMIN

  constructor(
    ISuperToken acceptedToken,
    ISuperfluid host,
    IConstantFlowAgreementV1 cfa
    address receiver) {
      require(address(host) != address(0), "PoolController:: host is zero address");
      require(address(cfa) != address(0), "PoolController:: cfa is zero address");
      require(address(acceptedToken) != address(0), "PoolController:: acceptedToken is zero address");
      require(address(receiver) != address(0), "PoolController:: receiver is zero address");
      require(!host.isApp(ISuperApp(receiver)), "PoolController:: receiver is an app");

    _acceptedToken = acceptedToken;
    _host = host;
    _cfa = cfa;

    uint256 configWord =
      SuperAppDefinitions.APP_LEVEL_FINAL |
      SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP |
      SuperAppDefinitions.AFTER_AGREEMENT_TERMINATED_NOOP;

    _host.registerApp(configWord);

    _host.callAgreement(
        _ida,
        abi.encodeWithSelector(
            _ida.createIndex.selector,
            _cashToken,
            INDEX_ID,
            new bytes(0) // placeholder ctx
        ),
        new bytes(0) // user data
    );
  }

  function _isSameToken(ISuperToken superToken) private view returns (bool) {
    return address(superToken) == address(_acceptedToken);
  }

  function _isCFAv1(address agreementClass) private view returns (bool) {
    return ISuperAgreement(agreementClass).agreementType()
      == keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1");
  }

  modifier onlyHost() {
    require(msg.sender == address(_host), "PoolController:: support only one host");
    _;
  }

  modifier onlyExpected(ISuperToken superToken, address agreementClass) {
    require(_isSameToken(superToken), "PoolController:: not accepted token");
    require(_isCFAv1(agreementClass), "PoolController:: only CFAv1 supported");
    _;
  }
}
