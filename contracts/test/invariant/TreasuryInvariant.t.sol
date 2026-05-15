// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWATreasury} from "../../src/treasury/RWATreasury.sol";

contract TreasuryInvariantERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract TreasuryHandler {
    RWATreasury public treasury;
    TreasuryInvariantERC20 public token;

    address public admin;
    address public receiver = address(0xB0B);

    uint256 public totalEtherWithdrawn;
    uint256 public totalTokenWithdrawn;

    constructor(RWATreasury _treasury, TreasuryInvariantERC20 _token, address _admin) {
        treasury = _treasury;
        token = _token;
        admin = _admin;
    }

    function withdrawEther(uint256 amount) external {
        uint256 balance = address(treasury).balance;

        if (balance == 0) {
            return;
        }

        amount = bound(amount, 1, balance);

        vmPrank(admin);
        try treasury.withdrawEther(payable(receiver), amount) {
            totalEtherWithdrawn += amount;
        } catch {}
    }

    function withdrawToken(uint256 amount) external {
        uint256 balance = token.balanceOf(address(treasury));

        if (balance == 0) {
            return;
        }

        amount = bound(amount, 1, balance);

        vmPrank(admin);
        try treasury.withdrawERC20(address(token), receiver, amount) {
            totalTokenWithdrawn += amount;
        } catch {}
    }

    function vmPrank(address caller) internal {
        Vm(address(uint160(uint256(keccak256("hevm cheat code"))))).prank(caller);
    }

    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        if (x < min) return min;
        if (x > max) return max;
        return x;
    }
}

interface Vm {
    function prank(address) external;
}

contract TreasuryInvariantTest is Test {
    RWATreasury treasury;
    TreasuryInvariantERC20 token;
    TreasuryHandler handler;

    address admin = address(0xA11CE);

    uint256 initialEther = 10 ether;
    uint256 initialTokens = 1_000 ether;

    function setUp() public {
        treasury = new RWATreasury(admin);
        token = new TreasuryInvariantERC20();

        vm.deal(address(treasury), initialEther);
        token.mint(address(treasury), initialTokens);

        handler = new TreasuryHandler(treasury, token, admin);
        targetContract(address(handler));
    }

    function invariant_EtherAccounting() public view {
        assertEq(
            address(treasury).balance + handler.totalEtherWithdrawn(),
            initialEther
        );
    }

    function invariant_TokenAccounting() public view {
        assertEq(
            token.balanceOf(address(treasury)) + handler.totalTokenWithdrawn(),
            initialTokens
        );
    }
}