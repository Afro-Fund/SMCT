pragma solidity ^0.7.6;
pragma abicoder v2;
import "./zep/contracts/access/Ownable.sol";
import "./TokenFactory.sol";


 contract Controller is Ownable {

    address public overlord;
    
    struct Owners{
        address _add;
        uint id;
    }
    
    struct Project{
       uint _blackVotes;
       address _tokenAddress;
       string _name;
       bool active;
    }
    
    Project[] public projects;
    
    mapping(uint=>Owners) index;
    mapping (address=>uint) public ownerMaps;
    mapping (address=> Project) projectMaps;
    
    address[] public _owners;
    
    uint public _ownerCount;
    
    mapping(address => bool) public activeAdmins;
    mapping(address=>bool) public activeProjects;
    mapping(address=>bool) public owners;

    
    event adminAdded(address indexed newAdmin);
    event projectDisabled(address indexed _project);
    event adminDisabled(address indexed _admin);
    event newOwnerAdded(address indexed newOwner);
    event ownerRemoved(address indexed owner_);
    event projectCreated(address indexed _newProjectDeployed,string name);

    /**
     * @dev Throws if called by any account other than the overlord
    */
    modifier onlyOverlord() {
        require(msg.sender == overlord,"you are not the overlord");
        _;
    }

  //makes sure the admin has not been deactivated yet 
    modifier adminNotDeactivated(address admin) {
        require(activeAdmins[admin] == true,"you are not an admin");
        _;
    }
    
    //makes sure _target is not an admin yet
    modifier notAdmin(address _target) {
        require(activeAdmins[_target]==false,"this address is an admin already");
        _;
    }
    
    //requires that the number of owners are always less or equal to 3
    modifier lengthHigh{
        require(_owners.length<=2,"more than 3");
        _;
    }
    
    
    //makes sure the caller is an owner
    modifier aOwner(address _target){
        require(owners[_target]==true,"you are not a owner");
        _;
    }
    
    //makes sure that target is not an owner
    modifier notAOwner(address target){
        require(owners[target]==false,"this address is already an owner");
        _;
    }
    
    //makes sure the project is active
    function isActive(address _project) internal view returns (bool) {
        return activeProjects[_project];
    }
    
    //only owners[] can set an overlord
    function setOverlord(address _newOverlord) public aOwner(msg.sender) returns(address){
        require(_newOverlord!=address(0),"Error, address 0");
        overlord=_newOverlord;
        return _newOverlord;
    }

    //only an overlord can add an admin
    function addAdmin(address _newAdmin) public onlyOverlord notAdmin(_newAdmin) returns(address){
        require(_newAdmin!= address(0),"Error, address 0");
        activeAdmins[_newAdmin]=true;
        emit adminAdded(_newAdmin);
        return _newAdmin;
    }
   
   //only an admin can disable an admin
    function disableAdmin(address _admin) public onlyOverlord adminNotDeactivated(_admin) returns(address) {
        activeAdmins[_admin] = false;
        emit adminDisabled(_admin);
        return _admin;
    }
    
    //sees all the owners
    function seeOwners() public view returns(address[] memory){
        return _owners;
    }
    
    //only the contract owner can add an owner
    function addOwner(address _newOwner) public onlyOwner notAOwner(_newOwner) lengthHigh returns(address){
     require(_newOwner!= address(0),"Error, address 0");
     //require(viewArrayLength()< 2,"more than 1");
     index[_ownerCount]._add = _newOwner;
     index[_ownerCount].id = _ownerCount;
     owners[_newOwner]=true;
     ownerMaps[_newOwner]=_ownerCount;
     _owners.push(_newOwner);
     _ownerCount++;
     return _newOwner;
     
    }
    
    //only the contract owner can remove an owner
    function removeOwner(address _owner) public onlyOwner aOwner(_owner) returns(address){
         require(_owner!= address(0),"Error, address 0");
         uint _index=ownerMaps[_owner]; 
         require (_index<_owners.length,"Array length error");
         _owners[_index]=_owners[_owners.length-1];
         _owners.pop();
         _ownerCount--;
         emit ownerRemoved(_owner);
         return _owner;
    }
    
    //allows admins to vote for a project deactivation
    //a minimum of 10votes is needed before a project is deactivated
    function deactivateProject(address _project) public adminNotDeactivated(msg.sender) returns(bool,uint){
        require(isActive(_project)==true,"project is not active");
        projectMaps[_project]._blackVotes++;
        if (projectMaps[_project]._blackVotes>=10){
            projectMaps[_project].active==false;
            emit projectDisabled(_project);
        }
        return (true,projectMaps[_project]._blackVotes);
        
    }
    
    //allows anybody to create a project 
    //saves all projects in a struct array
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

    //simple view function to return all projects that have been created
    function viewProjects() public view returns(Project[] memory){
        return projects;
    }


}

