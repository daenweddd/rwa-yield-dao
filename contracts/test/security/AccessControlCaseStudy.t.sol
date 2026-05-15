// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract VulnerableMintToken {
    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    event Mint(address indexed to, uint256 amount);

    function mint(address to, uint256 amount) external {
        require(to != address(0), "zero address");
        require(amount > 0, "zero amount");

        balanceOf[to] += amount;
        totalSupply += amount;

        emit Mint(to, amount);
    }
}

contract FixedMintToken is AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(address => uint256) public balanceOf;
    uint256 public totalSupply;

    event Mint(address indexed to, uint256 amount);

    error ZeroAddress();
    error ZeroAmount();

    constructor(address admin) {
        if (admin == address(0)) {
            revert ZeroAddress();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        balanceOf[to] += amount;
        totalSupply += amount;

        emit Mint(to, amount);
    }
}

contract AccessControlCaseStudyTest is Test {
    VulnerableMintToken vulnerableToken;
    FixedMintToken fixedToken;

    address admin;
    address attacker = address(0xBAD);
    address user = address(0xB0B);

    function setUp() public {
        admin = address(this);

        vulnerableToken = new VulnerableMintToken();
        fixedToken = new FixedMintToken(admin);
    }

    function testVulnerableTokenAllowsAnyoneToMint() public {
        vm.prank(attacker);
        vulnerableToken.mint(attacker, 1_000_000 ether);

        assertEq(vulnerableToken.balanceOf(attacker), 1_000_000 ether);
        assertEq(vulnerableToken.totalSupply(), 1_000_000 ether);
    }

    function testFixedTokenBlocksUnauthorizedMint() public {
        vm.prank(attacker);
        vm.expectRevert();
        fixedToken.mint(attacker, 1_000_000 ether);

        assertEq(fixedToken.balanceOf(attacker), 0);
        assertEq(fixedToken.totalSupply(), 0);
    }

    function testFixedTokenAllowsAuthorizedMinter() public {
        fixedToken.mint(user, 100 ether);

        assertEq(fixedToken.balanceOf(user), 100 ether);
        assertEq(fixedToken.totalSupply(), 100 ether);
    }

    function testFixedTokenAdminCanGrantMinterRole() public {
        address newMinter = address(0xCAFE);

        fixedToken.grantRole(fixedToken.MINTER_ROLE(), newMinter);

        vm.prank(newMinter);
        fixedToken.mint(user, 250 ether);

        assertEq(fixedToken.balanceOf(user), 250 ether);
        assertEq(fixedToken.totalSupply(), 250 ether);
    }

    function testFixedTokenNonMinterCannotMint() public {
    vm.prank(attacker);
    vm.expectRevert();
    fixedToken.mint(user, 500 ether);
    }

    function testFixedTokenRevertsForZeroAdmin() public {
        vm.expectRevert(FixedMintToken.ZeroAddress.selector);
        new FixedMintToken(address(0));
    }

    function testFixedTokenRevertsForZeroAddressMint() public {
        vm.expectRevert(FixedMintToken.ZeroAddress.selector);
        fixedToken.mint(address(0), 100 ether);
    }

    function testFixedTokenRevertsForZeroAmountMint() public {
        vm.expectRevert(FixedMintToken.ZeroAmount.selector);
        fixedToken.mint(user, 0);
    }
}