// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// --- Interface, the rulebook all ERC20s must obey ---
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

       // custom celebration event
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
  
}

// The fake Bitcoin everyone wishes they owned
contract Bitcoin is IERC20 {
    // Token ID card
    string constant name = "Bitcoin";
    string constant symbol = "BTC";
    uint8 constant decimals = 18;

    uint256 private _totalSupply;
    address immutable owner; // the chosen one

    // Wallet bookkeeping
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // --- Custom Errors (less gas, more sass) ---
    error InsufficientBalance();     // when your wallet cries 
    error InsufficientAllowance();   // when spender gets greedy 
    error ZeroAddress();             // when you try to send to the void 
    error OnlyOwner();               // when a random tries to act like the boss 

    // --- Constructor (creates the coin empire) ---
    constructor(uint256 initialSupply) {
        owner = msg.sender; // deployer becomes the supreme ruler
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _totalSupply; // give them all the tokens!
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // Modifier to protect the throne
    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    //ERC20 Basics: boring but necessary ---
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    //everyone can view their balance
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    // Move your coins like a boss
    function transfer(address to, uint256 amount) external override returns (bool) {
        if (to == address(0)){
            revert ZeroAddress();} // sending to 0x0 = throwing money away
        if (_balances[msg.sender] < amount){
             revert InsufficientBalance(); }// too broke!

        _balances[msg.sender] -= amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Let someone spend your coins 
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Check how much your friend can spend 
    function allowance(address from, address spender) external view override returns (uint256) {
        return _allowances[from][spender];
    }

    // Spend on someone else's behalf 
    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        if (to == address(0)) {
            revert ZeroAddress();}
        if (currentAllowance < amount) {
            revert InsufficientAllowance();}
        if (_balances[from] < amount){
             revert InsufficientBalance();}

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] = currentAllowance - amount;

        emit Transfer(from, to, amount);
        return true;
    }

    //Mint function: Owner prints new money like a central bank
    function mint(address account, uint256 amount) external onlyOwner {
        if (account == address(0)) revert ZeroAddress();

        _totalSupply += amount; //increase the total supply
        _balances[account] += amount; //increase owner balance
        emit Transfer(address(0), account, amount);//from nowhere to owner account(mint)
    }

    // --- Burn function: Owner deletes tokens
    function burn(address account, uint256 amount) external onlyOwner {
        if (account == address(0)) revert ZeroAddress();
        if (_balances[account] < amount) revert InsufficientBalance();

        _balances[account] -= amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);//from owner to zero account(burn)
    }
}
