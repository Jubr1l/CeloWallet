// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract CNS {
    //address of the cusd token
    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // keeps track of taken usernames
    mapping(string => bool) public taken;

    // A variable to check if the address has a name based of the state of its boolen
    mapping(address => bool) public registered;

    // Mapping variable that find the name of an address
    mapping(address => string) public userAddressLink;

    // Mapping system that connects name to address
    mapping(string => address) private user;

    /// @dev this check prevent users who wants to create more than one name with one address
    modifier checkRegisteredStatus() {
        require(
            registered[msg.sender] == false,
            "This user has already been registered"
        );
        _;
    }

    /** @dev This check was put in place to prevent users from picking a username that is already in use
     * Imagine waking up and your username belongs to someone else, it wouldnt be right.
     * @notice This will check that there is no address assigned to the name you would like to use
     */
    modifier UsernameAvailability(string calldata _username) {
        require(taken[_username] == false, "Username is already taken");
        _;
    }

    modifier checkAmount(uint amount) {
        require(amount >= 1 ether, "Amount must be at least one CUSD");
        _;
    }

    modifier checkAddress(address _address) {
        require(_address != address(0), "Error: address zero is not valid");
        _;
    }

    modifier onlyRegistered() {
        require(registered[msg.sender], "Caller is not registered");
        _;
    }

    /// @dev The function that allows a user add a username to their celo wallet address
    /// @param _username is desired username for the caller to register with
    /// @notice checks are enforced to make sure that _username is available and unique and that caller hasn't registered yet
    function addUser(string calldata _username)
        public
        checkRegisteredStatus
        UsernameAvailability(_username)
    {
        // makes sure that _username is not an empty string
        require(bytes(_username).length > 0, "Username is empty");
        user[_username] = msg.sender;
        userAddressLink[msg.sender] = _username;
        registered[msg.sender] = true;
        taken[_username] = true;
    }

    /**
     * @dev  A call function that is used to get the wallet address via username inputed
     * @return address of user with _username
     */
    function getUserViaUsername(string memory _username)
        public
        view
        returns (address)
    {
        require(taken[_username], "No registered user with this username");
        return user[_username];
    }

    /**
     * @dev  A call function that is used to get the wallet address via username inputed
     * @return address of user with _username
     */
    function getAddressViaUsername(address _user)
        public
        view
        checkAddress(_user)
        returns (string memory)
    {
        require(registered[_user], "No registered user with this address");
        return userAddressLink[_user];
    }

    /**
     * @dev allow registered users to transfer funds
     * @param receiver address of receiver
     * @notice both the sender(caller) and the receiver must be registered
     */
    function sendTokenByAddress(uint amount, address receiver)
        external
        payable
        onlyRegistered
        checkAmount(amount)
        checkAddress(receiver)
        returns (string memory)
    {
        require(receiver != msg.sender, "You can't send funds to yourself");

        require(registered[receiver], "Receiver is not registered");
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                receiver,
                amount
            ),
            "Transfer Failed. Contact Customer Care"
        );
        return (userAddressLink[receiver]);
    }

    /**
     * @dev allow registered users to transfer funds
     * @param _user username of receiver
     * @notice both the sender(caller) and the receiver must be registered
     */
    function sendTokenByUsername(uint amount, string calldata _user)
        external
        payable
        onlyRegistered
        checkAmount(amount)
        returns (address)
    {
        require(taken[_user], "No address registered with this username");
        require(
            user[_user] != msg.sender,
            "You can't transfer tokens to yourself"
        );
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                user[_user],
                amount
            ),
            "Transfer Failed. Contact Customer Care"
        );
        return (user[_user]);
    }
}
