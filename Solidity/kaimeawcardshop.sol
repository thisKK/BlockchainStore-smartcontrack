pragma solidity 0.6.3;
pragma experimental ABIEncoderV2;

contract kaimeawcardshop {
    
    event BuyCharacter(address indexed buyer, uint256 characterId); // Event
    event CreateCharacter(address indexed creater, uint256 characterId); // Event
    event ErrorCharacterNotAvailable(address indexed buyer, uint256 characterId); // Event
    event ErrorNotEnoughMoney(address indexed buyer, uint256 characterId); // Event
    
    struct Character {
        uint256 id;
        string name;
        uint256 price;
        CharacterStatus characterStatus;
        address seller;
        address buyer;
        string imgPath;
    }
    
    enum CharacterStatus {Available,Purchased,Unavailable}
    // presonal character have been purchase
    mapping (address => uint256[]) private userCharacters;
    // character storage
    mapping(uint256 => Character) characters;
    uint256[] characterList;
    
    constructor() public {
        characterCounter = 0;
        createCharacter("Anniversary",5.0,"anniversary.jpg");
        createCharacter("Behind",4.0,"behind.jpg");
        createCharacter("Corona",2.0,"corona.png");
        createCharacter("BadBoy",1.0,"badBoy.jpg");
        createCharacter("Democracy",3.0,"democracy.jpg");
        createCharacter("Democrat",5.0,"democrat.png");
        createCharacter("Dinosor",4.0,"dinosor.png");
        createCharacter("HNY",10.0,"hny.jpg");
        createCharacter("Joker",8.0,"joker.png");
        createCharacter("Niranarm",8.0,"niranarm.jpg");
    }

    uint256 characterCounter;
    function getCharacterId() private returns(uint) { return ++characterCounter; }
    
    function isEmpty(string memory _str) pure private returns(bool _isEmpty){
        bytes memory tempEmptyStringTest = bytes(_str); // Uses memory
        if (tempEmptyStringTest.length == 0) {
            return true;
        } else {
            return false;
        }
    }
    
    function createCharacter (string memory _name,uint256 _price,string memory _imgPath) public returns(bool success) {
        require(!isEmpty(_name),"Name must not empty.");
        uint256 characterId = getCharacterId();
        Character memory character = characters[characterId];
        character.id = characterId;
        character.name = _name;
        character.price = _price;
        character.characterStatus = kaimeawcardshop.CharacterStatus.Available;
        character.seller = msg.sender;
        character.imgPath = _imgPath;
        characters[characterId] = character;
        
        characterList.push(characterId);
        emit CreateCharacter(msg.sender, character.id);
        return true;
    }
    
    function getAllCharacterList() public view returns(uint256[] memory _characters){
        return characterList;
    }
    
    function getCharacterById(uint256 _id) private view returns(Character memory character){
        return characters[_id];
    }
    
    function getCharacterStrById(uint256 _id) public view returns(uint256 id,string memory name, uint256 price,string memory status,address seller,address buyer,string memory imgPath ){
        Character memory c = characters[_id];
        string memory statusTemp;
        if(c.characterStatus == CharacterStatus.Available){
            statusTemp = "Available";
        }else if(c.characterStatus == CharacterStatus.Purchased){
            statusTemp = "Purchased";
        }else if(c.characterStatus == CharacterStatus.Purchased){
            statusTemp = "Unavailable";
        }else{
            statusTemp = "unnamed";
        }
        return (c.id,c.name,c.price,statusTemp,c.seller,c.buyer,c.imgPath);
    }
    
    function getMyCharacter() public view returns(uint256[] memory character){
        return userCharacters[msg.sender];
    }
    
    function buyCharacter (uint256 _characterId) public payable returns(bool success){
        Character memory c = getCharacterById(_characterId);
        // require(c.characterStatus == CharacterStatus.Available,"Character not available for sale.");
        // require(msg.value >= c.price,"Not enough money.");
        if(c.characterStatus != CharacterStatus.Available){
            emit ErrorCharacterNotAvailable(msg.sender,_characterId);
            msg.sender.transfer(msg.value);
            return false;
        }
        if(msg.value <= c.price){
            emit ErrorNotEnoughMoney(msg.sender,_characterId);
            msg.sender.transfer(msg.value);
            return false;
        }
        
        c.buyer = msg.sender;
        c.characterStatus = kaimeawcardshop.CharacterStatus.Purchased;
        characters[_characterId] = c;
        userCharacters[msg.sender].push(c.id);
        emit BuyCharacter(msg.sender,c.id);
        return true;
    }
    
}