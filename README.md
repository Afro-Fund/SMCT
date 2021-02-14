# OpenZeppelin Contracts
This project makes use of the [openzepelin array of contracts](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts) for several arithmetic,accessibility and token standard operations 


# Contracts

## MainToken

One of the main contracts `MainToken.sol` implements the ERC20 interface.  It is the main `Afro.fund` token contract . All projects created via the `TokenFactory` have 5% of their `_totalSupply`deposited into the Afro.fund token contract. All arbitrary tokens in the Afro.fund token contract(Maintoken.sol)[https://github.com/Afro-Fund/SMCT/blob/master/contracts/MainToken.sol] can be withdrawn to an external address **only by the contract `owner`**. This is defined [here](https://github.com/Afro-Fund/SMCT/blob/544a5ce8a683a2d059795b209f24a1bae61f1477/contracts/MainToken.sol#L228).

| Roles | Max Count     | priveleges |
|:--------:|----------:|------|
| Owner     | 1        | can withdraw any project tokens deposited to the contract    |


## TokenFactory.sol

This is the contract that controls token allocation and acts as the project token creation modality. The main constructor to be followed is located [here](https://github.com/Afro-Fund/SMCT/blob/544a5ce8a683a2d059795b209f24a1bae61f1477/contracts/TokenFactory.sol#L49) and token allocations occur [here](https://github.com/Afro-Fund/SMCT/blob/544a5ce8a683a2d059795b209f24a1bae61f1477/contracts/TokenFactory.sol#L55) & [here](https://github.com/Afro-Fund/SMCT/blob/544a5ce8a683a2d059795b209f24a1bae61f1477/contracts/TokenFactory.sol#L56)

| Roles | Max Count     | Priveleges |
|:--------:|----------:|------|
|     |       |       |

## Functions 

- Constructor 

```solidity
 constructor (string memory name_, string memory symbol_, address _firstOwner)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        _totalSupply=10000000*10**18;    //10 million tokens
        uint256 _afro=getShare(_totalSupply);
        _balances[_firstOwner]=_totalSupply.sub(_afro);//assign all tokens to the contract deployer
        _balances[AFROFUND_add]=_afro; //allocate 5% to afro.fund
        emit Transfer(address(0),_firstOwner,_balances[_firstOwner]);
         emit Transfer(address(0),AFROFUND_add,_afro);

    }
    ```
    `name_`: name of project, also used to mint the project token
    `symbol_`: token symbol used for the project
    `_firstOwner`: 95% of totalSupply will be minted to this address
     The function emits two events called `Transfer` which shows the token transfers to `AFROFUND_add` and `_firstOwner`

 - transfer: allows tokens to be transferred from one account to another
 - approve: allows the caller to allow another address to spend tokens on his behalf
 - getShare: a `pure` function used to calculate 5% of totalSupply




## Blacklister.sol

This is one of the most important important contracts since it controls all access roles that are needed to govern over created projects. it inherits for `TokenFactory.sol` to create/initialize projects [here](https://github.com/Afro-Fund/SMCT/blob/544a5ce8a683a2d059795b209f24a1bae61f1477/contracts/Blacklister.sol#L157). 

The roles and privileges are explained below

| Roles | Max Count     | Privileges |
|:--------:|----------:|------|
| _owner    | 1       | Has the ability to add `owners`|
| owners   | 3        |   They have the ability to change the `overlord`   |
| overlord      | 1         |   Has the ability to add and disable `admins`   |
| admins      | infinite         |   They can vote for a created project to be blacklisted. A project is blacklisted if 10 or more admins vote for it to be blacklisted   |

## Other Features

- Events
`adminDeactivated`: Emitted when an admin has been deactivated by the `overlord`

`adminAdded`: Emitted when an admin has been added/activated by the `overlord`

`projectDisabled`: Emitted when a project has been disabledblacklisted

`adminDisabled`: Emitted when an admin has been disabled by the `overlord`

`newOwnerAdded` : Emitted when a new `owner` is added by the `overlord`

`ownerRemoved`: Emitted when an `owner` has been removed by the `overlord`

`projectCreated`: Emitted wshen a project is created


- Mappings
`activeAdmins`: Tracks all active admins

`activeProjects`: Tracks all active projects

`owners`: Tracks all active owners


- Structs
`Project`: contains all information about a project

`Owners`: primarily used to track the owner array length

 
## Other important functions
```solidity
   function createProject(string memory name, string memory sym,address firstOwner) public returns(address _deployed){
        Standard _newToken= new Standard(name,sym,firstOwner);
        projectMaps[address(_newToken)]._name=name; 
        projectMaps[address(_newToken)].active=true;
        projectMaps[address(_newToken)]._tokenAddress=(address(_newToken));
        projectMaps[address(_newToken)]._blackVotes=0;
        projects.push(Project(0,(address(_newToken)),name,true));
        activeProjects[address(_newToken)]=true;
        emit projectCreated(address(_newToken),name);
        return address(_newToken);
        
}
```

Allows anybody to start a project given the `name`(will be used to mint the project token ) , `symbol` and `firstOwner` (the address where the totalSupply will be minted to)






