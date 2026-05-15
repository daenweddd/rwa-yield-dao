// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {RWAAssetToken} from "../token/RWAAssetToken.sol";
import {AssetCertificateNFT} from "../token/AssetCertificateNFT.sol";

contract RWAFactory {
    event AssetTokenDeployed(address indexed token, address indexed admin);
    event AssetTokenDeployedCreate2(address indexed token, address indexed admin, bytes32 indexed salt);
    event CertificateNFTDeployed(address indexed nft, address indexed admin);

    function deployAssetTokenCreate(address admin) external returns (address token) {
        RWAAssetToken newToken = new RWAAssetToken(admin);
        token = address(newToken);

        emit AssetTokenDeployed(token, admin);
    }

    function deployAssetTokenCreate2(address admin, bytes32 salt) external returns (address token) {
        RWAAssetToken newToken = new RWAAssetToken{salt: salt}(admin);
        token = address(newToken);

        emit AssetTokenDeployedCreate2(token, admin, salt);
    }

    function deployCertificateNFT(address admin) external returns (address nft) {
        AssetCertificateNFT newNFT = new AssetCertificateNFT(admin);
        nft = address(newNFT);

        emit CertificateNFTDeployed(nft, admin);
    }

    function computeAssetTokenCreate2Address(address admin, bytes32 salt) external view returns (address predicted) {
        bytes memory bytecode = abi.encodePacked(type(RWAAssetToken).creationCode, abi.encode(admin));

        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)));

        predicted = address(uint160(uint256(hash)));
    }
}
