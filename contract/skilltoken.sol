// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract BasicSkillToken {
    // Struct to hold user data
    struct UserProfile {
        string name;
        string email;
        bool isInstructor;
        bool isStudent;
        bool isRegistered;
    }

    // Token details
    string public tokenName = "SkillToken";
    string public symbol = "STK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Arrays and Mappings
    UserProfile[] public userProfiles;
    mapping(address => uint256) public userIndex; // Maps user addresses to their index in the array
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event UserRegistered(address indexed user, string name, string email, bool isInstructor, bool isStudent);

    // Modifier to check for registered users
    modifier onlyRegistered() {
        uint256 index = userIndex[msg.sender];
        require(index < userProfiles.length && userProfiles[index].isRegistered, "User not registered");
        _;
    }

    // Function for user registration
    function registerUser(string memory _name, string memory _email, bool _isInstructor, bool _isStudent) external {
        uint256 index = userIndex[msg.sender];

        if (index == 0) {
            // New user
            index = userProfiles.length;
            userProfiles.push(UserProfile({
                name: _name,
                email: _email,
                isInstructor: _isInstructor,
                isStudent: _isStudent,
                isRegistered: true
            }));
            userIndex[msg.sender] = index;
        } else {
            // Existing user, update profile
            require(userProfiles[index].isRegistered, "User not registered");
            userProfiles[index].name = _name;
            userProfiles[index].email = _email;
            userProfiles[index].isInstructor = _isInstructor;
            userProfiles[index].isStudent = _isStudent;
        }

        emit UserRegistered(msg.sender, _name, _email, _isInstructor, _isStudent);
    }

    // Function to reward students after completing a course
    function rewardTokens(uint256 quizScore) external onlyRegistered {
        uint256 index = userIndex[msg.sender];
        require(userProfiles[index].isStudent, "Only students can receive rewards");

        uint256 tokensAwarded = quizScore * 10 ** decimals;
        _mint(msg.sender, tokensAwarded);
    }

    // Internal function to mint tokens
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");

        totalSupply += amount;
        balanceOf[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    // ERC20 standard functions
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }
}
