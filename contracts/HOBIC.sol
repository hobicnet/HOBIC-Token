/**
 *Submitted for verification at BscScan.com on 2025-03-27
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2025-03-26
*/

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/**
 * @title HOBIC Token (HBC)
 * @notice Modern and gas efficient ERC20 token with EIP-2612 permit support.
 * @dev Smart Contract by HOBIC — https://hobic.net
 *      Community: https://t.me/hobictoken | Twitter/X: https://x.com/hobicnet
 * @author Solmate
 */

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate
abstract contract ERC20 {
    /**
     * @notice Emitted when tokens are transferred.
     */
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /**
     * @notice Emitted when approval is set by the token owner.
     */
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// @notice Token name.
    string public name;

    /// @notice Token symbol.
    string public symbol;

    /// @notice Token decimals (usually 18).
    uint8 public immutable decimals;

    /// @notice Total supply of the token.
    uint256 public totalSupply;

    /// @notice Mapping of address to account balance.
    mapping(address => uint256) public balanceOf;

    /// @notice Mapping of owner to spender approvals.
    mapping(address => mapping(address => uint256)) public allowance;

    /// @notice Initial chain ID used for EIP-712 domain separation.
    uint256 internal immutable INITIAL_CHAIN_ID;

    /// @notice Initial domain separator for EIP-712.
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    /// @notice Mapping of nonces used for permit signatures.
    mapping(address => uint256) public nonces;

    /**
     * @notice Initializes token metadata and EIP-712 domain.
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /**
     * @notice Approves `spender` to spend `amount` on behalf of `msg.sender`.
     */
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfers `amount` of tokens to address `to`.
     */
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @notice Transfers `amount` of tokens from `from` to `to` using allowance mechanism.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @notice Sets `spender` allowance over `owner` tokens via signature.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");
            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    /**
     * @notice Returns the EIP-712 domain separator.
     */
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    /**
     * @notice Computes the EIP-712 domain separator.
     */
    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    /**
     * @notice Mints `amount` of tokens to address `to`.
     */
    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }

    /**
     * @notice Burns `amount` of tokens from address `from`.
     */
    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        unchecked {
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }
}

contract HOBIC is ERC20 {
    /// @notice Constant address used for burning tokens permanently.
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /**
     * @notice Constructor that mints and distributes the initial supply.
     * @param presaleWallet Address receiving the presale allocation (50%).
     * @param liquidityWallet Address receiving liquidity allocation (15%).
     * @param fundraisingWallet Address receiving fundraising allocation (10%).
     * @param marketingWallet Address receiving marketing/development allocation (10%).
     */
    constructor(
        address presaleWallet,
        address liquidityWallet,
        address fundraisingWallet,
        address marketingWallet
    ) ERC20("HOBIC", "HBC", 18) {
        uint256 total = 1_000_000_000 * 1 ether;

        _mint(presaleWallet, (total * 50) / 100);       // Presale allocation
        _mint(liquidityWallet, (total * 15) / 100);     // Liquidity allocation
        _mint(BURN_ADDRESS, (total * 15) / 100);        // Burned tokens
        _mint(fundraisingWallet, (total * 10) / 100);   // Fundraising allocation
        _mint(marketingWallet, (total * 10) / 100);     // Marketing/Development allocation
    }

    /**
     * @notice Allows users to burn their own tokens.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Returns the circulating supply (excluding burned tokens).
     */
    function circulatingSupply() external view returns (uint256) {
        return totalSupply - balanceOf[BURN_ADDRESS];
    }
}
