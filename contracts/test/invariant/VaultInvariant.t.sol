// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWAYieldVault} from "../../src/vault/RWAYieldVault.sol";

contract VaultInvariantERC20 is ERC20 {
    constructor() ERC20("RWA Asset", "RWA") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract VaultHandler {
    VaultInvariantERC20 public asset;
    RWAYieldVault public vault;

    address public user = address(0xB0B);

    constructor(VaultInvariantERC20 _asset, RWAYieldVault _vault) {
        asset = _asset;
        vault = _vault;

        asset.mint(address(this), 1_000_000 ether);
        asset.approve(address(vault), type(uint256).max);
    }

    function deposit(uint256 amount) external {
        amount = bound(amount, 1 ether, 100 ether);

        try vault.deposit(amount, address(this)) {} catch {}
    }

    function withdraw(uint256 amount) external {
        uint256 maxWithdraw = vault.maxWithdraw(address(this));

        if (maxWithdraw == 0) {
            return;
        }

        amount = bound(amount, 1, maxWithdraw);

        try vault.withdraw(amount, address(this), address(this)) {} catch {}
    }

    function redeem(uint256 shares) external {
        uint256 balance = vault.balanceOf(address(this));

        if (balance == 0) {
            return;
        }

        shares = bound(shares, 1, balance);

        try vault.redeem(shares, address(this), address(this)) {} catch {}
    }

    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        if (x < min) return min;
        if (x > max) return max;
        return x;
    }
}

contract VaultInvariantTest is Test {
    VaultInvariantERC20 asset;
    RWAYieldVault vault;
    VaultHandler handler;

    address admin = address(0xA11CE);
    address treasury = address(0x777);

    function setUp() public {
        asset = new VaultInvariantERC20();
        vault = new RWAYieldVault(asset, admin, treasury);

        handler = new VaultHandler(asset, vault);
        targetContract(address(handler));
    }

    function invariant_TotalAssetsEqualsVaultBalance() public view {
        assertEq(vault.totalAssets(), asset.balanceOf(address(vault)));
    }

    function invariant_TotalSupplyNeverExceedsTotalAssetsWhenOneToOne() public view {
        assertLe(vault.totalSupply(), vault.totalAssets());
    }
}