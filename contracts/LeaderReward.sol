//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "../interfaces/IReferralManager.sol";

contract LeaderReward is PausableUpgradeable, OwnableUpgradeable {
    event SubmitVote(
        uint256 indexed voteId,
        address indexed user,
        address newLeader,
        uint256 devClaimAmount
    );

    event LeaderConfirm(address indexed leader, uint256 indexed voteId);
    event DevConfirm(address indexed dev, uint256 indexed voteId);

    event LeaderCancel(address indexed leader, uint256 indexed voteId);
    event DevCancel(address indexed dev, uint256 indexed voteId);

    event ExecuteVote(uint256 indexed voteId);

    event ClaimedReward(address indexed user, uint256 reward);

    struct VoteInfo {
        bool executed;
        bool devVote;
        address newLeader;
        uint80 numLeaderVote;
        uint256 devClaimAmount;
    }

    uint256 constant DEV_POWER = 4900; //49.00%
    uint256 constant LEADER_POWER = 5100; // 51.00%

    address public severAddress;
    // owner = dev
    address public dev;
    IReferralManager referralManager;
    ERC20Upgradeable public rewardToken;

    uint256 public expiredTime;
    uint256 public numLeader;

    VoteInfo[] internal voteInfos;
    mapping(address => mapping(uint256 => bool)) voted;
    mapping(address => uint256) public claimedRank;
    mapping(address => bool) public isLeader;

    ///@custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _dev,
        address _severAddress,
        ERC20Upgradeable _rewardToken,
        IReferralManager _referralManager
    ) external initializer {
        __Ownable_init();
        dev = _dev;
        severAddress = _severAddress;
        rewardToken = _rewardToken;
        referralManager = _referralManager;
        expiredTime = block.timestamp + 1095 days; // 3*365 = 1095 days
    }

    function getLastVoteId() external view returns (uint256) {
        return voteInfos.length;
    }

    function getVoteInfo(uint256 _voteId)
        external
        view
        returns (VoteInfo memory)
    {
        return voteInfos[_voteId - 1];
    }

    function claimRewardAfterExpired() external {
        require(msg.sender == dev, "Not dev");
        require(block.timestamp > expiredTime, "Not yet");
        rewardToken.approve(dev, type(uint256).max);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // change onlyOwner sang 1 contract khác có quyền set leader, contract đó sẽ làm nhiệm vụ verify luôn
    // hoặc sau lưu danh sách leader ở 1 contract khác, rồi mình query sang check
    function setLeader(address _newLeader, bool _state) external onlyOwner {
        // check F0
        require(
            referralManager.referrerInformation(_newLeader) == address(0),
            "Not F0"
        );
        bool curState = isLeader[_newLeader];
        if (curState != _state) {
            if (_state) numLeader++;
            else numLeader--;
            isLeader[_newLeader] = _state;
        }
    }

    function changeDev(address _newDev) external {
        require(msg.sender == dev, "Not dev");
        dev = _newDev;
    }

    function changeReferralManager(IReferralManager _referralManager)
        external
        onlyOwner
    {
        referralManager = _referralManager;
    }

    function changeSeverAddres(address _severAddress) external onlyOwner {
        severAddress = _severAddress;
    }

    function claimReward(
        address _user,
        uint256 _score,
        bytes memory _signature
    ) external whenNotPaused {
        require(_verifyData(_user, _score, _signature), "Invalid data");
        // Check F0
        require(
            referralManager.referrerInformation(msg.sender) == address(0),
            "Not F0"
        );

        uint256 userRank = _caculateRank(_score);
        uint256 userClaimedRank = claimedRank[_user];

        require(
            userClaimedRank < userRank,
            "You have claimed all reward at your rank"
        );

        uint256 rewardAmout;

        for (uint256 i = (userClaimedRank + 1); i <= userRank; i++) {
            if (i == 1) {
                rewardAmout += 30000 * 1e18;
            } else if (i == 2) {
                rewardAmout += 60000 * 1e18;
            } else if (i == 3) {
                rewardAmout += 100000 * 1e18;
            } else if (i == 4) {
                rewardAmout += 400000 * 1e18;
            }
        }

        claimedRank[_user] = userRank;

        rewardToken.transfer(_user, rewardAmout);

        emit ClaimedReward(_user, rewardAmout);
    }

    // moi nguo`i tru F0
    function createVote(address _newLeader, uint256 _devClaimAmount)
        external
        returns (uint256)
    {
        // check new leader co phai F0 khong
        require(
            referralManager.referrerInformation(_newLeader) == address(0),
            "Not F0"
        );

        // id start từ 1
        // Nếu là leader hoặc dev thì confirm luôn
        VoteInfo memory newVote;
        uint256 voteId = voteInfos.length + 1;

        if (msg.sender == dev) {
            newVote.devVote = true;
            emit DevConfirm(msg.sender, voteId);
        } else if (isLeader[msg.sender]) {
            newVote.numLeaderVote++;
            voted[msg.sender][voteId] = true;
            emit LeaderConfirm(msg.sender, voteId);
        }

        newVote.newLeader = _newLeader;
        newVote.devClaimAmount = _devClaimAmount;

        voteInfos.push(newVote);

        emit SubmitVote(voteId, msg.sender, _newLeader, _devClaimAmount);

        return voteId;
    }

    // only leader va` dev
    function confirmVote(uint256 voteId) external {
        // Only dev and leader can vote
        VoteInfo memory voteInfo = voteInfos[voteId - 1];
        if (msg.sender == dev) {
            voteInfo.devVote = true;
            emit DevConfirm(msg.sender, voteId);
        } else if (isLeader[msg.sender]) {
            require(!voted[msg.sender][voteId], "You have vote yes already");
            voteInfo.numLeaderVote++;
            voted[msg.sender][voteId] = true;
            emit LeaderConfirm(msg.sender, voteId);
        }
        voteInfos[voteId - 1] = voteInfo;
    }

    function cancelVote(uint256 voteId) external {
        // Only dev and leader can vote
        VoteInfo memory voteInfo = voteInfos[voteId - 1];
        if (msg.sender == dev) {
            voteInfo.devVote = false;
            emit DevCancel(msg.sender, voteId);
        } else if (isLeader[msg.sender]) {
            require(voted[msg.sender][voteId], "You have vote no already");
            voteInfo.numLeaderVote--;
            voted[msg.sender][voteId] = false;
            emit LeaderCancel(msg.sender, voteId);
        }
        voteInfos[voteId - 1] = voteInfo;
    }

    // moi nguoi
    function executeVote(uint256 voteId) external {
        VoteInfo memory voteInfo = voteInfos[voteId - 1];
        require(!voteInfo.executed, "This vote has executed");
        uint256 rate;
        if (voteInfo.devVote) rate = DEV_POWER;
        uint256 totalNumberOfLeader = numLeader;
        rate +=
            (((LEADER_POWER * 1e6) / totalNumberOfLeader) *
                voteInfo.numLeaderVote) /
            1e6;
        require(rate > 5000, "Not enough voting power");
        if (voteInfo.newLeader != address(0)) {
            if (!isLeader[voteInfo.newLeader]) {
                numLeader++;
                isLeader[voteInfo.newLeader] = true;
            }
        }
        if (voteInfo.devClaimAmount != 0) {
            rewardToken.transfer(dev, voteInfo.devClaimAmount);
        }

        voteInfo.executed = true;

        voteInfos[voteId - 1] = voteInfo;

        emit ExecuteVote(voteId);
    }

    function _verifyData(
        address _user,
        uint256 _score,
        bytes memory _signature
    ) internal view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(_user, _score));

        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(
            messageHash
        );

        (address signer, ) = ECDSA.tryRecover(ethSignedMessageHash, _signature);

        return (severAddress == signer);
    }

    function _caculateRank(uint256 _score) internal pure returns (uint256) {
        if (_score >= 5e6) {
            return 4;
        } else if (_score >= 3e6) {
            return 3;
        } else if (_score >= 2e6) {
            return 2;
        } else if (_score >= 1e6) {
            return 1;
        }
        return 0;
    }
}
