// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DinosaurNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Dinosaur {
        string name;
        uint256 powerLevel;
    }

    mapping(uint256 => Dinosaur) public dinosaurs;
    IERC20 public eggToken;

    uint256 public constant Threshold = 500;

    event DinosaurCreated(uint256 tokenId, string name, uint256 powerLevel);
    event DinosaurFed(uint256 tokenId, uint256 amount);
    event DinosaurUpgraded(uint256 tokenId, string newName, uint256 newPowerLevel);

    constructor(string memory name, string memory symbol, address eggTokenAddress) ERC721(name, symbol) Ownable(msg.sender) {
        eggToken = IERC20(eggTokenAddress);
    }

    function mintDinosaur(string memory name, uint256 basePowerlevel) public onlyOwner {
        _tokenIds.increment();
        uint256 newDinosaurId = _tokenIds.current();
        dinosaurs[newDinosaurId] = Dinosaur(name, basePowerlevel);
        _mint(msg.sender, newDinosaurId);
        emit DinosaurCreated(newDinosaurId, name, basePowerlevel);
    }

    function feedDinosaur(uint256 tokenId, uint256 amount) public payable {
        require(ownerOf(tokenId) == msg.sender, "You must own the dinosaur");
        require(eggToken.transferFrom(msg.sender, address(this), amount), "Failed to transfer egg");

        Dinosaur storage dino = dinosaurs[tokenId];
        dino.powerLevel += amount;
        emit DinosaurFed(tokenId, amount);

        if (dino.powerLevel >= Threshold) {
            upgradeDinosaur(tokenId);
        }
    }

    function upgradeDinosaur(uint256 tokenId) internal {
        require(ownerOf(tokenId) == msg.sender, "You must own the dinosaur");
        Dinosaur storage oldDino = dinosaurs[tokenId];
        require(oldDino.powerLevel >= Threshold, "Dinosaur power level is not high enough for upgrade.");

        string memory newName = string(abi.encodePacked("Super ", oldDino.name));
        uint256 newPowerLevel = oldDino.powerLevel + 100;

        _burn(tokenId);
        _tokenIds.increment();
        uint256 newDinosaurId = _tokenIds.current();
        dinosaurs[newDinosaurId] = Dinosaur(newName, newPowerLevel);
        _mint(msg.sender, newDinosaurId);

        emit DinosaurUpgraded(newDinosaurId, newName, newPowerLevel);
    }
}
