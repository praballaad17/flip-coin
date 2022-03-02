// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

contract CoinFlip {
    //array of all user
    address[] internal userBetadress;
    //struct
    struct User {
        uint256 userBalance;
        bool userBetStatus;
        uint256 userBetOn;
        uint256 userBetValue;
        bool intializer;
    }
    mapping(address => User) public userData;

    event Winners(address winnerAddress, uint256 betAmount);

    //function to get the balance of the user
    function getUserBalnce(address _add)
        public
        view
        returns (
            uint256,
            bool,
            uint256,
            uint256,
            bool
        )
    {
        return (
            userData[_add].userBalance,
            userData[_add].userBetStatus,
            userData[_add].userBetOn,
            userData[_add].userBetValue,
            userData[_add].intializer
        );
    }

    //place the bate function

    //check for
    function placeBet(uint256 _amountToBet, uint256 _betOn) public {
        //first inititted with 100 points
        if (userData[msg.sender].intializer == false) {
            userData[msg.sender].userBalance = 100;
            userData[msg.sender].intializer = true;
        }

        // check user balance with current bet amount
        require(
            _amountToBet <= userData[msg.sender].userBalance,
            "Not enough balance"
        );

        //bet status stores if already placed the bet or not.
        require(
            userData[msg.sender].userBetStatus == false,
            "User have already placed bet"
        );
        userData[msg.sender].userBetValue = _amountToBet;
        userData[msg.sender].userBalance -= _amountToBet;
        userData[msg.sender].userBetOn = _betOn;
        userData[msg.sender].userBetStatus = true;
        userBetadress.push(msg.sender);
    }

    //inciate the reward bet which iterates for all users, an check for win
    function _rewardBet() public {
        uint256 length = userBetadress.length;

        //generate random vlaue 0/1
        uint256 rand = uint256(generateRand());
        uint256 reward = uint256(rand) % 2;

        for (uint256 i = 0; i < length; i++) {
            _checkBets(userBetadress[i], reward);
        }
        delete userBetadress;
    }

    //vrf function to genrate random number
    function generateRand() private view returns (bytes32 result) {
        bytes32 input;
        assembly {
            let memPtr := mload(0x40)
            if iszero(staticcall(not(0), 0xff, input, 32, memPtr, 32)) {
                invalid()
            }
            result := mload(memPtr)
        }
    }

    //check bet function to check for win and
    function _checkBets(address _add, uint256 reward) internal {
        require(
            userData[_add].userBetStatus == true,
            "you have not placed bet"
        );

        if (userData[_add].userBetOn == reward) {
            userData[_add].userBalance += (userData[_add].userBetValue * 2);
            emit Winners(_add, userData[_add].userBetValue);
        }
        userData[_add].userBetStatus = false;
    }
}
