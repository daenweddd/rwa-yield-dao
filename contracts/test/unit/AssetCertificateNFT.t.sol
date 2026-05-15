// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AssetCertificateNFT} from "../../src/token/AssetCertificateNFT.sol";

contract AssetCertificateNFTTest is Test {
    AssetCertificateNFT nft;

    address admin;
    address user = address(0xB0B);
    address stranger = address(0xBAD);

    function setUp() public {
        admin = address(this);
        nft = new AssetCertificateNFT(admin);
    }

    function testNameAndSymbolAreCorrect() public view {
        assertEq(nft.name(), "RealYield Asset Certificate");
        assertEq(nft.symbol(), "RYCERT");
    }

    function testAdminHasRoles() public view {
        assertTrue(nft.hasRole(nft.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(nft.hasRole(nft.CERTIFICATE_MINTER_ROLE(), admin));
    }

    function testConstructorRevertsForZeroAdmin() public {
        vm.expectRevert(bytes("Invalid admin"));
        new AssetCertificateNFT(address(0));
    }

    function testMintCertificateWorks() public {
        uint256 tokenId = nft.mintCertificate(user, "ipfs://certificate-1");

        assertEq(tokenId, 1);
        assertEq(nft.ownerOf(tokenId), user);
        assertEq(nft.tokenURI(tokenId), "ipfs://certificate-1");
    }

    function testMintCertificateIncrementsTokenId() public {
        uint256 tokenId1 = nft.mintCertificate(user, "ipfs://certificate-1");
        uint256 tokenId2 = nft.mintCertificate(user, "ipfs://certificate-2");

        assertEq(tokenId1, 1);
        assertEq(tokenId2, 2);
        assertEq(nft.tokenURI(tokenId1), "ipfs://certificate-1");
        assertEq(nft.tokenURI(tokenId2), "ipfs://certificate-2");
    }

    function testMintCertificateRevertsForZeroReceiver() public {
        vm.expectRevert(bytes("Invalid receiver"));
        nft.mintCertificate(address(0), "ipfs://certificate");
    }

    function testMintCertificateByNonMinterReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        nft.mintCertificate(user, "ipfs://certificate");
    }

    function testTokenURIRevertsForNonexistentToken() public {
        vm.expectRevert();
        nft.tokenURI(999);
    }

    function testAdminCanGrantMinterRole() public {
        address newMinter = address(0xCAFE);

        nft.grantRole(nft.CERTIFICATE_MINTER_ROLE(), newMinter);

        vm.prank(newMinter);
        uint256 tokenId = nft.mintCertificate(user, "ipfs://certificate-new");

        assertEq(tokenId, 1);
        assertEq(nft.ownerOf(tokenId), user);
    }

    function testSupportsERC721Interface() public view {
        assertTrue(nft.supportsInterface(0x80ac58cd));
    }

    function testSupportsAccessControlInterface() public view {
        assertTrue(nft.supportsInterface(0x7965db0b));
    }
}