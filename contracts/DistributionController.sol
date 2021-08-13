// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.3;
pragma experimental ABIEncoderV2;

import {
  ISuperfluid,
  ISuperToken,
  SuperAppBase,
  SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";
import {
  IInstantDistributionAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IInstantDistributionAgreementV1.sol";

contract DistributionController is SuperAppBase { // ETH distribution after swapping
  uint32 public constant INDEX_ID = 0;

  ISuperToken private acceptedToken; // fDAI or fDAIx (testing)
  ISuperfluid private host;
  IInstantDistributionAgreementV1 private ida;

  constructor(
    ISuperToken _acceptedToken,
    ISuperfluid _host,
    IInstantDistributionAgreementV1 _ida
  ) {

    _acceptedToken = acceptedToken;
    _host = host;
    _ida = ida;

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
}
