// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract CNS{

    //address of the cusd token, i need this to interact with the cusd token
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // Mapping system that connects name to address
    mapping (string=>address) user;

    // Mapping variable that find the name of an address
    mapping (address => string) public userAddressLink;

    // A variable to check if the address has a name based of the state of its boolen
    mapping(address => bool) public wallet_Address;

    // this check prevent users who wants to create more than one name with one address
    modifier CheckBooleanLink{
        require(
            wallet_Address[msg.sender] == false,
            "This user has already been registered"
        );
        _;
    }

    // This check was put in place to prevent users from picking a username that is already in use
    // Imagine waking up and your username belongs to someone else, it wouldnt be right.
    // This will check that there is no address assigned to the name you would like to use

    modifier UsernameAvailability(string memory _inputtedusername){
        address addressResult = user[_inputtedusername];
        require(addressResult ==  0x0000000000000000000000000000000000000000, "This username is already taken");
        _;
    } 
    
    function checkuser(string memory username) public view returns(address){
        address resultaddress = user[username];

        return resultaddress;
    } 

    //The function that allows a user add a username to their celo wallet address
    function addUser(string memory _inputtedusername) public CheckBooleanLink UsernameAvailability(_inputtedusername){
        user[_inputtedusername] = msg.sender;
        userAddressLink[msg.sender] = _inputtedusername;
        wallet_Address[msg.sender] = true;
    }

    // A call function that is used to get the wallet address via username inputed 
    function getUserViaUsername(string memory _inputtedusername) public view returns(address){
        return user[_inputtedusername];
    }


    // Similar to the function buyoken, this function is used to send token from one user to another user
    function sendToken(uint _index, address receiver) public payable returns(address) {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                receiver,
                _index
            ),
            "Transfer Failed. Contact Customer Care"
        );
        return(receiver);
    }


}
