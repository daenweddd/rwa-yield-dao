// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract AssetCertificateNFT is ERC721, AccessControl {
    bytes32 public constant CERTIFICATE_MINTER_ROLE = keccak256("CERTIFICATE_MINTER_ROLE");

    uint256 private _nextTokenId = 1;

    mapping(uint256 => string) private _tokenURIs;

    event CertificateMinted(uint256 indexed tokenId, address indexed owner, string metadataURI);

    constructor(address admin) ERC721("RealYield Asset Certificate", "RYCERT") {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(CERTIFICATE_MINTER_ROLE, admin);
    }

    function mintCertificate(address to, string calldata metadataURI)
        external
        onlyRole(CERTIFICATE_MINTER_ROLE)
        returns (uint256 tokenId)
    {
        require(to != address(0), "Invalid receiver");

        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _tokenURIs[tokenId] = metadataURI;

        emit CertificateMinted(tokenId, to, metadataURI);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
