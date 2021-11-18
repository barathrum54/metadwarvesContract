pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@taha/RewardContract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFT is ERC721Enumerable, Ownable {
    struct Dwarf {
        uint256 mining;
        uint256 luck;
        uint256 stamina;
        uint256 mineCooldown;
        uint256 lastMine;
        uint256 level;
        uint256 experience;
        uint256 nft_type;
    }
    struct Item {
        uint256 miningBonus;
        uint256 luckBonus;
        uint256 staminaBonus;
        uint256 mineCooldownBonus;
        uint256 durability;
        uint256 nft_type;
    }

    uint256 maxSupply = 0;
    mapping(uint256 => Item) private _itemDetails;
    mapping(uint256 => Dwarf) private _dwarfDetails;
    mapping(uint256 => uint256) private levels;
    mapping(uint256 => uint256) private types;
    uint256 levelsIndex = 0;
    address rewardAdress;
    uint256 lastStaminaReplenished;
    uint256 staminaReplenishTime = 30;
    uint256 exp = 100;
    uint256 expMultiplier = 30;
    uint256 randNonce = 0;
    uint256 nextId = 0;

    using SafeMath for uint256;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        maxSupply = 1000;
        lastStaminaReplenished = block.timestamp;
        _initialize();
    }

    function giveExperience(uint256 tokenId, uint256 amount)
        public
        returns (uint256)
    {
        _dwarfDetails[tokenId].experience += amount;
        uint256 requiredExp = requiredExpForNextLevel(
            _dwarfDetails[tokenId].level
        );
        if (_dwarfDetails[tokenId].experience >= requiredExp) {
            levelUp(tokenId);
        }
    }

    function addLevels(uint256 levelAmount) public onlyOwner {
        uint256 i = 0;
        for (i = 0; i < levelAmount; i++) {
            if (expMultiplier > 0) {
                expMultiplier = expMultiplier.sub(1);
            }
            exp = exp.add(((exp / 100) * expMultiplier));
            uint256 a = exp;
            uint256 m = 100;
            exp = ((a + m - 1) / m) * m;
            levels[i] = exp;
            levelsIndex++;
        }
        exp = levels[i];
    }

    function addStatPoint(uint256 tokenId) public returns (uint256) {
        randMod(10);
        uint256 rnd = randMod(10);
        if (rnd > 5) {
            _dwarfDetails[tokenId].mining.add(randMod(3));
            _dwarfDetails[tokenId].luck.add(randMod(2));
        }
        return rnd;
    }

    function returnLevel(uint256 levelIndex) public view returns (uint256) {
        return levels[levelIndex];
    }

    function randMod(uint256 _modulus) internal returns (uint256) {
        randNonce++;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    function levelUp(uint256 tokenId) public {
        _dwarfDetails[tokenId].level++;
        _dwarfDetails[tokenId].experience = 0;
        addStatPoint(tokenId);
    }

    function experienceOf(uint256 tokenId) public view returns (uint256) {
        return _dwarfDetails[tokenId].experience;
    }

    function levelOf(uint256 tokenId) public view returns (uint256) {
        return _dwarfDetails[tokenId].level;
    }

    function requiredExpForNextLevel(uint256 nextLevelIndex)
        public
        view
        returns (uint256)
    {
        return levels[nextLevelIndex];
    }

    function _initialize() internal {
        uint256 totalNft = nextId;
        uint256 i;
        if (lastStaminaReplenished + staminaReplenishTime < block.timestamp) {
            for (i = 0; i < totalNft; i++) {
                _replenishStamina(i);
            }
            lastStaminaReplenished = block.timestamp;
        }
    }

    function _replenishStamina(uint256 tokenId) internal {
        _dwarfDetails[tokenId].stamina++;
    }

    function lastStaminaReplenishedTime() public view returns (uint256) {
        return lastStaminaReplenished;
    }

    function getDwarfDetails(uint256 tokenId)
        public
        view
        returns (Dwarf memory)
    {
        return _dwarfDetails[tokenId];
    }

    function getItemDetails(uint256 tokenId) public view returns (Item memory) {
        return _itemDetails[tokenId];
    }

    function maxSupply_t() public view returns (uint256) {
        return maxSupply;
    }

    function setRewardAdress(address _rewardAdress) external {
        rewardAdress = _rewardAdress;
    }
    
    function mintItem(
        uint256 miningBonus,
        uint256 luckBonus,
        uint256 staminaBonus,
        uint256 mineCooldownBonus
    ) public {
        _itemDetails[nextId] = Item(
            miningBonus,
            luckBonus,
            staminaBonus,
            mineCooldownBonus,
            20,
            2
        );
        types[nextId] = 2;
        _safeMint(msg.sender, nextId);
        nextId++;
        _initialize();
    }

    function mintDwarf(
        uint256 mining,
        uint256 luck,
        uint256 stamina,
        uint256 mineCooldown
    ) public {
        _dwarfDetails[nextId] = Dwarf(
            mining,
            luck,
            stamina,
            mineCooldown,
            block.timestamp,
            0,
            0,
            1
        );
        types[nextId] = 1;
        _safeMint(msg.sender, nextId);
        nextId++;
        _initialize();
    }
    function getTypeOfNft(uint256 id) public view returns(uint256){
        return types[id];
    }
    function totalSupply_t() public view returns (uint256) {
        return nextId;
    }

    function mine(uint256 dwarfId, uint256 itemId) public returns (string memory) {
        _initialize();
        RewardContract rewardContract = RewardContract(rewardAdress);
        uint256 reward = 1000000000000000;
        address userAdress = msg.sender;
        rewardContract.reward(userAdress, reward);

        Dwarf storage dwarf = _dwarfDetails[dwarfId];
        Item storage item = _itemDetails[itemId];
        require(ownerOf(dwarfId) == msg.sender, "you dont own this dwarf");
        require(ownerOf(itemId) == msg.sender, "you dont own this item");
        require(
            dwarf.lastMine + dwarf.mineCooldown < block.timestamp,
            "on cooldown"
        );
        require(dwarf.stamina > 0, "no stamina");
        require(item.durability > 0, "no durability");
        dwarf.lastMine = block.timestamp;
        dwarf.stamina--;
        giveExperience(dwarfId, 200);
        return "Success";
    }
    function _calculateReward(uint256 dwarfId, uint256 itemId) view internal returns (uint256) {
        Dwarf storage dwarf = _dwarfDetails[dwarfId]; 
        Item storage item = _itemDetails[itemId]; 
        uint256 rewardAmount;
        return rewardAmount;
    }
    function getAllTokens() public view returns (uint256[] memory) {
        uint256 totalNft = nextId;
        uint256[] memory result = new uint256[](totalNft);
        uint256 i;
        uint256 resultIndex = 0;
        for (i = 0; i < totalNft; i++) {
            result[resultIndex] = i;
            resultIndex++;
        }
        require(result.length > 0, "no tokens");
        return result;
    }

    function getAllNftOfUser(address user)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(user);
        uint256[] memory result = new uint256[](tokenCount);
        uint256 totalNft = nextId;
        uint256 i;
        uint256 resultIndex = 0;
        for (i = 0; i < totalNft; i++) {
            if (ownerOf(i) == user) {
                result[resultIndex] = i;
                resultIndex++;
            }
        }
        return result;
    }



    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        Dwarf storage dwarf = _dwarfDetails[nextId];
        // require(dwarf.lastMine + dwarf.mineCooldown > block.timestamp);
        _initialize();
    }
}
