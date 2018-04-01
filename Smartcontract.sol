pragma solidity ^0.4.16;

contract ERC20{
    
    string public name="Faireaccess_token";
    string public symbol="FTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address admin;
    mapping (address => uint256) public balanceOf;
 
    event Transfer(address indexed from, address indexed to, uint256 value);

 


    function transfer(address _to, uint256 _value) public {
        _transfer( admin, msg.sender, _value);
    }

  
      function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
}

contract Acces_control is ERC20
{
 
uint256 public time_start; // access start time
uint256 public time_end; // access end time
uint256 public now_=now; // access end time

string location;// device location exp "baby room"
mapping(address=>role) white_list;// the whitelisted users
address public ad_device_owner; //device owner

enum role{
    Ressource_Owner,Babysitter,Service_Provider
}


function Acces_control(string device_location,uint256 access_time_start,uint256 access_time_end,uint256 initialSupply){ // the constructor initiated the total supply of token access and intial access control parameters
    
        totalSupply = initialSupply * 10 ** uint256(decimals); 
        ad_device_owner=msg.sender;
        admin=ad_device_owner;
        white_list[ad_device_owner]=role.Ressource_Owner; 
        time_start=access_time_start;
        time_end=access_time_end;
        location=device_location;
        balanceOf[ad_device_owner] = totalSupply;
       
}    


 
   modifier only_ressource_owner() // this modifier restricts the functions execution to the ressource owner
    {
        require(white_list[msg.sender]==role.Ressource_Owner);//check if the request comes from the ressource owner
        _;
    }


event allow_access_event(bool allowed);

    function setRole (address ad, uint256  roleID) only_ressource_owner // add new whitelisted user or define the role
    {

        if (roleID==0)
            white_list[ad]=role.Ressource_Owner;   
        if (roleID==1)
            white_list[ad]=role.Babysitter;  
        if (roleID==2)
            white_list[ad]=role.Service_Provider;  
        
    }

 
    function getrole(address ad) only_ressource_owner view returns (role) // get whitelisted users' roles
    {
        return white_list[ad];
    }


function access_control_policy(address requester, string location_)public returns (bool) { // this function represents an example of access control policy
    
    if(keccak256(location_)==keccak256("babyroom")&& now<time_end && now>time_start)// 
    
    {
                transfer(requester,1);// transfer 1 token to the requester 
                allow_access_event(true);
                return true;
    }
    else revert;
}

function Access_Request(string ressource_, string location) returns (bool){ // the requester call this function to get access token
    
    if(keccak256(ressource_)==keccak256("raspberry") && white_list[msg.sender]==role.Babysitter)//&& 
    {
        access_control_policy(msg.sender, location);
    
    return true;
    }
    else
    revert;
    
}

function burn_token(uint256 amount){// token is sent back to the contract after the access to the object
    _transfer(msg.sender,ad_device_owner,amount);
}

}
